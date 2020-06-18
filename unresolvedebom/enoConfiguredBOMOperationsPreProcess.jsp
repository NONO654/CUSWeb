<%--  enoConfiguredBOMOperationsPreProcess.jsp - The pre-process jsp for the Part create component used in Configured BOM "Add New" and "Replace New" functionality.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@page import="com.matrixone.apps.engineering.EngineeringConstants"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.unresolvedebom.CFFUtil" %>
<%@page import="com.matrixone.apps.domain.DomainObject" %>
<%@page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>

<%
	String objectId = emxGetParameter(request,"objectId");
	String rmbobjectId = emxGetParameter(request,"RMBID");
	String isFromRMB = emxGetParameter(request, "isFromRMB");
	String language  = request.getHeader("Accept-Language");
	String strBOMOperation = emxGetParameter(request, "BOMOperation");
	String rowId = "";
	String strInvalidSelectionMsg  = i18nStringNowUtil("emxUnresolvedEBOM.CommonView.Alert.Invalidselection","emxUnresolvedEBOMStringResource", language);
	String noModifyAccess = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.DragDrop.Message.NoModifyAccess");
	String editInviewMode = i18nStringNowUtil("emxUnresolvedEBOM.Command.editPartsInViewMode","emxUnresolvedEBOMStringResource", language);
	String contentURL = "";

%>

<script language="Javascript">

	function getFrame(bomOperation) {
		if (bomOperation == "Replace") { return getTopWindow().getWindowOpener(); }

		return findFrame(getTopWindow(), "PUEUEBOM");
	}
	
	function getXPath(selectedRowId, fromRMB) {
		var value = ( fromRMB == "true" ) ?  "/mxRoot/rows//r[@id='" + selectedRowId + "']" : "/mxRoot/rows//r[@checked='checked']"; 
		if(selectedRowId == "0"){
			value = "/mxRoot/rows//r[@id='0']";
		}
		return value;
	}
	
	function getSelectedRow(selectedRowId, fromRMB, bomOperation) {
		var targetFrame = getFrame(bomOperation);
		//if (bomOperation == "Replace") { return targetFrame.emxUICore.selectSingleNode(targetFrame.oXML.documentElement, getXPath(selectedRowId, fromRMB) ); }
	
		//else { return targetFrame.emxUICore.selectSingleNode( targetFrame.oXML.documentElement, getXPath(selectedRowId, fromRMB) ); }
		return targetFrame.emxUICore.selectSingleNode( targetFrame.oXML.documentElement, getXPath(selectedRowId, fromRMB) );
	}
	
	function getHighestFN(selectedRowId, fromRMB, bomOperation) {
		var highest = 0;
	    var targetFrame = getFrame(bomOperation);
		
		var xPath = getXPath(selectedRowId, fromRMB);
	    
	    var findNumberIndex = targetFrame.colMap.getColumnByName("Find Number").index;
	     
	    var findNumberList = emxUICore.selectNodes( targetFrame.oXML.documentElement, xPath + "/r/c["+findNumberIndex+"]/text()" );		    
	    
	    for (j = 0; j < findNumberList.length; j++) {
	    	
	    	if (findNumberList[j].nodeValue != "" ) {
		     	var intNodeValue = parseInt( findNumberList[j].nodeValue );
		     	
		     	if (j == 0) { highest = intNodeValue; }
		     	
		     	else if (highest<intNodeValue) { highest = intNodeValue; }    	
	    	}
	    }
	    
	    return highest;
	}
	
	function isOperationPerformedOnAddOrCutRow(selectedRowId, fromRMB, bomOperation) {
	    var aCopiedRowsChecked = getSelectedRow(selectedRowId, fromRMB, bomOperation);
	    
	    var status = aCopiedRowsChecked.getAttribute("status");
	    
	    if (bomOperation == "Add") { return  (status == 'cut'); }
	    
	    return (status == 'add' || status == 'cut');
	}

</script>
<%
    if (null != objectId && objectId.length() > 0) {

	  	  String tableRowIdList[] = emxGetParameterValues(request, "emxTableRowId");
	  	if(tableRowIdList == null){
			  tableRowIdList = new String[1];
			  tableRowIdList[0] = "|"+objectId+"||0";
		  }
	  		if("true".equalsIgnoreCase(isFromRMB)){
	  			StringList slList = FrameworkUtil.split(tableRowIdList[0], "|");
	  			System.out.println(slList);
	  		}
	      Map <String, String> tableRowInfo = getSelectedRowInfo( " " + tableRowIdList[0] );
	      rowId = tableRowInfo.get("rowId");
	      String strBOMAction = emxGetParameter(request, "BOMAction");
	      String strWorkUnderChangeId = emxGetParameter(request, "PUEUEBOMContextChangeFilter_actualValue");
	      
%>
			<script language = "javascript">
			//XSSOK
	          if ( isOperationPerformedOnAddOrCutRow( "<%= tableRowInfo.get("rowId") %>", "<xss:encodeForJavaScript><%=isFromRMB%></xss:encodeForJavaScript>", "<xss:encodeForJavaScript><%= strBOMOperation %></xss:encodeForJavaScript>" ) ) {
	          	alert ("inValidRow==");
	          	
	          	getTopWindow().closeWindow();
	          }
	        </script>
<%
		String objectIdpolicy = (  tableRowInfo.get("objectId") == null || "".equals(tableRowInfo.get("objectId") ) ) ? tableRowInfo.get("parentId") : tableRowInfo.get("objectId");
		boolean isConfiguredPart = isConfiguredPart(context, objectIdpolicy);
		
		if (!isConfiguredPart) {
		
			if(!"Replace".equalsIgnoreCase(strBOMOperation)){
				
			
		%>
			
		  <script language = "javascript">
		  //XSSOK
			alert("<%= getDisplayValue(context, "emxUnresolvedEBOM.CommonView.Alert.Invalidselection") %>");
                        getTopWindow().window.closeSlideInPanel(); 
			</script>
			<%
			return;
                  }
			 }
    String objectIdToBeValidated = (  tableRowInfo.get("objectId") == null || "".equals(tableRowInfo.get("objectId") ) ) ? tableRowInfo.get("parentId") : tableRowInfo.get("objectId");
          
          boolean changeControlled = isChangeControlled(context, objectIdToBeValidated);
 
          if ( isConfiguredPart && changeControlled ) {
        	  %>
           	  <script language="Javascript">
           	                    //XSSOK
						 	var mode = "view";
							if(findFrame(getTopWindow(),"PUEUEBOM").editableTable){
								mode=findFrame(getTopWindow(),"PUEUEBOM").editableTable.mode;
							}
								if("view" == mode){
           	                    //XSSOK
           	                    alert('<%=editInviewMode%>');
           	                    getTopWindow().window.closeSlideInPanel();
								}
           	                    
           	                    </script>
           	  <%
        	  if((strWorkUnderChangeId == null || "".equals(strWorkUnderChangeId) )){ 
%>
	        <script language = "javascript">
	           //XSSOK
	          alert("<%= getDisplayValue(context, "emxUnresolvedEBOM.Select.WorkUnderChange") %>");

	          if ( "Replace" == "<xss:encodeForJavaScript><%= strBOMOperation %></xss:encodeForJavaScript>" ) { getTopWindow().closeWindow(); }

	          else { getTopWindow().window.closeSlideInPanel(); }
	          
	        </script>
<%				
			return;
        	  }
	   	 }
          HashMap paramMap = new HashMap();
        	 paramMap.put("objectId", tableRowInfo.get("objectId"));
        	 String[] methodargs = JPO.packArgs(paramMap);
        	 boolean status =  JPO.invoke(context, "emxENCActionLinkAccess", null, "isApplyAllowed", methodargs,Boolean.class);
        	 
             if (!status) {
           	  %>
           	  <script language="Javascript">
           	                    //XSSOK
						 	var mode = "view";
							if(findFrame(getTopWindow(),"PUEUEBOM").editableTable){
								mode=findFrame(getTopWindow(),"PUEUEBOM").editableTable.mode;
							}
								if("view" == mode){
           	                    //XSSOK
           	                    alert('<%=noModifyAccess%>');
           	                    getTopWindow().window.closeSlideInPanel();
								}
           	                    
           	                    </script>
           	  <%
				}  
	 	  if ( "Replace".equalsIgnoreCase(strBOMOperation) ) {
	 		  
	          if (  "0".equals( tableRowInfo.get("rowId") )  ) { // check root node selected for replace
%>
					<script language="Javascript">
					//XSSOK
					alert("<%= getENGDisplayValue(context, "emxEngineeringCentral.BOM.ReplaceNewRootNodeError") %>");			
				    getTopWindow().closeWindow();
					</script>
<%				
					return;
			  }

              if ( changeControlled ) {
            	  
            	  //if ( CFFUtil.isEmptyEffectivityOnRelationship(context, tableRowInfo.get("connectionId") ) ) { 
            	  if ( false ) { 
%>
                 	<script language="Javascript">
                 
                     alert("<%= getDisplayValue(context, "emxUnresolvedEBOM.EBOM.BlankEffectivity.ReplaceOperation") %>");
                     getTopWindow().closeWindow();
                     </script>
                     
<%                   
					return;
                 }
                 
                 //else if ( !CFFUtil.isIntersectEffectivity(context, tableRowInfo.get("connectionId"), strWorkUnderChangeId) ) {
                 else if ( false ) {
%>               
					<script language="Javascript"> 	 
                     alert( "<%= getDisplayValue(context, "emxUnresolvedEBOM.Edit.EffectivityMatch") %>" );
                     getTopWindow().closeWindow();
                     </script>
<%                     
					return;
                 }
              }
	      }	     

          if ( "ReplaceNew".equals(strBOMAction) ) {
            	  contentURL = "../common/emxCreate.jsp?nameField=both&form=type_CreatePart&header=emxEngineeringCentral.PartCreate.FormHeader&type=type_Part&StringResourceFileId=emxEngineeringCentralStringResource"
              					+ "&suiteKey=EngineeringCentral&SuiteDirectory=engineeringcentral&postProcessURL=../engineeringcentral/PartCreatePostProcess.jsp&createMode=UEBOMReplaceNew&contextECO="+strWorkUnderChangeId
              					+ "&createJPO=emxPart:createPartJPO&HelpMarker=emxhelppartcreate&targetLocation=replace&bomRelId=" + tableRowInfo.get("connectionId") + "&bomObjectId="
              					+ tableRowInfo.get("objectId")+"&bomParentOID=" + tableRowInfo.get("parentId")+"&sRowId=" + tableRowInfo.get("rowId")
              					+ "&preProcessJavaScript=preProcessInCreatePartIntermediate&typeChooser=true&InclusionList=type_Part&ExclusionList=type_ManufacturingPart,type_ShopperProduct";
	      }
              
          else if (strBOMAction.equals("AddNew")) {
	    	  	contentURL = "../common/emxCreate.jsp?nameField=both&form=type_CreatePart&submitAction=doNothing&header=emxEngineeringCentral.PartCreate.FormHeader&type=type_Part&StringResourceFileId=emxEngineeringCentralStringResource" 
	    	  			+ "&suiteKey=EngineeringCentral&SuiteDirectory=engineeringcentral&createMode=UEBOMAddNew&createJPO=emxPart:createPartJPO&uiType=structureBrowser&addNew=true&showApply=true&contextECO="
	    	  			+ strWorkUnderChangeId + "&postProcessURL=../engineeringcentral/PartCreatePostProcess.jsp&HelpMarker=emxhelppartcreate&targetLocation="+emxGetParameter(request,"targetLocation")+"&slideinType=wider&bomRelId="
	    	  			+ tableRowInfo.get("connectionId")+"&bomObjectId="+tableRowInfo.get("objectId")+"&bomParentOID="+tableRowInfo.get("parentId")+"&sRowId="
	    	  			+ tableRowInfo.get("rowId")+"&sDisableSparePartYesOption=true"+"&preProcessJavaScript=preProcessInCreatePartIntermediate&multiPartCreation=" + emxGetParameter(request, "multiPartCreation")
	    	  			+ "&typeChooser=true&InclusionList=type_Part&ExclusionList=type_ManufacturingPart,type_ShopperProduct";
          }

} else {
	   contentURL = "../common/emxCreate.jsp?nameField=both&form=type_CreatePart&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&header=emxEngineeringCentral.PartCreate.FormHeader"
					+ "&type=type_Part&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&submitAction=treeContent" 
					+ "&postProcessURL=../engineeringcentral/PartCreatePostProcess.jsp&createMode=EBOMReplaceNew&createJPO=emxPart:createPartJPO&HelpMarker=emxhelppartcreate&targetLocation="+emxGetParameter(request,"targetLocation")
					+ "&slideinType=wider&preProcessJavaScript=preProcessInCreatePartIntermediate&typeChooser=true&InclusionList=type_Part&ExclusionList=type_ManufacturingPart,type_ShopperProduct";
}

%>

<%!

	public boolean isChangeControlled(Context context, String objectId) throws MatrixException {
		String strChangeControlled = DomainObject.newInstance(context, objectId).getAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_ChangeControlled"));
		
		return "True".equalsIgnoreCase(strChangeControlled);
	}
	public boolean isConfiguredPart(Context context, String objectId) throws MatrixException {
		String strObjectPolicy = DomainObject.newInstance(context, objectId).getInfo(context,DomainObject.SELECT_POLICY);
		
		return EngineeringConstants.POLICY_CONFIGURED_PART.equalsIgnoreCase(strObjectPolicy);
	}

	public Map getSelectedRowInfo(String selectedRowIdInfo) {
		Map <String, String> tableRowInfo = new HashMap <String, String> ();
		
		StringList slList = FrameworkUtil.split(selectedRowIdInfo, "|");
		     
		tableRowInfo.put ("connectionId", (String) slList.get(0) );
		tableRowInfo.put ("objectId", (String) slList.get(1) );
		tableRowInfo.put ("parentId", (String) slList.get(2) );
		tableRowInfo.put ("rowId", (String) slList.get(3) );
		
		return tableRowInfo;
	}
	
	public String getDisplayValue(Context context, String propertyValue) throws Exception {
		return EnoviaResourceBundle.getProperty(context, "emxUnresolvedEBOMStringResource", context.getLocale(), propertyValue);
	}
	
	public String getENGDisplayValue(Context context, String propertyValue) throws Exception {
		return EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), propertyValue);
	}
%>

<html>

	<head></head>
	
	<body scrollbar="no" border="0">
	
	<script language="JavaScript" type="text/javascript">
	var prmode = "";
	var isFROMRMB1 = "<%=XSSUtil.encodeForJavaScript(context,isFromRMB)%>";
	//XSSOK
	var rmbRowId1  = "<%=rowId%>";
	var encTargetFrame =  findFrame(getTopWindow(),"ENCBOM");
	var	 targetFrame = encTargetFrame ?  encTargetFrame :  findFrame(getTopWindow(),"PUEUEBOM");
	
	prmode=((targetFrame&& targetFrame.editableTable))?targetFrame.editableTable.mode:"view";
	document.location.href = '<%= XSSUtil.encodeForJavaScript(context, contentURL) %>' +'&prmode='+prmode+'&selPartRowId='+rmbRowId1+ '&highestFN=' + getHighestFN("<%= rowId %>", "<xss:encodeForJavaScript><%=isFromRMB%></xss:encodeForJavaScript>", "<xss:encodeForJavaScript><%= strBOMOperation %></xss:encodeForJavaScript>");

	</script>
	
	</body>
	
</html>
