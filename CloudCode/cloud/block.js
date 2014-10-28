Parse.Cloud.define("block", function(request, response) {
	Parse.Cloud.useMasterKey();
	var query = new Parse.Query("_User");
	var targetId = request.params.targetId;

	query.get(targetId, {
		success: function(target) {
			var user = request.user;
			var block = user.relation("blockUsers");

			block.add(target);
			
			var ACL = user.getACL();
			if ( !ACL ) { 
				ACL = new Parse.ACL(user);
				ACL.setPublicReadAccess(true);
			}

			ACL.setReadAccess(targetId, false);
			user.setACL(ACL);

			user.save(null, {
				success: function(userAgain) {
					block.query().find({ 
						success: function(result) {
							var functions = require('cloud/functions.js');
						
							response.success( functions.getObjectIdArray(result));
						},
						error: function(result, error) {
							response.error(error);
						}
					});
				},
				error: function(result, error) {
					response.error(error);
				}
			});

		},
		error: function(result, error) {
			response.error(error);
		}
	});

});

Parse.Cloud.define("unblock", function(request, response) {
	Parse.Cloud.useMasterKey();
	var query = new Parse.Query("_User");
	var targetId = request.params.targetId;

	query.get(targetId, {
		success: function(target) {
			var user = request.user;
			var block = user.relation("blockUsers");

			block.remove(target);
			
			var ACL = user.getACL();
			if ( !ACL ) { 
				ACL = new Parse.ACL(user);
				ACL.setPublicReadAccess(true);
			}

			ACL.setReadAccess(targetId, true);
			user.setACL(ACL);

			user.save(null, {
				success: function(userAgain) {
					block.query().find({ 
						success: function(result) {
							var idArray = new Array();

							for ( i = 0; i < result.length; ++i ) {
								idArray.push( result[i].id );
							}
								
							response.success( idArray )
						},
						error: function(result, error) {
							response.error(error);
						}
					});
				},
				error: function(result, error) {
					response.error(error);
				}
			});
		},
		error: function(result, error) {
			response.error(error);
		}
	});

});

