<%--  emxEngRMBIntermediate.jsp -  This is used as Intermediate jsp for all RMB.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@page import="com.dassault_systemes.enovia.enterprisechangemgt.common.ChangeConstants"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<%@include file = "emxDesignTopInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
    String strRMBTableID = emxGetParameter(request, "emxTableRowId");
    String strViewAndEditMode = emxGetParameter(request, "viewAndEditMode");
    String isFromRMB = emxGetParameter(request,"isFromRMB");
    String suiteKey = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "suiteKey"));
    String editmode = emxGetParameter(request,"mode");
    
    String objectId = emxGetParameter(request, "objectId");
    String relatedObjects = emxGetParameter(request, "PartRelatedObjectsView");
    String portalCmdName = emxGetParameter(request, "portalCmdName");
    
    String url = "";
    String strRMBID = null;
    String strTableRowId = "0";
    String strCommandName = "";
    String typeName = "";
    String partType ="";
    String selType="";
    String changeControlledValue="";
    
    DomainObject dmObj = DomainObject.newInstance(context,objectId);
    partType = dmObj.getInfo(context, DomainConstants.SELECT_TYPE);
    
    //added to handle edit mode in RMB 
    if(UIUtil.isNotNullAndNotEmpty(strRMBTableID) && strRMBTableID != "0"){
    StringList sList = FrameworkUtil.split(strRMBTableID, "|");    
    
    if (sList.size() == 3) {
        strRMBID = (String) sList.get(0);
        strTableRowId = (String) sList.get(2);
    } else if (sList.size() == 4) {
        strRMBID = (String) sList.get(1);
        strTableRowId = (String) sList.get(3);
    } else if (sList.size() == 2) {
        strRMBID = (String) sList.get(1);
    } else {
        strRMBID = strRMBTableID;
    }
    }

    if("true".equals(isFromRMB)){
    	if(UIUtil.isNullOrEmpty(strRMBID)){
    		objectId =objectId;
    	}else{
    		objectId = strRMBID;
    	}
    	
    	dmObj = DomainObject.newInstance(context,objectId);
    	selType = dmObj.getInfo(context, DomainConstants.SELECT_TYPE);   
        if(UIUtil.isNotNullAndNotEmpty(partType)) {
        	selType= MqlUtil.mqlCommand(context,"print type $1 select $2 dump $3",selType,"derived","|");
        }
      		//get change controlled value assigned to the part
      		Map programMap = new HashMap();
      		programMap.put("objectId",objectId);
      		changeControlledValue = JPO.invoke(context, "enoPartManagement", null, "getReviseChangeControlled", JPO.packArgs(programMap), String.class);
    }
    if("true".equals(relatedObjects) || "true".equals(isFromRMB))   
    {
    String strIsKindOf = dmObj.getInfo(context,"type.kindof");
    	    if(strIsKindOf.equals(DomainConstants.TYPE_PART)) 
    	    {
    	    	url = "../common/emxForm.jsp?form=type_PartSlidein&HelpMarker=emxhelppartproperties&toolbar=ENCRMBProperties&ECMChangeControlAppAccessJPO=enoUnifiedBOM&ECMChangeControlAppAccessMethod=showECMChangeControlCommands&suiteKey="+suiteKey;
    	    }
    	    else if(strIsKindOf.equals(DomainConstants.TYPE_DOCUMENT)||selType.equals(EngineeringConstants.DOCUMENTS))
    	    {
    	    	url = "../common/emxForm.jsp?form=type_Spec&HelpMarker=emxhelpspeceditdetails&toolbar=ENCRMBSpecProperties&ECMChangeControlAppAccessJPO=enoUnifiedBOM&ECMChangeControlAppAccessMethod=showECMChangeControlCommands&suiteKey="+suiteKey;
    	    }  
    	    else if(strIsKindOf.equals(ChangeConstants.TYPE_CHANGE_ORDER))
    	    {
    	    	url = "../common/emxForm.jsp?form=type_ChangeOrderSlidein&HelpMarker=false";
    	    }
    	    else if(strIsKindOf.equals(ChangeConstants.TYPE_CHANGE_REQUEST)) 
    	    {
    	    	url = "../common/emxForm.jsp?form=type_ChangeRequestSlidein&HelpMarker=false";
    	    } 
       	    else
       	    {
    	    	url = "../common/emxDynamicAttributes.jsp?HelpMarker=false";
    	    }
    	    
    	    //for edit mode URL
    	    if(strIsKindOf.equals(DomainConstants.TYPE_PART) && "edit".equals(editmode)) 
    	    {
    	    	url = "../common/emxForm.jsp?form=type_PartSlidein&Header=emxEngineeringCentral.Part.EditPart&HelpMarker=emxhelpparteditdetails&preProcessJavaScript=preProcessInEditPart&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&emxSuiteDirectory=engineeringcentral&preProcessJPO=emxPart:checkLicense&postProcessURL=../engineeringcentral/emxEngCommonRefresh.jsp&refreshStructure=true&submitAction=doNothing&viewAndEditMode=true&postProcessJPO=enoPartCollaboration:collaboratePartEdit&changeControlled="+changeControlledValue;
    	    }
    	    // remove spec toolbar on click of edit mode
    	    else if((strIsKindOf.equals(DomainConstants.TYPE_DOCUMENT)||selType.equals(EngineeringConstants.DOCUMENTS)) && "edit".equals(editmode))
    	    {
    	    	url = "../common/emxForm.jsp?form=type_Spec&HelpMarker=emxhelpspeceditdetails&suiteKey="+suiteKey;
    	    }  
    }
%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">   

			var skipExecutionOfUnwantedConditions = false;
			var isApplicationPart = false;
				//XSSOK
			if ("true" == "<%=XSSUtil.encodeForJavaScript(context, strViewAndEditMode)%>") {
				<%-- var actionURL = "../common/emxForm.jsp?form=type_PartSlidein&HelpMarker=emxhelppartproperties&toolbar=ENCRMBProperties&objectId=<%=XSSUtil.encodeForJavaScript(context, strRMBID)%>"; --%>
         var actionURL ="<%=url%>&mode=<xss:encodeForJavaScript><%=editmode%></xss:encodeForJavaScript>&objectId=<%=XSSUtil.encodeForJavaScript(context, objectId)%>";
			} 
				//XSSOK
			else if("<%=DomainConstants.TYPE_APPLICATION_PART%>" == "<%=partType%>")
				{
			 var actionURL = "../common/emxTree.jsp?objectId=<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>&suiteKey=<%=suiteKey%>";
				 getTopWindow().showModalDialog(actionURL, "600", "500");
				 isApplicationPart = true;
				} 
			else if("true" == "<%=XSSUtil.encodeForJavaScript(context, relatedObjects)%>"){
					 var skipExecutionOfUnwantedConditions = true;
					 var actionURL = "../common/emxTree.jsp?objectId=<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>&suiteKey=<%=suiteKey%>";
					 var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");
					 contentFrame.location.href = actionURL;
					
			}
			else if ("true" == "<%=XSSUtil.encodeForJavaScript(context, isFromRMB)%>"){
			if("ENCRelatedItem" == "<xss:encodeForJavaScript><%=portalCmdName%></xss:encodeForJavaScript>" || "ENCRelatedItem" == parent.name) {
						var actionURL = "<%=url%>&objectId=<%=XSSUtil.encodeForJavaScript(context, objectId)%>";
				}
				else if("edit"=="<xss:encodeForJavaScript><%=editmode%></xss:encodeForJavaScript>"){
					var actionURL = "<%=url%>&mode=<xss:encodeForJavaScript><%=editmode%></xss:encodeForJavaScript>&objectId=<%=XSSUtil.encodeForJavaScript(context, objectId)%>";
				}
				else {
				  	var actionURL = "../common/emxForm.jsp?form=type_PartSlidein&Header=emxEngineeringCentral.Part.EditPart&toolbar=ENCRMBProperties&ECMChangeControlAppAccessJPO=enoUnifiedBOM&ECMChangeControlAppAccessMethod=showECMChangeControlCommands&HelpMarker=emxhelpparteditdetails&preProcessJavaScript=preProcessInEditPart&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&emxSuiteDirectory=engineeringcentral&preProcessJPO=emxPart:checkLicense&postProcessURL=../engineeringcentral/emxEngCommonRefresh.jsp&refreshStructure=true&submitAction=doNothing&tableRowId=<%=XSSUtil.encodeForJavaScript(context,strTableRowId)%>&objectId=<%=XSSUtil.encodeForJavaScript(context,strRMBID)%>&commandName=" + parent.name;
				}
			}
			else {
				 var actionURL = "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForJavaScript(context, strRMBID)%>&suiteKey=<%=suiteKey%>";
				 var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");
				 var contentFrameMultiPartCreate;
				 if(contentFrame!=null)
				 contentFrameMultiPartCreate = contentFrame.location.href;
				  	 if(contentFrame !=null && contentFrameMultiPartCreate!="undefined" &&(contentFrameMultiPartCreate.indexOf("openShowModalDialog")>-1 ||contentFrameMultiPartCreate.indexOf("launched")>-1)) //This is to open a showModalDialog from popups in Part->RMB Open navigation
					 {
					 getTopWindow().showModalDialog(actionURL, "600", "500");
					}else if(contentFrame == null ) {
					 contentFrame = getTopWindow();
					 getTopWindow().showModalDialog(actionURL, "600", "500");
					 }else{									
					 contentFrame.location.href = actionURL;
					 }
			}

			if(skipExecutionOfUnwantedConditions == false){
			if (this.parent.parent.FullSearch) {
					getTopWindow().showModalDialog(actionURL, "600", "500");
			} else {
			if (("true" == "<%=XSSUtil.encodeForJavaScript(context, strViewAndEditMode)%>")||("true" == "<%=XSSUtil.encodeForJavaScript(context, isFromRMB)%>")) {
					getTopWindow().commandName = [];
					getTopWindow().commandName["refreshRowCommandName"] = parent.name;
			}
 
			 if (("true" == "<%=XSSUtil.encodeForJavaScript(context, isFromRMB)%>")&& !isApplicationPart)
			getTopWindow().showSlideInDialog(actionURL, true,"","",550);
			}
			}
		
</script>

