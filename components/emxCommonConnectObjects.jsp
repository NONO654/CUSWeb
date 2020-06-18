<%--  emxCommonConnectObjects.jsp  -

   Performs the action of connecting the objects by the given relationship

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonConnectObjects.jsp.rca 1.22 Wed Oct 22 16:18:09 2008 przemek Experimental przemek $";
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "emxSearchInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="matrix.db.JPO"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.common.Change"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUITreeUtil.js"></script>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<%!
  private static final String REQ_MAP = "reqMap";
  private static final String REQ_TABLE_MAP = "reqTableMap";
  private static final String COMPONENT_FRAMEWORK_BUNDLE = "emxComponentsStringResource";
  private static final String ALERT_MSG = "emxComponents.Search.Error.24";
%>

<%
String failedObjectId="";
String issueObjectName="";
try
{
  String strTableRowIds[]  = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(request.getParameterValues("emxTableRowId"));
  if((strTableRowIds==null)||(strTableRowIds.length==0)){
%>
	<script language="javascript" >
		if(parent.listFoot && parent.listFoot.clickEventCounter)
			parent.listFoot.clickEventCounter=0;
	</script>
<%       
	i18nNow i18nInstance = new i18nNow();
	String strLang = request.getHeader("Accept-Language");
	String strRetMsg = i18nInstance.GetString(COMPONENT_FRAMEWORK_BUNDLE, acceptLanguage,ALERT_MSG);
	
	throw new FrameworkException(strRetMsg);
}else{

  String timeStamp = emxGetParameter(request, "timeStamp");
  HashMap requestMap = new HashMap();
  String uiType = emxGetParameter(request, "uiType");
  String oslcSelectUI = emxGetParameter(request, "oslcSelectUI");
  if(UIUtil.isNotNullAndNotEmpty(oslcSelectUI) && "true".equalsIgnoreCase(oslcSelectUI)){
	  oslcSelectUI = "true";
  }
  else{
	  oslcSelectUI = "false";
  }
  
  if("structureBrowser".equalsIgnoreCase(uiType)){
  	requestMap = (HashMap)indentedTableBean.getRequestMap(timeStamp);
  }else if("table".equalsIgnoreCase(uiType)){
  	requestMap = (HashMap)tableBean.getRequestMap(timeStamp);
  } else{
	  Enumeration eNumParameters = emxGetParameterNames(request);
	    while( eNumParameters.hasMoreElements() ) {
	        String parmName = (String)eNumParameters.nextElement();
	        String parmValue = (String)emxGetParameter(request,parmName);
	        if(UIUtil.isNullOrEmpty(parmValue))
	            continue;
	        if(parmName.equals("objectId")){
	        	HashMap requestValuesMap = new HashMap();
	        	String [] objectId = new String[1];
	        	objectId[0] = parmValue;
	        	requestValuesMap.put(parmName, objectId);
	        	requestMap.put("RequestValuesMap", requestValuesMap);
	        }
	        requestMap.put(parmName, parmValue);
	    }
  }  
  
//Retrieve the map which contains all the values of multi-values parameters like "emxTableRowId"
  HashMap requestValuesMap = (HashMap)requestMap.get("RequestValuesMap");
   String strObjectId = (String)requestMap.get(Search.REQ_PARAM_OBJECT_ID);
   String strSuiteKey = (String)requestMap.get(Search.REQ_PARAM_SUITE_KEY);

   String strMidBusTypeSymb = (String)requestMap.get(Search.REQ_PARAM_MID_BUS_TYPE);
   String strMidBusType = strMidBusTypeSymb != null ? PropertyUtil.getSchemaProperty(context,strMidBusTypeSymb) : null;

   String strSrcDestRelNameSymb = (String)requestMap.get(Search.REQ_PARAM_SRC_DEST_REL_NAME);
   String strSrcDestRelName = strSrcDestRelNameSymb == null ? null : PropertyUtil.getSchemaProperty(context,strSrcDestRelNameSymb);

   String strSrcMidRelNameSymb = (String)requestMap.get(Search.REQ_PARAM_SRC_MID_REL_NAME);
   String strSrcMidRelName = strSrcMidRelNameSymb == null ? null : PropertyUtil.getSchemaProperty(context,strSrcMidRelNameSymb);

   String strMidDestRelNameSymb = (String)requestMap.get(Search.REQ_PARAM_MID_DEST_REL_NAME);
   String strMidDestRelName = strMidDestRelNameSymb == null ? null : PropertyUtil.getSchemaProperty(context,strMidDestRelNameSymb);
   String strIsTo = (String)requestMap.get(Search.REQ_PARAM_IS_TO);
   String strAddProgram = (String)requestMap.get(Search.REQ_PARAM_ADD_PROGRAM);
   String strAddFunction = (String)requestMap.get(Search.REQ_PARAM_ADD_FUNCTION);
   String strDoConnect = (String)requestMap.get(Search.REQ_PARAM_DO_CONNECT);

   String[] strChangeObjID = (String[])requestValuesMap.get("objectId");
   String[] relId = (String[])requestValuesMap.get("relId");
   
   String[] strOldAssigneeObjID = (String[])requestValuesMap.get("arrObjIds1");
   String[] arrRelIds1 = (String[])requestValuesMap.get("arrRelIds1");

   String strLoadPage = (String)requestMap.get(Search.REQ_PARAM_LOAD_PAGE);
   String strLoadPageMode = (String) requestMap.get ("loadPageMode");
   String strRefreshURL = emxGetParameter(request, "refreshURL");
   String frameName = emxGetParameter(request, "frameName");
   Search search = new Search();

   try {
    ContextUtil.startTransaction(context, true);
    if((strDoConnect != null) && (strDoConnect.equalsIgnoreCase("true")) ) {
      Map programMap = new HashMap();
      Map reqMap = new HashMap();
      Enumeration enumParamNames = request.getParameterNames();
      while(enumParamNames.hasMoreElements())
      {
        String paramName = (String) enumParamNames.nextElement();
        String paramValues[] = request.getParameterValues(paramName);
        if (paramValues != null ) {
          reqMap.put(paramName, paramValues);
        }
      }
      programMap.put(REQ_MAP, reqMap);
      programMap.put(REQ_TABLE_MAP, requestValuesMap);
      String[] methodargs =JPO.packArgs(programMap);
	  FrameworkUtil.validateMethodBeforeInvoke(context, strAddProgram, strAddFunction, "Program");
      JPO.invoke(context, strAddProgram, null, strAddFunction, methodargs, String.class);
    } else if( (strMidBusType == null) || (strMidBusType.equals("")) ) {

		//added for Affected Items : ENC V6R2009-1 Start
		String splitDelegateAssignment = (String)requestMap.get("splitDelegateAssignment");
		if(splitDelegateAssignment!=null && !splitDelegateAssignment.equals(""))  {
			Map reqMapAffectedItems = new HashMap();
			reqMapAffectedItems.put("strChangeObjID",strChangeObjID);
			reqMapAffectedItems.put("strNewAssigneeID",strTableRowIds);
			reqMapAffectedItems.put("arrAffectedItemRelID",arrRelIds1);
			try {
				Change changeObject = new Change();
				changeObject.splitDelegateAssignees(context, reqMapAffectedItems);
			}catch(Exception e){
		}
		}
		//added for Affected Items : ENC V6R2009-1 End

		//added for Assignees : ENC X-3 Start
		 String assgn = (String)requestMap.get("ECAssign");

		 if(assgn!=null && !assgn.equals("")) {
         	Map programMap1 = new HashMap();
		  	Map reqMap1 = new HashMap();
			reqMap1.put("strChangeObjID",strChangeObjID);
			reqMap1.put("strNewAssigneeID",strTableRowIds);
			reqMap1.put("strOldAssigneeObjID",strOldAssigneeObjID);
			reqMap1.put("arrRelIds1",arrRelIds1);
			reqMap1.put("relId",relId);
			Enumeration enumParamNames1 = request.getParameterNames();
  		    while(enumParamNames1.hasMoreElements()) {
				String paramName1 = (String) enumParamNames1.nextElement();
				String paramValues1[] = request.getParameterValues(paramName1);
				if (paramValues1 != null )  {
					  //reqMap1.put(paramName1, paramValues1);		  
				}
			}
			try {
				Change changeObject = new Change();
				changeObject.delegateAssignees(context, reqMap1);
	        } catch(Exception e) {}
		}
		//added for Assignees : ENC X-3 End
		

      for (int i=0; i<strTableRowIds.length; i++) {
      	if ( strIsTo.equalsIgnoreCase("true") ) {
			// added for the bog no 309028
			failedObjectId=strTableRowIds[i];
			String strSelectRelId = "from["+strSrcDestRelName+"].id";
			StringList slBusSelect = new StringList();
     	 	slBusSelect.add(DomainObject.SELECT_TYPE);
     	 	slBusSelect.add(DomainObject.SELECT_NAME);
     	 	slBusSelect.add(strSelectRelId);
			DomainObject domObjTC = DomainObject.newInstance(context,strObjectId);
			Map mapBusObjectInfo = domObjTC.getInfo(context, slBusSelect);
			String strRelId = (String) mapBusObjectInfo.get(strSelectRelId);
			issueObjectName = (String) mapBusObjectInfo.get(DomainObject.SELECT_NAME);
			// end the bug 309028
			search.connectObjects( context , strObjectId , strTableRowIds[i] , strSrcDestRelName);
		} else  {
			// Add for Assignee START
			// Checking the Value of Parameter passed from the Command. If Some Value is Passed then into the if clause 
            // In case of Parameter being passed no Connections made here
			// Checking the Value of Parameter passed from the Command. If No Value is Passed(Normal Add Existing) then into the else clause. 
            //Connections made here.
			if((assgn!=null && !assgn.equals(""))||(splitDelegateAssignment!=null && !splitDelegateAssignment.equals(""))) { 
			} else{				//
				search.connectObjects( context ,  strTableRowIds[i] , strObjectId ,strSrcDestRelName);
			}
		}
						// Add for Assignee END
	}
  } else {
      for (int i=0; i<strTableRowIds.length; i++) {
          String midBusOId = search.createObject(context, strMidBusType);
          if ( strIsTo.equalsIgnoreCase("true") ) {
              search.connectObjects( context , strObjectId , midBusOId , strSrcMidRelName);
              search.connectObjects( context , midBusOId , strTableRowIds[i] , strMidDestRelName);
          } else {
              search.connectObjects( context , strTableRowIds[i] , midBusOId , strSrcMidRelName);
              search.connectObjects( context , midBusOId ,  strObjectId , strMidDestRelName);
            }
        }
    }
    ContextUtil.commitTransaction(context);
  }  catch (Exception excp) {
    ContextUtil.abortTransaction(context);
%>
      <script>
        var tableFooterFrame = findFrame(parent, "listFoot");
        if(tableFooterFrame)
        	tableFooterFrame.setTableSubmitAction(true);
      </script>
    <%
    throw excp;
  }
  
  if(strRefreshURL==null || strRefreshURL.isEmpty())
  {
%>
<script>
	var contentFrame = openerFindFrame(getTopWindow(), "content");
	var frameNameToRefresh = '<%=XSSUtil.encodeForJavaScript(context, emxGetParameter(request, "frameNameToRefresh"))%>';
	var varOslcSelectUI = <%=oslcSelectUI%>;
	<%if(frameName != null && !frameName.isEmpty()){%>
		var refreshFrameName = openerFindFrame (getTopWindow(), '<%=XSSUtil.encodeForURL(context, frameName)%>');
		refreshFrameName.location.href = refreshFrameName.location.href;
	<%}else{%>
//Added for Affected Items : Start
  var objWin = getTopWindow().getWindowOpener();

  if(getTopWindow().getWindowOpener() != null && getTopWindow().getWindowOpener().name == "treeContent") {
     objWin = getTopWindow().getWindowOpener();
     objWin.document.location.href = objWin.document.location.href;
	 window.closeWindow();
  } else if (getTopWindow().window.getWindowOpener() != null) {
//Added for Affected Items : End
	if(getTopWindow().window.getWindowOpener().reloadTableEditPage != null && getTopWindow().window.getWindowOpener().reloadTableEditPage != 'undefined') {
		getTopWindow().window.getWindowOpener().reloadTableEditPage();
    } else {
		var frameToRefresh;
		if(true != varOslcSelectUI && getTopWindow().location.href.indexOf("emxNavigator.jsp")==-1) {
			frameToRefresh = findFrame(getTopWindow().getWindowOpener().getTopWindow(), 'detailsDisplay');
		} else {
			frameToRefresh = findFrame(getTopWindow(), 'detailsDisplay');
		}
    
		if("" != frameNameToRefresh && 'null' != frameNameToRefresh && frameToRefresh.location.href.indexOf('emxPortal.jsp') > -1 && null != findFrame(frameToRefresh, frameNameToRefresh)) {
       		// We shall not refresh the entire portal but only the data inside the portal channel
			frameToRefresh = findFrame(frameToRefresh, frameNameToRefresh);
        }
	    	    	
		frameToRefresh.location.href = frameToRefresh.location.href;
	}
  }else if(true == varOslcSelectUI){
	  emxUICore.findFrame(top, 'detailsDisplay').location = emxUICore.findFrame(top, 'detailsDisplay').location;
  }else  if (contentFrame) {

    contentFrame.location.reload();
  }
	<%}%>
<% 
	if("false".equals(oslcSelectUI)){
		if (strLoadPage != null && strLoadPage.trim().length() > 0) {
	%>

 		window.location.href='<%=XSSUtil.encodeForURL(context, strLoadPage)+"?mode="+XSSUtil.encodeForURL(context, strLoadPageMode)+"&parentObjId="+XSSUtil.encodeForURL(context, strObjectId)%>';
	<%  } else { %>
	if(getTopWindow().location.href.indexOf("emxNavigator.jsp")==-1) {
		getTopWindow().closeWindow();
	}
	<%  }

  }
}
  else
  {
	  response.sendRedirect( strRefreshURL );
  }
%>

</script>
<%
}
} // End of try
catch(Exception ex) {
	boolean clientTaskMessagesExists = false;
	clientTaskMessagesExists = MqlNoticeUtil.checkIfClientTaskMessageExists(context);
	if(!clientTaskMessagesExists){
		String message=EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource",context.getLocale(),"emxComponents.Common.Issue.ConnectCOObjectFailed");
	message=UIExpression.substituteValues(context, message, failedObjectId);
	message=FrameworkUtil.findAndReplace(message,"<businessObject>", issueObjectName);  
    session.putValue("error.message", message);
	}
%>
	<script language="javascript">
	if(parent.setSubmitURLRequestCompleted) {
		parent.setSubmitURLRequestCompleted();
	}
</script>
<%
} // End of catch
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
