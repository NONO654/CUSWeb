<%--  emxengchgEBOMUpdateDialog.jsp   - The Dialog page for Mass EBOM Update.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "emxengchgUtil.inc"%>
<%@include file = "emxengchgJavaScript.js"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxJSValidation.inc" %>

<%
  //Added for IR-069928V6R2012
  String PrevJsp=emxGetParameter(request,"PrevJsp");
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String selectedParts      = (String)session.getAttribute("selectedParts");
  
  String rdoName      = (String)session.getAttribute("rdoName");
  String selectedType = emxGetParameter(request,"selectedType");
  String checkedButtonValue=emxGetParameter(request,"checkedButtonValue");
  String checkboxValue=emxGetParameter(request,"checkboxValue");
  String Create = emxGetParameter(request,"Create");
  String prevmode  = emxGetParameter(request,"prevmode");
  String sName = emxGetParameter(request,"Name");
  String sRev = emxGetParameter(request,"Rev");
  String partsConnected =emxGetParameter(request,"partsConnected");
  String Relationship =emxGetParameter(request,"Relationship");

  String updateURL="";
  String languageStr      = request.getHeader("Accept-Language");
  String page1Heading     = "emxEngineeringCentral.Common.FindPart";
  String page2Heading     = "emxEngineeringCentral.Common.Select";
  String targetSearchPage = "emxEngrEBOMUpdateDialog.jsp";
  String objectId         = emxGetParameter(request, "objectId");
  String[] selectedObj    = (String[])session.getAttribute("selectedObjs");
  String ecrId            = emxGetParameter(request, "ecrId");
  String massUpdateAction = "";
  Part partObj = (Part)DomainObject.newInstance(context,
                                                DomainConstants.TYPE_PART,
                                                DomainConstants.ENGINEERING);
  partObj.setId(objectId);
  String partName = partObj.getInfo(context,"name");
  String partId = partObj.getInfo(context,"id");

  updateURL = "emxengchgEBOMMarkupEditAttributesDialogFS.jsp?&selectedObj="+selectedObj + "&ecrId="+ecrId;
  session.setAttribute("selectedObjects", selectedObj);


%>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<body onload="javascript:disableAffecPart();">
<form name="massEBOMUpdate" method="post" action="<%=XSSUtil.encodeForJavaScript(context,updateURL)%>" target="_parent" >
<table width="100%" border="0" cellspacing="2" cellpadding="5">
  <input type="hidden" name="partToRemoveId" value="<xss:encodeForHTMLAttribute><%=partId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="partToReplaceId" value="" />
  <input type="hidden" name="maintainCompSub" value="" />
  <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="Name" value="<xss:encodeForHTMLAttribute><%=sName%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="Rev" value="<xss:encodeForHTMLAttribute><%=sRev%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="Create" value="<xss:encodeForHTMLAttribute><%=Create%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="checkboxValue" value="<xss:encodeForHTMLAttribute><%=checkboxValue%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="selectedParts" value="<xss:encodeForHTMLAttribute><%=selectedParts%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="prevmode" value="<xss:encodeForHTMLAttribute><%=prevmode%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="selectedType" value="<xss:encodeForHTMLAttribute><%=selectedType%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="checkedButtonValue" value="<xss:encodeForHTMLAttribute><%=checkedButtonValue%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="partsConnected" value="<xss:encodeForHTMLAttribute><%=partsConnected%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="Relationship" value="<xss:encodeForHTMLAttribute><%=Relationship%></xss:encodeForHTMLAttribute>" />


<tr>
 <td width="25%" class="label" rowspan="4"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.MassChange.MassChangeOptions</emxUtil:i18n></td>
  <td class="inputField">
     <input type="radio" name="changeOption" value="replace" checked onClick="javascript:disableReplace();" /><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Replace</emxUtil:i18n>
<tr>
  <td class="inputField">
     <input type="radio" name="changeOption" value="remove" onClick="javascript:disableRemove();" /><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Remove</emxUtil:i18n>
<tr>
  <td class="inputField">
     <input type="radio" name="changeOption" value="add" onClick="javascript:disableAdd();" /><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Add</emxUtil:i18n>
<tr>
  <td class="inputField">
     <input type="radio" name="changeOption" value="update" onClick="javascript:disableUpdate();" /><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Update</emxUtil:i18n>

<tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.MassChange.AffectedPart</emxUtil:i18n></td>
    <td class="inputField">
      <input readonly type="text" name="partToRemove" size="30" onfocus="this.blur()" value="<xss:encodeForHTMLAttribute><%=partName%></xss:encodeForHTMLAttribute>" />
      <input class="button" type="button" name="removeButton" size = "200" value="..." alt="..." onClick="javascript:showPartSelect();" />
      <!--   <a id="clearButton" href="JavaScript:clearPart()"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Clear</emxUtil:i18n></a> -->
    </td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.MassChange.ReplacementNewPart</emxUtil:i18n></td>
    <td class="inputField">
      <input READONLY type="text" name="partToReplace" size="30" value="" onFocus="this.blur()" />
      <input class="button" type="button" name="replaceButton" size = "200" value="..." alt="..." onClick="javascript:showPartReplaceSearch();" />
      <a href="JavaScript:clearReplacement()"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Clear</emxUtil:i18n></a>
    </td>
  </tr>
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.MassChange.ReplacementOnly</emxUtil:i18n></td>
    <td class="inputField"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOM.MaintainAssemblySubstitute</emxUtil:i18n></td>
  </tr>
  <td width="150" class="label">&nbsp;</td>
  <td class="inputField">
    <table border="0">
      <tr>
        <td>
          <input type="radio" name="maintainSub" id="maintainSub" value="Yes" />
          <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Yes</emxUtil:i18n>
        </td>
      </tr>
      <tr>
        <td>
          <input type="radio" name="maintainSub" id="maintainSub" value="No" checked />
          <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.No</emxUtil:i18n>
        </td>
      </tr>
    </table>
  </td>
</table>
<input type="hidden" name="massUpdateAction" value="" />
</form>
</body>
<script language="JavaScript">
function disableAffecPart()
{
	 document.massEBOMUpdate.partToRemove.disabled=true;
     document.massEBOMUpdate.removeButton.disabled=true;
    
    
}

function goBack()
{      //Modified for IR-069928V6R2012 starts
	
	var PrevJsp="<xss:encodeForJavaScript><%=PrevJsp%></xss:encodeForJavaScript>";
	if("null"!=PrevJsp)
{
				document.massEBOMUpdate.action=PrevJsp+"?prevmode=true";
	}
	else
	{
	  document.massEBOMUpdate.action="emxpartReasonForChangeAnECRWizardFS.jsp?prevmode=true";
	}
        //Modified for IR-069928V6R2012 ends
   document.massEBOMUpdate.submit();

}
  function checkInput()
  {
    var partReplace = document.massEBOMUpdate.partToReplaceId.value;
    var partRemove = document.massEBOMUpdate.partToRemoveId.value;
    var maintainSub = "";
    var partMassUpdateAction = "";
    if(document.massEBOMUpdate.maintainSub[0].checked == true)
    {
		maintainSub = document.massEBOMUpdate.maintainSub[0].value;
	}
	else if(document.massEBOMUpdate.maintainSub[1].checked == true)
	{
		maintainSub = document.massEBOMUpdate.maintainSub[1].value;
	}

    if (document.massEBOMUpdate.changeOption[0].checked == true)
    {
      if ((document.massEBOMUpdate.partToRemove.value == "") || (document.massEBOMUpdate.partToReplace.value == ""))
        {
           alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.MassChange.PleaseSelectAtLeastPartToRemoveOrPartToAddReplace</emxUtil:i18nScript>");
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
      if (document.massEBOMUpdate.partToReplace.value == "")
        {
           alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.MassChange.PleaseSelectAtLeastPartToRemoveOrPartToAddReplace</emxUtil:i18nScript>");
           return;
        }

        document.massEBOMUpdate.massUpdateAction.value="Add";
        partMassUpdateAction = "Add";
    }
    else if (document.massEBOMUpdate.changeOption[3].checked == true)
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
        var goURL1 = "<%=updateURL%>&massUpdateAction="+partMassUpdateAction+"&partToReplaceId="+partReplace+"&partToRemoveId="+partRemove+"&maintainSub="+maintainSub;
        document.massEBOMUpdate.action=goURL1;
        document.massEBOMUpdate.submit();

      }
      else
      {
        var goURL2 = "emxengchgMassEBOMMarkupCreateProcess.jsp?sflag=false&mode=Create&selectedObj=<xss:encodeForURL><%=selectedObj%></xss:encodeForURL>&ecrId=<xss:encodeForURL><%=ecrId%></xss:encodeForURL>&partToRemoveId="+partRemove+"&partToReplaceId="+partReplace+"&massUpdateAction="+partMassUpdateAction;
        document.massEBOMUpdate.action = goURL2;
        startProgressBar(true);
        document.massEBOMUpdate.submit();
      }
    }
  }

  function showPartRemoveSearch()
  {
	  //XSSOK
    showChooser("emxEngrEBOMReplacementPartSearchDialogFS.jsp?targetSearchPage=<%=targetSearchPage%>&form=massEBOMUpdate&field=partToRemove&hidfield=partToRemoveId&suiteKey=<%=suiteKey%>");
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
   showChooser("../common/emxFullSearch.jsp?field=TYPES=type_Part&table=ENCAffectedItemSearchResult&selection=single&submitURL=../engineeringcentral/emxEngrMarkupChangeProcess.jsp&fieldNameActual=partToReplaceId&HelpMarker=emxhelpfullsearch&fieldNameDisplay=partToReplace&formName=massEBOMUpdate&suiteKey=EngineeringCentral");
  }

  function clearReplacement()
  {
    document.massEBOMUpdate.partToReplace.value = "";
    document.massEBOMUpdate.partToReplaceId.value = "";
    if(!document.massEBOMUpdate.replaceButton.disabled) {
        document.massEBOMUpdate.replaceButton.focus();
    }
  }

  function showPartSelect()
  {
	  showChooser("../engineeringcentral/emxEngrFullSearchPreProcess.jsp?calledMethod=removePart&objectId=<xss:encodeForURL><%=objectId%></xss:encodeForURL>");
  }

  function disableReplace() {
     document.massEBOMUpdate.partToRemove.disabled=true;
     document.massEBOMUpdate.removeButton.disabled=true;
     document.massEBOMUpdate.partToReplace.disabled=false;
     document.massEBOMUpdate.replaceButton.disabled=false;
     document.massEBOMUpdate.maintainSub[0].disabled=false;
     document.massEBOMUpdate.maintainSub[1].disabled=false;

     return;  }

  function disableRemove() {
     document.massEBOMUpdate.partToRemove.disabled=true;
     document.massEBOMUpdate.removeButton.disabled=true;
     document.massEBOMUpdate.partToReplace.disabled=true;
     document.massEBOMUpdate.replaceButton.disabled=true;
     document.massEBOMUpdate.maintainSub[0].disabled=true;
     document.massEBOMUpdate.maintainSub[1].disabled=true;
     return;  }
  function disableAdd() {
     document.massEBOMUpdate.partToRemove.disabled=true;
     document.massEBOMUpdate.removeButton.disabled=true;
     document.massEBOMUpdate.partToReplace.disabled=false;
     document.massEBOMUpdate.replaceButton.disabled=false;
     document.massEBOMUpdate.maintainSub[0].disabled=true;
     document.massEBOMUpdate.maintainSub[1].disabled=true;

     return;  }
  function disableUpdate() {
     document.massEBOMUpdate.partToRemove.disabled=true;
     document.massEBOMUpdate.removeButton.disabled=true;
     document.massEBOMUpdate.partToReplace.disabled=true;
     document.massEBOMUpdate.replaceButton.disabled=true;
     document.massEBOMUpdate.maintainSub[0].disabled=true;
     document.massEBOMUpdate.maintainSub[1].disabled=true;

     return;  }</script>

<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "emxEngrVisiblePageButtomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
