{ pkgs, buildGoModule }:
let
  sources = pkgs.callPackage ../../_sources/generated.nix { };
in
buildGoModule {
  inherit (sources.act3) pname version src;

  vendorHash = "sha256-+WSWlmxQTryLrpeloYdupyMibsgFYpjSuDvW+if3IHE=";

  # subPackages = [ "./cmd/act3" ];
}
