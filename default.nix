{ system ? builtins.currentSystem
, devshell
}:

{
  mkShell = config: devshell.mkShell {
    imports = [ ./modules/typelevel-shell.nix ];
    inherit config;
  };
}
