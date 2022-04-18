{ stdenvNoCC, ghc }: let
  haskellEnv = ghc.withPackages (x: with x; [
    split
    random-shuffle
    http-client
    http-client-tls
    scalpel-core
    JuicyPixels
  ]);
  ghcFlags = [
    "-XOverloadedStrings"
  ];
  cmd = "eoiw";
  install = target: ''
    mkdir -p ${target}
    cp target/ghc/Main ${target}/${cmd}
  '';
in stdenvNoCC.mkDerivation rec {
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
