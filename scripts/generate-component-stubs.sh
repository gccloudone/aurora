#!/usr/bin/env bash
set -euo pipefail

CATALOG_DIR="data/catalog"
CONTENT_DIR="content"
LANGUAGES=("en" "fr")

echo "Generating component stub pages from catalog…"

for lang in "${LANGUAGES[@]}"; do
  dir="${CONTENT_DIR}/${lang}/components"
  mkdir -p "${dir}"
  echo ""
  echo "--- Language: ${lang} ---"

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

    target="${dir}/${slug}.${lang}.md"

    today=$(date +%Y-%m-%d)
    cat <<EOF > "$target"
---
title: "${name}"
slug: "${slug}"
date: "${today}"
lastmod: "${today}"
layout: "components/single"
sidebar: false
build:
  render: always
  list: never
---
EOF

    echo "✔ Generated ${target}"
  done
done

echo ""
echo "✅ Component stub generation complete."
