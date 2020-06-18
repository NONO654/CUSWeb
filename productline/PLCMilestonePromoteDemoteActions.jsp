<%--  PLCMilestonePromoteDemoteActions.jsp  - 
Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
--%>


<%@page import="java.util.Enumeration"%>
<%@page import="com.matrixone.apps.productline.MilestoneTrack"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<html>
	<head>
		<title>
		</title>

		<%@include file = "../components/emxComponentsDesignTopInclude.inc"%>
		<%@include file = "../components/emxComponentsVisiblePageInclude.inc"%>
		<%@include file = "../common/emxTreeUtilInclude.inc"%>
		<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

		<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
	</head>

	<body>
		<%
		
		DomainObject decisionObj = DomainObject.newInstance(context);
		DomainObject toObj = DomainObject.newInstance(context);
		String strProductID = emxGetParameter(request,"objectId");
		String strMode = emxGetParameter(request,"mode");
		
		String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
		
		if(null !=selectedItems && selectedItems.length != 0){
		for (int i=0; i < selectedItems.length ;i++){
			String strMilestoneTrack = selectedItems[i];

			//if this is coming from the Full Text Search, have to parse out |objectId|relId|
			StringTokenizer strTokens1 = new StringTokenizer(selectedItems[i],"|");
			if(strTokens1.hasMoreTokens()){
				strMilestoneTrack = strTokens1.nextToken();
			}
			MilestoneTrack mileTrack = new MilestoneTrack();
			
			if("promote".equals(strMode)){
				mileTrack.publishMilestoneTrack(context,strProductID,strMilestoneTrack);
			}
		}
		}else{
			 String errorMsg = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProductLine.Milestone.TrackNotSelected",request.getHeader("Accept-Language"));
		
		%>
		<script language="JavaScript">
	       alert("<xss:encodeForJavaScript><%=errorMsg%></xss:encodeForJavaScript>");
		</script>
		<% 
		}
		%>

		<%@include file = "../components/emxComponentsDesignBottomInclude.inc"%>
	</body>
	
	<script language="Javascript" >
  		//parent.document.location.href = parent.document.location.href;
  		getTopWindow().window.closeWindow();
  	</script>
</html>
