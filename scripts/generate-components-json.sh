#!/usr/bin/env bash
# generate-components-json.sh
# Reads catalog YAML files and versions.yaml, outputs static/components.json
# for CCCS supply chain integrity review.
set -euo pipefail

CATALOG_DIR="data/catalog"
OUTPUT="static/components.json"

mkdir -p static

echo "Generating components.json for CCCS review…"

# Start JSON array
echo "[" > "$OUTPUT"

first=true

for file in "${CATALOG_DIR}"/*.yaml; do
  filename="$(basename "$file")"

  # Skip versions.yaml
  if [[ "$filename" == "versions.yaml" ]]; then
    continue
  fi

  name=$(yq '.name // ""' "$file")
  slug=$(yq '.slug // ""' "$file")
  product_version=$(yq '.productVersion // ""' "$file")
  homepage=$(yq '.project.homepage // ""' "$file")
  documentation=$(yq '.project.documentation // ""' "$file")
  cncf_landscape=$(yq '.project.cncf_landscape // ""' "$file")
  license=$(yq '.project.license // ""' "$file")
  category_hld=$(yq '.category.hld // ""' "$file")
  category_type=$(yq '.category.type // ""' "$file")
  short_desc=$(yq '.descriptions.short // ""' "$file")

  # Build sites array
  sites="["
  site_first=true
  for site in "$homepage" "$documentation" "$cncf_landscape"; do
    # Skip empty sites
    if [[ -z "$site" || "$site" == '""' || "$site" == "null" ]]; then
      continue
    fi
    if [[ "$site_first" == "true" ]]; then
      site_first=false
    else
      sites="${sites}, "
    fi
    sites="${sites}\"${site}\""
  done
  sites="${sites}]"

  # Escape double quotes in descriptions
  short_desc_escaped=$(echo "$short_desc" | sed 's/"/\\"/g')

  if [[ "$first" == "true" ]]; then
    first=false
  else
    echo "," >> "$OUTPUT"
  fi

  # Use yq to produce clean JSON for this component
  yq -o=json '.' "$file" | jq -c '{
    name: .name,
    slug: .slug,
    productVersion: .productVersion,
    category: .category.hld,
    type: .category.type,
    description: .descriptions.short,
    license: .project.license,
    sites: [
      .project.homepage,
      .project.documentation,
      .project.cncf_landscape
    ] | map(select(. != null and . != "")),
    cost: "$0.00 (opensource)",
    highestClassification: "Secret",
    hostedOnGCNetworks: true
  }' >> "$OUTPUT"
done

echo "" >> "$OUTPUT"
echo "]" >> "$OUTPUT"

# Pretty-print the JSON
if command -v jq &> /dev/null; then
  jq '.' "$OUTPUT" > "${OUTPUT}.tmp" && mv "${OUTPUT}.tmp" "$OUTPUT"
fi

echo "✅ Generated ${OUTPUT}"
echo "   Components exported: $(jq length "$OUTPUT")"
