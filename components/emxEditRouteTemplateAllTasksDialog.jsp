<%--  emxEditRouteTemplateAllTasksDialog.jsp

   Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxEditRouteTemplateAllTasksDialog.jsp.rca 1.19 Tue Oct 28 19:01:04 2008 przemek Experimental przemek $
--%>

<%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@include file  = "emxRouteInclude.inc"%>
<%@include file  = "../emxJSValidation.inc" %>
<%@page import  = "com.matrixone.apps.domain.util.*"%>
<head>
	<%@include file = "../common/emxUIConstantsInclude.inc"%>
<script language="JavaScript" src="../common/scripts/emxUICore.js"
	type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js"
	type="text/javascript"></script>
	<script language="Javascript">
		addStyleSheet("emxUIDefault");
		addStyleSheet("emxUIList");
	</script>
</head>

<%

String mode=emxGetParameter(request,"mode");
String strKindOfProxyGroup = "type.kindof["+ PropertyUtil.getSchemaProperty(context, "type_GroupProxy") +"]";
String strAny =EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(),
		"emxComponents.AssignTasksDialog.Any");

boolean isResponsibleRoleEnabled=com.matrixone.apps.common.InboxTask.checkIfResponsibleRoleEnabled(context);
String strAssigneeLabel=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(),"emxComponents.AssignTasksDialog.AssigneeInstructions");
if(isResponsibleRoleEnabled){
	strAssigneeLabel=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(),"emxComponents.AssignTasksDialog.AssigneeReviewerInstructions");
}

if(UIUtil.isNotNullAndNotEmpty(mode)&& mode.equals("EnableResponsibleRole")){
//Method To list Role or Person for selected value in Route Template create form
 String strAssigneeName=emxGetParameter(request,"assigneeName");
        String strcount=emxGetParameter(request,"count");
		StringList slRecepientList=new StringList();
  	 	StringBuffer strHTMLElement  = new StringBuffer();
  	 	String strUserOrg = PersonUtil.getActiveOrganization(context);
  	 	boolean isRole=false;
		try{
			slRecepientList=PersonUtil.getPersonFromRole(context,strAssigneeName);
			isRole=true;
		}catch(Exception e){
			slRecepientList.removeAllElements();
                	
		}
	
  		if((slRecepientList.size()==0)&&!isRole){
  			strHTMLElement.append("<input type=\"text\"  id=\"recepientList"+XSSUtil.encodeForHTMLAttribute(context,strcount)+"\" name = \"recepientList\" readonly=true disabled style=\"width:200px\"></input>").append("<input type=\"hidden\" id=\"recepientList"+XSSUtil.encodeForHTMLAttribute(context,strcount)+"\" name = \"recepientList\"  style=\"width:200px\" value=\" \">  </input>");
  		}
  		else{
  			strHTMLElement.append("<select id=\"recepientList"+XSSUtil.encodeForHTMLAttribute(context,strcount)+"\" name = \"recepientList\"  style=\"width:200px\">");
  		strHTMLElement.append("<option value=\"Any\">"+strAny+" </option>");
		for(Object obj :slRecepientList){
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
  DomainObject domainObject = DomainObject.newInstance(context);
  RouteTemplate routetemplate = (RouteTemplate)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE_TEMPLATE);


  // preload lookup strings
  String advanceDateOption = EnoviaResourceBundle.getProperty(context,"emxComponents.common.AdvancedDateOption");
  String routeTemplateId                        = emxGetParameter(request,"objectId");
  String sAttrRouteAction               = PropertyUtil.getSchemaProperty(context, "attribute_RouteAction");
  String sAttrRouteInstructions         = PropertyUtil.getSchemaProperty(context, "attribute_RouteInstructions");


  String sAttrTitle                     = PropertyUtil.getSchemaProperty(context, "attribute_Title");
  String sAttrRouteSequence             = PropertyUtil.getSchemaProperty(context, "attribute_RouteSequence");
  String sAttrRouteNodeID               = PropertyUtil.getSchemaProperty(context, "attribute_RouteNodeID");
  String sAttrRouteTaskUser             = PropertyUtil.getSchemaProperty(context, "attribute_RouteTaskUser");

  String typeRouteTaskUser      = PropertyUtil.getSchemaProperty(context, "type_RouteTaskUser");
  String sTypePerson                    = PropertyUtil.getSchemaProperty(context, "type_Person");
  String sRelRouteNode                  = PropertyUtil.getSchemaProperty(context, "relationship_RouteNode" );

  String languageStr     = request.getHeader("Accept-Language");
  String timeZone        = (String)session.getValue("timeZone");
  
  //Added for IR-043896V6R2011
     String newTaskIds                      = emxGetParameter(request,"newTaskIds");
  String isRouteTemplateRevised = emxGetParameter(request,"isRouteTemplateRevised"); 
  //Addition ends for IR-043896V6R2011

  String sAsigneeId        = "";
  String sRelId            = "";
  String sName             = null;
  String sRouteNodeID      = "";
  String sSequence         = "";
  String sAsignee          = null;
  String sDueDate          = null;
  String sAllowDelegation  = "";
  String sReviewTask="";
  String sConnectedRoute   = "";
  String sAction           = null;
  String sInstruction      = null;
  String sState            = null;
  String sTaskId           = null;
  Date curDate             = new Date();
  //String className = "even";
  boolean bFlag            = false;
  boolean rowFlag          = false;
  int taskCount            = 0;
  int inboxTaskCount       = 0;
  String routeDueDateOffsetFromStr= null;
    String sSelected         = "";
    String routeId="";

    final String STRING_NONE = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.RouteTemplateTaskAssignees.None");

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
  domainObject.setId(routeTemplateId);
  routetemplate.setId(routeTemplateId);
  //Get the route base purpose
  String sAttrRouteBasePurpose = PropertyUtil.getSchemaProperty(context, "attribute_RouteBasePurpose" );
  String routeBasePurpose = domainObject.getInfo(context,domainObject.getAttributeSelect(sAttrRouteBasePurpose));


  int sTaskSequence = 0;
  String sSequenceTask = "";
  int bTemp = 0;
 sTaskSequence = bTemp;
 
 
 /* UI Modifiations vh5 */
  StringBuffer personList = new StringBuffer(100);
  StringBuffer rolesList = new StringBuffer(100);
  StringBuffer groupsList = new StringBuffer(100);
  StringBuffer userGroupsList = new StringBuffer(100);
  StringList selectTypeStmts  =  new StringList();
  StringList selectTypeStmts1  =  new StringList();
  String roleGroupName ="";
  selectTypeStmts.add(routetemplate.SELECT_NAME);
  selectTypeStmts.add(strKindOfProxyGroup);
  
  com.matrixone.apps.domain.util.MapList routeMemberList  = routetemplate.getRouteTemplateMembers(context,selectTypeStmts,selectTypeStmts1,false);
  Iterator mapItr1 = routeMemberList.iterator();
  
  while(mapItr1.hasNext()){
      Map roleMap = (Map)mapItr1.next();
      String type = (String)roleMap.get(DomainObject.SELECT_TYPE);
      String roleName = (String)roleMap.get("attribute["+DomainObject.ATTRIBUTE_ROUTE_TASK_USER+"]");
      String isKindOfProxyGroup = (String)roleMap.get(strKindOfProxyGroup);
      if(type.equals(DomainObject.TYPE_ROUTE_TASK_USER)) {
          if(UIUtil.isNullOrEmpty(roleName)) {
              continue;
          }
          if(roleName.startsWith("role_")) {
              roleGroupName = (String) com.matrixone.apps.domain.util.PropertyUtil.getSchemaProperty(context,roleName);
              rolesList.append(roleGroupName).append("|");
          } else if(roleName.startsWith("group_")) {
              roleGroupName = (String) com.matrixone.apps.domain.util.PropertyUtil.getSchemaProperty(context,roleName);
              groupsList.append(roleGroupName).append("|");
          }
      } else {
    	  if("true".equalsIgnoreCase(isKindOfProxyGroup)){
    		  userGroupsList.append(roleMap.get("id")).append("|");
    	  }else {
          personList.append(roleMap.get("id")).append("|");
      }
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
  if(userGroupsList.length() > 0) {
	  userGroupsList.deleteCharAt(userGroupsList.length() -1);
  }
  StringList slBusSelect = new StringList(routetemplate.SELECT_ROUTE_BASE_PURPOSE);
  slBusSelect.add (DomainObject.SELECT_TYPE);
  slBusSelect.add (DomainObject.SELECT_CURRENT);
  
  Map mapRouteObjInfo = routetemplate.getInfo (context, slBusSelect);
  String sTypeName = (String) mapRouteObjInfo.get (DomainObject.SELECT_TYPE);
  String sRoute = (String) mapRouteObjInfo.get (routetemplate.SELECT_ROUTE_BASE_PURPOSE);
  
  String sCurrentState = (String) mapRouteObjInfo.get (DomainObject.SELECT_CURRENT);

  boolean showNoneOption = (DomainObject.TYPE_ROUTE_TEMPLATE.equals(sTypeName) || 	
        				   (DomainObject.TYPE_ROUTE.equals(sTypeName) && DomainObject.STATE_ROUTE_DEFINE.equals(sCurrentState)));


  StringBuffer selectAssigneeURL = new StringBuffer();
  selectAssigneeURL.append("../common/emxIndentedTable.jsp?");
  selectAssigneeURL.append("table=APPUserSummary").append('&');
  selectAssigneeURL.append("selection=single").append('&');
  selectAssigneeURL.append("program=emxRoute:getRouteAssigneesToSelect").append('&');
  selectAssigneeURL.append("showNone=").append(showNoneOption).append('&');
  selectAssigneeURL.append("personList=").append(personList).append('&');
  selectAssigneeURL.append("roleList=").append(rolesList).append('&');
  selectAssigneeURL.append("groupList=").append(groupsList).append('&');
  selectAssigneeURL.append("userGroupList=").append(userGroupsList).append('&');
  selectAssigneeURL.append("submitURL=").append("../components/emxRouteTemplateTaskAssignSelectProcess.jsp?fromPage=RouteTemplate").append('&');
  selectAssigneeURL.append("routeId=").append(XSSUtil.encodeForURL(context, routeTemplateId)).append('&');
  selectAssigneeURL.append("suiteKey=Components").append('&');
  selectAssigneeURL.append("header=emxComponents.Common.AssignTasks").append('&');
  selectAssigneeURL.append("submitLabel=emxFramework.Common.Done").append('&');
  selectAssigneeURL.append("cancelLabel=emxFramework.Common.Cancel").append('&');
  selectAssigneeURL.append("objectBased=false").append('&');
  selectAssigneeURL.append("displayView=details").append('&');
  selectAssigneeURL.append("HelpMarker=emxhelpcreateroutewizard3").append('&');
  selectAssigneeURL.append("showClipboard=false").append('&');
%>

<%
//
// If the edit all page opens and the route template is in Active state, 
// revise the route template
  boolean routeTemplateRevisedFlag = false;
  if(UIUtil.isNotNullAndNotEmpty(isRouteTemplateRevised)){
	  routeTemplateRevisedFlag = Boolean.parseBoolean( isRouteTemplateRevised);
  }
  routetemplate.setId(routeTemplateId);
  String templateState = routetemplate.getInfo(context,DomainObject.SELECT_CURRENT);
  if(templateState.equals(DomainObject.STATE_ROUTE_TEMPLATE_ACTIVE))
  {
     String revisionId = routetemplate.revise(context);
     routetemplate.setId(revisionId);
     routeTemplateId = revisionId;
     routeTemplateRevisedFlag = true;
  }

%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<script>
function setUnloadMethod()
{
	var bodyElement = document.getElementById("taskdelete");  
    if (isIE && bodyElement){    
        bodyElement.onunload = function () { closeWindow(); };
    }else{
        bodyElement.setAttribute("onbeforeunload",  "return closeWindow()");
    }
}
function removeOnloadEvents()
{
	var bodyElement = document.getElementById("taskdelete");
	if (isIE && bodyElement){	
   		bodyElement.onunload = null;
	}else{
	  	bodyElement.setAttribute("onbeforeunload",  "");
	}
}
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


  function isDeltaRadio(num) {
  	var count = 0;
    for (var k=0; k < document.TaskSummary.length; k++ ){
      if ((document.TaskSummary.elements[k].name == "routeOrder")) {
        count++;
      }
    }
  	if (count == 1) {
  		document.TaskSummary.duedateOffset.value = "";
  	}
  	else {
  		document.TaskSummary.duedateOffset[num].value = "";
  	}
  }
  
  function trimStr (textBox) {
    while (textBox.charAt(textBox.length-1)==' ')
      textBox = textBox.substring(0,textBox.length-1);
    while (textBox.charAt(0)==' ')
      textBox = textBox.substring(1,textBox.length);
    return textBox;
  }
    function trim (str) {
    return str.replace(/\s/gi, "");
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
  // function to check for minimum of one task is connected to route object
  function submitForm() {
<%
    if ( routeTemplateId == null ) {
%>
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.TaskMessage</emxUtil:i18nScript>");
      return;
<%
    }
%>
    var count = 0;
    for (var k=0; k < document.TaskSummary.length; k++ ){
      if ((document.TaskSummary.elements[k].name == "routeOrder")) {
        count++;
      }
    }

//Solved for Bug id 303944
//Check if tasks in order 
//Start
    if (count == 1) {     //only one order field
      if (document.TaskSummary.routeOrder.options !=null && document.TaskSummary.routeOrder.options[document.TaskSummary.routeOrder.selectedIndex].value != 1 ) {
         alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterorderBig</emxUtil:i18nScript>" +" "+ document.TaskSummary.routeOrder.options[document.TaskSummary.routeOrder.selectedIndex].value + " <emxUtil:i18nScript localize="i18nId">emxComponents.RouteAction.EnterorderCont</emxUtil:i18nScript>");
         return;
      }
    } else {
      selArray = document.TaskSummary.elements["routeOrder"];
      storeArray = new Array(count);
      var missingValue;
      for (ct = 0; ct < count; ct++){
	  	if(selArray[ct].type == "select-one") {
          // get array of values
          storeArray[ct] = parseInt(selArray[ct].options[selArray[ct].selectedIndex].value);
	       } else {
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
		
		//Solved for the issue id 303944 start
		alert(tempValue);
		//end 
		
        // set focus to errorValue
        for (ct = 0; ct < count; ct++){
        // compare to last value before above loop broke
        	if(selArray[ct].type == "select-one") {
          if ( parseInt(selArray[ct].options[selArray[ct].selectedIndex].value) == errorValue){
            selArray[ct].focus();
            break;
           }
         }
        }
        return;
      }
    }
    
//End    
    
    for (var i=0; i<document.TaskSummary.length;i++) {

        if ( (document.TaskSummary.elements[i].type == "text") && document.TaskSummary.elements[i].name == "taskName") {
                if(trim(document.TaskSummary.elements[i].value) != "")
                {
                        var namebadCharName       = checkForNameBadCharsList(document.TaskSummary.elements[i]);
                        if (namebadCharName.length != 0)
                        {
                                alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
                                document.TaskSummary.elements[i].focus();
                                return;
                        }
                }
                //Added for the Task Title Feature on 21st june 2007
                else {
                        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.EnterTitleField</emxUtil:i18nScript>");
                        document.TaskSummary.elements[i].focus();
                        return;
                }//End of the Task Title Feature

                document.TaskSummary.elements[i].value = trimStr(document.TaskSummary.elements[i].value);
                if (!(isAlphanumeric(trim(document.TaskSummary.elements[i].value), true))){
                        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertValidName</emxUtil:i18nScript>");
                        document.TaskSummary.elements[i].focus();
                        return;
                }
        }

        if (document.TaskSummary.elements[i].name == "routeInstructions") {
                var namebadCharDescrption = checkForBadChars(document.TaskSummary.elements[i]);

                if(trim(document.TaskSummary.elements[i].value)== "" ) {
                        alert("<emxUtil:i18nScript localize='i18nId'>emxComponents.RouteAction.EnterInstruc</emxUtil:i18nScript>");
                        document.TaskSummary.elements[i].focus();
                        return;
                }
                else if(namebadCharDescrption.length != 0)  {
                        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharDescrption+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
                        document.TaskSummary.elements[i].focus();
                        return;
                }
        }

    }


	<%

   if(advanceDateOption.equals("true")){
%>
    if (count == 1) {
      if(document.TaskSummary.duedateOption0[0].checked && document.TaskSummary.duedateOption0[0].value =="delta"){
          var duedateOffsetJS = trim(document.TaskSummary.duedateOffset.value);
          var isInvalidRange = CheckValidity(duedateOffsetJS);

          if( duedateOffsetJS.length == 0 || duedateOffsetJS <1 || duedateOffsetJS > 365 || isInvalidRange){
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.common.EnterOffset </emxUtil:i18nScript>");
            document.TaskSummary.duedateOffset.value = "";
            document.TaskSummary.duedateOffset.focus();
            return;
          }
       }
    } else {
      for (var k=0; k < count; k++){
        if((eval("document.TaskSummary.duedateOption"+k+"[0].checked") && eval("document.TaskSummary.duedateOption"+k+"[0].value") =="delta")){
           var duedateOffsetJS = trim(document.TaskSummary.duedateOffset[k].value);
           var isInvalidRange = CheckValidity(duedateOffsetJS);
           if( duedateOffsetJS.length == 0 || duedateOffsetJS <1 || duedateOffsetJS > 365 || isInvalidRange){
             alert("<emxUtil:i18nScript localize="i18nId">emxComponents.common.EnterOffset</emxUtil:i18nScript>");
             document.TaskSummary.duedateOffset[k].value="";
             document.TaskSummary.duedateOffset[k].focus();
             return;
            }
         }
      }
    }


  <%
  }
  %>
   startProgressBar();
   removeOnloadEvents();
   document.TaskSummary.submit();
  }
  var submitAction = false;
  function closeWindow() {
	removeOnloadEvents();
   // parent.window.close();
    //return;
//Commented and Added for IR-043896V6R2011
  // submitAction = true;
   //submitWithCSRF("emxRouteTemplateCancelNewTaskProcess.jsp?newTaskIds=<%=XSSUtil.encodeForURL(context, newTaskIds)%>", window);
   var isRouteTemplateRevised = <%=routeTemplateRevisedFlag%>;
   if(isRouteTemplateRevised == true)
   {
	   emxUICore.getDataPost("emxRouteTemplateCancelNewTaskProcess.jsp", "newTaskIds=<%=XSSUtil.encodeForURL(context, newTaskIds)%>&routTemplateRevisionId=<%=XSSUtil.encodeForURL(context, routeTemplateId)%>");
   }else{
   emxUICore.getDataPost("emxRouteTemplateCancelNewTaskProcess.jsp", "newTaskIds=<%=XSSUtil.encodeForURL(context, newTaskIds)%>");
   }
   parent.window.close();
   return;
    //Addition ends for IR-043896V6R2011
  }
// function to be called on click of Add Task Link
  function addTask() {
  	removeOnloadEvents();
    document.TaskSummary.fromPage.value="addtask";
    document.TaskSummary.action="emxEditRouteTemplateAllTasksProcess.jsp";
    document.TaskSummary.submit();
    return;
  }

      // function to sort tasks.
    function sortTaskList() {
    	removeOnloadEvents();
        document.TaskSummary.fromPage.value="sorttask";
        document.TaskSummary.action="emxEditRouteTemplateAllTasksProcess.jsp";
        document.TaskSummary.submit();
        return;
    }
    function showDeleteSelected() {
    	removeOnloadEvents();
    var checkedFlag = "false";
    for (var i=0; i < document.TaskSummary.elements.length; i++) {
      if (document.TaskSummary.elements[i].type == "checkbox"
         && document.TaskSummary.elements[i].name != "chkList" && document.TaskSummary.elements[i].checked)  {
         checkedFlag = "true";
      }
    }
    if (checkedFlag == "false") {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignTaskDialog.SelectTask</emxUtil:i18nScript>");
      return;
    } else {
      if (confirm("<emxUtil:i18nScript localize="i18nId">emxComponents.TaskDelete.MsgConfirm</emxUtil:i18nScript>") != 0)  {
        document.TaskSummary.action="emxDeleteTask.jsp?srcPg=editAllTasks";
        document.TaskSummary.submit();
        return;
      }
    }
  }

//function to return the checked check box value.
  function checkedCheckBoxValues(){

        var checkedVal='';
        for (var i=0; i < document.TaskSummary.elements.length; i++) {
            if (document.TaskSummary.elements[i].type == "checkbox"
                && document.TaskSummary.elements[i].name != "chkList" && document.TaskSummary.elements[i].checked)  { //&& (document.TaskSummary.elements[i+3].name == "oldAssignee" || document.TaskSummary.elements[i+2].name == "oldAssignee")
//modfied fro 293776 issue 3 311950
                        checkedVal = checkedVal+"~"+document.TaskSummary.elements[i].value;
						//		+"~"+document.TaskSummary.elements[i+1].value;//+'~'+document.TaskSummary.elements[i+2].value+'~';
//till here
                }
        }

        return checkedVal;
  }
  
  // function to make all the check box enable
  function doCheck(){
    var objForm   = document.TaskSummary;
    var chkList   = objForm.chkList;
    for (var i=0; i < objForm.elements.length; i++){
      if (objForm.elements[i].name.indexOf('chkItem') > -1){
        objForm.elements[i].checked = chkList.checked;
      }
    }
  }

  // function to make all the check box disable
  function updateCheck() {
    var objForm = document.TaskSummary;
    var chkList = objForm.chkList;
    chkList.checked = false;
  }

//function to list Role And Person for Route
  function getReviewersList(objThis,count) {
	var assineeName=objThis.value;
      	var assigneeVal=assineeName.split("#");
     	document.getElementById("recepientList"+count).style.visibility = 'visible';
	document.getElementById("recepientList"+count).style="width:200px";
	var response = emxUICore.getDataPost("../components/emxEditRouteTemplateAllTasksDialog.jsp?mode=EnableResponsibleRole&assigneeName="+assigneeVal[1]+"&count="+count);
  	 		document.getElementById("recepientDivList"+count).innerHTML=response;
  		 
       }
 

</script>

<%

  try  {
%>
  <%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%
  } catch(Exception e){
    String error = ComponentsUtil.i18nStringNow("emxComponents.AssignTaskDialog.ErrorMessage",request.getHeader("Accept-Language"));
  }
%>


<script language="javascript">
  //function to open the RouteTaskAssignSelected dialog window.
  function AssignSelected(){
	  removeOnloadEvents();
    var checkedValue = checkedCheckBoxValues();
    if (checkedValue == '') {
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AssignSelected.SelectTask</emxUtil:i18nScript>");
      return;
    } else {
    var selectAssigneeURL = "<%=selectAssigneeURL%>routeNodeId=" + escape(checkedValue);
     emxShowModalDialog(selectAssigneeURL, 575, 575);
    }
  }
</script>

<body id="taskdelete" name="taskdelete" onload="setUnloadMethod()" class="editable">
<form name = "TaskSummary" method="post" onSubmit="javascript:submitForm(); return false" action="emxEditRouteTemplateAllTasksProcess.jsp">

<input type="hidden" name="templateId"   value="<xss:encodeForHTMLAttribute><%=routeTemplateId%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="objectId"   value="<xss:encodeForHTMLAttribute><%=routeTemplateId%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="fromPage"   value="task"/>
<input type="hidden" name="newTaskIds" value="<xss:encodeForHTMLAttribute><%=newTaskIds%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="isRouteTemplateRevised" value="<xss:encodeForHTMLAttribute><%=routeTemplateRevisedFlag%></xss:encodeForHTMLAttribute>"/>

<%

  String proxyGoupType = PropertyUtil.getSchemaProperty(context,"type_GroupProxy");
  Pattern typePattern = new Pattern(sTypePerson);
  typePattern.addPattern(typeRouteTaskUser);
  typePattern.addPattern(proxyGoupType);
  Pattern relPattern  = new Pattern(sRelRouteNode);
  StringList objectSelect = new StringList();
  objectSelect.add(RouteTemplate.SELECT_NAME);
  objectSelect.add(RouteTemplate.SELECT_ID);
  objectSelect.add(RouteTemplate.SELECT_TYPE);
  objectSelect.add(strKindOfProxyGroup);

  StringList relationshipSelects = new StringList();
  relationshipSelects.add(RouteTemplate.SELECT_ROUTE_ACTION);
  relationshipSelects.add(RouteTemplate.SELECT_ROUTE_INSTRUCTIONS);
  relationshipSelects.add(RouteTemplate.SELECT_TITLE);
  relationshipSelects.add(RouteTemplate.SELECT_ROUTE_SEQUENCE);
  relationshipSelects.add(RouteTemplate.SELECT_RELATIONSHIP_ID);
  relationshipSelects.add(RouteTemplate.SELECT_ALLOW_DELEGATION);
  relationshipSelects.add(RouteTemplate.SELECT_ROUTE_TASK_USER);
  relationshipSelects.add("attribute["+RouteTemplate.ATTRIBUTE_DUEDATE_OFFSET+"]");
  relationshipSelects.add("attribute["+RouteTemplate.ATTRIBUTE_DATE_OFFSET_FROM+"]");
  relationshipSelects.add("attribute["+RouteTemplate.ATTRIBUTE_ASSIGNEE_SET_DUEDATE+"]");
  relationshipSelects.add("attribute["+RouteTemplate.ATTRIBUTE_ALLOW_DELEGATION+"]");
  relationshipSelects.add("attribute["+RouteTemplate.ATTRIBUTE_REVIEW_TASK+"]");


  MapList resultList = routetemplate.getRelatedObjects(context, relPattern.getPattern(), typePattern.getPattern(),objectSelect, relationshipSelects, false, true, (short)1, null, null);



  StringList memberList = new StringList();
  java.util.List<Hashtable> resMemberList = new java.util.ArrayList<Hashtable>();
  Hashtable tempTable = null;

  Hashtable tempMap = new Hashtable();
int count=0;
  String personId = "";
  String personName = "";
  String asigneeType = "";
  String toType="";
	String isKindOfProxy = "";
  for(int i =0; i < resultList.size(); i++)
  {
        tempMap    = (Hashtable) resultList.get(i);
        personName = (String) tempMap.get(Route.SELECT_ROUTE_TASK_USER);
        personId   = (String) tempMap.get(Route.SELECT_ID);
        toType=(String) tempMap.get(Route.SELECT_TYPE);
        isKindOfProxy = (String) tempMap.get(strKindOfProxyGroup);
        if(personName == null || "".equals(personName)){
            if( !DomainObject.TYPE_ROUTE_TASK_USER.equals(toType) && !"true".equalsIgnoreCase(isKindOfProxy) ) {
                    personName =  (String) tempMap.get(Route.SELECT_NAME);
                    asigneeType ="person";
            }else if("true".equalsIgnoreCase(isKindOfProxy)) {
            	 personName =  (String) tempMap.get(Route.SELECT_NAME);
                 asigneeType ="UserGroup";
            }
            else {
                continue;
            }
        }
        else if (UIUtil.isNotNullAndNotEmpty(personName)&&DomainObject.TYPE_PERSON.equals(toType)){
        	personName =  (String) tempMap.get(Route.SELECT_NAME);
            asigneeType ="person";
        }else if (UIUtil.isNotNullAndNotEmpty(personName)&& "true".equals(isKindOfProxy)){
       	 	personName =  (String) tempMap.get(Route.SELECT_NAME);
         	asigneeType ="UserGroup";
        }else {
        	if(personName.indexOf("_") > -1) {
                asigneeType = personName.substring(0,personName.indexOf("_"));
				personName=PropertyUtil.getSchemaProperty(context,personName);
        	}
                if(asigneeType.equalsIgnoreCase("role")) {
                        asigneeType = "Role";
                }else {
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

  resultList.sort(RouteTemplate.SELECT_ROUTE_SEQUENCE,"ascending","integer");

%>
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
		    	<emxUtil:i18n localize="i18nId">emxComponents.AssignTasksDialog.DueDateTimeEDT</emxUtil:i18n>
		    </th>
                  </tr>

<framework:mapListItr mapList="<%=resultList%>" mapName="routeMap">
<%
  String routeNodeId = (String)routeMap.get(RouteTemplate.SELECT_RELATIONSHIP_ID);

%>
    <tr class='<framework:swap id="1" first="odd" second="even" />'>
          <input type="hidden" name="relIds" value="<xss:encodeForHTMLAttribute><%=routeMap.get(RouteTemplate.SELECT_RELATIONSHIP_ID)%></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="oldAssignee" value="<xss:encodeForHTMLAttribute><%=RouteTemplate.SELECT_ID%></xss:encodeForHTMLAttribute>" />
        <td style="text-align: center;vertical-align:top;">
			<table>
				<tr>
					<td>
						<input type = "checkbox" name = "chkItem1" id = "chkItem1" value = "<xss:encodeForHTMLAttribute><%=routeMap.get(RouteTemplate.SELECT_RELATIONSHIP_ID)%></xss:encodeForHTMLAttribute>" onClick="updateCheck()"/>
					</td>
				</tr>
			</table>
		</td>
        <td style="vertical-align:top">
<!--Addedd for bug 293776 issue 3 -->
          <input type="hidden" name="oldPersonId" value="<xss:encodeForHTMLAttribute><%=personId%></xss:encodeForHTMLAttribute>"/>
<!--till here-->
                <input type="hidden" name="routeNode" value="<xss:encodeForHTMLAttribute><%=routeMap.get(RouteTemplate.SELECT_RELATIONSHIP_ID)%></xss:encodeForHTMLAttribute>"/>
          	<table>
				<tbody>
                	<tr><!-- Title Field -->
                  		<td>
							<table>
                  <tr>
                     <td>
                        <input type="text" name="taskName" value="<xss:encodeForHTMLAttribute><%=routeMap.get(RouteTemplate.SELECT_TITLE)%></xss:encodeForHTMLAttribute>"/>
                     </td>
                  </tr>
					 		</table>
                        </td>
                </tr>
                  	<tr><!-- Action -->
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

                                String routeActionValueStr = (String) routeMap.get(Route.SELECT_ROUTE_ACTION);

// Bug 345680: Show options Approve,Comment,Notify Only only
								AttributeType attrRouteAction = new AttributeType(DomainConstants.ATTRIBUTE_ROUTE_ACTION);
								  attrRouteAction.open(context);
								    
								  // Remove the Info Only and Investigate ranges which we no longer support- Bug 347955
								  StringList routeActionList = attrRouteAction.getChoices(context);
								  routeActionList.remove ("Information Only");
								  routeActionList.remove ("Investigate");
					     		  //Modified for bug 359347
								  Collections.sort ((java.util.List)routeActionList); // To maintain order Approve, Comment, Notify Only
								  attrRouteAction.close(context);
												if("Approval".equals(routeBasePurpose)) {
                                        routeActionList = new StringList(1);
                                        routeActionList.add("Approve");
                                }
			                                	else if("Review".equals(routeBasePurpose)) {
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
                        <select name="routeOrder">
<%
                                String routeSequenceValueStr = (String) routeMap.get(RouteTemplate.SELECT_ROUTE_SEQUENCE);
                                for (int loop = 1; loop <= 20; loop++) {
                                        Integer integerType = new Integer(loop);
                                        String loopString = integerType.toString();
						                                        	String selStr = routeSequenceValueStr.equals(loopString) ? "selected" : "";
%>
																	<option value="<%=loop%>" <%=selStr%>><%=loop%></option>	
<%
                                        }
%>
                        </select>
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
              <td>
              <%
              ++count;
              %>
                <select  id="personId" name="personId" size="1"  onchange="getReviewersList(this,<%=count%>)">
<%

                  String id = "";
                  String name = "";
                  String assigType = "";
                  String memberName = "";
                  String memberNameIntl = "";
                  Hashtable ht = new Hashtable();
                  String routeTaskUser = (String) routeMap.get(Route.SELECT_ROUTE_TASK_USER);
                  String routeNodeToType=(String) routeMap.get(Route.SELECT_TYPE);

                  if(UIUtil.isNullOrEmpty(routeTaskUser)){
                      if(routeNodeToType.equals(Route.TYPE_ROUTE_TASK_USER)) {
                            memberName = STRING_NONE;
                      }
                      else {
                            memberName = (String) routeMap.get(RouteTemplate.SELECT_NAME);
                      }
                  } 
                  else if(routeNodeToType.equals(Route.TYPE_ROUTE_TASK_USER)||UIUtil.isNotNullAndNotEmpty(routeTaskUser)) {
						memberName=PropertyUtil.getSchemaProperty(context,routeTaskUser);
                  }
                  else
                	  memberName = (String) routeMap.get(RouteTemplate.SELECT_NAME);
                	  
				                  		for(int j = 0; j < resMemberList.size(); j++) {
                        ht = (Hashtable) resMemberList.get(j);
                        id = (String) ht.get("id");
                        name = (String) ht.get("name");
                        assigType = (String) ht.get("asigneetype");
                        
                        if (("person".equals(assigType) || "UserGroup".equals(assigType) )&&UIUtil.isNullOrEmpty(routeTaskUser)) {
                                memberNameIntl =  name;
                        }else {
                        	if(UIUtil.isNotNullAndNotEmpty(routeTaskUser))
                        		name=memberName;
                                memberNameIntl = i18nNow.getAdminI18NString(assigType,name,languageStr);
                        }

                        if(memberName.equals(ht.get("name"))) {
%>
                                <option value="<%=XSSUtil.encodeForHTMLAttribute(context, id) + "#" + XSSUtil.encodeForHTMLAttribute(context, name) %>" Selected > <%=XSSUtil.encodeForHTMLAttribute(context, PersonUtil.getFullName(context, memberNameIntl))%> </option>
<%
                        } 
                        else {
%>
                                <option value="<%=XSSUtil.encodeForHTMLAttribute(context, id) + "#" + XSSUtil.encodeForHTMLAttribute(context, name) %>"> <%=XSSUtil.encodeForHTMLAttribute(context, PersonUtil.getFullName(context,memberNameIntl))%> </option>
<%
                        }
                }
                				  		if( STRING_NONE.equals(memberName) ) {
%>
                	<option value="<%=XSSUtil.encodeForHTMLAttribute(context, id)%>#none" selected><%=XSSUtil.encodeForHTMLAttribute(context, STRING_NONE)%></option>
<%
                }
                else {
%>
					<option value="none#none"><%=XSSUtil.encodeForHTMLAttribute(context, STRING_NONE)%></option>
<%                    
                }
%>
                </select>

                 <%
                       sAllowDelegation=(String)routeMap.get("attribute["+RouteTemplate.ATTRIBUTE_ALLOW_DELEGATION+"]");
                        if(sAllowDelegation==null)
                                sAllowDelegation="";
                        if(sAllowDelegation.equals("TRUE")){
                %>
                        &nbsp; <img src="../common/images/iconSmallAssignee.gif" name="imgAssignee" id="imgAssignee" />
                <%
                        }
                %>
                <%
                       sReviewTask=(String)routeMap.get("attribute["+RouteTemplate.ATTRIBUTE_REVIEW_TASK+"]");
                        if(sReviewTask==null)
                                sReviewTask="";
                        if(sReviewTask.equals("Yes")){
                %>
                        &nbsp;<img src="../common/images/iconSmallOwnerReview.gif" name="imgOwnerReview" id="imgOwnerReview" />
                <%
                        }
                %>
              </td>
             </tr>
             <%
         	        if(isResponsibleRoleEnabled){
             %>
              <tr>
               <td width="2%" style="text-align: left;" >
     		   <div  id = "recepientDivList<%=count %>"  style="text-align: left;">
         		<%
         		 matrix.util.StringList slSelect=new StringList();
         		String strUserOrg = PersonUtil.getActiveOrganization(context);
         		boolean isRoleSelected=false;
                        try{                        	 
            	              slSelect=PersonUtil.getPersonFromRole(context, memberName);
            	              isRoleSelected=true;
						}catch(Exception e){
							slSelect.removeAllElements();
								}
            		 String strRecipient =(String)routeMap.get("name");
  					   if(!slSelect.isEmpty()||isRoleSelected){
        		    %>
           		  <select id = "recepientList<%=count %>" name = "recepientList"  style="width:200px">
        						  <option value="Any"><%=strAny %></option>
               	    <% 
  				    for(Object strAssign:slSelect){
        						String strAssigneeName=(String)strAssign;
        						String strOrg=PersonUtil.getDefaultOrganization(context, strAssigneeName);
        						if(strUserOrg.equals(strOrg)){
        						String selected = "";
									 if(UIUtil.isNotNullAndNotEmpty(strRecipient)&&strRecipient.equals(strAssigneeName))
									selected="selected";
        						String  strAssingeeDisplay=PersonUtil.getFullName(context, strAssigneeName);
  				    %>
							  <option value="<%=strAssign %>" <%=selected %>><%=strAssingeeDisplay %></option>
 		          <%
       						 }
     					   }		
        		  %>
          </select>
                 <%
                  }else{
        	    %>
                    	<input type="text" id = "recepientList<%=count %>" name = "recepientList" readonly=true disabled style="width:200px"></input>
                     	<input type="hidden"  id = "recepientList<%=count %>" name = "recepientList" style="width:200px" value="">  </input>
		  <%
		       }
		   %>
             </div>
       
       </td>
        </tr>
         <%
         }
         %>
             <tr>
            			</table>
            		</td>
            	</tr>
            	<tr> <!-- Instructions -->
            		<td style="padding-top:3px;">
            			<table>
             <tr>
			        			<td>
			        				<textarea style="min-height:50px;width:250px;" rows="6" name="routeInstructions"><%=routeMap.get(Route.SELECT_ROUTE_INSTRUCTIONS)%></textarea>
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
            <%
                        String rangeValue       = "";
                        String i18nRouteAction  = "";
                        String i18nOffsetFrom   = "";
                        String sAssigneeDueDate="";
                        String dueDateOffsetValue = (String) routeMap.get("attribute["+RouteTemplate.ATTRIBUTE_DUEDATE_OFFSET+"]");

                        sAssigneeDueDate=(String)routeMap.get("attribute["+RouteTemplate.ATTRIBUTE_ASSIGNEE_SET_DUEDATE+"]");
                        routeDueDateOffsetFromStr=(String)routeMap.get("attribute["+RouteTemplate.ATTRIBUTE_DATE_OFFSET_FROM+"]");
            %>
<!--modified for 293776 issue 2 (if attribute Due Date Offset is not null then only ckeck the radio button -->

										<!-- <input type = "radio" onclick="" id = "duedateOption<%=xx%>" name = "duedateOption<%=xx%>" value ="delta" <%= ( sAssigneeDueDate.equals("No")?"checked":"" )%> /> -->
                <input type = "radio" onclick="" id = "duedateOption<%=xx%>" name = "duedateOption<%=xx%>" value ="delta" <%= ("".equals(dueDateOffsetValue) ? "" : "checked")%> />
<!--till here-->
                <input type="text" onFocus="" style="font-size:8pt; font-face=verdana, arial" name="duedateOffset" size="2" value="<%=routeMap.get("attribute["+RouteTemplate.ATTRIBUTE_DUEDATE_OFFSET+"]")%>" />
                 <emxUtil:i18n localize = "i18nId">emxComponents.common.DaysFrom</emxUtil:i18n>&nbsp;
                 <select name="duedateOffsetFrom" style="font-size:8pt; font-face=verdana, arial" onFocus="">
                <%
                     StringItr  offsetItr    = new StringItr (FrameworkUtil.getRanges(context, DomainObject.ATTRIBUTE_DATE_OFFSET_FROM));
                     while(offsetItr.next()) {
                        rangeValue        = offsetItr.obj();
                        i18nOffsetFrom    = i18nNow.getRangeI18NString(DomainObject.ATTRIBUTE_DATE_OFFSET_FROM, rangeValue, sLanguage);
                        if((sAssigneeDueDate !=null)&&(sAssigneeDueDate.equals("No")) ){
                                sSelected         = (routeDueDateOffsetFromStr != null && routeDueDateOffsetFromStr.equals(rangeValue) )?"selected":"";
                        }else{
                                sSelected="";
                        }
                  %>
                        <option value="<%=XSSUtil.encodeForHTMLAttribute(context, rangeValue)%>" <%=XSSUtil.encodeForHTMLAttribute(context, sSelected)%>> <%=XSSUtil.encodeForHTMLAttribute(context, i18nOffsetFrom)%> </option>
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
                <input type = "radio" onclick="isDeltaRadio('<%=xx%>')" id = "duedateOption<%=xx%>" name = "duedateOption<%=xx%>" value ="assignee" <%= ((sAssigneeDueDate.equals("Yes") || UIUtil.isNullOrEmpty(dueDateOffsetValue)) ? "checked" : "")%> />
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
                        <input type="checkbox" name="allowDelegation<%=XSSUtil.encodeForHTML(context, routeNodeId)%>" id="allowDelegation<%=xx%>" value="TRUE" <%= ( sAllowDelegation.equals("TRUE")?"checked":"" )%> />
                        <emxUtil:i18n localize = "i18nId">emxComponents.EditAllTasks.AllowDelegation</emxUtil:i18n>
                        <input type="checkbox" name="reviewTask<%=XSSUtil.encodeForHTML(context, routeNodeId)%>" id="reviewTask<%=xx++%>" value="Yes" <%= ( sReviewTask.equals("Yes")?"checked":"" )%> />
                        <emxUtil:i18n localize = "i18nId">emxComponents.Button.NeedReview</emxUtil:i18n>
                </td>
             </tr>
             </table>
          </td>
        </tr>
    			</tbody>
    		</table>
		</td>
	</tr>
  </framework:mapListItr>
  </tbody>
  </table>
</form>
</body>
<%
}
%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

