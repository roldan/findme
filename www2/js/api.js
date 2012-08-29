function create(fbID,fun){
	$.ajax({
		type: 'POST',
		url: 'index.php/users/create',
		data: {'fbID': fbID},
		success: function (data){
			fun (data);
		}
	});
	
}
function get(fbID,fun){
	$.ajax({
		type: 'GET',
		url: 'index.php/users/get',
		data: {'fbID': fbID},
		success: function (data){
			fun (data);
		}
	});
}
function check (fbID,hash,fun){
	$.ajax({
		type: 'GET', 
		url: 'index.php/users/get',
		data: {'fbID': fbID},
		success: function (data){
			fun (data);
		}
	});
}
function addPoints (fbID,add,fun){
	$.ajax({
		type: 'POST', 
		url: 'index.php/users/addPoints',
		data: {'fbID': fbID},
		success: function (data){
			fun (data);
		}
	});
}
function exists (fbID, fun){
	$.ajax({
		type: 'GET',
		url: 'index.php/users/exists',
		data: {'fbID': fbID},
		success: function (data){
			fun (data);
		}
	});
}