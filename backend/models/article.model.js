const mongoose = require('mongoose');

const articleSchema = new mongoose.Schema({
  _id: String,
  title: String,
  content: String,
  shortSummary: String,
  summary: String,
  imageUrl: String,
  link: String,
  category: String,
  source: {
    name: String,
    url: String
  },
  language: String,
  publishedAt: Date,
  savedBy: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }]
});

module.exports = mongoose.model('Article', articleSchema); 