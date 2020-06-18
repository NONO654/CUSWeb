<%-- emxCommonDocumentCheckinAppletHiddenProcess.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonDocumentCheckinAppletHiddenProcess.jsp.rca 1.7 Wed Oct 22 16:18:49 2008 przemek Experimental przemek $"
--%>

<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "emxComponentsCheckin.inc"%>
<%@ page import="com.matrixone.servlet.*,matrix.db.*,com.matrixone.fcs.http.*,com.matrixone.fcs.common.*,com.matrixone.fcs.mcs.*"%>
<%@page import="javax.json.JsonObject"%>
<%
    Map emxCommonDocumentCheckinData = (Map) session.getAttribute("emxCommonDocumentCheckinData");
    String objectAction        = (String) emxCommonDocumentCheckinData.get("objectAction");
    String fcsChunkThreshold        = (String) emxCommonDocumentCheckinData.get("fcsChunkThreshold");
    String fcsChunkSize        = (String) emxCommonDocumentCheckinData.get("fcsChunkSize");
    String store               = (String) emxCommonDocumentCheckinData.get("store");
    
    String targetPage  = "/"+ appDirectory +"/emxComponentsCheckinSuccess.jsp";
    String errorPage   = "/"+ appDirectory +"/emxComponentsError.jsp";
    String isVCDoc = (String)emxCommonDocumentCheckinData.get("isVcDoc");
    if("true".equals(isVCDoc)) {
       errorPage = "/"+ appDirectory +"/emxCommonDocumentVCError.jsp";
    }

    int numFiles = new Integer(request.getParameter("noOfFiles")).intValue();

    Enumeration enumParam = request.getParameterNames();

    while (enumParam.hasMoreElements())
    {
        String name = (String) enumParam.nextElement();
        String value = (String)request.getParameter(name);
        if ( value != null && !"".equals(value) && !"null".equals(value) )
        {
            emxCommonDocumentCheckinData.put(name, value);
        }
    }
          
	String newFiles = "";
	String checkinDirValue = "";
	String checkinFileFrom     = (String) emxCommonDocumentCheckinData.get("checkinFileFrom");
    String deleteFileOnCheckin = (String)emxCommonDocumentCheckinData.get("deleteFileOnCheckin");
    if(UIUtil.isNotNullAndNotEmpty(deleteFileOnCheckin) && "true".equalsIgnoreCase(deleteFileOnCheckin)){
    	
    	
    	if ("default".equalsIgnoreCase(checkinFileFrom)){
    		checkinDirValue = Download.processDefaultCheckoutDirectory(context);
    	}else{
    		checkinDirValue = (String)emxCommonDocumentCheckinData.get("checkinDirValue");
    	}
    	
    	for (int i=0; i<numFiles; i++){
    		String fileName = (String)request.getParameter("fileName"+i);
    		newFiles += checkinDirValue+ "/" + fileName;
    		if(i!=numFiles-1)
    			newFiles += "|";    			
    	}
        emxCommonDocumentCheckinData.put("updates", newFiles);
    }
              
    String processPage = "/"+ appDirectory +"/emxCommonDocumentPreCheckinProcess.jsp";
    if (DocumentUtil.isCheckinEligible(context,store))
    {
        processPage = "/"+ appDirectory +"/emxCommonDocumentCheckinProcess.jsp";
    }
    Map checkinURLMap = DocumentUtil.getFCSURLInfo(context,store.trim(),numFiles,processPage,targetPage,errorPage,request,response);
    String actionURL = (String)checkinURLMap.get("action");
    String ticketStr = (String)checkinURLMap.get("ticket");
    String jobTicket = (String)checkinURLMap.get("jobTicket");
    String JSESSIONID = (String)checkinURLMap.get("JSESSIONID");
    String failurePageName = (String)checkinURLMap.get("failurePageName");
    String failurePageValue = (String)checkinURLMap.get("failurePageValue");
    JsonObject csrfToken =  ENOCsrfGuard.getCSRFTokenJson_New(context,session);

%>
<html>
<body>

<script>
var mainForm = parent.frames["checkinFrame"];
mainForm.setJobTicket('<%=XSSUtil.encodeForJavaScript(context, ticketStr)%>');
mainForm.setActionURL('<%=XSSUtil.encodeForJavaScript(context, actionURL)%>');
mainForm.updateCookies('JSESSIONID', '<%=XSSUtil.encodeForJavaScript(context, JSESSIONID)%>');
mainForm.setCSRFToken('<%=csrfToken.toString()%>');
mainForm.setChunkThreshold('<%=XSSUtil.encodeForJavaScript(context, fcsChunkThreshold)%>');
mainForm.setChunkSize('<%=XSSUtil.encodeForJavaScript(context, fcsChunkSize)%>');
mainForm.submit();
</script>
</body>
</html>
