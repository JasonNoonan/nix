# Personal Nix Configuration

## New Installation

Follow the instructions [here](https://github.com/LnL7/nix-darwin?tab=readme-ov-file) to install nix-darwin.

It will also instruct you to install the base nix from [here](https://nix.dev/install-nix). At the time of creating this repo, the instructions were to simply run:

```sh
curl -L https://nixos.org/nix/install | sh
```

**Note:** You'll need to add the following flags to have the first install work (to get nix-darwin, not root nix)

```sh
export NIX_CONFIG="experimental-features = nix-command flakes"
```

## NIX_PATH

In order to have the `darwin-rebuild switch` command work without passing a flake path, clone this repo to `~/.nixpkgs`

## Unsupported Apps

The following applications were either not supported on MacOs from the Nix packages, or there were no Nix packages provided.

* MS Edge
* Postman
* Notion
* Amethyst
* Keeper
* OBS Studio
