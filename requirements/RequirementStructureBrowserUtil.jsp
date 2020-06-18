
<%--
RequirementStructureBrowserUtil.jsp

Utilities that are needed to create, delete and remove a Feature Option.

Copyright (c) 1999-2018 Dassault Systemes.
All Rights Reserved.

This program contains proprietary and trade secret information
of MatrixOne, Inc.  Copyright notice is precautionary only and
does not evidence any actual or intended publication of such program
--%>
<%--
    	@quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
    --%>
<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import = "com.matrixone.apps.productline.*"%>
<%@page import = "com.matrixone.apps.requirements.*"%>
<%@page import = "com.matrixone.apps.domain.*"%>
<%@page import = "java.util.List"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>
<html>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>

<form name="formName" method="post">
<%
String strMode = emxGetParameter(request,"mode");
String jsTreeID = emxGetParameter(request, "jsTreeID");
String strObjId = emxGetParameter(request, "objectId");
String uiType = emxGetParameter(request,"uiType");
String action = "";
String msg = "";
boolean bIsError = false;

//added to make work with selected and not just root - Bug 357763
String strTableRowId = emxGetParameter(request,"emxTableRowId");
StringList objectIdList = FrameworkUtil.split(strTableRowId, "|");
if (objectIdList.size() == 3)
{
	strObjId = (String) objectIdList.get(0);
} 
else if(objectIdList.size() == 4)
{
	strObjId = (String) objectIdList.get(1);
}

try
{
    List lstSubTypesProducts = ProductLineUtil.getChildrenTypes(context, ReqSchemaUtil.getProductsType(context));
    List lstSubTypes = ProductLineUtil.getChildrenTypes(context, ReqSchemaUtil.getRequirementType(context));
    List lstSubTypesTestCase = ProductLineUtil.getChildrenTypes(context, ReqSchemaUtil.getTestCaseType(context));
    List lstSubTypesUseCase = ProductLineUtil.getChildrenTypes(context, ReqSchemaUtil.getUseCaseType(context));
    if(strMode.equalsIgnoreCase("CreateTestCase"))
    {
        DomainObject domObject = new DomainObject(strObjId);
        String strType = domObject.getInfo(context, DomainConstants.SELECT_TYPE);
        if (strType.equals(ReqSchemaUtil.getRequirementType(context))|| lstSubTypes.contains(strType))
        {
            String href = "../components/emxCommonFS.jsp?functionality=TestCaseCreateFSInstance&PRCFSParam1=Requirement&IsOption=true&uiType=StructureBrowser&suiteKey=ProductLine&parentOID="+strObjId+"&objectId="+strObjId;
%>
            <script language="javascript" type="text/javaScript">
            window.location.href = "<%=XSSUtil.encodeForJavaScript(context, href) %>";
            </script>
<%		
        }
        else
        {
%>
            <script>
            alert("<emxUtil:i18n localize='i18nId'>emxRequirements.Alert.NoCreationTestCaseUnderSelectedObject</emxUtil:i18n>");
	     //KIE1 ZUD TSK447636 
            getTopWindow().closeWindow();
            </script>
<%
        }
    }
    else if(strMode.equalsIgnoreCase("CreateUseCase"))
    {
        //For creating a Use Case under the context in Requirement Structure Browser.(Not possible under Product Context)
        DomainObject domObject = new DomainObject(strObjId);
        String strType = domObject.getInfo(context, DomainConstants.SELECT_TYPE);
        if (strType.equals(ReqSchemaUtil.getRequirementType(context))|| lstSubTypes.contains(strType))
        {
            String href = "../components/emxCommonFS.jsp?functionality=UseCaseCreateFSInstance&PRCFSParam1=Requirement&IsOption=true&uiType=StructureBrowser&suiteKey=Requirements&parentOID="+strObjId+"&objectId="+strObjId;
%>
            <script language="javascript" type="text/javaScript">
            window.location.href = "<%=XSSUtil.encodeForJavaScript(context, href) %>";
            </script>
<%		
        }
        else
        {
%>
            <script>
            alert("<emxUtil:i18n localize='i18nId'>emxRequirements.Alert.NoCreationUseCaseUnderSelectedObject</emxUtil:i18n>");
	     //KIE1 ZUD TSK447636 
            getTopWindow().closeWindow();
            </script>
<%
        }
    }
    else if(strMode.equalsIgnoreCase("CreateRefDoc"))
    {
        DomainObject domObject = new DomainObject(strObjId);
        String strType = domObject.getInfo(context, DomainConstants.SELECT_TYPE);
        if (strType.equals(ReqSchemaUtil.getRequirementType(context))|| lstSubTypes.contains(strType))
        {
            String href = "../components/emxCommonDocumentPreCheckin.jsp?objectAction=create&uiType=StructureBrowser&StringResourceFileId=emxComponentsStringResource&SuiteDirectory=components&objectId="+strObjId+"&parentOID="+strObjId;
%>
            <script language="javascript" type="text/javaScript">
            window.location.href = "<%=XSSUtil.encodeForJavaScript(context, href) %>";
            </script>
<%		
            
        }
        else
        {
%>
            <script language="javascript" type="text/javaScript">
            alert("<emxUtil:i18n localize='i18nId'>emxRequirements.Alert.NoCreationReferenceDocumentUnderSelectedObject</emxUtil:i18n>");
	     //KIE1 ZUD TSK447636 
            getTopWindow().closeWindow();
            </script>
<%
        }
    }
    else if(strMode.equalsIgnoreCase("AddTestCase"))
    {
        //For Adding an existing Test Case under Context object in Requirement Structure Browser
        DomainObject domObject = new DomainObject(strObjId);
        String strType = domObject.getInfo(context, DomainConstants.SELECT_TYPE);
        if (strType.equals(ReqSchemaUtil.getRequirementType(context)) || lstSubTypes.contains(strType))
        {
        	String href = "../common/emxFullSearch.jsp?field=TYPES%3Dtype_TestCase&table=PLCSearchTestCasesTable&excludeOIDprogram=emxSpecificationStructure:excludeChildObjects&selection=multiple&suiteKey=Requirements&cancelButton=true&cancelLabel=emxRequirements.Button.Cancel&showSavedQuery=True&showInitialResults=false&searchCollectionEnabled=True&HelpMarker=emxhelpfullsearch&objectId=" +strObjId+ "&rel=relationship_RequirementValidation&type=type_TestCase&submitURL=../requirements/FullSearchUtil.jsp?mode=AddExisting%26relName=relationship_RequirementValidation%26from=true%26isFromRMB=false&formInclusionList=null";
%>
            <script language="javascript" type="text/javaScript">
            window.location.href = "<%=XSSUtil.encodeForJavaScript(context, href) %>";
            </script>
<%		
        	
        }
        else
        {
%>
	 //KIE1 ZUD TSK447636 
            <script language="javascript" type="text/javaScript">
            alert("<emxUtil:i18n localize='i18nId'>emxRequirements.Alert.NoCreationTestCaseUnderSelectedObject</emxUtil:i18n>");
            getTopWindow().closeWindow();
            </script>
<%
        }
    }
    else if(strMode.equalsIgnoreCase("AddUseCase"))
    {
        //For Adding an existing UseCase under Context object in Requirement Structure Browser
        DomainObject domObject = new DomainObject(strObjId);
        String strType = domObject.getInfo(context, DomainConstants.SELECT_TYPE);
        if (strType.equals(ReqSchemaUtil.getRequirementType(context))||lstSubTypes.contains(strType))
        {
        	String href = "../common/emxFullSearch.jsp?field=TYPES%3Dtype_UseCase&table=RMTSearchUseCasesTable&excludeOIDprogram=emxUseCase:excludeSubUseCases&selection=multiple&suiteKey=Requirements&cancelButton=true&cancelLabel=emxRequirements.Button.Cancel&showSavedQuery=True&showInitialResults=false&searchCollectionEnabled=True&HelpMarker=emxhelpfullsearch&objectId=" +strObjId+ "&rel=relationship_RequirementUseCase&type=type_UseCase&submitURL=../requirements/FullSearchUtil.jsp?mode=AddExisting%26relName=relationship_RequirementUseCase%26from=true%26isFromRMB=false&formInclusionList=null";
%>
            <script language="javascript" type="text/javaScript">
            window.location.href = "<%=XSSUtil.encodeForJavaScript(context, href) %>";
            </script>
<%		
        }
        else
        {
%>
 	 //KIE1 ZUD TSK447636 
            <script language="javascript" type="text/javaScript">
            alert("<emxUtil:i18n localize='i18nId'>emxRequirements.Alert.NoAdditionUseCaseUnderSelectedObject</emxUtil:i18n>");
            getTopWindow().closeWindow();
            </script>
<%
        }
    }
    else if(strMode.equalsIgnoreCase("AddRefDoc"))
    {
        //For Adding an existing Reference Document under Context object in Requirement Structure Browser
        DomainObject domObject = new DomainObject(strObjId);
        String strType = domObject.getInfo(context, DomainConstants.SELECT_TYPE);
        if (strType.equals(ReqSchemaUtil.getRequirementType(context))||lstSubTypes.contains(strType))
        {
        	String href = "../common/emxFullSearch.jsp?field=TYPES%3Dtype_DOCUMENTS:POLICY!=policy_Version&excludeOIDprogram=emxPLCCommon:excludeConnected&table=PLCSearchDocumentsTable&selection=multiple&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&objectId=" +strObjId+ "&submitURL=../productline/SearchUtil.jsp?mode=AddExisting&relName=relationship_ReferenceDocument&from=false";
%>
            <script language="javascript" type="text/javaScript">
            window.location.href = "<%=XSSUtil.encodeForJavaScript(context, href) %>";
            </script>
<%		
        }
        else
        {
%>
 //KIE1 ZUD TSK447636 
            <script language="javascript" type="text/javaScript">
            alert("<emxUtil:i18n localize='i18nId'>emxRequirements.Alert.NoAdditionReferenceDocumentUnderSelectedObject</emxUtil:i18n>");
            getTopWindow().closeWindow();
            </script>
<%
        }
    }
}
catch(Exception e)
{
    bIsError=true;
    session.putValue("error.message", e.getMessage());
}// End of main Try-catck block
%>
</form>
</html>

