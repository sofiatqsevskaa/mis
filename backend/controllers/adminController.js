const pool = require('../db');

exports.getUsers = async (req, res) => {
  try {
    const result = await pool.query(`SELECT id, name, email, role FROM users ORDER BY id ASC`);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
};

exports.updateUserRole = async (req, res) => {
  const { userId } = req.params;
  const { role } = req.body;

  try {
    await pool.query(`UPDATE users SET role=$1 WHERE id=$2`, [role, userId]);
    res.json({ message: 'User role updated' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update user role' });
  }
};

exports.getWhitelist = async (req, res) => {
  try {
    const result = await pool.query(`SELECT * FROM whitelisted_emails ORDER BY id ASC`);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch whitelist' });
  }
};

exports.addToWhitelist = async (req, res) => {
  const { email } = req.body;
  const added_by = req.user.id;
  console.log("adding user to whitelist")
  try {
    const result = await pool.query(
      `INSERT INTO whitelisted_emails (email, added_by) VALUES ($1,$2) RETURNING *`,
      [email, added_by]
    );
    await pool.query(`UPDATE users SET role='approved' WHERE email = $1`, [email])
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to add to whitelist' });
  }
};

exports.removeFromWhitelist = async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query(`DELETE FROM whitelisted_emails WHERE id=$1`, [id]);
    res.json({ message: 'Removed from whitelist' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to remove from whitelist' });
  }
};