<%--  emxTableAutoFilterController.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTableAutoFilterController.jsp.rca 1.13 Wed Oct 22 15:48:40 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%

String timeStamp = Request.getParameter(request, "timeStamp");

try {

    ContextUtil.startTransaction(context, false);

    boolean doFilter = false;

    // Get business object list from session level Table bean
    HashMap tableData = tableBean.getTableData(timeStamp);
    MapList relBusObjList = tableBean.getObjectList(tableData);
    HashMap tableControlMap = tableBean.getControlMap(tableData);
    HashMap paramMap = tableBean.getRequestMap(tableData);
    paramMap.put("languageStr", Request.getLanguage(request) );
    MapList autoFilterColumns = tableBean.getAutoFilterColumns(tableData);
    String i18nNoAccessMsg = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getSession().getLocale(),"emxFramework.Access.NoAccess");
    // Loop thru the columns and get the Filters to apply
    for (int j = 0; j < autoFilterColumns.size(); j++)
    {
        HashMap filterColumnMap = new HashMap();
        HashMap columnMap = (HashMap)autoFilterColumns.get(j);
        String columnName = tableBean.getName(columnMap);

        // remove the existing "SelectedFilters" key from the column map, if exist
        if (columnMap.get("SelectedFilters") != null)
            columnMap.remove("SelectedFilters");

        // Get the selected filter values
        String[] filterArray = Request.getParameterValues(request, columnName);
        StringList selectedFilters = new StringList();
        if (filterArray != null && java.lang.reflect.Array.getLength(filterArray) > 0)
        {
            for (int k = 0; k < java.lang.reflect.Array.getLength(filterArray); k++){
                selectedFilters.add(filterArray[k]);
            }

            columnMap.put("SelectedFilters", selectedFilters);
            doFilter = true;
        }
    }

    if (doFilter)
    {
        HashMap columnValuesMap = tableBean.getColumnValuesMap(context, application,autoFilterColumns, relBusObjList, tableData);
        Vector programResult[] = new Vector[autoFilterColumns.size()];
        BusinessObjectWithSelectList bwsl = (BusinessObjectWithSelectList)columnValuesMap.get("Businessobject");
        RelationshipWithSelectList rwsl = (RelationshipWithSelectList)columnValuesMap.get("Relationship");
        programResult = (Vector[])columnValuesMap.get("Program");
        MapList filterObjectList = new MapList();
        int resultIndex = 0;
        for (int i = 0; i < relBusObjList.size(); i++)
        {
            boolean filterItem = true;
            Map elementMap = (Map)relBusObjList.get(i);
			boolean hasReadAccess = true;
            if(UIUtil.isNotNullAndNotEmpty((String)elementMap.get("objReadAccess"))){
            	hasReadAccess = Boolean.valueOf((String)elementMap.get("objReadAccess"));
            }
            for (int j = 0; j < autoFilterColumns.size(); j++)
            {
                HashMap filterColumnMap = new HashMap();
                HashMap columnMap = (HashMap)autoFilterColumns.get(j);
                String columnName = tableBean.getName(columnMap);
                String columnType = tableBean.getSetting(columnMap, "Column Type");

                // Get the selected filter values from column
                StringList selectedFilters = (StringList)columnMap.get("SelectedFilters");
                if (selectedFilters != null && selectedFilters.size() > 0)
                {

                    if (    columnType.equals("businessobject") ||
                            columnType.equals("relationship") ||
                            columnType.equals("program") ||
                            columnType.equals("programHTMLOutput") )
                    {
                        StringList colValueList = new StringList();
                        String actualColumnValue = "";
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
                                String languageStr = Request.getLanguage(request);
                                if(UOMUtil.isSimpleAttributeExpression(columnSelect)) {
                                    String sUOMcolumnselect = (String)columnMap.get("UOM Input Select");
                                    String attrName = UOMUtil.getAttrNameFromSelect(columnSelect);
                                    String inputValue = "";
                                    String systemValue="";

                                    colValueList = (StringList)(bwsl.getElement(i).getSelectDataList(sUOMcolumnselect));
                                    if(colValueList != null) {
                                        inputValue = (String)colValueList.firstElement();
                                    }
                                    sUOMcolumnselect = (String)columnMap.get("UOM System Select");
                                    if(sUOMcolumnselect != null) {
                                        colValueList = (StringList)(bwsl.getElement(i).getSelectDataList(sUOMcolumnselect));
                                        if(colValueList != null) {
                                            systemValue = (String)colValueList.firstElement();
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
                                    String languageStr = Request.getLanguage(request);
                                    if(UOMUtil.isSimpleAttributeExpression(columnSelect)) {
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
                                        if("".equals(systemValue)) {
                                            strColumnValue = inputValue;
                                        }else {
                                            strColumnValue = inputValue + " (" + systemValue + ")";
                                        }
                                    }else {
                                        strColumnValue = (String)columnInfo.get(columnSelect);
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
                        } 
                        if (colValueList != null){
                            actualColumnValue = (String)(colValueList.firstElement());
                            if(columnType.equals("programHTMLOutput")){
                                actualColumnValue = actualColumnValue.replaceAll("&#160;&#160;","&nbsp; &nbsp;");
                                actualColumnValue = actualColumnValue.replaceAll("&","&amp;");
								actualColumnValue = actualColumnValue.replaceAll("&amp;","&");
                                actualColumnValue = actualColumnValue.replaceAll("\"","&quot;");
                           }
                         }
						 actualColumnValue = tableBean.NO_READ_ACCESS.equals(actualColumnValue) ? i18nNoAccessMsg : actualColumnValue;
                        // Verify if the value is in the "SelectedFilters" list
                        if ( selectedFilters.contains(actualColumnValue) )
                        {
                            filterItem = true;
                        } else {
                            filterItem = false;
                            break;
                        }
                    }
                }
            }
           

        }
            // If filterItem is true, add the item to filteredList
            if (filterItem == true){
                    filterObjectList.add((Map)relBusObjList.get(i));
              }

            if(hasReadAccess){
            	resultIndex++;
            }

        // If the filtered object List is same as the original list, use the original list
        if ( filterObjectList.size() == relBusObjList.size() )
            tableBean.removeFilteredObjectList(tableData);
        else {
            tableBean.setFilteredObjectList(tableData, filterObjectList);
            tableControlMap.put("All Values Map", null);
		}

      } 
    }else {

        // Remove the existing FilteredObjectList
        tableBean.removeFilteredObjectList(tableData);

    }

%>
<script language="JavaScript">
    // Verify the table page, if the user has already checked/selected some items.
    if (getTopWindow().getWindowOpener().parent.ids)
    {
        if(confirm("<emxUtil:i18nScript localize="i18nId">emxFramework.TableComponent.AutoFilterMsg1</emxUtil:i18nScript>"))
        {
            getTopWindow().getWindowOpener().parent.ids = null;
            getTopWindow().getWindowOpener().listDisplay.location.reload();
            //getTopWindow().getWindowOpener().parent.listFoot.location.reload();
            getTopWindow().closeWindow();
        }
    } else {
    	getTopWindow().getWindowOpener().loadFooter();
        getTopWindow().getWindowOpener().listDisplay.document.location.href = getTopWindow().getWindowOpener().listDisplay.document.location.href;
        getTopWindow().closeWindow();
    }

</script>
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

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
