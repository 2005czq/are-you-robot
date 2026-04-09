import fs from 'node:fs/promises';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

import { updateSeedManifest } from './bootstrap_manifest.mjs';

const currentFilePath = fileURLToPath(import.meta.url);
const repoRoot = path.resolve(path.dirname(currentFilePath), '..');
const envPath = path.join(repoRoot, '.env');
const picDir = path.join(repoRoot, 'pic');
const outputPath = path.join(repoRoot, 'assets', 'bootstrap', 'generated_image_challenges.json');
const manifestPath = path.join(repoRoot, 'assets', 'bootstrap', 'seed_manifest.json');
const difficulties = ['easy', 'normal', 'hard'];

async function main() {
  const env = await readEnv(envPath);
  const baseUrl = requiredEnv(env, 'OPENAI_BASE_URL');
  const apiKey = requiredEnv(env, 'OPENAI_API_KEY');
  const model = env.OPENAI_MODEL || 'gpt-5.4';
  const pairs = await discoverPairs(picDir);
  const challenges = [];

  for (const pair of pairs) {
    const challenge = await generateSingleChallenge({
      baseUrl,
      apiKey,
      model,
      pair,
    });

    challenges.push(challenge);
    await fs.writeFile(outputPath, `${JSON.stringify(challenges, null, 2)}\n`, 'utf8');
    console.log(`generated ${pair.slug}: ${challenge.title}`);
  }

  validateChallengeSet(challenges);

  await updateSeedManifest(manifestPath, {
    ensureSeeds: [
      {
        assetPath: 'assets/bootstrap/generated_text_challenges.json',
        kind: 'generated-text',
      },
      {
        assetPath: 'assets/bootstrap/generated_image_challenges.json',
        kind: 'generated-image',
      },
    ],
  });

  console.log(`wrote ${challenges.length} challenges to ${path.relative(repoRoot, outputPath)}`);
}

async function discoverPairs(directory) {
  const entries = await fs.readdir(directory);
  const trueFiles = new Map();
  const falseFiles = new Map();

  for (const entry of entries) {
    const trueMatch = entry.match(/^true(\d+)\.[^.]+$/i);
    if (trueMatch) {
      trueFiles.set(Number.parseInt(trueMatch[1], 10), entry);
      continue;
    }

    const falseMatch = entry.match(/^false(\d+)\.[^.]+$/i);
    if (falseMatch) {
      falseFiles.set(Number.parseInt(falseMatch[1], 10), entry);
    }
  }

  const indexes = [...trueFiles.keys()].filter((index) => falseFiles.has(index)).sort((left, right) => left - right);
  if (indexes.length === 0) {
    throw new Error('No matching trueN/falseN image pairs found in pic/');
  }

  return indexes.map((index) => ({
    index,
    slug: String(index).padStart(3, '0'),
    humanPath: path.join(picDir, trueFiles.get(index)),
    aiPath: path.join(picDir, falseFiles.get(index)),
    humanAsset: `pic/${trueFiles.get(index)}`,
    aiAsset: `pic/${falseFiles.get(index)}`,
  }));
}

async function generateSingleChallenge({ baseUrl, apiKey, model, pair }) {
  const humanImage = await encodeImageForVision(pair.humanPath);
  const aiImage = await encodeImageForVision(pair.aiPath);
  let lastError;

  for (let attempt = 1; attempt <= 4; attempt += 1) {
    try {
      const response = await fetch(`${baseUrl.replace(/\/$/, '')}/chat/completions`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify(buildPayload({
          model,
          pair,
          humanImage,
          aiImage,
        })),
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`generation failed for pair ${pair.slug}: ${response.status} ${errorText}`);
      }

      const json = await response.json();
      const content = json.choices?.[0]?.message?.content;
      if (typeof content !== 'string') {
        throw new Error(`missing structured output for pair ${pair.slug}`);
      }

      const parsed = parseLooseJson(content);
      return normalizeChallenge(parsed, pair);
    } catch (error) {
      lastError = error;
      if (attempt < 4) {
        await sleep(1000 * attempt);
      }
    }
  }

  throw lastError;
}

function buildPayload({ model, pair, humanImage, aiImage }) {
  return {
    model,
    temperature: 0.7,
    messages: [
      {
        role: 'system',
        content:
          '你是一个儿童向图灵测试图片题编辑。你会同时看到一张真实照片和一张 AI 生成图。你的任务是根据图像里的实际内容，为这组图片生成可直接入库的中文题目元数据。标题和提问必须贴合画面本身，不能写成泛泛的占位词。解释要指出真实照片和 AI 图在光线、边缘、材质、重复纹理、景深或结构上的差别，简洁具体，不要提文件名、左右位置或“第一张第二张”。只输出一个 JSON 对象。',
      },
      {
        role: 'user',
        content: [
          {
            type: 'text',
            text:
              `请根据下面这组图片生成 1 道图片挑战题。\n` +
              `已知真实照片文件是 ${path.basename(pair.humanPath)}，AI 生成图文件是 ${path.basename(pair.aiPath)}。\n` +
              '输出要求：\n' +
              '1. 只输出 JSON，不要 Markdown。\n' +
              '2. JSON 字段只能包含 title、prompt、difficulty、explanation。\n' +
              '3. title 要短，像题目标题。\n' +
              '4. prompt 要像直接对孩子说的话，表达“哪一张更像真实拍到的画面”。\n' +
              '5. difficulty 只能是 easy、normal、hard 之一。\n' +
              '6. explanation 用 40 到 100 个汉字，说明真人照片和 AI 图可观察到的区别。\n' +
              '7. 不要在 explanation 里说左右、第一张、第二张，也不要泄露文件名。',
          },
          {
            type: 'text',
            text: '真实照片：',
          },
          {
            type: 'image_url',
            image_url: {
              url: humanImage,
            },
          },
          {
            type: 'text',
            text: 'AI 生成图：',
          },
          {
            type: 'image_url',
            image_url: {
              url: aiImage,
            },
          },
        ],
      },
    ],
    response_format: {
      type: 'json_schema',
      json_schema: {
        name: 'image_challenge_item',
        strict: true,
        schema: {
          type: 'object',
          additionalProperties: false,
          required: ['title', 'prompt', 'difficulty', 'explanation'],
          properties: {
            title: { type: 'string' },
            prompt: { type: 'string' },
            difficulty: { type: 'string', enum: difficulties },
            explanation: { type: 'string' },
          },
        },
      },
    },
  };
}

function normalizeChallenge(challenge, pair) {
  const slug = pair.slug;
  const difficulty = normalizeDifficulty(challenge.difficulty);
  if (!difficulty) {
    throw new Error(`invalid difficulty for pair ${slug}`);
  }

  return {
    id: `image-${slug}`,
    mode: 'image',
    title: normalizeText(challenge.title),
    prompt: normalizeText(challenge.prompt),
    difficulty,
    explanation: normalizeText(challenge.explanation),
    options: [
      {
        id: `image-${slug}-a`,
        label: 'A',
        sourceType: 'human',
        asset: pair.humanAsset,
      },
      {
        id: `image-${slug}-b`,
        label: 'B',
        sourceType: 'ai',
        asset: pair.aiAsset,
      },
    ],
  };
}

async function encodeImageForVision(filePath) {
  const buffer = execFileSync(
    'convert',
    [
      filePath,
      '-auto-orient',
      '-background',
      'white',
      '-alpha',
      'remove',
      '-alpha',
      'off',
      '-resize',
      '1400x1400>',
      '-strip',
      '-quality',
      '82',
      'jpg:-',
    ],
    {
      stdio: ['ignore', 'pipe', 'pipe'],
      maxBuffer: 32 * 1024 * 1024,
    },
  );

  return `data:image/jpeg;base64,${buffer.toString('base64')}`;
}

function validateChallengeSet(challenges) {
  const ids = new Set();
  const titles = new Set();

  for (const challenge of challenges) {
    if (ids.has(challenge.id)) {
      throw new Error(`duplicate challenge id: ${challenge.id}`);
    }
    ids.add(challenge.id);

    if (titles.has(challenge.title)) {
      throw new Error(`duplicate challenge title: ${challenge.title}`);
    }
    titles.add(challenge.title);

    if (challenge.mode !== 'image') {
      throw new Error(`invalid mode for ${challenge.id}`);
    }

    if (!difficulties.includes(challenge.difficulty)) {
      throw new Error(`invalid difficulty for ${challenge.id}`);
    }

    if (!Array.isArray(challenge.options) || challenge.options.length !== 2) {
      throw new Error(`invalid options length for ${challenge.id}`);
    }

    if (!challenge.prompt || !challenge.explanation) {
      throw new Error(`missing prompt or explanation for ${challenge.id}`);
    }
  }
}

function normalizeDifficulty(value) {
  const normalized = normalizeText(value).toLowerCase();
  if (!normalized) {
    return 'normal';
  }

  if (['easy', '简单', '容易', '初级', '低'].includes(normalized)) {
    return 'easy';
  }

  if (['normal', '中等', '普通', '一般', '中'].includes(normalized)) {
    return 'normal';
  }

  if (['hard', '困难', '难', '高级', '高'].includes(normalized)) {
    return 'hard';
  }

  return null;
}

function parseLooseJson(content) {
  const trimmed = String(content).trim();

  try {
    return JSON.parse(trimmed);
  } catch {
    const fenced = trimmed.replace(/^```json\s*/i, '').replace(/^```\s*/i, '').replace(/```$/i, '').trim();
    try {
      return JSON.parse(fenced);
    } catch {
      const start = fenced.indexOf('{');
      const end = fenced.lastIndexOf('}');
      if (start !== -1 && end !== -1 && end > start) {
        return JSON.parse(fenced.slice(start, end + 1));
      }
      throw new Error('unable to parse JSON content');
    }
  }
}

function normalizeText(value) {
  return String(value ?? '').replace(/\r\n/g, '\n').replace(/\s+$/g, '').trim();
}

async function readEnv(filePath) {
  const raw = await fs.readFile(filePath, 'utf8');
  const entries = raw
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line && !line.startsWith('#'))
    .map((line) => {
      const separatorIndex = line.indexOf('=');
      if (separatorIndex === -1) {
        return null;
      }
      const key = line.slice(0, separatorIndex).trim();
      const value = line.slice(separatorIndex + 1).trim();
      return [key, value];
    })
    .filter(Boolean);

  return Object.fromEntries(entries);
}

function requiredEnv(env, key) {
  if (!env[key]) {
    throw new Error(`Missing ${key} in .env`);
  }
  return env[key];
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
