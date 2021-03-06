{stdenv, fetchFromGitHub, cmake, llvm, lld, clang, device-libs}:
stdenv.mkDerivation rec {
  pname = "comgr";
  version = "3.3.0";
  src = fetchFromGitHub {
    owner = "RadeonOpenCompute";
    repo = "ROCm-CompilerSupport";
    rev = "rocm-${version}";
    sha256 = "03i21jiqykxnkwbqkcb2ay2ss94qm6bk1x42ngha5v7827h1wdzc";
  };
  sourceRoot = "source/lib/comgr";
  nativeBuildInputs = [ cmake ];
  buildInputs = [ llvm lld clang device-libs ];
  
  cmakeFlags = [
    "-DCMAKE_CXX_COMPILER=${clang}/bin/clang++"
    "-DCMAKE_C_COMPILER=${clang}/bin/clang"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DLLVM_TARGETS_TO_BUILD=\"AMDGPU;X86\""
    "-DLLD_INCLUDE_DIRS=${lld.src}/include"
    "-DCMAKE_PREFIX_PATH=${llvm}/lib/cmake/llvm"
    "-DCMAKE_CXX_FLAGS=\"-std=c++17\""
  ];

  # The comgr build tends to link against the static LLVM libraries
  # *and* the dynamic library. Linking against both causes errors
  # about command line options being registered twice. This patch
  # removes the static library linking.
  patchPhase = ''
    sed -e '/^llvm_map_components_to_libnames/,/[[:space:]]*Symbolize)/d' \
        -i CMakeLists.txt
  '';
}
