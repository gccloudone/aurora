#!/bin/bash

echo -e "\033[0;32mStarting Hugo...\033[0m"

./scripts/generate-component-stubs.sh

hugo server --environment local \
            --watch
