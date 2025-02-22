#!/usr/bin/env -S nix shell nixpkgs#nushell --command nu

def get_latest_release []: nothing -> record {
  try {
	http get $"https://app.gitbutler.com/releases"
  } catch { |err| $"Failed to fetch latest release, aborting: ($err.msg)" }
}

def get_nix_hash [url: string]: nothing -> string  {
  nix store prefetch-file --hash-type sha256 --json $url | from json | get hash
}

export def generate_sources []: nothing -> record {
  let data = get_latest_release
  let prev_sources: record = open ./sources.json

  let tag = $data | get version

  if $tag == $prev_sources.version {
	# everything up to date
	return {
	  prev_tag: $tag
	  new_tag: $tag
	}
  }

  # The releases API only gives us a download link for the AppImage, not the `.deb`, which we want.

  # The download URL is not fixed, so we need to use the URL returned by the
  # API, then take its parent path, and join it with the name of the `.deb`
  # file.
  let x86_64_appimage_url: record = $data.platforms.linux-x86_64.url | url parse
  let deb_path = $x86_64_appimage_url.path | path dirname | path join $"GitButler_($tag)_amd64.deb"
  let deb_url = $x86_64_appimage_url | update path $deb_path | url join

  let sources = {
	version: $tag
	x86_64-linux: {
	  url:  $deb_url
	  hash: (get_nix_hash $deb_url)
	}
  }

  echo $sources | save --force "sources.json"

  return {
    new_tag: $tag
    prev_tag: $prev_sources.version
  }
}


def commit_update []: nothing -> nothing {
  let gitbutler_latest = generate_sources

  if ($gitbutler_latest.prev_tag == $gitbutler_latest.new_tag) {
    print $"Latest version is ($gitbutler_latest.prev_tag), no updates found"
  } else {
    print $"Performing update from ($gitbutler_latest.prev_tag) -> ($gitbutler_latest.new_tag)"

    git add -A
    git commit -m $"auto-update: ($gitbutler_latest.prev_tag) -> ($gitbutler_latest.new_tag)"

    nix flake update --commit-lock-file

    nix build
  }

}

commit_update
