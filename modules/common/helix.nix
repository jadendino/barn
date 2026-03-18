{ config, lib, pkgs, ... }:
let
  inherit (lib) optionalString;
in
{
  environment.systemPackages = [ pkgs.helix ];

  home-manager.sharedModules = [
    {
      xdg.configFile."helix/config.toml".text = /* toml */ ''
        theme = "catppuccin_mocha"

        [editor]
        auto-completion = false
        bufferline = "multiple"
        color-modes = true
        cursorline = true
        idle-timeout = 0
        line-number = "relative"
        shell = ["zsh", "-c"]

        [editor.file-picker]
        hidden = false

        [editor.soft-wrap]
        enable = true
      '';

      xdg.configFile."helix/languages.toml".text = /* toml */ ''
        [[language]]
        name = "latex"
        # language-servers = [ "texlab" ] # texlab is default

        [language-server.texlab.config]
        texlab.build.executable = "tectonic"
        texlab.build.args = [
          "-X",
          "compile",
          "%f",
          "--synctex",
          "--keep-logs",
          "--keep-intermediates"
        ]
        texlab.build.onSave = true
        ${optionalString config.isDarwin ''
        texlab.build.forwardSearchAfter = true
        texlab.forwardSearch.executable = "/Applications/Skim.app/Contents/SharedSupport/displayline"
        texlab.forwardSearch.args = ["-r", "%l", "%p", "%f"]''}

        [[language]]
        name = "typst"
        # language-servers = [ "tinymist" ] # tinymist is default

        [language-server.tinymist.config]
        preview.background.enabled = true
        preview.background.args = ["--data-plane-host=127.0.0.1:23635", "--invert-colors=never", "--open"]
      '';
    }
  ];
}
