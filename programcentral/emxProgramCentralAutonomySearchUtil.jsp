<%--  emxProgramCentralProgramsAutonomySearch.jsp -

   Intermediate JSP to update the fields by the object Id of the selected Object for selecting Programs
   while creating and editing ProjectSpace ProjectConcept

   Copyright (c) Dassault Systemes, 1993-2018 .All rights reserved

--%>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file="../components/emxSearchInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>


<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%!
  private static final String COMPONENT_FRAMEWORK_BUNDLE = "emxComponentsStringResource";
  private static final String ALERT_MSG = "emxComponents.Search.Error.24";

%>
<%
	try
{
  String strProjectId = (String)emxGetParameter(request,"projectId");
  String strType ="";
  if(ProgramCentralUtil.isNotNullString(strProjectId)){
			DomainObject domProject = new DomainObject(strProjectId);
			strType = (String) domProject.getInfo(context, DomainConstants.SELECT_TYPE);
			if (domProject.isKindOf(context, DomainConstants.TYPE_CHANGE_PROJECT)) {
				strType = DomainConstants.TYPE_CHANGE_PROJECT;
			}
		}
  String[] strTableRowIds = emxGetParameterValues(request,"emxTableRowId");
  String timeStamp = emxGetParameter(request, "timeStamp");
  String strFrameName = (String)emxGetParameter(request, Search.REQ_PARAM_FRAME_NAME);
  String strFormName = (String)emxGetParameter(request, Search.REQ_PARAM_FORM_NAME);
  String strFieldNameDisplay = (String)emxGetParameter(request, Search.REQ_PARAM_FIELD_NAME_DISPLAY);
  String strFieldNameActual = (String)emxGetParameter(request, Search.REQ_PARAM_FIELD_NAME_ACTUAL);
  strFieldNameActual = strFieldNameActual;
  String strObjname = "";
  String strObjvalue = "";
  int TableRowlen = strTableRowIds.length;
  String strSelectName = "";
  String strSelectValue = "";
  if ((strTableRowIds == null)||(strTableRowIds.length==0)){
  i18nNow i18nInstance = new i18nNow();
     String strLang = request.getHeader("Accept-Language");
     String strRetMsg = i18nInstance.GetString(COMPONENT_FRAMEWORK_BUNDLE, acceptLanguage,ALERT_MSG);
     throw new FrameworkException(strRetMsg);
  }
  else
  {
      StringList slPersonList = new StringList();
      StringList slPersonListValue = new StringList();
      for(int i =0;i<TableRowlen;i++){
      StringList splitObject = com.matrixone.apps.domain.util.FrameworkUtil.split(strTableRowIds[i],"|");
      Search search = new Search();
	  int cnt = splitObject.size();
	  strObjname = search.getObjectName(context, (String)splitObject.get(0));
	       strObjvalue = (String)splitObject.get(0);
	       slPersonList.add(strObjname);
	       slPersonListValue.add(strObjvalue);
   	 }
     if(slPersonList.size()>1){
         strSelectName =  FrameworkUtil.join(slPersonList,",");
         strSelectValue = FrameworkUtil.join(slPersonListValue,",");
     }else{
         strSelectName = strObjname;
         strSelectValue = strObjvalue;
     }
  }

%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript">
  function setAndRefresh()
  {
      var txtTypeDisplay;
      var txtTypeActual;
      var targetFrame = findFrame(getTopWindow().getWindowOpener(), "<%=XSSUtil.encodeForJavaScript(context,strFrameName)%>");
      var formName="<%=XSSUtil.encodeForJavaScript(context,strFormName)%>";
      var strfieldDisplay = "<%=XSSUtil.encodeForJavaScript(context,strFieldNameDisplay)%>";
      var strfieldNameActual = "<%=XSSUtil.encodeForJavaScript(context,strFieldNameActual)%>" ;
      var strProjectType = "<%=XSSUtil.encodeForJavaScript(context,strType)%>" ;
      var elementCount;
      for(var i=0;i<getTopWindow().getWindowOpener().document.forms.length;i++)
      {
   	elementCount = i;
 }
      if(targetFrame !=null)
      {
        txtTypeDisplay=targetFrame.document.forms[elementCount].elements[strfieldDisplay];
        txtTypeActual=targetFrame.document.forms[elementCount].elements[strfieldNameActual];

      }else{
		txtTypeDisplay = getTopWindow().getWindowOpener().document.forms[0].elements[strfieldDisplay];
        txtTypeActual = getTopWindow().getWindowOpener().document.forms[0].elements[strfieldNameActual];

      }
      var displayValue =txtTypeDisplay.value;
      var actualValue =txtTypeActual.value;
      if(strfieldNameActual=="ProgramId" || strfieldNameActual=="LocationId"){
    	  if("Change Project" == strProjectType){
    	      txtTypeDisplay.value = "<%=strSelectName%>";<%--XSSOK--%>
    	      txtTypeActual.value = "<%=strSelectValue%>";<%--XSSOK--%>
    	  }else{
    	    if(null!=displayValue && ""!=displayValue){
    	        displayValue = displayValue+","+"<%=strSelectName%>";<%--XSSOK--%>
    	        actualValue = actualValue+","+"<%=strSelectValue%>";<%--XSSOK--%>
    	        var arrDisplayValues = displayValue.split(",");
    	        var arrActualValues = actualValue.split(",");
    	        var arrActualUniqueValues =unique(arrActualValues);
    	        var arrDisplayUniqueValues =unique(arrDisplayValues);
    	        txtTypeDisplay.value = arrDisplayUniqueValues;
                txtTypeActual.value = arrActualUniqueValues;
            }
    	    else{
    	        txtTypeDisplay.value = "<%=strSelectName%>";<%--XSSOK--%>
    	        txtTypeActual.value = "<%=strSelectValue%>";<%--XSSOK--%>
    	    }
      }
      }
      else{
      txtTypeDisplay.value = "<%=strSelectName%>";<%--XSSOK--%>
      txtTypeActual.value = "<%=strSelectValue%>";<%--XSSOK--%>
      }
      getTopWindow().closeWindow();
  }

  function unique(arrayName) {
      var obj = new Object();

      // For each element create property on object
      // duplicate properties cannot be created thus we will get uniqueness automatically
      for (var i = 0; i < arrayName.length; i++) {
          obj[arrayName[i]] = arrayName[i];
      }

      // Get all the object properties in new array
      var newArray=new Array();
      for (var property in obj) {
          newArray[newArray.length] = property;
      }

      return newArray;
  }


</script>

<html>
<body onload=setAndRefresh()>
</body>
</html>

<%

} // End of try
catch(Exception ex) {
    ex.printStackTrace();
   session.putValue("error.message", ex.getMessage());
 } // End of catch
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
