<%-- emxEngrBOMAddExistingPartsPreProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@ include file="../emxUIFramesetUtil.inc"%>
<%@ include file="emxEngrFramesetUtil.inc"%>
<%
	String objectId = emxGetParameter(request, "objectId");
	String selPartObjectId = emxGetParameter(request, "selPartObjectId");
	if("".equals(selPartObjectId) || selPartObjectId == null)
	{
	 selPartObjectId = objectId;
	}
	String selPartRelId = emxGetParameter(request, "selPartRelId");
	String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
	String selectedId="";
	String[] selectedParts = new String[selectedItems.length];
	for (int i=0; i < selectedItems.length ;i++)
	{
	    java.util.StringTokenizer strTokens = new java.util.StringTokenizer(selectedItems[i],"|");
    	selectedId = strTokens.nextToken();
    	selectedParts[i] = selectedId.trim();
	    
	}
	
	 // Specify URL to come in middle of frameset
	  StringBuffer contentURL = new StringBuffer("emxEngrBOMAddExistingPartsFS.jsp");
	
	  // add these parameters to each content URL, and any others the App needs
	  contentURL.append("?suiteKey=");
	  contentURL.append(emxGetParameter(request, "suiteKey"));
	  
	  contentURL.append("&jsTreeID=");
	  contentURL.append(emxGetParameter(request, "jsTreeID"));
	
	  contentURL.append("&uiType=");
	  contentURL.append("AVLReportAddmanualPart");
	 
	  contentURL.append("&objectId=");
	  contentURL.append(emxGetParameter(request, "objectId"));
	  
	  contentURL.append("&isApplyTrue=");
	  contentURL.append(emxGetParameter(request, "false"));
	  
	  contentURL.append("&selectMode=");
	  contentURL.append(emxGetParameter(request, "fromAdvSearch"));
	  
	  
	java.util.Enumeration names =emxGetParameterNames(request);
	while(names.hasMoreElements())
	{
	    String name = (String) names.nextElement();
	    if(name.equals("emxTableRowId"))
	    {
	        session.setAttribute("checkBox", selectedParts);
	    } 
	}
%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">
	var contentFrame   = findFrame(getTopWindow(),"listHidden");
	//XSSOK
	contentFrame.parent.showModalDialog("<%=contentURL%>", 575, 575);
</script>

