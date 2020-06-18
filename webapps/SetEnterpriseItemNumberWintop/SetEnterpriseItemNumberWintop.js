define('DS/SetEnterpriseItemNumberWintop/SetPartNumberWintop', [
  'DS/ENOXEngineerCommonUtils/XENWebInWinHelper',
  'DS/EngineeringItemCmd/SetPartNumberCmd/SetPartCmd'
], function(XENWebInWinHelper, SetPartCmd) {

    'use strict';

    

    var  SetPartNumberWintop = {
      onLoad: function(){
        XENWebInWinHelper.initializeSocket();
        XENWebInWinHelper.getSocket().addListener('onDispatchToWin', function (parameters){
          var name = parameters.notif_name;
         var parameters_string = UWA.is(parameters.notif_parameters, 'string') ? parameters.notif_parameters : JSON.stringify(parameters.notif_parameters);
         var message = parameters_string;
         dscef.sendString (name + '=' + message,{
              recordable: true,
              captureAll: true
          });              	
       });  

        var selectedNodes = window["selectedItems"].map(function(item){
         return  {
            options:{
              padgrid:{
                'ds6w:globalType':'ds6w:Part'
              },
              grid:{
                
              }
            },
            getLabel: function(){
              return item.title;
            },
            getID: function(){
              return item.objectId;
            }
          }
        })

        var setPartNumber = new SetPartCmd({
          context:{
            getSelectedNodes: function(){
              return selectedNodes;
            }
          }
        });
        widget.body.empty();
        setPartNumber.execute();
      },
      onRefresh: function(){
        console.log('onRefresh ...');
      }
    };

    return SetPartNumberWintop;

});
