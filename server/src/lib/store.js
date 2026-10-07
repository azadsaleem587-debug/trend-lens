const path = require('path');
const fs = require('fs');

const DATA_DIR = process.env.DATA_DIR || path.resolve(__dirname, '..', '..', 'data');
const TEMPLATES_FILE = path.join(DATA_DIR, 'templates.json');
const USERS_FILE = path.join(DATA_DIR, 'users.json');

function readJson(file, fallback) {
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch (err) {
    if (err.code === 'ENOENT') return fallback;
    throw err;
  }
}

function writeJson(file, data) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, JSON.stringify(data, null, 2) + '\n');
}

module.exports = { DATA_DIR, TEMPLATES_FILE, USERS_FILE, readJson, writeJson };
