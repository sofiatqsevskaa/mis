const express = require('express');
const router = express.Router();
const eventsController = require('../controllers/eventsController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/upcoming', eventsController.getUpcomingEvents);
router.get('/calendar', eventsController.getCalendarEvents);
router.get('/admin', authMiddleware, eventsController.getAdminEvents);
router.post('/', authMiddleware, eventsController.createEvent);
router.put('/:eventId/status', authMiddleware, eventsController.updateEventStatus);
router.get('/:eventId/notes', authMiddleware, eventsController.getNotes);
router.post('/:eventId/notes', authMiddleware, eventsController.addNote);

module.exports = router;