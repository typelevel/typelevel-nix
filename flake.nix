{
  description = "Provides a basic development environment for Typelevel projects";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixpkgs-unstable;
    flake-utils.url = github:numtide/flake-utils;
    flake-compat = {
      url = github:edolstra/flake-compat;
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      forSystem = system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          mkTypelevelShell = { jdk }: pkgs.mkShell {
            name = "typelevel-dev-shell";
            buildInputs = [
              pkgs.git
              pkgs.scala-cli

              # JVM
              jdk
              pkgs.sbt

              # Scala.js
              pkgs.nodejs
              pkgs.yarn
            ];
            shellHook = ''
              JAVA_HOME="${jdk}"
            '';
          };
        in
        {
          devShells = {
            library = mkTypelevelShell {
              jdk = pkgs.jdk8_headless;
            };
            application = mkTypelevelShell {
              jdk = pkgs.jdk17_headless;
            };
          };
        };
    in
    flake-utils.lib.eachDefaultSystem forSystem;
}
