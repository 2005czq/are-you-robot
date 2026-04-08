#!/usr/bin/env node

import { readFile, rm, writeFile } from 'node:fs/promises';
import path from 'node:path';

const buildDir = process.argv[2] ?? path.join('build', 'web');
const fontManifestPath = path.join(buildDir, 'assets', 'FontManifest.json');
const localWebFontFamily = 'NotoSerifSC';

const manifest = JSON.parse(await readFile(fontManifestPath, 'utf8'));
const removedAssets = manifest
  .filter((entry) => entry.family === localWebFontFamily)
  .flatMap((entry) => entry.fonts.map((font) => font.asset));

if (removedAssets.length == 0) {
  console.log(`No local ${localWebFontFamily} fonts found in ${buildDir}.`);
  process.exit(0);
}

const filteredManifest = manifest.filter((entry) => entry.family !== localWebFontFamily);
await writeFile(fontManifestPath, JSON.stringify(filteredManifest));

for (const asset of removedAssets) {
  const assetPath = path.join(buildDir, 'assets', ...asset.split('/'));
  await rm(assetPath, {force: true});
}

console.log(`Removed ${removedAssets.length} local ${localWebFontFamily} font assets from ${buildDir}.`);
