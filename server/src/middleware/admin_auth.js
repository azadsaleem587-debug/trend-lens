module.exports = function adminAuth(req, res, next) {
  const provided = req.headers['x-admin-key'];
  if (!process.env.ADMIN_KEY || provided !== process.env.ADMIN_KEY) {
    return res.status(401).json({ error: 'unauthorized' });
  }
  next();
};
