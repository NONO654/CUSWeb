<%--  emxTableEditPreProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   static const char RCSID[] = $Id: emxTableEditPreProcess.jsp.rca 1.2.1.5 Wed Oct 22 15:48:05 2008 przemek Experimental przemek $
--%>

<%@page import="javax.json.JsonObject"%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%
String timeStamp = emxGetParameter(request, "timeStamp");
HashMap tableData = tableBean.getTableData(timeStamp);
HashMap requestMap = tableBean.getRequestMap(tableData);

String objectId = (String)requestMap.get("objectId");
String relId = (String)requestMap.get("relId");

String preProcessJPO = (String)requestMap.get("preProcessJPO");
String preProcessURL = (String)requestMap.get("preProcessURL");
String suiteKey = (String)requestMap.get("suiteKey");

HashMap returnMap = new HashMap();

MapList relBusObjPageList = tableBean.getEditObjectList(context, timeStamp);
HashMap jpoTableData = new HashMap();
jpoTableData.putAll(tableData);
if(relBusObjPageList != null && relBusObjPageList.size()>0)
{
  jpoTableData.put("ObjectList",relBusObjPageList);
}

//added condition to handle the preProcessURL parameter
if (preProcessURL!= null && !"".equals (preProcessURL))
{
  request.setAttribute("context", context);
  JsonObject tokenJson =  ENOCsrfGuard.getCSRFTokenJson_New(context,session);
	String tokenName = tokenJson.getString(ENOCsrfGuard.CSRF_TOKEN_NAME);
	String tokenValue = tokenJson.getString(tokenName);
	StringBuffer url = new StringBuffer();
	url.append(ENOCsrfGuard.CSRF_TOKEN_NAME);
	url.append("=");
	url.append(tokenName);
	url.append("&");
	url.append(tokenName);
	url.append("=");
	url.append(tokenValue);
	if(preProcessURL.indexOf("?")!=-1){
		preProcessURL+="&"+url.toString();
	}
	else{
		preProcessURL+="?"+url.toString();
	}
%>
<!-- //XSSOK -->  
  <jsp:include page = "<%=preProcessURL%>" flush="true" />
<%
}
//Added for preProcessJPO parameter
if(preProcessJPO != null && !"".equals(preProcessJPO) && preProcessJPO.indexOf(":") > 0)
{
  HashMap programMap = new HashMap();
  HashMap paramMap = new HashMap();

  paramMap.put("objectId", objectId);
  paramMap.put("relId", relId);
  programMap.put("paramMap", paramMap);

  // added to handle tableData, if this page is called form Table component
  programMap.put("requestMap", tableBean.getRequestMap(timeStamp));
  programMap.put("tableData", jpoTableData);
 
 
  String[] methodargs = JPO.packArgs(programMap);
  String strJPOName = preProcessJPO.substring(0, preProcessJPO.indexOf(":"));
  String strMethodName = preProcessJPO.substring (preProcessJPO.indexOf(":") + 1, preProcessJPO.length());
  try {
	FrameworkUtil.validateMethodBeforeInvoke(context, strJPOName, strMethodName,"preProcess");
    returnMap = (HashMap)JPO.invoke(context, strJPOName, null, strMethodName, methodargs, HashMap.class);
  } catch (Exception exJPO) {
       throw (new FrameworkException(exJPO.toString()));
  }
}
if(returnMap != null && returnMap.size()>0)
{
  String message = (String)returnMap.get("Message");
  String action  = (String)returnMap.get("Action");
  MapList objectList = (MapList)returnMap.get("ObjectList");
  
  if(message != null && !"".equals(message))
  {
    String suiteDir = "";
    String registeredSuite = suiteKey;

    if ( suiteKey != null && suiteKey.startsWith("eServiceSuite") )
      registeredSuite = suiteKey.substring("eServiceSuite".length());

    String stringResFileId = UINavigatorUtil.getStringResourceFileId(context, registeredSuite);
    if(stringResFileId == null || stringResFileId.length()==0)
      stringResFileId="emxFrameworkStringResource";

    String alertMessage = i18nNow.getI18nString(message, stringResFileId, Request.getLanguage(request));
    if ((alertMessage == null) || ("".equals(alertMessage)))
    {
      alertMessage = message;
    }

alertMessage = FrameworkUtil.findAndReplace(alertMessage,"\n","\\n");
alertMessage = FrameworkUtil.findAndReplace(alertMessage,"\r","\\r");

%>
<script language="javascript">
//XSSOK
if(("<%=alertMessage%>" != "") && ("<%=alertMessage%>" != null))
{
  alert("<xss:encodeForJavaScript><%=alertMessage%></xss:encodeForJavaScript>");
}
</script>
<%
}
if(action.equalsIgnoreCase("STOP"))
{
%>
<script language="javascript">

var topPage = getTopWindow().document.location.href;
if(topPage.indexOf("emxNavigator.jsp") > 0) {
  document.location.href = "emxBlank.jsp";
} else {
  getTopWindow().closeWindow(); // only for Popup
}

</script>
<%
}
else if(action.equalsIgnoreCase("CONTINUE"))
{
  if(objectList != null && objectList.size() > 0)
  {
    tableBean.setEditObjectList(context, timeStamp, objectList,null);
  }
}
}
%>
