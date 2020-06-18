<%--  emxFormEditCancelProcess.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFormEditCancelProcess.jsp.rca 1.7 Wed Oct 22 15:48:51 2008 przemek Experimental przemek $
--%>

<%@page import="javax.json.JsonObject"%>
<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="formEditBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<% 
    String timeStamp = emxGetParameter(request, "timeStamp");
    String suiteKey = emxGetParameter(request, "suiteKey");
    String action   = emxGetParameter(request, "action");
    String cancelAction   = emxGetParameter(request, "cancelAction");
    HashMap formMap = formEditBean.getFormData(timeStamp);

    if(formMap != null)
    {
      HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
  
      //Added for cancel process support
      String cancelProcessURL = emxGetParameter(request, "cancelProcessURL");
      String cancelProcessJPO = emxGetParameter(request, "cancelProcessJPO");

      String message="";
      HashMap returnMap = new HashMap();
  try {

      ContextUtil.startTransaction(context, false);

 	  if("cancel".equalsIgnoreCase(action) || "cancel".equalsIgnoreCase(cancelAction))
      {
      
      //added for cancelProcessURL parameter
      if (cancelProcessURL!= null && !"".equals (cancelProcessURL))
      {
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
          <jsp:include page = "<%=cancelProcessURL%>" flush="true" />
      <%
      }
      //added for cancelProcessJPO parameter 
      if(cancelProcessJPO != null && !"".equals(cancelProcessJPO) && cancelProcessJPO.indexOf(":") > 0)
      {
        HashMap programMap = new HashMap(6);
        HashMap paramMap = new HashMap(6);

        Enumeration paramNames = emxGetParameterNames(request);
        while(paramNames.hasMoreElements()) {
          String paramName = (String)paramNames.nextElement();
          String paramValue = emxGetParameter(request,paramName);
          paramMap.put(paramName, paramValue);
        }
        programMap.put("requestMap", requestMap);
        programMap.put("paramMap", paramMap);
        programMap.put("formMap", formMap);
  
        String[] methodargs = JPO.packArgs(programMap);
        String strJPOName = cancelProcessJPO.substring(0, cancelProcessJPO.indexOf(":"));
        String strMethodName = cancelProcessJPO.substring (cancelProcessJPO.indexOf(":") + 1, cancelProcessJPO.length());
        FrameworkUtil.validateMethodBeforeInvoke(context, strJPOName, strMethodName,"cancelProcess");
        try {
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
            
            String alertMessage = EnoviaResourceBundle.getProperty(context, stringResFileId, new Locale(request.getHeader("Accept-Language")), message);            
            if ((alertMessage == null) || ("".equals(alertMessage)))
            {
              alertMessage = message;
            }
            
            alertMessage = FrameworkUtil.findAndReplace(alertMessage,"\n","\\n");
        alertMessage = FrameworkUtil.findAndReplace(alertMessage,"\r","\\r");

out.clear();%><%=XSSUtil.encodeForJavaScript(context, alertMessage)%><%
          }
        }
      }
     }
        
      // Clean the session HashMap for this entry with timestamp
      formEditBean.removeFormData(timeStamp);

      // Cleanup if any table is embeded into the form
      MapList fields = formEditBean.getFormFields(formMap);
      
      for (int i=0; i < fields.size(); i++)
      {
          HashMap field = (HashMap)fields.get(i);
          if (formEditBean.isTableField(field))
          {
              tableBean.removeTableDataMaps(timeStamp + formEditBean.getName(field));
          }
      }


      } catch (Exception ex) {
          ContextUtil.abortTransaction(context);
          if (ex.toString() != null && (ex.toString().trim()).length() > 0)
              emxNavErrorObject.addMessage(ex.toString().trim());
          %><%@include file = "emxNavigatorBottomErrorInclude.inc"%><%
      } finally {
          ContextUtil.commitTransaction(context);
      }
    }
%>
