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
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gitbutler";
  version = "0.14.4";
  src = fetchurl {
    url = "https://releases.gitbutler.com/releases/release/0.14.4-1569/linux/x86_64/GitButler_${finalAttrs.version}_amd64.deb";
    hash = "sha256-z643LzoFxb5DKgNCe+h0naC1dA9/VfMAJ7ZSYhibhpQ=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    autoPatchelfHook
    dpkg
    webkitgtk_4_1
    libsoup_2_4
    makeWrapper
  ];

  unpackPhase = "dpkg-deb -x $src unpack";

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
