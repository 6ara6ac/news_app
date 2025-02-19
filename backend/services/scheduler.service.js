const newsService = require('./news.service');
const dbService = require('./db.service');
const indicatorsService = require('./indicators.service');

class SchedulerService {
  constructor() {
    this.interval = 10 * 60 * 1000; // 10 минут
    this.categories = ['crypto', 'forex', 'commodities', 'general'];
    this.countries = ['Соединенные Штаты', 'Китай', 'Зона евро', 'Германия'];
    
    // Добавляем обновление индикаторов раз в неделю
    setInterval(() => {
      this.updateIndicators();
    }, 7 * 24 * 60 * 60 * 1000); // 7 дней
  }

  start() {
    this.updateNews();
    setInterval(() => this.updateNews(), this.interval);
  }

  async updateNews() {
    console.log('Starting news update...');
    
    try {
      for (const country of this.countries) {
        for (const category of this.categories) {
          try {
            console.log(`Fetching news for ${country}/${category}`);
            
            const articles = await newsService.getNews({
              category,
              country,
              page: 1,
              pageSize: 50
            });

            if (articles.length > 0) {
              console.log(`Got ${articles.length} articles for ${country}/${category}`);
              
              for (const article of articles) {
                try {
                  console.log(`Processing article: ${article.title}`);

                  if (!article.imageUrl) {
                    console.log('Generating image...');
                    article.imageUrl = await newsService._generateImageForNews(
                      article.title,
                      article.description
                    );
                  }

                  if (!article.summary) {
                    console.log('Generating summary...');
                    article.summary = await newsService.summarizeArticle(
                      article.content || article.description
                    );
                    console.log('Generated summary:', article.summary);
                  }

                  const savedArticle = await dbService.saveArticle(article);
                  console.log(`Saved article: ${savedArticle.title}`);
                } catch (articleError) {
                  console.error('Error processing article:', articleError);
                  continue;
                }
              }
            }
          } catch (categoryError) {
            console.error(`Error fetching ${country}/${category}:`, categoryError);
            continue;
          }
        }
      }
      
      console.log('News update completed successfully');
    } catch (error) {
      console.error('News update failed:', error);
    }
  }

  async updateIndicators() {
    try {
      await indicatorsService.updateIndicators();
    } catch (error) {
      console.error('Failed to update indicators:', error);
    }
  }
}

module.exports = new SchedulerService(); 