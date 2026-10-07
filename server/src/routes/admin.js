const express = require('express');
const fs = require('fs');
const path = require('path');
const { TEMPLATES_FILE, USERS_FILE, readJson, writeJson } = require('../lib/store');

const router = express.Router();

const UPLOAD_DIR = process.env.UPLOAD_DIR || path.resolve(__dirname, '..', '..', 'uploads');
const AI_CACHE_DIR = process.env.AI_CACHE_DIR || path.resolve(__dirname, '..', '..', 'cache', 'ai');

function walk(dir, include = () => true) {
  let count = 0;
  let bytes = 0;
  if (!fs.existsSync(dir)) return { count, bytes };
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      const sub = walk(p, include);
      count += sub.count;
      bytes += sub.bytes;
    } else if (entry.isFile() && include(entry.name)) {
      count += 1;
      bytes += fs.statSync(p).size;
    }
  }
  return { count, bytes };
}

// GET /api/admin/stats
router.get('/stats', (req, res) => {
  const templates = readJson(TEMPLATES_FILE, []);
  const uploads = walk(UPLOAD_DIR);
  const cache = walk(AI_CACHE_DIR, (name) => name.endsWith('.jpg'));
  res.json({
    templates: templates.length,
    uploads: uploads.count,
    uploadsBytes: uploads.bytes,
    aiCacheEntries: cache.count,
    aiCacheBytes: cache.bytes,
  });
});

// --- Templates CRUD (edits data/templates.json, the public list's source) ---

router.get('/templates', (req, res) => {
  res.json(readJson(TEMPLATES_FILE, []));
});

router.post('/templates', (req, res) => {
  const templates = readJson(TEMPLATES_FILE, []);
  const t = req.body || {};
  if (!t.id || !t.title) {
    return res.status(400).json({ error: 'id_and_title_required' });
  }
  if (templates.some((x) => x.id === t.id)) {
    return res.status(409).json({ error: 'template_exists' });
  }
  templates.push(t);
  writeJson(TEMPLATES_FILE, templates);
  res.status(201).json(t);
});

router.put('/templates/:id', (req, res) => {
  const templates = readJson(TEMPLATES_FILE, []);
  const i = templates.findIndex((x) => x.id === req.params.id);
  if (i === -1) return res.status(404).json({ error: 'template_not_found' });
  templates[i] = { ...templates[i], ...(req.body || {}), id: templates[i].id };
  writeJson(TEMPLATES_FILE, templates);
  res.json(templates[i]);
});

router.delete('/templates/:id', (req, res) => {
  const templates = readJson(TEMPLATES_FILE, []);
  const next = templates.filter((x) => x.id !== req.params.id);
  if (next.length === templates.length) {
    return res.status(404).json({ error: 'template_not_found' });
  }
  writeJson(TEMPLATES_FILE, next);
  res.json({ deleted: true });
});

// --- Users (backed by data/users.json; entries auto-created) ---

router.get('/users', (req, res) => {
  res.json(readJson(USERS_FILE, []));
});

router.patch('/users/:id', (req, res) => {
  const users = readJson(USERS_FILE, []);
  let user = users.find((u) => u.id === req.params.id);
  if (!user) {
    user = { id: req.params.id, isPremium: false, quotaMb: 0 };
    users.push(user);
  }
  const { isPremium, quotaMb } = req.body || {};
  if (typeof isPremium === 'boolean') user.isPremium = isPremium;
  if (typeof quotaMb === 'number' && Number.isFinite(quotaMb)) user.quotaMb = quotaMb;
  writeJson(USERS_FILE, users);
  res.json(user);
});

module.exports = router;
