const { Socket } = require("socket.io");
const Player = require("../../model/Player");
const jwt = require("jsonwebtoken");

// Socket server run on a different port 
var io = require('socket.io')("1234");


var players = {};
var sockets = [];

io.use(require("../../middlewares/auth.").checkSocketToken)

io.on("connection", (socket) => {
    const { username, user_id } = socket.user
    // Create player on connection
    var player = new Player(username, user_id);
    players[user_id] = player
    sockets[user_id] = socket

    // socket.emit()

    // Tell the client the id
    socket.emit('register', { 'user_id': user_id })
    socket.emit('spawn', player)
    socket.broadcast.emit('spawn', player) // Tell other 

    for (var playerId in player) {
        if (playerId != user_id) {
            socket.emit('spawn', players[playerId])
        }
    }

    socket.on("Client-send", function(data) {
        console.log("the user said:", data)
        socket.emit("Server-send", data);
    });


    socket.on("disconnect", (socket) => {
        console.log("disconnected");
        delete socket
        delete player
    })
})


module.exports = {
    
}