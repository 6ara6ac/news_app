const axios = require('axios');
const OpenAI = require('openai');

const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
});

class NewsService {
    async fetchNews(language = 'ru') {
        try {
            const response = await axios.get('https://newsapi.org/v2/top-headlines', {
                params: {
                    country: language === 'ru' ? 'ru' : 'us',
                    language: language,
                    apiKey: process.env.NEWS_API_KEY,
                },
            });

            if (response.data.status === 'ok') {
                const articles = response.data.articles.map(article => ({
                    title: article.title,
                    link: article.url,
                    summary: article.description || '',
                    content: article.content || article.description || '',
                    urlToImage: article.urlToImage,
                }));
                return articles;
            }
            
            throw new Error('Failed to fetch news');
        } catch (error) {
            console.error('Error fetching news:', error);
            throw error;
        }
    }

    async searchNews(query, language = 'ru') {
        try {
            const response = await axios.get('https://newsapi.org/v2/everything', {
                params: {
                    q: query,
                    language: language,
                    apiKey: process.env.NEWS_API_KEY,
                },
            });

            if (response.data.status === 'ok') {
                const articles = response.data.articles.map(article => ({
                    title: article.title,
                    link: article.url,
                    summary: article.description || '',
                    content: article.content || article.description || '',
                    urlToImage: article.urlToImage,
                }));
                return articles;
            }
            
            throw new Error('Failed to search news');
        } catch (error) {
            console.error('Error searching news:', error);
            throw error;
        }
    }

    async summarizeText(text, language = 'ru') {
        try {
            if (!process.env.OPENAI_API_KEY) {
                console.warn('OpenAI API key not found, returning original text');
                return text;
            }

            console.log('Отправка текста в GPT для суммаризации:', {
                textLength: text.length,
                language,
                firstWords: text.substring(0, 50) + '...'
            });

            const response = await openai.chat.completions.create({
                model: "gpt-3.5-turbo",
                messages: [
                    {
                        role: "system",
                        content: language === 'ru' 
                            ? "Ты - эксперт по суммаризации новостей. Твоя задача - создавать краткие, информативные саммари новостных статей на русском языке. Саммари должно быть длиной 2-3 предложения и содержать только ключевые факты."
                            : "You are a news summarization expert. Your task is to create concise, informative summaries of news articles in English. The summary should be 2-3 sentences long and contain only key facts."
                    },
                    {
                        role: "user",
                        content: language === 'ru'
                            ? `Создай краткое содержание этой новости на русском языке: ${text}`
                            : `Create a brief summary of this news article in English: ${text}`
                    }
                ],
                max_tokens: 150,
                temperature: 0.7
            });

            const summary = response.choices[0].message.content.trim();
            console.log('Получен ответ от GPT:', {
                originalLength: text.length,
                summaryLength: summary.length,
                summary: summary
            });

            if (summary === text) {
                console.warn('GPT вернул оригинальный текст без изменений');
            }

            return summary;
        } catch (error) {
            console.error('Error summarizing text:', error);
            if (error.response) {
                console.error('OpenAI API error:', {
                    status: error.response.status,
                    data: error.response.data
                });
            }
            return text;
        }
    }
}

module.exports = new NewsService(); 