###
  Check if username credentials are valid for ActiveDirectory server and after that login 
  in Meteor accounts system with login: username_ad. 
###

AuthAD = AuthAD ? {}

_.extend AuthAD,
  settings:
    serverUrl: 'ldap://127.0.0.1'
    searchDN: 'cn=users,dc=example,dc=com'
    userSuffix: '_ad'

  LDAP = null
  ldap = null
  Future = Npm.require 'fibers/future'
  LDAP = Meteor.require('ldapjs')

  setSettings: (s)->    
    if s.serverUrl?
      @settings.serverUrl = s.serverUrl
    if s.searchDN?
      @settings.searchDN = s.searchDN
    if s.userSuffix?
      @settings.userSuffix = s.userSuffix

openLdap = () ->    
  ldap = LDAP.createClient {url: AuthAD.settings.serverUrl}
  return true

bindLdap = (username, password) ->
  bind_dn =  'cn=' + username + ',' + AuthAD.settings.searchDN
  fut = new Future()    
  ldap.bind bind_dn, password, Meteor.bindEnvironment ((err) =>   
    if (err)      
      ldap.unbind()
      fut.return null
      return      
    else
      userId = null      
      #check if user already exists. If no - create new one with ldap suffix
      user = Meteor.users.findOne({username: username + AuthAD.settings.userSuffix})                        
      if (!user)
        userId = Meteor.users.insert 
                    username: username + AuthAD.settings.userSuffix
                    email: ""                    
                    securityProfile:
                      globalRole: "user"
                    profile:
                      firstName: ""
                      lastName: ""
      else 
        userId = user._id 
      ldap.unbind()      
      fut.return userId
      return 
    ), (error) =>
        console.dir(error)
  return fut.wait()


#register new LoginHandler for activedirectory login. Input object should contains field "ad"
Accounts.registerLoginHandler (loginRequest) =>  
  console.dir(loginRequest)
  if(!loginRequest.ad) 
    return undefined
  if (openLdap())    
    userId = bindLdap(loginRequest.username, loginRequest.password)    
    #set login token to user, so it will be logged in as in usual account system
    stampedToken = Accounts._generateStampedLoginToken();
    Meteor.users.update(userId, 
      {$push: {'services.resume.loginTokens': stampedToken}}
    );
    return {id : userId, token: stampedToken.token}
  else 
    return null