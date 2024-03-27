var express = require('express');
var router = express.Router();

var middlewares = require('../middlewares/auth')
var auth = require('../controllers/userAuth')

router.get('/', middlewares.checkToken, (req,res,next) => {
  res.send('respond with a resource');
})

/* GET users listing. */
// router.get('/', function(req, res, next) {
//   res.send('respond with a resource');
// });

router.post('/signup', middlewares.checkUser, auth.signup)
router.post('/login', auth.login)

router.get('/signout', auth.signout)

module.exports = router;
