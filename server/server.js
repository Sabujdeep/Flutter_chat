import { WebSocketServer, WebSocket } from "ws";

const wss = new WebSocketServer({
  port: 3000,
  host: "0.0.0.0", // IMPORTANT for mobile devices
});

const clients = new Set();

wss.on("connection", (ws, req) => {
  clients.add(ws);

  console.log("Client connected");
  console.log("Total clients:", clients.size);

  ws.on("message", (message) => {
    const data = message.toString();
    console.log("Received:", data);

    // Broadcast to all connected clients
    clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(data);
      }
    });
  });

  ws.on("close", () => {
    clients.delete(ws);
    console.log("Client disconnected");
    console.log("Total clients:", clients.size);
  });

  ws.on("error", (error) => {
    console.error("WebSocket error:", error);
  });
});

console.log("Server running on ws://0.0.0.0:3000");