class Player {
    constructor(userName='', id=0) {
        this.userName = userName;
        this.id = id;

    }

    setPlayer (userName, id) {
        this.userName = userName;
        this.id = id;
    }
    
}

module.exports = Player