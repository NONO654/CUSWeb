<%--  emxFreezePaneCalculationOptionsProcess.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFreezePaneCalculationOptionsProcess.jsp.rca 1.4 Mon Dec 15 03:06:42 2008 ds-ukumar Experimental $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@ page import="com.matrixone.jdom.*,
                 com.matrixone.jdom.output.*"%>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<script language="javascript" src="/ematrix/common/scripts/emxUICore.js"></script>
<%
String timeStamp = emxGetParameter(request, "timeStamp");
//response.setContentType("text/javascript; charset=" + response.getCharacterEncoding());
String calcSum = "false";
String calcAverage = "false";
String calcMaximum = "false";
String calcMinimum = "false";
String calcMedian = "false";
String calcStandardDeviation = "false";
String calcCustom = "false";
boolean hasCalculations = false;

String stringResFileId="emxFrameworkStringResource";
String strLanguage = request.getHeader("Accept-Language");

StringList selFunctionList = new StringList();
StringList selColumnsList = new StringList();

try {
	
	String[] selcolumns = emxGetParameterValues(request, "selcolumns");
	if(selcolumns != null) {
		for(int i=0; i < selcolumns.length; i++){
			selColumnsList.add(selcolumns[i]);
		}
	}	
	
	String[] selFunction = emxGetParameterValues(request, "selFunction");
	if(selFunction != null) {
		for(int i=0; i < selFunction.length; i++){
		    selFunctionList.add(selFunction[i]);
		}
	}
	
	if(selFunction != null) {
		for(int count=0; count < selFunction.length; count++){
			if("SUM".equalsIgnoreCase(selFunction[count])) {
				calcSum = "true";
				hasCalculations = true;
			} else if("AVE".equalsIgnoreCase(selFunction[count])) {
				calcAverage = "true";
				hasCalculations = true;
			} else if("MAX".equalsIgnoreCase(selFunction[count])) {
				calcMaximum = "true";
				hasCalculations = true;
			} else if("MIN".equalsIgnoreCase(selFunction[count])) {
				calcMinimum = "true";
				hasCalculations = true;
			} else if("MEDIAN".equalsIgnoreCase(selFunction[count])) {
				calcMedian = "true";
				hasCalculations = true;
			} else if("STDDEV".equalsIgnoreCase(selFunction[count])) {
				calcStandardDeviation = "true";
				hasCalculations = true;
			}
			//else if("Custom".equalsIgnoreCase(selFunction[count])) {
			//    calcCustom = "true";
			//	hasCalculations = true;
			//}			
		}
	}

	if(selColumnsList.size() <= 0) {
		hasCalculations = false;
	}

 	HashMap tableData = indentedTableBean.getTableData(timeStamp);
    MapList columns = indentedTableBean.getColumns(tableData);
	HashMap tableControlMap = indentedTableBean.getControlMap(tableData);
    tableControlMap.put("HasCalculations", hasCalculations ? Boolean.TRUE : Boolean.FALSE);
	tableControlMap.put("HasSum", "true".equalsIgnoreCase(calcSum)? Boolean.TRUE : Boolean.FALSE);
	tableControlMap.put("HasAverage", "true".equalsIgnoreCase(calcAverage) ? Boolean.TRUE : Boolean.FALSE);
	tableControlMap.put("HasMaximum", "true".equalsIgnoreCase(calcMaximum) ? Boolean.TRUE : Boolean.FALSE);
	tableControlMap.put("HasMinimum", "true".equalsIgnoreCase(calcMinimum) ? Boolean.TRUE : Boolean.FALSE);
	tableControlMap.put("HasMedian", "true".equalsIgnoreCase(calcMedian) ? Boolean.TRUE : Boolean.FALSE);
	tableControlMap.put("HasStandardDeviation", "true".equalsIgnoreCase(calcStandardDeviation)? Boolean.TRUE : Boolean.FALSE);
	//tableControlMap.put("HasCustom", "true".equalsIgnoreCase(calcCustom)? Boolean.TRUE : Boolean.FALSE);
%>
<script type="text/javascript" language="JavaScript" src="scripts/emxUICore.js"></script>
<script type="text/javascript"><%
    int noOfColumns = columns.size();

	HashMap columnMap = new HashMap();
	for (int j = 0; j < noOfColumns; j++)
	{
		columnMap = (HashMap)columns.get(j);
		String columnName = indentedTableBean.getName(columnMap);
		HashMap tempMap = indentedTableBean.getSettings(columnMap);
		if(selColumnsList.contains(columnName))
		{
			tempMap.put("Calculate Sum", calcSum);
			tempMap.put("Calculate Average", calcAverage);
			tempMap.put("Calculate Maximum", calcMaximum);
			tempMap.put("Calculate Minimum",calcMinimum);
			tempMap.put("Calculate Median", calcMedian);
			tempMap.put("Calculate Standard Deviation", calcStandardDeviation);
			//tempMap.put("Calculate Custom", calcCustom);
			tempMap.put("HasCalculations", "true");
			for(int k = 0; k < selFunctionList.size(); k++){
			    String strCalcFunction = (String)selFunctionList.get(k);
			    String strCalcName = "";
		        String strCalcLabel = "";
			    if("SUM".equalsIgnoreCase(strCalcFunction)) {
		            strCalcName = indentedTableBean.getSetting(columnMap,"Calculate Sum Label");
                    if("".equals(strCalcName)){
                        strCalcName = "emxFramework.TableCalculation.Sum";
                    }
				} else if("AVE".equalsIgnoreCase(strCalcFunction)) {
				    strCalcName = indentedTableBean.getSetting(columnMap,"Calculate Average Label");
                    if("".equals(strCalcName)){
                        strCalcName = "emxFramework.TableCalculation.Average";
                    }
				} else if("MAX".equalsIgnoreCase(strCalcFunction)) {
				    strCalcName = indentedTableBean.getSetting(columnMap,"Calculate Maximum Label");
                    if("".equals(strCalcName)){
                        strCalcName = "emxFramework.TableCalculation.Maximum";
                    }
				} else if("MIN".equalsIgnoreCase(strCalcFunction)) {
				    strCalcName = indentedTableBean.getSetting(columnMap,"Calculate Minimum Label");
                    if("".equals(strCalcName)){
                        strCalcName = "emxFramework.TableCalculation.Minimum";
                    }
				} else if("MEDIAN".equalsIgnoreCase(strCalcFunction)) {
				    strCalcName = indentedTableBean.getSetting(columnMap,"Calculate Median Label");
                    if("".equals(strCalcName)){
                        strCalcName = "emxFramework.TableCalculation.Median";
                    }
				} else if("STDDEV".equalsIgnoreCase(strCalcFunction)) {
				    strCalcName = indentedTableBean.getSetting(columnMap,"Calculate Standard Deviation Label");
                    if("".equals(strCalcName)){
                        strCalcName = "emxFramework.TableCalculation.StandardDeviation";
                    }
				}
			    strCalcLabel = EnoviaResourceBundle.getProperty(context, stringResFileId, new Locale(strLanguage), strCalcName);
			    %>getTopWindow().getWindowOpener().addCalculationExpr("<%=columnName%>","<xss:encodeForJavaScript><%=strCalcFunction%></xss:encodeForJavaScript>","emx<%=strCalcName%>","<%=strCalcLabel%>");<%
			}
			
			if("false".equals(calcSum)){
			    String strCalcName = indentedTableBean.getSetting(columnMap,"Calculate Sum Label");
                if("".equals(strCalcName)){
                    strCalcName = "emxFramework.TableCalculation.Sum";
                }
                String strCalcLabel =  EnoviaResourceBundle.getProperty(context, stringResFileId, new Locale(strLanguage), strCalcName);
			    %>getTopWindow().getWindowOpener().removeCalculationRow("<%=strCalcLabel%>");<%
			}
			if("false".equals(calcAverage)){
			    String strCalcName = indentedTableBean.getSetting(columnMap,"Calculate Average Label");
                if("".equals(strCalcName)){
                    strCalcName = "emxFramework.TableCalculation.Average";
                }
			    String strCalcLabel =  EnoviaResourceBundle.getProperty(context, stringResFileId, new Locale(strLanguage), strCalcName);
			    %>getTopWindow().getWindowOpener().removeCalculationRow("<%=strCalcLabel%>");<%
			}
			if("false".equals(calcMaximum)){
			    String strCalcName = indentedTableBean.getSetting(columnMap,"Calculate Sum Maximum");
                if("".equals(strCalcName)){
                    strCalcName = "emxFramework.TableCalculation.Maximum";
                }
			    String strCalcLabel =  EnoviaResourceBundle.getProperty(context, stringResFileId, new Locale(strLanguage), strCalcName);
			    %>getTopWindow().getWindowOpener().removeCalculationRow("<%=strCalcLabel%>");<%
			}
			if("false".equals(calcMinimum)){
			    String strCalcName = indentedTableBean.getSetting(columnMap,"Calculate Minimum Label");
                if("".equals(strCalcName)){
                    strCalcName = "emxFramework.TableCalculation.Minimum";
                }
			    String strCalcLabel =  EnoviaResourceBundle.getProperty(context, stringResFileId, new Locale(strLanguage), strCalcName);
			    %>getTopWindow().getWindowOpener().removeCalculationRow("<%=strCalcLabel%>");<%
			}
			if("false".equals(calcMedian)){
			    String strCalcName = indentedTableBean.getSetting(columnMap,"Calculate Median Label");
                if("".equals(strCalcName)){
                    strCalcName = "emxFramework.TableCalculation.Median";
                }
			    String strCalcLabel =  EnoviaResourceBundle.getProperty(context, stringResFileId, new Locale(strLanguage), strCalcName);
			    %>getTopWindow().getWindowOpener().removeCalculationRow("<%=strCalcLabel%>");<%
			}
			if("false".equals(calcStandardDeviation)){
			    String strCalcName = indentedTableBean.getSetting(columnMap,"Calculate Standard Deviation Label");
                if("".equals(strCalcName)){
                    strCalcName = "emxFramework.TableCalculation.StandardDeviation";
                }
			    String strCalcLabel =  EnoviaResourceBundle.getProperty(context, stringResFileId, new Locale(strLanguage), strCalcName);
			    %>getTopWindow().getWindowOpener().removeCalculationRow("<%=strCalcLabel%>");<%
			}

		} else {
			tempMap.put("Calculate Sum", "false");
			tempMap.put("Calculate Average", "false");
			tempMap.put("Calculate Maximum", "false");
			tempMap.put("Calculate Minimum","false");
			tempMap.put("Calculate Median", "false");
			tempMap.put("Calculate Standard Deviation", "false");
			//tempMap.put("Calculate Custom", "false");
			tempMap.put("HasCalculations", "false");
			%>getTopWindow().getWindowOpener().clearCalculatedCalc("<%=columnName%>");<%
		}
		indentedTableBean.setSettings(columnMap, tempMap);
	}	
} catch (Exception ex) {
    if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        emxNavErrorObject.addMessage("emxFreezePaneCalculations:" + ex.toString().trim());
}%>
</script>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
<script type="text/javascript">
   getTopWindow().getWindowOpener().parseArithmethicExpr();
   getTopWindow().getWindowOpener().removeBlankCalcRows();
   getTopWindow().getWindowOpener().rebuildView();
   //getTopWindow().getWindowOpener().parent.closeWindow();
   getTopWindow().closeWindow();
</script>
