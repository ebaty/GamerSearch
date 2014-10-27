function getObjectIdArray(array) {
	var ids = new Array();
	
	for ( i = 0; i < array.length; ++i ) {
		ids.push( array[i] );
	}

	return ids;
};

module.exports = {
	getObjectIdArray: getObjectIdArray
}
