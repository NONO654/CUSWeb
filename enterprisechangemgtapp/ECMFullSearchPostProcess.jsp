<%--
  ECMFullSearchPostProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  static const char RCSID[] = "$Id: ECMFullSearchPostProcess.jsp 1.13 Tue Oct 28 23:01:03 2008 przemek Experimental przemek $";
  
  ECMFullSearchPostProcess.jsp which is post process jsp for all the add existing operations from toolbar.
  
--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "ECMDesignTopInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="changeUtil" class="com.dassault_systemes.enovia.enterprisechangemgt.util.ChangeUtil" scope="session"/>
<jsp:useBean id="mChangeOrder" class="com.dassault_systemes.enovia.enterprisechange.modeler.ChangeOrder" scope="session"/>
<jsp:useBean id="mChangeRequest" class="com.dassault_systemes.enovia.enterprisechange.modeler.ChangeRequest" scope="session"/>
<jsp:useBean id="changeUXUtil" class="com.dassault_systemes.enovia.enterprisechangemgtapp.common.ChangeUXUtil" scope="session"/>

<%
    String strMode         = emxGetParameter(request, "mode");
	String strSubmitAction         = emxGetParameter(request, "submitAction");
	
    String functionality   = emxGetParameter(request, "functionality");    
    String strTreeId       = emxGetParameter(request,"jsTreeID");
    String objectId        = emxGetParameter(request, "objectId");
    String targetObjId      = emxGetParameter(request, "newObjectId");
    String frameName       = emxGetParameter(request, "frameName");
    String targetLocation         = emxGetParameter(request, "targetLocation");
    targetLocation         =  !UIUtil.isNullOrEmpty(targetLocation) ? targetLocation : "";
    boolean boolAddAffectedItem = true; // added for configured part adding from My ENG view 
    
    String strLanguage     = context.getSession().getLanguage();    
    String errorMessage    = ""; 
    
    String strIsFrom            = emxGetParameter(request, "isFrom");
    String strRelSymbolic       = emxGetParameter(request, "targetRelName");
    String tmplId = emxGetParameter(request,"tmplId");
    String strRelationshipName  = ""; 
    strRelationshipName =  !UIUtil.isNullOrEmpty(strRelSymbolic) ? PropertyUtil.getSchemaProperty(context, strRelSymbolic) : "";
    String emxTableRowIds[]     = emxGetParameterValues(request, "emxTableRowId");
    Map objToRelIdMap = null;    
    ChangeOrder changeOrder = !changeUtil.isNullOrEmpty(objectId) ? new ChangeOrder(objectId) : new ChangeOrder(objectId);
    StringList selectedItemsList;DomainObject fromObj = null;DomainObject toObj = null;DomainRelationship rel = null;
    StringList selectedRelList;
    String stringResFileId = "emxEnterpriseChangeMgtStringResource";
    String strInvalidAffectedItems = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Message.InvalidRelatedItem");
    String strMergeCAmsg = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Message.MergeCA");
    String strValidCAMsg =  EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(),"EnterpriseChangeMgt.Alert.CAActions");
    String strInvalidObjectts = "";
    Map mpInvalidObjects = null;
    try {       
        
        ContextUtil.startTransaction(context,true);
        if (("AffectedItemsAddExisting".equalsIgnoreCase(functionality) || "AffectedItemsAddExistingForCR".equalsIgnoreCase(functionality))&& emxTableRowIds != null) {
        	selectedItemsList = changeUtil.getObjectIdsFromTableRowID(emxTableRowIds);
        	mpInvalidObjects = changeOrder.connectAffectedItems(context, selectedItemsList);
    		strInvalidObjectts = (String)mpInvalidObjects.get("strErrorMSG");
    		
        } else if ("AddToExistingChange".equalsIgnoreCase(functionality) || "AddToNewChange".equalsIgnoreCase(functionality) ||
        		   "ECMAddToExistingCO".equalsIgnoreCase(functionality) || "ECMAddToNewCO".equalsIgnoreCase(functionality)) {
        	targetObjId        = changeUtil.isNullOrEmpty(targetObjId) ? (String)(changeUtil.getObjectIdsFromTableRowID(emxTableRowIds)).get(0) : targetObjId;
			selectedItemsList  = ("ECMAddToExistingCO".equalsIgnoreCase(functionality) || "ECMAddToNewCO".equalsIgnoreCase(functionality)) ? new StringList(objectId) : changeUtil.getObjectIdsFromTableRowID((String[])session.getAttribute("sourceAffectedItemRowIds"));
			context		       = ("AddToNewChange".equalsIgnoreCase(functionality) || "ECMAddToNewCO".equalsIgnoreCase(functionality)) ? (matrix.db.Context)request.getAttribute("context") : context;			
			changeOrder	       = new ChangeOrder(targetObjId);			
			// Removed effectivity check as per discussion with se3, know onword we are supporting applicability on Change Action
				mpInvalidObjects   = changeOrder.connectAffectedItems(context, selectedItemsList);
				strInvalidObjectts = (String)mpInvalidObjects.get("strErrorMSG");
    		
	    } else if ("AddToExistingChangeRequest".equalsIgnoreCase(functionality) || "AddToNewChangeRequest".equalsIgnoreCase(functionality) ||
	    		   "ECMAddToExistingCR".equalsIgnoreCase(functionality) || "ECMAddToNewCR".equalsIgnoreCase(functionality))  {
	    	targetObjId   = changeUtil.isNullOrEmpty(targetObjId) ? (String)(changeUtil.getObjectIdsFromTableRowID(emxTableRowIds)).get(0) : targetObjId;
			StringList affeItemList = ("ECMAddToExistingCR".equalsIgnoreCase(functionality) || "ECMAddToNewCR".equalsIgnoreCase(functionality)) ? new StringList(objectId) : (StringList)session.getAttribute("sourceAffectedItemRowIds");
			context		  =  ("AddToNewChangeRequest".equalsIgnoreCase(functionality) || "ECMAddToNewCR".equalsIgnoreCase(functionality)) ? (matrix.db.Context)request.getAttribute("context") : context;
			ChangeRequest changeRequest	  = new ChangeRequest(targetObjId);
			mpInvalidObjects = changeRequest.connectAffectedItems(context, affeItemList);
    		strInvalidObjectts = (String)mpInvalidObjects.get("strErrorMSG");
	    } else if ("AddToExistingChangeAction".equalsIgnoreCase(functionality) || "AddToExistingCA".equalsIgnoreCase(functionality) 
	    		|| "AddToNewChangeAction".equalsIgnoreCase(functionality) || "AddToNewCA".equalsIgnoreCase(functionality))  {
	    	targetObjId   = changeUtil.isNullOrEmpty(targetObjId) ? (String)(changeUtil.getObjectIdsFromTableRowID(emxTableRowIds)).get(0) : targetObjId;
	    	selectedItemsList  = ("AddToExistingCA".equalsIgnoreCase(functionality) || "AddToNewCA".equalsIgnoreCase(functionality)) ? new StringList(objectId) : (StringList)session.getAttribute("sourceAffectedItemRowIds");
			context		  =  ("AddToNewChangeAction".equalsIgnoreCase(functionality) || "AddToNewCA".equalsIgnoreCase(functionality)) ? (matrix.db.Context)request.getAttribute("context") : context;
			ChangeAction changeAction	  = new ChangeAction(targetObjId);
			mpInvalidObjects = changeAction.connectAffectedItems(context, selectedItemsList);
 		strInvalidObjectts = (String)mpInvalidObjects.get("strErrorMSG");
	    }
	    else if (("AddExisting".equalsIgnoreCase(functionality) || "AddExistingRelatedCAs".equalsIgnoreCase(functionality) || "AddExistingPrerequisiteCOs".equalsIgnoreCase(functionality) || "AddExistingResolvedItems".equalsIgnoreCase(functionality)) && emxTableRowIds != null) {                                  	 
    		selectedItemsList = changeUtil.getObjectIdsFromTableRowID(emxTableRowIds);
    		changeOrder.connect(context, selectedItemsList,strRelationshipName,"true".equalsIgnoreCase(strIsFrom)? true : false);
	    } else if ("CAAffectedItemsAddExisting".equalsIgnoreCase(functionality) && emxTableRowIds != null) {
        	selectedItemsList = changeUtil.getObjectIdsFromTableRowID(emxTableRowIds);
        	mpInvalidObjects = new ChangeAction(objectId).connectAffectedItems(context, selectedItemsList);
    		strInvalidObjectts = (String)mpInvalidObjects.get("strErrorMSG");
        } else if ("MoveToNewCA".equalsIgnoreCase(functionality)) {
        	Map mapObjIdRelId 	  = changeUXUtil.getObjRelRowIdsMapFromTableRowID(emxTableRowIds);        	
        	changeOrder		  = new ChangeOrder(objectId);
			  changeOrder.moveToChangeAction(context, (StringList)mapObjIdRelId.get("RelId"),(StringList)mapObjIdRelId.get("ObjId"),null);
        } else if ("MoveToExistingCA".equalsIgnoreCase(functionality)) {
        	selectedItemsList = changeUtil.getObjectIdsFromTableRowID(emxTableRowIds);
			Map mapObjIdRelId 	  = changeUXUtil.getObjRelRowIdsMapFromTableRowID((String[])session.getAttribute("sourceAffectedItemRowIds"));        	
        	changeOrder		  = new ChangeOrder(objectId);
			  changeOrder.moveToChangeAction(context, (StringList)mapObjIdRelId.get("RelId"),(StringList)mapObjIdRelId.get("ObjId"),(String)selectedItemsList.get(0));
        } else if ("MergeCA".equalsIgnoreCase(functionality)) {
        	selectedItemsList = changeUtil.getObjectIdsFromTableRowID(emxTableRowIds);
        	if(selectedItemsList.size() > 1){
        		
        		boolean isSuccess = ChangeTemplate.checkSelectedCAType(context, selectedItemsList);
        		if(!isSuccess){%>
                <script language="javascript">          
                    alert("<%=XSSUtil.encodeForJavaScript(context,strValidCAMsg) %>");
                    getTopWindow().closeSlideInDialog();
                    </script>
                <%}
                else{
                	
					changeOrder		  = new ChangeOrder(objectId);
					changeOrder.checkForMergeCA(context, selectedItemsList);
					changeOrder.mergeChangeAction(context,selectedItemsList);
					//code to refresh window after merge
			        %>
			            <script language="javascript">          
			                var detailsDisplay = findFrame(getTopWindow() ,"detailsDisplay"); 
			                if(detailsDisplay){
			                        detailsDisplay.location.href = detailsDisplay.location.href;
			                }
			            </script>
			        <%
        		}
        	}
        	else
        		{
        		functionality = "";
        		errorMessage = XSSUtil.encodeForJavaScript(context,strMergeCAmsg);
        		%>
        		<script language="JavaScript">
        		alert("<%=XSSUtil.encodeForJavaScript(context,strMergeCAmsg)%>");
        		</script>
        		<%
        	}
        	%>
			<script language="JavaScript">
			var detailsDisplay = findFrame(getTopWindow() ,"detailsDisplay"); 
				if(detailsDisplay){
			                    detailsDisplay.location.href = detailsDisplay.location.href;
			    }
			
			</script>
			<%	
        	
        }else if((ChangeConstants.FOR_RELEASE.equalsIgnoreCase(functionality))||(ChangeConstants.FOR_OBSOLETE.equalsIgnoreCase(functionality))){
        	session.removeAttribute("functionality");
        	StringList affeItemList = (StringList)session.getAttribute("sourceAffectedItemRowIds");
			context = (matrix.db.Context)request.getAttribute("context");
    	 	changeOrder.setId(targetObjId);
	        changeOrder.MassReleaseOrObsolete(context,affeItemList,functionality);
    	 	functionality = "MassReleaseOrObsolete";
         }else if ("CRSupportingDocAddExisting".equalsIgnoreCase(functionality)){
        	 selectedItemsList = changeUtil.getObjectIdsFromTableRowID(emxTableRowIds);
     		 changeOrder.connect(context, selectedItemsList,strRelationshipName,"true".equalsIgnoreCase(strIsFrom)? true : false);
        }
         else if("AddCAReferential".equalsIgnoreCase(functionality)){
        	 session.removeAttribute("functionality");
        	 selectedItemsList = changeUtil.getObjectIdsFromTableRowID(emxTableRowIds);
        	 new ChangeAction().addReferential(context, objectId, selectedItemsList);      
%>
<script language="JavaScript">
var detailsDisplay = findFrame(getTopWindow() ,"detailsDisplay"); 
//alert("detailsDisplay"+detailsDisplay);
	if(detailsDisplay){
                    detailsDisplay.location.href = detailsDisplay.location.href;
    }
	getTopWindow().closeWindow();
</script>
<%			 
         }        
        
         else if ("CraeteNewCOUnderCR".equalsIgnoreCase(functionality)){
      		targetObjId        = changeUtil.isNullOrEmpty(targetObjId) ? (String)(changeUtil.getObjectIdsFromTableRowID(emxTableRowIds)).get(0) : targetObjId;
			selectedItemsList  = new StringList(objectId);
			 context		       =  ("CraeteNewCOUnderCR".equalsIgnoreCase(functionality)) ? (matrix.db.Context)request.getAttribute("context") : context;			
			rel = new DomainObject(targetObjId).addFromObject(context,new RelationshipType(ChangeConstants.RELATIONSHIP_CHANGE_ORDER),(String)selectedItemsList.get(0));
	 	}  
         else if ("DocAddExisting".equalsIgnoreCase(functionality)){
        	 selectedItemsList = changeUtil.getObjectIdsFromTableRowID(emxTableRowIds);
        	 boolean bIsFrom = "true".equalsIgnoreCase(strIsFrom)? true : false;
     		DomainRelationship.connect(context,new DomainObject(objectId),strRelationshipName, bIsFrom, (String[])selectedItemsList.toArray(new String[selectedItemsList.size()]));
        }
        
        
        
        
         else if ("CreateNewCOUnderCO".equalsIgnoreCase(functionality)){
       		targetObjId        = changeUtil.isNullOrEmpty(targetObjId) ? (String)(changeUtil.getObjectIdsFromTableRowID(emxTableRowIds)).get(0) : targetObjId;
 			
 			
 			 Map paramMap = new HashMap();
 			
 			String strUIContext = emxGetParameter(request, "UIContext");
 		     
 			if(!ChangeUtil.isNullOrEmpty(objectId)){
 				
 				paramMap.put("objectId",objectId );
 				
 			}
 			
 			
 			paramMap.put("objectCreation","New");
 			paramMap.put("newObjectId",targetObjId);
 			
 			String strXml = changeUtil.getXMLForSB(context, paramMap, ChangeConstants.RELATIONSHIP_CHANGE_BREAKDOWN);
 			
 			%>
        	<script language="JavaScript">
        	<!-- XSSOK -->
        	var strXml="<%=XSSUtil.encodeForJavaScript(context,strXml)%>";
        	var strUIContext="<%=XSSUtil.encodeForJavaScript(context,strUIContext)%>";
        	var frameName = "MyDesk"==strUIContext ? "ECMMyChangeOrders" : "detailsDisplay";
        	var targetFrame = findFrame(getTopWindow(), frameName);
        	targetFrame.emxEditableTable.addToSelected(strXml);
        	getTopWindow().closeSlideInDialog();
        	
        	</script>
        	<%
 	 	}
         else if("CreateExternalChangeAction".equalsIgnoreCase(functionality)){
        	 session.removeAttribute("functionality");
        	 
        	 selectedItemsList = changeUtil.getObjectIdsFromTableRowID(emxTableRowIds);
        	 String[] objectIdArray = new String[selectedItemsList.size()];
        	 
        	 
        	 for(int index=0; index<selectedItemsList.size();index++){
        		 objectIdArray[index] = (String)selectedItemsList.get(index);
     		}
        	 
        	DomainObject domObj = new DomainObject(objectId);
 			if(domObj.isKindOf(context,ChangeConstants.TYPE_CHANGE_ORDER)){
	        	 mChangeOrder.setId(objectId);
        	 mChangeOrder.addChangeActions(context, objectIdArray);
 			}else if(domObj.isKindOf(context,ChangeConstants.TYPE_CHANGE_REQUEST)){
 				mChangeRequest.setId(objectId);
 				mChangeRequest.addChangeActions(context, objectIdArray);
			}
			%>
			<script language="JavaScript">
			var detailsDisplay = findFrame(getTopWindow() ,"detailsDisplay"); 
			//alert("detailsDisplay"+detailsDisplay);
				if(detailsDisplay){
			                    detailsDisplay.location.href = detailsDisplay.location.href;
			    }
			//	getTopWindow().closeWindow();
			</script>
			<%			 
         }  
        
        
        
        
        
        
        ContextUtil.commitTransaction(context);
        if(!ChangeUtil.isNullOrEmpty(strInvalidObjectts)){
        	if (!boolAddAffectedItem) {
        		strInvalidAffectedItems = strInvalidObjectts;
        	} else {
        		strInvalidAffectedItems += strInvalidObjectts;
        	}
        	%>
        	<script language="JavaScript">
        	<!-- XSSOK -->
        	alert("<%=strInvalidAffectedItems%>");
        	</script>
        	<%
        }
    }  catch(Exception e) {
        e.printStackTrace();
        ContextUtil.abortTransaction(context);
        errorMessage=e.getMessage();
        if(!errorMessage.contains("ErrorCode:1500167")){
        	 session.putValue("error.message",errorMessage);
        }
       
    }
%>
 

<script language="javascript" type="text/javaScript">
var isFTS = getTopWindow().location.href.indexOf("common/emxFullSearch.jsp?") != -1;
if(isFTS) {
findFrame(getTopWindow(),"structure_browser").setSubmitURLRequestCompleted();
}
//XSSOK
var error  = "<%=errorMessage%>";
var functionality  = "<%=XSSUtil.encodeForJavaScript(context,functionality)%>";
var stargetLocation ="<%=XSSUtil.encodeForJavaScript(context,targetLocation)%>";
var objectId = "<%=XSSUtil.encodeForJavaScript(context,targetObjId)%>";
var vSubmitAction = "<%=XSSUtil.encodeForJavaScript(context,strSubmitAction)%>";
var vAddExisting = functionality.indexOf("Existing") > -1 ? true : false;



if(("MoveToExistingCA" == functionality || "MoveToNewCA" == functionality || 
	"AffectedItemsAddExistingForCR" == functionality || "AffectedItemsAddExisting" == functionality || "AddExistingResolvedItems" == functionality) && error == "") {
		
	var addExistingCase    = functionality.indexOf("Existing") > -1 ? true : false;
	var ECMCOResolvedItemsFrame = findFrame(addExistingCase ? getTopWindow().getWindowOpener().getTopWindow() :getTopWindow() ,"ECMCOResolvedItems");
	 
	var ECMCAPrerequisitesFrame = findFrame(addExistingCase ? getTopWindow().getWindowOpener().getTopWindow() :getTopWindow() ,"ECMCAPrerequisites");
	
	var ECMCRCOAffectedItemsFrame = findFrame(addExistingCase ? getTopWindow().getWindowOpener().getTopWindow() :getTopWindow() ,"ECMCRCOAffectedItems");	
	
//  IR 454663	
	var windowToRefer = addExistingCase ? getTopWindow().getWindowOpener().getTopWindow() : getTopWindow();
	var varDetailsDisplay = findFrame(windowToRefer, "detailsDisplay");
	
	if(ECMCRCOAffectedItemsFrame && ECMCRCOAffectedItemsFrame.location.origin!='null'){
		ECMCRCOAffectedItemsFrame.location.href = ECMCRCOAffectedItemsFrame.location.href; 
	}else if(ECMCOResolvedItemsFrame && ECMCOResolvedItemsFrame.location.origin!='null'){
		ECMCOResolvedItemsFrame.location.href = ECMCOResolvedItemsFrame.location.href;
    }else if (varDetailsDisplay) {
		varDetailsDisplay.location.href  = varDetailsDisplay.location.href;
	}

	if(ECMCAPrerequisitesFrame){
                    ECMCAPrerequisitesFrame.location.href = ECMCAPrerequisitesFrame.location.href;
    }

	if(vAddExisting == true) {
		getTopWindow().closeWindow();
	}
} else if("CAAffectedItemsAddExisting" == functionality && error == ""){
	var varECM3DAffectedItemsCAFrame = findFrame(getTopWindow(),"ECM3DAffectedItemsCA");
    varECM3DAffectedItemsCAFrame.location.href  = varECM3DAffectedItemsCAFrame.location.href;
	getTopWindow().closeWindow();

} else if("MassReleaseOrObsolete" == functionality && error == ""){
	getTopWindow().closeSlideInDialog();
	parent.location.href = "../common/emxTree.jsp?objectId="+objectId+"&DefaultCategory=ECMChangeContent";

} 
else if(("ECMAddToNewCR" == functionality || "ECMAddToNewCO"==functionality || "ECMAddToExistingCO" == functionality 
		|| "ECMAddToExistingCR" == functionality || "AddToExistingCA" == functionality || "AddToNewCA" == functionality || "CraeteNewCOUnderCR" == functionality) && error == "") {	
	var targetFrameName = ("ECMAddToExistingCO" == functionality || "ECMAddToNewCO" == functionality) ?  "ECMCOs" : (("ECMAddToExistingCR" == functionality || "ECMAddToNewCR" == functionality) ? "ECMCRs" : ("CraeteNewCOUnderCR" == functionality) ? "detailsDisplay": "ECMCAs");
	 //IR-519557-3DEXPERIENCER2018x
	//var windowToRefer   = functionality.indexOf("Existing") >0 ? getTopWindow().getWindowOpener().getTopWindow() : 
	var windowToRefer = "";
	var targetFrame = "";
	if(typeof getTopWindow().SnN != 'undefined' && getTopWindow().SnN.FROM_SNN){

           targetFrame = findFrame(getTopWindow(),targetFrameName);
	}else{
      windowToRefer   = functionality.indexOf("Existing") >0 ? getTopWindow().getWindowOpener().getTopWindow() : getTopWindow();
	  targetFrame     = findFrame(windowToRefer ,targetFrameName);
	}
	
	console.log(targetFrame);
	targetFrame.location.href = targetFrame.location.href;
	console.log(targetFrame.location.href);
	doClose(stargetLocation);
}
//IR-404899-3DEXPERIENCER2017x
else if(("AddToExistingChangeRequest" == functionality || "AddToNewChangeRequest" == functionality || "AddToNewChangeAction" == functionality || "AddToExistingChange" == functionality || "AddToNewChange" == functionality || "AddToExistingChangeAction" == functionality) && error == ""){
	doClose(stargetLocation);
	}
else if("CreateChange" == functionality && error == ""){
	getTopWindow().closeSlideInDialog();
	var contentFrame = findFrame(getTopWindow(), "content");
    if(contentFrame)
    {
        contentFrame.document.location.href = "../common/emxTree.jsp?objectId="+objectId+"&DefaultCategory=ECMChangeContent";
    }else{
	parent.location.href = "../common/emxTree.jsp?objectId="+objectId+"&DefaultCategory=ECMChangeContent";
    }
}else if("AddExistingPrerequisiteCOs" == functionality){
	var frameCOPrequisite =  findFrame(getTopWindow(),"ECMCOPrerequisites");
	frameCOPrequisite.location.href = frameCOPrequisite.location.href;
}else if("AddExisting" == functionality){
	var frameCOResolvedItems =  findFrame(getTopWindow(),"ECMCOResolvedItems");
	frameCOResolvedItems.location.href = frameCOResolvedItems.location.href
}else {
	if (error != "") {
		//alert("Exception Occured : "+error);
	} else {
	     getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
	     getTopWindow().closeWindow();
	}
}

function doClose(targetLocation) {
	"slidein" == targetLocation ? getTopWindow().closeSlideInDialog() : getTopWindow().closeWindow();	
}

</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
