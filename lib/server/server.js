const express = require("express");
const { createServer } = require("http");
const { Server } = require("socket.io");

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer);

io.on("connection", (socket) => {
   socket.join("anonymous_group");
   console.info(socket.id);
   socket.on('sendMsg', (msg) => {
      console.info("msg", msg);
      io.to("anonymous_group").emit("sendMsgServer", msg);
   });
   socket.on("negotiate", (amount)=> {
      console.info("nego", amount);
      io.to("anonymous_group").emit("nego", amount);
   });
});

const port = 1233;

httpServer.listen(port, () => {
   console.info(`Server running on port ${port}`);
});