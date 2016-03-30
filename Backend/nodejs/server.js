//server.js
//localhost on port 6969, handles scheduling and push notifications

//Modules
var express = require('express');
var bodyParser = require('body-parser');
var schedule = require('node-schedule');
var apn = require('apn');

//Push notification setup
var options = { 
	"production": false
};
var apnConnection = new apn.Connection(options);

function pushNotify(uiud, medid, message) {
	var device = new apn.Device(uiud);

	var note = new apn.Notification();
	note.expiry = Math.floor(Date.now() / 1000) + 3600; //1 hour expiration
	note.category = 'MED_CATEGORY';
	note.sound = 'takemed.m4a';
	note.payload = {'medid': medid};
	note.alert = message;

	apnConnection.pushNotification(note, device);
	console.log('Push notification with message: "' + message + '" delivered!');
}

//Schedule object that holds all scheduled tasks
var fullSchedule = { };

//Express and routing setup
var app = express();
var port = process.env.PORT || 6969;
var router = express.Router();

app.use(bodyParser.urlencoded());
app.use(bodyParser.json());

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
		//Parameters
		var schid = req.params.schid; //scheduling id
		var medtime = new Date(req.body.time); //schedule time, full datetime object
		//Push note requirements
		var uiud = req.body.uiud;
		var medid = req.body.medid;
		var message = req.body.message;
	
		if(schid == null || medtime == null || uiud == null || medid == null || message == null  )
			throw "Invalid POST data";
		else if(schid in fullSchedule)
			throw "Key already exists!";

		var rule = new schedule.RecurrenceRule();
		rule.second = medtime.getSeconds();
		var schej = schedule.scheduleJob(rule, function(){
			pushNotify(uiud, medid, message);
		});
	
		fullSchedule[schid] = schej;
		res.send("Schedule success!");
	});

// api/schedule/{schid}
// task modification / deletion
router.route('/schedule/:schid')

	.delete(function(req, res) {
		var schid = req.params.schid;
		
		if(!(schid in fullSchedule))
			throw "Invalid schid";

		fullSchedule[schid].cancel();
		res.send("Deletion successful")
	});

// api/notify
// POST request that creates and sends a push notification
router.route('/notify')

	.post(function(req, res) {
		//Parameters
		var uiud = req.body.uiud;
		var medid = req.body.medid;
		var message = req.body.message;

		if(uiud == null || medid == null || message == null)
			throw "Invalid POST data";

		pushNotify(uiud, medid, message);
		res.send("Send successful");
	});

app.use('/api', router);
app.listen(port);