<%--  emxEngrECRECOConnectAffectedItemsIntermediateProcess.jsp   - The Intermediate page for ECR/ECO Add Existing.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.apps.engineering.EngineeringConstants"%>
<%
	DomainObject changeObj = DomainObject.newInstance(context);
	String changeId =(String) emxGetParameter(request,"objectId");
	String sType = (String) emxGetParameter(request,"Type");
	String sPolicyClassification = (String) emxGetParameter(request,"PolicyClassification");
	String suiteKey = XSSUtil.encodeForJavaScript(context,(String) emxGetParameter(request,"suiteKey"));
	
	changeObj.setId(changeId);
	StringList strlDesginResIds = new StringList(1);
	String strDesginResId = "";

	String sSrearchURL = "../common/emxFullSearch.jsp?showInitialResults=false&suiteKey="+suiteKey+"&";
	
	if(DomainConstants.TYPE_ECR.equals(sType.trim()))
	{
		if("Dynamic".equals(sPolicyClassification.trim()))
		{
			// 363480		    
			//sSrearchURL += "field=TYPES=type_Part,type_CADModel,type_CADDrawing,type_DrawingPrint,type_PartSpecification:CURRENT=policy_ECPart.state_Release:REL_AFFECTED_ITEM!="+changeId+":LASTREVISION=true"+"&excludeOIDprogram=emxENCFullSearch:excludeAffectedItems&table=ENCAffectedItemSearchResult&selection=multiple&submitAction=refreshCaller&hideHeader=true&submitURL=../engineeringcentral/emxEngrECRECOConnectAffectedItems.jsp&srcDestRelName=relationship_AffectedItem&mandatorySearchParam=CURRENT&HelpMarker=emxhelpfullsearch&objectId="+changeId;
		    //IR-032470V6R2011
			sSrearchURL += "field=TYPES=type_Part,type_CADModel,type_CADDrawing,type_DrawingPrint,type_PartSpecification:CURRENT=policy_ECPart.state_Release:REL_AFFECTED_ITEM!="+changeId+":LATESTREVISION=TRUE"+"&excludeOIDprogram=emxENCFullSearch:excludeAffectedItems&table=ENCAffectedItemSearchResult&selection=multiple&submitAction=refreshCaller&hideHeader=true&submitURL=../engineeringcentral/emxEngrECRECOConnectAffectedItems.jsp&srcDestRelName=relationship_AffectedItem&mandatorySearchParam=CURRENT&HelpMarker=emxhelpfullsearch&objectId="+changeId;
		}
		else if("Static".equals(sPolicyClassification.trim()))
		{
			// 363480
		    //sSrearchURL += "field=TYPES=type_Part,type_CADModel,type_CADDrawing,type_DrawingPrint,type_PartSpecification:CURRENT=policy_ECPart.state_Release:LASTREVISION=true&excludeOIDprogram=emxENCFullSearch:excludeAffectedItems&table=ENCAffectedItemSearchResult&selection=multiple&submitAction=refreshCaller&hideHeader=true&submitURL=../engineeringcentral/emxEngrECRECOConnectAffectedItems.jsp&mandatorySearchParam=CURRENT&HelpMarker=emxhelpfullsearch&objectId="+changeId;
		    //IR-032470V6R2011
			sSrearchURL += "field=TYPES=type_Part,type_CADModel,type_CADDrawing,type_DrawingPrint,type_PartSpecification:CURRENT=policy_ECPart.state_Release:LATESTREVISION=TRUE&excludeOIDprogram=emxENCFullSearch:excludeAffectedItems&table=ENCAffectedItemSearchResult&selection=multiple&submitAction=refreshCaller&hideHeader=true&submitURL=../engineeringcentral/emxEngrECRECOConnectAffectedItems.jsp&mandatorySearchParam=CURRENT&HelpMarker=emxhelpfullsearch&objectId="+changeId;
		}

	}
	else if(DomainConstants.TYPE_ECO.equals(sType.trim()))
	{
	//Modified for RDO Convergence start	
		/*strlDesginResIds = changeObj.getInfoList(context, "to["+DomainConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY+"].from.id");		
		Iterator itrDesginResIds = strlDesginResIds.iterator();
		int k = 0;

		while (itrDesginResIds.hasNext())
		{
			if (k == 0)
			{
				strDesginResId = (String)itrDesginResIds.next();
			}
			else
			{
				strDesginResId = strDesginResId + "," + itrDesginResIds.next();
			}

			k++;
		} */
		strDesginResId= changeObj.getAltOwner1(context).toString();	
		//Modified for RDO Convergence End
	
		if("Dynamic".equals(sPolicyClassification.trim()))
		{	
			   
			sSrearchURL+="field=TYPES=type_Part,type_CADModel,type_CADDrawing,type_DrawingPrint,type_PartSpecification:Policy!=policy_ConfiguredPart,policy_ManufacturerEquivalent:CURRENT=";

			String policy=FrameworkProperties.getProperty(context,"emxEngineeringCentral.ECOAffectedItems.AllowedStates");
			sSrearchURL+=policy;
			 if (strDesginResId != null && strDesginResId.length() > 0) {
				    //sSrearchURL += ":AFFECTEDITEMS_RDO=Unassigned|"+strDesginResId;  //Modified for RDO Convergence
				    //sSrearchURL += ":ALTOWNER1=Unassigned|"+strDesginResId; //Modified for IR-232344
				    sSrearchURL += ":ORGANIZATION="+strDesginResId;
				 
			 }         
				 sSrearchURL += "&excludeOIDprogram=emxENCFullSearch:excludeAffectedItems&table=ENCAffectedItemSearchResult&selection=multiple&submitAction=refreshCaller&hideHeader=true&submitURL=../engineeringcentral/emxEngrECRECOConnectAffectedItems.jsp&srcDestRelName=relationship_AffectedItem&mandatorySearchParam=CURRENT&HelpMarker=emxhelpfullsearch&objectId="+changeId;
	        }
		
		else if("Static".equals(sPolicyClassification.trim()))
		{
			if (strDesginResId != null && strDesginResId.length() > 0)
			{
				sSrearchURL += "field=TYPES=type_Part,type_CADModel,type_CADDrawing,type_DrawingPrint,type_PartSpecification:Policy!=policy_ConfiguredPart,policy_ManufacturerEquivalent:CURRENT=policy_ECPart.state_Preliminary,policy_ECPart.state_Review,policy_ECPart.state_Approved:AFFECTEDITEMS_RDO=Unassigned|"+strDesginResId+"&excludeOIDprogram=emxENCFullSearch:excludeAffectedItems&table=ENCAffectedItemSearchResult&selection=multiple&submitAction=refreshCaller&hideHeader=true&submitURL=../engineeringcentral/emxEngrECRECOConnectAffectedItems.jsp&HelpMarker=emxhelpfullsearch&objectId="+changeId;
			}
			else
			{
				sSrearchURL += "field=TYPES=type_Part,type_CADModel,type_CADDrawing,type_DrawingPrint,type_PartSpecification:Policy!=policy_ConfiguredPart,policy_ManufacturerEquivalent:CURRENT=policy_ECPart.state_Preliminary,policy_ECPart.state_Review,policy_ECPart.state_Approved&excludeOIDprogram=emxENCFullSearch:excludeAffectedItems&table=ENCAffectedItemSearchResult&selection=multiple&submitAction=refreshCaller&hideHeader=true&submitURL=../engineeringcentral/emxEngrECRECOConnectAffectedItems.jsp&HelpMarker=emxhelpfullsearch&objectId="+changeId;
			}
		}
		else if("TeamCollaboration".equals(sPolicyClassification.trim())){
			String  policyName = changeObj.getInfo(context, EngineeringConstants.SELECT_POLICY);
			if(policyName.equals(EngineeringConstants.POLICY_TEAM_ECO)) {
			    String releaseStateFilter = !EngineeringConstants.STATE_TEAMECO_DESIGNWORK.equals(changeObj.getInfo(context, DomainConstants.SELECT_CURRENT))
					? ",policy_ECPart.state_Release" : "";
				sSrearchURL += "field=TYPES=type_Part" + com.matrixone.apps.engineering.EngineeringUtil.getAltOwnerFilterString(context)
					+ ":CURRENT=policy_ECPart.state_Preliminary,policy_ECPart.state_Review,policy_ECPart.state_Approved"+ releaseStateFilter +"&excludeOIDprogram=emxTeamUtils:excludeAffectedItems&table=ENCAffectedItemSearchResult&selection=multiple&submitAction=refreshCaller&hideHeader=true&submitURL=../engineeringcentral/emxEngrECRECOConnectAffectedItems.jsp&srcDestRelName=relationship_AffectedItem&mandatorySearchParam=CURRENT&HelpMarker=emxhelpfullsearch&objectId="+changeId+"&policyClassification="+sPolicyClassification+"&formInclusionList=VPM_PRODUCT_NAME";
			} else {
				sSrearchURL += "field=TYPES=type_Part" + com.matrixone.apps.engineering.EngineeringUtil.getAltOwnerFilterString(context)
					+ ":CURRENT=policy_DevelopmentPart.state_Create,policy_DevelopmentPart.state_PeerReview&excludeOIDprogram=emxTeamUtils:excludeAffectedItems&table=ENCAffectedItemSearchResult&selection=multiple&submitAction=refreshCaller&hideHeader=true&submitURL=../engineeringcentral/emxEngrECRECOConnectAffectedItems.jsp&srcDestRelName=relationship_AffectedItem&mandatorySearchParam=CURRENT&HelpMarker=emxhelpfullsearch&objectId="+changeId+"&policyClassification="+sPolicyClassification+"&formInclusionList=VPM_PRODUCT_NAME";
			}
		}
	}

%>

<script language="Javascript">
//XSSOK
var URL = "<%=XSSUtil.encodeForJavaScript(context,sSrearchURL)%>";
window.location.href = URL;
</script>
