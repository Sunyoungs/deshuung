var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
const cors=require('cors');
const axios=require('axios');
const { admin, db } = require("./config/firebaseAdmin");

var indexRouter = require('./routes/index');
var accountsRouter=require('./routes/accounts');
var carsRouter=require('./routes/cars');
var paymentsRouter=require('./routes/payments');
var storesRouter=require('./routes/stores');
var driveRouter=require('./routes/drive');

var app = express();


// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(cors());
app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', indexRouter);
app.use('/accounts', accountsRouter);
app.use('/cars',carsRouter);
app.use('/payments',paymentsRouter);
app.use('/stores',storesRouter);
app.use('/drive',driveRouter);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

// 테스트 라우트 (Firestore에서 데이터 조회)
app.get("/", async (req, res) => {
  const snapshot = await db.collection("accounts").get();
  const users = snapshot.docs.map(doc => doc.data());
  res.json({ users });
});

module.exports = app;
