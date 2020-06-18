<%--  emxMEPFormInclusionListAddExisting.jsp   -  This page deletes MEP objects.
    (c) Dassault Systemes, 1993-2018.All rights reserved.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   static const char RCSID[] = $Id: /ENOManufacturerEquivalentPart/CNext/webroot/manufactuerequivalentpart/emxMEPFormInclusionListAddExisting.jsp 1.1.2.1.1.1 Thur Dec 23 12:14:50 2010 GMT przemek Experimental$
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<script type="text/javascript" language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<%
String strSuiteKey              = emxGetParameter(request,  "suiteKey");
String strRelation              = emxGetParameter(request,  "relation");
String strSuiteDirectory        = emxGetParameter(request,  "SuiteDirectory");
String strStringResourceFileId  = emxGetParameter(request,  "StringResourceFileId");
String strSearchMode            = emxGetParameter(request,  "ObjectSearch");
String strObjectID              = emxGetParameter(request,  "objectId");
String strParentOID             = emxGetParameter(request,  "parentOID");
String strFormInclusionList     = "";

// XSS changes for IR-183141
strSuiteKey=XSSUtil.encodeForURL(context,strSuiteKey);
strStringResourceFileId=XSSUtil.encodeForURL(context,strStringResourceFileId);
strSuiteDirectory=XSSUtil.encodeForURL(context,strSuiteDirectory);
strObjectID=XSSUtil.encodeForURL(context,strObjectID);
strParentOID=XSSUtil.encodeForURL(context,strParentOID);

StringBuffer sbURL = new StringBuffer();

boolean isMCCInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionMaterialsComplianceCentral",false,null,null);

if (strSearchMode != null && !"".equals(strSearchMode) && !"null".equals(strSearchMode))
{
	strFormInclusionList = FrameworkProperties.getProperty(context, "emxManufacturerEquivalentPart.MEP.FormInclusionList" + strSearchMode);
	
	if("relationship_ManufacturerEquivalent".equals(strRelation))
	{
		sbURL.append("../common/emxFullSearch.jsp?");
		sbURL.append("field=TYPES=type_Part:POLICY=policy_ManufacturerEquivalent:INTERFACE!=interface_SuppliedPart:INTERFACE!=interface_ReportedPart");
		sbURL.append("&showInitialResults=false");
		sbURL.append("&header=emxManufacturerEquivalentPart.GlobalSearch.ManufacturerPartSearchResults");
		sbURL.append("&hideHeader=false");
		sbURL.append("&table=MEPAddExistingResults");
		sbURL.append("&selection=multiple");
		sbURL.append("&isFromFTSearch=false");
		sbURL.append("&excludeOIDprogram=jpo.manufacturerequivalentpart.Part:excludeAlreadyConnectedObjects");
		sbURL.append("&HelpMarker=emxhelpfullsearch");
		sbURL.append("&from=FullTextSearch&submitURL=../manufacturerequivalentpart/emxMEPPartAddUtilFTS.jsp?");
		sbURL.append("&relation=relationship_ManufacturerEquivalent");
		sbURL.append("&mode=AddExisting");
	}
	
	if("ManufacturerPart".equals(strSearchMode) && isMCCInstalled )
	{ 
		StringBuffer  formInclusionListBuff   = new StringBuffer(FrameworkProperties.getProperty(context, "emxMaterialsCompliance.MCCBase.FormInclusionList" + strSearchMode));
		
		boolean isMCCREACHInstalled   = FrameworkUtil.isSuiteRegistered(context,"appVersionREACHDataManagementOption",false,null,null);		
		boolean isMCCROHSInstalled    = FrameworkUtil.isSuiteRegistered(context,"appVersionRoHSDataManagementOption",false,null,null);
		boolean isMCCELVInstalled     = FrameworkUtil.isSuiteRegistered(context,"appVersionELVDataManagementOption",false,null,null);
		
		if(isMCCROHSInstalled)
		{
			formInclusionListBuff.append( ",");
			formInclusionListBuff.append(FrameworkProperties.getProperty(context,"emxMaterialsCompliance.RoHS.FormInclusionList"));
		}
	
		if(isMCCREACHInstalled)
        {
			formInclusionListBuff.append( ",");
			formInclusionListBuff.append(FrameworkProperties.getProperty(context,"emxMaterialsCompliance.REACH.FormInclusionList"));
        }
	
		if(isMCCELVInstalled)
		{
			formInclusionListBuff.append( ",");       
			formInclusionListBuff.append(FrameworkProperties.getProperty(context, "emxMaterialsCompliance.ELV.FormInclusionList" + strSearchMode));                   
	    }
		strFormInclusionList  = formInclusionListBuff.toString();
		
		sbURL.append("&fieldLabels=PartRevisionDate:emxFramework.FullTextSearch.MfgRevDate,Plant:emxFramework.FullTextSearch.ManufacturingLocation");      
        sbURL.append("&policyGroup=policy_ManufacturerEquivalent");        
	}		
}
sbURL.append("&hideHeader=false");
sbURL.append("&suiteKey=");
sbURL.append(strSuiteKey);
sbURL.append("&SuiteDirectory=");
sbURL.append(strSuiteDirectory);
sbURL.append("&StringResourceFileId=");
sbURL.append(strStringResourceFileId);
sbURL.append("&formInclusionList=");
sbURL.append(strFormInclusionList);

if (strObjectID != null && !"".equals(strObjectID) && !"null".equals(strObjectID)){
	sbURL.append("&objectId=");
	sbURL.append(strObjectID);
}
if (strParentOID != null && !"".equals(strParentOID) && !"null".equals(strParentOID)){
	sbURL.append("&parentOID=");
	sbURL.append(strParentOID);
}

%>

<script language="Javascript">
//XSSOK
var strURL = "<%=XSSUtil.encodeForJavaScript(context,sbURL.toString())%>";
 
/* window.location.href = strURL; */
 showModalDialog(strURL); 
</script>

