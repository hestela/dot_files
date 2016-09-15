{ config, pkgs, ... }:

{

  environment = {
    variables = {
      EDITOR = "vim";
    };

    systemPackages = with pkgs; [
      awscli                             # AWS command line interface
      bundler
      bundix                             # Structured Ruby package manager
      cargoUnstable                      # Rust package manager
      git                                # Git source control
      go
      fzf
      godep
      imagemagick                        # Image manip library
      ngrok
      nix-repl                           # Repl for nix package manager
      nodejs-5_x                         # Node.js event driven JS framework
      python27                           # Python programming language
      python27Packages.pip               # Python package manager
      python27Packages.virtualenv
      rustNightlyWithi686
      elixir
      ruby                               # Ruby programming language
      rubygems                           # Ad hoc Ruby package manager
      samba                              # Netbios
      silver-searcher                    # Code searching tool
      sqlite                             # sqlite database
      which                              # Dependency for fzf.vim
      vimPlugins.YouCompleteMe
      vim_configurable                   # Text editor
    ];
  };

  # Enable docker contaner svc
  virtualisation.docker.enable = true;

  # Rust nightly
  nixpkgs.config.packageOverrides = pkgs: rec {
    rustGetter = pkgs.fetchFromGitHub {
      owner = "Ericson2314";
      repo = "nixos-configuration";
      rev = "ca75f2a08643faf913ab667199ef1b3fe5615618";
      sha256 = "131hp2zp1i740zqrbgpa57zjczs5clj3q2dmylbnr9cgsqbcyznp";
    };

    funs = pkgs.callPackage "${rustGetter}/user/.nixpkgs/rust-nightly.nix" { };

    rustDate = "2016-09-13";
    rustStdDate = "2016-09-13";

    rustcNightly = funs.rustc {
      date = rustDate;
      hash = "0a3qmf6wf797zgg7dv76hkzjknhrhrlgln5db8fx60mxas2ck5rn";
    };

    rustStd = funs.rust-std {
      date = rustDate;
      hash = "1ka5kjnhs99wd9jylrg3vqcikhw5vrh9gmlsini8kp4qz5agh817";
    };

    rustNightlyWithi686 = funs.rustcWithSysroots {
      rustc = rustcNightly;
      sysroots = [
        (funs.rust-std {
          hash = "1ckqrhqidynfk80l9nzhza945x1c74n6a55ki45zdc02v81259mn";
          date = rustStdDate;
        })
        (funs.rust-std {
          hash = "10297dpdf3yvzg3bdlg9b3a15sgdrjyj582xq0fyvii0snrsnbkr";
          date = rustStdDate;
          system = "i686-linux";
        })
      ];
    };

    cargoNightly = funs.cargo {
      date = "2016-09-13";
      hash = "0spw9zgsvncjqi7hf6yn4knvzrq6mnsak3frm104ggizhlnq8gfv";
    };
  };
}
