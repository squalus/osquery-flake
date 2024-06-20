{ lib
, cmake
, fetchFromGitHub
, fetchurl
, git
, perl
, python3
, toolchain
, stdenvNoCC
, ninja
, autoPatchelfHook
}:

let

  version = "5.12.2";

  src = fetchFromGitHub {
    owner = "osquery";
    repo = "osquery";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-PJrGAqDxo5l6jtQdpTqraR195G6kaLQ2ik08WtlWEmk=";
  };

  # Pull the openssl hash and version out of a cmake file so we can download it instead of cmake
  opensslInfo = stdenvNoCC.mkDerivation {
    name = "openssl-info";
    dontUnpack = true;
    buildPhase = ''
      version=$(gawk 'match($0, /OPENSSL_VERSION "(.*)"/, a) {print a[1]}' < ${src}/libraries/cmake/formula/openssl/CMakeLists.txt)
      sha256=$(gawk 'match($0, /OPENSSL_ARCHIVE_SHA256 "(.*)"/, a) {print a[1]}' < ${src}/libraries/cmake/formula/openssl/CMakeLists.txt)
      echo "{\"version\": \"$version\", \"sha256\": \"$sha256\"}" > $out
    '';
  };

  opensslInfo' = builtins.fromJSON (builtins.readFile opensslInfo);

  opensslArchive = fetchurl {
    url = "https://www.openssl.org/source/openssl-${opensslInfo'.version}.tar.gz";
    inherit (opensslInfo') sha256;
  };

in
stdenvNoCC.mkDerivation rec {
  pname = "osquery";

  inherit src version;

  patches = [
    ./Remove-git-reset.patch
    ./install-paths.patch
  ];

  nativeBuildInputs = [
    cmake
    git
    perl
    python3
    ninja
    autoPatchelfHook
  ];

  configurePhase = ''
    mkdir build
    cd build
    cmake .. \
      -DCMAKE_INSTALL_PREFIX=$out \
      -DOSQUERY_TOOLCHAIN_SYSROOT=${toolchain} \
      -DOSQUERY_VERSION=${version} \
      -DCMAKE_PREFIX_PATH=${toolchain}/usr/lib/cmake \
      -DCMAKE_LIBRARY_PATH=${toolchain}/usr/lib \
      -DOSQUERY_OPENSSL_ARCHIVE_PATH=${opensslArchive} \
      -GNinja
  '';

  postInstall = ''
    rm -rf $out/control
  '';

  passthru = {
    inherit opensslInfo opensslArchive toolchain;
  };

  meta = with lib; {
    description = "A LLVM-based toolchain for Linux designed to build a portable osquery ";
    homepage = "https://github.com/osquery/osquery-toolchain";
    license = with licenses; [ gpl2Only asl20 ];
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [ binaryNativeCode fromSource ];
    maintainers = with maintainers; [ squalus ];
  };
}
