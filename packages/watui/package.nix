{ pkgs, buildGoModule }:
let
  sources = pkgs.callPackage ../../_sources/generated.nix { };
in
buildGoModule {
  inherit (sources.watui) pname version src;

  vendorHash = "sha256-edL8Lb5yYdtcIwMOPO2PUHAAWtwwAP/ALzHXNmXt7+g=";

  subPackages = [ "./cmd/watui" ];
}
