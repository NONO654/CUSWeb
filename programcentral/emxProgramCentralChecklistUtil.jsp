<%--  emxProgramCentralChecklistUtil.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.
  VM3:2011x PRG 8-05-2010

  static const char RCSID[] = $Id: emxProgramCentralAssigneeSummaryFS.jsp.rca 1.17 Wed Oct 22 15:49:13 2008 przemek Experimental przemek $
--%>

<%@ page import = "com.matrixone.apps.domain.*" %>
<%@ page import="matrix.util.StringList" %>
<%@ page import="com.matrixone.apps.domain.util.FrameworkUtil" %>
<%@ page import = "com.matrixone.apps.domain.util.MapList"%>
<%@ page import = "matrix.db.*"%>
<%@ page import = "java.util.*"%>
<%@ page import = "java.util.List"%>
<%@ page import = "com.matrixone.apps.domain.util.PropertyUtil"%>
<%@ page import = "com.matrixone.apps.domain.util.i18nNow" %>
<%@ page import = "com.matrixone.apps.domain.util.MqlUtil" %>
<%@ page import="com.matrixone.apps.program.ProgramCentralConstants"%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>

<%@page import="com.matrixone.apps.program.ProjectSpace"%>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@page import="com.matrixone.apps.domain.util.eMatrixDateFormat"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<SCRIPT language="javascript" src="../common/scripts/emxUIConstants.js"></SCRIPT>

<%

    final String TYPE_CHECKLIST_ITEM = PropertyUtil.getSchemaProperty(context,"type_ChecklistItem");
    final String ATTRIBUTE_RESPONSE = PropertyUtil.getSchemaProperty(context,"attribute_Response");
    final String RELATIONSHIP_CHECKLIST = PropertyUtil.getSchemaProperty(context,"relationship_Checklist");
    final String RELATIONSHIP_CHECKLIST_ITEM = PropertyUtil.getSchemaProperty(context,"relationship_ChecklistItem");
    final String TYPE_CHECKLIST = PropertyUtil.getSchemaProperty(context,"type_Checklist");

    /** Complete State of type Checklist*/
    final String STATE_COMPLETE =
        PropertyUtil.getSchemaProperty(context,"policy",
                PropertyUtil.getSchemaProperty(context,"policy_Checklist"),
        "state_Complete");

    String sLanguage = request.getHeader("Accept-Language");
    String objectId = emxGetParameter(request, "objectId");
    objectId = XSSUtil.encodeURLForServer(context, objectId);
    String strResponse = emxGetParameter(request, "response");
    String strResponseType = emxGetParameter(request, "strResponseType");
    String isMultiSelect = emxGetParameter(request, "isMultiSelect");
    String tableRowIdList[] = emxGetParameterValues(request, "emxTableRowId");
    String strTableRowId=emxGetParameter(request, "emxTableRowId");
    String strTimeStamp = emxGetParameter(request, "timeStamp");
    String stremxTableRowIdActual = emxGetParameter(request, "emxTableRowIdActual");
    i18nNow i18nnow = new i18nNow();
    String strObjectId = "";
    if(strTableRowId != null){
	    String[] strID =  strTableRowId.split("\\|");
	    strObjectId = strID[1];
    }else{
    	strObjectId = objectId;
    	strTableRowId = "|" + strObjectId + "||0";
    }
    strObjectId = XSSUtil.encodeURLForServer(context, strObjectId);
    String mode = emxGetParameter(request, "mode");
    String parentOID = emxGetParameter(request, "parentOID");
    parentOID = XSSUtil.encodeURLForServer(context, parentOID);

    if(null != mode &&mode.equalsIgnoreCase("select")){
    	String finalStringResponse = DomainConstants.EMPTY_STRING;
    if (null != objectId && !DomainConstants.EMPTY_STRING.equals(objectId)&& null != isMultiSelect && "false".equals(isMultiSelect)) {
        DomainObject domObj = DomainObject.newInstance(context,objectId);
        domObj.setAttributeValue(context, ATTRIBUTE_RESPONSE, strResponse);
    }
    else if (null != objectId && !DomainConstants.EMPTY_STRING.equals(objectId) && null != isMultiSelect && "true".equals(isMultiSelect)) {
        DomainObject domainObj = DomainObject.newInstance(context, objectId);
        String responseValue = domainObj.getAttributeValue(context,ATTRIBUTE_RESPONSE);
        StringList responseTypeList = FrameworkUtil.split(strResponseType, "|");
        StringList responseAllreadyPresentList = FrameworkUtil.split(responseValue, "|");
        List<Integer> arrayList = new ArrayList<Integer>();
        int index = 0;

        if ("".equals(responseValue)) {
        	domainObj.setAttributeValue(context, ATTRIBUTE_RESPONSE, strResponse);
        }
        else {
            if (!responseAllreadyPresentList.contains(strResponse)) {
                try{
                    for(int itr = 0; itr < responseTypeList.size() ; itr++){
                        if(null != responseAllreadyPresentList && responseAllreadyPresentList.contains(responseTypeList.get(itr))){
                        	arrayList.add(Integer.valueOf(itr));
                        }
                    }
                    if(null != strResponse){
                         index = responseTypeList.indexOf(strResponse);
                         arrayList.add(Integer.valueOf(index));
                    }
                    if(null != arrayList)
                    	Collections.sort(arrayList);

                     for(int i = 0; i <  arrayList.size(); i++){
                         int iposition = arrayList.get(i).intValue();
                         finalStringResponse += responseTypeList.get(iposition) + "|";
                      }
                    finalStringResponse = finalStringResponse.substring(0,finalStringResponse.length()-1);
                    domainObj.setAttributeValue(context, ATTRIBUTE_RESPONSE, finalStringResponse);

                }
                catch(Exception e){
                    e.printStackTrace();
                }
            }
            else {
                StringList strResponseList = FrameworkUtil.split(responseValue, "|");
                String strResponseTemp = DomainConstants.EMPTY_STRING;
                String strFinalResponse = DomainConstants.EMPTY_STRING;
                if(null != strResponseList && strResponseList.contains(strResponse)){
                    strResponseList.remove(strResponse);
                    for(int itr = 0; itr < strResponseList.size(); itr++){
                    	strFinalResponse += strResponseList.get(itr) + "|";
                    }
                    if(null != strFinalResponse && !DomainConstants.EMPTY_STRING.equalsIgnoreCase(strFinalResponse)){
                        strFinalResponse = strFinalResponse.substring(0,strFinalResponse.length()-1);
                        domainObj.setAttributeValue(context, ATTRIBUTE_RESPONSE, strFinalResponse);
                    }
                    else{
                    	domainObj.setAttributeValue(context, ATTRIBUTE_RESPONSE, "");
                    }
                 }
           }
        }
    }
    }
    String targetSearchPage = DomainConstants.EMPTY_STRING;


    if(null != mode &&mode.equalsIgnoreCase("edit")){
        String strType = DomainConstants.EMPTY_STRING;
        DomainObject domObj = null;
        String strParentState = DomainConstants.EMPTY_STRING;
        String strSelectedObjectState = DomainConstants.EMPTY_STRING;
        if(strObjectId != null){
            domObj = DomainObject.newInstance(context,strObjectId);
            strType = domObj.getType(context);
        }
        if(null != strType && strType.equalsIgnoreCase(TYPE_CHECKLIST)){
        	 strParentState = domObj.getInfo(context, "to["+RELATIONSHIP_CHECKLIST+"].from.current");
        	 strSelectedObjectState = domObj.getInfo(context, DomainConstants.SELECT_CURRENT);
        	 if(null != strParentState && (strParentState.equalsIgnoreCase(STATE_COMPLETE) || strSelectedObjectState.equalsIgnoreCase(STATE_COMPLETE)))
        	 {
        		 %>
        		 <script language="javascript" src="../common/scripts/emxUICore.js"></script>
                 <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
                 <script type="text/javascript" language="JavaScript">
        		 alert("<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.Checklist.CannotEditChecklist", sLanguage)%>");
        		 </script>
                 <%
            }
        	 else{
        		//targetSearchPage ="../common/emxForm.jsp?type=type_Checklist&form=PMCEditChecklistWebform&mode=edit&formHeader="+ strFormHeader +"&Submit=true&objectId="+strObjectId;
        		targetSearchPage ="../common/emxForm.jsp?type=type_Checklist&form=PMCEditChecklistWebform&mode=edit&Submit=true&objectId="+strObjectId+"&postProcessURL=../programcentral/emxProgramCentralChecklistUtil.jsp?mode=reload&HelpMarker=emxhelpchecklistedit&suiteKey=ProgramCentral&formHeader=emxProgramCentral.Common.Checklist.EditChecklistObject";
             %>
            <script language="javascript" src="../common/scripts/emxUICore.js"></script>


            <%@page import="com.matrixone.apps.program.ProgramCentralConstants"%>
			<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
             <script type="text/javascript" language="JavaScript">
             var sURL = "<%=targetSearchPage%>";
             showModalDialog(sURL,500,500);
             self.closeWindow();
             </script>
             <%
        	 }
        }
        else if(null != strType && strType.equalsIgnoreCase(TYPE_CHECKLIST_ITEM)){
        	 strParentState = domObj.getInfo(context, "to["+RELATIONSHIP_CHECKLIST_ITEM+"].from.current");
        	 if(null != strParentState && strParentState.equalsIgnoreCase(STATE_COMPLETE))
             {
                 %>
                 <script language="javascript" src="../common/scripts/emxUICore.js"></script>
                 <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
                 <script type="text/javascript" language="JavaScript">
                 alert("<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.Checklist.CannotEditChecklistItem", sLanguage)%>");
                 </script>
                 <%
            }
        	else{
        		//Added by vf2 R2012
        		String strFormHeader = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.Checklist.EditChecklistItemObject", sLanguage);
        		//targetSearchPage ="../common/emxForm.jsp?type=type_ChecklistItem&form=PMCEditChecklistItemWebform&mode=edit&formHeader="+ strFormHeader +"&Submit=true&postProcessJPO=emxChecklist:editChecklistItemDetails&objectId="+strObjectId;
        		targetSearchPage ="../common/emxForm.jsp?type=type_ChecklistItem&form=PMCEditChecklistItemWebform&mode=edit&formHeader="+ strFormHeader +"&Submit=true&postProcessJPO=emxChecklist:editChecklistItemDetails&objectId="+strObjectId+"&postProcessURL=../programcentral/emxProgramCentralChecklistUtil.jsp?mode=reload&HelpMarker=emxhelpchecklistitemedit&suiteKey=ProgramCentral";
        		//End by vf2 R2012
        		%>
        	 <script language="javascript" src="../common/scripts/emxUICore.js"></script>
             <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
             <script type="text/javascript" language="JavaScript">
             var sURL = "<%=targetSearchPage%>";
             showModalDialog(sURL,500,500);
             self.closeWindow();
             </script>
             <%
        	 }
        }
        else{
        	%>
        	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
            <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
            <script type="text/javascript" language="JavaScript">
            alert("<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.Checklist.CannotEditGate", sLanguage)%>");
            </script>
            <%
        }
    }

    if(null != mode &&mode.equalsIgnoreCase("createChecklist")){
    	String portalCmdName = emxGetParameter(request, "portalCmdName");
    	portalCmdName = XSSUtil.encodeURLForServer(context, portalCmdName);
        DomainObject domObj = null;
        String strType = DomainConstants.EMPTY_STRING;
        String strSelectedObjectState = DomainConstants.EMPTY_STRING;
        if(strObjectId != null && !DomainConstants.EMPTY_STRING.equalsIgnoreCase(strObjectId)){
            domObj = DomainObject.newInstance(context,strObjectId);
            strType = domObj.getType(context);
        }
        if(null != strType && !strType.equalsIgnoreCase(TYPE_CHECKLIST_ITEM)){
        	strSelectedObjectState = domObj.getInfo(context, DomainConstants.SELECT_CURRENT);
        	if(null != strSelectedObjectState && strSelectedObjectState.equalsIgnoreCase(STATE_COMPLETE)){
        		%>
                <script language="javascript" src="../common/scripts/emxUIModal.js" />
                <script type="text/javascript" language="JavaScript">
                alert("<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Checklist.CannotCreateChecklist", sLanguage)%>");
                </script>
                <%
        	}
        	else{
            //Modified:nr2:PRG:R211:01-Nov-2010:078793
            targetSearchPage ="../common/emxCreate.jsp?type=type_Checklist&form=PMCCreateChecklistWebform&relationship=relationship_Checklist&mode=edit&formHeader=emxProgramCentral.Common.FormBasics&HelpMarker=emxhelpchecklistcreate&Export=false&nameField=both&direction=From&submitAction=doNothing&postProcessJPO=emxChecklist:createRevision&postProcessURL=../programcentral/emxProgramCentralChecklistUtil.jsp?mode=refreshChecklistAfterAdd&objectId="+strObjectId+"&emxTableRowId="+strTableRowId+"&parentOID="+parentOID+"&suiteKey=ProgramCentral&showApply=true"+"&portalCmdName="+portalCmdName;
        	%>
             <script language="javascript" src="../common/scripts/emxUICore.js"></script>
             <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
             <script type="text/javascript" language="JavaScript">
             var sURL = "<%=targetSearchPage%>";
             getTopWindow().showSlideInDialog(sURL, true);
             </script>
             <%
        	}
        }
        else{
             %>
             <script language="javascript" src="../common/scripts/emxUICore.js"></script>
             <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
             <script type="text/javascript" language="JavaScript">
             alert("<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Checklist.ChecklistCreate", sLanguage)%>");
             </script>
             <%
        }
    }

if(null != mode &&mode.equalsIgnoreCase("createChecklistItem")){
	String portalCmdName = emxGetParameter(request, "portalCmdName");
	portalCmdName = XSSUtil.encodeURLForServer(context, portalCmdName);
        DomainObject domObj = null;
        String strType = DomainConstants.EMPTY_STRING;
        String strSelectedObjectState = DomainConstants.EMPTY_STRING;
        if(strObjectId != null && !DomainConstants.EMPTY_STRING.equalsIgnoreCase(strObjectId)){
            domObj = DomainObject.newInstance(context,strObjectId);
            strType = domObj.getType(context);
        }
        if(null != strType && strType.equalsIgnoreCase(TYPE_CHECKLIST)){
        	strSelectedObjectState = domObj.getInfo(context, DomainConstants.SELECT_CURRENT);
            if(null != strSelectedObjectState && strSelectedObjectState.equalsIgnoreCase(STATE_COMPLETE))
            {
                %>
                <script language="javascript" src="../common/scripts/emxUICore.js"></script>
                <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
                <script type="text/javascript" language="JavaScript">
                alert("<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Checklist.CannotCreateChecklistItem", sLanguage)%>");
                </script>
                <%
           }
           else{
            targetSearchPage ="../common/emxCreate.jsp?type=type_ChecklistItem&relationship=relationship_ChecklistItem&form=PMCCreateChecklistItemWebform&mode=edit&submitAction=doNothing&formHeader=emxProgramCentral.Common.FormBasics&HelpMarker=emxhelpchecklistitemcreate&Export=false&direction=From&postProcessJPO=emxChecklist:createChecklistItem&nameField=both&postProcessURL=../programcentral/emxProgramCentralChecklistUtil.jsp?mode=refreshChecklistAfterAdd&objectId="+strObjectId+"&emxTableRowId="+strTableRowId+"&parentOID="+parentOID+"&suiteKey=ProgramCentral&showApply=true"+"&portalCmdName="+portalCmdName;
            %>
            <script language="javascript" src="../common/scripts/emxUICore.js"></script>
            <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
            <script type="text/javascript" language="JavaScript">
            var sURL = "<%=targetSearchPage%>";
            getTopWindow().showSlideInDialog(sURL, true);
            </script>
            <%
           }
        }
        else{
        	%>
        	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
            <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
            <script type="text/javascript" language="JavaScript">
            alert("<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Checklist.ChecklistItemCreate", sLanguage)%>");
            </script>
            <%
        }
    }

         if(null != mode &&mode.equalsIgnoreCase("delete")){
            try{
            	String strState = DomainConstants.EMPTY_STRING;
                String strParentState = DomainConstants.EMPTY_STRING;
                String strParentType = DomainConstants.EMPTY_STRING;
                String strType =DomainConstants.EMPTY_STRING;
             // [MODIFIED::Feb 9, 2011:S4E:version:IR-069073V6R2012 ::Start]
                if (null != strObjectId && !"".equals(strObjectId)){
                    DomainObject domObj = DomainObject.newInstance(context,strObjectId);
                    Map objectInfoMap = new HashMap();
                    StringList slBusSelect = new StringList(DomainConstants.SELECT_TYPE);
                    slBusSelect.add(DomainConstants.SELECT_CURRENT);
                    slBusSelect.add("to["+RELATIONSHIP_CHECKLIST+"].from.type");
                    slBusSelect.add("to["+RELATIONSHIP_CHECKLIST+"].from.current");
                    slBusSelect.add("to["+RELATIONSHIP_CHECKLIST_ITEM+"].from.current");
                    slBusSelect.add("to["+RELATIONSHIP_CHECKLIST_ITEM+"].from.type");
                    objectInfoMap =  domObj.getInfo(context,slBusSelect);

                    strType =  (String)objectInfoMap.get(DomainConstants.SELECT_TYPE);
                    strState = (String)objectInfoMap.get(DomainConstants.SELECT_CURRENT);
                    strParentType = (String)objectInfoMap.get("to["+RELATIONSHIP_CHECKLIST+"].from.type");
                    strParentState = (String)objectInfoMap.get("to["+RELATIONSHIP_CHECKLIST+"].from.current");
                    if(null == strParentState || "".equalsIgnoreCase(strParentState)){
                        strParentState = (String)objectInfoMap.get("to["+RELATIONSHIP_CHECKLIST_ITEM+"].from.current");
                        strParentType = (String)objectInfoMap.get("to["+RELATIONSHIP_CHECKLIST_ITEM+"].from.type");
                    }
                    if(ProgramCentralUtil.isNotNullString(strParentType) && strParentType.equalsIgnoreCase(DomainConstants.TYPE_TASK)){
                    	strParentState = strState;
                    }
                }
                if(null != strParentState && !strParentState.equalsIgnoreCase(STATE_COMPLETE) && !strState.equalsIgnoreCase(STATE_COMPLETE)){
                StringList strList          = null;
                String strRelId             = DomainConstants.EMPTY_STRING;
                String strIds               = DomainConstants.EMPTY_STRING;

                String[] strTableRowIds  =  emxGetParameterValues(request, "emxTableRowId");
                String[] strRelIdArr    = new String[strTableRowIds.length];
                String[] strObjectIDArr    = new String[strTableRowIds.length];

                String partialXML = DomainConstants.EMPTY_STRING;
                String rowId = DomainConstants.EMPTY_STRING;
                for(int i = 0; i < strTableRowIds.length; i++)
                {
                    strIds                  = strTableRowIds[i];
                    strList                 = FrameworkUtil.split(strIds,"|");
                    strRelId                = (String)strList.get(0);
                    strObjectIDArr[i]        = (String)strList.get(1);
                    strRelIdArr[i]          = strRelId;
                    rowId =  (String)strList.lastElement();
                    partialXML += "<item id=\"" + rowId + "\" />";
                }
                DomainRelationship.disconnect(context,strRelIdArr);
                DomainObject.deleteObjects(context,strObjectIDArr) ;
                String xmlMessage = "<mxRoot>";
                String message = "";
                xmlMessage += "<action refresh=\"true\" fromRMB=\"\"><![CDATA[remove]]></action>";
                xmlMessage += partialXML;
                xmlMessage += "<message><![CDATA[" + message  + "]]></message>";
                xmlMessage += "</mxRoot>";
                %>
                <script type="text/javascript" language="JavaScript">
                window.parent.removedeletedRows('<%= xmlMessage %>');
                </script>
                <%}
                else if(ProgramCentralUtil.isNotNullString(strParentType) && strParentType.equalsIgnoreCase(TYPE_CHECKLIST)){

                	%>
                    <script language="javascript" type="text/javaScript">
                    alert("<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.Checklist.ParentChecklistDelete", sLanguage)%>");
                    </script>
                <%
                }
                else if(strType.equalsIgnoreCase(ProjectSpace.TYPE_GATE)){
                    %>
                    <script language="javascript" type="text/javaScript">
                    alert("<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.Checklist.CannotDeleteGate", sLanguage)%>");
                    </script>
                <%
                }
                else
                {%>
                    <script language="javascript" type="text/javaScript">
                    alert("<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Common.Checklist.CannotDeleteChecklist", sLanguage)%>");
                    </script>
                <%}
        }catch(Exception ex) {
                ex.printStackTrace();
        } // End of catch

        }
         if(null != mode &&mode.equalsIgnoreCase("checklistCopyFromWBSGateRMBMenu")){

             DomainObject domObj = null;
             String strType = DomainConstants.EMPTY_STRING;
             String strSelectedObjectState = DomainConstants.EMPTY_STRING;
             if(strObjectId != null && !DomainConstants.EMPTY_STRING.equalsIgnoreCase(strObjectId)){
                 domObj = DomainObject.newInstance(context,strObjectId);
                 strType = domObj.getType(context);
             }
             if(null != strType && !strType.equalsIgnoreCase(TYPE_CHECKLIST_ITEM)){

            	 targetSearchPage ="../common/emxFullSearch.jsp?table=PMCChecklistSummarySearchTable&header=emxProgramCentral.Common.Checklist.ChecklistSearch&selection=single&field=TYPES=type_Checklist&hideHeader=true&includeOIDprogram=emxChecklist:getChecklists&submitURL=../programcentral/emxProgramCentralChecklistUtil.jsp?mode=copy&objectId="+strObjectId+"&parentOID="+parentOID+"";
            	 if(FrameworkUtil.isSuiteRegistered(context, "appVersionLRA", false, null, null)){
            		 targetSearchPage +="&formInclusionList=REG_CONTEXT";
            	 }
             	%>
             	  <script language="javascript" src="../common/scripts/emxUICore.js"></script>
                  <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
                  <script type="text/javascript" language="JavaScript">
                           var strUrl ="<%=targetSearchPage%>";
                          // document.location.href = strUrl;
                          showModalDialog(strUrl);
             	   </script>
                    </script>
                  <%
             	}else{
           	 	 %>
            	 <script language="javascript" type="text/javaScript">
            	      	alert("<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Checklist.ChecklistCreate", sLanguage)%>");
            	      	window.close();
             		</script>
             	<%
             	}
             }

        if(null != mode &&mode.equalsIgnoreCase("copy")){
            try{
                //Map mapValues = null;
                boolean returnValue = true;
                Map methodMap = new HashMap(1);
                methodMap.put("objectId",strObjectId);
                methodMap.put("languageStr",sLanguage);
                methodMap.put("taskId",objectId);
                methodMap.put("timeStamp",strTimeStamp);
                methodMap.put("fromCommand","True");
                String[] methodArgs = JPO.packArgs(methodMap);
                //Added:nr2:PRG:R210:18-06-2010:For Checklist functionality
                Boolean returnVal  = (Boolean) JPO.invoke(context,
                                                 "emxChecklist",
                                                 null,
                                                 "copySelected",
                                                  methodArgs,
                                                  Boolean.class);
                if(!returnVal.booleanValue()){
                    DomainObject selectedObject = DomainObject.newInstance(context,objectId);
                    String checkListItemName = selectedObject.getInfo(context,DomainConstants.SELECT_NAME);

                    String strError = EnoviaResourceBundle.getProperty(context, "ProgramCentral",
              			  "emxProgramCentral.Checklist.CannotCopyChecklistUnderItem", sLanguage);

                    strError += checkListItemName;

                    %>
                    <script language="javascript" type="text/javaScript">
                    alert("<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.Checklist.CannotCopyChecklistUnderItem", sLanguage)%>");
                    </script>
                    <%
                }
                //Added:nr2:PRG:R210.HF1:03 Nov 2010:HF-078793
	               String pasteBelowToRow = "";
	               if(null != strTableRowId){
	                   StringList slPasteBelowToRow = FrameworkUtil.split(strTableRowId, "|");
	                   if(null != slPasteBelowToRow){
	                       pasteBelowToRow = slPasteBelowToRow.get(slPasteBelowToRow.size()-1).toString();
	                   }
	               }
	            DomainObject checklistObj = null;
	            // objectId is the parent on which child is to be copied from another node.
                if(ProgramCentralUtil.isNotNullString(objectId))
                    checklistObj = DomainObject.newInstance(context,objectId);
                StringList busSelects = new StringList();
                StringList relSelects = new StringList();
                busSelects.add(ProgramCentralConstants.SELECT_ID);
                busSelects.add(ProgramCentralConstants.SELECT_ORIGINATED);

                //get checklist connected to parent.
                MapList checklistObjects = checklistObj.getRelatedObjects(
                        context,                                     //matrix context
                        RELATIONSHIP_CHECKLIST,
                        TYPE_CHECKLIST,                              // type pattern,
                        busSelects,                                     // objectSelects
                        relSelects,                                  // relationshipPattern
                        false,                                        // getTo
                        true,                                        // getFrom
                        (short)1,                                    // recurseToLevel
                        null,                                        // objectWhere
                        null,                                         // relationshipWhere
                        0
                );

                StringList originatedList = new StringList();   // list to store originated date for each checklist.
                Map checkListMap = null;
                String originated = null;
                Date dtOriginated = null;
                for(Iterator itr = checklistObjects.iterator(); itr.hasNext();){
                	checkListMap = (Map)itr.next();
                	originated = (String)checkListMap.get(ProgramCentralConstants.SELECT_ORIGINATED);
                	dtOriginated = eMatrixDateFormat.getJavaDate(originated);
                	originated = String.valueOf(dtOriginated.getTime());
                	originatedList.add(originated);
                }
                Locale locale = context.getLocale();
                //Get the checklist with maximum originated value. This helps in getting recently created checklist.
                String maxOriginated = FrameworkUtil.getMaximum(context,locale,originatedList);
                int index = originatedList.indexOf(maxOriginated);
                checkListMap = (Map)checklistObjects.get(index);
                strObjectId = (String)checkListMap.get(ProgramCentralConstants.SELECT_ID);
                DomainObject dmoChecklist = DomainObject.newInstance(context,strObjectId);
                boolean isFromRMB = "true".equalsIgnoreCase(emxGetParameter(request, "isFromRMB"));
                String fromRMB = isFromRMB?"true":"";
                String relId = dmoChecklist.getInfo(context,"relationship[" + RELATIONSHIP_CHECKLIST + "].id");

                String xmlMessage = "<mxRoot>" +
                "<action><![CDATA[add]]></action>" +
                "<data status=\"committed\" fromRMB=\"" + fromRMB + "\"" + " >" +
                "<item oid=\"" + strObjectId + "\" relId=\"" + relId + "\" pid=\"" + objectId + "\"  pasteBelowToRow=\"" + pasteBelowToRow + "\" />" ;
                xmlMessage += "</data></mxRoot>";
                %>
                <script language="javascript"src="../common/scripts/emxUICore.js"></script>
                <script language="javascript" type="text/javaScript">
                 if(getTopWindow().window.parent.frameElement){
                    getTopWindow().window.parent.getWindowOpener().emxEditableTable.addToSelected('<%= xmlMessage%>');
                    getTopWindow().window.parent.getWindowOpener().refreshStructureWithOutSort();
                     getTopWindow().window.closeWindow();
                 }
                 else if(getTopWindow().window.parent){
                	 getTopWindow().getWindowOpener().parent.emxEditableTable.addToSelected('<%= xmlMessage%>');
                	 getTopWindow().getWindowOpener().parent.refreshStructureWithOutSort();
                getTopWindow().closeWindow();
                 }
                </script>
                <%
              //End:nr2:PRG:R210.HF1:03 Nov 2010:HF-078793
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }


        if(null != mode &&mode.equalsIgnoreCase("userRole")){
            try{
            	String portalCmdName = emxGetParameter(request, "portalCmdName");
            	portalCmdName = XSSUtil.encodeURLForServer(context, portalCmdName);
            	//Map mapValues = null;
                boolean returnValue = true;
                Map methodMap = new HashMap(1);
                methodMap.put("objectId",objectId);
                methodMap.put("languageStr",sLanguage);
                methodMap.put("emxTableRowIdActual",stremxTableRowIdActual);
                methodMap.put("timeStamp",strTimeStamp);
                String[] methodArgs = JPO.packArgs(methodMap);

                Boolean returnVal  = (Boolean) JPO.invoke(context,
                                                 "emxChecklist",
                                                 null,
                                                 "checkCreateObjectAccessFunctionProjectLead",
                                                  methodArgs,
                                                  Boolean.class);
                String strReturnValue = returnVal.toString();
                targetSearchPage ="../common/emxIndentedTable.jsp?table=PMCChecklistSummaryTable&mode=view&selection=multiple&sortColumnName=Name,Type&Export=true&relationship=relationship_Checklist,relationship_ChecklistItem&type=type_Checklist,type_ChecklistItem&direction=From&expandLevelFilter=true&header=emxProgramCentral.Common.Checklist.ChecklistSummary&suiteKey=ProgramCentral&editRootNode=false&HelpMarker=emxhelpgatechecklist&postProcessJPO=emxChecklist:postProcessRefreshTable&objectId="+objectId+"&emxTableRowId="+strTableRowId+"&portalCmdName="+portalCmdName;

                DomainObject domObj = DomainObject.newInstance(context,objectId);
                String gateState = domObj.getInfo(context, DomainConstants.SELECT_CURRENT);

                if((ProgramCentralUtil.isNotNullString(strReturnValue) && strReturnValue.equalsIgnoreCase("true")) && (!gateState.equalsIgnoreCase(STATE_COMPLETE))){
                	targetSearchPage += "&toolbar=PMCChecklistTopActionToolbar&editLink=true";
                }
%>
                <script type="text/javascript" language="JavaScript">
	                var sURL = "<%=targetSearchPage%>";
	                window.location.href = sURL;
	            </script>
<%
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        //Added by vf2 R2012
        if(null != mode && mode.equalsIgnoreCase("reload")){
            %>
                <script type="text/javascript" language="JavaScript">
                getTopWindow().closeWindow();
                parent.window.getWindowOpener().parent.document.location.href = parent.window.getWindowOpener().parent.document.location.href;
                </script>
            <%
        } else if (mode != null && mode.equalsIgnoreCase("refreshChecklistAfterAdd")) {

        	String newObjectId = (String) emxGetParameter(request,"newObjectId");
        	String relId = (String) emxGetParameter(request,"relId");
        	parentOID = (String) emxGetParameter(request,"parentOID");
        	String emxTableRowId = (String) emxGetParameter(request,"emxTableRowId");
        	String currentframe = emxGetParameter(request, "portalCmdName");
        	currentframe = XSSUtil.encodeForJavaScript(context, currentframe);
        	String pasteBelowToRow = DomainConstants.EMPTY_STRING;

        	if(emxTableRowId != null){
        	    StringList slPasteBelowToRow = FrameworkUtil.split(emxTableRowId, "|");
        	    if(slPasteBelowToRow != null){
        	        pasteBelowToRow = slPasteBelowToRow.get(slPasteBelowToRow.size()-1).toString();
        	        if(slPasteBelowToRow.size() == 4){
        	        	parentOID = slPasteBelowToRow.get(1).toString();
        	        } else {
        	        	parentOID = slPasteBelowToRow.get(0).toString();
        	        }
        	    }
        	}
        	String strSubOperation = "add";
        	boolean isFromRMB = "true".equalsIgnoreCase(emxGetParameter(request, "isFromRMB"));
        	String fromRMB = isFromRMB?"true":DomainConstants.EMPTY_STRING;

        	String xmlMessage = "<mxRoot>" +
        	"<action><![CDATA[add]]></action>" +
        	"<data status=\"committed\" fromRMB=\"" + fromRMB + "\"" + " >" +
        	"<item oid=\"" + newObjectId + "\" relId=\"" + relId + "\" pid=\"" + parentOID + "\" direction=\"from\" pasteBelowToRow=\"" + pasteBelowToRow + "\" />" ;
        	xmlMessage += "</data></mxRoot>";
        	%>
       		<script type="text/javascript" language="JavaScript">
       		var detailsDisplayFrame = findFrame(getTopWindow(),'detailsDisplay');
       		var topFrame = findFrame(detailsDisplayFrame, "<%=currentframe%>");
       		if(null == topFrame){
       			topFrame = findFrame(top, "detailsDisplay");	
  			     if(null == topFrame){
       		  	topFrame = findFrame(top, "PMCChecklist");
       		  }
       		}

       		    if(null == topFrame){
            			topFrame = findFrame(top, "content");
            	       		var topURL = top.location.href;
       		                 top.location.href = topURL;

		  }else{
	       		topFrame.emxEditableTable.addToSelected('<%=xmlMessage%>');
	       		topFrame.refreshStructureWithOutSort();
		  }
      		//getTopWindow().closeSlideInDialog();
               </script>
        	<%
     } else if(ProgramCentralUtil.isNotNullString(mode) && mode.equalsIgnoreCase("nameLink")){

    	 String checkListSummaryPage ="../common/emxIndentedTable.jsp?table=PMCChecklistSummaryTable&sortColumnName=Name,Type&Export=true&expandLevelFilter=true&header=emxProgramCentral.Common.Checklist.ChecklistSummary&suiteKey=ProgramCentral&HelpMarker=emxhelpgatechecklist&expandProgram=emxChecklist:expandChecklistSummaryTableObjects&editLink=true&objectId="+objectId;
		 %>
    	 <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
         <script type="text/javascript" language="JavaScript">
         var sURL = "<%=checkListSummaryPage%>";
         window.parent.location.href = sURL;
         </script>
         <%

        }
       //End by vf2 R2012
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%-- <jsp:include
    page="emxChartInclude.jsp" flush="true" /> --%>

