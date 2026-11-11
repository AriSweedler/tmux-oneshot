# tmux-oneshot: a command menu for tmux. JSON files list commands; a popup picks one with fzf
# and runs it.
{
  description = "tmux-oneshot: pick a command from JSON menus in a tmux popup and run it";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    ari-zshlib = { url = "github:AriSweedler/ari-zshlib"; inputs.nixpkgs.follows = "nixpkgs"; };
  };
  outputs = { self, nixpkgs, ari-zshlib }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
      each = f: nixpkgs.lib.genAttrs systems (s: f nixpkgs.legacyPackages.${s} s);
    in
    {
      packages = each (pkgs: system: {
        default = pkgs.callPackage ./package.nix { zshlib = ari-zshlib.packages.${system}.default; };
      });
    };
}
