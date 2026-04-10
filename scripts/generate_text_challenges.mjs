import crypto from 'node:crypto';
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { updateSeedManifest } from './bootstrap_manifest.mjs';

const currentFilePath = fileURLToPath(import.meta.url);
const repoRoot = path.resolve(path.dirname(currentFilePath), '..');
const envPath = path.join(repoRoot, '.env');
const outputPath = path.join(repoRoot, 'assets', 'bootstrap', 'generated_text_challenges.json');
const manifestPath = path.join(repoRoot, 'assets', 'bootstrap', 'seed_manifest.json');
const explanationOrderingReferencePattern = /(A段|B段|A选项|B选项|A回答|B回答|第一段|第二段|第1段|第2段|第一个选项|第二个选项|第一个回答|第二个回答|左边|右边|左侧|右侧|前者|后者)/u;

const topics = [
  '忘记带作业时的心情',
  '第一次独自坐公交',
  '家里最安静的角落',
  '让人尴尬的一次误会',
  '最想保留的一件旧东西',
  '一场突然下起来的雨',
  '最不喜欢但忘不掉的气味',
  '跟长辈一起逛菜市场',
  '一次没睡醒去上学的早晨',
  '印象很深的一次停电',
  '午睡醒来分不清时间的感觉',
  '一次排很久队才买到的东西',
  '被别人安慰的一瞬间',
  '最奇怪的一次梦',
  '一个让人舍不得扔掉的包装袋',
  '冬天教室里的味道',
  '因为迟到一路狂跑的经历',
  '不太会做但很想学会的家务',
  '一张总会想起的餐桌',
  '一次看牙之前的紧张',
  '最有安全感的一种声音',
  '朋友借给你的一样东西',
  '一次以为自己丢东西了',
  '一个总让人走神的下午',
  '你见过最像电影镜头的街角',
  '运动会里最累的项目',
  '最怕在全班面前发生的事',
  '第一次自己做饭',
  '旅行回来后最先想念的东西',
  '一件明明很小却一直记得的善意',
  '换座位之后的感觉',
  '最喜欢但不常吃到的一样食物',
  '一次等人的过程',
  '让你突然想家的时刻',
  '夏天楼道里的声音',
  '买新文具那天的心情',
  '一次体育课上的意外',
  '一个你总记不住名字的人',
  '第一次剪坏头发之后',
  '一个看起来普通但很重要的习惯',
  '你小时候相信过的奇怪说法',
  '一次差点赶不上车',
  '最适合发呆的天气',
  '一件借出去后一直惦记的东西',
  '走夜路时会注意到的细节',
  '考试结束铃响后的几秒钟',
  '一个你总会绕路去看的地方',
  '秋天傍晚的操场边',
  '一次吃得太急被烫到',
  '一个总让你想起小时候的颜色'
];

const difficulties = ['easy', 'normal', 'hard'];

async function main() {
  const env = await readEnv(envPath);
  const baseUrl = requiredEnv(env, 'OPENAI_BASE_URL');
  const apiKey = requiredEnv(env, 'OPENAI_API_KEY');
  const model = env.OPENAI_MODEL || 'gpt-5.4';

  const runLabel = `run-${Date.now()}-${crypto.randomUUID().slice(0, 8)}`;
  const challenges = await readExistingChallenges();

  for (let index = challenges.length; index < topics.length; index += 1) {
    const topic = topics[index];
    const challenge = await generateSingleChallenge({
      baseUrl,
      apiKey,
      model,
      topic,
      index,
      runLabel,
    });
    challenges.push(challenge);
    await fs.writeFile(outputPath, `${JSON.stringify(challenges, null, 2)}\n`, 'utf8');
    console.log(`generated ${index + 1}/${topics.length}: ${challenge.id}`);
  }

  validateChallengeSet(challenges);

  await updateSeedManifest(manifestPath, {
    ensureSeeds: [
      {
        assetPath: 'assets/bootstrap/generated_text_challenges.json',
        kind: 'generated-text',
      },
    ],
  });

  console.log(`wrote ${challenges.length} challenges to ${path.relative(repoRoot, outputPath)}`);
}

async function generateSingleChallenge({ baseUrl, apiKey, model, topic, index, runLabel }) {
  let lastError;

  for (let attempt = 1; attempt <= 4; attempt += 1) {
    const nonce = crypto.randomUUID();
    const requestFingerprint = crypto
        .createHash('sha256')
        .update(`${runLabel}:${index}:${topic}:${nonce}:attempt-${attempt}`)
        .digest('hex')
        .slice(0, 16);

    const payload = buildPayload({
      model,
      topic,
      runLabel,
      nonce,
      requestFingerprint,
    });

    try {
      const response = await fetch(`${baseUrl.replace(/\/$/, '')}/chat/completions`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${apiKey}`,
          'X-Run-Label': runLabel,
          'X-Cache-Busting-Nonce': nonce,
        },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`generation failed for topic ${topic}: ${response.status} ${errorText}`);
      }

      const json = await response.json();
      const content = json.choices?.[0]?.message?.content;
      if (typeof content !== 'string') {
        throw new Error(`missing structured output for topic ${topic}`);
      }

      const parsed = parseLooseJson(content);
      const normalized = normalizeChallenge(parsed, index, topic);
      validateChallengeSet([normalized]);
      return normalized;
    } catch (error) {
      lastError = error;
      if (attempt < 4) {
        await sleep(800 * attempt);
      }
    }
  }

  throw lastError;
}

function buildPayload({ model, topic, runLabel, nonce, requestFingerprint }) {
  return {
    model,
    temperature: 1.1,
    messages: [
      {
        role: 'system',
        content:
          '你是一个儿童向图灵测试题库编辑。你要生成可审核、可比较、可直接入库的中文文字题。每题必须有一个看起来像真人随手写的长回答和一个看起来像机器写的长回答，但两者都要自然、都不能自曝身份、不能提到 AI、模型、提示词、训练数据或系统指令。每个回答都要足够长，细节具体，可供孩子观察口吻差异。explanation 必须直接使用“真人回答”“AI回答”这类明确表述，不要使用 A/B、左右、前者后者、第一段第二段等顺序或位置指代。输出 JSON 时，字段键名必须使用英文，且只能使用这些键名：mode,title,prompt,difficulty,explanation,options,label,sourceType,text。',
      },
      {
        role: 'user',
        content:
          `请围绕主题“${topic}”生成 1 道文字挑战题。\n` +
          `运行标签：${runLabel}\n` +
          `去缓存随机盐：${nonce}\n` +
          `请求指纹：${requestFingerprint}\n` +
          '输出要求：\n' +
          '1. mode 固定为 text。\n' +
          '2. title 要像题目标题，简短自然。\n' +
          '3. prompt 是直接问孩子的话。\n' +
          '4. difficulty 只能是 easy、normal、hard 之一。\n' +
          '5. explanation 要指出两段回答在口吻、细节、组织方式上的区别，80 到 140 字，并且必须直接使用“真人回答”和“AI回答”来说明区别。\n' +
          '6. options 必须正好 2 个，一个 sourceType 为 human，一个 sourceType 为 ai。\n' +
          '7. 两个 answer 都必须是长回答，每个至少 180 个汉字。\n' +
          '8. human 风格要有轻微跳跃、个人犹豫、具体场景、偶发细节，但仍然通顺。\n' +
          '9. ai 风格要更完整、更均衡、更像整理后的表达，但依旧自然，不要僵硬套话。\n' +
          '10. label 先给 A/B 即可，后续客户端会重新随机。\n' +
          '11. explanation 不得使用 A/B、左右、前者/后者、第一段/第二段、第一个选项/第二个选项、第一个回答/第二个回答 这类位置或顺序指代。\n' +
          '12. 不要输出 Markdown，不要解释，只输出一个 JSON 对象。\n',
      },
    ],
    response_format: {
      type: 'json_schema',
      json_schema: {
        name: 'challenge_item',
        strict: true,
        schema: {
          type: 'object',
          additionalProperties: false,
          required: ['mode', 'title', 'prompt', 'difficulty', 'explanation', 'options'],
          properties: {
            mode: { type: 'string', enum: ['text'] },
            title: { type: 'string' },
            prompt: { type: 'string' },
            difficulty: { type: 'string', enum: difficulties },
            explanation: { type: 'string' },
            options: {
              type: 'array',
              minItems: 2,
              maxItems: 2,
              items: {
                type: 'object',
                additionalProperties: false,
                required: ['label', 'sourceType', 'text'],
                properties: {
                  label: { type: 'string', enum: ['A', 'B'] },
                  sourceType: { type: 'string', enum: ['human', 'ai'] },
                  text: { type: 'string' },
                },
              },
            },
          },
        },
      },
    },
  };
}

function normalizeChallenge(challenge, index, topic) {
  const source = unwrapChallenge(challenge);
  const slug = String(index + 1).padStart(3, '0');
  const normalizedOptions = collectNormalizedOptions(source.options ?? source.answers ?? source.choices ?? []);
  if (normalizedOptions.length !== 2) {
    throw new Error(`unable to normalize two options for topic ${topic}`);
  }

  const difficulty = normalizeDifficulty(source.difficulty);
  if (!difficulty) {
    throw new Error(`unable to normalize difficulty for topic ${topic}`);
  }

  const options = normalizedOptions.map((option, optionIndex) => ({
    id: `generated-text-${slug}-${String.fromCharCode(97 + optionIndex)}`,
    label: optionIndex === 0 ? 'A' : 'B',
    sourceType: option.sourceType,
    text: normalizeText(option.text),
  }));

  return {
    id: `generated-text-${slug}`,
    mode: 'text',
    title: normalizeText(source.title || topic),
    prompt: normalizeText(source.prompt || `如果让你聊聊“${topic}”，你会怎么说？`),
    difficulty,
    explanation: normalizeText(source.explanation),
    options,
  };
}

function unwrapChallenge(value) {
  if (Array.isArray(value)) {
    return unwrapChallenge(value[0]);
  }

  if (value && typeof value === 'object') {
    if (value.challenge && typeof value.challenge === 'object') {
      return unwrapChallenge(value.challenge);
    }
    if (value.item && typeof value.item === 'object') {
      return unwrapChallenge(value.item);
    }
  }

  return value ?? {};
}

function collectNormalizedOptions(options) {
  const picked = [];
  const seenSourceTypes = new Set();

  for (const option of Array.isArray(options) ? options : []) {
    const sourceType = normalizeSourceType(
      option?.sourceType ?? option?.type ?? option?.role ?? option?.label,
    );
    const text = normalizeText(option?.text ?? option?.content ?? option?.answer ?? '');
    if (!sourceType || !text || seenSourceTypes.has(sourceType)) {
      continue;
    }

    seenSourceTypes.add(sourceType);
    picked.push({ sourceType, text });
  }

  return picked.sort((left, right) => left.sourceType.localeCompare(right.sourceType));
}

function normalizeSourceType(value) {
  const normalized = normalizeText(value).toLowerCase();
  if (!normalized) {
    return null;
  }

  if (['human', '真人', '人类', '人写', '真实', 'real', 'person'].includes(normalized)) {
    return 'human';
  }

  if (['ai', '机器', '人工智能', '模型', '生成', 'machine', 'robot'].includes(normalized)) {
    return 'ai';
  }

  return null;
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

    if (challenge.mode !== 'text') {
      throw new Error(`invalid mode for ${challenge.id}`);
    }

    if (!difficulties.includes(challenge.difficulty)) {
      throw new Error(`invalid difficulty for ${challenge.id}`);
    }

    if (containsExplanationOrderingReference(challenge.explanation)) {
      throw new Error(`explanation uses order-dependent wording for ${challenge.id}`);
    }

    if (!Array.isArray(challenge.options) || challenge.options.length !== 2) {
      throw new Error(`invalid options length for ${challenge.id}`);
    }

    const sourceTypes = challenge.options.map((option) => option.sourceType).sort().join(',');
    if (sourceTypes !== 'ai,human') {
      throw new Error(`source types must be one ai and one human for ${challenge.id}`);
    }

    for (const option of challenge.options) {
      if (countCjk(option.text) < 180) {
        throw new Error(`answer too short for ${challenge.id}/${option.sourceType}`);
      }
    }
  }
}

function normalizeText(value) {
  return String(value).replace(/\r\n/g, '\n').replace(/\s+$/g, '').trim();
}

function countCjk(value) {
  return [...String(value)].filter((char) => /[\u3400-\u9fff]/u.test(char)).length;
}

function containsExplanationOrderingReference(value) {
  return explanationOrderingReferencePattern.test(String(value));
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

async function readExistingChallenges() {
  try {
    const raw = await fs.readFile(outputPath, 'utf8');
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
