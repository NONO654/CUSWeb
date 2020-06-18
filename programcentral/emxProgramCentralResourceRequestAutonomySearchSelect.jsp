<%--  emxCommonSelectPerson.jsp  -

   Intermediate JSP to update the fields by the object Id of the selected Object

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonSelectPerson.jsp.rca 1.13 Wed Oct 22 16:18:48 2008 przemek Experimental przemek przemek $";
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file="../components/emxSearchInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>



<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

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
  String[] strTableRowIds = emxGetParameterValues(request,"emxTableRowId");
  String timeStamp = emxGetParameter(request, "timeStamp");
  String typeAhead = emxGetParameter(request, "typeAhead");
    // System.out.println("requestMap >>>> "+ requestMap);
  //  HashMap requestMap = (HashMap)tableBean.getRequestMap(timeStamp);
   // System.out.println("requestMap>>>"+requestMap);

  // String strFrameName = (String)requestMap.get(Search.REQ_PARAM_FRAME_NAME);
  String strFrameName = (String)emxGetParameter(request, Search.REQ_PARAM_FRAME_NAME);
  String strFormName = (String)emxGetParameter(request, Search.REQ_PARAM_FORM_NAME);

  // String strFieldNameDisplay = (String)requestMap.get(Search.REQ_PARAM_FIELD_NAME_DISPLAY);
  String strFieldNameDisplay = (String)emxGetParameter(request, Search.REQ_PARAM_FIELD_NAME_DISPLAY);

   // String strFieldNameActual = (String)requestMap.get(Search.REQ_PARAM_FIELD_NAME_ACTUAL);
 String strFieldNameActual = (String)emxGetParameter(request, Search.REQ_PARAM_FIELD_NAME_ACTUAL);
 strFieldNameActual = strFieldNameActual;// + "OID";

  //System.out.println("strFieldNameActual *** " +strFieldNameActual);
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
  else{
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
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript">
  function setAndRefresh()
  {
      var txtTypeDisplay;
      var txtTypeActual;
      var targetFrame = findFrame(getTopWindow().getWindowOpener(), "<%=XSSUtil.encodeForJavaScript(context,strFrameName)%>");
      var typeAhead = "<%=XSSUtil.encodeForJavaScript(context, typeAhead)%>";

      var formName="<%=XSSUtil.encodeForJavaScript(context,strFormName)%>";
      var strfieldDisplay = "<%=XSSUtil.encodeForJavaScript(context,strFieldNameDisplay)%>";
      var strfieldNameActual = "<%=XSSUtil.encodeForJavaScript(context,strFieldNameActual)%>" ;

      if(targetFrame !=null){
	      txtTypeDisplay=targetFrame.document.forms[0].elements[strfieldDisplay];
	      txtTypeActual=targetFrame.document.forms[0].elements[strfieldNameActual];
      }else{
	      var targetWindow = null;
	      
	      if(typeAhead == "true"){
		      var frameName = "<%=XSSUtil.encodeForJavaScript(context, strFrameName)%>";
		      if(frameName == null || frameName == "null" || frameName == "") {
		      	targetWindow = window.parent;
		      }else {
		      	targetWindow = getTopWindow().findFrame(window.parent, frameName);
		      }
		            
		      if(!targetWindow){
		      	targetWindow = window.parent;
		      }
	      }else{
	      	targetWindow = getTopWindow().getWindowOpener();
	      }
	        	  
	      txtTypeActual=targetWindow.document.forms[0][strfieldNameActual];
	      txtTypeDisplay=targetWindow.document.forms[0][strfieldDisplay];
	        	  
	      if(txtTypeDisplay == undefined && txtTypeActual== undefined){
		      var elementCount;
		      for(var i=0;i<getTopWindow().getWindowOpener().document.forms.length;i++){
		          	elementCount = i;
		      }
		      txtTypeDisplay=targetWindow.document.forms[elementCount].elements[strfieldDisplay];
		      txtTypeActual=targetWindow.document.forms[elementCount].elements[strfieldNameActual];
	      }   
      }
     
      <%-- XSSOK--%> 
             if(txtTypeActual.value !=  '<%=strSelectValue%>' ){
    	 try{
    	      txtTypeDisplay.onchange();
    	      txtTypeActual.onchange();
   	      }catch(err)
   	      {}
     }
      txtTypeDisplay.value = "<%=XSSUtil.encodeForJavaScript(context,strSelectName)%>";
      txtTypeActual.value = "<%=XSSUtil.encodeForJavaScript(context,strSelectValue)%>";
      
    if(typeAhead != "true") { 
      getTopWindow().closeWindow();
    }
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
