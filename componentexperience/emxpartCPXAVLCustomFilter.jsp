<%--
  emxpartCPXAVLCustomFilter.jsp
  © Dassault Systemes, 1993 - 2010.  All rights reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
--%>

<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<emxUtil:localize id="i18nId" bundle="emxEngineeringCentralStringResource" locale='<%= request.getHeader("Accept-Language") %>' />

<%
//
// NOTE: Changes in this file are extended from engineeringcentral\emxpartAVLCustomFilter.jsp
//       If any issues, always refer to original source.
//

// tableID parameter will is the key to obtain the current table data.
String tableID = Request.getParameter(request, "tableID");
// Get the Person Object
com.matrixone.apps.common.Person person = (com.matrixone.apps.common.Person)DomainObject.newInstance(context, DomainConstants.TYPE_PERSON);

StringList resultSelects = new StringList(2);
resultSelects.addElement(DomainObject.SELECT_NAME);
resultSelects.addElement(DomainObject.SELECT_ID);

Map companyMap = person.getPerson(context).getCompany(context).getInfo(context,resultSelects);
// Get the Default Company Name of the User and it's id.
String locationName = (String)companyMap.get(DomainObject.SELECT_NAME);
String locationId = (String)companyMap.get(DomainConstants.SELECT_ID);

// Put the Location Id in session. As these parameters are to be passed to edit locations screen.
  session.setAttribute("locationId", locationId);
String language         = request.getHeader("Accept-Language");

String useBOMQualification = UINavigatorUtil.getI18nString("emxComponentExperience.AVL.UseBOMQualification","emxComponentExperienceStringResource",language);


%>
<script language="Javascript" >
    var bChecked = false;
    // this javascript function is used to display the Company/Locations selection page.
    function showLocationSelector() {
showModalDialog("../common/emxSearch.jsp?defaultSearch=ENCFindCompany&typename=Company&toolbar=ENCFindLocationsToolBar&title=Company&rowselect=single&isAVLReport=TRUE&fieldNameDisplay=locationName&fieldNameId=locationId", 500, 500);
    }

// this javascript function is used to set the Location Name and Location Id selected by the User

function setLocation(locId,locName) {
     document.getAVLBOMCustomFilter.locationName.value=locName;
     document.getAVLBOMCustomFilter.locationId.value=locId;
  }

// this javascript function is used to reset the location Name and Id to the default Location of the user.
  function resetLocation()
  {
    bChecked = eval("document.getAVLBOMCustomFilter.allLocations.checked");
    if (bChecked == false){
        document.getAVLBOMCustomFilter.locationName.value = "<%=locationName%>";
        document.getAVLBOMCustomFilter.locationId.value = "<%=locationId%>";
    }
  }

// this javascript function is used to set the location Name and Id if the user selects the All checkbox and
// clear the locations filter input field.
  function updateLocation()
  {
     bChecked = eval("document.getAVLBOMCustomFilter.allLocations.checked");
     if (bChecked == false){
         document.getAVLBOMCustomFilter.locationName.value="<%=locationName%>";
         document.getAVLBOMCustomFilter.locationId.value = "<%=locationId%>";
         document.getAVLBOMCustomFilter.ellipse.disabled=false;
     }
     else  {
         document.getAVLBOMCustomFilter.locationName.value="";
         document.getAVLBOMCustomFilter.locationId.value="All";
         document.getAVLBOMCustomFilter.ellipse.disabled=true;
     }
  }

  function updateBOMQualification()
    {
       bChecked = eval("document.getAVLBOMCustomFilter.bomQualification.checked");

       if (bChecked)
           document.getAVLBOMCustomFilter.useBOMQualification.value="true";
      else
           document.getAVLBOMCustomFilter.useBOMQualification.value="false";

  }


  // this javascript function is used to submit the values to the process page when the user clicks on Fiter Button
  function refreshReport()
  {
        document.getAVLBOMCustomFilter.action="emxpartCPXAVLCustomFilterProcess.jsp";
        document.getAVLBOMCustomFilter.target = "listHidden";
        document.getAVLBOMCustomFilter.submit();
  }
</script>
<%@ include file = "../emxUICommonHeaderEndInclude.inc"%>

<form name="getAVLBOMCustomFilter">
<input type="hidden" name="tableID" value="<xss:encodeForHTMLAttribute><%=tableID%></xss:encodeForHTMLAttribute>">
<table border="0" width="70%">
<tr>
        <td class="label"><label for="part"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Part.AVL.CompanyLocation</emxUtil:i18n></label></td>
        <td class="inputField">
        <input type="text" size="25" name="locationName" value="<xss:encodeForHTMLAttribute><%=locationName%></xss:encodeForHTMLAttribute>" onFocus="this.blur();"></td>
        	<td><input type=button name="ellipse" value="..." onClick="Javascript:showLocationSelector()"></td>
        	<td><a href="JavaScript:resetLocation()"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Reset</emxUtil:i18n></a></td>
        <input type="hidden" value="<xss:encodeForHTMLAttribute><%=locationId%></xss:encodeForHTMLAttribute>" name="locationId">
        <td><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Or</emxUtil:i18n></td>
        <td><input type="checkbox" name="allLocations" value="" onClick="javascript:updateLocation()"></td>
        <td><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.All</emxUtil:i18n></td>

        <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.ReferenceDesignator</emxUtil:i18n></td>

        <td>
           <select class="filter"  name="filterTable" >
             <option value="emxPart:getEBOMsWithRelSelectables" selected > <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOMReferenceDesignator.StoredFormat </emxUtil:i18n></option>
             <option value="emxPart:getExpandedEBOM" > <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOMReferenceDesignator.ExpandedFormat </emxUtil:i18n></option>
             <option value="emxPart:getDelimitedRollupEBOM"  > <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOMReferenceDesignator.DelimitedRoll-upFormat</emxUtil:i18n> </option>
             <option value="emxPart:getRangeRollupEBOM"  > <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOMReferenceDesignator.RangeRoll-upFormat</emxUtil:i18n> </option>
           </select>
        </td>

        <td><input type="checkbox" name="bomQualification" value="" onClick="updateBOMQualification()"></td>
        <td class="label"><%=useBOMQualification%></td>
        <input type="hidden" value="false" name="useBOMQualification">





<%
String filterString = com.matrixone.apps.engineering.EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.Filter",(String)request.getHeader("Accept-Language"));
%>
        <td><input type=button name="filter" value="<%=filterString%>" onClick="javascript:refreshReport()"></td>
</tr>
</table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

