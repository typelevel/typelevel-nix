{
  description = "Provides a basic development environment for Typelevel projects";

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
            overlays = [ devshell.overlay ];
          };

          mkTypelevelShell =
            { jdk
            , name ? "typelevel-dev-shell"
            }: pkgs.devshell.mkShell {
              inherit name;

              commands = [
                { package = pkgs.scala-cli; }
                { package = pkgs.sbt.override { jre = jdk; }; }
              ];

              motd =
                let
                  esc = "";
                  orange = "${esc}[38;5;202m";
                  reset = "${esc}[0m";
                  bold = "${esc}[1m";
                in
                ''
                  ${orange}🔨 Welcome to ${name}${reset}
                  $(type -p menu &>/dev/null && menu)

                  ${bold}[versions]${reset}

                    Java - ${jdk.version}
                    Node - ${pkgs.nodejs.version}
                '';

              packages = [
                pkgs.nodejs
                pkgs.yarn
              ];

              env = [
                {
                  name = "JAVA_HOME";
                  value = "${jdk}";
                }
              ];
            };
        in
        {
          devShells = {
            library = mkTypelevelShell {
              name = "typelevel-lib-shell";
              jdk = pkgs.jdk8_headless;
            };
            application = mkTypelevelShell {
              name = "typelevel-app-shell";
              jdk = pkgs.jdk17_headless;
            };
          };
        };
    in
    flake-utils.lib.eachDefaultSystem forSystem;
}
