file(REMOVE_RECURSE
  "libsim.pdb"
  "libsim.so"
)

# Per-language clean rules from dependency scanning.
foreach(lang CXX)
  include(CMakeFiles/sim.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
