class LoggerService {
  info(message) {
    console.log(`[INFO] ${message}`);
  }

  error(message, error) {
    console.error(`[ERROR] ${message}`, error);
  }

  warn(message) {
    console.warn(`[WARN] ${message}`);
  }

  debug(message) {
    console.debug(`[DEBUG] ${message}`);
  }
}

module.exports = new LoggerService(); 