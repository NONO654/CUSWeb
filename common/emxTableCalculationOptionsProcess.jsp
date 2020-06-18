<%--  emxTableCalculationOptionsProcess.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTableCalculationOptionsProcess.jsp.rca 1.4 Wed Oct 22 15:48:23 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%
String timeStamp = emxGetParameter(request, "timeStamp");

String calcSum = "false";
String calcAverage = "false";
String calcMaximum = "false";
String calcMinimum = "false";
String calcMedian = "false";
String calcStandardDeviation = "false";
boolean hasCalculations = false;

try {
	StringList selColumnsList = new StringList();
	String[] selcolumns = emxGetParameterValues(request, "selcolumns");
	if(selcolumns != null) {
		for(int i=0; i < selcolumns.length; i++){
			selColumnsList.add(selcolumns[i]);
		}
	}

	String[] selFunction = emxGetParameterValues(request, "selFunction");
	if(selFunction != null) {
		for(int count=0; count < selFunction.length; count++){
			if("Sum".equalsIgnoreCase(selFunction[count])) {
				calcSum = "true";
				hasCalculations = true;
			} else if("Average".equalsIgnoreCase(selFunction[count])) {
				calcAverage = "true";
				hasCalculations = true;
			} else if("Maximum".equalsIgnoreCase(selFunction[count])) {
				calcMaximum = "true";
				hasCalculations = true;
			} else if("Minimum".equalsIgnoreCase(selFunction[count])) {
				calcMinimum = "true";
				hasCalculations = true;
			} else if("Median".equalsIgnoreCase(selFunction[count])) {
				calcMedian = "true";
				hasCalculations = true;
			} else if("StandardDeviation".equalsIgnoreCase(selFunction[count])) {
				calcStandardDeviation = "true";
				hasCalculations = true;
			}
		}
	}

	if(selColumnsList.size() <= 0) {
		hasCalculations = false;
	}

 	HashMap tableData = tableBean.getTableData(timeStamp);
    MapList columns = tableBean.getColumns(tableData);
	HashMap tableControlMap = tableBean.getControlMap(tableData);
    tableControlMap.put("HasCalculations", hasCalculations ? Boolean.TRUE : Boolean.FALSE);
	tableControlMap.put("HasSum", "true".equalsIgnoreCase(calcSum)? Boolean.TRUE : Boolean.FALSE);
	tableControlMap.put("HasAverage", "true".equalsIgnoreCase(calcAverage) ? Boolean.TRUE : Boolean.FALSE);
	tableControlMap.put("HasMaximum", "true".equalsIgnoreCase(calcMaximum) ? Boolean.TRUE : Boolean.FALSE);
	tableControlMap.put("HasMinimum", "true".equalsIgnoreCase(calcMinimum) ? Boolean.TRUE : Boolean.FALSE);
	tableControlMap.put("HasMedian", "true".equalsIgnoreCase(calcMedian) ? Boolean.TRUE : Boolean.FALSE);
	tableControlMap.put("HasStandardDeviation", "true".equalsIgnoreCase(calcStandardDeviation)? Boolean.TRUE : Boolean.FALSE);

    int noOfColumns = columns.size();

	HashMap columnMap = new HashMap();
	for (int j = 0; j < noOfColumns; j++)
	{
		columnMap = (HashMap)columns.get(j);
		String columnName = tableBean.getName(columnMap);
		HashMap tempMap = tableBean.getSettings(columnMap);
		if(selColumnsList.contains(columnName))
		{
			tempMap.put("Calculate Sum", calcSum);
			tempMap.put("Calculate Average", calcAverage);
			tempMap.put("Calculate Maximum", calcMaximum);
			tempMap.put("Calculate Minimum",calcMinimum);
			tempMap.put("Calculate Median", calcMedian);
			tempMap.put("Calculate Standard Deviation", calcStandardDeviation);
			tempMap.put("HasCalculations", "true");
		} else {
			tempMap.put("Calculate Sum", "false");
			tempMap.put("Calculate Average", "false");
			tempMap.put("Calculate Maximum", "false");
			tempMap.put("Calculate Minimum","false");
			tempMap.put("Calculate Median", "false");
			tempMap.put("Calculate Standard Deviation", "false");
			tempMap.put("HasCalculations", "false");
		}
		tableBean.setSettings(columnMap, tempMap);
	}
} catch (Exception ex) {
    if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        emxNavErrorObject.addMessage("emxTableCalculations:" + ex.toString().trim());
}
%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
<script type="text/javascript">
	var myFrame = findFrame(getTopWindow().getWindowOpener(),"listDisplay");
	if(myFrame == null)
	{
	    myFrame = findFrame(getTopWindow().getWindowOpener().parent,"listDisplay");
	}

	myFrame.location.href = myFrame.location.href;
	getTopWindow().closeWindow();
</script>
