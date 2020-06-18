<%--  emxTeamGenericSelectFolderDialog.jsp   -   Display preDefined Folders

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamGenericSelectFolderDialog.jsp.rca 1.16 Wed Oct 22 16:05:55 2008 przemek Experimental przemek $
--%>

<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@include file  = "emxTeamCommonUtilAppInclude.inc"%>
<%@ include file = "emxTeamProfileUtil.inc" %>
<%@include file  = "emxTeamUtil.inc"%>
<%@include file = "../emxPaginationInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%
  com.matrixone.apps.common.Person person        = com.matrixone.apps.common.Person.getPerson(context);
  MapList FolderMapList = new  MapList();

  String jsTreeID               = emxGetParameter(request,"jsTreeID");
  String sProjectId             = emxGetParameter(request,"projectId");
  String sObjectId              = emxGetParameter(request,"objectId");
  String suiteKey               = emxGetParameter(request,"suiteKey");
  String sNextSortOrder         = emxGetParameter(request,"sort");
  String sFilterKey             = emxGetParameter(request,"key");
  String sSortImage             = emxGetParameter(request,"sortImage");
  String sCallPage              = emxGetParameter(request,"callPage");
  String sFormName              = emxGetParameter(request,"formName");
  String sRelProjectMembership  = Framework.getPropertyValue(session,"relationship_ProjectMembership");
  String sRelProjectMembers     = Framework.getPropertyValue(session,"relationship_ProjectMembers");
  String sRelWorkspaceVaults    = Framework.getPropertyValue(session,"relationship_ProjectVaults");
  String objectNameStr          = "";
  String objectIdStr            = "";
  String objectDescStr          = "";
  String sWorkspaceName         = "";
  String selWorkspace           = "";

  RelationshipWithSelectItr relGetVaults  = null;
  Pattern relPattern                      = null;
  Pattern typePattern                     = null;
  String strRouteScope                    = Framework.getPropertyValue( session, "relationship_RouteScope");
  String strProjectType                   = Framework.getPropertyValue( session, "type_Project");
  String relRouteScope                    = Framework.getPropertyValue(session,"relationship_RouteScope");
  String typeVault                        = Framework.getPropertyValue(session,"type_ProjectVault");
  String sTypeProjectMember               = Framework.getPropertyValue(session,"type_ProjectMember");
  String sTypeProject                     = Framework.getPropertyValue(session,"type_Project");

  if (sSortImage == null){
    sSortImage = "images/iconSortDown.gif";
  }  
  if (sFilterKey == null || sFilterKey.equals("")){
    sFilterKey = "Name";
  }
  if (sNextSortOrder == null){
    sNextSortOrder = "descending";
  }
  if ((sCallPage == null) || sCallPage.equals("")){
    sCallPage = "";
  }

  BusinessObject boProjectMember              = null;
  BusinessObject boProjectMem                 = null;
  BusinessObject boProject                    = null;
  ExpansionWithSelect docSelect               = null;
  RelationshipWithSelectItr  FolderRelSelItr  = null;
  RelationshipWithSelectItr  docRelSelItr     = null;
  BusinessObjectList boProjectList            = new BusinessObjectList();
%>

<script language="Javascript" >

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

  function sortMessages(keys , filterKey) {
    if (keys == filterKey) {
<%
      if (sNextSortOrder.equals("ascending")) {
%>
      document.folderSummary.sort.value = "descending"
      document.folderSummary.sortImage.value = "images/iconSortDown.gif"
<%
      } else if(sNextSortOrder.equals("descending")) {
%>
        document.folderSummary.sort.value = "ascending"
        document.folderSummary.sortImage.value = "images/iconSortUp.gif"
<%
      }
%>
    }
    document.folderSummary.key.value = keys;
    document.folderSummary.submit();
    return;
  }

  function submitForm() {
    var checkedFlag = "false";
    var chkbxFlag   = "false";
    var checkedvalue ="";
    var checkedId = "";
    var link =false;
    // finding searchcontent to set values -- added to resolve the javascript issue
    var frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "searchContent");
      // force to select atleast one member to remove
      for (var varj = 0; varj < document.folderSummary.elements.length; varj++) {
        if (document.folderSummary.elements[varj].type == "checkbox") {
          chkbxFlag = "true";

          if (document.folderSummary.elements[varj].checked ) {
            checkedFlag = "true";

            if (document.folderSummary.elements[varj].name.indexOf('chkItem') > -1) {

              
              //var checkval =","+ parent.window.getWindowOpener().parent.frames[2].document.forms['<%=sFormName%>'].WorkspaceFolder.value;
              // commented above code  as getting javascript error
              var checkval =","+ frameContent.document.forms['<%=XSSUtil.encodeForJavaScript(context, sFormName)%>'].WorkspaceFolder.value;
              //var checkId = ","+ parent.window.getWindowOpener().parent.frames[2].document.forms['<%=sFormName%>'].workspaceFolderId.value;
              // commented above code  as getting javascript error
              var checkId = ","+ frameContent.document.forms['<%=XSSUtil.encodeForJavaScript(context, sFormName)%>'].workspaceFolderId.value;
              if (checkval.indexOf(","+document.folderSummary.elements[varj].value+",") == -1) {
                var checkboxValue = document.folderSummary.elements[varj].value;

                checkedvalue = checkedvalue + checkboxValue.substring(0,checkboxValue.indexOf(';')) + ",";
                checkedId = checkedId + checkboxValue.substring(checkboxValue.indexOf(';')+1) + ",";
              }
            }
          }
        }
      }


    if ((checkedFlag == "false") && (chkbxFlag == "true")) {
      alert("<emxUtil:i18nScript  localize="i18nId">emxTeamCentral.Common.SelectFolder</emxUtil:i18nScript>");
      return;
    } else {
        //parent.window.getWindowOpener().parent.frames[2].document.forms['<%=sFormName%>'].WorkspaceFolder.value=checkedvalue;
        // commented above code  as getting javascript error
        frameContent.document.forms['<%=XSSUtil.encodeForJavaScript(context, sFormName)%>'].WorkspaceFolder.value=checkedvalue;
        //parent.window.getWindowOpener().parent.frames[2].document.forms['<%=sFormName%>'].workspaceFolderId.value=checkedId;
        // commented above code  as getting javascript error
        frameContent.document.forms['<%=XSSUtil.encodeForJavaScript(context, sFormName)%>'].workspaceFolderId.value=checkedId;

      }
      parent.window.closeWindow();
  }

  function closeWindow() {
    parent.window.closeWindow();
    return;
  }

</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="folderSummary" method="post">
  <input type="hidden" name="folderIds" value=""/>
  <input type="hidden" name="key"  value="<xss:encodeForHTMLAttribute><%=sFilterKey%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="sort" value="<xss:encodeForHTMLAttribute><%=sNextSortOrder%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="filter" value="false"/>
  <input type="hidden" name="sortImage" value="<xss:encodeForHTMLAttribute><%=sSortImage%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=sObjectId%></xss:encodeForHTMLAttribute>"/>

<%
  String sParams = "jsTreeID="+XSSUtil.encodeForHTML(context, jsTreeID)+"&objectId="+XSSUtil.encodeForHTML(context, sObjectId)+"&suiteKey="+XSSUtil.encodeForHTML(context, suiteKey);

    if(sProjectId  == null) {
      sProjectId = "";
    }

    if((sCallPage == null) || (sCallPage.equals(""))) {
      sCallPage = "";
    }
    BusinessObject bo = null;

    //To get all the folders of all the project in which login person is a project member
    if (sCallPage.equals("Search")) {

      boolean bNoFolder = false;
      String projectName = "";
      String projectId   = "";
      selWorkspace = "to["+sRelWorkspaceVaults+"].from.name";
  if (emxPage.isNewQuery()) {
      relPattern = new Pattern(sRelProjectMembership);
      relPattern.addPattern(sRelProjectMembers);
      relPattern.addPattern(sRelWorkspaceVaults);

      typePattern = new Pattern(sTypeProjectMember);
      typePattern.addPattern(strProjectType);
      typePattern.addPattern(typeVault);
      // type and rel patterns to include in the final resultset
      Pattern includeTypePattern = new Pattern(typeVault);
      Pattern includeRelPattern = new Pattern(sRelWorkspaceVaults);

      person.open(context);
      StringList selectTypeStmts = new StringList();
      selectTypeStmts.add(person.SELECT_TYPE);
      selectTypeStmts.add(person.SELECT_NAME);
      selectTypeStmts.add(person.SELECT_ID);
      selectTypeStmts.add(person.SELECT_DESCRIPTION);
      selectTypeStmts.add(selWorkspace);
      
      // Added for Role-Based access
      String whereExp = "current.access[read,checkout,show] == TRUE && (relationship["+sRelWorkspaceVaults+"] ~~ TRUE || relationship["+sRelProjectMembers+"] == TRUE || relationship["+sRelProjectMembership+"] == TRUE)";
      
      MapList roleAccessList = DomainObject.findObjects(context, DomainObject.TYPE_WORKSPACE_VAULT, "*", whereExp, selectTypeStmts);
      
      FolderMapList =  person.getRelatedObjects(context,
                                        relPattern.getPattern(),  //String relPattern
                                        typePattern.getPattern(), //String typePattern
                                        selectTypeStmts,         //StringList objectSelects,
                                        null,         //StringList relationshipSelects,
                                        true,                     //boolean getTo,
                                        true,                     //boolean getFrom,
                                        (short)3,                 //short recurseToLevel,
                                        "",                       //String objectWhere,
                                        "",                       //String relationshipWhere,
                                        includeTypePattern,       //Pattern includeType,
                                        includeRelPattern,       //Pattern includeRelationship,
                                        null);  
	  
      // Merge the results from Role-Based access
      
      MapList resultList = new MapList();
      Iterator itr = roleAccessList.iterator();
		while(itr.hasNext())
		{
			Map m = (Map) itr.next();
			resultList.add(m);		
		}
		
		itr = FolderMapList.iterator();
		while(itr.hasNext())
		{
			Map m = (Map) itr.next();
			if(resultList.contains(m)) //to avoid duplicate entries
			resultList.add(m);		
		}
		
     // pass the resultList to the following method
         emxPage.getTable().setObjects(resultList);
         // pass in the selectables to the following method
         emxPage.getTable().setSelects(selectTypeStmts);
      }
    // this Maplist is the one which is used to make the table.
    FolderMapList = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());
%>
  <table border="0" cellpadding="3" cellspacing="2" width="100%">
  
    <!-- //XSSOK -->
    <framework:sortInit  defaultSortKey="<%=person.SELECT_NAME%>"  defaultSortType="string"  mapList="<%=FolderMapList%>"  resourceBundle="emxTeamCentralStringResource"  ascendText="emxTeamCentral.Common.SortAscending"  descendText="emxTeamCentral.Common.SortDescending"  params = "<%=sParams%>"  />
      <tr>
        <th nowrap>
         <input type="checkbox" name="chkList" id="chkList" onclick="doCheck()" />
        </th>
       <th nowrap>
          <framework:sortColumnHeader
            title="emxTeamCentral.Common.Name"
            sortKey="<%=person.SELECT_NAME %>"
            sortType="string"
            anchorClass="sortMenuItem"/>
        </th>
        <th nowrap><!-- //XSSOK -->
          <framework:sortColumnHeader  title="emxTeamCentral.TaskSummary.WorkSpace"  sortKey="<%=selWorkspace%>"  sortType="string"  anchorClass="sortMenuItem"/>
        </th>

        <th nowrap>
            <framework:sortColumnHeader
              title="emxTeamCentral.Common.Description"
              sortKey="<%=person.SELECT_DESCRIPTION%>"
              sortType="string"
              anchorClass="sortMenuItem"/>
        </th>
      </tr>
      <!-- //XSSOK -->
      <framework:mapListItr mapList="<%=FolderMapList%>" mapName="FolderMap">
<%
        objectNameStr    = (String) FolderMap.get(person.SELECT_NAME);
        objectIdStr      = (String)FolderMap.get(person.SELECT_ID);
        objectDescStr    = (String)FolderMap.get(person.SELECT_DESCRIPTION);
        sWorkspaceName   = (String)FolderMap.get(selWorkspace);
%>
          <tr class= '<framework:swap id ="1" />' >
            <td><input type="checkbox" name="chkItem1" id="chkItem1" value="<%=XSSUtil.encodeForHTMLAttribute(context,objectNameStr)%>;<%=XSSUtil.encodeForHTMLAttribute(context,objectIdStr)%>" /></td>
            <td><%=XSSUtil.encodeForHTML(context,objectNameStr)%></td>
            <td><%=XSSUtil.encodeForHTML(context,sWorkspaceName)%></td>
            <td><%=XSSUtil.encodeForHTML(context, objectDescStr)%></td>
          </tr>
      </framework:mapListItr>
</table>
<%
   if((FolderMapList == null) || (FolderMapList.size() < 0))   {
%>      <tr class="odd">
        <td colspan="6" height="50"><emxUtil:i18n localize="i18nId">emxTeamCentral.TopicSummary.NoTopicsFound</emxUtil:i18n></td>
      </tr>
<%
    }

    }
%>
</table>
</form>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

