{ ... }:

{
  homebrew.casks = [ "ghostty" ];

  home-manager.sharedModules = [
    {
      xdg.configFile."ghostty/config".text = ''
        scrollback-limit = ${toString (10 * 1024 * 1024)}
      '';
    }
  ];
}
