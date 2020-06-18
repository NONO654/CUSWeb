 <%--  emxEngrAddNextHiddenProcess.jsp  -  Hidden Page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.dassault_systemes.enovia.partmanagement.modeler.interfaces.parameterization.*"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%
  //Check for ENGSMB Installation
	boolean isENGSMBInstalled =	EngineeringUtil.isENGSMBInstalled(context);
  
  //Variable declarations
  String selPartRelId      = "";
  String selPartObjectId   = "";
  String selPartParentOId  = "";
  //Added for V6R2009.HF0.2 - Starts
  String sRowId            = "";
  boolean FNFlag           = false;
  //Added for V6R2009.HF0.2 - Ends
   IParameterization iParameterization = new com.dassault_systemes.enovia.partmanagement.modeler.impl.parameterization.Parameterization();
   boolean isInstaceMode = iParameterization.isUnConfiguredBOMMode_Instance(context);

  // Get the parametes from request object
  String objectId = emxGetParameter(request,"objectId");
  String calledMethod      = emxGetParameter(request, "calledMethod");
  String suiteKey      = emxGetParameter(request, "suiteKey");
  String strAddNext = emxGetParameter(request, "addNext");
  String struiType = emxGetParameter(request, "uiType");
  String stromitSpareParts = emxGetParameter(request, "omitSpareParts");
  String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
  //Added for UX Changes- Introduced New Part Next functionality--Start
  String sFunctionality = emxGetParameter(request,"functionality");
  //Added for UX Changes- Introduced New Part Next functionality--Start
  //Added for V6R2009.HF0.2 - Starts
  String language          = request.getHeader("Accept-Language");

  String strInstanceModeErrorMessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
  		context.getLocale(),"emxEngineeringCentral.InstanceMode.NoModifyAccessOnLegacyComponents"); 
  // Get the property entries
  //Multitenant
  /* String NumberOfPartsExceed        = i18nNow.getI18nString("emxEngineeringCentral.Part.BOM.NumberOfPartsExceed",
                                                        "emxEngineeringCentralStringResource", 
                                                        language); */
  String NumberOfPartsExceed        = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
		  context.getLocale(),"emxEngineeringCentral.Part.BOM.NumberOfPartsExceed");
                                                        
  //Multitenant                                                    
  /* String AddNextOnDeletedRow        = i18nNow.getI18nString("emxEngineeringCentral.Part.BOM.AddNextOnDeleted",
                                                        "emxEngineeringCentralStringResource", 
                                                        language); */
  String AddNextOnDeletedRow        = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
		  context.getLocale(),"emxEngineeringCentral.Part.BOM.AddNextOnDeleted");
                                                        
  //Multitenant
  /* String AddNextRootNode            = i18nNow.getI18nString("emxEngineeringCentral.Part.BOM.AddNextRootNodeError",
                                                        "emxEngineeringCentralStringResource", 
                                                        language); */
  String AddNextRootNode            = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
		  context.getLocale(),"emxEngineeringCentral.Part.BOM.AddNextRootNodeError");
                                                        
  //Multitenant                                                     
  /* String AddNextFindNumber          = i18nNow.getI18nString("emxEngineeringCentral.Part.BOM.AddNextFailedFindNumberNotFound",
                                                        "emxEngineeringCentralStringResource", 
                                                        language); */
  String AddNextFindNumber          = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
		  context.getLocale(),"emxEngineeringCentral.Part.BOM.AddNextFailedFindNumberNotFound");
                                                        
  //Multitenant
  /* String strErrorMessage            = i18nNow.getI18nString("emxEngineeringCentral.Part.BOM.AddNextFail",
                                                        "emxEngineeringCentralStringResource", 
                                                        language); */
  String strErrorMessage            = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
		  context.getLocale(),"emxEngineeringCentral.Part.BOM.AddNextFail");
                                                        
  //Multitenant
  /* String strInvalidSelectionMsg = i18nNow.getI18nString("emxEngineeringCentral.CommonView.Alert.Invalidselection",
                                                    "emxEngineeringCentralStringResource", 
                                                    language); */
  String strInvalidSelectionMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
		  context.getLocale(),"emxEngineeringCentral.CommonView.Alert.Invalidselection");
  
                                                                                                       
  String sSymbolicRelEBOMName = FrameworkUtil.getAliasForAdmin(context,
                                                               "relationship", 
                                                               DomainConstants.RELATIONSHIP_EBOM, 
                                                               true);
  boolean isMBOMInstalled = com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context);
  //Added for V6R2009.HF0.2 - Ends

    //Added for R208.HF1 - Starts
    boolean inlineFlag = false;
  //Multitenant
    /* String inlineErrorMessage       = i18nNow.getI18nString("emxEngineeringCentral.Common.InlineErrorMessage",
                                                        "emxEngineeringCentralStringResource", language); */
    String inlineErrorMessage       = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
    		context.getLocale(),"emxEngineeringCentral.Common.InlineErrorMessage");
    //Added for R208.HF1 - Ends
  if (tableRowIdList!= null) {
    for (int i=0; i< tableRowIdList.length; i++) {
       //process - relId|objectId|parentId|rowid - using the tableRowId
       String tableRowId = tableRowIdList[i];
       //Modified for V6R2009.HF0.2 - Starts
       StringList slList = FrameworkUtil.split(" "+tableRowId, "|");
       selPartRelId     = ((String)slList.get(0)).trim();
       selPartObjectId  = ((String)slList.get(1)).trim();
       selPartParentOId = ((String)slList.get(2)).trim();
       sRowId           = ((String)slList.get(3)).trim();
       //Modified for V6R2009.HF0.2 - Ends
        //Added for R208.HF1 - starts
        if ("".equals(selPartObjectId) || selPartObjectId == null) {
            inlineFlag = true;
            break;
        }
        //Added for R208.HF1 - ends
       }
       }
    
    // for blocking the Add Next New/Existing operation if the selected part is configured Part  
    String selectedPartPolicy = "";
    String POLICY_CONFIGURED_PART = PropertyUtil.getSchemaProperty(context, "policy_ConfiguredPart");
    String strConfiguredBOMInvalidMessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
  		  context.getLocale(),"emxEngineeringCentral.Part.BOM.OperationInvalid");
    String rangeEAeach = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource", new Locale("en"), "emxFramework.Range.Unit_of_Measure.EA_(each)");
    if ( selPartParentOId != null && !"".equals(selPartParentOId) && !"null".equalsIgnoreCase(selPartParentOId) ) {
    	selectedPartPolicy = DomainObject.newInstance(context, selPartParentOId).getPolicy(context).getName();	
    }
 // for blocking the Add Next New/Existing operation if the selected part is configured Part
    
    
  //Added for V6R2009.HF0.2 - Starts
  if(selPartParentOId != null && !"".equals(selPartParentOId) && !"null".equals(selPartParentOId)){
    DomainObject ctxObj = DomainObject.newInstance(context);
    ctxObj.setId(selPartParentOId);

    StringList slSelectables = new StringList();
    slSelectables.add(DomainConstants.SELECT_POLICY);
    slSelectables.add(DomainObject.SELECT_CURRENT);

    Map mapSelects = ctxObj.getInfo(context,slSelectables);

    String strPolicy      = (String)mapSelects.get(DomainConstants.SELECT_POLICY);
    String strCurrent     = (String)mapSelects.get(DomainObject.SELECT_CURRENT);

    if ((strPolicy.equals(DomainConstants.POLICY_DEVELOPMENT_PART) && !strCurrent.equals(DomainConstants.STATE_DEVELOPMENT_PART_COMPLETE)) || (strPolicy.equals(DomainConstants.POLICY_EC_PART) && strCurrent.equals(DomainConstants.STATE_PART_PRELIMINARY)) ) {
        FNFlag = true;
    }
  }
//Added for V6R2009.HF0.2 - Ends
%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" type="text/javaScript">
//Added for V6R2009.HF0.2 - Starts
//Modified for IR042348V6R2011
var contentFrame   = findFrame(parent,"listHidden");
contentFrame       = contentFrame.parent;
var arrValidator   = contentFrame.getAllValidators();
var mxRoot         = contentFrame.oXML.documentElement;
var dupcurrentCell = contentFrame.currentCell;
var dupemxUICore   = contentFrame.emxUICore;
var dupcolMap      = contentFrame.colMap;
//XSSOK
var fnFlag         = "<%=FNFlag%>";
//Added for V6R2009.HF0.2 - Ends
//XSSOK
var calledMethod = "<%=XSSUtil.encodeForJavaScript(context,calledMethod)%>";
//XSSOK
var isMBOMInstalled = "<%=isMBOMInstalled%>";
var WorkUnderOID = "";
try{
if(calledMethod == "AddNext")
{
        //Added for V6R2009.HF0.2 - Starts
        //XSSOK
        var object = dupcolMap.getColumnByName("<%=DomainConstants.ATTRIBUTE_FIND_NUMBER%>");
        // If the BOM Page doesn't have Find Number column
        if(object == null || (typeof object == 'undefined')){
        	//XSSOK
            alert("<%=AddNextFindNumber%>");
        }
        // If the selected row is a root node
        //XSSOK
        else if("<%=sRowId%>" == "0"){
        	//XSSOK
            alert("<%=AddNextRootNode%>");
        }
        //Added for R208.HF1 - starts
        //XSSOK
        else if ("<%=inlineFlag%>" == "true") {
            //XSSOK
        	alert("<%=inlineErrorMessage%>");
        }

        //Added for R208.HF1 - ends
        else{
        	//XSSOK
		   var retValue = <%=XSSUtil.encodeForJavaScript(context,calledMethod)%>('<%=XSSUtil.encodeForJavaScript(context,objectId)%>','<%=selPartRelId%>','<%=selPartObjectId%>','<%=selPartParentOId%>','<%=XSSUtil.encodeForJavaScript(context,strAddNext)%>','<%=XSSUtil.encodeForJavaScript(context,struiType)%>','<%=XSSUtil.encodeForJavaScript(context,stromitSpareParts)%>');
        }
        //Added for V6R2009.HF0.2 - Ends
}
}
catch(e){
	//XSSOK
    alert("<%=strErrorMessage%>"+e.message);
}

/**************************************************************************/
/* function validateSelectedRows() - This function validates the slected  */
/* row if it is a newly added row. It checks for each column in the table */
/* if there is any validate program has set. If set it validates the same */
/* for the selected row.                                                  */
/* Added for V6R2009.HF0.2                                                */
/**************************************************************************/
function validateSelectedRows(checkedRow){
    try{
        for(var j=0;j<arrValidator.length;j++){
            var msg = "";
            var index = arrValidator[j].getColumnIndex()+1;
            var theValidator = arrValidator[j].getColumnFunction();
            var column = dupemxUICore.selectSingleNode(checkedRow, "c["+index+"]");
            dupcurrentCell.target = column;
            dupcurrentCell.target.setAttribute("position",index);
            contentFrame.currentRow = dupcurrentCell.target.parentNode;
            contentFrame.currentColumnPosition = index;                    

            var cellVal = "";
            if(column.lastChild){
                cellVal = column.lastChild.nodeValue;
            }else{
                cellVal = column.nodeValue;
}
            if(cellVal == null){
                cellVal = "";
            }
            var theColumn = dupcolMap.getColumnByIndex(index-1);
            var strInputType = theColumn.getSetting("Input Type");
            if(strInputType != undefined && strInputType == "combobox"){
                var tempCellVal = theColumn.getRangeValues(cellVal);
                if(tempCellVal!=undefined || tempCellVal!=null){
                    cellVal = tempCellVal;
                }                    
            }
            msg = contentFrame.eval(theValidator + "('" +cellVal+ "')");
            if(msg != true){
                return false;
            }
        }
    }
    catch(e){
        throw e;
    }
    return true;
}

//Instance Management Legacy data

/**************************************************************************/
/* function getActualValueForOtherColumn() - the main functionality of this method is to read the column values on selected row    */
/**************************************************************************/
function getActualValueForOtherColumn(contentFrame,colName,curFNObj){
    
    var objColumn = contentFrame.parent.colMap.getColumnByName(colName);
    var colIndex = objColumn.index;

    return (dupemxUICore.selectSingleNode(curFNObj, "c[" + colIndex + "]").getAttribute("a"));
}

/**************************************************************************/
/* function isLagacyComponent() - the main functionality of this method is to  validate if the selected row is in legacy data mode    */

/**************************************************************************/
function isLagacyComponent(contentFrame, checkedRow){
	var selRowUOM = getActualValueForOtherColumn(contentFrame,"UOM",checkedRow);
  	var selRowQuantity = getActualValueForOtherColumn(contentFrame,"Quantity",checkedRow);
  	//XSSOK
  	if(selRowUOM=="<%=rangeEAeach%>" && selRowQuantity > "1.0"){
  			return true;
  		}
	 
}

//ENG of Instance management

/**************************************************************************/
/* function AddNext() - the main functionality of this method is to pop   */
/* a serarch dialog page to select the part(s). this fucntion checks the  */
/* following conditions:                                                  */
/*      1. If the selected row is a newly added, validates the row.       */
/*      2. Validates the Find number if the selected part's Parent is     */
/*         not in preliminary state.                                      */
/*      3. Validates the deleted parts.                                   */
/* Modified for V6R2009.HF0.2                                             */
/**************************************************************************/
function AddNext(objectId,selPartRelId,selPartObjectId,selPartParentOId,AddNext,uiType,omitSpareParts)
{
    //Modified for V6R2009.HF0.2 - Starts
    try{
        // get the selected row from the BOM Page
        var xCheckedPath = "/mxRoot/rows//r[@checked='checked']";
        var SBselRow     = dupemxUICore.selectSingleNode(mxRoot, xCheckedPath);
		
        //Instance Management Legacy data
        var isInstaceMode = "<%=isInstaceMode%>";
        if(isInstaceMode && isInstaceMode=="true"){
        	var cntFrame   = findFrame(parent,"listHidden");
        	var isLegacyComponent = isLagacyComponent(cntFrame,SBselRow);
        	if(isLegacyComponent){
        		//XSSOK
        		 alert("<%=strInstanceModeErrorMessage%>");
                 return false;
        	}
        }
        //ENG of Instance management
        
        // if the selected row is deleted row
        var markup       = SBselRow.getAttribute("status");
        if(markup!=null && (typeof markup != 'undefined') && markup == "cut"){
        	//XSSOK
            alert("<%=AddNextOnDeletedRow%>");
            return false;
        }
        // if the selected row is newly added row.
        else if (markup == 'add'){
            var msg = validateSelectedRows(SBselRow);
            if(msg != true){
                return false;
            }
        }
if(isMBOMInstalled == "true"){
        var rel          = SBselRow.getAttribute("rel");
        if(rel == null){
            rel          = SBselRow.getAttribute("relType");
            if(rel){
                var arrRel = rel.split("|");
                rel = arrRel[0];
            }
        }
        // if the selected row is not a primary part.
        //XSSOK
        if(rel != null && rel != "<%=DomainConstants.RELATIONSHIP_EBOM%>" && rel != "<%=sSymbolicRelEBOMName%>"){
        	//XSSOK
            alert("<%=strInvalidSelectionMsg%>");
            return false;
        }
}
        // If the selected part's parent is not in Preliminary state
        if(SBselRow!=null && (typeof SBselRow != 'undefined') && fnFlag == "false"){
        	//XSSOK
            var object = dupcolMap.getColumnByName("<%=DomainConstants.ATTRIBUTE_FIND_NUMBER%>");
            var obj    = dupemxUICore.selectSingleNode(SBselRow, "c["+object.index+"]");
            var nV1 = parseInt(dupemxUICore.getText(obj));
            // If the selected part doesn't have Find Number
            if(isNaN(nV1)){
            	//XSSOK
                throw new Error("<%=strErrorMessage%>");
            }

            var dupSBselRow = SBselRow;

            // the following do while loop avoids the Substitutes/Alternates/Split Quantitites
            // and deleted primary parts, if the slected part's next sibling is any one of these.
            // And it looks for the next Sibling.
            do{
                var status = null;
                obj = null;
                var nextRow = dupemxUICore.getNextElement(dupSBselRow);
				if(isMBOMInstalled == "true"){
						if(!nextRow){    break;   }
						var rel = nextRow.getAttribute("rel");
						if(rel == null || (typeof rel == 'undefined')){
							rel = nextRow.getAttribute("relType");
							if(rel){
							var arrRel = rel.split("|");
							rel = arrRel[0];
						}
						}
						//XSSOK
						if(rel != "<%=DomainConstants.RELATIONSHIP_EBOM%>" && rel != "<%=sSymbolicRelEBOMName%>"){
							dupSBselRow = nextRow;
							status = "cut";
						}
						else if(nextRow != null && (typeof nextRow != 'undefined')){
							obj    = dupemxUICore.selectSingleNode(nextRow, "c["+object.index+"]");
							if(obj == null || (typeof obj == 'undefined')){
								break;
							}
							status = nextRow.getAttribute("status");
							dupSBselRow = nextRow;
						}
				}else{
                if(nextRow != null && (typeof nextRow != 'undefined')){
                    obj    = dupemxUICore.selectSingleNode(nextRow, "c["+object.index+"]");
                    if(obj == null || (typeof obj == 'undefined')){
                        break;
                    }
                    status = nextRow.getAttribute("status");
                    dupSBselRow = nextRow;
                }
				}
            }while(status!=null && status == "cut");

            // If there is no chance to insert inbetween the selected part and the next sibling
            /* ENG SMB */
		<%if(!isENGSMBInstalled){%>
            if(obj != null && (typeof obj != 'undefined')){
                var nV2 = parseInt(dupemxUICore.getText(obj));
                if((nV1 + 1) >= nV2){
                	//XSSOK
                    alert("<%=NumberOfPartsExceed%>");
                    return false;
                }
            }
		<%}%>
        }
        
        // URL for search pate        
        //Modified the url for the fix 672436       
        
		var url = "";
	/* 	var frameName = parent.name;
		var contentFrame = findFrame(getTopWindow(),frameName);
		contentFrame = (contentFrame != null && contentFrame != undefined)? contentFrame : getTopWindow();
 */		var tablemode = "view";
   		if(contentFrame && contentFrame.editableTable && contentFrame.editableTable != null && contentFrame.editableTable != undefined){
   				tablemode = contentFrame.editableTable.mode; 
   		}
   		else{
   			tablemode = "edit";
   		}
		//Modified to fix IR-093961V6R2012, IR-096297V6R2012
		WorkUnderOID = contentFrame.getRequestSetting("ChangeAuthoringContextOID");
		
		if (WorkUnderOID == null || WorkUnderOID == 'undefined' || WorkUnderOID == undefined) {
			WorkUnderOID = "";
		}
		
		//XSSOK
		<%
        if(stromitSpareParts.equalsIgnoreCase("TRUE")){
        	if("AddNewPartNext".equals(sFunctionality)){
        	%>
        	url = "../common/emxCreate.jsp?nameField=both&form=type_CreatePart&submitAction=doNothing&header=emxEngineeringCentral.PartCreate.FormHeader&type=type_Part&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&createMode=EBOM&createJPO=emxPart:createPartJPO&uiType=structureBrowser&addNew=true&contextECO=&postProcessURL=../engineeringcentral/emxENGSMBBOMAddNextPartsProcess.jsp&HelpMarker=emxhelppartcreate&preProcessJavaScript=preProcessInCreatePartIntermediate&typeChooser=true&InclusionList=type_Part&ExclusionList=type_ManufacturingPart,type_ShopperProduct,type_Trim,type_Label,type_Packaging,type_RawGoods,type_HardGoodsMaterial,type_TBD,type_Fabric,type_Finishings,type_GraphicPart&replace=false&SuiteDirectory=engineeringcentral&StringResourceFileId=emxEngineeringCentralStringResource&suiteKey=EngineeringCentral&multiPartCreation=true&functionality=AddNewPartNext&tablemode="+tablemode+"&objectId="+objectId+"&selPartRelId="+selPartRelId+"&selPartObjectId="+selPartObjectId+"&selPartParentOId="+selPartParentOId+"&addNext="+AddNext+"&WorkUnderOID="+WorkUnderOID+"&omitSpareParts="+omitSpareParts+"&selectedRowId=<%=XSSUtil.encodeForJavaScript(context,sRowId)%>";  
        	
		<%} else {%>
			url = "../common/emxFullSearch.jsp?field=TYPES=type_Part:SPARE_PART=No:POLICY=policy_ECPart,policy_DevelopmentPart,policy_StandardPart:CURRENT=policy_ECPart.state_Preliminary,policy_ECPart.state_Review,policy_ECPart.state_Approved,policy_ECPart.state_Release,policy_DevelopmentPart.state_Complete,policy_DevelopmentPart.state_PeerReview,policy_DevelopmentPart.state_Create&showInitialResults=false&table=ENCAffectedItemSearchResult&selection=multiple&excludeOIDprogram=emxENCFullSearch:excludeOIDAddNext&submitURL=../engineeringcentral/emxENGSMBBOMAddNextPartsProcess.jsp&replace=false&tablemode="+tablemode+"&objectId="+objectId+"&selPartRelId="+selPartRelId+"&selPartObjectId="+selPartObjectId+"&selPartParentOId="+selPartParentOId+"&addNext="+AddNext+"&omitSpareParts="+omitSpareParts+"&selectedRowId=<%=XSSUtil.encodeForJavaScript(context,sRowId)%>"+"&formInclusionList=VPM_PRODUCT_NAME";
		<%}
        } else {
		%>
		url = "../common/emxFullSearch.jsp?field=TYPES=type_Part:POLICY=policy_ECPart,policy_DevelopmentPart,policy_StandardPart:CURRENT=policy_ECPart.state_Preliminary,policy_ECPart.state_Review,policy_ECPart.state_Approved,policy_ECPart.state_Release,policy_DevelopmentPart.state_Complete,policy_DevelopmentPart.state_PeerReview,policy_DevelopmentPart.state_Create&showInitialResults=false&table=ENCAffectedItemSearchResult&selection=multiple&excludeOIDprogram=emxENCFullSearch:excludeOIDAddNext&submitURL=../engineeringcentral/emxENGSMBBOMAddNextPartsProcess.jsp&replace=false&tablemode="+tablemode+"&objectId="+objectId+"&selPartRelId="+selPartRelId+"&selPartObjectId="+selPartObjectId+"&selPartParentOId="+selPartParentOId+"&addNext="+AddNext+"&omitSpareParts="+omitSpareParts+"&selectedRowId=<%=XSSUtil.encodeForJavaScript(context,sRowId)%>"+"&formInclusionList=VPM_PRODUCT_NAME";
		<% }%>
        // pops a seach dialog page
        contentFrame.showModalDialog(url, 575, 575);
    }
    catch(e){
        throw e;
    }
    //Modified for V6R2009.HF0.2 - Ends
}
</script>
