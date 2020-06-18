<%-- emxTablePortalHeader.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTablePortalHeader.jsp.rca 1.16.2.1 Tue Dec 16 06:46:24 2008 ds-smahapatra Experimental $
--%>

<html>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxNavigatorTimerTop.inc"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%
    String progressImage = "../common/images/utilProgressBlue.gif";
    String timeStamp = emxGetParameter(request, "timeStamp");
	String appendParams = "timeStamp=" + XSSUtil.encodeForURL(context, timeStamp) + "&portalCmdName=" + XSSUtil.encodeForURL(context,emxGetParameter(request, "portalCmdName"))  + "&TransactionType=" + XSSUtil.encodeForURL(context, emxGetParameter(request, "TransactionType")) + "&sortColumnName=" + XSSUtil.encodeForURL(context, emxGetParameter(request, "sortColumnName"));
    String tableBodyURL = "emxTableBody.jsp?" + appendParams;
    try {

        ContextUtil.startTransaction(context, false);

        // Get Table Data from session level Table bean
        HashMap tableData = tableBean.getTableData(timeStamp);
        HashMap tableControlMap = tableBean.getControlMap(tableData);
        HashMap requestMap = tableBean.getRequestMap(tableData);

        String objectId = (String)requestMap.get("objectId");
        String relId = (String)requestMap.get( "relId");
        String topActionbar = (String)requestMap.get("topActionbar");
        String bottomActionbar = (String)requestMap.get("bottomActionbar");
        String toolbar = (String)requestMap.get("toolbar");
        String editLink = (String)requestMap.get("editLink");
        String header = tableBean.getPageHeader(tableControlMap);
        String inquiryList = (String)requestMap.get("inquiry");
        String inquiryLabel = (String)requestMap.get("inquiryLabel");
        String programList = (String)requestMap.get("program");
        String programLabel = (String)requestMap.get("programLabel");
        String selectedFilter = (String)requestMap.get("selectedFilter");
        String suiteKey = (String)requestMap.get("suiteKey");

		String sHelpMarker = (String)requestMap.get("HelpMarker");
        String tipPage = (String)requestMap.get("TipPage");
        String printerFriendly = (String)requestMap.get("PrinterFriendly");
        String showPageURLIcon = (String)requestMap.get("showPageURLIcon");
        String export = (String)requestMap.get("Export");
        String objectBased = (String)requestMap.get("objectBased");
        String objectCompare = (String)requestMap.get("objectCompare");
		String selection=(String)requestMap.get("selection");
		boolean hasNumericColumn = tableBean.hasNumericColumnForCalculations(context, tableData);
        boolean showChartIcon = hasNumericColumn;
        boolean showCalcIcon = hasNumericColumn;
          
        String calculations = (String)requestMap.get("calculations");
        if(calculations != null && "false".equalsIgnoreCase(calculations)) {
            showCalcIcon = false;
        }

        String chart = (String)requestMap.get("chart");
        if(chart != null && "false".equalsIgnoreCase(chart)) {
            showChartIcon = false;
        }

		StringBuffer title = new StringBuffer(50);
		title.append("header_");
		title.append(XSSUtil.encodeForHTML(context, (String)requestMap.get("table")));
		title.append("_");

      StringList filterStrList = new StringList();
      StringList filterLabelStrList = new StringList();

        // Get the list of enquiries and label
        if (inquiryList != null && inquiryList.trim().length() > 0 )
        {
            title.append(XSSUtil.encodeForHTML(context, inquiryList));
            if (inquiryList.indexOf(",") > 0 )
                filterStrList = FrameworkUtil.split(inquiryList, ",");

            if (inquiryLabel != null && inquiryLabel.trim().length() > 0 )
            {
                if (inquiryLabel.indexOf(",") > 0 )
                    filterLabelStrList = FrameworkUtil.split(inquiryLabel, ",");
            }
        } else if (programList != null && programList.trim().length() > 0 )
        {
            title.append(XSSUtil.encodeForHTML(context, programList));
            if (programList.indexOf(",") > 0 )
                filterStrList = FrameworkUtil.split(programList, ",");

            if (programLabel != null && programLabel.trim().length() > 0 )
            {
                if (programLabel.indexOf(",") > 0 )
                    filterLabelStrList = FrameworkUtil.split(programLabel, ",");
            }
        }
%>

<head>
    <!-- //XSSOK -->
    <title><%=title.toString()%></title>
	<%@include file = "emxUIConstantsInclude.inc"%>
	<%@include file = "../emxStyleDefaultInclude.inc"%>

	<script type="text/javascript">
        addStyleSheet("emxUIChannelDefault");
		addStyleSheet("emxUIToolbar");
		addStyleSheet("emxUIMenu");
	</script>

	<script language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
	<script language="JavaScript" src="scripts/emxUIToolbar.js"></script>
    <script language="javascript" type="text/javascript" src="scripts/emxUIModal.js"></script>
    <script language="javascript" type="text/javascript" src="scripts/emxNavigatorHelp.js"></script>
    <script language="JavaScript" type="text/javascript" src="scripts/emxUITableUtil.js"></script>
</head>

<body onLoad="loadDisplayFrame('<%=tableBodyURL%>')">
<form name="tableHeaderForm" method="post">
      <div class="filter-row">
	  <table border="0" width="100%" cellspacing="0" cellpadding="0">
      <tbody>
      <tr>
      

<td><div id="imgProgressDiv">&nbsp;<img src="<%=progressImage%>" width="21" height="19" name="progress" />&nbsp;</div></td>
<td style="padding-left: 10px; padding-top: 3px;"></td>
<%
          if (filterStrList != null && filterStrList.size() > 1)
          {
%>
            <td align="right"><select class="filter"  name="filterTable" onChange="onFilterOptionChange()">
<%
              if (selectedFilter == null || selectedFilter.length() == 0) {
                  selectedFilter = (String)filterStrList.get(0);
              }

              for (int i=0; i < filterStrList.size(); i++ )
              {
                  String optionSelect = "";
                  String filterItem = (String)filterStrList.get(i);
                  String filterLabel = (String)filterLabelStrList.get(i);

                  if (filterLabel != null)
                      filterLabel = UINavigatorUtil.parseHeader(context, filterLabel, objectId, suiteKey, Request.getLanguage(request));

                  if (filterItem.equalsIgnoreCase(selectedFilter) )
                      optionSelect = "selected";

%>
                <option value="<xss:encodeForHTMLAttribute><%=filterItem%></xss:encodeForHTMLAttribute>" <%=optionSelect%> ><xss:encodeForHTML><%=filterLabel%></xss:encodeForHTML></option>
<%
              }

%>
              </select>
<%
          }

%>
                        </td></tr>
                        
      </tbody></table>

      </div>

<!-- //XSSOK -->
<jsp:include page = "emxToolbar.jsp" flush="true">  <jsp:param name="portalMode" value="true"/>  <jsp:param name="toolbar" value="<%=XSSUtil.encodeForURL(context, toolbar)%>"/>  <jsp:param name="objectId" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/>  <jsp:param name="relId" value="<%=XSSUtil.encodeForURL(context, relId)%>"/>  <jsp:param name="parentOID" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/>  <jsp:param name="timeStamp" value="<%=XSSUtil.encodeForURL(context, timeStamp)%>"/>  <jsp:param name="editLink" value="<%=XSSUtil.encodeForURL(context, editLink)%>"/>  <jsp:param name="header" value="<%=XSSUtil.encodeForURL(context, header)%>"/>  <jsp:param name="suiteKey" value="<%=XSSUtil.encodeForURL(context, suiteKey)%>"/>  <jsp:param name="PrinterFriendly" value="<%=XSSUtil.encodeForURL(context, printerFriendly)%>"/>  <jsp:param name="showPageURLIcon" value="<%=XSSUtil.encodeForURL(context, showPageURLIcon)%>"/>  <jsp:param name="export" value="<%=XSSUtil.encodeForURL(context, export)%>"/>  <jsp:param name="uiType" value="table"/>  <jsp:param name="helpMarker" value="<%=XSSUtil.encodeForURL(context, sHelpMarker)%>"/>  <jsp:param name="tipPage" value="<%=XSSUtil.encodeForURL(context, tipPage)%>"/>  <jsp:param name="topActionbar" value="<%=XSSUtil.encodeForURL(context, topActionbar)%>"/>  <jsp:param name="bottomActionbar" value="<%=XSSUtil.encodeForURL(context, bottomActionbar)%>"/>  <jsp:param name="selectedFilter" value="<%=XSSUtil.encodeForURL(context, selectedFilter)%>"/>	  <jsp:param name="selection" value="<%=XSSUtil.encodeForURL(context, selection)%>"/>  <jsp:param name="showChartOptions" value="<%=showChartIcon%>"/>  <jsp:param name="showTableCalcOptions" value="<%=showCalcIcon%>"/>  <jsp:param name="objectBased" value="<%=XSSUtil.encodeForURL(context, objectBased)%>"/>  <jsp:param name="objectCompare" value="<%=XSSUtil.encodeForURL(context, objectCompare)%>"/>  <jsp:param name="AutoFilter" value="<%=tableBean.hasAutoFilterColumn(timeStamp)%>"/>
</jsp:include>


</form>
</body>

<%
    } catch (Exception ex) {
        ContextUtil.abortTransaction(context);

        if(ex.toString()!=null && (ex.toString().trim()).length()>0) {
            emxNavErrorObject.addMessage("emxTableHeader:" + ex.toString().trim());
		}

    } finally {
        ContextUtil.commitTransaction(context);
    }
%>

<%@include file = "emxNavigatorTimerBottom.inc"%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</html>
