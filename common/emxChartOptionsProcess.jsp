<%--  emxChartOptionsProcess.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxChartOptionsProcess.jsp.rca 1.11 Wed Oct 22 15:49:02 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%
String timeStamp = emxGetParameter(request, "timeStamp");
HashMap tableData = tableBean.getTableData(timeStamp);
HashMap requestMap = tableBean.getRequestMap(tableData);

StringBuffer strYAxis = new StringBuffer(100);
String[] yaxisvalues = emxGetParameterValues(request, "YAxis");
if(yaxisvalues != null) {
  for(int count=0; count < yaxisvalues.length; count++){
    if(count != 0){

      strYAxis.append(",");
    }
    strYAxis.append(yaxisvalues[count]);
  }
}

String chartType = emxGetParameter(request, "chartType");
boolean cntCrtChart = false;
/*************************************************************/
String stringResFileId  = "emxFrameworkStringResource";
Locale locale           = new Locale(request.getHeader("Accept-Language"));
String noObjectAlert    = EnoviaResourceBundle.getProperty(context, stringResFileId, locale, "emxFramework.ChartOptions.NoObjectAlert");
String pieAlert         = EnoviaResourceBundle.getProperty(context, stringResFileId, locale, "emxFramework.ChartOptions.PieChartAlert");
String strAlert         = noObjectAlert;

MapList columns                     = tableBean.getColumns(tableData);
int noOfColumns                     = columns.size();
HashMap tableControlMap             = tableBean.getControlMap(tableData);
RelationshipWithSelectList rwsl     = null;
BusinessObjectWithSelectList bwsl   = null;
Vector programResult[]              = new Vector[noOfColumns];

String tableRowIdList[]     = (String[])requestMap.get("emxTableRowId");
MapList relBusObjList       = tableBean.getFilteredObjectList(tableData);
MapList relBusObjPageList   = new MapList();
if (relBusObjList != null && relBusObjList.size() > 0)
{
  if ( tableBean.isMultiPageMode(tableControlMap))
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

  if(tableRowIdList == null || tableRowIdList.length <= 0) {
    tableBean.setEditObjectList(context, timeStamp, relBusObjPageList, null);
  } else {
    tableBean.setEditObjectList(context, timeStamp, relBusObjList, tableRowIdList);
  }

  relBusObjPageList         = tableBean.getEditObjectList(context, timeStamp);
  tableBean.setEditObjectList(context, timeStamp, null);
  HashMap columnValuesMap   = tableBean.getColumnValuesMap(context, application, relBusObjPageList, tableData);

  bwsl          = (BusinessObjectWithSelectList)columnValuesMap.get("Businessobject");
  rwsl          = (RelationshipWithSelectList)columnValuesMap.get("Relationship");
  programResult = (Vector[])columnValuesMap.get("Program");
}

if(relBusObjPageList.size() == 0) {
  cntCrtChart = true;
  strAlert = noObjectAlert;
}

if(chartType.equalsIgnoreCase("PieChart")) {
  String selycol = yaxisvalues[0];
  HashMap columnMap = new HashMap();
  int selcolindex = -1;
  for (int j = 0; j < noOfColumns; j++)
  {
    columnMap = (HashMap)columns.get(j);
    String columnName = tableBean.getName(columnMap);
    selcolindex = j;
    if(columnName.equalsIgnoreCase(selycol))
      break;
  }

  boolean bFIP = true;
  String columnType = tableBean.getSetting(columnMap, "Column Type");
  String columnSelect = tableBean.getBusinessObjectSelect(columnMap);
  String columnValue = null;

  for (int i = 0; i < relBusObjPageList.size(); i++)
  {
    Map elementMap = (Map)relBusObjPageList.get(i);
    String columnName = tableBean.getName(columnMap);

    columnValue = "";
    StringList colValueList = new StringList();


    if (columnType.equals("businessobject") )
    {
      if(tableBean.isAssociatedWithDimension(columnMap) && !UOMUtil.isSimpleAttributeExpression(columnSelect) && !tableBean.isAlphanumericField(columnMap)) {
            columnSelect = (String)columnMap.get("UOM Db Select");
      }
      colValueList = (StringList)(bwsl.getElement(i).getSelectDataList(columnSelect));
    } else if (columnType.equals("relationship") ) {
      RelationshipWithSelect rws = (RelationshipWithSelect)rwsl.elementAt(i);
      Hashtable columnInfo = rws.getRelationshipData();
      if(tableBean.isAssociatedWithDimension(columnMap) && !UOMUtil.isSimpleAttributeExpression(columnSelect) && !tableBean.isAlphanumericField(columnMap)) {
        columnSelect = (String)columnMap.get("UOM Db Select");
      }
      try {
        colValueList.add((String)columnInfo.get(columnSelect));
      } catch (Exception ex) {
        colValueList = (StringList)columnInfo.get(columnSelect);
      }
    } else if (columnType.equals("program") ) {
      try {
          HashMap tempHashString= (HashMap) programResult[selcolindex].get(i);
          String actualString= (String)tempHashString.get("ActualValue");
          colValueList.add(actualString);
      } catch (Exception ex) {
        colValueList = (StringList)programResult[selcolindex].get(i);
      }
    }

    if ( colValueList != null && colValueList.size() > 0 ) {
      columnValue = (String)(colValueList.firstElement());
    }
    if(i != 0 && columnValue!=null){
      if( (bFIP && (Double.valueOf(columnValue)).doubleValue() < 0.0) || (!bFIP && (Double.valueOf(columnValue)).doubleValue() >= 0.0) ){
        cntCrtChart = true;
        strAlert = pieAlert;
        break;
      }
    } else if(columnValue!=null){
      if((Double.valueOf(columnValue)).doubleValue() < 0.0)
        bFIP = false;

    }
  }
}
/*************************************************************/
if(cntCrtChart)
{
  session.setAttribute("error.message", strAlert);
%>
  <%@include file = "emxNavigatorBottomErrorInclude.inc"%>
<%
} else{
  requestMap.put("XAxis", emxGetParameter(request, "XAxis"));

  requestMap.put("YAxis", strYAxis.toString());

  requestMap.put("draw3D", emxGetParameter(request, "draw3D"));
  requestMap.put("chartTitle", emxGetParameter(request, "chartTitle"));
  requestMap.put("chartType", chartType);
  requestMap.put("labelDirection", emxGetParameter(request, "labelDirection"));
%>
  <%@include file = "emxNavigatorBottomErrorInclude.inc"%>
  <script language="JavaScript" src="scripts/emxUIConstants.js"></script>
  <script language="JavaScript" src="scripts/emxUIModal.js"></script>
  <script type="text/javascript">
    showModalDialog("emxChart.jsp?timeStamp=<%=XSSUtil.encodeForURL(context, timeStamp)%>", 800, 600, true);
  </script>
<%
}
%>

