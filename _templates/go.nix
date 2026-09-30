{ pkgs, buildGoModule }:
let
  sources = pkgs.callPackage ../../_sources/generated.nix { };
in
buildGoModule {
  inherit (sources.redthread) pname version src;

  vendorHash = "sha256-4kptp/OEahsOCnJe4gCM1jPevqhSnIB0498DfDQNjOA=";

  subPackages = [ "./cmd/redthread" ];
}
