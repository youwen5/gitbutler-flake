{
  appimageTools,
  fetchurl,
  stdenvNoCC,
}:
let
  pname = "gitbutler";
  version = "0.14.4";

  appimage = stdenvNoCC.mkDerivation {
    inherit version;
    pname = "gitbutler-appimage";
    src = fetchurl {
      url = "https://releases.gitbutler.com/releases/release/0.14.4-1569/linux/x86_64/GitButler_0.14.4_amd64.AppImage.tar.gz";
      hash = "sha256-RX1Jqn4M/chpHlbkFdeOQjxMwJhsa9h8ASBMHzG+Fao=";
    };

    unpackPhase = ''
      tar xvf $src
    '';

    installPhase = ''
      mkdir -p $out/bin
      install -Dm755 ./*.AppImage $out/bin
    '';
  };
in
appimageTools.wrapType2 {
  inherit pname version;

  src = "${appimage}/bin/GitButler_0.14.4_amd64.AppImage";
}
