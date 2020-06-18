


<%--  emxCommonDeleteObjects.jsp  -

   Intermediate JSP to update the fields by the object Id of the selected Object
   
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonDeleteObjects.jsp.rca 1.12 Wed Oct 22 16:17:43 2008 przemek Experimental przemek $";
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file=    "emxSearchInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import = "matrix.db.JPO"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>


<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%!
  private static final String REQ_PARAM_TIMESTAMP = "timeStamp";

  private static final String OBJECT_IDS = "objectIDs";
%>


<%
boolean errorOccurred = false;
String error = "";

  String timeStamp = emxGetParameter(request, REQ_PARAM_TIMESTAMP);

  Map requestMap = (Map)tableBean.getRequestMap(timeStamp);


try 
{ 
  String tableRowId[] = request.getParameterValues("emxTableRowId");
  

  String strDeleteJPO = (String)requestMap.get(Search.REQ_PARAM_DELETE_JPO);
  String strDeleteJPOMethod = (String)requestMap.get(Search.REQ_PARAM_DELETE_JPO_METHOD);
  String strSuiteKey = (String)requestMap.get("suiteKey");
  int iLast = strSuiteKey.indexOf("Central");
  String strAppName = strSuiteKey.substring(0,iLast);

  if ( (strDeleteJPO != null) && (strDeleteJPOMethod != null) && !(strDeleteJPO.equals("")) && !(strDeleteJPOMethod.equals("")) ) {
    Map inputMap = new HashMap();
    inputMap.put(OBJECT_IDS, tableRowId);
	FrameworkUtil.validateMethodBeforeInvoke(context, strDeleteJPO, strDeleteJPOMethod, "Program");
    JPO.invoke(context, strDeleteJPO, new String[0], strDeleteJPOMethod, JPO.packArgs(inputMap));
  }
  else {
       DomainObject.deleteObjects(context, tableRowId);
  }

} // End of try 
catch(Exception ex) { 
   errorOccurred = true;
   error = ex.getMessage();
   if(error.indexOf("java.lang.Exception:") != -1)
   {
   int firstIndex = error.indexOf("java.lang.Exception:");
   error = error.substring(firstIndex+20);
   int endIndex = error.indexOf("Warning:");
   error = (error.substring(0,endIndex)).trim(); 
  }
  else if(error.trim().length() == 0)
  {
    error =EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Common.NoDeleteAccess"); 
  }

} // End of catch 
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>

<body>
<form name="dummy">
<%
        java.util.Set keys = requestMap.keySet();
        Iterator itr = keys.iterator();
        String paramName = null;
        String paramValue = null;
        while(itr.hasNext()) {
          paramName = (String)itr.next();
          try {
            paramValue = (String)requestMap.get(paramName);
          }catch(Exception ClassCastException) {
            //Ignore the exception
          }
%>
          <input type="hidden" name="<%=XSSUtil.encodeForHTMLAttribute(context, paramName)%>" value = "<%=XSSUtil.encodeForHTMLAttribute(context, paramValue)%>" />
<%
        }
%>
         <input type="hidden" name="previousCommand" value = '<%=XSSUtil.encodeForHTMLAttribute(context, (String)requestMap.get("CommandName"))%>' />

</form>
</body>


<script>
<%
if(errorOccurred  && (error.length() != 0))
{
%>

alert("<%=XSSUtil.encodeForJavaScript(context, error)%>");
history.back(-1);
<%
}
else
{
%>
document.dummy.target = "searchView";
document.dummy.method="post";
document.dummy.action = "../common/emxTable.jsp";
document.dummy.submit();

<%
}
%>



</script>
