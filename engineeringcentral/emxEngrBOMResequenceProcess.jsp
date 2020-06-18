<%--  emxEngrBOMResequenceProcess.jsp -  This page Call the Bean to invoke JPO for resequence BOM.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.engineering.EngineeringConstants"%>

<jsp:useBean id="resequenceBean" class="com.matrixone.apps.engineering.Part" scope="session" />
<%
    // Get the parameters from request object
String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
String objId = emxGetParameter(request, "objectId");
    String language           = request.getHeader("Accept-Language");

    // Added for V6R2009.HF0.2 - Starts
    //Property entries
    boolean isMBOMInstalled = com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context);
	//IR-028428 : Given a condition before getting from the MBOM Properties file
    String strAutoUpdateFindNumber = null;
    if(isMBOMInstalled){
    strAutoUpdateFindNumber        = FrameworkProperties.getProperty(context, "emxMBOM.AutoUpdateFindNumber");
    }
    if(strAutoUpdateFindNumber == null || "null".equals(strAutoUpdateFindNumber)){
        strAutoUpdateFindNumber = "false";
    }

String newFindNumberValue = FrameworkProperties.getProperty(context, "emxEngineeringCentral.Resequence.InitialValue");
String incrementValue = FrameworkProperties.getProperty(context, "emxEngineeringCentral.Resequence.IncrementValue");
    String sSymbolicRelEBOMName = FrameworkUtil.getAliasForAdmin(context,
                                                                 "relationship", 
                                                                 DomainConstants.RELATIONSHIP_EBOM, 
                                                                 true);
    
  //Multitenant
    /* String sCutRowWrngMsg = i18nNow.getI18nString("emxEngineeringCentral.Part.BOM.ResequenceOnDeleted",
                                                  "emxEngineeringCentralStringResource", 
                                                   language); */
    String sCutRowWrngMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Part.BOM.ResequenceOnDeleted");
    
    //Multitenant
    /* String expandProblem      = i18nNow.getI18nString("emxEngineeringCentral.Part.BOM.ExpandInMozilla",
                                                  "emxEngineeringCentralStringResource", 
                                                   language); */
    String expandProblem      = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Part.BOM.ExpandInMozilla");
    
	//Multitenant
    /* String strErrorMessage    =  i18nNow.getI18nString("emxEngineeringCentral.Part.BOM.ResequenceFail",
                                                  "emxEngineeringCentralStringResource", 
                                                   language); */
	String strErrorMessage    =EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Part.BOM.ResequenceFail");
    
	//Multitenant
    /* String strProcessing         =  i18nNow.getI18nString("emxEngineeringCentral.Part.BOM.Processing",
                                                  "emxEngineeringCentralStringResource", 
                                                   language); */
    String strProcessing         =  EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Part.BOM.Processing");
    // Added for V6R2009.HF0.2 - Ends
    //Added R208.HF1 - Starts
    boolean inlineFlag = false;
  //Multitenant
    /* String inlineErrorMessage       = i18nNow.getI18nString("emxEngineeringCentral.Common.InlineErrorMessage",
                                                    "emxEngineeringCentralStringResource", language); */
    String inlineErrorMessage       = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.InlineErrorMessage");
    //Added R208.HF1 - Ends

    String strPolicyAndAllowedStates = FrameworkProperties.getProperty(context, "emxEngineeringCentral.Resequence.AllowedStates");

    StringList policyAndAllowedStatesList=FrameworkUtil.split(strPolicyAndAllowedStates, ",");
	Map policyAndAllowedStatesMap=new HashMap();
	String strTemp;
	String stringPolicyActual;
	String stringPolicy;
	for(int i=0;i<policyAndAllowedStatesList.size();i++){
	  strTemp=(String) policyAndAllowedStatesList.get(i);
	  stringPolicy=strTemp.substring(0,strTemp.indexOf(':'));
	  stringPolicyActual=PropertyUtil.getSchemaProperty(context,stringPolicy);
	  String strStates=strTemp.substring(strTemp.indexOf(':')+1);
	  StringList statesList=FrameworkUtil.split(strStates, "|");
	  StringList statesListActual=new StringList();
	  for(int j=0;j<statesList.size();j++){
		  strTemp=(String) statesList.get(j);
		  statesListActual.add(PropertyUtil.getSchemaProperty(context,"policy",stringPolicyActual,strTemp));
	  }
	  policyAndAllowedStatesMap.put(stringPolicyActual, statesListActual);
	}
  
  int newValue = 10;
    try{
  	newValue = Integer.parseInt(newFindNumberValue);
  }
  catch (Exception ex)
  {
	  newValue = 10;
  }

  int incrValue = 10;
    try{
  	incrValue = Integer.parseInt(incrementValue);
  }
  catch (Exception ex)
  {
	  incrValue = 10;
  }

    // Modified for V6R2009.HF0.2 - Starts
boolean blnValid = false;
    String objectId = "";
    String sRowId = "0";
    String validNames = "";
    String validObjects = "";
    String invalidObjects = "";
    String selPartParentOId="";
    String strPolicy ="";
    String strCurrent = "";
String callbackFunctionName = "loadMarkUpXML";
StringList spartList=new StringList();
    try {
if (tableRowIdList==null) {
            tableRowIdList = new String[1];
            tableRowIdList[0] = "|"+objId+"||0";
}

        for(int i=0;i<tableRowIdList.length;i++){
            StringList slList = FrameworkUtil.split(" "+tableRowIdList[i], "|");
            objectId  = ((String)slList.get(1)).trim();
            selPartParentOId  = ((String)slList.get(2)).trim();
            sRowId    = ((String)slList.get(3)).trim();
            //Added R208.HF1 - Starts
            if ("".equals(objectId) || objectId == null) {
                inlineFlag = true;
                break;
            }
            //if the selected part is parent part
            if("0".equals(sRowId)){
                selPartParentOId = objectId;
            }
            StringList selectList = new StringList();
            selectList.add(DomainConstants.SELECT_POLICY);
            selectList.add(DomainConstants.SELECT_CURRENT);
            selectList.add(DomainConstants.SELECT_NAME);
            selectList.add("policy.property[PolicyClassification].value");
            
            //Added R208.HF1 - Ends
            DomainObject doPart = new DomainObject(objectId);

            Map selectedMap = (Map)doPart.getInfo(context, selectList);

            strPolicy = (String)selectedMap.get(DomainConstants.SELECT_POLICY);
            strCurrent = (String)selectedMap.get(DomainConstants.SELECT_CURRENT);
            String strName = (String)selectedMap.get(DomainConstants.SELECT_NAME);
            String policyClass = (String)selectedMap.get("policy.property[PolicyClassification].value");
            
            //if ((strPolicy.equals(DomainConstants.POLICY_DEVELOPMENT_PART) && !strCurrent.equals(DomainConstants.STATE_DEVELOPMENT_PART_COMPLETE)) || (strPolicy.equals(DomainConstants.POLICY_EC_PART) && strCurrent.equals(DomainConstants.STATE_PART_PRELIMINARY)) ) {
            if ( !"Unresolved".equalsIgnoreCase(policyClass) && policyAndAllowedStatesMap.containsKey(strPolicy) && ((StringList)policyAndAllowedStatesMap.get(strPolicy)).contains(strCurrent) ) {
                if(!"".equals(validObjects)){
                    validObjects += "^";
                    validNames += "^";
                }
                validObjects += objectId + "|" +sRowId;
                validNames += strName;
                blnValid = true;
            }
            else{
              if (!spartList.contains(strName)) {							            	
            	  spartList.add(strName);
              }
          }
        }
            
        if (!spartList.isEmpty()) {
        	invalidObjects = FrameworkUtil.join(spartList, ",");
        }
            
    } catch (Exception ex) {
        throw ex;
    }
    // Modified for V6R2009.HF0.2 - Ends
%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript">
    // Added for V6R2009.HF0.2 - Starts
    var aAllRows = null;
    var cutRowMsg = "";
    var expandProblem = "";
    var dialogLayerOuterDiv, dialogLayerInnerDiv, iframeEl;
    //XSSOK
    var CONST_FN       = "<%=DomainConstants.ATTRIBUTE_FIND_NUMBER%>";
    //XSSOK
    var CONST_RD       = "<%=DomainConstants.ATTRIBUTE_REFERENCE_DESIGNATOR%>";
    //XSSOK
    var CONST_CONFIGURED_POLICY       = "<%=EngineeringConstants.POLICY_CONFIGURED_PART%>";
    //XSSOK
    var CONST_ECPART_CURRENT_PRELIMINARY      = "<%=EngineeringConstants.STATE_EC_PART_PRELIMINARY%>";
    
    

//Modified for IR042348V6R2011
    var contentFrame   = findFrame(parent,"listHidden");
    var dupemxUICore   = contentFrame.parent.emxUICore;
    var dupcolMap      = contentFrame.parent.colMap;
    var dupTimeStamp   = contentFrame.parent.timeStamp;
    var postXML        = null;
    var theRoot        = null;
    var mxRoot         = contentFrame.parent.oXML.documentElement;
    //XSSOK
    var varIsMBOMInstalled = "<%=isMBOMInstalled%>";
    
    // Added for V6R2009.HF0.2 - Ends

</script>
<script language="Javascript">
/**************************************************************************/
/* function addMask() - this function doesn't allows the user to do       */
/* anything while processing Resequence operation.                        */
/* Added for V6R2009.HF0.2                                                */
/**************************************************************************/
function addMask(){
try {
        dialogLayerOuterDiv = contentFrame.parent.document.createElement("div");
        dialogLayerOuterDiv.className = "mx_divLayerDialogMask";
        contentFrame.parent.document.body.appendChild(dialogLayerOuterDiv);
     
        if (isIE) {
            iframeEl = contentFrame.parent.document.createElement("IFRAME");
            iframeEl.frameBorder = 0;
            iframeEl.src = "../common/emxBlank.jsp";
            iframeEl.allowTransparency = true;
            contentFrame.parent.document.body.insertBefore(iframeEl, dialogLayerOuterDiv);
        }

        dialogLayerInnerDiv = contentFrame.parent.document.createElement("div");
        dialogLayerInnerDiv.className = "mx_alert";
        dialogLayerInnerDiv.setAttribute("id", "mx_divLayerDialog");
     
            
        dialogLayerInnerDiv.style.top = contentFrame.parent.editableTable.divPageHead.offsetHeight + 10 + "px";
        dialogLayerInnerDiv.style.left = contentFrame.parent.getWindowWidth()/3 + "px";
        
        contentFrame.parent.document.body.appendChild(dialogLayerInnerDiv);

        var CENTER = contentFrame.parent.document.createElement("CENTER");
        var BOLD = contentFrame.parent.document.createElement("b");
        if(isIE) {
        	//XSSOK
            BOLD.innerText = "<%=strProcessing%>";
        } else {
        	//XSSOK
            BOLD.textContent = "<%=strProcessing%>";
        }

        CENTER.appendChild(BOLD);
        dialogLayerInnerDiv.appendChild(CENTER);
        contentFrame.parent.turnOnProgress();
    }
    catch(e){
    }
}

/**************************************************************************/
/* function removeMask() - Once the Resequence process is finished, it    */
/* removes the added Mask to the BOM Page.                                */
/* Added for V6R2009.HF0.2                                                */
/**************************************************************************/
function removeMask(){
    try{
        contentFrame.parent.document.body.removeChild(dialogLayerInnerDiv);
        contentFrame.parent.document.body.removeChild(dialogLayerOuterDiv);
        
        if(isIE){
            contentFrame.parent.document.body.removeChild(iframeEl);
        }
        contentFrame.parent.turnOffProgress();
    }
    catch(e){
        }
      }
/**************************************************************************/
/* function trim() - This function trims at both the ends for a given     */
/* String value.                                                          */
/* Added for V6R2009.HF0.2                                                */
/**************************************************************************/
function trim(str){
    try{
        while(str.length != 0 && str.substring(0,1) == ' '){
            str = str.substring(1);
        }
        
        while(str.length != 0 && str.substring(str.length -1) == ' '){
            str = str.substring(0, str.length -1);
        }
    }
    catch(e){
    }
    return str;
}

/**************************************************************************/
/* function updateNextAltSubSibling() - This function automaticaly updates*/
/* the Find Number for Substitute/Alternate if the                        */
/* Primary is updated.                                                    */
/* Added for V6R2009.HF0.2                                                */
/**************************************************************************/
function updateNextAltSubSibling(currentRow, newFN){
    try{
        do{
            var nextElement = dupemxUICore.getNextElement(currentRow);
            var rel = nextElement.getAttribute("rel");
            if(rel == null || (typeof rel == 'undefined')){
                rel = nextElement.getAttribute("relType");
                if(rel){
                    var arrRel = rel.split("|");
                    rel = arrRel[0];
                }
            }
            if(rel && rel!="EBOM" && rel!="relationship_EBOM"){
                nextElement.setAttribute("markup","changed");

                var newNodeMarked = postXML.createElement("object");
                newNodeMarked.setAttribute("objectId",nextElement.getAttribute("o"));
                newNodeMarked.setAttribute("relId",nextElement.getAttribute("r"));
                newNodeMarked.setAttribute("parentId",nextElement.getAttribute("p"));

                newNodeMarked.setAttribute("markup","changed");
                var colNode = postXML.createElement("column");
                colNode.setAttribute("name",CONST_FN);
                colNode.setAttribute("edited","true");
                var textNode = postXML.createTextNode(newFN);

                colNode.appendChild(textNode);
                newNodeMarked.appendChild(colNode);
                theRoot.appendChild(newNodeMarked);
            }
            currentRow = nextElement;

        }while(rel!="EBOM" && rel!="relationship_EBOM");
    }
    catch(err){
        throw err;
    }
}

/**************************************************************************/
/* function updateSASQFindNumner() - This function automaticaly updates   */
/* the Find Number for Substitute/Alternate/Split quantities if the       */
/* Primary is updated.                                                    */
/* Added for V6R2009.HF0.2                                                */
/**************************************************************************/
function updateSASQFindNumner(currentRow, newFN){
    try{
        var duppostDataXML = contentFrame.parent.postDataXML.documentElement;
        var arrUndoRows    = contentFrame.parent.arrUndoRows;
        var iLevel = currentRow.getAttribute("level");
        var FN = "";
        var objColumnFN  = dupcolMap.getColumnByName(CONST_FN);
        var objFN    = dupemxUICore.selectSingleNode(currentRow, "c["+objColumnFN.index+"]");
        if(objFN){
        FN  = dupemxUICore.getText(objFN);
        }
        else{
            return false;
        }

        var NM  = "";
        var objColumnNM  = dupcolMap.getColumnByName("Name");
        var objNM    = dupemxUICore.selectSingleNode(currentRow, "c["+objColumnNM.index+"]");
        if(objNM){
            NM  = dupemxUICore.getText(objNM);
        }
        else{
            return ;
        }

        var xPath = "/mxRoot/rows//r[@level = '" + iLevel + "'";
        xPath += " and (node() = 'Substitute' or node() = 'Alternate')";
        xPath += " and node() = '"+ trim(NM) +"'";
        xPath += "]";

        var modifiedParentRowId = currentRow.parentNode.getAttribute("id");
        var existintRows = dupemxUICore.selectNodes(mxRoot, xPath);
        for(var raara=0; raara<existintRows.length;raara++){
            var subORalt = existintRows[raara];
            var childParentRowId = subORalt.parentNode.getAttribute("id");
            if(childParentRowId != modifiedParentRowId){
                continue;
            }
            var objsaFN    = dupemxUICore.selectSingleNode(subORalt, "c["+objColumnFN.index+"]");
            var saFN  = dupemxUICore.getText(objsaFN);

            if(saFN!=FN){
                continue;
            }

            var currMarkupRow = null;
            var xMarkupPath = "/mxRoot//object[@objectId = '"+ subORalt.getAttribute("o") +"'";
            xMarkupPath += " and @rowId = '"+ subORalt.getAttribute("id") +"']";

            var currMarkupRows = dupemxUICore.selectNodes(duppostDataXML, xMarkupPath);

            if(currMarkupRows.length > 0){
                if(currMarkupRows.length == 2){
                    var markup1 = currMarkupRows[0].getAttribute("markup");
                    var markup2 = currMarkupRows[1].getAttribute("markup");
                    if(markup1 == "cut"){
                        var currentNode = currMarkupRows[1];
                        currentNode.parentNode.removeChild(currentNode);
                        currMarkupRow = currMarkupRows[0];
                    }
                    if(markup2 == "cut"){
                        var currentNode = currMarkupRows[0];
                        currentNode.parentNode.removeChild(currentNode);
                        currMarkupRow = currMarkupRows[1];
                    }

                    if(markup1 == "add"){
                        currMarkupRow = currMarkupRows[0];
                    }
                    if(markup2 == "add"){
                        currMarkupRow = currMarkupRows[1];
                    }
                }
                else{
                    currMarkupRow = currMarkupRows[currMarkupRows.length-1];
                }
            }

            if(currMarkupRow != null && (typeof currMarkupRow != 'undefined')){
                var markup = currMarkupRow.getAttribute("markup");
                if(markup == null || (typeof markup == 'undefined')){
                    currMarkupRow.setAttribute("markup","changed");

                    var newNodeMarked = postXML.createElement("object");
                    newNodeMarked.setAttribute("objectId",subORalt.getAttribute("o"));
                    newNodeMarked.setAttribute("relId",subORalt.getAttribute("r"));
                    newNodeMarked.setAttribute("parentId",subORalt.getAttribute("p"));

                    newNodeMarked.setAttribute("markup","changed");
                    var colNode = postXML.createElement("column");
                    colNode.setAttribute("name",CONST_FN);
                    colNode.setAttribute("edited","true");
                    var textNode = postXML.createTextNode(newFN);

                    colNode.appendChild(textNode);
                    newNodeMarked.appendChild(colNode);
                    theRoot.appendChild(newNodeMarked);
                }
                else if(markup == "add" || markup == "changed"){
                    var nRootNoderowId = subORalt.getAttribute("id");
                    var colNode = postXML.createElement("column");
                    colNode.setAttribute("name",CONST_FN);
                    colNode.setAttribute("edited","true");

                    var textNode = postXML.createTextNode(newFN);
                    
                    colNode.appendChild(textNode);
                    currMarkupRow.appendChild(colNode);

                    var object = dupcolMap.getColumnByName(CONST_FN);
                    var obj    = dupemxUICore.selectSingleNode(subORalt, "c["+object.index+"]");
                    var nV = obj.getAttribute("d");
                    if(nV == null || (typeof nV == 'undefined')){
                        nV = obj.childNodes[0].nodeValue;
                    }
                    obj.setAttribute("edited","true");
                    if(nV != newFN){
                        obj.setAttribute("d", nV);
                        obj.setAttribute("a", nV);
                    }
                    dupemxUICore.setText(obj, newFN);

                    // this code is for Reset operation
                    var MxRootPath = "/mxRoot/columns//column";
                    var nColumn = dupemxUICore.selectNodes(mxRoot, MxRootPath);
                    var columnCount;
                    
                    var nColumnToChang = CONST_FN;
                    var nColumnValue   = nV;
                    for(var checkCount=0;checkCount<nColumn.length;checkCount++){
                        var Tempname=nColumn[checkCount].getAttribute("name");
                        if(Tempname==nColumnToChang){
                            columnCount = checkCount+1;
                            break;
                        }
                    }
                    if(!arrUndoRows[nRootNoderowId]) {
                        arrUndoRows[nRootNoderowId] = new Object();
                    }

                    if(!arrUndoRows[nRootNoderowId][columnCount - 1]){
                        arrUndoRows[nRootNoderowId][columnCount - 1] = nV;
                    }
                }
            }
            else{
                var newNodeMarked = postXML.createElement("object");
                newNodeMarked.setAttribute("objectId",subORalt.getAttribute("o"));
                newNodeMarked.setAttribute("relId",subORalt.getAttribute("r"));
                newNodeMarked.setAttribute("parentId",subORalt.getAttribute("p"));

                newNodeMarked.setAttribute("markup","changed");
                var colNode = postXML.createElement("column");
                colNode.setAttribute("name",CONST_FN);
                colNode.setAttribute("edited","true");
                var textNode = postXML.createTextNode(newFN);
                
                colNode.appendChild(textNode);
                newNodeMarked.appendChild(colNode);
                theRoot.appendChild(newNodeMarked);
            }
        }
    }
    catch(e){
        throw e;
    }
    return true;
}

/**************************************************************************/
/* function constructElement() - This function Constructs the markup      */
/* element and updates postXML or postDataXML with latest Find Number.    */
/* Added for V6R2009.HF0.2                                                */
/**************************************************************************/
function constructElement(currentRow, FNDef, FNIcr){
    try{
        var duppostDataXML = contentFrame.parent.postDataXML.documentElement;
        var arrUndoRows    = contentFrame.parent.arrUndoRows;
        var currMarkupRow = null;
        // get the current BOM Part xml from the postDataXML
        var currMarkupRows = dupemxUICore.selectNodes(duppostDataXML, "/mxRoot//object[@objectId = '"+ currentRow.getAttribute("o") +"' and @rowId = '"+ currentRow.getAttribute("id") +"']");

        // removing the duplicate markup XMLs if found
        if(currMarkupRows.length > 0){
            if(currMarkupRows.length == 2){
                var markup1 = currMarkupRows[0].getAttribute("markup");
                var markup2 = currMarkupRows[1].getAttribute("markup");
                if(markup1 == "cut"){
                    var currentNode = currMarkupRows[1];
                    currentNode.parentNode.removeChild(currentNode);
                    currMarkupRow = currMarkupRows[0];
                }
                if(markup2 == "cut"){
                    var currentNode = currMarkupRows[0];
                    currentNode.parentNode.removeChild(currentNode);
                    currMarkupRow = currMarkupRows[1];
                }

                if(markup1 == "add"){
                    currMarkupRow = currMarkupRows[0];
                }
                if(markup2 == "add"){
                    currMarkupRow = currMarkupRows[1];
                }
            }
            else{
                currMarkupRow = currMarkupRows[currMarkupRows.length-1];
            }
        }

        // If markup xml found in postDataXML
        if(currMarkupRow != null && (typeof currMarkupRow != 'undefined')){
            var markup = currMarkupRow.getAttribute("markup");
            //if no markup is found
            // update the theRoot xml
            if(markup == null || (typeof markup == 'undefined')){
                //currMarkupRow.setAttribute("markup","changed");

                var newNodeMarked = postXML.createElement("object");
                newNodeMarked.setAttribute("objectId",currentRow.getAttribute("o"));
                newNodeMarked.setAttribute("relId",currentRow.getAttribute("r"));
                newNodeMarked.setAttribute("parentId",currentRow.getAttribute("p"));
                //Below code added for resequencing
                newNodeMarked.setAttribute("currentRowId",currentRow.getAttribute("id"));

                newNodeMarked.setAttribute("markup","changed");
                var colNode = postXML.createElement("column");
                colNode.setAttribute("name",CONST_FN);
                colNode.setAttribute("edited","true");
                var textNode = postXML.createTextNode(FNDef);
                
                colNode.appendChild(textNode);
                newNodeMarked.appendChild(colNode);
                theRoot.appendChild(newNodeMarked);
                FNDef = FNIcr + FNDef;
            }
            //if it is a addition or changed
            // update the postDataXML
            else if(markup == "add" || markup == "changed"){
                var colNode = postXML.createElement("column");
                colNode.setAttribute("name",CONST_FN);
                colNode.setAttribute("edited","true");

                var textNode = postXML.createTextNode(FNDef);
                
                colNode.appendChild(textNode);
                currMarkupRow.appendChild(colNode);

                var object = dupcolMap.getColumnByName(CONST_FN);
                var obj    = dupemxUICore.selectSingleNode(currentRow, "c["+object.index+"]");
                var nV = obj.getAttribute("d");
                if(nV == null || (typeof nV == 'undefined')){
                    nV = obj.childNodes[0].nodeValue;
                }
                obj.setAttribute("edited","true");
                if(nV != FNDef){
                    obj.setAttribute("d", nV);
                    obj.setAttribute("a", nV);
                }
                dupemxUICore.setText(obj, FNDef);

                var checkCount;
                var columnCount;
                var MxRootPath = "/mxRoot/columns//column";
                var nColumn = dupemxUICore.selectNodes(mxRoot, MxRootPath);
                var nColumnToChang = CONST_FN;
                for(checkCount=0;checkCount<nColumn.length;checkCount++){
                    var Tempname=nColumn[checkCount].getAttribute("name");
                    if(Tempname==nColumnToChang){
                        columnCount = checkCount+1;
                        break;
                    }
                }
                var nRootNoderowId = currMarkupRow.getAttribute("rowId");
                if(!arrUndoRows[nRootNoderowId]) {
                    arrUndoRows[nRootNoderowId] = new Object();
                }
                if(!arrUndoRows[nRootNoderowId][columnCount-1]){
                    arrUndoRows[nRootNoderowId][columnCount-1] = nV;
                }
                FNDef = FNIcr + FNDef;
            }
        }
        // If markup xml is not found in the postDataXML
        // update the theRoot xml
        else{
            var newNodeMarked = postXML.createElement("object");
            newNodeMarked.setAttribute("objectId",currentRow.getAttribute("o"));
            newNodeMarked.setAttribute("relId",currentRow.getAttribute("r"));
            newNodeMarked.setAttribute("parentId",currentRow.getAttribute("p"));
            //Below code added for resequencing
            newNodeMarked.setAttribute("currentRowId",currentRow.getAttribute("id"));

            newNodeMarked.setAttribute("markup","changed");
            var colNode = postXML.createElement("column");
            colNode.setAttribute("name",CONST_FN);
            colNode.setAttribute("edited","true");
            var textNode = postXML.createTextNode(FNDef);
            FNDef = FNIcr + FNDef;
            
            colNode.appendChild(textNode);
            newNodeMarked.appendChild(colNode);
            theRoot.appendChild(newNodeMarked);
        }
    }
    catch(e){
        throw e;
    }
    return FNDef;
}

/**************************************************************************/
/* function initialiseAndUpdateVisualCue() - this function helps          */
/* doInitialProcess function to resequence perticular level.              */
/* Added for V6R2009.HF0.2                                                */
/**************************************************************************/
function initialiseAndUpdateVisualCue(objectId, rowId){
	if(varIsMBOMInstalled == "true") {
		return initialiseAndUpdateVisualCueForMBOM(objectId, rowId);
	} else {
		return initialiseAndUpdateVisualCueForEC(objectId, rowId);
	}
}
/**************************************************************************/
/* function initialiseAndUpdateVisualCue() - this function helps          */
/* doInitialProcess function to resequence perticular level.              */
/* Added for V6R2009.HF0.2                                                */
/**************************************************************************/
function initialiseAndUpdateVisualCueForMBOM(objectId, rowId){
    try{
        var bomFilter = window.parent.document.getElementById('ENCBillOfMaterialsViewCustomFilter');
        var bomFilterValue;
        if(!bomFilter){
            var suiteKey = window.parent.document.getElementById('suiteKey');
            if(suiteKey && suiteKey.value == "EngineeringCentral"){
                bomFilterValue = "engineering";
            }
            else{
                bomFilterValue = "common";
            }
        }
        else{
            bomFilterValue = bomFilter.value;
        }

        var autoExpand = false;
        //XSSOK
        var FNDef = parseInt("<%=newValue%>");
        //XSSOK
        var FNIcr = parseInt("<%=incrValue%>");

        // get the one of teh selcted row
        var rowToAdd = dupemxUICore.selectSingleNode(contentFrame.parent.oXML.documentElement, "/mxRoot/rows//r[@o = '" + objectId + "' and @id = '" + rowId + "']");

		if(rowToAdd == null || (typeof rowToAdd == 'undefined')){
			return false;
		}

        // If the selected row is deleted 
        var eleStatus = rowToAdd.getAttribute("status");
        if(eleStatus == "cut"){
        	//XSSOK
            cutRowMsg = "<%=sCutRowWrngMsg%>";
            return false;
        }

        // If the row is not expanded for the first time, expand the row by calling emxFreezePaneGetData.jsp
        var expand = rowToAdd.getAttribute("expand");
        if(expand == null || (typeof expand == 'undefined')){
            try{

                var toolbarData = contentFrame.parent.getToolbarData(contentFrame.parent.editableTable.expandFilter);
                var  whereExp = "&levelId="+ rowId + toolbarData + "|updateTableCache=true&IsStructureCompare=false";
                var oLocalXML = dupemxUICore.getXMLData("emxFreezePaneGetData.jsp?fpTimeStamp=" + dupTimeStamp + whereExp);
                if(oLocalXML){
                    aAllRows = dupemxUICore.selectNodes(oLocalXML.documentElement, "/mxRoot/rows/r");
                }

                if(aAllRows.length != 0){
                    var aAllRows = dupemxUICore.selectNodes(oLocalXML.documentElement, "/mxRoot/rows/r");
                    for (var i = 0; i < aAllRows.length; i++) {
                        rowToAdd.appendChild(aAllRows[i].cloneNode(true));
                    }
                    rowToAdd.setAttribute("display", "block");
                    rowToAdd.setAttribute("expand", "true");
                    var aDisplayRows = dupemxUICore.selectNodes(contentFrame.parent.oXML.documentElement, "/mxRoot/rows//r[(@level = '0' or count(ancestor::r[not(@display) or @display = 'none']) = '0')]");
                    var totalRows = aDisplayRows.length;
                    var nTotalRows = dupemxUICore.selectSingleNode(contentFrame.parent.oXML.documentElement, "/mxRoot/setting[@name = 'total-rows']");
                    dupemxUICore.setText(nTotalRows, totalRows);
                    autoExpand = true;
                }
            }
            // If it fails to expand the row
            catch(e){
            	//XSSOK
                expandProblem = "<%=expandProblem%>";
                return false;
            }
        }
        else{
            rowToAdd.setAttribute("display", "block");
        }

        mxRoot         = contentFrame.parent.oXML.documentElement;

        // Get all the selected row's BOM Structure
        var SBRows   = dupemxUICore.selectNodes(rowToAdd, "r");
        if(aAllRows){
            SBRows = aAllRows;
        }

        // if no BOM structure is found
        if((SBRows.length == 0 && aAllRows == null) || (SBRows.length == 0 && aAllRows.length == 0)){
            return false;
        }

        // iterate all the BOM parts
        for(var i=0;i<SBRows.length;i++){
            var relType = SBRows[i].getAttribute("rel");
            if(relType == null || (typeof relType == 'undefined')){
                relType = SBRows[i].getAttribute("relType");
                if(relType){
                    var arrRel = relType.split("|");
                    relType = arrRel[0];
                }
            }

            // If it is not a Primary part
            //XSSOK
            if(relType != null && relType != "<%=DomainConstants.RELATIONSHIP_EBOM%>" && relType != "<%=sSymbolicRelEBOMName%>"){
                if(autoExpand && bomFilterValue == "common"){
                    //call to update the Find Number for Substitute/Alterante/Split Quantity in existing postDataXML
                    constructElement(SBRows[i], (FNDef - FNIcr), FNIcr);
                }
                continue;
            }

            // If it is a primary part
            //XSSOK
            if(!autoExpand && bomFilterValue == "common" && "<%=strAutoUpdateFindNumber%>" == "true"){
                try{
                    //call to update the Find Number for Substitute/Alterante
                    var retStatus = updateSASQFindNumner(SBRows[i], FNDef);
                    if(retStatus == false){
                        updateNextAltSubSibling(SBRows[i], FNDef);
            }
                }catch(e){
            }
            }

            //finally construct the element for the primary part
            FNDef = constructElement(SBRows[i], FNDef, FNIcr);

        }
    }
    catch(e){
        throw e;
    }
    return true;
}
/**************************************************************************/
/* function initialiseAndUpdateVisualCue() - this function helps          */
/* doInitialProcess function to resequence perticular level.              */
/* Added for V6R2009.HF0.2                                                */
/**************************************************************************/
function initialiseAndUpdateVisualCueForEC(objectId, rowId)
{
    try{
        var arrUndoRows    = contentFrame.parent.arrUndoRows;
        //XSSOK
        var FNDef = parseInt("<%=newValue%>");
        //XSSOK
        var FNIcr = parseInt("<%=incrValue%>");

        if(postXML == null){
            postXML        = dupemxUICore.createXMLDOM();
            postXML.loadXML("<mxRoot/>");
      }

        var rowToAdd = dupemxUICore.selectSingleNode(contentFrame.parent.oXML.documentElement, "/mxRoot/rows//r[@o = '" + objectId + "' and @id = '" + rowId + "']");

		if(rowToAdd == null || (typeof rowToAdd == 'undefined')){
			return false;
		}

        var eleStatus = rowToAdd.getAttribute("status");
        if(eleStatus == "cut"){
        	//XSSOK
            cutRowMsg = "<%=sCutRowWrngMsg%>";
            return false;
      }

        var expand = rowToAdd.getAttribute("expand");

        if(expand == null || (typeof expand == 'undefined')){
            try{

                var toolbarData = contentFrame.parent.getToolbarData(contentFrame.parent.editableTable.expandFilter);
                var  whereExp = "&levelId="+ rowId + toolbarData + "|updateTableCache=true&IsStructureCompare=false";
                var oLocalXML = dupemxUICore.getXMLData("emxFreezePaneGetData.jsp?fpTimeStamp=" + dupTimeStamp + whereExp);
                if(oLocalXML){
                    aAllRows = dupemxUICore.selectNodes(oLocalXML.documentElement, "/mxRoot/rows/r");
                }

                if(aAllRows.length != 0){
                    var aAllRows = dupemxUICore.selectNodes(oLocalXML.documentElement, "/mxRoot/rows/r");
                    for (var i = 0; i < aAllRows.length; i++) {
                        rowToAdd.appendChild(aAllRows[i].cloneNode(true));
                    }
                    rowToAdd.setAttribute("display", "block");
                    rowToAdd.setAttribute("expand", "true");
                    var aDisplayRows = dupemxUICore.selectNodes(contentFrame.parent.oXML.documentElement, "/mxRoot/rows//r[(@level = '0' or count(ancestor::r[not(@display) or @display = 'none']) = '0')]");
                    var totalRows = aDisplayRows.length;
                    var nTotalRows = dupemxUICore.selectSingleNode(contentFrame.parent.oXML.documentElement, "/mxRoot/setting[@name = 'total-rows']");
                    dupemxUICore.setText(nTotalRows, totalRows);
  
                }
            }
            catch(e){
            	//XSSOK
                expandProblem = "<%=expandProblem%>";
                return false;
            }
        }
        else{
            rowToAdd.setAttribute("display", "block");
        }

        theRoot        = postXML.documentElement;
        mxRoot         = contentFrame.parent.oXML.documentElement;
        var duppostDataXML = contentFrame.parent.postDataXML.documentElement;

        var SBRows   = dupemxUICore.selectNodes(rowToAdd, "r");
        if(aAllRows){
            SBRows = aAllRows;
        }

        if((SBRows.length == 0 && aAllRows == null) || (SBRows.length == 0 && aAllRows.length == 0)){
            return false;
        }

        for(var i=0;i<SBRows.length;i++){
            var currMarkupRow = null;
            // get the current BOM Part xml from the postDataXML
            var currMarkupRows = dupemxUICore.selectNodes(duppostDataXML, "/mxRoot//object[@objectId = '"+ SBRows[i].getAttribute("o") +"' and @rowId = '"+ SBRows[i].getAttribute("id") +"']");
    
            // removing the duplicate markup XMLs if found
            if(currMarkupRows.length > 0){
                if(currMarkupRows.length == 2){
                    var markup1 = currMarkupRows[0].getAttribute("markup");
                    var markup2 = currMarkupRows[1].getAttribute("markup");
                    if(markup1 == "cut"){
                        var currentNode = currMarkupRows[1];
                        currentNode.parentNode.removeChild(currentNode);
                        currMarkupRow = currMarkupRows[0];
                    }
                    if(markup2 == "cut"){
                        var currentNode = currMarkupRows[0];
                        currentNode.parentNode.removeChild(currentNode);
                        currMarkupRow = currMarkupRows[1];
                    }
    
                    if(markup1 == "add"){
                        currMarkupRow = currMarkupRows[0];
                    }
                    if(markup2 == "add"){
                        currMarkupRow = currMarkupRows[1];
		}
    }
                else{
                    currMarkupRow = currMarkupRows[currMarkupRows.length-1];
    }
}

            // If markup xml found in postDataXML
            if(currMarkupRow != null && (typeof currMarkupRow != 'undefined')){
                var markup = currMarkupRow.getAttribute("markup");
                //if no markup is found
                // update the theRoot xml
                if(markup == null || (typeof markup == 'undefined')){
                    //currMarkupRow.setAttribute("markup","changed");

                    var newNodeMarked = postXML.createElement("object");
                    newNodeMarked.setAttribute("objectId",SBRows[i].getAttribute("o"));
                    newNodeMarked.setAttribute("relId",SBRows[i].getAttribute("r"));
                    newNodeMarked.setAttribute("parentId",SBRows[i].getAttribute("p"));
                    //Below code added for resequencing
                    newNodeMarked.setAttribute("currentRowId",SBRows[i].getAttribute("id"));

                    newNodeMarked.setAttribute("markup","changed");
                    var colNode = postXML.createElement("column");
                    colNode.setAttribute("name",CONST_FN);
                    colNode.setAttribute("edited","true");
                    var textNode = postXML.createTextNode(FNDef);
                    
                    colNode.appendChild(textNode);
                    newNodeMarked.appendChild(colNode);
                    theRoot.appendChild(newNodeMarked);
                    FNDef = FNIcr + FNDef;
}
                //if it is a addition or changed
                // update the postDataXML
                else if(markup == "add" || markup == "changed"){
                    var colNode = postXML.createElement("column");
                    colNode.setAttribute("name",CONST_FN);
                    colNode.setAttribute("edited","true");

                    var textNode = postXML.createTextNode(FNDef);

                    colNode.appendChild(textNode);
                    currMarkupRow.appendChild(colNode);
            
                    var object = dupcolMap.getColumnByName(CONST_FN);
                    var obj    = dupemxUICore.selectSingleNode(SBRows[i], "c["+object.index+"]");
                    var nV = obj.getAttribute("d");
                    if(nV == null || (typeof nV == 'undefined')){
                        nV = obj.childNodes[0].nodeValue;
                    }
                    obj.setAttribute("edited","true");
                    if(nV != FNDef){
                        obj.setAttribute("d", nV);
                        obj.setAttribute("a", nV);
                    }
                    dupemxUICore.setText(obj, FNDef);

                    var checkCount;
                    var columnCount;
                    var MxRootPath = "/mxRoot/columns//column";
                    var nColumn = dupemxUICore.selectNodes(mxRoot, MxRootPath);
                    var nColumnToChang = CONST_FN;
                    for(checkCount=0;checkCount<nColumn.length;checkCount++){
                        var Tempname=nColumn[checkCount].getAttribute("name");
                        if(Tempname==nColumnToChang){
                            columnCount = checkCount+1;
                            break;
                        }
                    }
                    var nRootNoderowId = currMarkupRow.getAttribute("rowId");
                    if(!arrUndoRows[nRootNoderowId]) {
                        arrUndoRows[nRootNoderowId] = new Object();
                    }
                    if(!arrUndoRows[nRootNoderowId][columnCount-1]){
                        arrUndoRows[nRootNoderowId][columnCount-1] = nV;
                    }
                    FNDef = FNIcr + FNDef;
                }
            }
            // If markup xml is not found in the postDataXML
            // update the theRoot xml
            else{
                var newNodeMarked = postXML.createElement("object");
                newNodeMarked.setAttribute("objectId",SBRows[i].getAttribute("o"));
                newNodeMarked.setAttribute("relId",SBRows[i].getAttribute("r"));
                newNodeMarked.setAttribute("parentId",SBRows[i].getAttribute("p"));
                //Below code added for resequencing
                newNodeMarked.setAttribute("currentRowId",SBRows[i].getAttribute("id"));
            
                newNodeMarked.setAttribute("markup","changed");
                var colNode = postXML.createElement("column");
                colNode.setAttribute("name",CONST_FN);
                colNode.setAttribute("edited","true");
                var textNode = postXML.createTextNode(FNDef);
                FNDef = FNIcr + FNDef;
            
                colNode.appendChild(textNode);
                newNodeMarked.appendChild(colNode);
                theRoot.appendChild(newNodeMarked);
            }
        }
    }
    catch(e){
        throw e;
}

    return true;
}

/**************************************************************************/
/* function doInitialProcess() - This function to resequences all         */
/* selected part's BOM Structure.                                         */
/* Added for V6R2009.HF0.2                                                */
/**************************************************************************/
function doInitialProcess(){
    try{
            // Initialise postXML and theRoot objects.
        if(postXML == null){
            postXML        = dupemxUICore.createXMLDOM();
            postXML.loadXML("<mxRoot/>");
            theRoot        = postXML.documentElement;
        }
    	//XSSOK
        var sNames = "<%=validNames%>";
      //XSSOK
        var sObjects = "<%=validObjects%>";
      //XSSOK
        var sIObjects = "<%=invalidObjects%>";
        //XSSOK
        var sPolicy = "<%=strPolicy%>";
        //XSSOK
        var sCurrent= "<%=strCurrent%>";
        var arrValidIds = sObjects.split("^");
        var arrValidNames = sNames.split("^");

        var errNames = "";
        var cutNames = "";
        var expNames = "";

        //Iterate all the selected parts
        for(var j=0;j<arrValidIds.length;j++){
            var arrCombi = arrValidIds[j].split("|");
            if(arrCombi[0] != null && arrCombi[0] != "" && (typeof arrCombi[0] != "undefiend")){
                // Call to initialiseAndUpdateVisualCue function wit arguments
                //         1. selcted row objectId and
                //         2. selcted rowid
                var retValue = initialiseAndUpdateVisualCue(arrCombi[0], arrCombi[1]);

                // If perticuler selected row is failed to resequence
                if(!retValue){
                    // Reason:1: not able to expand the part to show the BOM Structure
                    if(expandProblem != ""){
                        if(expNames != ""){          expNames += ",";    }
                        expNames += arrValidNames[j];
                        expandProblem = "";
                    }
                    // Reason:2: Selected row is deleted
                    else if(cutRowMsg != ""){
                        if(cutNames != ""){        cutNames += ",";        }
                        cutNames += arrValidNames[j];
                        cutRowMsg = "";
                    }
                    // Reason:3: No BOM Strucuture for selected row
                    else{
                        if(errNames != ""){            errNames += ",";        }
                        errNames += arrValidNames[j];
                    }
                }
            }
        }

        theRoot = postXML.documentElement;
        // Rebuild the view if exisitng postDataXML is modified.
        contentFrame.parent.rebuildView();
        // Render the newly contructed markup XML.
        if(theRoot.childNodes.length > 0){
        	
        //Start : Added for IR-044888V6R2011
         var getChildRowId = eval(contentFrame.parent.emxEditableTable.prototype.getChildRowId);
         var oNodes        = dupemxUICore.selectNodes(postXML,"/mxRoot/object");		 
         //XSSOK
	     var prwId         = '<%=sRowId%>';
		 for(var i = 0; i < oNodes.length; i++)
		 {
			var oNode = oNodes[i];
			var obId  = oNode.getAttribute("objectId");
			var rlId  = oNode.getAttribute("relId");
			//Below code added for resequencing
			var prID = oNode.getAttribute("currentRowId");
			if(prID == null || prID == undefined || prID == 'undefined'){
				prID = getChildRowId(prwId, obId, rlId);
			}
			//var rwId  = getChildRowId(prwId, obId, rlId);
			//End of modification
			oNode.setAttribute("rowId", prID);
		 }
          //XSSOK
  		  var callback = eval(contentFrame.parent.emxEditableTable.prototype.<%=callbackFunctionName%>);
          var oxmlstatus = callback(theRoot.xml, "true");
        }
        //End : IR-044888V6R2011

        var msg = "";
        if(sIObjects != ""){
        	if(sPolicy == CONST_CONFIGURED_POLICY){
            	msg += "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.ConfiguredBOM.ResequenceInvalid</emxUtil:i18nScript>\n ["+ sIObjects + "]\n";
            }
        	else if(sCurrent != CONST_ECPART_CURRENT_PRELIMINARY){
               msg += "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.BOM.ResequenceInvalid</emxUtil:i18nScript>\n ["+ sIObjects + "]\n";
            }
        }
        if(errNames != ""){
            msg += "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.NoBOMFound.Message</emxUtil:i18nScript>\n [" + errNames + "]\n";
        }
        if(cutNames != ""){
        	//XSSOK
            msg += "<%=sCutRowWrngMsg%>\n [" + cutNames + "]\n";
        }

        if(expNames != ""){
        	//XSSOK
            msg += "<%=expandProblem%>\n [" + expNames + "]\n";
        }

        if(msg != ""){
            alert(msg);
        }
      
    }
    catch(e){
        throw e;
    }
}
</script>
<script language="javascript">
// Added for V6R2009.HF0.2 - Starts
try{
    //Added R208.HF1 - Starts
    //XSSOK
    if ("<%=inlineFlag%>" == "false") {
    //Added R208.HF1 - Ends
     setTimeout("addMask()", 500);
        try{
            doInitialProcess();
        }
        catch(e){
        	//XSSOK
            alert("<%=strErrorMessage%>"+e.message);
            setTimeout("removeMask()", 500);
        }
        
    setTimeout("removeMask()", 500);
        //Added R208.HF1 - starts
        } else {
        	//XSSOK
            alert("<%=inlineErrorMessage%>");
        }
        //Added R208.HF1 - ends
	}
catch(e){
   setTimeout("removeMask()", 500);
}
// Added for V6R2009.HF0.2 - Ends
	</script>
