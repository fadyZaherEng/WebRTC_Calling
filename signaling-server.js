const io = require("socket.io")(process.env.PORT || 3000, {
  cors: { origin: "*" },
});

const users = new Map();

io.on("connection", (socket) => {
  const userId = socket.handshake.query.userId;
  if (userId) {
    users.set(userId, socket.id);
    console.log(`User ${userId} connected with socket ${socket.id}`);
  }

  socket.on("start-call", (data) => {
    const receiverSocketId = users.get(data.receiverId);
    if (receiverSocketId) {
      io.to(receiverSocketId).emit("incoming-call", data);
    }
  });

  socket.on("offer", (data) => {
    const receiverSocketId = users.get(data.receiverId);
    if (receiverSocketId) {
      io.to(receiverSocketId).emit("offer", data.offer);
    }
  });

  socket.on("answer", (data) => {
    const callerSocketId = users.get(data.callerId);
    if (callerSocketId) {
      io.to(callerSocketId).emit("answer", data.answer);
    }
  });

  socket.on("ice-candidate", (data) => {
    const peerSocketId = users.get(data.peerId);
    if (peerSocketId) {
      io.to(peerSocketId).emit("ice-candidate", data.candidate);
    }
  });

  socket.on("end-call", (data) => {
    const peerSocketId = users.get(data.peerId);
    if (peerSocketId) {
      io.to(peerSocketId).emit("call-ended");
    }
  });

  socket.on("disconnect", () => {
    users.forEach((value, key) => {
      if (value === socket.id) {
        users.delete(key);
        console.log(`User ${key} disconnected`);
      }
    });
  });
});

console.log("Signaling server running...");
