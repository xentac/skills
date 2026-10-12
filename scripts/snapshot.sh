#!/usr/bin/env bash
# Snapshot a skill's tracked primary sources into snapshots/<skill>/<YYYY-MM-DD>/.
#
#   scripts/snapshot.sh <skill>
#       Fetch every source in snapshots/<skill>/sources.tsv. A file is stored in
#       today's dated directory only if it differs from its newest stored copy;
#       either way its row in snapshots/<skill>/index.tsv gets last_checked=today.
#       When anything is stored, a README skeleton (files table + mechanical spec
#       diff) is written to the dated directory — or printed, if a README is
#       already there. The diff narrative is left for a person/agent to write.
#
#   scripts/snapshot.sh --record <skill> <file> <stored_in> [last_checked] [version] [upstream_last_modified]
#       Add or update an index row by hand, for snapshots taken manually
#       (Cloudflare-gated pages, console measurements, pasted rules text).
#       Omitted fields keep their current value ('-' for a new row);
#       last_checked defaults to stored_in for a new row.
#
# sources.tsv: one source per line, tab-separated `file  kind  url`; '#' starts
# a comment. Kinds:
#   raw                store the response body as-is
#   yaml-to-json       convert a YAML body to JSON (derived copy, so consumers
#                      can query it with jq instead of needing yq)
#   html-text          visible text from the first <h1> up to <footer>, so
#                      per-deploy asset hashes and site nav don't count as changes
#   userscript-header  only the // ==UserScript== metadata block
#
# Versions come from .info.version for *.json / *.yaml specs and @version for
# userscript headers. Requires curl, jq, yq (mikefarah v4), python3.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
today=$(date -u +%F)
index_header=$'file\tstored_in\tlast_checked\tversion\tupstream_last_modified'

usage() {
  sed -n '2,/^set -euo/p' "$0" | sed '$d; s/^# \{0,1\}//' >&2
  exit 2
}

declare -A stored checked version lastmod

load_index() {
  local f=$1 file s c v l
  [[ -f $f ]] || return 0
  while IFS=$'\t' read -r file s c v l; do
    [[ $file == file || -z $file ]] && continue
    stored[$file]=$s checked[$file]=$c version[$file]=$v lastmod[$file]=$l
  done <"$f"
}

write_index() {
  local f=$1 file
  {
    echo "$index_header"
    for file in $(printf '%s\n' "${!stored[@]}" | sort); do
      printf '%s\t%s\t%s\t%s\t%s\n' "$file" "${stored[$file]}" "${checked[$file]}" \
        "${version[$file]:--}" "${lastmod[$file]:--}"
    done
  } >"$f"
}

html_text() {
  python3 -c '
import html, re, sys
s = sys.stdin.read()
i = s.find("<h1")
j = s.find("<footer", max(i, 0))
s = s[max(i, 0) : j if j > 0 else None]
s = re.sub(r"(?s)<(script|style)\b.*?</\1>", "", s)
s = re.sub(r"(?i)<(br|/?(p|div|li|ul|ol|h[1-6]|tr|table|pre|section|article|dt|dd|blockquote))\b[^>]*>", "\n", s)
s = html.unescape(re.sub(r"<[^>]+>", "", s))
lines = [re.sub(r"[ \t]+", " ", l).strip() for l in s.splitlines()]
print("\n".join(l for l in lines if l))
'
}

spec_version() {
  case $1 in
    *.json) jq -r '.info.version // "-"' "$1" ;;
    *.yaml | *.yml) yq '.info.version // "-"' "$1" ;;
    *.user.js | *.meta.js) sed -n 's|^// @version[[:space:]]*||p' "$1" | head -1 ;;
    *) echo - ;;
  esac
}

spec_paths() {
  case $1 in
    *.json) jq -r '.paths // {} | keys[]' "$1" ;;
    *.yaml | *.yml) yq -o=json '.' "$1" | jq -r '.paths // {} | keys[]' ;;
  esac
}

if [[ ${1:-} == --record ]]; then
  [[ $# -ge 4 ]] || usage
  skill=$2 file=$3
  index=$root/snapshots/$skill/index.tsv
  load_index "$index"
  stored[$file]=$4
  checked[$file]=${5:-${checked[$file]:-$4}}
  version[$file]=${6:-${version[$file]:--}}
  lastmod[$file]=${7:-${lastmod[$file]:--}}
  write_index "$index"
  echo "recorded $file in $index"
  exit 0
fi

[[ $# -eq 1 && $1 != -* ]] || usage
skill=$1
base=$root/snapshots/$skill
sources=$base/sources.tsv
index=$base/index.tsv
[[ -f $sources ]] || { echo "no $sources" >&2; exit 1; }
load_index "$index"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
dated=$base/$today
changed=() unchanged=() failed=()
declare -A url_of kind_of prev_of

while IFS=$'\t' read -r file kind url; do
  [[ -z $file || $file == \#* ]] && continue
  url_of[$file]=$url kind_of[$file]=$kind
  if ! curl -fsSL -D "$tmp/hdr" -o "$tmp/body" "$url"; then
    echo "FAILED: $file <- $url" >&2
    failed+=("$file")
    continue
  fi
  out=$tmp/$file
  case $kind in
    raw) cp "$tmp/body" "$out" ;;
    yaml-to-json) yq -o=json '.' "$tmp/body" >"$out" ;;
    html-text) html_text <"$tmp/body" >"$out" ;;
    userscript-header) sed -n '\|// ==UserScript==|,\|// ==/UserScript==|p' "$tmp/body" >"$out" ;;
    *) echo "unknown kind '$kind' for $file" >&2; failed+=("$file"); continue ;;
  esac
  if [[ ! -s $out ]]; then
    echo "EMPTY after '$kind' processing: $file" >&2
    failed+=("$file")
    continue
  fi
  lm=$(grep -i '^last-modified:' "$tmp/hdr" | tail -1 | cut -d' ' -f2- | tr -d '\r' || true)
  prev=${stored[$file]:-}
  if [[ -n $prev && -f $base/$prev/$file ]] && cmp -s "$out" "$base/$prev/$file"; then
    unchanged+=("$file")
  else
    mkdir -p "$dated"
    cp "$out" "$dated/$file"
    prev_of[$file]=$prev
    stored[$file]=$today
    version[$file]=$(spec_version "$dated/$file")
    changed+=("$file")
  fi
  checked[$file]=$today
  lastmod[$file]=${lm:--}
done <"$sources"

write_index "$index"

echo "== $skill: ${#changed[@]} stored, ${#unchanged[@]} unchanged, ${#failed[@]} failed"
for f in "${unchanged[@]}"; do echo "unchanged: $f (stored in ${stored[$f]})"; done
for f in "${changed[@]}"; do echo "stored:    $f -> $today/ (version ${version[$f]})"; done
((${#changed[@]})) || exit $((${#failed[@]} ? 1 : 0))

skeleton() {
  local f p old new
  echo "# $skill snapshot — $today"
  echo
  echo "Taken with \`scripts/snapshot.sh $skill\`. TODO: say why, if not routine."
  echo
  echo "## Files"
  echo
  echo "| File | Source | Kind | Version | Upstream \`Last-Modified\` |"
  echo "|---|---|---|---|---|"
  for f in "${changed[@]}"; do
    echo "| \`$f\` | \`${url_of[$f]}\` | ${kind_of[$f]} | ${version[$f]} | ${lastmod[$f]} |"
  done
  if ((${#unchanged[@]})); then
    echo
    echo "## Checked and unchanged"
    echo
    for f in "${unchanged[@]}"; do echo "- \`$f\` — still the copy in \`../${stored[$f]}/\`"; done
  fi
  for f in "${changed[@]}"; do
    p=${prev_of[$f]}
    [[ -n $p && -f $base/$p/$f ]] || continue
    case $f in *.json | *.yaml | *.yml) ;; *) continue ;; esac
    old=$(spec_version "$base/$p/$f")
    echo
    echo "## Mechanical diff: \`$f\` vs \`../$p/\`"
    echo
    echo "Version **$old → ${version[$f]}**."
    spec_paths "$base/$p/$f" | sort >"$tmp/old_paths"
    spec_paths "$dated/$f" | sort >"$tmp/new_paths"
    echo
    echo "Added paths: $(comm -13 "$tmp/old_paths" "$tmp/new_paths" | sed 's/.*/`&`/' | paste -sd, | sed 's/,/, /g')"
    echo
    echo "Removed paths: $(comm -23 "$tmp/old_paths" "$tmp/new_paths" | sed 's/.*/`&`/' | paste -sd, | sed 's/,/, /g')"
  done
  echo
  echo "## Diff narrative"
  echo
  echo "TODO: deprecations, renames, changed fields, new error codes — whatever matters to the skill."
}

if [[ -f $dated/README.md ]]; then
  echo
  echo "$dated/README.md already exists; not overwriting. Merge this in by hand:"
  echo
  skeleton
else
  skeleton >"$dated/README.md"
  echo "wrote $dated/README.md — fill in the TODOs"
fi
exit $((${#failed[@]} ? 1 : 0))
