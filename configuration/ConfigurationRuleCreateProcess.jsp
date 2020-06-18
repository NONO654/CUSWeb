<%--
  ConfigurationRuleCreatePreProcess.jsp
  
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of 
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@ page import = "java.util.Map" %>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script type="text/javascript" src="../webapps/AmdLoader/AmdLoader.js"></script>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>

<%
	try{
			String strContextObjId = (String)emxGetParameter(request, "objectId");
			String strRuleType = (String)emxGetParameter(request, "ruleType");
			String strOriginator = com.matrixone.apps.domain.util.PersonUtil.getFullName(context, context.getUser());
			String frameName = "FTRMatrixRulesCommand";
			String tableName = "FTRMatrixRuleListTable";
			
			if(strRuleType.equals("Boolean")){
				frameName = "FTRExpressionRulesCommand";
				tableName = "FTRExpressionRuleListTable";
			}
	        StringList oidList = FrameworkUtil.split(strContextObjId, "|");
		    String ObjId = (String)oidList.get(0);
		        
		    StringList selList = new StringList();
		    selList.add(DomainObject.SELECT_ID);
		    selList.add(DomainObject.SELECT_NAME);
	  	  	selList.add(DomainObject.SELECT_REVISION);
	        selList.add("to[" + ConfigurationConstants.RELATIONSHIP_PRODUCTS + "].from.physicalid");
		        
	        
	        DomainObject domProduct  = new DomainObject(ObjId);
	 		Map ProductMAP = domProduct.getInfo(context,selList);
			
	        String physicalId ="";
	        
	        if(ProductMAP != null && ProductMAP.size() > 0){
	 			physicalId = (String)ProductMAP.get("to[" + ConfigurationConstants.RELATIONSHIP_PRODUCTS + "].from.physicalid");
	  	        if (physicalId== null)
	  	           	physicalId = (String)ProductMAP.get("to[" + ConfigurationConstants.RELATIONSHIP_MAIN_PRODUCT + "].from.physicalid");
	 		}
	        
	        String Name = (String)ProductMAP.get("name");
	        String Revision = (String)ProductMAP.get("revision");

%>
<script language="javascript" type="text/javaScript">

				var contextObjId = encodeURIComponent('<%=physicalId%>');
				var productId = encodeURIComponent('<%=strContextObjId%>');
				var Name = encodeURIComponent('<%=Name%>');
				<%-- //var ModelName = encodeURIComponent('<%=ModelName%>'); --%>
				var Revision = encodeURIComponent('<%=Revision%>');
				var strOriginator = encodeURIComponent('<%=strOriginator%>');
				var FrameName = '<%=XSSUtil.encodeForJavaScript(context,frameName)%>';
				var ruleType = encodeURIComponent('<%=strRuleType%>');
				
				var text = '{"configurationRule":{"revision":"-","mathematicalExpression":"","name":"","description":"","policy":"ConfigurationRule",'+
				'"attributes":{"Originator":"'+ strOriginator +'",'+
				'"ExpressionType":"'+ruleType+
				'"},"type":"ConfigurationRule","effectivity":{"input": {"id": "pid:'+productId +
				'","isRange":"true"},"type":"ProductRevision"}},"version":"1.0.1"}';
				
				require([
					"DS/CfgRules/scripts/CfgMatrixRulesWebServices"
				], function (CfgMatrixRulesWebServices)
				{
					debugger ;
					var objectId = CfgMatrixRulesWebServices.createRule(text,contextObjId);
					
					if(objectId !== null){
						var listFrame = findFrame(getTopWindow(),FrameName);

						//Remove SortColumnName Persistency
							getTopWindow().removePersistenceData("sortColumnName" , '<%= tableName %>' );
							getTopWindow().removePersistenceData("sortDirection" ,  '<%= tableName %>' ); 
						
						//Remove SortColumnName param if present in URL
						var newUrl = listFrame.location.href;
						var startSortParamIndex = newUrl.indexOf("sortColumnName=");
						if(startSortParamIndex > 0){
							var substringToDelete = newUrl.substring(startSortParamIndex ,newUrl.indexOf("&",startSortParamIndex) == -1 ? newUrl.length : newUrl.indexOf("&",startSortParamIndex));
							newUrl = newUrl.replace(substringToDelete,"");
						}
						
						//Reload Frame Data		
						listFrame.location.href = newUrl ;
					}					
				});		
			</script>
<%
	}catch(Exception ex)
	{
%>
<script language="javascript" type="text/javaScript">
	     	alert("<%=ex.getMessage()%>");                 
	    </script>
<% 
	}
%>
