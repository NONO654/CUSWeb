<%--  emxPersonSearchProcess.jsp  --  Comnnecting Contents to Route

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxPersonSearchProcess.jsp.rca 1.8 Tue Oct 28 19:01:10 2008 przemek Experimental przemek $
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>

<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<%
String sPersonId[] = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(emxGetParameterValues(request,"emxTableRowId"));
String UserName = "";
String fullName = "";
if(sPersonId != null && sPersonId.length > 0)
{
	for(int i =0; i < sPersonId.length; i++){
		com.matrixone.apps.common.Person personObject = new com.matrixone.apps.common.Person(sPersonId[i]);
		String tempUserName = personObject.getName(context);
		if(i !=0) {
			UserName += ",";
			fullName += " | ";
		}

		UserName += tempUserName; 
		fullName +=  PersonUtil.getFullName(context,tempUserName);
	}
}
String formName   = (String)emxGetParameter(request, "form");
String fieldNameDisplay  = "TYPES=Person:CURRENT=Active";
String fieldNameActual  = emxGetParameter(request, "field");
%>

<script language="javascript">
var objRef = null;
var winRef = null;

if(parent.getWindowOpener()) {
	objRef = parent.getWindowOpener();
	winRef = parent.window;
} else if(getTopWindow().getWindowOpener()) {
	objRef = getTopWindow().getWindowOpener();
	winRef = getTopWindow().window;
}
	
if(objRef && objRef.document.forms[0] && objRef.document.forms[0].person) {
	  
      objRef.document.forms[0].person.value="<%=XSSUtil.encodeForJavaScript(context, UserName)%>";	  
      if(objRef.document.forms[0].person_display) {
          objRef.document.forms[0].person_display.value="<%=XSSUtil.encodeForJavaScript(context, PersonUtil.getFullName(context,UserName))%>";
      }
}
else {
<%
    if(formName  != null && !"".equals(formName)  && !"null".equals(formName) &&fieldNameActual != null && !"".equals(fieldNameActual) && !"null".equals(fieldNameActual))
    {
%>  
        eval("objRef.document.forms['<%=XSSUtil.encodeForJavaScript(context, formName)%>'].<%=XSSUtil.encodeForJavaScript(context, fieldNameActual)%>.value='<%=XSSUtil.encodeForJavaScript(context, UserName)%>';");
        
        var displayFieldExists = eval("objRef.document.forms['<%=XSSUtil.encodeForJavaScript(context, formName)%>'].<%=XSSUtil.encodeForJavaScript(context, fieldNameDisplay)%>");
        if (displayFieldExists) 
        {
            displayFieldExists.value='<%=XSSUtil.encodeForJavaScript(context, fullName)%>';
        }
<%   
    }
%>
}
winRef.closeWindow();
</script>


