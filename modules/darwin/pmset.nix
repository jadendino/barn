{ config, lib, ... }:
let
  inherit (lib)
    concatStringsSep
    filterAttrs
    mapAttrsToList
    mkAfter
    mkOption
    optionalString
    types
    ;

  cfg = config.system.pmset;

  commonOptions = {
    displaysleep = mkOption {
      type = with types; nullOr ints.unsigned;
      default = null;
      description = "Display sleep timer in minutes (0 to disable).";
    };
    disksleep = mkOption {
      type = with types; nullOr ints.unsigned;
      default = null;
      description = "Disk spindown timer in minutes (0 to disable).";
    };
    sleep = mkOption {
      type = with types; nullOr ints.unsigned;
      default = null;
      description = "System sleep timer in minutes (0 to disable).";
    };
    womp = mkOption {
      type = with types; nullOr (enum [ 0 1 ]);
      default = null;
      description = "Wake on ethernet magic packet.";
    };
    ring = mkOption {
      type = with types; nullOr (enum [ 0 1 ]);
      default = null;
      description = "Wake on modem ring.";
    };
    powernap = mkOption {
      type = with types; nullOr (enum [ 0 1 ]);
      default = null;
      description = "Enable/disable Power Nap.";
    };
    proximitywake = mkOption {
      type = with types; nullOr (enum [ 0 1 ]);
      default = null;
      description = "Wake from sleep based on proximity of devices using same iCloud id.";
    };
    autorestart = mkOption {
      type = with types; nullOr (enum [ 0 1 ]);
      default = null;
      description = "Automatic restart on power loss.";
    };
    lidwake = mkOption {
      type = with types; nullOr (enum [ 0 1 ]);
      default = null;
      description = "Wake when laptop lid is opened.";
    };
    acwake = mkOption {
      type = with types; nullOr (enum [ 0 1 ]);
      default = null;
      description = "Wake when power source is changed.";
    };
    lessbright = mkOption {
      type = with types; nullOr (enum [ 0 1 ]);
      default = null;
      description = "Slightly dim display when switching to this power source.";
    };
    halfdim = mkOption {
      type = with types; nullOr (enum [ 0 1 ]);
      default = null;
      description = "Use half-brightness state between full and off for display sleep.";
    };
    sms = mkOption {
      type = with types; nullOr (enum [ 0 1 ]);
      default = null;
      description = "Use Sudden Motion Sensor to park disk heads.";
    };
    hibernatemode = mkOption {
      type = with types; nullOr (enum [ 0 3 25 ]);
      default = null;
      description = "Hibernation mode (0 = no hibernate, 3 = safe sleep, 25 = full hibernate).";
    };
    hibernatefile = mkOption {
      type = with types; nullOr path;
      default = null;
      description = "Hibernation image file location.";
    };
    ttyskeepawake = mkOption {
      type = with types; nullOr (enum [ 0 1 ]);
      default = null;
      description = "Prevent idle system sleep when any tty is active.";
    };
    networkoversleep = mkOption {
      type = with types; nullOr int;
      default = null;
      description = "How networking presents shared services during sleep.";
    };
    destroyfvkeyonstandby = mkOption {
      type = with types; nullOr (enum [ 0 1 ]);
      default = null;
      description = "Destroy FileVault key when going to standby mode.";
    };
    standbydelay = mkOption {
      type = with types; nullOr ints.unsigned;
      default = null;
      description = "Delay in seconds before standby hibernation (desktops).";
    };
    standbydelayhigh = mkOption {
      type = with types; nullOr ints.unsigned;
      default = null;
      description = "Standby delay when battery is below high threshold.";
    };
    standbydelaylow = mkOption {
      type = with types; nullOr ints.unsigned;
      default = null;
      description = "Standby delay when battery is above high threshold.";
    };
    highstandbythreshold = mkOption {
      type = with types; nullOr (ints.between 0 100);
      default = null;
      description = "Battery percentage threshold for standby delay selection.";
    };
    autopoweroff = mkOption {
      type = with types; nullOr (enum [ 0 1 ]);
      default = null;
      description = "Enable/disable auto power off.";
    };
    autopoweroffdelay = mkOption {
      type = with types; nullOr ints.unsigned;
      default = null;
      description = "Delay in seconds before entering autopoweroff mode.";
    };
    standby = mkOption {
      type = with types; nullOr (enum [ 0 1 ]);
      default = null;
      description = "Enable/disable standby mode.";
    };
    tcpkeepalive = mkOption {
      type = with types; nullOr (enum [ 0 1 ]);
      default = null;
      description = "Enable/disable TCP keepalive during sleep.";
    };
  };

  settingsToArgs =
    attrs:
    attrs
    |> filterAttrs (_: v: v != null)
    |> mapAttrsToList (k: v: "${k} ${toString v}")
    |> concatStringsSep " ";

  pmset = flag: attrs: optionalString (settingsToArgs attrs != "") "pmset ${flag} ${settingsToArgs attrs}";
in
{
  options.system.pmset = {
    all = mkOption {
      type = with types; nullOr (submodule { options = commonOptions; });
      default = { };
      description = "Power management settings for all energy sources.";
    };
    battery = mkOption {
      type = with types; nullOr (submodule { options = commonOptions; });
      default = { };
      description = "Power management settings for battery power.";
    };
    charger = mkOption {
      type = with types; nullOr (submodule { options = commonOptions; });
      default = { };
      description = "Power management settings for wall power.";
    };
    ups = mkOption {
      type = with types; nullOr (submodule { options = commonOptions; });
      default = { };
      description = "Power management settings for UPS power.";
    };
  };

  config.system.activationScripts = {
    extraActivation.text = mkAfter config.system.activationScripts.pmset.text;
    pmset.text = ''
      echo >&2 "configuring power management..."
      ${pmset "-a" cfg.all}
      ${pmset "-b" cfg.battery}
      ${pmset "-c" cfg.charger}
      ${pmset "-u" cfg.ups}
    '';
  };
}
