{ pkgs, buildGoModule }:
let
  sources = pkgs.callPackage ../../_sources/generated.nix { };
in
buildGoModule {
  inherit (sources.pwdsafety) pname version src;

  vendorHash = "sha256-4Nd4QU934XpCOH6aqiGLvRbfuPu+z4WwzxBIb/SPH8w=";

  subPackages = [ "./cmd/pwdsafety" ];
}
