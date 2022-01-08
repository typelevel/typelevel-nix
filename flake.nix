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
      forSystem = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              self.overlay
              devshell.overlay
            ];
          };
        in
        {
          devShells = {
            library = pkgs.typelevel-shell.mkShell {
              name = "typelevel-lib-shell";
              typelevel-shell.jdk.package = pkgs.jdk8_headless;
            };
            application = pkgs.typelevel-shell.mkShell {
              name = "typelevel-app-shell";
              typelevel-shell.jdk.package = pkgs.jdk17_headless;
            };
          };
        };
    in
    {
      overlay = import ./overlay.nix;
    } // flake-utils.lib.eachDefaultSystem forSystem;
}
