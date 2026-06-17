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

      pkgs = import nixpkgs {
        system = linuxSystem;
      };

      sampler = pkgs.callPackage ./pkgs/sampler.nix { };
    in
    {
      packages.${linuxSystem}.sampler = sampler;

      # ===== Home Manager (standalone) =====
      homeConfigurations.lilan = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = linuxSystem;
          config.allowUnfree = true;
        };
        modules = [
          ./home/lilan.nix
          inputs.nix-hazkey.homeModules.hazkey
          {
            services.hazkey.enable = true;
            i18n.inputMethod.type = "fcitx5";
            i18n.inputMethod.enable = true;
          }
        ];
        extraSpecialArgs = {
          inherit inputs;
        };
      };

      homeConfigurations.seli = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = linuxSystem;
          config.allowUnfree = true;
        };
        modules = [
          ./home/lilan.nix
          inputs.nix-hazkey.homeModules.hazkey
          {
            home.username = "seli";
            home.homeDirectory = "/home/seli";
            services.hazkey.enable = true;
            i18n.inputMethod.type = "fcitx5";
            i18n.inputMethod.enable = true;
          }
        ];
        extraSpecialArgs = {
          inherit inputs;
        };
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
            home-manager.users.lilan = import ./home/lilan.nix;
          }
        ];
      };

      # ===== macOS =====
      darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
        system = darwinSystem;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          home-manager.darwinModules.home-manager
          {
            system.stateVersion = 7;
            nixpkgs.config.allowUnfree = true;
            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
            users.users.alice.home = "/Users/alice";
            home-manager.users.alice = import ./home/alice.nix;
          }
        ];
      };
    };
}
