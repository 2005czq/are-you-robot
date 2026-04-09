import crypto from 'node:crypto';
import fs from 'node:fs/promises';
import path from 'node:path';

export async function updateSeedManifest(manifestFilePath, { ensureSeeds = [] } = {}) {
  const raw = await fs.readFile(manifestFilePath, 'utf8');
  const manifest = JSON.parse(raw);
  const repoRoot = path.resolve(path.dirname(manifestFilePath), '..', '..');

  for (const ensuredSeed of ensureSeeds) {
    const existing = manifest.seeds.find((seed) => seed.assetPath === ensuredSeed.assetPath);
    if (existing) {
      if (ensuredSeed.kind) {
        existing.kind = ensuredSeed.kind;
      }
      continue;
    }

    manifest.seeds.push({
      assetPath: ensuredSeed.assetPath,
      kind: ensuredSeed.kind,
    });
  }

  const signatureParts = [];

  for (const seed of manifest.seeds) {
    const absolutePath = path.join(repoRoot, seed.assetPath);
    const content = await fs.readFile(absolutePath);
    const checksum = crypto.createHash('sha256').update(content).digest('hex').slice(0, 16);
    signatureParts.push(`${seed.assetPath}:${checksum}`);

    if (seed.kind !== 'bootstrap' || seed.checksum) {
      seed.checksum = checksum;
    }
  }

  const signature = crypto
    .createHash('sha256')
    .update(signatureParts.join('|'))
    .digest('hex')
    .slice(0, 16);

  manifest.signature = `bootstrap-v3-${signature}`;

  await fs.writeFile(manifestFilePath, `${JSON.stringify(manifest, null, 2)}\n`, 'utf8');
}
