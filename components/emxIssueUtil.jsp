<%--
  emxIssueUtil.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  static const char RCSID[] = "$Id: emxIssueUtil.jsp.rca 1.24 Wed Oct 22 16:18:27 2008 przemek Experimental przemek $";

--%>
<%@page import="com.matrixone.apps.common.Issue"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.common.util.FormBean"%>
<%@page import="com.matrixone.apps.domain.util.AccessUtil"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="matrix.util.StringList"%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxComponentsCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../components/emxComponentsTreeUtilInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>

<%
    boolean bIsError = false;
  	boolean isClassificationType=false;
  	String strTableRowId="";
    //Get the mode called
    String strMode = emxGetParameter(request, "mode");
    String jsTreeID = emxGetParameter(request, "jsTreeID");
    String objectId = emxGetParameter(request, "objectId");
    String fromGlobalActionToolbar = emxGetParameter(request, "fromGlobalActionToolbar");
    String targetLocation = emxGetParameter(request,"targetLocation");
    if(!UIUtil.isNullOrEmpty(objectId)){
    if(new DomainObject(objectId).isKindOf(context,PropertyUtil.getSchemaProperty(context,"type_Classification")))
    	 isClassificationType=true;
    }
    
    strMode = strMode!=null ? strMode : "";
    boolean isCreateIssueMode = strMode.equalsIgnoreCase("createIssue");
    boolean isCreateMultipleIssueMode = strMode.equalsIgnoreCase("createMultipleIssue");
    boolean isDeleteMode = strMode.equalsIgnoreCase("delete");
    boolean isChangeTypeMode = strMode.equalsIgnoreCase("changeType");
    boolean isCloseMode = strMode.equalsIgnoreCase("Close");
    boolean isAddAssigneeMode = strMode.equalsIgnoreCase("addAssignee");
    boolean isDisconnectMode = strMode.equalsIgnoreCase("disconnect");
    boolean isDisconnectAssigneeMode = strMode.equalsIgnoreCase("disconnectAssignee");
    boolean isAddExistingMode = strMode.equalsIgnoreCase("addExisting");
    String lang = request.getHeader("Accept-Language");
    
     String appDirectory = (String)EnoviaResourceBundle.getProperty(context,"eServiceSuiteComponents.Directory");
     
    Map javaScriptHelperObjects = new HashMap(10);
    
try  {
 	Issue issueBean = new Issue();
 	FormBean formBean = new FormBean();
 	formBean.processForm(session, request);
    if (isCreateIssueMode || isCreateMultipleIssueMode) {
        String strAction = emxGetParameter(request,"IssueFSParam2");
        String parentObjId =(String)formBean.getElementValue("objectId");
        String strRelIssue = PropertyUtil.getSchemaProperty(context,"relationship_Issue");
        //Setting the latest Locale in context
        Locale Local = request.getLocale();
        context.setLocale(Local);
        String strIssueId = issueBean.create(context, formBean);
        javaScriptHelperObjects.put("createIssueId", strIssueId);
        javaScriptHelperObjects.put("parentObjId", parentObjId);
        //Added for the bug 338087 to retrieve the relationship ID in order to pass that to tree
        //This relId is passed as a parameter to the emxTree url where ever used in this JSP
        //Added if loop for the bug 340857
        if(parentObjId!=null && !"".equals(parentObjId))  {
            DomainObject issueObj = new DomainObject(strIssueId);
            StringList relSelects = new StringList(1);
            relSelects.add(DomainObject.SELECT_ID);
            MapList objlist = issueObj.getRelatedObjects(
                                    context,        // matrix context
                                    strRelIssue,   // relationship pattern
                                    "*",            // object pattern
                                    null,  // object selects
                                    relSelects,           // relationship selects
                                    false,           // to direction
                                    true,          // from direction
                                    (short) 0,  // recursion level
                                    "id == " + parentObjId, // object where clause
                                    null);
            if(objlist.size()>0) {
                Map RelObjMap = (Map) objlist.get(0);
                javaScriptHelperObjects.put("createIssueRelId", RelObjMap.get(DomainObject.SELECT_ID));
            }
        }
  } else if (isDeleteMode) {
	      //delete Functionality
          //get the table row ids of the test case objects selected
          String[] arrTableRowIds = FrameworkUtil.getSplitTableRowIds(emxGetParameterValues(request, "emxTableRowId"));
          //get the object ids of the tablerow ids passed
          String strObjectIds[] = strObjectIds = Issue.getObjectIds(arrTableRowIds);
          // check to see if user has "delete" access on the object
          boolean isPushed = false;
          try{
              String deleteAccessCheck = "current.access[delete]";
              StringList selects = new StringList();
              selects.add(deleteAccessCheck);
              selects.add(DomainObject.SELECT_ID);
              selects.add(DomainObject.SELECT_TYPE);
              selects.add(DomainObject.SELECT_NAME);
              selects.add(DomainObject.SELECT_REVISION);
              
              MapList issueDelAccessInfo = DomainObject.getInfo(context, strObjectIds, selects);
              Map noDeleteAccessObjectList = new HashMap();
              Map hasDeleteAccessObjectList = new HashMap();
              
              for (int i = 0; i < issueDelAccessInfo.size(); i++) {
                  Map issueDelAccess = (Map)issueDelAccessInfo.get(i);
                  String access = (String)issueDelAccess.get(deleteAccessCheck);
                  if("TRUE".equalsIgnoreCase(access)) {
                      hasDeleteAccessObjectList.put(issueDelAccess.get(DomainObject.SELECT_ID), issueDelAccess);
                  } else {
                      noDeleteAccessObjectList.put(issueDelAccess.get(DomainObject.SELECT_ID), issueDelAccess);
                  }
              }
              
              //Call the deleteObjects method of IssueBean to delete the selected object
              //Use push/pop bcz, user may not have ToDisconnect/FromDisconnect access not on the connected
              // object to the Decision
              if (hasDeleteAccessObjectList.size() > 0) {
                  ContextUtil.pushContext(context);
                  isPushed = true;
                  String[] deletedIssues = (String []) hasDeleteAccessObjectList.keySet().toArray(new String[]{});
                  javaScriptHelperObjects.put("deletedIds", deletedIssues);
				  issueBean.deleteObjects(context, deletedIssues, false);
              }
              if(noDeleteAccessObjectList.size() > 0) {
                  StringBuffer buffer = new StringBuffer(noDeleteAccessObjectList.size() * 20);
                  Iterator itr = noDeleteAccessObjectList.keySet().iterator();
                  buffer.append(i18nNow.getI18nString("emxComponents.Message.ObjectsNotDeleted", "emxComponentsStringResource", lang)).append("\n");
                  while (itr.hasNext()) {
                      String id = (String) itr.next();
                      Map map = (Map) noDeleteAccessObjectList.get(id);
                      buffer.append(map.get(DomainObject.SELECT_TYPE)).append(' ').
                      		 append(map.get(DomainObject.SELECT_NAME)).append(' ').
                      		 append(map.get(DomainObject.SELECT_REVISION)).append("\n");
                  }
                  throw new Exception(buffer.toString());
              }
          } catch(Exception ex){
             // START:OEP:BUG 371496
             String error = ex.getMessage();
             if(error.indexOf("java.lang.Exception:") != -1) {
				    int firstIndex = error.indexOf("java.lang.Exception:");
                    error = error.substring(firstIndex + 20);
                    int endIndex = error.indexOf("Warning:");
                    error = endIndex != -1 ? (error.substring(0,endIndex)).trim() : error;
                    endIndex = error.indexOf("Severity:");
                    error = endIndex != -1 ? (error.substring(0,endIndex)).trim() : error;
              }
              throw new Exception(error); 
                        // END:OEP:BUG 371496
           } finally {
              if(isPushed) {
                ContextUtil.popContext(context);
           	  }
           }
  }  else if (isCloseMode) {
	// Close Functionality
    try{
        //Calling the close Method of Issue.java
      String strCurrentState = issueBean.close(context, formBean);
      //get the last state and compare
      String strObjectId = (String)formBean.getElementValue("objectId");
      BusinessObject bobjStates = new BusinessObject(strObjectId);
      StateList lstStates = bobjStates.getStates(context);
      State lastState = (State) lstStates.get((lstStates.size()-1));
      String strFinalState = (String) lastState.getName();
      javaScriptHelperObjects.put("isInFinalState", strCurrentState.equalsIgnoreCase(strFinalState) ? "true" : "false");

    }catch(Exception e){
	    e.printStackTrace();
    	bIsError=true;
      	StringBuffer strAlertString = new StringBuffer("emxComponents.Alert.");
      	strAlertString=strAlertString.append(e.toString());
      	String strErrorMessage = "";
      	strErrorMessage = i18nNow.getI18nString(strAlertString.toString(),bundle,acceptLanguage);
	    if (strErrorMessage==null || "".equals(strErrorMessage)|| "null".equals(strErrorMessage))
    	    strErrorMessage = e.getMessage();
	        session.putValue("error.message", strErrorMessage);
     }
  } else if(isChangeTypeMode) {
		//    Change Type functionality starts here
   		//Processing the form using FormBean.processForm
	    issueBean.changeType (context, formBean);
  } else if (isAddAssigneeMode) {
   		String timeStamp = emxGetParameter(request, "timeStamp");
  		HashMap requestMap = (HashMap)tableBean.getRequestMap(timeStamp);
	 	//  String strParentId=(String)emxGetParameter(request,"productID");
   		String strParentId=(String)requestMap.get("productID");
    	String strTargetURL = "emxCommonSearch.jsp?strParentId="+XSSUtil.encodeForURL(context, strParentId);
 %><!-- //XSSOK -->
	   <jsp:forward page="<%=strTargetURL%>"/>
 <%
  } else if (isDisconnectMode) {
	//Disconnect Issue from Context object
    //get the table row ids of the test case objects selected
    String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
 	//get the object ids of the tablerow ids passed
    //get the relationship ids of the table row ids passed
    Map relIdMap = Issue.getObjectIdsRelIds(arrTableRowIds);
    String[] arrRelIds = (String[]) relIdMap.get("RelId");
    String[] strObjectIds = (String[]) relIdMap.get("ObjId");
    //Call the removeObjects method of IssueBeanto remove the selected object
    //<Fix 368250> call removeReportedAgainstObjects(), if disconnecting ReportedAgainst relations.
    String command = emxGetParameter(request, "command");
    String strExpr = "COUNT=true";
	String strIssueId = emxGetParameter(request,"objectId");
	String strRelIssue = PropertyUtil.getSchemaProperty(context,"relationship_Issue");	
	String sCommandStatement = "eval expr $1 on expand bus $2 rel $3 recurse to 1";
	String sReportedAgainstCount = MqlUtil.mqlCommand(context, sCommandStatement,strExpr,strIssueId,strRelIssue);
	int n = Integer.parseInt(sReportedAgainstCount);
   	if(n == arrTableRowIds.length && command != null && command.equals("RemoveReportedAgainst")) {
		String errMsg=EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource",context.getLocale(),"emxComponents.Warning.ReportedAgainstMinimumCount");
		session.putValue("error.message", errMsg);
	} else {
		boolean bFlag = (command != null && command.equals("RemoveReportedAgainst")) ?
		            issueBean.removeReportedAgainstObjects(context, arrRelIds) :
	                issueBean.removeObjects(context, arrRelIds);    
	javaScriptHelperObjects.put("deletedIds", strObjectIds);
	}    
    //</Fix 368250>
  } else if (isDisconnectAssigneeMode) {
	 // Disconnect Assignee from Issue object
     //get the table row ids of the test case objects selected
     String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
     //get the object ids of the tablerow ids passed
     //get the relationship ids of the table row ids passed
     Map relIdMap = Issue.getObjectIdsRelIds(arrTableRowIds);
     String[] arrRelIds = (String[]) relIdMap.get("RelId");
     String[] strObjectIds = (String[]) relIdMap.get("ObjId");
     //Call the removeObjects method of IssueBean to remove the selected object
     boolean bFlag = issueBean.removeAssignee(context, arrRelIds, strObjectIds);
     javaScriptHelperObjects.put("deletedIds", strObjectIds);
  } else if (isAddExistingMode) {
		// Add Existing Issue functionality
	    DomainObject parentObject = DomainObject.newInstance(context, objectId);
	    String strRelSymbolic = emxGetParameter(request, "srcDestRelName");
	    String strRelationshipName = PropertyUtil.getSchemaProperty(context, strRelSymbolic);
	    
	    StringList objSelects = new StringList(2);
		objSelects.add(DomainConstants.SELECT_ID);
		objSelects.add(DomainConstants.SELECT_NAME);
		
		StringList relSelects = new StringList(2);
		relSelects.add(DomainRelationship.SELECT_ID);
		relSelects.add(DomainRelationship.SELECT_NAME);
	    
		MapList mplIssues = parentObject.getRelatedObjects(context,
		        										   strRelationshipName,
		        										   PropertyUtil.getSchemaProperty(context,"type_Issue"),
		        										   objSelects,relSelects,
		        										   true,false,
		        										   (short)1
		        										   ,null,null);
		
		StringList strlIssueIds = new StringList(mplIssues.size());
		StringList strlIssueNames = new StringList(mplIssues.size());
		for(int k=0;k<mplIssues.size();k++) {
			Map map = (Map)mplIssues.get(k);
			strlIssueIds.add((String)map.get(DomainConstants.SELECT_ID));
			strlIssueNames.add((String)map.get(DomainConstants.SELECT_NAME));
		}
		
		StringBuffer existingIssues = new StringBuffer(200);
	    // From autonomy search the emxTableRowIds are submitted as
	    // <issue id>|<parent id>|1,0
		String emxTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
		emxTableRowIds = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(emxTableRowIds);
		for (int i = 0; i < emxTableRowIds.length; i++) {
	         strTableRowId = emxTableRowIds[i];	        
	        if(!strlIssueIds.contains(strTableRowId)) {
	            com.matrixone.apps.domain.DomainRelationship.connect(context, 
	                    DomainObject.newInstance(context, strTableRowId), 
	                    strRelationshipName, 
	                    parentObject);
	        } else {
	            existingIssues.append(strlIssueNames.get(strlIssueIds.indexOf(strTableRowId))).append(" ");
	        }
		 }
		javaScriptHelperObjects.put("existingIssues", existingIssues.toString());
   }
}catch(Exception e){
  bIsError=true;
  
  String message ="";
  if (e.getMessage().indexOf("fromdisconnect") >0 || e.getMessage().indexOf("todisconnect") >0) {
      message=EnoviaResourceBundle.getProperty(context,
                                    "emxComponentsStringResource",
                                    context.getLocale(),
                                    "emxComponents.Common.DisconnectObjectFailed");
  }else if (e.getMessage().indexOf("fromconnect") >0 || e.getMessage().indexOf("toconnect") >0) {
	  	 DomainObject domObjTC = DomainObject.newInstance(context,objectId);
	  	 String name=domObjTC.getInfo(context, DomainConstants.SELECT_NAME);
	 	 message=EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource",context.getLocale(),"emxComponents.Common.Issue.ConnectCOObjectFailed");
 	 	 message=UIExpression.substituteValues(context, message, strTableRowId);
		 message=FrameworkUtil.findAndReplace(message,"<businessObject>", name); 
  } else {
  	message = e.getMessage();
  }
 
  
//START:OEP:BUG 371496
  session.putValue("error.message", message);
//END:OEP:BUG 371496
  // e.printStackTrace(System.out);
 }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<script language="javascript" type="text/javaScript">
var issueId     = "<%=XSSUtil.encodeForJavaScript(context,(String)javaScriptHelperObjects.get("createIssueId"))%>";
var relId       = "<%=XSSUtil.encodeForJavaScript(context,(String)javaScriptHelperObjects.get("createIssueRelId"))%>";
var parentObjId = "<%=XSSUtil.encodeForJavaScript(context,(String)javaScriptHelperObjects.get("parentObjId"))%>";
var existingIssue = "<%=XSSUtil.encodeForJavaScript(context,(String)javaScriptHelperObjects.get("existingIssues"))%>";
var isInFinalState = "<%=XSSUtil.encodeForJavaScript(context,(String)javaScriptHelperObjects.get("isInFinalState"))%>";
var contentFrame = openerFindFrame(getTopWindow(),"content");
var fromGlobalActionToolbar = "<%=XSSUtil.encodeForJavaScript(context,fromGlobalActionToolbar)%>";
var targetLocation = "<%=XSSUtil.encodeForJavaScript(context,targetLocation)%>";
var treeURL = "";
if(fromGlobalActionToolbar == "true")
	//XSSOK
	treeURL = getTreeURL(issueId, "<%=appDirectory%>", relId, "replace");
else
	//XSSOK
	treeURL = getTreeURL(issueId, "<%=appDirectory%>", relId);
 
	<framework:ifExpr expr="<%=isCreateIssueMode%>">
	if(issueId != null && issueId != "null"){
		//XSSOK
		if(!<%=isClassificationType%>)
			//XSSOK
			loadTreeNode(issueId, parentObjId,"<%=XSSUtil.encodeForJavaScript(context, jsTreeID)%>","<%=appDirectory%>",true, treeURL);
		else
			getTopWindow().closeWindow();
	}
if("slidein" == targetLocation) {
		getTopWindow().closeSlideInDialog();
  }else if (getTopWindow().getWindowOpener()) {
	    	getTopWindow().closeWindow();
  }
</framework:ifExpr>
<framework:ifExpr expr="<%=isCreateMultipleIssueMode%>">

var listDisplay = getTopWindow().getWindowOpener() ? getTopWindow().getWindowOpener() : (openerFindFrame(getTopWindow(), "listDisplay") ? openerFindFrame(getTopWindow(), "listDisplay").parent : null);
if (listDisplay && fromGlobalActionToolbar != "true") {
listDisplay.location.href = listDisplay.location.href;
}
    else{
    //XSSOK
	loadTreeNode(issueId, parentObjId,"<%=XSSUtil.encodeForJavaScript(context, jsTreeID)%>","<%=appDirectory%>",true, treeURL);
    }
    parent.frames['pagecontent'].clicked = false;
    parent.document.getElementById("imgProgressDiv").style.visibility = "hidden";
    parent.window.focus();
</framework:ifExpr>
<framework:ifExpr expr="<%=isDeleteMode || isDisconnectAssigneeMode || isDisconnectMode%>">
var listDisplay = openerFindFrame(parent, "listDisplay");
var detailsDisplay = openerFindFrame(parent.getTopWindow(), "detailsDisplay");
<%if(isDisconnectMode || isDisconnectAssigneeMode){%>
 detailsDisplay = openerFindFrame(parent, "detailsDisplay");//for issue--Resolved By
<%}%>

if (listDisplay) {
listDisplay.parent.location.href = listDisplay.parent.location.href;
}
else{
contentFrame.getTopWindow().refreshTablePage();
}
if(detailsDisplay){
<%
String []deletedIds = (String[])javaScriptHelperObjects.get("deletedIds");
if(deletedIds != null && deletedIds.length > 0){
for(int i=0; i<deletedIds.length; i++){
%>
getTopWindow().deleteObjectFromTrees("<%=deletedIds[i]%>", false);
<%
}
}
%>
getTopWindow().refreshTrees();
}
</framework:ifExpr>
<framework:ifExpr expr="<%=isAddExistingMode%>">
if(existingIssue!=null && existingIssue!=""){
alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Workspace.AddExistingIssueAlert</emxUtil:i18nScript>" + " " +existingIssue+" ");
}
var listDisplay = getTopWindow().getWindowOpener() ? getTopWindow().getWindowOpener() : (openerFindFrame(getTopWindow(), "listDisplay") ? openerFindFrame(getTopWindow(), "listDisplay").parent : null);
if (listDisplay) {
listDisplay.location.href = listDisplay.location.href;
}
else{
contentFrame.getTopWindow().refreshTablePage();
}
if(getTopWindow().getWindowOpener())
getTopWindow().closeWindow();
</framework:ifExpr>
<framework:ifExpr expr="<%=isCloseMode || isChangeTypeMode%>">
if(!isInFinalState){
alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.CloseIssueUnSuccessfull</emxUtil:i18nScript>");
}
var formViewDisplay = findFrame(parent.window.getWindowOpener(), "formViewDisplay");
if (formViewDisplay) {
formViewDisplay.parent.location.href = formViewDisplay.parent.location.href;
}
else{
contentFrame.getTopWindow().refreshTablePage();
}
if(getTopWindow().getWindowOpener())
getTopWindow().closeWindow();
</framework:ifExpr>
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
