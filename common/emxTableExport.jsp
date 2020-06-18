<%--  emxTableExport.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTableExport.jsp.rca 1.49 Tue Oct 28 18:55:06 2008 przemek Experimental przemek $
--%><%@page import="com.matrixone.apps.domain.util.EnoviaBrowserUtility.Browsers"%><%@ page import = "matrix.db.*, matrix.util.*,com.matrixone.servlet.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.domain.util.*, com.matrixone.apps.domain.*, java.util.*, java.io.*" errorPage="emxNavigatorErrorPage.jsp"%><%@include file = "../emxTagLibInclude.inc"%><emxUtil:localize id="i18nId" bundle="emxFrameworkStringResource" locale='<xss:encodeForHTMLAttribute><%= Request.getLanguage(request) %></xss:encodeForHTMLAttribute>' /><jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/><%
if (!Framework.isLoggedIn(request))
{
    String loginPage = Framework.getPropertyValue("ematrix.login.page");
    %> <jsp:forward page ="<%=loginPage%>"/> <%
}

// Context initialization
matrix.db.Context context = Framework.getFrameContext(session);

boolean isIE = EnoviaBrowserUtility.is(request,Browsers.IE);
boolean isEdge = EnoviaBrowserUtility.is(request,Browsers.EDGE);

String fileEncodeType = request.getCharacterEncoding();
if ("".equals(fileEncodeType) || fileEncodeType == null || "null".equals(fileEncodeType)){
	fileEncodeType=UINavigatorUtil.getFileEncoding(context, request);
}

String languageStr = Request.getLanguage(request);
String fieldSeparator = "";
String recordSeparator = "";
String baseTimeStamp = Request.getParameter(request, "timeStamp");
String transactionType = Request.getParameter(request, "TransactionType");
String i18nNoAccessMsg = UINavigatorUtil.getI18nString("emxFramework.Access.NoAccess",
        "emxFrameworkStringResource", languageStr);
boolean updateTransaction = (transactionType != null && transactionType.equalsIgnoreCase("update"));
try {
    ContextUtil.startTransaction(context, updateTransaction);
    Vector userRoleList = PersonUtil.getAssignments(context);
    String component = Request.getParameter(request, "component");

    if(baseTimeStamp == null || "".equals(baseTimeStamp))
    {
        baseTimeStamp = tableBean.getTimeStamp();
    }
    if(tableBean.getTableData(baseTimeStamp) == null)
    {
        tableBean.setTableData(context, pageContext,request, baseTimeStamp, userRoleList);
    }
    // Get the preference settings
    // Type of the export "HTML, HTML, CSV, Text"
    String exportFormat = Request.getParameter(request, "exportFormat");
    if(exportFormat == null || "".equals(exportFormat))
    {
        exportFormat = PersonUtil.getExportFormat(context);
    }

    fieldSeparator = Request.getParameter(request, "fieldSeparator");

    if(fieldSeparator != null && !"".equals(fieldSeparator))
    {
        fieldSeparator = getCharacterValue(fieldSeparator);
    }

    if(fieldSeparator == null || "".equals(fieldSeparator))
    {
        fieldSeparator = PersonUtil.getFieldSeparator(context);
    }

    recordSeparator = PersonUtil.getRecordSeparator(context);
    String scarriageReturn = PersonUtil.getRemoveCarriageReturns(context);

    if (exportFormat == null || exportFormat.trim().length() == 0)
    {
        exportFormat = EnoviaResourceBundle.getProperty(context, "emxFramework.Preferences.ExportFormat.Default");
        if (exportFormat == null || exportFormat.trim().length() == 0)
        {
          exportFormat = "CSV";
        }
    }

    // If the export format is CSV or HTML set the record seperator as "\r\n" and field seperator as ","
    if (exportFormat.equals("HTML") )
    {
        recordSeparator = "\r\n";
        fieldSeparator  = ",";
    }
    if (exportFormat.equals("CSV") )
    {
        recordSeparator = "\r\n";
        fieldSeparator = getCharacterValue(fieldSeparator);
    }

    // Adjust record separator
    String sRecordSepPropValue = UINavigatorUtil.getI18nString(
                                        "emxFramework.Preferences.FieldSeparator.New_Line",
                                        "emxFrameworkStringResource",
                                        Request.getLanguage(request));
    if (recordSeparator == null
            || recordSeparator.trim().length() == 0
            || recordSeparator.equalsIgnoreCase(sRecordSepPropValue))
    {
        recordSeparator = "\r\n";
    }

    // Adjust field separator
    if (fieldSeparator != null)
    {
         fieldSeparator=getCharacterValue(fieldSeparator);
    }

    boolean isRemoveCarriageReturn=false;

    if(scarriageReturn != null && scarriageReturn.equalsIgnoreCase("Yes"))
    {
        isRemoveCarriageReturn=true;
    }

    if ( exportFormat.equals("HTML"))
    {%>
<script language="JavaScript" type="text/javascript" src="scripts/emxUITableUtil.js"></script>
<script language="JavaScript">
        // Call the TableBody for Excel Format
        exportToExcelHTML('<xss:encodeForJavaScript><%=baseTimeStamp%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=transactionType%></xss:encodeForJavaScript>');
</script><%
    } else {

        // For netscape HTML option is not supported
        if ( exportFormat.equals("HTML"))
        {
            exportFormat = "CSV";
        }

        if(component != null && component.equalsIgnoreCase("emxForm"))
        {
           //do not clear if coming from form component
        }else{
          out.clear();
        }

        String timeStamp = baseTimeStamp;
        HashMap tableData = tableBean.getTableData(timeStamp);
        HashMap tableControlMap = tableBean.getControlMap(tableData);
        HashMap requestMap = tableBean.getRequestMap(tableData);
        MapList relBusObjList = tableBean.getFilteredObjectList(tableData);


        String header =tableBean.getPageHeader(tableControlMap);
        String displayHeader = header;

        String subHeader = (String)requestMap.get("subHeader");
        String objectId = (String)requestMap.get("objectId");
        String suiteKey = (String)requestMap.get("suiteKey");
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

        //Added the Report format to requestMap and  can be used in the JPOs to show hrefs as test in Printer riendly format
        requestMap.put("exportFormat",exportFormat);
        requestMap.put("reportFormat",exportFormat);
        requestMap.put("isExportFormat","true");

        String badChars=":><[]|*/\\; ";
        char[] charArray=badChars.toCharArray();
        char repchar='_';

        header=replaceCharacters(header, charArray, repchar);
        MapList columns = tableBean.getColumns(tableData);
        int noOfColumns = columns.size();

        String filename = "";
        String fileCreateTimeStamp = Long.toString(System.currentTimeMillis());
        if ( exportFormat.equals("Text"))
        {
            //response.setContentType("text/plain");
            response.setContentType("text/plain; charset="+fileEncodeType);
            filename = header + fileCreateTimeStamp + ".txt";
        } else {
            //response.setContentType("application/vnd.ms-excel");
            // response.setContentType("application/vnd.ms-excel; charset="+fileEncodeType);
            filename = header + fileCreateTimeStamp + ".csv";
            if (isIE || isEdge)
            {
                response.setContentType("text/plain; charset=UTF-8");
                filename = FrameworkUtil.encodeURL(filename,"UTF8");
            } else {
                response.setContentType("application/csv; charset=UTF-8");
				//Fix for bug 372595 , updated by PW at 2009-05-26
				filename = "=?UTF-8?B?" + new String(FrameworkUtil.encodeBase64(filename.getBytes("UTF-8"),false), "UTF-8") + "?=";                
            }
        }

        response.setHeader ("Content-Disposition","attachment; filename=\"" + filename +"\"");
        response.setLocale(request.getLocale());

        // For CSV format in English, Assume the following delimiters
        String defaultSeperator= "";
        String defaultValueSeperator= "";

        try{
            defaultSeperator = EnoviaResourceBundle.getProperty(context, "emxFramework.Preferences.FieldSeparator.Default");
            defaultValueSeperator = EnoviaResourceBundle.getProperty(context, "emxFramework.Preferences.FieldValueSeparator.Delimiter");
        }catch(Exception exc)
        {
            defaultSeperator=",";
            defaultValueSeperator="\n";
        }

        if (defaultSeperator == null || defaultSeperator.length() == 0)
        {
            defaultSeperator=",";
        }else{
            defaultSeperator=getCharacterValue(defaultSeperator);
        }

        if (fieldSeparator == null || fieldSeparator.length() == 0)
        {
            fieldSeparator = defaultSeperator;
        }

        if (defaultValueSeperator == null || defaultValueSeperator.length() == 0)
        {
            defaultValueSeperator="\n";
        }else{
            defaultValueSeperator=getCharacterValue(defaultValueSeperator);
        }
        // response.setHeader ("Content-Disposition","attachment; filename=\"" + filename +"\"");
        if (exportFormat.equals("CSV")){
        	out.print(UIComponent.BOM_UTF8);
        }
        out.print(displayHeader + recordSeparator);
        if (subHeader != null)
        {
        	//XSS OK
                out.print(subHeader + recordSeparator);
        }

        String convert = (String)requestMap.get("convert");
        String ccCurrency = null;
        Map ucMap = null;
        String ucUnitSystem = null;
        String strEffectiveDate = null;
        char decimalSeparatorChar = PersonUtil.getDecimalSymbol(context) ;
        Boolean hasDigitSeparator = FrameworkUtil.hasDigitSeparator(context);

        if ("true".equalsIgnoreCase(convert))
        {
            ccCurrency = CurrencyConversion.getCurrency(session);
            ucMap = UnitConversion.getUnitConversionMap(context);
            ucUnitSystem = UnitConversion.getUnitSystem(session);
        }

        if (tableBean.hasGroupHeaderColumn(tableControlMap)) {
                // Print the Group header for report
                for (int i = 0; i < noOfColumns; i++)
                {
                    HashMap columnMap = (HashMap)columns.get(i);
                    String columnType = tableBean.getSetting(columnMap, "Column Type");
                    String columnHeader = tableBean.getLabel(columnMap);
                    String columnName = tableBean.getName(columnMap);
                    String columnGroupHeader = tableBean.getSetting(columnMap, "Group Header");

                    if (columnGroupHeader == null || columnGroupHeader.length() == 0)
                    {
                        if (tableBean.isColumnExport(columnMap) ) {
                                out.print("" + fieldSeparator);
                        }
                    }  else {
                        HashMap groupHeaderMap = (HashMap)tableControlMap.get("GroupHeaderMap");
                        HashMap groupMapItem = (HashMap)groupHeaderMap.get(columnName);
                        int colSpan = ((Integer)groupMapItem.get("colSpan")).intValue();
                        String translatedGroupHeader = (String)groupMapItem.get("translatedHeader");
                        for(int k = i ; k < colSpan + i; k++) {
                                HashMap innercolumnMap = (HashMap)columns.get(k);
                                if (tableBean.isColumnExport(innercolumnMap) ) {
                                        out.print(translatedGroupHeader + fieldSeparator);
                                }
                        }

                        i = i + colSpan - 1;
                    }
                }
        }

        out.print(recordSeparator);

        // Print the header for report
        for (int i = 0; i < noOfColumns; i++)
        {
            HashMap columnMap = (HashMap)columns.get(i);
            String columnType = tableBean.getSetting(columnMap, "Column Type");
            String columnHeader = tableBean.getLabel(columnMap);

            if (tableBean.isColumnExport(columnMap) )
            {
                out.print(columnHeader+fieldSeparator);
            }
        }

        //out.print(recordSeparator + recordSeparator);
        // Fix for the IR IR-056481V6R2011x
        out.print(recordSeparator);

        // business object list for current page
        MapList relBusObjPageList = new MapList();
        RelationshipWithSelectList rwsl = null;
        BusinessObjectWithSelectList bwsl = null;
        String selectType = "";
        String selectString = "";
        boolean columnSpan = false;
        // if selectType is program - get column result by invoking the specified JPO
        Vector programResult[] = new Vector[noOfColumns];
        // if selectType is checkbox - get column result by invoking the specified JPO
        Vector checkboxAccess[] = new Vector[noOfColumns];
        // format to be used for the date columns
        // Modified for IR-189755V6R2014
        String DateFrm = (new Integer(java.text.DateFormat.SHORT)).toString();
        // Date Format initialization
        //String DateFrm = PersonUtil.getPreferenceDateFormatString(context);
        String prefTimeDisp = PersonUtil.getPreferenceDisplayTime(context);
        HashMap GroupByColumnMap = (HashMap)tableControlMap.get("GroupByColumnMap");
        boolean exportGroupBy = GroupByColumnMap != null && tableBean.isColumnExport(GroupByColumnMap);

        if (relBusObjList != null && relBusObjList.size() > 0)
        {
            relBusObjPageList = relBusObjList;
            String hasGroupBy = (String)tableControlMap.get("HasGroupBy");
            if("true".equals(hasGroupBy) && exportGroupBy){
                tableBean.processGroupByHeader(context,application,session,pageContext,request,timeStamp,relBusObjPageList);
                relBusObjPageList = tableBean.getGrouped(context, timeStamp,relBusObjPageList);   
            }
            HashMap columnValuesMap = tableBean.getColumnValuesMap(context, application,  relBusObjPageList, tableData);
            bwsl = (BusinessObjectWithSelectList)columnValuesMap.get("Businessobject");
            rwsl = (RelationshipWithSelectList)columnValuesMap.get("Relationship");
            programResult = (Vector[])columnValuesMap.get("Program");
            checkboxAccess = (Vector[])columnValuesMap.get("Checkbox");
        }
        if (relBusObjPageList != null || relBusObjPageList.size() > 0 )
        {
        	int resultIndex = 0;
            for (int i = 0; i < relBusObjPageList.size(); i++)
            {
                HashMap columnMap = new HashMap();               
                //Modified for bug 352392 - Changed HashMap to Map
				Map elementMap = (Map)relBusObjPageList.get(i);
		        boolean hasReadAccess = true;
                if(UIUtil.isNotNullAndNotEmpty((String)elementMap.get("objReadAccess"))){
                	hasReadAccess = Boolean.valueOf((String)elementMap.get("objReadAccess"));
                }
                Map groupByRow       = (Map)elementMap.get("GroupByRow");
                
                if(groupByRow != null) 
                {                           
                    String groupByValue    = (String)groupByRow.get("GroupByValue");
                    elementMap.remove("GroupByRow");         
                    if(groupByValue == null || groupByValue.length() == 0)
                        groupByValue = "";           		
                    
                    out.print(groupByValue);
                    out.print(recordSeparator);   
                }                                           
                
                for (int j = 0; j < noOfColumns; j++)
                {
                    columnMap = (HashMap)columns.get(j);
                    String columnType = tableBean.getSetting(columnMap, "Column Type");
                    String colFormat = tableBean.getSetting(columnMap, "format");
                    String adminType = tableBean.getSetting(columnMap, "Admin Type");
                    boolean isTNRExpression = false;
                    if ( tableBean.isColumnExport(columnMap) )
                    {
                        String columnValue = "";
                        StringList colValueList = new StringList();
                        String columnSelect = null;
                        if(columnType.equals("businessobject") ){
                        	columnSelect = tableBean.getBusinessObjectSelect(columnMap);
                        	isTNRExpression = UIExpression.isTNRExpression(context, columnSelect);
                        }
						if(!hasReadAccess && !isTNRExpression){
							colValueList.add(i18nNoAccessMsg);
						}else{
                        if (columnType.equals("businessobject") )
                        {
                            if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
                                if(UOMUtil.isSimpleAttributeExpression(columnSelect)) {
                                    String sUOMcolumnselect = (String)columnMap.get("UOM Input Select");
                                    String attrName = UOMUtil.getAttrNameFromSelect(columnSelect);
                                    String inputValue = "";
                                    String systemValue="";

                                    colValueList = (StringList)(bwsl.getElement(i).getSelectDataList(sUOMcolumnselect));
                                    if(colValueList != null) {
                                        inputValue = (String)colValueList.firstElement();
                                        inputValue = UOMUtil.convertToI18nUnitName(inputValue, languageStr);
                                    }
                                    sUOMcolumnselect = (String)columnMap.get("UOM System Select");
                                    if(sUOMcolumnselect != null) {
                                        colValueList = (StringList)(bwsl.getElement(i).getSelectDataList(sUOMcolumnselect));
                                        if(colValueList != null) {
                                            systemValue = (String)colValueList.firstElement();
                                            systemValue = UOMUtil.convertToI18nUnitName(systemValue, languageStr);
                                        }
                                    }
                                    colValueList = new StringList();
                                    if("".equals(systemValue)) {
                                        colValueList.addElement(inputValue);
                                    }else {
                                        colValueList.addElement(inputValue + " (" + systemValue + ")");
                                    }
                                }else {
                            colValueList = (StringList)(bwsl.getElement(i).getSelectDataList(columnSelect));

                                }
                            }else {
                                colValueList = (StringList)(bwsl.getElement(i).getSelectDataList(columnSelect));
                            }
                        } else if (columnType.equals("relationship") ) {
	                            columnSelect = tableBean.getRelationshipSelect(columnMap);
                            RelationshipWithSelect rws = (RelationshipWithSelect)rwsl.elementAt(i);
                            Hashtable columnInfo = rws.getRelationshipData();

                            try {
                                String strColumnValue = "";
                                if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
                                    if(UOMUtil.isSimpleAttributeExpression(columnSelect)) {
                                        String sUOMcolumnselect = (String)columnMap.get("UOM Input Select");
                                        String attrName = UOMUtil.getAttrNameFromSelect(columnSelect);
                                        String inputValue = "";
                                        String systemValue="";
                                        inputValue = (String)columnInfo.get(sUOMcolumnselect);
                                        inputValue = UOMUtil.convertToI18nUnitName(inputValue, languageStr);
                                        sUOMcolumnselect = (String)columnMap.get("UOM System Select");
                                        if(sUOMcolumnselect != null) {
                                            systemValue = (String)columnInfo.get(sUOMcolumnselect);
                                            if(systemValue!= null) {
                                                systemValue = UOMUtil.convertToI18nUnitName(systemValue, languageStr);
                                            }else {
                                                systemValue="";
                                            }
                                        }
                                        if("".equals(systemValue)) {
                                            strColumnValue = inputValue;
                                        }else {
                                            strColumnValue = inputValue + " (" + systemValue + ")";
                                        }
                                    }else {
                                        strColumnValue = (String)columnInfo.get(columnSelect);
                                        //strColumnValue = UOMUtil.convertToI18nUnitName(strColumnValue, languageStr);
                                    }
                                }else {
                                    strColumnValue = (String)columnInfo.get(columnSelect);
                                }
                                //Bug Start 354730
                                if(strColumnValue == null){
                                    strColumnValue="";
                                }
								//Bug End 354730
                                colValueList.add(strColumnValue);
                            } catch (Exception ex) {
                                colValueList = (StringList)columnInfo.get(columnSelect);
                            }
                        } else if ( columnType.equals("program")) {
                        	try {
    	                    	if(programResult[j] != null){
    	                        	Map valueMap = (Map) programResult[j].get(resultIndex);
    	                        	Object colDispValue = valueMap.get("DisplayValue");
    	                            if(colDispValue instanceof StringList){
    	                            	colValueList = (StringList)colDispValue;
    	                            }else{
    	                            	colValueList.add((String)colDispValue);
    	                            }
    	                        	//colValueList.add(valueMap.get("DisplayValue"));
    	                    	}
    	                	} catch (Exception ex) {
	    	                		colValueList = (StringList) programResult[j].get(resultIndex);
    	                    }
                        } else if ( columnType.equals("programHTMLOutput") ) {
                            try {
	                                colValueList.add((String)programResult[j].get(resultIndex));
                            } catch (Exception ex) {
	                                colValueList = (StringList)programResult[j].get(resultIndex);
	                            }
                            }
                        }
                        if (colValueList == null)
                            colValueList = new StringList();

                        if (colValueList != null && adminType != null)
                        {
                        	if(!hasReadAccess){
                            	if(columnType.equals("businessobject") && UIExpression.isTypeExpression(context, columnSelect)){
                            		colValueList = UINavigatorUtil.getAdminI18NStringList(adminType, colValueList, languageStr); 
                            	}
                            }else{
                            if (adminType.equals("State") )
                            {
                                String alternatePolicySelect = tableBean.getSetting(columnMap, "Alternate Policy expression");

                                if (alternatePolicySelect != null && alternatePolicySelect.length() > 0) {
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
                                String attributeName = PropertyUtil.getSchemaProperty(context, adminType);
                                colValueList = UINavigatorUtil.getAttrRangeI18NStringList(attributeName, colValueList, languageStr);
                            } else {
                                colValueList = UINavigatorUtil.getAdminI18NStringList(adminType, colValueList, languageStr);
                            }
                        }
                        }
                        if ( colValueList != null && colValueList.size() > 0 )
                            columnValue = (String)(colValueList.firstElement());
						if(!hasReadAccess && !isTNRExpression){
							 out.print(i18nNoAccessMsg);
	                         out.print(fieldSeparator);
						}else{
                        if (colFormat.equalsIgnoreCase("user"))
                        {
                            String strUserFormatedName = "";

                            if (columnValue != null && !"".equalsIgnoreCase(columnValue))
                            {
                                strUserFormatedName = PersonUtil.getFullName(context,columnValue);
                            }

                            String formatedValues = "";
                            if (exportFormat.equals("CSV")){
                                formatedValues = getCSVFormatString(context, new StringList(strUserFormatedName), colFormat, "", languageStr);
                            }else{
                                formatedValues = getTextFormatString(context, new StringList(strUserFormatedName), defaultValueSeperator, isRemoveCarriageReturn, "", languageStr);
                            }
                            out.print(formatedValues);
                            //XSS OK
                            out.print(fieldSeparator);
                        } else if (colFormat.equals("email"))
                        {
                            out.print(columnValue);
                            out.print(fieldSeparator);
                        } else if (colFormat.equalsIgnoreCase("alphanumeric") || colFormat.equalsIgnoreCase("numeric") || (colFormat.equalsIgnoreCase("UOM") && tableBean.isAssociatedWithDimension(columnMap)))
                        {
                            String formatedValues = "";
                            String sDynamicUrl = "";
                            if(tableBean.isDynamicURLEnabled(context, columnMap)) {
                                sDynamicUrl = "enabled";
                            }
                            if (exportFormat.equals("CSV")){
                                formatedValues = getCSVFormatString(context, colValueList, colFormat, sDynamicUrl, languageStr);
                            }else{
                                formatedValues = getTextFormatString(context, colValueList, defaultValueSeperator, isRemoveCarriageReturn, sDynamicUrl, languageStr);
                            }
                            out.print(formatedValues);
                            out.print(fieldSeparator);

                        } else if (colFormat.equalsIgnoreCase("date"))
                        {
                            if (exportFormat.equals("CSV"))
                                out.print("\"");
                            String locDispValue = "";
                            if(UIUtil.isNotNullAndNotEmpty(columnValue)) {
                            HashMap lzMap = (HashMap) tableBean.getLzDate(context, columnValue, columnMap, requestMap, (String)session.getAttribute("timeZone"));
                            	locDispValue = (String)lzMap.get("value");
                            }
                            %><%=locDispValue%><%

                            if (exportFormat.equals("CSV"))
                                out.print("\"");

                            out.print(fieldSeparator);
                        } else if (colFormat.equalsIgnoreCase("currency"))
                        {
                            String fromCurrency = "";
                            String effectiveDate = "";

                            String currencyExpression = tableBean.getSetting(columnMap, "Currency Expression");
                            String effectiveDateExpression = tableBean.getSetting(columnMap, "Effective Date Expression");

                            if (currencyExpression != null)
                                fromCurrency = bwsl.getElement(i).getSelectData(currencyExpression);

                            if (effectiveDateExpression != null)
                                effectiveDate = bwsl.getElement(i).getSelectData(effectiveDateExpression);

                            if (    columnValue.length() > 0 &&
                                    ccCurrency != null &&
                                    ccCurrency.length() > 0 &&
                                    "true".equalsIgnoreCase(convert)
                                )
                            {
                                if (exportFormat.equals("CSV"))
                                    out.print("\"");
                                %><framework:convertCurrency from="<%=XSSUtil.encodeForHTMLAttribute(context, fromCurrency) %>" to="<%=XSSUtil.encodeForHTMLAttribute(context, ccCurrency) %>" value="<%= columnValue %>" date="<%= effectiveDate %>" decimalSeparator="<%= decimalSeparatorChar%>" digitSeparatorPreference="<%= hasDigitSeparator%>"/><%
                                if (exportFormat.equals("CSV"))
                                    out.print("\"");
                                out.print(fieldSeparator);
                            } else {
                            	//XSS OK
                                out.print(columnValue+fieldSeparator);
                            }
                        } else if (colFormat.equalsIgnoreCase("UOM") && (!tableBean.isAssociatedWithDimension(columnMap) || tableBean.isAlphanumericField(columnMap)))
                        {
                            String strUoM = "";
                            String UOMExpression = tableBean.getSetting(columnMap, "UOM Expression");
                            if (UOMExpression != null)
                                strUoM = bwsl.getElement(i).getSelectData(UOMExpression);

                            if (    columnValue.length() > 0 &&
                                    ucUnitSystem != null &&
                                    ucUnitSystem.length() > 0 &&
                                    "true".equalsIgnoreCase(convert)
                                )
                            {
                                if (exportFormat.equals("CSV"))
                                    out.print("\"");
                                %><framework:convertUnit map="<%= ucMap %>"  from="<%=strUoM %>" to="<%= ucUnitSystem %>" value="<%= columnValue %>" decimalSeparator="<%= decimalSeparatorChar%>" digitSeparatorPreference="<%= hasDigitSeparator.booleanValue()%>"/><%
                                if (exportFormat.equals("CSV"))
                                    out.print("\"");
                                out.print(fieldSeparator);
                            } else {
                                out.print(columnValue+fieldSeparator);
                            }
                        }
                    }
                    }
                }
                if(hasReadAccess){
                	resultIndex++;
                }

                out.print(recordSeparator);
            }
            // Add Export for calculations
            boolean bHasSum = tableBean.hasSumColumn(tableControlMap);
            boolean bHasCalculations = tableBean.hasCalculationsColumn(tableControlMap);
            boolean bHasAverage = tableBean.hasAverageColumn(tableControlMap);            
            boolean bHasMaximum = tableBean.hasMaximumColumn(tableControlMap);
            boolean bHasMinimum = tableBean.hasMinimumColumn(tableControlMap);
            boolean bHasMedian = tableBean.hasMedianColumn(tableControlMap);
            boolean bHasStandardDeviation = tableBean.hasStandardDeviationColumn(tableControlMap);
            boolean bArray[] = {bHasSum,bHasAverage,bHasMaximum,bHasMinimum,bHasMedian,bHasStandardDeviation};
            
            String strSumLable = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.Sum", "emxFrameworkStringResource", languageStr);
            String strAverageLable = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.Average", "emxFrameworkStringResource", languageStr);
            String strMaximumLable = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.Maximum", "emxFrameworkStringResource", languageStr);
            String strMinimumLable = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.Minimum", "emxFrameworkStringResource", languageStr);
            String strMedianLable = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.Median", "emxFrameworkStringResource", languageStr);
            String strStandardDeviationLable = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.StandardDeviation", "emxFrameworkStringResource", languageStr);
            
            if(bHasCalculations){
            	Map mAllValuesMap = (Map) tableControlMap.get("All Values Map");
            	for(int k=0;k<bArray.length;k++){
                	if(!bArray[k])
                		continue;
                	for (int j = 0; j < noOfColumns; j++){
                		HashMap columnMap = (HashMap)columns.get(j);                		
                        String columnUnit = (String)columnMap.get("DB Unit");                        
                        String columnName = (String)columnMap.get("name");
                        if ( tableBean.isColumnExport(columnMap) ){
                        	if("Name".equalsIgnoreCase(columnName) || "Title".equalsIgnoreCase(columnName)){
                        		switch(k){
                        		case 0:
                        			out.print(strSumLable+fieldSeparator);
                        			break;
                        		case 1:
                        			out.print(strAverageLable+fieldSeparator);
                        			break;
                        		case 2:
                        			out.print(strMaximumLable+fieldSeparator);
                        			break;
                        		case 3:
                        			out.print(strMinimumLable+fieldSeparator);
                        			break;
                        		case 4:
                        			out.print(strMedianLable+fieldSeparator);
                        			break;
                        		case 5:
                        			out.print(strStandardDeviationLable+fieldSeparator);
                        			break;
                        		}
                        		continue;
                        	}
                        	String columnValue = "";
                        	boolean bHasCalulationsOnColumn = ((String)tableBean.getSetting(columnMap,"HasCalculations")).equalsIgnoreCase("TRUE");
                        	if(bHasCalulationsOnColumn){
                        		Locale localeObj = context.getLocale();
                        		StringList columnValueList = (StringList)mAllValuesMap.get(columnName);
                        		switch(k){
                        		case 0:                        			
                        			columnValue = FrameworkUtil.getSum(context,localeObj,columnValueList);                        			
                        			break;
                        		case 1:
                        			columnValue = FrameworkUtil.getAverage(context,localeObj,columnValueList);
                        			break;
                        		case 2:
                        			columnValue = FrameworkUtil.getMaximum(context,localeObj,columnValueList);
                        			break;
                        		case 3:
                        			columnValue = FrameworkUtil.getMinimum(context,localeObj,columnValueList);
                        			break;
                        		case 4:
                        			columnValue = FrameworkUtil.getMedian(context,localeObj,columnValueList);
                        			break;
                        		case 5:
                        			columnValue = FrameworkUtil.getStandardDeviation(context,localeObj,columnValueList);
                        			break;
                        		}
                        		if(!columnValue.isEmpty() && columnUnit!=null)
                        			columnValue += columnUnit; 
                        		if(!columnValue.isEmpty() && exportFormat.equals("CSV"))                        			
                        			columnValue = "\"=\"\""+columnValue+"\"\"\"";                        		
                        		out.print(columnValue+fieldSeparator);
                        	}
                        	else{
                            	out.print(fieldSeparator);
                            }                        	
                        }
                	}
                	out.print(recordSeparator);
                }
            }
            // End Export for calculations
        }
    }

} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
} finally {
    ContextUtil.commitTransaction(context);
    HashMap tableData = tableBean.getTableData(baseTimeStamp);
    HashMap requestMap = tableBean.getRequestMap(tableData);
    requestMap.remove("exportFormat");
    requestMap.remove("reportFormat");
}%><%!
public String getCSVFormatString(Context context, StringList colValueList, String format, String sDynamicURL, String languageStr) throws Exception
{

    StringBuffer formatedColValues = new StringBuffer();
    String columnValue="";
    // Test if the the value is a number and has one value in the list
    if (colValueList.size() == 1)
    {
        columnValue= (String)colValueList.get(0);
        if(sDynamicURL.equals("enabled")) {
            columnValue = UINavigatorUtil.formatEmbeddedURL(context, columnValue, false, languageStr);
            columnValue = FrameworkUtil.findAndReplace(columnValue, "&amp;", "&");
            columnValue = FrameworkUtil.findAndReplace(columnValue, "&quot;", "\"");
        }

        if(columnValue.length() > 0){
	      	if(columnValue.indexOf("0") == 0 || columnValue.indexOf("+")>= 0 || columnValue.indexOf("-") >= 0){
	            formatedColValues = new StringBuffer("=\"");
	        }
	      	if(columnValue.indexOf('"') >= 0 || columnValue.indexOf(',') != -1 || columnValue.indexOf('\n') != -1){
	            formatedColValues = new StringBuffer("\"");
	            columnValue = FrameworkUtil.findAndReplace(columnValue ,"\"", "\"\"");
	        }
	        columnValue = columnValue.replace('\r', ' ');
	        formatedColValues.append(columnValue);
		}
    }
    else
    {
    	if(colValueList.size()==0){
    		return "";
    	}
        for (int i = 0; i < colValueList.size(); i++)
        {
            columnValue = (String)colValueList.get(i);
            if(sDynamicURL.equals("enabled")) {
                columnValue = UINavigatorUtil.formatEmbeddedURL(context, columnValue, false, languageStr);
                columnValue = FrameworkUtil.findAndReplace(columnValue, "&amp;", "&");
                columnValue = FrameworkUtil.findAndReplace(columnValue, "&quot;", "\"");
            }
            if (columnValue.indexOf('"') >= 0)
            {
                columnValue=FrameworkUtil.findAndReplace(columnValue ,"\"", "\"\"");
                columnValue = columnValue.replace('\r', ' ');
            }

            if(i == colValueList.size()-1 )
            {
                formatedColValues.append(columnValue);
            }
            else
            {
                formatedColValues.append(columnValue + "\n");
            }
         }
         
        String prefixStr = "\"";
        
        StringBuffer txtStringBuf = new StringBuffer(prefixStr);
        formatedColValues = txtStringBuf.append(formatedColValues);         
		formatedColValues.append("\"");
     }
        if (columnValue.indexOf('"') >= 0 || columnValue.indexOf(',') != -1 || columnValue.indexOf('\n') != -1) 
        {
            formatedColValues.append("\"");
        }
        else
        {
        	if(columnValue.indexOf("0") == 0 || columnValue.indexOf("+")>= 0 || columnValue.indexOf("-") >= 0)
			{
					formatedColValues.append("\"");
        	}	
        }

        return (formatedColValues.toString());
}

%><%!
public String getTextFormatString(Context context, StringList colValueList, String fieldSeparator, boolean isRemoveCarriageReturn, String sDynamicURL, String languageStr) throws Exception
{

    StringBuffer formatedColValues = new StringBuffer("");
    // Test if the the value is a number and has one value in the list
    if (colValueList.size() == 1)
    {
        String columnValue = (String)colValueList.get(0);
        if(sDynamicURL.equals("enabled")) {
            columnValue = UINavigatorUtil.formatEmbeddedURL(context, columnValue, false, languageStr);
            columnValue = FrameworkUtil.findAndReplace(columnValue, "&amp;", "&");
            columnValue = FrameworkUtil.findAndReplace(columnValue, "&quot;", "\"");
        }
        if(isRemoveCarriageReturn) {
            columnValue = columnValue.replace('\n', ' ');
            columnValue = columnValue.replace('\r', ' ');
        }
        formatedColValues.append(columnValue);
    } else {
        for (int i = 0; i < colValueList.size(); i++)
        {
            String columnValue = (String)colValueList.get(i);
            if(sDynamicURL.equals("enabled")) {
                columnValue = UINavigatorUtil.formatEmbeddedURL(context, columnValue, false, languageStr);
                columnValue = FrameworkUtil.findAndReplace(columnValue, "&amp;", "&");
                columnValue = FrameworkUtil.findAndReplace(columnValue, "&quot;", "\"");
            }
            if(isRemoveCarriageReturn) {
                columnValue = columnValue.replace('\n', ' ');
                columnValue = columnValue.replace('\r', ' ');
            }
            if(i == colValueList.size()-1 )
                formatedColValues.append(columnValue);
            else
                formatedColValues.append(columnValue + fieldSeparator);
        }
    }
    return (formatedColValues.toString());
}%><%!
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
%><%!
static public String getCharacterValue(String strValue)
{
if(strValue==null || strValue.length() == 0){
    return "";
}else{
    if ( strValue.equalsIgnoreCase("Pipe") ){
        strValue = "|";
    }else if ( strValue.equalsIgnoreCase("Comma") ){
        strValue = ",";
    }else if ( strValue.equalsIgnoreCase("Tab") ){
        strValue = "\t";
    }else if ( strValue.equalsIgnoreCase("Semicolon") ){
        strValue = ";";
    }
}

return strValue;
}%>

