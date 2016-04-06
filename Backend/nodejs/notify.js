//notify.js
//Handles push notifications

var apn = require('apn');
var options = { 
	"production": false
};
var apnConnection = new apn.Connection(options);

function Notify(uiud) {
	this.device = new apn.Device(uiud);
	this.note = new apn.Notification();
	this.note.expiry = Math.floor(Date.now() / 1000) + 3600; //1 hour expiration
}

Notify.prototype = {
	constructor: Notify,
	send: function() {
		console.log(this.note.category + " notification sent!");
		apnConnection.pushNotification(this.note, this.device)
	}
}

module.exports = {

	// For patients
	P_REMIND: function(uiud, medid) {
		var n = new Notify(uiud);
		n.note.category = 'P_REMIND';
		n.note.sound = 'takemed.m4a';
		n.note.payload = {'medid': medid};
		n.note.alert = "It's time to take your medication!";
		return n;
	},

	// For Caretakers
	C_TAKEN: function(uiud, name, pid) {
		var n = new Notify(uiud);
		n.note.category = 'C_TAKEN';
		n.note.sound = "ping.aiff";
		n.note.payload = {'pid': pid};
		n.note.alert = name + " just took all their medication";
		return n;
	},
	C_LATE: function(uiud, name, pid) {
		var n = new Notify(uiud);
		n.note.category = 'C_LATE';
		n.note.sound = "ping.aiff";
		n.note.payload = {'pid': pid};
		n.note.alert = name + " forgot to take their medication";
		return n;
	}
};
