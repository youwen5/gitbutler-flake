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
appimageTools.wrapType2 {
  inherit version;
  pname = "gitbutler";

  src = fetchzip {
    inherit url hash;
  };

  meta = {
    description = "Git client for simultaneous branches on top of your existing workflow";
    license = lib.licenses.fsl11Mit;
    mainProgram = "gitbutler-tauri";
    platforms = [ "x86_64-linux" ];
  };
}
