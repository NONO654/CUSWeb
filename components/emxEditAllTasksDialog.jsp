<%--  emxEditAllTasksDialog.jsp
   Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxEditAllTasksDialog.jsp.rca 1.33 Wed Oct 22 16:18:14 2008 przemek Experimental przemek $
--%>

<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@include file  = "emxRouteInclude.inc"%>
<%@include file  = "../emxJSValidation.inc" %>

<head>
  <%@include file = "../common/emxUIConstantsInclude.inc"%>
  <script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
</head>

<%
  DomainObject domainObject = DomainObject.newInstance(context);
  Route route = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);

  // preload lookup strings
  String routeId                        = emxGetParameter(request,"objectId");
  if(UIUtil.isNullOrEmpty(routeId)){
	  routeId                        = emxGetParameter(request,"routeId");
  }
  String sAttrRouteAction               = Framework.getPropertyValue(session, "attribute_RouteAction");
  String sAttrRouteInstructions         = Framework.getPropertyValue(session, "attribute_RouteInstructions");
  String sAttrScheduledCompletionDate   = Framework.getPropertyValue(session, "attribute_ScheduledCompletionDate");
  String sAttrAllowDelegation           = Framework.getPropertyValue(session, "attribute_AllowDelegation");
  String sAttrTitle                     = Framework.getPropertyValue(session, "attribute_Title");
  String sAttrRouteSequence             = Framework.getPropertyValue(session, "attribute_RouteSequence");
  String sAttrRouteNodeID               = Framework.getPropertyValue(session, "attribute_RouteNodeID");
  String sAttrRouteTaskUser             = Framework.getPropertyValue(session, "attribute_RouteTaskUser");

  String sTypeInboxTask                 = Framework.getPropertyValue(session, "type_InboxTask");
  String sTypePerson                    = Framework.getPropertyValue(session, "type_Person");
  String sTypeRouteTaskUser             = Framework.getPropertyValue(session, "type_RouteTaskUser");
  String sRelRouteTask                  = Framework.getPropertyValue(session, "relationship_RouteTask");
  String sRelProjectTask                = Framework.getPropertyValue(session, "relationship_ProjectTask");
  String sRelRouteNode                  = Framework.getPropertyValue(session, "relationship_RouteNode" );

  String languageStr     = request.getHeader("Accept-Language");
  String timeZone        = (String)session.getValue("timeZone");

  String sAsigneeId        = "";
  String sRelId            = "";
  String sName             = null;
  String sRouteNodeID      = "";
  String sSequence         = "";
  String sAsignee          = null;
  String sDueDate          = null;
  String sAllowDelegation  = null;
  String sConnectedRoute   = "";
  String sAction           = null;
  String sInstruction      = null;
  String sState            = null;
  String sTaskId           = null;
  Date curDate             = new Date();
  String className         = "even";
  boolean bFlag            = false;
  boolean rowFlag          = false;
  int taskCount            = 0;
  int inboxTaskCount       = 0;

  int xx     = 0;
  int mmonth = 0;
  int yyear  = 0;
  int dday   = 0;
  int hhrs   = 10;
  int mmin   = 0;

  String slctdate = "";
  Date tempdate = new Date();

 Vector vectPersons = new Vector();

  //checking if any inbox tasks exists
  domainObject.setId(routeId);
  route.setId(routeId);
  //Get the route base purpose
  String sAttrRouteBasePurpose = Framework.getPropertyValue( session, "attribute_RouteBasePurpose" );
  String routeBasePurpose = domainObject.getInfo(context,domainObject.getAttributeSelect(sAttrRouteBasePurpose));

    StringItr routeTaskListItr = new StringItr(domainObject.getInfoList(context, "to["+sRelRouteTask+"].from.id"));
    int sTaskSequence = 0;
    String sSequenceTask = "";
    int bTemp = 0;
    while(routeTaskListItr.next()){
      String inboxTaskId = (String)routeTaskListItr.obj();
      domainObject.setId(inboxTaskId);

      String relRouteNode = domainObject.getInfo(context, InboxTask.SELECT_ROUTE_NODE_ID);

      //Get the correct relId for the RouteNodeRel given the attr routeNodeId from the InboxTask.
      String actualRouteNodeId = route.getRouteNodeRelId(context, relRouteNode);

      //sSequenceTask = DomainRelationship.getAttributeString(context, relRouteNode,sAttrRouteSequence);
      sSequenceTask = DomainRelationship.getAttributeString(context, actualRouteNodeId,sAttrRouteSequence);

        if(sSequenceTask != null && !sSequenceTask.equals("") && !"null".equals(sSequenceTask)) {
          sTaskSequence = Integer.parseInt(sSequenceTask);
        }
        if(sTaskSequence >= bTemp ) {
          bTemp = sTaskSequence;
        }

    }
    sTaskSequence = bTemp;
%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<script language="Javascript" >

  var bChange = false;
  function closeWindow() {
    parent.window.close();
    return;
  }
  function setValue(){
    bChange = true;
  }

  // This Function Checks For The Length Of The Data That Has
  // Been Entered And Trims the Extra Spaces In The Front And Back.
  function trimStr (textBox) {
    while (textBox.charAt(textBox.length-1)==' ')
      textBox = textBox.substring(0,textBox.length-1);
    while (textBox.charAt(0)==' ')
      textBox = textBox.substring(1,textBox.length);
    return textBox;
  }
 function submitForm() {
    var count = 0;
    for (var k=0; k < document.TaskSummary.length; k++ ){
      if ((document.TaskSummary.elements[k].type  == "select-one" ) && (document.TaskSummary.elements[k].name == "routeOrder"))

      {
         count++;
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
    for (var i=0; i<document.TaskSummary.length;i++) {

    if ( document.TaskSummary.elements[i].name == "taskName"){
      // Name can not have apostrophe character "'", or DoubleQuotes character """, "#" hash charecter
      document.TaskSummary.elements[i].value = trimStr(document.TaskSummary.elements[i].value);
      var apostrophePosition = trim(document.TaskSummary.elements[i].value).indexOf("'");
      var hashPosition = trim(document.TaskSummary.elements[i].value).indexOf("#");
      var doublequotesPosition = trim(document.TaskSummary.elements[i].value).indexOf("\"");

      if (!(isAlphanumeric(trim(document.TaskSummary.elements[i].value), true))){
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertValidName</emxUtil:i18nScript>");
        document.TaskSummary.elements[i].focus();
        return;
      } else if ( apostrophePosition != -1 || hashPosition != -1 || doublequotesPosition != -1){
        alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.SpecialCharacters</emxUtil:i18nScript>");
        document.TaskSummary.elements[i].focus();
        return;
      }
    }

    if (document.TaskSummary.elements[i].name == "routeInstructions" ) {
      if ( document.TaskSummary.elements[i].value == "" ) {
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTask.AlertInstruction</emxUtil:i18nScript>");
        document.TaskSummary.elements[i].focus();
        return;
      } else {
        // DK 07-25-2002: Added check for special characters in instruction field
        var apostrophePosition   = document.TaskSummary.elements[i].value.indexOf("'");
        var hashPosition         = document.TaskSummary.elements[i].value.indexOf("#");
        var doublequotesPosition = document.TaskSummary.elements[i].value.indexOf("\"");

        if (apostrophePosition != -1 || hashPosition != -1 || doublequotesPosition != -1){
          alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.InstructionSpecialCharacters</emxUtil:i18nScript>");
          document.TaskSummary.elements[i].focus();
          return;
        }
      }
    }

    if (document.TaskSummary.elements[i].name.substring(0,28)  == "routeScheduledCompletionDate" ) {
      var date1 = new Date(parseInt(document.TaskSummary.elements[i].dateValue,10));
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


    if ( pastDate == "true" ) {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterdPastDate</emxUtil:i18nScript>");
      //return;
    }
    // end of date comparision by chakra

    //-----------------------------------------------------------------------------------
    //Step 1 : Check if tasks in order
    //-----------------------------------------------------------------------------------
    if (count == 1) {     //only one order field
       //XSSOK
       if ((document.TaskSummary.routeOrder.options[document.TaskSummary.routeOrder.selectedIndex].value != <%=sTaskSequence%> + 1)) {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.Enterorder</emxUtil:i18nScript> " + <%=sTaskSequence + 1%> +
                " <emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterorderSmall</emxUtil:i18nScript> " +
                 document.TaskSummary.routeOrder.options[document.TaskSummary.routeOrder.selectedIndex].value +
                  " <emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.WasEncountered</emxUtil:i18nScript>" +" "+
                  <%=sTaskSequence + 1%> +
                  " <emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.WhenExpected</emxUtil:i18nScript>");

          return;
       }
    } else {

       selArray = document.TaskSummary.elements["routeOrder"];


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
        	 //XSSOK
           if (storeArray[sorted] != <%=sTaskSequence%> + 1)  {
            //XSSOK
            missingValue = <%=sTaskSequence%> + 1;
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
        if (document.TaskSummary.routeScheduledCompletionDate0.value==""){
           alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterDate</emxUtil:i18nScript>");
           return;
        }
    } else {// more than one date field
      for (var i=0; i<document.TaskSummary.length;i++){
          if (document.TaskSummary.elements[i].name.substring(0,28)  == "routeScheduledCompletionDate" ){
             if (document.TaskSummary.elements[i].value == ""){
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

    //-----------------------------------------------------------------------------------
    //Step 4 : Check Instructions.
    //-----------------------------------------------------------------------------------
    if (count == 1){ //only one instruction field
        if (trim(document.TaskSummary.routeInstructions.value).length == 0){
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterInstruc</emxUtil:i18nScript>");
            document.TaskSummary.routeInstructions.value="";
            document.TaskSummary.routeInstructions.focus();
            return;
        }
    } else { // more than one instruction field
      for (var k=0; k < count; k++){
         if(trim(document.TaskSummary.routeInstructions[k].value).length == 0){
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterInstruc</emxUtil:i18nScript>");
            document.TaskSummary.routeInstructions[k].value="";
            document.TaskSummary.routeInstructions[k].focus();
            return;
         }
      }
    }
    for (var k=0; k < document.TaskSummary.length; k++ ){
       if (document.TaskSummary.elements[k].name.substring(0,28)  == "routeScheduledCompletionDate" ){
          var dtxt = new Date(parseInt(document.TaskSummary.elements[k].dateValue,10));
       }
    }

    //-----------------------------------------------------------------------------------
    //Step 5 :  Submit form.
    //-----------------------------------------------------------------------------------
    document.TaskSummary.submit();
  }//end function submitForm.

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
  // Function to remove focus
  //-----------------------------------------------------------------------------------

  // Method not used for the Bug 254085
  /*//removing focus from date field.Not letting user to update the field.
  function redirectFocus(num) {
    var count = 0;
    for ( var k = 0; k < document.TaskSummary.length; k++ ) {
      if (( document.TaskSummary.elements[k].type  == "select-one" )&& (document.TaskSummary.elements[k].name == "routeOrder")) {
       count++;
      }
    }
    if (count == 1) {
      document.TaskSummary.routeTime.focus();
      showCalendar('TaskSummary','routeScheduledCompletionDate0','');
    } else{
      eval("document.TaskSummary.routeTime[" + num + "].focus();");
      eval("showCalendar('TaskSummary','routeScheduledCompletionDate"+ num +"','');");
    }
    return;
  }
  */


  //-----------------------------------------------------------------------------------
  // Function to trim strings
  //-----------------------------------------------------------------------------------

  function trim (str) {
    return str.replace(/\s/gi, "");
  }

  //-----------------------------------------------------------------------------------
  // Function to populate array with date and order values.
  //-----------------------------------------------------------------------------------

  function dateOrderCompare()
  {
  // Step  1 : Moving dates in the order to array.

  // declaring an array to store the order number and date
        var arrcol = 0;
        var dateOrder = new Array(document.TaskSummary.routeOrder.length*2);
        var slctArray = document.TaskSummary.elements["routeOrder"];

        arrcol = 0;
        for (ct = 0; ct < slctArray.length; ct++){ // storing the order value
          dateOrder[arrcol] = parseInt(slctArray[ct].options[slctArray[ct].selectedIndex].value,10);
          arrcol+=2;
        }

        arrcol = 1;
        DtArray = document.TaskSummary.elements["routeTime"]; //storing all the times.
        var arrcount =0;
        for (var i=0; i<document.TaskSummary.elements.length;i++) // populating the array for dates
        {
           if ( document.TaskSummary.elements[i].name.substring(0,28)  == "routeScheduledCompletionDate" ){
                arrcount++;
                var DtTm =  new Date(parseInt(document.TaskSummary.elements[i].dateValue,10));
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

    if (document.TaskSummary.routeOrder.length < 2){ //only a single date field
      return true;
    } else {
      for (var k =0 ; k < dateOrder.length; k+=2){
        for (var q = k + 2; q < dateOrder.length; q+=2){
          var rslt = largestdate(dateOrder[k],dateOrder[k+1],dateOrder[q],dateOrder[q+1]);
          if (!rslt){
               alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.DateOrder</emxUtil:i18nScript>");
               eval("document.TaskSummary.routeTime[1].focus();");
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
  function largestdate(order1,dt1,order2,dt2)
  {
     var date1 = new Date(dt1);
     var date2 = new Date(dt2);

     //  Addressing  Y2K.
       if (date1.getFullYear()< 1950)
     {
       // add 100 years.
        date1.setFullYear(date1.getFullYear() + 100);

     }
       if (date2.getFullYear()< 1950)
     {
       // add 100 years.
        date2.setFullYear(date2.getFullYear() + 100);
     }
      // comparing the order and the dates

     if (((((order1 >  order2) && (Date.parse(date1.toGMTString()) >= Date.parse(date2.toGMTString())))) || (((order1 <  order2) && (Date.parse(date1.toGMTString()) <= Date.parse(date2.toGMTString())))) || (order1 ==  order2))){
        return true;
     }
     else{
        return false;
     }
  }
  function doCheck(){
    var objForm = document.TaskSummary;
    var chkList = objForm.chkList;
    var reChkName = /chkItem/gi;

    for (var i=0; i < objForm.elements.length; i++)
      if (objForm.elements[i].name.indexOf('chkItem') > -1) {
        objForm.elements[i].checked = chkList.checked;
      }
  }

  function updateCheck() {
    var objForm = document.TaskSummary;
    var chkList = objForm.chkList;
    chkList.checked = false;
  }

  function showDeleteSelected() {
    var checkedFlag = "false";

    for (var i=0; i < document.TaskSummary.elements.length; i++) {
      if (document.TaskSummary.elements[i].type == "checkbox"
         && document.TaskSummary.elements[i].name != "chkList" && document.TaskSummary.elements[i].checked   )  {
         checkedFlag = "true";
      }
    }
    if (checkedFlag == "false") {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.TaskSummary.SelectTask</emxUtil:i18nScript>");
      return;
    } else {
      if (confirm("<emxUtil:i18nScript localize="i18nId">emxComponents.TaskSummary.MsgConfirm</emxUtil:i18nScript>") != 0)  {
        document.TaskSummary.action="emxDeleteTask.jsp?objectId=<%=XSSUtil.encodeForURL(context, routeId)%>&srcPg=editAllTasks";
        document.TaskSummary.submit();
        return;
      }
    }
  }

  function allowDelegation() {
    var checkedFlag = "false";
    for(var i=0;i<document.TaskSummary.elements.length;i++) {
      if ( document.TaskSummary.elements[i].type == "checkbox"
          && document.TaskSummary.elements[i].name != "chkList" && document.TaskSummary.elements[i].checked )  {
          checkedFlag = "true";
      }
    }
    if ( checkedFlag == "false") {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.EditAllTasks.SelectOneObj</emxUtil:i18nScript>");
      return;
    } else {
      document.TaskSummary.action="emxAllowDelegation.jsp?srcPg=editAllTasks";
      document.TaskSummary.submit();
    }
  }

</script>
<body  onLoad="loaddates()" >

<%
  try  {
%>
  <%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%
  } catch(Exception e){
    String error = ComponentsUtil.i18nStringNow("emxComponents.AssignTaskDialog.ErrorMessage",request.getHeader("Accept-Language"));
  }
%>


<form name = "TaskSummary" method="post" onSubmit="return false" action="emxEditAllTasksProcess.jsp">

<input type="hidden" name="routeId"   value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>"/>

<table border="0" cellpadding="3" cellspacing="2" width="100%">
  <tr>
    <th width="5%" style="text-align:center">
      <input type="checkbox" name="chkList" id="chkList" onclick="doCheck()" />
    </th>
    <th>
      <emxUtil:i18n localize="i18nId">emxComponents.EditAllTasks.Order</emxUtil:i18n>
    </th>
    <th>
      <emxUtil:i18n localize="i18nId">emxComponents.EditAllTasks.TaskName</emxUtil:i18n>
    </th>
    <th>
      <emxUtil:i18n localize="i18nId">emxComponents.EditAllTasks.NameAndAction</emxUtil:i18n>
    </th>
    <th>
      <img src="../common/images/iconSmallAssignee.gif" name="imgTask" id="imgTask" alt="<emxUtil:i18n localize="i18nId">emxComponents.EditAllTasks.AllowDelegation</emxUtil:i18n>" />
    </th>
    <th>
      <emxUtil:i18n localize="i18nId">emxComponents.EditAllTasks.Instructions</emxUtil:i18n>
    </th>
    <th>
      <emxUtil:i18n localize="i18nId">emxComponents.EditAllTasks.DueDateTime</emxUtil:i18n>
    </th>
  </tr>

<%
  String routeSequenceStr   = Framework.getPropertyValue( session, "attribute_RouteSequence");

  // to get the folder Id from route Id
  Pattern relPattern     = new Pattern(sRelRouteTask);
  Pattern typePattern    = new Pattern(sTypeInboxTask);

  route.setId(routeId);
  SelectList objectSelects = new SelectList();
  objectSelects.add(Route.SELECT_ID);
  objectSelects.add(InboxTask.SELECT_ROUTE_NODE_ID);
  objectSelects.add("from["+sRelProjectTask+"].to.name");
  objectSelects.add("attribute["+routeSequenceStr+"]");


  MapList inboxTaskList = route.getRouteTasks(context,objectSelects, null, null, false);
  inboxTaskList.sort("attribute["+routeSequenceStr+"]","ascending","integer");
  Iterator mapItr = inboxTaskList.iterator();
  Vector inboxTaskVector = new Vector();
  while(mapItr.hasNext()) {
    Map map = (Map)mapItr.next();
    String routeNodeId = (String)map.get(InboxTask.SELECT_ROUTE_NODE_ID);
    inboxTaskVector.addElement(routeNodeId);

    //Get the correct relId for the RouteNodeRel given the attr routeNodeId from the InboxTask.
	String actualRouteNodeId = route.getRouteNodeRelId(context, routeNodeId);

    //Map routeNodeInfo = DomainRelationship.getAttributeMap(context, routeNodeId);
    Map routeNodeInfo = DomainRelationship.getAttributeMap(context, actualRouteNodeId);

    sName            = (String)routeNodeInfo.get(sAttrTitle);
    sSequence        = (String)routeNodeInfo.get(sAttrRouteSequence);
    sAllowDelegation = (String)routeNodeInfo.get(sAttrAllowDelegation);
    sAction          = (String)routeNodeInfo.get(sAttrRouteAction);
    sInstruction     = (String)routeNodeInfo.get(sAttrRouteInstructions);
    sDueDate         = (String)routeNodeInfo.get(sAttrScheduledCompletionDate);

    //Check to see if the current task is assigned to group or role
    sAsignee         = (String)routeNodeInfo.get(sAttrRouteTaskUser);

    if(sAsignee == null || ("".equals(sAsignee))){
        sAsignee = (String)map.get("from["+sRelProjectTask+"].to.name");
    }
    else
    {
      String sAsigneeType= sAsignee.substring(0,sAsignee.indexOf("_"));

      if(sAsigneeType.equalsIgnoreCase("role")) {
        sAsignee = i18nNow.getAdminI18NString("Role", Framework.getPropertyValue(session, sAsignee),languageStr);
      }
      else {
        sAsignee = i18nNow.getAdminI18NString("Group", Framework.getPropertyValue(session, sAsignee),languageStr);
      }
    }

    inboxTaskCount++;
    if (rowFlag) {
      className = "even";
      rowFlag = false;
    } else {
      className = "odd";
      rowFlag = true;
    }

%><!-- //XSSOK -->
    <tr class="<%=className%>">
      <td>&nbsp;</td>
      <td><%=XSSUtil.encodeForHTML(context, sSequence)%>&nbsp;</td>
      <td><%=XSSUtil.encodeForHTML(context, sName)%>&nbsp;</td>
      <td><%=XSSUtil.encodeForHTML(context, sAsignee)%> :&nbsp;<%=XSSUtil.encodeForHTML(context, i18nNow.getRangeI18NString(Route.ATTRIBUTE_ROUTE_ACTION, sAction, languageStr))%></td>
<%
      if (sAllowDelegation.equals("TRUE")) {
%>
        <td><img src="../common/images/iconSmallAssignee.gif" name="imgTask" id="imgTask" alt="<emxUtil:i18n localize="i18nId">emxComponents.EditAllTasks.AllowDelegation</emxUtil:i18n>" />&nbsp;</td>
<%
      } else {
%>
        <td>&nbsp;</td>
<%
      }
%>
      <td><%=XSSUtil.encodeForHTML(context, sInstruction)%>&nbsp;</td>
      <!-- //XSSOK -->
      <td><emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=XSSUtil.encodeForHTML(context, DateFrm) %>'><%=XSSUtil.encodeForHTML(context, sDueDate)%></emxUtil:lzDate>&nbsp;</td>
    </tr>
<%
  }

  typePattern = new Pattern(sTypePerson);
  typePattern.addPattern(sTypeRouteTaskUser);
  relPattern  = new Pattern(sRelRouteNode);
  StringList objectSelect = new StringList();
  objectSelect.add(Route.SELECT_NAME);
  objectSelect.add(Route.SELECT_ID);

  StringList relationshipSelects = new StringList();
  relationshipSelects.add(Route.SELECT_ROUTE_ACTION);
  relationshipSelects.add(Route.SELECT_ROUTE_INSTRUCTIONS);
  relationshipSelects.add(Route.SELECT_SCHEDULED_COMPLETION_DATE);
  relationshipSelects.add(Route.SELECT_TITLE);
  relationshipSelects.add(Route.SELECT_ROUTE_SEQUENCE);
  relationshipSelects.add(Route.SELECT_RELATIONSHIP_ID);
  relationshipSelects.add(Route.SELECT_ALLOW_DELEGATION);
  relationshipSelects.add(Route.SELECT_ROUTE_TASK_USER);
  relationshipSelects.add("attribute["+sAttrRouteNodeID+"]");

  MapList resultList = route.getRelatedObjects(context, relPattern.getPattern(), typePattern.getPattern(),objectSelect, relationshipSelects, false, true, (short)1, null, null);
  resultList.sort("attribute["+routeSequenceStr+"]","ascending","integer");

  StringList memberList = new StringList();
  java.util.List<Hashtable> resMemberList = new java.util.ArrayList<Hashtable>();
  Hashtable tempTable = null;

  //HashMap tempMap = new HashMap();
  Hashtable tempMap = new Hashtable();

  String personId = "";
  String personName = "";
  String asigneeType = "";
  String dateList ="";
  for(int i =0; i < resultList.size(); i++)
  {
    tempMap    = (Hashtable) resultList.get(i);
    personName = (String) tempMap.get(Route.SELECT_ROUTE_TASK_USER);
    personId   = (String) tempMap.get(Route.SELECT_ID);

    if(personName == null || "".equals(personName)){
      personName =  (String) tempMap.get(Route.SELECT_NAME);
      asigneeType ="person";
    }else {
      asigneeType = personName.substring(0,personName.indexOf("_"));
      personName = Framework.getPropertyValue(session, personName);
      if(asigneeType.equalsIgnoreCase("role")) {
        asigneeType = "Role";
      }
      else {
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

  int dateCnt =0;
%>
<framework:mapListItr mapList="<%=resultList%>" mapName="routeMap">
<%
  String routeNodeId = (String)routeMap.get(Route.SELECT_RELATIONSHIP_ID);
  String routeNodeAttrId = (String)routeMap.get("attribute["+sAttrRouteNodeID+"]");

  //check the attribute RouteNodeID value in the InboxTask object with the attribute value in the Rel.
  //this is for eliminating the Tasks already created.
  if (!inboxTaskVector.contains(routeNodeAttrId)) {
%>
    <tr class='<framework:swap id ="1" />'>
          <input type="hidden" name="relIds" value="<xss:encodeForHTMLAttribute><%=routeMap.get(Route.SELECT_RELATIONSHIP_ID)%></xss:encodeForHTMLAttribute>"/>
          <input type="hidden" name="oldAssignee" value="<xss:encodeForHTMLAttribute><%=Route.SELECT_ID%></xss:encodeForHTMLAttribute>"/>
          <td><input type="checkbox" name="chkItem1" id="chkItem1" value="<xss:encodeForHTMLAttribute><%=routeMap.get(Route.SELECT_RELATIONSHIP_ID)%></xss:encodeForHTMLAttribute>" /></td>
          <td  nowrap >
            <select name="routeOrder">
<%
            String routeSequenceValueStr = (String) routeMap.get(Route.SELECT_ROUTE_SEQUENCE);
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
            <input type="hidden" name="routeNode" value="<xss:encodeForHTMLAttribute><%=routeMap.get(Route.SELECT_RELATIONSHIP_ID)%></xss:encodeForHTMLAttribute>" />
          </td>
          <td><input type="text" name="taskName" value="<xss:encodeForHTMLAttribute><%=routeMap.get(Route.SELECT_TITLE)%></xss:encodeForHTMLAttribute>" /></td>
          <td>
          <table border="0">
            <tr>
              <td>
                <select name="personId" size="1" >
<%
    /*              Hashtable ht = new Hashtable();
                  String memberName = (String) routeMap.get(Route.SELECT_ROUTE_TASK_USER);

                  if(memberName == null || "".equals(memberName))
                    memberName =  (String) routeMap.get(Route.SELECT_NAME);*/

                  String id = "";
                  String name = "";
                  String assigType = "";
                  String memberName = "";
                  String memberNameIntl = "";
                  Hashtable ht = new Hashtable();
                  String routeTaskUser = (String) routeMap.get(Route.SELECT_ROUTE_TASK_USER);
                  if(routeTaskUser == null || "".equals(routeTaskUser)){
                    memberName =  (String) routeMap.get(Route.SELECT_NAME);
                  } else{
                    memberName = Framework.getPropertyValue(session, routeTaskUser);
                  }

                  for(int j = 0; j < resMemberList.size(); j++)
                  {
                    ht = (Hashtable) resMemberList.get(j);
                    id = (String) ht.get("id");
                    name = (String) ht.get("name");
                    assigType = (String) ht.get("asigneetype");

                    if (assigType.equals("person")) {
                      memberNameIntl =  name;
                    }
                    else {
                      memberNameIntl = i18nNow.getAdminI18NString(assigType,name,languageStr);
                    }

                    if(memberName.equals(ht.get("name"))) {

%>
                      <option value="<%=XSSUtil.encodeForHTMLAttribute(context, id) + "#" + XSSUtil.encodeForHTMLAttribute(context, name)   %>" Selected > <%=XSSUtil.encodeForHTMLAttribute(context, memberNameIntl)%> </option>

<%
                    } else {
%>
                      <option value="<%=XSSUtil.encodeForHTMLAttribute(context, id) + "#" + XSSUtil.encodeForHTMLAttribute(context, name) %>"> <%=XSSUtil.encodeForHTMLAttribute(context, memberNameIntl)%> </option>
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
                  String routeActionValueStr = (String) routeMap.get(Route.SELECT_ROUTE_ACTION);
                  StringList routeActionList = FrameworkUtil.getRanges(context, Route.ATTRIBUTE_ROUTE_ACTION);
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
                    String i18nRouteAction=i18nNow.getRangeI18NString(Route.ATTRIBUTE_ROUTE_ACTION, rangeValue, languageStr);
                      if(routeActionValueStr.equals(rangeValue)) {
%>
                        <option value="<%=XSSUtil.encodeForHTMLAttribute(context, rangeValue)%>" Selected> <%=XSSUtil.encodeForHTMLAttribute(context, i18nRouteAction)%> </option>
<%
                      } else {
%>
                        <option value="<%=XSSUtil.encodeForHTMLAttribute(context, rangeValue)%>"> <%=XSSUtil.encodeForHTMLAttribute(context, i18nRouteAction)%> </option>
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
          String routeAllowDelegationStr = (String) routeMap.get(Route.SELECT_ALLOW_DELEGATION);
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
            <textarea wrap rows="5" cols="25" name="routeInstructions"><xss:encodeForHTML><%=routeMap.get(Route.SELECT_ROUTE_INSTRUCTIONS)%></xss:encodeForHTML></textarea>
          </td>

          <td>
            <table border="0">
              <tr>
<%
                String routeScheduledCompletionDateValueStr = (String) routeMap.get(Route.SELECT_SCHEDULED_COMPLETION_DATE);

              String  displaySelectDate="";
              String scheduledDateVal ="";
                Long time;
                if ((routeScheduledCompletionDateValueStr.equals(null))||(routeScheduledCompletionDateValueStr.equals(""))){
                  slctdate="";
                   displaySelectDate="";
                  scheduledDateVal ="";
                 time = new Long(0);
                } else {
                Date dtObj = new Date(routeScheduledCompletionDateValueStr);
                time = new Long(dtObj.getTime());
                 scheduledDateVal =routeScheduledCompletionDateValueStr;
                  int iTimeZone = (new Double((new Double((String)session.getValue("timeZone"))).doubleValue() * -3600000)).intValue(); //60*60*1000 *-1;

               double iClientTimeOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();
               displaySelectDate = eMatrixDateFormat.getFormattedDisplayDate(routeScheduledCompletionDateValueStr,iClientTimeOffset,request.getLocale());
                  tempdate      = com.matrixone.apps.domain.util.eMatrixDateFormat.getJavaDate(routeScheduledCompletionDateValueStr);
                  GregorianCalendar cal = new GregorianCalendar();
                  int totaloffset = cal.get(Calendar.ZONE_OFFSET);
                  tempdate.setTime(tempdate.getTime()-totaloffset+iTimeZone);
                  mmonth = tempdate.getMonth() + 1;
                  yyear = tempdate.getYear();
                  dday  = tempdate.getDate();// gives no. of years after 1900.
                  if ( yyear >= 100 ) {
                    yyear = yyear - 100;
                  }
                  if (yyear < 10){//trying to display 2 digits for the year field
                    slctdate= mmonth+ "/" +dday+ "/0" + yyear;
                  } else {
                    slctdate= mmonth+ "/" +dday+ "/" + yyear;
                  }
                  hhrs = tempdate.getHours();
                  mmin = tempdate.getMinutes();
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
                  <input onfocus="this.blur()" readonly type="text" name="routeScheduledCompletionDate<%=xx%>" value="<xss:encodeForHTMLAttribute><%=displaySelectDate%></xss:encodeForHTMLAttribute>"/>&nbsp;
                  <a href="javascript:showCalendar('TaskSummary','routeScheduledCompletionDate<%=xx++%>','<%=XSSUtil.encodeForJavaScript(context, scheduledDateVal)%>')" ><img src="../common/images/iconSmallCalendar.gif" border=0 valign="absmiddle" name=img5/></a>&nbsp;
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
%><!-- //XSSOK -->
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
      }
   dateCnt++;
%>
  </framework:mapListItr>
  </table>

<script language="Javascript">
        // This function loads the array of dates into the completion
        // date field. The values stored in the dates array is the number
        // of milliseconds since 1970.
        function loaddates() {
        	//XSSOK
                var datelst ='<%=dateList%>';
                var datetypes = datelst.split(",");
                for (var k=0; k < document.TaskSummary.length; k++ ){
                   if (document.TaskSummary.elements[k].name.substring(0,28)  == "routeScheduledCompletionDate") {
                  var arrayindx= document.TaskSummary.elements[k].name.substring(28,document.TaskSummary.elements[k].name.length);
                  var dateVal = datetypes[arrayindx];
                  document.TaskSummary.elements[k].dateValue = dateVal;
          }
}
}
</script>
</form>
<%!
  //Get the correct relId for the RouteNodeRel given the attr routeNodeId from the InboxTask.
  static public String getRouteNodeRelId(Context context, HttpSession session, String relAttrRouteNodeId, com.matrixone.apps.domain.DomainObject route) throws FrameworkException
  {
  String sAttrRouteNodeID               = Framework.getPropertyValue(session, "attribute_RouteNodeID");
  String sTypePerson                    = Framework.getPropertyValue(session, "type_Person");
  String sTypeRouteTaskUser             = Framework.getPropertyValue(session, "type_RouteTaskUser");
  String sRelRouteNode                  = Framework.getPropertyValue(session, "relationship_RouteNode" );

	  Pattern typePattern = new Pattern(sTypePerson);
	  typePattern.addPattern(sTypeRouteTaskUser);
	  Pattern relPattern  = new Pattern(sRelRouteNode);
	  StringList objectSelects = new StringList();

	  StringList relationshipSelects = new StringList();
	  relationshipSelects.add(route.SELECT_RELATIONSHIP_ID);
	  relationshipSelects.add("attribute["+sAttrRouteNodeID+"]");

	  MapList resultList = route.getRelatedObjects(context, relPattern.getPattern(), typePattern.getPattern(), objectSelects, relationshipSelects, false, true, (short)1, null, null);

	  String routeNodeId = "";

	  Iterator routeItr = resultList.iterator();
	  while(routeItr.hasNext()) {
		  Map routeMap = (Map) routeItr.next();
		  String taskAttrRouteNodeId = (String) routeMap.get("attribute["+sAttrRouteNodeID+"]");
		  if(relAttrRouteNodeId.equals(taskAttrRouteNodeId)) {
			  routeNodeId = (String) routeMap.get(route.SELECT_RELATIONSHIP_ID);
			  break;
		  }
	  }
	  return routeNodeId;
  }
%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

