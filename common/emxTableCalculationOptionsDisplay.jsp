<%--  emxTableCalculationOptionsDisplay.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTableCalculationOptionsDisplay.jsp.rca 1.4 Wed Oct 22 15:48:06 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%
String timeStamp = emxGetParameter(request, "timeStamp");
StringBuffer optionsList = new StringBuffer();
HashMap tableControlMap = null;
try {
 	HashMap tableData = tableBean.getTableData(timeStamp);
    MapList columns = tableBean.getColumns(tableData);
    tableControlMap = tableBean.getControlMap(tableData);
    int noOfColumns = columns.size();

	HashMap columnMap = new HashMap();
	for (int j = 0; j < noOfColumns; j++)
	{
		columnMap = (HashMap)columns.get(j);
		String columnName = tableBean.getName(columnMap);
		String columnHeader = tableBean.getLabel(columnMap);
		String hasCalculations = tableBean.getSetting(columnMap, "HasCalculations");

		if(tableBean.isColumnNumericForCalculations(context, columnMap)) {
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
        emxNavErrorObject.addMessage("emxTableCalculations:" + ex.toString().trim());
}

    String stringResFileId="emxFrameworkStringResource";
    String strLanguage = Request.getLanguage(request);
    String strColumns = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.Columns", stringResFileId, strLanguage);
    String strFunctions = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.Functions", stringResFileId, strLanguage);

	String strSum = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.Sum", stringResFileId, strLanguage);
	String strAverage = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.Average", stringResFileId, strLanguage);
	String strMaximum = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.Maximum", stringResFileId, strLanguage);
	String strMinimum = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.Minimum", stringResFileId, strLanguage);
	String strMedian = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.Median", stringResFileId, strLanguage);
	String strStandardDeviation = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.StandardDeviation", stringResFileId, strLanguage);

	String strHint = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.MultiSelectionHint", stringResFileId, strLanguage);
	String strAlertColumn = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.AlertSelectColumn", stringResFileId, strLanguage);
	String strAlertFunction = UINavigatorUtil.getI18nString("emxFramework.TableCalculation.AlertSelectFunction", stringResFileId, strLanguage);
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
					//XSSOK
					alert("<%=strAlertFunction%>");
					return;
				}
			}
			else
			{
				if(isFuntionChecked)
				{
					//XSSOK
					alert("<%=strAlertColumn%>");
					return;
				}
			}

			objForm.action = "emxTableCalculationOptionsProcess.jsp";
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
	<form name="TableCalculationOptionsForm" method="post">
		<input type="hidden" name="timeStamp" value="<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>"/>
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
						<tr><td><input type="checkbox" name="selFunction" value="Sum" <%=(tableBean.hasSumColumn(tableControlMap)?"checked":"")%>/><%=strSum%></td></tr>
						<tr><td><input type="checkbox" name="selFunction" value="Average" <%=(tableBean.hasAverageColumn(tableControlMap)?"checked":"")%>/><%=strAverage%></td></tr>
						<tr><td><input type="checkbox" name="selFunction" value="Maximum" <%=(tableBean.hasMaximumColumn(tableControlMap)?"checked":"")%>/><%=strMaximum%></td></tr>
						<tr><td><input type="checkbox" name="selFunction" value="Minimum" <%=(tableBean.hasMinimumColumn(tableControlMap)?"checked":"")%>/><%=strMinimum%></td></tr>
						<tr><td><input type="checkbox" name="selFunction" value="Median" <%=(tableBean.hasMedianColumn(tableControlMap)?"checked":"")%>/><%=strMedian%></td></tr>
						<tr><td><input type="checkbox" name="selFunction" value="StandardDeviation" <%=(tableBean.hasStandardDeviationColumn(tableControlMap)?"checked":"")%> /><%=strStandardDeviation%></td></tr>
					</table>
				</td>
			</tr>
		</table>

	</form>
</td></tr></table>
</body>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

</html>

