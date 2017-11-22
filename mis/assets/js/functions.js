function sp_save(params,$scope,$http){
	$("#loading").show();
	$http({method:"GET",url:params.url,
		params:params.params
	}).success(function(data) {
		$("#loading").hide();
		if(data.error.code=="1"){
			noty({text: data.error.message,
				type:'error',
				layout:'center'
			});
		}else{
			noty({text: 'Saved success!',
				type:'success',
				layout:'center'
			});
		}
		
	}).error(function(data, status, headers, config){
		$("#loading").hide();
		noty({text: 'Saved error!',
			type:'error',
			layout:'center'
		});
	});
}

function sp_add(params,$scope,$http){
	$("#loading").show();
	$http({method:"GET",url:params.url,
		params:params.params
	}).success(function(data) {
		$("#loading").hide();
		if(data.error.code=="1"){
			noty({text: data.error.message,
				type:'error',
				layout:'center'
			});
		}else{
			noty({text: 'Saved success!',
				type:'success',
				layout:'center',
				modal: true,
				callback:{
					afterClose:function() {
						if(params.redirect){
							location.href=params.redirect;
						}
					}
				}
			});
			
		}
		
	}).error(function(data, status, headers, config){
		$("#loading").hide();
		noty({text: 'Saved error!',
			type:'error',
			layout:'center'
		});
	});
}

function sp_data(params,$scope,$http){
	$("#loading").show();
	$http.get(
			params.url,
	  {params:params.params}
	).success(function(data){
	  $("#loading").hide();
	  $scope.vo=data.data;
	}).error(function(data, status, headers, config){
	  $("#loading").hide();
	});
}

function sp_list(params,$scope,$http){
	$("#loading").show();
	$http.get(
	   params.url,
	  {params:params.params}
	).success(function(data){
	  $("#loading").hide();
	  $scope.lists=data.data;
	}).error(function(data, status, headers, config){
	  $("#loading").hide();
	});
}

function sp_delete(params,$scope,$http){
	noty({
		text: 'This will be deleted, are you sure?',
		type:'confirm',
		layout:"center",
		timeout: false,
		modal: true,
	   	buttons: [
		  {
			addClass: 'btn btn-primary', text: 'Yes', 
			onClick: function($noty){
				$("#loading").show();
				$noty.close();
				$http.get(params.url,{params:params.params})
				.success(function(data){
					if(data.error.code=="0"){
						noty({text: 'Deleted success!',
							type:'success',
							layout:'center'
						});
						$http.get(params.listurl,{})
						.success(function(data) {
							$("#loading").hide();
							$scope.lists = data.data;
						}).error(function(){
							$("#loading").show();
						});
					}else{
						$("#loading").hide();
					}
				});
		  	}
		  },
		  {addClass: 'btn btn-danger', text: 'Cancel', onClick: function($noty){$noty.close();}}
		]
	});
}


function sp_request(params,$scope,$http){
	$("#loading").show();
	$http.get(
			params.url,
	  {params:params.params}
	).success(function(data){
		if(data.error.code=="0"){
			noty({text: 'Success!',
				type:'success',
				layout:'center'
			});
		}else{
			
		}
		$("#loading").hide();
	}).error(function(data, status, headers, config){
	  $("#loading").hide();
	});
}

