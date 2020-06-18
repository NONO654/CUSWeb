<%--  
   emxLaunch3DPlayToggle   -  page to toggle the mode of 3D Play Viewer 
   Copyright (c) 1992-2018 Dassault Systemes.
--%>
<%@page import="com.matrixone.apps.engineering.EngineeringUtil"%>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>

<%
	String pref3DLive = PropertyUtil.getAdminProperty(context, "Person", context.getUser(), "preference_3DPlayToggle");        
	String accLanguage  = request.getHeader("Accept-Language");
	String strShow =  EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.3DPlay.Show3DLive", accLanguage);
	String strHide =  EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.3DPlay.Hide3DLive", accLanguage);
	
	String prefTxt = ("Show".equals(pref3DLive)) ? "Hide" : "Show";
					
	ContextUtil.startTransaction(context, true);
	PropertyUtil.setAdminProperty(context, "Person", context.getUser(), "preference_3DPlayToggle", prefTxt);
	ContextUtil.commitTransaction(context);
%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script>
var bomFrame = getTopWindow().findFrame(getTopWindow(),"ENCBOM");
//XSSOK
if("Hide" == "<%=prefTxt %>") {
		var tempListDisplayFrame = getTopWindow().findFrame(getTopWindow(),
				"portalDisplay");

		var channelName = "ENCPartEBOMChannel";
		tempListDisplayFrame = bomFrame ? bomFrame.parent
				: tempListDisplayFrame; // EBOM Parent will be portal display 
		if (typeof bomFrame == 'undefined' || bomFrame == null) {
			channelName = "ENCAffectedItemsChannel";
		}

		if (tempListDisplayFrame != null) {
			var tempContainer = null;
			var tempObjPortal = null;
			tempListDisplayFrame = tempListDisplayFrame ? tempListDisplayFrame
					: getTopWindow().findFrame(getTopWindow(), "portalDisplay");
			tempObjPortal = tempListDisplayFrame.objPortal;

			if(tempListDisplayFrame.PORTALNAME=="FAOProductBillofMaterial"){
				channelName = "FAOProductBillofMaterialChannel";
			}
			//TODO if tempObjPortal null needs to be handled
			if (tempObjPortal != null) {
				for (var i = 0; i < tempObjPortal.rows.length; i++) {
					for (var j = 0; j < tempObjPortal.rows[i].containers.length; j++) {
						if (tempObjPortal.rows[i].containers[j].channelName == channelName) {
							tempContainer = tempObjPortal.rows[i].containers[j];
						}
					}
				}
			}
			tempObjPortal.controller.doMaximise(tempContainer.element);
		}

	} else {
		
		if (typeof bomFrame != 'undefined' && bomFrame != null) {

			var sURL = getTopWindow().findFrame(getTopWindow(), "ENCBOM").parent.location.href;
			var sBOMRevisionFilter = window.parent.getTopWindow().document
					.getElementById('ENCBOMRevisionCustomFilter');

			if (sBOMRevisionFilter != null)
				var sBOMRevisionFilterVal = sBOMRevisionFilter.value;

			if (sURL.indexOf("ENCBOMRevisionCustomFilter=") != -1) {
				var splitString = sURL.split("&");
				var temp1 = "";
				var length = splitString.length;
				sURL = splitString[0];

				for (var i = 1; i < length; i++) {
					temp1 = splitString[i];

					if (temp1.indexOf("ENCBOMRevisionCustomFilter=") != -1) {
						temp1 = "ENCBOMRevisionCustomFilter="
								+ sBOMRevisionFilterVal;
					}

					sURL = sURL.concat("&", temp1);
				}
			} else {
				sURL += "&ENCBOMRevisionCustomFilter=" + sBOMRevisionFilterVal;
			}

			getTopWindow().findFrame(getTopWindow(), "ENCBOM").parent.location.href = sURL;

		} else {

			getTopWindow().findFrame(getTopWindow(),
					"ENCECOAffectedItemsTreeCategory").parent.location.href = getTopWindow()
					.findFrame(getTopWindow(),
							"ENCECOAffectedItemsTreeCategory").parent.location.href;
		}
	}
</script>
