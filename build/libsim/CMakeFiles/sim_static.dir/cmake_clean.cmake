file(REMOVE_RECURSE
  "libsim_static.a"
  "libsim_static.pdb"
)

# Per-language clean rules from dependency scanning.
foreach(lang CXX)
  include(CMakeFiles/sim_static.dir/cmake_clean_${lang}.cmake OPTIONAL)
endforeach()
