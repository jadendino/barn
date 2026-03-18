{ ... }:

{
  # system preferences
  # i.e., the ones you see when running
  #       `# defaults read` (as root)

  # Source:
  # https://github.com/nix-darwin/nix-darwin/tree/master/modules/system/defaults

  system.defaults.CustomSystemPreferences = {
    "com.apple.AdLib" = {
      allowApplePersonalizedAdvertising = false;
      allowIdentifierForAdvertising = false;
      forceLimitAdTracking = true;
      personalizedAdsMigrated = false;
    };

    "com.apple.SoftwareUpdate" = {
      AutomaticDownload = false;
    };

    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
  };

  system.defaults.loginwindow = {
    GuestEnabled = false;
    DisableConsoleAccess = true;
  };
}
