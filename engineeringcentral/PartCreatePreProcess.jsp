<%--  PartCreatePreProcess.jsp - The pre-process jsp for the Part create component used in EBOM "Add New" and "Replace New" functionality.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file ="emxEngrFramesetUtil.inc"%>

<%@page import="com.matrixone.apps.engineering.EngineeringUtil" %>
<%@page import="com.matrixone.apps.engineering.EngineeringConstants" %>
<%@page import="com.dassault_systemes.enovia.bom.modeler.util.*" %>
<%@page import="com.dassault_systemes.enovia.partmanagement.modeler.interfaces.parameterization.*"%>
<%@ page import="java.lang.reflect.*" %>
<%@page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<%
String objectId             = emxGetParameter(request,"objectId");
String targetLocation       = emxGetParameter(request,"targetLocation");
String SuiteDirectory       = emxGetParameter(request,"SuiteDirectory");
String StringResourceFileId = emxGetParameter(request,"StringResourceFileId");
String suiteKey             = emxGetParameter(request,"suiteKey");
String fromView      		= emxGetParameter(request, "fromView");
String fromMarkupView 		= emxGetParameter(request, "fromMarkupView");
String isFromRMB    		= emxGetParameter(request, "isFromRMB");
String UOMTypeOnNewPart = "";
String replaceRowQuantity = "";
IParameterization iParameterization = new com.dassault_systemes.enovia.partmanagement.modeler.impl.parameterization.Parameterization();
boolean isInstaceMode = iParameterization.isUnConfiguredBOMMode_Instance(context);

String contentURL           = "";
String partNotInEditMode = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.Command.EditingPartsInViewMode");
String noModifyAccess = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.DragDrop.Message.NoModifyAccess");
String editInviewMode = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource",context.getLocale(),"emxUnresolvedEBOM.Command.editPartsInViewMode");
String editUnConfigfromConfig = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource",context.getLocale(),"emxUnresolvedEBOM.CommonView.Alert.Invalidselection");
String strMultipleSelection        = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Common.PleaseSelectOneItemOnly");
String rangeEAeach =EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource", new Locale("en"), "emxFramework.Range.Unit_of_Measure.EA_(each)");
String strInstanceModeErrorMessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.InstanceMode.NoModifyAccessOnLegacyComponents"); 
String sCreateMode           = XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"CreateMode"));
String multiPartCreation           = emxGetParameter(request,"multiPartCreation");
String language  = request.getHeader("Accept-Language");
String bomRelId         = "";
String bomObjectId      = "";
String bomParentOID     = "";
boolean isLagacyComponent;
//2012x
String isWipBomAllowed;String isWipMode = "false";
String contextECO="";String strContextECOSelection;String selectedPartState;
boolean isECCInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionEngineeringConfigurationCentral",false,null,null);
String sRowId = "";
String strVPLMControlled = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
		context.getLocale(),"emxEngineeringCentral.Command.ReplaceNotPossibleForVPLMControlled");
%>
<script language="Javascript">
var msgflag = false;
var highest = 0;
var BOMViewMode = "";
</script>
<%
if ("fromPartFamily".equals(sCreateMode)) {    
    String strPFNameGenerator = "FALSE";
    String strPFDefaultPart = PropertyUtil.getSchemaProperty(context,"type_Part");
    
    if (objectId != null && !"".equals(objectId)) {
        String SELECT_DEFAULT_PART_TYPE = "attribute[" + PropertyUtil.getSchemaProperty(context,"attribute_DefaultPartType") + "]";
        String SELECT_PART_FAMILY_NAME_GENERATOR = "attribute[" + PropertyUtil.getSchemaProperty(context,"attribute_PartFamilyNameGeneratorOn") + "]";
        
        StringList objectSelect = new StringList(2);
        objectSelect.add(SELECT_DEFAULT_PART_TYPE);
        objectSelect.add(SELECT_PART_FAMILY_NAME_GENERATOR);
        
        DomainObject domObj = DomainObject.newInstance(context, objectId);
                    
        Map dataMap = domObj.getInfo(context, objectSelect);
        strPFNameGenerator = (String) dataMap.get(SELECT_PART_FAMILY_NAME_GENERATOR);
        strPFDefaultPart = PropertyUtil.getSchemaProperty(context,(String) dataMap.get(SELECT_DEFAULT_PART_TYPE));          
    }
    contentURL = "../common/emxCreate.jsp?nameField=both&slideinType=wider&targetLocation="+targetLocation+"&form=type_CreatePart&header=emxEngineeringCentral.PartCreate.FormHeader&type=type_Part&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&submitAction=doNothing&postProcessURL=../engineeringcentral/PartCreatePostProcess.jsp&createMode=LIB&createJPO=emxPart:createPartJPO&preProcessJavaScript=preProcessCreatePartInFamily&HelpMarker=emxhelppartcreate&objectId=" + objectId + "&PFNameGen=" + strPFNameGenerator + "&defaultPFPart=" + strPFDefaultPart + "&multiPartCreation=" + multiPartCreation+"&typeChooser=true&InclusionList=type_Part&ExclusionList=type_ManufacturingPart,type_ShopperProduct,type_POA,type_Trim,type_Label,type_Packaging,type_RawGoods,type_HardGoodsMaterial,type_TBD,type_Fabric,type_Finishings";
} 
else {

    if (null != objectId && objectId.length() > 0) {
	
	  String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
	  

	  if(tableRowIdList == null){
		  tableRowIdList = new String[1];
		  tableRowIdList[0] = "|"+objectId+"||0";
	  }
	  int nosRowsselected = 0;
	  if(tableRowIdList == null){
	  	nosRowsselected = 0;
	  }
	  else{
	  	nosRowsselected = tableRowIdList.length;
	  }
	  if (null != tableRowIdList) {
	  
		  boolean rootNodeFail = false;
	      //process - relId|objectId|parentId|rowId - using the tableRowId
	      String tableRowId = " "+tableRowIdList[0];
	      StringList slList = FrameworkUtil.split(tableRowId, "|");
	      
	      bomRelId       = ((String)slList.get(0)).trim();
	      bomObjectId    = ((String)slList.get(1)).trim();
	      bomParentOID   = ((String)slList.get(2)).trim();
	      sRowId  = ((String)slList.get(3)).trim();
	      replaceRowQuantity = BOMMgtUtil.isNotNullAndNotEmpty(bomRelId)?BOMMgtUtil.getRollupQuantity(context, bomRelId):"";
	      UOMTypeOnNewPart = (String)(DomainObject.newInstance(context,bomObjectId)).getInfo(context, EngineeringConstants.SELECT_UOM_TYPE);
	      //Instance management Start
	      if(isInstaceMode){
	          if(UIUtil.isNotNullAndNotEmpty(bomRelId)){
	        	  Map eBOMAttr = BOMMgtUtil.getEBOMAttribute(context, bomRelId);
	        	  String sUOMStored = (String)eBOMAttr.get(EngineeringConstants.ATTRIBUTE_UNIT_OF_MEASURE);
	        	  String sQtyStored = (String)eBOMAttr.get(EngineeringConstants.ATTRIBUTE_QUANTITY);
	        	  isLagacyComponent = (rangeEAeach.equals(sUOMStored) && !sQtyStored.equals("1.0"));
	        	  if(isLagacyComponent){
		        			  %>
		            	<script language="Javascript">
		          	                    //XSSOK
		          	        
			            	if("EBOMReplaceNew"=="<%=sCreateMode%>" || "UEBOMReplaceNew"=="<%=sCreateMode%>" || "<xss:encodeForJavaScript><%=fromMarkupView%></xss:encodeForJavaScript>"=="true"){
			            		if("Rollup" != getTopWindow().getWindowOpener().getParameter("BOMViewMode")){
			            		//XSSOK
			            		alert('<%=strInstanceModeErrorMessage%>');
			    	            getTopWindow().closeWindow();
			            		}
				    		}else{
				    			
	          	                		var targetFrame =  findFrame(getTopWindow(),"ENCBOM");
	          					targetFrame = targetFrame ?  targetFrame :  findFrame(getTopWindow(),"content");
	          					if(targetFrame){
	          						BOMViewMode =  targetFrame.getParameter("BOMViewMode");
	          					}
	          					if("Rollup" != BOMViewMode){
	          						//XSSOK
					    			alert('<%=strInstanceModeErrorMessage%>');
					    			getTopWindow().window.closeSlideInPanel();
				    			}
				    		}                
		             	  </script>
		             	  <%
	        	}
	          }
          }
	    //Instance management END
	    
	      selectedPartState      = (String)(DomainObject.newInstance(context,bomObjectId)).getInfo(context, com.matrixone.apps.domain.DomainConstants.SELECT_CURRENT);
          String parentPartState;		          
          if (!"".equalsIgnoreCase(bomParentOID) && UIUtil.isNotNullAndNotEmpty(bomParentOID)) {
        	  parentPartState  = (String)(DomainObject.newInstance(context,bomParentOID)).getInfo(context, com.matrixone.apps.domain.DomainConstants.SELECT_CURRENT);
          }else {
        	  parentPartState  = selectedPartState;
          }
          if (!DomainObject.STATE_PART_PRELIMINARY.equalsIgnoreCase(selectedPartState)) {
          	%>
          	<script language="Javascript">
        	                    //XSSOK
					 	var mode = "";
						var frameName = "ENCBOM";
						frameName = (findFrame(getTopWindow(),"ENCBOM") !=null) ? "ENCBOM" : "content";
						if(findFrame(getTopWindow(),frameName).editableTable){
							mode=findFrame(getTopWindow(),frameName).editableTable.mode;
						}
						if("view" == mode && "EBOMReplaceNew"!='<%=sCreateMode%>'){
							//XSSOK
       	                    alert('<%=partNotInEditMode%>');
       	                    getTopWindow().window.closeSlideInPanel();
						}
           	                    
           	  </script>
           	  <%
			}         
             HashMap paramMap = new HashMap();
         	 paramMap.put("objectId", bomObjectId);
         	 String[] methodargs = JPO.packArgs(paramMap);
         	 boolean status =  JPO.invoke(context, "emxENCActionLinkAccess", null, "isApplyAllowed", methodargs,Boolean.class);
         	 
            if (!status) {
          	  %>
          	  <script language="Javascript">
          	                    //XSSOK
				 	var mode = "";
				 	var encTargetFrame =  findFrame(getTopWindow(),"ENCBOM");
					var	 targetFrame = encTargetFrame ?  encTargetFrame :  findFrame(getTopWindow(),"PUEUEBOM");
					targetFrame = targetFrame ?  targetFrame :  findFrame(getTopWindow(),"content");
					if(targetFrame){
						mode=targetFrame.editableTable.mode;
					}
					if("view" == mode && "EBOMReplaceNew"!='<%=sCreateMode%>'){
						//XSSOK
         	            alert('<%=noModifyAccess%>');
         	            getTopWindow().window.closeSlideInPanel();
					}
         	                    
         	 </script>
         	 <%
			}
            %>
        	  <script language="Javascript">
        	                    //XSSOK
            var nosRowsselected = "<%=nosRowsselected%>";
   			if(nosRowsselected>1){
   				//XSSOK
   				alert("<%=strMultipleSelection%>");
   				getTopWindow().window.closeSlideInPanel();
   			}
   		 </script>
     	 <%
         	if (isECCInstalled) {
            	   String POLICY_CONFIGURED_PART = PropertyUtil.getSchemaProperty(context,"policy_ConfiguredPart");
     	    	  String STATEPRELIMINARY = PropertyUtil.getSchemaProperty(context,"policy",POLICY_CONFIGURED_PART, "state_Preliminary");
     	    	  String STATESUPERSEDED     = PropertyUtil.getSchemaProperty(context,"policy",POLICY_CONFIGURED_PART, "state_Superseded");
     	    	  //String supersededPartAlert = i18nNow.getI18nString("emxUnresolvedEBOM.Alert.SupersededPart","emxUnresolvedEBOMStringResource", language);
     	    	  String supersededPartAlert = EnoviaResourceBundle.getProperty(context ,"emxUnresolvedEBOMStringResource",context.getLocale(),"emxUnresolvedEBOM.Alert.SupersededPart");
     	    	  isWipBomAllowed = FrameworkProperties.getProperty(context, "emxUnresolvedEBOM.WIPBOM.Allowed");
     	          contextECO      = emxGetParameter(request,"PUEUEBOMContextChangeFilter_actualValue");
     	          contextECO      = (contextECO == null || "null".equalsIgnoreCase(contextECO))?"":contextECO;
     	          
     	          //strContextECOSelection = i18nNow.getI18nString("emxUnresolvedEBOM.CommonView.Alert.ContextECOSelection","emxUnresolvedEBOMStringResource", language);
     	          strContextECOSelection = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource",context.getLocale(),"emxUnresolvedEBOM.CommonView.Alert.ContextECOSelection");
	     	          
	              String releaseProcess = DomainObject.newInstance(context, UIUtil.isNullOrEmpty(bomParentOID) ? bomObjectId : bomParentOID).getInfo(context, EngineeringConstants.ATTRIBUTE_RELEASE_PHASE_VALUE);
	              isWipBomAllowed = Boolean.toString(EngineeringConstants.DEVELOPMENT.equals(releaseProcess));
		          
	              if (STATESUPERSEDED.equalsIgnoreCase(parentPartState)) {
	            	  %>
	            	                    <script language="Javascript">
	            	                    //XSSOK
	            	                    alert("<%=supersededPartAlert%>");
	            	                    getTopWindow().window.closeSlideInPanel();
	            	                    </script>
	            	  <%
	            	                 }  
	           	  if (("true".equalsIgnoreCase(isWipBomAllowed)) && STATEPRELIMINARY.equalsIgnoreCase(selectedPartState)) {
		          	    isWipMode = "true";
		          	}
	              //if parent part state is preliminary and development mode setting is true then only wip mode will be true.
                  if (("UEBOMAddNew".equalsIgnoreCase(sCreateMode))) {
                	  String objectIdpolicy = (  bomObjectId == null || "".equals(bomObjectId ) ) ? bomParentOID : bomObjectId;
              		  boolean isConfiguredPart = isConfiguredPart(context, objectIdpolicy);
              		  if (!isConfiguredPart) {
              			%>
              		  		<script language = "javascript">
              				var mode = "";
    						if(findFrame(getTopWindow(),"PUEUEBOM").editableTable){
    							mode=findFrame(getTopWindow(),"PUEUEBOM").editableTable.mode;
    						}
    						if("edit" != mode){
    							//XSSOK
     	                    alert('<%=editUnConfigfromConfig%>');
     	                    getTopWindow().window.closeSlideInPanel();
							}	
              		  		</script>
              			<%				
              		  }
                  	  String objectIdToBeValidated = (  bomObjectId == null || "".equals(bomObjectId ) ) ? bomParentOID : bomObjectId;
	                  boolean changeControlled = isChangeControlled(context, objectIdToBeValidated);
	                  if ( changeControlled ) {
	                  %>
	               	  <script language="Javascript">
	              	  	  var mode = "";
		              	  if(findFrame(getTopWindow(),"PUEUEBOM").editableTable){
		              			mode=findFrame(getTopWindow(),"PUEUEBOM").editableTable.mode;
		              	  }
		              	  if("edit" != mode){
		              		  //XSSOK
		                       alert('<%=editInviewMode%>');
		                       getTopWindow().window.closeSlideInPanel();
		              	  }
	                  </script>
	                  <%
	             	  }
	                  if("true".equalsIgnoreCase(isWipBomAllowed) && STATEPRELIMINARY.equalsIgnoreCase(selectedPartState)){
	                  	isWipMode = "true";
	                  }
	              }
	              if ("true".equalsIgnoreCase(isWipBomAllowed)) {
	                  if ("UEBOMReplaceNew".equalsIgnoreCase(sCreateMode) && STATEPRELIMINARY.equalsIgnoreCase(parentPartState)) {
	                       isWipMode = "true";
	                  }
	              }
	
		          //Starts for 2012x--force check for released parts to follow change proces incase of replace new/Add new 
		          if("".equals(contextECO) && "false".equalsIgnoreCase(isWipMode) && ("UEBOMAddNew".equalsIgnoreCase(sCreateMode) || "UEBOMReplaceNew".equalsIgnoreCase(sCreateMode))) 
		          {
						%>
			          <script language = "javascript">
			          //XSSOK
			          alert("<%=strContextECOSelection%>");
			          getTopWindow().window.closeSlideInPanel();
			            </script>
						<%
				  }
	    }
	 //2012x

	     //IR-083774V6R2012 start
	     boolean boolMBOMInstalled     = EngineeringUtil.isMBOMInstalled(context);
	     String  sSymbolicRelESQName   = FrameworkUtil.getAliasForAdmin(context,"relationship",EngineeringConstants.RELATIONSHIP_EBOM_SPLIT_QUANTITY,true);
	     /*String strWarningAddNewMsg    = i18nNow.getI18nString("emxEngineeringCentral.BOM.AddNewOnDeleted","emxEngineeringCentralStringResource",language);
	     String strWarningANEBOMSQMsg  = i18nNow.getI18nString("emxMBOM.BOM.AddNewOnSplitQuantity","emxMBOMStringResource",language);
         String strWarningREDeleteMsg  = i18nNow.getI18nString("emxEngineeringCentral.BOM.ReplaceWithNewOnAddedDeleted","emxEngineeringCentralStringResource",language);
         String strInvalidSelectionMsg = i18nNow.getI18nString("emxEngineeringCentral.CommonView.Alert.Invalidselection","emxEngineeringCentralStringResource",language);
         String strReplaceErrorMessage = i18nNow.getI18nString("emxEngineeringCentral.BOM.ReplacewithNewFail","emxEngineeringCentralStringResource",language);
        */
        String strWarningAddNewMsg    = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.BOM.AddNewOnDeleted");
	     String strWarningANEBOMSQMsg  = EnoviaResourceBundle.getProperty(context ,"emxMBOMStringResource",context.getLocale(),"emxMBOM.BOM.AddNewOnSplitQuantity");
        String strWarningREDeleteMsg  = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.BOM.ReplaceWithNewOnAddedDeleted");
        String strInvalidSelectionMsg = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.CommonView.Alert.Invalidselection");
        String strReplaceErrorMessage = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.BOM.ReplacewithNewFail");
       
         String sSymbolicRelEBOMName   = FrameworkUtil.getAliasForAdmin(context,"relationship",DomainConstants.RELATIONSHIP_EBOM,true);
         String EBOMPending = PropertyUtil.getSchemaProperty(context, "relationship_EBOMPending");
         String EBOMSubstitute = PropertyUtil.getSchemaProperty(context, "relationship_EBOMSubstitute");
         
         if (EBOMPending == null)
         	EBOMPending="";

	 	  if("EBOMReplaceNew".equalsIgnoreCase(sCreateMode) || "UEBOMReplaceNew".equalsIgnoreCase(sCreateMode)) {
	      {
	    	  String isVPLMControlled = "";
	    	  if(UIUtil.isNotNullAndNotEmpty(bomParentOID)){
	    		  isVPLMControlled = DomainObject.newInstance(context, bomParentOID).getInfo(context, "from["+EngineeringConstants.RELATIONSHIP_PART_SPECIFICATION+"].to.attribute["+EngineeringConstants.ATTRIBUTE_VPM_CONTROLLED+"]");
	    		  if("TRUE".equalsIgnoreCase(isVPLMControlled))
	  			{
	  				%>
	  		          <script>
	  		        var mode = "";
					if(getTopWindow() && getTopWindow().getWindowOpener()){
						mode=getTopWindow().getWindowOpener().editableTable.mode;
					}
					if("view" == mode){
						//XSSOK
	  		    	      alert("<%=strVPLMControlled%>");
	  		    	      getTopWindow().closeWindow();
					}
	  		          </script>
	  		       <%	
	  			 }
	    	  }
	    	   %>
	        	  <script language="Javascript">
	        	                    //XSSOK
	            var nosRowsselected = "<%=nosRowsselected%>";
	   			if(nosRowsselected>1){
	   				//XSSOK
	   				alert("<%=strMultipleSelection%>");
	   				getTopWindow().closeWindow();
	   			}
	   		 </script>
	     	 <%
	     	if (!DomainObject.STATE_PART_PRELIMINARY.equalsIgnoreCase(parentPartState)) {
				%>
				<script language="Javascript">
								//XSSOK
						var mode = "";
						if(getTopWindow() && getTopWindow().getWindowOpener()){
							mode=getTopWindow().getWindowOpener().editableTable.mode;
						}
						if("view" == mode){
							//XSSOK
							alert('<%=partNotInEditMode%>');
						   getTopWindow().closeWindow();
						}    
									
				  </script>
				  <%
			}         
			 HashMap paramMap1 = new HashMap();
			 if ( bomParentOID == null || "".equals(bomParentOID) ) {
			 	paramMap1.put("objectId", bomObjectId);
			 } else {
				 paramMap1.put("objectId", bomParentOID);
			 }
			 String[] methodargs1 = JPO.packArgs(paramMap1);
			 boolean status1 =  JPO.invoke(context, "emxENCActionLinkAccess", null, "isApplyAllowed", methodargs1,Boolean.class);
			 
			  if (!status1) {
				  %>
				  <script language="Javascript">
									//XSSOK
					var mode = "";
					var sCreateMode = '<%=sCreateMode%>';
					if(getTopWindow() && getTopWindow().getWindowOpener()){
						mode=getTopWindow().getWindowOpener().editableTable.mode;
					}
					if("view" == mode){
						//XSSOK
						alert('<%=noModifyAccess%>');
						getTopWindow().closeWindow();
					}          
			 </script>
			 <%
			} 
			  boolean isIntersectEffectivityForReplace = true;
	          if(sRowId.equals("0")) {
                  //String strRootNodeErrorMsgForReplaceNew = i18nNow.getI18nString("emxEngineeringCentral.BOM.ReplaceNewRootNodeError","emxEngineeringCentralStringResource",language);
                  String strRootNodeErrorMsgForReplaceNew = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.BOM.ReplaceNewRootNodeError");
		        	 %>
						<script language="Javascript">
						//XSSOK
						alert("<%=strRootNodeErrorMsgForReplaceNew%>");			
					    getTopWindow().closeWindow();
						</script>
					<%	
				 }
              //checking for the same pending change or not.
              if (sRowId!= null && !(sRowId.equals("0")) && isECCInstalled && "false".equalsIgnoreCase(isWipMode) && "UEBOMReplaceNew".equalsIgnoreCase(sCreateMode)) 
              {
              
              /*String strCyclicDependency  = i18nNow.getI18nString("emxUnresolvedEBOM.CommonView.Alert.Cyclicdependency","emxUnresolvedEBOMStringResource", language);
              String strWarningReplaceExistingMsgForEdit  = i18nNow.getI18nString("emxUnresolvedEBOM.Edit.checkOnPendingChange","emxUnresolvedEBOMStringResource",language);
              String strWarningMSGForIntersectEffectivity = i18nNow.getI18nString("emxUnresolvedEBOM.Edit.EffectivityMatch","emxUnresolvedEBOMStringResource",language);
              */
              String strCyclicDependency  = EnoviaResourceBundle.getProperty(context ,"emxUnresolvedEBOMStringResource", context.getLocale(),"emxUnresolvedEBOM.CommonView.Alert.Cyclicdependency");
              String strWarningReplaceExistingMsgForEdit  = EnoviaResourceBundle.getProperty(context ,"emxUnresolvedEBOMStringResource",context.getLocale(),"emxUnresolvedEBOM.Edit.checkOnPendingChange");
              String strWarningMSGForIntersectEffectivity = EnoviaResourceBundle.getProperty(context ,"emxUnresolvedEBOMStringResource",context.getLocale(),"emxUnresolvedEBOM.Edit.EffectivityMatch");
              String strBlankEffectivityMesg = EnoviaResourceBundle.getProperty(context ,"emxUnresolvedEBOMStringResource",context.getLocale(),"emxUnresolvedEBOM.EBOM.BlankEffectivity.ReplaceOperation");              
              
              Class klass = Class.forName("com.matrixone.apps.unresolvedebom.UnresolvedEBOM");
              Object unresolvedEBOM = klass.newInstance();
              // parameters depending on the bean method
              Class[] inputTypes = new Class[3];
              inputTypes[0]  = matrix.db.Context.class;
              inputTypes[1]  = String.class;
              inputTypes[2]  = String.class;
              Method methods = klass.getMethod("emptyEffectivityReplaceValidation", inputTypes);
              boolean blankEffectivityValidation = (Boolean) methods.invoke(unresolvedEBOM, new Object[] {context, bomRelId, contextECO});
              boolean cyclicDependency = false;
              
              
              if (blankEffectivityValidation) {
              
	              Class c = Class.forName("com.matrixone.apps.unresolvedebom.UnresolvedPart");
	              Object unresolvedPart = c.newInstance();
	              // parameters depending on the bean method
	              Class[] inputType = new Class[3];
	              inputType[0]  = matrix.db.Context.class;
	              inputType[1]  = String.class;
	              inputType[2]  = String.class;
	              Method method = c.getMethod("checkForCyclicPrerequisite", inputType);
	              cyclicDependency = (Boolean)method.invoke(unresolvedPart,new Object[]{context, bomRelId,contextECO});
              
                  try { 
                      Class c1 = Class.forName("com.matrixone.apps.unresolvedebom.PUEChange");
                      Object EFF = c1.newInstance();
                      // parameters depending on the bean method
                      Class[] inputType1 = new Class[3];
                      inputType1[0]  = matrix.db.Context.class;
                      inputType1[1]  = String.class;
                      inputType1[2]  = String.class;
                      Method method1 = c1.getMethod("isIntersectEffectivity", inputType1);
                      isIntersectEffectivityForReplace = (Boolean)method1.invoke(EFF,new Object[]{context, contextECO,bomRelId});                          
                   }  
                   catch (Exception e) 
                   {
                       isIntersectEffectivityForReplace = false;
                   }
              }
%>
                 <script language="Javascript">
                 //XSSOK
                 if(<%=blankEffectivityValidation%> == false) {
                	 //XSSOK
                     alert("<%=strBlankEffectivityMesg%>");         
                     getTopWindow().closeWindow();
                 }
                 
                 if(<%=cyclicDependency%> == true) {
                	 //XSSOK
                     alert("<%=strCyclicDependency%>");         
                     getTopWindow().closeWindow();
                 }
                 //XSSOK
                  if(<%=isIntersectEffectivityForReplace%> == false) {
                	  //XSSOK
                     alert("<%=strWarningMSGForIntersectEffectivity%>");         
                     getTopWindow().closeWindow();
                   }
                   </script>
<%
              }
	      }      
%>
             
                 <script language="Javascript">
                 
	            try {
					var isFROMRMB = "<%=XSSUtil.encodeForJavaScript(context,isFromRMB)%>";
					//XSSOK
					var rmbRowId  = "<%=sRowId%>";
					var xPath     =  isFROMRMB == "true" ?  "/mxRoot/rows//r[@id='"+rmbRowId+"']" : "/mxRoot/rows//r[@checked='checked']";	            	
	            	
	                //var aCopiedRowsChecked = getTopWindow().parent.getWindowOpener().emxUICore.selectSingleNode(getTopWindow().parent.getWindowOpener().oXML.documentElement, "/mxRoot/rows//r[@checked='checked']");
	                //var aCopiedRowsChecked = getTopWindow().parent.getWindowOpener().emxUICore.selectSingleNode(getTopWindow().parent.getWindowOpener().oXML.documentElement, xPath);
	                var aCopiedRowsChecked = getTopWindow().getWindowOpener().emxUICore.selectSingleNode(getTopWindow().getWindowOpener().oXML.documentElement, xPath);
	                var status = aCopiedRowsChecked.getAttribute("status");
	              //XSSOK
	                if("<%=boolMBOMInstalled%>" == "true"){
	                 var rel = aCopiedRowsChecked.getAttribute("rel");
	                 if(rel == null){
	                    rel = aCopiedRowsChecked.getAttribute("relType");
	                }

	                if(rel){
	                    var arrRel = rel.split("|");
	                    //XSSOK
	                    if(arrRel[0] != "<%=DomainConstants.RELATIONSHIP_EBOM%>" && arrRel[0] != "<%=sSymbolicRelEBOMName%>" && arrRel[0] != "<%=EBOMPending%>" && arrRel[0] != "relationship_EBOMPending"){
	                    	//XSSOK
	                        alert("<%=strInvalidSelectionMsg%>");
	                        msgflag = true;
	                        getTopWindow().closeWindow();
	                    }
	                    else if(status == 'add' || status == 'cut'){
	                    	msgflag = true;
	                    	//XSSOK
	                        alert("<%=strWarningREDeleteMsg%>");
	                        getTopWindow().closeWindow();
	                    }
	                }
	                else if(status == 'add' || status == 'cut'){
	                	//XSSOK
	                    alert("<%=strWarningREDeleteMsg%>");
	                    getTopWindow().closeWindow();
	                }
					}
					else{
						if(status == 'add' || status == 'cut'){
							msgflag = true;
							//XSSOK
		                    alert("<%=strWarningREDeleteMsg%>");
		                    getTopWindow().closeWindow();
	                }
					}
	            }
	            catch(e){
	            	//XSSOK
	                alert("<%=strReplaceErrorMessage%>"+e.message);
	                getTopWindow().closeWindow();
	            }
			        </script>
<%
	      }
	     
		      %>
          <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
          <script language="javascript">
          var targetFrame ="";
          var fromMarkupView = "<%=fromMarkupView%>";

          if("<%=fromView%>"=="MBOMCommon") {
         	 targetFrame = findFrame(getTopWindow(),"MBOMCommon");
          }	 
          else if(fromMarkupView == "true") {
        	  targetFrame = parent.getWindowOpener();
          } 	  
          else{
        	 var encTargetFrame =  findFrame(getTopWindow(),"ENCBOM");
           	 targetFrame = encTargetFrame ?  encTargetFrame :  findFrame(getTopWindow(),"PUEUEBOM");
           	 targetFrame = targetFrame ?  targetFrame :  findFrame(getTopWindow(),"content");
	       }
          
			var isFROMRMB1 = "<%=XSSUtil.encodeForJavaScript(context,isFromRMB)%>";
			//XSSOK
			var rmbRowId1  = "<%=sRowId%>";
			var xPath1     =  isFROMRMB1 == "true" ?  "/mxRoot/rows//r[@id='"+rmbRowId1+"']" : "/mxRoot/rows//r[@checked='checked']";	            	

			var findNumberIndex = targetFrame.colMap.getColumnByName("Find Number").index;
		    var checkedRows = emxUICore.selectNodes(targetFrame.oXML.documentElement, xPath1); 
		    //var findNumberList = emxUICore.selectNodes(targetFrame.oXML.documentElement, "/mxRoot/rows//r[@checked='checked']/r/c["+findNumberIndex+"]/text()"); 
		    var findNumberList = emxUICore.selectNodes(targetFrame.oXML.documentElement, xPath1+"/r/c["+findNumberIndex+"]/text()");
		    if(checkedRows.length == 0  || rmbRowId1 == "0"){
		    	xPath1 = "/mxRoot/rows//r[@id='0']";
		    	findNumberList = emxUICore.selectNodes(targetFrame.oXML.documentElement, xPath1+"/r/c["+findNumberIndex+"]/text()");
		    }
		    var findNumberValue	= new Array();
		    var k=0;
		    for(var i=0;i<findNumberList.length;i++) {
		    	var currFNValue = findNumberList[i].nodeValue;
		    	if(currFNValue.indexOf(",")>-1){
		    		var fnValuesSingleRow = currFNValue.split(",");
		    		for(var l=0;l<fnValuesSingleRow.length;l++) {
		    			findNumberValue[k] = fnValuesSingleRow[l];
		    			k++;
		    		}
		    	}
		    	else { findNumberValue[k] = findNumberList[i].nodeValue; k++;}
		    }
		    for(j=0;j<findNumberValue.length;j++){
		    	if (findNumberValue[j] != "") {
		     	var intNodeValue = parseInt(findNumberValue[j]);
		     	if(j==0)
		     		highest = intNodeValue;
		     	else if (highest<intNodeValue)
		     		highest = intNodeValue;    	
		    	}
		     }
            //var aCopiedRowsChecked = targetFrame.emxUICore.selectSingleNode(targetFrame.oXML.documentElement, "/mxRoot/rows//r[@checked='checked']");
            var aCopiedRowsChecked = targetFrame.emxUICore.selectSingleNode(targetFrame.oXML.documentElement, xPath1);
		    var status = aCopiedRowsChecked.getAttribute("status");
		    
		 	
		  //XSSOK
                if("<%=boolMBOMInstalled%>" == "true"){
                var rel = aCopiedRowsChecked.getAttribute("rel");
                if(rel == null){
                    rel = aCopiedRowsChecked.getAttribute("relType");
                }
                if(rel && msgflag == false){
                    var arrRel = rel.split("|");
                  //XSSOK
                    if(arrRel[0] == "<%=EngineeringConstants.RELATIONSHIP_EBOM_SPLIT_QUANTITY%>" || arrRel[0] == "<%=sSymbolicRelESQName%>"){
                    	//XSSOK
                        alert("<%=strWarningANEBOMSQMsg%>");
                        //getTopWindow().closeWindow();
                        fromMarkupView == "true" ? getTopWindow().closeWindow() : getTopWindow().closeSlideInDialog();
                    }
                  //XSSOK
                    else if(status == 'cut' && (arrRel[0] == "<%=DomainConstants.RELATIONSHIP_EBOM%>" || arrRel[0] == "<%=DomainConstants.RELATIONSHIP_ALTERNATE%>" || arrRel[0] == "relationship_EBOMSubstitute" || arrRel[0] == "<%=EBOMSubstitute%>" || arrRel[0] == "<%=sSymbolicRelEBOMName%>" || arrRel[0] == "<%=EBOMPending%>" || arrRel[0] == "relationship_EBOMPending") ){
                    	//XSSOK
                        alert("<%=strWarningAddNewMsg%>");
                        //getTopWindow().window.closeSlideInPanel();
                        fromMarkupView == "true" ? getTopWindow().closeWindow() : getTopWindow().closeSlideInDialog();
                    }
                }
              //XSSOK
             }else if ("<%=isECCInstalled%>" && "<xss:encodeForJavaScript><%=sCreateMode%></xss:encodeForJavaScript>" == 'UEBOMAddNew') {
		           	 if (status == 'cut' || status == 'add') {
		           		 //XSSOK
		                    alert("<%=strWarningAddNewMsg%>");
		                    getTopWindow().window.closeSlideInPanel();
	
		                }
             }
                else{
	                if(status == 'cut' && msgflag == false){
	                	 //XSSOK
	                    alert("<%=strWarningAddNewMsg%>");
	                    //getTopWindow().window.closeSlideInPanel();
	                    fromMarkupView == "true" ? getTopWindow().closeWindow() : getTopWindow().closeSlideInDialog();
	                }
				}
		      
          </script>
       <%   
              if(sCreateMode.equals("EBOMReplaceNew") || sCreateMode.equals("UEBOMReplaceNew")){	    	    
            	  		contentURL = "../common/emxCreate.jsp?nameField=both&form=type_CreatePart&header=emxEngineeringCentral.Replace.ReplaceWithNew&type=type_Part&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&postProcessURL=../engineeringcentral/PartCreatePostProcess.jsp&createMode="+sCreateMode+"&contextECO="+contextECO+"&isWipMode="+isWipMode+"&createJPO=emxPart:createPartJPO&HelpMarker=emxhelppartcreate&targetLocation=replace&SuiteDirectory="+SuiteDirectory+"&StringResourceFileId="+StringResourceFileId+"&suiteKey="+suiteKey+"&bomRelId="+bomRelId+"&bomObjectId="+bomObjectId+"&bomParentOID="+bomParentOID+"&sRowId="+sRowId+"&preProcessJavaScript=preProcessInCreatePartIntermediate&typeChooser=true&InclusionList=type_Part&ExclusionList=type_ManufacturingPart,type_ShopperProduct,type_POA,type_Trim,type_Label,type_Packaging,type_RawGoods,type_HardGoodsMaterial,type_TBD,type_Fabric,type_Finishings,type_GraphicPart";
	      }else if (sCreateMode.equals("EBOM") || sCreateMode.equals("UEBOMAddNew")) {
	    	  	contentURL = "../common/emxCreate.jsp?nameField=both&form=type_CreatePart&submitAction=doNothing&type=type_Part&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&createMode="+sCreateMode+"&createJPO=emxPart:createPartJPO&uiType=structureBrowser&addNew=true&showApply=true&contextECO="+contextECO+"&postProcessURL=../engineeringcentral/PartCreatePostProcess.jsp&HelpMarker=emxhelppartcreate&targetLocation="+targetLocation+"&slideinType=wider&SuiteDirectory="+SuiteDirectory+"&StringResourceFileId="+StringResourceFileId+"&suiteKey="+suiteKey+"&bomRelId="+bomRelId+"&bomObjectId="+bomObjectId+"&bomParentOID="+bomParentOID+"&sRowId="+sRowId+"&sDisableSparePartYesOption=true"+"&preProcessJavaScript=preProcessInCreatePartIntermediate&isWipMode="+isWipMode + "&multiPartCreation=" + multiPartCreation+"&typeChooser=true&InclusionList=type_Part&ExclusionList=type_ManufacturingPart,type_ShopperProduct,type_POA,type_Trim,type_Label,type_Packaging,type_RawGoods,type_HardGoodsMaterial,type_TBD,type_Fabric,type_Finishings,type_GraphicPart&fromMarkupView="+fromMarkupView;
	    	  if(EngineeringUtil.isMBOMInstalled(context)){
	    		  
	    		  contentURL = contentURL+"&fromView="+fromView;
	    	  }
          }else if(sCreateMode.equals("MFG")){
 
        	  boolean bIsCurrent = false;
        	  boolean isPlantMember = false;
        	  
        	  String tmpId = "";
        	  String mqlQuery = "";
        	  String strErrMsg = "";
        	  String strPlantId = "";
        	  String strBOMView = "";
        	  String attrPlantID = "";
        	  String strContextMCO = "";
        	  String strMBOMStatusQuery = "";
        	  String selectedParentMBOMStatus = "";
        	  String strContextMCOSelectionMSG = "";
        	  
        	  StringList assignedPlantList = null;
        	  
        	  try{	        	 
        		  strBOMView = emxGetParameter(request,"MFGMBOMViewCustomFilter"); 
	        	  strPlantId = emxGetParameter(request,"MFGMBOMPlantCustomFilter"); 
	        	  strContextMCO = emxGetParameter(request,"MFGMBOMMCOContextChangeFilter");
	        	  strContextMCO = (UIUtil.isNullOrEmpty(strContextMCO))?"":strContextMCO;
	        	  
	        	  strContextMCOSelectionMSG = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.PlantSpecificView.Alert.ContextMCOSelection");
	        	  
	        	  if("Current".equals(strBOMView))
	        		{
	        		  strContextMCOSelectionMSG = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.MBOMCustomFilter.AlertMessage");
	 	        	 
	        		}
        	  
        	  if("0".equals(sRowId) && "".equals(bomParentOID)){
				  bomParentOID = bomObjectId;
              }
	        	  assignedPlantList = getAssignedPlants(context);
        	  
	          if(UIUtil.isNullOrEmpty(strContextMCO)){
        	  
	        		  strErrMsg = strContextMCOSelectionMSG;
	        		  
	          }else if(UIUtil.isNullOrEmpty(strPlantId)){
        		  
        		  strErrMsg = EnoviaResourceBundle.getProperty(context,"emxMBOMStringResource",context.getLocale(),"emxMBOM.Common.Process.Error");
        		  strErrMsg += EnoviaResourceBundle.getProperty(context,"emxMBOMStringResource",context.getLocale(),"emxMBOM.Deviation.Raise.Error_2");
        		  
        	  }else{
        		  
        		  for (int j = 0; j < assignedPlantList.size(); j++) {
      				attrPlantID = (String) assignedPlantList.get(j);
      					if(attrPlantID.equals(strPlantId)) {
      						isPlantMember = true;
      						break;
      					}
      				}
	        		  if(!isPlantMember) {
           	  
	        			  strErrMsg = EnoviaResourceBundle.getProperty(context,"emxMBOMStringResource", context.getLocale(),"emxMBOM.Common.Process.Error") + ".";
	        			  strErrMsg += EnoviaResourceBundle.getProperty(context,"emxMBOMStringResource", context.getLocale(),"emxMBOM.Common.Membership.Error");
	  	          }
        	  }
        	  
        	  if(UIUtil.isNotNullAndNotEmpty(strErrMsg)){        		
   %>
   	          <script language = "javascript">
   	          //XSSOK
   	          var sERRORMSG = "<%=strErrMsg%>";
   	          //XSSOK
   	          var sContextMCOSelectionMSG = "<%=strContextMCOSelectionMSG%>";
   	       	  alert(sERRORMSG);
   	          getTopWindow().closeWindow();
   	          var sRef  = getTopWindow().getWindowOpener();
   	         if(sERRORMSG==sContextMCOSelectionMSG){
	   	        if(sRef!=undefined){
	   	        	sRef.showAutoFilterDisplay();
	   			  }
	             }	
        	  
   	            </script>
	  			 <% } else{
		  			contentURL = "../common/emxCreate.jsp?nameField=both&form=type_CreatePart&header=emxEngineeringCentral.MBOM.CreateManufacturingPart&type=type_MaterialPart,type_ToolPart,type_SupportPart&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&createMode="+sCreateMode+"&createJPO=emxPart:createPartJPO&uiType=structureBrowser&addNew=true&showApply=true&contextECO="+contextECO+"&MFGMBOMMCOContextChangeFilter=" + strContextMCO + "&postProcessURL=../manufacturingchange/MFGPartCreatePostProcess.jsp&HelpMarker=emxhelppartcreate&targetLocation="+targetLocation+"&slideinType=wider&SuiteDirectory="+SuiteDirectory+"&StringResourceFileId="+StringResourceFileId+"&suiteKey="+suiteKey+"&bomRelId="+bomRelId+"&bomObjectId="+bomObjectId+"&bomParentOID="+bomParentOID+"&sRowId="+sRowId+"&preProcessJavaScript=preProcessInCreatePartIntermediate&isWipMode="+isWipMode + "&multiPartCreation=" + multiPartCreation+"&typeChooser=true&InclusionList=type_MaterialPart,type_ToolPart,type_SupportPart";
	  			    }
	          }catch(Exception e){
	        	  throw e;
	          }
           }
	  }	    
} else {
	   contentURL = "../common/emxCreate.jsp?nameField=both&form=type_CreatePart&header=emxEngineeringCentral.PartCreate.FormHeader&type=type_Part&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&submitAction=treeContent&postProcessURL=../engineeringcentral/PartCreatePostProcess.jsp&createMode=EBOMReplaceNew&createJPO=emxPart:createPartJPO&HelpMarker=emxhelppartcreate&targetLocation="+targetLocation+"&slideinType=wider&SuiteDirectory="+SuiteDirectory+"&StringResourceFileId="+StringResourceFileId+"&suiteKey="+suiteKey+"&preProcessJavaScript=preProcessInCreatePartIntermediate&typeChooser=true&InclusionList=type_Part&ExclusionList=type_ManufacturingPart,type_ShopperProduct,type_Fabric,type_Trim,type_Label,type_Packaging,type_Finishings,type_RawGoods,type_HardGoodsMaterial,type_GraphicPart";
}
}
%>

<%!

	public StringList getAssignedPlants(Context context) throws Exception{
		
		String TYPE_PLANT    = PropertyUtil.getSchemaProperty(context,"type_Plant");
		com.matrixone.apps.common.Person contextUser =	com.matrixone.apps.common.Person.getPerson(context);
		
		String objectWhere = DomainConstants.SELECT_CURRENT + " == " + DomainConstants.STATE_PERSON_ACTIVE;
		
		MapList plantList =	contextUser.getRelatedObjects(context, DomainConstants.RELATIONSHIP_MEMBER, TYPE_PLANT, new StringList(EngineeringConstants.SELECT_PLANT_ID), null, true, false, (short) 1, objectWhere, null);
		StringList slassignedPlant = new StringList();
		for(int i = 0; i < plantList.size(); i++) {
			String attrPlantID	= (String)((Map)plantList.get(i)).get(EngineeringConstants.SELECT_PLANT_ID);
			slassignedPlant.add(attrPlantID);
		}
		return slassignedPlant;
	}
	public boolean isChangeControlled(Context context, String objectId) throws MatrixException {
		String strChangeControlled = DomainObject.newInstance(context, objectId).getAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_ChangeControlled"));
		
		return "True".equalsIgnoreCase(strChangeControlled);
	}
	public boolean isConfiguredPart(Context context, String objectId) throws MatrixException {
		String strObjectPolicy = DomainObject.newInstance(context, objectId).getInfo(context,DomainObject.SELECT_POLICY);
		
		return EngineeringConstants.POLICY_CONFIGURED_PART.equalsIgnoreCase(strObjectPolicy);
	}
%>


<html>
<head>
</head>
<body scrollbar="no" border="0">
<script language="JavaScript" type="text/javascript">
//XSSOK
var frameName = "ENCBOM";
var sCreateMode = '<%=sCreateMode%>';
if(sCreateMode == "EBOMReplaceNew" || sCreateMode == "UEBOMReplaceNew"){
	frameName = getTopWindow().getWindowOpener().name;
	BOMViewMode = getTopWindow().getWindowOpener().getParameter("BOMViewMode");
}
var prmode = "";
var selPartRowId = "";
var sCreateMode = '<%=sCreateMode%>';
//XSSOK
var rmbRowId1  = "<%=sRowId%>";
var encTargetFrame =  findFrame(getTopWindow(),frameName);
var	 targetFrame = encTargetFrame ?  encTargetFrame :  findFrame(getTopWindow(),"PUEUEBOM");
targetFrame = targetFrame ?  targetFrame :  findFrame(getTopWindow(),"content");
var scontentURL = '<%=XSSUtil.encodeForJavaScript(context,contentURL)%>';
var WorkUnderOID = "";
if(sCreateMode=="EBOM" || sCreateMode=="UEBOMAddNew"){
	prmode=((targetFrame&& targetFrame.editableTable) && (sCreateMode=="EBOM" || sCreateMode=="UEBOMAddNew"))?targetFrame.editableTable.mode:"";
	if(prmode=="edit"){
		scontentURL = scontentURL+'&header=emxEngineeringCentral.InsertNew.PartasMarkup';
	}
	else {
		scontentURL = scontentURL+'&header=emxEngineeringCentral.InsertNew.Part';
	}
	WorkUnderOID = (targetFrame)?targetFrame.getRequestSetting("ChangeAuthoringContextOID"):"";
	if (WorkUnderOID == null || WorkUnderOID == 'undefined' || WorkUnderOID == undefined) {
        WorkUnderOID = "";
    }
}
else if(sCreateMode=="EBOMReplaceNew" || sCreateMode=="UEBOMReplaceNew"){
	var contentFrame =  getTopWindow().getWindowOpener();
	var objColumn = contentFrame.colMap.getColumnByName("Quantity");
	var colIndex = objColumn.index;
	var replaceRowQuantity1 = getTopWindow().getWindowOpener().emxUICore.selectSingleNode(getTopWindow().getWindowOpener().oXML.documentElement, xPath1+"/c["+colIndex+"]").getAttribute("a");
	prmode=((getTopWindow() && getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().editableTable))?getTopWindow().getWindowOpener().editableTable.mode:"";
	WorkUnderOID = ((getTopWindow() && getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().editableTable))?getTopWindow().getWindowOpener().getRequestSetting("ChangeAuthoringContextOID"):"";
	
	if (WorkUnderOID == null || WorkUnderOID == 'undefined' || WorkUnderOID == undefined) {
        WorkUnderOID = "";
    }
}
if(sCreateMode=="fromPartFamily"){
	//XSSOK
	scontentURL=scontentURL+'&highestFN='+highest+'&prmode='+prmode+'&selPartRowId='+rmbRowId1+'&BOMViewMode='+BOMViewMode+'&UOMTypeOnNewPart='+'<%=UOMTypeOnNewPart%>'+'&replaceRowQuantity='+replaceRowQuantity1;
}else{
	//XSSOK
	scontentURL=scontentURL+'&highestFN='+highest+'&prmode='+prmode+'&selPartRowId='+rmbRowId1+'&BOMViewMode='+BOMViewMode+'&UOMTypeOnNewPart='+'<%=UOMTypeOnNewPart%>'+'&replaceRowQuantity='+replaceRowQuantity1+'&WorkUnderOID='+WorkUnderOID;
}
	document.location.href=scontentURL;


</script>
</body>
</html>
              
	      
   
