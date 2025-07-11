#!/bin/bash

set -e

# Input and output
input_file="2025-06-gc-artifacts.html"
output_file="newsletter-inlined.html"

# Confirm required files exist
for f in assets/background.jpeg assets/canada-logo.svg assets/ssc-text.svg "$input_file"; do
  if [ ! -f "$f" ]; then
    echo "❌ Error: $f not found."
    exit 1
  fi
done

# Encode files using cat | base64
bg64=$(cat assets/background.jpeg | base64 | tr -d '\n')
canada64=$(cat assets/canada-logo.svg | base64 | tr -d '\n')
ssc64=$(cat assets/ssc-text.svg | base64 | tr -d '\n')

# Copy HTML file
cp "$input_file" "$output_file"

# Inline replacements
sed -i '' "s|url('background.jpeg')|url(\"data:image/jpeg;base64,$bg64\")|g" "$output_file"
sed -i '' "s|src=\"canada-logo.svg\"|src=\"data:image/svg+xml;base64,$canada64\"|g" "$output_file"
sed -i '' "s|src=\"ssc-text.svg\"|src=\"data:image/svg+xml;base64,$ssc64\"|g" "$output_file"

echo "✅ Fully inlined newsletter written to $output_file"
