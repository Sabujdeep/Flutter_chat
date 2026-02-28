import { WebSocketServer, WebSocket } from "ws";

const wss = new WebSocketServer({ port: 3000 });

wss.on("connection", (ws) => {
  console.log("New client connected");
  console.log("Total clients:", wss.clients.size);

  ws.on("message", (message) => {
    console.log("Received:", message.toString());

    // Broadcast to ALL connected clients
    wss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(message.toString());
      }
    });
  });

  ws.on("close", () => {
    console.log("Client disconnected");
    console.log("Total clients:", wss.clients.size);
  });
});

console.log("WebSocket server running on port 3000");