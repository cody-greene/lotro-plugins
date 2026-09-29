#!/usr/bin/env bash
# Usage: ./build.sh <plugin_name> <out_dir>
#
# Create a standalone archive for distribution. Common modules are moved to
# avoid any issues where different plugins require different versions of the
# same common module. For example, say we have a plugins directory tree like this:
# Anon
# ├─ Common
# │  └─ Slider.lua
# ├─ Plugin_A
# └─ Plugin_B
#
# If users don't update all plugins at the same time, then Plugin_A might need
# Slider v1, while Plugin_B needs Slider v2 and then you're gonna have a bad
# time. We can avoid the problem if each plugin has its own copy:
#
# Anon
# ├─ Plugin_A
# │  └─ Common
# │     └─ Slider.lua
# └─ Plugin_B
#    └─ Common
#       └─ Slider.lua

set -e

plugin_name=${1:-CombatHUD}
out_dir=${2:-build}

resolve_mod() {
  local f="${1//./\/}" # replace "." with "/"
  if [[ -d "$f" ]]; then
    echo "$f/__init__.lua"
  else
    echo "$f.lua"
  fi
}

# Scan for imported Common modules (BFS)
queue=("src/$plugin_name")
declare -A visited
while [ ${#queue[@]} -gt 0 ]; do
  cur="${queue[0]}"
  queue=("${queue[@]:1}")
  deps=$(grep -rhw "import.\"src\.Common" "$cur" | grep -v "^\s*--" | cut -d'"' -f2 - | sort | uniq)

  for f in $deps; do
    f=$(resolve_mod "$f")
    if [[ -z "${visited[$f]}" ]]; then
      visited["$f"]=1
      queue+=("$f")

      # Copy the common files
      x="${f/src/$out_dir/$plugin_name}"
      mkdir -p "$(dirname "$x")"
      cp "$f" "$x"
    fi
  done
done

mkdir -p "$out_dir/$plugin_name"
cp -r "src/$plugin_name"{/*,.plugin} "$out_dir/$plugin_name/"

find "$out_dir/$plugin_name" -type f \( -name "*.lua" -o -name '*.plugin' \) -exec sed -i "s/src.$plugin_name/$plugin_name/g" {} +
find "$out_dir/$plugin_name" -type f -name "*.lua" -exec sed -i "s/src\.Common/$plugin_name.Common/g" {} +

ver=$(git describe --tags --match "$plugin_name/*")
ver=$(basename "$ver")
sed -i "s/<Version>latest/<Version>$ver/" "$out_dir/$plugin_name/$plugin_name.plugin"

cd "$out_dir"
zip -r -8 "$plugin_name.zip" "$plugin_name"
