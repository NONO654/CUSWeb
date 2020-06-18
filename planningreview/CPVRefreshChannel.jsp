<%--  emxPortalChannelRefresh.jsp
   Copyright (c) 1992-2017 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRefreshChannel.jsp.rca 1.1 Fri Nov 14 07:48:40 2008 ds-arajendiran Experimental $
--%>

<%-- 
 ** history:
 *  @quickreview spl7 gh4 2017/07/26: IR-533599 : Fixed issue of XSS encoding feature
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%
	String maximumTabLength  = EnoviaResourceBundle.getProperty(context, "emxFramework.PowerView.Channel.Label.MaximumLength");
	int tabLength = 17;
	if (maximumTabLength != null && maximumTabLength.trim().length() > 0)
	{
	        try {
	                tabLength = Integer.parseInt(maximumTabLength);
	        } catch(NumberFormatException e) {
	                tabLength = 17;
	        }
	}
    //String portal = emxGetParameter(request, "portal");
    String portal = "CPVMBOMPortal";
	String channel = emxGetParameter(request, "channel");
	String objectId = emxGetParameter(request, "objectId");
	String isIndentedTable = emxGetParameter(request, "isIndentedTable"); 
	if(isIndentedTable == null){
	    isIndentedTable = "false";
	}
	StringBuffer outStr = new StringBuffer();
	try{
    MapList rowMapList = UIPortal.getPortal(context,portal, UINavigatorUtil.getRequestParameterMap(request),
            PersonUtil.getAssignments(context), request.getHeader("Accept-Language"));
    MapList tabList = new MapList();
    for(int i = 0; i < rowMapList.size(); i++){
        HashMap rowMap = (HashMap)rowMapList.get(i);
        MapList channelMapList = UIPortal.getChannels(rowMap);
        for(int j = 0; j < channelMapList.size(); j++){
            HashMap channelMap = (HashMap)channelMapList.get(j);
            String channelName = (String)channelMap.get("name");
            if(channel != null && channel.equals(channelName)){
                tabList = UIPortal.getChannelTabs(channelMap);
            }
        }
    }
    out.clear();
    %>
    <script language="javascript" src="../common/scripts/emxUICore.js"></script>
    <script>
      
    var tempContainer = null;
    var tempObjPortal = null;
    var isIndentedTable = "<%=XSSUtil.encodeForJavaScript(context, isIndentedTable)%>"; 
    var channel = "<%=XSSUtil.encodeForJavaScript(context, channel)%>";
    //var tempListDisplayFrame = getTopWindow().openerFindFrame(getTopWindow(),"divPvChannel-1-2"); 
    //var topWindow = window.top;
    
    var tempListDisplayFrame=getTopWindow().findFrame(getTopWindow(),"CPVContextualAttrCmd");
    tempListDisplayFrame = tempListDisplayFrame.parent;
    tempObjPortal  = tempListDisplayFrame.objPortal;
    for(var i = 0;i< tempObjPortal.rows.length;i++){
    	for(var j = 0;j< tempObjPortal.rows[i].containers.length;j++){
    		if(tempObjPortal.rows[i].containers[j].channelName == channel){
    			tempContainer = tempObjPortal.rows[i].containers[j]
    		}
    	}
    }
    
    tempContainer.channelName=channel;
    var tempLastTab = tempContainer.tabset.lastTab;
    tempContainer.tabset.tabs = new Array();
 
	tempContainer.tabset.menu = new tempListDisplayFrame.emxUIPortalTabMenu(tempContainer.tabset);
	
    tempContainer.channels = new Array();
	tempContainer.element.innerHTML = "";
	var tempObjChannel = null;
	<%
    for(int k = 0; k< tabList.size(); k++){
        HashMap channelTabMap = (HashMap)tabList.get(k);
        StringBuffer href = new StringBuffer(100);
        href.append((String) UIPortal.getTabHRef(channelTabMap));
        String fullText = UIPortal.getTabLabel(channelTabMap);
        String tabName  = UIPortal.getName((HashMap)channelTabMap);
        String displayText = fullText;
        if(fullText.length() > tabLength) {
            displayText = fullText.substring(0, tabLength) + "...";
        }
        %>
     
		tempObjChannel = tempContainer.addChannel(new tempListDisplayFrame.emxUIComplexChannel("<%=XSSUtil.encodeForJavaScript(context,displayText)%>","<%=XSSUtil.encodeForJavaScript(context,fullText)%>","<%=XSSUtil.encodeForJavaScript(context,href.toString())%>","","<%=XSSUtil.encodeForJavaScript(context,tabName)%>"));
		
       	if(tempObjChannel != null){
       		tempObjChannel.init();
       	}
	<%
    }
	%>
	tempContainer.tabset.lastTab = tempLastTab;
    tempContainer.buildDOM();
	// IR-079252V6R2012
	tempObjPortal.controller.sensitizeSizingControls(tempContainer.element);
    </script>
    <%
	//out.clear();
	}catch(Exception ex){
	    if (ex.toString() != null && (ex.toString().trim()).length() > 0){
	        emxNavErrorObject.addMessage(ex.toString().trim());
	    %><%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%><%
	    }
	}
%>
