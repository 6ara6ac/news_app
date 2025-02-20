const Article = require('../models/article.model');
const crypto = require('crypto');

class DBService {
  async saveArticle(article) {
    try {
      if (!article || !article.title) {
        console.error('Invalid article:', article);
        return null;
      }

      // Генерируем уникальный ID на основе заголовка и даты
      const id = crypto
        .createHash('md5')
        .update(article.title + article.publishedAt)
        .digest('hex');

      const existingArticle = await Article.findOne({ 
        $or: [
          { _id: id },
          { title: article.title }
        ]
      });

      if (existingArticle) {
        console.log('Updating existing article:', article.title);
        return await Article.findOneAndUpdate(
          { _id: existingArticle._id },
          { 
            ...article,
            updatedAt: new Date()
          },
          { new: true }
        );
      }

      console.log('Creating new article:', article.title);
      return await Article.create({
        _id: id,
        ...article,
        createdAt: new Date(),
        updatedAt: new Date()
      });
    } catch (error) {
      console.error('Error saving article:', error);
      throw error;
    }
  }

  async getArticles({ query = {}, page = 1, pageSize = 20 }) {
    try {
      console.log('Getting articles with params:', { query, page, pageSize });

      const total = await Article.countDocuments(query);
      console.log('Total articles found:', total);

      // Добавляем distinct по _id для уникальности
      const articles = await Article.find(query)
        .sort({ publishedAt: -1 })
        .skip((page - 1) * pageSize)
        .limit(pageSize)
        .distinct('_id')
        .lean();
      
      // Получаем полные документы по уникальным id
      const uniqueArticles = await Article.find({
        _id: { $in: articles }
      }).sort({ publishedAt: -1 }).lean();
        
      console.log('Retrieved unique articles count:', uniqueArticles.length);

      return {
        articles: uniqueArticles.map(article => ({
          ...article,
          id: article._id
        })),
        total,
        hasMore: total > page * pageSize
      };
    } catch (error) {
      console.error('Error getting articles:', error);
      return { articles: [], total: 0, hasMore: false };
    }
  }

  async searchArticles(searchText, { category, page = 1, pageSize = 10 }) {
    try {
      const query = {
        $text: { $search: searchText }
      };
      if (category) {
        query.category = category;
      }

      return await Article.find(query)
        .sort({ publishedAt: -1 })
        .skip((page - 1) * pageSize)
        .limit(pageSize);
    } catch (error) {
      console.error('Error searching articles:', error);
      throw error;
    }
  }
}

module.exports = new DBService(); 