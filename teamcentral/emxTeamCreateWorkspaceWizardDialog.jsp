<%--  emxTeamCreateWorkspaceWizardDialog.jsp-  Create Dialog for WorkSpace Wizard
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamCreateWorkspaceWizardDialog.jsp.rca 1.43 Wed Oct 22 16:06:38 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@include file = "emxTeamProfileUtil.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>

<%
  String projectId             = emxGetParameter(request,"objectId");
  String projectName           = emxGetParameter(request,"workspaceName");
  String projectDescription    = emxGetParameter(request,"workspaceDesc");
  String templateId            = emxGetParameter(request, "templateId");
  String template              = emxGetParameter(request, "template");

  if(projectName == null || "null".equals(projectName)){
      projectName ="";
  }

  if(projectDescription == null || "null".equals(projectDescription)){
    projectDescription ="";
  }
  
  if(UIUtil.isNullOrEmpty(template)){
      template = "";
  }
  String sBuyerDeskId = null;
  String sBuyerDesk   = null;

  boolean bSourcing = FrameworkUtil.isSuiteRegistered(context,"appVersionSourcingCentral",false,null,null); //for bug 280457  

  Pattern relPat  = new Pattern(DomainObject.RELATIONSHIP_WORKSPACE_BUYER_DESK);
  Pattern typePat = new Pattern(DomainObject.TYPE_BUYER_DESK);

  if (projectId != null && !(("").equals(projectId ))) {
    BusinessObject boExistProject = new BusinessObject(projectId);
    boExistProject.open(context);
    projectName =  boExistProject.getName();
    projectDescription = boExistProject.getDescription();
    boExistProject.close(context);
    if (bSourcing) {
      BusinessObject boBuyerDesk = com.matrixone.apps.common.util.ComponentsUtil.getConnectedObject(context, boExistProject ,relPat.getPattern(),typePat.getPattern(),false, true);
      if(boBuyerDesk == null || "null".equals(boBuyerDesk)){
        ;
      } else {
        boBuyerDesk.open(context);
        sBuyerDeskId = boBuyerDesk.getObjectId();
        sBuyerDesk   = boBuyerDesk.getName();
        boBuyerDesk.close(context);
      }
    }
  }
%>

<script language="javascript">

  function trim (textBox) {
    while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) == "\n" )
      textBox = textBox.substring(0,textBox.length - 1);
    while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n")
      textBox = textBox.substring(1,textBox.length);
      return textBox;
  }

  function clear(textfield) {
   if(textfield == "templateDisplay")
   {
    if(trim(document.createDialog.templateDisplay.value) !=null) {
      document.createDialog.templateDisplay.value="";
      document.createDialog.templateId.value="";
    }
   }
   else
   {
    if(trim(document.createDialog.txtBuyerDesk.value) !=null) {
      document.createDialog.txtBuyerDesk.value="";
      document.createDialog.txtBuyerDeskId.value="";
    }
   }
    return;
  }

  //function  to move the focus from template textfield to search button.
  function moveFocus(){
    document.createDialog.searchTemp.focus();
    return;
  }

 function showSearchWindow() {
		var sURL = "../common/emxFullSearch.jsp?table=TMCWorkspaceTemplateSearchResults&hideHeader=true&HelpMarker=emxhelpfullsearch&mode=Chooser&selection=single&fieldNameActual=templateId&fieldNameDisplay=templateDisplay&fieldNameOID=templateIdOID&chooserType=TypeChooser&field=TYPES=type_WorkspaceTemplate:LATESTREVISION=TRUE&cancelLabel=emxTeamCentral.Button.Cancel&suiteKey=TeamCentral&submitURL=../teamcentral/emxTeamFullSearchUtil.jsp&displayView=details&includeOIDprogram=emxWorkspaceTemplate:getWorkspaceTemplateIncludeIDs&populateDescription=true";
		showModalDialog(sURL,600,600);		
      }

  function submitForm() {

      var sTextValue =  trim(document.createDialog.projectName.value);
      var description =  trim(document.createDialog.txtdescription.value);
      document.createDialog.projectName.value = sTextValue;
      document.createDialog.txtdescription.value = description;
      var namebadCharName = checkForUnifiedNameBadChars(document.createDialog.projectName, true);
      var nameAllBadCharName = getAllNameBadChars(document.createDialog.projectName);
      var name = document.createDialog.projectName.name;
      var namebadCharDescrption = checkForBadChars(document.createDialog.txtdescription);
      if (namebadCharName.length != 0){
	   	alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertInvalidInput</emxUtil:i18nScript>"+nameAllBadCharName+"<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Alert.RemoveInvalidChars</emxUtil:i18nScript> "+name+" <emxUtil:i18nScript localize="i18nId">emxTeamCentral.Alert.Field</emxUtil:i18nScript>");
        document.createDialog.projectName.focus();
        return;
       }
      else if (!(isAlphanumeric(sTextValue, true))) {
        alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertValidName</emxUtil:i18nScript>");
        document.createDialog.projectName.focus();
        return;
      }
      else if(!(isValidLength(sTextValue, 1,115))){
        alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.CreateWorkspace.NameLengthAlertMessage</emxUtil:i18nScript>");
        document.createDialog.projectName.focus();
        return;
      }
      else if(sTextValue == "") {

        alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.EnterName</emxUtil:i18nScript>");
        document.createDialog.projectName.focus();
        return;
      }
      else if(namebadCharDescrption.length != 0) {
        alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharDescrption+"<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
        document.createDialog.txtdescription.focus();
        return;
       }
      else if(description == "") {
        alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Common.EnterDisp</emxUtil:i18nScript>");
        document.createDialog.txtdescription.focus();
        return;
      } else {
              if(jsDblClick())
              {
                startProgressBar(true);
                document.createDialog.submit();
                return;
               }else
               {
                   alert("<emxUtil:i18nScript localize="i18nId">emxTeamCentral.Search.RequestProcessMessage</emxUtil:i18nScript>");
                   return;
               }
      }
  }

  function closeWindow() {
	  submitWithCSRF("emxWorkspaceWizardCancelProcess.jsp?projectId=<%=XSSUtil.encodeForURL(context, projectId)%>", window);
      return;
  }

  function showBuyerDesk() {
    emxShowModalDialog('emxTeamBuyerDeskSummaryFS.jsp?formName=createDialog&txtCtrl=txtBuyerDesk&txtId=txtBuyerDeskId',575,575);
  }
</script>


<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="createDialog" method="post" onSubmit="submitForm();return false;" action="emxTeamCreateWorkspaceWizardprocess.jsp" target="_parent">
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="txtBuyerDeskId" value=""/>
  <table>
    <tr>
      <td  nowrap  class="labelRequired"><label for="Name"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Name</emxUtil:i18n></label></td>
      <td nowrap  class="field">
<%
       if("".equals(projectName)) {
%>
      <input type="Text" name="projectName" size="20" value="<xss:encodeForHTMLAttribute><%=projectName%></xss:encodeForHTMLAttribute>"/>
<%
    } else {
%>
        <xss:encodeForHTML><%=projectName%></xss:encodeForHTML>
        <input type="hidden" name="projectName" value="<xss:encodeForHTMLAttribute><%=projectName%></xss:encodeForHTMLAttribute>" />
<%
    }
%>
    </td>
    </tr>

   <tr>
      <td class="label"><label for="Template"><emxUtil:i18n localize="i18nId">emxTeamCentral.CreateRouteWizardDialog.Template</emxUtil:i18n></label></td>
    <%
         if (UIUtil.isNotNullAndNotEmpty(templateId)) {
             
    %>

         <td class="field"><xss:encodeForHTML><%=template%></xss:encodeForHTML>&nbsp;</td>
           <input type="hidden" name="templateDisplay" value="<xss:encodeForHTMLAttribute><%=template%></xss:encodeForHTMLAttribute>"/>
           <input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=templateId%></xss:encodeForHTMLAttribute>"/>

    <%
        } else {
    %>
      <td class="field">
         
         <input type="text" name="templateDisplay" id="templateDisplay" value="" readonly />
         <input type="button" name="searchTemp" id="searchTemp" value="..." onClick="javascript:showSearchWindow()" />
         <input type="hidden" name="templateId" id="templateId" value="" />
         <a class="dialogClear" href="javascript:clear('templateDisplay')"><emxUtil:i18n localize="i18nId">emxTeamCentral.common.Clear</emxUtil:i18n></a>         
         <input type="hidden" name="templateIdOID" id="templateIdOID" value="" />
      </td>
    <%
        }
    %>
  </tr>

<%
  if(bSourcing) {
%>
    <tr>
       <td class="label"><label for="BuyerDesk"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.BuyerDesk</emxUtil:i18n></label></td>
<%
       if (projectName != null && !"".equals(projectName)) {
%>
       <td class="field"><%=(sBuyerDesk!=null)?sBuyerDesk:"&nbsp;"%></td>
       <input type="hidden" name="txtBuyerDeskId" value="<xss:encodeForHTMLAttribute><%=sBuyerDeskId%></xss:encodeForHTMLAttribute>"/>
<%
       } else {
%>
      <!-- modified for for bug 283291  -->
       <td class="field"><input type="text" readonly="readonly" name="txtBuyerDesk" size="20" value="<xss:encodeForHTMLAttribute><%=(sBuyerDesk!=null)?sBuyerDesk:""%></xss:encodeForHTMLAttribute>"/>&nbsp;<input type="button" name="" id="" value="..." onclick="showBuyerDesk()" />&nbsp;<a href="javascript:clear('txtBuyerDesk')"><emxUtil:i18n localize="i18nId">emxTeamCentral.common.Clear</emxUtil:i18n></a></td>
<%
       }
%>
   </tr>
<%
  }
%>
    <tr>
      <td class="labelRequired"><label for="Description"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Description</emxUtil:i18n></label></td>
      <td class="field" ><textarea name="txtdescription" cols = "40" rows="5" wrap><xss:encodeForHTML><%=projectDescription%></xss:encodeForHTML></textarea></td>
    </tr>
  </table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
