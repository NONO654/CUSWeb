define('DS/SMAExeCOSAdmin/Forms/ConfirmDialog',
    ['UWA/Core',
	 'DS/UIKIT/Form',
     'DS/UIKIT/Modal',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminWebServiceUtils',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminInfo',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminUtils',
	 'i18n!DS/SMAExeCOSAdmin/assets/nls/SMAExeCOSAdmin'
    ],

    /*
     * function to create modal dialog with a confirm dropdown
     * if we want to abort work items or wait for them to finish
     * we do this for either stop or restarts since both actions will
     * shut down the station.
     */
    function ( UWA,  UIForm, UIModal, WSUtils, COSInfo, COSUtils, NLS) {

         'use strict';
         var modal = {};
         var dlgForm={};
         var newDialog = {};


         var waitMsg = NLS.get('restartWait');
         var abortMsg = NLS.get('restartAbort');

         // define the form fields
         var myForm = new UIForm({
        	 className: 'vertical',
        	 fields: [{
        		 type: 'select',
        		 label: ' ',
        		 name: 'wait',
        		 options: [
        		           { label: waitMsg, value: '1' },
        		           { label: abortMsg, value: '2' }
        		           ]
        	 }],
        	 buttons: [{
        		 type: 'submit',
        		 value: 'Submit'
        	 }],
        	 events: {
        		 onSubmit:  function () {
        			 newDialog.updateStation(this);
        		 }
        	 }
         });


 		 // get the data from the model passed in and update the form's fields
         newDialog = {

                 // function to handle OK processing for web services based on action
                 // for single stop just update the model status and node badge
                 // for stop list of stations need to update all the models and badges
                 // also for stop list need to handle stations that were successfully stopped
                 // and display station that weren't
        		 okFunc : function (data) {
                	 var message = data.split('problem');
                	 var good = message[0];
                	 // if stations could not be resumed...display error
                	 if (message.length > 1) {
                		 COSUtils.displayError(data, true);
                	 }
        			 if ('stop' === dlgForm.action) {
        				 COSUtils.setBadgesOnNode(dlgForm.model.get('id'), 'Shutdown');
        				 dlgForm.model.set('@status', 'Shutdown', {silent:true});
        				 dlgForm.model.set('status', 'Shutdown');
        			 }
        			 else if ('stopList' === dlgForm.action) {
        	        	 var view = COSInfo.getBones().getViewAt(1);
        	        	 for (var i = 0 ; i < view.collection._models.length; i++) {
        	        		 var model = view.collection._models[i];
        	        		 if (good.indexOf(model.get('@name')) >=0) {
        	        			 // if station suspended update tree and list model status
        	        			 model.set('@status', 'Shutdown', {silent:true});
        	        			 model.set('status', 'Shutdown');
        	        			 var modelID = model.get('@name') + '@@' + model.get('serverName');
        	        			 var treeModel = COSUtils.findModel(0, modelID);
        	        			 if (treeModel) {
        	        				 treeModel.set('@status', 'Shutdown', {silent:true});
        	        				 treeModel.set('status', 'Shutdown');
        	        			 }
        	        			 COSUtils.setBadgesOnNode(modelID, 'Shutdown');
        	        		 }
        	        	 }
        			 }
        			 // need to fix selection since check-box and check-mark is removed
        			 // when updating the station status
        			 if ('stopList' === dlgForm.action || 'startList' === dlgForm.action) {
        				 COSUtils.fixSelection();
        			 }
                },

                 // function that gets the form data and will either call the webservice once or twice
                 // based on the wait value 1 means wait 2 means abort the workitem so a second call is made
                 // based on the action either the restart or shutdown webservice will be called

                 // if we are calling the stop function then need to reset the badge on success.
        		 updateStation : function (form) {
                	 dlgForm = form;
                	 // get the form data
                	 var formVal = form.getValues();
                	 var url = form.model.get('fullCosUrl');
                	 var server = form.model.get('serverName');
                	 var stationName = form.model._attributes['@name'];
                	 var functionToCall = WSUtils.startStation;
                	 if ('stopList' === form.action) {
                		 stationName = dlgForm.url;
                		 functionToCall = WSUtils.shutdownStations;
                	 }
                	 else if ('stop' === form.action) {
                		 functionToCall = WSUtils.shutdownStation;
                	 }
                	 else if ('startList' === form.action) {
                		 stationName = dlgForm.url;
                		 functionToCall = WSUtils.startStations;
                	 }
                	 if (formVal.wait === '2') {
                		 functionToCall(
            				 url,
            				 server,
            				 stationName,
            				 function() {
            					 functionToCall(
        							 url,
        							 server,
        							 stationName, newDialog.okFunc);
            				 });
                	 }
                	 else {
                		 functionToCall(
                				 url,
                				 server,
                				 stationName, newDialog.okFunc);
                	 }
        	         modal.hide();
                 },
        		// function to create the modal dialog from the form and show it
        		showDialog : function (model, header, url, action) {
                    myForm.model = model;
                    myForm.url = url;
                    myForm.action = action;
                    modal = new UIModal({
                        closable : true,
                        header : header,
                        body: myForm
                    });

                    modal.inject(COSInfo.getContainer());
                    modal.show();
        			return modal;
        		}
        };
        return newDialog;
});


