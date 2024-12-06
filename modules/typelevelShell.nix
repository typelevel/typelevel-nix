{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.typelevelShell;
  defaultMinJDKVersion = minPkg: (
    if (lib.versionAtLeast cfg.jdk.package.version minPkg.version)
    then cfg.jdk.package
    else minPkg
  );
in
{
  imports = [
    ./native.nix
    ./nodejs.nix
  ];

  options.typelevelShell = {
    jdk = {
      package = mkOption {
        type = types.package;
        default = pkgs.jdk17;
      };
      metals = {
        package = mkOption {
          type = types.package;
          default = defaultMinJDKVersion pkgs.jdk17;
        };
      };
      scala-cli = {
        package = mkOption {
          type = types.package;
          default = defaultMinJDKVersion pkgs.jdk17;
        };
      };
    };

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
          { package = pkgs.metals.override { jre = cfg.jdk.metals.package; }; }
          { package = pkgs.scala-cli.override { jre = cfg.jdk.scala-cli.package; }; }
          { package = pkgs.sbt.override { jre = cfg.jdk.package; }; }
        ];

        devshell.motd =
          let
            esc = "";
            orange = "${esc}[38;5;202m";
            reset = "${esc}[0m";
            bold = "${esc}[1m";
            differentVersion = name: pkg: if pkg != cfg.jdk.package then "  ${name} - ${pkg.version}\n" else "";
            metalsJDKVersion = differentVersion "Metals Java" cfg.jdk.metals.package;
            scalaCLIJDKVersion = differentVersion "Scala-cli Java" cfg.jdk.scala-cli.package;
          in
          ''
            ${orange}🔨 Welcome to ${config.devshell.name}${reset}
            $(type -p menu &>/dev/null && menu)

            ${bold}[versions]${reset}

              Java - ${cfg.jdk.package.version}
          '' +
          metalsJDKVersion + scalaCLIJDKVersion +
          optionalString cfg.nodejs.enable "  Node - ${cfg.nodejs.package.version}\n";

        devshell.packages = [
          cfg.jdk.package
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
