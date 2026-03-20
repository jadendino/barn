{
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.pmset.all = {
    sleep = 0;
    displaysleep = 0;
    disksleep = 0;
    standby = 0;
    autopoweroff = 0;
    hibernatemode = 0;
    powernap = 0;
    tcpkeepalive = 0;
    womp = 1;
    autorestart = 1;
  };
}
