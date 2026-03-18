{
  environment.shellAliases = {
    ls = "eza -a --group-directories-first --color=auto";
    tree = "eza --tree --git-ignore --group-directories-first";

    cp = "cp -Rv";
    mv = "mv -v";
    rm = "rm -Rv";
  };
}
