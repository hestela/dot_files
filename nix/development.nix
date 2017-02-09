{ config, pkgs, lib, ... }:

  # Rust
  let rustNightlyNixRepo = pkgs.fetchFromGitHub {
     owner = "solson";
     repo = "rust-nightly-nix";
     rev = "9e09d579431940367c1f6de9463944eef66de1d4";
     sha256 = "03zkjnzd13142yla52aqmgbbnmws7q8kn1l5nqaly22j31f125xy";
  };
  rustPackages = pkgs.callPackage rustNightlyNixRepo { };
  in {
    nixpkgs.config.packageOverrides = pkgs: rec {
      gdb = pkgs.gdb.overrideDerivation(oldAttrs:{
        src = pkgs.fetchurl {
          url = "mirror://gnu/gdb/gdb-7.12.tar.xz";
          sha256 = "152g2qa8337cxif3lkvabjcxfd9jphfb2mza8f1p2c4bjk2z6kw3";
        };
      });
    cargoLatest = rustPackages.cargo { date = "2016-10-28"; };
    rustcLatest = rustPackages.rustcWithSysroots {
      rustc = rustPackages.rustc {
        date = "2016-10-28";
      };
      sysroots = [
        (rustPackages.rust-std {
          date = "2016-10-28";
        })
        (rustPackages.rust-std {
          date = "2016-10-28";
          system = "asmjs-unknown-emscripten";
        })
        (rustPackages.rust-std {
          date = "2016-10-28";
          system = "wasm32-unknown-emscripten";
        })
      ];
    };
  };

  environment = {
    variables = {
      EDITOR = "vim";
    };

    systemPackages = with pkgs; [
      bashCompletion
      cargoLatest
      gcc
      git                                # Git source control
      gnumake
      go
      go2nix
      godep
      python27
      python27Packages.pip
      python27Packages.virtualenv
      rustcLatest
      sqlite
      vimPlugins.YouCompleteMe
      vim_configurable
      which
    ];
  };

  # Enable docker contaner svc
  virtualisation.docker.enable = true;
}
