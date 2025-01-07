{
  lib,
  url,
  version,
  hash,
  fetchurl,
  appimageTools,
  fetchzip,
  ...
}:
let
  pname = "gitbutler";

  srcZipped = fetchzip {
    inherit hash url;
  };

  appimageContents = appimageTools.extract {
    inherit pname version;
    src = "${srcZipped}/GitButler_${version}_amd64.AppImage.tar.gz";
  };
in
appimageTools.wrapType2 rec {
  inherit pname version;
  src = "${srcZipped}/GitButler_${version}_amd64.AppImage.tar.gz";

  extraInstallCommands = ''
    # install -Dm755 unpack/usr/bin/gitbutler-tauri $out/bin/gitbutler-tauri
    # install -Dm755 unpack/usr/bin/gitbutler-git-setsid $out/bin/gitbutler-git-setsid
    # install -Dm755 unpack/usr/bin/gitbutler-git-askpass $out/bin/gitbutler-git-askpass

    # cp -r unpack/usr/share $out/share
    ls -a appimageContents
  '';

  meta = {
    description = "Git client for simultaneous branches on top of your existing workflow";
    license = lib.licenses.fsl11Mit;
    mainProgram = "gitbutler-tauri";
    platforms = [ "x86_64-linux" ];
  };
}
