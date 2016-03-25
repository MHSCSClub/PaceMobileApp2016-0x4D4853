//server.js
//localhost on port 6969, handles scheduling and push notifications

var express = require('express');
var bodyParser = require('body-parser');
var schedule = require('node-schedule');

var app = express();
var port = process.env.PORT || 6969;
var router = express.Router();

app.use(bodyParser.urlencoded());
app.use(bodyParser.json());

var fullSchedule = { };

router.use(function(req, res, next) {
	try {
		next();
	} catch(e) {
		res.send(e.message);
	}
});

// api/schedule
// Creating a new task
router.route('/schedule')

	.post(function(req, res) {
		//Full date time object, only going to use hours + minutes
		var medtime = new Date(req.body.time);
		var medid = req.body.medid;
		var message = req.body.message;
	
		if(medid == null || message == null)
			throw "Invalid POST data";
		else if(medid in fullSchedule)
			throw "Key already exists!";

		var rule = new schedule.RecurrenceRule();
		rule.second = medtime.getSeconds();
		var schej = schedule.scheduleJob(rule, function(){
			console.log(message);
		});
	
		fullSchedule[medid] = schej;
		res.send("Schedule success!");
	});

// api/{medid}
// task modification / deletion
router.route('/schedule/:medid')

	.delete(function(req, res) {
		var medid = req.params.medid;
		
		if(!(medid in fullSchedule))
			throw "Invalid medid";

		fullSchedule[medid].cancel();
		res.send("Deletion successful")
	});

app.use('/api', router);
app.listen(port);