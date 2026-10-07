const express = require('express');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const rateLimit = require('express-rate-limit');

const router = express.Router();

const CACHE_DIR = process.env.AI_CACHE_DIR || path.resolve(__dirname, '..', '..', 'cache', 'ai');
const PER_HOUR = parseInt(process.env.RATE_LIMIT_PER_HOUR || '20', 10);

// Free tier: 20 generations/hour per IP by default.
const aiLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  limit: PER_HOUR,
  standardHeaders: 'draft-7',
  legacyHeaders: false,
  message: { error: 'ai_rate_limited' },
});
router.use(aiLimiter);

function cacheKey(prompt, width, height, seed) {
  return crypto
    .createHash('sha256')
    .update(`${prompt}|${width}|${height}|${seed ?? ''}`)
    .digest('hex');
}

function clamp(n, fallback, min, max) {
  const v = parseInt(n, 10);
  if (Number.isNaN(v)) return fallback;
  return Math.min(Math.max(v, min), max);
}

// POST /api/ai/style — free AI image proxy (Pollinations, no API key needed).
// Body: { prompt, width?, height?, seed? }
router.post('/style', async (req, res) => {
  const { prompt, seed } = req.body || {};
  if (!prompt || typeof prompt !== 'string' || !prompt.trim()) {
    return res.status(400).json({ error: 'prompt_required' });
  }

  const width = clamp(req.body.width, 768, 64, 2048);
  const height = clamp(req.body.height, 1024, 64, 2048);
  const seedStr = seed === undefined || seed === null ? '' : String(seed);

  const key = cacheKey(prompt.trim(), width, height, seedStr);
  const imgPath = path.join(CACHE_DIR, `${key}.jpg`);
  const metaPath = path.join(CACHE_DIR, `${key}.json`);

  // Disk cache first.
  if (fs.existsSync(imgPath)) {
    let contentType = 'image/jpeg';
    try {
      contentType = JSON.parse(fs.readFileSync(metaPath, 'utf8')).contentType || contentType;
    } catch {
      /* sidecar missing — default is fine */
    }
    res.set('X-Cache', 'HIT');
    res.type(contentType);
    return fs.createReadStream(imgPath).pipe(res);
  }

  const params = new URLSearchParams({ width: String(width), height: String(height), model: 'flux', nologo: 'true' });
  if (seedStr !== '') params.set('seed', seedStr);
  const url = `https://image.pollinations.ai/prompt/${encodeURIComponent(prompt.trim())}?${params}`;

  let upstream;
  try {
    upstream = await fetch(url);
  } catch {
    return res.status(502).json({ error: 'ai_upstream_failed' });
  }
  if (!upstream.ok || !upstream.body) {
    return res.status(502).json({ error: 'ai_upstream_failed' });
  }

  const contentType = upstream.headers.get('content-type') || 'image/jpeg';
  const buf = Buffer.from(await upstream.arrayBuffer());

  // Only cache image payloads.
  if (contentType.startsWith('image/')) {
    fs.mkdirSync(CACHE_DIR, { recursive: true });
    fs.writeFileSync(imgPath, buf);
    fs.writeFileSync(metaPath, JSON.stringify({ contentType, prompt: prompt.trim(), width, height, seed: seedStr }));
  }

  res.set('X-Cache', 'MISS');
  res.type(contentType);
  res.send(buf);
});

module.exports = router;
