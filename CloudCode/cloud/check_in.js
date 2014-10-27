var functions = require("cloud/functions.js");

Parse.Cloud.define("check_in", function(request, response) {
  var gameCenter = request.params.gameCenter;
	var user = request.user;

	if ( user.gameCenter == gameCenter ) {
		response.error();
		return;
	}

	user.set("gameCenter", gameCenter);
  user.set("checkInAt", new Date());

	user.save(null, {
		success: function() {
			var relation = user.relation("followedUsers");

			relation.query().find({
				success: function(followed) {
					var ids = functions.getObjectIdArray(followed);

					var query = new Parse.Query(Parse.Installation);
					query.containedIn(ids);

					var mes = user.username + "さんが" + gameCenter + "に来ました。";

					Parse.Push.send({
						where: query,
						data: {
							alert: mes
						}
					}, {
						success: function() {
						  response.success();
						},
						error: function() {
						  response.error();
						}
					});
				},
				error: function(error) {
					response.error(error);
				}
			});
		},
		error: function(error) {
			response.error(error);
		}
	});
});

Parse.Cloud.define("check_out", function(request, response) {
	var user = request.user;
	var gameCenter = request.params.gameCenter;

	if ( user.gameCenter != gameCenter ) {
		response.error();
		return;
	}

	user.set("gameCenter", user.gameCenter + "を出ました");
	user.set("checkInAt", new Date());

	user.save(null, {
		success: function(userAgain) {
			response.sucess();
		},
		error: function(error) {
			response.error(error);
		}
	});

});
