{ sources ? import ./sources.nix
}:
let
  # default nixpkgs
  pkgs = import sources.nixpkgs { };

  # gitignore.nix 
  gitignoreSource = (import sources."gitignore.nix" { inherit (pkgs) lib; }).gitignoreSource;

  pre-commit-hooks = (import sources."pre-commit-hooks.nix");

  src = gitignoreSource ./..;
in
{
  inherit pkgs src;

  # provided by shell.nix
  devTools = {
    inherit (pkgs) niv;
    inherit (pre-commit-hooks) pre-commit nixpkgs-fmt nix-linter;
  };

  # to be built by github actions
  ci = {
    pre-commit-check = pre-commit-hooks.run {
      inherit src;
      hooks = {
        shellcheck.enable = true;
        nixpkgs-fmt.enable = true;
        nix-linter.enable = true;
        # cargo-check.enable = true;
        # rustfmt = {
        #   enable = true;
        # };
      };
      # generated files
      excludes = [ "^nix/sources\.nix$" ];
    };
    yatima = import ../yatima.nix {
      inherit sources pkgs;
    };
  };
}
