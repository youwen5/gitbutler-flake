#!/usr/bin/env -S nix shell nixpkgs#nushell --command nu

def get_latest_release []: nothing -> record {
  try {
	http get $"https://app.gitbutler.com/releases"
  } catch { |err| $"Failed to fetch latest release, aborting: ($err.msg)" }
}

def get_nix_hash [url: string]: nothing -> string  {
  nix store prefetch-file  --json $url | from json | get hash
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

  let x86_64_url = $data | get platforms | get linux-x86_64
  let sources = {
	version: $tag
	x86_64-linux: {
	  url:  $x86_64_url.url
	  hash: (get_nix_hash $x86_64_url.url)
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
  }

  git add -A
  let commit = git commit -m $"auto-update: ($gitbutler_latest.prev_tag) -> ($gitbutler_latest.new_tag)" | complete

}

commit_update
