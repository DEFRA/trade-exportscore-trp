const routes = [].concat(
  require("../routes/healthy"),
  require("../routes/healthz"),
);

module.exports = {
  plugin: {
    name: "router",
    register: (server, _options) => {
      server.route(routes);
    },
  },
};
