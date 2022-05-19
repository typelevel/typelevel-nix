final: prev:

if prev.stdenv.isDarwin
then rec {
  jdk17 = prev.callPackage ./jdk17-darwin.nix {};
  jdk17_headless = jdk17 // { headless = jdk17; };
}
else {}
