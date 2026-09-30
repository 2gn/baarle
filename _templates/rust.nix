{ pkgs, craneLib }:
let
  sources = pkgs.callPackage ../../_sources/generated.nix { };
in
craneLib.buildPackage {
  inherit (sources.usbtree) pname version src;
}
