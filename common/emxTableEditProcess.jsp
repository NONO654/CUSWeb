<%--  emxTableEditProcess.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTableEditProcess.jsp.rca 1.25.2.1 Tue Dec 16 05:36:17 2008 ds-smahapatra Experimental $
--%>
<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%
    String isPopup = emxGetParameter(request, "isPopup");
    String timeStamp = emxGetParameter(request, "timeStamp");
    String portalMode = emxGetParameter(request, "portalMode");
    HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
    String suiteKey = (String)requestMap.get("suiteKey");
    HashMap requestValuesMap = UINavigatorUtil.getRequestParameterValuesMap(request);
    requestMap.put("RequestValuesMap", requestValuesMap);
    HashMap tableData = tableBean.getTableData(timeStamp);
    // time zone to be used for the date fields
    String timeZone = (String)session.getAttribute("timeZone");

    //Added for post process
    String objectId = (String)requestMap.get("objectId");
    String relId = (String)requestMap.get("relId");
    String cancelProcessURL = (String)requestMap.get("cancelProcessURL");
    String cancelProcessJPO = (String)requestMap.get("cancelProcessJPO");
    String invokeEditDirectly = (String)requestMap.get("invokeEditDirectly");
    String postProcessJPO = (String)requestMap.get("postProcessJPO");
    String postProcessURL = (String)requestMap.get("postProcessURL");
    String stopOOTBRefresh = (String)requestMap.get("stopOOTBRefresh");
    String cancelProcessParamExists = "false";
	String isApply = (String)requestMap.get("isApply");

	if(cancelProcessURL != null || cancelProcessJPO != null) {
		cancelProcessParamExists = "true";
	}

    String action="CONTINUE"; // Default Action is Continue - Commits transaction
    String message="";
    HashMap returnMap = new HashMap();

  boolean updateComplete = true;
  try {
    //Added for Post Process
    ContextUtil.startTransaction(context, true);
    tableData = tableBean.updateTableObjects(context, requestMap, tableData, timeZone);
    tableBean.setTableData(timeStamp, tableData);
    MapList relBusObjList = tableBean.getFilteredObjectList(tableData);
    if (relBusObjList != null && relBusObjList.size() > 0) {
      Map objectMap = (Map) relBusObjList.get(0);

      MapList columns = tableBean.getColumns(tableData);
      for (int j = 0; j < columns.size(); j++) {
        HashMap columnMap = (HashMap) columns.get(j);
        objectMap.remove(tableBean.getName(columnMap));
      }
    }

    //Added for postProcessURL parameter
    if (postProcessURL!= null && !"".equals (postProcessURL))
    {
          request.setAttribute("context", context);
          try
          {
          %>
          <!-- //XSSOK --> 
          <jsp:include page="<%=postProcessURL%>" flush="true" />
          <%
          }
          catch (ServletException se)
          {
//           Rethrow the root cause exception
          Throwable ex = se.getRootCause();
          while (ex instanceof ServletException)
          {
          se = (ServletException)ex;
          ex = se.getRootCause();
          }
          throw (ex != null) ? ex : se;
          }
             //
             // The exception thrown from postProcess page contains an error message, when it is caught by this page
             // the error message from exception object is replaced by the code of the JSP page which throws exception.
             // Therefore the error that is shown in alert box is improper. After analysis it is found that, this is due to latest
             // versions of the application server (ex Tomcat 6.0.14), while the earlier versions are working fine (Tomcat 5.0 etc)
             // Following solution is devised, where the error from the included JSP page is shared through the common request object.
             // If the request object contains error message then it is thrown as exception.
             //
             String strErrorMessage = (String)request.getAttribute("error.message");
             if (strErrorMessage != null) {
                    request.removeAttribute("error.message");
                 throw new Exception (strErrorMessage);
             }

    }
    //Added for postProcessJPO
    if(postProcessJPO != null && !"".equals(postProcessJPO) && postProcessJPO.indexOf(":") > 0)
    {
         HashMap programMap = new HashMap();
         HashMap paramMap = new HashMap();

         Enumeration paramNames = emxGetParameterNames(request);
         while(paramNames.hasMoreElements()) {
          String paramName = (String)paramNames.nextElement();
          String paramValue = emxGetParameter(request,paramName);
          paramMap.put(paramName, paramValue);
         }
         //Added for EditAction paramter
         paramMap.put("EditAction", "done");
         programMap.put("requestMap", requestMap);
         programMap.put("paramMap", paramMap);
         programMap.put("tableData", tableData);

         String[] methodargs = JPO.packArgs(programMap);
         String strJPOName = postProcessJPO.substring(0, postProcessJPO.indexOf(":"));
         String strMethodName = postProcessJPO.substring (postProcessJPO.indexOf(":") + 1, postProcessJPO.length());
         try {
        	FrameworkUtil.validateMethodBeforeInvoke(context, strJPOName, strMethodName,"postProcess");	 
          returnMap = (HashMap)JPO.invoke(context, strJPOName, null, strMethodName, methodargs, HashMap.class);
         } catch (Exception exJPO) {
               throw (new FrameworkException(exJPO.toString()));
         }
         if(returnMap != null && returnMap.size() > 0)
         {
           HashMap newTableData = (HashMap)returnMap.get("tableData");
           if (newTableData != null)
           {
             tableData = newTableData;
             tableBean.setTableData(timeStamp, tableData);
           }

           message = (String)returnMap.get("Message");
           action  = (String)returnMap.get("Action");
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
                alertMessage = FrameworkUtil.findAndReplace(alertMessage,"\"", "\\\"");
%>
<script language="javascript" type="text/javaScript">
alert("<xss:encodeForJavaScript><%=alertMessage%></xss:encodeForJavaScript>");
</script>
<%
           }
        }
     }

    if(action!=null && action.equalsIgnoreCase("continue"))
        {
            ContextUtil.commitTransaction(context);
            updateComplete = true;
    }
    else
        {
            ContextUtil.abortTransaction(context);
            updateComplete = false;
    }

  } catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    // Show the error message, only show the message and not exception object name
    String strExceptionMessage = ex.getMessage().trim();
    if (strExceptionMessage == null || "".equals(strExceptionMessage)) {
        strExceptionMessage = ex.toString().trim();
    }
    emxNavErrorObject.addMessage(strExceptionMessage);

    updateComplete = false;
  }
  HashMap tableControlMap = tableBean.getControlMap(tableData);
%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
<script language="JavaScript">
    var isPortal = ("<%=XSSUtil.encodeForJavaScript(context,portalMode)%>" == "true")?true:false;

<%
        if (updateComplete)
        {
            if ("true".equalsIgnoreCase(isPopup))
            {
%>
                try
                {

                    var myFrame = findFrame(getTopWindow().getWindowOpener(),"listDisplay");
                    if(myFrame == null)
                    {
                        myFrame = findFrame(getTopWindow().getWindowOpener().parent,"listDisplay");
                    }

<%
                    if(tableBean.isReloadTable(context, tableControlMap))
                    {
%>
                        myFrame = myFrame.parent;
<%
                    }
                    else
                    {
                        tableBean.setEditObjectList(context, timeStamp, null);
                    }
%>

                    if (getTopWindow().getWindowOpener() != null && !getTopWindow().getWindowOpener().closed)
                    {
                        if (getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().getTopWindow().modalDialog)
                        {
                            if(!(getTopWindow().getWindowOpener().getTopWindow().modalDialog.contentWindow.closed))
                            {
                                getTopWindow().getWindowOpener().getTopWindow().modalDialog.releaseMouse();
                            }
                        }
                    }
                }catch(e)
                {
                    //alert if anything other than permission denied
                  if(-2146828218 != e.number && -2147418094 != e.number)
                  {
         			if(e.description == ""){
							alert(emxUIConstants.STR_JS_AnExceptionOccurred + " " + emxUIConstants.STR_JS_ErrorName + " " + e.name
         	    				+ emxUIConstants.STR_JS_ErrorDescription + " " + e.description
         	    				+ emxUIConstants.STR_JS_ErrorNumber + " " + e.number
         	    				+ emxUIConstants.STR_JS_ErrorMessage + " " + e.message);
         	    	} else {
                        alert(e.description);
                    }
               	   }
               	}
<%
                if(tableBean.isReloadTable(context, tableControlMap))
                {
%>
                    myFrame = myFrame.parent;
<%
                }
                else
                {
                    tableBean.setEditObjectList(context, timeStamp, null);
                }
%>
           <%if(stopOOTBRefresh == null || "null".equalsIgnoreCase(stopOOTBRefresh)|| !"false".equalsIgnoreCase(stopOOTBRefresh)){%>
                if (getTopWindow().getWindowOpener() != null && !getTopWindow().getWindowOpener().closed)
                {
                    if (getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().getTopWindow().modalDialog)
                    {
                        if(!(getTopWindow().getWindowOpener().getTopWindow().modalDialog.contentWindow.closed))
                        {
                            getTopWindow().getWindowOpener().getTopWindow().modalDialog.releaseMouse();
                        }
                    }
                }

                if(myFrame != null)
                {
                    // Modified for bug no 344864
                    if(myFrame.parent.document.location.href.indexOf("selectedFilter") > -1){
                        //added for bug - 344302-(1)
                        getTopWindow().getWindowOpener().onFilterOptionChange();
                    }else{
                        myFrame.document.location.href = myFrame.document.location.href;
                    }
                    // Till here
                }
<%
          }
            }
            else {
                if (!"true".equalsIgnoreCase(invokeEditDirectly) && !"false".equalsIgnoreCase(cancelProcessParamExists))

            {
%>
                parent.document.location.reload()
<%
            }else{
                %>
                
                var bodyFrame = findFrame(parent, "formEditDisplay");
	            if(bodyFrame)
	            {
	                bodyFrame.setTableFormSubmitAction(true);
	            }
	            else
	            {
	                parent.setTableFormSubmitAction(true);
	            }
	            getTopWindow().turnOffProgress();
            
            <%
            }
            }
        }
        else
        {
%>
            parent.document.forms[0].clearEditObjList.value = "true";
            parent.document.forms[0].cancelProcess.value = "true";
            var bodyFrame = findFrame(parent, "formEditDisplay");
            if(bodyFrame)
            {
                bodyFrame.setTableFormSubmitAction(true);
            }
            else
            {
                parent.setTableFormSubmitAction(true);
            }
            getTopWindow().turnOffProgress();
            getTopWindow().closeWindow(<%=XSSUtil.encodeForJavaScript(context,isPopup)%>);
<%
        }
	if (isApply!=null && isApply.equalsIgnoreCase("true"))
        {
%>
	getTopWindow().turnOffProgress();
		
<%
        }
		
        else if (updateComplete & "true".equalsIgnoreCase(isPopup))
        {
%>
          getTopWindow().closeWindow();
<%
        }
%>
</script>
