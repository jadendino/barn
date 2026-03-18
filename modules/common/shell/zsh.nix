{ config, lib, pkgs, ... }:
let
  inherit (lib) enabled mkIf optionalAttrs;
in
{
  home-manager.sharedModules = [
    (
      homeArgs:
      let
        config' = homeArgs.config;
      in
      {
        programs.zsh = enabled {
          package = pkgs.zsh;
          dotDir = "${config'.xdg.configHome}/zsh";

          enableCompletion = true;
          syntaxHighlighting.enable = true;

          sessionVariables = {
            EDITOR = "hx";
            TERMINAL = "ghostty";
            PAGER = "nvim +Man!";
          } // optionalAttrs config.isDarwin {
            HOMEBREW_NO_ANALYTICS = 1;
            HOMEBREW_NO_ENV_HINTS = 1;
            HOMEBREW_CASK_OPTS_QUARANTINE = 0;
          };

          history = {
            extended = true;
            expireDuplicatesFirst = true;
            ignoreDups = true;
            ignoreSpace = true;
            path = "${config'.xdg.stateHome}/zsh/history";
            save = 20000;
            share = true;
            size = 20000;
          };

          initContent = ''
            # History options
            setopt HIST_EXPIRE_DUPS_FIRST
            setopt HIST_FIND_NO_DUPS
            setopt HIST_IGNORE_ALL_DUPS
            setopt HIST_IGNORE_DUPS
            setopt HIST_IGNORE_SPACE
            setopt HIST_SAVE_NO_DUPS
            setopt SHARE_HISTORY

            # Completion settings
            setopt globdots
            setopt menu_complete
            setopt list_rows_first
            zstyle ':completion:*' menu select

            # Ensure history directory exists
            [[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"

            # Disable Apple's shell session restore
            [[ "$(uname -s)" == "Darwin" ]] && SHELL_SESSIONS_DISABLE=1

            # Utility function for timing zsh startup
            timezsh() { repeat 10 { time zsh -i -c exit } }

            # Prompt
            PS1="%n@%m %1~ %# "

            # Yazi: change cwd on exit
            function y() {
              local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
              command yazi "$@" --cwd-file="$tmp"
              IFS= read -r -d "" cwd < "$tmp"
              [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
              rm -f -- "$tmp"
            }
          '';

          profileExtra = mkIf config.isDarwin ''
            eval "$(/opt/homebrew/bin/brew shellenv)"
          '';

          envExtra = ''
            export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
            export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"
            export XDG_STATE_HOME="''${XDG_STATE_HOME:-$HOME/.local/state}"
            export XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}"
            path=("$HOME/.local/bin" $path)
          '';
        };
      }
    )
  ];
}
