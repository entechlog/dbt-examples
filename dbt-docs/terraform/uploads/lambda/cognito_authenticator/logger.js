const pino = require('pino');

let logger;

function getLogger() {

  if (!logger) {
    logger = pino({
      level: 'info',
      base: null, // Remove pid, hostname and name logging as not useful for Lambda
    });
  }

  return logger;
}

module.exports = {
  getLogger
}
