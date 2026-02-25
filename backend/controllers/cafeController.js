const pool = require('../db');

exports.getCafeInfo = async (req, res) => {
  try {
    const result = await pool.query(`SELECT key, value FROM cafe_info`);
    const info = {};
    result.rows.forEach(row => info[row.key] = row.value);
    res.json(info);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch cafe info' });
  }
};