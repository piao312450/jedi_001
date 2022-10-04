const functions = require("firebase-functions");

const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

exports.helloWorld = functions.https.onRequest((request, response) => {
  response.send("Hello from Firebase!");
});

exports.fixScheduleMember = functions.firestore.document('users/{userID}/band/{bandID}').onUpdate((change, context) => {

  console.log(db.doc('schedules/${context.params.userID}/mySocialSchedule').get());

  const beforeMember = change.before.data()['member']
  const afterMember = change.after.data()['member']

  const deleteMember = beforeMember.filter((x) => !afterMember.includes(x));
  const addedMember = afterMember.filter((x) => !beforeMember.includes(x));


});

exports.deploySocialSchedule = functions.firestore.document('schedules/{userID}/mySocialSchedule/{scheduleID}').onUpdate((change, context) => {

});