<%--emxbomCPXMLBOMReportDialog.jsp
  © Dassault Systemes, 1993 - 2010.  All rights reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
        static const char RCSID[] =$Id: emxbomCPXMLBOMReportDialog.jsp.rca 1.40 Wed Oct 22 16:21:20 2008 przemek Experimental przemek $
--%>
<%@ include file = "../engineeringcentral/emxDesignTopInclude.inc"%>
<%@ include file = "../engineeringcentral/emxEngrVisiblePageInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<%@ include file = "../engineeringcentral/emxengchgJavaScript.js"%>
<%@ include file = "../emxJSValidation.inc" %>
<%@include file = "../emxI18NMethods.inc"%>
<%@ page import = "matrix.db.*,
                   matrix.util.* , 
                   com.matrixone.servlet.*,
                   java.io.*,
                   java.net.URLEncoder,
                   java.util.*,
                   java.text.*" errorPage="../common/eServiceError.jsp"%>

<%@ page import =  "com.matrixone.apps.common.BuyerDesk,
                    com.matrixone.apps.common.BusinessUnit,
                    com.matrixone.apps.common.Company,
                    com.matrixone.apps.common.CertificationHolder,
                    com.matrixone.apps.common.Document,
                    com.matrixone.apps.common.DocumentHolder,
                    com.matrixone.apps.common.FileFormatHolder,
                    com.matrixone.apps.common.InboxTask,
                    com.matrixone.apps.common.Location,
                    com.matrixone.apps.common.MarkupHolder,
                    com.matrixone.apps.common.Message,
                    com.matrixone.apps.common.MessageHolder,
                    com.matrixone.apps.common.MultipleOwner,
                    com.matrixone.apps.common.Organization,
                    com.matrixone.apps.common.OrganizationList,
                    com.matrixone.apps.common.Person,
                    com.matrixone.apps.common.PurchaseClassHolder,
                    com.matrixone.apps.common.Route,
                    com.matrixone.apps.common.RouteHolder,
                    com.matrixone.apps.common.RouteTemplate,
                    com.matrixone.apps.common.SketchHolder,
                    com.matrixone.apps.common.Subscribable,
                    com.matrixone.apps.common.SubscriptionManager,
                    com.matrixone.apps.common.VaultHolder,
                    com.matrixone.apps.common.Workspace,
                    com.matrixone.apps.common.WorkspaceVault" %>

<%@ page import = "com.matrixone.apps.engineering.*,
                   com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*"
%>

<%
  // Fix for IR-134370V6R2013
  com.matrixone.apps.engineering.Part part = (com.matrixone.apps.engineering.Part)DomainObject.newInstance(context,
                    DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);
  String languageStr  = request.getHeader("Accept-Language");
  String strRelEBOM       = PropertyUtil.getSchemaProperty(context, "relationship_EBOM");
  String strRelEBOMHistory= PropertyUtil.getSchemaProperty(context, "relationship_EBOMHistory");
  String strAnd   = i18nStringNowUtil("emxEngineeringCentral.Common.And", "emxEngineeringCentralStringResource",languageStr);
  String EbomAndEbomHistory =strRelEBOM +","+ strRelEBOMHistory;
  String strEbomAndEbomHistory =i18nStringNowUtil("emxEngineeringCentral.EBOM.EBOMAndEBOMHistoryRel", "emxEngineeringCentralStringResource",languageStr);

  String strRel   = i18nStringNowUtil("emxEngineeringCentral.Common.Relationship", "emxEngineeringCentralStringResource",languageStr);

  String qtyMessage       = i18nStringNowUtil("emxEngineeringCentral.EBOM.LevelHasToBeAWholeNumber", "emxEngineeringCentralStringResource",languageStr);

  String allString       = i18nStringNowUtil("emxEngineeringCentral.Common.All", "emxEngineeringCentralStringResource",languageStr);

  String levelStr       = i18nStringNowUtil("emxEngineeringCentral.Common.Levels", "emxEngineeringCentralStringResource",languageStr);
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

 
  //commented code for the bug 306505
  //String subHeader = partType + "|";
  //commented code for the bug 306505
  // Get default vaule with levels to expand the structure
  String sLevel = JSPUtil.getCentralProperty(application, session, "eServiceToolbarMLBM" ,"DefaultLevelToExpand");
  if (sLevel == null)
  {
    sLevel = "3";  // If not defined in properties set a default value
  }


  String useBOMQualification = UINavigatorUtil.getI18nString("emxComponentExperience.AVL.UseBOMQualification","emxComponentExperienceStringResource",languageStr);
  String optionYes = UINavigatorUtil.getI18nString("emxComponentExperience.AVL.UseBOMQualification.Option.YES","emxComponentExperienceStringResource",languageStr);
  String optionNo = UINavigatorUtil.getI18nString("emxComponentExperience.AVL.UseBOMQualification.Option.NO","emxComponentExperienceStringResource",languageStr);

%>

<script language="Javascript" >

 function showLocationSelector() {
   //showModalDialog("../common/emxSearch.jsp?defaultSearch=ENCFindCompany&typename=Company&toolbar=ENCFindLocationsToolBar&title=Company&rowselect=single&helpMarker=emxhelpsearchcompany", 500, 500);
   //369746
   showModalDialog("../common/emxSearch.jsp?defaultSearch=ENCFindCompany&typename=Company&toolbar=ENCFindLocationsToolBar&title=Company&rowselect=single&helpMarker=emxhelpsearchcompany&isAVLReport=TRUE&fieldNameDisplay=locationName&fieldNameId=locationId", 500, 500);
 }

 function setLocation(locId,locName) {
     document.getMLBOMLevels.locationName.value=locName;
     document.getMLBOMLevels.locationId.value=locId;
  }

  function resetLocation()
  {
    document.getMLBOMLevels.locationName.value = "<%=locationName%>";
    document.getMLBOMLevels.locationId.value = "<%=locationId%>";
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
          parent.frames[0].document.progress.src = "../common/images/utilProgressDialog.gif";
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
        <%--subHeadLevel = "<%=allString%>";--%>
        subHeadLevel = "emxEngineeringCentral.Common.All";
    }

    else if (level != null && level !=""){
        subHeadLevel = level;
        
    }

    var varRelationship = document.getMLBOMLevels.relationship.options[document.getMLBOMLevels.relationship.selectedIndex].value;
    var relForSubHeader="";

    if (varRelationship =="<%=EbomAndEbomHistory%>") {
        <%--relForSubHeader = "<%=strEbomAndEbomHistory%>";--%>
        relForSubHeader = "emxEngineeringCentral.EBOM.EBOMAndEBOMHistoryRel";
    }
    else if (varRelationship =="<%=strRelEBOM%>") {
        <%--relForSubHeader = "<%=strRelEBOM%>";
        relForSubHeader += " ";
        relForSubHeader += "<%=strRel%>";--%>
        relForSubHeader = "emxEngineeringCentral.EBOM.EBOMRel";
    }
    //added code for the bug 306505 for Issue1 and Issue2
	//modifed for the bug no:-339130 
    <%--var subHead =  "<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.Part</emxUtil:i18nScript>"+" |";--%>
    var subHead =  "emxEngineeringCentral.Common.Part"+" |";
    //added code for the bug 306505 for Issue1 and Issue2
    subHead += relForSubHeader;
    subHead += "|";
<%
     if (displayPage.equalsIgnoreCase("AVL")) {
%>
        locationvar = document.getMLBOMLevels.locationName.value;
        locationIdValue = document.getMLBOMLevels.locationId.value;
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
winurl = "../common/emxTable.jsp?program=emxPart:getMultiLevelEBOMsWithRelSelectables,emxPart:getExpandedEBOM,emxPart:getDelimitedRollupEBOM,emxPart:getRangeRollupEBOM&programLabel=emxEngineeringCentral.EBOMReferenceDesignator.StoredFormat,emxEngineeringCentral.EBOMReferenceDesignator.ExpandedFormat,emxEngineeringCentral.EBOMReferenceDesignator.DelimitedRoll-upFormat,emxEngineeringCentral.EBOMReferenceDesignator.RangeRoll-upFormat&objectId=<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>&table=CPXAVLMLReport&suiteKey=EngineeringCentral&header=emxEngineeringCentral.Part.AVL.ConfigTableMultiLevelAVLSummary&level=0&relationship="+varRelationship+"&subHeader="+subHead+"&PrinterFriendly=true&HelpMarker=emxhelppartbomavlmulti&reportType=AVL&location="+locationIdValue+"&CancelLabel=emxEngineeringCentral.Common.Close&CancelButton=true&Style=Dialog&multilevelReport=Yes&incECRECOImage=true";
<%
        } else {
       // Building the URL if the display page is BOM Report.
       // Appended reportType and location parameters to the URL
%>
      //fix for bug 306455 - removed  sortColumnName & sortDirection parameter
       winurl = "../common/emxTable.jsp?program=emxPart:getMultiLevelEBOMsWithRelSelectables,emxPart:getExpandedEBOM,emxPart:getDelimitedRollupEBOM,emxPart:getRangeRollupEBOM&programLabel=emxEngineeringCentral.EBOMReferenceDesignator.StoredFormat,emxEngineeringCentral.EBOMReferenceDesignator.ExpandedFormat,emxEngineeringCentral.EBOMReferenceDesignator.DelimitedRoll-upFormat,emxEngineeringCentral.EBOMReferenceDesignator.RangeRoll-upFormat&objectId=<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>&table=ENCMultiLevelBOMSummary&suiteKey=EngineeringCentral&header=emxEngineeringCentral.Part.ConfigTableMultiLevelBOMSummary&level=0&relationship="+varRelationship+"&subHeader="+subHead+"&PrinterFriendly=true&HelpMarker=emxhelppartbommultilevelreport&reportType=BOM&location=&CancelLabel=emxEngineeringCentral.Common.Close&CancelButton=true&Style=Dialog&multilevelReport=Yes&incECRECOImage=true&sortColumnName=FN&sortDirection=ascending";
                  turnOnProgress(true);
          clicked = true;
<%
       }
%>
        winurl = fnEncode(winurl);
        parent.window.location.href = winurl;
      }
    }
    else if ((level >= <%=maxShort%>) || (level <= 0) || (!isNumeric(level)) || charExists(level, '.'))
    {
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
           url = "../common/emxTable.jsp?program=emxPart:getMultiLevelEBOMsWithRelSelectables,emxPart:getExpandedEBOM,emxPart:getDelimitedRollupEBOM,emxPart:getRangeRollupEBOM&programLabel=emxEngineeringCentral.EBOMReferenceDesignator.StoredFormat,emxEngineeringCentral.EBOMReferenceDesignator.ExpandedFormat,emxEngineeringCentral.EBOMReferenceDesignator.DelimitedRoll-upFormat,emxEngineeringCentral.EBOMReferenceDesignator.RangeRoll-upFormat&objectId=<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>&table=CPXAVLMLReport&suiteKey=EngineeringCentral&header=emxEngineeringCentral.Part.AVL.ConfigTableMultiLevelAVLSummary&level="+parseInt(level,10)+"&relationship="+varRelationship+"&subHeader="+subHead+"&PrinterFriendly=true&HelpMarker=emxhelppartbomavlmulti&reportType=AVL&location="+locationIdValue+"&CancelLabel=emxEngineeringCentral.Common.Close&CancelButton=true&Style=Dialog&multilevelReport=Yes&incECRECOImage=true";
<%
        } else {
       // Building the URL if the display page is BOM Report.
       // Appended reportType and location parameters to the URL
%>
  //fix for bug 306455 - removed  sortColumnName & sortDirection parameter
          url = "../common/emxTable.jsp?program=emxPart:getMultiLevelEBOMsWithRelSelectables,emxPart:getExpandedEBOM,emxPart:getDelimitedRollupEBOM,emxPart:getRangeRollupEBOM&programLabel=emxEngineeringCentral.EBOMReferenceDesignator.StoredFormat,emxEngineeringCentral.EBOMReferenceDesignator.ExpandedFormat,emxEngineeringCentral.EBOMReferenceDesignator.DelimitedRoll-upFormat,emxEngineeringCentral.EBOMReferenceDesignator.RangeRoll-upFormat&objectId=<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>&table=ENCMultiLevelBOMSummary&suiteKey=EngineeringCentral&header=emxEngineeringCentral.Part.ConfigTableMultiLevelBOMSummary&level="+parseInt(level,10)+"&relationship="+varRelationship+"&subHeader="+subHead+"&PrinterFriendly=true&HelpMarker=emxhelppartbommultilevelreport&reportType=BOM&location=&CancelLabel=emxEngineeringCentral.Common.Close&CancelButton=true&Style=Dialog&multilevelReport=Yes&incECRECOImage=true&sortColumnName=FN&sortDirection=ascending";
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
var nameHeading='<%=partName%>' +"<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.Revision</emxUtil:i18nScript>" +'<%= partRev%>';
</script>
<%
//String nameHeading = partName + " rev " + partRev;
//  added code for the bug 306505 Issue4
%>

<form name="getMLBOMLevels" method="post" action="" onSubmit="return false" target=_parent>
<table border="0" cellpadding="5" cellspacing="2" width="100%">

<tr>
<td width="150" class="label"><label for="part"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Part</emxUtil:i18n></label></td>
<%
    // Get the alias name for this type.  If there is an icon defined in the
    // EC properties file for this alias, then use it.  Otherwise, use the
    // default icon
    // TODO!  This could be smarter by figuring out if we already have this icon
    //        by using some sort of cache.
    //
    //String alias = FrameworkUtil.getAliasForAdmin(context, "type", partType, true);

    //if ((alias == null) || (alias.equals("null")) || (alias.equals("")))
    //  typeIcon = defaultTypeIcon;
    //else
    //  typeIcon = getEngrProperty(application, session, alias, "SmallIcon");

    // AVL Code
    // Getting the Default Image of the Type being displayed.
    String defaultTypeIcon    = JSPUtil.getCentralProperty(application, session, "type_Default", "SmallIcon");
    String typeIcon     = null;
    String alias = FrameworkUtil.getAliasForAdmin(context, "type", partType, true);
    if ((alias == null) || (alias.equals("null")) || (alias.equals(""))) {
       typeIcon = defaultTypeIcon;
    } else {
        typeIcon = JSPUtil.getCentralProperty(application, session, alias, "SmallIcon");
    }

%>
<!-- code added for the bug 306505 Issue4-->
<td class="field"><b><img src="../common/images/<%=typeIcon%>" border="0">&nbsp;<script>document.write(nameHeading)</script></b></td>
<!-- code added for the bug 306505  Issue4-->
</tr>

<tr>
<td width="150" class="labelRequired"><label for="Levels"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Levels</emxUtil:i18n></label></td>
<td class="inputField"><input type="text" name="level" id="" value="<xss:encodeForHTMLAttribute><%=sLevel%></xss:encodeForHTMLAttribute>" onfocus="javascript:alertLevelInput()">
</td>
</tr>

<tr>
   <td width="150" class="label">&nbsp;</td>
   <td class="inputField"><input type="checkbox" name="allLevels" value="" onClick="javascript:updatelevel()">
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
        <input type="text" size="25" name="locationName" value="<xss:encodeForHTMLAttribute><%=locationName%></xss:encodeForHTMLAttribute>" onFocus="this.blur();">
                <input type=button name="" value="..." onClick="Javascript:showLocationSelector()">
                 <a href="JavaScript:resetLocation()"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Reset</emxUtil:i18n></a>
              </td>
        </tr>
        <input type="hidden" value="<xss:encodeForHTMLAttribute><%=locationId%></xss:encodeForHTMLAttribute>" name="locationId">
<%
    }
  
%>
<tr>
   <td width="150" class="labelRequired"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Relationship</emxUtil:i18n></td>
   <td class="inputField">
    <select name="relationship" >
      <option value = "<%=EbomAndEbomHistory%>"><%=getAdminI18NString("Relationship",strRelEBOM,languageStr)+strSpace+ strAnd+strSpace+getAdminI18NString("Relationship",strRelEBOMHistory,languageStr)%>
      <option value = "<%=strRelEBOM%>"><%=getAdminI18NString("Relationship",strRelEBOM,languageStr)%>
    </select>
    </td>
</tr>

<tr>
   <td width="150" class="labelRequired"><%=useBOMQualification%></td>
   <td class="inputField">
   	<select name="useBOMQualification" >
	      <option value = "true"><%=optionYes%>
	      <option value = "false" selected="selected"><%=optionNo%>
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
       <option value = "<%=stateName%>"><%=stateName%>
<%
    }
%>
    </select>
</td>
</tr>
--%>

</table>
<input type="image" name="inputImage" height="1" width="1" src="../common/images/utilSpacer.gif" hidefocus="hidefocus"
style="-moz-user-focus: none" />
</form>
<%
  }
  catch(Exception e)
  {
	  e.printStackTrace();
      throw e;
  }
%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
