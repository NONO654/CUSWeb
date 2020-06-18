<%--  emxCommonSelectPerson.jsp  -

   Intermediate JSP to update the fields by the object Id of the selected Object

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonSelectPerson.jsp.rca 1.13 Wed Oct 22 16:18:48 2008 przemek Experimental przemek $";
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file="emxSearchInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>



<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%!
  private static final String COMPONENT_FRAMEWORK_BUNDLE = "emxComponentsStringResource";
  private static final String ALERT_MSG = "emxComponents.Search.Error.24";

%>
<%
/* Modified by <Infosys> On <26th MAY 2003>
   For the following Bug
   <Proper display of Error Message when the operation fails>
   Fixed as Follows:
   <The corrresponding Errors are caught and added to Session>
*/
/* Modified by <Infosys> On <12th AUG 2003>
   For the following Bug
   <Product : When click Submit in a find select screen  with no item checked  getting an error: business type "" does not exist>
   Fixed as Follows:
   <Added a condition and throwing exception if no row is selected>
*/
%>

<%

try
{
  String[] strTableRowIds = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(emxGetParameterValues(request,"emxTableRowId"));

  String timeStamp = emxGetParameter(request, "timeStamp");
  HashMap requestMap = new HashMap();
  String uiType = emxGetParameter(request, "uiType");
  if("structureBrowser".equalsIgnoreCase(uiType)){
  	requestMap = (HashMap)indentedTableBean.getRequestMap(timeStamp);
  }else{
  	requestMap = (HashMap)tableBean.getRequestMap(timeStamp);
  }

  String strFrameName = (String)requestMap.get(Search.REQ_PARAM_FRAME_NAME);
  String strFormName = (String)requestMap.get(Search.REQ_PARAM_FORM_NAME);
  String strFieldNameDisplay = (String)requestMap.get(Search.REQ_PARAM_FIELD_NAME_DISPLAY);
  String strFieldNameActual = (String)requestMap.get(Search.REQ_PARAM_FIELD_NAME_ACTUAL);
  String strObjname = "";
  
  String displayFullName = (String)requestMap.get("displayFullName");
  String strObjDisplayName = "";
  
  if ((strTableRowIds == null)||(strTableRowIds.length==0)){
  i18nNow i18nInstance = new i18nNow();
     String strLang = request.getHeader("Accept-Language");
     String strRetMsg = i18nInstance.GetString(COMPONENT_FRAMEWORK_BUNDLE, acceptLanguage,ALERT_MSG);
     throw new FrameworkException(strRetMsg);
  }
  else{
  	if(displayFullName != null && "true".equalsIgnoreCase(displayFullName)) {
   		String[] strPersonDetails = com.matrixone.apps.common.util.ComponentsUtil.getPersonNameAndFullName(context, strTableRowIds);
   		strObjname = strPersonDetails[0];
   		strObjDisplayName = strPersonDetails[1];
   	} else {
   Search search = new Search();
   strObjname = search.getObjectName(context, strTableRowIds);
       strObjDisplayName = strObjname;
   	}  
  }
%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript">
  function setAndRefresh()
  {
      var txtTypeDisplay;
      var txtTypeActual;
      var targetFrame = findFrame(getTopWindow().getWindowOpener(), "<%=XSSUtil.encodeForJavaScript(context, strFrameName)%>");
      //Modified for the bug 325098
      var formName="<%=XSSUtil.encodeForJavaScript(context, strFormName)%>";
      var strfieldDisplay = "<%=XSSUtil.encodeForJavaScript(context, strFieldNameDisplay)%>";
      var strfieldNameActual = "<%=XSSUtil.encodeForJavaScript(context, strFieldNameActual)%>" ;
      var elementCount;
      for(var i=0;i<getTopWindow().getWindowOpener().document.forms.length;i++)
      {
        if(getTopWindow().getWindowOpener().document.forms[i].name == formName){
          elementCount = i;
        }
      }
      if(targetFrame !=null)
      {
        txtTypeDisplay=targetFrame.document.forms[elementCount].elements[strfieldDisplay];
        txtTypeActual=targetFrame.document.forms[elementCount].elements[strfieldNameActual];
      }else{
        txtTypeDisplay = getTopWindow().getWindowOpener().document.forms[elementCount].elements[strfieldDisplay];
        txtTypeActual = getTopWindow().getWindowOpener().document.forms[elementCount].elements[strfieldNameActual];
      }
      txtTypeDisplay.value = "<%=XSSUtil.encodeForJavaScript(context, strObjDisplayName)%>";
      txtTypeActual.value = "<%=XSSUtil.encodeForJavaScript(context, strObjname)%>";
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

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
