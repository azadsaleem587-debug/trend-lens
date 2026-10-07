const express = require('express');
const fs = require('fs');
const path = require('path');

const adminAuth = require('./middleware/admin_auth');
const templatesRouter = require('./routes/templates');
const aiRouter = require('./routes/ai');
const uploadRouter = require('./routes/upload');
const adminRouter = require('./routes/admin');

const PORT = parseInt(process.env.PORT || '3000', 10);
const UPLOAD_DIR = process.env.UPLOAD_DIR || path.resolve(__dirname, '..', 'uploads');
const AI_CACHE_DIR = process.env.AI_CACHE_DIR || path.resolve(__dirname, '..', 'cache', 'ai');
const DATA_DIR = process.env.DATA_DIR || path.resolve(__dirname, '..', 'data');

// Create storage directories at boot.
for (const dir of [UPLOAD_DIR, AI_CACHE_DIR, DATA_DIR]) {
  fs.mkdirSync(dir, { recursive: true });
}

const app = express();
app.use(express.json({ limit: '1mb' }));

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', time: new Date().toISOString() });
});

app.use('/api/templates', templatesRouter);
app.use('/api/ai', aiRouter);
app.use('/api/upload', uploadRouter);
app.use('/api/admin', adminAuth, adminRouter);

// Static file serving for uploaded media.
app.use('/uploads', express.static(UPLOAD_DIR));

app.listen(PORT, () => {
  console.log(`trend-lens server listening on port ${PORT}`);
});
