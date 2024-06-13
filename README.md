## osquery-flake

From-source Nix build for [osquery](https://github.com/osquery/osquery)

### Toolchain

osquery is built using [osquery-toolchain](https://github.com/osquery/osquery-toolchain).

osquery-toolchain uses LLVM 9. From testing, the newer versions of dependencies available in nixpkgs do not work to build osquery. So the osquery-toolchain is used instead of a nixpkgs-provided toolchain.

The oquery-toolchain is not easy to reproduce, so the binary distribution is used. Future work could involve building this toolchain from source code in a Nix environment.

### Run osqueryi

`nix run github:squalus/osquery-flake`
