#!/usr/bin/env bash
set -euo pipefail

CATALOG_DIR="data/catalog"
CONTENT_DIR="content/en/components"
LANG="en"

mkdir -p "${CONTENT_DIR}"

echo "Generating component stub pages from catalog…"

for file in "${CATALOG_DIR}"/*.yaml; do
  filename="$(basename "$file")"

  # Skip versions.yaml explicitly
  if [[ "$filename" == "versions.yaml" ]]; then
    echo "↷ Skipping ${filename}"
    continue
  fi

  # Extract fields using yq (v4+)
  slug=$(yq '.slug // ""' "$file")
  name=$(yq '.name // ""' "$file")

  if [[ -z "$slug" ]]; then
    echo "❌ Missing slug in $file"
    exit 1
  fi

  if [[ -z "$name" ]]; then
    echo "❌ Missing name in $file"
    exit 1
  fi

  target="${CONTENT_DIR}/${slug}.${LANG}.md"

  cat <<EOF > "$target"
---
title: "${name}"
slug: "${slug}"
layout: "components/single"
sidebar: false
_build:
  render: always
  list: never
---
EOF

  echo "✔ Generated ${target}"
done

echo "✅ Component stub generation complete."
