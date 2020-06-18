<%--  emxTeamSubFoldersView.jsp   -  Displays the SubFolders of the given Folder
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamSubFoldersView.jsp.rca 1.19 Wed Oct 22 16:06:10 2008 przemek Experimental przemek $
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxPaginationInclude.inc" %>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "eServiceUtil.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
  String jsTreeID            = emxGetParameter(request,"jsTreeID");
  String suiteKey            = emxGetParameter(request,"suiteKey");
  String strObjectId         = emxGetParameter(request, "objectId");
  String strTypeProjectVault = "type_ProjectVault";
  String strProjectVaultType = Framework.getPropertyValue( session, strTypeProjectVault );
  String strSubVaultsRel     = Framework.getPropertyValue( session, "relationship_SubVaults");
  if (strObjectId == null){
    strObjectId = "";
  }
  DomainObject domainObj=DomainObject.newInstance(context,strObjectId);

 String sParams = "jsTreeID="+XSSUtil.encodeForHTML(context, jsTreeID)+"&objectId="+XSSUtil.encodeForHTML(context, strObjectId)+"&suiteKey="+XSSUtil.encodeForHTML(context, suiteKey);
%>

<script language="javascript">

  function doCheck() {
    var objForm = document.forms[0];
    var chkList = objForm.chkList;
    var reChkName = /chkItem/gi;
    for (var i=0; i < objForm.elements.length; i++)
    if (objForm.elements[i].name.indexOf('chkItem') > -1){
      objForm.elements[i].checked = chkList.checked;
    }
  }

  function updateCheck() {
    var objForm = document.forms[0];
    var chkList = objForm.chkList;
    chkList.checked = false;
  }


 function showEditDialogPopup() {

   emxShowModalDialog('emxTeamCreateSubFoldersWorkspaceDialogFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, strObjectId)%>&callPage=workspacewizard', 575, 575);
  }

  function load(param) {

  parent.frames['treeDisplay'].document.location.href="emxTeamFoldersView.jsp?objectId="+param;
  }

  function showDeleteDialogPopup() {
      var varChecked = "false";
      var objForm = document.forms[0];
      objForm.folderIds.value="";
      for (var i=0; i < objForm.elements.length; i++)
        if (objForm.elements[i].type == "checkbox") {
          if ((objForm.elements[i].name.indexOf('chkItem') > -1) && (objForm.elements[i].checked == true)) {
            varChecked = "true";
            objForm.folderIds.value=objForm.folderIds.value+objForm.elements[i].value+";";
          }
        }

      if (varChecked == "false") {
        alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.FolderDelete.SelectSubfolder</emxUtil:i18nScript>");
        return;
      } else {
        if (confirm("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.FolderDelete.WizSubfolderMsg</emxUtil:i18nScript>") != 0)  {
          objForm.action="emxTeamDeleteFolders.jsp?page=WizSubfolder&folderIds="+objForm.folderIds.value;
          objForm.submit();
          return;
        }
      }
  }

  </script>

  <%@include file = "../emxUICommonHeaderEndInclude.inc" %>


<%


MapList subFolderMapList =  new  MapList();


if (emxPage.isNewQuery()) {

    Pattern relSubVaultPattern = new Pattern(strSubVaultsRel);
    Pattern typeCategoryPattern = new Pattern(strProjectVaultType);

 //build object-select statements
    StringList selectTypeStmts = new StringList();
    selectTypeStmts.add(domainObj.SELECT_TYPE);
    selectTypeStmts.add(domainObj.SELECT_NAME);
    selectTypeStmts.add(domainObj.SELECT_ID);
    selectTypeStmts.add(domainObj.SELECT_DESCRIPTION);

    subFolderMapList = domainObj.getRelatedObjects(context,
                                                  relSubVaultPattern.getPattern(),  //String relPattern
                                                  typeCategoryPattern.getPattern(), //String typePattern
                                                  selectTypeStmts,                  //StringList objectSelects,
                                                  null,                             //StringList relationshipSelects,
                                                  false,                             //boolean getTo,
                                                  true,                             //boolean getFrom,
                                                  (short)1,                         //short recurseToLevel,
                                                  "",                               //String objectWhere,
                                                  "",                               //String relationshipWhere,
                                                  null,                             //Pattern includeType,
                                                  null,                             //Pattern includeRelationship,
                                                  null);                            //Map includeMap




    // pass the resultList to the following method
    emxPage.getTable().setObjects(subFolderMapList);
    // pass in the selectables to the following method
    emxPage.getTable().setSelects(selectTypeStmts);
 }

  // this Maplist is the one which is used to make the table.
  subFolderMapList = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());
%>


  <form name="subFolderSummary" method="post">
    <input type="hidden" name="folderIds" value=""/>
    <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>"/>




 <script language="Javascript">
  	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIList");
 </script>
 <table class="list" id="UITable">

     <framework:sortInit
       defaultSortKey="<%=domainObj.SELECT_NAME%>"
       defaultSortType="string"
       mapList="<%=subFolderMapList%>"
       resourceBundle="emxTeamCentralStringResource"
       ascendText="emxTeamCentral.Common.SortAscending"
       descendText="emxTeamCentral.Common.SortDescending"
       params = "<%=sParams%>"  />
       <tr>
         <th width="5%" style="text-align:center">
           <input type="checkbox" name="chkList" id="chkList" onclick="doCheck()"/>
         </th>
         <th nowrap>
           <framework:sortColumnHeader
             title="emxTeamCentral.Common.Name"
             sortKey="<%=domainObj.SELECT_NAME %>"
             sortType="string"/>
         </th>

<%
     if (subFolderMapList != null && subFolderMapList.size() == 0) {
%>
		<tr>
			<td align="center" colspan="13" class="error"><emxUtil:i18n localize="i18nId">emxTeamCentral.DocSummary.NoSubCategories</emxUtil:i18n></td>
        </tr>
<%
      }else{
%>
<!-- \\XSSOK -->
<framework:mapListItr mapList="<%=subFolderMapList%>" mapName="subFolderMap">
 <%
    String objectNameStr   = (String) subFolderMap.get(domainObj.SELECT_NAME);
    String objectIdStr     = (String) subFolderMap.get(domainObj.SELECT_ID);
 %>
 <tr class='<framework:swap id ="1" />'>
    <td width="5%"  style="text-align:center" ><input type="checkbox" name="chkItem" id="chkItem" value="<%=objectIdStr%>" onclick="updateCheck()"/></td>
    <td><img src="images/iconSmallFolder_new.png" name="imgFolder" id="imgFolder" />&nbsp;<%=objectNameStr%></td>
 </tr>
    </framework:mapListItr>
<%
  }
%>
 </table>



</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>


