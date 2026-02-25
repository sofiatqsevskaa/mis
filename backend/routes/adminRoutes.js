const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/users', authMiddleware, adminController.getUsers);
router.put('/users/:userId/role', authMiddleware, adminController.updateUserRole);
router.get('/whitelist', authMiddleware, adminController.getWhitelist);
router.post('/whitelist', authMiddleware, adminController.addToWhitelist);
router.delete('/whitelist/:id', authMiddleware, adminController.removeFromWhitelist);

module.exports = router;