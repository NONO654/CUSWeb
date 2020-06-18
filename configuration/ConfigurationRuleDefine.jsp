<%--
  ConfigurationRulesCommand.jsp
  
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of 
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="com.dassault_systemes.enovia.configuration.modeler.ConfigurationGovernanceCommon"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>

<%
  out.clear();
  String urlStr = "";
  boolean bIsError = false;
  try
  {
		String objectId = emxGetParameter(request,"objectId");
		String parentOID = null;//emxGetParameter(request,"parentOID");
		String strProductID = emxGetParameter(request,"parentOID");
		DomainObject domProduct = new DomainObject(strProductID);
		String strProductPID = domProduct.getInfo(context,"physicalid");
		String sPortalCommandName = emxGetParameter(request,"portalCmdName");
		String sExpressionType = emxGetParameter(request,"ExpressionType");
		
		
		String[] idsArray = new String[1]; 
		StringList selList = new StringList();
		String physicalId ="";
		selList.add(DomainObject.SELECT_ID);
        selList.add("physicalid");
		
		StringList oidList = FrameworkUtil.split(objectId, "&");
        idsArray[0] = (String)oidList.get(0);
        
		if(parentOID == null) {
			DomainObject domCFR = new DomainObject(idsArray[0]);
			parentOID = (String)domCFR.getInfo(context, "to[" + ConfigurationConstants.RELATIONSHIP_CONFIGURATION_RULE + "].from.id");
		}
		
		if(strProductID == null)
		{
			domProduct = new DomainObject(parentOID);
			strProductPID = domProduct.getInfo(context,"physicalid");
		}
		
        MapList physicalIdRule = DomainObject.getInfo(context, idsArray, selList);
        if(physicalIdRule != null && physicalIdRule.size() > 0){
           for(int n=0; n < physicalIdRule.size(); n++){
               Map cxtMap = (Map)physicalIdRule.get(n);
                physicalId = (String)cxtMap.get("physicalid");
           }
        }
		
       idsArray[0] = parentOID;
        String physicalIdModel ="";
        MapList physicalIdML = DomainObject.getInfo(context, idsArray, selList);
        if(physicalIdML != null && physicalIdML.size() > 0){
           for(int n=0; n < physicalIdML.size(); n++){
               Map cxtMap = (Map)physicalIdML.get(n);
               physicalIdModel = (String)cxtMap.get("physicalid");
           }
        }
        
			DomainObject domModel = new DomainObject(physicalIdModel);
			String modelname = domModel.getInfo(context,ConfigurationConstants.SELECT_NAME);
			String productname = domProduct.getInfo(context,ConfigurationConstants.SELECT_NAME);
			String productrev = domProduct.getInfo(context,ConfigurationConstants.SELECT_REVISION);

			boolean isMobileMode = UINavigatorUtil.isMobile(context);
				boolean isRuleFrozen = ConfigurationUtil.isFrozenState(context,physicalId);//is modeler checking it already?
				boolean isProductFrozen = ConfigurationUtil.isFrozenState(context,strProductPID);//is modeler checking it already?
			boolean isFTRUser = ConfigurationUtil.isFTRUser(context); //checks for ENO_FTR_TP License
			String editLink="true";
			if(isMobileMode||isRuleFrozen||isProductFrozen ||!isFTRUser){
				  editLink="false";
			}
			
			if(sExpressionType!=null && ConfigurationConstants.RANGE_VALUE_EXPRESSION_TYPE_BOOLEAN.equalsIgnoreCase(sExpressionType)){
				urlStr = "../webapps/CfgRules/ExpressionRuleEdition.html?objectId=" + physicalId + "&modelPID=" + physicalIdModel + "&productPID=" +strProductPID +"&editLink=" +editLink;
			}else{
			urlStr = "../webapps/CfgRules/MatrixRulesEdition.html?objectId=" + physicalId + "&modelPID=" + physicalIdModel + "&productPID=" +strProductPID +"&editLink=" +editLink;
			}
  }
  catch(Exception e)
  {
    bIsError=true;
    session.putValue("error.message", e.getMessage());
  }// End of main Try-catck block
%>
<html>
<head>
<script>
	var rootNode;

	function generateURL()
	 {
		 if(rootNode)
		 {
			 getTopWindow().window.close();
		 }
		 else
		 {   
			  var url = '<%=urlStr%>';
			  var frame = document.getElementById("MatrixRules");
			  frame.setAttribute("src",url);
		 }
	 }
</script>
</head>
<body onLoad = "generateURL();" style="overflow:hidden;">
<iframe id="MatrixRules"  style="width:100%;height:100%;border:0"></iframe>
</body>
</html>  
