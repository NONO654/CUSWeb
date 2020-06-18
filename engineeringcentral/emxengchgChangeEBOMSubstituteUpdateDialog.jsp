<%--emxengchgChangeEBOMSubstituteUpdateDialog.jsp

    (c) Dassault Systemes, 1993-2018.  All rights reserved.
 
  --%>
<%@include file = "../engineeringcentral/emxDesignTopInclude.inc"%>
<%@include file = "../engineeringcentral/emxEngrVisiblePageInclude.inc"%>
<%@include file = "../engineeringcentral/emxengchgJavaScript.js"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxJSValidation.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*,com.matrixone.apps.domain.DomainRelationship,com.matrixone.apps.engineering.Part,com.matrixone.apps.domain.DomainObject"  %>

<%
  String path = emxGetQueryString(request);
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String selectedParts      = (String)session.getAttribute("selectedParts");
  String rdoId      = (String)session.getAttribute("rdoId");
  String rdoName      = (String)session.getAttribute("rdoName");
  String selectedType = emxGetParameter(request,"selectedType");
  String checkedButtonValue=emxGetParameter(request,"checkedButtonValue");
  String selectedObjs=emxGetParameter(request,"selectedObjs");
  String dojObjName=emxGetParameter(request,"dojObjName");
  String partId=emxGetParameter(request,"partId");
  String checkboxValue=emxGetParameter(request,"checkboxValue");
  String Create = emxGetParameter(request,"Create");
  String prevmode  = emxGetParameter(request,"prevmode");
  String sName = emxGetParameter(request,"Name");
  String sRev = emxGetParameter(request,"Rev");
  String partsConnected =emxGetParameter(request,"partsConnected");
  String Relationship =emxGetParameter(request,"Relationship");
  String affectedaction =emxGetParameter(request,"affectedaction");
  String updateURL="";
  String languageStr      = request.getHeader("Accept-Language");
  String page1Heading     = "emxEngineeringCentral.Common.FindPart";
  String page2Heading     = "emxEngineeringCentral.Common.Select";
  String targetSearchPage = "../engineeringcentral/emxEngrEBOMUpdateDialog.jsp";
  String objectId         = emxGetParameter(request, "objectId");
  String massUpdateAction = "";

  
  updateURL = "emxengchgChangeEBOMSubstituteMarkupEditAttributesDialogFS.jsp?objectId=" + objectId+"&partId="+partId+"&affectedaction="+affectedaction+"&Relationship="+Relationship+"&selectedObjs="+selectedObjs+"&dojObjName="+dojObjName+"&partId="+partId+"&ebomSubstituteChange=true";

%>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<form name="massEBOMUpdate" method="post" action="<xss:encodeForHTML><%=updateURL%></xss:encodeForHTML>" target=_parent>
<table width="100%" border="0" cellspacing="2" cellpadding="5">
  <input type="hidden" name="partToRemoveId" value="<xss:encodeForHTMLAttribute><%=partId%></xss:encodeForHTMLAttribute>">
  <input type="hidden" name="partToReplaceId" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"partToReplaceId") %></xss:encodeForHTMLAttribute>">
  <input type="hidden" name="maintainCompSub" value="">
  <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>">
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>">
  <input type="hidden" name="Name" value="<xss:encodeForHTMLAttribute><%=sName%></xss:encodeForHTMLAttribute>">
  <input type="hidden" name="Rev" value="<xss:encodeForHTMLAttribute><%=sRev%></xss:encodeForHTMLAttribute>">
  <input type="hidden" name="Create" value="<xss:encodeForHTMLAttribute><%=Create%></xss:encodeForHTMLAttribute>">
  <input type="hidden" name="checkboxValue" value="<xss:encodeForHTMLAttribute><%=checkboxValue%></xss:encodeForHTMLAttribute>" >
  <input type="hidden" name="selectedParts" value="<xss:encodeForHTMLAttribute><%=selectedParts%></xss:encodeForHTMLAttribute>">
  <input type="hidden" name="prevmode" value="<xss:encodeForHTMLAttribute><%=prevmode%></xss:encodeForHTMLAttribute>" >
  <input type="hidden" name="selectedType" value="<xss:encodeForHTMLAttribute><%=selectedType%></xss:encodeForHTMLAttribute>" >
  <input type="hidden" name="checkedButtonValue" value="<xss:encodeForHTMLAttribute><%=checkedButtonValue%></xss:encodeForHTMLAttribute>" >
  <input type="hidden" name="partsConnected" value="<xss:encodeForHTMLAttribute><%=partsConnected%></xss:encodeForHTMLAttribute>">
  <input type="hidden" name="Relationship" value="<xss:encodeForHTMLAttribute><%=Relationship%></xss:encodeForHTMLAttribute>">
  <input type="hidden" name="affectedaction" value="<xss:encodeForHTMLAttribute><%=affectedaction%></xss:encodeForHTMLAttribute>">
  <input type="hidden" name="mecoFieldId" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "mecoFieldId")%></xss:encodeForHTMLAttribute>">
  

<% 

if(path.contains("&partToReplaceId"))
{
	String patharray[] = path.split("&partToReplaceId");
	patharray[0]=request.getRequestURL()+"?"+patharray[0];
%> 
 <input type="hidden" name="path" value="<xss:encodeForHTMLAttribute><%=path %></xss:encodeForHTMLAttribute>">
<%
} else { 
	path=request.getRequestURL()+"?"+path;
	%>
	<input type="hidden" name="path">
	<% }

%>
	

<tr>
 <td width="25%" class="label" rowspan="3"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.MassChange.MassChangeOptions</emxUtil:i18n></td>
  <td class="inputField">
     <input type="radio" name="changeOption" value="replace" checked onClick="javascript:disableReplace();"/><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Replace</emxUtil:i18n>
<tr>
  <td class="inputField">
     <input type="radio" name="changeOption" value="remove" onClick="javascript:disableRemove();"/><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Remove</emxUtil:i18n>
<tr>
<tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.MassChange.AffectedPart</emxUtil:i18n></td>
    <td class="inputField">
      <input readonly type="text" name="partToRemove" size="30" onfocus="this.blur()" value="<xss:encodeForHTMLAttribute><%=dojObjName%></xss:encodeForHTMLAttribute>">
    </td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.MassChange.ReplacementPart</emxUtil:i18n></td>
    <td class="inputField"> <!--  Added Lines 103-108-->
	<% if (emxGetParameter(request,"partToReplace")!=null) { %>
      <input readonly type="text" name="partToReplace" size="30" onfocus="this.blur()" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"partToReplace") %></xss:encodeForHTMLAttribute>">
	<% } else { %>
      <input readonly type="text" name="partToReplace" size="30" onfocus="this.blur()">
	<% } %>
      <input class="button" type="button" name="replaceButton" size = "200" value="..." alt="..." onClick="javascript:showPartReplaceSearch();">
      <a href="JavaScript:clearReplacement()"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Clear</emxUtil:i18n></a>
    </td>
  </tr>
    <tr>
    <td  class="labelRequired"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Alert.SubstituteMassChangeUpdateMECO</emxUtil:i18n></td>
    <td class="inputField"> <!--  Added Lines 103-108-->
      <input readonly type="text" name="mecoField" size="30" onfocus="this.blur()">
      <input class="button" type="button" name="mecoButton" size = "200" value="..." alt="..." onClick="javascript:showMECOSearch();">
      <a href="JavaScript:clearMECO()"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Clear</emxUtil:i18n></a>
    </td>
  </tr>
  <!--
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.MassChange.ReplacementOnly</emxUtil:i18n></td>
    <td class="inputField"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOM.MaintainAssemblySubstitute</emxUtil:i18n></td>
  </tr>
  <td width="150" class="label">&nbsp</td>
  <td class="inputField">
    <table border="0">
      <tr>
        <td>
          <input type="radio" name="maintainSub" id="maintainSub" value="Yes">
          <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Yes</emxUtil:i18n>
        </td>
      </tr>
      <tr>
        <td>
          <input type="radio" name="maintainSub" id="maintainSub" value="No" checked>
          <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.No</emxUtil:i18n>
        </td>
      </tr>
    </table>
  </td>
  -->
</table>
<input type=hidden name="massUpdateAction" value="">

</form>
<script language="JavaScript">

/*
function goBack()
{
   document.massEBOMUpdate.action="emxpartReasonForChangeAnECRWizardFS.jsp";
   document.massEBOMUpdate.submit();

} */
  function checkInput()
  {
    var partReplace = document.massEBOMUpdate.partToReplaceId.value;
    var partRemove = document.massEBOMUpdate.partToRemoveId.value;
	var affectedactionname = document.massEBOMUpdate.affectedaction.value;
    //var maintainSub = "";
    var partMassUpdateAction = "";
    /*
	if(document.massEBOMUpdate.maintainSub[0].checked == true)
    {
		maintainSub = document.massEBOMUpdate.maintainSub[0].value;
	}
	else if(document.massEBOMUpdate.maintainSub[1].checked == true)
	{
		maintainSub = document.massEBOMUpdate.maintainSub[1].value;
	} */

    if (document.massEBOMUpdate.changeOption[0].checked == true)
    {
      if ((document.massEBOMUpdate.partToRemove.value == "") || (document.massEBOMUpdate.partToReplace.value == ""))
        {
           alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.MassChange.PleaseSelectRemoveOrPartToReplace</emxUtil:i18nScript>");
           return;
        }

        document.massEBOMUpdate.massUpdateAction.value="Replace";
        partMassUpdateAction = "Replace";
    }
    else if (document.massEBOMUpdate.changeOption[1].checked == true)
    {
      if (document.massEBOMUpdate.partToRemove.value == "")
        {
           alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.MassChange.PleaseSelectAtLeastPartToRemoveOrPartToAddReplace</emxUtil:i18nScript>");
           return;
        }

        document.massEBOMUpdate.massUpdateAction.value="Remove";
        partMassUpdateAction = "Remove";
    }
	else if (document.massEBOMUpdate.changeOption[2].checked == true)
    {
        document.massEBOMUpdate.massUpdateAction.value="Update";
        partMassUpdateAction = "Update";
    }

    if ((document.massEBOMUpdate.partToRemove.value == "")&&(document.massEBOMUpdate.partToReplace.value == ""))
    {
      alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.MassChange.PleaseSelectAtLeastPartToRemoveOrPartToAddReplace</emxUtil:i18nScript>");
      return;
    }

    if ((document.massEBOMUpdate.partToRemove.value==document.massEBOMUpdate.partToReplace.value) && (document.massEBOMUpdate.partToRemove.value!="" && document.massEBOMUpdate.partToReplace.value!=""))
    {
      alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EBOM.PartToRemoveReplaceAlert</emxUtil:i18nScript>");
      return;
    }
    else
    {
     if (partMassUpdateAction != "Remove")
      {
	  //XSSOK
    var goURL1 = "<%=updateURL%>&massUpdateAction="+partMassUpdateAction+"&partToReplaceId="+partReplace+"&partToRemoveId="+partRemove;
	//XSSOk
		//+"&objectId=<%=objectId%>";
        document.massEBOMUpdate.action=goURL1;
        document.massEBOMUpdate.submit();

      }
      else
      {
		  if (!jsDblClick()) {
			alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Process.MultiSubmit</emxUtil:i18nScript>");
            return;
            }
        var goURL2 = "emxengchgChangeMassEBOMSubstituteMarkupCreateProcess.jsp?mode=Create&partToRemoveId="+partRemove+"&partToReplaceId="+partReplace+"&massUpdateAction="+partMassUpdateAction+"&affectedaction="+affectedactionname+"&ebomSubstituteChange=true";	

	    var confirm = false;
		confirm = window.confirm("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.AIMassChange.NoMR</emxUtil:i18nScript>");
		if (confirm==false)
		{
	     return;
		}
        else
		{
        document.massEBOMUpdate.action = goURL2;
        startProgressBar(true);
        document.massEBOMUpdate.submit();
		}		
      }
    }
  }

  function showPartRemoveSearch()
  {
  //XSSOK
    showChooser("../engineeringcentral/emxEngrEBOMReplacementPartSearchDialogFS.jsp?targetSearchPage=<%=targetSearchPage%>&form=massEBOMUpdate&field=partToRemove&hidfield=partToRemoveId");
  }

  function clearPart()
  {
    document.massEBOMUpdate.partToRemove.value = "";
    document.massEBOMUpdate.partToRemoveId.value = "";
    if(!document.massEBOMUpdate.removeButton.disabled) {
      document.massEBOMUpdate.removeButton.focus();
    }
  }

  function showPartReplaceSearch()
  {
  //XSSOK
    //showChooser("../engineeringcentral/emxEngrEBOMReplacementPartSearchDialogFS.jsp?targetSearchPage=<%=targetSearchPage%>&form=massEBOMUpdate&field=partToReplace&hidfield=partToReplaceId");
	  showChooser("../common/emxFullSearch.jsp?field=TYPES=type_Part:LASTREVISION=TRUE&table=ENCAffectedItemSearchResult&selection=single&submitURL=../engineeringcentral/emxEngrMarkupChangeProcess.jsp&fieldNameActual=partToReplaceId&HelpMarker=emxhelpfullsearch&fieldNameDisplay=partToReplace&formName=massEBOMUpdate&suiteKey=EngineeringCentral");
  }
  function showMECOSearch()
  {
  //XSSOK
    //showChooser("../engineeringcentral/emxEngrEBOMReplacementPartSearchDialogFS.jsp?targetSearchPage=<%=targetSearchPage%>&form=massEBOMUpdate&field=partToReplace&hidfield=partToReplaceId");
	  showChooser("../common/emxFullSearch.jsp?field=TYPES=type_MECO:CURRENT=policy_MECO.state_Create&table=ENCAffectedItemSearchResult&selection=single&submitURL=../engineeringcentral/emxEngrMarkupChangeProcess.jsp&fieldNameActual=mecoFieldId&HelpMarker=emxhelpfullsearch&fieldNameDisplay=mecoField&formName=massEBOMUpdate&suiteKey=EngineeringCentral");
  }
  function clearReplacement()
  {
    document.massEBOMUpdate.partToReplace.value = "";
    document.massEBOMUpdate.partToReplaceId.value = "";
    if(!document.massEBOMUpdate.replaceButton.disabled) {
        document.massEBOMUpdate.replaceButton.focus();
    }
  }
  function clearMECO()
  {
    document.massEBOMUpdate.mecoField.value = "";
  }
  function showPartSelect()
  {
  //XSSOK
    showChooser("../engineeringcentral/emxEngrEBOMRemovePartSelectDialogFS.jsp?objectId=<xss:encodeForURL><%=objectId%></xss:encodeForURL>");
  }

  function disableReplace() {
     document.massEBOMUpdate.partToReplace.disabled=false;
     document.massEBOMUpdate.replaceButton.disabled=false;
     return;  }

  function disableRemove() {
     document.massEBOMUpdate.partToReplace.disabled=true;
     document.massEBOMUpdate.replaceButton.disabled=true;
     return;  }
	 </script>

<%@include file = "../engineeringcentral/emxDesignBottomInclude.inc"%>
<%@include file = "../engineeringcentral/emxEngrVisiblePageButtomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

