<%--  emxpartAVLCustomFilter.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<!-- XSSOK -->
<emxUtil:localize id="i18nId" bundle="emxEngineeringCentralStringResource" locale='<%= request.getHeader("Accept-Language") %>' />
 
<%
// tableID parameter will is the key to obtain the current table data.
String tableID = emxGetParameter(request,  "tableID");
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
 
%>
<script language="Javascript" >
    var bChecked = false;
    // this javascript function is used to display the Company/Locations selection page.
    function showLocationSelector() {
    	
       	showModalDialog("../common/emxFullSearch.jsp?field=TYPES=type_Organization,type_Company,type_BusinessUnit,type_Department,type_Location:CURRENT=state_Active&suiteKey=EngineeringCentral&HelpMarker=emxhelpfullsearch&table=AEFGeneralSearchResults&fieldNameDisplay=location&fieldNameActual=location&hideHeader=true&selection=single&submitURL=AEFSearchUtil.jsp&targetLocation=popup", 500, 500);

    }

// this javascript function is used to set the Location Name and Location Id selected by the User

function setLocation(locId,locName) {
     document.getAVLBOMCustomFilter.location.value=locName;
     document.getAVLBOMCustomFilter.locationOID.value=locId;
  }

// this javascript function is used to reset the location Name and Id to the default Location of the user.
  function resetLocation()
  {
    bChecked = eval("document.getAVLBOMCustomFilter.allLocations.checked");
    if (bChecked == false){
    	//XSSOK
        document.getAVLBOMCustomFilter.location.value = "<%=locationName%>";
        //XSSOK
        document.getAVLBOMCustomFilter.locationOID.value = "<%=locationId%>";
    }
  }

// this javascript function is used to set the location Name and Id if the user selects the All checkbox and
// clear the locations filter input field.
  function updateLocation()
  {
     bChecked = eval("document.getAVLBOMCustomFilter.allLocations.checked");
     if (bChecked == false){
    	//XSSOK
         document.getAVLBOMCustomFilter.location.value="<%=locationName%>";
       //XSSOK
         document.getAVLBOMCustomFilter.locationOID.value = "<%=locationId%>";
         document.getAVLBOMCustomFilter.ellipse.disabled=false;
     }
     else  {
          document.getAVLBOMCustomFilter.location.value="";
        document.getAVLBOMCustomFilter.locationOID.value="All";
         document.getAVLBOMCustomFilter.ellipse.disabled=true;
     }
  }

  // this javascript function is used to submit the values to the process page when the user clicks on Fiter Button
  function refreshReport()
  {
        document.getAVLBOMCustomFilter.action="emxpartAVLCustomFilterProcess.jsp";
        document.getAVLBOMCustomFilter.target = "listHidden";
        document.getAVLBOMCustomFilter.submit();
  }
</script>
<%@ include file = "../emxUICommonHeaderEndInclude.inc"%>

<form name="getAVLBOMCustomFilter">
<input type="hidden" name="tableID" value="<xss:encodeForHTMLAttribute><%=tableID%></xss:encodeForHTMLAttribute>" />
<table width="100%">
<tr>
        <td class="label"><label for="part"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Part.AVL.CompanyLocation</emxUtil:i18n></label></td>
      
        <td class="inputField"><input type="text" size="25" name="location" onfocus="this.blur();" value="<xss:encodeForHTMLAttribute><%=locationName%></xss:encodeForHTMLAttribute>" />        
        <input type="button" name="ellipse" value="..." onClick="Javascript:showLocationSelector()" />
        <a href="JavaScript:resetLocation()"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Reset</emxUtil:i18n></a></td>
      
        <input type="hidden" name="locationOID" value="<xss:encodeForHTMLAttribute><%=locationId%></xss:encodeForHTMLAttribute>" />
         
        <td class="inputField"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Or</emxUtil:i18n>
        <input type="checkbox" name="allLocations" value="" onClick="javascript:updateLocation()" />
        <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.All</emxUtil:i18n></td>
        <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.ReferenceDesignator</emxUtil:i18n></td>
        <td class="inputField">        
           <select class="filter"  name="filterTable" >
             <option value="emxPart:getEBOMsWithRelSelectables" selected > <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOMReferenceDesignator.StoredFormat </emxUtil:i18n></option>
             <option value="emxPart:getExpandedEBOM" > <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOMReferenceDesignator.ExpandedFormat </emxUtil:i18n></option>
             <option value="emxPart:getDelimitedRollupEBOM"  > <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOMReferenceDesignator.DelimitedRoll-upFormat</emxUtil:i18n> </option>
             <option value="emxPart:getRangeRollupEBOM"  > <emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOMReferenceDesignator.RangeRoll-upFormat</emxUtil:i18n> </option>
           </select>
        </td>


<%
String filterString = com.matrixone.apps.engineering.EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.Filter",request.getHeader("Accept-Language"));
%>
<!-- XSSOK -->
        <td class="label"><input type="button" name="filter" value="<%=filterString%>" onClick="javascript:refreshReport()" /></td>
</tr>
</table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>


