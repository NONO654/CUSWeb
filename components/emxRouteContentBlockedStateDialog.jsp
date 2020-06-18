<%--  displays result of search
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
  String languageStr   = request.getHeader("Accept-Language");
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String objectId      = emxGetParameter(request,"objectId");
  String sParams = "jsTreeID="+jsTreeID+"&suiteKey="+suiteKey+"&objectId="+objectId;

  Route routeObject = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
  // Set the domain object id with rout id
  routeObject.setId(objectId);

  String sCurState = "";
  String sType ="";
  String sName ="";
  String sRev ="";
  String sVer ="";
  String sRotableIds ="";
  String sPolicy = "";
  String sStates = "";
  String sRouteBaseState = "";
  String sNoneValue=ComponentsUtil.i18nStringNow( "emxComponents.AttachmentsDialog.none", sLanguage);
  String sAttrRouteCompletionAction = PropertyUtil.getSchemaProperty(context, "attribute_RouteCompletionAction" );

%>

<script language="Javascript" type="text/javascript">

  function closeWindow() {
	  getTopWindow().closeWindow();
    return;
  }


  function submitForm() {
    document.ContenForm.action="emxRouteContentBlockedStateProcess.jsp";
    document.ContenForm.submit();
    return;
  }


</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form method="post" onSubmit="javascript:submitForm(); return false" name="ContenForm" target="_parent">
  <input type="hidden" name="objectId" value="<%=XSSUtil.encodeForHTML(context, objectId)%>"/>

<%
    // build select params
    StringList selListObj = new SelectList();
    selListObj.add(routeObject.SELECT_TYPE);
    selListObj.add(routeObject.SELECT_NAME);
    selListObj.add(routeObject.SELECT_REVISION);
    selListObj.add(routeObject.SELECT_ID);
    selListObj.add(routeObject.SELECT_POLICY);
    selListObj.add(routeObject.SELECT_STATES);
    selListObj.add(routeObject.SELECT_CURRENT);
    selListObj.add(routeObject.SELECT_OWNER);

    // build select params for Relationship
    StringList selListRel = new SelectList();
    selListRel.add(routeObject.SELECT_RELATIONSHIP_ID);
    selListRel.add(routeObject.SELECT_ROUTE_BASESTATE);


    MapList routableObjsList =
                         routeObject.expandSelect(context,
                                                        routeObject.RELATIONSHIP_OBJECT_ROUTE,
                                                        "*",
                                                        selListObj,
                                                        selListRel,
                                                        true,
                                                        false,
                                                        (short)1,
                                                        null,
                                                        null,
                                                        null,
                                                        false);
%>
 <script language="Javascript">
  	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIList");
 </script>
 <table class="list" id="UITable">

    <framework:sortInit
       defaultSortKey="<%=routeObject.SELECT_NAME%>"
       defaultSortType="string"
       mapList="<%= routableObjsList %>"
       resourceBundle="emxComponentsStringResource"
       ascendText="emxComponents.Common.SortAscending"
       descendText="emxComponents.Common.SortDescending"
       params = "<%=XSSUtil.encodeForHTML(context, sParams)%>"  />
     <tr>

      <th width="70" nowrap>
        <framework:sortColumnHeader
          title="emxComponents.Common.Name"
          sortKey="<%=routeObject.SELECT_NAME %>"
          sortType="string"/>
      </th>
      <th width="5%" nowrap>
        <framework:sortColumnHeader
          title="emxComponents.AttachmentsDialog.Ver"
          sortKey="<%=routeObject.SELECT_REVISION%>"
          sortType="string"/>
      </th>
      <th width="5%" nowrap>
        <framework:sortColumnHeader
          title="emxComponents.AttachmentsDialog.Rev"
          sortKey="<%=routeObject.SELECT_REVISION%>"
          sortType="string"/>
      </th>
      <th>
        <emxUtil:i18n localize="i18nId">emxComponents.AttachmentsDialog.StateCondition</emxUtil:i18n>
      </th>
    </tr>


<%
    if (routableObjsList.size() == 0) {
%>
    <tr>
      <td align="center" colspan="13" class="error">
        <emxUtil:i18n localize="i18nId">emxComponents.AddContent.NoContentes</emxUtil:i18n>
      </td>
    </tr>
<%
    } else {

%>
    <framework:mapListItr mapList="<%=routableObjsList%>" mapName="routableObjsMap">
<%
   sCurState = (String) routableObjsMap.get(routeObject.SELECT_CURRENT);
   sType = (String)routableObjsMap.get(routeObject.SELECT_TYPE);
   sPolicy = (String) routableObjsMap.get(routeObject.SELECT_POLICY);
   sStates = routableObjsMap.get(routeObject.SELECT_STATES).toString();
   sRouteBaseState = (String)routableObjsMap.get(routeObject.SELECT_ROUTE_BASESTATE);
   if(sRotableIds.equals("")) {
     sRotableIds = (String)routableObjsMap.get(routeObject.SELECT_RELATIONSHIP_ID);
   } else {
     sRotableIds += "|" + (String)routableObjsMap.get(routeObject.SELECT_RELATIONSHIP_ID);
   }
   if(!(sStates.indexOf('[') <0 ) ) {
     sStates = sStates.substring(sStates.indexOf('[')+1,sStates.indexOf(']'));
   }

    sName = (String) routableObjsMap.get(routeObject.SELECT_NAME);
    sVer = (String)routableObjsMap.get(routeObject.SELECT_REVISION);
    sRev ="";

   String routeCompletionActionValue = routeObject.getAttributeValue(context, sAttrRouteCompletionAction);
   boolean isAutoPromote = false;
   if("Promote Connected Object".equals(routeCompletionActionValue)){
     isAutoPromote = true;
   }


%>
    <tr class='<framework:swap id ="1" />'>
      <td><input type="hidden" name="<%=(String)routableObjsMap.get(routeObject.SELECT_RELATIONSHIP_ID)+"State"%>" value="<xss:encodeForHTMLAttribute><%=sRouteBaseState%></xss:encodeForHTMLAttribute>" /><%=sName%>&nbsp;</td>
      <td><xss:encodeForHTML><%=sRev%></xss:encodeForHTML>&nbsp;</td>
      <td><xss:encodeForHTML><%=sVer%></xss:encodeForHTML>&nbsp;</td>
      <td>
        <%
        String sSymbolicPolicyName = FrameworkUtil.getAliasForAdmin(context, "policy", sPolicy, true);
        %>
		<!-- //XSSOK -->
      <%=populateCombo(context, session, sStates, isAutoPromote, (String)routableObjsMap.get(routeObject.SELECT_ID), (String)routableObjsMap.get(routeObject.SELECT_RELATIONSHIP_ID), (String)routableObjsMap.get(routeObject.SELECT_OWNER), sCurState, sPolicy, sRouteBaseState, sNoneValue, languageStr)%>
      </td>
    </tr>
    </framework:mapListItr>
<%
    }
%>

</table>

<input type="hidden" name="routableIds" value="<xss:encodeForHTMLAttribute><%=sRotableIds%></xss:encodeForHTMLAttribute>"/>
</form>

<%!
    static public String populateCombo(matrix.db.Context context, HttpSession session,String sStates,boolean isAutoPromote, String routableObjId, String sRelationID, String routeOwner, String curState, String sPolicy, String sStateValue, String sNoneValue,String sLangStr) {
      String sReturn    = "";

      try {
        String sSymbolicPolicyName = XSSUtil.encodeForHTMLAttribute(context,FrameworkUtil.getAliasForAdmin(context, "policy", sPolicy, true)) ;

        boolean canAdd = false;
        StringTokenizer sTok =  new StringTokenizer(sStates, ",");
        int numTokens = sTok.countTokens();
        int curtok = 1;
        BusinessObject routableObj = new BusinessObject(routableObjId);
        boolean isOwner = routeOwner.equals(context.getUser());
    	if(FrameworkUtil.hasAccess(context, routableObj, "promote")||isOwner){
        if(sTok.hasMoreTokens()) {
          sReturn = "<select name=\""+ sRelationID +"\" ><option value=\""+sSymbolicPolicyName+"#Ad Hoc\" >" +sNoneValue + "</option>";
          try{
            while(sTok.hasMoreTokens()) {
              boolean canPromote = false;

              if(curtok == numTokens){
                break;
              }

              curtok++;
              String sStateName =  sTok.nextToken().trim();
	
	              if(curState.equals(sStateName)){
	                  canAdd = true;
	              }
	              
	              
              if(FrameworkUtil.hasAccessForStateName( context, routableObj, sStateName, "Promote")){
                canPromote = true;
              }

              String sSymbolicStateName = FrameworkUtil.reverseLookupStateName(context, sPolicy, sStateName);
	              if(canAdd && canPromote){
	            	  if (sStateValue.equals(sSymbolicStateName)){
                  sReturn += "<option value=\""+sSymbolicPolicyName+"#"+ XSSUtil.encodeForHTMLAttribute(context,sSymbolicStateName)+"\" selected >" + i18nNow.getStateI18NString(sPolicy,sStateName,sLangStr) +"</option>";
	                   } else {
                  sReturn += "<option value=\""+sSymbolicPolicyName+"#"+XSSUtil.encodeForHTMLAttribute(context,sSymbolicStateName)+"\" >" + i18nNow.getStateI18NString(sPolicy,sStateName,sLangStr) +"</option>";
                }
	              } else if(canAdd && sStateValue.equals(sSymbolicStateName) && isOwner){
	            	  sReturn += "<option value=\""+sSymbolicPolicyName+"#"+ XSSUtil.encodeForHTMLAttribute(context,sSymbolicStateName)+"\" selected >" + i18nNow.getStateI18NString(sPolicy,sStateName,sLangStr) +"</option>";
	              }
	              
              }
            }
          catch(MatrixException e){}
          sReturn += "</select>";
          return sReturn;
        }
    	} else{
    		String sStateValueDisplayName = FrameworkUtil.lookupStateName(context, sPolicy, sStateValue);
    		if(UIUtil.isNullOrEmpty(sStateValueDisplayName)){
    			sReturn += "<input type=\"hidden\" name=\""+ XSSUtil.encodeForHTMLAttribute(context,sRelationID) +"\" value=\"\"  />" + i18nNow.getStateI18NString(sPolicy,sNoneValue,sLangStr);    			
    		}
    		else{
				sReturn += "<input type=\"hidden\" name=\""+ XSSUtil.encodeForHTMLAttribute(context,sRelationID) +"\" value=\"\"  />" + i18nNow.getStateI18NString(sPolicy,sStateValueDisplayName,sLangStr);
    		}			
			return sReturn;
    	}
        sReturn = "<input type=\"hidden\" name=\""+ XSSUtil.encodeForHTMLAttribute(context,sRelationID) +"\" value=\"\"  />" + XSSUtil.encodeForHTML(context, sNoneValue);
      } catch(Exception exp) {
        sReturn = exp.getMessage();
      }
      return sReturn;
    }

%>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
