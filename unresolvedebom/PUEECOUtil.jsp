<%--  PUEECOUtil.jsp   - The Processing page for ECR connections.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "../engineeringcentral/emxDesignTopInclude.inc"%>
<%@include file = "../engineeringcentral/emxEngrVisiblePageInclude.inc"%>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "../engineeringcentral/emxEngrStartUpdateTransaction.inc"%>
<%@include file = "../engineeringcentral/emxEngrCommitTransaction.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<!-- Added for IR-0668852011x -->

<%-- <jsp:useBean id="pueChange" class="com.matrixone.apps.unresolvedebom.PUEChange" scope="session" /> --%>

<%			
			String strMode       = emxGetParameter(request, "mode");

            String strActualMode = emxGetParameter(request, "actualMode");

			String sReason = emxGetParameter(request, "reason");
			
			String exceptionOccured = "false";
			String exceptionMessage = "";
			Locale Local = context.getLocale();

			String objectId = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "objectId"));
			String alertCancelMsg = i18nStringNowUtil("emxUnresolvedEBOM.CancelPUEECODialog.CancelPUEECOConfirm","emxUnresolvedEBOMStringResource",request.getHeader("Accept-Language"));		
			com.matrixone.apps.domain.DomainObject changeObj = null;
			com.matrixone.apps.domain.DomainObject toObj = null;
			String languageStr = request.getHeader("Accept-Language");
			String[] strTableRowIds;
		    if (strMode.equalsIgnoreCase("AddExisting")) {
                strTableRowIds = emxGetParameterValues(request,"emxTableRowId");
                String relType = emxGetParameter(request, "srcDestRelName");
                String strObjectID = "";
                if (strTableRowIds[0].indexOf("|") > 0) {
                    StringTokenizer strTokenizer = new StringTokenizer(strTableRowIds[0], "|");
                    String temp = strTokenizer.nextToken();
                    strObjectID = strTokenizer.nextToken();
                } 
                else 
                    strObjectID = objectId;
	            
                StringList selectables = new StringList(1);
                //372065 Starts
                String applicableItem  =PropertyUtil.getSchemaProperty(context,"relationship_ApplicableItem");
                selectables.add("relationship["+applicableItem+"].to.id");
                //372065 Ends
                selectables.add(com.matrixone.apps.domain.DomainConstants.SELECT_CURRENT);
                selectables.add(com.matrixone.apps.domain.DomainConstants.SELECT_POLICY);
                changeObj = com.matrixone.apps.domain.DomainObject.newInstance(context);
	   			changeObj.setId(strObjectID);
	   			java.util.Map ecoMap = changeObj.getInfo(context,selectables);
	   			String ecoState = (String)ecoMap.get(com.matrixone.apps.domain.DomainConstants.SELECT_CURRENT);
	   			String ecoPolicy = (String)ecoMap.get(com.matrixone.apps.domain.DomainConstants.SELECT_POLICY);
	   			//372065 Starts
	   			//commented below for the IR -068146V6R2011x
	   			//String ecoProductId = (String)ecoMap.get("relationship[Applicable Item].to.id");
	   			//372065 Ends
	   			if(ecoState.equals(com.matrixone.apps.unresolvedebom.UnresolvedEBOMConstants.STATE_PUE_ECO_RELEASE) ||ecoState.equals(com.matrixone.apps.unresolvedebom.UnresolvedEBOMConstants.STATE_PUE_ECO_CANCELLED) ||
	   			        ecoState.equals(com.matrixone.apps.unresolvedebom.UnresolvedEBOMConstants.STATE_PUE_ECO_IMPLEMENTED))
	   			{
	   			 	//String errMsg = i18nNow.getI18nString("emxUnresolvedEBOM.Alert.RemovePrerequiste", "emxUnresolvedEBOMStringResource", languageStr);
	   			 	String errMsg = EnoviaResourceBundle.getProperty(context, "emxUnresolvedEBOMStringResource", Local, "emxUnresolvedEBOM.Alert.RemovePrerequiste");
%>
					<script language="Javascript" type="text/javaScript">
					//XSSOK
						var errMsg = '<%=errMsg%>';
						alert(errMsg);
						getTopWindow().closeWindow();
					</script>
<%
	   			}
	   			else
	   			{    
	   			    //modified getTopWindow().location.href for the Bug 360269
%>
				<script language="javascript" src="../common/scripts/emxUICore.js"></script>
					<script language="Javascript" type="text/javaScript">
	   			    //372065 Starts ECOBASED_ON selectable added
	   			    //Starts-IR-068146V6R2011x
					
					//Modified for IR-181084V6R2013x by M24 start
					//XSSOK
					//getTopWindow().location.href = "../common/emxFullSearch.jsp?field=TYPES=type_PUEECO:CURRENT=policy_PUEECO.state_Create,policy_PUEECO.state_DefineComponents,policy_PUEECO.state_DesignWork,policy_PUEECO.state_Review&table=PUEPrerequisitesSearchResults&showInitialResults=false&hideHeader=true&selection=multiple&submitAction=refreshCaller&mode=Connect&objectId=<%=strObjectID%>&excludeOIDprogram=emxPUEECO:excludePrerequisitePUEECO&submitURL=../unresolvedebom/PUEECOUtil.jsp&mode=connect&srcDestRelName=relationship_Prerequisite";
					//XSSOK
					var url = "../common/emxFullSearch.jsp?field=TYPES=type_PUEECO:CURRENT=policy_PUEECO.state_Create,policy_PUEECO.state_DefineComponents,policy_PUEECO.state_DesignWork,policy_PUEECO.state_Review&table=PUEPrerequisitesSearchResults&showInitialResults=false&hideHeader=true&selection=multiple&submitAction=refreshCaller&mode=Connect&objectId=<%=strObjectID%>&excludeOIDprogram=emxPUEECO:excludePrerequisitePUEECO&submitURL=../unresolvedebom/PUEECOUtil.jsp&mode=connect&srcDestRelName=relationship_Prerequisite";
					var contentFrame   = findFrame(getTopWindow(),"detailsDisplay");					
					contentFrame.showModalDialog(url, 575, 575);					
					//Modified for IR-181084V6R2013x by M24 end
					//Ends-IR-068146V6R2011x					
	   			    //372065 Ends
					</script>
<%
					//End of modification for the Bug 360269
	   			}
   			} 
   			else if ( strMode.equalsIgnoreCase("Connect") ) 
   			{
	            changeObj = DomainObject.newInstance(context);
	            toObj = DomainObject.newInstance(context);
	            strTableRowIds = emxGetParameterValues(request,"emxTableRowId");
				String relType = emxGetParameter(request, "srcDestRelName");
				String strAttributeName =  PropertyUtil.getSchemaProperty(context, "attribute_UserDefined");
                if (strTableRowIds != null) {
                    changeObj.setId(objectId);
                    relType = PropertyUtil.getSchemaProperty(context, relType);
                    String selectedId = "";
                    for (int i = 0; i < strTableRowIds.length; i++) {
                        selectedId = strTableRowIds[i];
                        //if this is coming from the Full Text Search, have to parse out |objectId|relId|
                        StringTokenizer strTokens = new StringTokenizer(
                                strTableRowIds[i], "|");
                        if (strTokens.hasMoreTokens()) {
                            selectedId = strTokens.nextToken();
                        }
                        toObj.setId(selectedId);
                            DomainRelationship relObj = DomainRelationship.connect(context, changeObj, relType, toObj );
							relObj.setAttributeValue( context,strAttributeName,"Yes" ) ;
                        }
                    }
                
            %>
<%@include file = "../engineeringcentral/emxEngrCommitTransaction.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">
  //refresh the calling structure browser and close the search window
  getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
  getTopWindow().closeWindow();
</script>

<%}
else if(strMode.equalsIgnoreCase("Disconnect")){
    strTableRowIds = emxGetParameterValues(request,"emxTableRowId");
    String relType = emxGetParameter(request, "srcDestRelName");
    String  strAttrName = "";
    String[] strArrRelIds = null ;
	String strFlag = "" ;
	String isRoot = "false";
	String rootSelectedAlert = "";
	String systemPrerequisiteAlert = "";
    if (strTableRowIds != null) {

        relType = PropertyUtil.getSchemaProperty(context, relType);
        strAttrName = PropertyUtil.getSchemaProperty(context, "attribute_UserDefined");
        String selectedId = " ";
        String strAttribute = "";
        int intLength = strTableRowIds.length ;
        strArrRelIds = new String[intLength];
        for (int i = 0,j=0; i < intLength ; i++) {
            if (strTableRowIds[i].indexOf("|") > 0) {
                
                StringTokenizer strTokenizer = new StringTokenizer(strTableRowIds[i], "|");
                String strRelId = strTokenizer.nextToken() ;
                selectedId = strTokenizer.nextToken() ;
                strAttribute = DomainRelationship.getAttributeValue( context, strRelId , strAttrName ) ;
                
                if( strAttribute.equalsIgnoreCase( "Yes" ) )
                {
                    strArrRelIds[j++] = strRelId ;
                }
                else if( strAttribute.equalsIgnoreCase("No") )
                {
                    strFlag = "failed";
                }
            } else if(strTableRowIds[i].indexOf("|") == 0) {
                isRoot = "true";
                break;
            }
        }
        if( !strFlag.equalsIgnoreCase("failed") && isRoot.equals("false"))
        {
            DomainRelationship.disconnect( context , strArrRelIds ) ;
        } else {
            rootSelectedAlert = i18nStringNowUtil("emxUnresolvedEBOM.PUEECO.RootPUEECOSelected","emxUnresolvedEBOMStringResource",request.getHeader("Accept-Language"));
            systemPrerequisiteAlert = i18nStringNowUtil("emxUnresolvedEBOM.PUEECO.SystemPrerequisiteExists","emxUnresolvedEBOMStringResource",request.getHeader("Accept-Language"));
        }
        
    }
                
            %>
	<script language="Javascript">
	//XSSOK
		if("<%=isRoot%>" == "true") {
			//XSSOK
			alert("<%=rootSelectedAlert%>");
			//XSSOK
		} else if("<%=strFlag%>" == "failed" ) {
			//XSSOK
			alert("<%=systemPrerequisiteAlert%>");
		} else 
			refreshTreeDetailsPage();
	</script>
<%
}
else if(strMode.equalsIgnoreCase("delete") || ("cancel".equalsIgnoreCase(strActualMode) || strMode.equalsIgnoreCase("cancel")))
{
	StringBuffer strbufErrorMsg = new StringBuffer ();
        StringBuffer strbufErrorMsg1 = new StringBuffer ();
        boolean accessFlag = false;
        boolean delAccessFlag = false;
		//Start: Bug 358592, 358594
        int count = 0;
        StringBuffer strPreReq = new StringBuffer (" ");
        String typePUEECO = PropertyUtil.getSchemaProperty(context,"type_PUEECO");
		//End: Bug 358592, 358594
        StringBuffer strbufAlert = new StringBuffer (" ");
        StringBuffer strbufAlert1 = new StringBuffer (" ");
        StringBuffer strbufAlert2 = new StringBuffer (" ");
        String strRelName = PropertyUtil.getSchemaProperty(context,"relationship_Prerequisite");
        String[] selPUEECOIds = {};
        selPUEECOIds = emxGetParameterValues(request, "emxTableRowId");
        if(selPUEECOIds == null || selPUEECOIds.length == 0) {
            selPUEECOIds = new String[1];
            selPUEECOIds[0] = objectId;
        }
        int iRowSize = selPUEECOIds.length;
        String [] arrObjIdList = new String[iRowSize] ;
        String [] delObjIds = null ;
        StringBuffer sbObjectid = null;
        for(int i = 0; i < iRowSize; i++)
        {
            sbObjectid = new StringBuffer(selPUEECOIds[i]);
            int iCount = sbObjectid.length();
            int iPosition = selPUEECOIds[i].indexOf("|");
            iCount = selPUEECOIds[i].indexOf("|", iPosition+1);
            if(iPosition == -1)
            {
                arrObjIdList[i] = selPUEECOIds[i];
            } else
            {
                arrObjIdList[i] = selPUEECOIds[i].substring(iPosition + 1, iCount);
            }
        }
        StringList objectSelects = new StringList(3);
        objectSelects.addElement(DomainObject.SELECT_ID);
        objectSelects.addElement("current.access[delete]");
        objectSelects.addElement("to["+strRelName+"].id");
        MapList deleteAccessList = DomainObject.getInfo(context, arrObjIdList, objectSelects);
        Iterator deleteAccessItr = deleteAccessList.iterator();
        com.matrixone.apps.domain.DomainObject dom = new com.matrixone.apps.domain.DomainObject();
        Vector finalObjects = new Vector();
        while(deleteAccessItr.hasNext()) {
            Map accessMap = (Map)deleteAccessItr.next();
            String deleteAccess = (String)accessMap.get("current.access[delete]");
            String domObjectId = (String)accessMap.get(DomainObject.SELECT_ID);
            String strlPrerequisiteIds = (String)accessMap.get("to["+strRelName+"].id");
              if("true".equalsIgnoreCase(deleteAccess) || "cancel".equalsIgnoreCase(strActualMode))
            {
                if(strlPrerequisiteIds == null )    
                {
                    finalObjects.add( domObjectId ) ;
                }
                else
                {
                    accessFlag = true;
                    dom.setId(domObjectId);
                    dom.open(context);
					//Start: Bug 358592, 358594
                    matrix.util.StringList slPreReqList= dom.getInfoList(context, "to["+strRelName+"].from.name");                 
                    if(count>0) {
                        strPreReq.replace(0,strPreReq.length(),"");
                    }
                    for(int stringItr = 0;stringItr < slPreReqList.size();stringItr++) {
                       
                        //strPreReq.append(typePUEECO+" ");
                        strPreReq.append(slPreReqList.get(stringItr));
                        //strPreReq.append("-"+" ");
                        strPreReq.append(",");
                    }                           
                    strbufErrorMsg1.append(strPreReq);
                    count++;
                    String errorMessage = dom.getInfo(context , DomainConstants.SELECT_NAME);
                    strbufErrorMsg.append( errorMessage );
                    strbufErrorMsg.append(",");
					//End: Bug 358592, 358594
                    dom.close(context); 
                }
            }
            else 
            {
                delAccessFlag = true ;
                dom.setId(domObjectId);
                dom.open(context);
                String errorMessage1 = dom.getInfo(context , DomainConstants.SELECT_NAME);
                strbufErrorMsg1.append( errorMessage1 );
                dom.close(context);
            }
        }
        
        
        if (accessFlag == true) {			
        	//String strPrereqCancelAlert = i18nNow.getI18nString("emxUnresolvedEBOM.PUEECO.Prerequisites.Cancel", "emxUnresolvedEBOMStringResource", context.getSession().getLanguage());
           // String strPrereqDelAlert = i18nNow.getI18nString("emxUnresolvedEBOM.PUEECO.Prerequisites.Delete", "emxUnresolvedEBOMStringResource", context.getSession().getLanguage());
           
           String strPrereqCancelAlert = EnoviaResourceBundle.getProperty(context, "emxUnresolvedEBOMStringResource", Local,"emxUnresolvedEBOM.PUEECO.Prerequisites.Cancel");
            String strPrereqDelAlert = EnoviaResourceBundle.getProperty(context, "emxUnresolvedEBOMStringResource", Local,"emxUnresolvedEBOM.PUEECO.Prerequisites.Delete");
        	
        	String strECOName = strbufErrorMsg1.toString();
        	String strContextECOName = strbufErrorMsg.substring(0, strbufErrorMsg.length()-1);
        	
        	strbufAlert.append(strContextECOName);
        	strbufAlert2.append(strContextECOName);
        	strbufAlert.append(" ").append(strPrereqCancelAlert);        	
            strbufAlert2.append(" ").append(strPrereqDelAlert);
            strbufAlert.append(" ").append(strbufErrorMsg1.substring(0, strbufErrorMsg1.length()-1));       	
            strbufAlert2.append(" ").append(strbufErrorMsg1.substring(0, strbufErrorMsg1.length()-1));                      
        }
        
        if( delAccessFlag == true )
        {
            //String strDeleteAlert = i18nNow.getI18nString("emxUnresolvedEBOM.PUEECO.NoDeleteAccess","emxUnresolvedEBOMStringResource",context.getSession().getLanguage());
            String strDeleteAlert = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource",Local,"emxUnresolvedEBOM.PUEECO.NoDeleteAccess");
            strbufAlert1 = strbufErrorMsg1.insert(0, strDeleteAlert ) ;
        }
        try{
            
            delObjIds = (String[])finalObjects.toArray(new String[finalObjects.size()]);
            if( delObjIds.length > 0 )
            {
                ContextUtil.startTransaction(context, true);
                if("cancel".equalsIgnoreCase(strActualMode) || strMode.equalsIgnoreCase("cancel")) {
                    //IR-026348 - zvb - Starts
                    //com.matrixone.apps.unresolvedebom.PUEChange.cancelPUEECO(context, delObjIds);
                   // pueChange.cancelPUEECO(context, delObjIds, sReason);//modified for IR-0668852011x
                    //IR-026348 - zvb - Ends
                } else {
	                // Disconnect Unresolved EBOM relationships and delete PUE ECO.
	              //  pueChange.deletePUEECOs(context, delObjIds) ;//modified for IR-0668852011x
                }
                ContextUtil.commitTransaction(context);
            }
            
        }
        catch(Exception e) {
        	exceptionOccured = "true";
        	exceptionMessage = e.getMessage();
            ContextUtil.abortTransaction(context);
        }
        
        if(strMode.equalsIgnoreCase("delete")) {
	%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">
//XSSOK
	if ("<%= exceptionOccured%>" == "true") {
		//XSSOK
	    alert ("<%= exceptionMessage%>");
	}
//XSSOK
	if(<%=accessFlag%> || <%=delAccessFlag%> ) {
		
		alert("<xss:encodeForJavaScript><%=strbufAlert2%></xss:encodeForJavaScript>"+"<xss:encodeForJavaScript><%=strbufAlert1%></xss:encodeForJavaScript>");
	}
	getTopWindow().location.href = getTopWindow().location.href;

</script>
<%	
        } else {
%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">
//XSSOK
	if ("<%= exceptionOccured%>" == "true") {
		//XSSOK
	    alert ("<%= exceptionMessage%>");
	} 
	//XSSOK
	if(<%=accessFlag%> || <%=delAccessFlag%> ) {
		alert("<xss:encodeForJavaScript><%=strbufAlert%></xss:encodeForJavaScript>"+"<xss:encodeForJavaScript><%=strbufAlert1%></xss:encodeForJavaScript>");
	}
<%
    //Start: IR-0665182011x
    if("cancel".equalsIgnoreCase(strActualMode) || strMode.equalsIgnoreCase("cancel"))  {
%>    
     // var parentDetailsFrame = findFrame(getTopWindow(), "detailsDisplay");--Commented for Next Gen
     var parentDetailsFrame = findFrame(getTopWindow(), "detailsDisplay");
     parentDetailsFrame.document.location.href=parentDetailsFrame.document.location.href;
     getTopWindow().closeSlideInDialog();//--Next Gen Ends
<%    
    }
     else { 
%>
	getTopWindow().getWindowOpener().reload();
<%} //End: IR-0665182011x %>
	closeWindow();
</script>
<%            
        }
} else if ("RemovePUEECOAffectedItems".equalsIgnoreCase(strMode)) {
	strTableRowIds = emxGetParameterValues(request,"emxTableRowId");
	
	Map objRelIdMap = new HashMap(strTableRowIds.length);
	StringList objectIdList = new StringList(strTableRowIds.length);
	StringList relIdList = new StringList(strTableRowIds.length);
	
	for (int i = 0; i < strTableRowIds.length; i++) {
		StringList resultList = FrameworkUtil.split(strTableRowIds[i], "|");
		relIdList.addElement(resultList.get(0));
		objectIdList.addElement(resultList.get(1));
	}
	
	//StringList autoAddedAffectedItemList = pueChange.validateAndRemoveAffectedItems(context, objectIdList, relIdList, objectId);	
	StringList autoAddedAffectedItemList = new StringList();
	if (autoAddedAffectedItemList.size() > 0) {
		String autoAddedAINames = FrameworkUtil.join(autoAddedAffectedItemList, ",");
		String alertMsg = EnoviaResourceBundle.getProperty(context, "emxUnresolvedEBOMStringResource", Local, "emxUnresolvedEBOM.Alert.RemoveAffectedItems");
		alertMsg = alertMsg.replace("$1", autoAddedAINames);
		
%>	
		<script language="Javascript">
		//XSSOK
			alert ("<%= alertMsg%>");
		</script>
<%
	} else {
		String rowIds = FrameworkUtil.join(strTableRowIds, "@");
%>
		<%@include file = "../common/emxTreeUtilInclude.inc"%>
		
		<script language="Javascript">
		//XSSOK
			var rowsToRemove = "<%= rowIds%>";
			var rowsToRemoveArr = rowsToRemove.split("@");
			parent.emxEditableTable.removeRowsSelected(rowsToRemoveArr);
		</script>
<%		
	}
}

%>
