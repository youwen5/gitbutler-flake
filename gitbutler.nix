{
  stdenv,
  dpkg,
  autoPatchelfHook,
  wrapGAppsHook3,
  fetchurl,
  webkitgtk_4_1,
  libsoup_2_4,
  lib,
  makeWrapper,
  url,
  version,
  hash ? "",
}:
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "gitbutler";
  src = fetchurl {
    inherit url hash;
    nativeBuildInputs = [ dpkg ];
    postFetch = "dpkg-deb -x $downloadedFile $out";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    webkitgtk_4_1
    libsoup_2_4
  ];

  # TODO: check that the desktop file points to the right binary! Otherwise, use `substituteInPlace`
  installPhase = ''
    install -Dm755 unpack/usr/bin/gitbutler-tauri $out/bin/gitbutler-tauri
    install -Dm755 unpack/usr/bin/gitbutler-git-setsid $out/bin/gitbutler-git-setsid
    install -Dm755 unpack/usr/bin/gitbutler-git-askpass $out/bin/gitbutler-git-askpass

    cp -r unpack/usr/share $out/share
  '';

  meta = {
    description = "Git client for simultaneous branches on top of your existing workflow";
    license = lib.licenses.fsl11Mit;
    mainProgram = "gitbutler-tauri";
    platforms = [ "x86_64-linux" ];
  };
})
