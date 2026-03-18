inputs: self: super:
let
  inherit (self)
    attrValues
    filter
    getAttrFromPath
    hasAttrByPath
    collectNix
    ;

  modulesCommon = collectNix ../modules/common;
  modulesDarwin = collectNix ../modules/darwin;
  modulesLinux = collectNix ../modules/linux;

  collectInputs =
    let
      inputs' = attrValues inputs;
    in
    path: inputs' |> filter (hasAttrByPath path) |> map (getAttrFromPath path);

  inputModulesDarwin = collectInputs [
    "darwinModules"
    "default"
  ];
  inputModulesLinux = collectInputs [
    "nixosModules"
    "default"
  ];

  inputOverlays = collectInputs [
    "overlays"
    "default"
  ];
  overlayModule = {
    nixpkgs.overlays = inputOverlays;
  };

  specialArgs = inputs // {
    inherit inputs;
    lib = self;
  };
in
{
  darwinSystem' =
    module:
    (super.darwinSystem {
      inherit specialArgs;

      modules = [
        module
        overlayModule
      ]
      ++ inputModulesDarwin
      ++ modulesCommon
      ++ modulesDarwin;
    })
    // {
      class = "darwin";
    };

  nixosSystem' =
    module:
    (super.nixosSystem {
      inherit specialArgs;

      modules = [
        module
        overlayModule
      ]
      ++ inputModulesLinux
      ++ modulesCommon
      ++ modulesLinux;
    })
    // {
      class = "nixos";
    };
}
