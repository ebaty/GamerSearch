Parse.Cloud.define("follow", function(request, response) {
	Parse.Cloud.useMasterKey();

	var user = request.user;
	var followRelation = user.relation("followUsers");

	var query = new Parse.Query("_User");
	query.get(request.params.targetId, {

		success: function(target){
			followRelation.add(target);

			user.save(null, {
				success: function(userAgain){
					var followedRelation = target.relation("followedUsers");
					if ( !followedRelation ) {
						followedRelation = new Parse.Relation();
					}

					followedRelation.add(userAgain);
					
					target.save(null, {
						success: function(targetAgain){
							response.success();
						},
						error: function(result, error) {
							response.error(error);
						}
					})
				},
				error: error
			})

		},
		error: error
	});
	
	function error(result, error) {
    response.error(error);
  }
});

Parse.Cloud.define("unfollow", function(request, response) {
	Parse.Cloud.useMasterKey();

	var user = request.user;
	var followRelation = user.relation("followUsers");

	var query = new Parse.Query("_User");
	query.get(request.params.targetId, {

		success: function(target){
			followRelation.remove(target);

			user.save(null, {
				success: function(userAgain){
					var followedRelation = target.relation("followedUsers");
					if ( !followedRelation ) {
						followedRelation = new Parse.Relation();
					}
					followedRelation.remove(userAgain);
					
					target.save(null, {
						success: function(targetAgain){
							response.success();
						},
						error: function(targetAgain, error){
							response.error(error);
						}
					})
				},
				error: function(userAgain, error){
					response.error(error);
				}
			})

		},
		error: function(result, error){
			response.error(error);
		}
	});
});

