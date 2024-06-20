{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      with pkgs;
      let
        toolchain-bin = callPackage ./toolchain-bin { };
        osquery = callPackage ./osquery { toolchain = toolchain-bin; };
        osqueryi = {
          type = "app";
          program = "${osquery}/bin/osqueryi";
        };
      in
        {
          packages = {
            inherit osquery toolchain-bin;
            default = osquery;
          };
          checks = {
            inherit osquery;
          };
          apps = {
            inherit osqueryi;
            default = osqueryi;
          };
        });
}
