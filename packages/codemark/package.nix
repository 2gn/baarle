{ pkgs, craneLib }:
let
  # Load the automatically generated hashes
  sources = pkgs.callPackage ../../_sources/generated.nix { };
in
craneLib.buildPackage {
  inherit (sources.codemark) pname version src;

  nativeBuildInputs = [ pkgs.git ];

  preCheck = ''
    export HOME=$TMPDIR
    git config --global user.email "test@example.com"
    git config --global user.name "test"

    git init
    git add -A
    git commit -m "initial"
  '';

  # semantic_search tests need network to download HuggingFace models
  checkPhase = ''
    runHook preCheck

    cargo test --release --locked -- \
      --skip semantic_search

    runHook postCheck
  '';
}
