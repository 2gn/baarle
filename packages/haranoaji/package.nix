{ pkgs, ... }:

let
  sources = pkgs.callPackage ../../_sources/generated.nix { };
in
pkgs.stdenvNoCC.mkDerivation {
  # This pulls the name, version, and source URL automatically from _sources/generated.nix
  inherit (sources.haranoaji) pname version src;

  # Skip unnecessary build steps since we are just copying files
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Create the standard font directories
    mkdir -p $out/share/fonts/opentype

    # Recursively find and copy all .ttf and .otf files
    find . -type f -name '*.otf' -exec cp {} $out/share/fonts/opentype/ \;

    runHook postInstall
  '';
}
