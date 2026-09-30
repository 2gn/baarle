{ pkgs, buildGoModule }:
let
  sources = pkgs.callPackage ../../_sources/generated.nix { };
in
buildGoModule {
  inherit (sources.omm) pname version src;

  vendorHash = "sha256-o0Bcltct1xdpR2DArPcUaPHTS/QM6p+gHD0vYIfSllA=";

  subPackages = [ "." ];
}
