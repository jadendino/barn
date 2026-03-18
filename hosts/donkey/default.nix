lib:
lib.darwinSystem' (
  { config, lib, ... }:
  let
    inherit (lib) collectNix remove;
  in
  {
    imports = collectNix ./. |> remove ./default.nix;

    networking.hostName = "donkey";
    type = "desktop";

    system.primaryUser = "big";
    users.users.big = {
      name = "big";
      home = "/Users/big";
    };

    home-manager.users.big.home = {
      stateVersion = "25.11";
      homeDirectory = config.users.users.big.home;
    };

    system.stateVersion = 6;
  }
)
