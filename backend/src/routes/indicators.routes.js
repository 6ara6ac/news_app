const express = require('express');
const router = express.Router();
const indicatorsService = require('../../services/indicators.service');

router.get('/', async (req, res) => {
  try {
    console.log('GET /indicators request received');
    const indicators = await indicatorsService.getIndicators();
    console.log('Found indicators in DB:', indicators);
    res.json(indicators);
  } catch (error) {
    console.error('Error in GET /indicators:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router; 