{ pkgs, craneLib }:
let
  sources = pkgs.callPackage ../../_sources/generated.nix { };
in
craneLib.buildPackage {
  inherit (sources.countryfetch) pname version src;

  nativeBuildInputs = with pkgs; [
    perl
  ];
}
