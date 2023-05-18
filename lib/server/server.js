const express = require("express");
const { createServer } = require("http");
const { Server } = require("socket.io");

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer);

io.on("connection", (socket) => {
   socket.join("anonymous_group");
   socket.on('sendMsg', (msg) => {
      console.info("msg", msg);
      io.to("anonymous_group").emit("sendMsgServer", { ...msg, type: "otherMsg" , sender: socket.id});
   });
});

const port = 3000;

httpServer.listen(port, () => {
   console.info(`Server running on port ${port}`);
});