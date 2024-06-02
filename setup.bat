@echo off
mkdir controllers
mkdir models
mkdir routes
mkdir public
mkdir public\css
mkdir views

echo const mongoose = require('mongoose');
echo const playerSchema = new mongoose.Schema({
echo     name: String,
echo     entryDate: Date,
echo     discordLineName: String,
echo     rank: { type: String, enum: ['Boss', 'Admin', 'Mitglied'], default: 'Mitglied' },
echo     points: { type: Number, default: 0 },
echo     donations: { type: Number, default: 0 }
echo });
echo module.exports = mongoose.model('Player', playerSchema); > models/player.js

echo const mongoose = require('mongoose');
echo const bcrypt = require('bcrypt');
echo const userSchema = new mongoose.Schema({
echo     username: { type: String, unique: true },
echo     password: String
echo });
echo userSchema.pre('save', async function (next) {
echo     if (!this.isModified('password')) return next();
echo     this.password = await bcrypt.hash(this.password, 10);
echo     next();
echo });
echo userSchema.methods.comparePassword = function (candidatePassword) {
echo     return bcrypt.compare(candidatePassword, this.password);
echo };
echo module.exports = mongoose.model('User', userSchema); > models/user.js

echo const Player = require('../models/player');
echo const getPlayers = async (req, res) => {
echo     const players = await Player.find();
echo     res.render('dashboard', { players });
echo };
echo const addPlayer = async (req, res) => {
echo     const { name, entryDate, discordLineName } = req.body;
echo     await new Player({ name, entryDate, discordLineName }).save();
echo     res.redirect('/dashboard');
echo };
echo const getPlayer = async (req, res) => {
echo     const player = await Player.findById(req.params.id);
echo     res.render('profile', { player });
echo };
echo const updatePlayer = async (req, res) => {
echo     const { rank, points, donations } = req.body;
echo     await Player.findByIdAndUpdate(req.params.id, { rank, points, donations });
echo     res.redirect('/players/' + req.params.id);
echo };
echo const deletePlayer = async (req, res) => {
echo     await Player.findByIdAndDelete(req.params.id);
echo     res.redirect('/dashboard');
echo };
echo module.exports = { getPlayers, addPlayer, getPlayer, updatePlayer, deletePlayer }; > controllers/playerController.js

echo const User = require('../models/user');
echo const registerUser = async (req, res) => {
echo     const { username, password } = req.body;
echo     await new User({ username, password }).save();
echo     res.redirect('/login');
echo };
echo const loginUser = async (req, res) => {
echo     const { username, password } = req.body;
echo     const user = await User.findOne({ username });
echo     if (user && await user.comparePassword(password)) {
echo         req.session.userId = user._id;
echo         res.redirect('/dashboard');
echo     } else {
echo         res.redirect('/login');
echo     }
echo };
echo module.exports = { registerUser, loginUser }; > controllers/userController.js

echo const express = require('express');
echo const router = express.Router();
echo const playerController = require('../controllers/playerController');
echo const userController = require('../controllers/userController');
echo router.get('/dashboard', playerController.getPlayers);
echo router.post('/players/add', playerController.addPlayer);
echo router.get('/players/:id', playerController.getPlayer);
echo router.post('/players/update/:id', playerController.updatePlayer);
echo router.post('/players/delete/:id', playerController.deletePlayer);
echo router.get('/register', (req, res) => res.render('register'));
echo router.post('/register', userController.registerUser);
echo router.get('/login', (req, res) => res.render('login'));
echo router.post('/login', userController.loginUser);
echo module.exports = router; > routes/index.js

echo const express = require('express');
echo const mongoose = require('mongoose');
echo const session = require('express-session');
echo const bodyParser = require('body-parser');
echo const app = express();
echo mongoose.connect('mongodb://localhost:27017/playerdb', { useNewUrlParser: true, useUnifiedTopology: true });
echo app.set('view engine', 'ejs');
echo app.use(bodyParser.urlencoded({ extended: true }));
echo app.use(session({
echo     secret: 'your-secret-key',
echo     resave: false,
echo     saveUninitialized: true
echo }));
echo app.use('/css', express.static(__dirname + '/public/css'));
echo const routes = require('./routes');
echo app.use('/', routes);
echo app.listen(3000, () => console.log('Server started on port 3000')); > app.js

echo ^<!DOCTYPE html^>
echo ^<html^>
echo ^<head^>
echo   ^<title^>Register^</title^>
echo   ^<link rel="stylesheet" href="/css/styles.css"^> 
echo ^</head^>
echo ^<body^>
echo   ^<h1^>Register^</h1^>
echo   ^<form action="/register" method="post"^>
echo     ^<input type="text" name="username" placeholder="Username" required^>
echo     ^<input type="password" name="password" placeholder="Password" required^>
echo     ^<button type="submit"^>Register^</button^>
echo   ^</form^>
echo ^</body^>
echo ^</html^> > views/register.ejs

echo ^<!DOCTYPE html^>
echo ^<html^>
echo ^<head^>
echo   ^<title^>Login^</title^>
echo   ^<link rel="stylesheet" href="/css/styles.css"^>
echo ^</head^>
echo ^<body^>
echo   ^<h1^>Login^</h1^>
echo   ^<form action="/login" method="post"^>
echo     ^<input type="text" name="username" placeholder="Username" required^>
echo     ^<input type="password" name="password" placeholder="Password" required^>
echo     ^<button type="submit"^>Login^</button^>
echo   ^</form^>
echo ^</body^>
echo ^</html^> > views/login.ejs

echo ^<!DOCTYPE html^>
echo ^<html^>
echo ^<head^>
echo   ^<title^>Dashboard^</title^>
echo   ^<link rel="stylesheet" href="/css/styles.css"^>
echo ^</head^>
echo ^<body^>
echo   ^<h1^>Player Dashboard^</h1^>
echo   ^<form action="/players/add" method="post"^>
echo     ^<input type="text" name="name" placeholder="Name" required^>
echo     ^<input type="date" name="entryDate" placeholder="Entry Date" required^>
echo     ^<input type="text" name="discordLineName" placeholder="Discord/Line Name" required^>
echo     ^<button type="submit"^>Add Player^</button^>
echo   ^</form^>
echo   ^<ul^>
echo     ^<% players.forEach(player => { %^>
echo       ^<li^>
echo         ^<a href="/players/<%= player._id %>"^><%= player.name %>^</a^>
echo       ^</li^>
echo     ^<% }); %^>
echo   ^</ul^>
echo ^</body^>
echo ^</html^> > views/dashboard.ejs

echo ^<!DOCTYPE html^>
echo ^<html^>
echo ^<head^>
echo   ^<title^>Profile^</title^>
echo   ^<link rel="stylesheet" href="/css/styles.css"^>
echo ^</head^>
echo ^<body^>
echo   ^<h1^>Player Profile^</h1^>
echo   ^<form action="/players/update/<%= player._id %>" method="post"^>
echo     ^<p^>Name: <%= player.name %>^</p^>
echo     ^<p^>Entry Date: <%= player.entryDate.toISOString().split('T')[0] %>^</p^>
echo     ^<p^>Discord/Line Name: <%= player.discordLineName %>^</p^>
echo     ^<label for="rank"^>Rank:^</label^>
echo     ^<select name="rank" id="rank"^>
echo       ^<option value="Boss" <%= player.rank === 'Boss' ? 'selected' : '' %>^>Boss^</option^>
echo       ^<option value="Admin" <%= player.rank === 'Admin' ? 'selected' : '' %>^>Admin^</option^>
echo       ^<option value="Mitglied" <%= player.rank === 'Mitglied' ? 'selected' : '' %>^>Mitglied^</option^>
echo     ^</select^>
echo     ^<input type="number" name="points" placeholder="Points" value="<%= player.points %>"^>
echo     ^<input type="number" name="donations" placeholder="Donations" value="<%= player.donations %>"^>
echo     ^<button type="submit"^>Update Player^</button^>
echo   ^</form^>
echo   ^<form action="/players/delete/<%= player._id %>" method="post"^>
echo     ^<button type="submit"^>Delete Player^</button^>
echo   ^</form^>
echo ^</body^>
echo ^</html^> > views/profile.ejs

npm init -y
npm install express mongoose body-parser express-session ejs bcrypt
