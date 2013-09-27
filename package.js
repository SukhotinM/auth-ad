try {
    Package.describe({
        summary: "Meteor authorization through Active Directory"
    });

    Package.on_use(function (api) {
    	api.use(['coffeescript', 'npm', 'accounts-base'], ['server']);
        api.use(['standard-app-packages'], ['client','server']);        
        api.add_files('lib/client/auth-ad-client.js','client');
        api.add_files('lib/server/auth-ad-server.coffee','server');
        api.export ('AuthAD', 'server');
    });
}
catch (err) {
    console.log("Error while trying to load a package: " + err.message);
}
