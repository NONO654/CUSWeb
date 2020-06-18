<%--  emxRouteActionRequiredDialog.jsp   -   Display Summary Of People
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteActionRequiredDialog.jsp.rca 1.16 Wed Oct 22 16:18:07 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
  String sAttParallelNodeProcessionRule = Framework.getPropertyValue(session, "attribute_ParallelNodeProcessionRule");
  Route routeObj = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
  Map paramMap = (Map) session.getAttribute("strParams");
  String sRadioValue = "";
  Iterator keyItr = paramMap.keySet().iterator();
  while (keyItr.hasNext())
  {
    String name = (String) keyItr.next();
    String value = (String) paramMap.get(name);
    request.setAttribute(name, value);
  }

  String languageStr    = request.getHeader("Accept-Language");
  String sourcePage     = emxGetParameter(request,"sourcePage");
  if ((sourcePage == null) || sourcePage.equals("null")){
    sourcePage = "";
  }
  String routeOrder     = emxGetParameter(request, "routeOrder");
  String routeInstructions  = emxGetParameter(request, "routeInstructions");
  String routeTime      = emxGetParameter(request,"routeTime");
  String personName     = emxGetParameter(request,"personName");
  String routeId        = emxGetParameter(request,"routeId");
  String projectId      = emxGetParameter(request,"objectId");
  String routeNodes     = emxGetParameter(request, "routeNode");
  String templateId         = emxGetParameter(request,"templateId");
  String templateName       = emxGetParameter(request,"templateName");
  String assigneeType       = emxGetParameter(request,"assigneeType");
  String portalMode         = emxGetParameter(request,"portalMode");
  
  String routeAction = emxGetParameter(request, "routeAction");
  String assignURL   = "emxRouteAssignTaskDialogFS.jsp?selectedAction=";
  if ((routeAction == null) || routeAction.equals("null"))
    assignURL += "false";
  else
    assignURL += "true";
  
  assignURL += "&portalMode=" + XSSUtil.encodeForURL(context, portalMode);    

  String rowClass       = "even";
  String sSameRow       = "";
  boolean bRadioDisplay   = false;

  StringTokenizer sTokOrder = new StringTokenizer(routeOrder,"~");
  StringTokenizer sTokName  = new StringTokenizer(personName,"~");
  StringTokenizer sTokAction= new StringTokenizer(routeAction,"~");
  StringTokenizer sTokRouteNodes = new StringTokenizer(routeNodes,"~");
  StringTokenizer sTokAssigneeType = new StringTokenizer(assigneeType,"~");

%>

<script language="JavaScript">

  function closeWindow() {
    parent.window.getWindowOpener().parent.location = parent.window.getWindowOpener().parent.location.href;
    window.closeWindow();
    return;
  }

  function submitForm() {
    document.actionRequired.submit();
    return;
  }

  function goBack() {
<%
    if (sourcePage.equals("EditAllTasks")) {
%>
      document.actionRequired.action="emxEditAllTasksDialogFS.jsp";
<%
    } else {
%>
	  //XSSOK
      document.actionRequired.action="<%=assignURL%>";
<%
    }
%>
    document.actionRequired.submit();
    return;
  }

</script>



<form method="post" name="actionRequired" action="emxRouteActionRequiredProcess.jsp" target="_parent" >
<input type="hidden" name="sourcePage" value="<xss:encodeForHTMLAttribute><%=sourcePage%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="routeId" value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="routeInstructions" value="<xss:encodeForHTMLAttribute><%=routeInstructions%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="routeTime" value="<xss:encodeForHTMLAttribute><%=routeTime%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="routeOrder" value="<xss:encodeForHTMLAttribute><%=routeOrder%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="personName" value="<xss:encodeForHTMLAttribute><%=personName%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="routeAction" value="<xss:encodeForHTMLAttribute><%=routeAction%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=templateId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="templateName" value="<xss:encodeForHTMLAttribute><%=templateName%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="routeNodes" value="<xss:encodeForHTMLAttribute><%=routeNodes%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="assigneeType" value="<xss:encodeForHTMLAttribute><%=assigneeType%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>" />

  <table border="0" cellpadding="3" cellspacing="2" width="100%">
    <tr>
      <th><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.Order</emxUtil:i18n>&nbsp;</th>
       <th><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n>&nbsp;</th>
       <th><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.Action</emxUtil:i18n></th>
      <th><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.ActionRequired</emxUtil:i18n></th>
    </tr>

<%


  String strArray[]  = null;
  TreeMap sortMap  = new TreeMap();
  Vector sortVector = null;
  //HashTable ht = new HashTable();

   while(sTokOrder.hasMoreTokens()) {
     strArray = new String[5];
     strArray[0] =  sTokOrder.nextToken("~");
     strArray[1] =  sTokName.nextToken("~");
     strArray[2] =  sTokAction.nextToken("~");
     strArray[3] =  sTokRouteNodes.nextToken("~");
     strArray[4] =  sTokAssigneeType.nextToken("~");

     if (sortMap.containsKey(strArray[0])) {
       sortVector = (Vector)sortMap.get(strArray[0]);
       sortVector.addElement(strArray);
     }
     else
     {
       sortVector = new Vector();
       sortVector.addElement(strArray);
       sortMap.put(strArray[0], sortVector);
     }

  }


    String sRadioButtonNames = "";
    String sRouteNodeNames = "";

    String sRouteNodeIds = "";
    String sRouteNodeSecs = "";

    String sHiddenParams = "";

  for(int orderCount=0;orderCount<20; orderCount++) {

    rowClass = rowClass.equals("even") ? "odd" : "even";
    Integer inter = new Integer(orderCount);
    String sOrder = inter.toString();
    if(sortMap.containsKey(sOrder)) {
      Vector vect = (Vector) sortMap.get(sOrder);
      int iSize = vect.size();
      for(int iDisplay=0;iDisplay < vect.size(); iDisplay++) {
        String sTest[] = (String[])vect.elementAt(iDisplay);
        DomainRelationship routeNode = null;
        if(sTest[3] != null){
           routeNode = DomainRelationship.newInstance(context,sTest[3]);
           sRadioValue = routeNode.getAttributeValue(context, sAttParallelNodeProcessionRule);
         }

        String sAssigType = sTest[4];
%>
	<!-- //XSSOK -->
    <tr class="<%= rowClass %>">
      <td><%=sTest[0]%>&nbsp;</td>
<%
    if(!sAssigType.equals("Person"))
    {
%>
      <td><%=XSSUtil.encodeForHTML(context, i18nNow.getAdminI18NString(sAssigType,sTest[1],languageStr))%></td>
<%
    }
    else
    {
%>
     <td><%=sTest[1]%></td>
<%
    }
%>
      <td><%=XSSUtil.encodeForHTML(context, i18nNow.getRangeI18NString( routeObj.ATTRIBUTE_ROUTE_ACTION, sTest[2], languageStr))%></td>
      <td>
<%
        if(iSize > 1 ) {
          iSize=0;
      
        if(sRadioValue == null  || sRadioValue.equals("") ) {
          sRadioValue ="All";
        }
        
%>
         <table border="0">
           <tr>
           	 <!-- //XSSOK -->
             <td><input type="radio" <%=sRadioValue.equals("Any")?"checked":""%> value="Any" name="radioAction<%=sTest[0]%>" id="radioAction<%=sTest[0]%>" /></td>
             <td><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.Any</emxUtil:i18n></td>
             <!-- //XSSOK -->
             <td><input type="radio" <%=sRadioValue.equals("All")?"checked":""%> value="All" name="radioAction<%=sTest[0]%>" id="radioAction<%=sTest[0]%>" /></td>
             <td><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.All</emxUtil:i18n></td>
           </tr>
         </table>
<%
          // Store the radio button names.
          if(sRadioButtonNames.equals("")) {
            sRadioButtonNames = "radioAction"+sTest[0];
             sRouteNodeSecs += "RouteNodeAction"+sTest[0];
          } else {
            sRadioButtonNames += "|" + "radioAction"+sTest[0];
            sRouteNodeSecs += "|" + "RouteNodeAction"+sTest[0];
          }

        }
        sHiddenParams += "<input type=\"hidden\" name='RouteNodeAction"+sTest[0]+"' value='"+sTest[3] +"' />";
%>
      &nbsp;</td>
    </tr>
<%
      }
    }
  }
%>
  </table>
  <input type="hidden" name="radioNames" value="<xss:encodeForHTMLAttribute><%=sRadioButtonNames%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="routeNodeSecs" value="<xss:encodeForHTMLAttribute><%=sRouteNodeSecs%></xss:encodeForHTMLAttribute>"/>
  <xss:encodeForHTML><%=sHiddenParams%></xss:encodeForHTML>

</form>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
