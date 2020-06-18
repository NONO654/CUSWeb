<%--  IEFStartDesignCreateObjectFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ include file = "../components/emxSearchInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	String queryString = emxGetQueryString(request);

	Context context								= integSessionData.getClonedContext(session);
        String integrationName						=Request.getParameter(request,"integrationName");
	MCADGlobalConfigObject globalConfigObject	= integSessionData.getGlobalConfigObject(integrationName,context);
	boolean isAssignCADModelNameFromPart        = globalConfigObject.isAssignCADModelNameFromPart();
	
    String attrModelType                        = MCADMxUtil.getActualNameForAEFData(context, "attribute_ModelType");
    String attrDesignatedUser                   = MCADMxUtil.getActualNameForAEFData(context, "attribute_DesignatedUser");
    
	boolean isMatchCADModelRevisionForPart		= false;

	String confObjTNR = globalConfigObject.getEBOMRegistryTNR();
	StringTokenizer token = new StringTokenizer(confObjTNR, "|");
	if(token.countTokens() >= 3)
	{
		String confObjType			= (String) token.nextElement();
		String confObjName			= (String) token.nextElement();
		String confObjRev			= (String) token.nextElement();

		IEFEBOMConfigObject ebomConfigObj = new IEFEBOMConfigObject(context, confObjType, confObjName, confObjRev);
		String matchingPartString		  = ebomConfigObj.getConfigAttributeValue(IEFEBOMConfigObject.ATTR_PART_MATCHING_RULE);

		isMatchCADModelRevisionForPart = matchingPartString.equals("MATCH_CADMODEL_REV");
	}

	Enumeration enumParamNames = emxGetParameterNames(request);
	while(enumParamNames.hasMoreElements()) 
	{
		String paramName =XSSUtil.encodeForJavaScript(context,XSSUtil.encodeForURL(context,(String) enumParamNames.nextElement()));
		String paramValue = emxGetParameter(request, paramName);
		if (paramValue != null && paramValue.trim().length() > 0 )
			paramValue = XSSUtil.encodeForJavaScript(context,XSSUtil.encodeForURL(context,paramValue));
		queryString += "&"+paramName+ "=" +paramValue;
	}
%>

<html>
<head>
<script src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript">

<%@include file = "IEFTreeTableInclude.inc"%>

var frameheaderDisplay = null;
var frametableDisplay = null;
var framebottomDisplay = null;

function init()
{
	frameheaderFrame = findFrame(this,"headerFrame");
	framecontentFrame = findFrame(this,"contentFrame");
	framebottomDisplay = findFrame(this,"bottomDisplay");
}

function showPartSearchDialog()
{
	var url = "../common/emxFullSearch.jsp?field=TYPES=type_Part"+"&fieldNameOID=&selection=single&submitURL=../integrations/IEFSearchPartReSubmit.jsp?methodName=doPartSelect&table=ENCAffectedItemSearchResult";

	showIEFModalDialog(url, 575,575, true);
}

function doPartSelect(partName, partId)
{
//XSSOK
	var isMatchCADModelRevisionForPart = "<%=isMatchCADModelRevisionForPart%>";

	var mqlCmd			 = ["print bus $1 select $2 $3 dump $4",partId,"revision","description","|"];

	var integrationName	 = treeControlObject.getIntegrationName();

    var integrationFrame = getIntegrationFrame(this);
	var cmdResult		 = top.opener.getAppletObject().callCommandHandlerSynchronously(integrationName, "executeMQLCommandAtServer", mqlCmd) + "";
        cmdResult	     = cmdResult + "";
	var revision		 = cmdResult.substring(0, cmdResult.indexOf("|"));
	var specificationValue	= cmdResult.substring(cmdResult.indexOf("|") + 1,cmdResult.length);

	framecontentFrame.document.createForm.SpecDrawingNum.value = partName;
	framecontentFrame.document.createForm.partName.value = partName;
	framecontentFrame.document.createForm.partId.value = partId;
	if(isMatchCADModelRevisionForPart == "true")
	{
	framecontentFrame.document.createForm.CustomRevLevel.value = revision;
	}

	framecontentFrame.document.createForm.specification.value = specificationValue;
}

function showCreatePartDialog()
{
	var url = "../common/emxCreate.jsp?nameField=both&form=type_CreatePart&header=CreatePart&type=type_Part&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&submitAction=treeContent&postProcessURL=../engineeringcentral/PartCreatePostProcess.jsp&createJPO=emxPart:createPartJPO&createMode=DEC&preProcessJavaScript=setRDO&HelpMarker=emxhelppartcreate&typeChooser=true&InclusionList=type_Part&ExclusionList=type_ManufacturingPart";
	showIEFModalDialog(url, 575,575, true);
}


function jsTrim (valString)
{
    var trmString = valString;

    // this will get rid of leading spaces
    while (trmString.substring(0,1) == ' ')
    trmString = trmString.substring(1, trmString.length);

    // this will get rid of trailing spaces
    while (trmString.substring(trmString.length-1,trmString.length) == ' ')
    trmString = trmString.substring(0, trmString.length-1);

    return trmString;
}

function trimWhitespace(strString) {
    strString = strString.replace(/^[\s\u3000]*/g, "");
    return strString.replace(/[\s\u3000]+$/g, "");
}

function cancel()
{
	window.close();
}

function closeWindow()
{
	if(cancelOperation)
	{
		cancelOperation = false;

		var integrationName = treeControlObject.getIntegrationName();
		top.opener.getAppletObject().callCommandHandler(integrationName, "cancelOperation", true);		
	}
}


function submit()
{
<!--XSSOK-->
	var isAssignCADModelNameFromPart = "<%=isAssignCADModelNameFromPart%>";
	var specificationName = "";

	if(isAssignCADModelNameFromPart == "true")
	{
	   specificationName = framecontentFrame.document.createForm.specification.value ;
	}

	var isInputValid = framecontentFrame.window.checkInput();
	if(isInputValid)
	{
		//show the progress clock
		showProgressClock();		
//XSSOK		
		setObjectValue("<%=attrModelType%>");
		//XSSOK
        setObjectValue("<%=attrDesignatedUser%>");
        
		framecontentFrame.document.createForm.action = "IEFStartDesignCreateObject.jsp?specificationName="+specificationName;

		if(emxUIConstants.isCSRFEnabled){
    		var csrfKey = emxUIConstants.CSRF_TOKEN_KEY;
    		var csrfName = emxUIConstants.CSRF_TOKEN_NAME;
    		var tokenName = framecontentFrame.document.createForm.elements[csrfKey].value;
    		var tokenValue = framecontentFrame.document.createForm.elements[csrfName].value;
    		framecontentFrame.document.createForm.action=framecontentFrame.document.createForm.action+"&"+csrfKey+"="+tokenName+"&"+csrfName+"="+tokenValue;

            }
	
		framecontentFrame.document.createForm.submit();
	}
}

function setObjectValue(inputName)
{
    var Unassigned =  "<%=i18nNow.getI18nString("emxIEFDesignCenter.Common.Unassigned", "emxIEFDesignCenterStringResource", request.getHeader("Accept-Language"))%>";
    
    var defaultVal = "Unassigned";    
    var inputElement   = framecontentFrame.document.createForm.elements[inputName + "_dummy"];    
    var hiddenElement  = framecontentFrame.document.createForm.elements[inputName];
    
    if(hiddenElement != null && hiddenElement != "undefined" && inputElement.value == Unassigned)
    {
        hiddenElement.value = defaultVal;
    }   
}

function showProgressClock()
{
	frameheaderFrame.document.progress.src = "images/utilProgressDialog.gif";
}

function stopProgressClock()
{
	frameheaderFrame.document.progress.src = "images/utilSpacer.gif";
}

function createCheckoutPage(integrationName, rootObjectID)
{
	checkout(integrationName, 'true', rootObjectID + '|||', '' , "interactive","false");
}

//Event handlers End
</script>
</head>

<frameset rows="12%,*,12%,0" frameborder="no" framespacing="2" onLoad="javascript:init()" onUnload="javascript:closeWindow()">
	<frame name="headerFrame" src="IEFStartDesignCreateObjectHeader.jsp" scrolling=no>
	<frame name="contentFrame"  src="IEFStartDesignCreateObjectContent.jsp?<%=  XSSUtil.encodeURLwithParsing(context, queryString) %>" marginheight="5" marginwidth="10">
	<frame name="bottomFrame" src="IEFStartDesignCreateObjectFooter.jsp" scrolling=no >
	<frame name="hiddenFrame" src="IEFStartDesignCreateObject.jsp" scrolling=no >
</frameset>
</html>

