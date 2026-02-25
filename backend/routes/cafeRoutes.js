const express = require('express');
const router = express.Router();
const cafeController = require('../controllers/cafeController');

router.get('/', cafeController.getCafeInfo);

module.exports = router;