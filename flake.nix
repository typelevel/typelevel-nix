{
  description = "Virtual environments for Scala projects";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = github:edolstra/flake-compat;
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, devshell, ... }:
    let
      typelevelShell = ./modules/typelevelShell.nix;
      forSystem = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlay ];
          };
        in
        {
          devShells = {
            library = pkgs.devshell.mkShell {
              imports = [ typelevelShell ];
              name = "typelevel-lib-shell";
              typelevelShell.jdk.package = pkgs.jdk8_headless;
              typelevelShell.nodejs.enable = true;
            };
            application = pkgs.devshell.mkShell {
              imports = [ typelevelShell ];
              name = "typelevel-app-shell";
              typelevelShell.jdk.package = pkgs.jdk17_headless;
            };
          };
        };
    in
    {
      inherit (devshell) overlay;
      inherit typelevelShell;
    } // flake-utils.lib.eachDefaultSystem forSystem;
}
