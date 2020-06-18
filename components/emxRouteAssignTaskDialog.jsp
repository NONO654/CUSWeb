<%--  emxRouteAssignTaskDialog  -  Create Dialog for Assign task
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program

   static const char RCSID[] = $Id: emxRouteAssignTaskDialog.jsp.rca 1.45 Wed Oct 22 16:17:43 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "emxComponentsJavaScript.js"%>
<%@ page import="com.matrixone.apps.common.util.ComponentsUtil" %>

<head>
  <%@include file = "../common/emxUIConstantsInclude.inc"%>
  <script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
</head>

<%
  String languageStr     = request.getHeader("Accept-Language");
  String projectId       = emxGetParameter(request, "objectId");
  String routeId         = emxGetParameter(request, "routeId");
  String routeTemplateId = emxGetParameter(request, "templateId");
  String scopeId         = emxGetParameter(request, "scopeId");
  String sTemplateName   = emxGetParameter(request, "templateName");
  String sSortName       = emxGetParameter(request, "sortName");
  String chkRouteAction  = emxGetParameter(request,"chkRouteAction");
  String selectedAction = emxGetParameter(request,"selectedAction");
  String supplierOrgId = emxGetParameter(request,"supplierOrgId");
  String portalMode      = emxGetParameter(request,"portalMode");

  if (selectedAction == null || selectedAction.equals("null") || selectedAction.equals(""))
    selectedAction = "false";
  String memberName = "";

  StringBuffer sParams = new StringBuffer("objectId=");
  sParams.append(XSSUtil.encodeForURL(context,projectId));
  sParams.append("&routeId=");
  sParams.append(XSSUtil.encodeForURL(context,routeId));
  sParams.append("&templateId=");
  sParams.append(XSSUtil.encodeForURL(context,routeTemplateId));
  sParams.append("&templateName=");
  sParams.append(XSSUtil.encodeForURL(context,sTemplateName));
  sParams.append("&chkRouteAction=");
  sParams.append(XSSUtil.encodeForURL(context,chkRouteAction));
  sParams.append("&scopeId=");
  sParams.append(XSSUtil.encodeForURL(context,scopeId));
  sParams.append("&selectedAction=");
  sParams.append(XSSUtil.encodeForURL(context,selectedAction));
  sParams.append("&supplierOrgId=");
  sParams.append(XSSUtil.encodeForURL(context,supplierOrgId));
  sParams.append("&portalMode=");
  sParams.append(XSSUtil.encodeForURL(context,portalMode));

  Route routeObj = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
  // build select params
  SelectList objSelectStmts = new SelectList();
  objSelectStmts.addName();
  objSelectStmts.addId();

  SelectList relSelectStmts = new SelectList();
  relSelectStmts.addElement(routeObj.SELECT_RELATIONSHIP_ID);
  routeObj.setId(routeId);
  //Get the route base purpose
  String sAttrRouteBasePurpose = Framework.getPropertyValue( session, "attribute_RouteBasePurpose" );
  String routeBasePurpose = routeObj.getInfo(context,routeObj.getAttributeSelect(sAttrRouteBasePurpose));

  MapList boRouteNode = routeObj.getRelatedObjects(context, routeObj.RELATIONSHIP_ROUTE_NODE, "*", objSelectStmts, relSelectStmts,false,  true, (short)1, null, null);

  String addURL = FrameworkUtil.encodeURLParamValues("emxRouteAddMembersDialogFS.jsp?" + sParams.toString());
  String assignURL = FrameworkUtil.encodeURLParamValues("emxRouteAssignNewTask.jsp?" + sParams.toString());

  String routeActionDefaultProp = EnoviaResourceBundle.getProperty(context,"emxComponents.RouteDefaultAction");
  if (routeActionDefaultProp == null || routeActionDefaultProp.equals("null") || routeActionDefaultProp.equals("")) {
    routeActionDefaultProp = "";
  }
  boolean chkProp = false;

%>


<script language="Javascript">

  // function to be called on click of Add Task Link
  function addTask() {
	  //XSSOK
    document.routeActionsForm.action="<%=assignURL%>";
    document.routeActionsForm.submit();
    return;
  }

  function closeWindow() {
    parent.window.getWindowOpener().parent.location.href=parent.window.getWindowOpener().parent.location.href;
    window.closeWindow();
    return;
  }

  function submitForm() {
<%
    // function to check minimum of one task is connected to route object
    if ( boRouteNode == null || boRouteNode.size() == 0 ) {
%>
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.TaskMessage</emxUtil:i18nScript>");
      return;
<%
    }
%>
    var count = 0;
    for (var k=0; k < document.routeActionsForm.length; k++ ){
      if ((document.routeActionsForm.elements[k].type  == "select-one" ) && (document.routeActionsForm.elements[k].name == "routeOrder"))

      {
         count++;
      }
    }

    //-----------------------------------------------------------------------------------
    //Step 4 : Check Instructions.
    //-----------------------------------------------------------------------------------
    if (count == 1){ //only one instruction field
      if (trim(document.routeActionsForm.routeInstructions.value).length == 0){
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterInstruc</emxUtil:i18nScript>");
        document.routeActionsForm.routeInstructions.value="";
        document.routeActionsForm.routeInstructions.focus();
        return;
      }
    } else { // more than one instruction field
      for (var k=0; k < count; k++){
         if(trim(document.routeActionsForm.routeInstructions[k].value).length == 0){
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterInstruc</emxUtil:i18nScript>");
            document.routeActionsForm.routeInstructions[k].value="";
            document.routeActionsForm.routeInstructions[k].focus();
            return;
         }
      }
    }

    // Date Validation for giving message to user if any selected date is past date
    // Taking current date into a variable
    var toDayDate = new Date();
    // Decrimentng the current date by one day
    // This is required since we are taking month/date/year only and putting time as 00.00.00
    //  so this function will give alert if user picks up even todays date.
    toDayDate.setDate(toDayDate.getDate() - 1);

    var pastDate = "false";

    // checking whether the date selected is earlier than cuurent date.
    for (var i=0; i<document.routeActionsForm.length;i++) {

      if ( document.routeActionsForm.elements[i].name == "taskName"){
        // Name can not have apostrophe character "'", or DoubleQuotes character """, "#" hash charecter
        var apostrophePosition = trim(document.routeActionsForm.elements[i].value).indexOf("'");
        var hashPosition = trim(document.routeActionsForm.elements[i].value).indexOf("#");
        var doublequotesPosition = trim(document.routeActionsForm.elements[i].value).indexOf("\"");

        if (!(isAlphanumeric(trim(document.routeActionsForm.elements[i].value), true))){
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertValidName</emxUtil:i18nScript>");
          document.routeActionsForm.elements[i].focus();
          return;
        } else if ( apostrophePosition != -1 || hashPosition != -1 || doublequotesPosition != -1){
          alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.SpecialCharacters</emxUtil:i18nScript>");
          document.routeActionsForm.elements[i].focus();
          return;
        }
      }

    if (document.routeActionsForm.elements[i].name == "routeInstructions" ) {
      if ( document.routeActionsForm.elements[i].value == "" ) {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTask.AlertInstruction</emxUtil:i18nScript>");
        document.routeActionsForm.elements[i].focus();
        return;
      } else {
        // DK 07-25-2002: Added check for special characters in instruction field
        var apostrophePosition   = document.routeActionsForm.elements[i].value.indexOf("'");
        var hashPosition         = document.routeActionsForm.elements[i].value.indexOf("#");
        var doublequotesPosition = document.routeActionsForm.elements[i].value.indexOf("\"");

        if (apostrophePosition != -1 || hashPosition != -1 || doublequotesPosition != -1){
          alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.InstructionSpecialCharacters</emxUtil:i18nScript>");
          document.routeActionsForm.elements[i].focus();
          return;
        }
      }
    }

      if (document.routeActionsForm.elements[i].name.substring(0,28)  == "routeScheduledCompletionDate" ) {
        if ( (document.routeActionsForm.elements[i].value == "") ) {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterDate</emxUtil:i18nScript>");
          document.routeActionsForm.elements[i].focus();
          return;
        } else {
          var date1 = new Date(parseInt(document.routeActionsForm.elements[i].dateValue,10));

          //  Addressing  Y2K.
          if (date1.getFullYear()< 1950) {

            // add 100 years.
            date1.setFullYear(date1.getFullYear() + 100);
          }

          if ( (Date.parse(date1.toGMTString()) <= Date.parse(toDayDate.toGMTString())) ){
            pastDate = "true";
          }
        }
      }
    }

    if ( pastDate == "true" ) {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterdPastDate</emxUtil:i18nScript>");
    }
    // end of date comparision by chakra

    //-----------------------------------------------------------------------------------
    //Step 1 : Check if tasks in order
    //-----------------------------------------------------------------------------------
    if (count == 1) {     //only one order field
       if (document.routeActionsForm.routeOrder.options[document.routeActionsForm.routeOrder.selectedIndex].value != 1 ) {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterorderBig</emxUtil:i18nScript>" +" "+ document.routeActionsForm.routeOrder.options[document.routeActionsForm.routeOrder.selectedIndex].value + " <emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterorderCont</emxUtil:i18nScript>");
          return;
       }
    } else {

       selArray = document.routeActionsForm.elements["routeOrder"];
       storeArray = new Array(count);
       var missingValue;
       for (ct = 0; ct < count; ct++){
         //get array of values
         storeArray[ct] = parseInt(selArray[ct].options[selArray[ct].selectedIndex].value,10);
       }
       sortNum(storeArray,storeArray.length);

       for (sorted = 0; sorted < (storeArray.length - 1) ; sorted++){
         // make sure the first number in the sorted array is 1
         if (sorted == 0) {
           if (storeArray[sorted] != 1) {
             missingValue = 1;
             errorValue = storeArray[sorted];
             break;
           }
         }

         if ((storeArray[sorted] != storeArray[sorted + 1]) && ((storeArray[sorted] + 1) != storeArray[sorted + 1])){
           missingValue = (storeArray[sorted] + 1);
           errorValue = storeArray[sorted + 1];
           break;
         }
       }

       //check if a value is missing
       if (missingValue > -1) {
         alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.Enterorder</emxUtil:i18nScript>" + missingValue + " <emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterorderSmall</emxUtil:i18nScript> " + errorValue + " <emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.Encounter</emxUtil:i18nScript> " +  missingValue + "  <emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.Missing</emxUtil:i18nScript>");
         //set focus to errorValue
         for (ct = 0; ct < count; ct++){
           //compare to last value before above loop broke
           if ( parseInt(selArray[ct].options[selArray[ct].selectedIndex].value,10) == errorValue){
             selArray[ct].focus();
             break;
           }
         }
         return;
       }
     }

    //-------------------------------------------------------------------------------------------
    //Step 2 : Check if date is selected .
    //-------------------------------------------------------------------------------------------
    if (count == 1){ //only one date field
      if (document.routeActionsForm.routeScheduledCompletionDate0.value==""){
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterDate</emxUtil:i18nScript>");
        return;
      }
    } else {// more than one date field
      for (var i=0; i<document.routeActionsForm.length;i++){
        if (document.routeActionsForm.elements[i].name.substring(0,28)  == "routeScheduledCompletionDate" ){
          if (document.routeActionsForm.elements[i].value == ""){
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterDate</emxUtil:i18nScript>");
            return;
          }
        }
      }
    }

    //-----------------------------------------------------------------------------------
    //Step 3 : Check if dates are in order
    //-----------------------------------------------------------------------------------
    if (count > 1){
      var orderdate = dateOrderCompare();
      if (!orderdate){
        return;
      }
    }

    for (var k=0; k < document.routeActionsForm.length; k++ ){
       if (document.routeActionsForm.elements[k].name.substring(0,28)  == "routeScheduledCompletionDate" ){
         var dtxt = new Date(parseInt(document.routeActionsForm.elements[k].dateValue,10));
       }
    }

    //-----------------------------------------------------------------------------------
    //Step 5 :  Submit form.
    //-----------------------------------------------------------------------------------
    document.routeActionsForm.submit();
  }//end function submitForm.

  function AllowDelegation() {
    var checkedFlag = "false";
    for(var i=0;i<document.routeActionsForm.elements.length;i++) {
      if ( document.routeActionsForm.elements[i].type == "checkbox"
          && document.routeActionsForm.elements[i].checked )  {
          checkedFlag = "true";
      }
    }
    if ( checkedFlag == "false") {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AddContent.SelectOneObj</emxUtil:i18nScript>");
      return;
    } else {
      document.routeActionsForm.action="emxAllowDelegation.jsp";
      document.routeActionsForm.submit();
    }
  }

  //-----------------------------------------------------------------------------------
  // Function to Sort array
  //-----------------------------------------------------------------------------------

  //Array sort numerically
  function sortNum(arrayName,length){
     for (var i=0; i<(length-1); i++){
       for (var b=i+1; b<length; b++){
         if (arrayName[b] < arrayName[i]){
           var temp = arrayName[i];
           arrayName[i] = arrayName[b];
           arrayName[b] = temp;
         } //end-if
       } //end for-loop
     } //end for-loop
  }

  //-----------------------------------------------------------------------------------
  // Function to trim strings
  //-----------------------------------------------------------------------------------

  function trim (str) {
        return str.replace(/\s/gi, "");
  }

  //-----------------------------------------------------------------------------------
  // Function to remove focus
  //-----------------------------------------------------------------------------------

  // Method not used for the Bug 254085
  /*//removing focus from date field.Not letting user to update the field.
  function redirectFocus(num) {
    var count = 0;
    for ( var k = 0; k < document.routeActionsForm.length; k++ ) {
      if (( document.routeActionsForm.elements[k].type  == "select-one" )&& (document.routeActionsForm.elements[k].name == "routeOrder")){
       count++;
     }
    }
    if (count == 1) {
      document.routeActionsForm.routeTime.focus();
      showCalendar('routeActionsForm','routeScheduledCompletionDate0','');
    } else{
      eval("document.routeActionsForm.routeTime[" + num + "].focus();");
      eval("showCalendar('routeActionsForm','routeScheduledCompletionDate"+ num +"','');");
    }
    return;
  }
  */

  //-----------------------------------------------------------------------------------
  // Function to populate array with date and order values.
  //-----------------------------------------------------------------------------------

  function dateOrderCompare() {
    // Step  1 : Moving dates in the order to array.
    // declaring an array to store the order number and date
    var arrcol = 0;
    var dateOrder = new Array(document.routeActionsForm.routeOrder.length*2);
    var slctArray = document.routeActionsForm.elements["routeOrder"];
    arrcol = 0;
    for (ct = 0; ct < slctArray.length; ct++){ // storing the order value
      dateOrder[arrcol] = parseInt(slctArray[ct].options[slctArray[ct].selectedIndex].value,10);
      arrcol+=2;
    }

    arrcol = 1;
    DtArray = document.routeActionsForm.elements["routeTime"]; //storing all the times.
    var arrcount =0;
    for (var i=0; i<document.routeActionsForm.elements.length;i++) // populating the array for dates
    {
      if ( document.routeActionsForm.elements[i].name.substring(0,28)  == "routeScheduledCompletionDate" ){
        arrcount++;
        var DtTm =  new Date(parseInt(document.routeActionsForm.elements[i].dateValue,10));
        var k = arrcount - 1;
        if (DtTm.getFullYear()< 1950){ //Y2K complaint
          // add 100 years.
          DtTm.setFullYear(DtTm.getFullYear() + 100);
        }
        var AmPmVar = new String(DtArray[k].options[DtArray[k].selectedIndex].value.substring(DtArray[k].options[DtArray[k].selectedIndex].value.indexOf(" ") +1 ,DtArray[k].options[DtArray[k].selectedIndex].value.indexOf(" ") + 3));
        if (AmPmVar == "PM"){
          DtTm.setHours(parseInt(DtArray[k].options[DtArray[k].selectedIndex].value.substring(0,DtArray[k].options[DtArray[k].selectedIndex].value.indexOf(":")),10)+12);
        } else if (AmPmVar == "AM"){
          DtTm.setHours(parseInt(DtArray[k].options[DtArray[k].selectedIndex].value.substring(0,DtArray[k].options[DtArray[k].selectedIndex].value.indexOf(":")),10));
        }
        DtTm.setMinutes(parseInt(DtArray[k].options[DtArray[k].selectedIndex].value.substring(DtArray[k].options[DtArray[k].selectedIndex].value.indexOf(":")+1,DtArray[k].options[DtArray[k].selectedIndex].value.length),10));
        dateOrder[arrcol]=DtTm;
        arrcol+=2;
      }
    }

    // Step 2 :Passing it thru function largestdate to check validity
    if (document.routeActionsForm.routeOrder.length < 2){ //only a single date field
      return true;
    } else {
      for (var k =0 ; k < dateOrder.length; k+=2){
        for (var q = k + 2; q < dateOrder.length; q+=2){
          var rslt = largestdate(dateOrder[k],dateOrder[k+1],dateOrder[q],dateOrder[q+1]);
          if (!rslt){
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.DateOrder</emxUtil:i18nScript>");
            eval("document.routeActionsForm.routeTime[1].focus();");
            k = arrcol;
            q = arrcol;
            return false;
          }
        }
      }
    }
    return true;
  } // close function dateOrderCompare

  //-----------------------------------------------------------------------------------
  // Function to Compare if date and order are in sequence
  //-----------------------------------------------------------------------------------

  // checks whether the dates are later than today. Also checks the ordering of the dates.
  function largestdate(order1,dt1,order2,dt2) {
    var date1 = new Date(dt1);
    var date2 = new Date(dt2);

    //  Addressing  Y2K.
    if (date1.getFullYear()< 1950) {
      // add 100 years.
      date1.setFullYear(date1.getFullYear() + 100);
    }
    if (date2.getFullYear()< 1950) {
      // add 100 years.
      date2.setFullYear(date2.getFullYear() + 100);
    }
    // comparing the order and the dates
    if (((((order1 >  order2) && (Date.parse(date1.toGMTString()) >= Date.parse(date2.toGMTString())))) || (((order1 <  order2) && (Date.parse(date1.toGMTString()) <= Date.parse(date2.toGMTString())))) || (order1 ==  order2))){
      return true;
    }
    else {
      return false;
    }
  }


  function goBack() {
	  //XSSOK
    document.routeActionsForm.action="<%=addURL%>";
    document.routeActionsForm.submit();
    return;
  }

  // function to remove the task.
  function removeSelected() {
    var varChecked = "false";
    var objForm = document.routeActionsForm;
    for (var i=0; i < objForm.elements.length; i++) {
      if (objForm.elements[i].type == "checkbox") {
        if ( objForm.elements[i].name != "chkList" && objForm.elements[i].checked == true ) {
          varChecked = "true";
        }
      }
    }
    if (varChecked == "false") {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.SelectTask</emxUtil:i18nScript>");
      return;
    } else {
      if (confirm("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.MsgConfirm</emxUtil:i18nScript>") != 0)  {
        document.routeActionsForm.action="emxRouteRemoveTasksProcess.jsp";
        document.routeActionsForm.submit();
        return;
      }
    }
  }

    // function to sort tasks.
    function sortTaskList() {
  <%
      if ( boRouteNode == null || boRouteNode.size() == 0 ) {
  %>
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.TaskMessage</emxUtil:i18nScript>");
        return;
  <%
      } else {
  %>
        document.routeActionsForm.sortName.value="true";
        document.routeActionsForm.action="emxRouteSortTaskList.jsp";
        document.routeActionsForm.submit();
        return;
  <%
      }
  %>
  }

</script>
<%
  try  {
%>
  <%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%
  } catch(Exception e){
    String error = ComponentsUtil.i18nStringNow("emxComponents.AssignTaskDialog.ErrorMessage",languageStr);
%>
    <table width="90%" border="0"  cellspacing="0" cellpadding="3"  class="formBG" align="center" >
      <tr >
        <!-- //XSSOK -->
        <td class="errorHeader"><%=error%></td>
      </tr>
    </table>
<%
  }
%>
<body  onLoad="loaddates()" >

<form method="post" name="routeActionsForm" action="emxRouteAssignTaskProcess.jsp" target="_parent" >
<input type="hidden" name="routeId"         value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="objectId"        value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="templateId"      value="<xss:encodeForHTMLAttribute><%=routeTemplateId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="scopeId"      value="<xss:encodeForHTMLAttribute><%=scopeId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="templateName"        value="<xss:encodeForHTMLAttribute><%=sTemplateName%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="chkRouteAction"  value="<xss:encodeForHTMLAttribute><%=chkRouteAction%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="sortName"        value="<xss:encodeForHTMLAttribute><%= sSortName %></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>" />

<table border="0" cellpadding="3" cellspacing="2" width="100%">
  <tr>
    <th width="5%">
      <table>
        <tr>
          <td align="center">
            <input type="checkbox" name="chkList" id="chkList" onclick="doCheck('routeActionsForm')" />
          </td>
        </tr>
      </table>
    </th>
    <th><emxUtil:i18n localize="i18nId">emxComponents.RouteAction.Order</emxUtil:i18n>&nbsp;</th>
    <th><emxUtil:i18n localize="i18nId">emxComponents.AssignTasksDialog.TaskName</emxUtil:i18n></th>
    <th><emxUtil:i18n localize="i18nId">emxComponents.AssignTasksDialog.NameAction</emxUtil:i18n></th>
    <th><img src="../common/images/iconSmallAssignee.gif" name="imgAssignee" id="imgAssignee" alt="" />&nbsp;&nbsp;</th>
    <th><emxUtil:i18n localize="i18nId">emxComponents.AssignTasksDialog.Instructions</emxUtil:i18n></th>
    <th><emxUtil:i18n localize="i18nId">emxComponents.AssignTasksDialog.DueDateTime</emxUtil:i18n></th>
  </tr>

<%
try{
  // build select params
  SelectList selectPersonStmts = new SelectList();
  selectPersonStmts.addElement(routeObj.SELECT_ID);
  selectPersonStmts.addElement(routeObj.SELECT_NAME);

  // build select params for Relationship
  SelectList selectPersonRelStmts = new SelectList();
  selectPersonRelStmts.addElement(routeObj.SELECT_ROUTE_SEQUENCE);
  selectPersonRelStmts.addElement(routeObj.SELECT_ALLOW_DELEGATION);
  selectPersonRelStmts.addElement(routeObj.SELECT_ROUTE_ACTION);
  selectPersonRelStmts.addElement(routeObj.SELECT_ROUTE_INSTRUCTIONS);
  selectPersonRelStmts.addElement(routeObj.SELECT_TITLE);
  selectPersonRelStmts.addElement(routeObj.SELECT_SCHEDULED_COMPLETION_DATE);
  selectPersonRelStmts.addElement(routeObj.SELECT_RELATIONSHIP_ID);

  selectPersonRelStmts.addElement(routeObj.SELECT_ROUTE_TASK_USER);
  MapList resultList = routeObj.getRelatedObjects(context, routeObj.RELATIONSHIP_ROUTE_NODE, "*", selectPersonStmts,selectPersonRelStmts, false, true, (short)1, null, null);

  resultList.addSortKey(routeObj.SELECT_ROUTE_SEQUENCE, "ascending", "integer");
  resultList.addSortKey(routeObj.SELECT_NAME, "ascending", "String");
  resultList.sort();

  StringList memberList = new StringList();
  java.util.List<Hashtable> resMemberList = new java.util.ArrayList<Hashtable>();
  Hashtable tempTable = null;

  Hashtable tempMap = new Hashtable();

  String personId = "";
  String personName = "";
  String asigneeType = "";
  String dateList ="";
  for(int i =0; i < resultList.size(); i++)
  {
    tempMap = (Hashtable) resultList.get(i);
    personName = (String) tempMap.get(routeObj.SELECT_ROUTE_TASK_USER);
    personId = (String) tempMap.get(routeObj.SELECT_ID);
    if(personName == null || "".equals(personName)){
      personName =  (String) tempMap.get(Route.SELECT_NAME);
      asigneeType ="person";
    }
    else {

      asigneeType = personName.substring(0,personName.indexOf("_"));
      personName = Framework.getPropertyValue(session, personName);
      if(asigneeType.equalsIgnoreCase("role")){
        asigneeType = "Role";
      }else{
        asigneeType = "Group";
      }

    }

    if(!memberList.contains(personName))
    {
      memberList.addElement(personName);
      tempTable = new Hashtable();
      tempTable.put("id", personId);
      tempTable.put("name", personName);
      tempTable.put("asigneetype", asigneeType);
      resMemberList.add(tempTable);
    }

  }

  int xx      = 0;
  int hhrs    = 10;
  int mmin    = 0;

  int dateCnt =0;
  StringList routeActionList = FrameworkUtil.getRanges(context, routeObj.ATTRIBUTE_ROUTE_ACTION);
%>
  <framework:mapListItr mapList="<%=resultList%>" mapName="routeMap">
    <tr class='<framework:swap id ="1" />'>
          <td><input type="checkbox" name="chkItem1" id="chkItem1" onclick="updateCheck('routeActionsForm')" value="<xss:encodeForHTMLAttribute><%=routeMap.get(routeObj.SELECT_RELATIONSHIP_ID)%></xss:encodeForHTMLAttribute>" /></td>
          <td  nowrap >
            <select name="routeOrder">
<%
            String routeSequenceValueStr = (String) routeMap.get(routeObj.SELECT_ROUTE_SEQUENCE);
            for (int loop = 1; loop <= 20; loop++) {
              Integer integerType = new Integer(loop);
              String loopString = integerType.toString();
              if (routeSequenceValueStr.equals(loopString)) {

%>
                <option value="<%=loop%>" selected><%=loop%></option>
<%
              } else {

%>
                <option value="<%=loop%>"><%=loop%></option>
<%
              }
            }
%>
            </select>
            <input type="hidden" name="routeNode" value="<xss:encodeForHTMLAttribute><%=(String)routeMap.get(routeObj.SELECT_RELATIONSHIP_ID)%></xss:encodeForHTMLAttribute>" />
          </td>
          <td><input type="text" name="taskName" value="<xss:encodeForHTMLAttribute><%=(String)routeMap.get(routeObj.SELECT_TITLE)%></xss:encodeForHTMLAttribute>" /></td>
          <td>
          <table border="0">
            <tr>
              <td>
                <select name="personId" size="1" >
<%
                  Hashtable ht = new Hashtable();
                  String routeTaskUser = (String) routeMap.get(routeObj.SELECT_ROUTE_TASK_USER);
                  if(routeTaskUser == null || "".equals(routeTaskUser)){
                    memberName =  (String) routeMap.get(routeObj.SELECT_NAME);
                  } else{
                    memberName = Framework.getPropertyValue(session, routeTaskUser);
                  }
                  String id = "";
                  String name = "";
                  String assigType = "";
                  String memberNameIntl = "";

                  for(int j = 0; j < resMemberList.size(); j++)
                  {
                    ht = (Hashtable) resMemberList.get(j);
                    id = (String) ht.get("id");
                    name = (String) ht.get("name");
                    assigType = (String) ht.get("asigneetype");

                    if (assigType.equals("person")){
                      memberNameIntl =  name;
                    }else{
                      memberNameIntl = i18nNow.getAdminI18NString(assigType,name,languageStr);
                    }

                    if(memberName.equals(ht.get("name"))) {
%>
                      <option value="<%=id + "#" + name %>" Selected > <%=memberNameIntl%> </option>

<%
                    } else {
%>
                      <option value="<%=id + "#" + name %>"> <%=memberNameIntl%> </option>
<%
                    }

                  }
%>
                </select>

              </td>
             </tr>

             <tr>
               <td>
                <select name="routeAction" size="1" >
<%
                  if (selectedAction.equals("true"))
                     routeActionDefaultProp = (String)routeMap.get(routeObj.SELECT_ROUTE_ACTION);
                  if("Approval".equals(routeBasePurpose))
                  {
                      routeActionList = new StringList(1);
                      routeActionList.add("Approve");
                  }
                  else if("Review".equals(routeBasePurpose))
                  {
                      routeActionList = new StringList(1);
                      routeActionList.add("Comment");
                  }
                  StringItr  routeActionItr  = new StringItr (routeActionList);
                  while(routeActionItr.next()) {
                    String rangeValue = routeActionItr.obj();
                    String i18nRouteAction=i18nNow.getRangeI18NString(routeObj.ATTRIBUTE_ROUTE_ACTION, rangeValue, languageStr);
                      if(routeActionDefaultProp.equals(rangeValue) || "Review".equals(routeBasePurpose) || "Approval".equals(routeBasePurpose)) {
                        chkProp = true;
%>
                        <!-- //XSSOK -->
                        <option value="<%=rangeValue%>" Selected> <%=i18nRouteAction%> </option>
<%
                      } else {
%>
                        <!-- //XSSOK -->
                        <option value="<%=rangeValue%>"> <%=i18nRouteAction%> </option>
<%
                      }
                  }

%>
                </select>
              </td>
            </tr>
            </table>
          </td>
<%
          String routeAllowDelegationStr = (String) routeMap.get(routeObj.SELECT_ALLOW_DELEGATION);
          if (routeAllowDelegationStr.equals("TRUE") ) {
%>
            <td><img src="../common/images/iconSmallAssignee.gif" name="imgTask" id="imgTask" alt="" />&nbsp;</td>
<%
          } else {
%>
            <td>&nbsp;&nbsp;</td>
<%
          }
%>
          <td nowrap valign="top">
            <textarea wrap rows="5" cols="25" name="routeInstructions"><xss:encodeForHTML><%=routeMap.get(routeObj.SELECT_ROUTE_INSTRUCTIONS)%></xss:encodeForHTML></textarea>
          </td>

          <td>
            <table border="0">
              <tr>
<%
                String routeScheduledCompletionDateValueStr = (String) routeMap.get(routeObj.SELECT_SCHEDULED_COMPLETION_DATE);




               String displaySelectDate ="";
                Long time;
                if ((routeScheduledCompletionDateValueStr.equals(null))||(routeScheduledCompletionDateValueStr.equals(""))){
                  displaySelectDate="";
                 time = new Long(0);
                } else {

                  Date dtObj = eMatrixDateFormat.getJavaDate(routeScheduledCompletionDateValueStr);
                  time = new Long(dtObj.getTime());
                  int iTimeZone = (new Double((new Double((String)session.getValue("timeZone"))).doubleValue() * -3600000)).intValue(); //60*60*1000 *-1;

                  double iClientTimeOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();
                  displaySelectDate = eMatrixDateFormat.getFormattedDisplayDate(routeScheduledCompletionDateValueStr,iClientTimeOffset,request.getLocale());
                  Hashtable hashDateTime = eMatrixDateFormat.getFormattedDisplayInputDateTime(routeScheduledCompletionDateValueStr,iClientTimeOffset);
                  hhrs = (new Integer((String)hashDateTime.get("hours"))).intValue();
                  mmin = (new Integer((String)hashDateTime.get("minutes"))).intValue();

                }
                String timeStr = time.toString();
                if (dateCnt ==0) {
                if (dateCnt == resultList.size() -1) {
                 dateList = timeStr;
                }

                else {
                 dateList = timeStr+",";
                }
                }
                else {

                       if (dateCnt == resultList.size() -1) {
                                dateList +=timeStr;
                        }

                        else {
                        dateList += timeStr +",";

                       }
                }
%>

                <td>
               	  <!-- //XSSOK -->
                  <input onFocus="this.blur()" readonly type="text" name="routeScheduledCompletionDate<%=xx%>" value="<%=displaySelectDate%>" />&nbsp;
                  <!-- //XSSOK -->
                  <a href="javascript:showCalendar('routeActionsForm','routeScheduledCompletionDate<%=xx++%>','<%=displaySelectDate%>')" ><img src="../common/images/iconSmallCalendar.gif" border="0" valign="absmiddle" name="img5" /></a>&nbsp;
                </td>

               </tr>
               <tr>
                <td>
                  <select name="routeTime">
<%
                    for (int i=0;i<48;i++) {
                      String ttime = "";
                      String Slct ="";
                      String timeValue = "";
                      if (hhrs==24){
                        hhrs =0;
                      }

                      if (hhrs>12) {
                        ttime = (hhrs-12)+":";
                      } else if (hhrs ==0) {
                        ttime = "12:";
                      } else {
                        ttime = hhrs+":";
                      }

                      if (mmin<10) {
                        ttime= ttime + "0" + mmin;
                      } else {
                        ttime= ttime + mmin;
                      }
                      timeValue  = ttime + ":00";
                      if (hhrs>=12) {
                        ttime= ttime + " PM";
                        timeValue = timeValue + " PM";
                      } else {
                        ttime= ttime + " AM";
                        timeValue = timeValue + " AM";
                      }
                      if (i==0) {
                        Slct = "Selected";
                      } else {
                        Slct ="";
                      }
%>
					<!-- //XSSOK -->
                   <Option value="<%=timeValue%>" <%=Slct%>> <%=ttime%> </Option>
<%
                    mmin += 30;
                    if (mmin == 60){
                       mmin = 0;
                       hhrs ++;
                    }
                 }
%>
                  </select>
                </td>
              </tr>
            </table>
          </td>

        </tr>
<%
   dateCnt++;
%>
  </framework:mapListItr>

<script language="Javascript">
        // This function loads the array of dates into the completion
        // date field. The values stored in the dates array is the number
        // of milliseconds since 1970.
        function loaddates() {
        		//XSSOK
                var datelst ='<%=dateList%>';
                var datetypes = datelst.split(",");
                for (var k=0; k < document.routeActionsForm.length; k++ ){
                   if (document.routeActionsForm.elements[k].name.substring(0,28)  == "routeScheduledCompletionDate") {
                  var arrayindx= document.routeActionsForm.elements[k].name.substring(28,document.routeActionsForm.elements[k].name.length);
                  var dateVal = datetypes[arrayindx];
                  document.routeActionsForm.elements[k].dateValue = dateVal;
          }
         }


}
</script>

<%
  if(resultList.size() == 0)
  {
    chkProp = true;
  }
} catch(Exception e){
    // System.out.println("error:" + e);
}
%>

</form>
</table>



<%
  // if RouteDefaultAction value from the ComponentsStringResource.properties is not available in the
  // range list of ATTRIBUTE_ROUTE_ACTION, then error message is displayed at the bottom of the page
  if (chkProp==false) {
%>
      &nbsp;
      <table width="100%" border="0"  cellspacing="0" cellpadding="0"  class="formBG" align="center" >
        <tr >
          <td class="errorHeader"><%=i18nNow.getI18nString("emxFramework.Error.Header","emxUIFrameworkStringResource",languageStr)%></td>
        </tr>
        <tr align="center">
          <!-- //XSSOK -->
          <td class="errorMessage" align="center"><%=ComponentsUtil.i18nStringNow("emxComponents.Route.InvalidRouteDefaultAcionValue", languageStr)%></td>
        </tr>
      </table>
<%
  }
%>


<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

