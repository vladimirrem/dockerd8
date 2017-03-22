#!/usr/bin/env bash

set -e

if [ ! -d ./html ]; then
  echo "First start? (y/n):"
  read conf
  if [ "$conf == y" ]; then
    chmod +x ./scripts/install.sh
    chmod +x ./scripts/dru
    chmod +x ./scripts/com
    ./scripts/install.sh
  fi
fi

