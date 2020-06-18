<%--  emxTableAutoFilterDisplay.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTableAutoFilterDisplay.jsp.rca 1.16 Wed Oct 22 15:48:36 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<html>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<head>

<title>
</title>
<%@include file = "emxUIConstantsInclude.inc"%>
<script language="javascript" src="scripts/emxUIModal.js"></script>
<script language="JavaScript" src="scripts/emxUITableUtil.js"></script>
<script type="text/javascript">
	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIList");
</script>
</head>

<%
String timeStamp = Request.getParameter(request, "timeStamp");
int maxFilterCount = 0;

// format to be used for the date columns
String DateFrm = (new Integer(java.text.DateFormat.MEDIUM)).toString();
String languageStr = Request.getLanguage(request);
String i18nNoAccessMsg = UINavigatorUtil.getI18nString("emxFramework.Access.NoAccess",
        "emxFrameworkStringResource", Request.getLanguage(request));

try {

    ContextUtil.startTransaction(context, false);

    // Get business object list from session level Table bean
    HashMap tableData = tableBean.getTableData(timeStamp);
    MapList relBusObjList = tableBean.getObjectList(tableData);
    HashMap tableControlMap = tableBean.getControlMap(tableData);
    HashMap paramMap = tableBean.getRequestMap(tableData);
    paramMap.put("languageStr", Request.getLanguage(request) );

    MapList autoFilterColumns = tableBean.getAutoFilterColumns(tableData);

    HashMap columnValuesMap = tableBean.getColumnValuesMap(context, application,autoFilterColumns, relBusObjList, tableData);

    Vector programResult[] = new Vector[autoFilterColumns.size()];
    BusinessObjectWithSelectList bwsl = (BusinessObjectWithSelectList)columnValuesMap.get("Businessobject");
    RelationshipWithSelectList rwsl = (RelationshipWithSelectList)columnValuesMap.get("Relationship");
    programResult = (Vector[])columnValuesMap.get("Program");

    MapList filterMapList = new MapList();

    for (int j = 0; j < autoFilterColumns.size(); j++)
    {
        // TreeSet filterTreeSet = new TreeSet();
        TreeMap filterTreeMap = new TreeMap();
        HashMap filterColumnMap = new HashMap();

        HashMap columnMap = (HashMap)autoFilterColumns.get(j);

        String columnHeader = tableBean.getLabel(columnMap);
        String columnName = tableBean.getName(columnMap);

        String objectIcon = "";
        boolean showIcon = false;

        String showTypeIcons = tableBean.getSetting(columnMap, "Show Type Icon");
        String showAltIcons = tableBean.getSetting(columnMap, "Show Alternate Icon");
        if(tableBean.isAssociatedWithDimension(columnMap) && !tableBean.isAlphanumericField(columnMap)) {
            showAltIcons = null;
        }
        String columnType = tableBean.getSetting(columnMap, "Column Type");
        String colFormat = tableBean.getSetting(columnMap, "format");
        String adminType = tableBean.getSetting(columnMap, "Admin Type");

        Boolean multiValueColumn = Boolean.valueOf(false);
        Boolean adminTypeColumn = Boolean.valueOf(false);
        HashMap columnValueIconMap = new HashMap();
        int resultIndex = 0;

        for (int i = 0; i < relBusObjList.size(); i++)
        {
            String typeName = "";
            StringList objectIcons = new StringList();
            StringList typeNames = new StringList();
            Map elementMap = (Map)relBusObjList.get(i);
	        boolean hasReadAccess = true;
            if(UIUtil.isNotNullAndNotEmpty((String)elementMap.get("objReadAccess"))){
            	hasReadAccess = Boolean.valueOf((String)elementMap.get("objReadAccess"));
            }
            if (showTypeIcons != null && showTypeIcons.equals("true") && bwsl!=null)
            {
                typeName = bwsl.getElement(i).getSelectData("type");
                typeNames.addElement(typeName);
                showIcon = true;
            } else if (showAltIcons != null && showAltIcons.equals("true") ) {
                String alternateTypeSelect = tableBean.getSetting(columnMap, "Alternate Type expression");
                if (alternateTypeSelect != null)
                {
                    typeNames = bwsl.getElement(i).getSelectDataList(alternateTypeSelect);
                    showIcon = true;
                }
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

            if (    columnType.equals("businessobject") ||
                    columnType.equals("relationship") ||
                    columnType.equals("program") ||
                    columnType.equals("programHTMLOutput") )
            {

                StringList colValueList = new StringList();
                String displayColumnValue = "";
                String actualColumnValue = "";
                StringList UOMDisplayValueList = new StringList();
                String inputDisplayValue = "";
                String systemDusplayValue = "";

                boolean bUOMFiled = false;
                String columnSelect = null;
                boolean isTNRExpression = false; 
                if (columnType.equals("businessobject") )
                {
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
                                bUOMFiled = true;
                                inputDisplayValue = UOMUtil.convertToI18nUnitName(inputValue, languageStr);
                            }
                            sUOMcolumnselect = (String)columnMap.get("UOM System Select");
                            if(sUOMcolumnselect != null) {
                                colValueList = (StringList)(bwsl.getElement(i).getSelectDataList(sUOMcolumnselect));
                                if(colValueList != null) {
                                    systemValue = (String)colValueList.firstElement();
                                    bUOMFiled = true;
                                    systemDusplayValue = UOMUtil.convertToI18nUnitName(systemValue, languageStr);
                                }
                            }
                            colValueList = new StringList();
                            if("".equals(systemValue)) {
                                systemDusplayValue = inputDisplayValue;
                                colValueList.addElement(inputValue);
                            }else {
                                systemDusplayValue = inputDisplayValue + " (" + systemDusplayValue + ")";
                                colValueList.addElement(inputValue + " (" + systemValue + ")");
                            }
                            UOMDisplayValueList.add(systemDusplayValue);
                        }else {
                    colValueList = (StringList)(bwsl.getElement(i).getSelectDataList(columnSelect));
                            bUOMFiled = true;
                            UOMDisplayValueList = colValueList;
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
                                inputDisplayValue = UOMUtil.convertToI18nUnitName(inputValue, languageStr);
                                sUOMcolumnselect = (String)columnMap.get("UOM System Select");
                                if(sUOMcolumnselect != null) {
                                    systemValue = (String)columnInfo.get(sUOMcolumnselect);
                                    if(systemValue!= null) {
                                        systemDusplayValue = UOMUtil.convertToI18nUnitName(systemValue, languageStr);
                                    }else {
                                        systemValue="";
                                    }
                                }
                                if("".equals(systemValue)) {
                                    systemDusplayValue = inputDisplayValue;
                                    strColumnValue = inputValue;
                                }else {
                                    systemDusplayValue = inputDisplayValue + " (" + systemDusplayValue + ")";
                                    strColumnValue = inputValue + " (" + systemValue + ")";
                                }
                                bUOMFiled = true;
                                UOMDisplayValueList.add(systemDusplayValue);
                            }else {
                                strColumnValue = (String)columnInfo.get(columnSelect);
                                UOMDisplayValueList.add(strColumnValue);
                                bUOMFiled = true;
                            }
                            colValueList.add(strColumnValue);
                        }else {
                        colValueList.add((String)columnInfo.get(columnSelect));
                        }
                    } catch (Exception ex) {
                        colValueList = (StringList)columnInfo.get(columnSelect);
                    }

                } else if ( columnType.equals("programHTMLOutput") ) {
                    try {
	                        colValueList.add((String)programResult[j].get(resultIndex));
                    } catch (Exception ex) {
	                        colValueList = (StringList)programResult[j].get(resultIndex);
                    }
	                    resultIndex++;
                }
              // Auto Filter page is blank: the format in which values are returned by "program" are different than those returned by "prgramHTMLOutput". Hence separating the processing for both these column types
                else if (columnType.equals("program")){
                	try{
                		if(programResult[j] != null){
		                		HashMap tempMap = (HashMap)programResult[j].get(resultIndex);
	                    	colValueList.add((String)tempMap.get("DisplayValue"));
                		}
                	}  catch (Exception ex) {                		
	                		colValueList = (StringList)((HashMap)programResult[j].get(resultIndex)).get("DisplayValue");                    	
	                    } 
	                	resultIndex++;
                    } 
                }

                // If the columns value has more than one value, do not process this column.
                if (colValueList != null && colValueList.size() > 1)
                {
                    multiValueColumn = Boolean.valueOf(true);
                    filterTreeMap.clear();
                    break;
                }
                boolean accessDenied = false;
                if (colValueList != null)
                    actualColumnValue = (String)(colValueList.firstElement());

                if (colValueList != null && adminType != null)
                {
                	if(tableBean.NO_READ_ACCESS.equals(actualColumnValue)){
                    	accessDenied = true;
                    	actualColumnValue = i18nNoAccessMsg;
                    	displayColumnValue = i18nNoAccessMsg;
                    }else{
                    	if(!hasReadAccess){
                        	if(columnType.equals("businessobject") && UIExpression.isTypeExpression(context, columnSelect)){
                        		colValueList = UINavigatorUtil.getAdminI18NStringList(adminType, colValueList, languageStr); 
                        	}
                    	}else{	
                    if (adminType.equals("State") )
                    {
                        StringList policyList = (StringList)(bwsl.getElement(i).getSelectDataList("policy"));
                        colValueList = UINavigatorUtil.getStateI18NStringList(policyList, colValueList, languageStr);
                    } else if (adminType.startsWith("attribute_") ){
                        String attributeName = PropertyUtil.getSchemaProperty(context,adminType);
                        colValueList = UINavigatorUtil.getAttrRangeI18NStringList(attributeName, colValueList, languageStr);
                    } else {
                        colValueList = UINavigatorUtil.getAdminI18NStringList(adminType, colValueList, languageStr);
                    }
                    	}
                    }

                }

                if(bUOMFiled&& !accessDenied) {
                    colValueList = UOMDisplayValueList;
                }

                if (colValueList != null)
                {
                	if(!accessDenied){
                    	if(!hasReadAccess && !isTNRExpression){
                    		displayColumnValue = i18nNoAccessMsg;
                    	}else{
                    displayColumnValue = (String)(colValueList.firstElement());
                    if(tableBean.isDynamicURLEnabled(context, columnMap)) {
                        displayColumnValue = UINavigatorUtil.formatEmbeddedURL(context, displayColumnValue, false, languageStr);
                    }
                    	}
                	}

                    // Add the column value to the fiter list
                    // filterTreeSet.add(actualColumnValue);
                    filterTreeMap.put(actualColumnValue, displayColumnValue);

                    if (showIcon)
                        columnValueIconMap.put(actualColumnValue, objectIcon);
                }
            }
        }


        // Get the filterMap in the StringList format
        StringList filterValues = new StringList(filterTreeMap.size());

        if (filterTreeMap != null && filterTreeMap.size() > 0 )
        {
            Iterator filterTreeMapItr = filterTreeMap.keySet().iterator();

            while (filterTreeMapItr.hasNext())
                filterValues.add((String)filterTreeMapItr.next());
        }

        Boolean showIconInFilter = Boolean.valueOf(showIcon);

        // Build the Map required for displaying the filter
        filterColumnMap.put("FilterValue", filterValues);
        filterColumnMap.put("FilterValueMap", filterTreeMap);

        filterColumnMap.put("Header", columnHeader);
        filterColumnMap.put("Name", columnName);
        filterColumnMap.put("MultiValue", multiValueColumn);
        filterColumnMap.put("Format", colFormat);
        filterColumnMap.put("ShowIcon", showIconInFilter);
        filterColumnMap.put("IconMap", columnValueIconMap);
        filterColumnMap.put("Column Type",columnType);
        int filterCount = filterValues.size();

        // Check and reset the maxFilterCount
        if (filterCount > maxFilterCount)
            maxFilterCount = filterCount;

        // Add the filter column map to the Map List
        filterMapList.add(filterColumnMap);

    }
%>
<body onload="turnOffProgress();">
<form name="emxAutoFilterForm" method="post" onsubmit="filterTable(); return false">
<input type="hidden" name="timeStamp" value="<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>"/>
  <table class="list">
    <tr>
<%

    for (int i = 0; i < autoFilterColumns.size(); i++)
    {
        HashMap filterColumMap = (HashMap)filterMapList.get(i);
        String columnHeader = (String)filterColumMap.get("Header");
        String columnName = (String)filterColumMap.get("Name");
        String columnFilterHeaderName = columnName + "Filter";

%>
      <th>
      	<table><tr>
      	      	<td><input type="checkbox" name="<xss:encodeForHTMLAttribute><%=columnFilterHeaderName%></xss:encodeForHTMLAttribute>" value="checkbox" onclick="doFilterCheckboxClick(this, '<xss:encodeForJavaScript><%=columnName%></xss:encodeForJavaScript>')" checked /> </td>
      	      	<td><%=columnHeader%></td> <%-- XSSOK --%>
      	</tr></table> 
      </th>
<%
    }
%>
    </tr>

    <tr class='odd'>
<%
        for (int i = 0; i < autoFilterColumns.size(); i++)
        {
            HashMap filterColumMap = (HashMap)filterMapList.get(i);
            String columnName = (String)filterColumMap.get("Name");
            String colFormat = (String)filterColumMap.get("Format");
            Boolean multiValueColumn = (Boolean)filterColumMap.get("MultiValue");
            Boolean showIconInFilter = (Boolean)filterColumMap.get("ShowIcon");
            HashMap iconMap = (HashMap)filterColumMap.get("IconMap");

            HashMap columnMap = (HashMap)autoFilterColumns.get(i);
            StringList selectedFilters = (StringList)columnMap.get("SelectedFilters");

            StringList filterValues = (StringList)filterColumMap.get("FilterValue");
            TreeMap filterValueMap = (TreeMap)filterColumMap.get("FilterValueMap");
            String sColumnType = (String)filterColumMap.get("Column Type");
            String filterValue = "&nbsp;";
            String filterDisplayValue = "";

%>
			<td><table>
<%
           for (int k = 0; k < filterValues.size(); k++)
           {
%>
			<tr>
<%
                filterValue = (String)filterValues.get(k);
                filterDisplayValue = (String)filterValueMap.get(filterValue);
                if(sColumnType.equals("programHTMLOutput")){
				    filterValue = filterValue.replaceAll("&#160;&#160;","&nbsp; &nbsp;");
				    filterValue = filterValue.replaceAll("&amp;","&");
				}
                String filterSelected = "";
                String columnFilterHeaderName = columnName + "Filter";
                if (selectedFilters != null && selectedFilters.size() > 0 && selectedFilters.contains(filterValue))
                {
                    filterSelected = "checked";
                    // Check the heeader also
                }
                if(sColumnType.equals("programHTMLOutput")){
				    filterValue = filterValue.replaceAll("&","&amp;");
				    //filterValue = filterValue.replaceAll("&nbsp; &nbsp;","&#160;&#160;");
				}
                if(filterSelected.equals(""))
                {
%>
<script type="text/javascript">
//XSSOK
document.forms["emxAutoFilterForm"]['<%=columnFilterHeaderName%>'].checked = false;
</script>
<%
                }
filterValue = FrameworkUtil.findAndReplace(filterValue, "\"", "&quot;");
%>
      <td>
        <!-- //XSSOK -->
		<input type="checkbox" name="<%=XSSUtil.encodeForHTMLAttribute(context, columnName)%>" value="<%=XSSUtil.encodeForHTML(context,filterValue)%>" <%=filterSelected%> onclick="doFilterItemCheckboxClick(this)" />
      </td>
<%
                if (colFormat != null && colFormat.equals("date"))
                {
%>
                    <td class="listCell"><table border="0"><tr>
<%
                    if (showIconInFilter.booleanValue())
                    {
                        if (iconMap != null && iconMap.get(filterValue) != null)
                        {
                            String objectIcon = (String)iconMap.get(filterValue);
%>
                    <!-- //XSSOK -->
                    <td valign="top"><img border="0" src="<%=objectIcon%>" /></td>
<%
                        }
                    }
%>
                    <!-- //XSSOK -->
                    <td><emxUtil:lzDate localize="i18nId" tz='<%=XSSUtil.encodeForHTMLAttribute(context, (String)session.getAttribute("timeZone"))%>' format='<%=DateFrm %>' displaytime ="true"><%= filterDisplayValue %></emxUtil:lzDate></td>
                    </tr></table></td>
<%
                } else {
                    if(tableBean.isDynamicURLEnabled(context, columnMap)) {
                        filterDisplayValue = UINavigatorUtil.formatEmbeddedURL(context, filterDisplayValue, false, languageStr);
                    }
%>
                    <td class="listCell"><table><tr>
<%
                    if (showIconInFilter.booleanValue())
                    {
                        if (iconMap != null && iconMap.get(filterValue) != null)
                        {
                            String objectIcon = (String)iconMap.get(filterValue);
%>
                    <!-- //XSSOK -->
                    <td valign="top"><img border="0" src="<%=objectIcon%>" /></td>
<%
                        }
                    }
%>
                    <!-- //XSSOK -->
                    <td> <%=filterDisplayValue%></td>
                    </tr></table></td>
<%
                }
%>
    </tr>
<%
    }
%>
			</table></td>
<%
        }
%>
</tr>
  </table>
<%

} catch (Exception ex) {
    ContextUtil.abortTransaction(context);

    ex.printStackTrace();
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim());

} finally {
    ContextUtil.commitTransaction(context);
}

%>
</form>
</BODY>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

</HTML>
