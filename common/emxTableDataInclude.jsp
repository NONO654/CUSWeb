<%--  emxTableDataInclude.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%

String timeStamp = emxGetParameter(request, "timeStamp");
String showRMB = emxGetParameter(request, "showRMB");
String languageStr = Request.getLanguage(request);
String i18nNoAccessMsg = UINavigatorUtil.getI18nString("emxFramework.Access.NoAccess",
                                        "emxFrameworkStringResource", languageStr);
String transactionType = emxGetParameter(request, "TransactionType");
boolean updateTransaction = (transactionType != null && transactionType.equalsIgnoreCase("update"));

try {

    ContextUtil.startTransaction(context, updateTransaction);

    HashMap valuesColumnMap = new HashMap();
        String columnValue = "";
    // Get business object list from session level Table bean
    HashMap tableData = tableBean.getTableData(timeStamp);
    MapList relBusObjList = tableBean.getFilteredObjectList(tableData);
    HashMap tableControlMap = tableBean.getControlMap(tableData);
    HashMap requestMap = tableBean.getRequestMap(tableData);
    boolean isUserTable = ((Boolean)requestMap.get("userTable")).booleanValue();
    String header = tableBean.getPageHeader(tableControlMap);
    boolean checkBoxDefined = tableBean.hasCheckBoxColumn(tableControlMap);
    String selection = (String)tableControlMap.get("Selection");
    String sortColumnName = (String)tableControlMap.get("SortColumnName");
    String sortDirection = (String)tableControlMap.get("SortDirection");
    String disableSorting = (String)requestMap.get("disableSorting");
    String strMultiColSort= (String)requestMap.get("multiColumnSort");
    boolean isEmbeddedTable=false;
    if(UIUtil.isNotNullAndNotEmpty((String)emxGetParameter(request, "isEmbeddedTable")))
    {
    	isEmbeddedTable=Boolean.parseBoolean(emxGetParameter(request, "isEmbeddedTable"));
    }
    boolean isSortDisable = false;
    //Added For Bug No 341162: Begin
    String queryLimit=(String)requestMap.get("QueryLimit");
    String limitMessage=UINavigatorUtil.getI18nString("emxComponents.Warning.ObjectFindLimit","emxComponentsStringResource",languageStr);
    String taskMessage="";
    int ObjectlistSize=((MapList)tableData.get("ObjectList")).size();
        if(queryLimit!=null && !"".equals(queryLimit.trim()) && ObjectlistSize<Integer.parseInt(queryLimit)){
            ClientTaskList originalTasks=context.getClientTasks();
            ClientTaskList modifiedTasks=new ClientTaskList();
             ClientTaskItr itrTasks = new ClientTaskItr(originalTasks);
             while(itrTasks.next())
             {
                ClientTask task=(ClientTask)itrTasks.obj();
                taskMessage=(String) task.getTaskData();
				 if(taskMessage.contains("Warning #1501905")){
	                	continue;
	             }
                if(taskMessage.indexOf(limitMessage) == -1){
                   modifiedTasks.add(task);
                }
             }
             context.clearClientTasks();
             context.addClientTasks(modifiedTasks);
        }
    //Added for Bug No 341162: End
    //Added code for custom Table
    String strTableName = (String)requestMap.get("table");
    if(isUserTable)
    {
        sortColumnName = (String)requestMap.get("customSortColumns");
        sortDirection = (String)requestMap.get("customSortDirections");

    }

    //    Added code for custom Table
    StringTokenizer columnNameTok = new StringTokenizer(sortColumnName, ",");
    StringTokenizer columnDirectionTok = new StringTokenizer(sortDirection, ",");
    int columnNamesCount = columnNameTok.countTokens();
    int columnDirecCount = columnDirectionTok.countTokens();
    matrix.util.StringList strlName = new StringList(3);
    matrix.util.StringList strlDir = new StringList(3);

    if("false".equalsIgnoreCase(strMultiColSort)){
        if(sortColumnName.length()>0 ){
            columnNamesCount=1;
            strlName.addElement(columnNameTok.nextToken().trim());
            if((sortDirection.length()) > 0 || !"".equals(sortDirection)){
                strlDir.addElement(columnDirectionTok.nextToken().trim());
            }else{
                strlDir.addElement("ascending");
            }
        }
    }
    else{
        if(columnNamesCount==columnDirecCount){
            while(columnNameTok.hasMoreTokens()){
                strlName.addElement(columnNameTok.nextToken().trim());
                strlDir.addElement(columnDirectionTok.nextToken().trim());
            }
        }else{
            while(columnNameTok.hasMoreTokens()){
                      strlName.addElement(columnNameTok.nextToken().trim());
                      if(columnDirectionTok.hasMoreTokens()){
                        strlDir.addElement(columnDirectionTok.nextToken().trim());
                      }else{
                        if(strlDir.size() > 0){
                            if(strlDir.size()==2){
                                String strDirFirst=(String)strlDir.get(0);
                                String strDirSecond=(String)strlDir.get(1);
                                if(strDirFirst.equals(strDirSecond)){
                                    strlDir.addElement(strDirFirst);
                                }else{
                                    strlDir.addElement("ascending");
                                }
                            }else{
                                String strDirFirst=(String)strlDir.get(0);
                                strlDir.addElement(strDirFirst);
                            }
                        }
                    }
                }
        }
     }
    if(disableSorting != null && "true".equalsIgnoreCase(disableSorting)) {
        sortColumnName = null;
        isSortDisable = true;
    }

    int headerRepeatCount = tableBean.getHeaderRepeat(tableControlMap);
    boolean reportMode = false;

    boolean hasCalculationsColumn = tableBean.hasCalculationsColumn(tableControlMap);
    boolean hasSumColumn = tableBean.hasSumColumn(tableControlMap);
    boolean hasAverageColumn = tableBean.hasAverageColumn(tableControlMap);
    boolean hasMaximumColumn = tableBean.hasMaximumColumn(tableControlMap);
    boolean hasMinimumColumn = tableBean.hasMinimumColumn(tableControlMap);
    boolean hasMedianColumn = tableBean.hasMedianColumn(tableControlMap);
    boolean hasStandardDeviationColumn = tableBean.hasStandardDeviationColumn(tableControlMap);
    boolean hasCustomColumn = tableBean.hasCustomColumn(tableControlMap);

    // get the reportFormat
    String reportFormat = emxGetParameter(request, "reportFormat");

    if (reportFormat != null && (reportFormat.equals("HTML") || reportFormat.equals("ExcelHTML")))
        reportMode = true;

    String portalMode = (String)requestMap.get("portalMode");
    String publicPortal = (String)requestMap.get("publicPortal");
    String objectId = (String)requestMap.get("objectId");
    String relId = (String)requestMap.get("relId");
    String jsTreeID = (String)requestMap.get("jsTreeID");
    String helpMarker = (String)requestMap.get("HelpMarker");
    String suiteDir = (String)requestMap.get("suiteDirectory");
    String sHeaderRepeat = (String)requestMap.get("headerRepeat");
    String suiteKey = (String)requestMap.get("suiteKey");
    String objectBased = (String)requestMap.get("objectBased");
    String table = (String)requestMap.get("table");
    String launched = (String)requestMap.get("launched");

    String onselectAction = "";
    String listMode = (String)requestMap.get("listMode");

  if(listMode != null && "search".equalsIgnoreCase(listMode)) {
    try {
      onselectAction = EnoviaResourceBundle.getProperty(context, "emxFramework.Search.OnSelect.Action");
    } catch(Exception e) {
      onselectAction = "Show Content";
    }
  }

    boolean isObjectBased=true;
    if( objectBased != null && objectBased.equalsIgnoreCase("false")){
       isObjectBased=false;
    }
    // Date Format initialization
    String DateFrm = PersonUtil.getPreferenceDateFormatString(context);
    String prefTimeDisp = PersonUtil.getPreferenceDisplayTime(context);

    //Currency and Unit of Measure Conversion
    String convert = (String)requestMap.get("convert");
    String ccCurrency = null;
    Map ucMap = null;
    String ucUnitSystem = null;
    String strEffectiveDate = null;
    char decimalSeparatorChar = ',';
    Boolean hasDigitSeparator = Boolean.valueOf(false);

    if ("true".equalsIgnoreCase(convert))
    {
        decimalSeparatorChar = PersonUtil.getDecimalSymbol(context);
        hasDigitSeparator = FrameworkUtil.hasDigitSeparator(context);

        // ccCurrency = CurrencyConversion.getCurrency(session);
        ccCurrency = PersonUtil.getCurrency(context);
        ucMap = UnitConversion.getUnitConversionMap(context);
        // ucUnitSystem = UnitConversion.getUnitSystem(session);
        ucUnitSystem = PersonUtil.getUnitOfMeasure(context);
    }

    // business object list for current page
    MapList relBusObjPageList = new MapList();

    // HashMap tableMap = new HashMap();
    MapList columns = tableBean.getColumns(tableData);
    int noOfColumns = columns.size();

    RelationshipWithSelectList rwsl = null;
    BusinessObjectWithSelectList bwsl = null;

    boolean columnSpan = false;

    // if selectType is program - get column result by invoking the specified JPO
    Vector programResult[] = new Vector[noOfColumns];

    // if selectType is checkbox - get column result by invoking the specified JPO
    Vector checkboxAccess[] = new Vector[noOfColumns];

     // if selectType is image - get column result by invoking the specified JPO
    Vector imageResult[] = new Vector[noOfColumns];

    // if column type is File - get column result by calling getColumnValuesMap
    Vector fileResult[] = new Vector[noOfColumns];

    // Added for Overriden type Icons
    MapList iconResults[] = new MapList[noOfColumns];

    if (relBusObjList != null && relBusObjList.size() > 0)
    {
        if ( tableBean.isMultiPageMode(tableControlMap) && !reportMode)
        {
            int currentIndex = tableBean.getCurrentIndex(tableControlMap);
            int lastPageIndex = tableBean.getPageEndIndex(tableControlMap);

            for (int i = currentIndex; i < lastPageIndex; i++)
            {
                if (i >= relBusObjList.size())
                    break;
                relBusObjPageList.add(relBusObjList.get(i));
            }
        } else {
            relBusObjPageList = relBusObjList;
        }

        String hasGroupBy = (String)tableControlMap.get("HasGroupBy");
        if("true".equals(hasGroupBy)){
            tableBean.processGroupByHeader(context,application,session,pageContext,request,timeStamp,relBusObjPageList);
            relBusObjPageList = tableBean.getGrouped(context, timeStamp,relBusObjPageList);
        }
        HashMap columnValuesMap = tableBean.getColumnValuesMap(context, application, relBusObjPageList, tableData);

        bwsl = (BusinessObjectWithSelectList)columnValuesMap.get("Businessobject");
        rwsl = (RelationshipWithSelectList)columnValuesMap.get("Relationship");
        programResult = (Vector[])columnValuesMap.get("Program");
        fileResult = (Vector[])columnValuesMap.get("File");
        imageResult = (Vector[])columnValuesMap.get("Image");
        checkboxAccess = (Vector[])columnValuesMap.get("Checkbox");
        // Added for overidden Type icons
        iconResults = (MapList[])columnValuesMap.get("Icons");
        // End


    }
String stringResFileId="emxFrameworkStringResource";
String strLanguage = Request.getLanguage(request);
String noObjectAlert = UINavigatorUtil.getI18nString("emxFramework.ChartOptions.NoObjectAlert", stringResFileId, strLanguage);
String calcnoObjectAlert = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.CalcNoObjectAlert", stringResFileId, strLanguage);
%>
<input type="hidden" name="totalNumObjects" value="<%=relBusObjList.size()%>" />
<!-- //XSSOK -->
<input type="hidden" name="chartAlert" value="<%=noObjectAlert%>" />
<!-- //XSSOK -->
<input type="hidden" name="calcAlert" value="<%=calcnoObjectAlert%>" />
<%
    if (columns != null && columns.size() > 0 )
    {

        String cellpadding = "3";
        String cellspacing = "2";

        if(portalMode != null && "true".equalsIgnoreCase(portalMode) && !reportMode)
        {
      cellspacing = "1";
%>
      <script type="text/javascript">
      appendStyleSheet("emxUIChannelList");
      </script>
<%
    }

        if (reportMode)
        {
            cellpadding = "5";
            cellspacing = "0";
        }
%>
<table class="list" id="<xss:encodeForHTMLAttribute><%=table%></xss:encodeForHTMLAttribute>" showRMB ="<xss:encodeForHTMLAttribute><%=showRMB%></xss:encodeForHTMLAttribute>">
<tbody>
<%
    }

    // Check if there is a Column Group Header
    if (tableBean.hasGroupHeaderColumn(tableControlMap))
    {
%>
<tr class="groupheader">
<%
        // show Check box or radio only if a checkbox column is not defined explicitly
        if ( !(checkBoxDefined) && !(reportMode) )
        {
            if (selection.equals("single") || selection.equals("multiple"))
            {
                %><td></td><%
            }
        }

        for (int i = 0; i < noOfColumns; i++)
        {
            HashMap columnMap = (HashMap)columns.get(i);
            String columnType = tableBean.getSetting(columnMap, "Column Type");
            String columnName = tableBean.getName(columnMap);
            String columnGroupHeader = tableBean.getSetting(columnMap, "Group Header");
            if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
                columnGroupHeader = null;
            }
            if (columnGroupHeader == null || columnGroupHeader.length() == 0)
            {
                if (columnType.equals("separator") ) {

                    %><th class="separator"></th><%

                } else {
                    %><th></th><%
                }

            }  else {

                HashMap groupHeaderMap = (HashMap)tableControlMap.get("GroupHeaderMap");
                HashMap groupMapItem = (HashMap)groupHeaderMap.get(columnName);

                int colSpan;

                if(groupMapItem == null || "null".equals(groupMapItem))
                {
                  colSpan = 1;
%>
                  <!-- //XSSOK -->
                  <th class="groupheader" colspan="<%=colSpan%>"></th>
<%
                } else {
                  colSpan = ((Integer)groupMapItem.get("colSpan")).intValue();
                  String translatedGroupHeader = (String)groupMapItem.get("translatedHeader");
%>
                  <!-- //XSSOK -->
				  <th class="groupheader" colspan="<%=colSpan%>"><%=XSSUtil.encodeForHTML(context, translatedGroupHeader)%></th>
<%
                }

                i = i + colSpan - 1;
            }
        }
    %>
    </tr>
    <%
    } else {
    %>
    <tr>
    <%
    }
    int columnincre = 0;

    if (columns != null && columns.size() > 0 )
    {

    // show Check box or radio only if a checkbox column is not defined explicitly
    if ( !(checkBoxDefined) && !(reportMode) )
    {
        if (selection != null && selection.equals("single"))
        {
            columnincre = 1;
%><th>&nbsp;</th><%
        } else if (selection != null && selection.equals("multiple"))
        {
            columnincre = 1;
%><th width="16" style="text-align:center"><input type="checkbox" name="chkList" onclick="doCheck()" /></th><%
        }
    }

    boolean invalidColumnNameExist = false;

    for (int i = 0; i < noOfColumns; i++)
    {
        HashMap columnMap = (HashMap)columns.get(i);
        String sColumnWidth = tableBean.getSetting(columnMap, "Width");
        StringList selectedFilters = (StringList) columnMap.get("SelectedFilters");
        String filterImage = (selectedFilters == null) ? "" : "images/iconColHeadFilterApplied.gif";
        String headerNoWrap = "";
        if(sColumnWidth == null || sColumnWidth.length() == 0) {
            sColumnWidth = "";
        }else {
        	headerNoWrap = " nowrap";
            sColumnWidth = "width=\"" + sColumnWidth + "\"";
            sColumnWidth = "<img src=\"images/utilSpacer.gif\" " + sColumnWidth + " height=\"1\" alt=\"\" border=\"0\" />";
        }
        boolean isJapanese = false;
        String param = languageStr;
        if(param.indexOf(";") != -1){
        	param = param.substring(0, param.indexOf(";"));
        }
        if(param.indexOf(",") != -1){
        	param = param.substring(0, param.indexOf(","));
        }

        if("ja".equalsIgnoreCase(param) || "ja-JP".equalsIgnoreCase(param)){
        	isJapanese = true;
        }

        if(!reportMode && isJapanese){
        	headerNoWrap = " nowrap";
        }

        String columnType = tableBean.getSetting(columnMap, "Column Type");
        String columnName = tableBean.getName(columnMap);
        String columnHeader = tableBean.getLabel(columnMap);
        if(columnType.equalsIgnoreCase("Image")) {
            if(!FrameworkUtil.isThisSuiteRegistered(context,session,"eServiceSuiteCommonComponents")){
                continue;
            }else {
                columnHeader = "<img src='images/iconColHeadImage.gif' align='absmiddle' border='0' />";
            }
        } else if(columnType.equalsIgnoreCase("File")){
            if(!FrameworkUtil.isThisSuiteRegistered(context,session,"eServiceSuiteCommonComponents")){
                continue;
            } else {
                UITable.modifySetting(columnMap,"Sortable","true");
                if (reportMode){
                    columnHeader = "<img border=\"0\" src=\"../common/images/iconSmallPaperclipVertical.gif\"></img>";
                } else {
                    columnHeader = "<img border=\"0\" src=\"../common/images/iconSmallPaperclipVerticalR.gif\"></img>";
                }
            }
        }

        if (columnName == null && !invalidColumnNameExist )
        {
            invalidColumnNameExist = true;
            sortColumnName = null;
            emxNavErrorObject.addMessage("Invalid Column Name. Please check the UI Table configuration..");
            emxNavErrorObject.addMessage("Sorting may not work correctly..");
        }

    String colHasCalculations = tableBean.getSetting(columnMap, "HasCalculations");
    if(colHasCalculations != null && "true".equalsIgnoreCase(colHasCalculations))
    {
      valuesColumnMap.put(columnName, new StringList());
    }

        //if ("".equals(columnHeader) || "icon".equals(columnType)){
		if ("".equals(columnHeader)){
            columnHeader = "&nbsp;";
        }

        if (columnType.equals("checkbox") )
        {
            if (reportMode)
                continue;

            if (selection != null && selection.equals("single"))
            {
            %><th>&nbsp;</th><%
            }
            else
            {
            	if(UIComponent.getUIAutomationStatus(context)){
            		%><th data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" width="16" style="text-align:center"><input type="checkbox" name="chkList" onclick="doCheck()"></th><%
            	} else {
            %><th width="16" style="text-align:center"><input type="checkbox" name="chkList" onclick="doCheck()" /></th><%
            }
            }

        } else if (columnType.equals("separator") ) {

            %><td class="separator"></td><%

        }else {
            if (    sortColumnName == null ||
                    sortColumnName.length() == 0 ||
                    !strlName.contains(columnName) ||
                    reportMode )
            {
                    String columnSortable = tableBean.getSetting(columnMap, "Sortable");
                    if(reportMode && columnType.equalsIgnoreCase("Icon")) {
                    	continue;
                    }
                    if ( (isSortDisable) || (reportMode) ||
                            (columnSortable != null && columnSortable.equals("false")) )
                    {
                        if(columnType.equalsIgnoreCase("Image")) {
							if(!reportMode){
								if(UIComponent.getUIAutomationStatus(context)){
%>
                            		<th data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" <%=headerNoWrap%> style="text-align:center"><%=columnHeader%>
<%                               } else {
%>
                            <th<%=headerNoWrap%> style="text-align:center"><%=columnHeader%>
<%							
                                }
						}
                        } else {
                        	if(UIComponent.getUIAutomationStatus(context)){
%>
								 <th data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" <%=headerNoWrap%>><%=columnHeader%>                           
<%
                        } else {
%>
                            <th<%=headerNoWrap%>><%=columnHeader%>
<%
                        }
                        }
                    } else {
                        if(columnType.equalsIgnoreCase("Image") || (columnType.equals("programHTMLOutput") && !isEmbeddedTable) || columnType.equals("File")) {
                        	if(UIComponent.getUIAutomationStatus(context)){
%>
                            	<th<%=headerNoWrap%> data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" style="text-align:center"><a href="javascript:reloadTable('<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>', '<xss:encodeForJavaScript><%=columnName%></xss:encodeForJavaScript>' , '','<xss:encodeForJavaScript><%=transactionType%></xss:encodeForJavaScript>')"><%= columnHeader %> </a>
<%
                        } else {
%>								<th<%=headerNoWrap%> style="text-align:center"><a href="javascript:reloadTable('<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>', '<xss:encodeForJavaScript><%=columnName%></xss:encodeForJavaScript>' , '','<xss:encodeForJavaScript><%=transactionType%></xss:encodeForJavaScript>')"><%=columnHeader%></a>
<%                         		
                        	}
                        } else {
                        	if(UIComponent.getUIAutomationStatus(context)){
%>
									<th<%=headerNoWrap%> data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" class=sorted><table><tr><td <%=headerNoWrap%>>
									<a href="javascript:reloadTable('<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>', '<xss:encodeForJavaScript><%=columnName%></xss:encodeForJavaScript>','','<xss:encodeForJavaScript><%=transactionType%></xss:encodeForJavaScript>')"> <%= columnHeader %> </a>
									</td>
<%							} else if(isEmbeddedTable) {
%>
				<th<%=headerNoWrap%> class="sorted"><table><tr><td <%=headerNoWrap%>>
									<a href="javascript:sortEmbeddedTable('<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=table%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=columnName%></xss:encodeForJavaScript>')"><%= columnHeader %> </a>
	 								</td>
<%
							}else{%>
									<th<%=headerNoWrap%> class="sorted"><table><tr><td <%=headerNoWrap%>>
				<a href="javascript:reloadTable('<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>', '<xss:encodeForJavaScript><%=columnName%></xss:encodeForJavaScript>','','<xss:encodeForJavaScript><%=transactionType%></xss:encodeForJavaScript>')"> <%= columnHeader %> </a>
				</td>
<%
							}
				if (filterImage != null && filterImage.length() > 0) {
%>
				<td><img src="<%=filterImage%>" align="absmiddle" border="0" /></td>
<%
				}
%>
				</tr></table>
<%
                        }
%>
<%
                    }
            } else {
                String sortImage = "";
                String nextSortDirection = "";

                //Modified to operate Multi Column Sorting feature
                if(strlName.contains(columnName)){
                    StringList strTempList = new StringList(sortColumnName.length());
                    if(strlDir.size() > 0){
                        strTempList = (StringList)strlDir.clone();
                        int columnIndex = strlName.indexOf(columnName);
                        String strDirValue = (String)strTempList.elementAt(columnIndex);
                        columnName = sortColumnName;
                        String strTempDirValue = null;

                        if(strDirValue.equals("ascending")){
                            strTempDirValue = "descending";
                            sortImage = "images/utilSortArrowUp.png";
                        }else if(strDirValue.equals("descending")){
                            strTempDirValue = "ascending";
                            sortImage = "images/utilSortArrowDown.png";
                        }

                        strTempList.set(columnIndex, strTempDirValue);
                        nextSortDirection = strTempList.toString().trim();
                        StringBuffer strb = new StringBuffer(3);
                        for(int columnCount=0; columnCount<columnNamesCount; columnCount++){
                            String strTemp = (String)strTempList.get(columnCount);
                            strb.append(strTemp.trim());
                            if(columnCount != columnNamesCount-1)
                                strb.append(",");
                        }
                        nextSortDirection = strb.toString();
                    }
                    else{
                        nextSortDirection =  "descending";
                        sortImage = "images/utilSortArrowUp.png";
                    }
                }
                if(UIComponent.getUIAutomationStatus(context)){
%>
					<th<%=headerNoWrap%> data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" class=sorted><table><tr><td <%=headerNoWrap%>>
					<a href="javascript:reloadTable('<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>', '<xss:encodeForJavaScript><%=columnName%></xss:encodeForJavaScript>', '<xss:encodeForJavaScript><%=nextSortDirection%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=transactionType%></xss:encodeForJavaScript>')"> <%= columnHeader %> </a>
					<!-- //XSSOK -->
					</td><td><img src="<%=sortImage%>" align="absmiddle" border="0" /></td>
<%
                }
                else if(isEmbeddedTable){%>
                	<th<%=headerNoWrap%> class="sorted"><table><tr><td <%=headerNoWrap%>>
				    <a href="javascript:sortEmbeddedTable('<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=table%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=columnName%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=nextSortDirection%></xss:encodeForJavaScript>')"><%= columnHeader %> </a>
					</td><td><img src="<%=sortImage%>" align="absmiddle" border="0" /></td>
<%
                } else {
%>
					<th<%=headerNoWrap%> class="sorted"><table><tr><td <%=headerNoWrap%>>
					<a href="javascript:reloadTable('<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>', '<xss:encodeForJavaScript><%=columnName%></xss:encodeForJavaScript>', '<xss:encodeForJavaScript><%=nextSortDirection%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=transactionType%></xss:encodeForJavaScript>')"> <%= columnHeader %> </a>
					<!-- //XSSOK -->
					</td><td><img src="<%=sortImage%>" align="absmiddle" border="0" /></td>
<%
                }
				if (filterImage != null && filterImage.length() > 0) {
%>
<td><img src="<%=filterImage%>" align="absmiddle" border="0" /></td>
<%
				}
%>
</tr></table>
<%
            }
        }
%>
<%=sColumnWidth%></th>
<%
    }
%>
</tr>
<%
}

    if (relBusObjPageList == null || relBusObjPageList.size() == 0 )
    {
        int totalColumns = noOfColumns + 1;
%>
<tr class="even"> <td class="error" colspan="<%=totalColumns%>" align="center"><emxUtil:i18nScript localize="i18nId">emxFramework.IconMail.Common.NoObjectsFound</emxUtil:i18nScript></td> </tr>
<%
    } else if (columns == null || columns.size() == 0) {
%>

<table class="list">
<tr class=even> <td class="error" align=center><emxUtil:i18nScript localize="i18nId">emxFramework.Table.NoColumns</emxUtil:i18nScript></td> </tr>
</table>
<%
    } else {

    // variables used for printing every other row shaded
    int iOddEven = 1;
    String sRowClass = "odd";
    int resultIndex = 0;
    for (int i = 0; i < relBusObjPageList.size(); i++)
    {
        iOddEven = i;
       Map elementMap       = (Map)relBusObjPageList.get(i);
       Map groupByRow       = (Map)elementMap.get("GroupByRow");
       boolean hasReadAccess = true;
       if(UIUtil.isNotNullAndNotEmpty((String)elementMap.get("objReadAccess"))){  
    	   hasReadAccess = Boolean.valueOf((String)elementMap.get("objReadAccess")); 
       }

       if(groupByRow != null)
       {
           String groupclassName  = reportMode ? " class=\"listCell\"" : "";
           String groupByValue    = (String)groupByRow.get("GroupByValue");
           elementMap.remove("GroupByRow");
           if(groupByValue == null || groupByValue.length() == 0)
               groupByValue = "&nbsp;";

            %>
            <tr class="group">
                    <!-- //XSSOK -->
                    <td nowrap colspan="<%=noOfColumns + columnincre%>" align="left" <%=groupclassName%> ><%=groupByValue%></td>
            </tr>
            <%
       }
        String elementOID = (String)elementMap.get("id");
        String elementRELID = (String)elementMap.get("id[connection]");
        String strRepeatHeader = (String)elementMap.get("Header Repeat");

        String checkboxName = "emxTableRowId";
        String sValue = "";

        if (elementRELID == null || elementRELID.trim().length() == 0)
            sValue = elementOID;
        else
            sValue = elementRELID + "|" + elementOID;

        if ((iOddEven%2) == 0)
            sRowClass = "even";
        else
            sRowClass = "odd";

        boolean repeatHeader = false;
        if ( (i != 0) && ((headerRepeatCount != 0 && (i % headerRepeatCount == 0)) || (strRepeatHeader != null && strRepeatHeader.equalsIgnoreCase("true")))) {
            repeatHeader = true;
        }

        if(repeatHeader)
        {
%><tr class="repeat-header"><%
            if ( !(checkBoxDefined) && ( ( selection.equals("single") || selection.equals("multiple") ) &&
                ( !reportMode ) )
                )
            {
%><td></td><%
            }

            for (int k = 0; k < noOfColumns; k++)
            {
                HashMap columnMap = (HashMap)columns.get(k);
                String sColumnWidth = tableBean.getSetting(columnMap, "Width");
                String headerNoWrap = "";
                if(sColumnWidth == null || sColumnWidth.length() == 0) {
                    sColumnWidth = "";
                }else {
                    headerNoWrap = " nowrap";
                    sColumnWidth = "width=\"" + sColumnWidth + "\"";
                    sColumnWidth = "<img src=\"images/utilSpacer.gif\" " + sColumnWidth + " height=\"1\" alt=\"\" border=\"0\" />";
                }
                String columnName = tableBean.getName(columnMap);
                String columnHeader = tableBean.getLabel(columnMap);

                if (columnName == null )
                    sortColumnName = null;

                String columnType = tableBean.getSetting(columnMap, "Column Type");
                if (columnType.equals("checkbox") && reportMode)
                    continue;
                if(columnType.equalsIgnoreCase("Image")) {
                    if(!FrameworkUtil.isThisSuiteRegistered(context,session,"eServiceSuiteCommonComponents")){
                        continue;
                    }else {
                        columnHeader = "<img src='images/iconColHeadImage.gif' align='absmiddle' border='0' />";
                    }
                } else if(columnType.equalsIgnoreCase("File")){
                    if(!FrameworkUtil.isThisSuiteRegistered(context,session,"eServiceSuiteCommonComponents")){
                        continue;
                    } else {
                        UITable.modifySetting(columnMap,"Sortable","true");
                        if (reportMode){
                            columnHeader = "<img border=0 src='images/iconSmallPaperclipVertical.gif'></img>";
                        } else {
                            columnHeader = "<img border=0 src='images/iconSmallPaperclipVerticalR.gif'></img>";
                        }
                    }
                }
                if (columnHeader == null || columnHeader.length() == 0)
                    columnHeader = "&nbsp;";

                if (columnType.equals("checkbox") ) {
%><td><%
                }else if (columnType.equals("separator") ) {
%><td class="separator"><%
                }
                else if (sortColumnName == null || (! strlName.contains(columnName)) || reportMode)
                {
%><td<%=headerNoWrap%>> <%=columnHeader%><%=sColumnWidth%><%

                } else {
%><td<%=headerNoWrap%>><table><tr><td><%
        String sortImage = "";
        String nextSortDirection = "";

        //Modified to operate Multi Column Sorting feature
        if(strlName.contains(columnName)){
            StringList strTempList = new StringList(sortColumnName.length());

            if(strlDir.size() > 0){
                strTempList = (StringList)strlDir.clone();
                int columnIndex = strlName.indexOf(columnName);
                String strDirValue = (String)strTempList.elementAt(columnIndex);
                columnName = sortColumnName;
                String strTempDirValue = null;

                if(strDirValue.equals("ascending")){
                    strTempDirValue = "descending";
                    sortImage = "images/utilSortArrowUp.png";
                }else if(strDirValue.equals("descending")){
                    strTempDirValue = "ascending";
                    sortImage = "images/utilSortArrowDown.png";
                }

                strTempList.set(columnIndex, strTempDirValue);
                nextSortDirection = strTempList.toString().trim();
                StringBuffer strb = new StringBuffer(3);
                for(int columnCount=0; columnCount<columnNamesCount; columnCount++){
                    String strTemp = (String)strTempList.get(columnCount);
                    strb.append(strTemp.trim());
                    if(columnCount != columnNamesCount-1)
                        strb.append(",");
                }
                nextSortDirection = strb.toString();
            }
            else{
                nextSortDirection =  "ascending";
                sortImage = "images/utilSortArrowUp.png";
            }
        }

%><%=columnHeader%>
<!-- //XSSOK -->
</td><td><img src="<%=sortImage%>"/></td></tr></table>
<%
                }
%></td><%
            }
%></tr><%
        }
        if(UIComponent.getUIAutomationStatus(context)){
        String columnContent = "";
        StringList colValue = new StringList(); 
        if(bwsl != null) {
      		 colValue = (StringList)(bwsl.getElement(i).getSelectDataList("name"));      		      		 
        }              
        if ( colValue != null && colValue.size() > 0 ) {
  			columnContent = (String)(colValue.firstElement());
        }
%><tr data-aid="<%=columnContent%>" class="<%=sRowClass%>"><%
        } else {
%><tr class="<%=sRowClass%>"><%
        }
        // Show default Check box column, only if a checkbox column is explicitly not defined
if ( !(checkBoxDefined) && !(reportMode) )
{
// Add RowSelectable check (default true)
      String rowSelectable = (String)elementMap.get("RowSelectable");
      if ("false".equals(rowSelectable) || !hasReadAccess)
         {
           if (selection.equals("multiple") ) {
             %><td style="text-align: center"><img src="images/utilCheckOffDisabled.gif" /></td><%
               } else if (selection.equals("single") ) {
             %><td style="text-align: center"><img src="images/utilRadioOffDisabled.gif" /></td><%
               }
             } else {
             if (selection.equals("multiple") ) {
         %><td style="text-align: center" width="16"><input type="checkbox" name="<%=checkboxName%>" value="<%=sValue%>"    onclick="doCheckboxClick(this, event); doSelectAllCheck(this)" /><script>strPageIDs += "<%=sValue%>" + "~";</script></td><%
         } else if (selection.equals("single") ) {
           %><td style="text-align: center" width="16"><input type="radio" name="<%=checkboxName%>" value="<%=sValue%>" onclick="doRadioButtonClick(this);" /></td><%
         }
      }
}

        HashMap columnMap = new HashMap();
        String strClassCode = "";
        if(reportMode) {
      strClassCode = " class=\"listCell\"";
    }
        for (int j = 0; j < noOfColumns; j++)
        {
            columnMap = (HashMap)columns.get(j);
            StringList colValueUOMList = null;

            String objectIcon = "";
            boolean showIcon = false;
            boolean showPrependIcon = false;
            //To get the Column level RMB Setting
            String strRMBSetting = tableBean.getSetting(columnMap, "RMB Menu");
            String nowrapSetting = tableBean.getSetting(columnMap, "Nowrap");
            if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
                nowrapSetting = null;
            }
            String nowrap = "";
            if(nowrapSetting != null && nowrapSetting.equalsIgnoreCase("true")) {
        nowrap = " nowrap";
      }

            String passOID = elementOID;
            //Added for Bug : 353307
            String passRELID = (elementRELID != null) ? elementRELID : "";
            StringList passOIDList = new StringList();
          String columnName = tableBean.getName(columnMap);
            StringBuffer href = new StringBuffer(150);
            href.append(tableBean.getHRef(columnMap));
            if (publicPortal != null && publicPortal.equalsIgnoreCase("TRUE"))
            {
                if (href.toString().indexOf("emxTree.jsp") >= 0)
                {
                    href = new StringBuffer(FrameworkUtil.findAndReplace(href.toString(), "emxTree.jsp", "emxNavigator.jsp"));
                }
                else
                {
                    href = null;
                }
            }
            String showTypeIcons = tableBean.getSetting(columnMap, "Show Type Icon");
            if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
                showTypeIcons = null;
            }

            String prependIcons = tableBean.getSetting(columnMap, "Prepend Icon");

            String showAltIcons = tableBean.getSetting(columnMap, "Show Alternate Icon");
            if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
                showAltIcons = null;
            }
            String columnType = tableBean.getSetting(columnMap, "Column Type");
            String colFormat = tableBean.getSetting(columnMap, "format");
            if(tableBean.isAssociatedWithDimension(columnMap) && !"alphanumeric".equalsIgnoreCase(colFormat)) {
                colFormat = "UOM";
            }
            String adminType = tableBean.getSetting(columnMap, "Admin Type");
            String alternateOIDSelect = tableBean.getSetting(columnMap, "Alternate OID expression");

                if(columnType.equalsIgnoreCase("File") && !FrameworkUtil.isThisSuiteRegistered(context,session,"eServiceSuiteCommonComponents")){
                    continue;
                }
            if (prependIcons != null && prependIcons.trim().length()>0)
            {
              showPrependIcon=true;
            }
            if (alternateOIDSelect != null && alternateOIDSelect.length() > 0)
            {
                passOIDList = (StringList)(bwsl.getElement(i).getSelectDataList(alternateOIDSelect));
                if (passOIDList != null)
                    passOID = (String)(passOIDList.firstElement());
            }

            String typeName = "";
            StringList objectIcons = new StringList();
            StringList typeNames = new StringList();
            //Added for Overridden type Icon
            StringList alternateObjectList =  new StringList();
            boolean customIcon=false;
            String typeIconProgram = tableBean.getSetting(columnMap,"Type Icon Program");
            String typeIconFunction = tableBean.getSetting(columnMap,"Type Icon Function");
            String defaultProgramFunction = EnoviaResourceBundle.getProperty(context, "emxFramework.UIComponents.OverriddenTypeIcon.Program");

              // End
              if ("businessobject".equals(columnType)&& "true".equals(showTypeIcons))
              {
                if (typeIconProgram.length() > 0 && typeIconFunction.length() > 0 || defaultProgramFunction.length()>0)
                {
                    java.util.HashMap iconMap= (java.util.HashMap)iconResults[j].get(i);
                    if(iconMap.containsKey(elementOID))
                    {
                        objectIcon = (String)iconMap.get(elementOID);
                        if(objectIcon!=null && objectIcon.length()>0)
                        {
                            objectIcon = "images/" + objectIcon;
                               objectIcons.addElement(objectIcon);
                        }
                        else
                        {
                            typeName = bwsl.getElement(i).getSelectData("type");
                            objectIcon = UINavigatorUtil.getTypeIconProperty(context, application, typeName);
                            objectIcon = "images/" + objectIcon;
                            objectIcons.addElement(objectIcon);
                        }
                    }
                    else
                    {
                        objectIcon = "images/iconSmallDefault.gif";
                           objectIcons.addElement(objectIcon);
                    }
                    customIcon = true;

                }
                else
                {
                    typeName = bwsl.getElement(i).getSelectData("type");
                    typeNames.addElement(typeName);

                }
                showIcon = true;

            }

              else if (("businessobject".equals(columnType) || "icon".equals(columnType))&&"true".equals(showAltIcons)) {

                if (typeIconProgram.length() > 0 && typeIconFunction.length() > 0 ||defaultProgramFunction.length()>0)
                {
                    String alternateOID = tableBean.getSetting(columnMap, "Alternate OID expression");
                    alternateObjectList = bwsl.getElement(i).getSelectDataList(alternateOID);
                    if(alternateObjectList!=null && alternateObjectList.size()>0)
                    {
                        java.util.HashMap iconMap= (java.util.HashMap)iconResults[j].get(i);
                        // Columns having alternate OID Expression setting,
                        // Structure of IconMap is different.
                        // Using objectid we have to get the alternateObjectIDMap
                        // This Map will contain the alternate objectid's of the objectid as key
                        // and iconNames as values.
                        HashMap alternateObjectsMap = (HashMap)iconMap.get(elementOID);
                        Iterator sltObjItr = alternateObjectList.iterator();
                        while(sltObjItr.hasNext())
                        {
                            objectId = (String)sltObjItr.next();
                            if(alternateObjectsMap.containsKey(objectId))
                            {
                                objectIcon = (String)alternateObjectsMap.get(objectId);
                                objectIcon = "images/" + objectIcon;
                                   objectIcons.addElement(objectIcon);
                            }
                            else
                            {
                                objectIcon = "images/buttonContextSearch.gif";
                                   objectIcons.addElement(objectIcon);
                            }
                        }
                        customIcon = true;
                    }

                }
                else
                {
                    String alternateTypeSelect = tableBean.getSetting(columnMap, "Alternate Type expression");
                    if (alternateTypeSelect != null)
                    {
                        typeNames = bwsl.getElement(i).getSelectDataList(alternateTypeSelect);

                    }
                    customIcon = false;
                }
                showIcon=true;
            }

            if (showIcon && typeNames != null && typeNames.size() > 0)
            {
                StringItr typeItr = new StringItr(typeNames);

                while (typeItr.next()) {
                    typeName = typeItr.obj();
                    objectIcon = UINavigatorUtil.getTypeIconProperty(context, application, typeName);
                    if (objectIcon == null || objectIcon.length() == 0 )
                        objectIcon = "images/iconSmallDefault.gif";
                    else
                        objectIcon = "images/" + objectIcon;

                    objectIcons.addElement(objectIcon);
                }
            }

            if (href != null && href.toString().length() > 0)
            {
                href.append((href.toString().indexOf("?") == -1 ? "?" : "&"));
                href.append("relId=");
                href.append(elementRELID);
                href.append("&parentOID=");
                href.append(objectId);
                href.append("&jsTreeID=");
                href.append(jsTreeID);
                href.append("&suiteKey=");
                href.append(tableBean.getSetting(columnMap, "Registered Suite"));

                if(href.toString().indexOf("${ROW_ID}")>=0){
                    href = new StringBuffer(UINavigatorUtil.getMacroSubtitution(href.toString(),passOID,"${ROW_ID}"));
                }

                if(href.toString().indexOf("$")>-1){
                    href = new StringBuffer(UIExpression.substituteValues(context, pageContext, href.toString(), passOID));
                }

                href = new StringBuffer(XSSUtil.encodeForURL(context,href.toString()));
            }
			boolean isTNRExpression = false;
            if (columnType.equals("businessobject"))
            {
                String columnSelect = tableBean.getBusinessObjectSelect(columnMap);
           		 isTNRExpression = UIExpression.isTNRExpression(context, columnSelect);
            }

            if (columnType.equals("separator") ) {
%><td class="separator"></td><%
            } else if(!hasReadAccess && !isTNRExpression){
             //no need to add "No Access" to colValueList
            	%><td><%=i18nNoAccessMsg%></td><% 
            }else{
            if( columnType.equals("businessobject") ||
                            columnType.equals("relationship") ||
                            columnType.equals("program") )
            {
                columnValue = "";
                StringList colValueList = new StringList();
                StringList colValueDisplayList = new StringList();
                colValueUOMList = new StringList();

                if (columnType.equals("businessobject") )
                {
                    String columnSelect = tableBean.getBusinessObjectSelect(columnMap);
                    if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
                        String sDBselect = columnSelect;
                        if(UOMUtil.isSimpleAttributeExpression(columnSelect)) {
                            String sUOMcolumnselect = (String)columnMap.get("UOM Input Select");
                            String attrName = UOMUtil.getAttrNameFromSelect(columnSelect);
                            String inputValue = "";
                            String systemValue="";

                            colValueList = (StringList)(bwsl.getElement(i).getSelectDataList(sUOMcolumnselect));
                            if(colValueList != null) {
                                inputValue = (String)colValueList.firstElement();
                                //inputValue = UOMUtil.convertToI18nUnitName(inputValue, languageStr);
                            }
                            sUOMcolumnselect = (String)columnMap.get("UOM System Select");
                            if(sUOMcolumnselect != null) {
                                colValueList = (StringList)(bwsl.getElement(i).getSelectDataList(sUOMcolumnselect));
                                if(colValueList != null) {
                                    systemValue = (String)colValueList.firstElement();
                                    //systemValue = UOMUtil.convertToI18nUnitName(systemValue, languageStr);
                                }
                            }
                            colValueList = new StringList();
                            colValueList.addElement(UOMUtil.formatDisplayValue(context, inputValue, systemValue, languageStr));
                        }else {
                            sDBselect = (String)columnMap.get("UOM Db Select");
                    colValueList = (StringList)(bwsl.getElement(i).getSelectDataList(columnSelect));
                        }
                        colValueUOMList = (StringList)(bwsl.getElement(i).getSelectDataList(sDBselect));
                    }else {
                        String isRTE = (String)columnMap.get(UIComponent.ISRTEFIELD);
                        if(isRTE != null && "true".equalsIgnoreCase(isRTE)){
                       		colValueList = (StringList)(bwsl.getElement(i).getSelectDataList((String)columnMap.get(UITable.RTE_EXPRESSION)));
                       		if(colValueList == null || "".equalsIgnoreCase((String)colValueList.get(0))) {
                        colValueList = (StringList)(bwsl.getElement(i).getSelectDataList(columnSelect));
                       		}
                        }else{
                        	colValueList = (StringList)(bwsl.getElement(i).getSelectDataList(columnSelect));
                        }
                    }
                } else if (columnType.equals("relationship") ) {
                    String columnSelect = tableBean.getRelationshipSelect(columnMap);
                    RelationshipWithSelect rws = (RelationshipWithSelect)rwsl.elementAt(i);
                    Hashtable columnInfo = rws.getRelationshipData();
                    try {
                            String strColumnValue = "";
                            if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
                                String sUOMDbValue = "";
                                if(UOMUtil.isSimpleAttributeExpression(columnSelect)) {
                                    sUOMDbValue = (String)columnInfo.get(columnSelect);
                                    String sUOMcolumnselect = (String)columnMap.get("UOM Input Select");
                                    String attrName = UOMUtil.getAttrNameFromSelect(columnSelect);
                                    String inputValue = "";
                                    String systemValue="";
                                    inputValue = (String)columnInfo.get(sUOMcolumnselect);
                                    sUOMcolumnselect = (String)columnMap.get("UOM System Select");
                                    if(sUOMcolumnselect != null) {
                                        systemValue = (String)columnInfo.get(sUOMcolumnselect);
                                        if(systemValue == null) {
                                            systemValue="";
                                        }
                                    }
                                    strColumnValue = UOMUtil.formatDisplayValue(context, inputValue, systemValue, languageStr);

                                }else {
                                    String sUOMcolumnselect = (String)columnMap.get("UOM Db Select");
                                    sUOMDbValue = (String)columnInfo.get(sUOMcolumnselect);
                                    strColumnValue = (String)columnInfo.get(columnSelect);
                                }
                                if(sUOMDbValue == null) {
                                    sUOMDbValue = "";
                                }
                                colValueUOMList.add(sUOMDbValue);
                            }else {
                                strColumnValue = (String)columnInfo.get(columnSelect);
                            }

                        if (strColumnValue == null)
                        {
                          strColumnValue = "";
                        }
                        colValueList.add(strColumnValue);
                    } catch (Exception ex) {
                        colValueList = (StringList)columnInfo.get(columnSelect);
                    }

                } else if ( columnType.equals("program") ) {
                    if(i <= (programResult[j].size() - 1))
                    {
                        HashMap  cellValueMap = (HashMap)programResult[j].get(i);
                        Object colActualValue = cellValueMap.get("ActualValue");
                        if(colActualValue instanceof StringList){
                        	colValueList = (StringList)colActualValue;
                        }else{
                        	colValueList.add((String)colActualValue);
                        }

                        Object colDisplayValue = cellValueMap.get("DisplayValue");
                        if(colDisplayValue instanceof StringList){
                        	colValueDisplayList = (StringList)colDisplayValue;
                        }else{
                        	colValueDisplayList.add((String)colDisplayValue);
                        }
                    }
                }
                if (colValueList == null)
                    colValueList = new StringList();

                if (colValueList.size() > 0)
                {
                    UIForm uf = new UIForm();
                    String select = "";
                    if (columnType.equals("businessobject"))
                    {
                        select = uf.getBusinessObjectSelect(columnMap);
                    }
                    else if (columnType.equals("relationship"))
                    {
                        select = uf.getRelationshipSelect(columnMap);
                    }
                    String fldType = tableBean.getSetting(columnMap, "Field Type");
                    if(fldType != null && fldType.equalsIgnoreCase("attribute") && select.startsWith("attribute"))

                    {

                        AttributeType attType = new AttributeType(uf.getAttrNameFromSelect(select));

                        String dataType = (String) columnMap.get("Attribute Data Type"); 
						if(UIUtil.isNullOrEmpty(dataType)) {
                        	dataType = attType.getDataType(context);
                        }
                        if("boolean".equalsIgnoreCase(dataType))

                        {
                            attType.open(context);
                            StringList fldChoices = attType.getChoices();
                            attType.close(context);
                            if(fldChoices != null && fldChoices.size()==2)
                            {
                                String clnValue = (String) colValueList.get(0);
                                String strChoice = (String)fldChoices.get(0);
                                if("Yes".equalsIgnoreCase(strChoice) || "On".equalsIgnoreCase(strChoice) || "True".equalsIgnoreCase(strChoice) || "1".equalsIgnoreCase(strChoice))
                                {
                                    if("TRUE".equalsIgnoreCase(clnValue))
                                        clnValue = strChoice;
                                    else
                                        clnValue = (String)fldChoices.get(1);
                                }
                                colValueList = new StringList(clnValue);
                            }
                        }
                    }
                }

                if (colValueList != null && adminType != null)
                {
                    if (adminType.equals("State") )
                    {
                        String alternatePolicySelect = tableBean.getSetting(columnMap, "Alternate Policy expression");

                        if (alternatePolicySelect != null && alternatePolicySelect.length() > 0)
                        {
                            StringList policyList = (StringList)(bwsl.getElement(i).getSelectDataList(alternatePolicySelect));
                            colValueList = UINavigatorUtil.getStateI18NStringList(policyList, colValueList, languageStr);
                            StringList noAccessList = new StringList(colValueList.size());
                            Iterator colValueListItr = colValueList.iterator();
                            while(colValueListItr.hasNext()){
                            	String colVal = (String) colValueListItr.next();
                            	noAccessList.add(tableBean.NO_READ_ACCESS.equals(colVal) ? i18nNoAccessMsg : colVal);
                            }
                            colValueList = noAccessList;
                        } else {
                            StringList policyList = (StringList)(bwsl.getElement(i).getSelectDataList("policy"));
                            colValueList = UINavigatorUtil.getStateI18NStringList(policyList, colValueList, languageStr);
                        }

                    } else if (adminType.startsWith("attribute_") ){
                        // String attributeName = Framework.getPropertyValue(session, adminType);
                        String attributeName = PropertyUtil.getSchemaProperty(context,adminType);
                        colValueList = UINavigatorUtil.getAttrRangeI18NStringList(attributeName, colValueList, languageStr);
                    } else {
                        colValueList = UINavigatorUtil.getAdminI18NStringList(adminType, colValueList, languageStr);
                        if(columnType.equals("program")){
                            colValueList = colValueDisplayList;
                        }
                    }
                }

                if ( colValueList != null && colValueList.size() > 0 )
                    columnValue = (String)(colValueList.firstElement());

                if (    href == null || href.toString().length() == 0 ||
                        (reportMode) )
                {
                    if(colFormat.equalsIgnoreCase("user")){
                                                String dispFormat = tableBean.getSetting(columnMap, "Display Format");
                                                if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
                                                    dispFormat = "";
                                                }
                                                Boolean showNameLink = Boolean.valueOf(false);
                                                Boolean showNameIcon = Boolean.valueOf(false);
                                                if(dispFormat != null && ("Icon With Link".equalsIgnoreCase(dispFormat) || "Link".equalsIgnoreCase(dispFormat))) {
                                                        showNameLink = Boolean.valueOf(true);
                                                }

                                                if(dispFormat != null && ("Icon With Link".equalsIgnoreCase(dispFormat) || "Icon".equalsIgnoreCase(dispFormat))) {
                                                        showNameIcon = Boolean.valueOf(true);
                                                }
%>
                                                <!-- //XSSOK -->
                                                <td<%=nowrap%><%=strClassCode%>>
                                                <!-- //XSSOK -->
                                                <framework:fullName userName="<%= columnValue %>" showHyperLink="<%= showNameLink.booleanValue()%>" showTypeIcon="<%= showNameIcon.booleanValue()%>" />
                                                </td>
<%
                                        }
                    //BEGIN OF CHANGE FOR EMAIL FIELD
                    else if(colFormat.equalsIgnoreCase("email")){
                       if ( reportMode ) {
                    	   if(UIComponent.getUIAutomationStatus(context)){
%><td<%=nowrap%><%=strClassCode%> data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>"><xss:encodeForHTML><%=columnValue%></xss:encodeForHTML>&nbsp;</td><%
                    	   }else{
%><td<%=nowrap%><%=strClassCode%>><xss:encodeForHTML><%=columnValue%></xss:encodeForHTML>&nbsp;</td><%
                    	   }
                        }else{
                        	if(UIComponent.getUIAutomationStatus(context)){
%><td<%=nowrap%><%=strClassCode%> data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" rmb= "<%=strRMBSetting%>" ><A HREF="mailto:<%=columnValue%>"><xss:encodeForHTML><%=columnValue%></xss:encodeForHTML></A>&nbsp;</td><%
                        	} else{
%><td<%=nowrap%><%=strClassCode%> rmb= "<%=strRMBSetting%>" ><A HREF="mailto:<%=columnValue%>"><xss:encodeForHTML><%=columnValue%></xss:encodeForHTML></A>&nbsp;</td><%
                        	}
                         }
                    }
                    //END OF CHANGE FOR EMAIL FIELD
                    else if (colFormat.equalsIgnoreCase("date"))
                    {
                        String displayTime = tableBean.getSetting(columnMap, "Display Time");
                        if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
                            displayTime = "";
                        }
                        String displayFormat = tableBean.getSetting(columnMap, "Display Format");
                        if(UIComponent.getUIAutomationStatus(context)){
%>
                        <td<%=nowrap%><%=strClassCode%> rmb= "<%=strRMBSetting%>" data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" >
<%
                        } else {
%>
						<!-- //XSSOK -->
						<td<%=nowrap%><%=strClassCode%> rmb= "<%=strRMBSetting%>" >
<%

                        }
                        if ( displayFormat != null && displayFormat.length() > 0 && !tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
                            DateFrm = displayFormat.trim();
                        }

                        if ( displayTime == null ||
                                displayTime.trim().length() == 0 ||
                                ( !displayTime.equalsIgnoreCase("true") &&
                                    !displayTime.equalsIgnoreCase("false") ) )
                        {
                            displayTime = prefTimeDisp;
                        }

                        int listSize = colValueList.size();
                        for(int k=0;k<listSize;k++) {
                            columnValue=(String)(colValueList.elementAt(k));
%>
<!-- //XSSOK -->
<emxUtil:lzDate displaydate='true' displaytime='<%=displayTime%>' localize="i18nId" tz='<%=XSSUtil.encodeForHTMLAttribute(context, (String)session.getAttribute("timeZone"))%>' format='<%=DateFrm%>' ><%= columnValue %></emxUtil:lzDate>&nbsp;
<%
                            if (listSize > 1 && k != listSize -1) {
%>
                            <br /><br />
<%
                            }
                        }
%>
                        </td>
<%
                    } else if (colFormat.equalsIgnoreCase("currency"))
                    {
                        String fromCurrency = "";
                        String effectiveDate = "";

                        String currencyExpression = tableBean.getSetting(columnMap, "Currency Expression");
                        String effectiveDateExpression = tableBean.getSetting(columnMap, "Effective Date Expression");
                        if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
                            effectiveDateExpression = null;
                        }

                        if (currencyExpression != null)
                            fromCurrency = bwsl.getElement(i).getSelectData(currencyExpression);

                        if (effectiveDateExpression != null)
                            effectiveDate = bwsl.getElement(i).getSelectData(effectiveDateExpression);
                        if(UIComponent.getUIAutomationStatus(context)){
%><td<%=nowrap%><%=strClassCode%> data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" rmb= "<%=strRMBSetting%>"><%
                        } else {
%><td<%=nowrap%><%=strClassCode%> rmb= "<%=strRMBSetting%>"><%
                        }
                            if ( columnValue.length() > 0 &&
                                ccCurrency != null &&
                                ccCurrency.length() > 0 &&
                                "true".equalsIgnoreCase(convert)
                                ) { %>
                            <framework:convertCurrency
                                from="<%= fromCurrency %>"
                                to="<%= ccCurrency %>"
                                value="<%= columnValue %>"
                                date="<%= effectiveDate %>"
                                decimalSeparator="<%= decimalSeparatorChar%>"
                                digitSeparatorPreference="<%= hasDigitSeparator.booleanValue()%>"/>
                        <% } else { %>
                            <xss:encodeForHTML><%= columnValue %></xss:encodeForHTML>
                        <% } %>&nbsp;</td>
<%
                    } else if (colFormat.equalsIgnoreCase("UOM") && (!tableBean.isAssociatedWithDimension(columnMap) || tableBean.isAlphanumericField(columnMap)))
                    {
                        String strUoM = "";

                        String UOMExpression = tableBean.getSetting(columnMap, "UOM Expression");
                        if (UOMExpression != null)
                            strUoM = bwsl.getElement(i).getSelectData(UOMExpression);
                        if(UIComponent.getUIAutomationStatus(context)){
%><td<%=nowrap%><%=strClassCode%> data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" rmb= "<%=strRMBSetting%>"><%
                        } else {
%><td<%=nowrap%><%=strClassCode%> rmb= "<%=strRMBSetting%>"><%
                        }
                        if ( columnValue.length() > 0 &&
                                ucUnitSystem != null &&
                                ucUnitSystem.length() > 0 &&
                                "true".equalsIgnoreCase(convert)
                                ) { %>
                        <framework:convertUnit
                            map="<%= ucMap %>"
                            from="<%=strUoM %>"
                            to="<%= ucUnitSystem %>"
                            value="<xss:encodeForHTMLAttribute><%= columnValue %></xss:encodeForHTMLAttribute>"
                            decimalSeparator="<%= decimalSeparatorChar%>"
                            digitSeparatorPreference="<%= hasDigitSeparator.booleanValue()%>"/>
                        <% } else { %>
                            <xss:encodeForHTML><%= columnValue %></xss:encodeForHTML>
                        <% } %>&nbsp;</td><%
                    } else { // for all other formats
                    	if(UIComponent.getUIAutomationStatus(context)){
%><td<%=nowrap%><%=strClassCode%> data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" rmb = "<%=strRMBSetting%>"<%
                    	} else {
%><td<%=nowrap%> rmb = "<%=strRMBSetting%>"<%
                    	}
                        switch(colValueList.size()) {
                            case 0:
                            {
                                %>&nbsp;<%
                                break;
                            }
                            default:
                            {
                                if (showIcon || showPrependIcon)
                                {
                                    %><%=strClassCode%>> <table border="0"><%
                                }

                                for (int noColValues = 0; noColValues < colValueList.size(); noColValues++)
                                {
                                    columnValue = (String)colValueList.get(noColValues);
                                    String sPrgHTMLEncode = EnoviaResourceBundle.getProperty(context, "emxFramework.Table.ProgramColumn.HTMLEncode");
                                    if("true".equalsIgnoreCase(sPrgHTMLEncode)) {
                                        String actualColumnValue = columnValue;
                                        columnValue = XSSUtil.encodeForHTML(context, columnValue);
                                        if(UIComponent.isRichTextEnabled(context, columnMap)){
											columnValue = UIRTEUtil.containsRTETags(context, actualColumnValue) ? UIRTEUtil.decodeRTESupportedTags(context, columnValue) : columnValue;                                
                                        }
                                    }
                                    if(tableBean.isDynamicURLEnabled(context, columnMap)) {
                                        if(reportMode) {
                                            columnValue = UINavigatorUtil.formatEmbeddedURL(context, columnValue, false, languageStr);
                                        }else {
                                            columnValue = UINavigatorUtil.formatEmbeddedURL(context, columnValue, true, languageStr);
                                        }
                                    }

                                    boolean isNumeric = "numeric".equals(tableBean.getSetting(columnMap, "Data Type"));
                                    String decFormat = UIForm.formDecimalFormat(columnMap);
                                    if (isNumeric){
                                        if (!"".equalsIgnoreCase(columnValue) && !"".equalsIgnoreCase(decFormat) && decFormat != null && !decFormat.equals("null")){
                                            DecimalFormat df = new DecimalFormat(decFormat);
	                                        double d = Double.parseDouble(columnValue);
	                                        String jsFieldValueDecimal = df.format(d);
	                                        columnValue = jsFieldValueDecimal;
                                        }
                                    }

                                    if (showIcon || showPrependIcon)
                                    {
                                        if (prependIcons != null && prependIcons.trim().length()>0){
                                               objectIcon=prependIcons;
                                        }else{
                                               if (objectIcons != null && objectIcons.size() > 0)
                                                {
                                                    try {
                                                        objectIcon = (String)objectIcons.get(noColValues);
                                                    } catch (Exception est) {
                                                        objectIcon = (String)objectIcons.firstElement();
                                                    }
                                                }
                                         }
%><tr><td<%=nowrap%> rmb= "<%=strRMBSetting%>" valign="top"><img border="0" src="<%=objectIcon%>" /></td><td<%=nowrap%> rmb= "<%=strRMBSetting%>" ><%=columnValue%></td></tr><%
                                    } else {
										if( noColValues == 0) {
											if(columnType.equals("businessobject") || columnType.equals("relationship")) {
												%><%=(strClassCode.length() > 0 ? strClassCode : "class= \"verbatim\"")%>><%
											} else {
												%>><%
											}
										}
										%><%=columnValue%>&nbsp;<%
                                        if (colValueList.size() > 1 && noColValues != colValueList.size() -1) {
                                            %><br /><br /><%
                                        }
                                    }
                                }
                                if (showIcon || showPrependIcon) {
%></table><%
                                }

                            }
                        } //ENd: switch
%></td><%
                    }

                } else {  //ELSE FOR HREF CASE

                    String targetLocation = tableBean.getSetting(columnMap, "Target Location");
                    String popupsize = tableBean.getSetting(columnMap, "Popup Size");
                    String windowWidth = tableBean.getSetting(columnMap, "Window Width");
                    String windowHeight = tableBean.getSetting(columnMap, "Window Height");
                    String popupModal = tableBean.getSetting(columnMap, "Popup Modal");

                    if((portalMode != null && "true".equalsIgnoreCase(portalMode))  ||
                      (launched != null && "true".equalsIgnoreCase(launched)))
                    {
                        //code commented for PowerView Enhancement 16 Aug 2007
                             //targetLocation = "popup";
                      if(windowWidth == null || "".equals(windowWidth))
                      {
                        windowWidth = "700";
                        windowHeight = "600";
                      }

                    }
                    if(UIComponent.getUIAutomationStatus(context)){
%><td<%=nowrap%><%=strClassCode%> data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" rmbID = "<%=passOID%>" rmb= "<%=strRMBSetting%>"><%
                    } else {
%><td<%=nowrap%><%=strClassCode%> rmbID = "<%=passOID%>" rmb= "<%=strRMBSetting%>"><%
                    }
                    switch(colValueList.size()) {
                        case 0:
                        {
                            %>&nbsp;<%
                            break;
                        }
                        default:
                        {

                            if (showIcon ||showPrependIcon) {
                                %><div><%
                            }

                            for (int noColValues = 0; noColValues < colValueList.size(); noColValues++)
                            {
                                columnValue = (String)colValueList.get(noColValues);

                                if (passOIDList != null && passOIDList.size() > 0)
                                    passOID = (String)passOIDList.get(noColValues);

                                String colItemHref = href.toString();
                                if(portalMode != null && "true".equalsIgnoreCase(portalMode)) {
                                        colItemHref += "&portalCmdName=" + XSSUtil.encodeForURL(context,(String)requestMap.get("portalCmdName"));
                                                                }
                                if(isObjectBased){
                                   colItemHref += "&objectId=" + passOID;
                                }

                                String tempColumnVal = FrameworkUtil.findAndReplace(columnValue,"\"","&quot;");
								tempColumnVal = FrameworkUtil.findAndReplace(tempColumnVal,"'","&rsquo;");

                                StringBuffer hrefHTML = new StringBuffer(250);
                                hrefHTML.append("JavaScript:emxTableColumnLinkClick('");
                                hrefHTML.append(colItemHref);
                                hrefHTML.append("', '");
                                hrefHTML.append(windowWidth);
                                hrefHTML.append("', '");
                                hrefHTML.append(windowHeight);
                                hrefHTML.append("', '");
                                hrefHTML.append(popupModal);
                                hrefHTML.append("', '");
                                hrefHTML.append(targetLocation);
                                hrefHTML.append("', '");
                                hrefHTML.append(onselectAction);

 //   * Code added for PowerView Enhancement Feature.
 //   * The emxTableColumnLinkClick method dynamically assigns the 'src' of iframe with the required 'href'
 //   * and displays the 'href' content in the target tab.
 //   * 16 Aug 2007
                                hrefHTML.append("', '");
                                hrefHTML.append(XSSUtil.encodeForURL(context, tempColumnVal));
                                hrefHTML.append("', '");
                                hrefHTML.append("false");
                                hrefHTML.append("', '");
                                hrefHTML.append(popupsize);
                                hrefHTML.append("', '");
                                hrefHTML.append(tableBean.getSetting(columnMap, "Slidein Width"));
                                hrefHTML.append("')");

                                String displayTime = "";
                                String displayFormat = "";
                                if (colFormat.equalsIgnoreCase("date"))
                                {
                                    displayTime = tableBean.getSetting(columnMap, "Display Time");
                                    if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
                                        displayTime = "";
                                    }
                                    displayFormat = tableBean.getSetting(columnMap, "Display Format");

                                    if ( displayFormat != null && displayFormat.length() > 0  && (!tableBean.isAssociatedWithDimension(columnMap) || tableBean.isAlphanumericField(columnMap)))
                                    {
                                        DateFrm = displayFormat.trim();
                                    }

                                    if ( displayTime == null ||
                                            displayTime.trim().length() == 0 ||
                                            ( !displayTime.equalsIgnoreCase("true") &&
                                                !displayTime.equalsIgnoreCase("false") ) )
                                    {
                                        displayTime = prefTimeDisp;
                                    }
                                }

                                if (showIcon || showPrependIcon)
                                {
                                    if("user".equalsIgnoreCase(colFormat)) {
                                            columnValue = PersonUtil.getFullName(context, columnValue);
                                    }

                                    if (prependIcons != null && prependIcons.trim().length()>0){
                                           objectIcon=prependIcons;
                                    }else{

                                            if (objectIcons != null && objectIcons.size() > 0)
                                            {
                                                try {
                                                    objectIcon = (String)objectIcons.get(noColValues);
                                                } catch (Exception est) {
                                                    objectIcon = (String)objectIcons.firstElement();
                                                }
                                            }
                                    }
                                    if(hasReadAccess){
%>
										   <!-- //XSSOK -->
                                           <table><tr><td rmb="<%=strRMBSetting%>" rmbID = "<%=passOID%>" rmbRelID="<%=passRELID%>" ><a href="<%=hrefHTML.toString()%>"  class="object"><img border="0" src="<%=objectIcon%>" /></a></td><td rmb="<%=strRMBSetting%>" rmbID ="<%=passOID%>" rmbRelID="<%=passRELID%>"><a href="<%=hrefHTML.toString()%>" class="object"><xss:encodeForHTML><%=columnValue%></xss:encodeForHTML></a></td></tr></table>
                                        <%
                                    }
                                    else{

                                        %>
                                        <table><tr><td rmb="<%=strRMBSetting%>" rmbID = "<%=passOID%>" rmbRelID="<%=passRELID%>" ><img border="0" src="<%=objectIcon%>" /></td><td rmb="<%=strRMBSetting%>" rmbID ="<%=passOID%>" rmbRelID="<%=passRELID%>"><span class="object"> <xss:encodeForHTML><%=columnValue%></xss:encodeForHTML></span></td></tr></table>
                                     <%

                                    }
                                } else {
                                    if (colFormat.equalsIgnoreCase("date")) {
%>
                                        <!-- //XSSOK -->
                                        <a href="<%=hrefHTML.toString()%>"><emxUtil:lzDate displaydate='true' displaytime='<%=displayTime%>' localize="i18nId" tz='<%=XSSUtil.encodeForHTMLAttribute(context, (String)session.getAttribute("timeZone"))%>' format='<%=DateFrm%>'><%= columnValue %></emxUtil:lzDate></a>&nbsp;
<%
                                    } else {
                                        if("user".equalsIgnoreCase(colFormat)) {
                                            columnValue = PersonUtil.getFullName(context, columnValue);
                                        }
	                                    if(hasReadAccess){
%>
                                        <a href="<%=hrefHTML.toString()%>"><xss:encodeForHTML><%=columnValue%></xss:encodeForHTML></a>&nbsp;
<%
	                                    }else{
	                                    	%>
	                                    	<xss:encodeForHTML><%=columnValue%></xss:encodeForHTML>
	                                    	<%
	                                    }
                                    }

                                    if (colValueList.size() > 1)
                                    {
%>
                                        <br /><br />
<%
                                    }
                                }
                            }
                            if (showIcon || showPrependIcon)
                            {
%>
                                </div>
<%
                            }
                        }
                    } //End: switch
%></td><%
                }
            }
            else if ( columnType.equals("programHTMLOutput") )
            {
                columnValue = programResult[j].get(resultIndex).toString();
                if (columnValue == null || columnValue.length() == 0)
                {
                    columnValue = "&nbsp;";
                }
                if(UIComponent.getUIAutomationStatus(context)){
%><td<%=nowrap%><%=strClassCode%> data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" rmb="<%=strRMBSetting%>" rmbID="<%=passOID%>" rmbRelID="<%=passRELID%>" ><%=columnValue%></td><%
                } else {
%><td<%=nowrap%><%=strClassCode%> rmb="<%=strRMBSetting%>" rmbID="<%=passOID%>" rmbRelID="<%=passRELID%>" ><%=columnValue%></td><%
                }
            } else if ( columnType.equalsIgnoreCase("Image") )
            {
                if(!FrameworkUtil.isThisSuiteRegistered(context,session,"eServiceSuiteCommonComponents")){
                    continue;
                }
                columnValue = "";
                String imageViewerURL = "../components/emxImageManager.jsp?HelpMarker=emxhelpimagesview&objectId=" + passOID;
                if(href != null && href.toString().length() > 0) {
                    imageViewerURL = href.toString();
                    imageViewerURL += "&objectId=" + passOID;

                }
          if(reportMode){
	              columnValue = imageResult[j].get(resultIndex).toString();
          }else{
	              columnValue = "<a href='javascript:showModalDialog(\"" + imageViewerURL + "\",850,650)'>" + imageResult[j].get(resultIndex).toString() + "</a>";
                }

		if(!reportMode){
			if(UIComponent.getUIAutomationStatus(context)){
%><td data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" width="1%" ALIGN="center" rmb="<%=strRMBSetting%>" rmbID="<%=passOID%>" rmbRelID="<%=passRELID%>" ><%=columnValue%>&nbsp;</td><%
			} else {
%><td width="1%" ALIGN="center" rmb="<%=strRMBSetting%>" rmbID="<%=passOID%>" rmbRelID="<%=passRELID%>" ><%=columnValue%>&nbsp;</td><%
				}
            }
            }
            else if ( columnType.equals("icon") )
            {
                // Added for Bug 336642
                String columnSelect = tableBean.getBusinessObjectSelect(columnMap);
                StringList colValueList = new StringList();
                if(columnSelect != null && columnSelect.length()>0)
                {
                    colValueList = (StringList)(bwsl.getElement(i).getSelectDataList(columnSelect));
                     colValueList = UINavigatorUtil.getAdminI18NStringList(adminType, colValueList, languageStr);
                }
                // Ended

                String targetLocation = tableBean.getSetting(columnMap, "Target Location");
                String popupsize = tableBean.getSetting(columnMap, "Popup Size");
                String windowWidth = tableBean.getSetting(columnMap, "Window Width");
                String windowHeight = tableBean.getSetting(columnMap, "Window Height");
                String popupModal = tableBean.getSetting(columnMap, "Popup Modal");
                if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
                    popupModal = "false";
                }
                columnValue = tableBean.getSetting(columnMap, "Column Icon");
                if(columnValue != null && columnValue.length() > 0) {
                    columnValue = UINavigatorUtil.parseHREF(context,columnValue, tableBean.getSetting(columnMap, "Registered Suite"));
                }

                String altText = tableBean.getAlt(columnMap);

                if((portalMode != null && "true".equalsIgnoreCase(portalMode))  ||
                  (launched != null && "true".equalsIgnoreCase(launched)))
                {
 //code commented for PowerView Enhancement 16 Aug 2007
                             //targetLocation = "popup";
                    if(windowWidth == null || "".equals(windowWidth))
                    {
                        windowWidth = "700";
                        windowHeight = "600";
                    }
                }

                if(altText == null || altText.equals("null")) {
              altText = "";
                }

                if (columnValue == null || columnValue.length() == 0 || (tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap))) {
                    columnValue = "&nbsp;";
                }

                if(!reportMode){
                if (    href == null || href.toString().length() == 0) {
                	if(UIComponent.getUIAutomationStatus(context)){
%><td<%=nowrap%><%=strClassCode%> data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" rmb="<%=strRMBSetting%>" rmbID="<%=passOID%>" rmbRelID="<%=passRELID%>" style="text-align: center"><img border="0" src="<%= columnValue %>" title="<%=altText%>">&nbsp;</td><%
                	} else {
%><td<%=nowrap%><%=strClassCode%> rmb="<%=strRMBSetting%>" rmbID="<%=passOID%>" rmbRelID="<%=passRELID%>" style="text-align: center"><img border="0" src="<%= columnValue %>" title="<%=altText%>" />&nbsp;</td><%
                }
                }
                else
                {
                if((colValueList.size()>0 && alternateOIDSelect.length()>0) || alternateOIDSelect.length()>0)
                {
                    %><td><table border="0"><%
                    for(int noOfValues=0;noOfValues<colValueList.size();noOfValues++)
                    {
                      if (passOIDList != null && passOIDList.size() > 0)
                            passOID = (String)passOIDList.get(noOfValues);
                      String colItemHref = href.toString();
                        if(portalMode != null && "true".equalsIgnoreCase(portalMode)) {
                                colItemHref += "&portalCmdName=" + (String)requestMap.get("portalCmdName");
                        }
                        if(isObjectBased){
                            colItemHref += "&objectId=" + passOID;
                        }
     //Additional parameters added for PowerView Enhancement 16 Aug 2007
     //columnValue and indented table boolean value 'false'
     if(UIComponent.getUIAutomationStatus(context)){
    %><tr><td<%=nowrap%><%=strClassCode%> data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" rmb="<%=strRMBSetting%>" style="text-align: left" rmbID="<%=passOID%>" rmbRelID="<%=passRELID%>" ><a href="javascript:emxTableColumnLinkClick('<%=colItemHref%>', '<%=windowWidth%>', '<%=windowHeight%>', '<%=popupModal%>', '<%=targetLocation%>', '<%=onselectAction%>','<%=columnValue%>','false', '<%=popupsize%>', '<%=tableBean.getSetting(columnMap, "Slidein Width")%>')"><img border="0" src="<%= columnValue %>" title="<%=altText%>">&nbsp;<%=colValueList.get(noOfValues)%></a></td></tr><%
     } else {
    %><tr><td<%=nowrap%><%=strClassCode%> rmb="<%=strRMBSetting%>" style="text-align: left" rmbID="<%=passOID%>" rmbRelID="<%=passRELID%>" ><a href="javascript:emxTableColumnLinkClick('<%=colItemHref%>', '<%=windowWidth%>', '<%=windowHeight%>', '<%=popupModal%>', '<%=targetLocation%>', '<%=onselectAction%>','<%=columnValue%>','false', '<%=popupsize%>', '<%=tableBean.getSetting(columnMap, "Slidein Width")%>')"><img border="0" src="<%= columnValue %>" title="<%=altText%>" />&nbsp;<%=colValueList.get(noOfValues)%></a></td></tr><%
                    }
                    }
                    %></table></td><%
                }
                else if(alternateOIDSelect.length()==0)
                {
                      String colItemHref = href.toString();
                        if(portalMode != null && "true".equalsIgnoreCase(portalMode)) {
                                colItemHref += "&portalCmdName=" + (String)requestMap.get("portalCmdName");
                        }
                        if(isObjectBased){
                            colItemHref += "&objectId=" + passOID;
                        }
     //Additional parameters added for PowerView Enhancement 16 Aug 2007
     //columnValue and indented table boolean value 'false'
     if(UIComponent.getUIAutomationStatus(context)){
    %><td<%=nowrap%><%=strClassCode%> data-aid="<%=columnName%>" rmb="<%=strRMBSetting%>" style="text-align: center" rmbID="<%=passOID%>" rmbRelID="<%=passRELID%>" ><a href="javascript:emxTableColumnLinkClick('<%=colItemHref%>', '<%=windowWidth%>', '<%=windowHeight%>', '<%=popupModal%>', '<%=targetLocation%>', '<%=onselectAction%>','<%=columnValue%>','false', '<%=popupsize%>', '<%=tableBean.getSetting(columnMap, "Slidein Width")%>')"><img border="0" src="<%= columnValue %>" title="<%=altText%>" /></a>&nbsp;</td><%
     } else {
    %><td<%=nowrap%><%=strClassCode%> rmb="<%=strRMBSetting%>" style="text-align: center" rmbID="<%=passOID%>" rmbRelID="<%=passRELID%>" ><a href="javascript:emxTableColumnLinkClick('<%=colItemHref%>', '<%=windowWidth%>', '<%=windowHeight%>', '<%=popupModal%>', '<%=targetLocation%>', '<%=onselectAction%>','<%=columnValue%>','false', '<%=popupsize%>', '<%=tableBean.getSetting(columnMap, "Slidein Width")%>')"><img border="0" src="<%= columnValue %>" title="<%=altText%>" /></a>&nbsp;</td><%
                        }
                        
                }
				}
				}
            } else if (columnType.equals("checkbox") )
            {
                columnValue = checkboxAccess[j].get(resultIndex).toString();

                if ( reportMode )
                {
%>
                    <!-- <th></th> -->
<%
                } else {
                    if (columnValue == null || columnValue.length() == 0)
                        columnValue = "true";

                    if (selection.equals("single"))
                    {
                        if (columnValue != null && columnValue.equals("true") ) {
                        	if(UIComponent.getUIAutomationStatus(context)){
%><td<%=nowrap%> data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" style="text-align: center"><input type="radio" name="<%=checkboxName%>" value="<%=sValue%>" onclick="doRadioButtonClick(this);">&nbsp;</td><%
                        	} else {
%><td<%=nowrap%> style="text-align: center"><input type="radio" name="<%=checkboxName%>" value="<%=sValue%>" onclick="doRadioButtonClick(this);" />&nbsp;</td><%
                        	}
                        } else {
                        	if(UIComponent.getUIAutomationStatus(context)){
%><td<%=nowrap%> data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" style="text-align: center"><img src="images/utilRadioOffDisabled.gif"></td><%
                        } else {
%><td<%=nowrap%> style="text-align: center"><img src="images/utilRadioOffDisabled.gif" /></td><%
                        }
                        }
                    } else {
                        if (columnValue != null && columnValue.equals("true") ) {
                        	if(UIComponent.getUIAutomationStatus(context)){
%><td<%=nowrap%> data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" style="text-align: center" width="16"><input type="checkbox" name="<%=checkboxName%>" value="<%=sValue%>" onclick="doCheckboxClick(this, event); doSelectAllCheck(this)"><script>strPageIDs += "<%=sValue%>" + "~";</script></td><%
                    } else {
%><!-- //XSSOK -->
<td<%=nowrap%> style="text-align: center" width="16"><input type="checkbox" name="<%=checkboxName%>" value="<%=sValue%>" onclick="doCheckboxClick(this, event); doSelectAllCheck(this)" /><script>strPageIDs += "<%=sValue%>" + "~";</script></td><%
                        	}
                        } else {
                        	if(UIComponent.getUIAutomationStatus(context)){
                            //Bug 348880 removed &nbsp;
%><td<%=nowrap%> data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" style="text-align: center"><img src="images/utilCheckOffDisabled.gif"></td><%
                        	} else {
%><td<%=nowrap%> style="text-align: center"><img src="images/utilCheckOffDisabled.gif" /></td><%
                        }
                    }
                }
                }
            }else if(columnType.equalsIgnoreCase("File")){
                columnValue = fileResult[j].get(resultIndex).toString();
                if (columnValue == null || columnValue.length() == 0)
                {
                    columnValue = "&nbsp;";
                }
                if(UIComponent.getUIAutomationStatus(context)){
%><td<%=nowrap%><%=strClassCode%> data-aid="<xss:encodeForHTMLAttribute><%=columnName%></xss:encodeForHTMLAttribute>" rmb="<%=strRMBSetting%>" rmbID="<%=passOID%>" rmbRelID="<%=passRELID%>" ><%=columnValue%>&nbsp;</td><%
                } else {
%><td<%=nowrap%><%=strClassCode%> rmb="<%=strRMBSetting%>" rmbID="<%=passOID%>" rmbRelID="<%=passRELID%>" ><%=columnValue%>&nbsp;</td><%
                }
             }
            }
      StringList valuesList = (StringList) valuesColumnMap.get(columnName);
      if(valuesList != null) {
          String sUOMValue = "";
        if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
            if(colValueUOMList != null) {
                sUOMValue = (String)colValueUOMList.firstElement();
            }
            valuesList.add(sUOMValue);
        }else {
        valuesList.add(columnValue);
        }
        valuesColumnMap.put(columnName, valuesList);
      }
        }
        if(hasReadAccess){
        	resultIndex++;
        }
%></td></tr>
<%
    }
}

if(hasCalculationsColumn)
{
  Locale localeObj = request.getLocale();
  //Locale localeObj = null;
  String pageStr = UINavigatorUtil.getI18nString("emxFramework.TableComponent.Page", "emxFrameworkStringResource", languageStr);
  String allStr = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.All", "emxFrameworkStringResource", languageStr);
  String itemsStr = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.Items", "emxFrameworkStringResource", languageStr);
  StringBuffer pageCalculationHeader = new StringBuffer(100);
  pageCalculationHeader.append(pageStr);
  pageCalculationHeader.append(" (");
  pageCalculationHeader.append(relBusObjPageList.size());
  pageCalculationHeader.append(" ");
  pageCalculationHeader.append(itemsStr);
  pageCalculationHeader.append(")");


  StringBuffer allCalculationHeader = new StringBuffer(100);
  allCalculationHeader.append(allStr);
  allCalculationHeader.append(" (");
  allCalculationHeader.append(relBusObjList.size());
  allCalculationHeader.append(" ");
  allCalculationHeader.append(itemsStr);
  allCalculationHeader.append(")");

  int numcols = columns.size();
  int startindex = 0;
  if ( checkBoxDefined ){
    if(reportMode ) {
      numcols--;
      startindex = 2;
    }
    else {
      startindex = 1;
    }
  }
  else {
    if(reportMode ) {
      startindex = 1;
    } else if(!selection.equals("single") &&  !selection.equals("multiple")) {
      startindex = 1;
     } else {
          numcols++;
        }
  }


  boolean iMultipageMode = tableBean.isMultiPageMode(tableControlMap);
  int numpages = (tableBean.getNumberOfPages(tableControlMap)).intValue();
  int currentpage = 1;
  if((tableBean.getPagination(tableControlMap)).intValue() > 0) {
    currentpage = tableBean.getPageEndIndex(tableControlMap) / (tableBean.getPagination(tableControlMap)).intValue();
  }

  HashMap allValuesColumnMap = (HashMap) tableControlMap.get("All Values Map");
  // This one is added to recalculate the calculations if one of the object is updated using the web form
  String clearValuesMap = emxGetParameter(request, "clearValuesMap");
  if(allValuesColumnMap == null || (clearValuesMap != null && "true".equalsIgnoreCase(clearValuesMap)))
  {
    allValuesColumnMap = new HashMap();
    HashMap columnValuesMap = tableBean.getColumnValuesMap(context, application, relBusObjList, tableData);
    bwsl = (BusinessObjectWithSelectList)columnValuesMap.get("Businessobject");
    rwsl = (RelationshipWithSelectList)columnValuesMap.get("Relationship");
    programResult = (Vector[])columnValuesMap.get("Program");
    checkboxAccess = (Vector[])columnValuesMap.get("Checkbox");

    StringList allvaluesList = null;
    int resultIndex = 0;
    for (int i = 0; i < relBusObjList.size(); i++)
    {
        Map elementMap = (Map)relBusObjList.get(i);
        boolean hasReadAccess = true;
        if(UIUtil.isNotNullAndNotEmpty((String)elementMap.get("objReadAccess"))){
        	hasReadAccess = Boolean.valueOf((String)elementMap.get("objReadAccess"));
        }
        HashMap columnMap = new HashMap();
        if(hasReadAccess){
        for (int j = 0; j < noOfColumns; j++)
        {
            columnMap = (HashMap)columns.get(j);
            String columnName = tableBean.getName(columnMap);
            String columnType = tableBean.getSetting(columnMap, "Column Type");

            if(tableBean.isColumnNumericForCalculations(context, columnMap))
            {
                allvaluesList = (StringList)allValuesColumnMap.get(columnName);
                if(allvaluesList == null) {
                    allvaluesList = new StringList();
                }
                columnValue = "";
                StringList colValueList = new StringList();
                StringList colValueDisplayList = new StringList();

                if (columnType.equals("businessobject") )
                {
                    String columnSelect = tableBean.getBusinessObjectSelect(columnMap);
                    if(tableBean.isAssociatedWithDimension(columnMap)  && !(UOMUtil.isSimpleAttributeExpression(columnSelect)) && !tableBean.isAlphanumericField(columnMap)) {
                        columnSelect = (String)columnMap.get("UOM Db Select");
                    }
                    colValueList = (StringList)(bwsl.getElement(i).getSelectDataList(columnSelect));
                } else if (columnType.equals("relationship") ) {
                    String columnSelect = tableBean.getRelationshipSelect(columnMap);
                    if(tableBean.isAssociatedWithDimension(columnMap)  && !(UOMUtil.isSimpleAttributeExpression(columnSelect)) && !tableBean.isAlphanumericField(columnMap)) {
                        columnSelect = (String)columnMap.get("UOM Db Select");
                    }
                    RelationshipWithSelect rws = (RelationshipWithSelect)rwsl.elementAt(i);
                    Hashtable columnInfo = rws.getRelationshipData();
                    try {
                        colValueList.add((String)columnInfo.get(columnSelect));
                    } catch (Exception ex) {
                        colValueList = (StringList)columnInfo.get(columnSelect);
                    }
                } else if (columnType.equals("program") ) {
                    if(i <= (programResult[j].size() - 1))
                    {
	                        HashMap  cellValueMap = (HashMap)programResult[j].get(resultIndex);
                        colValueList.add((String)cellValueMap.get("ActualValue"));
                    }
                }

                if ( colValueList != null && colValueList.size() > 0 ) {
                    columnValue = (String)(colValueList.firstElement());
                }

                allvaluesList.add(columnValue);
                allValuesColumnMap.put(columnName, allvaluesList);
            }
        }
			if(hasReadAccess){
	        	resultIndex++;
	        }
        }
    }
    tableControlMap.put("All Values Map", allValuesColumnMap);
  }


  String pageHeaderHtml = "<tr><th colspan=\"" + numcols + "\">" + pageCalculationHeader.toString() + "</th></tr>";
  String allHeaderHtml = "<tr><th colspan=\"" + numcols + "\">" + allCalculationHeader.toString()+ "</th></tr>";

  String trHtml = "<tr class=\"calculation\">";
  String tdHtml = "<td>";

  StringBuffer sumHtml = new StringBuffer(300);
  sumHtml.append(trHtml);
  sumHtml.append("<td>");
  sumHtml.append(UINavigatorUtil.getI18nString("emxFramework.TableCalculation.Sum", "emxFrameworkStringResource", languageStr));
  sumHtml.append("</td>");

  StringBuffer averageHtml = new StringBuffer(300);
  averageHtml.append(trHtml);
  averageHtml.append("<td>");
  averageHtml.append(UINavigatorUtil.getI18nString("emxFramework.TableCalculation.Average", "emxFrameworkStringResource", languageStr));
  averageHtml.append("</td>");

  StringBuffer maximumHtml = new StringBuffer(300);
  maximumHtml.append(trHtml);
  maximumHtml.append("<td>");
  maximumHtml.append(UINavigatorUtil.getI18nString("emxFramework.TableCalculation.Maximum", "emxFrameworkStringResource", languageStr));
  maximumHtml.append("</td>");

  StringBuffer minimumHtml = new StringBuffer(300);
  minimumHtml.append(trHtml);
  minimumHtml.append("<td>");
  minimumHtml.append(UINavigatorUtil.getI18nString("emxFramework.TableCalculation.Minimum", "emxFrameworkStringResource", languageStr));
  minimumHtml.append("</td>");

  StringBuffer medianHtml = new StringBuffer(300);
  medianHtml.append(trHtml);
  medianHtml.append("<td>");
  medianHtml.append(UINavigatorUtil.getI18nString("emxFramework.TableCalculation.Median", "emxFrameworkStringResource", languageStr));
  medianHtml.append("</td>");

  StringBuffer stdDevHtml = new StringBuffer(300);
  stdDevHtml.append(trHtml);
  stdDevHtml.append("<td>");
  stdDevHtml.append(UINavigatorUtil.getI18nString("emxFramework.TableCalculation.StandardDeviation", "emxFrameworkStringResource", languageStr));
  stdDevHtml.append("</td>");

  StringBuffer customHtml = new StringBuffer(300);
  customHtml.append(trHtml);
  customHtml.append("<td>");
  customHtml.append(UINavigatorUtil.getI18nString("emxFramework.TableCalculation.Custom", "emxFrameworkStringResource", languageStr));
  customHtml.append("</td>");

  StringBuffer allsumHtml = new StringBuffer(300);
  allsumHtml.append(sumHtml.toString());
  StringBuffer allaverageHtml = new StringBuffer(300);
  allaverageHtml.append(averageHtml.toString());
  StringBuffer allmaximumHtml = new StringBuffer(300);
  allmaximumHtml.append(maximumHtml.toString());
  StringBuffer allminimumHtml = new StringBuffer(300);
  allminimumHtml.append(minimumHtml.toString());
  StringBuffer allmedianHtml = new StringBuffer(300);
  allmedianHtml.append(medianHtml.toString());
  StringBuffer allstdDevHtml = new StringBuffer(300);
  allstdDevHtml.append(stdDevHtml.toString());
  StringBuffer allcustomHtml = new StringBuffer(300);
  allcustomHtml.append(customHtml.toString());


  int decPecProp = Integer.parseInt(EnoviaResourceBundle.getProperty(context, "emxFramework.TableCalculations.DecimalPrecision"));

  if(iMultipageMode && numpages > 1) {
%>
    <!-- //XSSOK -->
    <%=pageHeaderHtml%>
<%

    for (int i = startindex; i < columns.size(); i++)
    {
      HashMap columnMap = (HashMap)columns.get(i);
      String unitName = (String)columnMap.get("DB Unit");
      if(unitName == null || tableBean.isAlphanumericField(columnMap)) {
          unitName = "";
      } else {
          unitName = "&nbsp;" + i18nNow.getDimensionI18NString(FrameworkUtil.findAndReplace(unitName, " ", "_"), languageStr);
      }
      String columnName = tableBean.getName(columnMap);

      sumHtml.append(tdHtml);
      averageHtml.append(tdHtml);
      maximumHtml.append(tdHtml);
      minimumHtml.append(tdHtml);
      medianHtml.append(tdHtml);
      stdDevHtml.append(tdHtml);
      customHtml.append(tdHtml);

      String calcSum = tableBean.getSetting(columnMap, "Calculate Sum");
      String calcAverage = tableBean.getSetting(columnMap, "Calculate Average");
      String calcMaximum = tableBean.getSetting(columnMap, "Calculate Maximum");
      String calcMinimum = tableBean.getSetting(columnMap, "Calculate Minimum");
      String calcMedian = tableBean.getSetting(columnMap, "Calculate Median");
      String calcStandardDeviation = tableBean.getSetting(columnMap, "Calculate Standard Deviation");
      String calcCustom = tableBean.getSetting(columnMap, "Calculate Custom");
      String decimalPrecision = tableBean.getSetting(columnMap, "Decimal Precision");
      int decPec = -1;
      try{
          decPec = Integer.parseInt(decimalPrecision);
      } catch(NumberFormatException nfe) {
          decPec = decPecProp;
      }

      if(calcSum != null && "true".equalsIgnoreCase(calcSum)) {
        sumHtml.append(FrameworkUtil.getSum(context, localeObj, (StringList) valuesColumnMap.get(columnName)));
        sumHtml.append(unitName);
        sumHtml.append("</td>");
      } else{
        sumHtml.append(" </td>");
      }

      if(calcAverage != null && "true".equalsIgnoreCase(calcAverage)) {
        averageHtml.append(FrameworkUtil.getAverage(context, localeObj, (StringList) valuesColumnMap.get(columnName), decPec));
        averageHtml.append(unitName);
        averageHtml.append("</td>");
      } else{
        averageHtml.append(" </td>");
      }

      if(calcMaximum != null && "true".equalsIgnoreCase(calcMaximum)) {
        maximumHtml.append(FrameworkUtil.getMaximum(context, localeObj, (StringList) valuesColumnMap.get(columnName)));
        maximumHtml.append(unitName);
        maximumHtml.append("</td>");
      } else{
        maximumHtml.append(" </td>");
      }

      if(calcMinimum != null && "true".equalsIgnoreCase(calcMinimum)) {
        minimumHtml.append(FrameworkUtil.getMinimum(context, localeObj, (StringList) valuesColumnMap.get(columnName)));
        minimumHtml.append(unitName);
        minimumHtml.append("</td>");
      } else{
        minimumHtml.append(" </td>");
      }

      if(calcMedian != null && "true".equalsIgnoreCase(calcMedian)) {
        medianHtml.append(FrameworkUtil.getMedian(context, localeObj, (StringList) valuesColumnMap.get(columnName), decPec));
        medianHtml.append(unitName);
        medianHtml.append("</td>");
      } else{
        medianHtml.append("</td>");
      }

      if(calcStandardDeviation != null && "true".equalsIgnoreCase(calcStandardDeviation)) {
        stdDevHtml.append(FrameworkUtil.getStandardDeviation(context, localeObj, (StringList) valuesColumnMap.get(columnName), decPec));
        stdDevHtml.append(unitName);
        stdDevHtml.append("</td>");
      } else{
        stdDevHtml.append(" </td>");
      }

      /*
      if(calcCustom != null && "true".equalsIgnoreCase(calcCustom)) {
        customHtml += FrameworkUtil.getSum(context, localeObj, (StringList) valuesColumnMap.get(columnName)) + "</td>";
      } else{
        customHtml +=" </td>";
      }
      */

    } // end of for

    sumHtml.append("</tr>");
    averageHtml.append("</tr>");
    maximumHtml.append("</tr>");
    minimumHtml.append("</tr>");
    medianHtml.append("</tr>");
    stdDevHtml.append("</tr>");
    customHtml.append("</tr>");

%>
    <!-- //XSSOK -->
    <%=(hasSumColumn?sumHtml.toString():"")%>
    <!-- //XSSOK -->
    <%=(hasAverageColumn?averageHtml.toString():"")%>
    <!-- //XSSOK -->
    <%=(hasMaximumColumn?maximumHtml.toString():"")%>
    <!-- //XSSOK -->
    <%=(hasMinimumColumn?minimumHtml.toString():"")%>
    <!-- //XSSOK -->
    <%=(hasMedianColumn?medianHtml.toString():"")%>
    <!-- //XSSOK -->
    <%=(hasStandardDeviationColumn?stdDevHtml.toString():"")%>
    <!-- //XSSOK -->
    <%=(hasCustomColumn?customHtml.toString():"")%>
<%
  }
%>
    <!-- //XSSOK -->
    <%=allHeaderHtml%>
<%
    for (int i = startindex; i < columns.size(); i++)
    {
      HashMap columnMap = (HashMap)columns.get(i);
      String unitName = (String)columnMap.get("DB Unit");
      if(unitName == null || tableBean.isAlphanumericField(columnMap)) {
          unitName = "";
      } else {
          unitName = "&nbsp;" + i18nNow.getDimensionI18NString(FrameworkUtil.findAndReplace(unitName, " ", "_"), languageStr);
      }
      String columnName = tableBean.getName(columnMap);

      allsumHtml.append(tdHtml);
      allaverageHtml.append(tdHtml);
      allmaximumHtml.append(tdHtml);
      allminimumHtml.append(tdHtml);
      allmedianHtml.append(tdHtml);
      allstdDevHtml.append(tdHtml);
      allcustomHtml.append(tdHtml);

      String calcSum = tableBean.getSetting(columnMap, "Calculate Sum");
      String calcAverage = tableBean.getSetting(columnMap, "Calculate Average");
      String calcMaximum = tableBean.getSetting(columnMap, "Calculate Maximum");
      String calcMinimum = tableBean.getSetting(columnMap, "Calculate Minimum");
      String calcMedian = tableBean.getSetting(columnMap, "Calculate Median");
      String calcStandardDeviation = tableBean.getSetting(columnMap, "Calculate Standard Deviation");
      String calcCustom = tableBean.getSetting(columnMap, "Calculate Custom");
      String decimalPrecision = tableBean.getSetting(columnMap, "Decimal Precision");
      int decPec = -1;
      try{
          decPec = Integer.parseInt(decimalPrecision);
      } catch(NumberFormatException nfe) {
          decPec = decPecProp;
      }

      if(calcSum != null && "true".equalsIgnoreCase(calcSum)) {
        allsumHtml.append(FrameworkUtil.getSum(context, localeObj, (StringList) allValuesColumnMap.get(columnName)));
        allsumHtml.append(unitName);
        allsumHtml.append("</td>");
      } else{
        allsumHtml.append(" </td>");
      }

      if(calcAverage != null && "true".equalsIgnoreCase(calcAverage)) {
        allaverageHtml.append(FrameworkUtil.getAverage(context, localeObj, (StringList) allValuesColumnMap.get(columnName), decPec));
        allaverageHtml.append(unitName);
        allaverageHtml.append("</td>");
      } else{
        allaverageHtml.append(" </td>");
      }

      if(calcMaximum != null && "true".equalsIgnoreCase(calcMaximum)) {
        allmaximumHtml.append(FrameworkUtil.getMaximum(context, localeObj, (StringList) allValuesColumnMap.get(columnName)));
        allmaximumHtml.append(unitName);
        allmaximumHtml.append("</td>");
      } else{
        allmaximumHtml.append(" </td>");
      }

      if(calcMinimum != null && "true".equalsIgnoreCase(calcMinimum)) {
        allminimumHtml.append(FrameworkUtil.getMinimum(context, localeObj, (StringList) allValuesColumnMap.get(columnName)));
        allminimumHtml.append(unitName);
        allminimumHtml.append("</td>");
      } else{
        allminimumHtml.append(" </td>");
      }

      if(calcMedian != null && "true".equalsIgnoreCase(calcMedian)) {
        allmedianHtml.append(FrameworkUtil.getMedian(context, localeObj, (StringList) allValuesColumnMap.get(columnName), decPec));
        allmedianHtml.append(unitName);
        allmedianHtml.append("</td>");
      } else{
        allmedianHtml.append("</td>");
      }

      if(calcStandardDeviation != null && "true".equalsIgnoreCase(calcStandardDeviation)) {
        allstdDevHtml.append(FrameworkUtil.getStandardDeviation(context, localeObj, (StringList) allValuesColumnMap.get(columnName), decPec));
        allstdDevHtml.append(unitName);
        allstdDevHtml.append("</td>");
      } else{
        allstdDevHtml.append(" </td>");
      }

      /*
      if(calcCustom != null && "true".equalsIgnoreCase(calcCustom)) {
        allcustomHtml += FrameworkUtil.getSum(context, localeObj, (StringList) allValuesColumnMap.get(columnName)) + "</td>";
      } else{
        allcustomHtml +=" </td>";
      }
      */
    } // end of for

    allsumHtml.append("</tr>");
    allaverageHtml.append("</tr>");
    allmaximumHtml.append("</tr>");
    allminimumHtml.append("</tr>");
    allmedianHtml.append("</tr>");
    allstdDevHtml.append("</tr>");
    allcustomHtml.append("</tr>");
%>
    <!-- //XSSOK -->
    <%=(hasSumColumn?allsumHtml.toString():"")%>
    <!-- //XSSOK -->
    <%=(hasAverageColumn?allaverageHtml.toString():"")%>
    <!-- //XSSOK -->
    <%=(hasMaximumColumn?allmaximumHtml.toString():"")%>
    <!-- //XSSOK -->
    <%=(hasMinimumColumn?allminimumHtml.toString():"")%>
    <!-- //XSSOK -->
    <%=(hasMedianColumn?allmedianHtml.toString():"")%>
    <!-- //XSSOK -->
    <%=(hasStandardDeviationColumn?allstdDevHtml.toString():"")%>
    <!-- //XSSOK -->
    <%=(hasCustomColumn?allcustomHtml.toString():"")%>

  <tr class="calculations-bottom">
  <td colspan="<%=numcols%>"><img src="images/utilSpacer.gif" alt="" height="1" /></td>
  </tr>
<%
}
%>
</tbody>
</table>
<%
} catch (Exception ex) {
    ContextUtil.abortTransaction(context);

    if(ex.toString()!=null && (ex.toString().trim()).length()>0){
    	String sErrorMsg = ex.toString();
        int pos = sErrorMsg.indexOf("#5000001:");
        if (pos > -1) {
            sErrorMsg = sErrorMsg.substring(pos+9).trim();
        }
        emxNavErrorObject.addMessage("emxTableDataInclude:" + sErrorMsg.trim());
    }

} finally {
    ContextUtil.commitTransaction(context);
}
%>

