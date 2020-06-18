<%--  smaTemplateTableEditProcess.jsp
        This JSP is strictly for use of oneClick Template Edit Process for Dashboard.
        For any queries contact Experience Studio team.
--%>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
    String isPopup = emxGetParameter(request, "isPopup");
    String TEMPLATE_EDIT_TIMESTAMP = emxGetParameter(request, "TEMPLATE_EDIT_TIMESTAMP");
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
    %>
    <script type="text/JavaScript">
       alert("<%=strExceptionMessage%>");
    </script>
    <% 
    updateComplete = false;
  }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="JavaScript">
    var isPortal = ("<%=XSSUtil.encodeForJavaScript(context,portalMode)%>" == "true")?true:false;

<%
        if (updateComplete)
        {
%>
            console.log("post a refresh postMessage");
            var refreshMsg = {
               TEMPLATE_EDIT_TIMESTAMP : "<%=TEMPLATE_EDIT_TIMESTAMP%>",
               OPERATION : "refresh"
           };
           var contentFrame = getTopWindow().top;
           refreshMsg = JSON.stringify(refreshMsg);
           contentFrame.postMessage(refreshMsg, "*");
           //parent.document.location.reload();
                
<%
        }  else {
            %>          
            console.log("Error : Unable to Save Template Options");
 <%
        }
%>
</script>
