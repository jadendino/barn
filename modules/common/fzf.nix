{ lib, ... }:
let
  inherit (lib) enabled;
in
{
  home-manager.sharedModules = [
    {
      programs.fzf = enabled {
        enableZshIntegration = true;
      };
    }
  ];
}
