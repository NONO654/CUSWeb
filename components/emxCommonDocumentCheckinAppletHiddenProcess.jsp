<%-- emxCommonDocumentCheckinAppletHiddenProcess.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonDocumentCheckinAppletHiddenProcess.jsp.rca 1.7 Wed Oct 22 16:18:49 2008 przemek Experimental przemek $"
--%>

<%@page import="javax.json.JsonObject"%>
<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "emxComponentsCheckin.inc"%>
<%@ page import="com.matrixone.servlet.*,matrix.db.*,com.matrixone.fcs.http.*,com.matrixone.fcs.common.*,com.matrixone.fcs.mcs.*"%>

<%
    Map emxCommonDocumentCheckinData = (Map) session.getAttribute("emxCommonDocumentCheckinData");
    String objectAction        = (String) emxCommonDocumentCheckinData.get("objectAction");
    String showFormat          = (String) emxCommonDocumentCheckinData.get("showFormat");
    String showDescription     = (String) emxCommonDocumentCheckinData.get("showDescription");
    String showComments        = (String) emxCommonDocumentCheckinData.get("showComments");
    String showTitle           = (String) emxCommonDocumentCheckinData.get("showTitle");

    if (showFormat == null || showFormat.equals("") )
    {
        showFormat = "true";
    }

    if (showTitle == null || showTitle.equals("") )
    {
        showTitle = "true";
    }

    if (showDescription == null || showDescription.equals("") )
    {
        showDescription = "true";
    }

    if (showComments == null || showComments.equals("") )
    {
        showComments = "true";
    }

    if (objectAction == null || objectAction.equals("") )
    {
        objectAction = "create";
    }

    if ( !CommonDocument.OBJECT_ACTION_CREATE_MASTER_PER_FILE.equalsIgnoreCase(objectAction) )
    {
        showDescription = "false";
        showTitle = "false";
    } else {
        showComments = "false";
    }

    String targetPage  = "/"+ appDirectory +"/emxComponentsCheckinSuccess.jsp";
    String errorPage   = "/"+ appDirectory +"/emxComponentsError.jsp";
    String isVCDoc = (String)emxCommonDocumentCheckinData.get("isVcDoc");
    if("true".equals(isVCDoc)) {
       errorPage = "/"+ appDirectory +"/emxCommonDocumentVCError.jsp";
    }

    int numFiles = new Integer(request.getParameter("noOfFiles")).intValue();

    Enumeration enumParam = request.getParameterNames();
    //jpoName = request.getParameter("JPOName");
    //appProcessPage = request.getParameter("appProcessPage");
    //appDir   = request.getParameter("appDir");
    while (enumParam.hasMoreElements())
    {
        String name = (String) enumParam.nextElement();
        String value = (String)request.getParameter(name);
        if ( value != null && !"".equals(value) && !"null".equals(value) )
        {
            emxCommonDocumentCheckinData.put(name, value);
        }
    }
    String store = request.getParameter("store");

    String processPage = "/"+ appDirectory +"/emxCommonDocumentPreCheckinProcess.jsp";
    if (DocumentUtil.isCheckinEligible(context,store))
    {
        processPage = "/"+ appDirectory +"/emxCommonDocumentCheckinProcess.jsp";
    }
    Map checkinURLMap = DocumentUtil.getFCSURLInfo(context,store.trim(),numFiles,processPage,targetPage,errorPage,request,response);
    String actionURL = (String)checkinURLMap.get("action");
    String JSESSIONID = (String)checkinURLMap.get("JSESSIONID");
    String ticketStr = (String)checkinURLMap.get("ticket");
    String jobTicket = (String)checkinURLMap.get("jobTicket");
    String failurePageName = (String)checkinURLMap.get("failurePageName");
    String failurePageValue = (String)checkinURLMap.get("failurePageValue");

/*
The following form is added to support applet cancel and resubmit functionality
This form should be identical as of emxCommonDocumentCheckinAppletHiddenDialog.jsp form.
*/
%>
<html>
<body>
<form name="hiddenForm" action="emxCommonDocumentCheckinAppletHiddenProcess.jsp" method="post">
<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
<input type="hidden" name="noOfFiles" />
<input type="hidden" name="store" />
<%
    String fcsChunkThreshold = null;
    String fcsChunkSize      = null;
    try
    {
       fcsChunkThreshold = EnoviaResourceBundle.getProperty(context,"emxFramework.Applet.fcsChunkThreshold");
       fcsChunkSize      = EnoviaResourceBundle.getProperty(context,"emxFramework.Applet.fcsChunkSize");
    }
    catch (Throwable TEx)
    {}
    if ((null == fcsChunkThreshold) || (0 >= fcsChunkThreshold.length())) fcsChunkThreshold = "";
    if ((null == fcsChunkSize) || (0 >= fcsChunkSize.length()))  fcsChunkSize = "";
    String maxNoOfFilesStr = EnoviaResourceBundle.getProperty(context,"emxFramework.Applet.MaximumNoFilesLimit");
    int maxNoOfFiles = (new Integer(maxNoOfFilesStr)).intValue();
    for (int i=0; i<=maxNoOfFiles; i++)
    {
%>
        <input type="hidden" name="fileName<%=i%>" />
<%
        if( "true".equalsIgnoreCase(showComments) || "required".equalsIgnoreCase(showComments) )
        {
%>
          <input type="hidden" name="comments<%=i%>" />
<%
        }
        if ( "true".equalsIgnoreCase(showDescription) || "required".equalsIgnoreCase(showDescription))
        {
%>
          <input type="hidden" name="description<%=i%>" />
<%
        }
        if ( "true".equalsIgnoreCase(showTitle) || "required".equalsIgnoreCase(showTitle))
        {
%>
          <input type="hidden" name="title<%=i%>" />
<%
        }
       
%>
          <input type="hidden" name="format<%=i%>" />
<%
    }
    JsonObject csrfToken =  ENOCsrfGuard.getCSRFTokenJson_New(context,session);
    
%>

</form>
<script>
var mainForm = parent.frames["checkinFrame"];
mainForm.setJobTicket('<%=XSSUtil.encodeForJavaScript(context, ticketStr)%>');
mainForm.updateCookies('JSESSIONID', '<%=XSSUtil.encodeForJavaScript(context, JSESSIONID)%>');
mainForm.setActionURL('<%=XSSUtil.encodeForJavaScript(context, actionURL)%>');
mainForm.setCSRFToken('<%=csrfToken.toString()%>');
//XSSOK
mainForm.setChunkThreshold('<%=fcsChunkThreshold%>');
//XSSOK
mainForm.setChunkSize('<%=fcsChunkSize%>');
mainForm.submit();
</script>
</body>
</html>
