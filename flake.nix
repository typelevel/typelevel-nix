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
      typelevel-shell = ./modules/typelevel-shell.nix;
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
              imports = [ typelevel-shell ];
              name = "typelevel-lib-shell";
              typelevel-shell.jdk.package = pkgs.jdk8_headless;
            };
            application = pkgs.devshell.mkShell {
              imports = [ typelevel-shell ];
              name = "typelevel-app-shell";
              typelevel-shell.jdk.package = pkgs.jdk17_headless;
            };
          };
        };
    in
    {
      inherit (devshell) overlay;
      inherit typelevel-shell;
    } // flake-utils.lib.eachDefaultSystem forSystem;
}
