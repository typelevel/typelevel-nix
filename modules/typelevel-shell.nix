{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.typelevel-shell;
in
{
  options.typelevel-shell = {
    jdk = {
      package = mkOption {
        type = types.package;
        default = pkgs.jdk17;
      };
    };
  };

  config =
    let
      jdk = config.typelevel-shell.jdk.package;
    in
    {
      commands = [
        { package = pkgs.scala-cli; }
        { package = pkgs.sbt.override { jre = jdk; }; }
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

            Java - ${jdk.version}
            Node - ${pkgs.nodejs.version}
        '';

      devshell.packages = [
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
}
