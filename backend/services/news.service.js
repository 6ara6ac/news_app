const axios = require('axios');
const cheerio = require('cheerio');
const { NEWS_API_KEY } = process.env;
const { OpenAI } = require('openai');
const cacheService = require('./cache.service');
const https = require('https');
const Article = require('../models/article.model');

class NewsService {
  constructor() {
    this.newsApiClient = axios.create({
      baseURL: 'https://newsapi.org/v2',
      headers: {
        'X-Api-Key': NEWS_API_KEY
      }
    });

    this.finamClient = axios.create({
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
        'Referer': 'https://www.finam.ru/'
      }
    });

    // Добавим прокси для обхода блокировок
    this.proxyClient = axios.create({
      proxy: {
        host: 'proxy.crawlera.com',
        port: 8010,
        auth: { username: 'your-api-key' }
      },
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
        'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache'
      }
    });

    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY
    });

    // Создаем новый axios instance с отключенной проверкой SSL
    this.parserClient = axios.create({
      httpsAgent: new https.Agent({  
        rejectUnauthorized: false
      }),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7'
      }
    });
  }

  async getNews({ category, page = 1, pageSize = 10 }) {
    try {
      const query = category ? { category } : {};
      
      const articles = await Article.find(query)
        .sort({ publishedAt: -1 })
        .skip((page - 1) * pageSize)
        .limit(pageSize)
        .lean(); // Используем lean() для получения простых объектов
      
      console.log('Retrieved articles:', articles.map(a => ({
        id: a._id,
        title: a.title,
        imageUrl: a.imageUrl // Проверим, что URL изображения передается
      })));

      return articles;
    } catch (error) {
      console.error('Error getting articles:', error);
      return [];
    }
  }

  async getSavedNews(userId) {
    return await Article.find({ savedBy: userId }).sort({ publishedAt: -1 });
  }

  async saveArticle(articleId, userId) {
    const article = await Article.findById(articleId);
    if (!article) throw new Error('Article not found');
    
    if (!article.savedBy.includes(userId)) {
      article.savedBy.push(userId);
      await article.save();
    }
    return article;
  }

  async unsaveArticle(articleId, userId) {
    const article = await Article.findById(articleId);
    if (!article) throw new Error('Article not found');
    
    article.savedBy = article.savedBy.filter(id => id !== userId);
    await article.save();
    return article;
  }

  async _getFinamNews(category, page, pageSize) {
    try {
      // Маппинг категорий на разделы Finam
      const categoryUrls = {
        'crypto': 'crypto',
        'forex': 'forex',
        'commodities': 'commodities',
        'default': 'market'
      };

      const section = categoryUrls[category] || categoryUrls.default;
      const url = `https://www.finam.ru/publications/section/${section}/`;
      
      const response = await this.finamClient.get(url);
      const $ = cheerio.load(response.data);
      
      const articles = [];
      
      // Обновленный селектор для новостей Finam
      $('.publication-list .publication-item').each((i, elem) => {
        if (articles.length >= pageSize) return false;
        
        const $elem = $(elem);
        const title = $elem.find('.publication-item__title').text().trim();
        const description = $elem.find('.publication-item__text').text().trim();
        const link = $elem.find('.publication-item__title-link').attr('href');
        const publishedAt = $elem.find('.publication-item__date').attr('datetime') || new Date().toISOString();
        const imageUrl = $elem.find('.publication-item__image img').attr('src') || '';

        if (title && link) {
          articles.push({
            id: this._generateId(link),
            title,
            description,
            content: description,
            imageUrl: imageUrl.startsWith('http') ? imageUrl : `https://www.finam.ru${imageUrl}`,
            link: link.startsWith('http') ? link : `https://www.finam.ru${link}`,
            publishedAt: new Date(publishedAt),
            category: this._detectCategory(title + ' ' + description),
            country: 'ru',
            source: {
              id: 'finam',
              name: 'Финам'
            }
          });
        }
      });

      // Если новостей нет, пробуем получить из альтернативного раздела
      if (articles.length === 0) {
        const alternativeUrl = 'https://www.finam.ru/analysis/newsitem/';
        const altResponse = await this.finamClient.get(alternativeUrl);
        const $alt = cheerio.load(altResponse.data);
        
        $alt('.news-list .news-item').each((i, elem) => {
          if (articles.length >= pageSize) return false;
          
          const $elem = $(elem);
          const title = $elem.find('.news-title').text().trim();
          const description = $elem.find('.news-description').text().trim();
          const link = $elem.find('a').attr('href');
          const publishedAt = $elem.find('.news-date').attr('datetime') || new Date().toISOString();
          
          if (title && link) {
            articles.push({
              id: this._generateId(link),
              title,
              description,
              content: description,
              imageUrl: '',
              link: link.startsWith('http') ? link : `https://www.finam.ru${link}`,
              publishedAt: new Date(publishedAt),
              category: this._detectCategory(title + ' ' + description),
              country: 'ru',
              source: {
                id: 'finam',
                name: 'Финам'
              }
            });
          }
        });
      }

      // Пагинация
      const startIndex = (page - 1) * pageSize;
      return articles.slice(startIndex, startIndex + pageSize);
    } catch (error) {
      console.error('Finam parsing error:', error);
      // В случае ошибки возвращаем пустой массив
      return [];
    }
  }

  async _getRBCNews(category) {
    try {
      const url = this._getRBCUrl(category);
      console.log('Requesting RBC URL:', url);
      
      const response = await this.parserClient.get(url);
      const $ = cheerio.load(response.data);
      
      const articles = [];

      console.log('Parsing news items...');

      // Обновленные селекторы для RBC
      $('.news-feed__item').each((i, elem) => {
        try {
          if (articles.length >= pageSize) return false;

          const $elem = $(elem);
          const title = $elem.find('span[class*="news-feed__item__title"]').text().trim();
          const link = $elem.find('a[class*="news-feed__item"]').attr('href');

          console.log('Found article:', { title, link });

          if (title && link) {
            articles.push({
              id: this._generateId(link),
              title,
              description: title,
              content: title,
              imageUrl: '',
              link,
              publishedAt: new Date(),
              category: this._detectCategory(title),
              country: 'ru',
              source: {
                id: 'rbc',
                name: 'РБК'
              }
            });
          }
        } catch (err) {
          console.error('Error parsing news item:', err);
        }
      });

      console.log(`Found ${articles.length} articles on RBC`);
      return articles;
    } catch (error) {
      console.error('RBC parsing error:', error);
      throw error;
    }
  }

  async _getInvestingNews(category, page, pageSize) {
    try {
      const categoryUrls = {
        'crypto': 'cryptocurrency',
        'forex': 'forex',
        'commodities': 'commodities',
        'default': 'economy'
      };

      const section = categoryUrls[category] || categoryUrls.default;
      const url = `https://ru.investing.com/news/${section}`;
      
      const response = await this.finamClient.get(url);
      const $ = cheerio.load(response.data);
      
      const articles = [];
      
      $('.articleItem').each((i, elem) => {
        if (articles.length >= pageSize) return false;
        
        const $elem = $(elem);
        const title = $elem.find('.title').text().trim();
        const description = $elem.find('.description').text().trim();
        const link = $elem.find('.title a').attr('href');
        const publishedAt = $elem.find('.date').attr('data-timestamp') || new Date().toISOString();
        const imageUrl = $elem.find('.img img').attr('data-src') || '';

        if (title && link) {
          articles.push({
            id: this._generateId(link),
            title,
            description,
            content: description,
            imageUrl,
            link: link.startsWith('http') ? link : `https://ru.investing.com${link}`,
            publishedAt: new Date(parseInt(publishedAt) * 1000),
            category: this._detectCategory(title + ' ' + description),
            country: 'ru',
            source: {
              id: 'investing',
              name: 'Investing.com'
            }
          });
        }
      });

      return articles;
    } catch (error) {
      console.error('Investing.com parsing error:', error);
      return [];
    }
  }

  async _getVedomostiNews(category, page, pageSize) {
    try {
      const url = 'https://www.vedomosti.ru/finance';
      const response = await this.finamClient.get(url);
      const $ = cheerio.load(response.data);
      const articles = [];

      $('.article-preview').each((i, elem) => {
        if (articles.length >= pageSize) return false;
        
        const $elem = $(elem);
        const title = $elem.find('.article-preview__title').text().trim();
        const description = $elem.find('.article-preview__text').text().trim();
        const link = $elem.find('a').attr('href');
        const imageUrl = $elem.find('img').attr('src') || '';

        if (title && link) {
          articles.push({
            id: this._generateId(link),
            title,
            description,
            content: description,
            imageUrl,
            link: `https://www.vedomosti.ru${link}`,
            publishedAt: new Date(),
            category: this._detectCategory(title + ' ' + description),
            country: 'ru',
            source: { id: 'vedomosti', name: 'Ведомости' }
          });
        }
      });
      return articles;
    } catch (error) {
      console.error('Vedomosti parsing error:', error);
      return [];
    }
  }

  async _getKommersantNews(category, page, pageSize) {
    try {
      const url = 'https://www.kommersant.ru/finance';
      const response = await this.finamClient.get(url);
      const $ = cheerio.load(response.data);
      const articles = [];

      $('.article_name').each((i, elem) => {
        if (articles.length >= pageSize) return false;
        
        const $elem = $(elem);
        const title = $elem.find('a').text().trim();
        const link = $elem.find('a').attr('href');
        const description = $elem.next('.article_text').text().trim();
        const imageUrl = $elem.closest('.article_block').find('img').attr('src') || '';

        if (title && link) {
          articles.push({
            id: this._generateId(link),
            title,
            description,
            content: description,
            imageUrl: imageUrl.startsWith('http') ? imageUrl : `https://www.kommersant.ru${imageUrl}`,
            link: link.startsWith('http') ? link : `https://www.kommersant.ru${link}`,
            publishedAt: new Date(),
            category: this._detectCategory(title + ' ' + description),
            country: 'ru',
            source: { id: 'kommersant', name: 'Коммерсантъ' }
          });
        }
      });
      return articles;
    } catch (error) {
      console.error('Kommersant parsing error:', error);
      return [];
    }
  }

  async _getBankiRuNews(category, page, pageSize) {
    try {
      const url = 'https://www.banki.ru/news/';
      const response = await this.finamClient.get(url);
      const $ = cheerio.load(response.data);
      const articles = [];

      $('.NewsItemWrapper').each((i, elem) => {
        if (articles.length >= pageSize) return false;
        
        const $elem = $(elem);
        const title = $elem.find('.NewsItemTitle').text().trim();
        const description = $elem.find('.NewsItemLead').text().trim();
        const link = $elem.find('a').attr('href');
        const publishedAt = $elem.find('.NewsItemDate').attr('datetime') || new Date().toISOString();
        const imageUrl = $elem.find('.NewsItemImage img').attr('src') || '';

        if (title && link) {
          articles.push({
            id: this._generateId(link),
            title,
            description,
            content: description,
            imageUrl,
            link: link.startsWith('http') ? link : `https://www.banki.ru${link}`,
            publishedAt: new Date(publishedAt),
            category: this._detectCategory(title + ' ' + description),
            country: 'ru',
            source: { id: 'banki', name: 'Банки.ру' }
          });
        }
      });
      return articles;
    } catch (error) {
      console.error('Banki.ru parsing error:', error);
      return [];
    }
  }

  async _getForbesNews(category, page, pageSize) {
    try {
      const url = 'https://www.forbes.ru/finansy';
      const response = await this.finamClient.get(url);
      const $ = cheerio.load(response.data);
      const articles = [];

      $('.article-preview').each((i, elem) => {
        if (articles.length >= pageSize) return false;
        
        const $elem = $(elem);
        const title = $elem.find('.article-preview__title').text().trim();
        const description = $elem.find('.article-preview__description').text().trim();
        const link = $elem.find('a').attr('href');
        const imageUrl = $elem.find('img').attr('src') || '';

        if (title && link) {
          articles.push({
            id: this._generateId(link),
            title,
            description,
            content: description,
            imageUrl,
            link: link.startsWith('http') ? link : `https://www.forbes.ru${link}`,
            publishedAt: new Date(),
            category: this._detectCategory(title + ' ' + description),
            country: 'ru',
            source: { id: 'forbes', name: 'Forbes Russia' }
          });
        }
      });
      return articles;
    } catch (error) {
      console.error('Forbes parsing error:', error);
      return [];
    }
  }

  async _getBcsExpressNews(category, page, pageSize) {
    try {
      const url = 'https://bcs-express.ru/novosti-i-analitika';
      // ... логика парсинга
      return [];
    } catch (error) {
      console.error('BCS Express parsing error:', error);
      return [];
    }
  }

  async _getTinkoffNews(category, page, pageSize) {
    try {
      const url = 'https://journal.tinkoff.ru/flows/news/';
      // ... логика парсинга
      return [];
    } catch (error) {
      console.error('Tinkoff Journal parsing error:', error);
      return [];
    }
  }

  async _getPrimeNews(category, page, pageSize) {
    try {
      const url = 'https://1prime.ru/Financial_market/';
      // ... логика парсинга
      return [];
    } catch (error) {
      console.error('Prime parsing error:', error);
      return [];
    }
  }

  async _getInterfaxNews(category, page, pageSize) {
    try {
      const url = 'https://www.interfax.ru/business/';
      // ... логика парсинга
      return [];
    } catch (error) {
      console.error('Interfax parsing error:', error);
      return [];
    }
  }

  async _getTassNews(category) {
    try {
      const url = this._getTassUrl(category);
      console.log('Requesting TASS URL:', url);
      
      const response = await this.parserClient.get(url);
      const $ = cheerio.load(response.data);
      
      const articles = [];

      // Обновленные селекторы для TASS
      $('.news-list__item').each((i, elem) => {
        try {
          if (articles.length >= pageSize) return false;

          const $elem = $(elem);
          const title = $elem.find('.news-list__title').text().trim();
          const link = $elem.find('a').attr('href');

          console.log('Found article:', { title, link });

          if (title && link) {
            articles.push({
              id: this._generateId(link),
              title,
              description: title,
              content: title,
              imageUrl: '',
              link: `https://tass.ru${link}`,
              publishedAt: new Date(),
              category: this._detectCategory(title),
              country: 'ru',
              source: {
                id: 'tass',
                name: 'ТАСС'
              }
            });
          }
        } catch (err) {
          console.error('Error parsing news item:', err);
        }
      });

      console.log(`Found ${articles.length} articles on TASS`);
      return articles;
    } catch (error) {
      console.error('TASS parsing error:', error.message);
      throw error;
    }
  }

  _buildQuery(category) {
    const queries = {
      'crypto': 'cryptocurrency OR bitcoin OR ethereum',
      'forex': 'forex OR currency trading OR exchange rate',
      'commodities': 'commodities OR gold OR oil price',
      'default': 'financial markets OR trading OR investment'
    };
    return queries[category] || queries.default;
  }

  async _generateImageForNews(title, description) {
    try {
      const cacheKey = this._generateId(title + description);
      const cachedImage = await cacheService.getImage(cacheKey);
      
      if (cachedImage) {
        return cachedImage;
      }

      const imageUrl = await this._generateImage(title, description);
      if (imageUrl) {
        await cacheService.setImage(cacheKey, imageUrl);
      }
      
      return imageUrl;
    } catch (error) {
      console.error('Image handling error:', error);
      return '';
    }
  }

  async _generateImage(title, description) {
    try {
      // Очищаем текст от потенциально опасных слов
      const safeTitle = this._sanitizeText(title);
      const safeDescription = this._sanitizeText(description);
      
      const prompt = `Create a business news thumbnail about: ${safeTitle}. Style: modern, professional, financial news`;
      
      // Добавляем задержку между запросами
      await new Promise(resolve => setTimeout(resolve, 1000));

      const response = await this.openai.images.generate({
        prompt,
        n: 1,
        size: "1024x1024",
        quality: "standard",
        style: "natural"
      });

      return response.data[0].url;
    } catch (error) {
      console.error('Image generation error:', error);
      // Возвращаем дефолтное изображение при ошибке
      return 'https://via.placeholder.com/1024x1024?text=News';
    }
  }

  _sanitizeText(text) {
    // Удаляем потенциально проблемные слова и символы
    return text
      .replace(/[^\w\s]/gi, '')
      .replace(/\b(gambling|betting|casino|trump|coin|crypto|meme)\b/gi, 'business')
      .slice(0, 100);
  }

  async _formatArticles(articles) {
    const formattedArticles = [];
    
    for (const article of articles) {
      let imageUrl = article.urlToImage || '';
      
      // Генерируем изображение только если его нет
      if (!imageUrl) {
        imageUrl = await this._generateImageForNews(article.title, article.description);
        console.log('Generated image for article:', article.title, imageUrl);
      }

      formattedArticles.push({
        id: this._generateId(article.url),
        title: article.title,
        description: article.description,
        content: article.content,
        imageUrl,
        link: article.url,
        publishedAt: new Date(article.publishedAt),
        category: this._detectCategory(article.title + ' ' + article.description),
        country: this._detectCountry(article.source.name),
        source: article.source
      });
    }

    return formattedArticles;
  }

  _generateId(url) {
    return Buffer.from(url).toString('base64').slice(0, 24);
  }

  _detectCategory(text) {
    const lowerText = text.toLowerCase();
    if (lowerText.includes('крипто') || lowerText.includes('биткоин')) return 'crypto';
    if (lowerText.includes('форекс') || lowerText.includes('валют')) return 'forex';
    if (lowerText.includes('сырье') || lowerText.includes('золото')) return 'commodities';
    return 'general';
  }

  _detectCountry(source) {
    const sourceMap = {
      'finam': 'ru',
      'reuters': 'us',
      'bloomberg': 'us',
      'bbc': 'gb'
    };
    return sourceMap[source.toLowerCase()] || 'us';
  }

  async scrapeArticle(url) {
    try {
      const response = await axios.get(url);
      const $ = cheerio.load(response.data);
      
      // Базовая логика извлечения текста статьи
      const articleText = $('article, [class*="article"], [class*="content"]')
        .find('p')
        .map((_, el) => $(el).text())
        .get()
        .join('\n');

      return articleText;
    } catch (error) {
      console.error('Scraping error:', error);
      return null;
    }
  }

  _getRBCUrl(category) {
    const categoryUrls = {
      'crypto': 'https://quote.rbc.ru/crypto/',
      'forex': 'https://quote.rbc.ru/forex/',
      'commodities': 'https://quote.rbc.ru/commodities/',
      'default': 'https://quote.rbc.ru/'
    };
    return categoryUrls[category] || categoryUrls.default;
  }

  _getTassUrl(category) {
    const categoryUrls = {
      'crypto': 'https://tass.ru/crypto',
      'forex': 'https://tass.ru/ekonomika/finansy',
      'commodities': 'https://tass.ru/ekonomika/rynki',
      'default': 'https://tass.ru/ekonomika'
    };
    return categoryUrls[category] || categoryUrls.default;
  }

  async summarizeArticle(text) {
    try {
      if (!text || text.length < 100) {
        return text;
      }

      // Добавляем задержку между запросами
      await new Promise(resolve => setTimeout(resolve, 500));

      const response = await this.openai.chat.completions.create({
        model: "gpt-3.5-turbo",
        messages: [
          {
            role: "system",
            content: "You are a professional news summarizer. Create short, informative summaries in the same language as the input text."
          },
          {
            role: "user",
            content: `Summarize this news article in 2-3 sentences: ${text}`
          }
        ],
        temperature: 0.7,
        max_tokens: 150
      });

      const summary = response.choices[0].message.content.trim();
      console.log('Generated summary:', summary);
      return summary;
    } catch (error) {
      console.error('Summarization error:', error);
      return text;
    }
  }
}

module.exports = new NewsService(); 