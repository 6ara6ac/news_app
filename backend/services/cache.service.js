const fs = require('fs').promises;
const path = require('path');

class CacheService {
  constructor() {
    this.imageCache = new Map();
    this.cacheDuration = 24 * 60 * 60 * 1000; // 24 часа
    this.cacheFile = path.join(__dirname, '../data/image_cache.json');
    this.ensureCacheDirectory();
  }

  async ensureCacheDirectory() {
    try {
      await fs.mkdir(path.dirname(this.cacheFile), { recursive: true });
      await this.loadCache();
    } catch (error) {
      console.error('Cache directory creation error:', error);
    }
  }

  async getImage(key) {
    const cached = this.imageCache.get(key);
    if (cached && Date.now() - cached.timestamp < this.cacheDuration) {
      return cached.url;
    }
    return null;
  }

  async setImage(key, url) {
    try {
      this.imageCache.set(key, {
        url,
        timestamp: Date.now()
      });
      await this.saveCache();
    } catch (error) {
      console.error('Cache save error:', error);
    }
  }

  async loadCache() {
    try {
      const data = await fs.readFile(this.cacheFile, 'utf8');
      const cached = JSON.parse(data);
      this.imageCache = new Map(Object.entries(cached));
    } catch (error) {
      if (error.code !== 'ENOENT') {
        console.error('Cache load error:', error);
      }
    }
  }

  async saveCache() {
    try {
      const data = JSON.stringify(Object.fromEntries(this.imageCache));
      await fs.writeFile(this.cacheFile, data, 'utf8');
    } catch (error) {
      console.error('Cache save error:', error);
    }
  }
}

module.exports = new CacheService(); 