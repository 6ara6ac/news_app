// На бэкенде формировать полный URL для изображений
// async findOne(id: number) {
//   const news = await this.newsRepository.findOne(id);
//   const fullImageUrl = `${process.env.API_URL}/images/${news.imageUrl}`;
//   return { ...news, imageUrl: fullImageUrl };
// } 