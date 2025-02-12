const axios = require('axios');

class SimilarWebService {
  constructor(apiKey) {
    this.apiKey = apiKey;
    this.baseUrl = 'https://api.similarweb.com/v1';
  }

  async getTopSites(country) {
    try {
      const response = await axios.get(
        `${this.baseUrl}/marketplaces/ranking`,
        {
          params: {
            country,
            category: 'news',
          },
          headers: {
            'api-key': this.apiKey,
          },
        }
      );
      return response.data;
    } catch (error) {
      console.error('SimilarWeb API error:', error);
      throw error;
    }
  }
}

module.exports = new SimilarWebService(process.env.SIMILARWEB_API_KEY); 