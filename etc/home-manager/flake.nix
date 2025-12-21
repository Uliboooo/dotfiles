{
  description = "Home Manager configuration for coyuki on Arch Linux";

  inputs = {
    # 最新のパッケージを利用
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 外部 Flakes
    zen-browser.url = "github:MarceColl/zen-browser-flake";
    ghostty.url = "github:ghostty-org/ghostty";
  };

  outputs = { self, nixpkgs, home-manager, zen-browser, ghostty, ... }@inputs: {
    homeConfigurations."coyuki" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      
      # home.nix で inputs (ghosttyなど) を使えるようにする
      extraSpecialArgs = { inherit inputs; };
      
      modules = [ 
        ./home.nix 
      ];
    };
  };
}
