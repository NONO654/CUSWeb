
define('DS/ENOCommonSearchLocalActions/SearchLocalActionsForAllTypes',[ 'UWA/Class','UWA/Class/Debug',
                                                                       'UWA/Class/Events'

                                                                       ], function(UWAClass,
                                                                    		   UWADebug,
                                                                    		   UWAEvents
                                                                    		   ) {

	var ActionsHandler = UWAClass.singleton(UWAEvents, UWADebug, {

		executeAction: function (actions_data) {
		var newForm= document.createElement('form');
		document.body.appendChild(newForm);
		newForm.method = "POST"; 
		var input1   = document.createElement('input');
		input1.type="hidden";
		input1.name  ="objectId";
		input1.value=actions_data.object_id;
		var input2   = document.createElement('input');
		input2.type="hidden";
		input2.name  ="action";
		newForm.appendChild(input1);
		newForm.appendChild(input2);
		var today=new Date();
		var suffix=today.getTime();
		var winName = "_self";
		var formActionURl = "";
		if((actions_data.action_id== "action_AddToClipboard")){
			if(actions_data.object_ids.length > 1){
				formActionURl = "../common/emxCollectionsAddToProcess.jsp?mode=Clipboard&emxTableRowId="+actions_data.object_ids+"&addFrom3DSearch=true";
			}else{
				formActionURl = "../common/emxCollectionsAddToProcess.jsp?mode=Clipboard&objectId="+newForm.objectId.value+"&addFrom3DSearch=true";
			}
			newForm.action = formActionURl;
			newForm.target ="hiddenFrame";
			addSecureToken(newForm);
			newForm.submit();
			removeSecureToken(newForm);
		}else if(actions_data.action_id== "action_AddtoCollection"){
			if(actions_data.object_ids.length > 1){
				formActionURl = "../common/emxCollectionsAddToProcess.jsp?emxTableRowId="+actions_data.object_ids+"&suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common&widgetId=null&addFrom3DSearch=true";
			}else{
				formActionURl = "../common/emxCollectionsAddToProcess.jsp?objectId="+newForm.objectId.value+"&suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common&widgetId=null&addFrom3DSearch=true";
			}
			newForm.action = formActionURl;
			newForm.action.value="New";
			newForm.target = "listHidden";
			newForm.method = "post";
			addSecureToken(newForm);
			newForm.submit();
			removeSecureToken(newForm);
		}else if(actions_data.action_id== "action_DisplayDetails"){
			var selectedObjectID = newForm.objectId.value;
			var phyIds = new Array();
			phyIds.push(selectedObjectID);
				jQuery.ajax({
					   url: '../resources/bps/PhyIdToObjId/phyIds',
					   dataType: 'json',
					   async:false,
					   contentType:'application/json; charset=utf-8',
					   data:JSON.stringify({phyIds : phyIds}),
					   method:'POST',
					   success: function (data){
								selectedObjectID = data.ObjIds[0];
					   }
			     });
			var url = '../common/emxTree.jsp?objectId=' + selectedObjectID;
            emxUICore.link(url, "content");
			jQuery('#closeWidget').click();
		}	
	},


	});

	return ActionsHandler;

});
