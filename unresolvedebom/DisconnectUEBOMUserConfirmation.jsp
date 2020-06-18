<%--  DisconnectUEBOMUserConfirmation.jsp  - To disconnect part from the BOM with user confirmation.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@page import="com.matrixone.apps.engineering.EngineeringConstants"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<!-- 2011x - Starts -->
<%@ page import="com.matrixone.apps.domain.DomainConstants" %>
<%-- <%@ page import="com.matrixone.apps.unresolvedebom.UnresolvedEBOM" %> --%>
<%@ page import="com.matrixone.apps.unresolvedebom.UnresolvedEBOMConstants" %>
<%-- <jsp:useBean id="pueChange" class="com.matrixone.apps.unresolvedebom.PUEChange" scope="session"/>
<jsp:useBean id="unresolvedPart" class="com.matrixone.apps.unresolvedebom.UnresolvedPart" scope="session"/> --%>
<!-- 2011x - Ends  -->

<%
    String language  = request.getHeader("Accept-Language");
	String objectId  = emxGetParameter(request,"objectId");

    //2012--Starts
   // String isWipBomAllowed = FrameworkProperties.getProperty("emxUnresolvedEBOM.WIPBOM.Allowed");
   // String isWipBomAllowed = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOM.WIPBOM.Allowed");
   //	String isWipBomAllowed = UnresolvedEBOM.isWipBomAllowedForParts(context,objectId);
   	String isWipBomAllowed = "false";
    String isWipMode   = "false";
    String parentState = "";
    String sCurrent    = "";
    String calledMethod    = emxGetParameter(request,"calledMethod");
    //2012--Ends
    
    //2011x - Starts
    boolean allowRemove                          = true;
    boolean isIntersectEffectivityForRemove      = true; 
    boolean isCyclicDependent = false; 
    String blockRemoveMSGForPendingChange        = i18nStringNowUtil("emxUnresolvedEBOM.Edit.checkOnPendingChange","emxUnresolvedEBOMStringResource", language);
    String blockRemoveMSGForIntersectEffectivity = i18nStringNowUtil("emxUnresolvedEBOM.Edit.EffectivityMatch","emxUnresolvedEBOMStringResource", language);
    
    String alertMessage    = i18nStringNowUtil("emxUnresolvedEBOM.Alert.DoNotAllowUnUnresolvedWithinResolved","emxUnresolvedEBOMStringResource", language); 
    String STATESUPERSEDED = PropertyUtil.getSchemaProperty(context,"policy",UnresolvedEBOMConstants.POLICY_CONFIGURED_PART, "state_Superseded");
    String supersededPart  = i18nStringNowUtil("emxUnresolvedEBOM.Alert.SupersededPart","emxUnresolvedEBOMStringResource", language);   
    String RemoveonRemove  = i18nStringNowUtil("emxUnresolvedEBOM.BOM.RemoveonRemove","emxUnresolvedEBOMStringResource",language);
    String strCyclicDependency = i18nStringNowUtil("emxUnresolvedEBOM.CommonView.Alert.Cyclicdependency", "emxUnresolvedEBOMStringResource", language);
    
    String strRootNodeSelected     = i18nStringNowUtil("emxUnresolvedEBOM.Remove.RootNodeSelected","emxUnresolvedEBOMStringResource", language);
    String strContextECOSelection  = i18nStringNowUtil("emxUnresolvedEBOM.Select.WorkUnderChange","emxUnresolvedEBOMStringResource", language);

    String contextECO = emxGetParameter(request,"PUEUEBOMContextChangeFilter_actualValue");
    contextECO  = (contextECO == null || "null".equalsIgnoreCase(contextECO))?"":contextECO;
    
	String subsequentChildNodeRemoveConfirmation    = i18nStringNowUtil("emxUnresolvedEBOM.Remove.Common.MsgConfirm","emxUnresolvedEBOMStringResource", language);
	String pleaseSelectAlert = i18nStringNowUtil("emxUnresolvedEBOM.PUEECO.PleaseSelect","emxUnresolvedEBOMStringResource", language);
	String unAssignToPUEECONotAllowed = i18nStringNowUtil("emxUnresolvedEBOM.PUEECO.ErrorOnUnAssign","emxUnresolvedEBOMStringResource", language);
	com.matrixone.apps.domain.DomainObject doObject = com.matrixone.apps.domain.DomainObject.newInstance(context);
	
	String sParentPolicyClass   = "";
	String policyClassification = "policy.property[PolicyClassification].value";
	
	boolean blnAllow   = true;
	boolean blnCurrent = false;
	boolean contextECOSelection = true;

%>
<html>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript">
    var contentFrame   	= findFrame(parent,"listHidden");
    var dupemxUICore 	= contentFrame.parent.emxUICore;
    var mxRoot 			= contentFrame.parent.oXML.documentElement;
    var checkedRow 		= "";
    var status         	= null;
    var tablemode = "edit";
    var displayView = contentFrame.parent.displayView;
	if(contentFrame.parent.editableTable && contentFrame.parent.editableTable != null && contentFrame.parent.editableTable != undefined){
			tablemode = contentFrame.parent.editableTable.mode; 
	}
    //2012x--Starts
    //XSSOK
    var isWipBomAllowed   = "<%=isWipBomAllowed%>";
    //XSSOK
    var pleaseSelectAlert = "<%=pleaseSelectAlert%>";
    var selectedParts   = "";
    var warningMessage  = "";
    var rowsSelected    = "";
    //2012x--Ends
    
    //for displaying object names when operation fails -- start
    var validationFailed = false;
    var objectNames = "";
  //for displaying object names when operation fails -- end
    
    try{
    	if(dupemxUICore != undefined)
    	{
            checkedRow     = dupemxUICore.selectSingleNode(mxRoot, "/mxRoot/rows//r[@checked='checked']");
        	status         = checkedRow != null?checkedRow.getAttribute("status"):null;
       	}
        //2012x-Starts-prepares a string with selected obj ids information for ADD TO PUEECO Existing
        var calledMethod = "<xss:encodeForJavaScript><%=calledMethod%></xss:encodeForJavaScript>";
        
        if ((calledMethod == "unAssignPUEECO") && isWipBomAllowed.toLowerCase()=="true")
        {	
            var rowsSelected = dupemxUICore.selectNodes(mxRoot, "/mxRoot/rows//r[@checked='checked']");

            //warningMessage   = (rowsSelected == "") ? pleaseSelectAlert : "";

            if (rowsSelected.length == 0) {
            	warningMessage = pleaseSelectAlert;
            }
            
            if (rowsSelected.length != 0) {
                for(var i=0; i<rowsSelected.length; i++) {
                        var oid   = rowsSelected[i].getAttribute("o");
                        var id    = rowsSelected[i].getAttribute("id");
                        var p     = rowsSelected[i].getAttribute("p");
                        var relId = rowsSelected[i].getAttribute("r");
                        p         = (p == null || p == "null")?"":p;
                        relId     = (relId == null || relId == "null")?"":relId;

                        //var colInitialRelease = contentFrame.parent.emxEditableTable.getCellValueByRowId(id,"InitialRelease");
                        //var InitialRelease    = colInitialRelease.value.current.actual;
                        var columnState       = contentFrame.parent.emxEditableTable.getCellValueByRowId(id,"State");
                        var objState          = columnState.value.current.actual;
                        var columnName       = contentFrame.parent.emxEditableTable.getCellValueByRowId(id,"Name");
                        var objName          = columnName.value.current.actual;
                        //Incase of Un Assign if selected parts are not connected to any pueeco then raise the alert
                        //XSSOK   
                             if ((calledMethod == "unAssignPUEECO") && (objState != "<%=UnresolvedEBOMConstants.STATE_PART_PRELIMINARY%>")) {
                            	 validationFailed = true;
                                 objectNames = (objectNames == "") ? objName : (objectNames + "," + objName);
                            }
                             if (selectedParts.indexOf(oid) > -1) {
 								continue;
                             }
                      selectedParts += oid+"|"+relId+"|"+id+"~";                                  
                 }

                if (validationFailed) {
                	//XSSOK
                    warningMessage = "<%=unAssignToPUEECONotAllowed%>";
                    warningMessage += "\n" + objectNames; 
                }  
           } //2012x-Ends
      }   
  }
      
    catch(e){
        alert("Exception Occurred:"  +e.message);
	}
</script>
<body>
<form name="userConfirmationForm" method="post">
<input type=hidden name="selectedPartsList" value=""/>
<%
	String[] emxTableRowId = emxGetParameterValues(request,"emxTableRowId");
	String selectedRows = StringUtil.join(emxTableRowId, "~");
    boolean removeRootNodeError = false;
	if((!"unAssignPUEECO".equalsIgnoreCase(calledMethod) && emxTableRowId!=null && emxTableRowId.length>0))
	{
	    for(int i=0;i<emxTableRowId.length;i++)
	    {
	        String rowId = (String)emxTableRowId[i];
	        //375195 - Starts
			StringList slDataList 	= FrameworkUtil.splitString(rowId, "|");
	        Iterator itrList 		= slDataList.iterator();
	        String connectionId 	= (itrList.hasNext())?(String)itrList.next(): "";
	        String childObjId 		= (itrList.hasNext())?(String)itrList.next(): "";
            String parentObjId 		= (itrList.hasNext())?(String)itrList.next(): "";
            String selectedRowId    = (itrList.hasNext())?(String)itrList.next(): "";
            String releaseProcess   = "";
            if("0".equals(selectedRowId)) {
            	removeRootNodeError = true;
            }
            
            if (!"".equals(parentObjId) && !"".equals(childObjId)) {
                doObject.setId(childObjId);
                sCurrent = doObject.getInfo(context, DomainConstants.SELECT_CURRENT);
                doObject.setId(parentObjId);
                Map parentPartInfoMap = doObject.getInfo(context, StringList.create(DomainConstants.SELECT_CURRENT, policyClassification, EngineeringConstants.ATTRIBUTE_RELEASE_PHASE_VALUE));
                parentState = (String)parentPartInfoMap.get(DomainConstants.SELECT_CURRENT);
                if (STATESUPERSEDED.equalsIgnoreCase(sCurrent) || STATESUPERSEDED.equalsIgnoreCase(parentState)) {
                   blnCurrent = true;
                   break;
                }
				releaseProcess = (String)parentPartInfoMap.get(EngineeringConstants.ATTRIBUTE_RELEASE_PHASE_VALUE);
               sParentPolicyClass = (String)parentPartInfoMap.get(policyClassification);
               if (!"Unresolved".equalsIgnoreCase(sParentPolicyClass))
               {
                   blnAllow = false;
                   break;
               } else {
%>
                <input type="hidden" name="emxTableRowId" value="<xss:encodeForHTMLAttribute><%=rowId%></xss:encodeForHTMLAttribute>"/>
<%
               }
           }
            //if parent part state is preliminary and development mode setting is true then only wip mode will be true.
            if (/*"true".equalsIgnoreCase(isWipBomAllowed)*/ EngineeringConstants.DEVELOPMENT.equals(releaseProcess) && UnresolvedEBOMConstants.STATE_PART_PRELIMINARY.equalsIgnoreCase(parentState)) {
            	   isWipMode = "true";
            }
            //if context ECO is empty and parent state is release in case of wip mode then raise alert
            contextECOSelection =  ("".equalsIgnoreCase(contextECO) && "false".equalsIgnoreCase(isWipMode) && !("unAssignPUEECO".equalsIgnoreCase(calledMethod)))?false:true;

            if ("false".equalsIgnoreCase(isWipMode) && !"".equalsIgnoreCase(contextECO)) {
            	try {
            		if (contextECO != null && !"".equals(contextECO) && !"null".equals(contextECO))
            	     //isIntersectEffectivityForRemove = pueChange.isIntersectEffectivity(context,contextECO,connectionId);
            			isIntersectEffectivityForRemove = true;
            	     
            	     if (isIntersectEffectivityForRemove) {
            	    	// isCyclicDependent =  unresolvedPart.checkForCyclicPrerequisite(context, connectionId, contextECO);
            	    	 isCyclicDependent=false;
            	     }
            	     
            	     if (isCyclicDependent || !isIntersectEffectivityForRemove) {
						 break;
      	 			 }
            	}
            	catch (Exception e) {            		
            		isIntersectEffectivityForRemove = false;
            	}
            }            
	    }
	}
	if (blnAllow) {
		java.util.Enumeration eNumParameters = emxGetParameterNames(request); 
		while( eNumParameters.hasMoreElements()) {
		    String paramName = (String)eNumParameters.nextElement(); 
		    if("header".equals(paramName) ||"parsedHeader".equals(paramName)||"emxTableRowId".equals(paramName)) 
			{ 
				continue;     
			}
		    String paramValue = (String)emxGetParameter(request, paramName);
	%>
		<input type="hidden" name="<xss:encodeForHTMLAttribute><%=paramName%></xss:encodeForHTMLAttribute>" value="<xss:encodeForHTMLAttribute><%=paramValue%></xss:encodeForHTMLAttribute>"/>
	<% 	    
		} 
	}
%>
<!-- 375195 move js validation to the end -->
<script language="javascript">

<%
    if (removeRootNodeError) {
%>
	     //XSSOK
         alert("<%=strRootNodeSelected%>");
<%
}
    else if (!contextECOSelection) {
%>
		//XSSOK
         alert("<%=strContextECOSelection%>");
<%
}
    else if (blnCurrent) {
%>
		//XSSOK
         alert("<%=supersededPart%>");
<%
}   else if (blnAllow == false && allowRemove == true) {
%>
//XSSOK
         alert("<%=alertMessage%>");
<%
}   else if (!allowRemove) {
%>
//XSSOK
         alert("<%=blockRemoveMSGForPendingChange%>");
<%
}   else if (!isIntersectEffectivityForRemove){
%>	
		//XSSOK
         alert("<%=blockRemoveMSGForIntersectEffectivity%>");
<%        
} else if (isCyclicDependent) {
%>
//XSSOK
		 alert("<%= strCyclicDependency%>");
<%
}
    else {
%>
    if (status == 'cut' || status == 'add') {
    	//XSSOK
	     alert("<%=RemoveonRemove%>");
	} 
    else if (warningMessage != "") {
        alert(warningMessage);
    } 
    else {
    	 selectedParts = selectedParts != ""?selectedParts.substring(0,selectedParts.lastIndexOf('~')):"";
    	 document.userConfirmationForm.selectedPartsList.value=selectedParts;
		 var Confirmation = true;
		 var selectedRow = "<xss:encodeForJavaScript><%=selectedRows%></xss:encodeForJavaScript>";
		 var formatedSelectedRow = "";
 		if(tablemode != "edit") {
 			
 			var vSelectedObjectArray =  selectedRow.split("~");
 			var i;
 			for (i = 0; i < vSelectedObjectArray.length; i++) {
 			    var selectedObjArray = vSelectedObjectArray[i].split("|");
 			    if(selectedObjArray.length >3){
 			    	var selectedRowId = selectedObjArray[3];
 			    	var parentId = selectedObjArray[2];
 			    	var childId = selectedObjArray[1];
 			    	var relId = selectedObjArray[0];
 			    	var xSelectedPath1  = "/mxRoot/rows//r[@rowid = '" + selectedRowId + "']";
 			    	var selectedNode = dupemxUICore.selectNodes(mxRoot, xSelectedPath1);
 			    	if(selectedRowId != 0){
	 			    	if(relId == ""){
	 			    		relId            = checkedRow.getAttribute("r");
	 			    	}
	 			    	if(relId == ""){
	 			    		parentId            = checkedRow.getAttribute("p");
	 			    	}
 			    }
 			    	else {
 			    		relId = "rootNode";
 			    	}
 			    	if(formatedSelectedRow == ""){
 			    		formatedSelectedRow = relId+"|"+childId+"|"+parentId+"|"+selectedRowId;
 			    	}
 			    	else {
 			    		formatedSelectedRow = formatedSelectedRow + "~"+relId+"|"+childId+"|"+parentId+"|"+selectedRowId;
 			    	}
 			    }
 			}}
		 //XSSOK
		 var url = "DisconnectUEBOM.jsp?userConfirmation="+Confirmation+"&tablemode="+tablemode+"&selectedRow="+formatedSelectedRow+"&calledMethod="+calledMethod+"&isWipMode=<%=isWipMode%>";
		 document.userConfirmationForm.action=url;
		 document.userConfirmationForm.submit();
         }
<%
}
%>
</script>
</form>
</body>
</html>
    
       

   


       
       



