<%--emxbomMLBOMReportDialog.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@ include file = "emxDesignTopInclude.inc"%>
<%@ include file = "emxEngrVisiblePageInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<%@ include file = "emxengchgJavaScript.js"%>
<%@ include file = "../emxJSValidation.inc" %>

<%
  Part part = (Part)DomainObject.newInstance(context,
                    DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);
  String languageStr  = request.getHeader("Accept-Language");
  String strRelEBOM       = PropertyUtil.getSchemaProperty(context, "relationship_EBOM");
  String strRelEBOMHistory= PropertyUtil.getSchemaProperty(context, "relationship_EBOMHistory");
  //Multitenant
  //String strAnd   = i18nNow.getI18nString("emxEngineeringCentral.Common.And", "emxEngineeringCentralStringResource",languageStr);
  String strAnd   = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.And");
  String EbomAndEbomHistory =strRelEBOM +","+ strRelEBOMHistory;
//Multitenant
  //String strEbomAndEbomHistory =i18nNow.getI18nString("emxEngineeringCentral.EBOM.EBOMAndEBOMHistoryRel", "emxEngineeringCentralStringResource",languageStr);
String strEbomAndEbomHistory = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.EBOM.EBOMAndEBOMHistoryRel");

//Multitenant
//String strRel   = i18nNow.getI18nString("emxEngineeringCentral.Common.Relationship", "emxEngineeringCentralStringResource",languageStr);
String strRel   = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.Relationship");

//Multitenant
//String qtyMessage       = i18nNow.getI18nString("emxEngineeringCentral.EBOM.LevelHasToBeAWholeNumber", "emxEngineeringCentralStringResource",languageStr);
String qtyMessage       = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.EBOM.LevelHasToBeAWholeNumber");

//Multitenant
//String allString       = i18nNow.getI18nString("emxEngineeringCentral.Common.All", "emxEngineeringCentralStringResource",languageStr);
String allString       = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.All");

//Multitenant
//String levelStr       = i18nNow.getI18nString("emxEngineeringCentral.Common.Levels", "emxEngineeringCentralStringResource",languageStr);
String levelStr       = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.Levels");
  String jsTreeID         = emxGetParameter(request,"jsTreeID");
  String objectId         = emxGetParameter(request,"objectId");
  String objectName       = emxGetParameter(request,"objectName");

  String displayPage = emxGetParameter(request,"displayPage");
  String locationName = "";
  String locationId = "";

  if (displayPage.equalsIgnoreCase("AVL")) {
     locationName = Person.getPerson(context).getCompany(context).getInfo(context,DomainConstants.SELECT_NAME);
     locationId = Person.getPerson(context).getCompany(context).getInfo(context,DomainConstants.SELECT_ID);
  }

  String maxShort         = Short.toString(Short.MAX_VALUE);
  String partName;
  String partRev;
  String partType;
  String strSpace=" ";
  String typeIcon;

  try
  {
    // set the part id
    part.setId(objectId);

    StringList resultSelects = new StringList(3);
    resultSelects.addElement(DomainObject.SELECT_TYPE);
    resultSelects.addElement(DomainObject.SELECT_NAME);
    resultSelects.addElement(DomainObject.SELECT_REVISION);

    Map resultsMap = part.getInfo(context, resultSelects);
    partType = (String)resultsMap.get(DomainObject.SELECT_TYPE);
    partName = (String)resultsMap.get(DomainObject.SELECT_NAME);
    partRev  = (String)resultsMap.get(DomainObject.SELECT_REVISION);
    typeIcon=EngineeringUtil.getDisplayPartIcon(context , partType);
     
  }
  catch(Exception e)
  {
      throw e;
  }
  //commented code for the bug 306505
  //String subHeader = partType + "|";
  //commented code for the bug 306505
  // Get default value with levels to expand the structure
  String sLevel = JSPUtil.getCentralProperty(application, session, "eServiceToolbarMLBM" ,"DefaultLevelToExpand");
  if (sLevel == null)
  {
    sLevel = "3";  // If not defined in properties set a default value
  }

%>

<script language="Javascript" >

 function showLocationSelector() {
   //showModalDialog("../common/emxSearch.jsp?defaultSearch=ENCFindCompany&typename=Company&toolbar=ENCFindLocationsToolBar&title=Company&rowselect=single&helpMarker=emxhelpsearchcompany", 500, 500);
   //369746
   	 showModalDialog("../common/emxFullSearch.jsp?field=TYPES=type_Organization,type_Company,type_BusinessUnit,type_Department,type_Location:CURRENT=state_Active&suiteKey=EngineeringCentral&HelpMarker=emxhelpfullsearch&table=AEFGeneralSearchResults&fieldNameDisplay=location&fieldNameActual=location&hideHeader=true&selection=single&submitURL=AEFSearchUtil.jsp", 500, 500);
 }

 function setLocation(locId,locName) {
     document.getMLBOMLevels.location.value=locName;
     document.getMLBOMLevels.locationOID.value=locId;
  }

  function resetLocation()
  {
	//XSSOK 
    document.getMLBOMLevels.location.value = "<%=locationName%>";
  	//XSSOK 
    document.getMLBOMLevels.locationOID.value = "<%=locationId%>";
  }

  function updatelevel()
  {
    document.getMLBOMLevels.level.value="";
  }

  function alertLevelInput() {
    var field = document.getMLBOMLevels.allLevels;
    if(field.checked ==true) {
       field.focus();
      alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EBOM.AlreadyChosenAllLevel</emxUtil:i18nScript>");
      document.getMLBOMLevels.level.value="";
      return false;
    }
  }

function startSearchProgressBar1(){
      if (parent.frames[0].document.progress){
          parent.frames[0].document.progress.src = "../common/images/utilProgressBlue.gif";
      }
      return true;
   }


  var clicked = false;
// End
  function doneMethod(){
        //added for the form not to submitted more than once
    if (clicked) {
    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Search.RequestProcessMessage</emxUtil:i18nScript>");
    return;
     }

    var level = document.getMLBOMLevels.level.value;

    if ((!document.getMLBOMLevels.allLevels.checked) && (level==null || level=="")){
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EBOM.SelectEitherLevelOrCheckbox</emxUtil:i18nScript>");
        document.getMLBOMLevels.level.focus();
        return;
    }
    if (document.getMLBOMLevels.allLevels.checked) {
        
        subHeadLevel = "emxEngineeringCentral.Common.All";
    }

    else if (level != null && level !=""){
        subHeadLevel = level;
        
    }

    var varRelationship = document.getMLBOMLevels.relationship.options[document.getMLBOMLevels.relationship.selectedIndex].value;
    var relForSubHeader="";
	//XSSOK
    if (varRelationship =="<%=EbomAndEbomHistory%>") {
        
        relForSubHeader = "emxEngineeringCentral.EBOM.EBOMAndEBOMHistoryRel";
    }
	//XSSOK
    else if (varRelationship =="<%=strRelEBOM%>") {
       
        relForSubHeader = "emxEngineeringCentral.EBOM.EBOMRel";
    }
    //added code for the bug 306505 for Issue1 and Issue2
	//modifed for the bug no:-339130 
    <%--var subHead =  "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.Part</emxUtil:i18nScript>"+" |";--%>
    var subHead =  "emxEngineeringCentral.Common.Part"+"|";
    //added code for the bug 306505 for Issue1 and Issue2
    subHead += relForSubHeader;
    subHead += "|";
<%
     if (displayPage.equalsIgnoreCase("AVL")) {
%>
        locationvar = document.getMLBOMLevels.location.value;
        locationIdValue = document.getMLBOMLevels.locationOID.value;
        //added code for the bug 306505 for Issue1
        <%--subHead += locationvar + " <emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.TeamPersonDetails.Location</emxUtil:i18nScript>";--%>
        subHead += locationvar +"|"+ "emxEngineeringCentral.TeamPersonDetails.Location";
        //added code for the bug 306505 Issue1
        subHead += "|";
<%
     }
%>

        subHead += subHeadLevel;
       subHead += "|";
        subHead += "emxEngineeringCentral.Common.Levels";

    if (document.getMLBOMLevels.allLevels.checked && level != null && level != "")
    {
      alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EBOM.SelectLevelorCheckbox</emxUtil:i18nScript>");
      document.getMLBOMLevels.level.focus();
      return;

    }
    if (document.getMLBOMLevels.level.value==null || document.getMLBOMLevels.level.value=="")
    {
      if (!document.getMLBOMLevels.allLevels.checked)
      {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EBOM.SelectLevel</emxUtil:i18nScript>");
        document.getMLBOMLevels.level.focus();
      return;
      }
      else
      {
        //All Levels checked, so send level value as zero
<%
        if (displayPage.equalsIgnoreCase("AVL")) {
%>
      // added parameters to displayClose Link in the Multi-Level Engineering Bill of Materials Report window of a Part for closing the window
winurl = "../common/emxTable.jsp?program=emxPart:getMultiLevelEBOMsWithRelSelectables,emxPart:getExpandedEBOM,emxPart:getDelimitedRollupEBOM,emxPart:getRangeRollupEBOM&programLabel=emxEngineeringCentral.EBOMReferenceDesignator.StoredFormat,emxEngineeringCentral.EBOMReferenceDesignator.ExpandedFormat,emxEngineeringCentral.EBOMReferenceDesignator.DelimitedRoll-upFormat,emxEngineeringCentral.EBOMReferenceDesignator.RangeRoll-upFormat&objectId=<xss:encodeForURL><%=objectId%></xss:encodeForURL>&table=ENCAVLMLReport&suiteKey=EngineeringCentral&header=emxEngineeringCentral.Part.AVL.ConfigTableMultiLevelAVLSummary&level=0&relationship="+varRelationship+"&subHeader="+subHead+"&PrinterFriendly=true&HelpMarker=emxhelppartbomavlmulti&reportType=AVL&location="+locationIdValue+"&CancelLabel=emxEngineeringCentral.Common.Close&CancelButton=true&Style=Dialog&multilevelReport=Yes&incECRECOImage=true";
<%
        } else {
       // Building the URL if the display page is BOM Report.
       // Appended reportType and location parameters to the URL
%>
      //fix for bug 306455 - removed  sortColumnName & sortDirection parameter
       winurl = "../common/emxTable.jsp?program=emxPart:getMultiLevelEBOMsWithRelSelectables,emxPart:getExpandedEBOM,emxPart:getDelimitedRollupEBOM,emxPart:getRangeRollupEBOM&programLabel=emxEngineeringCentral.EBOMReferenceDesignator.StoredFormat,emxEngineeringCentral.EBOMReferenceDesignator.ExpandedFormat,emxEngineeringCentral.EBOMReferenceDesignator.DelimitedRoll-upFormat,emxEngineeringCentral.EBOMReferenceDesignator.RangeRoll-upFormat&objectId=<xss:encodeForURL><%=objectId%></xss:encodeForURL>&table=ENCMultiLevelBOMSummary&suiteKey=EngineeringCentral&header=emxEngineeringCentral.Part.ConfigTableMultiLevelBOMSummary&level=0&relationship="+varRelationship+"&subHeader="+subHead+"&PrinterFriendly=true&HelpMarker=emxhelppartbommultilevelreport&reportType=BOM&location=&CancelLabel=emxEngineeringCentral.Common.Close&CancelButton=true&Style=Dialog&multilevelReport=Yes&incECRECOImage=true";
                  turnOnProgress(true);
          clicked = true;
<%
       }
%>
        winurl = fnEncode(winurl);
        parent.window.location.href = winurl;
      }
    }
    //XSSOK
    else if ((level >= <%=maxShort%>) || (level <= 0) || (!isNumeric(level)) || charExists(level, '.'))
    {
    	//XSSOK
      alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.EBOM.InvalidLevelRange</emxUtil:i18nScript>" + <%=maxShort%>);
      document.getMLBOMLevels.level.focus();
      return;
    }
    else
    {
<%
        // Building the URL if the display page is AVL Report.
        if (displayPage.equalsIgnoreCase("AVL")) {
%>
           url = "../common/emxTable.jsp?program=emxPart:getMultiLevelEBOMsWithRelSelectables,emxPart:getExpandedEBOM,emxPart:getDelimitedRollupEBOM,emxPart:getRangeRollupEBOM&programLabel=emxEngineeringCentral.EBOMReferenceDesignator.StoredFormat,emxEngineeringCentral.EBOMReferenceDesignator.ExpandedFormat,emxEngineeringCentral.EBOMReferenceDesignator.DelimitedRoll-upFormat,emxEngineeringCentral.EBOMReferenceDesignator.RangeRoll-upFormat&objectId=<xss:encodeForURL><%=objectId%></xss:encodeForURL>&table=ENCAVLMLReport&suiteKey=EngineeringCentral&header=emxEngineeringCentral.Part.AVL.ConfigTableMultiLevelAVLSummary&level="+parseInt(level,10)+"&relationship="+varRelationship+"&subHeader="+subHead+"&PrinterFriendly=true&HelpMarker=emxhelppartbomavlmulti&reportType=AVL&location="+locationIdValue+"&CancelLabel=emxEngineeringCentral.Common.Close&CancelButton=true&Style=Dialog&multilevelReport=Yes&incECRECOImage=true";
<%
        } else {
       // Building the URL if the display page is BOM Report.
       // Appended reportType and location parameters to the URL
%>
  //fix for bug 306455 - removed  sortColumnName & sortDirection parameter
          url = "../common/emxTable.jsp?program=emxPart:getMultiLevelEBOMsWithRelSelectables,emxPart:getExpandedEBOM,emxPart:getDelimitedRollupEBOM,emxPart:getRangeRollupEBOM&programLabel=emxEngineeringCentral.EBOMReferenceDesignator.StoredFormat,emxEngineeringCentral.EBOMReferenceDesignator.ExpandedFormat,emxEngineeringCentral.EBOMReferenceDesignator.DelimitedRoll-upFormat,emxEngineeringCentral.EBOMReferenceDesignator.RangeRoll-upFormat&objectId=<xss:encodeForURL><%=objectId%></xss:encodeForURL>&table=ENCMultiLevelBOMSummary&suiteKey=EngineeringCentral&header=emxEngineeringCentral.Part.ConfigTableMultiLevelBOMSummary&level="+parseInt(level,10)+"&relationship="+varRelationship+"&subHeader="+subHead+"&PrinterFriendly=true&HelpMarker=emxhelppartbommultilevelreport&reportType=BOM&location=&CancelLabel=emxEngineeringCentral.Common.Close&CancelButton=true&Style=Dialog&multilevelReport=Yes&incECRECOImage=true";
<%
        }
%>
        url = fnEncode(url);
        turnOnProgress(true);
        clicked = true;

        parent.window.location.href = url;
    }
  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<!-- added code for the bug 306505 Issue4 -->
<script>
//modifed for the bug no:-339130 
var nameHeading="<xss:encodeForJavaScript><%=partName%></xss:encodeForJavaScript>" +"&nbsp;<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.Revision</emxUtil:i18nScript>" +"&nbsp;<xss:encodeForJavaScript><%= partRev%></xss:encodeForJavaScript>";
</script>
<%
//String nameHeading = partName + " rev " + partRev;
//  added code for the bug 306505 Issue4
%>

<form name="getMLBOMLevels" method="post" action="" onSubmit="return false" target="_parent">
<table border="0" cellpadding="5" cellspacing="2" width="100%">

<tr>
<td width="150" class="label"><label for="part"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Part</emxUtil:i18n></label></td>
<!-- code added for the bug 306505 Issue4-->
 <!-- XSSOK  -->
<td class="field"><b><img src="../common/images/<%=typeIcon%>" border="0" />&nbsp;<script>document.write(nameHeading)</script></b></td>
<!-- code added for the bug 306505  Issue4-->
</tr>

<tr>
<td width="150" class="labelRequired"><label for="Levels"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Levels</emxUtil:i18n></label></td>
<td class="inputField"><input type="text" name="level" id="" onfocus="javascript:alertLevelInput()" value="<xss:encodeForHTMLAttribute><%=sLevel%></xss:encodeForHTMLAttribute>" />
</td>
</tr>

<tr>
   <td width="150" class="label">&nbsp;</td>
   <td class="inputField"><input type="checkbox" name="allLevels" value="" onClick="javascript:updatelevel()" />
   <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Or</emxUtil:i18n>
   <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.All</emxUtil:i18n>
   <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Levels</emxUtil:i18n>
   </td>
</tr>
<%

/**
  * If the display page is AVL Report, display the Locations selector.
  */
   if (displayPage.equalsIgnoreCase("AVL"))
   {
%>
        <tr>
        <td width="150" class="labelRequired"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.TeamPersonDetails.Location</emxUtil:i18n></td>
        <td class="inputField">
        <input type="text" size="25" name="location" onfocus="this.blur();" value="<xss:encodeForHTMLAttribute><%=locationName%></xss:encodeForHTMLAttribute>" />
                <input type="button" name="" value="..." onClick="Javascript:showLocationSelector()" />
                 <a href="JavaScript:resetLocation()"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Reset</emxUtil:i18n></a>
              </td>
        </tr>
        <input type="hidden" name="locationOID" value="<xss:encodeForHTMLAttribute><%=locationId%></xss:encodeForHTMLAttribute>" />
<%
    }
%>
<tr>
   <td width="150" class="labelRequired"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Relationship</emxUtil:i18n></td>
   <td class="inputField">
    <select name="relationship" >
     <!-- XSSOK  -->
     <option value = "<%=strRelEBOM%>"> <%=i18nNow.getAdminI18NString("Relationship",strRelEBOM,languageStr)%> </option>
       <!-- XSSOK  -->
      <option value = "<%=EbomAndEbomHistory%>"> <%=i18nNow.getAdminI18NString("Relationship",strRelEBOM,languageStr)+strSpace+ strAnd+strSpace+i18nNow.getAdminI18NString("Relationship",strRelEBOMHistory,languageStr)%> </option>
    </select>
    </td>
</tr>

<%-- Comment this out - will be a new feature to filter on State
<tr>
<td width="150" class="labelRequired"><label for="State"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.State</emxUtil:i18n></label></td>
<td class="inputField">
    <select name="selectState" >
    <option value="All" > <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.All</emxUtil:i18n>
<%
    StateList stateList = part.getStates(context);
    int stateCnt = stateList.size();
    for (int i = 0; i < stateCnt; i++)
    {
      State state = (State)stateList.elementAt(i);
       String stateName = state.getName();
%>
//XSSOK
       <option value = "<%=stateName%>"><%=stateName%>
<%
    }
%>
    </select>
</td>
</tr>
--%>

</table>
<!-- <input type="image" name="inputImage" height="1" width="1" src="../common/images/utilSpacer.gif" hidefocus="hidefocus"
style="-moz-user-focus: none" /> -->
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
