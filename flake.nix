{
  description = "Wrapped fastfetch with pinned config and logo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems f;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          wrappedFastfetch = pkgs.writeShellScriptBin "fastfetch" ''
            exec ${pkgs.fastfetch}/bin/fastfetch \
              --config ${./nixos-01.jsonc} \
              --logo ${./logo/nixos_logo_2.webp} \
              "$@"
          '';
        in
        {
          default = wrappedFastfetch;
          fastfetch = wrappedFastfetch;
        });

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/fastfetch";
        };
      });
    };
}
