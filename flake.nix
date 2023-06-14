{
  description = "Virtual environments for Scala projects";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    devshell.url =
      "github:numtide/devshell?rev=3e0e60ab37cd0bf7ab59888f5c32499d851edb47";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, devshell, ... }:
    let
      typelevelShell = ./modules/typelevelShell.nix;

      systems = [
        "aarch64-darwin"
        # TODO no scala-cli
        # "aarch64-linux"
        # TODO jdk17 refers to openjdk-headless-16
        # "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      forSystem = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlay (import ./overlay.nix) ];
          };

          devShells = {
            library = pkgs.devshell.mkShell {
              imports = [ typelevelShell ];
              name = "typelevel-lib-shell";
              typelevelShell.jdk.package = pkgs.jdk8_headless;
              typelevelShell.nodejs.enable = true;
              typelevelShell.native.enable = true;
            };
            application = pkgs.devshell.mkShell {
              imports = [ typelevelShell ];
              name = "typelevel-app-shell";
              typelevelShell.jdk.package = pkgs.jdk17_headless;
            };
          };
        in {
          inherit devShells;
          checks = devShells;
        };
    in {
      inherit typelevelShell;
      overlay = devshell.overlays.default;
    } // flake-utils.lib.eachSystem systems forSystem;
}
