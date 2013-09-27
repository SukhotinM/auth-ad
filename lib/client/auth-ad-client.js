Meteor.loginWithAD = function(username, password, callback) {  
  var loginRequest = {ad: true, username: username, password: password};
  Accounts.callLoginMethod({
    methodArguments: [loginRequest],
    userCallback: callback
  });
};