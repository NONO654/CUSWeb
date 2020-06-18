
<%--
  ECMDisconnectProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  static const char RCSID[] = "$Id: ECMDisconnectProcess.jsp 1.13 Tue Oct 28 23:01:03 2008 przemek Experimental przemek $";
  
  ECMDisconnectProcess.jsp is process jsp for all disconnect operations in ECM.
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "ECMDesignTopInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="changeUtil" class="com.dassault_systemes.enovia.enterprisechangemgt.util.ChangeUtil" scope="session"/>
<jsp:useBean id="changeSubscription" class="com.dassault_systemes.enovia.enterprisechangemgt.common.ChangeSubscription" scope="session"/>
<jsp:useBean id="mChangeOrder" class="com.dassault_systemes.enovia.enterprisechange.modeler.ChangeOrder" scope="session"/>
<jsp:useBean id="mChangeRequest" class="com.dassault_systemes.enovia.enterprisechange.modeler.ChangeRequest" scope="session"/>
<jsp:useBean id="changeUXUtil" class="com.dassault_systemes.enovia.enterprisechangemgtapp.common.ChangeUXUtil" scope="session"/>

<%
    String strMode   	   = emxGetParameter(request, "mode");
    String functionality   = emxGetParameter(request, "functionality");    
    String strTreeId 	   = emxGetParameter(request,"jsTreeID");
    String objectId  	   = emxGetParameter(request, "objectId"); 
    String[] strTableRowIds= emxGetParameterValues(request, "emxTableRowId");
    String targetCOId      = emxGetParameter(request, "newObjectId");
    String targetCRId      = emxGetParameter(request, "newObjectId");
    String strCommandName  = emxGetParameter(request, "commandName");
    String tmplId = emxGetParameter(request,"tmplId");
    String strLanguage     = context.getSession().getLanguage();    
    boolean bIsError       = false; 
    String strAlertMessage = DomainConstants.EMPTY_STRING;
	ChangeOrder changeOrder=  new ChangeOrder(objectId);
   
	Map mapObjIdRelId 	   = changeUXUtil.getObjRelRowIdsMapFromTableRowID(strTableRowIds);
	StringList listObjIDs  = (StringList)mapObjIdRelId.get("ObjId");
	StringList listRelIDs  = (StringList)mapObjIdRelId.get("RelId");
	StringList listRowIDs  = (StringList)mapObjIdRelId.get("RowId");
	
	String strValidProxyChangeMsg =  EnoviaResourceBundle.getProperty(context, "emxEnterpriseChangeMgtStringResource", context.getLocale(),"EnterpriseChangeMgt.Alert.ProxyChange");
	
	StringBuffer xmlResponse = new StringBuffer(1024); 
	boolean isRemoveDone     = false; 
	StringList selectedItemsList;
	String errorMessage = "";
	
    try {       
         ContextUtil.startTransaction(context,true);
         if (("disconnectAffectedItem".equalsIgnoreCase(functionality) && listRelIDs != null)) {          	 	
        	 	mapObjIdRelId = changeUXUtil.getObjRelRowIdsMapFromTableRowID(strTableRowIds);
         		changeOrder.disconnectAffectedItems(context,(StringList)mapObjIdRelId.get("RelId"));
         		isRemoveDone = true;
         }
         else if("disconnectAffectedItemFromChangeMgmt".equalsIgnoreCase(functionality)){
        	     mapObjIdRelId = changeUXUtil.getObjRelRowIdsMapFromTableRowID(strTableRowIds);
      		     changeOrder.disconnectAffectedItems(context,(StringList)mapObjIdRelId.get("RelId"));
      		     
      		     xmlResponse.append("<mxRoot>").append("<action>remove</action>");
				 xmlResponse.append(changeUtil.getItemXMLFromList(listRowIDs));
				 xmlResponse.append("</mxRoot>");
				 %>
				 <script language="javascript" type="text/javaScript">
					//XSSOK
					//Added for removing XML Parsing error
					var response = "<%=xmlResponse%>";
					if(response != "")
					{
						parent.removedeletedRows("<%=xmlResponse%>");
					}
				 </script>
				 <%
				
         }
         else if ("disconnect".equalsIgnoreCase(functionality) &&  listRelIDs != null) {                            			        	 
        	 	changeOrder.disconnect(context,listRelIDs);
		      	isRemoveDone = true;
         }
         else if ("MoveToNewCO".equalsIgnoreCase(functionality) || "MoveToExistingCO".equalsIgnoreCase(functionality)) {                                  	
	    		selectedItemsList = strTableRowIds != null ? changeUtil.getObjectIdsFromTableRowID(strTableRowIds) : new StringList();
	    		targetCOId		  = changeUtil.isNullOrEmpty(targetCOId) ? (String)selectedItemsList.get(0) : targetCOId;
        	 	context			  = "MoveToNewCO".equalsIgnoreCase(functionality)? (matrix.db.Context)request.getAttribute("context") : context;        	 	
            	mapObjIdRelId 	  = changeUXUtil.getObjRelRowIdsMapFromTableRowID((String[])session.getAttribute("sourceAffectedItemRowIds"));        	
            	changeOrder.setId(targetCOId);    			
            	changeOrder.moveToChangeOrder(context, (StringList)mapObjIdRelId.get("RelId"), (StringList)mapObjIdRelId.get("ObjId"),objectId); 
        	 	listRowIDs = (StringList)mapObjIdRelId.get("RowId");
        	 	isRemoveDone = true;
				functionality= "move";
		}
         else if ("MoveToNewCR".equalsIgnoreCase(functionality) || "MoveToExistingCR".equalsIgnoreCase(functionality)) {                                  	
        	    selectedItemsList = strTableRowIds != null ? changeUtil.getObjectIdsFromTableRowID(strTableRowIds) : new StringList();
	    		targetCRId		  = changeUtil.isNullOrEmpty(targetCRId) ? (String)selectedItemsList.get(0) : targetCRId;

            	mapObjIdRelId = changeUXUtil.getObjRelRowIdsMapFromTableRowID((String[])session.getAttribute("sourceAffectedItemRowIds"));     	 		listRowIDs		  = (StringList)((Map)changeUXUtil.getObjRelRowIdsMapFromTableRowID((String[])session.getAttribute("sourceAffectedItemRowIds"))).get("RowId");
     	 		context			  = "MoveToNewCR".equalsIgnoreCase(functionality) ? (matrix.db.Context)request.getAttribute("context") : context;
     	 		ChangeRequest changeRequest=  new ChangeRequest(targetCRId);
     	 		changeRequest.moveAffectedItems(context, (StringList)mapObjIdRelId.get("RelId"), (StringList)mapObjIdRelId.get("ObjId"));
      			isRemoveDone = true;
				functionality= "move";
		} else if ("disconnectCAAffectedItem".equalsIgnoreCase(functionality)) {
			 ChangeAction changeAction = new ChangeAction(objectId);
				 changeAction.disconnectAffectedItems(context,listRelIDs);
	    		 isRemoveDone = true;
			
		}
    	else if ("deleteSubscriptions".equalsIgnoreCase(functionality)) {

	   		listObjIDs			  = (UIUtil.isNullOrEmpty(objectId)) ? listObjIDs : new StringList(objectId);
	   		String strObjDeleted  = (String) changeSubscription.deleteSubscriptionEvents(context,listObjIDs);

        %>
		 	<script language="javascript" type="text/javaScript">
        	var channelFrame = findFrame(getTopWindow(),"<%=XSSUtil.encodeForJavaScript(context, strCommandName)%>");
        	
        	if(channelFrame != null){
        		
        	channelFrame.document.location.href = channelFrame.document.location.href;
        	
        	} else {
        		
        		getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
        		getTopWindow().closeWindow();
        		
        	}
        	</script>
        		
        <% 
        		
		 }
    	else if ("removeReferential".equalsIgnoreCase(functionality) &&  listObjIDs != null) {
   			 new ChangeAction().removeReferential(context, objectId, listObjIDs);
    	   	isRemoveDone = true;
	      }
    	else if ("removeExternalChangeAction".equalsIgnoreCase(functionality) &&  listRelIDs != null&&  listObjIDs != null) {
    		String[] relIdArray = new String[listRelIDs.size()];
    		boolean bIsChangeProxyObject = true;
    		for(int index=0; index<listRelIDs.size();index++){
    			String strObjectId = (String)listObjIDs.get(index);
    			DomainObject domObj = new DomainObject(strObjectId);
    			if(!domObj.isKindOf(context,ChangeConstants.TYPE_CHANGE_PROXY)){
    				bIsChangeProxyObject = false;
    				break;
    			}
    				
    			relIdArray[index] = (String)listRelIDs.get(index);
    		}
    		 if(!bIsChangeProxyObject)
    		 {
    		 %>
             <script language="javascript">          
                 alert("<%=XSSUtil.encodeForJavaScript(context,strValidProxyChangeMsg) %>");
                 </script>
             <%
             }
             else{
            	 
            	 DomainObject domObj = new DomainObject(objectId);
      			if(domObj.isKindOf(context,ChangeConstants.TYPE_CHANGE_ORDER)){
     	        	 mChangeOrder.setId(objectId);
             	 mChangeOrder.removeChangeActions(context, relIdArray);
      			}else if(domObj.isKindOf(context,ChangeConstants.TYPE_CHANGE_REQUEST)){
      				mChangeRequest.setId(objectId);
      				mChangeRequest.removeChangeActions(context, relIdArray);
     			}
             }
	      }
    	else if ("disconnectChangeAction".equalsIgnoreCase(functionality) &&  listRelIDs != null) {
    		String[] relIdArray = new String[listRelIDs.size()];
    		for(int index=0; index<listRelIDs.size();index++){
    			relIdArray[index] = (String)listRelIDs.get(index);
    		}
    		mChangeOrder.setId(objectId);
    		//Calling modeler API ro disconnect Change Order and Change Action
    		mChangeOrder.removeChangeActions(context, relIdArray);
	      }
         
         if(isRemoveDone) {
				xmlResponse.append("<mxRoot>").append("<action>remove</action>");
				xmlResponse.append(changeUtil.getItemXMLFromList(listRowIDs));
				xmlResponse.append("</mxRoot>");
         }
         ContextUtil.commitTransaction(context);
     } 
    catch(Exception e) 
	{
    	e.printStackTrace();
    	ContextUtil.abortTransaction(context);
        bIsError=true;
        errorMessage = e.getMessage();
        session.putValue("error.message",errorMessage);
	}
%> 

<script language="javascript" type="text/javaScript">
<!-- XSSOK -->
var bError = "<%=bIsError%>";
//XSSOK
var functionality = "<%=XSSUtil.encodeForJavaScript(context, functionality)%>";
//XSSOK
var isRemoveDone  = "<%=isRemoveDone%>";

if (bError=="true") {
	alert("Exception Occurred: "+errorMessage);
 }
else if(("MoveToNewCO" == functionality || "disconnectAffectedItem" == functionality || 
		 "MoveToExistingCO" == functionality || "MoveToNewCR" == functionality || "MoveToExistingCR" == functionality || "removeExternalChangeAction" == functionality|| "disconnectChangeAction" == functionality) && bError == "false") {
	var addExistingCase    = functionality.indexOf("Existing") > -1 ? true : false;
//	var affectedItemFrame  = findFrame(addExistingCase ? getTopWindow().getWindowOpener().getTopWindow() :getTopWindow() ,"ECMCRCOAffectedItems");
//	var changeActionsFrame = findFrame(addExistingCase ? getTopWindow().getWindowOpener().getTopWindow() :getTopWindow(),"ECMCRCOAffectedChangeActions");
//	affectedItemFrame.location.href  = affectedItemFrame.location.href;
//	changeActionsFrame.location.href = changeActionsFrame.location.href;

	var windowToRefer = addExistingCase ? getTopWindow().getWindowOpener().getTopWindow() : getTopWindow();
	var varDetailsDisplay = findFrame(windowToRefer, "detailsDisplay");
	if (varDetailsDisplay) {
			varDetailsDisplay.location.href = varDetailsDisplay.location.href;
	}	
	
	if(addExistingCase) getTopWindow().closeWindow();

}
else if(isRemoveDone=="true" && getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().removedeletedRows) {
	//XSSOK
	//getTopWindow().getWindowOpener().removedeletedRows("<%=xmlResponse%>");
	//parent.location.href = parent.location.href;
	getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
	getTopWindow().closeWindow();
}
else if(isRemoveDone=="true" && parent.removedeletedRows) {	 
	//XSSOK
	//Added for removing XML Parsing error
	var response = "<%=xmlResponse%>";
	if(response != "")
	{
		parent.removedeletedRows("<%=xmlResponse%>");
	}
}
else if("disconnectAffectedItemFromChangeMgmt" ==functionality){
	// we have written refresh logic in above block itself
	//strategic change to make seperate JSP for each action 
}
else {	
	refreshTreeDetailsPage();  
}
</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
