<%--  emxEngrMarkupActionProcess.jsp -  This page performs markup actions
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>


<%@page import="com.dassault_systemes.enovia.partmanagement.modeler.util.ECMUtil"%>
<%@page import="com.dassault_systemes.enovia.partmanagement.modeler.util.PartMgtUtil"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.dassault_systemes.enovia.enterprisechangemgt.common.ChangeConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@ page import="com.matrixone.apps.domain.util.ContextUtil"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
	
	//ContextUtil.pushContext(context);
	String[] emxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
	String[] objectid = emxGetParameterValues(request, "objectId");
	String mode   = emxGetParameter(request, "mode");
	String changeObjectId = objectid[0];
	String  currentState = "";
	String errorMessage = "";
	String POLICY_ECO = PropertyUtil.getSchemaProperty(context,"policy_ECO");
	String POLICY_ECR = PropertyUtil.getSchemaProperty(context,"policy_ECR");
	String createState =PropertyUtil.getSchemaProperty(context,"policy", POLICY_ECR, "state_Create");
	String submitState =PropertyUtil.getSchemaProperty(context,"policy", POLICY_ECR, "state_Submit");
	String evaluateState =PropertyUtil.getSchemaProperty(context,"policy", POLICY_ECR, "state_Evaluate");
	String reviewState =PropertyUtil.getSchemaProperty(context,"policy", POLICY_ECR, "state_Review");
	String defineState =PropertyUtil.getSchemaProperty(context,"policy", POLICY_ECO, "state_DefineComponents");
	String designState =PropertyUtil.getSchemaProperty(context,"policy", POLICY_ECO, "state_DesignWork");
	String strType=null;
	String TYPE_PART_SPECIFICATION=PropertyUtil.getSchemaProperty(context,"type_PartSpecification");
	String TYPE_PART=PropertyUtil.getSchemaProperty(context,"type_Part");
	String TYPE_DOCUMENTS=PropertyUtil.getSchemaProperty(context,"type_DOCUMENTS");
	String uiType = emxGetParameter(request, "uiType");
    	
	boolean isSelPart=false;
		
	for(int i=0;i<emxTableRowIds.length;i++) {
		String rowtemp=emxTableRowIds[i];
		StringList strmarkupId = FrameworkUtil.split(emxTableRowIds[i],"|");
		String strSelId = (String)strmarkupId.elementAt(1);

		DomainObject dosel=new DomainObject(strSelId);
		//open as user agent as non owners cannot
		ContextUtil.pushContext(context);
		String sselType=dosel.getInfo(context,DomainConstants.SELECT_TYPE);
		ContextUtil.popContext(context);
        boolean bpart=mxType.isOfParentType(context,sselType,DomainConstants.TYPE_PART);
		boolean bSpec=mxType.isOfParentType(context,sselType,TYPE_DOCUMENTS);

		if(bpart || bSpec) {
			isSelPart=true;
%>

			<Script language="JavaScript">
				alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.MarkupAlertonSelectionofDifferentAffectedItems</emxUtil:i18nScript>");
			</Script>
<%	
			break;	
		}
	}
	
	if(!isSelPart) {
		DomainObject dObj = new DomainObject(changeObjectId);
		currentState = dObj.getInfo(context,com.matrixone.apps.domain.DomainConstants.SELECT_CURRENT);
	 	strType= dObj.getInfo(context,com.matrixone.apps.domain.DomainConstants.SELECT_TYPE);
     	String strTypeName = dObj.getTypeName();
	 	String strObjectName = dObj.getName();
	 	
	 	String changeActionId ="";
        if(UIUtil.isNotNullAndNotEmpty(changeObjectId)){
      	  if(dObj.isKindOf(context, TYPE_PART)){
      		  changeActionId = PartMgtUtil.getWorkUnderChangeId(context, changeObjectId);
      	  }
      	  else if(ChangeConstants.TYPE_CHANGE_ACTION.equalsIgnoreCase(strType)){
      		  changeActionId = changeObjectId;
      	  }
        }
        
	 	context.setCustomData("fromMarkupActions", "TRUE");

		if(DomainConstants.TYPE_ECR.equalsIgnoreCase(strType)||DomainConstants.TYPE_ECO.equalsIgnoreCase(strType)) {
			if(((strTypeName.equals(DomainConstants.TYPE_ECR))&&(currentState.equals(createState)||currentState.equals(submitState)||currentState.equals(evaluateState)||currentState.equals(reviewState))) ||
				((strTypeName.equals(DomainConstants.TYPE_ECO))&&(currentState.equals(createState)||currentState.equals(defineState)||currentState.equals(designState)))) {
				//Change changeObject=new Change();
				StringList objectList = new StringList();
				StringList markupsl =new StringList();
				String partObjectId = "";
				String temp = "";
				int sRowIdsCount = emxTableRowIds.length;

		   		if (sRowIdsCount > 0) {
		   		    for(int count=0; count < sRowIdsCount; count++) {
						temp =  emxTableRowIds[count];
						objectList = FrameworkUtil.split(temp,"|");
						partObjectId = (String)objectList.elementAt(1) ;
						markupsl.addElement(partObjectId);
		   		    }
					String jpoName = "emxPartMarkup";
					String methodName = "";

					if(mode.equals("reject") || mode.equals("rejectFromPartContext")) {						
						methodName = "rejectMarkup";
						//changeObject.rejectMarkupObjects(context,jpoName,methodName,programMap);
						JPO.invoke(context,jpoName,null,methodName,JPO.packArgs(markupsl),void.class);
					} else if(mode.equals("approve") || mode.equals("approveFromPartContext")) {
						methodName = "approveMarkup";
						//changeObject.approveMarkupObjects(context,jpoName,methodName,programMap);
						JPO.invoke(context,jpoName,null,methodName,JPO.packArgs(markupsl),void.class);
					} else if(mode.equals("apply") || mode.equals("applyFromPartContext")) {
						try{
							ContextUtil.startTransaction(context, true);
							ECMUtil.setWorkUnderChange(context, changeActionId);
						HashMap programMap = new HashMap();
						programMap.put("markupIds", markupsl);
						programMap.put("changeId", changeObjectId);
						methodName = "applyMarkup";
						//changeObject.applyMarkupObjects(context,jpoName,methodName,programMap);
						JPO.invoke(context,jpoName,null,methodName,JPO.packArgs(programMap),void.class);
						ContextUtil.commitTransaction(context);
						}catch(Exception e){
							errorMessage = e.getMessage();
							ContextUtil.abortTransaction(context);
						}finally{
							ECMUtil.clearWorkUnderChange(context);
						}
					} else if(mode.equals("delete") || mode.equals("deleteFromPartContext")) {
						methodName = "deleteMarkup";
						//changeObject.applyMarkupObjects(context,jpoName,methodName,programMap);
						JPO.invoke(context,jpoName,null,methodName,JPO.packArgs(markupsl),void.class);
					}
				}
			} else {
%>

				<script>
				//XSSOK
				var smode="<%=XSSUtil.encodeForJavaScript(context,mode)%>";
				//Markups can not be Applied for Affected Items in this state
				
				if("delete"==smode || "deleteFromPartContext" == smode ) {
					//XSSOK
					alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.ChangeProcessunauthorisedstatefordelete</emxUtil:i18nScript>"+'<%=strObjectName%>');
				}
	
				if("reject"==smode || "rejectFromPartContext"==smode) {
					//XSSOK
					alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.ChangeProcessunauthorisedstateforreject</emxUtil:i18nScript>"+'<%=strObjectName%>');
				}		
	
				if("apply"==smode || "applyFromPartContext"==smode) {
					//XSSOK
					alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.ChangeProcessunauthorisedstateforapply</emxUtil:i18nScript>"+'<%=strObjectName%>');
				}
	
				if("approve"==smode || "approveFromPartContext"==smode) {
					//XSSOK
					alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.ChangeProcessunauthorisedstateforapprove</emxUtil:i18nScript>"+'<%=strObjectName%>');
				}
<%
			}

		} else {

			StringList objectList = new StringList();
			StringList markupsl =new StringList();
			String partObjectId = "";
			String temp = "";
			int sRowIdsCount = emxTableRowIds.length;

			if (sRowIdsCount > 0) {
			    for(int count=0; count < sRowIdsCount; count++) {
					temp =  emxTableRowIds[count];
					objectList = FrameworkUtil.split(temp,"|");
					partObjectId = (String)objectList.elementAt(1) ;
					markupsl.addElement(partObjectId);
			    }
				String jpoName = "emxPartMarkup";
				String methodName = "";

				if(mode.equals("reject") || mode.equals("rejectFromPartContext")) {
					methodName = "rejectMarkup";
					//changeObject.rejectMarkupObjects(context,jpoName,methodName,programMap);
					JPO.invoke(context,jpoName,null,methodName,JPO.packArgs(markupsl),void.class);
				} else if(mode.equals("approve") || mode.equals("approveFromPartContext")) {
					methodName = "approveMarkup";
					//changeObject.approveMarkupObjects(context,jpoName,methodName,programMap);
					JPO.invoke(context,jpoName,null,methodName,JPO.packArgs(markupsl),void.class);
				} else if(mode.equals("apply") || mode.equals("applyFromPartContext")) {
					try{
						ContextUtil.startTransaction(context, true);
						ECMUtil.setWorkUnderChange(context, changeActionId);
					HashMap programMap = new HashMap();
					programMap.put("markupIds", markupsl);
					programMap.put("changeId", changeObjectId);
					methodName = "applyMarkup";
					//changeObject.applyMarkupObjects(context,jpoName,methodName,programMap);
					JPO.invoke(context,jpoName,null,methodName,JPO.packArgs(programMap),void.class);
					ContextUtil.commitTransaction(context);
					}catch(Exception e){
						errorMessage = e.getMessage();
						ContextUtil.abortTransaction(context);
					}finally{
						ECMUtil.clearWorkUnderChange(context);
					}
				} else if(mode.equals("delete")|| mode.equals("deleteFromPartContext")) {
					methodName = "deleteMarkup";
					//changeObject.applyMarkupObjects(context,jpoName,methodName,programMap);
					JPO.invoke(context,jpoName,null,methodName,JPO.packArgs(markupsl),void.class);
				}

			}
		}
		context.removeFromCustomData("fromMarkupActions");
%>
</Script>

<%@include file = "emxEngrVisiblePageInclude.inc"%>

<Script language="JavaScript">
	//Modified for IR-146926 start
	//XSSOK
	var errorMessage = "<%= errorMessage%>";
	if(errorMessage != ""){
        alert(errorMessage);
    }
	if ("table" == "<%= XSSUtil.encodeForJavaScript(context,uiType)%>") {	
		parent.closeWindow();
		parent.window.location = parent.window.location;		
		if ("rejectFromPartContext" == "<%=XSSUtil.encodeForJavaScript(context,mode)%>" || "approveFromPartContext" == "<%=XSSUtil.encodeForJavaScript(context,mode)%>") {
			parent.window.getWindowOpener().location = parent.window.getWindowOpener().location;
		}
	} else if ("rejectFromPartContext" == "<%=XSSUtil.encodeForJavaScript(context,mode)%>" 
			|| "approveFromPartContext" == "<%=XSSUtil.encodeForJavaScript(context,mode)%>") {
		//contentWindow.document.location.href = contentWindow.document.location.href;		
            	parent.getTopWindow().getWindowOpener().emxEditableTable.refreshStructureWithOutSort();
            	getTopWindow().closeWindow();                                        
		} 
	else if("deleteFromPartContext" == "<%=XSSUtil.encodeForJavaScript(context,mode)%>" 
			|| "applyFromPartContext" == "<%=XSSUtil.encodeForJavaScript(context,mode)%>")
		{
			parent.window.location = parent.window.location;
		}
	else {
		var frameObject = findFrame(getTopWindow(), "listHidden").parent;	
		//XSSOK
		if ("delete" == "<%=XSSUtil.encodeForJavaScript(context,mode)%>" || frameObject == null || frameObject == "undefined" || "table" == "<%= XSSUtil.encodeForJavaScript(context,uiType)%>") {
			getTopWindow().refreshTablePage();	
		} else {
		    frameObject.emxEditableTable.refreshStructureWithOutSort();  // Added for refreshing table only
		}
	}
	//Modified for IR-146926 end
</Script>

<%
		//ContextUtil.popContext(context);	

	}

%>
