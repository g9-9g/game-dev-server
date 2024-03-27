var express = require('express');
var router = express.Router();

var db = require('../model/index')
var auth = require('../middlewares/auth')
var userAuth = require('../controllers/userAuth')

/* GET home page. */
router.post('/signup', auth.checkUser, userAuth.signup);

router.post('/login', userAuth.login);

module.exports = router;
