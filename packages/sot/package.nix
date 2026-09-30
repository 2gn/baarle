{ pkgs, python3Packages }:
let
  sources = pkgs.callPackage ../../_sources/generated.nix { };
in
python3Packages.buildPythonApplication {
  inherit (sources.sot) pname version src;

  pyproject = true;

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    py-cpuinfo
    distro
    psutil
    rich
    textual
  ];
}
