{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.typelevelShell.nodejs;
in
{
  options.typelevelShell.nodejs = {
    enable = mkEnableOption "Provide nodejs and yarn";

    package = mkOption {
      type = types.package;
      default = pkgs.nodejs-16_x;
      description = "Package to use for nodejs";
    };
  };

  config = mkIf cfg.enable {
    devshell.packages = [
      cfg.package
      pkgs.yarn
    ];
  };
}
