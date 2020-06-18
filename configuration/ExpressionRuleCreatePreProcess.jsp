<%--
  ExpressionRuleCreatePreProcess.jsp
  
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of 
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.dassault_systemes.enovia.configuration.modeler.Product"%>



<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%
	try{
			String strContextObjId = (String)emxGetParameter(request, "objectId");//context product object Id
			String frameName = "FTRExpressionRulesCommand";
	        StringList oidList = FrameworkUtil.split(strContextObjId, "|");
		    String ObjId = (String)oidList.get(0);
		    //retrieve product physicalID and Model physical ID
		    
		    com.dassault_systemes.enovia.configuration.modeler.Product strModelerPrd=new com.dassault_systemes.enovia.configuration.modeler.Product(ObjId);
		    Map mpProduct=strModelerPrd.getProductDetails(context, null);
		    String strProductPhyId="";
		    String strProductName="";
		    String strProductRev="";
		    if(mpProduct!=null && mpProduct.containsKey(ConfigurationConstants.SELECT_PHYSICAL_ID)){
			    strProductPhyId=(String)mpProduct.get(ConfigurationConstants.SELECT_PHYSICAL_ID);
			    strProductName=(String)mpProduct.get(DomainConstants.SELECT_NAME);
			    strProductRev=(String)mpProduct.get(DomainConstants.SELECT_REVISION);
			}
		    Map mpModel=strModelerPrd.getModelDetails(context, null);
		    String strModelPhyId="";
		    String strModelName="";
		    if(mpModel!=null && mpModel.containsKey(ConfigurationConstants.SELECT_PHYSICAL_ID)){
			    strModelPhyId=(String)mpModel.get(ConfigurationConstants.SELECT_PHYSICAL_ID);
			    strModelName=(String)mpModel.get(DomainConstants.SELECT_NAME);
		    }		    
%>
			<script language="javascript" type="text/javaScript">
				var strModelPhyId = encodeURIComponent('<%=strModelPhyId%>');
				var strProductPhyId = encodeURIComponent('<%=strProductPhyId%>');
				var FrameName = '<%=XSSUtil.encodeForJavaScript(context,frameName)%>';
				var varProductName = encodeURIComponent('<%=strProductName%>');
				var varProductRev = encodeURIComponent('<%=strProductRev%>');
				var varModelName = encodeURIComponent('<%=strModelName%>');
				
				var vURL= "./CreateExpressionRule.html?contextObjId="+strModelPhyId+"&parentOID="+strProductPhyId+"&postProcess="+FrameName
						+"&productName="+varProductName+"&productRev="+varProductRev+"&modelName="+varModelName;
				getTopWindow().showSlideInDialog(vURL,true);
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
