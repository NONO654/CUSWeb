<%-- emxTableHeader.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTableHeader.jsp.rca 1.58 Wed Oct 22 15:48:01 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>


<%
    String timeStamp = emxGetParameter(request, "timeStamp");
	//Added to append the showRMB and uitype for table for RMB Feature
	String appendParams = "timeStamp=" + timeStamp + "&portalCmdName=" + emxGetParameter(request, "portalCmdName") + "&TransactionType=" +emxGetParameter(request, "TransactionType") + "&sortColumnName=" + emxGetParameter(request, "sortColumnName")+"&showRMB=" + emxGetParameter(request, "showRMB")+"&uiType=table";
	String tableBodyURL = "emxTableBody.jsp?" + appendParams;
    try {
        ContextUtil.startTransaction(context, false);

        // Get Table Data from session level Table bean
        HashMap tableData = tableBean.getTableData(timeStamp);
        HashMap tableControlMap = tableBean.getControlMap(tableData);
        HashMap requestMap = tableBean.getRequestMap(tableData);
        String header = tableBean.getPageHeader(tableControlMap);
        String objectId = (String)requestMap.get("objectId");
		// IR-052863V6R2011x adding parentOID as param value
        String parentOID = (String)requestMap.get("parentOID");        
        String toolbar = (String)requestMap.get("toolbar");
        String relId = (String)requestMap.get( "relId");
        String sHelpMarker = (String)requestMap.get("HelpMarker");
        String suiteKey = (String)requestMap.get("suiteKey");
        String inquiryList = (String)requestMap.get("inquiry");
        String inquiryLabel = (String)requestMap.get("inquiryLabel");
        String programList = (String)requestMap.get("program");
        String programLabel = (String)requestMap.get("programLabel");
        String selectedFilter = (String)requestMap.get("selectedFilter");
        String topActionbar = (String)requestMap.get("topActionbar");
        String bottomActionbar = (String)requestMap.get("bottomActionbar");
        String objectCompare=(String)requestMap.get("objectCompare");
        String selection=(String)requestMap.get("selection");
        String objectBased=(String)requestMap.get("objectBased");
        String strCustomize=(String)requestMap.get("customize");
        String tipPage = (String)requestMap.get("TipPage");
        String printerFriendly = (String)requestMap.get("PrinterFriendly");
        String showPageURLIcon = (String)requestMap.get("showPageURLIcon");
        String export = (String)requestMap.get("Export");
        String style = (String)requestMap.get("Style");
        String subHeader = (String)requestMap.get("subHeader");
        String languageStr = Request.getLanguage(request);
        String editLink = (String)requestMap.get("editLink");
        String findMxLink = (String)requestMap.get("findMxLink");
        String triggerValidation = (String)requestMap.get("triggerValidation");

                StringBuffer title = new StringBuffer(50);
                title.append("header_");
                title.append((String)requestMap.get("table"));
                title.append("_");


        if ( (subHeader != null) && (subHeader.trim().length() > 0) ){
        	String subHeaderSeparator = UINavigatorUtil.getI18nString("emxFramework.CustomTable.Subheader.Separator", "emxFrameworkStringResource", languageStr);
        	StringList subHeaderList = FrameworkUtil.split(subHeader, subHeaderSeparator);
        	StringBuffer subHeaderBuffer = new StringBuffer();

        	for(int x = 0; x < subHeaderList.size(); x++){
        		if(x > 0) subHeaderBuffer.append(" ").append(subHeaderSeparator).append(" "); 
        		subHeaderBuffer.append(UINavigatorUtil.parseHeader(context, pageContext, (String)subHeaderList.get(x), objectId, suiteKey, languageStr));
        	}
        	subHeader = subHeaderBuffer.toString();
        	//		
        }

        // Assign the style sheet to be used based on the input
        String cssFile = "emxUIList";
        String progressImage = "images/utilProgressBlue.gif";
        String bodyclass = "head";
        if ( style != null && style.equalsIgnoreCase("dialog") ) {
            cssFile = EnoviaResourceBundle.getProperty(context, "emxNavigator.UITable.Style.Dialog");
            progressImage = "images/utilProgressBlue.gif";
            bodyclass = "head dialog";
        }
        else
            cssFile = EnoviaResourceBundle.getProperty(context, "emxNavigator.UITable.Style.List");

        if ( cssFile == null || cssFile.trim().length() == 0) {
            cssFile = "emxUIList";
        }

        boolean useDefaultCSS=false;
        if ( cssFile == null || cssFile.trim().length() == 0){
          useDefaultCSS=true;
        }

        boolean bExport = true;
        if ("false".equals(export))
            bExport = false;

      StringList filterStrList = new StringList();
      StringList filterLabelStrList = new StringList();

        // Get the list of enquiries and label
        if (inquiryList != null && inquiryList.trim().length() > 0 )
        {
            title.append(inquiryList);
            if (inquiryList.indexOf(",") > 0 )
                filterStrList = FrameworkUtil.split(inquiryList, ",");

            if (inquiryLabel != null && inquiryLabel.trim().length() > 0 )
            {
                if (inquiryLabel.indexOf(",") > 0 )
                    filterLabelStrList = FrameworkUtil.split(inquiryLabel, ",");
            }
        } else if (programList != null && programList.trim().length() > 0 )
        {
            title.append(programList);
            if (programList.indexOf(",") > 0 )
                filterStrList = FrameworkUtil.split(programList, ",");

            if (programLabel != null && programLabel.trim().length() > 0 )
            {
                if (programLabel.indexOf(",") > 0 )
                    filterLabelStrList = FrameworkUtil.split(programLabel, ",");
            }
        }

        String registeredSuite = suiteKey;

        if ( suiteKey != null && suiteKey.startsWith("eServiceSuite") )
        {
            registeredSuite = suiteKey.substring(13);
        }

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
		
%>

<form name="tableHeaderForm">
<div id="pageHeadDiv">
   <table>
     <tr>
    <td class="page-title">
      <h2><xss:encodeForHTML><%=header%> </xss:encodeForHTML></h2>
<%
      if(subHeader != null && !"".equals(subHeader)) {
%>
        <h3><xss:encodeForHTML><%=subHeader%> </xss:encodeForHTML></h3>
<%
        }
%>
    </td>
    <%
       String processingText = UINavigatorUtil.getProcessingText(context, languageStr);
    %>
        <td class="functions">
        <table>
              <tr>
                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>
<%
    if (filterStrList != null && filterStrList.size() > 1)
    {
%>    	
                <td class="label">Filter Label<//td>
                <td class="input">
                    <select name="filterTable" onChange="onFilterOptionChange()">
<%
        if (selectedFilter == null || selectedFilter.length() == 0)
            selectedFilter = (String)filterStrList.get(0);

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
            <option value="<xss:encodeForHTMLAttribute><%=filterItem%></xss:encodeForHTMLAttribute>" <%=optionSelect%> ><xss:encodeForHTML><%=filterLabel%></xss:encodeForHTML></option><%
        }
        %>
        </select></td>
<%
    }
%>
        
        </tr></table>
        </td>
        </tr>
        </table>
<!-- //XSSOK -->
<jsp:include page = "emxToolbar.jsp" flush="true"> <jsp:param name="toolbar" value="<%=XSSUtil.encodeForURL(context, toolbar)%>"/> <jsp:param name="objectId" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/> <jsp:param name="relId" value="<%=XSSUtil.encodeForURL(context, relId)%>"/> <jsp:param name="parentOID" value="<%=XSSUtil.encodeForURL(context, parentOID)%>"/> <jsp:param name="parentOID" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/> <jsp:param name="timeStamp" value="<%=XSSUtil.encodeForURL(context, timeStamp)%>"/> <jsp:param name="editLink" value="<%=XSSUtil.encodeForURL(context, editLink)%>"/> <jsp:param name="header" value="<%=XSSUtil.encodeForURL(context, header)%>"/> <jsp:param name="PrinterFriendly" value="<%=XSSUtil.encodeForURL(context, printerFriendly)%>"/> <jsp:param name="showPageURLIcon" value="<%=XSSUtil.encodeForURL(context, showPageURLIcon)%>"/> <jsp:param name="export" value="<%=XSSUtil.encodeForURL(context, export)%>"/> <jsp:param name="showChartOptions" value="<%=showChartIcon%>"/> <jsp:param name="showTableCalcOptions" value="<%=showCalcIcon%>"/> <jsp:param name="uiType" value="table"/> <jsp:param name="helpMarker" value="<%=XSSUtil.encodeForURL(context, sHelpMarker)%>"/> <jsp:param name="tipPage" value="<%=XSSUtil.encodeForURL(context, tipPage)%>"/> <jsp:param name="suiteKey" value="<%=XSSUtil.encodeForURL(context, registeredSuite)%>"/> <jsp:param name="topActionbar" value="<%=XSSUtil.encodeForURL(context, topActionbar)%>"/> <jsp:param name="bottomActionbar" value="<%=XSSUtil.encodeForURL(context, bottomActionbar)%>"/> <jsp:param name="AutoFilter" value="<%=tableBean.hasAutoFilterColumn(timeStamp)%>"/> <jsp:param name="CurrencyConverter" value="<%=tableBean.hasCurrencyUOMColumn(timeStamp)%>"/> <jsp:param name="objectCompare" value="<%=XSSUtil.encodeForURL(context, objectCompare)%>"/> <jsp:param name="objectBased" value="<%=XSSUtil.encodeForURL(context, objectBased)%>"/> <jsp:param name="selection" value="<%=XSSUtil.encodeForURL(context, selection)%>"/> <jsp:param name="selectedFilter" value="<%=XSSUtil.encodeForURL(context, selectedFilter)%>"/> <jsp:param name="findMxLink" value="<%=XSSUtil.encodeForURL(context, findMxLink)%>"/> <jsp:param name="customize" value="<%=XSSUtil.encodeForURL(context, strCustomize)%>"/> <jsp:param name="triggerValidation" value="<%=XSSUtil.encodeForURL(context, triggerValidation)%>"/>
</jsp:include>
</div><!-- /#pageHeadDiv -->
</form>
<%
    } catch (Exception ex) {
        ContextUtil.abortTransaction(context);
    } finally {
        ContextUtil.commitTransaction(context);
    }
%>
