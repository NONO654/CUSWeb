<%--  emxRouteTemplateWizardAssignTaskDialog.jsp  -  Create Dialog for Assign task
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program

   static const char RCSID[] = $Id: emxRouteTemplateWizardAssignTaskDialog.jsp.rca 1.12 Tue Oct 28 19:01:08 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "emxComponentsJavaScript.js"%>
<%@ page import="com.matrixone.apps.framework.ui.UIUtil,java.util.*" %>
<head>
  <%@include file = "../common/emxUIConstantsInclude.inc"%>
   <script language="Javascript">
  		addStyleSheet("emxUIDefault");
  		addStyleSheet("emxUIList");
 </script>
</head>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%

String keyValue=emxGetParameter(request,"keyValue");

String mode=emxGetParameter(request,"mode");
String strAny =EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(),
		"emxComponents.AssignTasksDialog.Any");
 boolean isResponsibleRoleEnabled=com.matrixone.apps.common.InboxTask.checkIfResponsibleRoleEnabled(context);
if(UIUtil.isNotNullAndNotEmpty(mode)&& mode.equals("EnableResponsibleRole")){
//Method To list Role or Person for selected value in Route Template create form
String strValue=emxGetParameter(request,"assigneeName");
        String strcount=emxGetParameter(request,"count");
		StringList slVal=FrameworkUtil.split(strValue, "~");
		StringBuffer strHTMLElement  = new StringBuffer();
		StringList slSelect=new StringList();
		String strUserOrg = PersonUtil.getActiveOrganization(context);
		boolean isRole=false;
		try{
			 slSelect=PersonUtil.getPersonFromRole(context, slVal.get(1).toString());
			 isRole=true;
		}catch(Exception e){
			slSelect.removeAllElements();
		}
	if((slSelect.size()==0)&&!isRole){
  			strHTMLElement.append("<input type=\"text\"  id=\"recepientList"+strcount+"\" name = \"recepientList\" readonly=true disabled style=\"width:200px\"></input>").append("<input type=\"hidden\" id=\"recepientList"+strcount+"\" name = \"recepientList\"  style=\"width:200px\" value=\" \">  </input>");
  		}
  		else{
  			strHTMLElement.append("<select id=\"recepientList"+strcount+"\" name = \"recepientList\"  style=\"width:200px\">");
  		strHTMLElement.append("<option value=\"Any\">"+strAny+" </option>");
		for(Object obj :slSelect){
				String strAssign=(String)obj;
				String strOrg=PersonUtil.getDefaultOrganization(context, strAssign);
				if(strUserOrg.equals(strOrg)){
              	strHTMLElement.append(" <option value=\""+strAssign+"\">"+PersonUtil.getFullName(context, strAssign) +"</option>");
	}
	}
  		strHTMLElement.append("</select>");
		}
	out.clear();
  	out.println(strHTMLElement);
}
else if(UIUtil.isNullOrEmpty(mode)){
String languageStr     = request.getHeader("Accept-Language");

String strRole = i18nNow.getI18nString("emxComponents.Common.Role", "emxComponentsStringResource", languageStr);
String strGroup = i18nNow.getI18nString("emxComponents.Common.Group", "emxComponentsStringResource", languageStr);
String strUserGroup = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",new Locale(languageStr), "emxFramework.Type.Group");

int xx                                      = 0;
int Count                                   = 0;

int AllowDelegationCount           = 0;
int NeedsReviewCount                        = 0;

   String projectId  =  (String) formBean.getElementValue("objectId");
   String routeId       =  (String) formBean.getElementValue("routeId");
   String templateId    =  (String) formBean.getElementValue("templateId");
   String templateName  =  (String) formBean.getElementValue("templateName");
   String scopeId       =  (String) formBean.getElementValue("scopeId");
   String selectedAction   =  (String) formBean.getElementValue("selectedAction");
   String sortName    =  (String) formBean.getElementValue("sortName");
   String supplierOrgId    =  (String) formBean.getElementValue("supplierOrgId");
   String chkRouteAction   =  (String) formBean.getElementValue("chkRouteAction");
   String portalMode    =  (String) formBean.getElementValue("portalMode");
   String routeTemplateBasePurpose   =  (String) formBean.getElementValue("routeTemplateBasePurpose");
   String fromPageStr  =  (String) formBean.getElementValue("fromPage");
   String toAccessPage =  (String) formBean.getElementValue("toAccessPage");
   

     Date tempdate                               = new Date();

     String advanceDateOption="";
     MapList maplst  = (MapList)formBean.getElementValue("taskMapList");

     MapList routeMemberMapList  = (MapList)formBean.getElementValue("routeMemberMapList");
     Hashtable routeDetails  = (Hashtable)formBean.getElementValue("hashRouteWizFirst");
     String routeTaskEdits = (String) formBean.getElementValue("RouteTaskEdits");
     
     /*UI modifications vh5*/
     StringBuffer personList = new StringBuffer(100);
     StringBuffer rolesList = new StringBuffer(100);
     StringBuffer groupsList = new StringBuffer(100);
     
     Iterator mapItr1 = routeMemberMapList.iterator();
     while(mapItr1.hasNext()){
         Map roleMap = (Map)mapItr1.next();
         String type = (String) roleMap.get("type");
         String name = (String) roleMap.get("name");
         
         if(type.equalsIgnoreCase("Role"))
         {
             rolesList.append(name).append("|");
         }else if(type.equalsIgnoreCase("Group"))
         {
             groupsList.append(name).append("|");
         }else
         {
             personList.append((String) roleMap.get("id")).append("|");
         }
         
     }
     
     if(personList.length() > 0) {
         personList.deleteCharAt(personList.length() -1);
     }
     if(rolesList.length() > 0) {
         rolesList.deleteCharAt(rolesList.length() -1);
     }
     if(groupsList.length() > 0) {
         groupsList.deleteCharAt(groupsList.length() -1);
     }
     
     StringBuffer selectAssigneeURL = new StringBuffer();
     selectAssigneeURL.append("../common/emxIndentedTable.jsp?");
     selectAssigneeURL.append("table=APPUserSummary").append('&');
     selectAssigneeURL.append("selection=single").append('&');
     selectAssigneeURL.append("program=emxRoute:getRouteAssigneesToSelect").append('&');
     selectAssigneeURL.append("showNone=").append("true").append('&');
     selectAssigneeURL.append("personList=").append(personList).append('&');
     selectAssigneeURL.append("roleList=").append(rolesList).append('&');
     selectAssigneeURL.append("groupList=").append(groupsList).append('&');
     selectAssigneeURL.append("submitURL=").append("../components/emxRouteWizardTaskAssignSelectProcess.jsp?fromPage=RouteTemplateWizard").append('&');
     selectAssigneeURL.append("suiteKey=Components").append('&');
     selectAssigneeURL.append("header=emxComponents.Common.AssignTasks").append('&');
     selectAssigneeURL.append("submitLabel=emxFramework.Common.Done").append('&');
     selectAssigneeURL.append("cancelLabel=emxFramework.Common.Cancel").append('&');
     selectAssigneeURL.append("objectBased=false").append('&');
     selectAssigneeURL.append("displayView=details").append('&');
     selectAssigneeURL.append("customize=false").append('&');
     selectAssigneeURL.append("objectCompare=false").append('&');
     selectAssigneeURL.append("multiColumnSort=false").append('&');
     selectAssigneeURL.append("HelpMarker=emxhelpcreateroutewizard3").append('&');
     selectAssigneeURL.append("showClipboard=false").append('&');


       String parentObjectId = null;
       if (routeDetails != null){
           parentObjectId = (String)routeDetails.get("objectId");
       }

       String parentTaskDueDate = getParentTaskDueDate(context,parentObjectId);
       
       toAccessPage = UIUtil.isNullOrEmpty(toAccessPage) ? "" : toAccessPage;
       fromPageStr = UIUtil.isNullOrEmpty(fromPageStr) ? "" : fromPageStr;
       selectedAction = UIUtil.isNullOrEmpty(selectedAction) ? "false" : fromPageStr;

     com.matrixone.apps.common.Person PersonObject = (com.matrixone.apps.common.Person) DomainObject.newInstance(context, DomainConstants.TYPE_PERSON);


//TO GET THE NAME OF THE ROUTE OWNER


      //BusinessObject routeOwner = new BusinessObject(DomainObject.TYPE_PERSON,context.getUser().trim(),"-",context.getVault().getName());
          Person routeOwner = Person.getPerson(context);
      //routeOwner.open(context);
      String routeOwnerName          = routeOwner.getObjectId()+"~"+routeOwner.getName().trim();
      //routeOwner.close(context);

      Hashtable hashRouteWizFirst = (Hashtable)formBean.getElementValue("hashRouteWizFirst");

     templateId          = (String)hashRouteWizFirst.get("templateId");
     
     String sTaskEditSetting = null;
     if(templateId != null && !"".equals(templateId) && !templateId.equals("null")){
          DomainObject routeTempObj = DomainObject.newInstance(context ,templateId);
          sTaskEditSetting = routeTempObj.getAttributeValue(context,DomainObject.ATTRIBUTE_TASKEDIT_SETTING);
          templateName    = routeTempObj.getName(context);
     }
     
     maplst = maplst == null ? new MapList() : maplst;
     routeMemberMapList = routeMemberMapList == null ? new MapList() : routeMemberMapList;

      maplst.sort(PersonObject.ATTRIBUTE_ROUTE_SEQUENCE, "ascending", "String");

 %>


<script language="Javascript">

  var thisday = null;
  var thismonth = null;
  var thisyear = null;
  var CurrentDate = "";

  // function to be called on click of Add Task Link
  function addTask() {


    document.routeActionsForm.action="emxRouteTemplateWizardAssignTaskProcess.jsp?linkFlag=AddTask&projectId=<%=XSSUtil.encodeForURL(context, projectId)%>";

    document.routeActionsForm.submit();
    return;

  }

  // function to remove the task.
  function removeSelected() {

    var checkedFlag = checkedCheckBoxValues();
    if (checkedFlag == '') {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.SelectTask</emxUtil:i18nScript>");
      return;
    } else {
      if (confirm("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.MsgConfirm</emxUtil:i18nScript>") != 0)  {

        document.routeActionsForm.action="emxRouteTemplateWizardAssignTaskProcess.jsp?linkFlag=RemoveSelected&projectId=<%=XSSUtil.encodeForURL(context, projectId)%>";

        document.routeActionsForm.submit();
        return;
      }
    }
  }


    function sortTaskList() {

  <%
      if ( maplst.size() == 0 ) {
  %>
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.TaskMessage</emxUtil:i18nScript>");
        return;
  <%
      } else {
  %>

        document.routeActionsForm.action="emxRouteTemplateWizardAssignTaskProcess.jsp?linkFlag=sortList&projectId=<%=XSSUtil.encodeForURL(context, projectId)%>";

        document.routeActionsForm.submit();
        return;
  <%
      }
  %>
  }


//function to open the RouteTaskAssignSelected dialog window.
  function AssignSelected(){
    var checkedValue = checkedCheckBoxValues();
    if (checkedValue == '') {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignSelected.SelectTask</emxUtil:i18nScript>");
      return;
      } else {
      var selectAssigneeURL = "<%=selectAssigneeURL%>keyValue=<%=XSSUtil.encodeForJavaScript(context, keyValue)%>&routeNodeId="+escape(checkedValue);
      emxShowModalDialog(selectAssigneeURL,575,575);
      }
  }


//function to close the window.
  function closeWindow() {

    submitWithCSRF("emxRouteWizardCancelProcess.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>", window);

  }

  // function to be called on click of previous button
  function goBack() {

    // submit with values to process page of step 4; then from there redirect to step 3
    document.routeActionsForm.action="emxRouteTemplateWizardAssignTaskProcess.jsp?toAccessPage=yes&keyValue=<%=keyValue%>";
    document.routeActionsForm.submit();
    return;

  }


//function to return the checked check box value.
  function checkedCheckBoxValues(){
    var checkedVal='';
    for (var i=0; i < document.routeActionsForm.elements.length; i++) {
      if (document.routeActionsForm.elements[i].name == "routeNodeId" && document.routeActionsForm.elements[i+5].checked)  {
        checkedVal = checkedVal+document.routeActionsForm.elements[i].value+'~'+document.routeActionsForm.elements[i+1].value+'~';
      }
    }
    return checkedVal;

  }


  // function to select all the check boxes
  function doCheck() {

    var objForm = document.routeActionsForm;
    var chkList = objForm.chkList;
    for (var i=0; i < objForm.elements.length; i++)
    if (objForm.elements[i].name=='chkItem1'){
      objForm.elements[i].checked = chkList.checked;
    }

  }


  // removes leading, trailing whitespaces
  function trimStr (textStr) {

      while (textStr.charAt(textStr.length-1)==' ')
        textStr = textStr.substring(0,textStr.length-1);
      while (textStr.charAt(0)==' ')
        textStr = textStr.substring(1,textStr.length);
      return textStr;
  }



   // to allow only integers as delta offsets
  function CheckValidity(toCheckStr){

    var allowedChars = "0123456789";
    for (i = 0; i < toCheckStr.length; i++){
      checkChar = allowedChars.indexOf(toCheckStr.charAt(i))
      if (checkChar < 0){
         return true;
      }
     }
    return false;
   }


  //Array sort numerically
  function sortNum(arrayName,length) {

    for (var i=0; i<(length-1); i++) {
      for (var b=i+1; b<length; b++) {
        if (arrayName[b] < arrayName[i]) {
          var temp = arrayName[i];
          arrayName[i] = arrayName[b];
          arrayName[b] = temp;
        }
      }
    }
  }


 function isDeltaRadio(num){

       var count = 0;
       for ( var k = 0; k < document.routeActionsForm.length; k++ ) {
         if (( document.routeActionsForm.elements[k].type  == "select-one" )&& (document.routeActionsForm.elements[k].name == "routeOrder")){
             count++;
         }
       }
       if (count == 1) {
       //(document.routeActionsForm.duedateOption0[0].checked && document.routeActionsForm.duedateOption0[0].value =="calendar")
          if((document.routeActionsForm.duedateOption0[1].checked && document.routeActionsForm.duedateOption0[1].value =="assignee")) {
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.common.NotDeltaOption</emxUtil:i18nScript>");
            document.routeActionsForm.duedateOffset.value = "";
            document.routeActionsForm.duedateOption0[1].focus();
            return;
          }
        }else {
          if((eval("document.routeActionsForm.duedateOption"+num+"[1].checked") && eval("document.routeActionsForm.duedateOption"+num+"[1].value") =="assignee")) {
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.common.NotDeltaOption</emxUtil:i18nScript>");
            document.routeActionsForm.duedateOffset[num].value = "";
            eval("document.routeActionsForm.duedateOption"+num+"[1].focus();");
            return;
          }
        }
 }

      // if assignee due-date / delta selected, clear default date..
  function toggleDefaultDate(num) {
        var count = 0;

        for ( var k = 0; k < document.routeActionsForm.length; k++ ) {
                if (( document.routeActionsForm.elements[k].type  == "select-one" )&& (document.routeActionsForm.elements[k].name == "routeOrder")){
                        count++;
                }
        }
<%
        if(advanceDateOption.equals("true")){
%>

                if (count == 1) {
                        if((document.routeActionsForm.duedateOption0[1].checked && document.routeActionsForm.duedateOption0[1].value =="assignee")) {
                                document.routeActionsForm.duedateOffset.value = "";
                        }
                        return;
                }else{
                        if((eval("document.routeActionsForm.duedateOption"+num+"[1].checked") && eval("document.routeActionsForm.duedateOption"+num+"[1].value") =="assignee")) {
                                document.routeActionsForm.duedateOffset[num].value = "";
                        }
                        return;
                }

<%
        }
%>
         return;

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

 //function to submit the page.
  function submitForm() {
<%
    // function to check minimum of one task is connected to route object
    if ( maplst.size() == 0 ) {
%>
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.TaskMessage</emxUtil:i18nScript>");
      return;
<%
    }
%>
    var count = 0;
    for (var k=0; k < document.routeActionsForm.length; k++ ) {
      if ((document.routeActionsForm.elements[k].name == "routeOrder")) {
        count++;
      }
    }

    // step 4 : Check Instructions.
    if (count == 1){ //only one instruction field
      var namebadCharDescrption = checkForBadChars(document.routeActionsForm.routeInstructions);
      if (trim(document.routeActionsForm.routeInstructions.value).length == 0){
        alert("<emxUtil:i18nScript localize='i18nId'>emxComponents.RouteAction.EnterInstruc</emxUtil:i18nScript>");
        document.routeActionsForm.routeInstructions.focus();
        return;
      }else if (namebadCharDescrption.length != 0){
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharDescrption+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
        document.routeActionsForm.routeInstructions.focus();
        return;
      }

    } else {

      // more than one instruction field
      for (var k=0; k < count; k++) {
         var namebadCharDescrption = checkForBadChars(document.routeActionsForm.routeInstructions[k]);
        if(trim(document.routeActionsForm.routeInstructions[k].value).length == 0) {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterInstruc</emxUtil:i18nScript>");
          document.routeActionsForm.routeInstructions[k].focus();
          return;
        }else if (namebadCharDescrption.length != 0){
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharDescrption+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
          document.routeActionsForm.routeInstructions[k].focus();
          return;
        }

      }
    }


    var pastDate = "false";
    var position = 0;
    var parentTaskDate = "false";

    // checking whether the date selected is earlier than cuurent date.
    // also added check to prevent Route Owner asking self-review
    for (var i=0; i<document.routeActionsForm.length;i++) {

       if(document.routeActionsForm.elements[i].type=="select-one" && document.routeActionsForm.elements[i].name == "personId"){
         var rtOwnerStr    = '<%=XSSUtil.encodeForJavaScript(context, routeOwnerName)%>';
         var assigneeStr   = document.routeActionsForm.elements[i].options[document.routeActionsForm.elements[i].selectedIndex].value;
         // 3rd form element from task assignee select box is hidden form element having NeedReview flag value
         var needReviewStr = document.routeActionsForm.elements[i+3].value;
         if(rtOwnerStr == assigneeStr && needReviewStr=="Yes"){
           alert("<emxUtil:i18nScript localize="i18nId">emxComponents.TaskEdit.CanNotHaveTaskReview</emxUtil:i18nScript>");
           document.routeActionsForm.elements[i].focus();
           return;
         }
       }

      if ((document.routeActionsForm.elements[i].type  == "text" ) && (document.routeActionsForm.elements[i].name == "taskName")){
        //Added for the Task Title Feature on 21st june 2007
        if(document.routeActionsForm.elements[i].value.length == 0){
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.EnterTitleField</emxUtil:i18nScript>");
            document.routeActionsForm.elements[i].focus();
            return;
        }//End of the Task Title Feature
        var namebadCharName       = checkForNameBadCharsList(document.routeActionsForm.elements[i]);
        if (namebadCharName.length != 0){
              alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
              document.routeActionsForm.elements[i].focus();
              return;
        }

        if (!(isAlphanumeric(trim(document.routeActionsForm.elements[i].value), true))){
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertValidName</emxUtil:i18nScript>");
          document.routeActionsForm.elements[i].focus();
          return;
        }
      }
    }
    // step 1 : Check if tasks in order
    if (count == 1) {     //only one order field
      if (document.routeActionsForm.routeOrder.options !=null && document.routeActionsForm.routeOrder.options[document.routeActionsForm.routeOrder.selectedIndex].value != 1 ) {
         alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterorderBig</emxUtil:i18nScript>" +" "+ document.routeActionsForm.routeOrder.options[document.routeActionsForm.routeOrder.selectedIndex].value + " <emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterorderCont</emxUtil:i18nScript>");
         return;
      }
    } else {
      selArray = document.routeActionsForm.elements["routeOrder"];
      storeArray = new Array(count);
      var missingValue;
      for (ct = 0; ct < count; ct++){
       if(selArray[ct].type == "select-one")
        {
          // get array of values
          storeArray[ct] = parseInt(selArray[ct].options[selArray[ct].selectedIndex].value);
        }
        else
        {
          storeArray[ct] = parseInt(selArray[ct].value);
        }
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

      // check if a value is missing
      if (missingValue > -1) {
        tempValue ="<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.Enterorder</emxUtil:i18nScript>";
        tempValue += missingValue + " <emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterorderSmall</emxUtil:i18nScript> ";
        tempValue += errorValue + " <emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.Encounter</emxUtil:i18nScript> ";
        tempValue += missingValue + "  <emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.Missing</emxUtil:i18nScript>";

        //Solved for the Bug 303944
        //start
        alert(tempValue);
        //end

        // set focus to errorValue
        for (ct = 0; ct < count; ct++){
        // compare to last value before above loop broke
        if(selArray[ct].type == "select-one")
         {

          if ( parseInt(selArray[ct].options[selArray[ct].selectedIndex].value) == errorValue){
            selArray[ct].focus();
            break;
           }
         }
        }
        return;
      }
    }
    // step 2 :  Checking for Empty Dates - Bypassed for(Assignee-set duedate feature)
    //           Check for valid delta offset range, if option selected.

    if (count == 1) {
      if(document.routeActionsForm.duedateOption0[0].checked && document.routeActionsForm.duedateOption0[0].value =="delta"){
          var duedateOffsetJS = trim(document.routeActionsForm.duedateOffset.value);
          var isInvalidRange = CheckValidity(duedateOffsetJS);

          if( duedateOffsetJS.length == 0 || duedateOffsetJS <1 || duedateOffsetJS > 365 || isInvalidRange){
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.common.EnterOffset </emxUtil:i18nScript>");
            document.routeActionsForm.duedateOffset.value = "";
            document.routeActionsForm.duedateOffset.focus();
            return;
          }
       }
    } else {
      for (var k=0; k < count; k++){
        if((eval("document.routeActionsForm.duedateOption"+k+"[0].checked") && eval("document.routeActionsForm.duedateOption"+k+"[0].value") =="delta")){
           var duedateOffsetJS = trim(document.routeActionsForm.duedateOffset[k].value);
           var isInvalidRange = CheckValidity(duedateOffsetJS);
           if( duedateOffsetJS.length == 0 || duedateOffsetJS <1 || duedateOffsetJS > 365 || isInvalidRange){
             alert("<emxUtil:i18nScript localize="i18nId">emxComponents.common.EnterOffset</emxUtil:i18nScript>");
             document.routeActionsForm.duedateOffset[k].value="";
             document.routeActionsForm.duedateOffset[k].focus();
             return;
            }
         }
      }
    }
    // step 5 :  Submit form.
    startProgressBar(true);
    document.routeActionsForm.submit();
  }
 
 
//function to list Role And Person for Route
function getReviewersList(objThis,count) {
var assineeName=objThis.value;
			document.getElementById("recepientList"+count).style.visibility = 'visible';
	document.getElementById("recepientList"+count).style="width:200px";
	 		var response = emxUICore.getDataPost("../components/emxRouteTemplateWizardAssignTaskDialog.jsp?mode=EnableResponsibleRole&assigneeName="+assineeName+"&count="+count);
	 	       document.getElementById("recepientDivList"+count).innerHTML=response;
     }
</script>


<%
try{
%>
    <%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%
  }catch(Exception e) {

    String error = ComponentsUtil.i18nStringNow("emxComponents.AssignTaskDialog.ErrorMessage",languageStr);
%>
    <table width="90%" border="0"  cellspacing="0" cellpadding="3"  class="formBG" align="center" >
      <tr >
        <td class="errorHeader"><%=XSSUtil.encodeForJavaScript(context, error)%></td>
      </tr>
    </table>
<%
  }
String strAssigneeLabel=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(),"emxComponents.AssignTasksDialog.AssigneeInstructions");
if(isResponsibleRoleEnabled){
	strAssigneeLabel=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(),"emxComponents.AssignTasksDialog.AssigneeReviewerInstructions");
}

%>


<body class="editable">
<form method="post" name="routeActionsForm" onSubmit="javascript:submitForm(); return false" action="emxRouteTemplateWizardAssignTaskProcess.jsp" target="_parent" >

<input type="hidden" name="routeId"         value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="objectId"        value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="templateId"      value="<xss:encodeForHTMLAttribute><%=templateId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="scopeId"      value="<xss:encodeForHTMLAttribute><%=scopeId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="templateName" value="<xss:encodeForHTMLAttribute><%=templateName%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="chkRouteAction" value="<xss:encodeForHTMLAttribute><%=chkRouteAction%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="sortName" value="<xss:encodeForHTMLAttribute><%= sortName %></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="projectId"    value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="keyValue" value="<xss:encodeForHTMLAttribute><%=keyValue%></xss:encodeForHTMLAttribute>" />

<table class="list" id="taskList">
	<tbody>
		<tr>
			<th width="5%" style="text-align:center">
				<input type="checkbox" name="chkList" id="chkList" onclick="doCheck()"/>
			</th>
			<th nowrap width="20%" class="required">
				<emxUtil:i18n localize="i18nId">emxComponents.AssignTasksDialog.TitleActionOrder</emxUtil:i18n>
			</th>
			<th nowrap width="35%" class="required">
				<%=strAssigneeLabel%>
			</th>
			<th nowrap width="42%" class="required">
				<emxUtil:i18n localize="i18nId">emxComponents.common.Advanced</emxUtil:i18n>
			</th>
		</tr>
		<framework:ifExpr expr="<%=maplst.isEmpty()%>">
			<tr>
				<td align="center" colspan="13" class="error">
					<emxUtil:i18n localize="i18nId">emxComponents.AddMembers.NoMembers</emxUtil:i18n>
				</td>
	   		</tr>
		</framework:ifExpr>
		<framework:ifExpr expr="<%=!maplst.isEmpty()%>">
<%
          Iterator mapItr = maplst.iterator();
           while(mapItr.hasNext()) {
      			Map  map                              = (Map)mapItr.next();
    			String sPersonId                             = (String)map.get("PersonId");
    			String userName                              = (String)map.get(DomainConstants.SELECT_NAME);
			    String sPersonName                           = (String)map.get("PersonName");
			    String routeSequenceValueStr                 = (String)map.get(PersonObject.ATTRIBUTE_ROUTE_SEQUENCE);
			    String routeAllowDelegationStr               = (String)map.get(PersonObject.ATTRIBUTE_ALLOW_DELEGATION);
		    	String strAssigneeDueDateOpt                 = (String)map.get(DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE);
    			String routeActionValueStr                   = (String)map.get(PersonObject.ATTRIBUTE_ROUTE_ACTION);
				String    routeInstructionsValueStr             = (String)map.get(PersonObject.ATTRIBUTE_ROUTE_INSTRUCTIONS);
    			String taskNameValueStr                      = (String)map.get(PersonObject.ATTRIBUTE_TITLE);
				String    routeScheduledCompletionDateValueStr  = (String)map.get(PersonObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE);
				String strNeedsReview                        = (String)map.get(DomainObject.ATTRIBUTE_REVIEW_TASK);
				String strDueDateOffset                      = (String)map.get(DomainObject.ATTRIBUTE_DUEDATE_OFFSET);
				String strDueDateOffsetFrom                  = (String)map.get(DomainObject.ATTRIBUTE_DATE_OFFSET_FROM);
				String sTemplateTask                    = (String)map.get("templateFlag");
			    int routeNodeIds                         = 0;
			   try{
			         routeNodeIds                     = Integer.parseInt((String)map.get(PersonObject.RELATIONSHIP_ROUTE_NODE));
		       } catch(Exception sTask){}
		       
		       routeAllowDelegationStr = UIUtil.isNullOrEmpty(routeAllowDelegationStr) ? "" : routeAllowDelegationStr;
		       strNeedsReview = UIUtil.isNullOrEmpty(strNeedsReview) ? "" : strNeedsReview;

			   boolean bDueDateEmpty = UIUtil.isNullOrEmpty(routeScheduledCompletionDateValueStr);
			   boolean bAssigneeDueDate = "Yes".equalsIgnoreCase(strAssigneeDueDateOpt);
			   boolean bDeltaDueDate = !UIUtil.isNullOrEmpty(strDueDateOffset) && bDueDateEmpty;
			   boolean bShowSystemDate = "AccessMembersProcess".equals(fromPageStr) && !"yes".equalsIgnoreCase(toAccessPage) && !bAssigneeDueDate && !bDeltaDueDate;
			   boolean bOwnerNotSetDate = bDueDateEmpty && !bAssigneeDueDate && !bDeltaDueDate && !bShowSystemDate;
			   
			   double clientTZOffset     = (new Double((String)session.getValue("timeZone"))).doubleValue();
			   
			   String slctdate = bDueDateEmpty ? "" : null;

			  if (!bDueDateEmpty){
        		tempdate                = eMatrixDateFormat.getJavaDate(routeScheduledCompletionDateValueStr);
		        slctdate                = eMatrixDateFormat.getFormattedDisplayDate(routeScheduledCompletionDateValueStr,clientTZOffset, request.getLocale());
			  }
			  
			  boolean isTemplateTask = sTemplateTask != null && sTemplateTask.equals("Yes");
			  boolean canModDelTaskList = "Modify/Delete Task List".equals(sTaskEditSetting);
			  boolean canModTaskList = "Modify Task List".equals(sTaskEditSetting);
			  
			  
			  //Bug 345680: Show options Approve,Comment,Notify Only only
			  AttributeType attrRouteAction = new AttributeType(DomainConstants.ATTRIBUTE_ROUTE_ACTION);
			  attrRouteAction.open(context);
			    
			  // Remove the Info Only and Investigate ranges which we no longer support-Bug 347955
			  StringList routeActionList = attrRouteAction.getChoices(context);
			  routeActionList.remove ("Information Only");
			  routeActionList.remove ("Investigate");
				//Modified for bug 359347				  
			  Collections.sort((java.util.List)routeActionList);
			 
			  attrRouteAction.close(context);
			  
          	String checkAssigneeSetDueDate = bAssigneeDueDate || !bDeltaDueDate ? "checked" : "";
		    String checkAllowDelegation = "TRUE".equals(routeAllowDelegationStr) ? "checked" : "";
		    String checkNeedsReivew = "Yes".equals(strNeedsReview) ? "checked" : "";
  %>
    <tr class='<framework:swap id="1" />'>
        <input type="hidden" name="routeNodeId" value="<xss:encodeForHTMLAttribute><%=routeNodeIds%></xss:encodeForHTMLAttribute>"/>
        <input type="hidden" name="oldAssignee" value="<%=XSSUtil.encodeForHTMLAttribute(context, sPersonId)%>~<%=XSSUtil.encodeForHTMLAttribute(context, sPersonName)%>"/>
        <input type="hidden" name="templateTask" value="<xss:encodeForHTMLAttribute><%=sTemplateTask%></xss:encodeForHTMLAttribute>"/>
        <input type="hidden" name="AllowDelegation" value="<xss:encodeForHTMLAttribute><%=routeAllowDelegationStr%></xss:encodeForHTMLAttribute>"/>
        <input type="hidden" name="NeedsReview" value="<xss:encodeForHTMLAttribute><%=strNeedsReview%></xss:encodeForHTMLAttribute>"/>
    
		<td style="text-align: center;vertical-align:top;">
			<table>
				<tr>
					<td>
						<input type = "checkbox" name = "chkItem1" id = "chkItem1" value = "<%=Count++%>"/>
					</td>
				</tr>
			</table>
		</td>
		<!-- Title, Action & Number Column -->
		<td style="vertical-align:top">
			<table>
				<tbody>
					<tr><!-- Title Field -->
						 	<td>
						 		<table>
						 			<tr>
						 				<td>
										 	<framework:ifExpr expr="<%=!isTemplateTask || canModDelTaskList%>">
										 		<input type="text" name="taskName" size="20" value="<xss:encodeForHTMLAttribute><%=taskNameValueStr%></xss:encodeForHTMLAttribute>"/>
									 		</framework:ifExpr>
										 	<framework:ifExpr expr="<%=isTemplateTask && !canModTaskList%>">
												<%=XSSUtil.encodeForHTML(context, taskNameValueStr)%>(t)
												<input type="hidden" name="taskName" value="<xss:encodeForHTMLAttribute><%=taskNameValueStr%></xss:encodeForHTMLAttribute>"/>
										 	</framework:ifExpr>
						 				</td>
						 			</tr>
					 			</table>
							 </td>
						</tr>
						<tr> <!-- Action -->
							<td>
								<table>
									<tbody>
										<tr>
											<td style="font-weight: bold;padding-top:10px;padding-bottom: 2px;">
												<emxUtil:i18n localize = "i18nId">emxComponents.common.Action</emxUtil:i18n>
											</td>
										</tr>
										<tr>
											<td>
												<select name="routeAction" >
<%
                                                  //add the actions according to the Route Base Purpose selected in initial Page
                                                   if("Approval".equals(routeTemplateBasePurpose)){                                                    
                                                        routeActionList = new StringList(1);
                                                        routeActionList.add("Approve");
                                                    }else if("Review".equals(routeTemplateBasePurpose)){                                                    
                                                        routeActionList = new StringList(1);
                                                        routeActionList.add("Comment");
                                                    }
													StringItr  routeActionItr  = new StringItr (routeActionList);
													while(routeActionItr.next()) {
													    String rangeValue = routeActionItr.obj();
													    String i18nRouteAction = i18nNow.getRangeI18NString(PersonObject.ATTRIBUTE_ROUTE_ACTION, rangeValue, languageStr);
													    String selected = (routeActionValueStr != null) && routeActionValueStr.equals(rangeValue) ? "selected" : "";
%>
														<option value="<%=XSSUtil.encodeForHTMLAttribute(context, rangeValue)%>" <%=XSSUtil.encodeForHTMLAttribute(context, selected) %>> <%=XSSUtil.encodeForHTML(context, i18nRouteAction)%> </option>
<% 										    
													}
%>									
												</select>										
											</td>
										</tr>
										<tr> <!-- Order Field -->
											<td>
												<table>
													<tbody>
														<tr>
											 				<td style="font-weight: bold;padding-top:10px;padding-bottom: 2px;">
															 	<emxUtil:i18n localize = "i18nId">emxComponents.common.Order</emxUtil:i18n>&nbsp;
															</td>
														</tr>
														<tr>
															<td>
																<framework:ifExpr expr="<%=!isTemplateTask || (canModDelTaskList || canModTaskList)%>">
																	<select name = "routeOrder" >
<%
															              for (int loop = 1; loop <= 20; loop++) {
															                Integer integerType     = new Integer(loop);
															                String loopString       = integerType.toString();
															                String selected = loopString.equals(routeSequenceValueStr) ? "selected" : "";
%>									           
																				 <option value="<%=loop%>" <%=XSSUtil.encodeForHTMLAttribute(context, selected)%>><%=loop%></option>
<%
															              }
%>
																	</select>
																</framework:ifExpr>
																<framework:ifExpr expr="<%=isTemplateTask && !(canModDelTaskList || canModTaskList)%>">
																	<%=XSSUtil.encodeForHTML(context, routeSequenceValueStr)%>
																	<input type="hidden" name="routeOrder" value="<xss:encodeForHTMLAttribute><%=routeSequenceValueStr%></xss:encodeForHTMLAttribute>"/>
																	</framework:ifExpr>
															</td>											
														</tr>
													</tbody>
												</table>
											</td>
										</tr>
										
									</tbody>
								</table>
							</td>
						</tr>						
				</tbody>
			</table>
		</td>
		<td style="vertical-align:top"> <!-- Assignee & Instructions -->
			<table>
            	<tr> <!-- Assignee -->
            		<td>
            			<table>
            				<tr>
            					<td style="padding-top:3px;">
			            			<select name="personId" id="personId" onchange="getReviewersList(this,<%=Count%>)">
			            				<%
			            				if("Modify/Delete Task List".equals(routeTaskEdits) || "Modify Task List".equals(routeTaskEdits)){
			            				%>
			            				<option value="none~none">
			            					<emxUtil:i18n localize="i18nId">emxComponents.RouteTemplateTaskAssignees.None</emxUtil:i18n>
			            				</option>
			            				<% } %>
		            					<framework:mapListItr mapList="<%=routeMemberMapList%>" mapName="tempMap">
<%
											String strPersonId = (String)tempMap.get(PersonObject.SELECT_ID);
											String strUserName = (String)tempMap.get("name");
											String strPersonName = (String)tempMap.get("LastFirstName");
			                                
			                                if (UIUtil.isNullOrEmpty(strPersonId)) {//Invalid
			                                    continue;
			                                }
											
											strPersonId = (strPersonId == null || "".equals(strPersonId)) ? "Role" : strPersonId;
											strPersonName = strPersonId.equals("Role") ? i18nNow.getAdminI18NString("Role", strPersonName, languageStr) + "(" + strRole + ")" :
		  										        strPersonId.equals("Group") ? i18nNow.getAdminI18NString("Group",strPersonName,languageStr) + "(" + strGroup + ")" :
  	  										            strPersonName;
										     if(FrameworkUtil.isObjectId(context,strPersonId) && new DomainObject(strPersonId).isKindOf(context ,PropertyUtil.getSchemaProperty(context,"type_GroupProxy")))  {
										    	 strPersonName = strPersonName + "(" + strUserGroup +")" ;
										     }
											String selected = strPersonId.equals("Role") && strUserName.equals(sPersonName) ||
				  										  strPersonId.equals("Group") && strUserName.equals(sPersonName) ||
 				  										  strUserName.equals(userName) ? "selected" : "";
										        

%>		            				
												<option value="<%=XSSUtil.encodeForHTMLAttribute(context, strPersonId)%>~<%=XSSUtil.encodeForHTMLAttribute(context, strUserName)%>" <%=XSSUtil.encodeForHTMLAttribute(context, selected)%>> <%=XSSUtil.encodeForHTML(context, strPersonName)%></option>
			            				</framework:mapListItr>
			            			</select>		            					
            					</td>
            				</tr>
            				<%
            				if(isResponsibleRoleEnabled){
            				%>
            				<tr>
            				<td width="2%" style="text-align: left;" >
        								<div  id="recepientDivList<%=Count%>"style="text-align: left;" >	
            				<%
            						StringList slSelect=new StringList();
            						boolean isRoleSelected=false;
            			    	 	 try{
            			    	 		 slSelect=PersonUtil.getPersonFromRole(context, sPersonName);
            			    	 		isRoleSelected=true;
            							}catch(Exception e){
            								slSelect.removeAllElements();
            							}
            			    	 	 String strOrg = PersonUtil.getActiveOrganization(context);
            			    	 	if((!slSelect.isEmpty())||isRoleSelected){
               				%>
       										 <select id = "recepientList<%=Count%>" name = "recepientList" style="width:200px">
        										<%
        										String strRecipient                    = (String)map.get("recepient");
    											%>
   		 																		<option value="Any"><%= strAny%></option>
   												<%
       													for(Object strAssign:slSelect){
      	   															 String strAssigneName=	(String)strAssign;
       				            String org=PersonUtil.getDefaultOrganization(context, strAssigneName);
       					    if(org.equals(strOrg)){
      	   														String selected = "";
      	   															 if(UIUtil.isNotNullAndNotEmpty(strRecipient)&&strRecipient.equals(strAssigneName))
      	   															selected="selected";
     																	String 	strAssignDisplay=PersonUtil.getFullName(context, strAssigneName);
          										  %>
		 																<option value="<%=strAssign %>" <%=selected %> ><%=strAssignDisplay %></option>
										          <%
        													}
        				}
          											%>
          											
          											</select>
   					<%
        				  }else{
        	        		%>
        	        	 	<input type="text" id = "recepientList<%=Count %>" name = "recepientList" readonly=true disabled style="width:200px"></input>
          	                        <input type="hidden"  id = "recepientList<%=Count %>" name = "recepientList" style="width:200px" value="">  </input>
        	 			<%
      						}
       					%>
 	      				</div>
       										</td> 
       								</tr>
       								<%
       							}
       									%>
							
            				
            			</table>
            		</td>
            	</tr>
            	<tr> <!-- Instructions -->
            		<td>
            			<table>
            				<tr>
			            		<td style="padding-top:3px;">
			            			<textarea style="min-height:50px;width:250px;" rows="6" name="routeInstructions"><xss:encodeForHTML><%=routeInstructionsValueStr%></xss:encodeForHTML></textarea>
			            		</td>
            				</tr>
            			</table>
            		</td>
            	</tr>
            </table>
		</td>
    	<td style="vertical-align:top"> <!-- Advanced  -->
    		<table>
    			<tbody>
    				<tr>
    					<td>
    						<table>
    							<tr>
    								<td>
                 						 <input type = "radio" onclick="javascript:toggleDefaultDate('<%=xx%>')" id = "duedateOption<%=xx%>" name = "duedateOption<%=xx%>" value ="delta" <%=bDeltaDueDate?"checked":""%> />
                    					 <input type="text" onfocus="isDeltaRadio('<%=xx%>')" name="duedateOffset" size="3" value="<xss:encodeForHTMLAttribute><%=bDeltaDueDate?strDueDateOffset:""%></xss:encodeForHTMLAttribute>" />
                      					 <emxUtil:i18n localize = "i18nId">emxComponents.common.DaysFrom</emxUtil:i18n>
                        				 <select name="duedateOffsetFrom" style="font-size:8pt; font-face=verdana, arial" onFocus="isDeltaRadio('<%=xx%>')">
<%
					                           StringItr  offsetItr    = new StringItr (FrameworkUtil.getRanges(context, DomainObject.ATTRIBUTE_DATE_OFFSET_FROM));
                    					       while(offsetItr.next()) {
					                           		String rangeValue        = offsetItr.obj();
						                            String i18nOffsetFrom    = i18nNow.getRangeI18NString(DomainObject.ATTRIBUTE_DATE_OFFSET_FROM, rangeValue, languageStr);
						                            String Slct  = (strDueDateOffsetFrom != null && strDueDateOffsetFrom.equals(rangeValue) )?"selected":"";
%>
						                            <option value="<%=XSSUtil.encodeForHTMLAttribute(context, rangeValue)%>" <%=Slct%>> <%=XSSUtil.encodeForHTML(context, i18nOffsetFrom)%> </option>
<%
                          						}
%>
				                        </select>
    								</td>
    							</tr>
    							
    						</table>
    					</td>
    				</tr>
    				<tr>
    					<td>
    						&nbsp;
    					</td>
    				</tr>
    				<tr>
    					<td>
    						<table>
    							<tr>
    								<td>
	    								<input type = "radio" onclick="javascript:toggleDefaultDate('<%=xx%>')" id = "duedateOption<%=xx%>" name = "duedateOption<%=xx++%>" value = "assignee" <%=checkAssigneeSetDueDate%>/>    								
	    								<emxUtil:i18n localize = "i18nId">emxComponents.AssignTasksDialog.AssigneeDueDate</emxUtil:i18n>
    								</td>
    							</tr>
    						</table>
    					</td>
    				</tr>
    				<tr>
    					<td>
    						&nbsp;
    					</td>
    				</tr>
    				<tr>
    					<td>
    						<table>
    							<tr>
    								<td>
										<input type="checkbox" name="AllowDelegationchkItem" id="AllowDelegationchkItem" <%=checkAllowDelegation%> value="<%=AllowDelegationCount++%>"/>
										<emxUtil:i18n localize = "i18nId">emxComponents.AssignTasksDialog.AllowDelegation</emxUtil:i18n>
										&nbsp;
										<input type="checkbox" name="NeedsReviewchkItem" id="NeedsReviewchkItem" <%=checkNeedsReivew%> value="<%=NeedsReviewCount++%>"/>
										<emxUtil:i18n localize = "i18nId">emxComponents.AssignTasksDialog.RequiresOwnerReview</emxUtil:i18n>
    								</td>
    							</tr>
    						</table>
    					</td>
    				</tr>
    			</tbody>
    		</table>
		</td>
    </tr>
    <%
     }//while
 %>
</framework:ifExpr>
</tbody>
 </table>
</form>
</body>


<%!
// Method to return Parent Task Due Date will return null if no parent task
public static String getParentTaskDueDate(Context context,String objectId){
  String parentTaskDueDate=null;
  try{
    if(objectId!=null){
      DomainObject doObject=DomainObject.newInstance(context,objectId,DomainObject.TEAM);
      if(DomainObject.TYPE_INBOX_TASK.equals(doObject.getType(context))){
        parentTaskDueDate=doObject.getInfo(context,"attribute["+DomainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE+"]");
      }
    }
  }catch(Exception ex){
  }
  return parentTaskDueDate;
}

%>
<%
}
%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
