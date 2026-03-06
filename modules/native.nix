{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.typelevelShell.native;

  clang = if pkgs.stdenv.isLinux then
    pkgs.runCommand "sysrooted-clang" { } ''
      mkdir -p $out/bin
      for bin in clang clang++; do
        cat > $out/bin/$bin <<EOF
#!${pkgs.runtimeShell}
exec "${pkgs.clang}"/bin/$bin --sysroot="${pkgs.glibc.dev}" "\$@"
EOF
        chmod +x $out/bin/$bin
      done
      ''
    else pkgs.clang;
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
      clang
      pkgs.llvmPackages.libcxx
    ] ++ flatten (map (e: [ (getDev e) (getLib e) ]) cfg.libraries);

    env = [
      {
        name = "LIBRARY_PATH";
        prefix = "$DEVSHELL_DIR/lib";
      }
      {
        name = "C_INCLUDE_PATH";
        prefix = "$DEVSHELL_DIR/include";
      }
    ];
  };
}
