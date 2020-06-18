define('DS/SMAExeCOSAdmin/Forms/AddStationsDialog',
    ['UWA/Core',
	 'DS/UIKIT/Form',
     'DS/UIKIT/Modal',
     'DS/SMAExeCOSAdmin/Forms/COSFormUtils',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminWebServiceUtils',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminInfo',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminUtils',
	 'i18n!DS/SMAExeCOSAdmin/assets/nls/SMAExeCOSAdmin'
    ],

    /*
     * function to process adding stations to group or removing station from group
     */
    function ( UWA,  UIForm, UIModal, FormUtils, WSUtils, COSInfo, COSUtils, NLS) {

         'use strict';
         var modal = null;

         // handles adding stations to group or removing stations from group
         var AddStationsDialog = {

                 // function to handle OK processing for updateStations web service
                 // if adding/changing group ...
                 // updates server station collection model with groups attributes
                 // otherwise just set group to empty string
                 // looks up tree collection model
                 // if tree has been expanded... will update tree station model and re-parent tree node
                 // if doing remove from group's station list need to remove selected station models
                 // from the group's collection
                 okFunc: function (data, form) {
            		 var groupId = '';

            		 // if we are doing the remove command from a group's station list...
            		 // the server name will be in the form groupName@@serverName so adjust server name
            		 var serverToUse = COSUtils.fixServer(form.serverName);

            		 // assume new parent will be the server node unless adding/changing group
            		 var newPar =  COSUtils.findNode(serverToUse);
              	     var groupMod = null;

              	     // the view at one will either be the server's station list or the group's station list
              	     var view = COSInfo.getBones().getViewAt(1);
                	 if ('add' === form.action)  {
        	    		groupId = form.selectedGroup +'@@' + serverToUse;
        	    		newPar =  COSUtils.findNode(groupId);
        	      	    groupMod = COSUtils.findModel(1, form.selectedGroup);
                	 }
              	     for (var i = 0; i < form.models.length; i++) {

              	    	// update the selected model's group attribute
              	    	// will be blanked out if doing remove
               	    	var model =form.models[i];
               	    	model._attributes['@group'] =  form.selectedGroup;
               	    	model._attributes.group =  form.selectedGroup;
                  		// if we are adding/changing group need to update the model's attributes
               	    	// from the group's model
                  		if (groupMod) {
                  			COSUtils.updateModelAttributesFromGroup(model._attributes, groupMod);
                  		}
                  		model.dispatchEvent('onChange');

                  		// if tree has been expanded... update tree model data
                  		// and re-parent
               	    	var treeModel = COSUtils.findModel(0, model.id+'@@' + serverToUse);
               	    	if (treeModel) {
        	          		treeModel._attributes['@group'] =  form.selectedGroup;
        	          		treeModel._attributes.group =  form.selectedGroup;
        	          		// if we are adding/changing group
        	          		if (groupMod) {
        	          			COSUtils.updateModelAttributesFromGroup(treeModel._attributes, groupMod);
        	          		}
        	       	    	treeModel.dispatchEvent('onChange');
        	          		var myNode = COSUtils.findNode(model.id +'@@' + serverToUse);
        	        		var parNode = myNode.getParent();
        	        		// re-parent the station
        	        		parNode.removeChild(myNode);
        	        		newPar.addChild(myNode);
               	    	}

               	    	// if we are removing stations from a group from the group's station facet
               	    	// need to remove the model from the collection since no longer in the group
               	    	if (serverToUse !== form.serverName) {
               	    		view.collection.remove(model);
               	    	}
              	     }
              	     // need to fix selection since check-box and check-mark is removed
              	     // when updating group value for the station
              	     COSUtils.fixSelection();
                 },
        		 // get station XML with new group info and call JS API to update stations
        		 processStation: function (form) {
              	     var that = this;
              	     var errMsg='';

              	     // if adding to group get it
              	     if ('add' === form.action) {
	                	 var formVal = form.getValues();

	                	 // get the selected group from the form
	                	 form.selectedGroup = formVal.selectedGroup;
              	     }
              	     else {
              	    	form.selectedGroup = '';
              	     }
                	 that.dlgForm = form;
               	     var StationXml = '<?xml version="1.0" encoding="utf-8"?>' + '<StationList>';
               	     for (var i = 0; i < that.dlgForm.models.length; i++) {
               	    	 var model = that.dlgForm.models[i];

               	    	 // add check to see if adding station to the same group and display msg if yes
               	    	 // IR-545528
               	    	 if (form.selectedGroup === model.get('@group') && form.selectedGroup.length > 0) {
               	    		errMsg = model.get('id') + NLS.get('alreadyInGroup');
               	    	 }

               	    	 // get station xml with the new group
                         var oneStationXml = COSUtils.getStationXml(model, '', form.selectedGroup, form.action);
                         StationXml = StationXml + oneStationXml;
               	     }
               	     StationXml = StationXml + '</StationList>';

               	     if (errMsg.length === 0) {

               	    	 // call the JS API to update the stations
               	    	 WSUtils.updateStation(that.dlgForm.url, that.dlgForm.serverName, StationXml,
               	    			 function(data){
               	    		 COSUtils.displayInfo('DATA: ' + data, false);
               	    		 that.okFunc(data, that.dlgForm);
               	    	 });
               	    	 if (modal) {
               	    		 modal.hide();
               	    	 }
               	     }
               	     else {
               	    	 if (modal) {
               	    		 modal.hide();
               	    	 }
               	    	 COSUtils.displayError(errMsg, true);
               	     }
                 },

                 // get a from with a drop down containing the groups
                 // save passed in data on the form
         		updateFields : function (models, serverName, url, action) {
                    // define the form fields
        	         var myForm = {};
        	         if ('add' === action) {
             	         myForm = new UIForm({
	         	        	 className: 'vertical',
	         	        	 fields: [{
	         	        		 type: 'select',
	         	        		 label: ' ',
	         	        		 name: 'selectedGroup',
	         	        		 options:FormUtils.getGroupSelectArray(models[0], false)
	         	        	 }],
	         	        	 buttons: [{
	         	        		 type: 'submit',
	         	        		 value: 'Submit'
	         	        	 }],
	         	        	 events: {
	         	        		 onSubmit:  function () {
	         	        			AddStationsDialog.processStation(this);
	         	        		 }
	         	        	 }
	         	         });
        	         }
                     myForm.models = models;
                     myForm.action = action;
                     myForm.url = url;
                     myForm.serverName = serverName;

                    return myForm;
        		},
        		// function to create the modal dialog from the form and show it
        		showDialog : function (myForm) {
                    modal = new UIModal({
                        closable : true,
                        header : NLS.get('group'),
                        body: myForm
                    });

                    modal.inject(COSInfo.getContainer());
                    modal.show();
         		}
        };
        return AddStationsDialog;
});


