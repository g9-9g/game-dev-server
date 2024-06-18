var express = require('express');
var router = express.Router();

var middlewares = require('../middlewares/auth.')
var auth = require('../controller/user/auth')

var userInfo = require('../controller/user/friends')

router.get('/', middlewares.checkToken, (req,res,next) => {
  res.send('respond with a resource');
})

router.post('/register', auth.signup)
router.post('/login', auth.login)

router.get('/signout', [middlewares.checkToken, auth.signout])

router.use('/showFriendList', [middlewares.checkToken, userInfo.showFriendList]);

router.use('/showFriendRequestList', [middlewares.checkToken, userInfo.showFriendRequestList]);

router.use('/sendFriendRequest', [middlewares.checkToken, userInfo.sendFriendRequest]);

router.use('/responseFriendRequest', [middlewares.checkToken, userInfo.responseFriendRequest]);

router.use('/removeFriend', [middlewares.checkToken, userInfo.removeFriend]);

module.exports = router;
