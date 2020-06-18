<%--  emxChartInclude.jsp
  Displays the Chart.
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxChartInclude.jsp.rca 1.16 Wed Oct 22 15:48:31 2008 przemek Experimental przemek $";
--%>


<%@ page import ="java.io.*,com.matrixone.servlet.*,com.matrixone.apps.domain.util.FrameworkUtil,com.matrixone.apps.framework.ui.*,java.util.*,java.awt.Font,java.awt.GraphicsEnvironment" %>
<jsp:useBean id="chartBean" class="com.matrixone.apps.framework.ui.UIChart" scope="request"/>
<%
String tempFilePath = "";
try {
    /*****************************************************************************/
        String chrtType = chartBean.getChartType();
        String chrtdelimiter = chartBean.getDelimiter();

        String labels = "";
        String strXAxisTitle = "";
        HashMap xAxisMap = chartBean.getXAxis();
        ArrayList xTitleList = (ArrayList) xAxisMap.get("Titles");
        ArrayList xValueList = (ArrayList) xAxisMap.get("Values");

        for(int i = 0; i < xValueList.size(); i++){
            strXAxisTitle = (String) xTitleList.get(i);
            labels = (String) xValueList.get(i);
        }
        //create the chart
        javachart.servlet.Bean chart = null;
        if(chrtType.equalsIgnoreCase("BarChart"))
        {
            chart = new javachart.servlet.columnApp();
            chart.setProperty("xAxisLabels", labels);
        }
        else if(chrtType.equalsIgnoreCase("PieChart"))
        {
            chart = new javachart.servlet.pieApp();
            chart.setProperty("dataset0Labels", labels);
            chart.setProperty("antialiasOn", "true");
            chart.setProperty("textLabelsOn", "true");

            if(!chartBean.getShowPercentage())
                chart.setProperty("percentLabelsOff", "false");

            if(chartBean.getShowValues())
                chart.setProperty("valueLabelsOn", "true");
        }
        else if(chrtType.equalsIgnoreCase("LineChart"))
        {
            chart = new javachart.servlet.lineApp();
            chart.setProperty("dataset0xValues", labels);
            chart.setProperty("antialiasOn", "true");
        }
        else if(chrtType.equalsIgnoreCase("LabelLineChart"))
        {
            chart = new javachart.servlet.labelLineApp();
            chart.setProperty("xAxisLabels", labels);
            chart.setProperty("antialiasOn", "true");
        }
        else if(chrtType.equalsIgnoreCase("StackBarChart"))
        {
            chart = new javachart.servlet.stackColumnApp();
            chart.setProperty("xAxisLabels", labels);
        }

        chart.setProperty("delimiter", chrtdelimiter);

        String strTitleFontName = "Monospaced" + chrtdelimiter + "25" + chrtdelimiter + "0";
        String strValueFontName = "Monospaced" + chrtdelimiter + "10" + chrtdelimiter + "0";
        String strLegendFontName = "Monospaced" + chrtdelimiter + "9" + chrtdelimiter + "1";

        String strLavelFontName = "Monospaced";
        String axisLabelFont = strLavelFontName + chrtdelimiter + "10" + chrtdelimiter + "0";
        String axisTitleFont = strLavelFontName + chrtdelimiter + "10" + chrtdelimiter + "0";

        HashMap yAxisMap = chartBean.getYAxis();
        ArrayList yTitleList = (ArrayList) yAxisMap.get("Titles");
        ArrayList yValueList = (ArrayList) yAxisMap.get("Values");
        for(int i = 0; i < yValueList.size(); i++){
            chart.setProperty("dataset" + i + "yValues", (String) yValueList.get(i));
            chart.setProperty("dataset" + i + "Name", (String) yTitleList.get(i));
        }
        chart.setProperty("imageType", "j_png");
        chart.setProperty("useCache", "false");
        chart.setProperty("byteStream", "true");
        chart.setProperty("width", "567");
        chart.setProperty("height", "556");
        if(chartBean.get3D()) {
            chart.setProperty("3D", "true");
        }

        chart.setProperty("defaultFont", strValueFontName);
        chart.setProperty("plotAreaTop", "0.80");
        chart.setProperty("plotAreaBottom", "0.20");
        chart.setProperty("plotAreaLeft", "0.12");
        chart.setProperty("plotAreaRight", "0.95");
        chart.setProperty("plotAreaColor", "eeeeee");
        chart.setProperty("dwellUseXValue", "false");
        chart.setProperty("labelsOn", "true");


        if(!chrtType.equals("PieChart")) {
            chart.setProperty("xAxisTitle", strXAxisTitle);
            chart.setProperty("yAxisTitle", chartBean.getYAxisTitle());
            chart.setProperty("legendOn", "true");
            chart.setProperty("legendColor", "transparent");
            chart.setProperty("legendLabelFont", strLegendFontName);
            chart.setProperty("legendHorizontal", "true");
            chart.setProperty("iconGap", "0.005");
            chart.setProperty("iconHeight", "0.03");
            chart.setProperty("iconWidth", "0.05");
            chart.setProperty("legendllX", "0.0");
            chart.setProperty("legendllY", "0.85");

            if("Vertical".equalsIgnoreCase(chartBean.getLabelDirection())) {
                chart.setProperty("xAxisLabelAngle", "90");
            }

            chart.setProperty("xAxisLabelFont", axisLabelFont);
            chart.setProperty("yAxisLabelFont", axisLabelFont);
            chart.setProperty("xAxisTitleFont", axisTitleFont);
            chart.setProperty("yAxisTitleFont", axisTitleFont);
        }


        chart.setProperty("titleString", chartBean.getChartTitle());
        chart.setProperty("titleFont", strTitleFontName);
        chart.setProperty("titleColor", "990000");
        String fileName = "chart" + UIComponent.getTimeStamp() + ".png";
        OutputStream out2 = Framework.createTemporaryFile(session,fileName);
        out2.write(chart.getImageBytes());
        out2.flush();
        out2.close();
        tempFilePath = Framework.getTemporaryFilePath(response,session,fileName,true);
} catch (Exception ex) {
    System.out.println("exception" + ex);
}
%>

<img src="<%=tempFilePath%>"></img>
