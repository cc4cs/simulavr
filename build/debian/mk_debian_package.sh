#!/bin/bash
set -e

# global settings
PRE_INSTALL_PATH=/home/xeder/simulavr/build/install/usr
PACKAGE_ARCHITECTURE=amd64
PACKAGE_VERSION=1.1.0
BUILD_PATH=/home/xeder/simulavr/build/debian
BASE_PATH=usr
PYTHON_VERSION=3.10
PYTHON_MAJOR_VERSION=3

# package name and filename
PACKAGE_NAME="$1"
PACKAGE=${PACKAGE_NAME}_${PACKAGE_VERSION}_${PACKAGE_ARCHITECTURE}.deb

function copy_doc_structure() {
  D=${BASE_PATH}/share/doc/$1
  mkdir -p $D
  chmod g-w ${BASE_PATH}/share ${BASE_PATH}/share/doc ${BASE_PATH}/share/doc/$1
  cp -r ${PRE_INSTALL_PATH}/share/doc/common/* $D
  chmod 644 $D/*
}

function make_libsim_structure() {
  # create directory structure
  mkdir ${PACKAGE_NAME}
  pushd ${PACKAGE_NAME}
  mkdir -p ${BASE_PATH}/lib
  chmod -R g-w ${BASE_PATH}
  popd

  # copy files
  pushd ${PACKAGE_NAME}
  cp ${PRE_INSTALL_PATH}/lib/libsim.so ${BASE_PATH}/lib
  strip ${BASE_PATH}/lib/libsim.so
  chmod 644 ${BASE_PATH}/lib/libsim.so
  copy_doc_structure ${PACKAGE_NAME}
  popd

  # create control files
  pushd ${PACKAGE_NAME}
  mkdir DEBIAN
  cp ../${PACKAGE_NAME}.control DEBIAN/control
  chmod 755 DEBIAN/control
  cp ../${PACKAGE_NAME}.triggers DEBIAN/triggers
  chmod 644 DEBIAN/triggers
  popd
}

function make_simulavr_structure() {
  # create directory structure
  mkdir ${PACKAGE_NAME}
  pushd ${PACKAGE_NAME}
  mkdir -p ${BASE_PATH}/bin
  mkdir -p ${BASE_PATH}/share/info
  mkdir -p ${BASE_PATH}/share/man/man1
  chmod -R g-w ${BASE_PATH}
  popd

  # copy files
  pushd ${PACKAGE_NAME}
  cp ${PRE_INSTALL_PATH}/bin/simulavr ${BASE_PATH}/bin
  strip ${BASE_PATH}/bin/simulavr
  chmod 755 ${BASE_PATH}/bin/simulavr
  cp ${PRE_INSTALL_PATH}/share/info/simulavr.info.gz ${BASE_PATH}/share/info
  chmod 644 ${BASE_PATH}/share/info/simulavr.info.gz
  cp ${PRE_INSTALL_PATH}/share/man/man1/simulavr.1.gz ${BASE_PATH}/share/man/man1
  chmod 644 ${BASE_PATH}/share/man/man1/simulavr.1.gz
  copy_doc_structure ${PACKAGE_NAME}
  popd

  # create control files
  pushd ${PACKAGE_NAME}
  mkdir DEBIAN
  cp ../${PACKAGE_NAME}.control DEBIAN/control
  chmod 755 DEBIAN/control
  popd
}

function make_vpi_structure() {
  # create directory structure
  mkdir ${PACKAGE_NAME}
  pushd ${PACKAGE_NAME}
  mkdir -p ${BASE_PATH}/lib/simulavr
  chmod -R g-w ${BASE_PATH}
  popd

  # copy files
  pushd ${PACKAGE_NAME}
  cp ${PRE_INSTALL_PATH}/lib/simulavr/avr.vpi ${BASE_PATH}/lib/simulavr
  strip ${BASE_PATH}/lib/simulavr/avr.vpi
  chmod 644 ${BASE_PATH}/lib/simulavr/avr.vpi
  copy_doc_structure ${PACKAGE_NAME}
  popd

  # create control files
  pushd ${PACKAGE_NAME}
  mkdir DEBIAN
  cp ../${PACKAGE_NAME}.control DEBIAN/control
  chmod 755 DEBIAN/control
  popd
}

function make_python_structure() {
  if [ "${PYTHON_MAJOR_VERSION}" = "3" ]; then
    PYTHON_VERSION_NAME=python${PYTHON_MAJOR_VERSION}
  else
    PYTHON_VERSION_NAME=python${PYTHON_VERSION}
  fi
  PYTHON_MODULE_PATH=${BASE_PATH}/lib/${PYTHON_VERSION_NAME}/dist-packages
  
  # create directory structure
  mkdir ${PACKAGE_NAME}
  pushd ${PACKAGE_NAME}
  mkdir -p ${PYTHON_MODULE_PATH}
  chmod -R g-w ${BASE_PATH}
  popd

  # copy files
  pushd ${PACKAGE_NAME}
  cp ${BUILD_PATH}/../pysimulavr/build/lib*/* ${PYTHON_MODULE_PATH}
  test -f ${BUILD_PATH}/../pysimulavr/pysimulavr.py && cp ${BUILD_PATH}/../pysimulavr/pysimulavr.py ${PYTHON_MODULE_PATH}
  strip ${PYTHON_MODULE_PATH}/*.so
  chmod 644 ${PYTHON_MODULE_PATH}/*
  copy_doc_structure ${PACKAGE_NAME}
  popd

  # create control files
  pushd ${PACKAGE_NAME}
  mkdir DEBIAN
  cp ../${PACKAGE_NAME}.control DEBIAN/control
  chmod 755 DEBIAN/control
  cp ../${PACKAGE_NAME}.postinst DEBIAN/postinst
  chmod 755 DEBIAN/postinst
  cp ../${PACKAGE_NAME}.prerm DEBIAN/prerm
  chmod 755 DEBIAN/prerm
  popd
}

function make_tcl_structure() {
  # create directory structure
  mkdir ${PACKAGE_NAME}
  pushd ${PACKAGE_NAME}
  mkdir -p ${BASE_PATH}/lib/simulavr
  chmod -R g-w ${BASE_PATH}
  popd

  # copy files
  pushd ${PACKAGE_NAME}
  cp ${PRE_INSTALL_PATH}/lib/libsimulavr.so ${BASE_PATH}/lib/simulavr
  strip ${BASE_PATH}/lib/simulavr/libsimulavr.so
  chmod 644 ${BASE_PATH}/lib/simulavr/libsimulavr.so
  copy_doc_structure ${PACKAGE_NAME}
  popd

  # create control files
  pushd ${PACKAGE_NAME}
  mkdir DEBIAN
  cp ../${PACKAGE_NAME}.control DEBIAN/control
  chmod 755 DEBIAN/control
  popd
}

function make_dev_structure() {
  # create directory structure
  mkdir ${PACKAGE_NAME}
  pushd ${PACKAGE_NAME}
  mkdir -p ${BASE_PATH}/include/simulavr
  chmod -R g-w ${BASE_PATH}
  popd

  # copy files
  pushd ${PACKAGE_NAME}
  cp -r ${PRE_INSTALL_PATH}/include/* ${BASE_PATH}/include/simulavr
  chmod -R g-w ${BASE_PATH}/include/simulavr/*
  copy_doc_structure ${PACKAGE_NAME}
  popd

  # create control files
  pushd ${PACKAGE_NAME}
  mkdir DEBIAN
  cp ../${PACKAGE_NAME}.control DEBIAN/control
  chmod 755 DEBIAN/control
  popd
}

# clean package build directory
rm -rf ${PACKAGE_NAME}

# create package build directory
if [ "${PACKAGE_NAME}" == "libsim" ]; then
  make_libsim_structure
elif [ "${PACKAGE_NAME}" == "simulavr" ]; then
  make_simulavr_structure
elif [ "${PACKAGE_NAME}" == "simulavr-vpi" ]; then
  make_vpi_structure
elif [ "${PACKAGE_NAME}" == "python-simulavr" ]; then
  make_python_structure
elif [ "${PACKAGE_NAME}" == "python3-simulavr" ]; then
  make_python_structure
elif [ "${PACKAGE_NAME}" == "simulavr-tcl" ]; then
  make_tcl_structure
elif [ "${PACKAGE_NAME}" == "simulavr-dev" ]; then
  make_dev_structure
else
  echo "error: unknown debian package name: ${PACKAGE_NAME}"
  exit 1
fi

# build package
fakeroot dpkg -b ${PACKAGE_NAME} ${BUILD_PATH}/$PACKAGE

# exit
exit 0

# EOF
