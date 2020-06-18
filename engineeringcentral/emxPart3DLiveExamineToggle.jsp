<%--  
   emxPart3DLiveExamineToggle.jsp   -  page to toggle the mode of 3DLive Examine Viewer 
   Copyright (c) 1992-2018 Dassault Systemes.
--%>
<%@page import="com.matrixone.apps.engineering.EngineeringUtil"%>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>

<%
	String pref3DLive = PropertyUtil.getAdminProperty(context, "Person", context.getUser(), "preference_3DLiveExamineToggle");        
	String accLanguage  = request.getHeader("Accept-Language");
	String strShow =  EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.3DLiveExamine.Show3DLive", accLanguage);
	String strHide =  EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.3DLiveExamine.Hide3DLive", accLanguage);
	
	String prefTxt = ("Show".equals(pref3DLive) || "".equals(pref3DLive)) ? "Hide" : "Show";
					
	ContextUtil.startTransaction(context, true);
	PropertyUtil.setAdminProperty(context, "Person", context.getUser(), "preference_3DLiveExamineToggle", prefTxt);
	ContextUtil.commitTransaction(context);
%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script>
	
	
	var bomFrame = getTopWindow().findFrame(getTopWindow(),"ENCPartProperty");
	var channelName = "ENCPartPropertyChannel1";

	//XSSOK
	if("Hide" == "<%=prefTxt %>") {
		
		var tempListDisplayFrame = getTopWindow().findFrame(getTopWindow(),"portalDisplay");
		
		if(tempListDisplayFrame != null) {
			var tempContainer = null;
		    var tempObjPortal = null;
		    var tempListDisplayFrame = getTopWindow().findFrame(getTopWindow(),"portalDisplay");
		    tempObjPortal  = tempListDisplayFrame.objPortal;
		    
		    if(tempObjPortal != null) {
			    for(var i = 0;i< tempObjPortal.rows.length;i++) {
			    	for(var j = 0;j< tempObjPortal.rows[i].containers.length;j++) {
			    		if(tempObjPortal.rows[i].containers[j].channelName == channelName) {
			    			tempContainer = tempObjPortal.rows[i].containers[j];
			    		}
			    	}
			    }
		    }
			tempObjPortal.controller.doMaximise(tempContainer.element);
		}
	}
	else if(typeof bomFrame != 'undefined' && bomFrame != null)
		bomFrame.parent.location.href = bomFrame.parent.location.href;
	
</script>
