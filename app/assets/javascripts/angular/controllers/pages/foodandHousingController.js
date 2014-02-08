angular.module('calcentral.controllers').controller('FoodandHousingController', function($http, $routeParams, $scope, apiService) {

  $scope.balance = 0;
  $scope.addToBalance= function () {
  	$scope.balance = $scope.balance + 1;
  };

  $scope.diningHalls = [
	  	{ 'name': 'Crossroads', 
	  		'menu': {'item 1': 'Roast Beef', 'item 2': 'pizza'}

	  	},
	  	{ 'name': 'Cafe3',
	  		'menu': {'item 1': 'Roast Beef', 'item 2': 'pizza'}
	  	}
  ];
  $scope.menuSort = 'id';


});


// {
//   "activities": [
//     {
//       "id": 1,
//       "title": "Evacuate Dwinelle Hall",
//       "summary": "Evacuate Dwinelle Hall immediately, gas leak",
//       "source": "Warn Me",
//       "type": "alert",
//       "date": {
//         "epoch": 1349049728,
//         "date_time": "2013-01-15T19:52:27+00:00",
//         "date_string": "Today"
//       },
//       "source_url": "https://warnme.berkeley.edu/",
//       "emitter": "bSpace"
//     },
// }