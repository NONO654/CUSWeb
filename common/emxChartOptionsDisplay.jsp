<%--  emxChartOptionsDisplay.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxChartOptionsDisplay.jsp.rca 1.7 Wed Oct 22 15:48:48 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%
String timeStamp = emxGetParameter(request, "timeStamp");
StringBuffer tempList = new StringBuffer();
StringBuffer yAxisoptionsList = new StringBuffer();
StringBuffer xAxisoptionsList  = new StringBuffer();
HashMap tableControlMap = null;
try {
    HashMap tableData = tableBean.getTableData(timeStamp);
    MapList columns = tableBean.getColumns(tableData);
    tableControlMap = tableBean.getControlMap(tableData);
    int noOfColumns = columns.size();

    HashMap columnMap = new HashMap();
    for (int j = 0; j < noOfColumns; j++)
    {
        tempList = new StringBuffer();
        columnMap = (HashMap)columns.get(j);
        String columnName = XSSUtil.encodeForHTML(context, tableBean.getName(columnMap));
        String columnHeader = XSSUtil.encodeForHTML(context, tableBean.getLabel(columnMap));
        //Added for bug 363607
        boolean xAxisFlag = true;
        if(columnHeader != null && columnHeader.indexOf("img") > -1)
            xAxisFlag = false;
        //Ended
        String columnType = tableBean.getSetting(columnMap, "Column Type");

        tempList.append("<option value='");
        tempList.append(columnName);
        tempList.append("'>");
        tempList.append(columnHeader);
        tempList.append("</option>");

        if(tableBean.isColumnNumericForCalculations(context, columnMap)) {
            yAxisoptionsList.append(tempList.toString());
        } else if(!"icon".equalsIgnoreCase(columnType) && !"checkbox".equalsIgnoreCase(columnType) && !"separator".equalsIgnoreCase(columnType) && xAxisFlag) {
            xAxisoptionsList.append(tempList.toString());
        }
    }
} catch (Exception ex) {
    if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        emxNavErrorObject.addMessage("emxTableCalculations:" + ex.toString().trim());
}

    String stringResFileId  = "emxFrameworkStringResource";
    String strLanguage      = request.getHeader("Accept-Language");
    Locale locale           = new Locale(strLanguage);

    String strHint              = EnoviaResourceBundle.getProperty(context, stringResFileId, locale, "emxFramework.TableCalculation.MultiSelectionHint");
    String strChartType         = EnoviaResourceBundle.getProperty(context, stringResFileId, locale, "emxFramework.ChartOptions.ChartType"); 
    String strRenderOptions     = EnoviaResourceBundle.getProperty(context, stringResFileId, locale,"emxFramework.ChartOptions.RenderOptions");
    String str3D                = EnoviaResourceBundle.getProperty(context, stringResFileId, locale,"emxFramework.ChartOptions.3D");
    String strXAxis             = EnoviaResourceBundle.getProperty(context, stringResFileId, locale,"emxFramework.ChartOptions.XAxis");
    String strYAxis             = EnoviaResourceBundle.getProperty(context, stringResFileId, locale,"emxFramework.ChartOptions.YAxis");
    String strSliceLabels       = EnoviaResourceBundle.getProperty(context, stringResFileId, locale,"emxFramework.ChartOptions.SliceLabels");
    String strLineLabels        = EnoviaResourceBundle.getProperty(context, stringResFileId, locale,"emxFramework.ChartOptions.LineLabels");
    String strChartData         = EnoviaResourceBundle.getProperty(context, stringResFileId, locale,"emxFramework.ChartOptions.ChartData");
    String strAxisLabels        = EnoviaResourceBundle.getProperty(context, stringResFileId, locale,"emxFramework.ChartOptions.XAxisLabels");
    String strHorizontal        = EnoviaResourceBundle.getProperty(context, stringResFileId, locale,"emxFramework.ChartOptions.XAxisLabels.Horizontal");
    String strVertical          = EnoviaResourceBundle.getProperty(context, stringResFileId, locale,"emxFramework.ChartOptions.XAxisLabels.Vertical");

    String strBarChart          = EnoviaResourceBundle.getProperty(context, stringResFileId, locale,"emxFramework.ChartOptions.ChartTypes.BarChart");
    String strStackBarChart     = EnoviaResourceBundle.getProperty(context, stringResFileId, locale,"emxFramework.ChartOptions.ChartTypes.StackBarChart");
    String strPieChart          = EnoviaResourceBundle.getProperty(context, stringResFileId, locale,"emxFramework.ChartOptions.ChartTypes.PieChart");
    String strLineChart         = EnoviaResourceBundle.getProperty(context, stringResFileId, locale,"emxFramework.ChartOptions.ChartTypes.LineChart");
    String strDateLineChart     = EnoviaResourceBundle.getProperty(context, stringResFileId, locale,"emxFramework.ChartOptions.ChartTypes.DateLineChart");

    String strXAxisAlert        = EnoviaResourceBundle.getProperty(context, stringResFileId, locale,"emxFramework.ChartOptions.XAxisAlert");
    String strYAxisAlert        = EnoviaResourceBundle.getProperty(context, stringResFileId, locale,"emxFramework.ChartOptions.YAxisAlert");
    String strSliceLabelAlert   = EnoviaResourceBundle.getProperty(context, stringResFileId, locale,"emxFramework.ChartOptions.SliceLabelAlert");
    String strChartDataAlert    = EnoviaResourceBundle.getProperty(context, stringResFileId, locale,"emxFramework.ChartOptions.ChartDataAlert");


    StringBuffer chartDataHTML = new StringBuffer();
    chartDataHTML.append("<select size='5' name=\\\"YAxis\\\">");
    chartDataHTML.append(yAxisoptionsList.toString());
    chartDataHTML.append("</select>");

    StringBuffer yAXisHTML = new StringBuffer();
    yAXisHTML.append("<select size='5' multiple name=\\\"YAxis\\\">");
    yAXisHTML.append(yAxisoptionsList.toString());
    yAXisHTML.append("</select>");
    yAXisHTML.append("<br/>");
    yAXisHTML.append(strHint);


    StringBuffer lineChartXAxisOptionsHTML = new StringBuffer();
    lineChartXAxisOptionsHTML.append("<select size='5' name=\\\"XAxis\\\">");
    lineChartXAxisOptionsHTML.append(yAxisoptionsList.toString());
    lineChartXAxisOptionsHTML.append("</select>");

    StringBuffer otherXAxisOptionsHTML = new StringBuffer();
    otherXAxisOptionsHTML.append("<select size='5' name=\\\"XAxis\\\">");
    otherXAxisOptionsHTML.append(xAxisoptionsList.toString());
    otherXAxisOptionsHTML.append("</select>");
%>

<head>
    <title></title>
    <script type="text/javascript">
        function submitOptions()
        {
            var objForm = document.forms[0];
            var chrtType = objForm.chartType.value;

            var isXAxisChecked = false;
            for (var i = 0; i < objForm.XAxis.length; i++)
            {
                if(objForm.XAxis[i].selected)
                {
                  isXAxisChecked = true;
                  break;
                }
            }

            var isYAxisChecked = false;
            for (var i = 0; i < objForm.YAxis.length; i++)
            {
                if(objForm.YAxis[i].selected)
                {
                  isYAxisChecked = true;
                  break;
                }
            }

            if(!isXAxisChecked) {
                if(chrtType == 'PieChart') {
                    alert("<%=strSliceLabelAlert%>");
                } else {
                    alert("<%=strXAxisAlert%>");
                }
                return;
            }

            if(!isYAxisChecked) {
                if(chrtType == 'PieChart' || chrtType == 'LineChart') {
                    alert("<%=strChartDataAlert%>");
                } else {
                    alert("<%=strYAxisAlert%>");
                }
                return;
            }

            objForm.target = "pagehidden";
            objForm.action = "emxChartOptionsProcess.jsp";
            objForm.submit();
        }

        function swapFormfield(f)
        {
            var xdiv = document.getElementById('dXAxis');
            var ydiv = document.getElementById('dYAxis');
            var yDatadiv = document.getElementById('dYAxisData');
            var xDatadiv = document.getElementById('dXAxisData');
            var labelDirrow = document.getElementById('labeldirectionrow');

            switch(f)
            {
                case "PieChart" :
                    xdiv.innerHTML = "<%=strSliceLabels%>";
                    ydiv.innerHTML = "<%=strChartData%>";
                    //XSSOK
                    yDatadiv.innerHTML = "<%=chartDataHTML%>";
                    //XSSOK
                    xDatadiv.innerHTML = "<%=otherXAxisOptionsHTML%>";
                    labelDirrow.style.display = 'none';
                    break;
                case "LineChart" :
                case "DateLineChart" :
                    xdiv.innerHTML = "<%=strXAxis%>";
                    ydiv.innerHTML = "<%=strChartData%>";
                  	//XSSOK
                    yDatadiv.innerHTML = "<%=yAXisHTML%>";
                    //XSSOK
                    xDatadiv.innerHTML = "<%=lineChartXAxisOptionsHTML%>";
                    labelDirrow.style.display = '';
                    break;
                default :
                    xdiv.innerHTML = "<%=strXAxis%>";
                    ydiv.innerHTML = "<%=strYAxis%>";
                  	//XSSOK
                    yDatadiv.innerHTML = "<%=yAXisHTML%>";
                    //XSSOK
                    xDatadiv.innerHTML = "<%=otherXAxisOptionsHTML%>";
                    labelDirrow.style.display = '';
                    break;
            }
        }
    </script>
    <%@include file = "emxUIConstantsInclude.inc"%>
    <%@include file = "../emxStyleDefaultInclude.inc"%>
    <%@include file = "../emxStyleFormInclude.inc"%>
</head>

<body>

    <form name="TableCalculationOptionsForm" method="post">
        <input type="hidden" name="timeStamp" value="<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>">
        <table class="form">
            <tr>
                <td width="150" class="labelRequired"><%=strChartType%></td>
                <td class="inputField">
                    <select name="chartType" onChange="swapFormfield(this.options[this.selectedIndex].value)">
                        <option value="BarChart"><%=strBarChart%></option>
                        <option value="StackBarChart"><%=strStackBarChart%></option>
                        <option value="PieChart"><%=strPieChart%></option>
                        <option value="LineChart"><%=strLineChart%></option>
                        <!--<option value="DateLineChart"><%=strDateLineChart%></option>-->
                    </select>
                </td>
            </tr>

            <tr id="labeldirectionrow">
                <td width="150" class="label"><div id="dlabelDir"><%=strAxisLabels%></div></td>
                <td class="inputField">
                    <div id="dlabelDirVal">
                    <table>
                        <tr><td><input type="radio" name="labelDirection" value="Horizontal" /></td><td><%=strHorizontal%></td></tr>
                        <tr><td><input type="radio" name="labelDirection" value="Vertical" checked /></td><td><%=strVertical%></td></tr>
                    </table>
                    </div>
                </td>
            </tr>

            <tr>
                <td width="150" class="label"><%=strRenderOptions%></td>
                <td class="inputField">
                    <table>
                        <tr><td><input type="checkbox" name="draw3D" value="true" /></td><td><%=str3D%></td></tr>
                    </table>
                </td>
            </tr>

            <tr>
                <td width="150" class="labelRequired">
                    <div id="dXAxis"><%=strXAxis%></div>
                </td>
                <td class="inputField">
                    <div id="dXAxisData">
                        <select size="5" name="XAxis">
                            <%=xAxisoptionsList.toString()%>
                        </select>
                    </div>
                </td>
            </tr>

            <tr>
                <td width="150" class="labelRequired">
                    <div id="dYAxis"><%=strYAxis%></div>
                </td>
                <td class="inputField">
                    <div id="dYAxisData">
                        <select size='5' multiple name="YAxis">
                        <%=yAxisoptionsList.toString()%>
                        </select><br/><%=strHint%>
                    </div>
                </td>
            </tr>
        </table>

    </form>
</body>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</html>

