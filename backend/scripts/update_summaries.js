require('dotenv').config();
const mongoose = require('mongoose');
const Article = require('../models/article.model');
const aiService = require('../services/ai.service');

async function updateSummaries() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    const articles = await Article.find({});
    console.log(`Found ${articles.length} articles to update`);

    for (const article of articles) {
      try {
        console.log(`\nUpdating summaries for article: ${article.title}`);
        
        // Проверяем подключение к OpenAI
        const isConnected = await aiService.testConnection();
        if (!isConnected) {
          console.error('OpenAI connection failed, skipping article');
          continue;
        }

        // Генерируем оба саммари из контента статьи
        const shortSummary = await aiService.summarizeText(article.content, true);
        console.log('Short summary generated');
        
        // Добавляем небольшую задержку между запросами
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        const fullSummary = await aiService.summarizeText(article.content, false);
        console.log('Full summary generated');

        // Обновляем документ в БД
        await Article.findByIdAndUpdate(article._id, {
          shortSummary: shortSummary,
          summary: fullSummary
        });

        console.log('Article updated successfully');
        
        // Задержка перед следующей статьей
        await new Promise(resolve => setTimeout(resolve, 2000));
      } catch (error) {
        console.error(`Error updating article ${article._id}:`, error);
        continue;
      }
    }

    console.log('\nAll articles updated');
    process.exit(0);
  } catch (error) {
    console.error('Script error:', error);
    process.exit(1);
  }
}

updateSummaries(); 