<%--  PLCParameterUtil.jsp


  Copyright (c) 2005-2018 Dassault Systemes.  All Rights Reserved.

  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

 --%>
 <%--
 	@quickreview KIE1 ZUD 16:01:22 : HL Parameter under Test Execution.
 	@quickreview KIE1	  16:08:24 : IR-459152-3DEXPERIENCER2017x:R419-FUN055836:NLS: In Parameters under Test Executions, high chart labels are not getting translated.
 	@quickreview KIE1 ZUD 17:10:05 : IR-439272-3DEXPERIENCER2018x: R419-FUN055836: No Title on graph chart or label on pop up window is displayed on High Chart graph invoked from Parameter
 --%>



<%@page import="java.util.List"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<link rel="shortcut icon" href="../favicon.ico" type="image/x-icon" />
<link rel="stylesheet" type="text/css" href="../common/styles/emxDashboardCommon.css">
<script type="text/javascript" src="../plugins/libs/jquery/2.0.3/jquery.js"></script> 
<script type="text/javascript" src="../plugins/highchart/3.0.2/js/highcharts.js"></script>
<script type="text/javascript" src="../plugins/highchart/3.0.2/js/highcharts-more.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" src="../productline/PLCParameterUtil.js" type="text/javascript"></script>
    
<%
	try{
		// reading propertied file
		//  ++KIE1 IR-459152-3DEXPERIENCER2017x:
		String variableName 			= EnoviaResourceBundle.getProperty(context, "emxProductLineStringResource", context.getLocale(), "emxProduct.HighChart.ParameterValue");
	    String upperBound 				= EnoviaResourceBundle.getProperty(context, "emxProductLineStringResource", context.getLocale(), "emxProduct.HighChart.upperBound");
	    String lowerBound 				= EnoviaResourceBundle.getProperty(context, "emxProductLineStringResource", context.getLocale(), "emxProduct.HighChart.lowerBound");
	    String target 					= EnoviaResourceBundle.getProperty(context, "emxProductLineStringResource", context.getLocale(), "emxProduct.HighChart.target");
    	String propertiesVariables		= variableName+","+upperBound+","+lowerBound+","+target;
				
		String strMode 					= emxGetParameter(request, "Mode");
		String objectId 				= emxGetParameter(request, "objectId");
		String parentOID 				= emxGetParameter(request, "parentOID");
		String relId 					= emxGetParameter(request, "relId");
		DomainObject parmObj 			= DomainObject.newInstance(context, objectId);
		String categories 		= (String) JPO.invoke(context,
				            "emxPLCCommonBase", null, "getTestExecutionName", JPO.packArgs(parentOID+":"+objectId),
				            String.class );
		//parameterContent 				= "["+parameterContent+"]"; 
		MapList parametervalues 		= (MapList) JPO.invoke(context,
				            "emxPLCCommonBase", null, "getParameterValues", JPO.packArgs(parentOID+":"+objectId),
				            MapList.class );
		String unit 					= parmObj.getAttributeValue(context, "PlmParamDisplayUnit");
  	    StringList aggregatedParameter  = (StringList)parametervalues.get(0);
		StringList targetParameter 		= (StringList)parametervalues.get(1);
		StringList maxParameter 		= (StringList)parametervalues.get(2);
		StringList minParameter 		= (StringList)parametervalues.get(3);
		String paramName 				= parmObj.getInfo(context, DomainConstants.SELECT_NAME);
		String paramTitle 				= parmObj.getAttributeValue(context, "Title");
		
		//JSONArray categories 			= new JSONArray(parameterContent);
	
		if(strMode.equals("getHighChart"))
		{
			%>
			<div id="content" >
			<div class="chart chartBorder"	id="divChartStatus"  style="height:100%;width:100%;cursor:pointer;"></div>
						
		  <!--   <div id="divPageFoot" style="display:block;resize:both;bottom:0px;position:absolute">
				<div id="divDialogButtons">
					<table>
						<tr>
							<td class=nbRequirements align="left"></td>
							<td class='buttons' align="right">
								<table>
									<tbody>
										<tr>
											<td>
												<div id="cancelImage">
													<a onclick="closePanel()" href="javascript:void(0)">
													<img alt="Cancel" border="0" src="../requirements/images/buttonDialogCancel.gif">
													</a>
												</div>
											</td>
											<td>
												<div id='cancelText'>
													<a class='button' onclick="closeSlideinWindow(getTopWindow())" href="javascript:void(0)">Close</a>
												</div>
											</td>
										</tr>
									</tbody>
								</table>
							</td>
						</tr>
					</table>
				</div>	
			</div> -->
			</div>
			<script type="text/javascript">
				getHighChart(<%=categories%>,<%=aggregatedParameter%>,<%=targetParameter%>,<%=maxParameter%>,<%=minParameter%>,'<%=paramName +"||"+paramTitle%>','<%=unit%>','<%=propertiesVariables%>');
			</script>
			<title><%=paramName%></title>
	<%		
		}
	
	}catch(Exception e)
	{
		e.printStackTrace();
	}
%>
