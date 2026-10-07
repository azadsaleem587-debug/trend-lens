const express = require('express');
const { TEMPLATES_FILE, readJson } = require('../lib/store');

const router = express.Router();

// GET /api/templates — public list; data/templates.json is the single
// source of truth, edited via the admin panel (or /api/admin/templates).
router.get('/', (req, res) => {
  res.json(readJson(TEMPLATES_FILE, []));
});

module.exports = router;
