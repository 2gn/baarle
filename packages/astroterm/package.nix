{ pkgs, ... }:
let
  sources = pkgs.callPackage ../../_sources/generated.nix { };
in
pkgs.stdenvNoCC.mkDerivation {
  inherit (sources.astroterm) pname version src;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp $src $out/bin/astroterm
    chmod +x $out/bin/astroterm

    runHook postInstall
  '';
}
