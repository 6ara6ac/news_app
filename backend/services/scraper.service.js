const axios = require('axios');
const cheerio = require('cheerio');
const crypto = require('crypto');
const aiService = require('./ai.service');
const Article = require('../models/article.model');
const Queue = require('bull');

class ScraperService {
  constructor() {
    this.sources = [
      {
        name: 'Investing.com Crypto',
        url: 'https://ru.investing.com/crypto/news',
        category: 'crypto',
        selector: 'article.js-article-item',
        titleSelector: '.js-article-item-title',
        linkSelector: '.js-article-item-title',
        contentSelector: '.articlePage',
        language: 'ru',
        baseUrl: 'https://ru.investing.com'
      },
      {
        name: 'BitNovosti',
        url: 'https://bitnovosti.com',
        category: 'crypto',
        selector: 'article.post',
        titleSelector: 'h2.entry-title',
        linkSelector: 'h2.entry-title a',
        contentSelector: '.entry-content',
        language: 'ru'
      },
      {
        name: 'РБК Крипто',
        url: 'https://www.rbc.ru/crypto/',
        category: 'crypto',
        selector: '.item__wrap',
        titleSelector: '.item__title',
        linkSelector: '.item__link',
        contentSelector: '.article__text',
        language: 'ru'
      },
      {
        name: 'CoinSpot',
        url: 'https://coinspot.io',
        category: 'crypto',
        selector: '.article-card',
        titleSelector: '.article-card__title',
        linkSelector: '.article-card__link',
        contentSelector: '.article-content',
        language: 'ru'
      },
      {
        name: 'ProFinance',
        url: 'https://www.profinance.ru/news/crypto/',
        category: 'crypto',
        selector: '.news-item',
        titleSelector: '.news-title',
        linkSelector: '.news-title a',
        contentSelector: '.news-text',
        language: 'ru'
      },
      {
        name: 'BitsMedia',
        url: 'https://bits.media',
        category: 'crypto',
        selector: '.article-card',
        titleSelector: '.article-title',
        linkSelector: '.article-link',
        contentSelector: '.article-content',
        language: 'ru'
      }
    ];

    this.axiosInstance = axios.create({
      timeout: 15000,
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
        'Accept-Encoding': 'gzip, deflate, br'
      }
    });

    // Инициализация очередей
    this.scrapeQueue = new Queue('news-scraping', process.env.REDIS_URL || 'redis://127.0.0.1:6379', {
      defaultJobOptions: {
        removeOnComplete: true,
        removeOnFail: true,
        attempts: 3,
        backoff: {
          type: 'exponential',
          delay: 2000
        }
      }
    });

    this.setupQueue();

    this.scrapeQueue.on('error', (error) => {
      console.error('Redis queue error:', error);
    });

    this.scrapeQueue.on('failed', (job, error) => {
      console.error(`Job ${job.id} failed:`, error);
    });

    // Проверяем подключение к Redis при старте
    this.scrapeQueue.client.on('connect', () => {
      console.log('Connected to Redis successfully');
    });

    this.scrapeQueue.client.on('error', (error) => {
      console.error('Redis connection error:', error);
    });
  }

  setupQueue() {
    // Обработчик для регулярного скрапинга
    this.scrapeQueue.process('regular-scraping', async (job) => {
      console.log('Starting regular scraping cycle');
      for (const source of this.sources) {
        await this.scrapeSource(source);
      }
    });

    // Обработчик для отдельных источников
    this.scrapeQueue.process('scrape-source', async (job) => {
      const { source } = job.data;
      console.log(`Processing source: ${source.name}`);
      return await this.scrapeSource(source);
    });

    // Планирование регулярного скрапинга
    this.scrapeQueue.add('regular-scraping', {}, {
      repeat: {
        every: 5 * 60 * 1000 // 5 минут
      }
    });

    // Обработка событий
    this.scrapeQueue.on('completed', (job) => {
      console.log(`Job ${job.id} completed for ${job.name}`);
    });

    this.scrapeQueue.on('failed', (job, error) => {
      console.error(`Job ${job.id} failed for ${job.name}:`, error);
    });

    this.scrapeQueue.on('error', (error) => {
      console.error('Queue error:', error);
    });
  }

  async startScraping() {
    console.log('\n=== Starting news scraping ===');

    try {
      // Добавляем задачи для каждого источника в очередь
      const jobs = this.sources.map(source => 
        this.scrapeQueue.add('scrape-source', { source })
      );

      await Promise.all(jobs);
      console.log('All scraping jobs added to queue');
    } catch (error) {
      console.error('Error adding jobs to queue:', error);
    }
  }

  async scrapeSource(source) {
    console.log(`\nStarting to scrape ${source.name}...`);
    try {
      const response = await this.axiosInstance.get(source.url);
      const $ = cheerio.load(response.data);
      
      // Получаем все статьи и берем только первые 5
      const articles = $(source.selector).toArray().slice(0, 5);
      console.log(`Found ${articles.length} articles on ${source.name}`);

      // Обрабатываем статьи последовательно
      for (const article of articles) {
        try {
          const result = await this.processArticle($, article, source);
          if (result) {
            console.log(`Successfully processed article from ${source.name}`);
          }
        } catch (error) {
          console.error(`Error processing article from ${source.name}:`, error.message);
          continue; // Продолжаем со следующей статьей
        }
      }
    } catch (error) {
      console.error(`Failed to scrape ${source.name}:`, error.message);
    }
  }

  async processArticle($, element, source) {
    const $element = $(element);
    const title = $element.find(source.titleSelector).text().trim();
    let link = $element.find(source.linkSelector).attr('href');
    
    if (!title || !link) {
      console.log('Skipping: missing title or link');
      return null;
    }

    // Обработка относительных ссылок
    if (link.startsWith('/')) {
      link = source.baseUrl ? source.baseUrl + link : source.url + link;
    } else if (!link.startsWith('http')) {
      link = source.url + '/' + link;
    }

    console.log(`\nProcessing article: ${title}`);
    console.log(`Link: ${link}`);

    try {
      // Проверяем, существует ли статья
      const id = crypto.createHash('md5').update(title + link).digest('hex');
      const exists = await Article.findOne({ _id: id });
      
      if (exists) {
        console.log('Article already exists, skipping');
        return null;
      }

      // Получаем содержимое статьи
      console.log('Fetching article content...');
      const articleResponse = await this.axiosInstance.get(link);
      const article$ = cheerio.load(articleResponse.data);
      const content = article$(source.contentSelector).text().trim();

      if (!content || content.length < 100) {
        console.log('Insufficient content, skipping');
        return null;
      }

      // Генерируем саммари и изображение
      console.log('Generating summary and image...');
      const summary = await aiService.summarizeText(content, source.language);
      const imageUrl = await aiService.generateImageForNews(title, source.language);

      // Создаем и сохраняем статью
      const article = new Article({
        _id: id,
        title,
        content,
        summary,
        imageUrl,
        link,
        category: source.category,
        source: {
          name: source.name,
          url: source.url
        },
        language: source.language,
        publishedAt: new Date()
      });

      await article.save();
      console.log('Article saved successfully');
      return article;

    } catch (error) {
      console.error(`Error processing "${title}":`, error.message);
      return null;
    }
  }
}

module.exports = new ScraperService(); 