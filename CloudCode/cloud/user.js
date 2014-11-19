Parse.Cloud.define("gamecenter_user", function(request, response) {
	var user = request.user;
	var block = user.relation("blockUsers");

	if ( !block ) {
		block = new Parse.Relation();
	}

	block.query().find({
		success: function(blockUsers) {
			var idArray = new Array();
			for ( i = 0; i < blockUsers.length; ++i ) {
				idArray.push( blockUsers[i].id );
			}

			var query = new Parse.Query("_User");
			query.notContainedIn("objectId", idArray);

			query.equalTo("gameCenter", request.params.gameCenter);

			var date = new Date();
			var halfDay = 12 * 60 * 60 * 1000;
			date = new Date( date.getTime() - halfDay );

			query.greaterThanOrEqualTo("checkInAt", date);
			query.descending("checkInAt");

			query.find({
				success: function(result) {
					response.success(result);
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
