 <%--  emxCPXBOMSearchPreProcess.jsp
  © Dassault Systemes, 1993 - 2010.  All rights reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

    static const char RCSID[] = $Id: emxEngrFullSearchPreProcess.jsp.rca 1.15.3.2 Tue Oct 28 18:55:25 2008 przemek Experimental przemek przemek $
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="../engineeringcentral/emxEngrFramesetUtil.inc"%>


<%
	// Variable Declarations
	String selPartRelId = "";
	String selPartObjectId = "";
	String selPartParentOId = "";
	String selPartRowId     = "";
	String strRelEbomIds    = "";

	// get the parameters from the request object

	String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
	String objectId              = emxGetParameter(request,"objectId");
	String prevmode          = emxGetParameter(request, "prevmode");
	String language         = request.getHeader("Accept-Language");
	boolean isMBOMInstalled = com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context);
	String calledMethod      = emxGetParameter(request,"calledMethod");
	//calledMethod=XSSUtil.encodeForURL(context,calledMethod);
	objectId=XSSUtil.encodeForURL(context,objectId);

	// JavaScript Exception message
	String strErrorMessage   = i18nStringNowUtil("emxEngineeringCentral.BOM.AddExistingFail",
								      "emxEngineeringCentralStringResource",
								       language);
	String inlinErrorMessage  = i18nStringNowUtil("emxFramework.FreezePane.SBEditActions.RowSelectError",
								      "emxFrameworkStringResource",
								       language);

%>
	<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
	<script language="Javascript">

		var warningMessage = "";
		var varIsMbomInstalled = "<%=isMBOMInstalled%>";
		var dupemxUICore = undefined;
		var mxRoot = undefined;

		var contentFrame   = findFrame(parent,"listHidden");
		var xmlRef = contentFrame.parent.oXML;

		var excludeID="";
		var rowId ="";
		var checkedRow ="";

		if(xmlRef!=undefined)
		{
		dupemxUICore   = contentFrame.parent.emxUICore;
		mxRoot         = contentFrame.parent.oXML.documentElement;
		}
		var status         =  null;
		var rel            = null;
		try{
			if(dupemxUICore!=undefined)
			{
			    checkedRow     = dupemxUICore.selectSingleNode(mxRoot, "/mxRoot/rows//r[@checked='checked']");
				status         = checkedRow.getAttribute("status");
				rel            = checkedRow.getAttribute("rel");
				if(rel == null){
				rel = checkedRow.getAttribute("relType");
				if(rel != null){
					var arrRel = rel.split("|");
					rel = arrRel[0];
					}
				}
			}
			
			var findNumberIndex = contentFrame.parent.colMap.getColumnByName("Find Number").index; 
			   var checkedRows = dupemxUICore.selectNodes(contentFrame.parent.oXML, "/mxRoot/rows//r[@checked='checked']"); 
			    var findNumberList = dupemxUICore.selectNodes(contentFrame.parent.oXML, "/mxRoot/rows//r[@checked='checked']/r/c["+findNumberIndex+"]/text()");
			    var highest = 0;
			    for(j=0;j<findNumberList.length;j++){
			    	var intNodeValue = parseInt(findNumberList[j].nodeValue);
			    	if(j==0)
			    		highest = intNodeValue;
			    	else if (highest<intNodeValue)
			    		highest = intNodeValue;    	
			    }
		}
		catch(e){
			warningMessage = "<%=strErrorMessage%>" + e.message;
		}

	</script>
<%
	//In case of "Add Existing" and "Add New" commands
	//constructs the table Row Id for context part
	if(tableRowIdList == null){
		tableRowIdList = new String[1];
		tableRowIdList[0] = "|"+objectId+"||0";
	}

  	if (tableRowIdList!= null) {
    		for (int i=0; i< tableRowIdList.length; i++) {

            	selPartRelId = selPartObjectId = selPartParentOId = selPartRowId = "";

       		//process - relId|objectId|parentId - using the tableRowId
       		String tableRowId = tableRowIdList[i];
		StringList slList = FrameworkUtil.split(" "+tableRowIdList[i], "|");
		try
		{
		    selPartRelId     = ((String)slList.get(0)).trim();
		    selPartObjectId  = ((String)slList.get(1)).trim();
		    selPartParentOId = ((String)slList.get(2)).trim();
		    selPartRowId     = ((String)slList.get(3)).trim();
		}
		catch(Exception e)
		{
			selPartParentOId="";
		}

 %>
                <script language="javascript">
                if ("<%=selPartObjectId%>" == "" || "<%=selPartObjectId%>" == null) {
                    warningMessage = "<%=inlinErrorMessage%>";
                }
                </script>
 <%

		//if the selected part is parent part
		if("0".equals(selPartRowId)){
			selPartParentOId = selPartObjectId;
		}

		// Add Existing
		if(calledMethod.equals("addExisting")){
			String strWarningAEDeleteMsg = i18nStringNowUtil("emxEngineeringCentral.BOM.AddExistingOnDeleted",
									 "emxEngineeringCentralStringResource",
									 language);
			String strWarningAEEBOMSQMsg = "";
			String sSymbolicRelESQName   = "";
			if(isMBOMInstalled) {
				strWarningAEEBOMSQMsg = i18nStringNowUtil("emxMBOM.BOM.AddExistingOnSplitQuantity",
					"emxMBOMStringResource",
					language);
				sSymbolicRelESQName   = FrameworkUtil.getAliasForAdmin(context,
				    "relationship",
				    EngineeringConstants.RELATIONSHIP_EBOM_SPLIT_QUANTITY,
				    true);
			}

	%>
			<script language="Javascript">

			rowId = checkedRow.getAttribute("id");
			var Rows = dupemxUICore.selectNodes(mxRoot, "/mxRoot/rows//r[@id='" + rowId + "']/ancestor::r");
			var j = Rows.length;
			for(var i=0;i<j;i++) {
				var objid = Rows[i].getAttribute('o');
				excludeID = objid+","+excludeID;
			}

			if(varIsMbomInstalled == "true" && (rel != null && (rel == "<%=EngineeringConstants.RELATIONSHIP_EBOM_SPLIT_QUANTITY%>" || rel == "<%=sSymbolicRelESQName%>"))){
				warningMessage = "<%=strWarningAEEBOMSQMsg%>";
			} else if(status == 'cut'){
				warningMessage = "<%=strWarningAEDeleteMsg%>";
			}
			</script>
        <%
            	}//end of addExisting

        }//end of for (int i=0; i< ...
    }// end of if (tableRowIdList!= null)


	if(prevmode == null || "null".equals(prevmode)){
		prevmode ="";
	}

	// Put EBOM's RelIds in Session
	if(!prevmode.equals("true")){
		session.setAttribute("strRelEbomIds",strRelEbomIds);
		session.removeAttribute("searchPARTprop_KEY");
	}

	String enableStdSearch = FrameworkProperties.getProperty(context, "CPC.enableStandardPartSearch");

	String contentURL = "../common/emxFullSearch.jsp?showInitialResults=false&table=CPXSearchResults&formInclusionList=SEPName,Vendor,SEPreference,MEPName,Manufacturer,MEPreference&toolbar=CPCStandardPartsGlobalSearchToolbar&fieldLabels=Vendor:emxFramework.FullTextSearch.Supplier,Manufacturer:emxFramework.FullTextSearch.Manufacturer,SEPreference:emxFramework.FullTextSearch.SEPPreference,MEPreference:emxFramework.FullTextSearch.MEPPreference,SEPName:emxFramework.FullTextSearch.SEPName,MEPName:emxFramework.FullTextSearch.MEPName";

	if(enableStdSearch != null && enableStdSearch.equals("true"))
		contentURL += "&field=TYPES=type_Part:POLICY=policy_StandardPart";
	else
		contentURL += "&field=TYPES=type_Part";


	contentURL += "&selection=multiple&cancelLabel=emxFramework.FullSearch.button.Cancel&submitLabel=emxFramework.FullSearch.button.Done&hideHeader=true&HelpMarker=emxhelpsearchcompfrombom&objectId="+objectId+"&selection=multiple&selPartObjectId="+selPartObjectId+"&selPartRelId="+selPartRelId+"&selPartParentOId="+selPartParentOId+"&calledMethod=addExisting&submitURL=../componentexperience/emxCPXPartBOMAddExisting.jsp?calledMethod=addExisting&includeOIDprogram=jpo.componentcentral.sep.PartBase:checkAVXLicense";


%>

<html>
<head>
</head>
<body>
<form name="engrfullsearch" method="post">
<input type=hidden name="excludeOID" value=""/>
<input type="hidden" name="highestFN" value="0"/>
<script language="Javascript">

    if(warningMessage != ""){
        alert(warningMessage);
    }
    else{
        var mode = "<%=XSSUtil.encodeForJavaScript(context,calledMethod)%>";
        window.open('about:blank','newWin','height=575,width=575');
        document.engrfullsearch.target="newWin";
        if(mode=='addExisting'){
		document.engrfullsearch.excludeOID.value=excludeID;
		document.engrfullsearch.action="<%=contentURL%>";
		document.engrfullsearch.highestFN.value = highest;
		document.engrfullsearch.submit();
        }
       else{
		document.engrfullsearch.action="<%=contentURL%>";
		document.engrfullsearch.submit();
           }
      window.close();
    }

</script>
</form>
</body>
</html>

