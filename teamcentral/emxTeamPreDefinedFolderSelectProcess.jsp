
<%--  emxTeamMigrationSelectMembersProcess.jsp  -

   Intermediate JSP to update the fields by the object Id of the selected Object

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxTeamMigrationSelectMembersProcess.jsp.rca 1.17 Wed Oct 22 16:18:42 2008 przemek Experimental przemek $";
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>

<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<%!
  private static final String COMPONENT_FRAMEWORK_BUNDLE = "emxComponentsStringResource";
  private static final String ALERT_MSG = "emxComponents.Search.Error.24";
  
%>


<%
try
{
  String timeStamp = emxGetParameter(request, "timeStamp");
  HashMap requestMap = (HashMap)indentedTableBean.getRequestMap(timeStamp);
  String strFrameName = (String)requestMap.get(Search.REQ_PARAM_FRAME_NAME);
  String strFormName = (String)requestMap.get(Search.REQ_PARAM_FORM_NAME);
  String strFieldNameDisplay = (String)requestMap.get(Search.REQ_PARAM_FIELD_NAME_DISPLAY);
  String strFieldNameActual = (String)requestMap.get(Search.REQ_PARAM_FIELD_NAME_ACTUAL);
  String strObjname = "";
  String strTableRowId = emxGetParameter(request,"emxTableRowIdActual");
  String strShowRevision = (String)requestMap.get("ShowRevision");
  String name = "";
  String description = "";
  java.util.StringTokenizer st = new java.util.StringTokenizer(strTableRowId, "|");

    name = st.nextToken();
    description = st.nextToken();


%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript">
  function setAndRefresh()
    {
      
	        var txtTypeDisplay;
      var txtTypeActual;
      var targetFrame = findFrame(getTopWindow().getWindowOpener(), "<%=XSSUtil.encodeForJavaScript(context,(String)strFrameName)%>");
      //Modified for the bug 325098
      var formName="<%=XSSUtil.encodeForJavaScript(context,(String)strFormName)%>";
      var strfieldDisplay = "<%=XSSUtil.encodeForJavaScript(context,(String)strFieldNameDisplay)%>";
      var strfieldNameActual = "<%=XSSUtil.encodeForJavaScript(context,(String)strFieldNameActual)%>" ;
      var elementCount;
      for(var i=0;i<getTopWindow().getWindowOpener().document.forms.length;i++)
      {
     
        if(getTopWindow().getWindowOpener().document.forms[i].name == formName){
          elementCount = i;
        }
      }

      
      if(targetFrame !=null && targetFrame != 'undefined')
      {
        txtTypeDisplay=targetFrame.document.forms[elementCount].elements[strfieldDisplay];
        txtTypeActual=targetFrame.document.forms[elementCount].elements[strfieldNameActual];
      }else{
        txtTypeDisplay = getTopWindow().getWindowOpener().document.forms[elementCount].elements[strfieldDisplay];
        txtTypeActual = getTopWindow().getWindowOpener().document.forms[elementCount].elements[strfieldNameActual];
      }
      txtTypeDisplay.value = "<xss:encodeForJavaScript><%=name%></xss:encodeForJavaScript>";
      //XSSOK
      txtTypeActual.value = "<%=strObjname%>";
      getTopWindow().getWindowOpener().FormHandler.SetFieldValue("Description","<xss:encodeForJavaScript><%=description%></xss:encodeForJavaScript>");
      getTopWindow().closeWindow();
    }

</script>

<html>
<body onload=setAndRefresh()>
</body>
</html>

<%
} // End of try
catch(Exception ex) {
   session.putValue("error.message", ex.getMessage());
 } // End of catch
%>

