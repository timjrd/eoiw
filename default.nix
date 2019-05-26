let
  rev    = "ce0d9d638ded6119f19d87e433e160603683fb1b"; # nixos-18.03
  sha256 = "0na6kjk4xw6gqrn3a903yv3zfa64bspq2q3kd6wyf52y44j3s8sx";

  repo = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs-channels/archive/${rev}.tar.gz";
    inherit sha256;
  };
  nixpkgs = import repo {};
in
  with nixpkgs;
  let
    haskellEnv = haskell.packages.ghc822.ghcWithPackages
      (haskellPackages: with haskellPackages; [
        http-client
        http-client-tls
        scalpel-core
      ]);
    ghcFlags = [
      "-XOverloadedStrings"
    ];
    cmd = "eoiw";
    install = target: ''
      mkdir -p ${target}
      cp target/ghc/Main ${target}/${cmd}
    '';
  in
    stdenv.mkDerivation rec {
      name = cmd;
      src = ./.;
      buildInputs = [
        haskellEnv
      ];
      
      cleanPhase = ''
        rm -rf target
      '';
      
      postUnpack = ''(
        cd $sourceRoot
        ${cleanPhase}
      )'';
      
      buildPhase = ''
        mkdir -p target/ghc

        ghc -odir target/ghc -hidir target/ghc -isrc -O2 \
            --make src/Main.hs -o target/ghc/Main \
            ${builtins.concatStringsSep " " ghcFlags}

        ${install "target/bin"}
      '';
      
      installPhase = install "$out/bin";
    }
