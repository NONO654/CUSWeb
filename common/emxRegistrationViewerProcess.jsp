<%--  emxRegistrationViewerProcess.jsp   - This page is the processing page for Viewer property registration dialog
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRegistrationViewerProcess.jsp.rca 1.9 Wed Oct 22 15:48:54 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<html>
<head>
<jsp:useBean id="adminBean" class="com.matrixone.apps.domain.util.RegistrationUtil"/>
<script type="text/javascript" src="../common/scripts/emxAdminUtils.js"></script>
<%
String sFormat                      = (String) emxGetParameter(request, "lstformats");
String shdnMode                     = (String) emxGetParameter(request, "hdnMode");
String shdnViewerServlet            = (String) emxGetParameter(request, "hdnViewerServlet");
String sViewerTip                   = (String) emxGetParameter(request, "txtViewerTip");
String shdnViewerServletIndex       = (String) emxGetParameter(request, "hdnViewerServletIndex");


//  uncomment the below lines for variable length select list boxes     
// StringBuffer sbAssignedViewers = new StringBuffer("<select name=\"lstassignedviewers\" id=\"lstassignedviewers\" multiple size=\"10\" width=\"200\">");
// StringBuffer sbUnAssignedViewers = new StringBuffer("<select name=\"lstunassignedviewers\" id=\"lstunassignedviewers\" multiple size=\"10\" width=\"200\">");
//  uncomment the below lines for fixed length select list boxes 
StringBuffer sbAssignedViewers = new StringBuffer("<select name=\"lstassignedviewers\" id=\"lstassignedviewers\" multiple size=\"10\" style=\"width:100%\">");
StringBuffer sbUnAssignedViewers = new StringBuffer("<select name=\"lstunassignedviewers\" id=\"lstunassignedviewers\" multiple size=\"10\" style=\"width:100%\">");
try{
    ContextUtil.startTransaction(context, true);
    if(shdnMode != null && shdnMode.length()>0 ) {
        // Build the parameter/value HashMap from the request
        HashMap paramMap = UINavigatorUtil.getRequestParameterMap(request);
        if(shdnMode.equals("list")){
            sbAssignedViewers.append(adminBean.getAssignedViewers(context, sFormat));
            sbUnAssignedViewers.append(adminBean.getUnAssignedViewers(context));
            sbAssignedViewers.append("</select>");
            sbUnAssignedViewers.append("</select>");
        }else if(shdnMode.equals("create") || shdnMode.equals("update")){
            adminBean.registerViewerProcess(context,paramMap);
        }else if(shdnMode.equals("delete")){
            adminBean.registerViewerProcess(context,paramMap);
            sbAssignedViewers.append(adminBean.getAssignedViewers(context, sFormat));
            sbAssignedViewers.append("</select>");
            sbUnAssignedViewers.append(adminBean.getUnAssignedViewers(context));
            sbUnAssignedViewers.append("</select>");
        }else if(shdnMode.equals("assign") || shdnMode.equals("unassign")) {
            adminBean.assignProcess(context,paramMap);
        }
    }
    %>
    <script language="javascript">
        function loadList(){
            var lstAssignedViewers          =   parent.document.getElementById("assignedviewers");
            lstAssignedViewers.innerHTML    =   '<xss:encodeForJavaScript><%=sbAssignedViewers.toString()%></xss:encodeForJavaScript>';
            var lstUnAssignedViewers        =   parent.document.getElementById("unassignedviewers");
            lstUnAssignedViewers.innerHTML  =   '<xss:encodeForJavaScript><%=sbUnAssignedViewers.toString()%></xss:encodeForJavaScript>';
        }
    <%
        sViewerTip          = FrameworkUtil.findAndReplace((String)FrameworkUtil.findAndReplace(sViewerTip+"","'","\\\'"),"\"","\\\"");
        shdnViewerServlet   = FrameworkUtil.findAndReplace((String)FrameworkUtil.findAndReplace(shdnViewerServlet+"","'","\\\'"),"\"","\\\"");
        if(shdnMode.equals("list")){
    %>            
            loadList();
    <%
        }else if(shdnMode.equals("create")){
    %>
            var optNewViewer  = new Option("<%=XSSUtil.encodeForHTMLAttribute(context, shdnViewerServlet)%>","<%=XSSUtil.encodeForHTMLAttribute(context, sViewerTip)%>");
            parent.document.forms[0].lstviewerservlet.options.add(optNewViewer);
            parent.document.forms[0].lstviewerservlet.options[parent.document.forms[0].lstviewerservlet.options.length-1].selected=true;
            var optUnAssigned = new Option("<%=XSSUtil.encodeForHTMLAttribute(context, shdnViewerServlet)%>","<%=XSSUtil.encodeForHTMLAttribute(context, shdnViewerServlet)%>");
            parent.document.forms[0].lstunassignedviewers.options.add(optUnAssigned);
    <%
        }else if(shdnMode.equals("update")){
    %>
            parent.document.forms[0].lstviewerservlet.options[<%=XSSUtil.encodeForHTMLAttribute(context, shdnViewerServletIndex)%>].value="<%=XSSUtil.encodeForHTMLAttribute(context, sViewerTip)%>";
    <%
        }else if(shdnMode.equals("delete")){
    %>
            parent.document.forms[0].lstviewerservlet.options[<%=XSSUtil.encodeForHTMLAttribute(context, shdnViewerServletIndex)%>] = null;
            parent.document.forms[0].txtViewerTip.value='';
            loadList();
    <%
        }
    %>
    //Enabling the dissabled butons in the parent page
    enableViewerButtons(parent.document.forms[0],"<xss:encodeForJavaScript><%=shdnMode%></xss:encodeForJavaScript>");
    </script>
<%  
} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    emxNavErrorObject.addMessage(ex.toString().trim());
} finally {
    ContextUtil.commitTransaction(context);
}
%>
<script>
    parent.clicked= false;
    parent.turnOffProgress();
</script>
</head>
<body>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
