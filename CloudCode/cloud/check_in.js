Parse.Cloud.define("check_in", function(request, response) {
  var gameCenter = request.params.gameCenter;
	var user = request.user;

	if ( user.get("gameCenter") == gameCenter ) {
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
					var query = new Parse.Query(Parse.Installation);
					query.containedIn("user", followed);

					var mes = user.get("username") + "さんが" + gameCenter + "に来ました。";

					Parse.Push.send({
						where: query,
						data: {
							alert: mes,
							badge: "Increment"
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

	if ( user.get("gameCenter") != gameCenter ) {
		response.error( user.gameCenter + "!= " + gameCenter);
	}else {
		user.set("gameCenter", gameCenter + "を出ました");
		user.set("checkInAt", new Date());

		user.save(null, {
			success: function(userAgain) {
				response.success();
			},
			error: function(error) {
				response.error(error);
			}
		});
	}
});
