{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.typelevelShell.native;
in
{
  options.typelevelShell.native = {
    enable = mkEnableOption "Provide scala-native environment";

    libraries = mkOption {
      type = types.listOf types.package;
      default = [ pkgs.zlib ];
      description = "A list of split-output libraries to include (dev output) and link (lib output)";
    };
  };

  config = mkIf cfg.enable {
    devshell.packages = [
      pkgs.clang
      pkgs.llvmPackages.libcxxabi
    ] ++ flatten (map (e: [ (getDev e) (getLib e) ]) cfg.libraries);

    env = [
      {
        name = "LD_LIBRARY_PATH";
        prefix = "$DEVSHELL_DIR/lib";
      }
      {
        name = "C_INCLUDE_PATH";
        prefix = "$DEVSHELL_DIR/include";
      }
      {
        name = "LLVM_BIN";
        prefix = "${pkgs.clang}/bin";
      }
    ];
  };
}
