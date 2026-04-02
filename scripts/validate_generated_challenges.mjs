import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const currentFilePath = fileURLToPath(import.meta.url);
const repoRoot = path.resolve(path.dirname(currentFilePath), '..');
const generatedPath = path.join(repoRoot, 'assets', 'bootstrap', 'generated_text_challenges.json');

async function main() {
  const raw = await fs.readFile(generatedPath, 'utf8');
  const challenges = JSON.parse(raw);

  if (!Array.isArray(challenges)) {
    throw new Error('generated_text_challenges.json must contain an array');
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

    assert(challenge.mode === 'text', `${challenge.id} must be text mode`);
    assert(['easy', 'normal', 'hard'].includes(challenge.difficulty), `${challenge.id} has invalid difficulty`);
    assert(typeof challenge.explanation === 'string' && challenge.explanation.length >= 40, `${challenge.id} explanation is too short`);
    assert(Array.isArray(challenge.options) && challenge.options.length === 2, `${challenge.id} must have 2 options`);

    const sourceTypes = challenge.options.map((option) => option.sourceType).sort().join(',');
    assert(sourceTypes === 'ai,human', `${challenge.id} must contain one human and one ai option`);

    for (const option of challenge.options) {
      assert(typeof option.id === 'string' && option.id.length > 0, `${challenge.id} has option without id`);
      assert(typeof option.text === 'string' && countCjk(option.text) >= 180, `${challenge.id}/${option.id} answer is too short`);
    }
  }

  console.log(`validated ${challenges.length} generated text challenges`);
}

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function countCjk(value) {
  return [...String(value)].filter((char) => /[\u3400-\u9fff]/u.test(char)).length;
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
