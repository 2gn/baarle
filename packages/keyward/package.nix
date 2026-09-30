{ pkgs, buildGoModule }:
let
  # Load the automatically generated hashes
  sources = pkgs.callPackage ../../_sources/generated.nix { };
in
buildGoModule {
  inherit (sources.keyward) pname version src;

  vendorHash = "sha256-YD2D/lNYavNzjc0KO3ULMadXll8vgWkU3yp0FpPKGRI=";

  preCheck = ''
    export HOME=$TMPDIR
  '';

  # nativeBuildInputs = [
  #   pkgs.pkg-config
  # ];

  # C libraries the application needs to link against
  # buildInputs = [
  #   pkgs.wayland
  #   pkgs.libxkbcommon
  #   pkgs.libGL

  #   # Raylib usually requires X11 fallback libraries as well:
  #   pkgs.libx11
  #   pkgs.libxcursor
  #   pkgs.libxrandr
  #   pkgs.libxinerama
  #   pkgs.libxi
  # ];

  # installPhase = ''
  #   mkdir -p $out/bin
  #   cp dskDitto $out/bin/dskditto
  # '';

  # subPackages = [ "cmd/dskDitto" ];
}
