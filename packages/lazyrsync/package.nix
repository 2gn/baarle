{ pkgs, craneLib }:
let
  # Load the automatically generated hashes
  sources = pkgs.callPackage ../../_sources/generated.nix { };
in
craneLib.buildPackage {
  inherit (sources.lazyrsync) pname version src;
  # No more manual SHA hashes!
}
