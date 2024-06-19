const User = require('../../db/friends')

const checkPageOption = (page_option) => {
    const err_message = "Page option must be an object, 0 < max_page <= 25, 0 < page_num"
    const { max_page, page_num } = page_option;
    if (!max_page || !page_num) throw Error(err_message)
    if (!(0 < max_page && max_page <= 25)) throw Error(err_message)
    if (!(0 < page_num)) throw Error(err_message)
}

const showFriendList = async (req, res) => {
    try {
        
        const page_option = req.body.page_option

        console.log(req.body)
        const user_id = req.user.user_id
        
        checkPageOption(page_option)
        
        return res.status(200).send( {"friends_list": await User.showFriendList(user_id, page_option) })
    } catch (error) {
        console.log(error)
        return res.status(400).send( {"error": error} )
    }
}

const showFriendRequestList = async (req,res) => {
    try {
        const user_id = req.user.user_id
        const page_option = req.body.page_option
        checkPageOption(page_option)
        return res.status(200).send( {"friends_list": await User.showFriendRequestList(user_id, page_option) } )
    } catch (error) {
        console.log(error)
        return res.status(400).send( {"error": error} )
    }
}

const sendFriendRequest = async (req,res) => {
    try {
        const user_id = req.user.user_id
        const friend_id = req.body.friend_id
    
        return res.status(200).send(await User.addFriend(user_id, friend_id))
    } catch (error) {
        console.log(error)
        if (error.code == 23505) {
            return res.status(400).send( {"error": `Already send friend request to user ${friend_id}`} )
        }
        else if (error.code == 'P0001') {
            return res.status(400).send( {"error": `Cannot send friend request to yourself`} )
        } else {
            return res.status(400).send( {"error": error} )
        }
    }
}


const ACCEPT = 1;
const DECLINE = 0;
// decline or accept -> will delete from request list
const responseFriendRequest = async (req,res) => {
    try {
        const user_id = req.user.user_id
        const friend_id = req.body.friend_id
        const command = req.body.command // decline = 0; accept = 1;
    
        if (command == ACCEPT) {
            return res.status(200).send(await User.addFriend(user_id, friend_id))
        } else if (command == DECLINE) {
            if (await User.removeFriendRequest(user_id, friend_id) == 0) {
                throw new Error(`Friend request from uid: ${friend_id} does not exist`)
            }
            return res.status(200).send(`Successfully remove friend request from uid: ${friend_id}`)
        } else {
            throw new Error("Invalid command code !")
        }
    } catch (error) {
        console.log(error)
        if (error.code == 23505) {
            return res.status(400).send( {"error": `Already accept friend request to user ${friend_id}`} )
        } else {
            return res.status(400).send( {"error": error} )
        }
    }
}

const removeFriend = async (req,res) => {
    try {
        const user_id = req.user.user_id
        const friend_id = req.body.friend_id

        const result = await User.removeFriend(user_id, friend_id);
        if (result == 0) {
            throw new Error(`Friend with uid: ${friend_id} does not exist`)
        }

        return res.status(200).send(`Successfully remove friend with uid: ${friend_id}`)
    } catch (error) {
        console.log(error)
        return res.status(400).send( {"error": error} )
    }
}

module.exports = {
    showFriendList,
    sendFriendRequest,
    responseFriendRequest,
    showFriendRequestList,
    removeFriend
}