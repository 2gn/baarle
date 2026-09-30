{ pkgs, buildGoModule }:
let
  # Load the automatically generated hashes
  sources = pkgs.callPackage ../../_sources/generated.nix { };
in
buildGoModule {
  inherit (sources.dskditto) pname version src;

  vendorHash = "sha256-j8QCOGM1v4rQZ4aLJwp4txaPBEk3HFkGbIzHxzE3no8=";

  nativeBuildInputs = [
    pkgs.pkg-config
  ];

  # C libraries the application needs to link against
  buildInputs = [
    pkgs.wayland
    pkgs.libxkbcommon
    pkgs.libGL

    # Raylib usually requires X11 fallback libraries as well:
    pkgs.libx11
    pkgs.libxcursor
    pkgs.libxrandr
    pkgs.libxinerama
    pkgs.libxi
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp dskDitto $out/bin/dskditto
  '';

  subPackages = [ "cmd/dskDitto" ];
}
