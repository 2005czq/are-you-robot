import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const currentFilePath = fileURLToPath(import.meta.url);
const repoRoot = path.resolve(path.dirname(currentFilePath), '..');
const generatedPath = path.join(repoRoot, 'assets', 'bootstrap', 'generated_image_challenges.json');
const allowedAssetRoots = [
  'pic/',
  'output/generated/',
  'output/tmp/',
  'output2/generated/',
  'output2/tmp/',
];

async function main() {
  const raw = await fs.readFile(generatedPath, 'utf8');
  const challenges = JSON.parse(raw);

  if (!Array.isArray(challenges)) {
    throw new Error('generated_image_challenges.json must contain an array');
  }

  const ids = new Set();
  const titles = new Set();

  for (const challenge of challenges) {
    if (ids.has(challenge.id)) {
      throw new Error(`duplicate id: ${challenge.id}`);
    }
    ids.add(challenge.id);

    if (titles.has(challenge.title)) {
      throw new Error(`duplicate title: ${challenge.title}`);
    }
    titles.add(challenge.title);

    assert(challenge.mode === 'image', `${challenge.id} must be image mode`);
    assert(['easy', 'normal', 'hard'].includes(challenge.difficulty), `${challenge.id} has invalid difficulty`);
    assert(typeof challenge.prompt === 'string' && challenge.prompt.length >= 8, `${challenge.id} prompt is too short`);
    assert(typeof challenge.explanation === 'string' && challenge.explanation.length >= 20, `${challenge.id} explanation is too short`);
    assert(Array.isArray(challenge.options) && challenge.options.length === 2, `${challenge.id} must have 2 options`);

    const sourceTypes = challenge.options.map((option) => option.sourceType).sort().join(',');
    assert(sourceTypes === 'ai,human', `${challenge.id} must contain one human and one ai option`);

    for (const option of challenge.options) {
      assert(typeof option.id === 'string' && option.id.length > 0, `${challenge.id} has option without id`);
      assert(
        typeof option.asset === 'string' && allowedAssetRoots.some((root) => option.asset.startsWith(root)),
        `${challenge.id}/${option.id} asset must point to a supported image root`,
      );
      await fs.access(path.join(repoRoot, option.asset));
    }
  }

  console.log(`validated ${challenges.length} generated image challenges`);
}

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
