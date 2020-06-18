<%--  emxTeamCreateWorkSpaceToplevelFolders.jsp   -   Display Top Level Folders
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamCreateWorkspaceToplevelFolders.jsp.rca 1.26 Wed Oct 22 16:06:24 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "emxTeamProfileUtil.inc"%>
<%@include file = "emxTeamUtil.inc"%>
<%@include file = "../emxPaginationInclude.inc" %>
<%@ include file = "../emxJSValidation.inc" %>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
  MapList folderMapList            =  null;

  String projectId                 = emxGetParameter(request, "objectId");
  String sWsTemplateId             = emxGetParameter(request, "templateId");
  String template                  = emxGetParameter(request, "template");

  String treeUrl                   = null;

 DomainObject folderObj  = DomainObject.newInstance(context,projectId);
 if (emxPage.isNewQuery()) {
  Pattern relPattern               = new Pattern(folderObj.RELATIONSHIP_PROJECT_VAULTS);
  Pattern typePattern              = new Pattern(folderObj.TYPE_PROJECT_VAULT);
  SelectList typeselectList        = new SelectList();

  typeselectList.add(folderObj.SELECT_NAME);
  typeselectList.add(folderObj.SELECT_DESCRIPTION);
  typeselectList.add(folderObj.SELECT_ID);

  folderMapList          = folderObj.getRelatedObjects(context,
                                        relPattern.getPattern(),
                                        typePattern.getPattern(),
                                        typeselectList,
                                        new StringList(),
                                        false,
                                        true,
                                        (short)1,
                                        "",
                                        "",
                                        null,
                                        null,
                                        null);

     // pass the resultList to the following method
      emxPage.getTable().setObjects(folderMapList);
   }

    // this Maplist is the one which is used to make the table.
    folderMapList = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());


    String sParams = "objectId="+ XSSUtil.encodeForHTML(context, projectId);

  treeUrl = UINavigatorUtil.getCommonDirectory(context)+
                  "/emxTree.jsp?AppendParameters=true&objectId="+ XSSUtil.encodeForURL(context, projectId) +
                  "&mode=insert"+
                  "&emxSuiteDirectory="+appDirectory;

%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<script language="JavaScript">

  function trim (textBox) {
    return textBox.replace(/\s/gi, "");
  }

  function doCheck(){
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

  function submitForm() {

        if(jsDblClick())
        {
            // Create an alias for the form.
            startProgressBar(true);
            document.CreateProject.action =  "emxTeamCreateWorkspaceWizardSubFoldersFS.jsp";
            document.CreateProject.submit();
            return ;
        }else
        {
                   alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Search.RequestProcessMessage</emxUtil:i18nScript>");
                   return;
        }

  }
  function closeWindow() {
  		submitWithCSRF("emxWorkspaceWizardCancelProcess.jsp?projectId=<%=XSSUtil.encodeForURL(context, projectId)%>", window);
  return;
  }

  function showCreateNewFolderDilaog(){

    emxShowModalDialog("emxTeamCreateNewFolderDialogFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, projectId)%>&templateId=<%=XSSUtil.encodeForURL(context, sWsTemplateId)%>&template=<%=XSSUtil.encodeForURL(context, template)%>", 575, 575);

  }

  function goBack(){

    document.CreateProject.action =  "emxTeamCreateWorkspaceWizardDialogFS.jsp?projectId=<%=XSSUtil.encodeForURL(context, projectId)%>&templateId=<%=XSSUtil.encodeForURL(context, sWsTemplateId)%>&template=<%=XSSUtil.encodeForURL(context, template)%>";
    if(jsDblClick())
    {
        startProgressBar(true);
   		document.CreateProject.submit();
    }else
    {
		alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Search.RequestProcessMessage</emxUtil:i18nScript>");
    }
    return ;
  }

  function showDeleteDialogPopup() {
    var varChecked = "false";
    var objForm = document.forms[0];
    objForm.folderIds.value="";
    for (var i=0; i < objForm.elements.length; i++)
      if (objForm.elements[i].type == "checkbox") {
        if ((objForm.elements[i].name.indexOf('chkItem1') > -1) && (objForm.elements[i].checked == true)) {
          varChecked = "true";
          objForm.folderIds.value=objForm.folderIds.value+objForm.elements[i].value+";";
        }
      }

    if (varChecked == "false") {
      alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.CreateWorkSpaceToplevelFolderDelete.SelectFolder</emxUtil:i18nScript>");
      return;
    } else {
      if (confirm("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.CreateWorkSpaceToplevelFolderDelete.WizFolderMsg</emxUtil:i18nScript>") != 0)  {
        objForm.action="emxTeamDeleteFolders.jsp?page=WizFolder&folderIds="+objForm.folderIds.value;
        //handle double-click issue
	    if(jsDblClick())
    	{
        	startProgressBar(true);
        	objForm.submit();
         }else
   		 {
      	 	alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Search.RequestProcessMessage</emxUtil:i18nScript>");
   		 }
        return;
      }
    }
  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<form name="CreateProject" method="post" action="" target="_parent">
<input type="hidden" name="folderIds" value=""/>

<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%= projectId %></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=sWsTemplateId%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="template" value="<xss:encodeForHTMLAttribute><%=template%></xss:encodeForHTMLAttribute>"/>


 <script language="Javascript">
  	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIList");
 </script>
 <table class="list" id="UITable">

  <framework:sortInit
     defaultSortKey="<%=folderObj.SELECT_NAME%>"
     defaultSortType="string"
     mapList="<%=folderMapList%>"
     resourceBundle="emxTeamCentralStringResource"
     ascendText="emxTeamCentral.Common.SortAscending"
     descendText="emxTeamCentral.Common.SortDescending"
     params = "<%=sParams%>"  />
   <tr>
    <th width="5%">
      <table>
      <tr>
        <td align="center">
        <input type="checkbox" name="chkList" id="chkList" onclick="doCheck()"/>
        </td>
        </tr>
      </table>
    </th>
    <th nowrap>
      <framework:sortColumnHeader
        title="emxTeamCentral.Common.Name"
        sortKey="<%=folderObj.SELECT_NAME %>"
        sortType="string"/>
    </th>

    <th nowrap>
      <framework:sortColumnHeader
        title="emxTeamCentral.Common.Description"
        sortKey="<%=folderObj.SELECT_DESCRIPTION%>"
        sortType="string"/>
    </th>
  </tr>

<%
  if (folderMapList.size() == 0) {
%>
      <tr>
		<td align="center" colspan="13" class="error">
			<emxUtil:i18n localize="i18nId">emxTeamCentral.FolderDelete.NoTopicsFound</emxUtil:i18n>
		</td>
      </tr>
<%
  }
%>
  <!-- //XSSOK -->
  <framework:mapListItr mapList="<%=folderMapList%>" mapName="templateMap">
  <tr class='<framework:swap id ="1" />'>
    <!-- //XSSOK -->
	<td align="center"><input type="checkbox" name="chkItem1" id="chkItem1" onclick="updateCheck()" value="<%=XSSUtil.encodeForHTMLAttribute(context,templateMap.get(folderObj.SELECT_ID).toString())%>" /></td>
    <!-- //XSSOK -->
	<td><img src="images/iconSmallFolder_new.png" name="imgFolder" id="imgFolder" alt="<%=XSSUtil.encodeForHTMLAttribute(context,templateMap.get(folderObj.SELECT_NAME).toString())%>" /><a href="<%=templateMap.get(folderObj.SELECT_NAME)%>"></a> <%=templateMap.get(folderObj.SELECT_NAME)%></td>
    <!-- //XSSOK -->
	<td><%=XSSUtil.encodeForHTML(context,templateMap.get(folderObj.SELECT_DESCRIPTION).toString())%>&nbsp;</td>
  </tr>
  </framework:mapListItr>
  </table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
