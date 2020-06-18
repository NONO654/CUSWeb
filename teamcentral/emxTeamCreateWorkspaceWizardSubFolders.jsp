<%--
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<!DOCTYPE html>
<html>
	<head>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>

<%
  String jsTreeID     = emxGetParameter(request,"jsTreeID");
  String templateId   = emxGetParameter(request, "templateId");
  String template     = emxGetParameter(request, "template");
  String suiteKey     = emxGetParameter(request,"suiteKey");
  String strObjectId  = emxGetParameter(request, "objectId");

String treeUrl = UINavigatorUtil.getCommonDirectory(context)+
                  "/emxTree.jsp?AppendParameters=true&objectId="+ XSSUtil.encodeForURL(context, strObjectId) +
                  "&mode=insert"+
                  "&emxSuiteDirectory="+XSSUtil.encodeForURL(context, appDirectory);
%>

<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUISelectableTree.js"></script>
<script language="javascript" src="../emxUIPageUtility.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>

<script language="javascript">

  var tree = new jsSelectableTree("emxUITree.css");
  function submitForm() {
  		if(jsDblClick()) {
        	// Create an alias for the form.
            startProgressBar(true);
 <%
            String personUrl = "../common/emxIndentedTable.jsp?program=emxDomainAccess:getObjectAccessList&table=DomainAccess&editLink=true&selection=multiple&toolbar=DomainAccessToolBar&header=emxFramework.WorkSpaceAccessMembersDialog.AccessMembers&editRootNode=false&objectBased=false&showClipboard=false&displayView=details&showPageURLIcon=false&massUpdate=false&HelpMarker=emxhelpmultipleownershipaccess&suiteKey=Framework&objectId="+strObjectId+"&template="+ template +"&templateId="+templateId +"&submitLabel=emxFramework.Button.Submit";
                personUrl += "&submitURL=../teamcentral/emxTeamWorkspaceSelectMembersProcess.jsp&fromPage=WorkspaceWizard&return=access";
                personUrl += "&prevURL=../teamcentral/emxTeamCreateWorkspaceWizardSubFoldersFS.jsp";
 %>
            parent.window.location.href ="<%=personUrl%>";
            return;
        } else{
            alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Search.RequestProcessMessage</emxUtil:i18nScript>");
            return;
        }
  }

  function closeWindow() {
	    submitWithCSRF("emxWorkspaceWizardCancelProcess.jsp?projectId=<%=XSSUtil.encodeForURL(context, strObjectId)%>", window);
	    return;
  }

  function goBack(){
  	  	parent.window.location.href ="emxTeamCreateWorkspaceToplevelFoldersFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, strObjectId)%>&template=<%=XSSUtil.encodeForURL(context, template)%>&templateId=<%=XSSUtil.encodeForURL(context, templateId)%>";
    	return;
  }
</script>

			<style>
				#divFolderTreePabe {
					position:absolute;
					top:0;
					bottom:0;
					left:0;
					width:200px;
					background-color:lightgreen;
					overflow:hidden;
					}
				
				#divSubFolderPane {
					position:absolute;
					top:0;
					bottom:0;
					left:200px;
					right:0;
					background-color:lightblue;
					overflow:hidden;
					}
				
				#divFolderTreePabe iframe,
				#divSubFolderPane iframe {
					position:absolute;
					top:0;
					bottom:0;
					left:0;
					right:0;
					width:100%;
					height:100%;
					overflow:auto;
					}
			</style>	
	</head>
	<div id='divPageBody'>
       	<div id="divFolderTreePabe">
       		<iframe name="folderTree" id="folderTree" src="emxTeamFoldersView.jsp?jsTreeID=<%=XSSUtil.encodeForURL(context, jsTreeID)%>&objectId=<%=XSSUtil.encodeForURL(context, strObjectId)%>&template=<%=template%>&templateId=<%=XSSUtil.encodeForURL(context, templateId)%>" allowtransparency="true" frameborder="0"></iframe>
        </div>
	    <div id="divSubFolderPane">
    	   	<iframe name="subFolderList" id='subFolderList' src="emxTeamBlankSubFolders.jsp" allowtransparency="true" frameborder="0"></iframe>
	    </div>
	</div>
</html>
