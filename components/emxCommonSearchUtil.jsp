<%--  emxCommonSearchUtil.jsp  -

   Performs the action of connecting the objects by the given relationship

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonSearchUtil.jsp.rca 1.20 Wed Oct 22 16:17:46 2008 przemek Experimental przemek $";
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file  ="../emxContentTypeInclude.inc" %>

<%@page import="com.matrixone.apps.common.*"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<html>
  <body>
    <script language="javascript" src="../emxUIPageUtility.js"></script>
    <form name="searchFrom" method="post">

<%
      try {
        String timeStamp = emxGetParameter(request, "timeStamp");
        HashMap requestMap = new HashMap();
        String uiType = emxGetParameter(request, "uiType");
        if("structureBrowser".equalsIgnoreCase(uiType)){
        	requestMap = (HashMap)indentedTableBean.getRequestMap(timeStamp);
        }else{
        	requestMap = (HashMap)tableBean.getRequestMap(timeStamp);
        }         
        requestMap.remove("deleteJPO");
        requestMap.remove("deleteJPOMethod");
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
		            paramValue = null;
          }
%>
          <input type="hidden" name="<%=paramName%>" value="<xss:encodeForHTMLAttribute><%=paramValue%></xss:encodeForHTMLAttribute>"/>
<%
        }
%>
          <input type="hidden" name="previousCommand" value="<xss:encodeForHTMLAttribute><%=(String)requestMap.get("CommandName")%></xss:encodeForHTMLAttribute>"/>
<%
        String strSearchMode = (String) requestMap.get("searchmode");
        String strURL = "";
        String strSearchMenu = (String) requestMap.get("searchmenu");
        String strSearchCommand = (String) requestMap.get("searchcommand");
        String strSuiteKey = (String) requestMap.get("suiteKey");

        if (strSearchMode == null || "".equals(strSearchMode) || strSearchMode.equals("null"))
          strSearchMode = "globalsearch";

        if (strSearchMode.equals("copy") || strSearchMode.equals("replace")) {
          String selObjectId = (String)requestMap.get("emxTableRowId");
          StringBuffer strProcessURL = new StringBuffer();
          strProcessURL.append(XSSUtil.encodeForURL(context, (String) requestMap.get("processURL")));

          String isCopyFrom = (String)requestMap.get("isCopyFrom");

          String objectId = (String)requestMap.get("objectId");
          strProcessURL.append("?isCopyFrom=");
          strProcessURL.append(XSSUtil.encodeForURL(context, isCopyFrom));
          strProcessURL.append("&searchmode=");
          strProcessURL.append(XSSUtil.encodeForURL(context, strSearchMode));
          strProcessURL.append("&objectId=");
          strProcessURL.append(XSSUtil.encodeForURL(context, objectId));
          strProcessURL.append("&selObjectId=");
          strProcessURL.append(XSSUtil.encodeForURL(context, selObjectId));
          String objectIds[] = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(emxGetParameterValues(request,"emxTableRowId"));
          StringBuffer Ids = new StringBuffer();
          String isNewSearch = emxGetParameter(request,"isNewSearch");
          if("false".equals(isNewSearch)) {
            for(int i=0;i<objectIds.length;i++) {
              Ids.append(objectIds[i]);
              if(i != objectIds.length) {
                Ids.append("|");
              }
            }
            strProcessURL.append("&emxTableRowId=");
            strProcessURL.append(XSSUtil.encodeForURL(context, Ids.toString()));
            strURL = strProcessURL.toString();
%>
            <script language = "javascript">
            //XSSOK
              document.searchFrom.action=fnEncode("<%=strURL%>");
            </script>
<%
          } else {

%>
            <script language = "javascript">
              document.searchFrom.action="../components/emxCommonSearch.jsp";
            </script>
<%
          }
        } else {
%>
          <script language = "javascript">
            document.searchFrom.action="../components/emxCommonSearch.jsp";
          </script>
<%
        }
%>
          <script language = "javascript">
			document.searchFrom.target = "_top";
            document.searchFrom.submit();
          </script>
<%
      } // End of try
      catch(Exception ex) {
         session.putValue("error.message", ex.getMessage());
       } // End of catch
%>
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

    </form>
  </body>
</html>
