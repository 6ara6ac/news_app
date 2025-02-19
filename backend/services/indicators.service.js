const axios = require('axios');
const cheerio = require('cheerio');
const Indicator = require('../models/indicator.model');

class IndicatorsService {
  async updateIndicators() {
    try {
      console.log('Starting indicators update...');
      const response = await axios.get('https://ru.tradingeconomics.com/matrix', {
        headers: {
          'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        }
      });

      console.log('Got response from tradingeconomics');
      const $ = cheerio.load(response.data);
      
      const indicators = [];
      let count = 0;
      
      // Берем только первые 20 строк
      $('#matrix tbody tr').each((i, row) => {
        if (count >= 20) return false; // Прерываем цикл после 20 строк
        
        const $row = $(row);
        const country = $row.find('td:first-child a.matrix-country').text().trim();
        const interestRate = this._parseNumber($row.find('td:nth-child(4) a').text());
        const inflation = this._parseNumber($row.find('td:nth-child(5) a').text());
        const unemployment = this._parseNumber($row.find('td:nth-child(6) a').text());

        if (country && (interestRate || inflation || unemployment)) {
          indicators.push({
            country,
            interestRate: interestRate || 0,
            inflation: inflation || 0,
            unemployment: unemployment || 0,
            lastUpdated: new Date(),
            order: count // Добавляем порядковый номер для сортировки
          });
          count++;
        }
      });

      console.log(`Parsed ${indicators.length} indicators`);

      // Сначала удаляем все старые записи
      await Indicator.deleteMany({});

      // Затем добавляем новые
      for (const indicator of indicators) {
        await Indicator.create(indicator);
      }

      return indicators;
    } catch (error) {
      console.error('Error updating indicators:', error);
      throw error;
    }
  }

  _parseNumber(value) {
    if (!value) return null;
    // Удаляем все кроме цифр, точки и минуса
    const cleaned = value.replace(/[^\d.-]/g, '');
    const number = parseFloat(cleaned);
    return isNaN(number) ? null : number;
  }

  async getIndicators() {
    try {
      // Получаем индикаторы, отсортированные по порядку
      return await Indicator.find().sort({ order: 1 });
    } catch (error) {
      console.error('Error getting indicators:', error);
      throw error;
    }
  }
}

module.exports = new IndicatorsService(); 