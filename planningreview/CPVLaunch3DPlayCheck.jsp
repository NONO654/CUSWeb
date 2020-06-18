<%--  CPVLaunch3DPlayCheck.jsp
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%-- 
 ** history:
 *  @quickreview spl7 gh4 2017/07/26: IR-533599 : Fixed issue of XSS encoding feature
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<emxUtil:localize id="i18nId" bundle="emxComponentsStringResource" locale='<%= XSSUtil.encodeForHTML(context, request.getHeader("Accept-Language")) %>' />

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>

<html>
	<script>
	<%
		boolean isLaunch3dPlay =true;
		String strObjectId = (String)emxGetParameter(request, "objectId");   
		String timeStamp   = (String)emxGetParameter(request,"timeStamp");
		//Cross Highlight Changes Start: Added for Compare channel
		String objectId1 = emxGetParameter(request, "objectId1");
		String objectId2 = emxGetParameter(request, "objectId2");
		String compare3D = emxGetParameter(request, "3DCompare");
		//Cross Highlight Changes Start: Added for Compare channel
		
		if(isLaunch3dPlay) 
		{
			StringBuffer contentURL = new StringBuffer("CPVLaunch3DPlay.jsp?");
			
			//Cross Highlight Changes Start: Added for Compare channel
			if(emxGetParameter(request, "3DCompare") != null) {
			    contentURL = new StringBuffer("CPVLaunchCompare3DPlay.jsp?");
			    contentURL.append("objectId1=").append(XSSUtil.encodeForURL(context, objectId1)).append("&objectId2=").append(XSSUtil.encodeForURL(context, objectId2)).append("&");
			}
			//Cross Highlight Changes End: Added for Compare channel
			
			contentURL.append("timeStamp=");
			contentURL.append(XSSUtil.encodeForURL(context, timeStamp));
			contentURL.append("&");
			contentURL.append("objectId=");
			contentURL.append(XSSUtil.encodeForURL(context, strObjectId));
			contentURL.append("&");
			contentURL.append(XSSUtil.encodeURLwithParsing(context, request.getQueryString()));
			
			//Cross Highlight Changes Start: Added for Powerview Channel and Compare channel            
			String crossHighlight = (String)emxGetParameter(request, "crossHighlight");            
			if("true".equalsIgnoreCase(crossHighlight) || "true".equalsIgnoreCase(compare3D)) {
			%>
				//encoding in the url is retained.Need to remove after checking
				document.location.href = "<%=XSSUtil.encodeForURL(context, contentURL.toString())%>";
			<%
			}
			else {
			%>   //To support regular functionality of popup
				//encoding in the url is retained.Need to remove after checking
				showModalDialog("<%=XSSUtil.encodeForURL(context, contentURL.toString())%>", 600, 600, true);
			<%
		    }
		}
	    
	%>
	</script>
</html>
