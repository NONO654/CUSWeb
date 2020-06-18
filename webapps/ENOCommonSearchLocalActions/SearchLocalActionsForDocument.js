
define('DS/ENOCommonSearchLocalActions/SearchLocalActionsForDocument',[ 'UWA/Class','UWA/Class/Debug',
                                                                       'UWA/Class/Events'

                                                                       ], function(UWAClass,
                                                                    		   UWADebug,
                                                                    		   UWAEvents
                                                                    		   ) {

	var ActionsHandler = UWAClass.singleton(UWAEvents, UWADebug, {

		executeAction: function (actions_data) {
			var that = this;
			actions_data.actionsHelper.getServiceURL({ 'onComplete' : function(url){
				var newForm= document.createElement('form');
				document.body.appendChild(newForm);
				var objectIdinput = that.createFormElements('input','objectId','objectId','hidden');
				newForm.appendChild(objectIdinput);
				var actionInput = that.createFormElements('input','action','action','hidden');
				newForm.appendChild(actionInput);
				newForm.objectId.value=actions_data.object_id;
				newForm.action = url + "/components/emxCommonDocumentPreCheckout.jsp";
				var today=new Date();
				var suffix=today.getTime();
				var winName = "_self";
				
				if(document.getElementById("hiddenFrameDiv") == null){
					var hiddenFrameDiv = that.createFormElements('div','hiddenFrameDiv','hiddenFrameDiv','hidden');
					document.body.appendChild(hiddenFrameDiv);
					var hiddeniFrame = that.createFormElements('iframe','hiddeniFrame','hiddeniFrame','hidden');
					hiddeniFrame.setAttribute('style', 'display:none');
					document.getElementById("hiddenFrameDiv").appendChild(hiddeniFrame);
				}

				if((actions_data.action_id== "documentAction_Download")){
					newForm.action.value="download";
							newForm.target ="hiddeniFrame";
					newForm.submit();
				}else{
					newForm.action.value="view";
					var strFeatures = "width=730,height=450";
					winName="CheckoutWin"+suffix;
					win = window.open('', winName, strFeatures);
					newForm.target =winName;
					newForm.submit();
				}
				document.body.removeChild(newForm);
			}, 'id' : actions_data.object_id});
				
	},

		createFormElements: function(elementType,name,id,type){
			var newElement = document.createElement(elementType);
			newElement.setAttribute('id', id);
			newElement.setAttribute('name', name);
			newElement.setAttribute('type', type);
			return newElement;
		},
	});

	return ActionsHandler;

});
