const mongoose = require('mongoose');

const indicatorSchema = new mongoose.Schema({
  country: { type: String, required: true },
  interestRate: { type: Number, default: 0 },
  inflation: { type: Number, default: 0 },
  unemployment: { type: Number, default: 0 },
  lastUpdated: { type: Date, default: Date.now },
  order: { type: Number, required: true }
}, {
  timestamps: true
});

module.exports = mongoose.model('Indicator', indicatorSchema); 