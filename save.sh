#!/bin/bash
set -euo pipefail

zig build --release=small
sudo cp ./zig-out/bin/launcher /usr/local/bin/launcher
