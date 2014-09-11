specimenEvent = angular.module('specimen-event-app',['plus.formsServices', 'plus.directives','ui.bootstrap']);

specimenEvent.controller('SpecimenEventController', ['$scope', 'SpecimensEventService', 'SpecimensService', 'FormsService', function($scope, SpecimensEventService, SpecimensService, FormsService){

  function getSpecimenLabels() {
    var query = parent.location.search.substr(1);
    var params = {};
    query.split("&").forEach(function(part) {
      var item = part.split("=");
      params[item[0]] = decodeURIComponent(item[1]);
    });
    return params.specimenLabels;
  }

  $scope.selectedEvent = undefined;
  $scope.specimenLabels = getSpecimenLabels();

  var dataTable = undefined;
  FormsService.getAllSpecimenEventForms().then( function(events) {
    $scope.specimenEvents = events;
  });

  $scope.onEventSelect = function(selectedEvent) {
    $scope.dataEntryMode = $scope.editRecords  = false;
    FormsService.getFormDef(selectedEvent.formId).then(function (data){
      var formDef = data;
      dataTable = new edu.common.de.DataTable({
        formId           : selectedEvent.formId,
        idColumnLabel    : 'Specimen Label',
        formDef          : formDef,
        formDiv          : 'data-table',
        onValidationError: function() {
          Utility.notify($("#notifications"), "There are some errors on form. Please rectify them before saving", "error", true);
        }
      });
      dataTable.clear();
    });
  }

  $scope.addRecord = function() {
    $("#notifications").hide();
    $scope.loading = true;

    var re = /\s*,\s*/;
    var specimenLabels = $scope.specimenLabels.trim().split(re);
    var tableData =[];

    SpecimensService.validateSpecimensLabel(specimenLabels).then( function(data) {
      $scope.loading = false;
      if(isValidSpecimenLabels(data)) {
        for(var i =0; i < specimenLabels.length; i++) {
          var tableRec = {key : {id : specimenLabels[i] , label : specimenLabels[i]}, records : []};
          tableData.push(tableRec);
        }

        $scope.dataEntryMode = true;
        $scope.editRecords = false;
        dataTable.setMode($scope.dataEntryMode == true ? 'edit' : 'view');
        renderDataTable(tableData);
      }
    });
  };

  var isValidSpecimenLabels = function(data) {
    var invalidSpecimens = [];
    $.each(data, function(key,val){
      if(val == false) {
        invalidSpecimens.push(key);
      }
    });

    if(invalidSpecimens.length > 0) {
      var errorMsg = "Specimen labels " + invalidSpecimens  + " does not exist or don't have access.";
      Utility.notify($("#notifications"), errorMsg, "error", false);
      return false;
    }
    return true;
  }

  $scope.saveDataTable = function() {
    $scope.loading = true;
    var formData = JSON.stringify(dataTable.getData());
    if(formData == undefined || formData == null) {
       $scope.loading = false;
       return;
    }
    SpecimensEventService.saveFormData($scope.selectedEvent.formId, JSON.stringify(formData)).then(function(data){
      $scope.loading = false;
      Utility.notify($("#notifications"), "Form Data Saved", "success", true);

      var obj = jQuery.parseJSON(data);
      var savedFormData = eval(obj);
      var tableData = populateTableData(savedFormData);

      $scope.dataEntryMode = false;
      $scope.editRecords = true;
      dataTable.setMode('view');
      renderDataTable(tableData);
    },
    function(data) {
      $scope.loading = false;
      Utility.notify($("#notifications"), "Form Data Save Failed.", "error", true);
    }
    );
  }

  $scope.editDataTable = function() {
    $scope.loading = true;
    var tableData = populateTableData(dataTable.getData());
    $scope.dataEntryMode = true;
    $scope.editRecords = false;
    dataTable.setMode('edit');
    renderDataTable(tableData);
    $scope.loading = false;
  }

  $scope.cancelDataTable = function() {
    dataTable.clear();
    $scope.dataEntryMode = false;
  }

  $scope.applyFirstToAll = function() {
    dataTable.copyFirstToAll();
  }

  var populateTableData = function(tableData) {
    var tblData = [];
    for(var i = 0; i< tableData.length; i++) {
      var specimenLabel = tableData[i].appData.id;
      var records = [];
      records.push(tableData[i]);
      var tableRec = {key : {id : specimenLabel , label : specimenLabel}, records : records };
      tblData.push(tableRec);
    }
    return tblData;
  }

  var renderDataTable = function(tableData) {
    dataTable.setData(tableData);
  }
}]);


specimenEvent.factory('SpecimensEventService',function($http){

    var apiUrl = '/openspecimen/rest/ng/';
    var baseUrl = apiUrl + 'specimen-events/';

    var successfn = function(result){
      return result.data;
    }

    return{
      saveFormData : function(formId, formDataJson) {
        var url = baseUrl + "/" + formId + "/data/";
        ret = $http.post(url, formDataJson).then(successfn);
        return ret;
      }
    }
});

specimenEvent.factory('SpecimensService', function($http) {

  var apiUrl = '/openspecimen/rest/ng/';
  var baseUrl = apiUrl + 'specimens/';

  var successfn = function(result){
    return result.data;
  }

  return {
    validateSpecimensLabel : function(labels) {
      var params = { specimenLabels : labels};
      var url = baseUrl + '/validate-labels';
      return Utility.get($http, url, successfn, params);
    }
  }
});