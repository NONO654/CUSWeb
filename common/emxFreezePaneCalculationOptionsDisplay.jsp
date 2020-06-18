<%--  emxFreezePaneCalculationOptionsDisplay.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFreezePaneCalculationOptionsDisplay.jsp.rca 1.2 Tue Dec  9 07:14:52 2008 ds-ukumar Experimental $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%
String timeStamp = emxGetParameter(request, "timeStamp");
StringBuffer optionsList = new StringBuffer();
HashMap tableControlMap = null;
boolean hasCustomCalc = false;
try {
 	HashMap tableData = indentedTableBean.getTableData(timeStamp);
    MapList columns = indentedTableBean.getColumns(tableData);
    tableControlMap = indentedTableBean.getControlMap(tableData);
    int noOfColumns = columns.size(); 

	HashMap columnMap = new HashMap();
	for (int j = 0; j < noOfColumns; j++)
	{
		columnMap = (HashMap)columns.get(j);
		String columnName = indentedTableBean.getName(columnMap);
		String columnHeader = indentedTableBean.getLabel(columnMap);
		String hasCalculations = indentedTableBean.getSetting(columnMap, "HasCalculations");
		//String calcCustom = indentedTableBean.getSetting(columnMap, "Calculate Custom");

		if(indentedTableBean.isColumnNumericForCalculations(context, columnMap)) {
		    //if(calcCustom != null && !"".equals(calcCustom)){
		    //    hasCustomCalc = true;
		    //}
			optionsList.append("<option value=\"");
			optionsList.append(XSSUtil.encodeForHTMLAttribute(context, columnName));
			optionsList.append("\"");
			if("true".equalsIgnoreCase(hasCalculations)) {
				optionsList.append(" selected");
			}
			optionsList.append(">");
			optionsList.append(XSSUtil.encodeForHTML(context, columnHeader));
			optionsList.append("</option>");
		}
	}
} catch (Exception ex) {
    if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        emxNavErrorObject.addMessage("emxFreezePaneCalculations:" + ex.toString().trim());
}

    String stringResFileId="emxFrameworkStringResource";
    String strLanguage = request.getHeader("Accept-Language");
    Locale loc = request.getLocale();
    String strColumns = EnoviaResourceBundle.getProperty(context,stringResFileId, loc, "emxFramework.TableCalculation.Columns");
    String strFunctions = EnoviaResourceBundle.getProperty(context,stringResFileId, loc, "emxFramework.TableCalculation.Functions");

	String strSum = EnoviaResourceBundle.getProperty(context,stringResFileId, loc, "emxFramework.TableCalculation.Sum");
	String strAverage = EnoviaResourceBundle.getProperty(context,stringResFileId, loc, "emxFramework.TableCalculation.Average");
	String strMaximum = EnoviaResourceBundle.getProperty(context,stringResFileId, loc, "emxFramework.TableCalculation.Maximum");
	String strMinimum = EnoviaResourceBundle.getProperty(context,stringResFileId, loc, "emxFramework.TableCalculation.Minimum");
	String strMedian = EnoviaResourceBundle.getProperty(context,stringResFileId, loc, "emxFramework.TableCalculation.Median");
	String strStandardDeviation = EnoviaResourceBundle.getProperty(context,stringResFileId, loc, "emxFramework.TableCalculation.StandardDeviation");
	String strCustomCalc = EnoviaResourceBundle.getProperty(context,stringResFileId, loc, "emxFramework.TableCalculation.Custom");

	String strHint = EnoviaResourceBundle.getProperty(context,stringResFileId,loc, "emxFramework.TableCalculation.MultiSelectionHint");
	String strAlertColumn = EnoviaResourceBundle.getProperty(context,stringResFileId,loc, "emxFramework.TableCalculation.AlertSelectColumn");
	String strAlertFunction = EnoviaResourceBundle.getProperty(context,stringResFileId,loc, "emxFramework.TableCalculation.AlertSelectFunction");
%>

<head>
	<title></title>
	<script type="text/javascript">
		function submitOptions()
		{
			var objForm = document.forms[0];
			objForm.target = "optionsHidden";

			var isFuntionChecked = false;
			for (var i = 0; i < objForm.selFunction.length; i++)
			{
				if(objForm.selFunction[i].checked)
				{
				  isFuntionChecked = true;
				  break;
				}
			}

			var isColumnSelected = false;
			for (var i = 0; i < objForm.selcolumns.length; i++)
			{
				if(objForm.selcolumns[i].selected)
				{
				  isColumnSelected=true;
				  break;
				}
			}

			if(isColumnSelected)
			{
				if(!isFuntionChecked)
				{
					alert("<%=strAlertFunction%>");
					return;
				}
			}
			else
			{
				alert("<%=strAlertColumn%>");
				return;
			}

			objForm.action = "emxFreezePaneCalculationOptionsProcess.jsp";
			objForm.submit();
		}
	</script>
	<%@include file = "emxUIConstantsInclude.inc"%>
	<%@include file = "../emxStyleDefaultInclude.inc"%>
	<%@include file = "../emxStyleFormInclude.inc"%>
</head>

<body>
<table border="0" cellspacing="2" cellpadding="2" width="100%">
<tr>
<td width="99%">
	<form name="FreezePaneCalculationOptionsForm" method="post">
		<input type="hidden" name="timeStamp" value="<%=XSSUtil.encodeForHTMLAttribute(context,timeStamp)%>">
		<table border="0" width="99%" cellpadding="5" cellspacing="2">
			<tr>
				<td width="150" class="label"><%=strColumns%></td>
				<td class="inputField">
					<select multiple name="selcolumns">
						<%=optionsList.toString()%>
					</select><br/>
					<%=strHint%>
				</td>
			</tr>
			<tr>
				<td width="150" class="label"><%=strFunctions%></td>
				<td class="inputField">
					<table>
						<tr><td><input type="checkbox" name="selFunction" value="SUM" <%=(indentedTableBean.hasSumColumn(tableControlMap)?"checked":"")%> /><%=strSum%></td></tr>
						<tr><td><input type="checkbox" name="selFunction" value="AVE" <%=(indentedTableBean.hasAverageColumn(tableControlMap)?"checked":"")%> /><%=strAverage%></td></tr>
						<tr><td><input type="checkbox" name="selFunction" value="MAX" <%=(indentedTableBean.hasMaximumColumn(tableControlMap)?"checked":"")%> /><%=strMaximum%></td></tr>
						<tr><td><input type="checkbox" name="selFunction" value="MIN" <%=(indentedTableBean.hasMinimumColumn(tableControlMap)?"checked":"")%> /><%=strMinimum%></td></tr>
						<tr><td><input type="checkbox" name="selFunction" value="MEDIAN" <%=(indentedTableBean.hasMedianColumn(tableControlMap)?"checked":"")%> /><%=strMedian%></td></tr>
						<tr><td><input type="checkbox" name="selFunction" value="STDDEV" <%=(indentedTableBean.hasStandardDeviationColumn(tableControlMap)?"checked":"")%> /><%=strStandardDeviation%></td></tr>
					</table>
				</td>
			</tr>
		</table>

	</form>
</td></tr></table>
<iframe class="hidden-frame" name="optionsHidden" src="emxBlank.jsp"/>	
</body>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

</html>
