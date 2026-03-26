const pool = require('../db');

exports.getUpcomingEvents = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT * FROM events 
       WHERE event_date >= NOW() 
         AND visibility='public' 
         AND status='approved' 
       ORDER BY event_date ASC`
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch upcoming events' });
  }
};

exports.getCalendarEvents = async (req, res) => {
  const { month, year } = req.query;
  try {
    const result = await pool.query(
      `SELECT * FROM events
       WHERE EXTRACT(MONTH FROM event_date)=$1
         AND EXTRACT(YEAR FROM event_date)=$2
         AND visibility='public'
         AND status='approved'
       ORDER BY event_date ASC`,
      [month, year]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch calendar events' });
  }
};

exports.getAdminEvents = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT * FROM events ORDER BY event_date DESC`
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch admin events' });
  }
};

exports.createEvent = async (req, res) => {
  const { title, description, event_date, start_time, end_time, visibility } = req.body;
  const created_by = req.user.id;

  try {
    const result = await pool.query(
      `INSERT INTO events (title, description, event_date, start_time, end_time, visibility, created_by)
       VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *`,
      [title, description, event_date, start_time, end_time, visibility, created_by]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create event' });
  }
};

exports.updateEventStatus = async (req, res) => {
  const { eventId } = req.params;
  const { status } = req.body;
  const approved_by = req.user.id;

  try {
    await pool.query(
      `UPDATE events SET status=$1, approved_by=$2 WHERE id=$3`,
      [status, approved_by, eventId]
    );
    res.json({ message: 'Event status updated' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update event status' });
  }
};

exports.getNotes = async (req, res) => {
  const { eventId } = req.params;
  try {
    const result = await pool.query(
      `SELECT * FROM event_notes WHERE event_id=$1 ORDER BY created_at ASC`,
      [eventId]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch notes' });
  }
};

exports.addNote = async (req, res) => {
  const { eventId } = req.params;
  const { note } = req.body;
  const author_id = req.user.id;

  try {
    const result = await pool.query(
      `INSERT INTO event_notes (event_id, author_id, note) VALUES ($1, $2, $3) RETURNING *`,
      [eventId, author_id, note]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to add note' });
  }
};