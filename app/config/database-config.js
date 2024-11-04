const { DefaultAzureCredential } = require("@azure/identity");
const { development, production, test } = require("./constants").environments;

function isProd() {
  return process.env.NODE_ENV === production;
}

const hooks = {
  beforeConnect: async (cfg) => {
    if (isProd()) {
      const credential = new DefaultAzureCredential({
        managedIdentityClientId: process.env.AZURE_CLIENT_ID,
      });

      const accessToken = await credential.getToken(
        "https://ossrdbms-aad.database.windows.net/.default",
      );

      cfg.password = accessToken.token;
    }
  },
};

const retry = {
  backoffBase: 500,
  backoffExponent: 1.1,
  match: [/SequelizeConnectionError/],
  max: 10,
  name: "connection",
  timeout: 60000,
};

const dbConfig = {
  database:
    "master",
  dialect: "mssql",
  dialectOptions: {
    ssl: isProd(),
  },
  hooks,
  host: process.env.SQL_HOST || "trade-exportscore-trp-sql",
  password: process.env.SQL_PASSWORD,
  port: process.env.SQL_PORT,
  logging: process.env.SQL_LOGGING || false,
  retry,
  schema: process.env.SQL_SCHEMA_NAME || "public",
  username: process.env.SQL_USERNAME,
};

const config = {};
config[development] = dbConfig;
config[production] = dbConfig;
config[test] = dbConfig;

module.exports = config;
