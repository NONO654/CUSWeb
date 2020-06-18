<%--  emxRouteContentSummary.jsp - displys result of search
   Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteContentSummaryNS.jsp.rca 1.10 Wed Oct 22 16:17:56 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>

<%
  Route routeObject = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);

  String languageStr  = request.getHeader("Accept-Language");
  String jsTreeID     = emxGetParameter(request,"jsTreeID");
  String suiteKey     = emxGetParameter(request,"suiteKey");

  String routeId    = emxGetParameter(request,"routeId");
  String sParams     = "jsTreeID="+jsTreeID+"&suiteKey="+suiteKey;
  String nextURL     = "";
  String target      = "";

  // Set the domain object id with rout id
  routeObject.setId(routeId);

  String sPolicy = "";
  String sStates = "";
  String sRotableIds ="";
  String stateValue = "";
  String sNoneValue=ComponentsUtil.i18nStringNow( "emxComponents.AttachmentsDialog.none", sLanguage);
  // build select params
  StringList selListObj = new SelectList();
  selListObj.add(routeObject.SELECT_NAME);
  selListObj.add(routeObject.SELECT_ID);
  selListObj.add(routeObject.SELECT_TYPE);
  selListObj.add(routeObject.SELECT_DESCRIPTION);
  selListObj.add(routeObject.SELECT_POLICY);
  selListObj.add(routeObject.SELECT_CURRENT);
  selListObj.add(routeObject.SELECT_FILE_NAME);

  // build select params for Relationship
  StringList selListRel = new SelectList();
  selListRel.add(routeObject.SELECT_RELATIONSHIP_ID);
  selListRel.addElement(routeObject.SELECT_ROUTE_BASEPOLICY);
  selListRel.addElement(routeObject.SELECT_ROUTE_BASESTATE);

  MapList routableObjsList = new MapList();
  routableObjsList = routeObject.getConnectedObjects(context, selListObj, selListRel, false);

  String sDownloadTip = ComponentsUtil.i18nStringNow("emxComponents.FileDownload.Download",sLanguage);
  String sViewerTip   = ComponentsUtil.i18nStringNow("emxComponents.Common.Viewer",sLanguage);
  int numberOfFiles   = 0;
  StringList fileNames = new StringList();
  String fileName = "";
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
       params = "<%=sParams%>"  />
     <tr>
      <th width="70" nowrap>
        <framework:sortColumnHeader
          title="emxComponents.Common.Name"
          sortKey="<%=routeObject.SELECT_NAME %>"
          sortType="string"/>
      </th>

      <th nowrap="nowrap">
       <emxUtil:i18n localize="i18nId">emxComponents.Common.Actions</emxUtil:i18n>
      </th>

      <th nowrap>
        <framework:sortColumnHeader
          title="emxComponents.Common.Description"
          sortKey="<%=routeObject.SELECT_DESCRIPTION%>"
          sortType="string"/>
      </th>
      <th>
        <emxUtil:i18n localize="i18nId">emxComponents.AttachmentsDialog.StateCondition</emxUtil:i18n>
      </th>
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
<!-- \\XSSOK -->
    <framework:mapListItr mapList="<%=routableObjsList%>" mapName="routableObjsMap">
<%
   fileNames = new StringList();

   try{
     fileNames = (StringList) routableObjsMap.get(routeObject.SELECT_FILE_NAME);
   } catch ( ClassCastException excep) {
     fileName  = (String)routableObjsMap.get(routeObject.SELECT_FILE_NAME);
     if(fileName != null && !"".equals(fileName) && !"null".equals(fileName)){
       fileNames.addElement(fileName);
     }
   }

   boolean isActions = false;

   if(fileNames != null /*&& fileNames.size() == 1*/){
     isActions = true;
   }

   StringBuffer viewerURL    = new StringBuffer(256);

   if(isActions) {
     viewerURL  = new StringBuffer("../components/emxCommonDocumentPreCheckout.jsp?objectId=");
     viewerURL.append(routableObjsMap.get(routeObject.SELECT_ID));
     viewerURL.append("&action=view");
   }

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
   if (("".equals(jsTreeID)) || (jsTreeID == null || ("null".equals(jsTreeID)) )){
     nextURL = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId=" + routableObjsMap.get(routeObject.SELECT_ID);

     //show the alternate menu only if the app is ProgramCentral and the type is Document
     if(appDirectory.equalsIgnoreCase(EnoviaResourceBundle.getProperty(context,"eServiceSuiteProgramCentral.Directory"))  && routableObjsMap.get(routeObject.SELECT_TYPE).equals(routeObject.TYPE_DOCUMENT))
     {
     nextURL += "&treeMenu=" + EnoviaResourceBundle.getProperty(context,"eServiceSuiteProgramCentral.emxTreeAlternateMenuName.type_Document");
   }
     nextURL = "javascript:emxShowModalDialog('" + nextURL + "',800,575)";
   } else{
     nextURL = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?jsTreeID=" + jsTreeID + "&mode=insert&objectId=" + routableObjsMap.get(routeObject.SELECT_ID);

     //show the alternate menu only if the app is ProgramCentral and the type is Document
     if(appDirectory.equalsIgnoreCase(EnoviaResourceBundle.getProperty(context,"eServiceSuiteProgramCentral.Directory"))  && routableObjsMap.get(routeObject.SELECT_TYPE).equals(routeObject.TYPE_DOCUMENT))
     {
     nextURL += "&treeMenu=" + EnoviaResourceBundle.getProperty(context,"eServiceSuiteProgramCentral.emxTreeAlternateMenuName.type_Document");
   }
     //nextURL = "javascript:addChildNodeParams('" + jsTreeID + "', '" + routableObjsMap.get(routeObject.SELECT_ID) + "', 'emxSuiteDirectory=components')";
     target  = " target=\"content\"";
   }
%>
    <tr class='<framework:swap id ="1" />'>
      <td><a href="<%=nextURL%>" <%=target%> class="object"> <%=(String)routableObjsMap.get(routeObject.SELECT_NAME)%>&nbsp;</a></td>

      <td>
<%
   if(isActions) {
%>
      <a href="javascript:callCheckout('<%=routableObjsMap.get(routeObject.SELECT_ID)%>','download')">
      <img border="0" src="../common/images/iconDownLoad.gif" alt="<%=sDownloadTip%>" /></a>&nbsp;
  <%if(fileNames.size() == 1){%>
      <a href="javascript:openGenericWindow('<%=viewerURL.toString()%>')">
      <img border="0" src="../common/images/iconActionView.gif" alt="<%=sViewerTip%>" /></a>
  <%} %>
<%
  }
%>
      &nbsp;</td>
      <td><%=(String)routableObjsMap.get(routeObject.SELECT_DESCRIPTION)%>&nbsp;</td>
      <td><%=i18nNow.getStateI18NString(sPolicy,stateValue, languageStr)%>&nbsp;</td>
    </tr>
    </framework:mapListItr>
<%
    }
%>

</table>
