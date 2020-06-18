<%--  emxTeamPreDefinedFolderDialog.jsp   -   Display PreDefined Folders
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamPreDefinedFolderDialog.jsp.rca 1.21 Wed Oct 22 16:06:33 2008 przemek Experimental przemek $
--%>

<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@ include file = "emxTeamProfileUtil.inc"%>
<%@ include file = "emxTeamUtil.inc"%>
<%@ include file = "../emxPaginationInclude.inc" %>
<%@ include file = "../emxJSValidation.inc" %>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>

<%
  DomainObject templateObj      = DomainObject.newInstance(context);
  MapList templateMapList       = new MapList();

  String projectId              = emxGetParameter(request, "objectId");
  String strRelProjectVaults    = Framework.getPropertyValue(session, "relationship_ProjectVaults");
  String strTypeProjectVault    = Framework.getPropertyValue(session, "type_ProjectVault");
  BusinessObject boProject      = new BusinessObject(projectId);

  Hashtable hashCategoriesTable = new Hashtable();
  Enumeration categoriesEnum    = null;
  boolean isSelected            = false;

  String sParams                = "";
  boolean bFolderListEmpty      = false;
    // Take the Categories and its Descriptions from a Properties File
    String catList = JSPUtil.getApplicationProperty(context,application, "emxTeamCentral.DefaultCategories");
  if (emxPage.isNewQuery()) {
    StringTokenizer catToken = new StringTokenizer(catList, ";");
    String cat = "";
    String catName = "";
    String catDesc = "";
    while (catToken.hasMoreTokens())
    {
      cat     = catToken.nextToken();
      catName = i18nNow.getI18nString("emxTeamCentral.AddCategoriesDialog."+cat,"emxTeamCentralStringResource",sLanguage);
      catDesc = i18nNow.getI18nString("emxTeamCentral.AddCategoriesDialog."+cat+"Desc","emxTeamCentralStringResource",sLanguage);
      hashCategoriesTable.put(catName, catDesc);
    }
    Pattern relPattern  = new Pattern(strRelProjectVaults);
    Pattern typePattern = new Pattern(strTypeProjectVault);
    SelectList typeselectList = new SelectList();
    typeselectList.addId();
    typeselectList.addName();
    typeselectList.addDescription();

    boProject.open(context);
    ExpansionWithSelect expandWSelectProject = boProject.expandSelect(context,relPattern.getPattern(),typePattern.getPattern(),
                                               typeselectList,new StringList(),false, true, (short)1);
    boProject.close(context);

    RelationshipWithSelectItr relWSelectProjectVaultItr = new RelationshipWithSelectItr(expandWSelectProject.getRelationships());

    while(relWSelectProjectVaultItr.next()) {
      Hashtable vaultHashTable    = relWSelectProjectVaultItr.obj().getTargetData();
      String strVaultName         = (String)vaultHashTable.get("name");
      String strVaultDescription  = (String)vaultHashTable.get("description");

      if(hashCategoriesTable.containsKey(strVaultName)) {
        hashCategoriesTable.remove(strVaultName);
      }
    }

    templateObj.setId(projectId);


    if ( hashCategoriesTable != null ){
      categoriesEnum = hashCategoriesTable.keys();
    }
    String strFolderName="";
%>

<%
    bFolderListEmpty = true;
      // Getting all the Folderds in the Which is connected to the project
    while( categoriesEnum.hasMoreElements()){
      bFolderListEmpty = false;
      String strCategoryName = (String)categoriesEnum.nextElement();
      String strCategoryDescription  = (String)hashCategoriesTable.get(strCategoryName);

      Hashtable hashCategoriesTableFinal = new Hashtable();
      hashCategoriesTableFinal.put(templateObj.SELECT_NAME, strCategoryName);
      hashCategoriesTableFinal.put(templateObj.SELECT_DESCRIPTION, strCategoryDescription);

      templateMapList.add(hashCategoriesTableFinal);
    }

    sParams = "objectId="+XSSUtil.encodeForHTML(context, projectId);
%>
<%

  // pass the resultList to the following method
  emxPage.getTable().setObjects(templateMapList);
  // pass in the selectables to the following method
  emxPage.getTable().setSelects(new StringList());
}

templateMapList = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());
%>

<script language="JavaScript">

  function submitForm() {

      var checkedFlag = "false";
      var chkbxFlag = "false";
      // force to select at least one folder
      for (var i=0; i < document.CreateProject.elements.length; i++) {
        if (document.CreateProject.elements[i].type == "radio") {
          chkbxFlag = "true";
          if ((document.CreateProject.elements[i].name.indexOf('chkItem1') > -1) && (document.CreateProject.elements[i].checked)) {
            checkedFlag = "true";
            checkedvalue = document.CreateProject.elements[i].value;
            var checkedNameDes = checkedvalue.split("~");
            parent.window.getWindowOpener().parent.frames[1].document.forms['createDialog'].folderName.value=checkedNameDes[0];
            parent.window.getWindowOpener().parent.frames[1].document.forms['createDialog'].folderDescription.value=checkedNameDes[1];
            break;
          }
        }
      }

      if ((checkedFlag == "false") && (chkbxFlag == "true")) {
        alert("<emxUtil:i18nScript  localize="i18nId">emxTeamCentral.PreDefinedDialog.SelectOneFolder</emxUtil:i18nScript>");
        return;
      } else {
        parent.window.closeWindow();
      }

  }

  function closeWindow() {
    parent.window.closeWindow();
    return;
  }

</script>



<%@include file = "../emxUICommonHeaderEndInclude.inc"%>



<form name="CreateProject" method="post" action="" target="_parent">

 <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%= projectId %></xss:encodeForHTMLAttribute>" />

 <script language="Javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
 </script>

  <table class="list">

  <framework:sortInit
     defaultSortKey="<%=templateObj.SELECT_NAME%>"
     defaultSortType="string"
     mapList="<%=templateMapList%>"
     resourceBundle="emxTeamCentralStringResource"
     ascendText="emxTeamCentral.Common.SortAscending"
     descendText="emxTeamCentral.Common.SortDescending"
     params = "<%=sParams%>"  />
   <tr>
    <th>&nbsp;</th>
    <th nowrap>
      <framework:sortColumnHeader
        title="emxTeamCentral.Common.Name"
        sortKey="<%=templateObj.SELECT_NAME %>"
        sortType="string"/>
    </th>

    <th nowrap>
      <framework:sortColumnHeader
        title="emxTeamCentral.Common.Description"
        sortKey="<%=templateObj.SELECT_DESCRIPTION%>"
        sortType="string"/>
    </th>
  </tr>

<%
    if (bFolderListEmpty==true) {
%>
    <tr>
       <td align="center" colspan="13" class="error">
        	<emxUtil:i18n localize="i18nId">emxTeamCentral.FolderDelete.NoTopicsFound</emxUtil:i18n></td>
      </tr>
<%
    }
%>
 <!-- \\XSSOK -->
  <framework:mapListItr mapList="<%=templateMapList%>" mapName="templateMap">
  <tr class='<framework:swap id ="1" />'>
<%
    String strCategoryName = (String)templateMap.get(templateObj.SELECT_NAME);
    String strCategoryDescription = (String)templateMap.get(templateObj.SELECT_DESCRIPTION);
%>
    <td><input type="radio" name="chkItem1" id="chkItem1" value="<%=XSSUtil.encodeForHTMLAttribute(context, strCategoryName)%>~<%=XSSUtil.encodeForHTMLAttribute(context,strCategoryDescription)%>" /></td>
    <td><img src="images/iconSmallFolder_new.png" name="imgFolder" id="imgFolder" alt="<%=XSSUtil.encodeForHTMLAttribute(context,strCategoryName)%>" /><a href="<%=XSSUtil.encodeForURL(context,strCategoryName)%>"></a><%=XSSUtil.encodeForHTML(context,strCategoryName)%></td>
    <td><%=XSSUtil.encodeForHTML(context,strCategoryDescription)%>&nbsp;</td>
  </tr>
  </framework:mapListItr>


  </table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
