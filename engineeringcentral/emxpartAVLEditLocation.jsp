<%--  emxpartAVLEditLocation.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>

<head>
  <%@include file = "../common/emxUIConstantsInclude.inc"%>
  <script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
</head>

<%!
   private static final String ATTRIBUTES_NONE = "emxEngineeringCentral.Part.AVL.None";
   private static final String LOCATIONSTATUS = "Location Status";
   private static final String LOCATIONPREFERENCE = "Location Preference";
   private static final String LOCATIONNAME = "Location Name";
   private static final String LOCATIONTYPE = "Location Type";
   private static final String SELECTED = "Selected";
   private static final String ALL = "All";
%>
<% 
   boolean isMepConnected = true;
  String languageStr = request.getHeader("Accept-Language");
  String objectId = emxGetParameter(request,"objectId"); // part object id
  //String locationId = (String)session.getValue("locationId");
  String locationId = (String)session.getAttribute("locationId");
  String parentOID = emxGetParameter(request,"parentOID");

  Part part = (Part)DomainObject.newInstance(context,
                  DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);
  part.setId(objectId);

DomainRelationship relObject = null;
MapList locationList = new MapList();
//com.matrixone.apps.common.Person person = (com.matrixone.apps.common.Person)DomainObject.newInstance(context,       DomainConstants.TYPE_PERSON);
String hostCompId = com.matrixone.apps.common.Person.getPerson(context).getCompany(context).getObjectId(context);

if (part.getInfo(context,DomainObject.SELECT_TYPE).equals(DomainConstants.TYPE_APPLICATION_PART)){
    locationList = part.getApplicationPartData(context, locationId, objectId);
}
else {
    if (hostCompId.equals(locationId))
    {
        locationList = part.getMEPartData(context, objectId, locationId, true);
    }
    else {
        locationList = part.getMEPartData(context, objectId, locationId, false);
    }
}

DomainObject locObject = new DomainObject();
String locId = "";
String relId = "";
String mepId = "";

ListIterator i = locationList.listIterator();
while (i.hasNext())
{
   Map map = (Map) i.next();
   mepId = (String) map.get("mePartId");
   if(mepId!=null && !mepId.equals("") && !mepId.equals("null")) {
       locObject.setId(mepId);
       if(locObject.getInfo(context, DomainConstants.SELECT_TYPE).equals(DomainConstants.TYPE_MPN)) {
            i.remove();
            continue;
       }
       locId = (String) map.get("Location Id");
       relId = (String) map.get("Allocation Responsibility Id");
       if (relId!=null && !("").equals(relId)){
           isMepConnected = true;
       locObject.setId(locId);
       StringList objSelects  = new StringList(2);
       objSelects.addElement(DomainObject.SELECT_NAME);
       objSelects.addElement(DomainObject.SELECT_TYPE);
       Map resultsMap = locObject.getInfo(context,objSelects);
       /*map.put(LOCATIONNAME, locObject.getName(context));
       map.put(LOCATIONTYPE, locObject.getType(context));*/
       map.put(LOCATIONNAME, (String)resultsMap.get(DomainObject.SELECT_NAME));
       map.put(LOCATIONTYPE, (String)resultsMap.get(DomainObject.SELECT_TYPE));
       map.put("City", locObject.getAttributeValues(context, "City").getValue());
       map.put("State", locObject.getAttributeValues(context, "State/Region").getValue());
       map.put("Postal Code", locObject.getAttributeValues(context, "Postal Code").getValue());
       map.put("Country", locObject.getAttributeValues(context, "Country").getValue());
       relObject = new DomainRelationship(relId);
       map.put(LOCATIONSTATUS, relObject.getAttributeValue(context, DomainConstants.ATTRIBUTE_LOCATION_STATUS));
       map.put(LOCATIONPREFERENCE, relObject.getAttributeValue(context, DomainConstants.ATTRIBUTE_LOCATION_PREFERENCE));
      }
   } else {
       continue;
   }
}

    int x = 0;
 // retreive the range values of Location Preference Attribute
//added code for the bug 306505 Issue 7
 //StringList strListLocPreference = FrameworkUtil.getRanges(context, DomainConstants.ATTRIBUTE_LOCATION_PREFERENCE);
StringList strListLocPreference = JSPUtil.getCentralProperties(application, session, "eServiceEngineeringCentral", "AVLLocationPreferencesFilter");
// retreive the range values of Location Status Attribute
//StringList strListLocStatus = FrameworkUtil.getRanges(context, DomainConstants.ATTRIBUTE_LOCATION_STATUS);
StringList strListLocStatus =JSPUtil.getCentralProperties(application, session, "eServiceEngineeringCentral", "AVLLocationStatusFilter");
//added code for the bug 306505 Issue 7
%>
<%@include file = "emxengchgJavaScript.js" %>
<script language="javascript">
  var store = new Array();
  store[0] = new Array(1);
<%
     // iterate the Location Status Range Values StringList and populate the javascript Array
     String str = "";
     if (strListLocStatus != null && strListLocStatus.size() > 0) {
           StringItr strStatusItr = new StringItr(strListLocStatus);
           while (strStatusItr.next()) {
		   
               if (("").equals(str)){
//added code for the bug 306505 Issue 7
				  str = "\""+EngineeringUtil.i18nStringNow(context,strStatusItr.obj(),languageStr)+"\"";
               } else {
                  str = str + ",\""+EngineeringUtil.i18nStringNow(context,strStatusItr.obj(),languageStr)+"\"";
//added code for the bug 306505 Issue 7
               }
           }
     }
%>
//XSSOK
  store[1] = new Array(<%=str%>);
<%
     // iterate the Location Preference Range Values StringList and populate the javascript Array
     if (strListLocPreference != null && strListLocPreference.size() > 0) {
         StringItr strPreferenceItr = new StringItr(strListLocPreference);
         str = "";
         while (strPreferenceItr.next()) {
              if (("").equals(str)){
//added code for the bug 306505 Issue 7
				  str = "\""+EngineeringUtil.i18nStringNow(context,strPreferenceItr.obj(),languageStr)+"\"";
              } else {
                  str = str + ",\""+EngineeringUtil.i18nStringNow(context,strPreferenceItr.obj(),languageStr)+"\"";
//added code for the bug 306505 Issue 7
			  }
         }

      }


%>
//XSSOK
  store[2] = new Array(<%=str%>);
  // This javascript function is used to populate the rangeCombo based on the Value selected in attributeCombo.
  function populateCombo() {
     var indx = document.editForm.attributeCombo.selectedIndex;
     var list = store[indx];
      document.forms['editForm'].rangeCombo.options.length = 0;
     for(i=0;i<list.length;i++)
     {
         document.forms['editForm'].rangeCombo.options[i] = new Option(list[i],list[i]);
     }
  }
  // This function is used to submit the page to the process page.
  function submit() {
       document.editForm.action = "emxpartAVLEditLocationProcess.jsp";
       document.editForm.submit();
  }
  // This method is used to set the attribute value selected by the user for the selected rows.
function updateSelectedLocations() {
       var chkprefix = "checkbox";
       var attributeIndex = document.editForm.attributeCombo.selectedIndex;
       var attributeValue = document.editForm.attributeCombo.options[document.editForm.attributeCombo.selectedIndex].value;
		//XSSOK
       if (attributeValue != '<%=ATTRIBUTES_NONE%>') {
           var selectedIndex = document.editForm.rangeCombo.selectedIndex;
           var selectedValue = document.editForm.rangeCombo.options[document.editForm.rangeCombo.selectedIndex].value;
           var selectCheck = "false";

           for (var i = 1; i<document.editForm.elements.length; i++) {
              var CheckboxObj = document.editForm.elements[i];
              if(CheckboxObj.type == "checkbox") {
                  var chkboxName = CheckboxObj.name;
                     if (CheckboxObj.checked == true && chkboxName != "checkAll") {
                         // if first attribute in the attributeCombo is selected
                         if (attributeIndex==1)
                         {
                             index = chkboxName.substring(chkprefix.length,chkboxName.length);
                             var statuscombo = eval("document.editForm.statusCombo"+index);
                             statuscombo.options[selectedIndex].selected = true;
                          }
                          else if (attributeIndex==2){
                             // if second attribute in the attributeCombo is selected
                              index = chkboxName.substring(chkprefix.length,chkboxName.length);
                              var preferencecombo = eval("document.editForm.preferenceCombo"+index);
                              preferencecombo.options[selectedIndex].selected = true;
                          }

                          selectCheck = "true";
                     }
              }// if checkbox
           }// for
   		   if (selectCheck == "false")
		   alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.AVL.SelectLocation</emxUtil:i18nScript>");
       }
       else{ //if
		   alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.AVL.SelectColumnValue</emxUtil:i18nScript>");
	   }
  }// function

// This method is used to set the attribute value selected by the user for all the rows.
function updateAll() {
       var status = "statusCombo";
       var preference = "preferenceCombo";
       var attributeIndex = document.editForm.attributeCombo.selectedIndex;
       var attributeValue = document.editForm.attributeCombo.options[document.editForm.attributeCombo.selectedIndex].value;
     //XSSOK
       if (attributeValue != '<%=ATTRIBUTES_NONE%>') {
           var selectedIndex = document.editForm.rangeCombo.selectedIndex;
           if (selectedIndex != -1) {
               var selectedValue = document.editForm.rangeCombo.options[document.editForm.rangeCombo.selectedIndex].value;
           }
           for (var i = 1; i<document.editForm.elements.length; i++) {
               var obj = document.editForm.elements[i];
               if(obj.type == "select-one") {
                 var objname = obj.name;
                  if (attributeIndex==1) {
                     if (objname.indexOf(status,0) > -1) {
                         index = objname.substring(status.length,objname.length);
                         var statuscombo = eval("document.editForm.statusCombo"+index);
                         statuscombo.options[selectedIndex].selected = true;
                     }
                 }
                   else if (attributeIndex==2){
                       if (objname.indexOf(preference,0) > -1){
                          index = objname.substring(preference.length,objname.length);
                          var preferencecombo = eval("document.editForm.preferenceCombo"+index);
                          preferencecombo.options[selectedIndex].selected = true;
                       }
                 }
               }
          }// for
    }
    else{//if
		 alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.AVL.SelectColumnValue</emxUtil:i18nScript>");
	}
}// function

// The function is used to select the checkboxes of all the rows when the header checkbox is selected.
// the 'allSelected()' method of emxengchgJavaScript.js is overwridden.
// in the allSelected(), the header checkbox is hardcoded as the 0th element.
function selectAll(formName)
{
       var operand = "";
       var bChecked = false;
       var count = eval("document." + formName + ".elements.length");
       var typeStr = "";
       //retrieve the checkAll's checkbox value
       var allChecked = eval("document." + formName + ".checkAll.checked");
       for(var i = 1; i < count; i++)
       {
          operand = "document." + formName + ".elements[" + i + "].checked";
          typeStr = eval("document." + formName + ".elements[" + i + "].type");
          if(typeStr == "checkbox" )
          {
             operand += " = " + allChecked + ";";
             eval (operand);
          }
       }
       return;
  }
// The below javascript function is used to deselect the header checkbox, even if one row not selected.
function deselectHeaderChkbox(formName) {
   var count = eval("document." + formName + ".elements.length");
   var bFirstCheckBox = true;
   var bChecked = true;
   var typeStr ="";
   for(var i = 0; i < count; i++)
   {
           typeStr = eval("document." + formName + ".elements[" + i + "].type");
           if(typeStr == "checkbox" )
           {
               if (bFirstCheckBox) {
                       bFirstCheckBox = false;
                       continue;
               }
               bChecked = eval("document." + formName + ".elements[" + i + "].checked");
               if(bChecked==false) {
                    document.editForm.checkAll.checked = false;
                    return;
               }

           }
   }
   document.editForm.checkAll.checked = true;
   return;
}

</script>

<!--Added for IR-118698V6R2012x start -->
<script language="Javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
 </script>
 <!--Added for IR-118698V6R2012x end -->
 
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
  <form name="editForm" method="post">
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="totalrows" value="-1" />
  <table width="100%" border="0">
      <tr>
        <td class="label" width="15%" align="left"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Part.AVL.ColumnValue</emxUtil:i18n></td>
<%
       // Get options of Attributes list to be displayed in the attributeCombo
       StringList attributesList = JSPUtil.getCentralProperties(application, session, "eServiceEngineeringCentral", "AVLAttributesFilter");


%>
         <td class="inputField" width="30%" align="left">
             <select name="attributeCombo" onChange="populateCombo()">
<%
            if (attributesList != null && attributesList.size() > 0) {
                   StringItr strAttributesItr = new StringItr(attributesList);
                   String attrChoice = "";
                   while (strAttributesItr.next()) {
                        attrChoice = strAttributesItr.obj();

%>
					<!-- XSSOK -->
                    <option value="<%=attrChoice%>"><%=EngineeringUtil.i18nStringNow(context,attrChoice,languageStr)%></option>
<%

                   }
            } else {
%>
				<!-- XSSOK -->
                  <option value="<%=ATTRIBUTES_NONE%>"><%=EngineeringUtil.i18nStringNow(context,ATTRIBUTES_NONE,languageStr)%></option>
<%
           }
%>
              </select>
             <select name="rangeCombo" style="WIDTH: 175px">
              </select>
         </td>
<%
         // get the apply selected button name
         String applySelected = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Part.AVL.ApplySelected",languageStr);

         // get the apply all button name
         String applyAll = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Part.AVL.ApplyAll",languageStr);
%>
<!-- XSSOK -->
         <td width=30% align="right"><input type="button" name="ApplySelected" value="<%=applySelected%>" onClick="Javascript:updateSelectedLocations()" />
         <!-- XSSOK -->
         <input type="button" name="ApplyAll" value="<%=applyAll%>" onClick="Javascript:updateAll()" /></td>
     </tr>
  </table>
  
 <!-- <table width="100%" border="0" cellpadding="3" cellspacing="2"> -->  <!--Modified for IR-118698V6R2012x -->
  <table class="list">   
    <tr>
      <th><input type="checkbox" name="checkAll" onClick="selectAll('editForm')" /></th>
      <th nowrap="nowrap">
             <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Name</emxUtil:i18n>
      </th>
      <th nowrap="nowrap">
              <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Type</emxUtil:i18n>
      </th>
      <th nowrap="nowrap">
               <emxUtil:i18n localize="i18nId">emxEngineeringCentral.PersonDialog.City</emxUtil:i18n>
      </th>
      <th nowrap="nowrap">
               <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.State</emxUtil:i18n>
      </th>
      <th nowrap="nowrap">
               <emxUtil:i18n localize="i18nId">emxEngineeringCentral.PersonDialog.PostalCode</emxUtil:i18n>
      </th>
      <th nowrap="nowrap">
               <emxUtil:i18n localize="i18nId">emxEngineeringCentral.PersonDialog.Country</emxUtil:i18n>
      </th>
      <th nowrap="nowrap">
               <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Status</emxUtil:i18n>
      </th>
      <th nowrap="nowrap">
               <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Part.AVL.Preference</emxUtil:i18n>
      </th>
    </tr>
    <!-- XSSOK -->
<fw:mapListItr mapList="<%= locationList %>" mapName="resultsMap">
<%
if (resultsMap.get("Location Id")!= null && !("").equals(resultsMap.get("Location Id"))) {
%>
      <tr>
      <!-- XSSOK -->
     <td width = "3%"><input type="checkbox" name="checkbox<%=x%>" value="<xss:encodeForHTMLAttribute><%=resultsMap.get("Allocation Responsibility Id")%></xss:encodeForHTMLAttribute>" onClick="Javascript:deselectHeaderChkbox('editForm')" /></td>
     <!-- XSSOK -->
            <input type="hidden" name="relId<%=x%>" value="<xss:encodeForHTMLAttribute><%=resultsMap.get("Allocation Responsibility Id")%></xss:encodeForHTMLAttribute>" />
<%
      // get the type image
      String typeIcon = null;
      String alias = FrameworkUtil.getAliasForAdmin(context, "type", DomainConstants.TYPE_LOCATION, true);
       if ((alias == null) || (alias.equals("")) || (alias.equals("null"))){
        typeIcon = JSPUtil.getCentralProperty(application, session, "type_Default", "SmallIcon");
      }else{
        typeIcon = JSPUtil.getCentralProperty(application, session, alias, "SmallIcon");
      }
%>
      <td>
        <table>
          <tr>
          <!-- XSSOK -->
          <td><img src="../common/images/<%=typeIcon%>" border="0" /></td>
          <td><xss:encodeForHTML><%=(String)resultsMap.get(LOCATIONNAME)%></xss:encodeForHTML></td>
          </tr>
        </table>
      </td>
      <td><xss:encodeForHTML><%=(String)resultsMap.get(LOCATIONTYPE)%></xss:encodeForHTML></td>
      <td><xss:encodeForHTML><%=(String)resultsMap.get("City")%></xss:encodeForHTML></td>
      <td><xss:encodeForHTML><%=(String)resultsMap.get("State")%></xss:encodeForHTML></td>
      <td><xss:encodeForHTML><%=(String)resultsMap.get("Postal Code")%></xss:encodeForHTML></td>
      <td><xss:encodeForHTML><%=(String)resultsMap.get("Country")%></xss:encodeForHTML></td>
         <td class="inputField">
         <!-- XSSOK -->
                <select name="statusCombo<%=x%>">
<%
String statusChoice_en="";
String preferenceChoice_en="";
         if (strListLocStatus != null && strListLocStatus.size() > 0) {
               StringItr strStatusItr = new StringItr(strListLocStatus);
               while (strStatusItr.next()) {
                    String statusChoice = strStatusItr.obj();
                    statusChoice_en=EngineeringUtil.i18nStringNow(context,statusChoice,"en-us");
                    statusChoice=EngineeringUtil.i18nStringNow(context,statusChoice,languageStr);
                   
                    if (statusChoice_en.equals((String)resultsMap.get(LOCATIONSTATUS))) {
%>
<!-- XSSOK -->
<option value="<%=statusChoice_en%>"<%=SELECTED%>><%=statusChoice%></option>
<%
                    } else {
%>
					<!-- XSSOK -->
                   <option  value="<%=statusChoice_en%>"><%=statusChoice%></option>
<%
                    }
               }//while
         }
         else {
                   String statusvalue = (String)resultsMap.get(LOCATIONSTATUS);
%>
					<!-- XSSOK -->
                   <option value="<%=statusvalue%>"><%=statusvalue%></option>
<%
         }
%>
              </select></td>
         <td class="inputField">
         <!-- XSSOK -->
                <select name="preferenceCombo<%=x%>">
<%
         if (strListLocPreference != null && strListLocPreference.size() > 0) {
               StringItr strPreferenceItr = new StringItr(strListLocPreference);
               while (strPreferenceItr.next()) {
                    String preferenceChoice = strPreferenceItr.obj();
                    preferenceChoice_en=EngineeringUtil.i18nStringNow(context,preferenceChoice,"en-us");
                    preferenceChoice=EngineeringUtil.i18nStringNow(context,preferenceChoice,languageStr);
                    if (preferenceChoice_en.equals((String)resultsMap.get(LOCATIONPREFERENCE))) {
%>
<!-- XSSOK -->
<option value="<%=preferenceChoice_en%>"<%=SELECTED%>><%=preferenceChoice%></option>
<%
                    } else {
%>
					<!-- XSSOK -->
                   <option  value="<%=preferenceChoice_en%>"><%=preferenceChoice%></option>
<%
                    }
               }//while
         }
         else {
                   String preferencevalue = (String)resultsMap.get(LOCATIONPREFERENCE);
%>
					<!-- XSSOK -->
                   <option value="<%=preferencevalue%>"><%=preferencevalue%></option>
<%
         }
%>
              </select></td>
    </tr>
<%
    x = x + 1;
%>
<script language="javascript">
<!-- XSSOK -->
     document.editForm.totalrows.value = "<%=x%>";
</script>
<%
}
%>
  </fw:mapListItr>
  </table>
<%
   if (!isMepConnected) {
%>
       <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Part.AVL.NoMepConnected</emxUtil:i18n>
<%
    }
%>
  </form>
  <%@include file = "../emxUICommonEndOfPageInclude.inc" %>
