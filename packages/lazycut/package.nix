{ pkgs, buildGoModule }:
let
  sources = pkgs.callPackage ../../_sources/generated.nix { };
in
buildGoModule {
  inherit (sources.lazycut) pname version src;

  vendorHash = "sha256-KfVNSESu06xiFYb+r2Yv4rgDc/NZ1tuGC0IWUdQrywo=";

  subPackages = [ "." ];
}
