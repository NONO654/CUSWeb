<%--  emxComponentsChangeAssigneeProcess.jsp   - Change Assignee by Groups processing page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsChangeAssigneeProcess.jsp.rca 1.7 Wed Oct 22 16:18:19 2008 przemek Experimental przemek $
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<%

String fieldNameActual = emxGetParameter(request, "fieldNameActual");
String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
String fromPage = emxGetParameter(request, "fromPage");
String strLanguage = request.getHeader("Accept-Language");
String[] sGroupList = request.getParameterValues("emxTableRowId");
String strRowId[] = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(sGroupList);

if(sGroupList == null) {
%> 
	<script language="javascript">
    	alert("<%=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Message.PleaseMakeASelection")%>");
	</script>
<%
	return;
}

// check if unregistered group is selected then alert the end user
String selectedGroupSymbName = FrameworkUtil.getAliasForAdmin(context, "Group", strRowId[0], true);
if(UIUtil.isNullOrEmpty(selectedGroupSymbName) && !"addApprover".equals(fromPage)) {
%> 
	<script language="javascript">
    	alert("<%=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Group.GroupNotRegistered")%>");
	</script>
<%
	return;
}

StringBuffer actualValue = new StringBuffer();
StringBuffer displayValue = new StringBuffer();
for(int i=0; i<strRowId.length; i++) {
    displayValue.append(XSSUtil.encodeForJavaScript(context, i18nNow.getAdminI18NString("Group", strRowId[i], strLanguage)));
    actualValue.append(XSSUtil.encodeForJavaScript(context, strRowId[i]));
}                       
%>

<script language="javascript" type="text/javaScript">

var targetWindow = getTopWindow().getWindowOpener();

var tmpFieldNameActual = "<%=XSSUtil.encodeForJavaScript(context, fieldNameActual)%>";
var tmpFieldNameDisplay = "<%=XSSUtil.encodeForJavaScript(context, fieldNameDisplay)%>";

var vfieldNameActual = targetWindow.document.getElementById(tmpFieldNameActual);
var vfieldNameDisplay = targetWindow.document.getElementById(tmpFieldNameDisplay);

if (vfieldNameActual==null && vfieldNameDisplay==null) {
vfieldNameActual=targetWindow.document.forms[0][tmpFieldNameActual];
vfieldNameDisplay=targetWindow.document.forms[0][tmpFieldNameDisplay];
}

if (vfieldNameActual==null && vfieldNameDisplay==null) {
vfieldNameActual=targetWindow.document.getElementsByName(tmpFieldNameActual)[0];
vfieldNameDisplay=targetWindow.document.getElementsByName(tmpFieldNameDisplay)[0];
}

/*
   FIX IR-088125V6R2012 
   In IE8, for some use-cases, getElementsByName doesn't work when 
   accessing URL with its full name. Below code address the issue.
 */
if (vfieldNameActual==null && vfieldNameDisplay==null) {
     var elem = targetWindow.document.getElementsByTagName("input");
     var att;
     var iarr;
     for(i = 0,iarr = 0; i < elem.length; i++) {
        att = elem[i].getAttribute("name");
        if(tmpFieldNameDisplay == att) {
            vfieldNameDisplay = elem[i];
            iarr++;
        }
        if(tmpFieldNameActual == att) {
            vfieldNameActual = elem[i];
            iarr++;
        }
        if(iarr == 2) {
            break;
        }
    }
}
/* FIX - END */

vfieldNameDisplay.value ="<%=displayValue%>" ;
vfieldNameActual.value ="<%=actualValue%>" ;

getTopWindow().closeWindow();

</script>
