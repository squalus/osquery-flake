{ stdenv
, lib
, autoPatchelfHook
}:
let
  version = "1.1.0";
  dist = {
    "x86_64-linux" = {
      url = "https://github.com/osquery/osquery-toolchain/releases/download/${version}/osquery-toolchain-${version}-x86_64.tar.xz";
      sha256 = "sha256:1j88qg9g27s4py3bx6a18pi1rfmhwl36wkp6wgxf8xxlqr3s9dwa";
    };
    "aarch64-linux" = {
      url = "https://github.com/osquery/osquery-toolchain/releases/download/${version}/osquery-toolchain-${version}-aarch64.tar.xz";
      sha256 = "sha256:0p0ji5fmdajazfdq2dq24dh3h16vp2pw3s518840isjf1gs722bi";
    };
  };
in

stdenv.mkDerivation {
  name = "osquery-toolchain-bin";
  inherit version;
  src = fetchTarball dist.${stdenv.hostPlatform.system};
  nativeBuildInputs = [ autoPatchelfHook ];
  installPhase = ''
    mkdir $out
    cp -r * $out
  '';
  meta = with lib; {
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = with licenses; [ gpl2Only asl20 ];
  };
}
