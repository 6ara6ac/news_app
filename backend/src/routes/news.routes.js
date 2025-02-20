const express = require('express');
const router = express.Router();
const dbService = require('../../services/db.service');

router.get('/', async (req, res) => {
  try {
    const { category, page = 1, pageSize = 20, search, searchFields, exact } = req.query;
    console.log('News request received:', { category, page, pageSize, search });
    
    const query = {};
    
    if (category && category !== 'all') {
      query.category = category.toLowerCase();
    }
    
    if (search) {
      if (exact) {
        // Для точного поиска используем $regex с учетом регистра
        const searchRegex = new RegExp(search, 'i');
        query.$or = searchFields.map(field => ({
          [field]: searchRegex
        }));
      } else {
        // Для обычного поиска используем text search
        query.$text = { $search: search };
      }
    }
    
    const result = await dbService.getArticles({
      query,
      page: parseInt(page),
      pageSize: parseInt(pageSize)
    });

    console.log('Sending response:', {
      articlesCount: result.articles.length,
      total: result.total,
      hasMore: result.hasMore
    });

    res.json(result);
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