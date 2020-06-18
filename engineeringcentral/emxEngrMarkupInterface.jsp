<%--  emxEngrMarkupInterface.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@ page import="java.util.*,java.io.*,com.matrixone.jdom.*,com.matrixone.jdom.output.*"%>
<%@ page import="com.matrixone.jdom.*,
    com.matrixone.jdom.input.*,
    com.matrixone.jdom.output.*,
    com.matrixone.apps.common.util.*, 
    com.matrixone.apps.domain.util.* "%>
<%@page import="com.matrixone.apps.engineering.*"%>
<%@page import="com.dassault_systemes.enovia.partmanagement.modeler.interfaces.parameterization.*"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
String ebomUniquenessOperator = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","EBOMUniquenessOperator");

boolean sflag=false;
String sObjId = emxGetParameter(request,"objectId");
String relId = emxGetParameter(request, "relId");

//to fix relationship does not exists on click of Save Markup
if ("undefined".equals(relId)) { relId = ""; }  

String commandType=emxGetParameter(request,"commandType");
String contentURL = "";

IParameterization iParameterization = new com.dassault_systemes.enovia.partmanagement.modeler.impl.parameterization.Parameterization();
boolean isInstaceMode = iParameterization.isUnConfiguredBOMMode_Instance(context);

//Multitenant
/* String strFNRDEmpty = i18nNow.getI18nString("emxEngineeringCentral.BuildEBOM.FNAndRDfieldemptypleaseenterAnyOne", "emxEngineeringCentralStringResource", context.getSession().getLanguage());
String strFNEmpty = i18nNow.getI18nString("emxEngineeringCentral.BuildEBOM.FNfieldisemptypleaseenteranumber", "emxEngineeringCentralStringResource", context.getSession().getLanguage());
String strRDEmpty = i18nNow.getI18nString("emxEngineeringCentral.BuildEBOM.RDfieldisemptypleaseenteranumber", "emxEngineeringCentralStringResource", context.getSession().getLanguage());
String strQuantityEmpty = i18nNow.getI18nString("emxEngineeringCentral.BuildEBOM.Quantityfieldisemptypleaseenteranumber", "emxEngineeringCentralStringResource", context.getSession().getLanguage());
String strMarkupEmpty = i18nNow.getI18nString("emxEngineeringCentral.Markup.Empty", "emxEngineeringCentralStringResource", context.getSession().getLanguage()); */

String strFNRDEmpty = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.BuildEBOM.FNAndRDfieldemptypleaseenterAnyOne");
String strFNEmpty = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.BuildEBOM.FNfieldisemptypleaseenteranumber");
String strRDEmpty = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.BuildEBOM.RDfieldisemptypleaseenteranumber");
String strQuantityEmpty = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.BuildEBOM.Quantityfieldisemptypleaseenteranumber");
String strMarkupEmpty = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Markup.Empty");
String strInstanceModeErrorMessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.InstanceMode.NoModifyAccessOnLegacyComponents"); 

String rangeEAeach = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource", new Locale("en"), "emxFramework.Range.Unit_of_Measure.EA_(each)");
String quantityCanNotBeModified = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.validate.QuantityCanNotBeModified");
String quantityValueinInstanceModeforAdd = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.validate.quantityValueinInstanceModeforAdd");

//Added for BUG 358059-Starts
//Multitenant
/*String strMessage1 = i18nNow.getI18nString("emxEngineeringCentral.ReferenceDesignator.SingleQuantity.Msg1", "emxEngineeringCentralStringResource", context.getSession().getLanguage());
String strMessage2 = i18nNow.getI18nString("emxEngineeringCentral.ReferenceDesignator.SingleQuantity.Msg2", "emxEngineeringCentralStringResource", context.getSession().getLanguage());
String strMessage3 = i18nNow.getI18nString("emxEngineeringCentral.ReferenceDesignator.SingleQuantity.Msg3", "emxEngineeringCentralStringResource", context.getSession().getLanguage());*/

String strMessage1 = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.ReferenceDesignator.SingleQuantity.Msg1");
String strMessage2 = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.ReferenceDesignator.SingleQuantity.Msg2");
String strMessage3 = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.ReferenceDesignator.SingleQuantity.Msg3");

//Added for BUG 358059-Ends

String strSelectOnlyPart = "";
String strMultipleObjects = "";
String strInvalidStateError = "";
String strIsReleased = "";

//Multitenant
//String strSaveAsError = i18nNow.getI18nString("emxEngineeringCentral.Markup.SaveAsError", "emxEngineeringCentralStringResource", context.getSession().getLanguage());
String strSaveAsError = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Markup.SaveAsError"); 
String strLanguage    = request.getHeader("Accept-Language");

String[] sCheckBoxArray = emxGetParameterValues(request, "emxTableRowId");

String strObjectIds = "";

String strPolicy = null;

//IR-027996 - Starts
String strInlineError           = "";
/* String invalidRowInBOM          = i18nNow.getI18nString("emxEngineeringCentral.MarkupSave.InlineErrorMessage",
                                                        "emxEngineeringCentralStringResource", context.getSession().getLanguage()); */
String invalidRowInBOM          = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.MarkupSave.InlineErrorMessage");
//IR-027996 - Ends

//IR-053304
String rdQtyValidation = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","ReferenceDesignatorQtyValidation");

if (sCheckBoxArray != null)
{
	int intNumRowsSelected = sCheckBoxArray.length;

	for (int i=0; i < intNumRowsSelected; i++)
	{
		String strRowInfo = sCheckBoxArray[i];

		StringList strlRowInfo = FrameworkUtil.split(strRowInfo, "|");

		String strTempPartId = null;

		if (strlRowInfo.size() == 3)
    {
			strTempPartId = (String) strlRowInfo.get(0);
		}
		else if (strlRowInfo.size() == 4)
        {
			strTempPartId = (String) strlRowInfo.get(1);
		}

		if (strTempPartId != null)
            {
			if (strObjectIds.length() == 0)
			{
				strObjectIds = strTempPartId;
			}
			else
                {
				strObjectIds = strObjectIds + "|" + strTempPartId;
			}

            //IR-027996 - Starts
            DomainObject doTemp = null;
            String strTempPolicy = "";
            String strTempType = "";
            String strTempName = "";
            String strTempRevision = "";
            String strTempState = "";
            if (!"".equals(strTempPartId) && strTempPartId != null ) {
                //DomainObject doTemp = new DomainObject(strTempPartId);
                //String strTempPolicy = doTemp.getInfo(context, DomainConstants.SELECT_POLICY);
                //String strTempType = doTemp.getInfo(context, DomainConstants.SELECT_TYPE);
                //String strTempName = doTemp.getInfo(context, DomainConstants.SELECT_NAME);
                //String strTempRevision = doTemp.getInfo(context, DomainConstants.SELECT_REVISION);
                //String strTempState = doTemp.getInfo(context, DomainConstants.SELECT_CURRENT);
                doTemp = new DomainObject(strTempPartId);
                strTempPolicy = doTemp.getInfo(context, DomainConstants.SELECT_POLICY);
                strTempType = doTemp.getInfo(context, DomainConstants.SELECT_TYPE);
                strTempName = doTemp.getInfo(context, DomainConstants.SELECT_NAME);
                strTempRevision = doTemp.getInfo(context, DomainConstants.SELECT_REVISION);
                strTempState = doTemp.getInfo(context, DomainConstants.SELECT_CURRENT);
            } else {
                strInlineError = invalidRowInBOM;
                break;
            }
            //IR-027996 - Ends
			if (strPolicy == null)
					{
				strPolicy = strTempPolicy;
					}
			else
			{
				if (!strPolicy.equals(strTempPolicy))
					{
					//Multitenant
					//strMultipleObjects = i18nNow.getI18nString("emxEngineeringCentral.Markup.DifferentTypesError", "emxEngineeringCentralStringResource", context.getSession().getLanguage());
					strMultipleObjects = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Markup.DifferentTypesError");
					
					break;
				}
					}

			HashMap programMap = new HashMap();
			programMap.put("objectId", strTempPartId);

			Boolean  blnIsCreateAllowed = (Boolean)JPO.invoke(context,"emxENCActionLinkAccess",null,"isSaveMarkupAllowed",JPO.packArgs(programMap),Boolean.class);

			boolean blnCreate = blnIsCreateAllowed.booleanValue();

			if (!blnCreate)
					{
			
			
			/* strInvalidStateError = i18nNow.getI18nString("emxEngineeringCentral.Alert.InvalidStateError.1", "emxEngineeringCentralStringResource", strLanguage)+
			 strTempRevision + " " + strTempName + " " + strTempRevision 
			 + i18nNow.getI18nString("emxEngineeringCentral.Alert.InvalidStateError.2", "emxEngineeringCentralStringResource", strLanguage); */
			 strInvalidStateError = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Alert.InvalidStateError.1")+
					 strTempType + " " + strTempName + " " + strTempRevision +" "
			 + EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Alert.InvalidStateError.2");
				break;
					}

		       }
	     }
   }

else
					{

	DomainObject doTemp = new DomainObject(sObjId);
	String strTempPolicy = doTemp.getInfo(context, DomainConstants.SELECT_POLICY);
	String strTempType = doTemp.getInfo(context, DomainConstants.SELECT_TYPE);
	String strTempName = doTemp.getInfo(context, DomainConstants.SELECT_NAME);
	String strTempRevision = doTemp.getInfo(context, DomainConstants.SELECT_REVISION);
	String strTempCurrent = doTemp.getInfo(context, DomainConstants.SELECT_CURRENT);

	HashMap programMap = new HashMap();
	programMap.put("objectId", sObjId);

	Boolean  blnIsCreateAllowed = (Boolean)JPO.invoke(context,"emxENCActionLinkAccess",null,"isSaveMarkupAllowed",JPO.packArgs(programMap),Boolean.class);

	boolean blnCreate = blnIsCreateAllowed.booleanValue();

	if (!blnCreate || strTempCurrent.equals(EngineeringConstants.STATE_EC_PART_REVIEW) || strTempCurrent.equals(DomainObject.STATE_PART_APPROVED))
					{

		/* strInvalidStateError = i18nNow.getI18nString("emxEngineeringCentral.Alert.InvalidStateError.1", "emxEngineeringCentralStringResource", strLanguage)+
        strTempRevision + " " + strTempName + " " + strTempRevision 
        + i18nNow.getI18nString("emxEngineeringCentral.Alert.InvalidStateError.2", "emxEngineeringCentralStringResource", strLanguage); */
		strInvalidStateError = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Alert.InvalidStateError.1")+
				strTempType + " " + strTempName + " " + strTempRevision +" "
        + EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Alert.InvalidStateError.2");
					}

					}

DomainObject sdomobj=new DomainObject();
sdomobj.setId(sObjId);

	if (strObjectIds.length() > 0) {	
		contentURL = "../engineeringcentral/emxEngrMarkupPreInterface.jsp?form=MarkupSave&targetLocation=slidein&formHeader=emxEngineeringCentral.Markup.Create&HelpMarker=emxhelpebommarkupcreate&mode=edit&postProcessJPO=emxPartMarkup:saveMarkup&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource"
			+ "&commandType=" + XSSUtil.encodeForJavaScript(context,commandType) + "&sObjId=" + sObjId+"&submitAction=doNothing&Action=Save";
	sflag=true;
	} else {
		contentURL = "../engineeringcentral/emxEngrMarkupInterfaceRouteRequest.jsp?objectId="
				+ sObjId + "&commandType=" + XSSUtil.encodeForJavaScript(context,commandType);
	sflag=true;
					}


%>

<%
if(sflag)
{%>
<html>
<head>
</head>
<body>
<form name="form" method="post">
<input type="hidden" name="markupXML" value="" />
<input type="hidden" name="objectIds" value="" />
<input type="hidden" name="relId" value="" />
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" type="text/javascript">

function getFrame() {
	
	var targetFrame = findFrame(getTopWindow(),"ENCBOM");
	if(isValidFrame(targetFrame)) {
		return targetFrame;
	}
	targetFrame = findFrame(getTopWindow(),"ENCWhereUsed");
	if(isValidFrame(targetFrame)) {
		return targetFrame;
	}
	var multipleFrames = "ENCWhereUsed,ENCBOM"; // if we need to support one more navigation/frame, add respective frame with comma separated
	var portalFrames   = "portalDisplay,detailsDisplay"; // if we need to support one more portal navigation/frame, add respective frame with comma separated
	
	targetFrame = getActiveFrame(portalFrames,multipleFrames); // gets the frame by searching in portals 
	return isValidFrame(targetFrame) ? targetFrame : findFrame(getTopWindow(),"content");
}

// This API searches for ENCWhereUsed, ENCBOM frames in each portalFrame
function getActiveFrame(portalFrameNames,multipleFrameNames) {	
	if(isValidData(portalFrameNames) && isValidData(multipleFrameNames)) {		
		var portalFrameNamesArr  = portalFrameNames.split(",");
		var multipleFrameNamesArr= multipleFrameNames.split(",");
				
		var tempPortalFrameName,tempFrameName,tempPortalFrame,tempFrame;		
		for(var i = 0; i < portalFrameNamesArr.length; i++)
		{
			tempPortalFrameName = portalFrameNamesArr[i];		
			tempPortalFrame     = findFrame(getTopWindow(),tempPortalFrameName);	
			if(isValidFrame(tempPortalFrame)){
				for(var j = 0; j < multipleFrameNamesArr.length; j++) {
					tempFrame = findFrame(tempPortalFrame, multipleFrameNamesArr[j]);
					if(isValidFrame(tempFrame)) {
						return tempFrame;
					}
			    } 				
            }        
		}
    }		
	return null;
}
	
function isValidFrame(frameName) { //sometimes frame contains about:blank url and so need to check the url length atleast greater than 25 
	return (isValidData(frameName) && frameName.location.href.length > 25) ? true : false;
}

function isValidData(frameName) {
	return (frameName != null && frameName != undefined && frameName != "") ? true : false;
}

//Starts--Next Gen slidein
var isSubmitAllowed = true;
/*var reference     = findFrame(getTopWindow(), "portalDisplay") == null?findFrame(getTopWindow(), "content"): findFrame(getTopWindow(), "ENCBOM");
if(reference== null){
	reference = findFrame(getTopWindow(), "portalDisplay") == null?findFrame(getTopWindow(), "content"): findFrame(getTopWindow(), "ENCWhereUsed");
}*/

var reference = getFrame();
var callback      = reference.emxEditableTable.prototype.getMarkUpXML;
// var callback = getTopWindow().sb.emxEditableTable.prototype.getMarkUpXML;
var oXMLStatus        = callback();
var oXMLCallBack  = reference.oXML;
var dupemxUICore  = reference.emxUICore;
//Ends--Next Gen slidein
//XSSOK
var SINGLE_SEPARATOR="<%=JSPUtil.getCentralProperty(application,session,"emxEngineeringCentral","DelimitedReferenceDesignatorSeparator")%>";
//XSSOK
var RANGE_SEPARATOR="<%=JSPUtil.getCentralProperty(application,session,"emxEngineeringCentral","RangeReferenceDesignatorSeparator")%>";
//Added for BUG 358059-Ends

var inputXML = oXMLStatus.xml;
document.form.markupXML.value = inputXML;
//XSOK
document.form.relId.value = "<%=XSSUtil.encodeForJavaScript(context,relId)%>";
//XSSOK
var selectError = "<%=strSelectOnlyPart%>";
//XSSOK
var multipleError = "<%=strMultipleObjects%>";
//XSSOK
var invlalidStateError = "<%=strInvalidStateError%>";
//XSSOK
var cmdType = "<%=XSSUtil.encodeForJavaScript(context,commandType)%>";

//Added for IR-053304-Starts
//XSSOK
var rdQtyValidation           = "<%=rdQtyValidation%>";
//XSSOK
var VPLM_EA_EACH_STRING = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Qty.AllowEADecimal.String")%>";
var INSTANCE_TITLE_STRING = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.InstanceTitle.MarkupString")%>";
var INSTANCE_DESCRIPTION_STRING = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.InstanceDescription.MarkupString")%>";
var InValidDesignCollaboration = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.findNumber.DesignCollaborationMustbeSame")%>";
var InValidReferenceDesignator = "<%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.findNumber.ReferenceDesignatorError")%>";
var fnPropertyArray = new Array();
var rdPropertyArray = new Array();
var rdRequired = "";
<%String fnRequired = "";
String rdRequired = "";
String actualType  = "";
Map fnMap = EngineeringUtil.typeFNRDRequiredStatusMap(context);
Iterator iterator = fnMap.keySet().iterator();
while(iterator.hasNext()) {
     actualType  = (String)iterator.next();
      if (actualType==null || "".equals(actualType))
           continue;
  StringList sValue = (StringList)fnMap.get(actualType);
  fnRequired = (String)sValue.get(0);
  rdRequired = (String)sValue.get(1);
  %>
  //XSSOK
  fnPropertyArray["<%=actualType%>"]="<%=fnRequired%>";
//XSSOK
  rdPropertyArray["<%=actualType%>"]="<%=rdRequired%>";
<%
}
%>
//Added for IR-053304-Ends
//XSSOK
var objTempIds = "<%=XSSUtil.encodeForJavaScript(context,strObjectIds)%>";
var arrTempObjIds = objTempIds.split("|");

// Instance management Start
var isInstaceMode = "<%=isInstaceMode%>";

var xPath     =  "/mxRoot/rows//r[@status = 'changed']";	
contentFrame = getFrame();
var modifiedRow = emxUICore.selectNodes(contentFrame.oXML, xPath);
if(modifiedRow == null || modifiedRow.length==0){
	modifiedRow = emxUICore.selectNodes(contentFrame.oXML, "/mxRoot/rows//r[@status = 'add']");
}
for(var i=0;i<modifiedRow.length;i++){
	var status = modifiedRow[i].getAttribute("status");
	//changes-start
	var level = modifiedRow[i].getAttribute("level");
	var rowid = modifiedRow[i].getAttribute("id");
	var modifiedRowFN =contentFrame.emxEditableTable.getCellValueByRowId(modifiedRow[i].getAttribute("id"),"Find Number").value.current.actual;
	var modifiedRowVPMVisible = null;
	if(contentFrame.emxEditableTable.getCellValueByRowId(modifiedRow[i].getAttribute("id"),"VPMVisible") != undefined){
		modifiedRowVPMVisible =contentFrame.emxEditableTable.getCellValueByRowId(modifiedRow[i].getAttribute("id"),"VPMVisible").value.current.actual;
	}
	var modifiedRowRD =contentFrame.emxEditableTable.getCellValueByRowId(modifiedRow[i].getAttribute("id"),"Reference Designator").value.current.actual;
	var sameObjectRows = emxUICore.selectNodes(contentFrame.oXML,"/mxRoot/rows//r[child::c[@a='"+modifiedRowFN+"'] and @level = '" + level + "' and @id != '" + rowid + "']");
	if(sameObjectRows && sameObjectRows.length >0){
		for(var j=0; j<sameObjectRows.length; j++) {
			var rowObjId=sameObjectRows[j].getAttribute('o');
			var sameObjectRowsVPMVisible = null;
				if(contentFrame.emxEditableTable.getCellValueByRowId(sameObjectRows[j].getAttribute("id"),"VPMVisible") != undefined){
				sameObjectRowsVPMVisible =contentFrame.emxEditableTable.getCellValueByRowId(sameObjectRows[j].getAttribute("id"),"VPMVisible").value.current.actual;	
				}
			var sameObjectRowsRD =contentFrame.emxEditableTable.getCellValueByRowId(sameObjectRows[j].getAttribute("id"),"Reference Designator").value.current.actual;
			if(modifiedRowVPMVisible != null && sameObjectRowsVPMVisible.toUpperCase() != modifiedRowVPMVisible.toUpperCase()){
				 alert(InValidDesignCollaboration);
	  		     getTopWindow().closeSlideInDialog();
	  		}
			if ( (sameObjectRowsRD!="" && modifiedRowRD=="") || (sameObjectRowsRD=="" && modifiedRowRD!="") ) {
	  		  alert(InValidReferenceDesignator);
	  		  getTopWindow().closeSlideInDialog();
	  		}
		}		
	}
	//changes end
	var newQty = contentFrame.emxEditableTable.getCellValueByRowId(modifiedRow[i].getAttribute("id"),"Quantity").value.current.actual;
	var newUOM = contentFrame.emxEditableTable.getCellValueByRowId(modifiedRow[i].getAttribute("id"),"UOM").value.current.actual;
	if(contentFrame.emxEditableTable.getCellValueByRowId(modifiedRow[i].getAttribute("id"),"InstanceTitle") != undefined){
		var oldInstanceTitle = contentFrame.emxEditableTable.getCellValueByRowId(modifiedRow[i].getAttribute("id"),"InstanceTitle").value.old.actual;
		var newInstanceTitle = contentFrame.emxEditableTable.getCellValueByRowId(modifiedRow[i].getAttribute("id"),"InstanceTitle").value.current.actual;
		var oldInstanceDescription = contentFrame.emxEditableTable.getCellValueByRowId(modifiedRow[i].getAttribute("id"),"InstanceDescription").value.old.actual;
		var newInstanceDescription = contentFrame.emxEditableTable.getCellValueByRowId(modifiedRow[i].getAttribute("id"),"InstanceDescription").value.current.actual;
	}

	if(findFrame(getTopWindow(),"ENCWhereUsed")){
		newUOM = contentFrame.emxEditableTable.getCellValueByRowId(modifiedRow[i].parentNode.getAttribute("id"),"UOM").value.current.actual;
		//XSSOK
		if(newUOM == "<%=rangeEAeach%>"){
			if(newQty%1) {
				alert(VPLM_EA_EACH_STRING);
				 getTopWindow().closeSlideInDialog();
				 isSubmitAllowed = false;
				 break;
			  }
			if(isInstaceMode && isInstaceMode=="true"){
		 		if((status == "add" || status == "new") && parseInt(newQty)>100){
		 			//XSSOK
		 			alert("<%=quantityValueinInstanceModeforAdd %>");
					 getTopWindow().closeSlideInDialog();
					 isSubmitAllowed = false;
					 break;
		 		}
		 		//XSSOK
	     		if (status != "add" && status != "new" && parseInt(newQty)>1 && newUOM == "<%=rangeEAeach%>") {
	     			//XSSOK
	     			alert("<%=quantityCanNotBeModified %>");
					 getTopWindow().closeSlideInDialog();
					 isSubmitAllowed = false;
					 break;
	     		}
			}
		}
		if(oldInstanceTitle != newInstanceTitle && status != "add" && status != "new" ){
			alert(INSTANCE_TITLE_STRING);
		    getTopWindow().closeSlideInDialog();
			isSubmitAllowed = false;
			break;
     	 }
		if(oldInstanceDescription != newInstanceDescription && status != "add" && status != "new" ){
			alert(INSTANCE_DESCRIPTION_STRING);
		    getTopWindow().closeSlideInDialog();
			isSubmitAllowed = false;
			break;
     	 }
	}
	else if(isInstaceMode && isInstaceMode=="true"){
		//XSSOK
		if(!("1.0" == newQty) && (newUOM == "<%=rangeEAeach%>")){
			//XSSOK
			alert("<%=strInstanceModeErrorMessage%>");
			 getTopWindow().closeSlideInDialog();
		}
		if(oldInstanceTitle != newInstanceTitle && status != "add" && status != "new" ){
			alert(INSTANCE_TITLE_STRING);
			 getTopWindow().closeSlideInDialog();
		}
		if(oldInstanceDescription != newInstanceDescription && status != "add" && status != "new"){
			alert(INSTANCE_DESCRIPTION_STRING);
			 getTopWindow().closeSlideInDialog();
		}
	}
}

//Instance management END
if (selectError != "")
{
	isSubmitAllowed = false;
	alert(selectError);
    //Start--Next Gen slidein - Replaced all the occurrences of getTopWindow().window.close with getTopWindow().closeSlideInDialog() in page
    //top.window.close();
    getTopWindow().closeSlideInDialog();
    //Ends--Next Gen slidein
}
else if (cmdType == "SaveAs" && arrTempObjIds.length > 1)
{
	  isSubmitAllowed = false;
	  //XSSOK
	  alert("<%=strSaveAsError%>");
      getTopWindow().closeSlideInDialog();

}
else if (invlalidStateError != "")
{
	isSubmitAllowed = false;
	alert(invlalidStateError);
    getTopWindow().closeSlideInDialog();
}
else if (multipleError != "")
{
	isSubmitAllowed = false;
	alert(multipleError);
    getTopWindow().closeSlideInDialog();
}
else if (!(oXMLStatus.childNodes[0].hasChildNodes()))
 {
	isSubmitAllowed = false;
	//XSSOK
	alert("<%=strMarkupEmpty%>");
    getTopWindow().closeSlideInDialog();
 } 
else
{
	var msg = "";
	var markupIds = "";
	//XSSOK
	var objIds = "<%=XSSUtil.encodeForJavaScript(context,strObjectIds)%>";

	document.form.objectIds.value = objIds;

	var firstlevelchildren = oXMLStatus.childNodes[0].childNodes;
	for( var i =0;i<firstlevelchildren.length;i++)
					{
		var nextlevelchild = firstlevelchildren[i];

		var objId = "";
		var relID = undefined;

		if (nextlevelchild.hasChildNodes())
		{
			var action = nextlevelchild.getAttribute('markup');

			if (action != "changed")
			{

				objId = nextlevelchild.getAttribute('objectId');

				if (markupIds == "")
				{
					markupIds = objId;
               }
                else
                {
					markupIds = markupIds + "|" + objId;
    }

				var validate = "true";
				if (objIds == "" )
				{
					validate = "true";
            }
				else
				{
					if (objIds.indexOf(objId) != -1)
					{
						validate = "true";
        }
					else
        {
						validate = "false";
        }
    }

				if (validate == "true")
				{
					var subNodes = nextlevelchild.childNodes;


					for( var j =0;j<subNodes.length;j++)
					{
						var node = subNodes[j];

						action = node.getAttribute('markup');
						objId = node.getAttribute('objectId');
						relID = node.getAttribute('relId');
						if (action == "add")
						{
							var FN = "";
							var RD = "";
							var Qty = "";
							var attributes = node.childNodes;

							for( var k =0;k<attributes.length;k++)
							{
								var attribute = attributes[k];
								var attrName = attribute.getAttribute('name');

								if (attrName == "Find Number" || attrName == "FindNumber"){
									FN = attribute.childNodes[0].nodeValue;
								}else if (attrName == "Reference Designator"){
									RD = attribute.childNodes[0].nodeValue;
								}else if (attrName == "Quantity"){
									Qty = attribute.childNodes[0].nodeValue;
								}

							}
							//365724 Starts
// 							var Type = returnColValue(objId,relID,"Type");
//							var Type = getTopWindow().sb.emxEditableTable.getCellValueByObjectRelId(relID,objId,"Type").value.current.actual;//Mohan
							var Type = reference.emxEditableTable.getCellValueByObjectRelId(relID,objId,"Type").value.current.actual;
							var retMessage = validateECQuantityonApply(RD, Qty,Type);
							if(retMessage!=null && retMessage!="")
						    {
							    isSubmitAllowed = false;
								alert(retMessage);
								getTopWindow().closeSlideInDialog();
							}
							//365724 Ends
							//XSSOK
							if ("<%=ebomUniquenessOperator%>" == "or"){
								if ((FN == null || FN.length == 0 || FN == " ") && (RD == null || RD.length == 0 || RD == " ")){
								//XSSOK
									msg = "<%=strFNRDEmpty%>";
									break;
								}
								//XSSOK
							}else if ("<%=ebomUniquenessOperator%>" == "and"){
							  if(FN == null || FN.length == 0 || FN == " "){
								//XSSOK
								  msg = "<%=strFNEmpty%>";
								  break;
							  }else if(RD == null || RD.length == 0 || RD == " "){
								//XSSOK
								 msg = "<%=strRDEmpty%>";
								 break;
							 }
							}

							if (Qty == null || Qty.length == 0)
							{//XSSOK
								msg = "<%=strQuantityEmpty%>";
								break;
							}
						}
                        //IR-027996 - Starts
                        if (action == "new" || action == "lookup") {
                        	//XSSOK
                            msg = "<%=invalidRowInBOM%>";
                            break;
                        }
                        //IR-027996 - Ends
					}
				}
			}
			//Added for BUG 358059-Starts
			else if(action == "changed"){
				objId = nextlevelchild.getAttribute("objectId");
			    relID = nextlevelchild.getAttribute("relId");
				var attributes = nextlevelchild.childNodes;
				var FN = "";
				var RD = "";
				var Qty = "";
				for( var k =0;k<attributes.length;k++)
				{
						var attribute = attributes[k];
						var attrName = attribute.getAttribute('name');
						if (attrName == "Find Number")
						{
							FN = attribute.childNodes[0].nodeValue;
						}
						else if (attrName == "Reference Designator")
						{
							RD = attribute.childNodes[0].nodeValue;
						}
						else if (attrName == "Quantity")
						{
							Qty = attribute.childNodes[0].nodeValue;
						}
				}
				if(RD!="" & Qty==""){
					var Qty = returnColValue(objId,relID,"Quantity");
					var Type = returnColValue(objId,relID,"Type");
					var retMessage = validateECQuantityonApply(RD, Qty,Type);
					if(retMessage!=null && retMessage!="")
					{
						isSubmitAllowed = false;
						alert(retMessage);
                        getTopWindow().closeSlideInDialog();
					}
				}
				objId = nextlevelchild.getAttribute('parentId');
				if (markupIds == ""){
					markupIds = objId;
				}else{
					markupIds = markupIds + "|" + objId;
				}
			}
			//Added for BUG 358059-Ends
			else
			{
				objId = nextlevelchild.getAttribute('parentId');

				if (markupIds == "")
				{
					markupIds = objId;
				}
				else
				{
					markupIds = markupIds + "|" + objId;
				}
			}
		}
	}

	if (objIds == "")
	{
		if (msg.length == 0)
		{
			//XSSOK
			document.form.action='<%=contentURL%>';
		}
		else
		{
			isSubmitAllowed = false;
			alert(msg);
            getTopWindow().closeSlideInDialog();
			}
		}
		else
			{
		if (markupIds == "")
			{
			isSubmitAllowed = false;
			//XSSOK
			alert("<%=strMarkupEmpty%>");
	        getTopWindow().closeSlideInDialog();

			}
			else
			{
			var arrObjIds = objIds.split("|");

			var numObjIds = arrObjIds.length;

			var isEmpty = "false";

			for (var l = 0; l < numObjIds; l++)
			{
				if (markupIds.indexOf(arrObjIds[l]) == -1)
				{
					isEmpty = "true";
					break;
				}
			}

			if (isEmpty == "true")
			{
				isSubmitAllowed = false;
				//XSSOK
				alert("<%=strMarkupEmpty%>");
                getTopWindow().closeSlideInDialog();
			}
			else
			{
				if (msg.length == 0)
				{
					//XSSOK
					document.form.action='<%=contentURL%>';
				}
				else
				{
		            isSubmitAllowed = false;
					alert(msg);
                    getTopWindow().closeSlideInDialog();
				}
			}
		}

		}
}
//Added for BUG 358059-Starts
function isNumeric(varValue)
{
    if (isNaN(varValue))
    {
        return false;
    } else {
        return true;
    }
}
function validateECQuantityonApply(rdValue, qtyvalue,objectType)
{
    if(qtyvalue != null)
    {
      //IR-060860
	  if (qtyvalue.indexOf(",") != -1 ) {
        qtyvalue = qtyvalue.replace(",", ".");
      }
      if(!isNumeric(qtyvalue))
      {
        //return "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeANumber</emxUtil:i18nScript>";
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeANumber</emxUtil:i18nScript>");
        return false;
      }
      if((qtyvalue).substr(0,1) == '-')
      {
        //return "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeAPositiveNumber</emxUtil:i18nScript>";
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeAPositiveNumber</emxUtil:i18nScript>");
        return false;
      }
      //if(objectType=="") objectType = "Part";
      
      //Added for IR-053304 - Starts
      rdRequired = rdPropertyArray[objectType];
      if(rdQtyValidation && (rdQtyValidation.toLowerCase()=="true")){
	  //Added for IR-053304 -  Ends
	      if (rdValue!=null && rdValue!="null" && rdValue!="")
	      {
	           var rdQty = getRDQuantity(rdValue);
	          if (qtyvalue != rdQty)
		      {
	        //XSSOK
            var msg = "<%=strMessage1 %>";
		    msg = msg + " " + rdValue;
		  //XSSOK
		    msg = msg + " " + "<%=strMessage2%>";
		    msg = msg + " " + qtyvalue;
		  //XSSOK
		    msg = msg + "<%=strMessage3%>";
            return msg;
		      }
	      }
      }
    }
    return "";
}
/***************************************************************************** /
/* function getRDQuantity(string) - returns the no. of Reference Designator   */
/*   components. It returns 1 if the RD is a single value else returns        */
/*   the no. of RD components.This function has to be used when the           */
/*   RD value is given.                                                       */
/*****************************************************************************/
   function getRDQuantity(string)
   {
       var str1=string;
       var tot=0;
	   if (str1==null || str1=="null" || str1=="")
	      return 0;
       if((str1.indexOf(SINGLE_SEPARATOR) !=-1) && (str1.indexOf(RANGE_SEPARATOR) != -1))
       {
          hyp = str1.split(SINGLE_SEPARATOR);
          for(var i=0,diff1=0,delimct=0;i<hyp.length;i++)
          {
            st=hyp[i];

            if(st.indexOf(RANGE_SEPARATOR)!=-1)
            {
               ctr= (st.indexOf(RANGE_SEPARATOR));
               num1=st.substring(0,st.indexOf(RANGE_SEPARATOR));
               num2=st.substring(st.indexOf(RANGE_SEPARATOR)+1);
			   diff1= sumRDRange(num1,num2);
               tot=tot+diff1;
             }
             else
             {
               delimct++;
             }
        }

      	return (tot+delimct);

      }
      else if(str1.indexOf(SINGLE_SEPARATOR)!=-1)
      {
		   ctr=str1.split(SINGLE_SEPARATOR);
           return ctr.length;
      }
      else if(str1.indexOf(RANGE_SEPARATOR)!=-1)
      {
		   num1=str1.substring(0,str1.indexOf(RANGE_SEPARATOR));
           num2=str1.substring(str1.indexOf(RANGE_SEPARATOR)+1);
           diff1=sumRDRange(num1,num2);
           return diff1;
      }
      else
      {
		   return 1;
      }
	return 0;
   }


/********************************************************************* /
/* function sumRDRange(num1,num2) - returns the no. of Reference      */
/*  Designator components in a range . It returns the range of the RD */
/**********************************************************************/
  function sumRDRange(num1,num2)
  {

     var txt1=num1.match(/[0-9]*$/g);
     var txt2=num2.match(/[0-9]*$/g);
     arr1=txt1.toString().split(SINGLE_SEPARATOR);
     arr2=txt2.toString().split(SINGLE_SEPARATOR);
     var diff1 =parseInt(arr2[0]) -parseInt(arr1[0]);
     return ++diff1;
  }
 function returnColValue(objId,relID,columnToChange)
 {
 	var MxRootPath = "/mxRoot/columns//column";
    var nColumn = dupemxUICore.selectNodes(oXMLCallBack.documentElement, MxRootPath);
    var columnCount;
    var nColumnType = "";
    var columnXML = "";
    for(checkCount=0;checkCount<nColumn.length;checkCount++){
            var Tempname=nColumn[checkCount].getAttribute("name");
            if(Tempname==columnToChange){
                columnCount = checkCount+1;
                break;
            }
    }
    if(typeof relID!="undefined"){
    	columnXML = dupemxUICore.selectSingleNode(oXMLCallBack.documentElement,"/mxRoot/rows//r[@o = '" + objId + "'][@r='"+ relID +"']/c[" +columnCount+ "]");
	}else{
		columnXML = dupemxUICore.selectSingleNode(oXMLCallBack.documentElement,"/mxRoot/rows//r[@o = '" + objId + "']/c[" +columnCount+ "]");
	}
	
	var nColumnValue = dupemxUICore.getText(columnXML);
	
	//Added for 053304 -Starts
	
	//If user need the type of Part like EC Part or Development Part then following code will execute if on 
	//"Type" is passed by user to columnToChange parameter. this method return the object Type which is
	//required for rdRequired value.
	
	if(columnToChange=="Type"){
		nColumnType = columnXML.getAttribute("a");
		nColumnValue = nColumnType;
	}
	//Added for 053304 -Ends
	return nColumnValue;
 }
 //Added for BUG 358059-Ends
 if (isSubmitAllowed){
	    document.form.submit();
 }   

</script>
 </form>
 </body>
</html>
<%} %>







