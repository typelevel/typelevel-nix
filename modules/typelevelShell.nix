{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.typelevelShell;
in
{
  options.typelevelShell = {
    jdk = {
      package = mkOption {
        type = types.package;
        default = pkgs.jdk17;
      };
    };

    nodejs.enable = mkEnableOption "Provide nodejs and yarn";

    sbtMicrosites = {
      enable = mkEnableOption "Add support for sbt-microsites";
      siteDir = mkOption {
        type = types.path;
        description = "Path to your microsite module. Should have a Gemfile, Gemfile.lock, and gemset.nix";
      };
    };
  };

  config =
    let
      main = {
        commands = [
          {
            package = pkgs.metals.override {
              jdk = cfg.jdk.package;
              jre = cfg.jdk.package;
            };
          }
          { package = pkgs.scala-cli; }
          { package = pkgs.sbt.override { jre = cfg.jdk.package; }; }
        ];

        devshell.motd =
          let
            esc = "";
            orange = "${esc}[38;5;202m";
            reset = "${esc}[0m";
            bold = "${esc}[1m";
          in
          ''
            ${orange}🔨 Welcome to ${config.devshell.name}${reset}
            $(type -p menu &>/dev/null && menu)

            ${bold}[versions]${reset}

              Java - ${cfg.jdk.package.version}
          '' + optionalString cfg.nodejs.enable "  Node - ${pkgs.nodejs.version}\n";

        devshell.packages = [
          cfg.jdk.package
        ] ++ optionals cfg.nodejs.enable [
          pkgs.nodejs
          pkgs.yarn
        ];

        env = [
          {
            name = "JAVA_HOME";
            value = "${cfg.jdk.package}";
          }
        ];
      };

      microsites = let
        gems = pkgs.bundlerEnv {
          name = "sbt-microsite-env";
          inherit (pkgs) ruby;
          gemdir = cfg.sbtMicrosites.siteDir;
        };
      in mkIf cfg.sbtMicrosites.enable {
        commands = [{
          name = "jekyll";
          command = "${gems}/bin/jekyll $@";
          help = "Runs jekyll with your sbt-microsites config";
        }];
      };
    in
      mkMerge [ main microsites ];
}
