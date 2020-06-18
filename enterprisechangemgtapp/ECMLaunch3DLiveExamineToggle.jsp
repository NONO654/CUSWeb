<%--  
   emxLaunch3DLiveExamineToggle   -  page to toggle the mode of 3DLive Examine Viewer 
   Copyright (c) 1992-2018 Dassault Systemes.
--%>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%
	String pref3DLive = PropertyUtil.getAdminProperty(context, "Person", context.getUser(), "preference_3DLiveExamineToggle");        
	String accLanguage  = request.getHeader("Accept-Language");
	String stringResFileId = "emxEnterpriseChangeMgtStringResource";
	String strShow =  EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.3DLiveExamine.Show3DLive");
	String strHide =  EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.3DLiveExamine.Hide3DLive");
	
	String prefTxt = ("Show".equals(pref3DLive) || "".equals(pref3DLive)) ? "Hide" : "Show";
					
	ContextUtil.startTransaction(context, true);
	PropertyUtil.setAdminProperty(context, "Person", context.getUser(), "preference_3DLiveExamineToggle", prefTxt);
	ContextUtil.commitTransaction(context);
%>

<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script>
//XSSOK
if("Hide" == "<%=prefTxt %>") {
	var tempListDisplayFrame = getTopWindow().findFrame(getTopWindow(),"portalDisplay");
	var channelName = "ECMChangeAffectedChannel";
	var channelexists = getTopWindow().findFrame(getTopWindow(),"ECM3DAffectedItemsCOCR");
	if(channelexists == null)
		channelName = "ECMCAAffectedItemsChannel";
	
	if(tempListDisplayFrame != null) {
		var tempContainer = null;
	    var tempObjPortal = null;
	    var tempListDisplayFrame = getTopWindow().findFrame(getTopWindow(),"portalDisplay");
	    tempObjPortal  = tempListDisplayFrame.objPortal;
	    
		//TODO if tempObjPortal null needs to be handled
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
// 	getTopWindow().findFrame(getTopWindow(),"portalDisplay").parent.location.href = getTopWindow().findFrame(getTopWindow(),"portalDisplay").parent.location.href;
} else {
	getTopWindow().findFrame(getTopWindow(),"portalDisplay").parent.location.href = getTopWindow().findFrame(getTopWindow(),"portalDisplay").parent.location.href;
	
}
	
</script>
