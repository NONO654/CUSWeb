<%--  emxTableBody.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTableBody.jsp.rca 1.45.2.1 Tue Dec 23 03:20:14 2008 ds-arajendiran Experimental $
--%>
<%@include file = "emxNavigatorInclude.inc"%>


<html>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxNavigatorTimerTop.inc"%>
<%@ page import = "com.matrixone.apps.framework.ui.UIUtil,
                   com.matrixone.apps.domain.util.XSSUtil"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%
String timeStamp = emxGetParameter(request, "timeStamp");
//added for 310470 till here (get the TransactionType and decides the mode of transaction
String transactionType = emxGetParameter(request, "TransactionType");

boolean updateTransaction = (transactionType != null && transactionType.equalsIgnoreCase("update"));
//till here

//Added to append the showRMB and uitype for table for RMB Feature
String appendParams = "timeStamp=" + timeStamp + "&portalCmdName=" + emxGetParameter(request, "portalCmdName") + "&TransactionType=" +transactionType+"&uiType=table";
// This one is added to recalculate the calculations if one of the object is updated using the web form

try {

//modified for 310470
    //ContextUtil.startTransaction(context, false);
    ContextUtil.startTransaction(context, updateTransaction);
//till here

    HashMap tableControlMapTemp = tableBean.getControlMap(timeStamp);
    boolean bDataLoaded = ((Boolean)tableControlMapTemp.get("DataLoaded")).booleanValue();
    HashMap requestMap = tableBean.getRequestMap(timeStamp);

    //Only set table data if it is not yet set
    if(!bDataLoaded)
    {
        //set data objects in Table bean
        tableBean.setTableObjects(context, timeStamp);

        // Sort the table data
        String sortColumnName = emxGetParameter(request, "sortColumnName");
        
        String customSortColumns = (String)requestMap.get("customSortColumns");
        
        if ( (sortColumnName != null && sortColumnName.trim().length() > 0 && (!(sortColumnName.equals("null"))) ) 
                || (customSortColumns != null && customSortColumns.trim().length() > 0 && (!(customSortColumns.equals("null"))) ) )
        {
            tableBean.sortObjects(context, timeStamp);
        }
    }

    HashMap tableControlMap = tableBean.getControlMap(timeStamp);
    String clearValuesMap = emxGetParameter(request, "clearValuesMap");
   
    //HashMap tableControlMap = tableBean.getControlMap(timeStamp);

    boolean rememberSelction = ((Boolean)tableControlMap.get("RememberSelection")).booleanValue();

    String objectId = (String)requestMap.get("objectId");
    String objectName = (String)requestMap.get("objectName");
    String relId = (String)requestMap.get("relId");
    String jsTreeID = (String)requestMap.get("jsTreeID");
    String portalMode = (String)requestMap.get("portalMode");
    String portalCmdName = (String)requestMap.get("portalCmdName");
    String showRMB = (String)requestMap.get("showRMB");
    String parentOID = objectId;
    String reportFormat = emxGetParameter(request, "reportFormat");
    boolean reportMode = false;
    if (reportFormat != null && (reportFormat.equals("HTML") || reportFormat.equals("ExcelHTML")))
        reportMode = true;

    String selection = (String)tableControlMap.get("Selection");

    String inquiryList = (String)requestMap.get("inquiry");
    String programList = (String)requestMap.get("program");
    //suiteKey
    String suiteKey = (String)requestMap.get("suiteKey");
	String tableName =(String)requestMap.get("table");
	String title_prefix = UINavigatorUtil.getI18nString("emxFramework.WindowTitle.Body", "emxFrameworkStringResource", Request.getLanguage(request));
    String title = title_prefix + (String)requestMap.get("table") + "_";

    if (inquiryList != null && inquiryList.trim().length() > 0 )
    {
        title += inquiryList;
    } else if (programList != null && programList.trim().length() > 0 )
    {
        title += programList;
    }

    // Assign the style sheet to be used based on the input
    String cssFile = EnoviaResourceBundle.getProperty(context, "emxNavigator.UITable.Style.List");
    boolean useDefaultCSS=false;
    if ( cssFile == null || cssFile.trim().length() == 0){
        useDefaultCSS=true;
    }
%>

<head>
  <title><xss:encodeForHTML><%=title%></xss:encodeForHTML></title>
  <%@include file = "emxUIConstantsInclude.inc"%>
  <%@include file = "../emxStyleDefaultInclude.inc"%>

    <%
     if(useDefaultCSS)
     {
     %>
      <%@include file = "../emxStyleListInclude.inc"%>
     <%}else{
     %>
     <script>
          //XSSOK
          addStyleSheet("<%=cssFile%>");
    </script>
    <% }
    %>
    <script>
          addStyleSheet("emxUIMenu");
<%
		if(portalMode != null && "true".equalsIgnoreCase(portalMode) && !reportMode) {
%>
          addStyleSheet("emxUIChannelList");          
<%
		}
%>
    </script>

  <script language="JavaScript" src="scripts/emxUIModal.js" type="text/javascript"></script>
  <script language="JavaScript" src="scripts/emxUIToolbar.js" type="text/javascript"></script>
  <script language="JavaScript" type="text/javascript" src="scripts/emxUICore.js"></script>
  <script language="JavaScript" src="scripts/emxUITableUtil.js" type="text/javascript"></script>
  <script language="JavaScript" src="scripts/emxUIPopups.js" type="text/javascript"></script>
    <script language="JavaScript">
		var strPageIDs = "~";
		emxUICore.addEventHandler(window, "load", function(){attachRMBAttribute('<xss:encodeForJavaScript><%=tableName%></xss:encodeForJavaScript>');attachTDAttribute('<xss:encodeForJavaScript><%=tableName%></xss:encodeForJavaScript>');});
	 </script>
	 <!-- Includes js and jps files -->
	 <%
    	StringList incFileList = UIForm.getJSValidationFileList(context, suiteKey);
    	String fileTok = "";
    	for(StringItr keyItr = new StringItr(incFileList); keyItr.next();)
    	{
        	fileTok = keyItr.obj();
        	if(fileTok.endsWith(".jsp")) {
	%>
	<!-- //XSSOK -->
            	<jsp:include page = "<%=fileTok%>" flush="true" />
	<%
        		} else if(fileTok.endsWith(".js")) {
	%>
	<!-- //XSSOK -->
        <script language="javascript" src="<%=fileTok%>"></script>
	<%
        	}
    	}
	%>
	 <!-- Ends inclusion -->
</head>

<body class="properties" onload="doCheckUpdate(); turnOffProgress();">
<form name="emxTableForm" method="post" onSubmit="javascript:submitTable(); return false">

<jsp:include page = "emxTableDataInclude.jsp" flush="true">
    <jsp:param name="timeStamp" value="<%=XSSUtil.encodeForURL(context, timeStamp)%>"/>
    <jsp:param name="clearValuesMap" value="<%=XSSUtil.encodeForURL(context, clearValuesMap)%>"/>
</jsp:include>

<input type="hidden" name="timeStamp" value="<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="objectName" value="<xss:encodeForHTMLAttribute><%=objectName%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="relId" value="<xss:encodeForHTMLAttribute><%=relId%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="parentOID" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="portalCmdName" value="<xss:encodeForHTMLAttribute><%=portalCmdName%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="uiType" value="table" />
<input type="hidden" name="table" value="<xss:encodeForHTMLAttribute><%=tableName%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="showRMB" id="showRMB" value="<xss:encodeForHTMLAttribute><%=showRMB%></xss:encodeForHTMLAttribute>"/>

<%if (!rememberSelction) { %>
<script language="JavaScript"> parent.ids = "~"; </script>
<%
}
    if (!selection.equalsIgnoreCase("single")) {
%>

<script language="JavaScript">
    if (typeof parent.ids == "string") {

        var arrTemp = parent.ids.split("~");

        arrTemp.length = arrTemp.length - 1;
        var strTemp = "";
        for (var i=1; i < arrTemp.length; i++)
        {
            if (strPageIDs.indexOf("~" + arrTemp[i] + "~") == -1) {
                document.write("<input type=\"hidden\" name=\"emxTableRowId\" value=\"" + arrTemp[i] + "\" />");
                strTemp += arrTemp[i] + "\n";
            }
        }
    }
</script>
<%
}
    ContextUtil.commitTransaction(context);

} catch (Exception ex) {
    ContextUtil.abortTransaction(context);

    if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        emxNavErrorObject.addMessage("emxTableBody:" + ex.toString().trim());

}

%>
</form>
<%@include file = "emxNavigatorTimerBottom.inc"%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
