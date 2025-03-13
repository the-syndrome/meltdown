#!/usr/bin/env fish

nvm use v23.9.0
npm install
npm prune
npm rebuild esbuild
npm run dev
