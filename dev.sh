#!/bin/bash

echo -e "\033[0;32mStarting Hugo...\033[0m"

hugo server --environment local \
            --watch
