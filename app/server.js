const hapi = require("@hapi/hapi");
const config = require("./config");
//const { sequelize } = require("./services/database-service");
const logger = require("./utilities/logger");
const path = require("path");
const filenameForLogging = path.join("app", __filename.split("app")[1]);

async function createServer() {
  // try {
  //   await sequelize.authenticate();
  // } catch (err) {
  //   logger.logError(
  //     filenameForLogging,
  //     "createServer > sequelize.authenticate()",
  //     err,
  //   );
  // }

  let server;
  try {
    // Create the hapi server
    server = hapi.server({
      port: config.port,
      routes: {
        validate: {
          options: {
            abortEarly: false,
          },
        },
      },
    });
  } catch (err) {
    logger.logError(filenameForLogging, "createServer > hapi.server()", err);
  }

  try {
    // Register the plugins
    await server.register(require("./plugins/router"));
  } catch (err) {
    logger.logError(
      filenameForLogging,
      "createServer > server.register()",
      err,
    );
  }

  try {
    if (config.isDev) {
      await server.register(require("blipp"));
    }
  } catch (err) {
    logger.logError(
      filenameForLogging,
      "createServer > server.register() [DEV]",
      err,
    );
  }

  return server;
}

module.exports = createServer;
