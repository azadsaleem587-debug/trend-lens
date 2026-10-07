const express = require('express');
const fs = require('fs');
const path = require('path');
const multer = require('multer');

const router = express.Router();

const UPLOAD_DIR = process.env.UPLOAD_DIR || path.resolve(__dirname, '..', '..', 'uploads');
const MAX_UPLOAD_MB = parseInt(process.env.MAX_UPLOAD_MB || '100', 10);

function sanitizeUserId(id) {
  const clean = String(id || '').replace(/[^a-zA-Z0-9_-]/g, '').slice(0, 64);
  return clean || 'anon';
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const userId = sanitizeUserId(req.headers['x-user-id']);
    const dir = path.join(UPLOAD_DIR, userId);
    fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    const safe = file.originalname.replace(/[^\w.\- ]+/g, '_').slice(0, 120) || 'file';
    cb(null, `${Date.now()}-${safe}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: MAX_UPLOAD_MB * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/') || file.mimetype.startsWith('video/')) {
      cb(null, true);
    } else {
      cb(new Error('only_image_and_video_files_allowed'));
    }
  },
});

// POST /api/upload — PREMIUM-ONLY cloud storage.
// TODO: replace the x-premium header check with real JWT auth.
router.post('/', (req, res) => {
  if (req.headers['x-premium'] !== 'true') {
    return res.status(403).json({ error: 'cloud_storage_requires_premium' });
  }

  upload.single('file')(req, res, (err) => {
    if (err) {
      if (err.code === 'LIMIT_FILE_SIZE') {
        return res.status(413).json({ error: 'file_too_large' });
      }
      return res.status(400).json({ error: err.message || 'upload_failed' });
    }
    if (!req.file) {
      return res.status(400).json({ error: 'file_required' });
    }
    const userId = sanitizeUserId(req.headers['x-user-id']);
    res.status(201).json({
      url: `/uploads/${userId}/${req.file.filename}`,
      size: req.file.size,
    });
  });
});

module.exports = router;
