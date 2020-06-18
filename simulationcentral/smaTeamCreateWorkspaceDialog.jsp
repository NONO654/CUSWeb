<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
    This is an exact copy of emxTeamCreateSubFoldersWorkspaceDialogFS.jsp.
    The reason is so that we don't change Team Central code.  The real
    reason is that we must send back a structure browser xml string
    at the end of this functionality.

    Changes:
    The include file paths have been changed to point to team central.
    The emx prefix has been changed to sma where appropriate
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../teamcentral/emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../teamcentral/eServiceUtil.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>

<script language="javascript">


  function trim (textBox) {
    while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) == "\n" )
      textBox = textBox.substring(0,textBox.length - 1);
    while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n")
      textBox = textBox.substring(1,textBox.length);
      return textBox;
  }

  function submitform() {

      var sTextValue =  trim(document.createDialog.txtName.value);
      var description =  trim(document.createDialog.txtdescription.value);
      document.createDialog.txtName.value = sTextValue;
      document.createDialog.txtdescription.value = description;
      var namebadCharName = checkForNameBadCharsList(document.createDialog.txtName);
      var namebadCharDescrption = checkForNameBadCharsList(document.createDialog.txtdescription);

      if (namebadCharName.length != 0){
        alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
        document.createDialog.txtName.focus();
        return;
       }
      else if (!(isAlphanumeric(sTextValue, true))){
        alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertName</emxUtil:i18nScript>");
        document.createDialog.txtName.focus();
        return;
      }
     else if(!(isValidLength(sTextValue, 1,115))){
        alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.CreateWorkspace.NameLengthAlertMessage</emxUtil:i18nScript>");
        document.createDialog.txtName.focus();
        return;
      }
      else if ( sTextValue == "" ) {
        alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.CreateWorkspace.EnterProjName</emxUtil:i18nScript>");
        document.createDialog.txtName.focus();
        return;
      }
      else if (namebadCharDescrption.length != 0){
        alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharDescrption+"<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
        document.createDialog.txtdescription.focus();
        return;
       }
      else if ( description == "" ) {
        alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.CreateWorkspace.ProjDesc</emxUtil:i18nScript>");
        document.createDialog.txtdescription.focus();
        return;
      }
      if(jsDblClick()) {
        startProgressBar(true);
        document.createDialog.submit();
        return;
      }else
      {
           alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Search.RequestProcessMessage</emxUtil:i18nScript>");
           return;
      }
  }

  function closeWindow() {
    //parent.closeWindow();
    exitComposeShorCut();
    return;
  }

  function showBuyerDesk() {
    emxShowModalDialog('../teamcentral/emxTeamBuyerDeskSummaryFS.jsp?formName=createDialog&txtCtrl=txtBuyerDesk&txtId=txtBuyerDeskId',575,575);
  }


</script>


<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%

  boolean bSourcing = FrameworkUtil.isSuiteRegistered(context,"appVersionSourcingCentral",false,null,null); // 19/01/2004 for bug 280457 

  String projectName        = emxGetParameter(request,"workspaceName");
  String projectDescription = emxGetParameter(request,"workspaceDesc");
  String sourcePageName     = emxGetParameter(request,"sourcePageName");
  String templateId         = emxGetParameter(request,"templateId");
  String template           = emxGetParameter(request,"templateDisplay");
  String sBuyerDesk         = emxGetParameter(request,"txtBuyerDesk");
  String sBuyerDeskId       = emxGetParameter(request,"txtBuyerDeskId");

  int Count  = 0;
  StringList objectSelects = new StringList(1);
  objectSelects.add(DomainObject.SELECT_NAME);


  com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
  Company company = person.getCompany(context);

  try{
    MapList resultRouteTemplateList= DomainObject.findObjects(context,DomainObject.TYPE_WORKSPACE_TEMPLATE,
                          "*",
                          "*",
                          "*",
                          company.getAllVaults(context,true),
                          "",
                          false,
                          objectSelects);

    Count = resultRouteTemplateList.size();
  } catch(Exception ex){
    session.setAttribute("error.message", ex.getMessage());
    }
%>


<form name="createDialog" method="post"  onSubmit="submitform()" action="../simulationcentral/smaTeamCreateWorkspace.jsp" target="_parent">
<input type=hidden name="txtBuyerDeskId" value="<%=setSpace(sBuyerDeskId)%>">
<input type=hidden name="sourcePageName" value="<%=sourcePageName%>">
  <table border="0" cellpadding="5" cellspacing="2" width="530">
    <tr>
      <td  nowrap  class="labelRequired"><label for="Name"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Name</emxUtil:i18n></label></td>
      <td nowrap  class="field"><input type="Text" name="txtName" value="<%=setSpace(projectName)%>" size="20"></td>
    </tr>

    <tr>
      <td class="label">
        <label for="Template"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Template</emxUtil:i18n></label>
      </td>

      <td class="Field">
        <input type="hidden" name="templateId" value="<%=setSpace(templateId)%>">
        <input type="hidden" name="templateIdOID" id="templateIdOID" value="" >
        <input type="text" readonly="readonly" name="templateDisplay" value="<%=setSpace(template)%>" size="20" >
        <input type="button" name="" id="" value="..." onClick="javascript:showSearchWindow()">&nbsp;&nbsp;<a href="javascript:clearAll('Template')"><emxUtil:i18n localize="i18nId">emxTeamCentral.common.Clear</emxUtil:i18n></a>
      </td>
    </tr>
<%
   if (bSourcing) {
%>
    <tr>
     <td class="label"><label for="Name"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.BuyerDesk</emxUtil:i18n></label></td>
     <td class="field"><input type="Text" readonly="readonly" name="txtBuyerDesk" value="<%=setSpace(sBuyerDesk)%>" size="20" >
     <input type="button" name="" id="" value="..." onclick="showBuyerDesk()" >&nbsp;&nbsp;<a href="javascript:clearAll('Buyer')"><emxUtil:i18n localize="i18nId">emxTeamCentral.common.Clear</emxUtil:i18n></a>
     </td>
    </tr>
<%
   }
%>
    <tr>
      <td class="labelRequired"><label for="Name"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Description</emxUtil:i18n></label></td>
      <td class="field" ><textarea name="txtdescription" cols="40" rows="5" wrap><%=setSpace(projectDescription)%></textarea></td>
    </tr>
  </table>

  <script>

   function showSearchWindow() {
    <%
        if ( Count > 0 ) {
    %>
          emxShowModalDialog('../common/emxFullSearch.jsp?field=TYPES=type_WorkspaceTemplate&table=TMCWorkspaceTemplateSearchResults&selection=single&cancelLabel=smaSimulationCentral.Button.Cancel&hideHeader=true&suiteKey=SimulationCentral&fieldNameActual=templateId&fieldNameDisplay=templateDisplay&fieldNameOID=templateIdOID&submitURL=../teamcentral/emxTeamFullSearchUtil.jsp&mode=Chooser&chooserType=TypeChooser&HelpMarker=emxhelpfullsearch',775, 500);
    <%
        } else {
    %>
          alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.CreateWorkspaceDialog.WorkspaceTemplageNotExistsMessage</emxUtil:i18nScript>");
          return;
    <%
        }
    %>
    }
  function clearAll(Obj) {
    if(Obj =='Template' ) {
      document.createDialog.template.value          = "";
      document.createDialog.templateId.value        = "";
    } else {
      document.createDialog.txtBuyerDeskId.value    = "";
      document.createDialog.txtBuyerDesk.value      = "";
    }
      return;
  }


</script>
</form>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

<%!
public String setSpace(String sVal) {
    if(sVal == null || "null".equals(sVal)){
    sVal ="";
    }
    return sVal;
}

%>
