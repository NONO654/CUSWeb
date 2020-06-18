define("DS/ENOPartMgt/commands/CollaborateUPSToEBOMCmd/CollaborateToEBOMCmdBase",
[
 'UWA/Element',
 'DS/UIKIT/Modal',
 'DS/Controls/Button',
 'DS/Controls/ComboBox',
 'DS/PADUtils/PADContext',
 'DS/Controls/SpinBox',
 'DS/Controls/TooltipModel',
 'DS/Notifications/NotificationsManagerUXMessages',
 'DS/Notifications/NotificationsManagerViewOnScreen',
 'DS/PlatformAPI/PlatformAPI',
 'DS/WAFData/WAFData',
 'i18n!DS/ENOPartMgt/assets/nls/ENOPartMgtNLS'
], function(Element, Modal, WUXButton, WUXComboBox, PADContext, WUXSpinBox, WUXTooltipModel, NotificationsManagerUXMessages, NotificationsManagerViewOnScreen, PlatformAPI, WAFData, NLS){
	
    'use strict';
    
    var strSpecify="specify";
    var levelLabel = ["0", "1", NLS.All, NLS.specify];
    var levelValues = ["0", "1", "ALL", strSpecify];    

    var levelList = [];
    for (var index = 0; index < levelLabel.length; index++) {
    	levelList[index] = { labelItem: levelLabel[index], valueItem: levelValues[index] };
    	}

    NotificationsManagerViewOnScreen.setNotificationManager(NotificationsManagerUXMessages);
    
    var myComboBox=new WUXComboBox({
	      elementsList: levelList,
	      selectedIndex: 2,
	      enableSearchFlag: false,
	      actionOnClickFlag: false
	});
	
	
	var spinBoxLevel = new WUXSpinBox({
	    minValue: 0,
	    stepValue: 1,
	    disabled: true
	});
	
	//EventListner for change of Combobox which enables Spinbox when Specify option is selected
	myComboBox.addEventListener('change', function (){
		if(strSpecify == myComboBox.value) {
			spinBoxLevel.disabled = false;
		}
		else {
			spinBoxLevel.disabled = true;
		}

	});
	
	//EventListner for validating the level manually specified by user, which throws warning when fraction is entered
	spinBoxLevel.addEventListener('endEdit', function (){
		if(spinBoxLevel.value % 1 !=0) {
			var warningOptions = {
					    level: 'warning',
					    message: NLS.fractionWarning,
				  };
			NotificationsManagerUXMessages.addNotif(warningOptions);
			spinBoxLevel.value = parseInt(spinBoxLevel.value);
		}
	});
	
      var CollaborateToEBOMCmdBase ={
        execute: function () {
        	var that = this;
        	var newModal = new Modal({
        		className: 'fancy',
        		closable: true,
        		animate: true,
        		header: new UWA.Element("h4", {
        					text: NLS.modalHeader
        				}),
        		body:   that.getContent(),                    
                footer: [new WUXButton({
        	        		label: NLS.labelOK,
        	        		emphasize: 'primary',
        	        		onClick: function () {

        	            		var myContext = PADContext.get();
        	            		var selected_Nodes = myContext.getSelectedNodes(); 
        	            		var levelInfo = spinBoxLevel.disabled == false ? spinBoxLevel.value : myComboBox.value;
        	            		        	            		
        	                    var sCsrfServiceURL = '/resources/v1/application/E6WFoundation/CSRF';
        	                    var sUPStoEBOMCollabServiceURL = '/resources/v2/partmodeler/ebomcollaboration?level='+levelInfo;

        	            		var my3DSpaceUrl = PlatformAPI.getApplicationConfiguration('app.urls.myapps');
        	                    
        	            		var servicePath = my3DSpaceUrl+sUPStoEBOMCollabServiceURL;
        	            		
        	            		var securityContext = myContext.getSecurityContext();
        	            		
        	            		var collaborateOptions = {
        								'method': 'POST',
        								'type' : 'json',
        								'headers': {
        									'Accept': 'application/json, application/xml',
        									'Content-Type': 'application/json',
        									'SecurityContext': securityContext.SecurityContext
        								}
        							};
        						
        	            		var csrfOptions = {
        								'method': 'GET',
        								'headers': {
        									'Accept': 'application/json, application/xml',
        									'Content-Type': 'application/json'
        								}
        							};

                	    		
                	    		var data=[];
                	    		for(var i=0;i<selected_Nodes.length;i++){
            	                	data[i]={"id":selected_Nodes[i].options.resourceid}
            	                }
                	    		
                	    		var payload = {"data": data}

								csrfOptions.url = my3DSpaceUrl + sCsrfServiceURL;
								
								csrfOptions.onComplete = function (response, headers) {
									var res = JSON.parse(response);
									payload.csrf = res.csrf;
	                	    		var jsonData = JSON.stringify(payload);  

	                	    		collaborateOptions.data = jsonData;
	                	    		collaborateOptions.url = servicePath;
									
									
	                	    		collaborateOptions.onComplete = function (response, headers) {
										//alert("completed");
									},
									collaborateOptions.onFailure = function (error, response, headers) {
										var joPartDeleteResponse = JSON.parse(response);
										//alert("failed");
									}
									
									WAFData.authenticatedRequest(collaborateOptions.url, collaborateOptions);

								}
								WAFData.authenticatedRequest(csrfOptions.url, csrfOptions);

        	        			newModal.hide();
        	        		}
        	    		}),
        	    		new WUXButton({
        	    			label: NLS.labelCancel,
        	    			emphasize: 'secondary',
        	    			onClick: function () {
        	    				newModal.hide();
        	    			}
        	    		})]
        	}).inject(widget.body);
        	
        	//newModal.setBody(this.getContent());
        	newModal.show();
        	//that.end();
        	
        },
		 
        getContent: function () {

        	return [new UWA.Element("h5", {
						text: NLS.expandDepth
					}),
                    myComboBox,spinBoxLevel,
                    new UWA.Element("h5", {
    					text: NLS.modalMsg
    				})]
        }
        
    };

    return CollaborateToEBOMCmdBase;
});
