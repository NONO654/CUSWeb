<%--  emxEngrMarkupsMerge.jsp -  This page performs markup actions
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@ page import="com.matrixone.apps.domain.util.ContextUtil"%>


<%
try
{
	 ContextUtil.pushContext(context);
   	 String[] emxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
	 String[] objectid = emxGetParameterValues(request, "objectId");
	 session.setAttribute("emxTableRowIds",emxTableRowIds);
	  

	 String mode   = emxGetParameter(request, "mode");
	 String changeObjectId = objectid[0];
	 session.setAttribute("changeObjectId",changeObjectId);
	 String  currentState = "";
	 //String createState =PropertyUtil.getSchemaProperty(context,"policy", DomainConstants.POLICY_ECR_STANDARD, "state_Create");
	// String submitState =PropertyUtil.getSchemaProperty(context,"policy", DomainConstants.POLICY_ECR_STANDARD, "state_Submit");
	 //String evaluateState =PropertyUtil.getSchemaProperty(context,"policy", DomainConstants.POLICY_ECR_STANDARD, "state_Evaluate");
	 //String reviewState =PropertyUtil.getSchemaProperty(context,"policy", DomainConstants.POLICY_ECR_STANDARD, "state_Review");
	 //String defineState =PropertyUtil.getSchemaProperty(context,"policy", DomainConstants.POLICY_ECO_STANDARD, "state_DefineComponents");
	// String designState =PropertyUtil.getSchemaProperty(context,"policy", DomainConstants.POLICY_ECO_STANDARD, "state_DesignWork");

	 DomainObject dObj = new DomainObject(changeObjectId);
	 currentState = dObj.getInfo(context,com.matrixone.apps.domain.DomainConstants.SELECT_CURRENT);
     String strTypeName = dObj.getTypeName();
	 String strObjectName = dObj.getName();
		

	
	 String TYPE_PART_SPECIFICATION=PropertyUtil.getSchemaProperty(context,"type_PartSpecification");
	 String TYPE_DOCUMENTS=PropertyUtil.getSchemaProperty(context,"type_DOCUMENTS");

	 boolean isSelPart=false;
		
	for(int i=0;i<emxTableRowIds.length;i++)
	{


		String rowtemp=emxTableRowIds[i];
		
		StringList strmarkupId = FrameworkUtil.split(emxTableRowIds[i],"|");
		String strSelId = (String)strmarkupId.elementAt(1);
		
		

		DomainObject dosel=new DomainObject(strSelId);
		String sselType=dosel.getInfo(context,DomainConstants.SELECT_TYPE);

		
        boolean bpart=mxType.isOfParentType(context,sselType,DomainConstants.TYPE_PART);
		boolean bSpec=mxType.isOfParentType(context,sselType,TYPE_DOCUMENTS);

	
		


		if(bpart || bSpec)

		{
			isSelPart=true;
			

%>

			<Script language="JavaScript">
			
			// This alerts  hits when User selects any Part or Specification related stuff ,
			alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.MarkupAlertonSelectionofDifferentAffectedItems</emxUtil:i18nScript>");

			</Script>


			

<%	
			break;	
}




	}






if(!isSelPart)

{	
	if(emxTableRowIds.length==1)
	{

%>

		<script language="javascript">
		
		var isselmutlitple=false;
		alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.MergeErroronSingleSelect</emxUtil:i18nScript>");
		if(getTopWindow().getWindowOpener()){
			parent.closeWindow();
			parent.window.getWindowOpener().location = parent.window.getWindowOpener().location;
		}
		</script>

<%

	}


	else
	{

		%>

		<script language="javascript">
		
		var isselmutlitple=true;
			

		</script>


<%

	}



	 
%>
		<script language="javascript">
			
			
			if(isselmutlitple)

			{
			
			if(confirm("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.MergeMsgConfirm</emxUtil:i18nScript>"))
			{			
				document.location.href = "emxengrMergeMarkupProcess.jsp?mode=<xss:encodeForURL><%=mode%></xss:encodeForURL>";						
			}else{
				parent.closeWindow();
			}

			}


			//parent.window.location = parent.window.location;
			</script>


<%

ContextUtil.popContext(context);	



}
}
catch (Exception ex)
{
	
}

%>


