{ pkgs, craneLib }:
let
  lib = pkgs.lib;
  # Load the automatically generated hashes
  sources = pkgs.callPackage ../../_sources/generated.nix { };

  isCrosstermRepo = p: lib.hasInfix "HalFrgrd/crossterm.git" p.source;

  cargoVendorDir = craneLib.vendorCargoDeps {
    inherit (sources.flyline) src;
    overrideVendorGitCheckout =
      ps: drv:
      if lib.any isCrosstermRepo ps then
        drv.overrideAttrs (_old: {
          postPatch = ''
            # Remove broken readme references from Cargo.toml files
            # to prevent "readme does not appear to exist" errors
            find . -name Cargo.toml -exec sed -i '/^readme/d' {} \;
          '';
        })
      else
        drv;
  };
in
craneLib.buildPackage {
  inherit (sources.flyline) pname version src;
  inherit cargoVendorDir;

  doCheck = false;
}
