<%--
  PLCProductRoadmapTimelineReportPreProcess.jsp
  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>

<%--Common Include File --%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties" %>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%
  boolean bIsError=false;
  try
  {
	  String strTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
	  StringList lstProductChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ProductLineConstants.TYPE_PRODUCTS);
	  String strLanguage      = context.getSession().getLanguage();
	  String strAlertMessage  = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.ProductRoadMapTimelineReport", strLanguage);
	  boolean isModelSelected = false;
	  String strMode = emxGetParameter(request, "mode");
	  String timeStamp = emxGetParameter(request, "timeStamp");
	  String strRowIds = "";
	  String strTabRowIds = "";
	  for(int i = 0; i < strTableRowIds.length; i++)
	  {
		  String[] strTableIds = strTableRowIds[i].split("\\|");
		  String  strObjectID  = strTableIds[strTableIds.length - 3];
		  DomainObject domObject = DomainObject.newInstance(context, strObjectID);
		  String strType = domObject.getInfo(context, DomainConstants.SELECT_TYPE);
		  if(!lstProductChildTypes.contains(strType))
		  {
			  isModelSelected = true;
			  break;
		  }
		  strRowIds += strObjectID + ",";
		  strTabRowIds += "&emxTableRowId=" + XSSUtil.encodeForURL(context, strTableRowIds[i]);
	  }
	  
	  if(isModelSelected)
	  {
%>   	 
 	       <Script language="javascript" type="text/javaScript">
 	       alert("<%=strAlertMessage%>");
 	       getTopWindow().closeWindow();
 	       </Script>  	  
<%		  
	  }
	  else
	  {
		  if("ProductRoadmapReport".equals(strMode))
		  {
%>
			 <script language="javascript" type="text/javaScript">
			 var url= "../common/emxIndentedTable.jsp?program=emxProduct:getProductsForRoadmap&sortColumnName=Name&table=PLCProductRoadmapList&header=emxProduct.Heading.RoadmapReport&selection=multiple&Style=PrinterFriendly&HelpMarker=emxhelproadmapreport&suiteKey=ProductLine&StringResourceFileId=emxProductLineStringResource&SuiteDirectory=productline&timeStamp=<%=XSSUtil.encodeForURL(context, timeStamp)%>&RowIds=<%=XSSUtil.encodeForURL(context, strRowIds)%>";
			 showModalDialog(url,575,575,"true","Large");
			 </script>		  
<%			  
		  }
		  else if("TimelineReport".equals(strMode))
		  {
%>
			<script language="javascript" type="text/javaScript">
			var url= "../common/emxTimeline.jsp?program=emxPLCTimeline:getRoadmap&filterCommand=PLCFilterTimelineCommand&header=emxProduct.Header.ProductTimeline&<%=strTabRowIds%>&suiteKey=ProductLine";
			showModalDialog(url,575,575,"true","Large");
			</script>		  
<%				  
		  }
	  }
  }
  catch(Exception e)
  {
	  bIsError=true;
	  session.putValue("error.message", e.getMessage());	  
  }
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
