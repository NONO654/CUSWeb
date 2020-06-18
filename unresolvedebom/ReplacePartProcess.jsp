<%--  ReplacePartProcess.jsp -  This page is used to replace an unresolved BOM
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file = "../engineeringcentral/emxDesignTopInclude.inc"%>
<%@include file="../engineeringcentral/emxEngrVisiblePageInclude.inc"%>
<%@include file = "../engineeringcentral/emxEngrStartUpdateTransaction.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%-- 2011x - Starts --%>
<%@page import = "com.matrixone.apps.unresolvedebom.CFFUtil,com.matrixone.jsystem.util.StringUtils"%>
<%@page import = "com.matrixone.apps.effectivity.EffectivityFramework"%>
<%-- 2011x - Ends --%>

<%

	String objectId         = emxGetParameter(request,"objectId");
	String jsTreeID         = emxGetParameter(request,"jsTreeID");
	String selPartRelId     = emxGetParameter(request,"selPartRelId");
	String selPartObjectId  = emxGetParameter(request,"selPartObjectId");
	String selPartParentOId = emxGetParameter(request,"selPartParentOId");
	String calledMethod     = emxGetParameter(request, "calledMethod");
	String replace          = emxGetParameter(request, "replace");
	String[] selectedItems  = emxGetParameterValues(request, "emxTableRowId");
	String createMode       = emxGetParameter(request, "createMode");
	String newObjID         = emxGetParameter(request, "createdPartObjId");
    String selectedId       = "";
	int count1;String totalCount;String[] selPartIds;
	
	
	
	if ("UEBOMReplaceNew".equalsIgnoreCase(createMode)) {
		     count1     = 1;
		     totalCount = String.valueOf(count1);
		     selPartIds = new String[count1];
		     selPartIds[0] = newObjID;
		
	} else {
			count1     = selectedItems.length;
		    totalCount = String.valueOf(count1);
		    selPartIds = new String[count1];
	}
		
	 String contextECO   = emxGetParameter(request, "contextECO");
	 //2012--Starts --for WIP BOM call one api or call another api to effectivity value
     //String isWipMode = DomainObject.newInstance(context, objectId).getAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_ChangeControlled"));
     String changeControlled = DomainObject.newInstance(context, selPartParentOId).getAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_ChangeControlled"));
			 
	 String ecoName = "";
			 
	 String displayValue  = "";
	 
	 displayValue = StringUtils.replaceAll(displayValue,"<","&lt;");
	 displayValue = StringUtils.replaceAll(displayValue,">","&gt;");
	 if(contextECO != null &&!"null".equals(contextECO) && !"".equals(contextECO)) {
		     ecoName  = (String)com.matrixone.apps.domain.DomainObject.newInstance(context,contextECO).getInfo(context,com.matrixone.apps.domain.DomainConstants.SELECT_NAME);
	 }		     
     //2012--Ends

	if (selectedItems != null) {
		for (int i=0; i < selectedItems.length ;i++)
		{
		    selectedId = selectedItems[i];
		    //if this is coming from the Full Text Search, have to parse out |objectId|relId|
		    java.util.StringTokenizer strTokens = new java.util.StringTokenizer(selectedItems[i],"|");
		    if ( strTokens.hasMoreTokens())
		    {
		        selectedId = strTokens.nextToken();
		    	 DomainObject selObj = DomainObject.newInstance(context,selectedId.trim());
		        selPartIds[i] = selObj.getInfo(context, DomainObject.SELECT_ID);
		        //selPartIds[i] = selectedId.trim();
		    }
		}
 }
	if("replaceExisting".equals(calledMethod) || "UEBOMReplaceNew".equalsIgnoreCase(createMode))
	{
	    session.setAttribute("selPartIds",selPartIds);
	}

//read the necessary parameters from the posted data

String objId = emxGetParameter(request, "objectId");
String radioOption = "replaceWithNoBOM";
String replaceWithExisting = "true";
String relType = com.matrixone.apps.unresolvedebom.UnresolvedEBOMConstants.RELATIONSHIP_EBOM_PENDING;

//XML string input to the callBack function
String strInput = "<mxRoot>";
strInput = strInput + "<object objectId=\"" + selPartParentOId + "\">";
String callbackFunctionName = "loadMarkUpXML";
String newPart = "";

java.util.HashMap paramMap = new java.util.HashMap();

try {

    com.matrixone.apps.domain.util.ContextUtil.startTransaction(context, true);

    com.matrixone.apps.domain.DomainRelationship selPartDomObj = com.matrixone.apps.domain.DomainRelationship.newInstance(context,selPartRelId);
    java.util.Map attrMap = (java.util.Map)selPartDomObj.getAttributeMap(context);
    String CompLocation = (String) attrMap.get(com.matrixone.apps.domain.DomainConstants.ATTRIBUTE_COMPONENT_LOCATION);
    String FindNumber = (String) attrMap.get(com.matrixone.apps.domain.DomainConstants.ATTRIBUTE_FIND_NUMBER);     
    String RefDesig = (String) attrMap.get(com.matrixone.apps.domain.DomainConstants.ATTRIBUTE_REFERENCE_DESIGNATOR);     
    String Usage = (String) attrMap.get(com.matrixone.apps.domain.DomainConstants.ATTRIBUTE_USAGE);
    String Qty = (String) attrMap.get(com.matrixone.apps.domain.DomainConstants.ATTRIBUTE_QUANTITY);
    // Check if the Option choosen is replace with existing Action command
    if (("UEBOMReplaceNew".equalsIgnoreCase(createMode) || replaceWithExisting.equals("true")) && !totalCount.equals("")) {
        Integer count = new Integer(totalCount);
    
    //Remove the selected part from BOM
    
    //2012--If it is WIP bom relationship will be "ebom" else "ebom pending"
    //String relationshipToFollow = "true".equalsIgnoreCase(isWipMode)?"relationship_EBOM":"relationship_EBOMPending";
    String relationshipToFollow = "relationship_EBOM";
    strInput = strInput + "<object objectId=\"" + selPartObjectId + "\" relId=\"" + selPartRelId + "\" relType=\"" + relationshipToFollow + "\" markup=\"cut\" param1=\"replaceCut\"></object>";
    //2012
    
    for(int i=0; i<count.intValue(); i++) {
    	 //UOM Management: Show the UOM value of Part in the Markup - start
        newPart = selPartIds[i];
        String sUOMForMarkUp = DomainObject.newInstance(context,newPart).getInfo(context,EngineeringConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
        String Rang1 = StringUtils.replace(sUOMForMarkUp," ", "_");
  	  	String attrName2 = "emxFramework.Range." + EngineeringConstants.UNIT_OF_MEASURE + "." + Rang1;
  	  	String sUOMValIntValue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),attrName2);
        //UOM Management: Show the UOM value of Part in the Markup - end
    // Add the existing part and update EBOM attributes of the removed part
	    if(i<1) {
	    newPart = selPartIds[i];
	    strInput = strInput + "<object objectId=\"" + selPartIds[i] + "\" relId=\"\" relType=\"relationship_EBOM\" markup=\"add\" param2=\""+selPartRelId+"\" param1=\"replace\">";
	    // Adding EBOM attributes to the replaced part.
	    strInput = strInput + "<column name=\""+com.matrixone.apps.domain.DomainConstants.ATTRIBUTE_FIND_NUMBER+"\" edited=\"true\">"+FindNumber+"</column>";
	    strInput = strInput + "<column name=\""+com.matrixone.apps.domain.DomainConstants.ATTRIBUTE_REFERENCE_DESIGNATOR+"\" edited=\"true\">"+RefDesig+"</column>";
	    strInput = strInput + "<column name=\""+com.matrixone.apps.domain.DomainConstants.ATTRIBUTE_COMPONENT_LOCATION+"\" edited=\"true\">"+CompLocation+"</column>";
	    strInput = strInput + "<column name=\""+com.matrixone.apps.domain.DomainConstants.ATTRIBUTE_QUANTITY+"\" edited=\"true\">"+Qty+"</column>";
	    strInput = strInput + "<column name=\""+com.matrixone.apps.domain.DomainConstants.ATTRIBUTE_USAGE+"\" edited=\"true\">"+Usage+"</column>";
	    strInput = strInput + "<column name=\"UOM\" edited=\"true\" actual=\""+sUOMForMarkUp+"\" a=\""+sUOMForMarkUp+"\">"+ sUOMValIntValue +"</column>"; //UOM Management
	    strInput = strInput + "<column name=\"VPMVisible\" edited=\"true\">True</column>";
	    
	    //2012--for wip bom append Current effectivity inplace of ProposedEffectivity
	    //XSSOK
	    strInput = "true".equalsIgnoreCase(changeControlled) 
	    				? strInput + "<column name=\"ProposedEffectivity\" edited=\"true\">"+displayValue+"</column><column name=\"Add\">"+ecoName+"</column>"
	    				: strInput + "<column name=\"CurrentEffectivity\" edited=\"true\">"+displayValue+"</column>";
	    //2012
	    strInput = strInput + "</object>";
	    
	    } else {
	    //connectPart.connectPartToBOMBean(context, selPartParentOId, selPartIds[i], relType);
	     strInput = strInput + "<object objectId=\"" + selPartIds[i] + "\" relId=\"" + selPartRelId + "\" relType=\"relationship_EBOM\" markup=\"add\" param2=\""+selPartRelId+"\" param1=\"replace\"></object>";
	    }
	      
	    }
    }
    strInput = strInput + "</object></mxRoot>";
    strInput = StringUtils.replaceAll(strInput,"&","&amp;");
    strInput = StringUtils.replaceAll(strInput,"&amp;lt;","&lt;");
    strInput = StringUtils.replaceAll(strInput,"&amp;gt;","&gt;");

    // Check if the option choosen is replace with new part.
    com.matrixone.apps.domain.util.ContextUtil.commitTransaction(context);
   

} catch (Exception ex) {
     
     com.matrixone.apps.domain.util.ContextUtil.abortTransaction(context);
}
//clear the output buffer
out.clear();

%>
	<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
<script language = "javascript">
//XSSOK
  var callback = eval(getTopWindow().getWindowOpener().emxEditableTable.prototype.<%=callbackFunctionName%>);    
  var status = callback('<xss:encodeForJavaScript><%=strInput%></xss:encodeForJavaScript>', "true");
  getTopWindow().closeWindow();
</script>

      <%@include file = "../engineeringcentral/emxEngrCommitTransaction.inc"%>
