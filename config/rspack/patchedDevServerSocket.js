import WebSocketClient from "@rspack/dev-server/client/clients/WebSocketClient.js";
import { log } from "@rspack/dev-server/client/utils/log.js";

const Client =
  typeof __rspack_dev_server_client__ !== "undefined"
    ? __rspack_dev_server_client__.default !== undefined
      ? __rspack_dev_server_client__.default
      : __rspack_dev_server_client__
    : WebSocketClient;

let client = null;

function socket(url, handlers, reconnect) {
  let retries = 0;
  const maxRetries = reconnect ?? 10;
  let reconnectTimeoutId;

  const connect = () => {
    client = new Client(url);

    client.onOpen(() => {
      retries = 0;

      if (reconnectTimeoutId) {
        clearTimeout(reconnectTimeoutId);
      }
    });

    client.onClose(() => {
      if (retries === 0) {
        handlers.close();
      }

      client = null;

      if (retries < maxRetries) {
        const retryInMs = 1000 * 2 ** retries + 100 * Math.random();
        retries += 1;
        log.info("Trying to reconnect...");
        reconnectTimeoutId = setTimeout(connect, retryInMs);
      }
    });

    client.onMessage((data) => {
      const message = JSON.parse(data);

      if (handlers[message.type]) {
        handlers[message.type](message.data, message.params);
      }
    });
  };

  connect();
}

export default socket;
export { client };
