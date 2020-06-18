<%-- emxEngrBOMAddNextPartsProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program

     This JSP is for Add Next operation. this has been created to handle the V6R2009.HF0.2 Multi-level Structure Browser
     Edit functionality.
     This JSP Handles the following functionalities:
        1. This Add Next works on Find Number column.
        2. If the slected part's Parent is in preliminary state it resequenses the same level based on the
           property values emxEngineeringCentral.Resequence.InitialValue and emxEngineeringCentral.Resequence.IncrementValue.
        3. If the selected Part's Parent is not in preliminary state it inserts the selected parts from the search page.
           If it is not possible to insert it pops an alert.
        4. It automatically updates the Substitute/Alternate/Split Quantity objects, if the primary is resequenced.
        5. This JSP code is completely depends on the AEF cache objects. If there is any change in cache objects
           its required to update this page also.
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<jsp:useBean id="connectPart" class="com.matrixone.apps.engineering.Part" scope="session" />

<%@ page import="com.matrixone.apps.domain.util.ContextUtil" %>
<%@ page import="com.matrixone.apps.domain.*"%>
<%@ page import="com.matrixone.apps.engineering.Part"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.dassault_systemes.enovia.partmanagement.modeler.util.ECMUtil"%>
<%@ page import="com.dassault_systemes.enovia.partmanagement.modeler.interfaces.services.IUserFactChangeLogService"%>
<%@ page import="com.dassault_systemes.enovia.partmanagement.modeler.impl.UserFactChangeLogService"%>
<%@page import="com.dassault_systemes.enovia.bom.modeler.util.BOMMgtUIUtil"%>

<jsp:useBean id="createBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session" />
<%
    boolean isMBOMInstalled = EngineeringUtil.isMBOMInstalled(context);
    // variables declarations
    String callbackFunctionName = "loadMarkUpXML";
    String sAllSelIds = "";
    String objectId   = "";
    // Added for V6R2009.HF0.2 - Starts
    String sRowId     = "";
    boolean FNFlag    = false;
    String language   = request.getHeader("Accept-Language");

    String strAutoUpdateFindNumber        = "";// FrameworkProperties.getProperty(context, "emxMBOM.AutoUpdateFindNumber");
    if(strAutoUpdateFindNumber == null || !"true".equalsIgnoreCase(strAutoUpdateFindNumber)){
        strAutoUpdateFindNumber = "false";
    }
    // Property Entries
    String sSymbolicRelEBOMName = FrameworkUtil.getAliasForAdmin(context,
                                                               "relationship",
                                                               DomainConstants.RELATIONSHIP_EBOM,
                                                               true);
    //Multitenant
    /* String strErrorMessage    =  i18nNow.getI18nString("emxEngineeringCentral.Part.BOM.AddNextFail",
                                                  "emxEngineeringCentralStringResource",
                                                   language); */                                               
	String strErrorMessage    =  EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Part.BOM.AddNextFail");
                                                   
    String newFindNumberValue   = FrameworkProperties.getProperty(context, "emxEngineeringCentral.Resequence.InitialValue");
    String incrementValue       = FrameworkProperties.getProperty(context, "emxEngineeringCentral.Resequence.IncrementValue");
    String VPMProductName1 = emxGetParameter(request, "VPMProductName1");
    String VPMProductName = emxGetParameter(request, "VPMProductName");
    String prmode    		= emxGetParameter(request, "prmode");
    String WorkUnderOID    		= emxGetParameter(request, "WorkUnderOID");

    String strVname = (VPMProductName1 == null) ? VPMProductName : VPMProductName1;
    String busVName      = "";
    String strInstanceTitle  = "";
   	Part partObj = null;
   	
    String selPartParentOId = emxGetParameter(request,"selPartParentOId");
    if(selPartParentOId==null) {
        selPartParentOId="";
    }
   	
   	String vpmVisibleColumnValue = BOMMgtUIUtil.getBOMColumnDesignCollaborationValue(context, selPartParentOId, null);
   	String strIsVPMVisible_int = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.isVPMVisible.TRUE");
    String strIsVPMVisible = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", Locale.ENGLISH,"emxFramework.Range.isVPMVisible.TRUE");
   	
   	if ("false".equalsIgnoreCase(vpmVisibleColumnValue)) {
   		strIsVPMVisible_int = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.isVPMVisible.FALSE");
   	    strIsVPMVisible = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", Locale.ENGLISH,"emxFramework.Range.isVPMVisible.FALSE");
   	}
   	
   	String strUOM ="";
   	String strUOM_en ="";
    StringBuffer sbVName = new StringBuffer();
    StringBuffer sbUOM = new StringBuffer();
    StringBuffer sbUOM_en = new StringBuffer();
    StringBuffer sbInstanceTitle = new StringBuffer();
    // Added for V6R2009.HF0.2 - Ends
    
    /*Added for Auto Collab st*/
    ArrayList<String> partList = new ArrayList<String>();
    /*Added for Auto Collab en*/
    
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
incrValue = 1;
    String selPartRelId = emxGetParameter(request,"selPartRelId");
    if(selPartRelId==null) {
        selPartRelId="";
    }
    String selPartObjectId = emxGetParameter(request,"selPartObjectId");
    if(selPartObjectId==null) {
        selPartObjectId="";
    }



    String selectedRowId = emxGetParameter(request,"selectedRowId");
    String sFunctionality = emxGetParameter(request,"functionality");
    int total = 0;
    StringList slnewPartselectables = new StringList();
    slnewPartselectables.add(DomainConstants.SELECT_NAME);
    slnewPartselectables.add(EngineeringConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
  if("AddNewPartNext".equals(sFunctionality))
  {
    context = (matrix.db.Context)request.getAttribute("context");
    String multiObjectCreate    = emxGetParameter(request, "multiPartCreation");
    String strPartObjId  = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "newObjectId")); 
    String noOfParts            = emxGetParameter(request, "NoOfParts");
    String partIds = null;
    String timeStamp            = emxGetParameter(request, "timeStamp");
    
    if("true".equalsIgnoreCase(multiObjectCreate) ){        
        if(noOfParts != null && !"".equals(noOfParts)){
            int partCount = 0;
            try{
                partCount = Integer.parseInt(noOfParts);
                total = partCount;
            }catch(NumberFormatException ne){
                ne.printStackTrace();
                throw new FrameworkException(ne);
            }
            if((partCount>1) && (strPartObjId != null)){
                MapList fields = createBean.getFormFields(timeStamp);
                HashMap requestMap = UINavigatorUtil.getRequestParameterMap(request);
                HashMap requestValuesMap = UINavigatorUtil.getRequestParameterValuesMap(request);
                String timeZone = (String) session.getAttribute("timeZone");
                requestMap.put("RequestValuesMap", requestValuesMap);
                String temp = "";
                partIds = Part.createMultipleParts(context, createBean, requestMap,fields, timeZone, partCount);
           }
        }
    }
    if(partIds == null){
        partIds = strPartObjId;
    }else{
        partIds = strPartObjId + "~" + partIds;
    }
    partIds = partIds.replace("~", ",");
    sAllSelIds = partIds;
    
    StringList objListSize                    = FrameworkUtil.split(sAllSelIds,",");
    int listSize = objListSize.size();
    
    for (int i=0; i < objListSize.size() ;i++)
   		{  
      	      partObj = new Part();
      	    
      	      String sPartId = (String)objListSize.get(i);
              partObj.setId(sPartId);
              
              Map newmap = partObj.getInfo(context,slnewPartselectables);
              busVName      = (String)newmap.get(DomainConstants.SELECT_NAME);
              if(i>0){
            	  sbInstanceTitle.append(",");
              }
              sbInstanceTitle.append(BOMMgtUIUtil.getInstanceTitle(context, sPartId));
              strUOM     = (String)newmap.get(EngineeringConstants.SELECT_ATTRIBUTE_UNITOFMEASURE); 

              if(UIUtil.isNullOrEmpty(strVname)){
              	partObj.setAttributeValue(context, EngineeringConstants.ATTRIBUTE_V_NAME, busVName); 
    			sbVName=sbVName.append(busVName);
      			sbVName=sbVName.append(",");
              }else{
            		busVName=strVname;
              }
              if(UIUtil.isNotNullAndNotEmpty(strUOM)){
            	  	String strUOM_en1 = strUOM;
			String Rang1 = StringUtils.replace(strUOM," ", "_");
         	    	String attrName2 = "emxFramework.Range." + EngineeringConstants.UNIT_OF_MEASURE + "." + Rang1;
         	    	strUOM = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),attrName2);
			sbUOM=sbUOM.append(strUOM);
         	    	sbUOM=sbUOM.append(",");
         	    	sbUOM_en=sbUOM_en.append(strUOM_en1);
           	    	sbUOM_en=sbUOM_en.append(","); 
         	    }
			
              // Auto Sync
              partList.add(sPartId);
  			}
    
    	if(sbVName!=null && sbVName.length()>0){
    		busVName=sbVName.substring(0, sbVName.length()-1);
    	}
    	if(sbUOM!=null && sbUOM.length()>0){
    		strUOM=sbUOM.substring(0, sbUOM.length()-1);
                strUOM_en=sbUOM_en.substring(0, sbUOM_en.length()-1);
    	}
    		strInstanceTitle=sbInstanceTitle.toString();
    	
    	/* Added for VPM auto collab .st */
        	JPO.invoke(context, "enoPartCollaboration", null, "collaboratePartCreate", JPO.packArgs(partList), void.class);
       	/* Added for VPM auto collab .en*/
        	ECMUtil.setWorkUnderChange(context, WorkUnderOID);
        	IUserFactChangeLogService iUserFactChangeLogService = new com.dassault_systemes.enovia.partmanagement.modeler.impl.UserFactChangeLogService();
    		iUserFactChangeLogService.updateObjectUserFact(context, FrameworkUtil.split(partIds, ","), IUserFactChangeLogService.USER_EVENT_OBJECT_CREATE);
    }
    else {
    String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
    total = selectedItems.length;

   for (int i=0; i < selectedItems.length ;i++)
    {
        // Modified for V6R2009.HF0.2 - Starts
        StringList slList = FrameworkUtil.split(" "+selectedItems[i], "|");
        objectId  = ((String)slList.get(1)).trim();
        sRowId    = ((String)slList.get(3)).trim();
	objectId =DomainObject.newInstance(context, objectId).getInfo(context, DomainObject.SELECT_ID);
        if(!sAllSelIds.equals("")){
            sAllSelIds += ",";
        }
        sAllSelIds += objectId.trim();
        // Modified for V6R2009.HF0.2 - Ends
    } 
   StringList objListSize1       = FrameworkUtil.split(sAllSelIds,",");
   int listSize = objListSize1.size();
 
   for (int i=0; i < objListSize1.size() ;i++)
		{  
        	
             String newPart = (String)objListSize1.get(i);
             slnewPartselectables.add("attribute["+EngineeringConstants.ATTRIBUTE_V_NAME+"]");
             Map existingMap = DomainObject.newInstance(context,newPart).getInfo(context,slnewPartselectables);
             busVName      = (String)existingMap.get(DomainConstants.SELECT_NAME);
             if(i>0){
           	    sbInstanceTitle.append(",");
             }
             sbInstanceTitle.append(BOMMgtUIUtil.getInstanceTitle(context, newPart));
             strVname	   = (String)existingMap.get("attribute["+EngineeringConstants.ATTRIBUTE_V_NAME+"]");
             if(UIUtil.isNullOrEmpty(strVname)){
            	 sbVName=sbVName.append(busVName);
       			 sbVName=sbVName.append(",");
             }else{
            	 sbVName=sbVName.append(strVname);
       			 sbVName=sbVName.append(",");
             }
             //UOM Management: Show the UOM value of Part in the Markup - start
             String sUOMForMarkUp = (String)existingMap.get(EngineeringConstants.SELECT_ATTRIBUTE_UNITOFMEASURE); 
             String Rang1 = StringUtils.replace(sUOMForMarkUp," ", "_");
       	  	 String attrName2 = "emxFramework.Range." + EngineeringConstants.UNIT_OF_MEASURE + "." + Rang1;
       	     strUOM = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),attrName2);
       	    if(!UIUtil.isNullOrEmpty(strUOM)){
       	    	sbUOM=sbUOM.append(strUOM);
       	    	sbUOM=sbUOM.append(",");
       	    	sbUOM_en=sbUOM_en.append(sUOMForMarkUp);
       	    	sbUOM_en=sbUOM_en.append(",");       	    }
             //UOM Management: Show the UOM value of Part in the Markup - end
		}
   if(sbVName!=null && sbVName.length()>0){
		busVName=sbVName.substring(0, sbVName.length()-1);
	}
	if(sbUOM!=null && sbUOM.length()>0){
		strUOM=sbUOM.substring(0, sbUOM.length()-1);
		strUOM_en=sbUOM_en.substring(0, sbUOM_en.length()-1);
	}
		strInstanceTitle=sbInstanceTitle.toString();
   }
    DomainObject ctxObj = DomainObject.newInstance(context);
    ctxObj.setId(selPartParentOId);

    StringList slSelectables = new StringList();
    slSelectables.add(DomainConstants.SELECT_POLICY);
    slSelectables.add(DomainObject.SELECT_CURRENT);

    // Database Hit
    Map mapSelects = ctxObj.getInfo(context,slSelectables);

    String strPolicy      = (String)mapSelects.get(DomainConstants.SELECT_POLICY);
    String strCurrent     = (String)mapSelects.get(DomainObject.SELECT_CURRENT); 
    if ((strPolicy.equals(DomainConstants.POLICY_DEVELOPMENT_PART) && !strCurrent.equals(DomainConstants.STATE_DEVELOPMENT_PART_COMPLETE)) || (strPolicy.equals(DomainConstants.POLICY_EC_PART) && strCurrent.equals(DomainConstants.STATE_PART_PRELIMINARY)) || (strPolicy.equals(EngineeringConstants.POLICY_CONFIGURED_PART))) {
        FNFlag = true;
    }
   //Added to get Highest F/N
 StringList eBOMFN;  
 int incrementIntValue = 1;
 int FNvalue = 1;
 DomainObject domObj = new DomainObject(selPartParentOId);
     	eBOMFN = domObj.getInfoList(context, "from["+ EngineeringConstants.RELATIONSHIP_EBOM+"].attribute["+EngineeringConstants.ATTRIBUTE_FIND_NUMBER+"].value" );
     	FNvalue = (FNvalue <= 1)?EngineeringUtil.getHighestNumber(eBOMFN)+incrementIntValue:FNvalue;

%>
<%@include file = "emxDesignBottomInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">
    // Added for V6R2009.HF0.2 - Starts
    //XSSOK
	var isMBOMInstalled = "<%=isMBOMInstalled%>";
    var execute        = true;
  //XSSOK
    var FNDef          = parseInt("<%=newValue%>");
  //XSSOK
    var FNIcr          = parseInt("<%=incrValue%>");
  //XSSOK
    var parentPartId   = "<%=XSSUtil.encodeForJavaScript(context, selPartParentOId)%>";
  //XSSOK
    var rowId          = "<%=XSSUtil.encodeForJavaScript(context, selectedRowId)%>";
  //XSSOK
    var fnFlag         = "<%=FNFlag%>";
  //XSSOK
    var CONST_FN       = "<%=DomainConstants.ATTRIBUTE_FIND_NUMBER%>";
  //XSSOK
    var CONST_V_NAME       = "<%=EngineeringConstants.ATTRIBUTE_V_NAME%>";
  //XSSOK
    var V_Name          = "<%=busVName%>";
    var V_NamearrIds         = V_Name.split(",");
    //XSSOK
    var CONST_UOM       = "UOM";
    //XSSOK
    var vUOM          = "<%=strUOM%>";
    var V_UOMUsage         = vUOM.split(",");
    //XSSOK
    var vUOM_en       = "<%=strUOM_en%>";
    //XSSOk
    var V_UOMUsage_en = vUOM_en.split(",");
    var vIsVPMVisible = "<%=strIsVPMVisible%>"
    //XSSOK
    var vIsVPMVisible_int = "<%=strIsVPMVisible_int%>"
  //XSSOK
    var iTotal         = parseInt("<%=total%>");
  //XSSOK
    var allIds         = "<%=sAllSelIds%>";
    var arrIds         = allIds.split(",");
    var mxRoot         = getTopWindow().getWindowOpener().oXML.documentElement;
    var dupemxUICore   = getTopWindow().getWindowOpener().emxUICore;
    var dupcolMap      = getTopWindow().getWindowOpener().colMap;
    var duppostDataXML = getTopWindow().getWindowOpener().postDataXML;
    var object         = dupcolMap.getColumnByName(CONST_FN);
    var instanceTitle          = "<%=strInstanceTitle%>";
    var V_instanceTitle         = instanceTitle.split(",");

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
        var arrUndoRows    = getTopWindow().getWindowOpener().arrUndoRows;
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

        var NM = "";
        var objColumnNM  = dupcolMap.getColumnByName("Name");
        var objNM    = dupemxUICore.selectSingleNode(currentRow, "c["+objColumnNM.index+"]");
        if(objNM){
            NM  = dupemxUICore.getText(objNM);
        }
        else{
            return false;
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

            var currMarkupRows = dupemxUICore.selectNodes(duppostDataXML.documentElement, xMarkupPath);

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
				if(markup == null || (typeof markup == 'undefined'))
					var markup = currMarkupRow.childNodes[0].getAttribute("markup");
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
                    colNode.setAttribute("name","Find Nubmer");
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
if(isMBOMInstalled == "true"){
		try{
			var arrUndoRows    = getTopWindow().getWindowOpener().arrUndoRows;
			var bomFilter = getTopWindow().getWindowOpener().document.getElementById('ENCBillOfMaterialsViewCustomFilter');
			var bomFilterValue;
			if(!bomFilter){
				var suiteKey = getTopWindow().getWindowOpener().document.getElementById('suiteKey');
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

			var object         = dupcolMap.getColumnByName(CONST_FN);
			if(postXML == null){
				postXML        = dupemxUICore.createXMLDOM();
				postXML.loadXML("<mxRoot/>");
				theRoot = postXML.documentElement;
			}

			// selected part from the Bill of Materials page
			var SBselRow = dupemxUICore.selectSingleNode(mxRoot, "/mxRoot/rows//r[@checked='checked']");
			var rowid    = SBselRow.getAttribute("id");
			var level    = SBselRow.getAttribute("level");

			// The selected part should be a priliminary part
			if(fnFlag == "false" && (SBselRow!=null && (typeof SBselRow != 'undefined'))){
				var obj    = dupemxUICore.selectSingleNode(SBselRow, "c["+object.index+"]");
				var nV1 = parseInt(dupemxUICore.getText(obj));

				// get the next row, until the correct primary row found
				var dupSBselRow = SBselRow;
				do{
					var oxmlstatus = null;
					obj = null;
					var nextRow = dupemxUICore.getNextElement(dupSBselRow);
					if(!nextRow){   break;   }
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
						oxmlstatus = "cut";
					}
					else if(nextRow != null && (typeof nextRow != 'undefined')){
						obj    = dupemxUICore.selectSingleNode(nextRow, "c["+object.index+"]");
						if(obj == null || (typeof obj == 'undefined')){
							break;
						}
						oxmlstatus = nextRow.getAttribute("status");
						dupSBselRow = nextRow;
					}
				}while(oxmlstatus!=null && oxmlstatus == "cut");

				//if next is not found 
				if(obj == null || (typeof obj == 'undefined')){
					FNIcr = 1;
					FNDef = nV1 + FNIcr;
				}
				else{//otherwise it takes the mean value of find numbers of the selected and its next row
					var nV2 = parseInt(dupemxUICore.getText(obj));
					FNIcr = Math.floor((nV2 - nV1) / (iTotal + 1));
					if((FNIcr == 0) || ((nV1 + FNIcr) >= nV2)){
						alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.BOM.NumberOfPartsExceed</emxUtil:i18nScript>");
						execute = false;
					}
					else{
						FNDef = nV1 + FNIcr;
					}
				}
			}

			if(execute){
				if(fnFlag != "false"){
					var SBRows   = dupemxUICore.selectNodes(mxRoot, "/mxRoot/rows//r[@p = '"+ parentPartId +"' and @level = '"+ level +"']");

					for(var i=0;i<SBRows.length;i++){
						var rel = SBRows[i].getAttribute("rel");
						var selStatus = SBRows[i].getAttribute("status");
						if(!rel){
							rel = SBRows[i].getAttribute("relType");
							if(rel){
								var arrRel = rel.split("|");
								rel = arrRel[0];
							}
						}
						//XSSOK
						if(rel != null && rel != "<%=DomainConstants.RELATIONSHIP_EBOM%>" && rel != "<%=sSymbolicRelEBOMName%>"){
							continue;
						}

					// if it is not the selcted row
					if(SBRows[i] != SBselRow){
						//XSSOK
						if(bomFilterValue == "common" && "<%=strAutoUpdateFindNumber%>" == "true"){
							try{
								var retStatus = updateSASQFindNumner(SBRows[i], FNDef);
								if(retStatus == false){
									updateNextAltSubSibling(SBRows[i], FNDef);
						}
							}catch(e){
							}
						}
                    /* var currMarkupRow = dupemxUICore.selectSingleNode(duppostDataXML.documentElement, "/mxRoot//object[@objectId = '"+ SBRows[i].getAttribute("o") +"' and @rowId = '"+ SBRows[i].getAttribute("id") +"']");

						if(currMarkupRow != null && (typeof currMarkupRow != 'undefined')){

								var markup = currMarkupRow.getAttribute("markup");
								if(markup == null || (typeof markup == 'undefined'))
									var markup = currMarkupRow.childNodes[0].getAttribute("markup");

								if(markup == null || (typeof markup == 'undefined')){
									currMarkupRow.setAttribute("markup","changed");

								var newNodeMarked = postXML.createElement("object");
								newNodeMarked.setAttribute("objectId",SBRows[i].getAttribute("o"));
								newNodeMarked.setAttribute("relId",SBRows[i].getAttribute("r"));
								newNodeMarked.setAttribute("parentId",SBRows[i].getAttribute("p"));

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
							else if(markup == "add" || markup == "changed"){
								var colNode = postXML.createElement("column");
								colNode.setAttribute("name",CONST_FN);
								colNode.setAttribute("edited","true");

								var textNode = postXML.createTextNode(FNDef);
								
								colNode.appendChild(textNode);
								currMarkupRow.appendChild(colNode);

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
						else{
							var newNodeMarked = postXML.createElement("object");
							newNodeMarked.setAttribute("objectId",SBRows[i].getAttribute("o"));
							newNodeMarked.setAttribute("relId",SBRows[i].getAttribute("r"));
							newNodeMarked.setAttribute("parentId",SBRows[i].getAttribute("p"));

							newNodeMarked.setAttribute("markup","changed");
							var colNode = postXML.createElement("column");
							colNode.setAttribute("name",CONST_FN);
							colNode.setAttribute("edited","true");
							var textNode = postXML.createTextNode(FNDef);
							FNDef = FNIcr + FNDef;
							
							colNode.appendChild(textNode);
							newNodeMarked.appendChild(colNode);
							theRoot.appendChild(newNodeMarked);
                    } */
					}
					// If it is a selected row
					else{
						if(bomFilterValue == "common"){
							updateSASQFindNumner(SBRows[i], FNDef);
						}

							var sMarkupRow = dupemxUICore.selectSingleNode(duppostDataXML.documentElement, "/mxRoot//object[@objectId = '"+ SBselRow.getAttribute("o") +"' and @rowId = '"+ rowId +"']");

                    /* if(sMarkupRow != null && (typeof sMarkupRow != 'undefined')){

							var colNode1 = postXML.createElement("column");
							colNode1.setAttribute("name",CONST_FN);
							colNode1.setAttribute("edited","true");

							var textNode = postXML.createTextNode(FNDef);
							
							colNode1.appendChild(textNode);
							sMarkupRow.appendChild(colNode1);

							var obj    = dupemxUICore.selectSingleNode(SBselRow, "c["+object.index+"]");
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
							FNDef = FNIcr + FNDef;
						}
						else{
							var newNodeMarked1 = postXML.createElement("object");
							newNodeMarked1.setAttribute("objectId",SBselRow.getAttribute("o"));
							newNodeMarked1.setAttribute("relId",SBselRow.getAttribute("r"));
							newNodeMarked1.setAttribute("parentId",SBselRow.getAttribute("p"));
							newNodeMarked1.setAttribute("markup","changed");

							var colNode1 = postXML.createElement("column");
							colNode1.setAttribute("name",CONST_FN);
							colNode1.setAttribute("edited","true");
						
							var textNode = postXML.createTextNode(FNDef);
							FNDef = FNIcr + FNDef;
							
							colNode1.appendChild(textNode);
							newNodeMarked1.appendChild(colNode1);
							theRoot.appendChild(newNodeMarked1);
                    } */

						/*
						 * constructs the markup for selected parts parts (markup = add)
						 */
                    var nextRow = dupemxUICore.getNextElement(SBselRow);
                    var selectedRelId = SBselRow.getAttribute("r");
                    var nextRelId="";
                    if(nextRow != null)
                   		nextRelId = nextRow.getAttribute("r");
					if(nextRelId==null)
						nextRelId= "";
					var newNode = postXML.createElement("object"); 
					newNode.setAttribute("objectId",parentPartId);

						var before = null;
                    FNDef = <%=FNvalue%>;
						for(var h=0;h<arrIds.length;h++){
							var newChildNode = postXML.createElement("object"); 
							newChildNode.setAttribute("objectId",arrIds[h]);
							newChildNode.setAttribute("relId","");
							newChildNode.setAttribute("pasteAction","pasteBelow");
							newChildNode.setAttribute("rowIdForPasteAction", rowid);
							newChildNode.setAttribute("relType","relationship_EBOM");
							newChildNode.setAttribute("markup","add");
                        newChildNode.setAttribute("param1","AddNext");
                        newChildNode.setAttribute("param2",selectedRelId);
                        newChildNode.setAttribute("param3",nextRelId);
                        newChildNode.setAttribute("param4","");
                        newChildNode.setAttribute("param5",h);
                        
							var colNode = postXML.createElement("column");
							colNode.setAttribute("name",CONST_FN);
							colNode.setAttribute("edited","true");
							
							var textNode = postXML.createTextNode(FNDef);
							FNDef = FNIcr + FNDef;
							colNode.appendChild(textNode);
							newChildNode.appendChild(colNode);

							colNode = postXML.createElement("column");
							colNode.setAttribute("name","Manufacturing Part Usage");
							colNode.setAttribute("edited","true");
							
							textNode = postXML.createTextNode("Primary");
							colNode.appendChild(textNode);
							newChildNode.appendChild(colNode);
							
							if(V_NamearrIds[h]!=null && (typeof V_NamearrIds[h] != 'undefined')){
							var colNode = postXML.createElement("column");
							colNode.setAttribute("name",CONST_V_NAME);
							
							textNode = postXML.createTextNode(V_NamearrIds[h]);
							colNode.appendChild(textNode);
							newChildNode.appendChild(colNode);
							}
							if(V_UOMUsage[h]!=null && (typeof V_UOMUsage[h] != 'undefined')){
							var colNode = postXML.createElement("column");
							colNode.setAttribute("name",CONST_UOM);
							colNode.setAttribute("edited","true");
                            colNode.setAttribute("a",V_UOMUsage_en[h]);
							
							textNode = postXML.createTextNode(V_UOMUsage[h]);
							colNode.appendChild(textNode);
							newChildNode.appendChild(colNode);
							}
                            colNode = postXML.createElement("column");
                            colNode.setAttribute("name","VPMVisible");
                            colNode.setAttribute("edited","true");
                            colNode.setAttribute("a",vIsVPMVisible);
	
                            textNode = postXML.createTextNode(vIsVPMVisible_int);
                            colNode.appendChild(textNode);
                            newChildNode.appendChild(colNode);
                            
							var colNode = postXML.createElement("column");
							colNode.setAttribute("name","Quantity");
							colNode.setAttribute("edited","true");
							
							textNode = postXML.createTextNode("1.0");
							colNode.appendChild(textNode);
							newChildNode.appendChild(colNode);

							if(before == null){
								newNode.appendChild(newChildNode);
							}
							else{
								newNode.insertBefore(newChildNode, before);
							}
							before = newChildNode;

							theRoot.appendChild(newNode);
						}
					}
				}
			}
			else{
                
				var newNode = postXML.createElement("object"); 
				newNode.setAttribute("objectId",parentPartId);
				var before = null;

				for(var h=0;h<arrIds.length;h++){
					var newChildNode = postXML.createElement("object"); 
					newChildNode.setAttribute("objectId",arrIds[h]);
					newChildNode.setAttribute("relId","");
					newChildNode.setAttribute("pasteAction","pasteBelow");
					newChildNode.setAttribute("rowIdForPasteAction", rowid);
					newChildNode.setAttribute("relType","relationship_EBOM");
					newChildNode.setAttribute("markup","add");

					var colNode = postXML.createElement("column");
					colNode.setAttribute("name",CONST_FN);
					colNode.setAttribute("edited","true");
					
					var textNode = postXML.createTextNode(FNDef);
					FNDef = FNIcr + FNDef;
					colNode.appendChild(textNode);
					newChildNode.appendChild(colNode);
					
					if(V_UOMUsage[h]!=null && (typeof V_UOMUsage[h] != 'undefined')){
						var colNode = postXML.createElement("column");
						colNode.setAttribute("name",CONST_UOM);
						colNode.setAttribute("edited","true");
						
						textNode = postXML.createTextNode(V_UOMUsage[h]);
						colNode.appendChild(textNode);
						newChildNode.appendChild(colNode);
						}
						var colNode = postXML.createElement("column");
						colNode.setAttribute("name","Quantity");
						colNode.setAttribute("edited","true");
						
						textNode = postXML.createTextNode("1.0");
						colNode.appendChild(textNode);
						newChildNode.appendChild(colNode);
					
					colNode = postXML.createElement("column");
					colNode.setAttribute("name","Manufacturing Part Usage");
					colNode.setAttribute("edited","true");
					
					textNode = postXML.createTextNode("Primary");
					colNode.appendChild(textNode);
					newChildNode.appendChild(colNode);

					if(before == null){
						newNode.appendChild(newChildNode);
					}
					else{
						newNode.insertBefore(newChildNode, before);
					}
					before = newChildNode;

					theRoot.appendChild(newNode);
				}
			}

			//rebuild the Structure Browser
			getTopWindow().getWindowOpener().rebuildView();

			//render the markup xml
			if(theRoot.childNodes.length > 0){
				//XSSOK
			  var callback = eval(getTopWindow().getWindowOpener().emxEditableTable.prototype.<%=callbackFunctionName%>);
			  var oxmlstatus = callback(theRoot.xml, "true");
			}
		}

		// close the search page
		getTopWindow().closeWindow();
	}
	catch(e){
		//XSSOK
		alert("<%=strErrorMessage%>"+e.message);
	}
}else{
   // Added for V6R2009.HF0.2 - ends
    try{
        var arrUndoRows    = getTopWindow().getWindowOpener().arrUndoRows;
        var postXML        = dupemxUICore.createXMLDOM();
        postXML.loadXML("<mxRoot/>");

        var theRoot = postXML.documentElement;

        // selected part from the Bill of Materials page
        var SBselRow = dupemxUICore.selectSingleNode(mxRoot, "/mxRoot/rows//r[@checked='checked']");
        var rowid    = SBselRow.getAttribute("id");
        var level    = SBselRow.getAttribute("level");

        // The selected part should be a priliminary part
        if(fnFlag == "false" && (SBselRow!=null && (typeof SBselRow != 'undefined'))){
            var obj    = dupemxUICore.selectSingleNode(SBselRow, "c["+object.index+"]");
            var nV1 = parseFloat(dupemxUICore.getText(obj));

        // get the next row, until the correct primary row found
            var dupSBselRow = SBselRow;
            do{
                var oxmlstatus = null;
                obj = null;
                var nextRow = dupemxUICore.getNextElement(dupSBselRow);
                if(nextRow != null && (typeof nextRow != 'undefined')){
                    obj    = dupemxUICore.selectSingleNode(nextRow, "c["+object.index+"]");
                    if(obj == null || (typeof obj == 'undefined')){
                        break;
                    }
                    oxmlstatus = nextRow.getAttribute("status");
                    dupSBselRow = nextRow;
                }
            }while(oxmlstatus!=null && oxmlstatus == "cut");

            //if next is not found
            if(obj == null || (typeof obj == 'undefined')){
                FNIcr = 1;
                FNDef = nV1 + FNIcr;
            }
            else{//otherwise it takes the mean value of find numbers of the selected and its next row
                var nV2 = parseFloat(dupemxUICore.getText(obj));
                FNIcr = (nV2 - nV1) / (iTotal + 1); //Math.floor((nV2 - nV1) / (iTotal + 1));
                if((FNIcr == 0) || ((nV1 + FNIcr) >= nV2)){
                    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.BOM.NumberOfPartsExceed</emxUtil:i18nScript>");
                    execute = false;
                }
                else{
                    FNDef = nV1 + FNIcr;
                }
            }
        }

        if(execute){
            if(fnFlag != "false"){
                var SBRows   = dupemxUICore.selectNodes(mxRoot, "/mxRoot/rows//r[@p = '"+ parentPartId +"' and @level = '"+ level +"']");

                for(var i=0;i<SBRows.length;i++){
                    // if it is not the selcted row
                    if(SBRows[i] != SBselRow){
                        /* var currMarkupRow = dupemxUICore.selectSingleNode(duppostDataXML.documentElement, "/mxRoot//object[@objectId = '"+ SBRows[i].getAttribute("o") +"' and @rowId = '"+ SBRows[i].getAttribute("id") +"']");

                        if(currMarkupRow != null && (typeof currMarkupRow != 'undefined')){

                            var markup = currMarkupRow.getAttribute("markup");
            				if(markup == null || (typeof markup == 'undefined'))
        						var markup = currMarkupRow.childNodes[0].getAttribute("markup");
                            if(markup == null || (typeof markup == 'undefined')){
                                currMarkupRow.setAttribute("markup","changed");

                                var newNodeMarked = postXML.createElement("object");
                                newNodeMarked.setAttribute("objectId",SBRows[i].getAttribute("o"));
                                newNodeMarked.setAttribute("relId",SBRows[i].getAttribute("r"));
                                newNodeMarked.setAttribute("parentId",SBRows[i].getAttribute("p"));

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
                            else if(markup == "add" || markup == "changed"){
                                var colNode = postXML.createElement("column");
                                colNode.setAttribute("name",CONST_FN);
                                colNode.setAttribute("edited","true");

                                var textNode = postXML.createTextNode(FNDef);

                                colNode.appendChild(textNode);
                                currMarkupRow.appendChild(colNode);

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
                        else{
                            var newNodeMarked = postXML.createElement("object");
                            newNodeMarked.setAttribute("objectId",SBRows[i].getAttribute("o"));
                            newNodeMarked.setAttribute("relId",SBRows[i].getAttribute("r"));
                            newNodeMarked.setAttribute("parentId",SBRows[i].getAttribute("p"));

                            newNodeMarked.setAttribute("markup","changed");
                            var colNode = postXML.createElement("column");
                            colNode.setAttribute("name",CONST_FN);
                            colNode.setAttribute("edited","true");
                            var textNode = postXML.createTextNode(FNDef);
                            FNDef = FNIcr + FNDef;

                            colNode.appendChild(textNode);
                            newNodeMarked.appendChild(colNode);
                            theRoot.appendChild(newNodeMarked);
                        } */
                    }
                    // If it is a selected row
                    else{
                        var sMarkupRow = dupemxUICore.selectSingleNode(duppostDataXML.documentElement, "/mxRoot//object[@objectId = '"+ SBselRow.getAttribute("o") +"' and @rowId = '"+ rowId +"']");
                        var SBRows   = dupemxUICore.selectNodes(mxRoot, "/mxRoot/rows//r[@p = '"+ parentPartId +"' and @level = '"+ level +"']");
                        var sortOrder = ""
                        for(var i=0;i<SBRows.length;i++){
                        	if(sortOrder == "")
                        		sortOrder = SBRows[i].getAttribute("r");
                        	else 
                        		sortOrder = sortOrder + "|"+SBRows[i].getAttribute("r");
                        }
                        /* if(sMarkupRow != null && (typeof sMarkupRow != 'undefined')){

                            var colNode1 = postXML.createElement("column");
                            colNode1.setAttribute("name",CONST_FN);
                            colNode1.setAttribute("edited","true");

                            var textNode = postXML.createTextNode(FNDef);

                            colNode1.appendChild(textNode);
                            sMarkupRow.appendChild(colNode1);

                            var obj    = dupemxUICore.selectSingleNode(SBselRow, "c["+object.index+"]");
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
                            FNDef = FNIcr + FNDef;
                        }
                        else{
                            var newNodeMarked1 = postXML.createElement("object");
                            newNodeMarked1.setAttribute("objectId",SBselRow.getAttribute("o"));
                            newNodeMarked1.setAttribute("relId",SBselRow.getAttribute("r"));
                            newNodeMarked1.setAttribute("parentId",SBselRow.getAttribute("p"));
                            newNodeMarked1.setAttribute("markup","changed");

                            var colNode1 = postXML.createElement("column");
                            colNode1.setAttribute("name",CONST_FN);
                            colNode1.setAttribute("edited","true");

                            var textNode = postXML.createTextNode(FNDef);
                            FNDef = FNIcr + FNDef;

                            colNode1.appendChild(textNode);
                            newNodeMarked1.appendChild(colNode1);
                            theRoot.appendChild(newNodeMarked1);
                        } */

                       /*
                        * constructs the markup for selected parts parts (markup = add)
                        */
                        var nextRow = dupemxUICore.getNextElement(SBselRow);
                        var selectedRelId = SBselRow.getAttribute("r");
                        var nextRelId = "";
                        if(nextRow != null)
                        	nextRelId = nextRow.getAttribute("r");
                        if(nextRelId==null)
							nextRelId= "";
                        var newNode = postXML.createElement("object");
                        newNode.setAttribute("objectId",parentPartId);

                        var before = null;
                        FNDef = <%=FNvalue%>;
                        for(var h=0;h<arrIds.length;h++){
                            var newChildNode = postXML.createElement("object");
                            newChildNode.setAttribute("objectId",arrIds[h]);
                            newChildNode.setAttribute("relId","");
                            newChildNode.setAttribute("pasteAction","pasteBelow");
                            newChildNode.setAttribute("rowIdForPasteAction", rowid);
                            newChildNode.setAttribute("relType","relationship_EBOM");
                            newChildNode.setAttribute("markup","add");
                            newChildNode.setAttribute("param1","AddNext");
                            newChildNode.setAttribute("param2",selectedRelId);
                            newChildNode.setAttribute("param3",nextRelId);
                            newChildNode.setAttribute("param4",sortOrder);
                            newChildNode.setAttribute("param5",h);
                            
                            
                            var colNode = postXML.createElement("column");
                            colNode.setAttribute("name",CONST_FN);
                            colNode.setAttribute("edited","true");

                            var textNode = postXML.createTextNode(FNDef);
                            FNDef = FNIcr + FNDef;
                            colNode.appendChild(textNode);
                            newChildNode.appendChild(colNode);
                            if(V_UOMUsage[h]!=null && (typeof V_UOMUsage[h] != 'undefined')){
								var colNode = postXML.createElement("column");
								colNode.setAttribute("name",CONST_UOM);
								colNode.setAttribute("edited","true");
								colNode.setAttribute("a",V_UOMUsage_en[h]);
								textNode = postXML.createTextNode(V_UOMUsage[h]);
								colNode.appendChild(textNode);
								newChildNode.appendChild(colNode);
								}
								var colNode = postXML.createElement("column");
								colNode.setAttribute("name","Quantity");
								colNode.setAttribute("edited","true");
								
								textNode = postXML.createTextNode("1.0");
								colNode.appendChild(textNode);
								newChildNode.appendChild(colNode);

                            colNode = postXML.createElement("column");
                            colNode.setAttribute("name","VPMVisible");
                            colNode.setAttribute("edited","true");
                            colNode.setAttribute("a",vIsVPMVisible);
	
                            textNode = postXML.createTextNode(vIsVPMVisible_int);
                            colNode.appendChild(textNode);
                            newChildNode.appendChild(colNode);
								
                            colNode = postXML.createElement("column");
                            colNode.setAttribute("name","Manufacturing Part Usage");
                            colNode.setAttribute("edited","true");

                            textNode = postXML.createTextNode("Primary");
                            colNode.appendChild(textNode);
                            newChildNode.appendChild(colNode);
                            
                            if(V_instanceTitle[h]!=null && (typeof V_instanceTitle[h] != 'undefined')){
	                            colNode = postXML.createElement("column");
	                            colNode.setAttribute("name","InstanceTitle");
	                            colNode.setAttribute("edited","true");
	
	                            textNode = postXML.createTextNode(V_instanceTitle[h]+".1");
	                            colNode.appendChild(textNode);
	                            newChildNode.appendChild(colNode);
                            }
                            if(before == null){
                                newNode.appendChild(newChildNode);
                            }
                            else{
                                newNode.insertBefore(newChildNode, before);
                            }
                            before = newChildNode;

                            theRoot.appendChild(newNode);
                        }
                    }
                }
            }
            else{
                var newNode = postXML.createElement("object");
                newNode.setAttribute("objectId",parentPartId);
                var before = null;

                for(var h=0;h<arrIds.length;h++){
                    var newChildNode = postXML.createElement("object");
                    newChildNode.setAttribute("objectId",arrIds[h]);
                    newChildNode.setAttribute("relId","");
                    newChildNode.setAttribute("pasteAction","pasteBelow");
                    newChildNode.setAttribute("rowIdForPasteAction", rowid);
                    newChildNode.setAttribute("relType","relationship_EBOM");
                    newChildNode.setAttribute("markup","add");

                    var colNode = postXML.createElement("column");
                    colNode.setAttribute("name",CONST_FN);
                    colNode.setAttribute("edited","true");

                    var textNode = postXML.createTextNode(FNDef.toFixed(4));
                    FNDef = FNIcr + FNDef;
                    colNode.appendChild(textNode);
                    newChildNode.appendChild(colNode);

                    colNode = postXML.createElement("column");
                    colNode.setAttribute("name","Manufacturing Part Usage");
                    colNode.setAttribute("edited","true");

                    textNode = postXML.createTextNode("Primary");
                    colNode.appendChild(textNode);
                    newChildNode.appendChild(colNode);

                    if(before == null){
                        newNode.appendChild(newChildNode);
                    }
                    else{
                        newNode.insertBefore(newChildNode, before);
                    }
                    before = newChildNode;

                    theRoot.appendChild(newNode);
                }
            }

            //rebuild the Structure Browser
            getTopWindow().getWindowOpener().rebuildView();

            //render the markup xml
            if(theRoot.childNodes.length > 0){
            	//XSSOK
              var callback = eval(getTopWindow().getWindowOpener().emxEditableTable.prototype.<%=callbackFunctionName%>);
              var oxmlstatus = callback(theRoot.xml, "true");
            }
        }

        // close the search page
        getTopWindow().closeWindow();
    }
    catch(e){
    	//XSSOK
        alert("<%=strErrorMessage%>"+e.message);
    }
}
</script>
