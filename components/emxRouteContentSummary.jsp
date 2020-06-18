<%--  emxRouteContentSummary.jsp - displys result of search
   Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteContentSummary.jsp.rca 1.33 Wed Oct 22 16:18:26 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxPaginationInclude.inc" %>

<%
  //Determine if we should use printer friendly version
  //
  boolean isPrinterFriendly = false;
  String printerFriendly = emxGetParameter(request, "PrinterFriendly");

  if ((printerFriendly != null)         &&
      (!"null".equals(printerFriendly)) &&
      (!"".equals(printerFriendly)))
  {
    isPrinterFriendly = "true".equals(printerFriendly);
  }
%>
<%
  Route routeObject = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);

  String languageStr = request.getHeader("Accept-Language");
  String jsTreeID    = emxGetParameter(request,"jsTreeID");
  String suiteKey    = emxGetParameter(request,"suiteKey");
  String objectId    = emxGetParameter(request,"objectId");

  StringBuffer sParams = new StringBuffer(64);
  sParams.append("jsTreeID=");
  sParams.append(jsTreeID);
  sParams.append("&suiteKey=");
  sParams.append(suiteKey);
  sParams.append("&objectId=");
  sParams.append(objectId);

  String nextURL    = "";
  String target     = "";
  String isFromTask = emxGetParameter(request,"isFromTask");

  if (isFromTask == null || "null".equals(isFromTask))
  {
    isFromTask = "";
  }

  // Set the domain object id with rout id
  routeObject.setId(objectId);

  String sPolicy = "";
  String sStates = "";
  String sRotableIds ="";
  String stateValue = "";
  String sNoneValue=ComponentsUtil.i18nStringNow( "emxComponents.AttachmentsDialog.none", sLanguage);
  //Below Code is Added for Bug326830
  String sNotFound=ComponentsUtil.i18nStringNow( "emxComponents.Object.NotFound", sLanguage);

  // build select params
  StringList selListObj = new SelectList(6);
  selListObj.add(routeObject.SELECT_NAME);
  selListObj.add(routeObject.SELECT_ID);
  selListObj.add(routeObject.SELECT_TYPE);
  selListObj.add(routeObject.SELECT_DESCRIPTION);
  selListObj.add(routeObject.SELECT_POLICY);
  selListObj.add(routeObject.SELECT_CURRENT);

  // build select params for Relationship
  StringList selListRel = new SelectList(3);
  selListRel.add(routeObject.SELECT_RELATIONSHIP_ID);
  selListRel.addElement(routeObject.SELECT_ROUTE_BASEPOLICY);
  selListRel.addElement(routeObject.SELECT_ROUTE_BASESTATE);

  MapList routableObjsList = new MapList();
  if (emxPage.isNewQuery())
  {
    routableObjsList = routeObject.getConnectedObjects(context,
                                                       selListObj,
                                                       selListRel,
                                                       false);
    emxPage.getTable().setObjects(routableObjsList);
  }
  // Below Code is Added for Bug326830
  int count=routableObjsList.size();
  routableObjsList = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());

//  18decString url = "emxRouteRemoveContentProcess.jsp?deletefromsummary=true";
  String url = "emxRouteRemoveContentProcess.jsp?deletefromsummary=true&routeId="+XSSUtil.encodeForURL(context, objectId) ;
  
  
  // Get a list of Document and its sub type to be used for checking against the attachment's type
  String subtypes = MqlUtil.mqlCommand(context, "print type \"" + DomainConstants.TYPE_DOCUMENT + "\" select derivative dump |");
  StringList documentTypesList = null;
  documentTypesList = FrameworkUtil.split(subtypes, "|");
  documentTypesList.add(0, DomainConstants.TYPE_DOCUMENT);
  boolean bTeam = FrameworkUtil.isSuiteRegistered(context,"featureVersionTeamCentral",false,null,null);
  String relType=DomainObject.RELATIONSHIP_OBJECT_ROUTE;
  String searchTypes = MqlUtil.mqlCommand(context, "print relationship $1 select $2 dump", true, relType, "fromtype");
 
%>

<script language="Javascript" type="text/javascript">

  function updateContent(remedit) {

    var varChecked = "false";
    var objForm = document.ContenForm;
    for (var i=0; i < objForm.elements.length; i++) {
      if (objForm.elements[i].type == "checkbox") {
        if ((objForm.elements[i].name.indexOf('chkItem') > -1) && (objForm.elements[i].checked == true)) {
          varChecked = "true";
         }
      }
    }
    if (varChecked == "false") {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteContentSummary.SelectContent</emxUtil:i18nScript>");
      return;
    } else {
      if(remedit == 'edit') {
        document.ContenForm.action="emxRouteEditContentProcess.jsp";
        document.ContenForm.submit();
        return;
      }
      else if (confirm("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteContentSummary.MsgConfirm</emxUtil:i18nScript>") != 0)  {
        //XSSOK
        document.ContenForm.action="<%=url%>";
        document.ContenForm.submit();
        return;
      }
    }
  }

  function removeSelected() {
    updateContent('remove');
  }

  function editContent() {
    updateContent('edit');
  }
 <%
  if(bTeam)
  {
  	String folderURL = "emxCommonSelectWorkspaceFolderDialogFS.jsp";
 %>
 function uploadExternalFile() {
  //jp char checkin fix
 showCheckinDialog('../components/emxCommonDocumentPreCheckin.jsp?showDescription=required&JPOName=emxRouteDocumentBase&showFolder=required&folderURL=<%=folderURL%>&parentRelName=relationship_VaultedDocuments&objectAction=create&routeContentId=<%=XSSUtil.encodeForURL(context, objectId)%>&parentId=RouteWizard','','');
 }
<%
}
%>
  function editBlockState(){
    // function to call blockstate dialog page
	//Below code is Added for Bug326830
  var length = <%=count%>;
if(length!=0){
emxShowModalDialog('emxRouteContentBlockedStateDialogFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, objectId)%>&jsTreeID=<%=XSSUtil.encodeForURL(context, jsTreeID)%>&suiteKey=<%=XSSUtil.encodeForURL(context, suiteKey)%>',575, 575);
              }
			  else { 
				  alert('<%=XSSUtil.encodeForJavaScript(context, sNotFound)%>');
				  }
//End of code Added for Bugs326830
  }



  //Function to select all the check boxes
  function doCheck() {
    var objForm = document.ContenForm;
    var chkList = objForm.chkList;
    var reChkName = /chkItem/gi;
    for (var i=0; i < objForm.elements.length; i++)
    if (objForm.elements[i].name.indexOf('chkItem') > -1){
      objForm.elements[i].checked = chkList.checked;
    }
  }

  //Function to uncheck all the check box values.
  function updateCheck() {
    var objForm     = document.ContenForm;
    var chkList     = objForm.chkList;
    chkList.checked = false;
  }


  function AddContent() {
    emxShowModalDialog("../common/emxFullSearch.jsp?field=TYPES=<%=XSSUtil.encodeForURL(context,searchTypes)%>&table=APPRouteContentSearchResults&objectId=<%=XSSUtil.encodeForURL(context,objectId)%>&submitURL=../components/emxRouteAddContentProcess.jsp?fromPage=addFromTaskSummary",750,500);
    
  }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form method="post" name="ContenForm" >
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
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
       params = "<%=XSSUtil.encodeForHTML(context, sParams.toString())%>"  />
     <tr>
       <%
       if (!isPrinterFriendly && !isFromTask.equals("true")) {
       %>
        <th width="5%" style="text-align:center">
          <input type="checkbox" name="chkList" id="chkList" onclick="doCheck()" />
      </th>
      <%
      }
      %>
      <th width="70" nowrap>
        <framework:sortColumnHeader
          title="emxComponents.Common.Name"
          sortKey="<%=routeObject.SELECT_NAME %>"
          sortType="string"/>
      </th>
      <th nowrap>
        <framework:sortColumnHeader
          title="emxComponents.Common.Description"
          sortKey="<%=routeObject.SELECT_DESCRIPTION%>"
          sortType="string"/>
      </th>
      <!--th>
        <emxUtil:i18n localize="i18nId">emxComponents.AttachmentsDialog.StateCondition</emxUtil:i18n>
      </th-->
      <!--5jan start to fix bug#276127 -->
      <th nowrap>
        <framework:sortColumnHeader
          title="emxComponents.AttachmentsDialog.StateCondition"
          sortKey="<%=routeObject.SELECT_ROUTE_BASESTATE%>"
          sortType="string"/>
      </th>
      <!--5jan end to fix bug#276127-->

      </th>

    </tr>


<%
    if (routableObjsList.size() == 0) {
%>
    <tr>
      <td align="center" colspan="13" class="error">
        <emxUtil:i18n localize="i18nId">emxComponents.AddContent.NoContents</emxUtil:i18n>
      </td>
    </tr>
<%
    } else {

%>
    <!-- XSSOK -->
    <framework:mapListItr mapList="<%=routableObjsList%>" mapName="routableObjsMap">
<%
   sPolicy = (String) routableObjsMap.get(routeObject.SELECT_POLICY);
   sStates = (String) routableObjsMap.get(routeObject.SELECT_ROUTE_BASESTATE);

   if(!(sStates.indexOf('[') <0 ) ) {
     sStates = sStates.substring(sStates.indexOf('[')+1,sStates.indexOf(']'));
   }

   if(sRotableIds.equals("")) {
     sRotableIds = (String)routableObjsMap.get(routeObject.SELECT_RELATIONSHIP_ID);
   } else {
     sRotableIds += "|" + (String)routableObjsMap.get(routeObject.SELECT_RELATIONSHIP_ID);
   }
   stateValue = (String)routableObjsMap.get(routeObject.SELECT_ROUTE_BASESTATE);
   if (!"Ad Hoc".equals(stateValue)){
    stateValue = FrameworkUtil.lookupStateName(context,sPolicy,stateValue);
   } else {
     stateValue = sNoneValue;
   }
   
   String docType = (String)routableObjsMap.get(routeObject.SELECT_TYPE);   
   boolean docOrSubType = false;
   if(documentTypesList.contains(docType)){      
      docOrSubType = true;
   }
   
   
   
   if (("".equals(jsTreeID)) || (jsTreeID == null || ("null".equals(jsTreeID)) )){
     nextURL = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId=" + routableObjsMap.get(routeObject.SELECT_ID);

     //show the alternate menu only if the app is ProgramCentral and the type is Document or its subtype
     if(appDirectory.equalsIgnoreCase(FrameworkProperties.getProperty(context,"eServiceSuiteProgramCentral.Directory"))  && docOrSubType)
     {
       nextURL += "&treeMenu=" + EnoviaResourceBundle.getProperty(context,"eServiceSuiteProgramCentral.emxTreeAlternateMenuName.type_Document");
     }

     if(isFromTask.equals("true"))
     {
       nextURL = "javascript:emxShowModalDialog('" + nextURL + "',800,575)";
     }
     else
     {
       target  = " target=\"content\"";
     }
   } else{
     nextURL = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?jsTreeID=" + jsTreeID + "&mode=insert&objectId=" + routableObjsMap.get(routeObject.SELECT_ID);

     //show the alternate menu only if the app is ProgramCentral and the type is Document or its subtype
     if(appDirectory.equalsIgnoreCase(FrameworkProperties.getProperty(context,"eServiceSuiteProgramCentral.Directory"))  && docOrSubType)
     {
        nextURL += "&treeMenu=" + EnoviaResourceBundle.getProperty(context,"eServiceSuiteProgramCentral.emxTreeAlternateMenuName.type_Document");
     }
     //nextURL = "javascript:addChildNodeParams('" + jsTreeID + "', '" + routableObjsMap.get(routeObject.SELECT_ID) + "', 'emxSuiteDirectory=components')";
     target  = " target=\"content\"";
   }


%>
    <tr class='<framework:swap id ="1" />'>
         <%
       if (!isPrinterFriendly) {
       if(!isFromTask.equals("true"))
       {
       %>
        <td style="text-align:center">
        <input type="checkbox" name="chkItem" id="chkItem" value ="<xss:encodeForHTMLAttribute><%=routableObjsMap.get(routeObject.SELECT_RELATIONSHIP_ID)%></xss:encodeForHTMLAttribute>" onclick="updateCheck()" /></td>
       <%
       }
       %>
       <!-- //XSSOK -->
      <td><a href="<%=nextURL%>" <%=target%> class="object"> <xss:encodeForHTML><%=(String)routableObjsMap.get(routeObject.SELECT_NAME)%></xss:encodeForHTML>&nbsp;</a></td>
      <%
      } else {
      %>
      <td><xss:encodeForHTML><%=(String)routableObjsMap.get(routeObject.SELECT_NAME)%></xss:encodeForHTML>&nbsp;</td>
      <%
      }
     %>
      <td><xss:encodeForHTML><%=(String)routableObjsMap.get(routeObject.SELECT_DESCRIPTION)%></xss:encodeForHTML>&nbsp;</td>
      <td><%=XSSUtil.encodeForHTML(context, i18nNow.getStateI18NString(sPolicy,stateValue, languageStr))%>&nbsp;</td>
    </tr>
    </framework:mapListItr>
<%
    }
%>

</table>

<input type="hidden" name="routableIds" value="<xss:encodeForHTMLAttribute><%=sRotableIds%></xss:encodeForHTMLAttribute>"/>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
