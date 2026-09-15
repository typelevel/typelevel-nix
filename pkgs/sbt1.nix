# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Copyright (c) 2003-2026 Eelco Dolstra and the Nixpkgs/NixOS contributors
# SPDX-FileContributor: https://github.com/nixos/nixpkgs/blob/d9507283e60f11ad9fcb53b734cbf59154fc3b01/pkgs/development/tools/build-managers/sbt/default.nix

{
  lib,
  stdenv,
  fetchurl,
  jre,
  autoPatchelfHook,
  zlib,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sbt";
  version = "1.12.13";

  src = fetchurl {
    url = "https://github.com/sbt/sbt/releases/download/v${finalAttrs.version}/sbt-${finalAttrs.version}.tgz";
    hash = "sha256-gmcpLmAjXGDC0l6ho48lyS1uxHdY1SImNrjB7PCM1ec=";
  };

  postPatch = ''
    echo -java-home ${jre.home} >>conf/sbtopts
  '';

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc # libstdc++.so.6
    zlib
  ];

  propagatedBuildInputs = [
    # for infocmp
    ncurses
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/sbt $out/bin
    cp -ra . $out/share/sbt
    ln -sT ../share/sbt/bin/sbt $out/bin/sbt
    ln -sT ../share/sbt/bin/sbtn-${
      if (stdenv.hostPlatform.isDarwin) then
        "universal-apple-darwin"
      else if (stdenv.hostPlatform.isAarch64) then
        "aarch64-pc-linux"
      else
        "x86_64-pc-linux"
    } $out/bin/sbtn

    runHook postInstall
  '';

  meta = {
    homepage = "https://www.scala-sbt.org/";
    license = lib.licenses.bsd3;
    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];
    description = "Build tool for Scala, Java and more";
    platforms = lib.platforms.unix;
    mainProgram = "sbt";
  };
})
