{
  description = "dotfiles: NixOS + flakes + Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-hazkey = {
      url = "github:aster-void/nix-hazkey/4f791a241963f6804420d69613c25c6d25610e73";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jolt = {
      url = "github:jordond/jolt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wlmstr = {
      url = "github:Uliboooo/wlmstr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zathura-gui = {
      url = "github:Uliboooo/zathura_thin_gui_wrapper";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # tirith = {
    #   url = "github:sheeki03/tirith";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    shojiwm = {
      url = "github:bea4dev/ShojiWM";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprpanopticon = {
      url = "github:Uliboooo/hyprPanopticon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }@inputs:
    let
      linuxSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin"; # change to x86_64-darwin for Intel Mac

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      # sampler は alsa-lib に依存するので Linux のみ。
      sampler = (mkPkgs linuxSystem).callPackage ./pkgs/sampler.nix { };

      mkHome =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          modules = [ ./home/seli.nix ];
          extraSpecialArgs = {
            inherit inputs;
          };
        };
    in
    {
      packages.${linuxSystem}.sampler = sampler;

      # ===== Home Manager (standalone) =====
      # nix-darwin を使わず、パッケージマネージャとしてだけ使う場合はこちら。
      homeConfigurations = {
        seli = mkHome linuxSystem;
        "seli@${linuxSystem}" = mkHome linuxSystem;
        "seli@${darwinSystem}" = mkHome darwinSystem;
      };

      # ===== NixOS (desktop) =====
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        system = linuxSystem;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./hosts/desktop/configuration.nix

          (
            {
              pkgs,
              ...
            }:
            {
              environment.systemPackages = with pkgs; [
                bash
              ];
              environment.pathsToLink = [ "/bin" ];
            }
          )

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
            home-manager.users.seli = import ./home/seli.nix;
          }

          inputs.shojiwm.nixosModules.default
          {
            programs.shojiwm = {
              enable = true;
              initConfig = {
                enable = true;
                users = [ "seli" ];
              };
            };
          }
        ];
      };

      # ===== macOS =====
      darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./hosts/macbook/configuration.nix

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
            home-manager.users.seli = import ./home/seli.nix;
          }
        ];
      };
    };
}
