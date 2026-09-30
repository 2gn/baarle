{ pkgs, buildGoModule }:
let
  # Load the automatically generated hashes
  sources = pkgs.callPackage ../../_sources/generated.nix { };
in
buildGoModule {
  inherit (sources.flow) pname version src;

  vendorHash = "sha256-KwLuF9dMvUgmeoM8K+zMrAH9fa5y1tzWtuGvjY1Q0vE=";

  # nativeBuildInputs = [
  #   pkgs.pkg-config
  # ];

  # C libraries the application needs to link against
  buildInputs = [
  ];

  # subPackages = [ "cmd/dskDitto" ];
}
