add_triton_library(TritonToHIVM
  TritonToHIVM.cpp

  DEPENDS
  TritonToHIVMConversionPassIncGen
  TritonCanonicalizeIncGen

  LINK_LIBS
  BiShengIRHIVMDialect
  MLIRIR
  MLIRPass
  MLIRTransforms
  MLIRSupport
  TritonIR
)
