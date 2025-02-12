require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./src/config/db.config');
const authRoutes = require('./src/routes/auth.routes');
const newsRoutes = require('./src/routes/news.routes');
const axios = require('axios');
const newsService = require('./services/news.service');
const aiService = require('./services/ai.service');
const mongoose = require('mongoose');
const schedulerService = require('./services/scheduler.service');
const scraperService = require('./services/scraper.service');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3000;

// Подключение к MongoDB
connectDB().then(() => {
  console.log('MongoDB connected successfully');
  schedulerService.start();
}).catch((err) => {
  console.error('MongoDB connection error:', err);
  process.exit(1);
});

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/news', newsRoutes);

// Роуты для новостей
app.get('/api/news', async (req, res) => {
  try {
    const { page, category, country, language } = req.query;
    const articles = await newsService.getNews({
      category,
      country,
      page: parseInt(page),
      pageSize: 10
    });
    res.json({ articles });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/news/summarize', async (req, res) => {
  try {
    const { text } = req.body;
    const summary = await aiService.summarizeText(text);
    res.json({ summary });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Роут для AI чата
app.post('/api/chat', async (req, res) => {
  try {
    const { message } = req.body;
    const reply = await aiService.chatResponse(message);
    res.json({ reply });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Запускаем скрапинг при старте сервера
scraperService.startScraping();

// Добавляем раздачу статических файлов
app.use('/images', express.static(path.join(__dirname, 'public/images')));

// Создаем директорию для изображений при старте сервера
const imagesDir = path.join(__dirname, 'public/images');
if (!fs.existsSync(imagesDir)) {
  fs.mkdirSync(imagesDir, { recursive: true });
}

// Обработка завершения работы
async function gracefulShutdown() {
  console.log('Shutting down...');
  
  // Закрываем очередь
  if (scraperService.scrapeQueue) {
    await scraperService.scrapeQueue.close();
  }
  
  // Закрываем соединение с MongoDB
  await mongoose.connection.close();
  
  process.exit(0);
}

process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
}); 