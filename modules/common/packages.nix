{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    rage
    eza
    fd
    fzf
    git
    hyperfine
    # mpv
    neovim
    ripgrep
    ruff
    tectonic
    texlab
    uv
    yazi
    nil
    nixfmt
    ffmpeg
    typst
    tinymist
    tmux
    lazygit
  ];
}
