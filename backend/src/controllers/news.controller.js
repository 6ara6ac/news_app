const newsService = require('../services/news.service');

class NewsController {
    async getNews(req, res) {
        try {
            const { language = 'ru' } = req.query;
            const news = await newsService.fetchNews(language);
            res.json(news);
        } catch (error) {
            console.error('Error in getNews:', error);
            res.status(500).json({ error: 'Failed to fetch news' });
        }
    }

    async searchNews(req, res) {
        try {
            const { query, language = 'ru' } = req.query;
            if (!query) {
                return res.status(400).json({ error: 'Query parameter is required' });
            }
            const news = await newsService.searchNews(query, language);
            res.json(news);
        } catch (error) {
            console.error('Error in searchNews:', error);
            res.status(500).json({ error: 'Failed to search news' });
        }
    }

    async summarizeArticle(req, res) {
        try {
            const { text, language = 'ru' } = req.body;
            if (!text) {
                return res.status(400).json({ error: 'Text is required' });
            }
            const summary = await newsService.summarizeText(text, language);
            res.json({ summary });
        } catch (error) {
            console.error('Error in summarizeArticle:', error);
            res.status(500).json({ error: 'Failed to summarize article' });
        }
    }
}

module.exports = new NewsController(); 