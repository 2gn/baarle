{
  buildDotnetModule,
  dotnetCorePackages,
  pkgs,
}:

let
  # Load the automatically generated hashes
  sources = pkgs.callPackage ../../_sources/generated.nix { };
in
buildDotnetModule {
  inherit (sources.podliner) pname version src;
  projectFile = "StuiPodcast.App/StuiPodcast.App.csproj";
  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;
  # nugetDeps = ./deps.json;
}
