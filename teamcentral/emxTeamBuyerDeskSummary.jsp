<%--  emxTeamBuyerDeskSummary.jsp   -   Display the list of Buyer desk that can be connected to Workspace
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamBuyerDeskSummary.jsp.rca 1.15 Wed Oct 22 16:06:09 2008 przemek Experimental przemek $
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "emxTeamUtil.inc"%>
<%@include file = "eServiceUtil.inc"%>
<%@include file = "../emxPaginationInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
  String formName = emxGetParameter(request,"formName");
  String txtCtrl  = emxGetParameter(request,"txtCtrl");
  String txtId    = emxGetParameter(request,"txtId");
  

  String fieldDisplay    = emxGetParameter(request,"fieldDisp");
 


  DomainObject buyerDeskConnectedObj     = DomainObject.newInstance(context);
  BusinessObject busPerson = JSPUtil.getPerson(context, session);
  BusinessObject busOrganization = JSPUtil.getOrganization(context,  session, busPerson );
  String         organizationId = busOrganization.getObjectId();


  String sParams = "formName="+formName+"&txtCtrl="+txtCtrl+"&txtId="+txtId;

  MapList buyerDeskMapList =  null;


  if (emxPage.isNewQuery()) {

  String typeBuyerDesk = Framework.getPropertyValue(session, "type_BuyerDesk");
  String relWorkSpaceBuyerDesk  = Framework.getPropertyValue( session, "relationship_WorkspaceBuyerDesk");
  String relAssignedToBuyersDesk = Framework.getPropertyValue( session, "relationship_AssignedToBuyersDesk");
  String sWhereExp = "(!(to["+ relWorkSpaceBuyerDesk +"].id!~~\"\"))";

  matrix.util.Pattern filterRelPattern = null;
  String relPattern = relAssignedToBuyersDesk;
  StringList selectRelStmts = new StringList();
  StringList selectTypeStmts = new StringList();
  buyerDeskConnectedObj.setId(organizationId);
  // build select params
  selectTypeStmts.add(buyerDeskConnectedObj.SELECT_ID);
  selectTypeStmts.add(buyerDeskConnectedObj.SELECT_NAME);
  selectTypeStmts.add(buyerDeskConnectedObj.SELECT_DESCRIPTION);
  selectTypeStmts.add(buyerDeskConnectedObj.SELECT_OWNER);
  selectTypeStmts.add(buyerDeskConnectedObj.SELECT_CURRENT);
  selectTypeStmts.add(buyerDeskConnectedObj.SELECT_POLICY);

  filterRelPattern  = new matrix.util.Pattern(relAssignedToBuyersDesk);
  /*expandSelect(context,
                java.lang.String relationshipPattern,
                java.lang.String typePattern,
                matrix.util.StringList objectSelects,
                matrix.util.StringList relationshipSelects,
                boolean getTo, boolean getFrom,
                short recurseToLevel,
                java.lang.String objectWhere,
                java.lang.String relationshipWhere,
                com.matrixone.framework.beans.Pattern includeType,
                com.matrixone.framework.beans.Pattern includeRelationship,
                java.util.Map includeMap,
                MapList cachedList, boolean
                useCache)
  */
  boolean flag = false;
  try {
  ContextUtil.pushContext(context, null, null, null);
  flag = true;
  buyerDeskMapList =  buyerDeskConnectedObj.expandSelect(context,
                                                      relPattern ,
                                                      typeBuyerDesk,
                                                      selectTypeStmts,
                                                      selectRelStmts,
                                                      true,
                                                      false,
                                                      (short)0,
                                                      sWhereExp,
                                                      null,
                                                      null,
                                                      filterRelPattern,
                                                      null,
                                                      null,
                                                      false);

  // pass the resultList to the following method
    emxPage.getTable().setObjects(buyerDeskMapList);
    // pass in the selectables to the following method
    emxPage.getTable().setSelects(selectTypeStmts);
  }catch (Exception e) {}
  finally {
    if(flag){
      ContextUtil.popContext(context);
    }  
  }
}

  // this Maplist is the one which is used to make the table.
  buyerDeskMapList = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());
  


%>

 <script language="javascript" >
  function submitForm() {
    var checkedFlag = "false";
    var objForm = document.buyerdeskform;
    for (var i=0; i < objForm.elements.length; i++) {
      if (objForm.elements[i].type == "radio") {
        if ((objForm.elements[i].name.indexOf('radItem') > -1) && (objForm.elements[i].checked == true)) {
          checkedFlag = "true";
          var checkedValue = objForm.elements[i].value;
          var args = checkedValue.split("~");
  /*10-7-0-0 Conversion Start*/
          parent.window.getWindowOpener().document.forms['<%=XSSUtil.encodeForJavaScript(context,formName)%>'].<%=XSSUtil.encodeForJavaScript(context,txtId)%>.value=args[0];
          parent.window.getWindowOpener().document.forms['<%=XSSUtil.encodeForJavaScript(context,formName)%>'].<%=XSSUtil.encodeForJavaScript(context,txtCtrl)%>.value=args[1];
          //parent.window.getWindowOpener().document.forms['<%=formName%>'].<%=fieldDisplay%>.value=args[1];
            
         break;
        }
      }
    }
  /*10-7-0-0 Conversion End*/
    if (checkedFlag == "false") {
      alert("<emxUtil:i18nScript  localize="i18nId">emxTeamCentral.BuyerDeskSummary.SelectOneFolder</emxUtil:i18nScript>");
    } else {
      parent.window.closeWindow();
    }
    return;
  }

  function closeWindow() {
    parent.window.closeWindow();
    return;
  }
  </script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="buyerdeskform" method="post" >
<table border="0" cellpadding="3" cellspacing="2" width="100%" class="list">

  <framework:sortInit
     defaultSortKey="<%=buyerDeskConnectedObj.SELECT_NAME%>"
     defaultSortType="string"
     mapList="<%=buyerDeskMapList%>"
     resourceBundle="emxTeamCentralStringResource"
     ascendText="emxTeamCentral.Common.SortAscending"
     descendText="emxTeamCentral.Common.SortDescending"
     params = "<%=sParams%>"/>
  <tr>
    <th width="5%" style="text-align:center">&nbsp;</th>
    <th nowrap>
      <framework:sortColumnHeader
        title="emxTeamCentral.Common.Name"
        sortKey="<%=buyerDeskConnectedObj.SELECT_NAME %>"
        sortType="string"
        anchorClass="sortMenuItem"/>
    </th>

    <th nowrap>
      <framework:sortColumnHeader
        title="emxTeamCentral.Common.Description"
        sortKey="<%=buyerDeskConnectedObj.SELECT_DESCRIPTION%>"
        sortType="string"
        anchorClass="sortMenuItem"/>
    </th>

    <th nowrap>
      <framework:sortColumnHeader
        title="emxTeamCentral.BuyerDeskSummary.State"
        sortKey="<%=buyerDeskConnectedObj.SELECT_CURRENT%>"
        sortType="string"
        anchorClass="sortMenuItem"/>
    </th>
  </tr>

<%
    if(buyerDeskMapList.size() > 0)  {
%>
<framework:mapListItr mapList="<%=buyerDeskMapList%>" mapName="buyerDeskMap">
  <tr class='<framework:swap id ="1" />'>
    <td style="text-align:center">
     <input type="radio" name="radItem" id="radItem"
      value ="<%=buyerDeskMap.get(buyerDeskConnectedObj.SELECT_ID)%>~<%=buyerDeskMap.get(buyerDeskConnectedObj.SELECT_NAME)%>" >
    </td>
    <td><%=buyerDeskMap.get(buyerDeskConnectedObj.SELECT_NAME)%>&nbsp;</td>
    <td><%=buyerDeskMap.get(buyerDeskConnectedObj.SELECT_DESCRIPTION)%>&nbsp;</td>
    <td><%
            String projectPolicy = (String)buyerDeskMap.get(DomainObject.SELECT_POLICY);
            String i18NBuyerDeskState  = i18nNow.getStateI18NString(projectPolicy, buyerDeskMap.get(buyerDeskConnectedObj.SELECT_CURRENT).toString(), sLanguage);
			
        %>
        <%=i18NBuyerDeskState%>
        &nbsp;</td>
  </tr>
</framework:mapListItr>
<%

  } else {
%>
 <tr class="odd">
    <td class="noresult" colspan="4" ><emxUtil:i18n localize="i18nId">emxTeamCentral.BuyerDeskSummary.NoBuyerDesksFound</emxUtil:i18n></td>
  </tr>
<%
  }
%>
</table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
