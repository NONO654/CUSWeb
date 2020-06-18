<%-- emxEngrAssociateAffectedItemECOConnectECO.jsp - Processing page to connect selected ECO with ECR during ECR-ECO association
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>


<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@ page import="com.matrixone.apps.engineering.ECO,com.matrixone.apps.engineering.ECR"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.jsystem.util.StringUtils"%>

<%


	// Context ECR/ECO
	String strSourceECRECOId  = emxGetParameter(request,"objectId");

	String fromPartWhereUsed  = emxGetParameter(request, "fromPartWhereUsed");
    if (fromPartWhereUsed == null || "null".equals(fromPartWhereUsed) || "".equals(fromPartWhereUsed)) {
    	fromPartWhereUsed = "false";
    }
    
	// Identify the action AssignTo or AddTo or MoveTo
	String strMode = (String)session.getAttribute("strMode");	
	session.removeAttribute("strMode");	
	
	// Selected ECO	
	String strSelectedTargetECOId = null;
	
	String[] selectedECOIds = emxGetParameterValues(request, "emxTableRowId");
		
	if (selectedECOIds.length > 0) {
		StringTokenizer strTokens = new StringTokenizer(selectedECOIds[0],"|");
		if ( strTokens.hasMoreTokens()) {
			strSelectedTargetECOId = strTokens.nextToken();
		}
	}	

	String [] affectedItemsList = ( String [] ) session.getAttribute("programMapforPart");
	session.removeAttribute("programMapforPart");

	if ("AddToECOExisting".equals(strMode) || "AddToECO".equals(strMode) || "AddToPUEECOExisting".equals(strMode))
			{
		ECO ecoTarget = new ECO(strSelectedTargetECOId);
		ecoTarget.connectAffectedItems(context, affectedItemsList);
			}
	else if ("MoveToECOExisting".equals(strMode) || "MoveToECO".equals(strMode))
			{
		ECO ecoSource = new ECO(strSourceECRECOId);
		ecoSource.moveAffectedItems(context, strSelectedTargetECOId, affectedItemsList);
			}
	else if ("AssignToECOExisting".equals(strMode) || "AssignToECO".equals(strMode))
                                        {
		ECR ecrSource = new ECR(strSourceECRECOId);
		ecrSource.assignAffectedItems(context, strSelectedTargetECOId, affectedItemsList, true);
                                        }
	else if("MoveToCRExisting".equals(strMode) || "MoveToCRNew".equals(strMode)) {
		
		ContextUtil.startTransaction(context, true);
				
		HashMap paramMap = new HashMap();       
        paramMap.put("sourceECRId", strSourceECRECOId);
        paramMap.put("newObjectId", strSelectedTargetECOId);
        paramMap.put("strMode", strMode);
        paramMap.put("strSelectedAffectedItem", session.getAttribute("strSelectedItemIds"));              
        String[] methodargs = JPO.packArgs(paramMap);
        int retMap =(int)JPO.invoke(context, "emxPart", null, "addAffectedItemstoCR", methodargs);
        		        
		ContextUtil.commitTransaction(context);
	}	
%>
									
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<html>
<head>
</head>
<body>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">
//XSSOK
if ("<%=XSSUtil.encodeForJavaScript(context,fromPartWhereUsed)%>" == "true") {
    getTopWindow().getWindowOpener().parent.emxEditableTable.refreshStructureWithOutSort();   
} else {
	//XSSOK
	 var strid="<%=XSSUtil.encodeForJavaScript(context,strSourceECRECOId)%>";
	 <%	 
	 if ("MoveToECOExisting".equals(strMode) || "MoveToCRExisting".equals(strMode))
		{
	 %>
	 	getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href; 
	 <%
		}else
	 {
	 %>
	    if(!strid){
	    getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href; 
	    }else{
	     parent.getTopWindow().getWindowOpener().emxEditableTable.refreshStructureWithOutSort();
	    }
	 <%
	 }
	 %>
}
getTopWindow().closeWindow();
  
</script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>

