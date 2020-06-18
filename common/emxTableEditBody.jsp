<%-- emxTableEditBody.jsp
   Copyright (c) 1993-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTableEditBody.jsp.rca 1.26 Tue Oct 28 18:55:07 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxFormUtil.inc"%>
<script language="JavaScript" type="text/javascript" src="scripts/emxUITableUtil.js"></script>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%
    // timeStamp to handle the business objectList
    String timeStamp = emxGetParameter(request, "timeStamp");
    String reportFormat = emxGetParameter(request, "reportFormat");

    Vector userRoleList = PersonUtil.getAssignments(context);

    // Process the request object to obtain the table data and set it in Table bean
    if ( tableBean.getTableData(timeStamp) == null )
        tableBean.setTableData(context, request, timeStamp, userRoleList);
    
    HashMap tableData = tableBean.getTableData(timeStamp);
    HashMap requestMap = tableBean.getRequestMap(tableData);
	requestMap.put(UIComponent.UI_TYPE, UIComponent.FLAT_TABLE);
	requestMap.put(UIComponent.FLAT_TABLE_EDIT_MODE,UIComponent.TRUE);

    // Sort the table data
    String sortColumnName = emxGetParameter(request, "sortColumnName");
    if (sortColumnName != null && sortColumnName.trim().length() > 0 && (!(sortColumnName.equals("null"))) )
        tableBean.sortObjects(context, timeStamp);

    // Get business object list from session level Table bean
   

    MapList relBusObjList = tableBean.getFilteredObjectList(tableData);
    // if selectType is checkbox - get column result by invoking the specified JPO
    MapList relBusObjPageList = tableBean.getEditObjectList(context, timeStamp);

    HashMap tableControlMap = tableBean.getControlMap(tableData);

    MapList columns = tableBean.getColumns(tableData);
    int noOfColumns = columns.size();
    int headerRepeatCount = tableBean.getHeaderRepeat(tableControlMap);
    String objectId = (String)requestMap.get("objectId");
    String relId = (String)requestMap.get("relId");
    String jsTreeID = (String)requestMap.get("jsTreeID");
    String helpMarker = (String)requestMap.get("HelpMarker");
    String suiteDir = (String)requestMap.get("suiteDirectory");
    String sHeaderRepeat = (String)requestMap.get("headerRepeat");
    String suiteKey = (String)requestMap.get("suiteKey");
    String preProcessJavaScript = (String)requestMap.get("preProcessJavaScript");
    String languageStr = Request.getLanguage(request);
    String i18nNoAccessMsg = UINavigatorUtil.getI18nString("emxFramework.Access.NoAccess",
            "emxFrameworkStringResource", languageStr);
%>
<html>
   <head>
      <title></title>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "emxFormConstantsInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
        <script language="javascript" src="scripts/emxUICalendar.js"></script>
		<script language="javascript" src="scripts/emxQuery.js"></script>
        <script language="javascript" src="scripts/emxUIFormUtil.js"></script>
        <script language="javascript" src="scripts/emxUITableEditUtil.js"></script>
        <script language="JavaScript" src="scripts/emxUIPopups.js"></script>

      <script type="text/javascript">
<%
		UIForm uif = new UIForm();
		String phtmlcolumns = "";
		HashMap rangeValuesMap=new HashMap();
		for (int i = 0; i < noOfColumns; i++)
        {
            HashMap column = (HashMap)columns.get(i);
            String columnName = tableBean.getName(column);
            String columnType = tableBean.getSetting(column,"Column Type");
            String methodStr = "";
    		boolean validateBadChars = false;
    		boolean validateBadNameChars = false;
    		boolean validateRestrictedBadChars = false;

            if ((uif.getSetting(column, "Validate Type") != null &&
    				uif.getSetting(column, "Validate Type").equalsIgnoreCase("Basic"))) {
    		    validateBadChars = true;
    		}
    		if ((uif.getSetting(column, "Validate Type") != null &&
    				uif.getSetting(column, "Validate Type").equalsIgnoreCase("Name"))) {
    		    validateBadNameChars = true;
    		}
    		if ((uif.getSetting(column, "Validate Type") != null &&
    				uif.getSetting(column, "Validate Type").equalsIgnoreCase("Restricted"))) {
    		    validateRestrictedBadChars = true;
    		}

	        // If the field has validation method add
	        if (uif.hasValidation(column)) {
	        	if(!"".equals(methodStr))
	        	{
	        		methodStr += ",";
	        	}
	        	methodStr += "customValidate:" + uif.getValidationMethod(column);
	        }
	        // If the field is numeric add numeric validation
	        if (uif.isNumericField(column)) {
	        	if(!"".equals(methodStr))
	        	{
	        		methodStr += ",";
	        	}
	        	methodStr += "validateNumericField";
	        }
	        // If the field is an integer , then add integer validation
	        if (uif.isIntegerField(column)) {
	        	if(!"".equals(methodStr))
	        	{
	        		methodStr += ",";
	        	}
	        	methodStr += "validateIntegerField";
	        }
	        // If the field is Required
	        if (uif.isFieldRequired(column)) {
	        	if(!"".equals(methodStr))
	        	{
	        		methodStr += ",";
	        	}
	        	methodStr += "validateRequiredField";
	        }
	        if (uif.isTextAreaField(column) || (uif.isTextBoxField(column))) {
	            if (validateBadChars) {
		        	if(!"".equals(methodStr))
		        	{
		        		methodStr += ",";
		        	}
		        	methodStr += "validateForBadCharacters";
	            }
	            if (validateBadNameChars) {
		        	if(!"".equals(methodStr))
		        	{
		        		methodStr += ",";
		        	}
		        	methodStr += "validateForBadNameCharacters";
	            }
	            if (validateRestrictedBadChars) {
		        	if(!"".equals(methodStr))
		        	{
		        		methodStr += ",";
		        	}
		        	methodStr += "validateForRestrictedBadCharacters";
	            }
	        }

	        if (uif.isFieldEditable(column) && ("programHTMLOutput".equalsIgnoreCase(columnType)|| uif.isClassificationAttributesField(column) || uif.isClassificationPathsField(column))) {
	        	if(phtmlcolumns.length() > 0)
	        	{
	        		phtmlcolumns += ",";
	        	}
	        	phtmlcolumns += columnName;
	        }
	        String strColLabel = tableBean.getLabel(column);
	        strColLabel = FrameworkUtil.findAndReplace(strColLabel,"'","\\\'");
%>
	        columnValidateMap['<%=XSSUtil.encodeForJavaScript(context, columnName)%>'] = '<%=XSSUtil.encodeForJavaScript(context, methodStr)%>';
	        columnLabelMap['<%=XSSUtil.encodeForJavaScript(context, columnName)%>'] = '<%=XSSUtil.encodeForJavaScript(context, strColLabel)%>';
<%
        }
%>
		columnValidateMap.programhtmlcolumns = '<xss:encodeForHTMLAttribute><%=phtmlcolumns%></xss:encodeForHTMLAttribute>';
<%
        if(relBusObjPageList != null && relBusObjPageList.size() > 0){
%>
            columnValidateMap.numobjects = <%=relBusObjPageList.size()%>;
<%
        } else{
%>
            columnValidateMap.numobjects = 0;
<%
        }
%>

        </script>
<%@include file = "../emxStyleListInclude.inc"%>

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
        <script type="text/javascript">
            addStyleSheet("emxUIDefault");
            addStyleSheet("emxUIMenu");
        </script>
		<script type="text/javascript" src="scripts/emxUIFormHandler.js"></script>
		<script type="text/javascript">
			emxUICore.addEventHandler(window, "load",function() { FormHandler.Init(); });
			<%if(preProcessJavaScript != null && !"".equals(preProcessJavaScript)) { %>
				FormHandler.SetPreProcess("<xss:encodeForJavaScript><%=preProcessJavaScript%></xss:encodeForJavaScript>");
			<% } %>
			FormHandler.SetFormType("emxTable");
		</script>
    </head>
<body class="editable" onload=setProgramHTMLFields()>
<form name="editDataForm" method="post" onsubmit="tableEditsaveChanges(); return false">
<input type="hidden" name="isPopup" value="true" />
<input type="hidden" name="selectedRows" value="" />

<%
    HashMap hiddenParamMap = new HashMap();
    hiddenParamMap.putAll(requestMap);
    Enumeration enumParamNames =emxGetParameterNames(request);
    while(enumParamNames.hasMoreElements()) {
        String paramName = (String) enumParamNames.nextElement();
        String paramValue = emxGetParameter(request, paramName);
        if(paramName != null && !"null".equalsIgnoreCase(paramName) && !hiddenParamMap.containsKey(paramName) && paramValue != null && !"null".equals(paramValue) && !"".equals(paramValue) ) {
            hiddenParamMap.put(paramName, paramValue);
        }
    }


    Iterator itr = hiddenParamMap.keySet().iterator();
    while(itr.hasNext()) {
        String paramName = (String) itr.next();
        if(paramName != null && !"null".equalsIgnoreCase(paramName) && !"RequestValuesMap".equalsIgnoreCase(paramName) && !"languageStr".equalsIgnoreCase(paramName) && !"emxTableRowId".equals(paramName) && !"chkList".equals(paramName)) {
%>
            <input type=hidden name="<xss:encodeForHTMLAttribute><%=paramName%></xss:encodeForHTMLAttribute>" value="<xss:encodeForHTMLAttribute><%=hiddenParamMap.get(paramName).toString()%></xss:encodeForHTMLAttribute>" id="<xss:encodeForHTMLAttribute><%=paramName%></xss:encodeForHTMLAttribute>"/>
<%
        }
    }


    String localDateFormat = ((java.text.SimpleDateFormat)java.text.DateFormat.getDateInstance(eMatrixDateFormat.getEMatrixDisplayDateFormat(), request.getLocale())).toLocalizedPattern();
    String allowKeyableDates = "false";
    try {
                    allowKeyableDates = EnoviaResourceBundle.getProperty(context, "emxFramework.AllowKeyableDates");
    } catch(Exception e) {
            allowKeyableDates = "false";
    }

    HashMap inputMap = new HashMap();
    inputMap.put("componentType", "table");
    inputMap.put("localDateFormat", localDateFormat);
    inputMap.put("allowKeyableDates", allowKeyableDates);

try {
        ContextUtil.startTransaction(context, false);
        String timeZone = (String)session.getAttribute("timeZone");
        String showMassUpdate = (String)requestMap.get("massUpdate");
        if(showMassUpdate == null || "".equals(showMassUpdate.trim())) {
                try {
                        showMassUpdate = EnoviaResourceBundle.getProperty(context, "emxFramework.ShowMassUpdate");
                } catch(Exception e) {
                        showMassUpdate = "false";
                }
        }

    //Currency and Unit of Measure Conversion
    String convert = (String)requestMap.get("convert");
    String ccCurrency = null;
    Map ucMap = null;
    String ucUnitSystem = null;
    String strEffectiveDate = null;
    char decimalSeparatorChar = ',';
    Boolean hasDigitSeparator = Boolean.FALSE;

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

    // HashMap tableMap = new HashMap();
    RelationshipWithSelectList rwsl = null;
    BusinessObjectWithSelectList bwsl = null;

    boolean columnSpan = false;

    // if selectType is program - get column result by invoking the specified JPO
    Vector programResult[] = new Vector[noOfColumns];

    int objCount = 0;

    // if column type is File - get column result by calling getColumnValuesMap
    Vector fileResult[] = new Vector[noOfColumns];

	//Added for Overriden type Icons
    MapList iconResults[] = new MapList[noOfColumns];


   boolean reportMode = false;
   Vector imageResult[] = new Vector[noOfColumns];

    if (relBusObjPageList != null && relBusObjPageList.size() > 0)
    {
        String hasGroupBy = (String)tableControlMap.get("HasGroupBy");
        if("true".equals(hasGroupBy)){
            tableBean.processGroupByHeader(context,application,session,pageContext,request,timeStamp,relBusObjPageList);
            relBusObjPageList = tableBean.getGrouped(context, timeStamp,relBusObjPageList);
        }
        HashMap columnValuesMap = tableBean.getColumnValuesMap(context, application, relBusObjPageList, tableData, true);

        bwsl = (BusinessObjectWithSelectList)columnValuesMap.get("Businessobject");
        rwsl = (RelationshipWithSelectList)columnValuesMap.get("Relationship");
        programResult = (Vector[])columnValuesMap.get("Program");
        fileResult = (Vector[])columnValuesMap.get("File");
		//Added for overidden Type icons
        iconResults = (MapList[])columnValuesMap.get("Icons");
		// End

	   imageResult = (Vector[])columnValuesMap.get("Image");

	    if (reportFormat != null && (reportFormat.equals("HTML")
			|| 		reportFormat.equals("ExcelHTML")))
        reportMode = true;



        objCount = relBusObjPageList.size();
    }

 if(relBusObjPageList != null && relBusObjPageList.size() > 0) {
    if (columns != null && columns.size() > 0 )
    {

        String cellpadding = "3";
        String cellspacing = "2";
%>

<input type="hidden" name="objCount" value="<%=objCount%>" /><!-- XSSOK -->
<input type="hidden" name="updatedfieldmap" value="" />
<% for (int i = 0; i < relBusObjPageList.size(); i++)
    {
	    Map elementMap = (Map)relBusObjPageList.get(i);
	    String elementOID = (String)elementMap.get("id");
	    String elementRELID = (String)elementMap.get("id[connection]");
	    %>
	    <input type=hidden name="<%="objectId"+ i%>" value="<xss:encodeForHTMLAttribute><%=elementOID%></xss:encodeForHTMLAttribute>"/>
        <input type=hidden name="<%="relId"+ i%>" value="<xss:encodeForHTMLAttribute><%=elementRELID%></xss:encodeForHTMLAttribute>"/>
	    <%
	}
    }
}
%>
<table class="list">
<%
    // Check if there is a Column Group Header
    if (tableBean.hasGroupHeaderColumn(tableControlMap))
    {
%>
<tr class="groupheader">
<%
        if(showMassUpdate != null && "true".equalsIgnoreCase(showMassUpdate)) {
                %>
                <th width="5%">&nbsp;</th>
<%
        }
        for (int i = 0; i < noOfColumns; i++)
        {
            HashMap columnMap = (HashMap)columns.get(i);
            String columnType = tableBean.getSetting(columnMap, "Column Type");
            String columnName = tableBean.getName(columnMap);
            if(columnType.equals("icon") || columnType.equals("checkbox")) {
                                continue;
                        }
            String columnGroupHeader = tableBean.getSetting(columnMap, "Group Header");
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
                if(groupMapItem != null) {
                	int colSpan = ((Integer)groupMapItem.get("colSpan")).intValue();
                	String translatedGroupHeader = (String)groupMapItem.get("translatedHeader");
                	String strcolspan = "";
                	if(colSpan > 1){
                		strcolspan = "colspan=\"" + String.valueOf(colSpan) + "\"";
                	}
%>
	<th class="groupheader" <%=strcolspan%>><xss:encodeForHTML><%=translatedGroupHeader%></xss:encodeForHTML></th>
<%
                	i = i + colSpan - 1;
            	}
            }
        }
    %>
</tr>
    <%
    }
%>
<tr>
<%
	int columnincre = 0;
    if (columns != null && columns.size() > 0 )
    {

        if(showMassUpdate != null && "true".equalsIgnoreCase(showMassUpdate)) {
            	columnincre = 1;
%>
                <th width="5%"><input type="checkbox" name="chkList" onclick="doCheck()" /></th>
<%
        }
    boolean invalidColumnNameExist = false;

    for (int i = 0; i < noOfColumns; i++)
    {
        HashMap columnMap = (HashMap)columns.get(i);
        String sColumnWidth = tableBean.getSetting(columnMap, "Width");
        if(sColumnWidth == null || sColumnWidth.length() == 0) {
            sColumnWidth = "";
        }else {
            sColumnWidth = "width=\"" + XSSUtil.encodeForHTMLAttribute(context, sColumnWidth) + "\"";
            sColumnWidth = "<img src=\"images/utilSpacer.gif\" " + sColumnWidth + " height=\"1\" alt=\"\" border=\"0\" />";
        }
        String fieldRegisteredDir = "";
        String fieldStringResFileId = "";
        String fieldSuite = "";
        fieldSuite = tableBean.getSetting(columnMap, "Registered Suite");
        if ((fieldSuite != null) && (fieldSuite.trim().length() > 0)) {
            fieldRegisteredDir = UINavigatorUtil.getRegisteredDirectory(context,fieldSuite);
            fieldStringResFileId = UINavigatorUtil.getStringResourceFileId(context,fieldSuite);

            columnMap.put("suiteKey", fieldSuite);
            columnMap.put("suiteDirectory", fieldRegisteredDir);
            columnMap.put("StringResourceFileId", fieldStringResFileId);
        }

        String columnType = tableBean.getSetting(columnMap, "Column Type");
        String columnName = tableBean.getName(columnMap);
        if(columnType.equals("icon") || columnType.equals("checkbox")) {
                        continue;
                }
        String columnHeader = tableBean.getLabel(columnMap);
        String isColumnRequired = tableBean.getSetting(columnMap, "Required");

        if (columnName == null && !invalidColumnNameExist )
        {
            invalidColumnNameExist = true;
            emxNavErrorObject.addMessage("Invalid Column Name. Please check the UI Table configuration..");
            emxNavErrorObject.addMessage("Sorting may not work correctly..");
        }

        if ("".equals(columnHeader))
            columnHeader = "&nbsp;";

		if(columnType.equals("File")){
			if(!FrameworkUtil.isThisSuiteRegistered(context,session,"eServiceSuiteCommonComponents")){
				continue;
			} else {
				columnHeader = "<img border=\"0\" src=\"../common/images/iconSmallPaperclipVerticalR.gif\"></img>";
			}
		}
        if(columnType.equalsIgnoreCase("Image")) {
            if(!FrameworkUtil.isThisSuiteRegistered(context,session,"eServiceSuiteCommonComponents")){
                continue;
            }else {
                columnHeader = "<img src='images/iconColHeadImage.gif' align='absmiddle' border='0' />";
            }
         }

        if (columnType.equals("separator") ) {
%>
        	<td class="separator"></td>
<%
        } else {
%>
<!-- xssencoding is not required for columnHeader //XSSOK -->
                        <th nowrap <%=((isColumnRequired != null && "true".equalsIgnoreCase(isColumnRequired))?"class='required'":"")%>><%=columnHeader%>
<%
                        if(uif.isDateField(columnMap)) {
                                String fieldallowKeyableDates = (String)tableBean.getSetting(columnMap, "Allow Manual Edit");
                                if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
                                    fieldallowKeyableDates = null;
                                }
                                if((allowKeyableDates != null && "true".equalsIgnoreCase(allowKeyableDates)) || (fieldallowKeyableDates != null && "true".equalsIgnoreCase(fieldallowKeyableDates))) {
%>
                                        <!-- //XSSOK -->
                                        <br/><span class="hint">(<%=localDateFormat%>)</span>
<%
                                }
                        }
%>
                        <!-- //XSSOK -->
                        <%=sColumnWidth%></th>
<%
        }
    }
%>
</tr>
<%
   }

    if (relBusObjPageList == null || relBusObjPageList.size() == 0 )
    {
        int totalColumns = noOfColumns + 1;
%>
<table class="list">
<tr class="even"> <td class="error" colspan="<%=totalColumns%>" align="center"><emxUtil:i18nScript localize="i18nId">emxFramework.IconMail.Common.NoObjectsFound</emxUtil:i18nScript></td> </tr>
</table>
<%
    } else if (columns == null || columns.size() == 0) {
%>

<table class="list">
<tr class="even"> <td class="error" align="center">Unable to get Table Columns</td> </tr>
</table>
<%
    } else {

    // variables used for printing every other row shaded
    int iOddEven = 1;
    String sRowClass = "odd";

    for (int i = 0; i < relBusObjPageList.size(); i++)
    {
        Map elementMap = (Map)relBusObjPageList.get(i);
        String elementOID = (String)elementMap.get("id");
        String elementRELID = (String)elementMap.get("id[connection]");
		String strRepeatHeader = (String)elementMap.get("Header Repeat");
        String rowType = (String)elementMap.get("rowType");
        String isRowEditable = (String)elementMap.get("RowEditable");

        BusinessObjectWithSelect bws = null;
	    String busType = "";
        if (bwsl != null) {
        	bws = (BusinessObjectWithSelect) bwsl.elementAt(i);
            busType = (String) bws.getSelectData("type");
          }
        

        if(isRowEditable != null && "hide".equalsIgnoreCase(isRowEditable)) {
            continue;
        }
        iOddEven++;
        Map groupByRow       = (Map)elementMap.get("GroupByRow");

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

        String sValue = "";

        if (elementRELID == null || elementRELID.trim().length() == 0)
            sValue = elementOID;
        else
            sValue = elementRELID + "|" + elementOID;

        if ((iOddEven%2) == 0)
            sRowClass = "even";
        else
            sRowClass = "odd";

        if(rowType != null && "added".equalsIgnoreCase(rowType)) {
            sRowClass = "added";
        }

        boolean repeatHeader = false;
        if ( (i != 0) && ((headerRepeatCount != 0 && (i % headerRepeatCount == 0)) || (strRepeatHeader != null && strRepeatHeader.equalsIgnoreCase("true")))) {
        	repeatHeader = true;
        }

        if(repeatHeader)
        {
%><tr class="repeat-header"><%
            if(showMassUpdate != null && "true".equalsIgnoreCase(showMassUpdate))
            {
%><td width="5%"></td><%
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
                String columnHeader = tableBean.getLabel(columnMap);
                String columnType = tableBean.getSetting(columnMap, "Column Type");
                if(columnType.equals("icon") || columnType.equals("checkbox")) {
                                        continue;
                                }
                if(columnType.equals("File")){
        			if(!FrameworkUtil.isThisSuiteRegistered(context,session,"eServiceSuiteCommonComponents")){
        				continue;
        			} else {
        				columnHeader = "<img border=0 src='images/iconSmallPaperclipVerticalR.gif'></img>";
        			}
        		}
                if(columnType.equalsIgnoreCase("Image")) {
                    if(!FrameworkUtil.isThisSuiteRegistered(context,session,"eServiceSuiteCommonComponents")){
                        continue;
                    }else {
                        columnHeader = "<img src='images/iconColHeadImage.gif' align='absmiddle' border='0' />";
                    }
                 }
                if (columnHeader == null || columnHeader.length() == 0)
                    columnHeader = "&nbsp;";

                                if (columnType.equals("separator") ) {
%>
                                        <td class="separator"></td>
<%
                } else {
%>
										<!-- xssencoding is not required for columnHeader //XSSOK -->
                                        <td<%=headerNoWrap%>><%=columnHeader%>
<%
                                        if(uif.isDateField(columnMap)) {
                                                String fieldallowKeyableDates = (String)tableBean.getSetting(columnMap, "Allow Manual Edit");
                                                if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
                                                    fieldallowKeyableDates = null;
                                                }
                                                if((allowKeyableDates != null && "true".equalsIgnoreCase(allowKeyableDates)) || (fieldallowKeyableDates != null && "true".equalsIgnoreCase(fieldallowKeyableDates))) {
%>
                                                <!-- //XSSOK -->
                                                <br/><span class="hint">(<%=localDateFormat%>)</span>
<%
                                }
                        }
%>
                                        <%=XSSUtil.encodeForHTML(context, sColumnWidth)%></td>
<%
                }
              }
%></tr><%
        }

%>
<!-- //XSSOK -->
<tr class="<%=sRowClass%>">
<%
        if(showMassUpdate != null && "true".equalsIgnoreCase(showMassUpdate)) {
%>
                <td><input id="chkbox<%=i%>" type="checkbox" name="emxTableRowId" value="<xss:encodeForHTMLAttribute><%=sValue%></xss:encodeForHTMLAttribute>" onclick="doCheckboxClick(this, 'chkbox<%=i%>',event, '<%=i%>');" /><input type="hidden" name="chkbox<%=i%>" value='false' /></td>
<%
        }

        for (int j = 0; j < noOfColumns; j++)
        {
            HashMap columnMap = (HashMap)columns.get(j);
            columnMap.put("elementOID",elementOID);
            columnMap.remove(UIComponent.ISRTEFIELD); 
            columnMap.put("elementRELID",elementRELID);
            String columnType = tableBean.getSetting(columnMap, "Column Type");
			String isEditable = tableBean.getSetting(columnMap, "Editable");
            String columnValue = "";
            boolean accessDenied = false;
            if(columnType.equals("icon") || columnType.equals("checkbox")) {
                continue;
            }
            if(columnType.equalsIgnoreCase("File") && (FrameworkUtil.isThisSuiteRegistered(context,session,"eServiceSuiteCommonComponents"))) {
                columnValue = fileResult[j].get(i).toString();
                if (columnValue == null || columnValue.length() == 0)
                {
                    columnValue = "&nbsp;";
                }
%><td nowrap ><%=columnValue%>&nbsp;</td><%
				        continue;
			      }

/* SETTING THE FIELDS VALUES FOR EDIT START */

            StringList colValueList = new StringList();
            StringList colProgramDisplayValue = new StringList();
			//Added for Bug : 347438
            StringList colDisplayValueList = null;
            String objectIcon = "";
            boolean showIcon = false;
            StringList passOIDList = new StringList();
            String showTypeIcons = tableBean.getSetting(columnMap, "Show Type Icon");
            String showAltIcons = tableBean.getSetting(columnMap, "Show Alternate Icon");
            String alternateOIDSelect = tableBean.getSetting(columnMap, "Alternate OID expression");
            String adminType = tableBean.getSetting(columnMap, "Admin Type");
            if (alternateOIDSelect != null && alternateOIDSelect.length() > 0)
            {
                passOIDList = (StringList)(bwsl.getElement(i).getSelectDataList(alternateOIDSelect));
                columnMap.put("field_alt_oid", passOIDList);
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
            // Modified exisiting code for overridden type icon
          	if (showTypeIcons != null && showTypeIcons.equals("true") )
            {
                if (typeIconProgram.length() > 0 && typeIconFunction.length() > 0 || defaultProgramFunction.length()>0)
                {
                	java.util.HashMap iconMap= (java.util.HashMap)iconResults[j].get(i);
					if(iconMap.containsKey(elementOID))
					{
				    	objectIcon = (String)iconMap.get(elementOID);
				    	objectIcon = "images/" + objectIcon;
				   		objectIcons.addElement(objectIcon);
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

            } else if (showAltIcons != null && showAltIcons.equals("true") ) {

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
			// End
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

            if (objectIcons != null && objectIcons.size() > 0) {
                columnMap.put("field_show_icon", "true");
                columnMap.put("field_icon_list", objectIcons);
            }

            String canCellEdit = "true";
            int attrind = -1;
            String attrtypeSelect = "";
            StringList attrTypelist = new StringList();
            String attrType = "";
            String fieldType = tableBean.getSetting(columnMap, SETTING_FIELD_TYPE);

            if (columnType.equals("separator") ) {
                %><td class="separator"></td><%
                continue;
            } else if ( columnType.equals("businessobject") ||
                            columnType.equals("relationship") ||
                            columnType.equals("program") )
            {
                if (columnType.equals("businessobject") )
                {
                    String columnSelect = tableBean.getBusinessObjectSelect(columnMap);
                    if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
                        if(UOMUtil.isSimpleAttributeExpression(columnSelect)) {
                            String sUOMcolumnselect = (String)columnMap.get("UOM Input Select");
                            String attrName = UOMUtil.getAttrNameFromSelect(columnSelect);
                            String inputValue = "";
                            String systemValue="";

                            colValueList = (StringList)(bwsl.getElement(i).getSelectDataList(sUOMcolumnselect));
                            inputValue = (String)colValueList.firstElement();
                            sUOMcolumnselect = (String)columnMap.get("UOM System Select");
                            if(sUOMcolumnselect != null) {
                                colValueList = (StringList)(bwsl.getElement(i).getSelectDataList(sUOMcolumnselect));
                                if(colValueList != null) {
                                    systemValue = (String)colValueList.firstElement();
                                }
                            }

                            String sDisplayValue = UOMUtil.formatDisplayValue(context, inputValue, systemValue, languageStr);
							//added for HF-054891V6R2009_
							if(inputValue.length()>0){
                            int index = inputValue.indexOf(" ");
                            columnMap.put("uom_input_value", inputValue.substring(0, index).trim());
                            columnMap.put("uom_input_unit", inputValue.substring(index).trim());
                            columnMap.put("uom_display_value", sDisplayValue);
                        }
                    }
                    }
                    
                    String sInputType = tableBean.getSetting(columnMap, "Input Type");
                    if("textarea".equals(sInputType)) {
                    	try
                        {
                    		String busSelect = tableBean.getBusinessObjectSelect(columnMap);
                            if (busSelect.equals("description")){
                            	if( UIRTEUtil.isRTEEnabled(context, busType, "description_RTE")){
                            		String rteexpression = "attribute[description_RTE].value";
                            		columnMap.put(tableBean.RTE_EXPRESSION, rteexpression);
                                	columnMap.put(tableBean.ISRTEFIELD, "true");
                            	}
                            } else {
                            	String attributeName = UOMUtil.getAttrNameFromSelect(busSelect);
                            	if( UIRTEUtil.isRTEEnabled(context, busType, attributeName)){
                            		String rteexpression = tableBean.getRTESelect(context, busSelect);
                                    columnMap.put(tableBean.ISRTEFIELD, "true");
                                    columnMap.put(tableBean.RTE_EXPRESSION, rteexpression);
                            	}
                            }
                        } catch (Exception e) {
                            // do nothing
                        }                    
                    }
                    
                    String isRTE = (String)columnMap.get(UIComponent.ISRTEFIELD);
                    if(isRTE != null && "true".equalsIgnoreCase(isRTE)){
                   		colValueList = (StringList)(bwsl.getElement(i).getSelectDataList((String)columnMap.get(UITable.RTE_EXPRESSION)));
                   		if(colValueList == null || "".equalsIgnoreCase((String)colValueList.get(0))) {
                    colValueList = (StringList)(bwsl.getElement(i).getSelectDataList(columnSelect));
                   		}
                    }else{
                    	colValueList = (StringList)(bwsl.getElement(i).getSelectDataList(columnSelect));
                    }

                    // This select is added to check if the attribute select is valid for a given object
                    if (fieldType != null && "attribute".equalsIgnoreCase(fieldType))
                    {
                        attrind = columnSelect.indexOf("attribute[");

                        if(attrind >=0)
                        {
                            attrtypeSelect = columnSelect.substring(attrind, columnSelect.indexOf("]", attrind)+1) + ".type.name";
                        }
                        attrTypelist = (StringList) (bwsl.getElement(i).getSelectDataList(attrtypeSelect));
                        if(attrTypelist != null)
                        {
                            attrType = (String) attrTypelist.get(0);
                        }
                        if(attrType == null || "".equals(attrType.trim()))
                        {
                            canCellEdit = "false";
                        }
                    }
                } else if (columnType.equals("relationship") ) {
                    String columnSelect = tableBean.getRelationshipSelect(columnMap);
                    RelationshipWithSelect rws = (RelationshipWithSelect)rwsl.elementAt(i);
                    Hashtable columnInfo = rws.getRelationshipData();

                    // This select is added to check if the attribute select is valid for a given object
                    if (fieldType != null && "attribute".equalsIgnoreCase(fieldType))
                    {
                        attrind = columnSelect.indexOf("attribute[");

                        if(attrind >=0)
                        {
                            attrtypeSelect = columnSelect.substring(attrind, columnSelect.indexOf("]", attrind)+1) + ".type.name";
                        }

                        try {
                            attrTypelist.add((String) columnInfo.get(attrtypeSelect));
                        } catch(Exception e) {
                            attrTypelist = (StringList) columnInfo.get(attrtypeSelect);
                        }

                        if(attrTypelist != null)
                        {
                            attrType = (String) attrTypelist.get(0);
                        }

                        if(attrType == null || "".equals(attrType.trim()))
                        {
                            canCellEdit = "false";
                        }
                    }

                    try {
                        String strColumnValue = "";
                        if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
                            if(UOMUtil.isSimpleAttributeExpression(columnSelect)) {
                                String sUOMcolumnselect = (String)columnMap.get("UOM Input Select");
                                String inputValue = (String)columnInfo.get(sUOMcolumnselect);
                                String systemValue = "";
                                sUOMcolumnselect = (String)columnMap.get("UOM System Select");
                                if(sUOMcolumnselect != null) {
                                    systemValue = (String)columnInfo.get(sUOMcolumnselect);
                                    if(systemValue == null) {
                                        systemValue="";
                                    }
                                }
                                String sDisplayValue = UOMUtil.formatDisplayValue(context, inputValue, systemValue, languageStr);
								//added for HF-054891V6R2009_
							if(inputValue.length()>0){
                                int index = inputValue.indexOf(" ");
                                columnMap.put("uom_input_value", inputValue.substring(0, index).trim());
                                columnMap.put("uom_input_unit", inputValue.substring(index).trim());
                                columnMap.put("uom_display_value", sDisplayValue);
                            }
                        }
                        }
                        strColumnValue = (String)columnInfo.get(columnSelect);
                        if(strColumnValue == null || "null".equalsIgnoreCase(strColumnValue)){
                            strColumnValue = "";
                        }
                        colValueList.add(strColumnValue);

                    } catch (Exception ex) {
                        colValueList = (StringList)columnInfo.get(columnSelect);
                    }

                } else if ( columnType.equals("program") ) {
                	try {
                    	if(programResult[j] != null){
                        	Map valueMap = (Map) programResult[j].get(i);
                        	if(valueMap.get("ActualValue") instanceof StringList) {
                        		colValueList	= (StringList)valueMap.get("ActualValue");
                        		colProgramDisplayValue	= (StringList)valueMap.get("DisplayValue");
                        	}
                        	else {
	                        	colValueList.add((String)valueMap.get("ActualValue"));
	                        	colProgramDisplayValue.add((String)valueMap.get("DisplayValue"));
                        	}
                    	}
                	} catch (Exception ex) {
                		colValueList = (StringList) programResult[j].get(i);
                		colProgramDisplayValue.add((String)colValueList.get(0));
                    }
                 }
                String fldType="";
				if (colValueList != null && colValueList.size() > 0)
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
		             fldType = tableBean.getSetting(columnMap, "Field Type");
			        if(fldType != null && fldType.equalsIgnoreCase("attribute") && select.startsWith("attribute"))

					{

						AttributeType attType = new AttributeType(uf.getAttrNameFromSelect(select));

						String dataType = (String) columnMap.get("Attribute Data Type"); 						
						if(UIUtil.isNullOrEmpty(dataType)) {
                        	dataType=attType.getDataType(context);
                        }
						String isRangeProgramFromTCL = tableBean.getSetting(columnMap, "isRangeProgramFromTCL");


                     	if ("true".equalsIgnoreCase(isRangeProgramFromTCL))
                        {
                        	  java.util.Map newMap;
                        	  if(rangeValuesMap.containsKey(select)) {
                        		  newMap= (Map) rangeValuesMap.get(select);
                        	  } else {
                        		  newMap = uf.getRangeValues(context, requestMap, elementOID,
                        			  elementRELID, columnMap, Request.getLanguage(request));
                        		  rangeValuesMap.put(select, newMap);
                        	  }
                        	  StringList rangeValues     = new matrix.util.StringList(new java.util.ArrayList(newMap.keySet()));
                        	  StringList rangeDispValues = new matrix.util.StringList( new ArrayList(newMap.values()));
                        	  columnMap.put("field_choices",rangeValues );
                        	  columnMap.put("field_display_choices",rangeDispValues );
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
                        	StringList noAccessList = new StringList(colValueList.size());  
                            Iterator colValueListItr = colValueList.iterator();
                            while(colValueListItr.hasNext()){
                            	String colVal = (String) colValueListItr.next();
                            	if(tableBean.NO_READ_ACCESS.equals(colVal)){
                            		colVal = i18nNoAccessMsg;
                            		accessDenied = true;
                            		canCellEdit = "false";
                            	}
                            	noAccessList.add(tableBean.NO_READ_ACCESS.equals(colVal) ? i18nNoAccessMsg : colVal);
                            }
                            colValueList = noAccessList;
                            StringList policyList = (StringList)(bwsl.getElement(i).getSelectDataList(alternatePolicySelect));
                            colDisplayValueList = UINavigatorUtil.getStateI18NStringList(policyList, colValueList, languageStr);
                        } else {
                            StringList policyList = (StringList)(bwsl.getElement(i).getSelectDataList("policy"));
                            colDisplayValueList = UINavigatorUtil.getStateI18NStringList(policyList, colValueList, languageStr);
                        }

                    } else if (adminType.startsWith("attribute_") ){
                        String attributeName = PropertyUtil.getSchemaProperty(context,adminType);
                        colDisplayValueList = UINavigatorUtil.getAttrRangeI18NStringList(attributeName, colValueList, languageStr);
                    } else {
                          colDisplayValueList = UINavigatorUtil.getAdminI18NStringList(adminType, colValueList, languageStr);
                          if(columnType.equals("program")){
                        	 colDisplayValueList =colProgramDisplayValue;
                         }
                    }
                }

                if (colValueList == null)
                    colValueList = new StringList();

            }
            else if ( columnType.equals("programHTMLOutput") )
            {


											try {
								colValueList.add((String)programResult[j].get(i));
							} catch (Exception ex) {
								colValueList = (StringList)programResult[j].get(i);
							}
							columnValue = (String) colValueList.get(0);

            }
           //drawFormEditElement method expects Field Type setting not Column Type setting.
           //Added this setting so that it works for all.
            if(tableBean.getSetting(columnMap,"Field Type").length()<=0 && columnType.length()>0)
            {
               tableBean.modifySetting(columnMap, "Field Type", columnType);

            }

            if (colDisplayValueList == null) {
                colDisplayValueList = colValueList;
            }

            columnMap.put("field_value", colValueList);
            columnMap.put("field_display_value", colDisplayValueList);

            StringList accessList = new StringList();
            String rowEditMask = tableBean.getSetting(columnMap, "Edit Access Mask");
            if(rowEditMask != null && !accessDenied)
            {
                StringTokenizer token = new StringTokenizer(rowEditMask,",");
                while (token.hasMoreTokens())
                {
                    String rowEditExpression = "current.access[" + token.nextToken().trim() + "]";
                    accessList = (StringList)(bwsl.getElement(i).getSelectDataList(rowEditExpression));
                    if(accessList != null && "false".equalsIgnoreCase((String)accessList.get(0))) {
                        canCellEdit = "false";
                        break;
                    }
                }
            }
            columnMap.put("canCellEdit", canCellEdit);

/* Start Adjust Field Type */
            // convert to lowercase to make compares quicker
            String inputType = tableBean.getSetting(columnMap, "Input Type");
            if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
                inputType = "textbox";
            }
            // If input type is not assigned, default will be Text Box
            if (inputType.length() == 0)
            {
                inputType = "textbox";
            }
            // if the input type contains a space character
            else if (inputType.indexOf(" ") != -1)
            {
                if (inputType.equals("text box"))
                {
                    inputType = "textbox";
                }
                else if (inputType.equals("text area"))
                {
                    inputType = "textarea";
                }
                else if (inputType.equals("combo box"))
                {
                    inputType = "combobox";
                }
                else if (inputType.equals("list box"))
                {
                    inputType = "listbox";
                }
                else if (inputType.equals("radio button"))
                {
                    inputType = "radiobutton";
                }
                else if (inputType.equals("popup"))
                {
                    inputType = "popup";
                }
            }

            String rangeHelperURL = uif.getRangeHelperURL(columnMap);
            if (rangeHelperURL != null && rangeHelperURL.length() > 0)
            {
                if ("textbox".equals(inputType) || "textarea".equals(inputType))
                {
                    columnMap.put("field_popup", "true");
                }
                else if ("popup".equals(inputType))
                {
                    inputType = "textbox";
                    columnMap.put("field_popup", "true");
                }
            }
            // put the field type back in the map
            tableBean.modifySetting(columnMap, "Input Type", inputType);

/* End Adjust Field Type */

/* SETTING THE FIELDS VALUES FOR EDIT END */
//Added:For Enhanced Calendar Control:AEF:nr2:20-11-09
//For Calendar Control component
    if(requestMap.get("timeStamp") == null || "".equals(requestMap.get("timeStamp"))){
    	requestMap.put("timeStamp",timeStamp);
    }
//End:For Enhanced Calendar Control:AEF:nr2:20-11-09
            if(isRowEditable != null && "readonly".equalsIgnoreCase(isRowEditable)) {

                // display the value directly for programHTMLOutput field
                if ( columnType.equals("programHTMLOutput") )  {
                    if (columnValue == null || columnValue.length() == 0)
                    {
                        columnValue = "&nbsp;";
                    }
%>
                    <td><%=columnValue%>&nbsp;</td>
<%

                }
                else {
%>
                    <%=drawFormEditElement(context, requestMap, columnMap, inputMap, timeZone, false, 2, i, true)%>
<%
                }
            } else {
                // display the value directly for programHTMLOutput field
                if (columnType.equals("programHTMLOutput") && (!uif.isFieldEditable(columnMap) || "false".equals(tableBean.getSetting(columnMap, "HTMLOutputEditable")))) {
                    if (columnValue == null || columnValue.length() == 0)
                    {
                        columnValue = "&nbsp;";
                    }
%>
                    <td><%=columnValue%>&nbsp;</td>
<%
                }
                else
                {

				if(columnType.equals("Image") )	{
					if(!FrameworkUtil.isThisSuiteRegistered(context,session,"eServiceSuiteCommonComponents"))
			{
                continue;
				}else
				{
					String passOID = elementOID ;
					StringBuffer href = new StringBuffer(150);

					href.append(tableBean.getHRef(columnMap));

		            if (href.toString().indexOf("emxTree.jsp") >= 0)
			        {
                    href = new StringBuffer(FrameworkUtil.findAndReplace(href.toString(), "emxTree.jsp", "emxNavigator.jsp"));
				    }
					else
	                {
                    href = null;
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

							 href = new StringBuffer(FrameworkUtil.encodeHref(request,href.toString()));
							 }
			if(!FrameworkUtil.isThisSuiteRegistered(context, session, "eServiceSuiteCommonComponents"))
								 {
								   continue;
								  }
							columnValue = "";
							String imageViewerURL = "";

							imageViewerURL = "../components/emxImageManager.jsp?HelpMarker=emxhelpimagesview&objectId=" + passOID;

							if(href != null && href.toString().length() > 0)
							{
								imageViewerURL = href.toString();
								imageViewerURL += "&objectId=" + passOID;
							}
							if(!(imageResult[j].get(i).toString()).equals(""))
								{
								  if(reportMode)
									 {
									  columnValue = imageResult[j].get(i).toString();
									}else
									{
										columnValue = imageResult[j].get(i).toString();
  								    }
							}
			}
%>
                  <td width="1%" align="center" ><%=columnValue%>&nbsp;</td>
<%
	}
				else {
	%>

                    <%=drawFormEditElement(context, requestMap, columnMap, inputMap, timeZone, false, 2, i, false)%>
<%
                }
                }
            }

		if ( !(isEditable.equalsIgnoreCase("false") || columnType.equalsIgnoreCase("separator")) ) {
%>
            <script type="text/javascript">
           	var field = FieldFactory.CreateField("<%=XSSUtil.encodeForHTMLAttribute(context, ((String)columnMap.get("name")))%><%=i%>","<%=XSSUtil.encodeForHTMLAttribute(context, columnType)%>",
           		"<%= tableBean.getSetting(columnMap,"Input Type")%>","<%=tableBean.getSetting(columnMap,"format")%>","<%=columnMap.get("AssociatedWithUOM")%>");

           	  field.SetFieldName("<%=XSSUtil.encodeForHTMLAttribute(context, ((String)columnMap.get("name")))%>");
           	  field.SetFieldId("<%=i%>");
<%
           	if(i == 0)
           	{
	           	HashMap settings = tableBean.getSettings(columnMap);
				Iterator keyItr  = settings.keySet().iterator();
%>
					//JavaScript HashMap Object
					var settings = new HashMap();
<%
				while(keyItr.hasNext())
				{
					String key   = (String)keyItr.next();
					String value = tableBean.getSetting(columnMap,key);
					value		 = FrameworkUtil.findAndReplace(value,"\"","\\\"");
%>
					settings.Put("<%=key%>",new Setting("<%=key%>","<%=value%>"));
<%
				}
%>
					FormHandler.PutSettings("<%=XSSUtil.encodeForHTMLAttribute(context, ((String)columnMap.get("name")))%>",settings);
<%
           	}

%>
               //FormHandler.MapField(field, "<%=i%>");
               field.SetSettings(FormHandler.GetSettings("<%=XSSUtil.encodeForHTMLAttribute(context, ((String)columnMap.get("name")))%>"));
            <%
			String onChangeHandler = tableBean.getSetting(columnMap, "On Change Handler");
			if(UIUtil.isNullOrEmpty(onChangeHandler)){
				onChangeHandler = tableBean.getSetting(columnMap, "OnChange Handler");
			}
			
			String onFocusHandler = tableBean.getSetting(columnMap, "On Focus Handler");
			if(UIUtil.isNullOrEmpty(onFocusHandler)){
				onFocusHandler = tableBean.getSetting(columnMap, "OnFocus Handler");
			}
			
			String reloadProgram = tableBean.getSetting(columnMap, "Reload Program");
			
			if( UIUtil.isNotNullAndNotEmpty(onChangeHandler) || UIUtil.isNotNullAndNotEmpty(onFocusHandler) || UIUtil.isNotNullAndNotEmpty(reloadProgram) ){	
			%>
               FormHandler.AddField(field);
			<%
			}
			%>
           </script>
<%
		 }
        }
%>
</tr>
<%
    }
}

} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        emxNavErrorObject.addMessage("emxTableEditBody:" + ex.toString().trim());

} finally {
    ContextUtil.commitTransaction(context);
}
%>

</table>
</form>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "emxRTE.inc"%>
</body>
</html>
