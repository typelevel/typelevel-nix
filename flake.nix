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
          scala-cli-override = final: prev:
            {
              scala-cli =
                if system == "aarch64-darwin"
                then
                  let x86Packages = import nixpkgs { system = "x86_64-darwin"; }; in
                  # Using x86_64's scala-cli, but a native JVM for optimal performance
                    # (only the CLI will be emulated with Rosetta, whereas the bloop server will not)
                  x86Packages.scala-cli.override { inherit (final) jre; }
                else prev.scala-cli;
            };

          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              self.overlay
              scala-cli-override
              (import ./overlay.nix)
            ];
          };
        in
        {
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
        };
    in
    {
      inherit (devshell) overlay;
      inherit typelevelShell;
    } // flake-utils.lib.eachDefaultSystem forSystem;
}
