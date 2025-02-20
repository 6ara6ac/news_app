const { OpenAI } = require('openai');
const { OPENAI_API_KEY } = process.env;
const axios = require('axios');
const fs = require('fs').promises;
const path = require('path');

class AIService {
  constructor() {
    this.openai = new OpenAI({
      apiKey: OPENAI_API_KEY
    });
    this.imageStoragePath = path.join(__dirname, '../public/images');
  }

  async summarizeText(text, isShort = true) {
    try {
      console.log(`Summarizing text (${isShort ? 'short' : 'full'})...`);
      console.log('Text length:', text.length);
      
      const systemPrompt = isShort
        ? "Создай краткое содержание финансовой новости в 2-3 предложения, максимум 150 символов. Сфокусируйся на ключевых фактах и цифрах. Ответ должен быть на русском языке."
        : "Создай подробное содержание финансовой новости, максимум 1200 символов. Включи основные факты, цифры и контекст. Сохрани важные детали. Ответ должен быть на русском языке.";

      const response = await this.openai.chat.completions.create({
        model: "gpt-3.5-turbo",
        messages: [
          {
            role: "system",
            content: systemPrompt
          },
          {
            role: "user",
            content: text
          }
        ],
        max_tokens: isShort ? 150 : 1200,
        temperature: 0.7
      });

      const summary = response.choices[0].message.content;
      return summary;
    } catch (error) {
      console.error('Error summarizing text:', error);
      return isShort ? text.substring(0, 150) + '...' : text.substring(0, 1200) + '...';
    }
  }

  async chatResponse(message) {
    try {
      const response = await this.openai.chat.completions.create({
        model: "gpt-3.5-turbo",
        messages: [
          {
            role: "system",
            content: "Ты - эксперт по трейдингу и финансовым рынкам. Отвечай на вопросы пользователя, давая полезные советы и рекомендации."
          },
          {
            role: "user",
            content: message
          }
        ],
        temperature: 0.7
      });

      return response.choices[0].message.content;
    } catch (error) {
      console.error('OpenAI Chat API error:', error);
      throw error;
    }
  }

  async generateImageForNews(text, language = 'ru') {
    try {
      const response = await this.openai.images.generate({
        model: "dall-e-3",
        prompt: text,
        n: 1,
        size: "1024x1024",
      });

      const imageUrl = response.data[0].url;
      
      // Скачиваем и сохраняем изображение
      const imageName = `news_${Date.now()}.png`;
      const localPath = path.join(this.imageStoragePath, imageName);
      
      const imageResponse = await axios.get(imageUrl, { responseType: 'arraybuffer' });
      await fs.writeFile(localPath, imageResponse.data);

      // Возвращаем локальный URL для сохранения в БД
      return `/images/${imageName}`;
    } catch (error) {
      console.error('Error generating image:', error);
      return 'https://via.placeholder.com/1024x1024?text=News';
    }
  }

  async testConnection() {
    try {
      const response = await this.openai.chat.completions.create({
        model: "gpt-4o",
        messages: [
          {
            role: "user",
            content: "Test connection"
          }
        ],
      });
      console.log('Connection successful');
      return true;
    } catch (error) {
      console.error('Connection test error:', error);
      return false;
    }
  }
}

module.exports = new AIService(); 