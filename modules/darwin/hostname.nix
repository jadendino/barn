{ config, ... }:
{
  networking.computerName = config.networking.hostName;

  system.defaults.smb = {
    NetBIOSName = config.networking.hostName;
    ServerDescription = config.networking.hostName;
  };
}
