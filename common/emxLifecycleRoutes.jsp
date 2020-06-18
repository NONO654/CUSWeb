<%--  emxEngrLifecycleRoutes.jsp   - The main page for View Routes. The routes for this state are displayed.

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxLifecycleRoutes.jsp.rca 1.16 Wed Oct 22 15:48:10 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<%
  String appDirectory = (String)EnoviaResourceBundle.getProperty(context, "eServiceSuiteFramework.Directory");
  if(appDirectory == null || "".equals(appDirectory) || "null".equals(appDirectory))
  {
    appDirectory = "common";
  }

  DomainObject dom = (DomainObject)DomainObject.newInstance(context,
                    DomainConstants.TYPE_ROUTE);

  //
  // get the Business Id the from and to States names.
  //
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String sBusId = emxGetParameter(request, "objectId");
  String suiteKey = emxGetParameter(request, "suiteKey");
  String sFromStateName = emxGetParameter(request, "fromState");
  String sToStateName = emxGetParameter(request, "toState");
  String sIsInCurrentState = emxGetParameter(request, "isInCurrentState");
  String languageStr = request.getHeader("Accept-Language");
  String sAdHoc = FrameworkUtil.i18nStringNow("emxFramework.Lifecycle.AdHocRouteName", request.getHeader("Accept-Language"));

  boolean isPrinterFriendly = false;
  String printerFriendly = emxGetParameter(request, "PrinterFriendly");
  if (printerFriendly != null && "true".equals(printerFriendly) ) {
    isPrinterFriendly = true;
  }

  try {
    //Starts Database transaction
    ContextUtil.startTransaction(context,false);


    // Before displaying any data to the user, first get all the routes based
    // of the from and to states and save them in a hashtable.
    // ==Get the name of the policy that governs this business object.==

    BusinessObject busObject = new BusinessObject(sBusId);
    busObject.open(context);

    String sStatePolicyName = busObject.getPolicy(context).getName();
    String sDisplayState = " : " + UINavigatorUtil.getStateI18NString(sStatePolicyName,sFromStateName,languageStr);


    String sCurrentPolicyName = "";
    Policy currentPolicy = null;
    try {
      currentPolicy = busObject.getPolicy(context);
      currentPolicy.open(context);
      sCurrentPolicyName = currentPolicy.getName();
      currentPolicy.close(context);
    }
    catch (Exception e) {
      currentPolicy = null;
      sCurrentPolicyName = "";
    }

    // Expand the current bus object and get the routes connected to it.
    // First get the lookup names for routes and relationships.
    
    Pattern relPattern        = new Pattern("");
	String relWorkflowContent = PropertyUtil.getSchemaProperty(context, "relationship_WorkflowContent");
	String relObjectRoute = PropertyUtil.getSchemaProperty(context, "relationship_ObjectRoute");
	relPattern.addPattern(relWorkflowContent);
	relPattern.addPattern(relObjectRoute);
	
	Pattern typePattern        = new Pattern("");
	String typeWorkflow = PropertyUtil.getSchemaProperty(context, "type_Workflow");
	String typeRoute = PropertyUtil.getSchemaProperty(context, "type_Route");
	typePattern.addPattern(typeWorkflow);
	typePattern.addPattern(typeRoute);
    
    
    String sRouteType = PropertyUtil.getSchemaProperty(context, "type_Route");
    String sRouteBasePolicyAttr = PropertyUtil.getSchemaProperty(context, "attribute_RouteBasePolicy");
    String sRouteBaseStateAttr = PropertyUtil.getSchemaProperty(context, "attribute_RouteBaseState");

    // Define 3 variables: the route id, and 2 vars for which state of which policy that this route is based of.
    String sRouteId = null;
    String sObjectRouteBasePolicy = null;
    String sObjectRouteBaseState = null;
    String absolutePolicyName = null;
    String absoluteStateName = null;
    String objType = null;

    // Get the routes connected to this object.
    ExpansionWithSelect routeSelect = null;

    // build select params
    SelectList selectRouteStmts = new SelectList();
    selectRouteStmts.addType();
    SelectList selectObjectRouteRelStmts = new SelectList();
    selectRouteStmts.addId();
    selectObjectRouteRelStmts.addId();
    selectObjectRouteRelStmts.addAttribute(sRouteBasePolicyAttr);
    selectObjectRouteRelStmts.addAttribute(sRouteBaseStateAttr);

    routeSelect = busObject.expandSelect(context, relPattern.getPattern(), typePattern.getPattern(), selectRouteStmts,
                                                selectObjectRouteRelStmts, true, true, (short)1);

    RelationshipWithSelectItr relObjectRouteItr = new RelationshipWithSelectItr(routeSelect.getRelationships());

    Hashtable objectRouteRelAttributes = new Hashtable();
    Hashtable routeBusObjAttributes = new Hashtable();

    Vector vRouteIds = new Vector();

    // Loop thru routes and put the value of policy+statenames in a hashtable as keys. Values will be true.
    // This will identify which states has routes needed for promotion.
    int routeCounter = 0;
    while (relObjectRouteItr.next()) {
      // if the relationship is "Object Route" then get the routes.      
        objectRouteRelAttributes =  relObjectRouteItr.obj().getRelationshipData();
        sObjectRouteBasePolicy = (String)objectRouteRelAttributes.get("attribute[" + sRouteBasePolicyAttr + "]");
        sObjectRouteBaseState = (String)objectRouteRelAttributes.get("attribute[" + sRouteBaseStateAttr + "]");
        routeBusObjAttributes =  relObjectRouteItr.obj().getTargetData();
        sRouteId = (String)routeBusObjAttributes.get("id");
        objType = (String)routeBusObjAttributes.get("type");

        if ((sObjectRouteBaseState!=null && (!sObjectRouteBaseState.equalsIgnoreCase("null"))&& sObjectRouteBaseState.equals(sAdHoc)) || objType.equals(typeWorkflow)) {
          absolutePolicyName = sObjectRouteBasePolicy;
          absoluteStateName = sObjectRouteBaseState;
        }
        else {
          absolutePolicyName = PropertyUtil.getSchemaProperty(context, sObjectRouteBasePolicy);
          absoluteStateName = FrameworkUtil.lookupStateName(context, absolutePolicyName, sObjectRouteBaseState);
        }

        if (absolutePolicyName.length() > 0 && !absolutePolicyName.equalsIgnoreCase(sCurrentPolicyName) ){
          continue;
        }

        // The code below separates the "Ad hoc" routes from state based routes.
        // Also if this state is not current state do not display Ad Hoc Routes.
        if (absoluteStateName!= null && absoluteStateName.equals(sFromStateName)) {
          vRouteIds.insertElementAt(sRouteId, routeCounter);
          routeCounter++;
        }
        else if (sIsInCurrentState.equals("true") && sAdHoc.equals(absoluteStateName)) {
          vRouteIds.addElement(sRouteId);
          routeCounter++;
        }
    } // end of iterating thru routes

    busObject.close(context);

  %>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<form name="mud">
<%-- This is for header at top of page --%>

<table border="0" cellspacing="0" cellpadding="0" width="100%">
  <tr>
    <td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" /></td>
  </tr>
</table>

<table border="0" width="100%" cellspacing="2" cellpadding="4">
<tr>
<td class="pageHeader" width="99%"> <emxUtil:i18n localize="i18nId">emxFramework.Lifecycle.Routes</emxUtil:i18n><%=sDisplayState%></td><!-- XSSOK -->
<td width="1%"><img src="images/utilSpacer.gif" width="1" height="28" alt="" /></td>
</tr>
</table>

    <table width="100%" border="0" cellspacing="2" cellpadding="3" class="list">
      <tr>
         <th align="left"><emxUtil:i18n localize="i18nId">emxFramework.Common.Name</emxUtil:i18n></th>
         <th align="left"><emxUtil:i18n localize="i18nId">emxFramework.Lifecycle.Status</emxUtil:i18n></th>
         <th align="left"><emxUtil:i18n localize="i18nId">emxFramework.Common.Description</emxUtil:i18n></th>
      </tr>
  <%
    routeCounter = 0;
    String sRowStyleClass = "even";
    Enumeration enumRouteIds = vRouteIds.elements();
    StringList strList = new StringList(5);
    strList.addElement(DomainObject.SELECT_NAME);
    strList.addElement(DomainObject.SELECT_DESCRIPTION);
    strList.addElement(DomainObject.SELECT_TYPE);
    strList.addElement("attribute["+DomainObject.ATTRIBUTE_ROUTE_STATUS+"]");
    strList.addElement(DomainObject.SELECT_CURRENT);


    while (enumRouteIds.hasMoreElements()) {
	  //Added for bug 339378
      StringBuffer nextURL = new StringBuffer(100);
	  //End of bug 339378
      sRouteId = (String) enumRouteIds.nextElement();
      routeCounter++;
      dom.setId(sRouteId);
      Map map = dom.getInfo(context,strList);
      String sRouteName = (String) map.get(DomainObject.SELECT_NAME);
      String sRtType = (String) map.get(DomainObject.SELECT_TYPE);
      String sRouteDesc = (String) map.get(DomainObject.SELECT_DESCRIPTION);
      String sRouteStatus = (String) map.get("attribute["+DomainObject.ATTRIBUTE_ROUTE_STATUS+"]");
	  if (sRouteStatus == null || "".equals(sRouteStatus))
	  {
			sRouteStatus = (String) map.get(DomainObject.SELECT_CURRENT);
	  }
      //sRouteStatus = sRouteStatus == null ? "" : (String) map.get(DomainObject.SELECT_CURRENT);

      sRowStyleClass = (routeCounter%2 == 0) ? "even" : "odd";
      
	  //added for BUG 305200
	  String displayString="";
	  displayString = i18nNow.getTypeI18NString(sRouteType, languageStr);

	  StringBuffer sDisplay = new StringBuffer(100);
      sDisplay.append(displayString);
      sDisplay.append("-");
      sDisplay.append(sRouteName);

      nextURL = new StringBuffer(100);
      nextURL.append("../common/emxTree.jsp?objectId=");
      nextURL.append(sRouteId);
      nextURL.append("&emxSuiteDirectory=");
      nextURL.append(appDirectory);
      
      if (!isPrinterFriendly){
%>
      <tr class="<%=sRowStyleClass%>">
        <td align="left">
          <a href="javascript:emxShowModalDialog('<%=nextURL.toString()%>',700,600,false)"><img border="0" src="../common/images/iconSmallRoute.png" align="middle" /></a>&nbsp;
          <a href="javascript:emxShowModalDialog('<%=nextURL.toString()%>',700,600,false)"><%=sDisplay.toString()%></a>
<%
      } else {
%>
      <tr>
        <td align="left"><%=sDisplay.toString()%>
<%
      }
%>
        &nbsp;</td>
        <td align="left"><%=i18nNow.getRangeI18NString(DomainObject.ATTRIBUTE_ROUTE_STATUS,sRouteStatus,languageStr)%></td>
        <td align="left"><%=sRouteDesc%></td>
      </tr>
  <%

      ContextUtil.commitTransaction(context);
    }
  %>
    </table>
</form>
<%
  }
  catch(Exception e) {
    ContextUtil.abortTransaction(context);
    //Throw the exception again to stop any further processing
    throw e;
  }
%>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
