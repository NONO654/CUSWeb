<%-- emxConstructNavigatorURL.jsp

Copyright  (c) 2006-2018 Dassault Systemes. All Rights Reserved.
This program contains proprietary and trade secret information of MatrixOne, Inc.
Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

static const char RCSID[] = $Id: emxConstructNavigatorURL.jsp.rca 1.2.2.2.1.4.2.1 Fri Nov  7 09:36:13 2008 ds-kvenkanna Experimental $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%!
	public String DecodeUrlParam(String param)
	{
    	if(param == null || param.length() == 0)
    	{
    	    return param;
    	}
    	
    	java.util.StringTokenizer st   = new java.util.StringTokenizer(param,".");
		StringBuffer decoded = new StringBuffer(16);
		while(st.hasMoreTokens())
		{
			String strToken = st.nextToken();
			char ch = (char)Integer.parseInt(strToken);
			decoded.append(ch);
		}
		return decoded.toString();
	}
%>
<%
try {
    String sType = emxGetParameter(request, "type");
    String sName = emxGetParameter(request, "name");
    sName		 = DecodeUrlParam(sName);
    String sRev = emxGetParameter(request, "rev");
    String sVault = emxGetParameter(request, "vault");
    String sFullClientSideURL = MailUtil.getBaseURL(context);
    if(sFullClientSideURL == null || "".equals(sFullClientSideURL)) {
        sFullClientSideURL = UINavigatorUtil.notificationURL(context, request, null, null, false);
    }
    String sObjectId = UINavigatorUtil.getObjectId(context, sType, sName, sRev, sVault);
    if("".equals(sObjectId)) {
        sObjectId = "1.2";//pass dummy id
    }
    out.println(sFullClientSideURL + "?objectId=" + sObjectId + "&mode=tree");
}catch(Exception ex) {
    if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        emxNavErrorObject.addMessage(ex.toString().trim());
}
%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
