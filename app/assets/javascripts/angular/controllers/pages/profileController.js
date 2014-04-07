(function(angular) {
  'use strict';

  /**
   * Settings controller
   */
  angular.module('calcentral.controllers').controller('ProfileController', function($scope, apiService) {

    apiService.util.setTitle('Profile');

    var services = ['google'];

  });

})(window.angular);
