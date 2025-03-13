#!/usr/bin/env fish
curl -LO https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish
source fisher.fish && fisher install jorgebucaran/fisher
fisher install jorgebucaran/nvm.fish
set nvm_mirror https://unofficial-builds.nodejs.org/download/release
set nvm_arch x64-musl
nvm install v23.9.0
nvm use v23.9.0

# npm config
npm config set -g audit false
npm config set -g fund false
npm config set -g update-notifier false
npm config set -g loglevel error
npm config set -g progress false
npm config set -g package-lock false
npm config set -g engine-strict false
