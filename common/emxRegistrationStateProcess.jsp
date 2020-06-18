<%--  emxRegistrationStateProcess.jsp   - This page is the processing page for State property registration dialog
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRegistrationStateProcess.jsp.rca 1.8 Wed Oct 22 15:48:08 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<html>
<head>
<jsp:useBean id="adminBean" class="com.matrixone.apps.domain.util.RegistrationUtil"/>
<script type="text/javascript" src="../common/scripts/emxAdminUtils.js"></script>
<%
    String sPolicy              = (String) emxGetParameter(request, "lstpolicy");
    String shdnMode             = (String) emxGetParameter(request, "hdnMode");
    String sSymbolicName        = (String) emxGetParameter(request, "txtSymbolicName");
    String sStateName           = (String) emxGetParameter(request, "lststatenames");
    String sPropertyState       = (String) emxGetParameter(request, "lstpropertystates");
    String shdnPropertyIndex    = (String) emxGetParameter(request, "hdnPropertyIndex");
    String shdnStateIndex       = (String) emxGetParameter(request, "hdnStateIndex");
    String slstSymbolicName     = "";
//  uncomment the below lines for variable length select list boxes     
//  StringBuffer sbPropertyStates = new StringBuffer("<select name=\"lstpropertystates\" id=\"lstpropertystates\" size=\"10\">");
//  StringBuffer sbStateNames = new StringBuffer("<select name=\"lststatenames\" id=\"lststatenames\" size=\"10\">");
//  uncomment the below lines for fixed length select list boxes 
    StringBuffer sbPropertyStates = new StringBuffer("<select name=\"lstpropertystates\" id=\"lstpropertystates\" size=\"10\" style=\"width:200\">");
    StringBuffer sbStateNames = new StringBuffer("<select name=\"lststatenames\" id=\"lststatenames\" size=\"10\" style=\"width:200\">");

    try{
        ContextUtil.startTransaction(context, true);
        if(shdnMode != null && shdnMode.length()>0 ) {
            if((shdnMode.equals("list"))){
                sbPropertyStates.append(adminBean.getPropertyStates(context, sPolicy));
                sbStateNames.append(adminBean.getStateNames(context, sPolicy));
                sbPropertyStates.append("</select>");
                sbStateNames.append("</select>");
            }else if(shdnMode.equals("create") || shdnMode.equals("update") || shdnMode.equals("delete")){
                // Build the parameter/value HashMap from the request
                HashMap paramMap = UINavigatorUtil.getRequestParameterMap(request);
                adminBean.registerProcess(context,paramMap);
            }
        }
%>
<script language="javascript">
    <%
        if((shdnMode.equals("list"))){
    %>
            var lstPropStates       = parent.document.getElementById("propertystates");
            lstPropStates.innerHTML = '<xss:encodeForJavaScript><%=sbPropertyStates.toString()%></xss:encodeForJavaScript>';
            var lstStates           = parent.document.getElementById("statenames");
            lstStates.innerHTML     = '<xss:encodeForJavaScript><%=sbStateNames.toString()%></xss:encodeForJavaScript>';
        <%
            }
        %>
    <%
        if(shdnMode.equals("create")){
            sSymbolicName    = FrameworkUtil.findAndReplace((String)FrameworkUtil.findAndReplace(sSymbolicName+"","'","\\\'"),"\"","\\\"");
            sStateName       = FrameworkUtil.findAndReplace((String)FrameworkUtil.findAndReplace(sStateName+"","'","\\\'"),"\"","\\\"");
            slstSymbolicName = sSymbolicName + " | " + sStateName;
    %>
            var optPropState = new Option("<xss:encodeForHTMLAttribute><%=slstSymbolicName%></xss:encodeForHTMLAttribute>","<xss:encodeForHTMLAttribute><%=sSymbolicName%></xss:encodeForHTMLAttribute>");
            parent.document.forms[0].lstpropertystates.options.add(optPropState);
    <%
        }else if(shdnMode.equals("delete")){
    %>
            parent.document.forms[0].lstpropertystates.options[<%=XSSUtil.encodeForHTMLAttribute(context, shdnPropertyIndex)%>]=null;
    <%
        }else if(shdnMode.equals("update")){
            sPropertyState   = FrameworkUtil.findAndReplace((String)FrameworkUtil.findAndReplace(sPropertyState+"","'","\\\'"),"\"","\\\"");
            sStateName       = FrameworkUtil.findAndReplace((String)FrameworkUtil.findAndReplace(sStateName+"","'","\\\'"),"\"","\\\"");
            slstSymbolicName = sPropertyState + " | " + sStateName;
    %>
            parent.document.forms[0].lstpropertystates.options[<%=XSSUtil.encodeForHTMLAttribute(context, shdnPropertyIndex)%>].text="<xss:encodeForHTMLAttribute><%=slstSymbolicName%></xss:encodeForHTMLAttribute>";
            parent.document.forms[0].lstpropertystates.options[<%=XSSUtil.encodeForHTMLAttribute(context, shdnPropertyIndex)%>].value="<xss:encodeForHTMLAttribute><%=sPropertyState%></xss:encodeForHTMLAttribute>";
    <%
        }
    %>
    //Enabling the dissabled butons in the parent page
    enableStateButtons(parent.document.forms[0],"<xss:encodeForJavaScript><%=shdnMode%></xss:encodeForJavaScript>");
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
