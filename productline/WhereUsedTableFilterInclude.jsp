
<%--  WhereUsedTableFilterInclude.jsp

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program --%>

<!-- Include file for error handling -->
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<!-- Include directives -->
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>

<%@include file = "../emxUICommonAppInclude.inc"%>




<!-- Page directives -->
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import = "com.matrixone.apps.domain.util.i18nNow"%>
<%@page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%

String tableID    = emxGetParameter(request, "tableID");

String STR_TABLE_COLUMNS = "columns";
String STR_RELATIONSHIP ="Relationship";
String STR_FILTERVALUE = "FilterValue";
String STR_FILTERVALUEMAP = "FilterValueMap";
String STR_BUSINESSOBJECT = "Businessobject";
String STR_COLUMNTYPE="Column Type";
String STR_ADMINTYPE="Admin Type";
//get the string values from the properties file
String STR_LEVEL_ONE = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.WhereUsed.LevelOne",acceptLanguage);
String STR_ALL = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Filter.All",acceptLanguage);
MapList mlFilterMapList = new MapList();
StringList slFilterValuesMapList = new StringList();

try {

	ContextUtil.startTransaction(context, false);

//Start of Add by Enovia MatrixOne for Bug # 312385 date 02-Dec-05
	HashMap tableControlMapTemp = tableBean.getControlMap(tableID);
	boolean bDataLoaded = ((Boolean)tableControlMapTemp.get("DataLoaded")).booleanValue();

if(!bDataLoaded)
    {
        //set data objects in Table bean
        tableBean.setTableObjects(context, tableID);

        // Sort the table data
        String sortColumnName = emxGetParameter(request, "sortColumnName");

        if (sortColumnName != null && sortColumnName.trim().length() > 0 && (!(sortColumnName.equals("null"))) )
        {
            tableBean.sortObjects(context, tableID);
        }
    }
//End of Add by Enovia MatrixOne for Bug # 312385 date 02-Dec-05


	int iFilterCount = 0;
	int iMaxFilterCount = 0;
	String strColumnHeader = "";
	String strTypeName = "";
	String strColumnType = "";
	String strAdminType = "";
	String strDisplayColumnValue = "";
	String strActualColumnValue = "";
	String strColumnSelect ="";
	StringList slTypeNamesList = new StringList();
	StringList slPolicyList= new StringList();
	StringList slColValueList = new StringList();

	//obtain the objects' maplist from the tablebean
	Iterator filterTreeMapItr = null;
    Map mpColumnInfoMap = null;
	Map mpColumnMap = null;
	MapList	 mlFilterColumnsList = new MapList();

	// Get business object list from session level Table bean
    HashMap tableData = tableBean.getTableData(tableID);
	MapList relBusObjList = tableBean.getObjectList(tableData);
	MapList mlColumnsMapList = (MapList)tableData.get(STR_TABLE_COLUMNS);


	//The following code gets the MapList of the columns to be filtered
	if (mlColumnsMapList != null && mlColumnsMapList.size() > 0)
        {
		  for (int i=0; i < mlColumnsMapList.size(); i++)
            {
				mpColumnMap = (HashMap)mlColumnsMapList.get(i);
				strColumnHeader=tableBean.getName((HashMap)mpColumnMap);
				if(strColumnHeader.equalsIgnoreCase(ProductLineConstants.SELECT_STATES)||
				   strColumnHeader.equalsIgnoreCase(ProductLineConstants.SELECT_TYPE)
				   )
                   {
                   mlFilterColumnsList.add((HashMap)mpColumnMap);
                   }
            }
         }

	HashMap columnValuesMap = tableBean.getColumnValuesMap(context,
		                                                   application,
		                                                   mlFilterColumnsList,
		                                                   relBusObjList,
		                                                   tableData);
	BusinessObjectWithSelectList bwsl = (BusinessObjectWithSelectList)
		                                 columnValuesMap.get(STR_BUSINESSOBJECT);

	/* The following code process each table row (each map in the maplist),
	  for each filter column and get the values for that column */
    for (int j = 0; j < mlFilterColumnsList.size(); j++)
    {
        TreeMap filterTreeMap = new TreeMap();
        HashMap filterColumnMap = new HashMap();

		mpColumnMap = (HashMap)mlFilterColumnsList.get(j);
        strColumnHeader = tableBean.getName((HashMap)mpColumnMap);
        strColumnType = tableBean.getSetting(mpColumnMap, STR_COLUMNTYPE);
        strAdminType = tableBean.getSetting(mpColumnMap, STR_ADMINTYPE);

        for (int i = 0; i < relBusObjList.size(); i++)
        {
            strTypeName = bwsl.getElement(i).getSelectData
				         (ProductLineConstants.SELECT_TYPE);
            slTypeNamesList.addElement(strTypeName);

			if (strColumnType.equalsIgnoreCase(STR_BUSINESSOBJECT) )
			{
				strColumnSelect = tableBean.
									  getBusinessObjectSelect((HashMap)mpColumnMap);
				slColValueList = (StringList)
							   (bwsl.getElement(i).getSelectDataList(strColumnSelect));
			}

			// If the columns value has more than one value, do not process this column.
			if (slColValueList != null && slColValueList.size() > 1)
			{
				filterTreeMap.clear();
				break;
			}

			if (slColValueList != null)
				{
				strActualColumnValue = (String)(slColValueList.firstElement());
				}
			  //get the internationalized string for the column values
			 if (slColValueList != null && strAdminType != null)
			  {
				if (strAdminType.equalsIgnoreCase(ProductLineConstants.SELECT_STATES) )
				{
					slPolicyList =(StringList)
										   (bwsl.getElement(i).getSelectDataList
										   (ProductLineConstants.SELECT_POLICY));
					slColValueList = i18nNow.getStateI18NStringList
										   (slPolicyList, slColValueList, acceptLanguage);
				}
				else {
					slColValueList = i18nNow.getAdminI18NStringList
											 (strAdminType,slColValueList, acceptLanguage);
				}

			  }

			if (slColValueList != null)
			{
				strDisplayColumnValue = (String)(slColValueList.firstElement());

				// Add the column value to the fiter list
				filterTreeMap.put(strActualColumnValue, strDisplayColumnValue);
			}

        }
        // Get the filterMap in the StringList format
         slFilterValuesMapList = new StringList(filterTreeMap.size());

        if (filterTreeMap != null && filterTreeMap.size() > 0 )
        {
            filterTreeMapItr = filterTreeMap.keySet().iterator();

            while (filterTreeMapItr.hasNext())
                slFilterValuesMapList.add((String)filterTreeMapItr.next());
        }
        // Build the Map required for displaying the filter
        filterColumnMap.put(STR_FILTERVALUE, slFilterValuesMapList);
        filterColumnMap.put(STR_FILTERVALUEMAP, filterTreeMap);
        filterColumnMap.put(ProductLineConstants.SELECT_NAME, strColumnHeader);



        iFilterCount = slFilterValuesMapList.size();

        // Check and reset the iMaxFilterCount
        if (iFilterCount > iMaxFilterCount)
           {
            iMaxFilterCount = iFilterCount;
           }
        // Add the filter column map to the Map List
        mlFilterMapList.add(filterColumnMap);
    }
}
catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    ex.printStackTrace();

} finally {
    ContextUtil.commitTransaction(context);
}

%>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<script language="javascript">
    function filterData() {
       var filterProcessURL="WhereUsedTableFilterIncludeProcess.jsp";
       document.filterIncludeForm.action = filterProcessURL;
       document.filterIncludeForm.target = "listHidden";
       document.filterIncludeForm.submit();
    }
</script>


	<form name="filterIncludeForm">
		<table border="0" cellspacing="2" cellpadding="3" >
		  <tr >
		  <!--Code to populate "Level" combobox on the filter bar -->
			   <td  width="90" bgColor=#e2e2e2 fontsize ><b>
				  <emxUtil:i18n localize="i18nId">
					emxProduct.Form.Label.Show
				  </emxUtil:i18n></b>
			   </td>
			   <td width="80" bgcolor=#cccccc><b>
				  <emxUtil:i18n localize="i18nId">
					emxProduct.Form.Label.Level
				  </emxUtil:i18n></b>
			   </td>
			   <td class="inputField" colspan="1">
					<select name="Level">
					  <option value="1">
						  <%=XSSUtil.encodeForHTML(context,STR_LEVEL_ONE)%>
					  </option>
					  <option value="all" selected>
						  <%=XSSUtil.encodeForHTML(context,STR_ALL)%>
					  </option>
					</select>
			   </td>
		 <!--Code to populate "Type" combobox on the filter bar -->
			   <td  width="80" bgcolor=#cccccc><b>
					<emxUtil:i18n localize="i18nId">
					  emxFramework.Basic.Type
					</emxUtil:i18n></b>
				</td>
				<td class="inputField" colspan="1">
					<select name="Type">
					  <option value="all" selected ><%=XSSUtil.encodeForHTML(context,STR_ALL)%></option>
			 <%
						HashMap filterColumMap=new HashMap();
						Map filterColumnValuesMap=null;
						String strColumnHeader="";
						for (int i = 0; i < mlFilterMapList.size(); i++)
							{
							filterColumMap = (HashMap)mlFilterMapList.get(i);
							strColumnHeader = (String)filterColumMap.get
								          (ProductLineConstants.SELECT_NAME);
							 if(strColumnHeader.equalsIgnoreCase
								   (ProductLineConstants.SELECT_TYPE))
								 {
									slFilterValuesMapList = (StringList)filterColumMap.
										                    get(STR_FILTERVALUE);
									filterColumnValuesMap=(Map)filterColumMap.
									                       get(STR_FILTERVALUEMAP);
									break;
								 }
							}
						   for(int i=0;i<slFilterValuesMapList.size();i++)
						   {
		%>
							  <option value='<xss:encodeForHTMLAttribute><%=slFilterValuesMapList.elementAt(i)%></xss:encodeForHTMLAttribute>'>
							  <%=XSSUtil.encodeForHTML(context,(String)filterColumnValuesMap.get
			                                  (slFilterValuesMapList.elementAt(i)))%>
							  </option>
		<%
					   }
		%>
		          </select>
			   </td>
		<!--Code to populate "State" combobox on the filter bar -->
			   <td  width="80" bgcolor=#cccccc><b>
					<emxUtil:i18n localize="i18nId">
					  emxFramework.Basic.State
					</emxUtil:i18n></b>
			   </td>
			   <td class="inputField" colspan="1">
					<select name="State">
					  <option value="all" selected ><%=XSSUtil.encodeForHTML(context,STR_ALL)%></option>
			 <%			for (int i = 0; i < mlFilterMapList.size(); i++)
							{
							filterColumMap = (HashMap)mlFilterMapList.get(i);
							strColumnHeader = (String)filterColumMap.get
							             (ProductLineConstants.SELECT_NAME);
							 if(strColumnHeader.equalsIgnoreCase
								         (ProductLineConstants.SELECT_STATES))
								 {
									slFilterValuesMapList = (StringList)filterColumMap.get(STR_FILTERVALUE);
									 filterColumnValuesMap = (Map)filterColumMap.
										                         get(STR_FILTERVALUEMAP);
									 break;
								 }
							}
						   for(int i=0;i<slFilterValuesMapList.size();i++)
						   {
		%>
						  <option value='<xss:encodeForHTMLAttribute><%=slFilterValuesMapList.elementAt(i)%></xss:encodeForHTMLAttribute>'>
							<%=XSSUtil.encodeForHTML(context,(String)filterColumnValuesMap.get(slFilterValuesMapList.elementAt(i)))%>
						  </option>
		<%
					   }
		%>
		         </select>
			   </td>
			   <td width="90"><input type="button" id="btnFilter" value="<emxUtil:i18n  localize="i18nId">emxProduct.Button.Filter</emxUtil:i18n>"
			   onclick="javascript:filterData();">
			   </td>
		   </tr>
		</table>
	<input type="hidden" name="tableID" value="<xss:encodeForHTMLAttribute><%=tableID%></xss:encodeForHTMLAttribute>">
	</form>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
