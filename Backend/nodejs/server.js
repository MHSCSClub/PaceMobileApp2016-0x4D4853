//server.js
//Main server file
//Localhost on port 6969, handles scheduling and push notifications

//Modules
var express = require('express');
var bodyParser = require('body-parser');
var schedule = require('node-schedule');
var notify = require('./notify');

//Schedule object that holds all scheduled tasks
var fullSchedule = { };

//Express and routing setup
var app = express();
var port = process.env.PORT || 6969;
var router = express.Router();

var SUCCESS = {
	status: "success",
	message: "Generic success"
}
var ERROR = {
	status: "error",
	message: "Generic error"
}

app.use(bodyParser.urlencoded());
app.use(bodyParser.json());

router.use(function(req, res, next) {
	try {
		next();
	} catch(e) {
		ERROR.message = e.message;
		res.send(ERROR);
	}
});

//Null check
function NC(p) {
	if(p == null)
		throw "Invalid POST data"
	return p;
}

// api/schedule
// Creating a new task
router.route('/schedule')

	.post(function(req, res) {
		//Parameters
		var schid = NC(req.body.schid); //scheduling id
		var medtime = new Date(NC(req.body.time)); //schedule time, full datetime object

		//Push note requirements
		var p_uiud = NC(req.body.patient.uiud);
		var name = NC(req.body.patient.name);
		var pid = NC(req.body.patient.pid);

		var c_uiud = NC(req.body.caretaker.uiud);
	
		if(schid in fullSchedule)
			throw "Key already exists!";

		var mrule = new schedule.RecurrenceRule();
		mrule.hour = medtime.getHours();
		mrule.minute = medtime.getMinutes();

		var lrule = new schedule.RecurrenceRule();
		lrule.hour = medtime.getHours();
		lrule.minute = medtime.getMinutes() + 5;
	
		fullSchedule[schid] = {

			medsche: schedule.scheduleJob(mrule, function(){
				var cur = fullSchedule[schid];
				notify.P_REMIND(p_uiud).send();
				cur.take = false;
				cur.send = true;
			}),

			late: schedule.scheduleJob(lrule, function() {
				var cur = fullSchedule[schid];
				if(!cur.take && cur.send) {
					notify.P_REMIND(p_uiud).send();
					notify.C_LATE(c_uiud, name, pid).send();
					cur.send = false;
				}
			}),

			take: false,
			send: false

		};

		res.json(SUCCESS);
	});

// api/schedule/{schid}
// task modification / deletion
router.route('/schedule/:schid')

	.post(function(req, res) {
		//TODO
		throw "todo";
	})

	.delete(function(req, res) {
		var schid = NC(req.params.schid);
		var cur = fullSchedule[schid];
		
		if(!(schid in fullSchedule))
			throw "Invalid schid";

		console.log(fullSchedule);
		cur.medsche.cancel();
		cur.late.cancel();
		delete fullSchedule[schid];

		res.json(SUCCESS);
	});

// api/schedule/{schid}/take
router.route('/schedule/:schid/take')

	.post(function(req, res) {
		var schid = NC(req.params.schid);

		var c_uiud = NC(req.body.caretaker.uiud);
		var name = NC(req.body.patient.name);
		var pid = NC(req.body.patient.pid);

		if(!(schid in fullSchedule))
			throw "Invalid schid";

		fullSchedule[schid].take = true;
		notify.C_TAKEN(c_uiud, name, pid).send();
		res.json(SUCCESS);
	});


app.use('/api', router);
app.listen(port);