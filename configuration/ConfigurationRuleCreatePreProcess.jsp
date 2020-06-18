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
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%
	try{
			String strContextObjId = (String)emxGetParameter(request, "objectId");
			String strOriginator = com.matrixone.apps.domain.util.PersonUtil.getFullName(context, context.getUser());
			String frameName = "FTRMatrixRulesCommand";
			
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

	        
	        //fetch model name 
	        
	        DomainObject domProduct1  = new DomainObject(physicalId);
	        
	        StringList selList1 = new StringList();
		    selList1.add(DomainObject.SELECT_NAME);
		    Map ModelMAP = domProduct1.getInfo(context,selList1);
		    String ModelName = (String)ModelMAP.get("name");
%>
			<script language="javascript" type="text/javaScript">
			/*
				var contextObjId = '<%=XSSUtil.encodeForURL(context,physicalId)%>';
				var productId = '<%=XSSUtil.encodeForURL(context,strContextObjId)%>';
				var Name = '<%=XSSUtil.encodeForURL(context,Name)%>';
				var ModelName = '<%=XSSUtil.encodeForURL(context,ModelName)%>';
				var Revision = '<%=XSSUtil.encodeForURL(context,Revision)%>';
				var FrameName = '<%=XSSUtil.encodeForJavaScript(context,frameName)%>';
			*/
				var contextObjId = encodeURIComponent('<%=physicalId%>');
				var productId = encodeURIComponent('<%=strContextObjId%>');
				var Name = encodeURIComponent('<%=Name%>');
				var ModelName = encodeURIComponent('<%=ModelName%>');
				var Revision = encodeURIComponent('<%=Revision%>');
				var strOriginator = encodeURIComponent('<%=strOriginator%>');
				var FrameName = '<%=XSSUtil.encodeForJavaScript(context,frameName)%>';
	
				var vURL= "./CreateConfigurationRule.html?contextObjId="+contextObjId+"&parentOID="+productId+"&postProcess="+FrameName+"&Name="+Name+"&Revision="+Revision+"&ModelName="+ModelName+"&strOriginator="+strOriginator;
				getTopWindow().showSlideInDialog(vURL,true);
				/* getTopWindow().document.getElementById("rightSlideIn").style.width = "560px";  */

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
