<%--  emxTableReportView.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTableReportView.jsp.rca 1.27 Wed Oct 22 15:48:09 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<html>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@ page import="java.text.*"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%

String timeStamp = Request.getParameter(request, "timeStamp");
String transactionType = emxGetParameter(request, "TransactionType");
boolean updateTransaction = (transactionType != null && transactionType.equalsIgnoreCase("update"));

try {
    ContextUtil.startTransaction(context, updateTransaction);

    HashMap tableControlMapTemp = tableBean.getControlMap(timeStamp);
    boolean bDataLoaded = ((Boolean)tableControlMapTemp.get("DataLoaded")).booleanValue();

    //Only set table data if it is not yet set
    if(!bDataLoaded)
    {
        //set data objects in Table bean
        tableBean.setTableObjects(context, timeStamp);

        // Sort the table data
        String sortColumnName = emxGetParameter(request, "sortColumnName");

        if (sortColumnName != null && sortColumnName.trim().length() > 0 && (!(sortColumnName.equals("null"))) )
        {
            tableBean.sortObjects(context, timeStamp);
        }
    }

    HashMap tableData = tableBean.getTableData(timeStamp);
    HashMap tableControlMap = tableBean.getControlMap(tableData);
    HashMap requestMap = tableBean.getRequestMap(tableData);
    String header = tableBean.getPageHeader(tableControlMap);
    String displayHeader = header;
    String badChars=":><[]|*/\\; ";
    char[] charArray=badChars.toCharArray();
    char repchar='_';

    String subHeader = (String)requestMap.get("subHeader");
    String languageStr = Request.getLanguage(request);
    String objectId = (String)requestMap.get("objectId");
    String suiteKey = (String)requestMap.get("suiteKey");

    //to get the dateformat
    String DateFrm = PersonUtil.getPreferenceDateFormatString(context);

    if ( (subHeader != null) && (subHeader.trim().length() > 0) )
    {
        // Add code take into consideration separator in subheader.
    	String subHeaderSeparator = UINavigatorUtil.getI18nString("emxFramework.CustomTable.Subheader.Separator", "emxFrameworkStringResource", languageStr);
    	StringList subHeaderList = FrameworkUtil.split(subHeader, subHeaderSeparator);
    	StringBuffer subHeaderBuffer = new StringBuffer();

    	for(int x = 0; x < subHeaderList.size(); x++){
    		if(x > 0) subHeaderBuffer.append(" ").append(subHeaderSeparator).append(" ");
    		subHeaderBuffer.append(UINavigatorUtil.parseHeader(context, pageContext, (String)subHeaderList.get(x), objectId, suiteKey, languageStr));
    	}
    	subHeader = subHeaderBuffer.toString();
    }
    // Get the preference settings
    // Type of the export "HTML, Excel-HTML, Excel-CSV, TXT"
    String reportFormat = Request.getParameter(request, "reportFormat");

    if (reportFormat == null || reportFormat.length() == 0)
        reportFormat = "HTML";

    requestMap.put("reportFormat",reportFormat);


    String fileEncodeType = UINavigatorUtil.getFileEncoding(context, request);
    if (reportFormat.equals("ExcelHTML"))
    {
     response.setContentType("text/html; charset="+fileEncodeType);
      String fileCreateTimeStamp = Long.toString(System.currentTimeMillis());
      String filename = header + fileCreateTimeStamp + ".html";
      filename = replaceCharacters(filename, charArray, repchar);
      filename = FrameworkUtil.encodeURL(filename,"UTF8");
      response.setHeader ("Content-Disposition","attachment; filename=\"" + filename +"\"");
      response.setLocale(request.getLocale());

      //add header information to the exported file
      String recordSeparator = "\r\n";
      out.print(displayHeader + recordSeparator);
      if (subHeader != null)
      {
         out.print(subHeader + recordSeparator);
      }
      out.print(recordSeparator);
    }

    if (reportFormat.equals("HTML"))
    {
        String userName = PersonUtil.getFullName(context);
        // Get the calendar on server
        Calendar currServerCal = Calendar.getInstance();
        Date currentDateObj = currServerCal.getTime();

        // Date Format initialization
        int iDateFormat = PersonUtil.getPreferenceDateFormatValue(context);
        String prefTimeDisp = PersonUtil.getPreferenceDisplayTime(context);

        java.text.DateFormat outDateFrmt = null;
        if (prefTimeDisp != null && prefTimeDisp.equalsIgnoreCase("true"))
        {
            outDateFrmt = DateFormat.getDateTimeInstance(iDateFormat, iDateFormat, request.getLocale());
        } else {
            outDateFrmt = DateFormat.getDateInstance(iDateFormat, request.getLocale());
        }

        currentDateObj = outDateFrmt.parse(outDateFrmt.format(currentDateObj));
        String currentTime = outDateFrmt.format(currentDateObj);

%>
<head>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "../emxStyleDefaultPFInclude.inc"%>
<%@include file = "../emxStyleListPFInclude.inc"%>
<script language="JavaScript" src="scripts/emxUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/emxUITableUtil.js" type="text/javascript"></script>
<title><xss:encodeForHTML><%=header%></xss:encodeForHTML></title>
</head>

<body>
<form name="emxTableReportForm">

        <hr noshade>
        <table border="0" width="100%" cellspacing="2" cellpadding="4">
        <tr>
            <td class="pageHeader" width="80%">
            <span class="pageHeader"><xss:encodeForHTML><%=header%> </xss:encodeForHTML>&nbsp;</span>
<%
            if (subHeader != null && subHeader.length() > 0 )
            {
                %><br/><span class="pageSubTitle"><xss:encodeForHTML><%=subHeader%> </xss:encodeForHTML>&nbsp;</span><%
            }
%>
            </td>
            <td width="1%"><img src="images/utilSpacer.gif" width="1" height="28" alt="" /></td>
            <td width="39%" align="right"></td>
            <td nowrap>
                <table>
                <tr><td nowrap=""><xss:encodeForHTML><%=userName%> </xss:encodeForHTML></td></tr>
                <!-- //XSSOK -->
                <tr><td nowrap=""><%=currentTime%></td></tr>

                <!-- //XSSOK -->
                <%-- <tr><td nowrap=""><emxUtil:lzDate localize='i18nId' tz='<%= (String)session.getAttribute("timeZone") %>' format='<%= DateFrm %>' displaydate='true' displaytime='<%=prefTimeDisp%>'><%=currentTime%></emxUtil:lzDate></td></tr> --%>
                </table>
            </td>
        </tr>
        </table>
        <hr noshade>
<%
    }
%>
    <jsp:include page = "emxTableDataInclude.jsp" flush="true">
        <jsp:param name="timeStamp" value="<%=XSSUtil.encodeForURL(context, timeStamp)%>"/>
        <jsp:param name="reportFormat" value="<%=XSSUtil.encodeForURL(context, reportFormat)%>"/>
        <jsp:param name="TransactionType" value="<%=XSSUtil.encodeForURL(context, transactionType)%>"/>
    </jsp:include>
<%
} catch (Exception ex) {
    ContextUtil.abortTransaction(context);

    if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        emxNavErrorObject.addMessage("emxTableExport:" + ex.toString().trim());

} finally {
    ContextUtil.commitTransaction(context);
    HashMap tableData = tableBean.getTableData(timeStamp);
    HashMap requestMap = tableBean.getRequestMap(tableData);
    requestMap.remove("reportFormat");
}

%>
</form>
</body>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

</html>

<%!
static public String replaceCharacters(String source, char[] charList, char replacementChar)
{
  String retString = source;
  if(retString==null)
  {
    retString="";
  }
  if(charList !=null && charList.length>0 )
  {
       for (int index = 0; index < charList.length; index++)
         {
            char sElement = charList[index];
            retString=retString.replace(sElement,replacementChar);
         }

    }

return retString;

}

%>
