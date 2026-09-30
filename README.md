[![Garnix CI build status](https://img.shields.io/endpoint?url=https%3A%2F%2Fgarnix.io%2Fapi%2Fbadges%2F2gn%2Fbaarle%3Fbranch%3Dmistress&label=Garnix%20CI&color=%2300AAFF)](https://opencollective.com/garnix_io)

<hr/>

# baarle

just a bunch of packages, and a sandbox for stuff that we might upstream later.

## what's inside?

run `nix flake show github:2gn/baarle`

## usage

slide `github:2gn/baarle` into your flake inputs like so

```nix
{
  inputs = {
    # ...
    baarle.url = "github:2gn/baarle";
    baarle.inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

then add inputs or just baarle to your specialArgs

```nix
{
  nixosConfigurations = {
    system = lib.nixosSystem {
      specialArgs = {
        inherit baarle;
      };
    };
  };
}
```

<!--
and add the overlay in your nixos config
```nix
{ baarle, pkgs, ... }:
{
  nixpkgs.overlays = [ baarle.overlays.default ];
}
```
-->

Add/use packages and modules as needed.

```nix
{baarle, ...}: {
  imports = [
    baarle.nixosModules.arrpc
  ];
}
```

cross your fingers and hope things work :3
