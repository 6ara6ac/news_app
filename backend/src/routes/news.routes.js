const express = require('express');
const router = express.Router();
const dbService = require('../../services/db.service');

router.get('/', async (req, res) => {
  try {
    const { category, page = 1, pageSize = 10, search } = req.query;
    console.log('News request received:', { category, page, pageSize, search });
    
    let result;
    if (search) {
      result = await dbService.searchArticles(search, {
        category,
        page: parseInt(page),
        pageSize: parseInt(pageSize)
      });
    } else {
      result = await dbService.getArticles({
        category,
        page: parseInt(page),
        pageSize: parseInt(pageSize)
      });
    }

    console.log('Sending response:', {
      articlesCount: result.articles.length,
      total: result.total,
      hasMore: result.hasMore
    });

    res.json({
      articles: result.articles,
      total: result.total,
      hasMore: result.hasMore
    });
  } catch (error) {
    console.error('News route error:', error);
    res.status(500).json({ 
      error: error.message,
      articles: [],
      total: 0,
      hasMore: false
    });
  }
});

module.exports = router; 