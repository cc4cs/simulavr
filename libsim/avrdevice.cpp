/*
 ****************************************************************************
 *
 * simulavr - A simulator for the Atmel AVR family of microcontrollers.
 * Copyright (C) 2001, 2002, 2003   Klaus Rudolph       
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 ****************************************************************************
 *
 *  $Id$
 */

#include <limits>
#include <assert.h>
#include <stdio.h> 
#include <iostream>


#include "avrdevice.h"
#include "traceval.h"
#include "helper.h"
#include "irqsystem.h"  //GetNewPc
#include "systemclock.h"
#include "avrerror.h"
#include "avrmalloc.h"
#include "avrreadelf.h"
#include "flash.h"
#include "hwsreg.h"
#include "hwstack.h"

const unsigned int AvrDevice::registerSpaceSize = 32;
const unsigned int AvrDevice::totalIoSpace = 0x10000;
long instructions = 0; // tracks how many assembly instructions are executed by the simulator

long AvrDevice::GetExecutedInstructions() {
    return instructions;
}

void AvrDevice::AddToResetList(Hardware *hw) {
    if(find(hwResetList.begin(), hwResetList.end(), hw) == hwResetList.end())
        hwResetList.push_back(hw);
}

void AvrDevice::AddToCycleList(Hardware *hw) {
    if(find(hwCycleList.begin(), hwCycleList.end(), hw) == hwCycleList.end())
        hwCycleList.push_back(hw);
}
        
void AvrDevice::RemoveFromCycleList(Hardware *hw) {
    std::vector<Hardware*>::iterator element;
    element=find(hwCycleList.begin(), hwCycleList.end(), hw);
    if(element != hwCycleList.end())
        hwCycleList.erase(element);
}

void AvrDevice::Load(const char* fname) {
    actualFilename = fname;
    ELFLoad(this);
}

void AvrDevice::SetClockFreq(SystemClockOffset nanosec) {
   clockFreq = nanosec;
}

SystemClockOffset AvrDevice::GetClockFreq() {
    return clockFreq;
}

Pin *AvrDevice::GetPin(const char *name) {
    Pin *ret = allPins[name];
    if(!ret)
        avr_error("unknown Pin requested! -> %s is not available", name);
    return ret;
}

AvrDevice::~AvrDevice() {
    if (dumpManager) {
        // unregister device on DumpManager
        dumpManager->unregisterAvrDevice(this);
    }
    
    // delete invalid RW memory cells on shadow store + shadow store self
    unsigned size = totalIoSpace - registerSpaceSize - iRamSize - eRamSize;
    for(unsigned idx = 0; idx < size; idx++)
        delete invalidRW[idx];
    delete [] invalidRW;
    
    // delete Ram cells and registers
    for(unsigned idx = 0; idx < registerSpaceSize; idx++)
        delete rw[idx];
    size = registerSpaceSize + ioSpaceSize + iRamSize + eRamSize;
    for(unsigned idx = (registerSpaceSize + ioSpaceSize); idx < size; idx++)
        delete rw[idx];
    
    // delete rw and other allocated objects
    delete Flash;
    delete statusRegister;
    delete status;
    delete [] rw;
    delete data;
    delete fuses;
    delete lockbits;
}

/*! To ease debugging, also supply the option to have the PC*2 in the trace
 * output file. This is also the format the other normal tracing will output
 * addresses and the format avr-objdump produces disassemblies in. */
class TwiceTV : public TraceValue {
public:
    TwiceTV(const std::string &_name, TraceValue *_ref)
        : TraceValue(_ref->bits()+1, _name), ref(_ref) {}
    
    virtual void cycle() {
        change(ref->value()*2);
        set_written();
    }
private:
    TraceValue *ref; // Reference value that will be doubled
};


AvrDevice::AvrDevice(unsigned int _ioSpaceSize,
                     unsigned int IRamSize,
                     unsigned int ERamSize,
                     unsigned int flashSize,
                     unsigned int pcSize):
    TraceValueRegister(),
    ioSpaceSize(_ioSpaceSize),
    iRamSize(IRamSize),
    eRamSize(ERamSize),
    devSignature(std::numeric_limits<unsigned int>::max()),
    PC_size(pcSize),
    rampz(nullptr),
    eind(nullptr),
    abortOnInvalidAccess(false),
    coreTraceGroup(this),
    deferIrq(false),
    newIrqPc(0xffffffff),
    v_supply(5.0),  // assume 5V supply voltage
    v_bandgap(1.1), // assume a bandgap ref unit with 1.1V
    flagIWInstructions(true),
    flagJMPInstructions(true),
    flagIJMPInstructions(true),
    flagEIJMPInstructions(false),
    flagLPMInstructions(true),
    flagELPMInstructions(false),
    flagMULInstructions(true),
    flagMOVWInstruction(true),
    flagTiny10(false),
    flagTiny1x(false),
    flagXMega(false),
    wado(nullptr)
{
    dumpManager = DumpManager::Instance();
    dumpManager->registerAvrDevice(this);
    DebugRecentJumpsIndex = 0;
    
    //TraceValue* pc_tracer=trace_direct(&coreTraceGroup, "PC", &cPC);
    //coreTraceGroup.RegisterTraceValue(new TwiceTV(coreTraceGroup.GetTraceValuePrefix()+"PCb",  pc_tracer));
    trace_on = 0;
    
    fuses = new AvrFuses;
    lockbits = new AvrLockBits;
    data = new Data; //only the symbol container

    // memory space for all RW-Memory addresses + shadow store for invalid cells
    unsigned invalidSize = totalIoSpace - registerSpaceSize - IRamSize - ERamSize; 
    rw = new RWMemoryMember* [totalIoSpace];
    invalidRW = new RWMemoryMember* [invalidSize];
    
    // get data address mask, where significant bits are set
    {
        unsigned temp = registerSpaceSize + IRamSize + ERamSize + ioSpaceSize;
        dataAddressMask = 0;
        while(temp > 0) {
            dataAddressMask <<= 1;
            dataAddressMask += 1;
            temp >>= 1;
        }
    }

    // the status register is generic to all devices
    status = new HWSreg();
    if(status == nullptr)
        avr_error("Not enough memory for HWSreg in AvrDevice::AvrDevice");
    statusRegister = new RWSreg(&coreTraceGroup, status);
    if(statusRegister == nullptr)
        avr_error("Not enough memory for RWSreg in AvrDevice::AvrDevice");

    // placeholder for SPM register
    spmRegister = nullptr;
    
    // create the flash area with specified size
    Flash = new AvrFlash(this, flashSize);
    if(Flash == nullptr)
        avr_error("Not enough memory for Flash in AvrDevice::AvrDevice");

    // create all registers
    unsigned currentOffset = 0;
    unsigned invalidRWOffset = 0;

    for(unsigned ii = 0; ii < registerSpaceSize; ii++) {
        rw[currentOffset] = new RAM(&coreTraceGroup, "r", ii, registerSpaceSize);
        if(rw[currentOffset] == nullptr)
            avr_error("Not enough memory for registers in AvrDevice::AvrDevice");
        currentOffset++;
    }      

    /* Create invalid registers in I/O space which will fail on access (to
       make simulavr more robust!)  In all well implemented devices, these
       should be overwritten by the particular device type. But accessing such
       a register will at least notify the user that there is an unimplemented
       feature or reserved register. */
    for(unsigned ii = 0; ii < ioSpaceSize; ii++) {
        invalidRW[invalidRWOffset] = new InvalidMem(this, currentOffset);
        if(invalidRW[invalidRWOffset] == nullptr)
            avr_error("Not enough memory for io space in AvrDevice::AvrDevice");
        rw[currentOffset] = invalidRW[invalidRWOffset];
        currentOffset++;
        invalidRWOffset++;
    }

    // create the internal ram handlers 
    for(unsigned ii = 0; ii < IRamSize; ii++ ) {
        rw[currentOffset] = new RAM(&coreTraceGroup, "IRAM", ii, IRamSize);
        if(rw[currentOffset] == nullptr)
            avr_error("Not enough memory for IRAM in AvrDevice::AvrDevice");
        currentOffset++;
    }

    // create the external ram handlers, TODO: make the configuration from
    // mcucr available here
    for(unsigned ii = 0; ii < ERamSize; ii++ ) {
        rw[currentOffset] = new RAM(&coreTraceGroup, "ERAM", ii, ERamSize);
        if(rw[currentOffset] == nullptr)
            avr_error("Not enough memory for io space in AvrDevice::AvrDevice");
        currentOffset++;
    }

    assert(currentOffset<=totalIoSpace);
    // fill the rest of the address space with error handlers
    for(; currentOffset < totalIoSpace; currentOffset++, invalidRWOffset++) {
        invalidRW[invalidRWOffset] = new InvalidMem(this, currentOffset);
        if(invalidRW[invalidRWOffset] == nullptr)
            avr_error("Not enough memory for fill address space in AvrDevice::AvrDevice");
        rw[currentOffset] = invalidRW[invalidRWOffset];
    }
}

// do a single core step, (0)->a real hardware step, (1) until the uC finish the opcode!
int AvrDevice::Step(bool &untilCoreStepFinished, SystemClockOffset *nextStepIn_ns) {
    if(cpuCycles <= 0)
        cPC=PC;

    if(trace_on == 1) {
        traceOut << actualFilename << " ";
        traceOut << HexShort(cPC << 1) << std::dec << ": ";

        std::string sym(Flash->GetSymbolAtAddress(cPC));
        traceOut << sym << " ";
        for(int len = sym.length(); len < 30;len++)
            traceOut << " " ;
    }

    bool hwWait = false;
    for(unsigned i = 0; i < hwCycleList.size(); i++) {
        Hardware * p = hwCycleList[i];
        if(p->CpuCycle() > 0)
            hwWait = true;
    }

    if(hwWait) {
        if(trace_on)
            traceOut << "CPU-Hold by IO-Hardware ";
    } else if(cpuCycles <= 0) {

            //check for enabled breakpoints here
            if(BP.end() != find(BP.begin(), BP.end(), PC)) {
                if(trace_on)
                    traceOut << "Breakpoint found at 0x" << std::hex << PC << std::dec << std::endl;
                if(nextStepIn_ns != nullptr)
                    *nextStepIn_ns = clockFreq;
                untilCoreStepFinished = !(cpuCycles > 0);
                dumpManager->cycle();
                return BREAK_POINT;
            }

            if(EP.end() != find(EP.begin(), EP.end(), PC)) {
                avr_message("Simulation finished!");
                SystemClock::Instance().Stop();
                dumpManager->cycle();
                return 0;
            }

            if(deferIrq) {
                /* Every IRQ is delayed of one cycle. Normally this happens (see datasheet)
                 * only after a SEI instruction or after a RETI. But because of
                 * "pipelining" (first cycle is fetch instruction, second is processing)
                 * it's never possible to raise an interrupt with a instruction from
                 * inside the controller immediately after fetching (and processing here
                 * in simulavr) this instruction. Only a external source or peripherals
                 * could do that. Hold this in mind, if you try to measure processing time!
                 */
                deferIrq = false;

                /* Attention: If now the I flag was cleaned, do not enter to the irq, CLI 
                 * will stop execution of irq handling immediatly
                 */

                /* TODO: The handling of IRQ was correct in older versions!
                 * Please refactor the Step method to get it simpler and faster.
                 * Checking multiple times on I flag and pending IRQs looks very ugly here!
                 */
                if ( status->I == 1 )
                {
                    newIrqPc = irqSystem->GetNewPc(actualIrqVector);

                    if ( newIrqPc != 0xffffffff )
                    {
                        if(trace_on)
                            traceOut << "IRQ DETECTED: VectorAddr: " << newIrqPc ;

                        irqSystem->IrqHandlerStarted(actualIrqVector);    //what vector we raise?
                        Funktor* fkt = new IrqFunktor(irqSystem, &HWIrqSystem::IrqHandlerFinished, actualIrqVector);
                        stack->SetReturnPoint(stack->GetStackPointer(), fkt);
                        stack->PushAddr(PC);
                        cpuCycles = 4; //push needs 4 cycles! (on external RAM +2, this is handled from HWExtRam!)
                        status->I = 0; //irq started so remove I-Flag from SREG
                        PC = newIrqPc - 1;   //we add a few lines later 1 so we sub here 1 :-)
                    }
                }

            } 
            
            if( (!deferIrq ) && (status->I == 1) ) {
                if ( irqSystem->IsIrqPending() )
                {
                    deferIrq = true; // do always one instruction before entering irq vect
                }
            }

            if(cpuCycles <= 0) {
                if((unsigned int)(PC << 1) >= (unsigned int)Flash->GetSize() ) {
                    std::ostringstream os;
                    os << actualFilename << " Simulation runs out of Flash Space at " << std::hex << (PC << 1);
                    std::string s = os.str();
                    if(trace_on)
                        traceOut << s << std::endl;
                    avr_error("%s", s.c_str());
                }

                DecodedInstruction *de = (Flash->GetInstruction(PC));

                if(trace_on) {
                    cpuCycles = de->Trace();
                } else {
                    cpuCycles = (*de)(); 
                    instructions++;
                    // std::cout << "instr: " << typeid((*de)).name()  << " lines: " << lines << '\n';
                }
                // report changes on status
                statusRegister->trigger_change();
            }

            PC++;
            cpuCycles--;
    } else { //cpuCycles>0
        if(trace_on == 1)
            traceOut << "CPU-waitstate";
        cpuCycles--;
    }

    if(nextStepIn_ns != nullptr)
        *nextStepIn_ns = clockFreq;

    if(trace_on == 1) {
        traceOut << std::endl;
        sysConHandler.TraceNextLine();
    }

    untilCoreStepFinished = !((cpuCycles > 0) || hwWait);
    dumpManager->cycle();
    return (cpuCycles < 0) ? cpuCycles : 0;
}

void AvrDevice::Reset() {
    cPC = PC = fuses->GetResetAddr();

    std::vector<Hardware *>::iterator ii;
    for(ii= hwResetList.begin(); ii != hwResetList.end(); ii++)
        (*ii)->Reset();

    *status = 0;

    // init the old static vars from Step()
    cpuCycles = 0;
}

void AvrDevice::DeleteAllBreakpoints() {
    BP.erase(BP.begin(), BP.end());
}

void AvrDevice::SetDeviceNameAndSignature(const std::string &name, unsigned int signature) {
    devName = name;
    devSignature = signature;
}

void AvrDevice::ReplaceIoRegister(unsigned int offset, RWMemoryMember *newMember) {
    if (offset >= ioSpaceSize + registerSpaceSize)
        avr_error("Could not replace register in non existing IoRegisterSpace");
    rw[offset] = newMember;
}

bool AvrDevice::ReplaceMemRegister(unsigned int offset, RWMemoryMember *newMember) {
    if(offset < totalIoSpace) {
        rw[offset] = newMember;
        return true;
    }
    return false;
}

RWMemoryMember* AvrDevice::GetMemRegisterInstance(unsigned int offset) {
    if(offset < totalIoSpace)
        return rw[offset];
    return nullptr;
}

void AvrDevice::RegisterTerminationSymbol(const char *symbol) {
    unsigned int epa = Flash->GetAddressAtSymbol(symbol);
    EP.push_back(epa);
}

void AvrDevice::DebugOnJump()
{
    const int COUNT = sizeof DebugRecentJumps / sizeof DebugRecentJumps[0];
    DebugRecentJumpsIndex = (DebugRecentJumpsIndex + 1) % COUNT;
    DebugRecentJumps[DebugRecentJumpsIndex] = PC * 2;
    int next = (DebugRecentJumpsIndex + 1) % COUNT;
    DebugRecentJumps[next] = -1;
}

unsigned char AvrDevice::GetRWMem(unsigned addr) {
    if(addr >= GetMemTotalSize())
        return 0;
    return *(rw[addr]);
}

bool AvrDevice::SetRWMem(unsigned addr, unsigned char val) {
    if(addr >= GetMemTotalSize())
        return false;
    *(rw[addr]) = val;
    return true;
}

unsigned char AvrDevice::GetCoreReg(unsigned addr) {
    assert(addr < registerSpaceSize);
    return *(rw[addr]);
}

bool AvrDevice::SetCoreReg(unsigned addr, unsigned char val) {
    assert(addr < registerSpaceSize);
    *(rw[addr]) = val;
    return true;
}

unsigned char AvrDevice::GetIOReg(unsigned addr) {
    assert(addr < ioSpaceSize);  // callers do use 0x00 base, not 0x20
    return *(rw[addr + registerSpaceSize]);
}

bool AvrDevice::SetIOReg(unsigned addr, unsigned char val) {
    assert(addr < ioSpaceSize);  // callers do use 0x00 base, not 0x20
    *(rw[addr + registerSpaceSize]) = val;
    return true;
}

bool AvrDevice::SetIORegBit(unsigned addr, unsigned bitaddr) {
    assert(addr < 0x20);  // only first 32 IO registers are bit-settable
    (rw[addr + registerSpaceSize])->set_bit( bitaddr );
    return true;
}

bool AvrDevice::ClearIORegBit( unsigned addr, unsigned bitaddr ) {
    assert(addr < 0x20);  // only first 32 IO registers are bit-settable
    (rw[addr + registerSpaceSize])->clear_bit( bitaddr );
    return true;
}

unsigned AvrDevice::GetRegX(void) {
    // R27:R26
    return (*(rw[27]) << 8) + *(rw[26]);
}

unsigned AvrDevice::GetRegY(void) {
    // R29:R28
    return (*(rw[29]) << 8) + *(rw[28]);
}

unsigned AvrDevice::GetRegZ(void) {
    // R31:R30
    return (*(rw[31]) << 8) + *(rw[30]);
}

// EOF
