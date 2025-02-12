const Parser = require('rss-parser');
const parser = new Parser();

class RssService {
  async getNews(category) {
    try {
      const feeds = [
        'https://www.finanz.ru/rss/news',
        'https://www.interfax.ru/rss.asp',
        'https://quote.rbc.ru/rss'
      ];

      const allNews = await Promise.all(
        feeds.map(feed => this.getFeedItems(feed))
      );

      return allNews
        .flat()
        .filter(item => this.matchesCategory(item, category))
        .sort((a, b) => b.publishedAt - a.publishedAt);
    } catch (error) {
      console.error('RSS fetch error:', error);
      return [];
    }
  }

  async getFeedItems(feedUrl) {
    try {
      const feed = await parser.parseURL(feedUrl);
      return feed.items.map(item => ({
        id: item.guid,
        title: item.title,
        description: item.contentSnippet || item.title,
        content: item.content || item.contentSnippet || item.title,
        link: item.link,
        publishedAt: new Date(item.pubDate),
        imageUrl: this.extractImage(item),
        source: {
          id: new URL(feedUrl).hostname,
          name: feed.title
        }
      }));
    } catch (error) {
      console.error(`Error fetching RSS feed ${feedUrl}:`, error);
      return [];
    }
  }

  matchesCategory(item, category) {
    if (!category) return true;
    
    const text = `${item.title} ${item.description}`.toLowerCase();
    const keywords = {
      crypto: ['крипто', 'биткоин', 'ethereum', 'блокчейн'],
      forex: ['форекс', 'валют', 'курс', 'доллар', 'евро'],
      commodities: ['нефть', 'золото', 'газ', 'металл', 'сырье']
    };

    return keywords[category]?.some(keyword => text.includes(keyword)) ?? true;
  }

  extractImage(item) {
    // Пытаемся извлечь URL изображения из различных форматов RSS
    return item.enclosure?.url || 
           item['media:content']?.$.url ||
           item['media:thumbnail']?.$.url || '';
  }
}

module.exports = new RssService(); 