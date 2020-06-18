 <%--  emxEngrFullSearchPreProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@ page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@ page import="matrix.db.BusinessObject"%>
<%@ page import="com.matrixone.apps.engineering.EngineeringUtil"%>
<%@ page import="com.matrixone.apps.engineering.EngineeringConstants"%>
<%@page import="com.dassault_systemes.enovia.partmanagement.modeler.interfaces.parameterization.*"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxEngrFramesetUtil.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
<%

    // Variable Declarations
  	String selPartRelId = "";
  	String selPartObjectId = "";
  	String selPartParentOId = "";
    String selPartRowId     = "";
    String strRelEbomIds    = "";
    String relType = emxGetParameter(request,"relType");
    long timeinMilli = System.currentTimeMillis();
    // get the parameters from the request object
    String calledMethod      = XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"calledMethod"));
    String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
    String objectId              = emxGetParameter(request,"objectId");
    String prevmode          = emxGetParameter(request, "prevmode");
    String language         = request.getHeader("Accept-Language");
    String suiteKey         = XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"suiteKey"));
    String sCustomFilter  =  emxGetParameter(request,"ENCBillOfMaterialsViewCustomFilter");
    
    IParameterization iParameterization = new com.dassault_systemes.enovia.partmanagement.modeler.impl.parameterization.Parameterization();
    boolean isInstaceMode = iParameterization.isUnConfiguredBOMMode_Instance(context);
    
    boolean isMBOMInstalled = EngineeringUtil.isMBOMInstalled(context);
    int nosRowsselected = 0;
    if(tableRowIdList == null){
    	nosRowsselected = 0;
    }
    else{
    	nosRowsselected = tableRowIdList.length;
    }
    
   // boolean isENGSMBInstalled = EngineeringUtil.isENGSMBInstalled(context); //Commented for IR-213006
  //Multitenant
    /* String strInvalidSelectionMsg = i18nNow.getI18nString("emxEngineeringCentral.CommonView.Alert.Invalidselection",
            "emxEngineeringCentralStringResource", 
            language); */
    String strInvalidSelectionMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
    		context.getLocale(),"emxEngineeringCentral.CommonView.Alert.Invalidselection"); 
    String strInstanceModeErrorMessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
    		context.getLocale(),"emxEngineeringCentral.InstanceMode.NoModifyAccessOnLegacyComponents"); 
 	//Multitenant
	/* String strAddDeleteErrorMsg   = i18nNow.getI18nString("emxEngineeringCentral.BOM.ChangePositionOnAddDelete",
            "emxEngineeringCentralStringResource",
            language); */
    String strAddDeleteErrorMsg   = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
    		context.getLocale(),"emxEngineeringCentral.BOM.ChangePositionOnAddDelete");
	//Multitenant
	/* String ChangePositionErrorMessage        = i18nNow.getI18nString("emxEngineeringCentral.BOM.ChangePositionFail",
            "emxEngineeringCentralStringResource",
            language); */
	String ChangePositionErrorMessage        = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
			context.getLocale(),"emxEngineeringCentral.BOM.ChangePositionFail");
            String strMultipleSelection        = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", 
        			context.getLocale(),"emxFramework.Common.PleaseSelectOneItemOnly");
            
    String editInViewMode        = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
			context.getLocale(),"emxEngineeringCentral.Command.EditingPartsInViewMode");
    String noModifyAccess        = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
			context.getLocale(),"emxEngineeringCentral.DragDrop.Message.NoModifyAccess");
    String strOperationInvalid    =EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Part.BOM.OperationInvalid");
    String strVPLMControlled = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
    		context.getLocale(),"emxEngineeringCentral.Command.ReplaceNotPossibleForVPLMControlled");
    String rangeEAeach = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource", new Locale("en"), "emxFramework.Range.Unit_of_Measure.EA_(each)");
String sSymbolicRelEBOMName   = FrameworkUtil.getAliasForAdmin(context,
        "relationship", 
        DomainConstants.RELATIONSHIP_EBOM, 
        true);

    // JavaScript Exception message
    //Multitenant
    /* String strErrorMessage                          = i18nNow.getI18nString("emxEngineeringCentral.BOM.AddExistingFail",
                                                                      "emxEngineeringCentralStringResource",
                                                                       language); */
	String strErrorMessage                          = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
			context.getLocale(),"emxEngineeringCentral.BOM.AddExistingFail");

    //Added R208.HF1 - Starts
    //Multitenant
    /* String inlinErrorMessage                        = i18nNow.getI18nString("emxFramework.FreezePane.SBEditActions.RowSelectError",
                                                                      "emxFrameworkStringResource",
                                                                       language); */
	String inlinErrorMessage                        = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", 
			context.getLocale(),"emxFramework.FreezePane.SBEditActions.RowSelectError");
    
	//Multitenant
    /* String changePositionRootNodeSelectionMess      = i18nNow.getI18nString("emxEngineeringCentral.BOM.ChangePositionRootNodeError",
            "emxEngineeringCentralStringResource",
             language); */
	String changePositionRootNodeSelectionMess      = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
			context.getLocale(),"emxEngineeringCentral.BOM.ChangePositionRootNodeError");
    
    //Added R208.HF1 - Ends
    
    //IR-044514	
     //Multitenant
     /* String strDone = i18nNow.getI18nString("emxFramework.Command.Done", "emxEngineeringCentralStringResource",language); */
     String strDone = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxFramework.Command.Done");
   //Multitenant
   /* String strCancel = i18nNow.getI18nString("emxFramework.Command.Cancel", "emxEngineeringCentralStringResource",language); */
     String strCancel = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxFramework.Command.Cancel");
     String isFromRMB    		= emxGetParameter(request, "isFromRMB");
     boolean blnValid = false;
     String invalidObjects = "";
     if("true".equalsIgnoreCase(isFromRMB)) {
         StringList tempList = FrameworkUtil.split(" "+tableRowIdList[0], "|");
         selPartRowId     = ((String)tempList.get(3)).trim(); 
     }
     
%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript">
    // Added for V6R2009.HF0.2 - Starts
    var warningMessage = "";
    var BOMViewMode = "";
    var warningMessageinViewMode = "";
    //XSSOK
    var varIsMbomInstalled = "<%=isMBOMInstalled%>";
    var dupemxUICore = undefined;
    var mxRoot = undefined;
    // IR-027941V6R2011 Changed from top to parent.
    var contentFrame   = findFrame(parent,"listHidden");
    if (contentFrame != null && contentFrame != "undefined") {
        var xmlRef = contentFrame.parent.oXML;
    }    
    //Added for the bug 376740
    var excludeID="";
    var rowId ="";
    var checkedRow ="";
    //376740 ends
    if(xmlRef!=undefined)
    {
    	dupemxUICore   = contentFrame.parent.emxUICore;
    	mxRoot         = contentFrame.parent.oXML.documentElement;
    }
    var highest = 0;
    var isFROMRMB = "<%=XSSUtil.encodeForJavaScript(context, isFromRMB)%>";
	//XSSOK
	var rmbRowId  = "<%=selPartRowId%>";
	var xPath     =  isFROMRMB == "true" ?  "/mxRoot/rows//r[@id='"+rmbRowId+"']" : "/mxRoot/rows//r[@checked='checked']";	
  if("addExisting" == "<%=calledMethod%>"){
   var findNumberIndex = contentFrame.parent.colMap.getColumnByName("Find Number").index; 
   var checkedRows = emxUICore.selectNodes(contentFrame.parent.oXML, xPath); 
    var findNumberList = emxUICore.selectNodes(contentFrame.parent.oXML, xPath +"/r/c["+findNumberIndex+"]/text()");
    //Start ----- For DragNDrop
    if(checkedRows.length == 0 || rmbRowId == "0"){
    	xPath = "/mxRoot/rows//r[@id='0']";
    	checkedRows = emxUICore.selectNodes(contentFrame.parent.oXML, "/mxRoot/rows//r['0']");
    	findNumberList = emxUICore.selectNodes(contentFrame.parent.oXML, xPath+"/r/c["+findNumberIndex+"]/text()");
    }
  //END ----- For DragNDrop
    for(j=0;j<findNumberList.length;j++){
    	if (findNumberList[j].nodeValue != "") {
    	var intNodeValue = parseInt(findNumberList[j].nodeValue);
    	if(j==0)
    		highest = intNodeValue;
    	else if (highest<intNodeValue)
    		highest = intNodeValue;    	
    	}
    }
  }
    var status         =  null;
    var rel            = null;
    
	var isFROMRMB = "<%=XSSUtil.encodeForJavaScript(context, isFromRMB)%>";
	//XSSOK
	var rmbRowId  = "<%=selPartRowId%>";
	var xPath     =  isFROMRMB == "true" ?  "/mxRoot/rows//r[@id='"+rmbRowId+"']" : "/mxRoot/rows//r[@checked='checked']";	            	
	
	var calledMethod = "<%=XSSUtil.encodeForJavaScript(context, calledMethod)%>";
	var sCustomFilter = "<%=XSSUtil.encodeForJavaScript(context, sCustomFilter)%>";
    
    try{
    	if(calledMethod!= "addExisting" && ((sCustomFilter != "engineering") || (sCustomFilter != "Engineering"))){
	    	if(dupemxUICore!=undefined)
	    	{
	            //checkedRow     = dupemxUICore.selectSingleNode(mxRoot, "/mxRoot/rows//r[@checked='checked']");
	            checkedRow     = dupemxUICore.selectSingleNode(mxRoot, xPath);
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
    	}
    }
    catch(e){
    	//XSSOK
        warningMessage = "<%=strErrorMessage%>" + e.message;
   		}
    // Added for V6R2009.HF0.2 - Ends
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
            // Modfied for V6R2009.HF0.2 - Starts
            selPartRelId = selPartObjectId = selPartParentOId = selPartRowId = "";
       //process - relId|objectId|parentId - using the tableRowId
       		String tableRowId = XSSUtil.encodeForJavaScript(context,tableRowIdList[i]);
            StringList slList = FrameworkUtil.split(" "+tableRowIdList[i], "|");
            try
            {
	            selPartRelId     = ((String)slList.get(0)).trim();
	            selPartRelId = XSSUtil.encodeForJavaScript(context,selPartRelId); 
	            selPartObjectId  = ((String)slList.get(1)).trim();
	            selPartObjectId = XSSUtil.encodeForJavaScript(context,selPartObjectId); 
	            selPartParentOId = ((String)slList.get(2)).trim();
	            selPartParentOId = XSSUtil.encodeForJavaScript(context,selPartParentOId); 
	            selPartRowId     = ((String)slList.get(3)).trim();
	            selPartRowId = XSSUtil.encodeForJavaScript(context,selPartRowId); 
            }
            catch(Exception e)
            {
                selPartParentOId="";
            }
            //if the selected part is parent part
            if("0".equals(selPartRowId)){
                selPartParentOId = selPartObjectId;
            }
           if(("changePosition".equals(calledMethod)||"copyTo".equals(calledMethod)) && UIUtil.isNotNullAndNotEmpty(selPartParentOId)){
	            DomainObject doPart = new DomainObject(selPartParentOId);
	            StringList selectList = new StringList();
	            selectList.add(DomainConstants.SELECT_POLICY);
	            selectList.add(DomainConstants.SELECT_CURRENT);
	            selectList.add(DomainConstants.SELECT_NAME);
	
	            Map selectedMap = (Map)doPart.getInfo(context, selectList);
	
	            String strPolicy = (String)selectedMap.get(DomainConstants.SELECT_POLICY);
	            String strCurrent = (String)selectedMap.get(DomainConstants.SELECT_CURRENT);
	            String strName = (String)selectedMap.get(DomainConstants.SELECT_NAME);
				
	            if (strPolicy.equals(EngineeringConstants.POLICY_CONFIGURED_PART) && "copyTo".equals(calledMethod)) {
	                if(!"".equals(invalidObjects)){
	                    invalidObjects += ",";
	                }
	                invalidObjects += strName;
	                blnValid = false;
	            	}
            }
            //Added R208.HF1 - Starts
            %>
                <script language="javascript">
                //XSSOK
                if ("<%=selPartObjectId%>" == "" || "<%=selPartObjectId%>" == null) {
                	//XSSOK
                    warningMessage = "<%=inlinErrorMessage%>";
                }
                </script>
            <%
            //Added R208.HF1 - Ends
 

            // Add Existing
            if(calledMethod.equals("addExisting")){
            	//Multitenant
            	/* String strWarningAEDeleteMsg = i18nNow.getI18nString("emxEngineeringCentral.BOM.AddExistingOnDeleted",
                                                                 "emxEngineeringCentralStringResource",
                                                                 language); */
				String strWarningAEDeleteMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
						context.getLocale(),"emxEngineeringCentral.BOM.AddExistingOnDeleted");
                String strWarningAEEBOMSQMsg = "";
                String sSymbolicRelESQName   = "";
                if(isMBOMInstalled) {
                	//Multitenant
                	/* strWarningAEEBOMSQMsg = i18nNow.getI18nString("emxMBOM.BOM.AddExistingOnSplitQuantity",
	                        "emxMBOMStringResource",
	                        language); */
	                        strWarningAEEBOMSQMsg = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", 
	                        		context.getLocale(),"emxMBOM.BOM.AddExistingOnSplitQuantity");
					sSymbolicRelESQName   = FrameworkUtil.getAliasForAdmin(context,
	                                    "relationship",
	                                    EngineeringConstants.RELATIONSHIP_EBOM_SPLIT_QUANTITY,
	                                    true);
                }

        %>
            <script language="Javascript">
                    //Added for the bug 376740
                  if(calledMethod!= "addExisting" && ((sCustomFilter != "engineering") || (sCustomFilter != "Engineering"))){
                   rowId = checkedRow.getAttribute("id");
                   var Rows = dupemxUICore.selectNodes(mxRoot, "/mxRoot/rows//r[@id='" + rowId + "']/ancestor::r");
               	   var j = Rows.length;
               	   for(var i=0;i<j;i++) {
      	   		   var objid = Rows[i].getAttribute('o');
      	   		   excludeID = objid+","+excludeID;
        		}
            }
    	          // 376740 ends
    	          //XSSOK 
					if(varIsMbomInstalled == "true" && (rel != null && (rel == "<%=EngineeringConstants.RELATIONSHIP_EBOM_SPLIT_QUANTITY%>" || rel == "<%=sSymbolicRelESQName%>"))){
						//XSSOK
						warningMessage = "<%=strWarningAEEBOMSQMsg%>";
					} else if(status == 'cut'){
						//XSSOK
                        warningMessage = "<%=strWarningAEDeleteMsg%>";
                    }
            </script>
        <%
            }//end of addExisting

            // Copy From
            else if(calledMethod.equals("copyFrom")){
            	//Multitenant
            	/* String strWarningCFDeleteMsg =  i18nNow.getI18nString("emxEngineeringCentral.BOM.CopyFromOnDeleted",
                                                                  "emxEngineeringCentralStringResource",
                                                                  language); */
				String strWarningCFDeleteMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
						context.getLocale(),"emxEngineeringCentral.BOM.CopyFromOnDeleted");  
                
                //Multitenant
				/* String strWarningCFRootNode  = i18nNow.getI18nString("emxEngineeringCentral.BOM.CopyFromRootNodeError",
                                                                 "emxEngineeringCentralStringResource",
                                                                 language); */
				String strWarningCFRootNode  = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
						context.getLocale(),"emxEngineeringCentral.BOM.CopyFromRootNodeError");
                String strWarningCFEBOMSQMsg = "";
                String sSymbolicRelESQName  = "";
                if(isMBOMInstalled) {
                	//Multitenant
                	/* strWarningCFEBOMSQMsg = i18nNow.getI18nString("emxMBOM.BOM.CopyFromOnSplitQuantity",
	                        "emxMBOMStringResource",
	                        language); */
	                        strWarningCFEBOMSQMsg = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", 
	                        		context.getLocale(),"emxMBOM.BOM.CopyFromOnSplitQuantity");
					sSymbolicRelESQName   = FrameworkUtil.getAliasForAdmin(context,
	                                     "relationship",
	                                      EngineeringConstants.RELATIONSHIP_EBOM_SPLIT_QUANTITY,
	                                     true);
                }
             
                %>
                <script language="Javascript">
                //XSSOK
					if(varIsMbomInstalled == "true" && (rel != null && (rel == "<%=EngineeringConstants.RELATIONSHIP_EBOM_SPLIT_QUANTITY%>" || rel == "<%=sSymbolicRelESQName%>"))){
                        //XSSOK
                        warningMessage = "<%=strWarningCFEBOMSQMsg%>";
                    }else if(status == 'cut' && warningMessage == "") {
                        //XSSOK
                        warningMessage = "<%=strWarningCFDeleteMsg%>";
                	}
                </script>
                <%
            }//end of copyFrom

            // Copy To
            else if(calledMethod.equals("copyTo")){
            	//Multitenant
            	/* String strWarningCopyToMsg           = i18nNow.getI18nString("emxEngineeringCentral.BOM.CopyToOnAdded",
                                                                         "emxEngineeringCentralStringResource",
                                                                         language); */
				String strWarningCopyToMsg           = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
						context.getLocale(),"emxEngineeringCentral.BOM.CopyToOnAdded");
                //Multitenant
				/* String strRootNodeErrorMsgForCopyTo  = i18nNow.getI18nString("emxEngineeringCentral.BOM.CopyToRootNodeError",
                                                                          "emxEngineeringCentralStringResource",
                                                                         language); */
				String strRootNodeErrorMsgForCopyTo  = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
						context.getLocale(),"emxEngineeringCentral.BOM.CopyToRootNodeError");

                String strWarningCTEBOMSQMsg = "";
                String sSymbolicRelESQName  = "";
                if(isMBOMInstalled) {
                	//Multitenant
                	/* strWarningCTEBOMSQMsg  = i18nNow.getI18nString("emxMBOM.BOM.CopyToOnSplitQuantity",
                        "emxMBOMStringResource",
                        language); */
                strWarningCTEBOMSQMsg  = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", 
                		context.getLocale(),"emxMBOM.BOM.CopyToOnSplitQuantity");
                sSymbolicRelESQName   = FrameworkUtil.getAliasForAdmin(context,
                        "relationship",
                        EngineeringConstants.RELATIONSHIP_EBOM_SPLIT_QUANTITY,
                        true);
                }
                %>
                <script language="Javascript">
                    if(warningMessage == "" && dupemxUICore!=undefined){
                        try{
                        	//XSSOK
                           if(varIsMbomInstalled == "true" && (rel != null && (rel == "<%=EngineeringConstants.RELATIONSHIP_EBOM_SPLIT_QUANTITY%>" || rel == "<%=sSymbolicRelESQName%>"))){
                               //XSSOK 
                                warningMessage = "<%=strWarningCTEBOMSQMsg%>";
                            } else {
                            	var checkedRows     = dupemxUICore.selectNodes(mxRoot, "/mxRoot/rows//r[@checked='checked' and @status='add']");
                                if(checkedRows.length > 0){
                                	//XSSOK
                                warningMessage = "<%=strWarningCopyToMsg%>";
                            	}
                            }
                        }
                        catch(e){
                        	//XSSOK
                            warningMessage = "<%=strErrorMessage%>" + e.message;
                        }
       }
       			//XSSOK
              if(varIsMbomInstalled == "true" && (rel != null && rel != "<%=DomainConstants.RELATIONSHIP_EBOM%>" && rel != "<%=sSymbolicRelEBOMName%>"))
              {
            	  //XSSOK
                 warningMessage = "<%=strInvalidSelectionMsg%>";
              }
       
                </script>
                <%
                if("0".equals(selPartRowId)){
				%>
              <script language="Javascript">
                        if(warningMessage == "" && dupemxUICore!=undefined){
                        	//XSSOK
                            warningMessage = "<%=strRootNodeErrorMsgForCopyTo%>";
                        }
              </script>
              <%
              break;
            }
                else if(selPartRelId != null && !"null".equals(selPartRelId) && !"".equals(selPartRelId)){
                    if(!"".equals(strRelEbomIds)){
                        strRelEbomIds += ",";
                    }
                    strRelEbomIds += selPartRelId;
       }
            }//end of copyTo

            //    Replace with Existing
            else if(calledMethod.equals("replaceExisting")){
            	//Multitenant
            	/* String strWarningReplaceExistingMsg  = i18nNow.getI18nString("emxEngineeringCentral.BOM.ReplacewithExistingOnAddedDeleted",
                                                                                 "emxEngineeringCentralStringResource",
                                                                                 language); */
				String strWarningReplaceExistingMsg  = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
						context.getLocale(),"emxEngineeringCentral.BOM.ReplacewithExistingOnAddedDeleted");
                //Multitenant
				/* String strRootNodeErrorMsgForReplaceExisting = i18nNow.getI18nString("emxEngineeringCentral.BOM.ReplaceExistingRootNodeError",
                                                                                 "emxEngineeringCentralStringResource",
                                                                                 language); */
				String strRootNodeErrorMsgForReplaceExisting = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
						context.getLocale(),"emxEngineeringCentral.BOM.ReplaceExistingRootNodeError");
               
               
                if(isMBOMInstalled) {
                	//Multitenant
                	/* strInvalidSelectionMsg = i18nNow.getI18nString("emxEngineeringCentral.CommonView.Alert.Invalidselection",
	                        "emxEngineeringCentralStringResource",
	                        language); */
					strInvalidSelectionMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
							context.getLocale(),"emxEngineeringCentral.CommonView.Alert.Invalidselection");
	                sSymbolicRelEBOMName = FrameworkUtil.getAliasForAdmin(context,
	                        "relationship",
	                        DomainConstants.RELATIONSHIP_EBOM,
	                        true);
                }



                %>
                <script language="Javascript">
                //XSSOK
  		           if(varIsMbomInstalled == "true" && (rel != null && rel != "<%=DomainConstants.RELATIONSHIP_EBOM%>" && rel != "<%=sSymbolicRelEBOMName%>")){
  		        	//XSSOK
                        warningMessage = "<%=strInvalidSelectionMsg%>";
                    }
                    else if((status == 'add' || status == 'cut') && warningMessage == ""){
                    	//XSSOK
                        warningMessage = "<%=strWarningReplaceExistingMsg%>";
                    }
                </script>
                <%
                if("0".equals(selPartRowId)){
                    %>
                    <script language="Javascript">
                        if(warningMessage == ""){
                        	//XSSOK
                            warningMessage = "<%=strRootNodeErrorMsgForReplaceExisting%>";
    }
                    </script>
                    <%
                    break;
  }
            }//end of replaceExisting
        }//end of for (int i=0; i< ...
    }// end of if (tableRowIdList!= null)
    // Modfied for V6R2009.HF0.2 - Ends
    
    //Start - Added for IR-044888V6R2011
     session.setAttribute("selPartRowId",selPartRowId);
    //End - IR-044888V6R2011

  if(prevmode == null || "null".equals(prevmode)){
    prevmode ="";
  }

  // Put EBOM's RelIds in Session
  if(!prevmode.equals("true")){
    session.setAttribute("strRelEbomIds",strRelEbomIds);
    session.removeAttribute("searchPARTprop_KEY");
  }
  
    String stateNames = EngineeringUtil.getPolicyAndStateList(context,selPartObjectId); 

	String contentURL = "../common/emxFullSearch.jsp?field=TYPES=type_Part:" + stateNames + "&table=ENCAffectedItemSearchResult&HelpMarker=emxhelpfullsearch&hideHeader=true&objectId="+objectId;
	StringBuffer sBuff = new StringBuffer();
	if(calledMethod.equals("addExisting")){
		contentURL ="../common/emxFullSearch.jsp?field=TYPES=type_Part:SPARE_PART=No:" + stateNames + "&freezePane=Name,Name1&showInitialResults=true&calledMethod="+calledMethod+"&table=ENCAffectedItemSearchResult&suiteKey="+suiteKey+"&submitLabel="+"emxFramework.Command.Done"+"&hideHeader=true&HelpMarker=emxhelpfullsearch&excludeOIDprogram=emxENCFullSearch:excludeRecursiveOIDAddExisting&objectId="+objectId+"&selection=multiple&selPartObjectId="+selPartObjectId+"&selPartRelId="+selPartRelId+"&selPartParentOId="+selPartParentOId+"&selPartRowId="+selPartRowId+"&rememberSelection=true";
		DomainObject domObj = UIUtil.isNotNullAndNotEmpty(selPartObjectId)?new DomainObject(selPartObjectId):null;
		String currentState = UIUtil.isNotNullAndNotEmpty(selPartObjectId)?domObj.getInfo(context, EngineeringConstants.SELECT_CURRENT): "";
		  if(!currentState.equalsIgnoreCase(DomainConstants.STATE_PART_PRELIMINARY)){
			  %>
		        <script language="javascript">
		        if(warningMessageinViewMode == ""){
		        	//XSSOK
		            warningMessageinViewMode = "<%=editInViewMode%>";
		        }
		        </script>

			<%
		  }
		  HashMap paramMap = new HashMap();
	    	 paramMap.put("objectId", selPartObjectId);
	    	 String[] methodargs = JPO.packArgs(paramMap);
	    	 boolean status =  JPO.invoke(context, "emxENCActionLinkAccess", null, "isApplyAllowed", methodargs,Boolean.class);
			if(!status){
				  %>
			        <script language="javascript">
			        if(warningMessageinViewMode == ""){
			        	//XSSOK
			            warningMessageinViewMode = "<%=noModifyAccess%>";
			        }
			        </script>

			<%
		  }
    	//Modified to fix IR-090294V6R2012
		
    }
    else if(calledMethod.equals("replaceExisting")){
	//Modified to fix IR-090294V6R2012
	
        session.removeAttribute("selPartRowId");
        session.setAttribute("selPartRowId", selPartRowId);
        DomainObject domObj = UIUtil.isNotNullAndNotEmpty(selPartParentOId)?new DomainObject(selPartParentOId):null;
        String currentUOMType = UIUtil.isNotNullAndNotEmpty(selPartParentOId)?new DomainObject(selPartObjectId).getInfo(context, EngineeringConstants.SELECT_UOM_TYPE):"";
        contentURL ="../common/emxFullSearch.jsp?field=TYPES=type_Part:"+ stateNames +":UNIT_OF_MEASURE_TYPE=" + currentUOMType+ "&showInitialResults=false&table=ENCAffectedItemSearchResult&suiteKey="+suiteKey+"&cancelLabel=emxFramework.Command.Cancel&submitLabel=emxFramework.Command.Done&HelpMarker=emxhelpfullsearch&excludeOIDprogram=emxENCFullSearch:excludeOIDAddNextAndReplaceExisting&excludeOID="+selPartObjectId+"&hideHeader=true&objectId="+objectId+"&selection=single&selPartObjectId="+selPartObjectId+"&selPartRelId="+selPartRelId+"&relType="+relType+"&selPartParentOId="+selPartParentOId+"&replace=true&submitURL=../engineeringcentral/emxEngrPartBOMHiddenProcess.jsp?calledMethod="+calledMethod;
        
        String currentState = UIUtil.isNotNullAndNotEmpty(selPartParentOId)?domObj.getInfo(context, EngineeringConstants.SELECT_CURRENT): "";
		String isVPLMControlled = domObj.getInfo(context, "from["+EngineeringConstants.RELATIONSHIP_PART_SPECIFICATION+"].to.attribute["+EngineeringConstants.ATTRIBUTE_VPM_CONTROLLED+"]");
		if("TRUE".equalsIgnoreCase(isVPLMControlled)){
			  %>
		        <script language="javascript">
		        if(warningMessageinViewMode == ""){
		        	//XSSOK
		            warningMessageinViewMode = "<%=strVPLMControlled%>";
		        }
		        </script>

			<%
		  }
		  if(!currentState.equalsIgnoreCase(DomainConstants.STATE_PART_PRELIMINARY)){
			  %>
		        <script language="javascript">
		        if(warningMessageinViewMode == ""){
		        	//XSSOK
		            warningMessageinViewMode = "<%=editInViewMode%>";
		        }
		        </script>

			<%
		  }
		  HashMap paramMap = new HashMap();
	    	 paramMap.put("objectId", selPartParentOId);
	    	 String[] methodargs = JPO.packArgs(paramMap);
	    	 boolean status =  JPO.invoke(context, "emxENCActionLinkAccess", null, "isApplyAllowed", methodargs,Boolean.class);
			if(!status){
				  %>
			        <script language="javascript">
			        if(warningMessageinViewMode == ""){
			        	//XSSOK
			            warningMessageinViewMode = "<%=noModifyAccess%>";
			        }
			        </script>

			<%
		  }
    } else if(calledMethod.equals("copyFrom") || calledMethod.equals("AVLCopyFrom")){
	//Modified to fix IR-090294V6R2012
		contentURL += "&showInitialResults=false&excludeOIDprogram=emxENCFullSearch:excludeRecursiveOIDCopyFrom&selection=single&selPartObjectId="+selPartObjectId+"&selPartRelId="+selPartRelId+"&excludeOID="+selPartObjectId+"," + selPartParentOId + "&selPartParentOId="+selPartParentOId+"&submitURL=../engineeringcentral/emxEngrPartBOMHiddenProcess.jsp?calledMethod="+calledMethod;
    } else if(calledMethod.equals("copyTo")){
	//Modified to fix IR-090294V6R2012
		contentURL = "../common/emxFullSearch.jsp?field=TYPES=type_Part:" + stateNames +"&table=ENCAffectedItemSearchResult&HelpMarker=emxhelpfullsearch&hideHeader=true&objectId="+objectId;
        contentURL += "&showInitialResults=false&selection=single&excludeOIDprogram=emxENCFullSearch:excludeRecursiveOIDCopyFrom&zprevmode="+prevmode+"&selPartParentOId="+selPartParentOId+"&selPartObjectId="+selPartObjectId+"&excludeOID="+selPartObjectId+"," + selPartParentOId+"&submitURL=../engineeringcentral/emxEngrPartBOMHiddenProcess.jsp?calledMethod="+calledMethod;
    } else if (calledMethod.equals("removePart")) {
    	 String[] selectedObj    = (String[])session.getAttribute("selectedObjs");
    	
    	  for(int i=0;i<selectedObj.length;i++){
    		  String selectedObjId=	(String) selectedObj[i].substring(0, selectedObj[i].indexOf('|'));
    		  	sBuff.append(selectedObjId);
    		  	
    		  	if(i<selectedObj.length-1){    		  	   
    		  	   sBuff.append("|");
    		  	}
    		    }
    	contentURL = "../common/emxFullSearch.jsp?field=TYPES=type_Part&objectId="+objectId+"&includeOIDprogram=emxENCFullSearch:includeCommonParts&HelpMarker=emxhelpfullsearch&table=ENCAffectedItemEBOMRemovePartSearchResult&freezePane=Name,Matches&selection=single&submitURL=../engineeringcentral/emxEngrMarkupChangeProcess.jsp&fieldNameActual=partToRemoveId&fieldNameDisplay=partToRemove&formName=massEBOMUpdate&suiteKey=EngineeringCentral";
    }    else if(calledMethod.equals("changePosition")) {
	
	  //IR-136973V6R2013
        %>
        <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
        <script language="Javascript">
            try{
                var selectedRow = getTopWindow().getWindowOpener().emxUICore.selectSingleNode(getTopWindow().getWindowOpener().oXML.documentElement, "/mxRoot/rows//r[@checked='checked']");
                var level    = selectedRow.getAttribute("level");
                var status = selectedRow.getAttribute("status");
              //XSSOK
                if(<%=isMBOMInstalled%>){
					var rel = selectedRow.getAttribute("rel");
					if(rel == null){
						rel = selectedRow.getAttribute("relType");
						var arrRel = rel.split("|");
						rel = arrRel[0];
					}
					//XSSOK
					if(rel != null && rel != "<%=DomainConstants.RELATIONSHIP_EBOM%>" && rel != "<%=sSymbolicRelEBOMName%>"){
						//XSSOK
						alert("<%=strInvalidSelectionMsg%>");
						getTopWindow().closeWindow();
					}
					else{
						var Xpath="/mxRoot/rows//r[@level = '"+level+"' and (@status = 'add' or @status = 'cut')]";
						var AddorDelRow=getTopWindow().getWindowOpener().emxUICore.selectNodes(getTopWindow().getWindowOpener().oXML.documentElement, Xpath);
						
						if(AddorDelRow.length > 0)    {
							//XSSOK
							alert("<%=strAddDeleteErrorMsg%>");
							getTopWindow().closeWindow();
						}
					    }
				}else{ 
					  var Xpath="/mxRoot/rows//r[@level = '"+level+"' and (@status = 'add' or @status = 'cut')]";
                      var AddorDelRow=getTopWindow().getWindowOpener().emxUICore.selectNodes(getTopWindow().getWindowOpener().oXML.documentElement, Xpath);
                      
                      if(AddorDelRow.length > 0)    {
                    	//XSSOK
                      alert("<%=strAddDeleteErrorMsg%>");
                      getTopWindow().closeWindow();
                }
			   }
               }
            catch(e){
              //  alert("<%=ChangePositionErrorMessage%>"+e.message);
              //  getTopWindow().close();
      }
        </script>
        <%
    	contentURL = "../common/emxIndentedTable.jsp?program=emxPart:getEBOMDataForChangePosition&massPromoteDemote=false&triggerValidation=false&suiteKey=EngineeringCentral&table=ENCEBOMIndentedSummary&HelpMarker=emxhelppartbomedit&objectId="+selPartParentOId+"&tableRowId="+XSSUtil.encodeForJavaScript(context,tableRowIdList[0])+"&selection=single&header=emxEngineeringCentral.Part.ChangePositionPageHeading&submitURL=../engineeringcentral/emxEngrBOMChangePositionDailogProcess.jsp&cancelLabel=emxEngineeringCentral.Button.Cancel&submitLabel=emxEngineeringCentral.Button.Submit";
    }
    
    //if(isENGSMBInstalled){ //Commented for IR-213006
    	contentURL +="&formInclusionList=VPM_PRODUCT_NAME,PART_RELEASE_PHASE";
    //}
    if(isMBOMInstalled)
    {
        String commonViewAddExisting = emxGetParameter(request,"commonViewAddExisting");
        if("true".equalsIgnoreCase(commonViewAddExisting))
    	contentURL +="&commonViewAddExisting=true";
    }
%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript">

//Instance Management legacy Data
function getActualValueForOtherColumn(contentFrame,colName,curFNObj){
  
  var objColumn = contentFrame.parent.colMap.getColumnByName(colName);
  var colIndex = objColumn.index;

  return (emxUICore.selectSingleNode(curFNObj, "c[" + colIndex + "]").getAttribute("a"));
}

function isLagacyComponent(contentFrame, checkedRow){
	var selRowUOM = getActualValueForOtherColumn(contentFrame,"UOM",checkedRow);
	var selRowQuantity = getActualValueForOtherColumn(contentFrame,"Quantity",checkedRow);
	//XSSOK
	if(selRowUOM=="<%=rangeEAeach%>" && selRowQuantity > "1.0"){
			return true;
		}
	 
}

var isInstaceMode = "<%=isInstaceMode%>";
if(isInstaceMode && isInstaceMode=="true"){
	var contentFrame   = findFrame(parent,"listHidden");
	var xPath     =  isFROMRMB == "true" ?  "/mxRoot/rows//r[@id='"+rmbRowId+"']" : "/mxRoot/rows//r[@checked='checked']";	
	contentFrame = (contentFrame != null && contentFrame != undefined)? contentFrame : findFrame(getTopWindow().getWindowOpener(),"listHidden");
	BOMViewMode = contentFrame.parent.getParameter("BOMViewMode"); 
	if("Rollup"!=contentFrame.parent.getParameter("BOMViewMode")){
		var selectedRow = emxUICore.selectSingleNode(contentFrame.parent.oXML, xPath);
		if(selectedRow == null || selectedRow == ""){
			selectedRow = emxUICore.selectSingleNode(contentFrame.parent.oXML, "/mxRoot/rows//r[@id='0']");
		}
		
		var isLegacyComponent = isLagacyComponent(contentFrame,selectedRow);
		if(isLegacyComponent){
			//XSSOK
			warningMessage = "<%=strInstanceModeErrorMessage%>";
		}
	}
}

//END of Instance management

</script>
<html>
<head>
</head>
<body>
<form name="engrfullsearch" method="post">
<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
<input type="hidden" name="excludeOID" value=""/>
<input type="hidden" name="highestFN" value="0"/>
<input type="hidden" name="selectedObjs" value=""/>
<script language="Javascript">
var frameName = parent.name;
var mode = "<%=calledMethod%>";
if(mode == 'changePosition' && warningMessage != ""){
	alert(warningMessage);
	getTopWindow().closeWindow();
}
else if(warningMessage != ""){
        alert(warningMessage);
    } else {
    	//XSSOK
        var sCustomFilter = "<%=sCustomFilter%>";
        //XSSOK
     	 var sIObjects = "<%=invalidObjects%>";
     	 //XSSOk
     	 var sOperationInvalid = "<%=strOperationInvalid%>";
     	 
   	     var msg = "";
   	     //XSSOK
   	  var selectedRowId = "<%=selPartRowId%>";
   	  if(mode == 'changePosition' && "0" != selectedRowId){
          if(sIObjects != ""){
              msg +=sOperationInvalid +"\n ["+sIObjects+"]";
          }
          if(msg != ""){
              alert(msg);
              getTopWindow().closeWindow();
          }  
   	  }
   	  if(mode == 'copyTo'){
          if(sIObjects != ""){
              msg += sOperationInvalid+ "\n["+sIObjects+"]";
          }
          if(msg != ""){
              alert(msg);
              getTopWindow().closeWindow();
          }  
   	  }
        if(mode == 'changePosition' || mode=='AVLCopyFrom') {
           // var selectedRowId = "<xss:encodeForJavaScript><%=selPartRowId%><xss:encodeForJavaScript>";
           //XSSOK
            var selectedRowId = "<%=selPartRowId%>";
            if ("0" == selectedRowId &&  mode!='AVLCopyFrom') {
            	//XSSOK
            	alert("<%=changePositionRootNodeSelectionMess%>");
                closeWindow();
            } else {
            	//XSSOK           	
            	//document.location.href = "<%=contentURL%>";
            	if(mode == 'changePosition'){
            		//XSSOK
            		document.location.href = "<%=contentURL%>"+"&frameName="+frameName;
            	}
            	else{
            		var contentFrame = findFrame(getTopWindow(),"content");
            		contentFrame.showModalDialog("<xss:encodeForURL><%=contentURL%></xss:encodeForURL>", 575, 575);
            	}           	
            }
            
        } else {
 	      	if(mode=='addExisting') {
 	      		if(!(getTopWindow().getWindowOpener()) && (sCustomFilter == "engineering" || sCustomFilter == "Engineering") && frameName == "ENCBOM"){
 	 	      		var contentFrame = findFrame(getTopWindow(),frameName);
 	 	      		contentFrame = (contentFrame != null && contentFrame != undefined)? contentFrame : getTopWindow();
	 	      		var tablemode = "view";
	 	      		var WorkUnderOID = contentFrame.getRequestSetting("ChangeAuthoringContextOID");
	 	      		
	 	      		if (WorkUnderOID == null || WorkUnderOID == 'undefined' || WorkUnderOID == undefined) {
	 	               WorkUnderOID = "";
	 	           }
	 	      		
	 	      		if(contentFrame && contentFrame.editableTable && contentFrame.editableTable != null && contentFrame.editableTable != undefined){
	 	      				tablemode = contentFrame.editableTable.mode; 
	 	      		}
	 	      		else{
	 	      			tablemode = "edit";
	 	      		}
	 	      		if("view"== tablemode && warningMessageinViewMode != ""){
		 	      	        alert(warningMessageinViewMode);
	 	      		}
	 	      		else{
	 	      			
	 	      			var nosRowsselected = "<%=nosRowsselected%>";
	 	      			if(nosRowsselected>1){
	 	      				//XSSOK
	 	      				alert("<%=strMultipleSelection%>");
	 	      			}
	 	      			else{
		 	      			contentURL = "<%=XSSUtil.encodeForJavaScript(context, contentURL)%>"+"&highestFN="+highest+"&frameName="+frameName+"&WorkUnderOID="+WorkUnderOID+"&submitURL=../engineeringcentral/emxEngrPartBOMAddExisting.jsp?calledMethod="+mode+"&tablemode="+tablemode;
		 	      			showModalDialog(contentURL);
	 	      			}

	 	      		}
 	      		}
 	      		else{
 	      			var contentFrame = findFrame(getTopWindow(),frameName);
 	      			var tablemode = "";
 	      			var WorkUnderOID = "";
	 	      		if(contentFrame && contentFrame.editableTable && contentFrame.editableTable != null && contentFrame.editableTable != undefined){
	 	      				tablemode = contentFrame.editableTable.mode;
	 	      				WorkUnderOID = contentFrame.getRequestSetting("ChangeAuthoringContextOID");
	 	      				if (WorkUnderOID == null || WorkUnderOID == 'undefined' || WorkUnderOID == undefined) {
	 	      		            WorkUnderOID = "";
	 	      		        }
	 	      		}
 	      			contentURL = "<%=contentURL%>"+"&highestFN="+highest+"&frameName="+frameName+"&WorkUnderOID="+WorkUnderOID+"&cancelLabel="+"emxFramework.Command.Cancel"+"&submitLabel="+"emxFramework.Command.Done"+"&submitURL=../engineeringcentral/emxEngrPartBOMAddExisting.jsp?calledMethod="+mode+"&tablemode="+tablemode;
	 	      		
				showModalDialog(contentURL);
			      //XSSOK
			        
 	      		}
	        }
 	      	else if(mode=='removePart') {
 	      		//XSSOK
		        document.engrfullsearch.selectedObjs.value="<xss:encodeForJavaScript><%=sBuff.toString()%></xss:encodeForJavaScript>";
		      //XSSOK
		        document.engrfullsearch.action="<xss:encodeForURL><%=contentURL%></xss:encodeForURL>";
		        document.engrfullsearch.submit();
			}	else if(mode=='replaceExisting'){
				//XSSOK
				var nosRowsselected = "<%=nosRowsselected%>";
				var replaceRowQuantity = getActualValueForOtherColumn(contentFrame,"Quantity",checkedRow);
				var contentFrame = findFrame(getTopWindow(),frameName);
	 	      		contentFrame = (contentFrame != null && contentFrame != undefined)? contentFrame : getTopWindow();
 	      		var tablemode = "";
 	      		var WorkUnderOID = contentFrame.getRequestSetting("ChangeAuthoringContextOID");
 	      		if (WorkUnderOID == null || WorkUnderOID == 'undefined' || WorkUnderOID == undefined) {
 	               WorkUnderOID = "";
 	           }
 	      		if(contentFrame && contentFrame.editableTable && contentFrame.editableTable != null && contentFrame.editableTable != undefined){
 	      				tablemode = contentFrame.editableTable.mode; 
 	      				BOMViewMode = contentFrame.getParameter("BOMViewMode");
 	      		}
 	      		if("view"== tablemode && warningMessageinViewMode != ""){
 	      			
 	      	        alert(warningMessageinViewMode);
	      		}
 	      		else{
 	      		 showModalDialog("<%=XSSUtil.encodeForJavaScript(context, contentURL)%>"+"&frameName="+frameName+"&tablemode="+tablemode+"&WorkUnderOID="+WorkUnderOID+"&BOMViewMode="+BOMViewMode+"&replaceRowQuantity="+replaceRowQuantity);
 	      		}
	        }
 	      	else {
				//XSSOK
			showModalDialog("<%=XSSUtil.encodeForJavaScript(context, contentURL)%>"+"&frameName="+frameName);
		        //document.engrfullsearch.action="<%=contentURL%>";
	    	    //document.engrfullsearch.submit();
	        }
        }
    }
</script>
</form>
</body>
</html>
