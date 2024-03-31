const { Socket } = require("socket.io");
const Player = require("../../model/game/Player");
const jwt = require("jsonwebtoken");


const disconnect = (event) => {
    console.log("Disconnected")
} 

var players = {};
var sockets = [];

const onConnection = (socket) => {
    // Create player on connection
    var player = new Player();


    socket.use(async (packet, next) => {
        const token = socket.handshake.headers.token || socket.handshake.query.token;
        console.log(token)
        try {
            const decoded = await jwt.verify(token, process.env.secretKey)
            console.log(decoded)
            const { user_id , username, email } = decoded.user

            // Set player
            player.setPlayer(username, user_id);
            players[user_id] = player // Assigned to players array


            next()
        } catch (error) {
            next(new Error("lmao"))
        }
        
    })

    

    // socket.emit()

    socket.on("Client-send", function(data) {
            console.log("the user said:", data)
            socket.emit("Server-send", data);
    });


  socket.on("disconnect", disconnect)
}


module.exports = {
    onConnection
}