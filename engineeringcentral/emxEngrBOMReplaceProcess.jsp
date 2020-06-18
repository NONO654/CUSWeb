<%--  emxEngrBOMReplaceProcess.jsp -  This page Call the Bean to invoke JPO for resequence BOM.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@page import="com.dassault_systemes.enovia.bom.modeler.constants.BOMMgtConstants"%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrStartUpdateTransaction.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<jsp:useBean id="replacePart" class="com.matrixone.apps.engineering.Part" scope="session" />
<jsp:useBean id="connectPart" class="com.matrixone.apps.engineering.Part" scope="session" />
<%@page import="com.dassault_systemes.enovia.partmanagement.modeler.interfaces.parameterization.*"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.dassault_systemes.enovia.bom.modeler.util.BOMMgtUtil"%>
<%@page import="com.matrixone.apps.engineering.Part" %>
<%@page import="com.dassault_systemes.enovia.bom.modeler.util.BOMMgtUIUtil"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%


//read the necessary parameters from the posted data
String languageStr   = request.getHeader("Accept-Language");
String objId = emxGetParameter(request, "objectId");
String partFamilyContextId = emxGetParameter(request,"partFamilyContextId");
String selPartObjectId = emxGetParameter(request,"selPartObjectId");
String selPartParentOId = emxGetParameter(request,"selPartParentOId");
String createdPartObjId = emxGetParameter(request,"createdPartObjId");
String radioOption = emxGetParameter(request,"radioBOM");
String selPartRelId = emxGetParameter(request,"selPartRelId");
String replaceWithExisting = emxGetParameter(request,"replaceWithExisting");
String relType = emxGetParameter(request,"relType");
String frameName = emxGetParameter(request, "frameName");
String strIncorrectRolledupView = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.validate.RefreshRollupView");
String BOMViewMode = emxGetParameter(request, "BOMViewMode");
BOMViewMode = UIUtil.isNotNullAndNotEmpty(BOMViewMode)?BOMViewMode:"";
String replaceRowQuantity = emxGetParameter(request,"replaceRowQuantity");
String WorkUnderOID = emxGetParameter(request,"WorkUnderOID");
WorkUnderOID = UIUtil.isNotNullAndNotEmpty(WorkUnderOID)?WorkUnderOID:"";
Map rolledupData = new HashMap();
boolean isRollUpView = BOMViewMode.equalsIgnoreCase("RollUp");
if(isRollUpView){
	rolledupData = BOMMgtUtil.getRollupDataMap(context,selPartRelId);
}
String tablemode = emxGetParameter(request,"tablemode");
String strErrorMsg = "";
//Added for V6R2009.HF0.2 - Starts
 // Commented and added for Part Create conversion to common comp. R211
//String selPartRowId = (String)session.getAttribute("selPartRowId");
IParameterization iParameterization = new com.dassault_systemes.enovia.partmanagement.modeler.impl.parameterization.Parameterization();
boolean isInstaceMode = iParameterization.isUnConfiguredBOMMode_Instance(context);
String selPartRowId         = "";

if (replaceWithExisting!=null && !("null".equals(replaceWithExisting)) && replaceWithExisting.equals("true"))
{
	selPartRowId = (String)session.getAttribute("selPartRowId");
} else {
	selPartRowId   = emxGetParameter(request,"sRowId");
}


//Start : Added for IR-044888V6R2011
int iselPartParentRowId = selPartRowId.lastIndexOf(",");
String selPartParentRowId = selPartRowId.substring(0,iselPartParentRowId);
//End : IR-044888V6R2011
session.removeAttribute("selPartRowId");
//Added for V6R2009.HF0.2 - Ends


if (relType == null || "".equals(relType)) {
	relType = "EBOM";
}

String symRelType = FrameworkUtil.getAliasForAdmin(context,"relationship",relType,true);
    String totalCount = emxGetParameter(request,"totalCount");
String[] checkBoxArray =  {"|||"+selPartRowId};
String rid = selPartRowId.substring(0, selPartRowId.lastIndexOf(","));
String sParentRowId = "|||"+selPartRowId.substring(0, selPartRowId.lastIndexOf(","));
//XML string input to the callBack function
String strInput = "<mxRoot>";
//Modified the parent row to support rowId
//Start : Modified for IR-044888V6R2011
if(!"view".equalsIgnoreCase(tablemode)){
	strInput = strInput + "<object objectId=\"" + selPartParentOId + "\" rowId=\""+selPartParentRowId+"\">";
}
//End : IR-044888V6R2011
String callbackFunctionName = "loadMarkUpXML";
String newPart = "";

HashMap paramMap = new HashMap();

try {

     ContextUtil.startTransaction(context, true);
    String RolledUpQty = (String)rolledupData.get(EngineeringConstants.SELECT_ATTRIBUTE_QUANTITY);
 	if(!replaceRowQuantity.equalsIgnoreCase(RolledUpQty) && isRollUpView){
 		ContextUtil.abortTransaction(context); 
 		strErrorMsg = strIncorrectRolledupView;
 		 throw new Exception(strErrorMsg);
 	 }
    DomainRelationship selPartDomObj = DomainRelationship.newInstance(context,selPartRelId);
    Map attrMap = (Map)selPartDomObj.getAttributeMap(context);
    String CompLocation = (String) attrMap.get(DomainConstants.ATTRIBUTE_COMPONENT_LOCATION);
    String FindNumber = (String) attrMap.get(DomainConstants.ATTRIBUTE_FIND_NUMBER);     
    FindNumber = (String) FrameworkUtil.split( FindNumber, "." ).get(0);
    String RefDesig = (String) attrMap.get(DomainConstants.ATTRIBUTE_REFERENCE_DESIGNATOR);     
    String Usage = (String) attrMap.get(DomainConstants.ATTRIBUTE_USAGE);
    String PLMExternalID =(String) attrMap.get(BOMMgtConstants.ATTRIBUTE_EBOM_INSTANCE_TITLE);
    String V_description =(String) attrMap.get(BOMMgtConstants.ATTRIBUTE_EBOM_INSTANCE_DESCRIPTION);
    String strUsage = FrameworkUtil.findAndReplace(i18nNow.getRangeI18NString("Usage", Usage, languageStr),"'","\\'");
    String Qty = (String) attrMap.get(DomainConstants.ATTRIBUTE_QUANTITY);
    StringList fnValueUnderParentObject = DomainObject.newInstance(context, selPartParentOId).getInfoList(context, "from["+relType+"].attribute["+EngineeringConstants.ATTRIBUTE_FIND_NUMBER+"].value");
    int sHighestFn = getHighestNumber(fnValueUnderParentObject);
    
    // Creating and Adding select statements for the object
    SelectList resultSelects = new SelectList(8);
    resultSelects.add(DomainObject.SELECT_ID);
    resultSelects.add(DomainObject.SELECT_TYPE);
    resultSelects.add(DomainObject.SELECT_NAME);
    resultSelects.add(DomainObject.SELECT_REVISION);
    resultSelects.add(DomainObject.SELECT_DESCRIPTION);
    resultSelects.add(DomainObject.SELECT_CURRENT);
    resultSelects.add(DomainObject.SELECT_OWNER);
    resultSelects.addElement(DomainConstants.SELECT_POLICY);
    resultSelects.addElement(DomainConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);//UOM Management.

    // Creating and Adding select statements for the relationsip object
    StringList selectRelStmts = new StringList(6);
    selectRelStmts.addElement(DomainConstants.SELECT_ATTRIBUTE_FIND_NUMBER);
    selectRelStmts.addElement(DomainConstants.SELECT_ATTRIBUTE_QUANTITY);
    selectRelStmts.addElement(DomainConstants.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR);
    selectRelStmts.addElement(DomainConstants.SELECT_ATTRIBUTE_COMPONENT_LOCATION);
    selectRelStmts.addElement(DomainConstants.SELECT_ATTRIBUTE_USAGE);
    selectRelStmts.addElement(Part.SELECT_RELATIONSHIP_ID);
    Part selPartParentOId1 = new Part(selPartParentOId);
    String selPartParentCurrent = selPartParentOId1.getInfo(context, DomainObject.SELECT_CURRENT);
    // Create new object with the part selected in BOM
    Part selPart = new Part(selPartObjectId);
    // Get the BOM under the part selected in BOM
    MapList ebomList = selPart.getEBOMs(context, resultSelects, selectRelStmts, false);
    DomainRelationship domRelation = new DomainRelationship(selPartRelId);
    
    String vpmControlState = "false".equalsIgnoreCase( BOMMgtUIUtil.getBOMColumnDesignCollaborationValue(context, selPartParentOId, null) ) ? "true" : "false";
    String strVPMVisibleTrue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.isVPMVisible.TRUE");  
    String strVPMVisibleFalse = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.isVPMVisible.FALSE");
    String rangeEAeach = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource", context.getLocale(), "emxFramework.Range.Unit_of_Measure.EA_(each)");
    boolean isENGSMBInstalled = EngineeringUtil.isENGSMBInstalled(context, false);
    
    if(selPartParentCurrent.equalsIgnoreCase(DomainObject.STATE_PART_PRELIMINARY) && "view".equalsIgnoreCase(tablemode)){
    	StringList newPartIds = new StringList();
    	Map attrMap1 = domRelation.getAttributeMap(context, true);
//     	attrMap1.remove(EngineeringConstants.ATTRIBUTE_UNIT_OF_MEASURE);
		String strSelectedFN = (String) attrMap1.get(DomainConstants.ATTRIBUTE_FIND_NUMBER);
	
		MapList listBOMDataWithSameFN = DomainObject.newInstance(context, selPartParentOId).getRelatedObjects( context,
				BOMMgtConstants.RELATIONSHIP_EBOM, BOMMgtConstants.QUERY_WILDCARD,
				null, null,
				false, true, 
				(short) 1, 
				null, "attribute[" + BOMMgtConstants.ATTRIBUTE_FIND_NUMBER + "]=='" + strSelectedFN + "'", 
				(short) 0, DomainObject.CHECK_HIDDEN, 
				DomainObject.PREVENT_DUPLICATES, DomainObject.PAGE_SIZE, 
				null, null, null, null, null, DomainObject.FILTER_STRUCTURE );
		
		int noOfSameChildPartWithSameFN = listBOMDataWithSameFN.size();
		String nonUniqueFindNumberNotAllowedErrorMessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.findNumber.NonUniqueFindNumberNotAllowed");

    	Map programMap = new HashMap();
    	programMap.put("parentObjId",selPartParentOId);
    	programMap.put("oldChildObjectId",selPartObjectId);
    	programMap.put("replaceCutId",selPartRelId);
    	programMap.put("BOMViewMode",BOMViewMode);
    	programMap.put("columnValue",attrMap1);
    	programMap.put("WorkUnderOID",WorkUnderOID);
    	if (replaceWithExisting.equals("true") && !totalCount.equals("")) {
    		String selPartIds[] = (String[])session.getValue("selPartIds");
            Integer count = new Integer(totalCount);
	    	for(int i=0; i<count.intValue(); i++) {
	    		newPartIds.add(selPartIds[i]);
	    	}
	    	if(isInstaceMode){
	    	String sUOMForMarkUp = (String) DomainObject.newInstance(context,selPartIds[0]).getInfo(context,EngineeringConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
	    	attrMap1.put(EngineeringConstants.ATTRIBUTE_UNIT_OF_MEASURE, sUOMForMarkUp);
    	    	String Rang1 = StringUtils.replace(sUOMForMarkUp," ", "_");
    		String attrName2 = "emxFramework.Range." + EngineeringConstants.UNIT_OF_MEASURE + "." + Rang1;
    		String sUOMValIntValue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),attrName2);
    		if(sUOMValIntValue.equals(rangeEAeach)){
    			attrMap1.put(EngineeringConstants.ATTRIBUTE_QUANTITY,"1.0");
    		  }
	    	}
	    	try{
	        	programMap.put("bomOperation","replace");
	        	programMap.put("NewChildObjectIds",newPartIds);
	        	programMap.put("WorkUnderOID",WorkUnderOID);
	    		if(noOfSameChildPartWithSameFN > 1)
	        		throw new Exception(nonUniqueFindNumberNotAllowedErrorMessage);
	        	else{
		        	StringBuffer strInput1 = new StringBuffer();
	        		strInput1 = (StringBuffer) JPO.invoke(context, "enoUnifiedBOM", null, "updateBOMInView", JPO.packArgs(programMap),StringBuffer.class);
	        		strInput = "";
	        		strInput = strInput1.toString();
	        	}
	    	}catch (Exception ex) {
	    		strInput = "";
	    		checkBoxArray =  new String[0];
	    		strErrorMsg = ex.getMessage();
	    		strErrorMsg = strErrorMsg.trim();
	    		if(strErrorMsg.indexOf("System Error: #5000001:") != -1){
	    			strErrorMsg = strErrorMsg.replace("System Error: #5000001: ", "");
	        	}
	    		ContextUtil.abortTransaction(context); 
	    		throw new Exception(strErrorMsg);
	    	}
	    	
    	}else{
    		try{
	    		newPartIds.add(createdPartObjId);
	    		programMap.put("bomOperation","replace");
	    		programMap.put("BOMViewMode",BOMViewMode);
	        	programMap.put("NewChildObjectIds",newPartIds);
	        	programMap.put("WorkUnderOID",WorkUnderOID);
	        	if(isInstaceMode){
	    	    	String sUOMForMarkUp = (String) DomainObject.newInstance(context,createdPartObjId).getInfo(context,EngineeringConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
	    	    	attrMap1.put(EngineeringConstants.ATTRIBUTE_UNIT_OF_MEASURE, sUOMForMarkUp);
	    	    	String Rang1 = StringUtils.replace(sUOMForMarkUp," ", "_");
	        		String attrName2 = "emxFramework.Range." + EngineeringConstants.UNIT_OF_MEASURE + "." + Rang1;
	        		String sUOMValIntValue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),attrName2);
	        		if(sUOMValIntValue.equals(rangeEAeach)){
	        			attrMap1.put(EngineeringConstants.ATTRIBUTE_QUANTITY,"1.0");
	        		  }
	    	    }
	        	if(noOfSameChildPartWithSameFN > 1)
	        		throw new Exception(nonUniqueFindNumberNotAllowedErrorMessage);
	        	else{
	        		StringBuffer strInput1 = new StringBuffer();
	        		strInput1 = (StringBuffer) JPO.invoke(context, "enoUnifiedBOM", null, "updateBOMInView", JPO.packArgs(programMap),StringBuffer.class);
	        		strInput = "";
	        		strInput = strInput1.toString();
	        	}
    		}catch (Exception ex) {
	    		strInput = "";
	    		checkBoxArray =  new String[0];
	    		strErrorMsg = ex.getMessage();
	    		strErrorMsg = strErrorMsg.trim();
	    		if(strErrorMsg.indexOf("System Error: #5000001:") != -1){
	    			strErrorMsg = strErrorMsg.replace("System Error: #5000001: ", "");
	        	}
	    		ContextUtil.abortTransaction(context); 
	    		throw new Exception(strErrorMsg);
	    	}
    	}
    	if ("replaceWithExistingBOM".equals(radioOption)) {
    		Map  replaceWithBOMMap= new HashMap();
    	    if (ebomList!=null) {
    	    	Iterator ebomItr = ebomList.iterator();
    	    	try{
			        while (ebomItr.hasNext()) {
				        Map newMap = (Map) ebomItr.next();
				        String sObjId = (String) newMap.get("id");
				        String relId = (String) newMap.get("id[connection]");
				        attrMap1 = DomainRelationship.newInstance(context, relId).getAttributeMap(context, true);
				        if(isInstaceMode){
					    	String sUOMForMarkUp = (String)attrMap1.get(EngineeringConstants.ATTRIBUTE_UNIT_OF_MEASURE);
					    	String Rang1 = StringUtils.replace(sUOMForMarkUp," ", "_");
				    		String attrName2 = "emxFramework.Range." + EngineeringConstants.UNIT_OF_MEASURE + "." + Rang1;
				    		String sUOMValIntValue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),attrName2);
				    		if(sUOMValIntValue.equals(rangeEAeach)){
				    			attrMap1.put(EngineeringConstants.ATTRIBUTE_QUANTITY,"1.0");
				    		  }
					    	}
						attrMap1.remove(DomainConstants.ATTRIBUTE_FIND_NUMBER);
						replaceWithBOMMap.put("ParentObjId",newPartIds.get(newPartIds.size()-1));
						replaceWithBOMMap.put("bomOperation","add");
						replaceWithBOMMap.put("ChildObjectIds",new StringList(sObjId));
						replaceWithBOMMap.put("ColumnValue",attrMap1);
						replaceWithBOMMap.put("WorkUnderOID",WorkUnderOID);
						if(noOfSameChildPartWithSameFN > 1)
			        		throw new Exception(nonUniqueFindNumberNotAllowedErrorMessage);
			        	else
				    		JPO.invoke(context, "enoUnifiedBOM", null, "updateBOMInView", JPO.packArgs(replaceWithBOMMap),StringBuffer.class);
			        }
    	    	}catch (Exception ex) {
    	    		strInput = "";
    	    		checkBoxArray =  new String[0];
    	    		strErrorMsg = ex.getMessage();
    	    		strErrorMsg = strErrorMsg.trim();
    	    		if(strErrorMsg.indexOf("System Error: #5000001:") != -1){
    	    			strErrorMsg = strErrorMsg.replace("System Error: #5000001: ", "");
    	        	}
    	    		ContextUtil.abortTransaction(context); 
    	    		throw new Exception(strErrorMsg);
    	    	}
    	    }
    	}
	}
    else{
    // Check if the Option choosen is replace with existing Action command
    if (replaceWithExisting.equals("true") && !totalCount.equals("")) {
        Integer count = new Integer(totalCount);
    String selPartIds[] = (String[])session.getValue("selPartIds");
	
    //Start : Modified for IR-044888V6R2011
    //Remove the selected part from BOM
    strInput = strInput + "<object objectId=\"" + selPartObjectId + "\" relId=\"" + selPartRelId + "\" relType=\"" + symRelType + "\" markup=\"cut\" param1=\"replaceCut\" rowId=\""+ selPartRowId +"\"></object>";
    //End : IR-044888V6R2011

    for(int i=0; i<count.intValue(); i++) {
    // Add the existing part and update EBOM attributes of the removed part
    	
        //UOM Management: Show the UOM value of Part in the Markup - start
      newPart = selPartIds[i];
      String sUOMForMarkUp = DomainObject.newInstance(context,newPart).getInfo(context,EngineeringConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
      String Rang1 = StringUtils.replace(sUOMForMarkUp," ", "_");
	  String attrName2 = "emxFramework.Range." + EngineeringConstants.UNIT_OF_MEASURE + "." + Rang1;
	  String sUOMValIntValue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),attrName2);
	  if(sUOMValIntValue.equals(rangeEAeach)){
		  if(isRollUpView){
			  Qty = replaceRowQuantity;// (String)rolledupData.get(EngineeringConstants.SELECT_ATTRIBUTE_QUANTITY);
			  RefDesig = ((String)rolledupData.get(EngineeringConstants.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR));
			  RefDesig = UIUtil.isNotNullAndNotEmpty(RefDesig)?RefDesig:"";
		  }
		  else if(isInstaceMode){
			  Qty = "1.0";
		  }
	  }
      //UOM Management: Show the UOM value of Part in the Markup - end
    if(i<1) {
    //newPart = selPartIds[i];
    // Call the Bean to invoke JPO
    //replacePart.replacePartinBOM(context, selPartRelId, selPartObjectId, selPartIds[i], selPartParentOId, partFamilyContextId, radioOption);
                // Modified for V6R2009.HF0.2 - Starts
                strInput = strInput + "<object objectId=\"" + selPartIds[i] + "\" relId=\"\" relType=\"" + symRelType + "\" pasteAction=\"pasteBelow\" rowIdForPasteAction=\""+ selPartRowId +"\" markup=\"add\" param2=\""+selPartRelId+"\" param1=\"replace\">";
                // Modified for V6R2009.HF0.2 - Ends
    // Adding EBOM attributes to the replaced part.
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_FIND_NUMBER+"\" edited=\"true\">"+FindNumber+"</column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_REFERENCE_DESIGNATOR+"\" edited=\"true\">"+RefDesig+"</column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_COMPONENT_LOCATION+"\" edited=\"true\">"+CompLocation+"</column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_QUANTITY+"\" edited=\"true\">"+Qty+"</column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_USAGE+"\" edited=\"true\" a=\""+Usage+"\">"+strUsage+"</column>";
    strInput = strInput + "<column name=\"InstanceTitle\" edited=\"true\">"+PLMExternalID+"</column>";
    strInput = strInput + "<column name=\"InstanceDescription\" edited=\"true\">"+V_description+"</column>";
    strInput = strInput + "<column name=\"UOM\" edited=\"true\" actual=\""+sUOMForMarkUp+"\" a=\""+sUOMForMarkUp+"\">"+ sUOMValIntValue +"</column>"; //UOM Management
    //Added for Common View Replace operation
    
     if(isENGSMBInstalled && "true".equalsIgnoreCase(vpmControlState)) { 
    	 strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"False\">"+strVPMVisibleFalse+"</column>";
     } else {
    	 strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"True\">"+strVPMVisibleTrue+"</column>";
     } 
    
    if(com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context)){
    strInput = strInput + "<column name=\"Manufacturing Part Usage\" edited=\"true\">Primary</column><column name=\"Stype\" edited=\"true\">Unassigned</column><column name=\"Switch\" edited=\"true\">Yes</column><column name=\"Target Start Date\" edited=\"true\"></column><column name=\"Target End Date\" edited=\"true\"></column>";
    }
    strInput = strInput + "</object>";
    
    } else {
    //connectPart.connectPartToBOMBean(context, selPartParentOId, selPartIds[i], relType);
    //Modified for Common View Replace operation    
    strInput = strInput + "<object objectId=\"" + selPartIds[i] + "\" relId=\"" + selPartRelId + "\" relType=\"" + symRelType + "\" markup=\"add\" param2=\""+selPartRelId+"\" param1=\"replace\">";
    //Added for Common View Replace opertaion : Start
        if(com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context)){
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_FIND_NUMBER+"\" edited=\"true\"></column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_REFERENCE_DESIGNATOR+"\" edited=\"true\"></column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_COMPONENT_LOCATION+"\" edited=\"true\"></column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_QUANTITY+"\" edited=\"true\"></column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_USAGE+"\" edited=\"true\" a=\""+Usage+"\">"+strUsage+"</column>";
    strInput = strInput + "<column name=\"UOM\" edited=\"true\" actual=\""+sUOMForMarkUp+"\" a=\""+sUOMForMarkUp+"\">"+ sUOMValIntValue +"</column>"; //UOM Management
     
    if(isENGSMBInstalled && "true".equalsIgnoreCase(vpmControlState)) { 
    	strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"False\">"+strVPMVisibleFalse+"</column>";
    } else {
    	strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"True\">"+strVPMVisibleTrue+"</column>";
    } 
    
    strInput = strInput + "<column name=\"Manufacturing Part Usage\" edited=\"true\">Primary</column><column name=\"Stype\" edited=\"true\">Unassigned</column><column name=\"Switch\" edited=\"true\">Yes</column><column name=\"Target Start Date\" edited=\"true\"></column><column name=\"Target End Date\" edited=\"true\"></column>";
    //Added for Common View Replace opertaion : End
    }
    strInput = strInput + "</object>";
    }
      
    }
    }
    // Check if the option choosen is replace with new part.
    else if(!"".equals(createdPartObjId)){
    newPart = createdPartObjId;
    // Call the Bean to invoke JPO
    // replacePart.replacePartinBOM(context, selPartRelId, selPartObjectId, createdPartObjId, selPartParentOId, partFamilyContextId, radioOption);
    //Start : Modified for IR-044888V6R2011
    
    //UOM Management: Show the UOM value of Part in the Markup - start
      String sUOMForMarkUp = DomainObject.newInstance(context,newPart).getInfo(context,EngineeringConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
      String Rang1 = StringUtils.replace(sUOMForMarkUp," ", "_");
	  String attrName2 = "emxFramework.Range." + EngineeringConstants.UNIT_OF_MEASURE + "." + Rang1;
	  String sUOMValIntValue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),attrName2);
	  if(sUOMValIntValue.equals(rangeEAeach)){
		  if(isRollUpView){
			  Qty =  replaceRowQuantity;//(String)rolledupData.get(EngineeringConstants.SELECT_ATTRIBUTE_QUANTITY);
			  RefDesig = ((String)rolledupData.get(EngineeringConstants.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR));
			  RefDesig = UIUtil.isNotNullAndNotEmpty(RefDesig)?RefDesig:"";
		  }
		  else if(isInstaceMode){
			  Qty = "1.0";
		  }
	  }
      //UOM Management: Show the UOM value of Part in the Markup - end
    
    strInput = strInput + "<object objectId=\"" + selPartObjectId + "\" relId=\"" + selPartRelId + "\" relType=\"" + symRelType + "\" markup=\"cut\" param1=\"replaceCut\" rowId=\""+ selPartRowId +"\"></object>";
    //End : IR-044888V6R2011
        // Modified for V6R2009.HF0.2 - Starts
        strInput = strInput + "<object objectId=\"" + createdPartObjId + "\" relId=\"" + selPartRelId + "\" relType=\"" + symRelType + "\" pasteAction=\"pasteBelow\" rowIdForPasteAction=\""+ selPartRowId +"\" markup=\"add\" param2=\""+selPartRelId+"\" param1=\"replace\">";
        // Modified for V6R2009.HF0.2 - Ends
    // Adding EBOM attributes to the replaced part.
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_FIND_NUMBER+"\" edited=\"true\">"+FindNumber+"</column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_REFERENCE_DESIGNATOR+"\" edited=\"true\">"+RefDesig+"</column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_COMPONENT_LOCATION+"\" edited=\"true\">"+CompLocation+"</column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_QUANTITY+"\" edited=\"true\">"+Qty+"</column>";
    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_USAGE+"\" edited=\"true\" a=\""+Usage+"\">"+strUsage+"</column>";
    strInput = strInput + "<column name=\"InstanceTitle\" edited=\"true\">"+PLMExternalID+"</column>";
    strInput = strInput + "<column name=\"InstanceDescription\" edited=\"true\">"+V_description+"</column>";
    strInput = strInput + "<column name=\"UOM\" edited=\"true\" actual=\""+sUOMForMarkUp+"\" a=\""+sUOMForMarkUp+"\">"+ sUOMValIntValue +"</column>"; //UOM Management
    
    if(isENGSMBInstalled && "true".equalsIgnoreCase(vpmControlState)) { 
    	strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"False\">"+strVPMVisibleFalse+"</column>";
    } else {
    	strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"True\">"+strVPMVisibleTrue+"</column>";
    }
    
    //Added for Common View Replace opertaion
    if(com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context)){
    strInput = strInput + "<column name=\"Manufacturing Part Usage\" edited=\"true\">Primary</column><column name=\"Stype\" edited=\"true\">Unassigned</column><column name=\"Switch\" edited=\"true\">Yes</column><column name=\"Target Start Date\" edited=\"true\"></column><column name=\"Target End Date\" edited=\"true\"></column>";
    }
    strInput = strInput + "</object>";
    }
    // Check if the option choosen is replace with the BOM of existing part
    if ("replaceWithExistingBOM".equals(radioOption)) {
    if (ebomList!=null) {
    strInput = strInput + "</object>";
    strInput = strInput + "<object objectId=\"" + newPart + "\">";
    Iterator ebomItr = ebomList.iterator();
    StringList sConnectionIds = new StringList();
    while (ebomItr.hasNext()) {
    Map newMap = (Map) ebomItr.next();
    String sObjId = (String) newMap.get("id");
    String relId = (String) newMap.get("id[connection]");
    String NewCompLocation = (String) newMap.get(DomainConstants.SELECT_ATTRIBUTE_COMPONENT_LOCATION);
    String NewFindNumber = (String) newMap.get(DomainConstants.SELECT_ATTRIBUTE_FIND_NUMBER);
    String NewRefDesig = (String) newMap.get(DomainConstants.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR);
    String NewUsage = (String) newMap.get(DomainConstants.SELECT_ATTRIBUTE_USAGE);
    String strNewUsage = FrameworkUtil.findAndReplace(i18nNow.getRangeI18NString("Usage", NewUsage, languageStr),"'","\\'");
    String NewQty = (String) newMap.get(DomainConstants.SELECT_ATTRIBUTE_QUANTITY);
  //UOM Management: Show the UOM value of Part in the Markup - start
  	String sUOMForMarkUp = (String) newMap.get(DomainConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
    String Rang1 = StringUtils.replace(sUOMForMarkUp," ", "_");
	String attrName2 = "emxFramework.Range." + EngineeringConstants.UNIT_OF_MEASURE + "." + Rang1;
	String sUOMValIntValue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),attrName2);
	if(sUOMValIntValue.equals(rangeEAeach)){
		if(isRollUpView){
		    	if(sConnectionIds.contains(relId)){
		    		continue;
		    	}
		    	Map existingPartRollupData = (Map)BOMMgtUtil.getRollupDataMap(context,relId);
		    	NewQty = (String)existingPartRollupData.get(EngineeringConstants.SELECT_ATTRIBUTE_QUANTITY);
		    	NewRefDesig = ((String)existingPartRollupData.get(EngineeringConstants.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR));
		    	NewRefDesig = UIUtil.isNotNullAndNotEmpty(NewRefDesig)?NewRefDesig:"";
		    	sConnectionIds.addAll(BOMMgtUtil.getRollupConnectionIdList(context, relId));
	    	}else if(isInstaceMode){
			NewQty = "1.0";
		  }
	}
    //UOM Management: Show the UOM value of Part in the Markup - end

    //strInput = strInput + "<object objectId=\"" + sObjId + "\" relId=\"\" relType=\"" + symRelType + "\" markup=\"add\" param1=\""+selPartRelId+"\"></object>";
        strInput = strInput + "<object objectId=\"" + sObjId + "\" relId=\"\" relType=\"" + symRelType + "\" markup=\"add\" bomOperation=\"add\" param2=\""+selPartRelId+"\" param1=\"add\">";
	    // Adding EBOM attributes to the replaced part.
	    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_FIND_NUMBER+"\" edited=\"true\">"+NewFindNumber+"</column>";
	    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_REFERENCE_DESIGNATOR+"\" edited=\"true\">"+NewRefDesig+"</column>";
	    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_COMPONENT_LOCATION+"\" edited=\"true\">"+NewCompLocation+"</column>";
	    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_QUANTITY+"\" edited=\"true\">"+NewQty+"</column>";
	    strInput = strInput + "<column name=\""+DomainConstants.ATTRIBUTE_USAGE+"\" edited=\"true\" a=\""+NewUsage+"\">"+strNewUsage+"</column>";
	    strInput = strInput + "<column name=\"UOM\" edited=\"true\" actual=\""+sUOMForMarkUp+"\" a=\""+sUOMForMarkUp+"\">"+ sUOMValIntValue +"</column>"; //UOM Management
	    
	    if(isENGSMBInstalled && "true".equalsIgnoreCase(vpmControlState)) { 
	    	strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"False\">"+strVPMVisibleFalse+"</column>";
	    } else {
	    	strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\" a=\"True\">"+strVPMVisibleTrue+"</column>";
	    }
	    
    //Added for Common View Replace opertaion : Start
    if(com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context)){
    strInput = strInput + "<column name=\"Manufacturing Part Usage\" edited=\"true\">Primary</column><column name=\"Stype\" edited=\"true\">Unassigned</column><column name=\"Switch\" edited=\"true\">Yes</column><column name=\"Target Start Date\" edited=\"true\"></column><column name=\"Target End Date\" edited=\"true\"></column>";
    }   
    strInput = strInput + "</object>";
    }
    } 
    }
    strInput = strInput + "</object></mxRoot>";
    }
      ContextUtil.commitTransaction(context);
   

} catch (Exception ex) {
     
     ContextUtil.abortTransaction(context);
}
//clear the output buffer
out.clear();

%>
<%!
public static int getHighestNumber(StringList slValues) {
	int iNumber;
	int highestNumber = 0;
	for (int i = 0; i < slValues.size(); i++) {
		String slValue = ((String) slValues.get(i)).replace(",",".");
		slValue = slValue.contains(".")? slValue.replaceAll("\\..*", ""):slValue;
		if(UIUtil.isNotNullAndNotEmpty(slValue)){
		iNumber = Integer.parseInt(slValue);
		if (iNumber > highestNumber) { highestNumber = iNumber; }
		}
	}
	
	return highestNumber;
}
%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUIFreezePane.js"></script>

<script>
//XSSOK
 var strErrorMsg = '<%=strErrorMsg%>';
 if(strErrorMsg != ""){
	 alert(strErrorMsg);
 }
 else{
 var frameName = "ENCBOM";
 
 var callback = "";
 var objWin = getTopWindow().getWindowOpener().parent;

  if(getTopWindow().getWindowOpener().parent.name == "treeContent")
  {
     objWin=getTopWindow().getWindowOpener();
  }
 //Added for the fix 376740
 //XSSOK
 if ("true"=="<%=XSSUtil.encodeForJavaScript(context,replaceWithExisting)%>"){
	//XSSOK
	if ("view"!="<%=XSSUtil.encodeForJavaScript(context,tablemode)%>"){
		 if(emxUICore.findFrame(getTopWindow().getWindowOpener().getTopWindow(),"<xss:encodeForJavaScript><%=frameName%></xss:encodeForJavaScript>")){
			 objWin = emxUICore.findFrame(getTopWindow().getWindowOpener().getTopWindow(),"<xss:encodeForJavaScript><%=frameName%></xss:encodeForJavaScript>");
		}
		else{
			objWin =getTopWindow().getWindowOpener().parent;
		}
		callback = eval(objWin.emxEditableTable.prototype.<%=callbackFunctionName%>);     
	 //callback = eval(getTopWindow().getWindowOpener().parent.emxEditableTable.prototype.<%=callbackFunctionName%>);
	}
     }
 else{
	//XSSOK
	if ("view"!="<%=XSSUtil.encodeForJavaScript(context,tablemode)%>"){
    	 callback = eval(getTopWindow().getWindowOpener().emxEditableTable.prototype.<%=callbackFunctionName%>);
	}
     }
  //376740 ends
  if ("view"!="<%=XSSUtil.encodeForJavaScript(context,tablemode)%>"){
  	var oxmlstatus = callback('<xss:encodeForJavaScript><%=strInput%></xss:encodeForJavaScript>', "true");
  }
  else {
	  var rowsSelected = "<%=XSSUtil.encodeForJavaScript(context, ComponentsUIUtil.arrayToString(checkBoxArray, "~"))%>";
	  if ("true"=="<%=XSSUtil.encodeForJavaScript(context,replaceWithExisting)%>"){
		  frameName = ((getTopWindow().getWindowOpener().parent.openerFindFrame(getTopWindow(),frameName) != null)) ? frameName :"content";
		  objWin = getTopWindow().getWindowOpener().parent.openerFindFrame(getTopWindow(),frameName);
		  objWin.emxEditableTable.removeRowsSelected(rowsSelected.split("~")); 
		  //XSSOK
		  eval(objWin.openerFindFrame(getTopWindow(),frameName).FreezePaneregister('<%=sParentRowId%>',"true"));
		 //XSSOK
		  objWin.emxEditableTable.addToSelected('<%=strInput%>');
		  eval(objWin.openerFindFrame(getTopWindow(),frameName).FreezePaneunregister('<%=sParentRowId%>',"true"));
		  
	  }
	  else {
	  objWin = getTopWindow().getWindowOpener();
	   if(emxUICore.findFrame(getTopWindow().getWindowOpener().getTopWindow(),frameName)){
			objWin = emxUICore.findFrame(getTopWindow().getWindowOpener().getTopWindow(),frameName);
		}
		else{
			objWin =getTopWindow().getWindowOpener();
		}
		  frameName = ((objWin.openerFindFrame(getTopWindow(),frameName) != null)) ? frameName :"content";
		  objWin.openerFindFrame(getTopWindow(),frameName);
		  objWin.emxEditableTable.removeRowsSelected(rowsSelected.split("~")); 
		 // XSSOK
		  eval(objWin.openerFindFrame(getTopWindow(),frameName).FreezePaneregister('<%=sParentRowId%>',"true"));
		 //XSSOK
		  objWin.emxEditableTable.addToSelected('<%=strInput%>');
		  //XSSOK
		  eval(objWin.openerFindFrame(getTopWindow(),frameName).FreezePaneunregister('<%=sParentRowId%>',"true"));
		  

	  }
	  
  }
 }
  //objWin.document.location.href = objWin.document.location.href;
  parent.closeWindow();

</script>

      <%@include file = "emxEngrCommitTransaction.inc"%>
