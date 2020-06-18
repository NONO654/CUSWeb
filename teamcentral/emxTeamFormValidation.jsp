<%--  emxTeamFormValidation.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
   static const char RCSID[] = $Id: emxTeamFormValidation.jsp.rca 1.14 Tue Oct 28 19:01:07 2008 przemek Experimental przemek $

 --%>
<%-- Common Includes --%>
<%@include file = "../components/emxComponentsCommonInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil" %>
<%@ page import = "com.matrixone.apps.domain.DomainConstants" %>
<%@ page import = "com.matrixone.apps.domain.DomainObject" %>
<%
String languageStr = request.getHeader("Accept-Language");
String ResFormFileId = "emxTeamCentralStringResource";  

String vaultedObjToType = "";
String typeSelected = "";
String typeSelectedDisplay = "";
if("TMCGeneralSearch".equals(request.getParameter("searchcommand")) || "TMCFolderSearch".equals(request.getParameter("searchcommand"))) {
    try {
        String relType = com.matrixone.apps.domain.DomainObject.RELATIONSHIP_VAULTED_OBJECTS;

        vaultedObjToType = com.matrixone.apps.domain.util.MqlUtil.mqlCommand(context, "print relationship $1 select $2 dump", relType,"totype");
    } catch (com.matrixone.apps.domain.util.FrameworkException fe){
        vaultedObjToType = " ";
    }
    typeSelected = request.getParameter("Type");
    typeSelected = com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(typeSelected) ? "Document" : typeSelected;
    typeSelectedDisplay = com.matrixone.apps.domain.util.i18nNow.getTypeI18NString(typeSelected, languageStr);
}



%>

<script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script>
<script language="javascript" src="../common/scripts/emxJSValidationUtil.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIModal.js"></script>

<SCRIPT LANGUAGE="JavaScript">

function getWorkSpaceId()
{
	var WorkspaceOID = document.getElementsByName("WorkspaceOID")[0];
	if(WorkspaceOID != null)
	{
	   url = "../common/emxTable.jsp?formName=editDataForm&program=emxWorkspace:findContentFolderSearch&table=TMCFindContentFolderSearch&selection=multiple&header=emxTeamCentral.UploadFolderDialogFS.Heading&suiteKey=TeamCentral&HelpMarker=emxhelpdiscussion&Export=false&objectCompare=false&sortColumnName=Name&sortDirection=ascending&CancelButton=true&multiColumnSort=false&customize=false&showPageURLIcon=false&showClipboard=false&SubmitURL=../components/emxCommonSelectObjects.jsp&fieldNameDisplay=WorkspaceFolderDisplay&fieldNameActual=WorkspaceFolder";
	   url += "&projectId=" + WorkspaceOID.value + "&fieldNameOID=WorkspaceFolderOID";
	}
	showChooser(url,400,400);
}

//<!--
function isContainBadChar(field)
{
    var apostrophePosition = field.value.indexOf("'");
    var hashPosition = field.value.indexOf("#");
    var doublequotesPosition = field.value.indexOf("\"");

    if (apostrophePosition != -1 || hashPosition != -1 || doublequotesPosition != -1){
        alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.SpecialCharacters</emxUtil:i18nScript>");
        field.value="";
        field.focus();
        return true;
    }
}
// Checking for Bad characters in the field
function checkBadNameChars(fieldName) 
{
	   if(!fieldName)
	        fieldName=this;
	    var badChars = "";
	    badNameChars=checkForNameBadChars(fieldName, true);
	    var nameAllBadCharName=getAllNameBadChars(fieldName);
	    var name=fieldName.name;
	    if ((badNameChars).length != 0) {
	    	msg = "<%=i18nNow.getI18nString("emxTeamCentral.ErrorMsg.InvalidInputMsg",ResFormFileId,languageStr)%>";
	        msg += badNameChars;
	        msg += "<%=i18nNow.getI18nString("emxTeamCentral.Common.AlertInvalidInput", ResFormFileId,languageStr)%>";
	        msg += nameAllBadCharName;
	        msg += "<%=i18nNow.getI18nString("emxTeamCentral.Alert.RemoveInvalidChars", ResFormFileId,languageStr)%> ";
	        msg += name;
	        msg += " <%=i18nNow.getI18nString("emxTeamCentral.Alert.Field", ResFormFileId,languageStr)%> ";
	        fieldName.focus();
            alert(msg);
            return false;
        }
        return true;
 }
 
//Checking for Bad characters in the Text Area field
function checkBadChars(fieldName)
{
    if(!fieldName)
    fieldName=this;
    var badChars = "";
    badChars=checkForBadChars(fieldName,true);
    if ((badChars).length != 0) {
        msg = "<%=i18nNow.getI18nString("emxTeamCentral.Alert.InvalidChars",ResFormFileId,languageStr)%>";
        msg += badChars;
        msg += "<%=i18nNow.getI18nString("emxTeamCentral.Alert.RemoveInvalidChars", ResFormFileId,languageStr)%> ";
        msg += fieldName.name;
        msg += " <%=i18nNow.getI18nString("emxTeamCentral.Alert.Field", ResFormFileId,languageStr)%> ";
        fieldName.focus();
        alert(msg);
        return false;
    }
    return true;
}
 //Call page for workspace folder ellipsis
    function workspaceFolderSelector() {
    
      var value = document.FilesSearch.projectId.value;
      emxShowModalDialog("${COMMON_DIR}/emxTable.jsp?table=TMCMyDeskWorkspaceSummary&program=emxWorkspace:getAllMyDeskWorkspace&selection=single&cancelLabel=emxTeamCentral.Button.Cancel&header=emxTeamCentral.Common.SelectWorkspace&SubmitURL=../components/emxCommonSelectObject.jsp&mode=chooser&chooserType=ObjectChooser&HelpMarker=emxhelpcreatenewworkspace&findMxLink=false&showPageURLIcon=false&customize=false&showClipboard=false&&multiColumnSort=false&PrinterFriendly=false&Export=false&autoFilter=false&CancelButton=true&formName=editDataForm&projectId="+value+"");
    }



 function Update(checkBox)
    { 	
        if(checkBox.checked==true)
        {
        	document.getElementsByName("txtRev")[0].value = "";
        	document.getElementsByName("txtRev")[0].readOnly=true;
        	checkBox.focus();
        }
        else
        {
        	document.getElementsByName("txtRev")[0].value = "*";
        	document.getElementsByName("txtRev")[0].readOnly=false;
            document.getElementsByName("txtRev")[0].focus();
        }
    }
 
 function handleFocus()
 {	
	 var chkLastRevObj = document.getElementsByName("chkLastRevision")[0];
     if(chkLastRevObj.value == "true")
     {
       Update(chkLastRevObj);
     }
 }
    
    function unSubscribeEvent()
	{
	var sAllIds = "";
	var count = eval("document.forms[0].elements.length");
    for(var i = 0; i < count; i++){
      if ((document.forms[0].elements[i].type == "checkbox")
          && (!document.forms[0].elements[i].checked)
          && (document.forms[0].elements[i].name == "chkUnSubscribeEvent") ){
            sAllIds += document.forms[0].elements[i].value + ";";
      }
    }

    document.forms[0].sUnsubscribedEventIds.value = sAllIds;
    return;
	}  

function templateDataSelected(objCheckbox){
    var strMembers = document.getElementById("addMembers").checked;
    var strFolders = document.getElementById("addFolders").checked;
    if (!strMembers && !strFolders) {
        objCheckbox.checked = true;
        alert("<%=i18nNow.getI18nString("emxTeamCentral.WorkspaceTemplateSaveDialog.TemplateDataError",ResFormFileId,languageStr)%>");
    }
    document.forms[0].TemplateData.value = document.getElementById("addMembers").checked + "|" + document.getElementById("addFolders").checked;
}

function addContentShowTypeChooser() {
	var sURL    = '../common/emxTypeChooser.jsp?fieldNameDisplay=TypeDisplay';
    sURL        = sURL + '&fieldNameActual=Type&formName=editDataForm&SelectType=singleselect';
    sURL        = sURL + '&SelectAbstractTypes=true&ObserveHidden=false';
    sURL        = sURL + '&ShowIcons=true&SuiteDirectory=components&Suitekey=Components&HelpMarker=emxhelpselectorganization';
    sURL        = sURL + '&InclusionList=<%=vaultedObjToType%>';
    showModalDialog(sURL,500,400);
}

function contentSearchSetTypeValue() {
	document.forms[0].TypeDisplay.value = "<%=typeSelectedDisplay%>";
	document.forms[0].Type.value = "<%= XSSUtil.encodeForJavaScript(context, typeSelected)%>";
	<%
    String projectName = "";
    String projectID   = "";
    String objectId=emxGetParameter(request, "objectId");

	if(!"".equals(objectId)&&objectId!=null)
	{
		
	 String strProjectVault = PropertyUtil.getSchemaProperty(context,"relationship_ProjectVaults" );
     String strProjectType  = PropertyUtil.getSchemaProperty(context,"type_Project");
     String strSubVaultsRel = PropertyUtil.getSchemaProperty(context,"relationship_SubVaults");
     String strProjectVaultType  = PropertyUtil.getSchemaProperty(context,"type_ProjectVault" );
     DomainObject domainObject = DomainObject.newInstance(context);
     domainObject.setId(objectId);


     Pattern relPattern  = new Pattern(strProjectVault);
     relPattern.addPattern(strSubVaultsRel);
     Pattern typePattern = new Pattern(strProjectType);
     typePattern.addPattern(strProjectVaultType);

     StringList objSelects = new StringList();
     objSelects.addElement(DomainConstants.SELECT_NAME);
     objSelects.addElement(DomainConstants.SELECT_ID);

     MapList mapList = domainObject.getRelatedObjects(context,
                                              relPattern.getPattern(),
                                              typePattern.getPattern(),
                                              objSelects,
                                              null,
                                              true,
                                              false,
                                              (short)-1,
                                              "",
                                              "",
                                              null,
                                              null,
                                              null);
     Iterator mapItr = mapList.iterator();
     if(mapItr.hasNext())
     {
       Map map = (Map)mapItr.next();
       projectName = (String) map.get(DomainConstants.SELECT_NAME);
       projectID = (String) map.get(DomainConstants.SELECT_ID);
     }
     
	}     
	   
		 %>
		 
		 var Workspace=document.getElementsByName("Workspace")[0];
		 if(Workspace!=null)
			 {
		 //XSSOK
		 document.getElementsByName("WorkspaceDisplay")[0].value="<%=projectName%>";
		 //XSSOK
		 document.getElementsByName("Workspace")[0].value="<%=projectName%>";
		 //XSSOK
		 document.getElementsByName("WorkspaceOID")[0].value="<%=projectID%>";

			 }
}

//-->
</SCRIPT>
