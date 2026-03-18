_: self: super:
let
  inherit (builtins) pathExists;
  inherit (self) filter hasSuffix;
  inherit (self.filesystem) listFilesRecursive;
in
{
  collectNix =
    path: if pathExists path then listFilesRecursive path |> filter (hasSuffix ".nix") else [ ];
}
