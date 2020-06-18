<%--  emxTableEditProcess.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTableEditCancelProcess.jsp.rca 1.8 Wed Oct 22 15:48:32 2008 przemek Experimental przemek $
--%>
<%@page import="javax.json.JsonObject"%>
<%@include file="emxNavigatorInclude.inc"%>
<html>
<head>
<title>Table Edit Form Cancel processing</title>
</head>
<%@include file="emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="tableBean"
	class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<script language="JavaScript" type="text/javascript"
	src="scripts/emxUITableUtil.js"></script>
<%
    String strAlertNewlyAddedorDeleted = UINavigatorUtil.getI18nString("emxFramework.TableEdit.AlertNewlyAddedorDeleted", "emxFrameworkStringResource", Request.getLanguage(request));
    String timeStamp = emxGetParameter(request, "timeStamp");
    HashMap tableData = tableBean.getTableData(timeStamp);
    HashMap tableControlMap = tableBean.getControlMap(tableData);

    //Added for cancel process support
    HashMap requestMap = tableBean.getRequestMap(timeStamp);
    String objectId = (String)requestMap.get("objectId");
    String relId = (String)requestMap.get("relId");
    String cancelProcessURL = (String)requestMap.get("cancelProcessURL");
    String cancelProcessJPO = (String)requestMap.get("cancelProcessJPO");
    String invokeEditDirectly = (String)requestMap.get("invokeEditDirectly");
    String suiteKey = (String)requestMap.get("suiteKey");
    String message="";
    HashMap returnMap = new HashMap();
    String strcancelProcess = (String)emxGetParameter(request,"cancelProcess");

 try {

    //added for cancelProcessURL parameter
    if (cancelProcessURL!= null && !"".equals (cancelProcessURL))
    {
      java.util.Set paramNames = requestMap.keySet();
      Iterator iter = paramNames.iterator();
      StringBuffer newURL = new StringBuffer(paramNames.size()*10);

      boolean firstItem = true;
      String paramName = "";
      while(iter.hasNext())
      {
      	if(firstItem)
        {
        	firstItem = false;
        }
        else
        {
	        newURL.append("&");
        }
        paramName = (String)iter.next();
        newURL.append(paramName).append("=");
        newURL.append(XSSUtil.encodeForURL(context, requestMap.get(paramName).toString()));
      }

      if((cancelProcessURL.indexOf("?") == -1))
      {
	      cancelProcessURL += "?";
      }
      else
      {
      	cancelProcessURL += "&";
      }

      cancelProcessURL += newURL.toString();

      request.setAttribute("context", context);
      JsonObject tokenJson =  ENOCsrfGuard.getCSRFTokenJson_New(context,session);
  	String tokenName = tokenJson.getString(ENOCsrfGuard.CSRF_TOKEN_NAME);
  	String tokenValue = tokenJson.getString(tokenName);
  	request.setAttribute("context", context);
	StringBuffer url = new StringBuffer();
	url.append(ENOCsrfGuard.CSRF_TOKEN_NAME);
	url.append("=");
	url.append(tokenName);
	url.append("&");
	url.append(tokenName);
	url.append("=");
	url.append(tokenValue);
  	if(cancelProcessURL.indexOf("?")!=-1){
  		cancelProcessURL+="&"+url.toString();
  	}
  	else{
  		cancelProcessURL+="?"+url.toString();
  	}
    %>
<!-- //XSSOK -->
<jsp:include page="<%=cancelProcessURL%>" flush="true" />
<%
    }
    //added for cancelProcessJPO parameter
    if(cancelProcessJPO != null && !"".equals(cancelProcessJPO) && cancelProcessJPO.indexOf(":") > 0 && "true".equals(strcancelProcess))
    {
      HashMap programMap = new HashMap();
      HashMap paramMap = new HashMap();

      paramMap.put("objectId", objectId);
      paramMap.put("relId", relId);
      programMap.put("requestMap", requestMap);
      programMap.put("paramMap", paramMap);
      programMap.put("tableData", tableData);

      String[] methodargs = JPO.packArgs(programMap);
      String strJPOName = cancelProcessJPO.substring(0, cancelProcessJPO.indexOf(":"));
      String strMethodName = cancelProcessJPO.substring (cancelProcessJPO.indexOf(":") + 1, cancelProcessJPO.length());
      try {
		FrameworkUtil.validateMethodBeforeInvoke(context, strJPOName, strMethodName,"cancelProcess");
        returnMap = (HashMap)JPO.invoke(context, strJPOName, null, strMethodName, methodargs, HashMap.class);
      } catch (Exception exJPO) {
             throw (new FrameworkException(exJPO.toString()));
      }
      if(returnMap != null)
      {
        message = (String)returnMap.get("Message");
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
<script language="javascript" type="text/javaScript">
alert("<xss:encodeForJavaScript><%=alertMessage%></xss:encodeForJavaScript>");
</script>
<%
        }
      }
    }




%>


<script language="JavaScript">
<%
  if(tableBean.isReloadTable(context, tableControlMap)) {
%>
    //XSSOK
    alert("<%=strAlertNewlyAddedorDeleted%>");
    if(getTopWindow().modalDialog){
      getTopWindow().modalDialog.releaseMouse();
    }

    parent.document.location.reload();
<%
  }

  tableBean.setEditObjectList(context, timeStamp, null);

  if(invokeEditDirectly != null && "true".equalsIgnoreCase(invokeEditDirectly)) {
%>
    cleanupSession('<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>');
<%
  }
%>
</script>

<%
} catch (Exception ex)
{
	if (ex.toString() != null && (ex.toString().trim()).length() > 0)
	{
		emxNavErrorObject.addMessage(ex.toString().trim());
	}
}

%>


<%@include file="emxNavigatorBottomErrorInclude.inc"%>
</html>


