<%--  emxRouteCreateSimpleDialog.jsp - Create Dialog for Simple Route creation

   Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information
   of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

static const char RCSID[] = $Id: emxRouteCreateSimpleDialog.jsp.rca 1.4.2.6 Tue Oct 28 19:01:03 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
 <%@ include file = "../emxPaginationInclude.inc" %>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<script>addStyleSheet("emxUITemp","../");</script>
<link rel="stylesheet" href="emxSimpleRoute.css" type="text/css"/>
<%@include file = "emxComponentsJavaScript.js"%>
<script language="javascript" src="../common/scripts/emxJSValidationUtil.js"></script>
<script language="JavaScript" src="emxRouteSimpleFunctions.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<%
MapList tmpList = new MapList();
String suiteKey     = emxGetParameter(request,"suiteKey");
String portalMode   = emxGetParameter(request,"portalMode");

boolean bTeam = FrameworkUtil.isSuiteRegistered(context,"featureVersionTeamCentral",false,null,null);
boolean bProgram = FrameworkUtil.isSuiteRegistered(context,"appVersionProgramCentral",false,null,null);

/* Variable Declaration*/
String sDefaultType = EnoviaResourceBundle.getProperty(context,"emxComponents.Routes.DefaultContentType");

String routeInstructions =emxGetParameter(request,"routeInstructions");
if(UIUtil.isNotNullAndNotEmpty(routeInstructions)){
	 routeInstructions= FrameworkUtil.findAndReplace(routeInstructions, "E:N:T:E:R", "\n");
}
String routeInitiateManner=emxGetParameter(request,"routeInitiateManner");
String allowDelegation=emxGetParameter(request,"allowDelegation");
String routeAction=emxGetParameter(request,"routeAction");
String routeDueDate=emxGetParameter(request,"routeDueDate");
String routeId = "";
String tempContentIds = "";
boolean isCompletedTask       = false;
String strLanguage = request.getHeader("Accept-Language");
//Error message if task is completed.
String errorMessage        = EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource", new Locale(strLanguage),"emxComponents.CreateRoute.OnCompleteTaskError");
String routeMemberFilter="";
String personName="";
Hashtable peopleFinalList=new Hashtable();
String routeMemberString=emxGetParameter(request,"routeMemberString");

 //For Content
      String sName  = "";
      String buyerCompany = "";
      String sRev= "";
      String sVer= "";
      String sRotableIds  = "";
      String sPolicy= "";
      String sStates= "";
      String sType=null;
      String sNoneValue= "None";// i18nNow.getI18nString("emxComponentsStringResource", "emxComponents.AttachmentsDialog.none", sLanguage);
      HashMap hashStateMap =  new HashMap();
     String relRTSQuotation = PropertyUtil.getSchemaProperty(context, "relationship_RTSQuotation");
     String relCompRFQ= PropertyUtil.getSchemaProperty(context, "relationship_CompanyRFQ");
     String relRFQHolder = PropertyUtil.getSchemaProperty(context, "relationship_RFQHolder");

     String objectId="'";
     String sParams = "jsTreeID=jsTreeID&suiteKey=suiteKey";
     String parentId="";
     String scopeId="";
     String routeDueDateMSValue = emxGetParameter(request,"routeDueDateMSValue");
     DomainObject  parentObject=new DomainObject();

     //start of code added for the bug 313531
	 ArrayList contentSelectArray = new ArrayList();
	 if(formBean.getElementValue("contentSelectArray") != null && !formBean.getElementValue("contentSelectArray").equals("")) {
       contentSelectArray = (ArrayList) formBean.getElementValue("contentSelectArray");
	 }
	 //end of code added for the bug 313531

String keyValue=emxGetParameter(request,"keyValue");
	if(keyValue == null){
	   keyValue = formBean.newFormKey(session);
 	 }

formBean.processForm(session,request,"keyValue");
objectId=(String)formBean.getElementValue("objectId");
if((objectId==null)  || (objectId.equals("null"))) {
        objectId="";
}
parentId=objectId;
parentObject.setId(parentId);
if(UIUtil.isNotNullAndNotEmpty(parentId)){
	 StringList selects = new StringList(2);
     selects.add(DomainObject.SELECT_TYPE);
     selects.add(DomainObject.SELECT_CURRENT);
     Map infoMap = parentObject.getInfo(context,selects);
     String typeName = (String)infoMap.get(DomainObject.SELECT_TYPE);
     String currentState = (String)infoMap.get(DomainObject.SELECT_CURRENT);
     if(DomainObject.TYPE_INBOX_TASK.equalsIgnoreCase(typeName) && DomainObject.STATE_INBOX_TASK_COMPLETE.equalsIgnoreCase(currentState)){
     	isCompletedTask = true;
     }
     	
     if(isCompletedTask){
     	%>
     	 <script language="javascript">
     	alert("<%=errorMessage%>");
     	closeWindow();
     	 </script>
     	<%
     	return;
     }
}

scopeId=emxGetParameter(request,"scopeId");
Hashtable memberLinks=makeRouteMemberLinks(context,session,formBean,scopeId);

/* If the page is being refreshed due to adding content  or Removing Content , The below Hashtable help us to retain the entered Data*/
Hashtable hashRouteWizFirst=(Hashtable)formBean.getElementValue("hashRouteWizFirst");
//For the first Time Set the values to empty
if(hashRouteWizFirst==null || hashRouteWizFirst.size()==0) {
        hashRouteWizFirst=new Hashtable();
        hashRouteWizFirst.put("routeInitiateManner","");
          hashRouteWizFirst.put("routeAction","");
          hashRouteWizFirst.put("routeDueDate","");
          hashRouteWizFirst.put("routeInstructions","");
          hashRouteWizFirst.put("documentID","");
          hashRouteWizFirst.put("routeMemberFilter","");
          formBean.setElementValue("hashRouteWizFirst",hashRouteWizFirst);
 }
String routeInitiateManner1 = (String)(((Hashtable)formBean.getElementValue("hashRouteWizFirst")).get("routeInitiateManner"));
String routeAction1 = (String)(((Hashtable)formBean.getElementValue("hashRouteWizFirst")).get("routeAction"));
String allowDelegation1 = (String)(((Hashtable)formBean.getElementValue("hashRouteWizFirst")).get("allowDelegation"));
String routeDueDate1 = (String)(((Hashtable)formBean.getElementValue("hashRouteWizFirst")).get("routeDueDate"));
String routeInstructions1 = (String)(((Hashtable)formBean.getElementValue("hashRouteWizFirst")).get("routeInstructions"));
String routeMemberString1 = (String)(((Hashtable)formBean.getElementValue("hashRouteWizFirst")).get("routeMemberString"));

routeInitiateManner = (UIUtil.isNullOrEmpty(routeInitiateManner)&&(UIUtil.isNotNullAndNotEmpty(routeInitiateManner1)))? 
		routeInitiateManner1:routeInitiateManner;
		
routeAction = (UIUtil.isNullOrEmpty(routeAction)&&(UIUtil.isNotNullAndNotEmpty(routeAction1)))? 
		routeAction1:routeAction;
		
routeDueDate = (UIUtil.isNullOrEmpty(routeDueDate)&&(UIUtil.isNotNullAndNotEmpty(routeDueDate1)))? 
		routeDueDate1:routeDueDate;

routeInstructions = (UIUtil.isNullOrEmpty(routeInstructions)&&(UIUtil.isNotNullAndNotEmpty(routeInstructions1)))? 
		routeInstructions1:routeInstructions;

routeInitiateManner = (UIUtil.isNullOrEmpty(routeInitiateManner)&&(UIUtil.isNotNullAndNotEmpty(routeInitiateManner1)))? 
		routeInitiateManner1:routeInitiateManner;

allowDelegation = (UIUtil.isNullOrEmpty(allowDelegation)&&(UIUtil.isNotNullAndNotEmpty(allowDelegation1)))? 
		allowDelegation1:allowDelegation;

routeMemberString = (UIUtil.isNullOrEmpty(routeMemberString)&&(UIUtil.isNotNullAndNotEmpty(routeMemberString1)))? 
		routeMemberString1:routeMemberString;

if(formBean.getElementValue("hashStateMap") != null && !(formBean.getElementValue("hashStateMap").equals("null")) && !(formBean.getElementValue("hashStateMap").equals(""))) {
       hashStateMap = (HashMap) formBean.getElementValue("hashStateMap");
}
    String sContentId =  (String) formBean.getElementValue("contentID");
    String searchDocId  =  (String) formBean.getElementValue("searchDocId");
if(sContentId == null) {
       sContentId = searchDocId;
}
sContentId = (String) hashRouteWizFirst.get("documentID") + sContentId;
     session.putValue("RouteContent",sContentId);
     routeDueDateMSValue=(String)formBean.getElementValue("routeDueDateMSValue");
if(routeDueDateMSValue==null || routeDueDateMSValue.equals("null") || routeDueDateMSValue.equals("")) {
         routeDueDateMSValue="0";
     }
     formBean.setFormValues(session);

//There will be only 3 types of route tasks. Approve, Comment, Notify Only.
AttributeType attrRouteAction = new AttributeType(DomainConstants.ATTRIBUTE_ROUTE_ACTION);
attrRouteAction.open(context);
// Remove the Info Only and Investigate ranges which we no longer support-Bug 347955
StringList routeActionList = attrRouteAction.getChoices(context);
routeActionList.remove ("Information Only");
routeActionList.remove ("Investigate");
Collections.sort ((java.util.List)routeActionList); // To maintain order Approve, Comment, Notify Only

// Get attribute default value
String strDefaultAction = attrRouteAction.getDefaultValue(context);
if (strDefaultAction == null || "".equals(strDefaultAction.trim())) {
	strDefaultAction = null;
}
attrRouteAction.close(context);
String searchTypes = "";
String relType=DomainObject.RELATIONSHIP_OBJECT_ROUTE;
String sDocType = PropertyUtil.getSchemaProperty(context, "type_Document");
String fldName=emxGetParameter(request, "fieldNameDisplay");

String mqlCmd = "print relationship \"" + relType + "\" select fromtype dump";

// Use the list returned from mql to populate
// the type chooser
//
try
{
  searchTypes = MqlUtil.mqlCommand(context, mqlCmd);
  String strMemberListType = PropertyUtil.getSchemaProperty(context, DomainSymbolicConstants.SYMBOLIC_type_MemberList);
  if(searchTypes.contains(strMemberListType) ){
	   searchTypes=searchTypes.replace(strMemberListType,"");
  }
}
catch (FrameworkException fe)
{
  searchTypes = " ";
}

if((!sContentId.equals("null")) && (!sContentId.equals(""))) {
	StringTokenizer strTokDocsIds = new StringTokenizer(sContentId, "~");
	while(strTokDocsIds.hasMoreTokens()) {
		tempContentIds += strTokDocsIds.nextToken() + ",";
	}
	tempContentIds = tempContentIds.substring(0,tempContentIds.length()-1);
}
%>

<script language="JavaScript">
function getStatesWithIds() {
	var docIds = "<%=tempContentIds%>";
	var docIdsStates = "";
	if(docIds != null && docIds != "null" && docIds != "") {
		var docIdsList = docIds.split(",");
		for(i = 0; i < docIdsList.length; i++) {
			docIdsStates += document.getElementById(docIdsList[i]).value + ";";
		}
		docIdsStates = docIdsStates.replace(/#/g, ":");
	}
	return docIdsStates;
}

/*Function to Add The content */
function AddContent() {
	var routeInstructions= document.getElementById("routeInstructions").value;;
	var routeInitiateManner= document.getElementsByName("routeInitiateManner");
	var allowDelegation= document.getElementsByName("allowDelegation");
	var routeAction= document.getElementsByName("routeAction");
	var peopleFinalList=new Array();
	var peopleNameFinalList=new Array();
	var routeDueDate=document.getElementsByName("routeDueDate");
    var routeMemberFilter="";
    var routeMemberString="";
	var routeDueDateMSValue="";
	var totalPeople=document.createSimpleDialog.memberFinalList.length;
	for(var i=0;i<totalPeople;i++)
		{
			peopleFinalList[i]=document.createSimpleDialog.memberFinalList.options[i].value;
			peopleNameFinalList[i]=document.createSimpleDialog.memberFinalList.options[i].text;
			routeMemberString=peopleFinalList[i]+"~"+peopleNameFinalList[i]+"|"+routeMemberFilter;
		}
		thisForm=document.createSimpleDialog;

		routeInstructions=jsTrim(thisForm.routeInstructions.value+"");
		routeInstructions=encodeURIComponent(routeInstructions);
		routeInstructions= routeInstructions.replace(/%0A/g,"E:N:T:E:R");

	if(thisForm.routeInitiateManner.checked) {
			routeInitiateManner="checked";
		}else{
		routeInitiateManner="";
	}
	if(thisForm.allowDelegation.checked) {
		allowDelegation="checked";
	}else{
		allowDelegation="";
	}

		routeAction=thisForm.routeAction.value;

        routeDueDate=thisForm.routeDueDate.value;
		o = thisForm.memberFinalList.options;
        routeMemberFilter="";
        routeDueDateMSValue=thisForm.routeDueDate_msvalue.value;
        
    	var docIdsStates = getStatesWithIds();

        //calling the joinFinalMemberList to make a string in the format memberName1|MemberValue1;memberName2|MemberValue2;....
       
        routeMemberString=joinFinalMemberList(); 
		var url ="../common/emxFullSearch.jsp?formInclusionList=ORIGINATOR&mode=addContentCreateRoute&table=AppFolderSearchResult&showInitialResults=true&invokePurpose=QuickRouteContent&submitURL=../components/emxContentSearchProcess.jsp?statesWithIds="+docIdsStates+"&form=AddContentSearchForm&selection=multiple&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&contentID=<%=XSSUtil.encodeForURL(context,sContentId)%>&objectId=<%=XSSUtil.encodeForURL(context, objectId)%>&routeInstructions="+routeInstructions+"&routeInitiateManner="+routeInitiateManner+"&routeDueDate="+routeDueDate+"&routeAction="+routeAction+"&routeMemberFilter="+routeMemberFilter+"&routeMemberString="+routeMemberString+"&routeDueDateMSValue="+routeDueDateMSValue+"&allowDelegation="+allowDelegation;
		url= url+"&field=TYPES="+"<%=searchTypes%>";
		emxShowModalDialog(url,750,500);
		
	}

function selectComboElement(box,selectedValue) {
	for(i=0;i<box.length;i++) {
    	if(box[i].value==selectedValue) {
                    box[i].selected=true;
                }
        }
    }

    //Function that gets loaded when the page is loaded
function initDialog() {
        //retaining the user selected "RouteAction" (If any)
        selectComboElement(document.createSimpleDialog.routeAction,"<%=routeAction%>");
        //retaing the memberList
        makeFinalMemberList("<%=routeMemberString%>");
    }
function submitForm() {
       //If the form is completely filled then Go Ahead
      proceedFurther=finalChecks();

	if(proceedFurther && jsDblClick()) {
        startProgressBar();
      	document.createSimpleDialog.submit();
      }
      return;
  }

  function closeWindow() {
       window.location.href = "emxRouteSimpleCancelProcess.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>";
    }

    //when the "Properties" button is clicked with only one memberSelection , then display the person properites , other wise (in case or role/group/multiple person...give an
function loadPersonPropertiesPage() {
        entries=getSelectedEntries(document.createSimpleDialog.memberFinalList);
    if(entries==null || entries.length==0) {
                alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CreateSimpleRoute.PersonDetails</emxUtil:i18nScript>");
        }
    else if(entries.length>1) {
                alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CreateSimpleRoute.PersonDetails</emxUtil:i18nScript>");
        }
    else {
            var isPersonBool=isPerson(entries[0]);
        if(isPersonBool) {
                url="emxComponentsPeopleDetailsFS.jsp?suiteKey=Components&objectId="+entries[0];
                emxShowModalDialog(url,775, 500);
            }
        else {
                alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CreateSimpleRoute.PersonDetails</emxUtil:i18nScript>");
            }
        }
  }
  //assigning the value to "Start" or "Empty"
  function startRouteUpdate(){
		thisForm=document.createSimpleDialog;
  	if(thisForm.routeInitiateManner.checked) {
  			thisForm.routeInitiateManner.value="start";
  		}
  	else {
  			thisForm.routeInitiateManner.value="";
  		}
  }

  //Added new method allowDelegation for bug 351803

  //assigning the value of allow delegation to "TRUE" or "FALSE"
  function allowDelegation(){
		thisForm=document.createSimpleDialog;
  	if(thisForm.allowDelegation.checked) {
  			thisForm.allowDelegation.value="TRUE";
  		}
  	else {
  			thisForm.allowDelegation.value="FALSE";
  		}
  }
  //end of method allowDelegation for bug 351803

function routeMemberListUpdate() {
		thisForm=document.createSimpleDialog;
		thisForm.routeMemberString.value=joinFinalMemberList();

  }
  /**
       The following are the final Checks to be made
        1.Check whether "Route Action", "Route Instructions", "Route Due Date" and "Members " are entered
        2.Check whether Route Due Date is valid

  */
function finalChecks() {
		routeMemberListUpdate();
		startRouteUpdate();

		allowDelegation();
		thisForm=document.createSimpleDialog;

		lRouteInstrs=jsTrim(thisForm.routeInstructions.value+"");
		lRouteDueDate=jsTrim(thisForm.routeDueDate.value+"");
		lRouteMemberString=jsTrim(thisForm.routeMemberString.value+"");

	if(lRouteInstrs.length == 0 || lRouteDueDate.length == 0 || lRouteMemberString.length <=2) {
				alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CreateSimpleRoute.MissingDetails</emxUtil:i18nScript>");
                thisForm.routeInstructions.focus();
				return false;
		}
        validDates=validateRouteDueDate(thisForm.routeDueDate_msvalue.value);
    if(validDates) {
            return true;
        }
    else {
           alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CreateSimpleRoute.PastDate</emxUtil:i18nScript>");
           return false;
       }
  }
 //updating the content table checkboxes
 function updateCheckBox() {
 var objForm  = document.createSimpleDialog;
 var chkList  = objForm.chkList;
 chkList.checked = false;
  }

 function doCheck(){
	var objForm = document.forms[0];
	var chkList = objForm.chkList;

	    for (var i=0; i < objForm.elements.length; i++){
	      if (objForm.elements[i].name.indexOf('chkItem') > -1){
	        objForm.elements[i].checked = chkList.checked;
	         }
	    }
   }

  /*
        Function to remove the selected content
  */
function removeSelectedContent() {
                            		var routeInstructions="";
                                    var routeInitiateManner="";
                                    var allowDelegation="";
                                    var routeAction="";
                                    var peopleFinalList=new Array();
                                    var routeDueDate="";
                                    var routeMemberFilter="";
                                    var routeDueDateMSValue="";
                                    thisForm=document.createSimpleDialog;

                                    routeInstructions=jsTrim(thisForm.routeInstructions.value+"");
									routeInstructions=encodeURIComponent(routeInstructions);
                            		routeInstructions= routeInstructions.replace(/%0A/g,"E:N:T:E:R");
    var docIdsStates = getStatesWithIds();

    if(thisForm.routeInitiateManner.checked) {
                                        routeInitiateManner="checked";
                                    }
    if(thisForm.allowDelegation.checked) {
		allowDelegation="checked";
	}
                                    routeAction=thisForm.routeAction.value;

                                    routeDueDate=thisForm.routeDueDate.value;
                                    routeDueDateMSValue=thisForm.routeDueDate_msvalue.value;
                                    o = thisForm.memberFinalList.options;
                                    routeMemberString=joinFinalMemberList();
               var varChecked = "false";
               var objForm = document.createSimpleDialog;
    for (var i=0; i < objForm.elements.length; i++) {
		if (objForm.elements[i].type == "checkbox") {
                         if ((objForm.elements[i].name.indexOf('chkItem1') > -1) && (objForm.elements[i].checked == true)) {
                         varChecked = "true";
                     }
                   }
             }
    if (varChecked == "false") {
                   alert("<emxUtil:i18nScript localize="i18nId">emxComponents.AttachmentsDialog.SelectContent</emxUtil:i18nScript>");
                   return;
             }
    else {
    	if (confirm("<emxUtil:i18nScript localize="i18nId">emxComponents.AttachmentsDialog.MsgConfirm</emxUtil:i18nScript>") != 0) {
                      document.createSimpleDialog.action="emxRouteSimpleRemoveContentProcess.jsp?statesWithIds="+docIdsStates+"&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&objectId=<%=XSSUtil.encodeForURL(context, objectId)%>&routeInstructions="+routeInstructions+"&routeInitiateManner="+routeInitiateManner+"&routeDueDate="+routeDueDate+"&routeAction="+routeAction+"&routeMemberFilter="+routeMemberFilter+"&routeMemberString="+routeMemberString+"&routeDueDateMSValue="+routeDueDateMSValue+"&allowDelegation="+allowDelegation;
                      document.createSimpleDialog.submit();
                      return;
                  }
             }
  }

</script>

</head>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<body onLoad="initDialog()">

<form name="createSimpleDialog" method="post" action="emxRouteSimpleCreateProcess.jsp" target="_parent" onsubmit="javascript:submitForm(); return false">



  <table border="0" cellpadding="5" cellspacing="2" width="100%">
    <tr><!-- Added for the bug 314794-->
      <td class="labelRequired" width="100%"><emxUtil:i18n localize="i18nId">emxComponents.CreateSimpleRouteDialog.RouteDetails</emxUtil:i18n></td>
  </table>
  	
    <table  border="0" cellpadding="5" cellspacing="2" width="100%">
     <tr>
        <td width="100%" class="inputField">
            	<table width="100%" cellpadding="5" cellspacing="2">
            <tr>
                		<td  width="60%"  class="inputField">
                    		<table border="0"  width="50%">
    			<tr>
                            <td><emxUtil:i18n localize="i18nId">emxComponents.CreateSimpleRouteDialog.RouteInstructions</emxUtil:i18n></label></td>
    			</tr>
    			<tr>
                            		<td><textarea name="routeInstructions"  id="routeInstructions" cols="30" rows="5" style="width:400px" wrap><xss:encodeForHTML><%=routeInstructions%></xss:encodeForHTML></textarea></td>
    			</tr>
                    </table>
		</td>
						<td width="40%" class="inputField">
                   <table width="100%" cellpadding="0" cellspacing="4">
                   <tr>
                       <td width="100%">
                           <table border="0" cellspacing="2" cellpadding="0">
				<tr>
				<td><emxUtil:i18n localize="i18nId">emxComponents.CreateSimpleRouteDialog.RouteAction</emxUtil:i18n></td>
				</tr>
				<tr>
                                				<td>
                                          <select name="routeAction">
                <%
                 //added below line of code for the bug 314795
     			  StringItr  routeActionItr  = new StringItr (routeActionList);
	              while(routeActionItr.next()) {
                  	String rangeValue = routeActionItr.obj();
                    String i18nRouteAction = i18nNow.getRangeI18NString(DomainConstants.ATTRIBUTE_ROUTE_ACTION, rangeValue, sLanguage);

                    if ( strDefaultAction != null && strDefaultAction.equals(rangeValue) ) {
%>
                  <!-- //XSSOK -->    
                      <option value="<%=rangeValue%>" Selected> <%=XSSUtil.encodeForHTMLAttribute(context, i18nRouteAction)%> </option>
<%
                    } else {
%>                <!-- //XSSOK --> 
                       <option value="<%=rangeValue%>"> <%=XSSUtil.encodeForHTMLAttribute(context, i18nRouteAction)%> </option>
<%
                    }
                  }

              //end of  code for the bug 314795
%>
                                          </select>
                                    </td>
  				</tr>
  			   </table>
                       </td>
                   </tr>
                   <tr>
                        <td width="100%">
                            <table border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td><emxUtil:i18n localize="i18nId">emxComponents.CreateSimpleRouteDialog.RouteDueDate</emxUtil:i18n></td>
                                </tr>
                                <tr>
                                    			<td><input readonly type="text" name="routeDueDate" value="<xss:encodeForHTMLAttribute><%=routeDueDate%></xss:encodeForHTMLAttribute>"/>&nbsp;<a href="javascript:showCalendar('createSimpleDialog','routeDueDate','',true)" ><img src="../common/images/iconSmallCalendar.gif" border=0 valign="absmiddle" name=img5/></a>&nbsp;</td>
                                </tr>
                            </table>
			</td>
                    </tr>
                    <tr>
                        <td width="100%">
                            <table border="0" cellspacing="0" cellpadding="0">
                                <tr><!-- //XSSOK -->
                                    			<td nowrap><input  type="checkbox" name="routeInitiateManner" <%=routeInitiateManner.equals("checked")?"checked value=\"start\"":"value=\"\" "%>/>&nbsp; <emxUtil:i18n localize="i18nId"> emxComponents.CreateSimpleRoute.RouteStart</emxUtil:i18n> &nbsp;</td>
                                </tr>
                                <tr>
                                   				<td nowrap><input  type="checkbox" name="allowDelegation"  <%=allowDelegation.equals("checked")?"checked value=\"TRUE\"":"value=\"FALSE\" "%> />&nbsp; <emxUtil:i18n localize="i18nId"> emxComponents.AssignTasksDialog.AllowDelegation</emxUtil:i18n> &nbsp;</td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                   </table>
		</td>
            </tr>
            </table>
        </td>
     </tr>
     </table>

<jsp:include page="emxRouteSimplePeopleSearch.jsp">
        <jsp:param name="findRole" value="<%=memberLinks.get(\"findRole\")%>" />
        <jsp:param name="findPerson" value="<%=memberLinks.get(\"findPerson\")%>" />
        <jsp:param name="findGroup" value="<%=memberLinks.get(\"findGroup\")%>" />
         <jsp:param name="findUserGroup" value="<%=memberLinks.get(\"findUserGroup\")%>" />
        <jsp:param name="findMemberList" value="<%=memberLinks.get(\"findMemberList\")%>" />
</jsp:include>

<table width="100%" >
<tr><td  width="100%" nowrap class="labelRequired"><emxUtil:i18n localize="i18nId">emxComponents.Command.TaskContent</emxUtil:i18n></td>
</table>
  <%@include file = "emxRouteWizardDocumentSummary.inc" %>

  <!--------- Hidden Variables  Start------------>
    <input type="hidden" name="routeDueDate_msvalue" value="<xss:encodeForHTMLAttribute><%=routeDueDateMSValue%></xss:encodeForHTMLAttribute>"/>
  <input  type="hidden" name="parentId" value="<xss:encodeForHTMLAttribute><%=parentId%></xss:encodeForHTMLAttribute>"/>
  <input  type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="routeId"    value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="keyValue" value="<xss:encodeForHTMLAttribute><%=keyValue%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="routeMemberString" value="<xss:encodeForHTMLAttribute><%=keyValue%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="searchDocId" value="<xss:encodeForHTMLAttribute><%=searchDocId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="scopeId" value="<xss:encodeForHTMLAttribute><%=scopeId%></xss:encodeForHTMLAttribute>"/>

  <!--------- Hidden Variables End ------------>
</form>
<script language="JavaScript">
    var suffixParam="&keyValue=<%=XSSUtil.encodeForJavaScript(context, keyValue)%>&fromPage=QuickRoute";
    var memberLinks=new Array();
	//XSSOK
    memberLinks['findRole']="<%=memberLinks.get("findRole")%>"+suffixParam
	//XSSOK
    memberLinks['findGroup']="<%=memberLinks.get("findGroup")%>"+suffixParam;
    //XSSOK
    memberLinks['findPerson']="<%=memberLinks.get("findPerson")%>"+suffixParam;
    //XSSOK
    memberLinks['findUserGroup']="<%=memberLinks.get("findUserGroup")%>"+suffixParam;
    //XSSOK
    memberLinks['findMemberList']="<%=memberLinks.get("findMemberList")%>"+suffixParam;
    function getRouteMemebers(memberName) {
        var url=eval("memberLinks['"+memberName+"']");
        var frame = emxUICore.findFrame(getTopWindow(), "pagehidden");
        if(memberName== 'findPerson' || memberName == 'findMemberList' || memberName== 'findUserGroup' ){
        	frame.location.href = url;
        }else{
        emxShowModalDialog(url,775, 500);
        }
    }
</script>
<%!
            /**
                        Method to decide which pages needs to be called for "Role", "Group" or "People " selection
                        When the underlying object is "Workspace" , then make the set of pages
                        When the underlying object is "Project" , then make the set of pages
                        When the underlying object is "Project Folder " , then make the set of pages
                        other wise  make the set of pages.
            */
	public Hashtable makeRouteMemberLinks(Context context,HttpSession session,FormBean formBean,String objectId) {
                   Hashtable linksTable=new Hashtable();
                   String supplierOrgId=(String)formBean.getElementValue("supplierOrgId");
                   String projectId="";
                   String folderId="";
                   String projObjType="";
                   String curObjType="";

        try {
           DomainObject curentObj=new DomainObject(objectId);
           curObjType=curentObj.getInfo(context,DomainConstants.SELECT_TYPE);

           DomainObject projObj=new DomainObject();
           if(curObjType.equals(DomainConstants.TYPE_WORKSPACE_VAULT)) {
               projectId=UserTask.getProjectId( context, objectId);
               projObj.setId(projectId);
	            projObjType=projObj.getInfo(context,DomainConstants.SELECT_TYPE);
    	    }
		}catch(Exception e) {}
		
		try {
			if(curObjType.equals(DomainConstants.TYPE_WORKSPACE) || projObjType.equals(DomainConstants.TYPE_WORKSPACE)) {
				/* linksTable.put("findRole", "emxRouteMembersSearch.jsp?fromPage=QuickRoute&memberType=Role&scopeId="+objectId+ "&objectId="+objectId); */
				linksTable.put("findRole", "hide");
				linksTable.put("findPerson", "emxRouteMembersSearch.jsp?fromPage=QuickRoute&memberType=Person&scopeId="+objectId+ "&objectId="+objectId);
				/* linksTable.put("findGroup", "emxRouteMembersSearch.jsp?fromPage=QuickRoute&memberType=Group&scopeId="+objectId+ "&objectId="+objectId); */
				linksTable.put("findGroup", "hide");
				linksTable.put("findUserGroup", "emxRouteMembersSearch.jsp?fromPage=QuickRoute&memberType=UserGroup&scopeId="+objectId+ "&objectId="+objectId);
			    linksTable.put("findMemberList", "hide");
				/* linksTable.put("findMemberList", "emxRouteMembersSearch.jsp?fromPage=QuickRoute&memberType=MemberList&scopeId="+objectId+ "&objectId="+objectId); */

			} else if(projObjType.equals(DomainObject.TYPE_PROJECT_SPACE) || (projObjType!=null && !"null".equals(projObjType) && !"".equals(projObjType) && mxType.isOfParentType(context,projObjType,DomainConstants.TYPE_PROJECT_SPACE))) {//Modified to handle Sub Type 
				/* linksTable.put("findRole", "emxRouteMembersSearch.jsp?fromPage=QuickRoute&memberType=Role&scopeId="+projectId+ "&objectId="+objectId); */
				linksTable.put("findRole", "hide");
				linksTable.put("findPerson", "emxRouteMembersSearch.jsp?fromPage=QuickRoute&memberType=Person&scopeId="+projectId+ "&objectId="+objectId);
				/* linksTable.put("findGroup", "emxRouteMembersSearch.jsp?fromPage=QuickRoute&memberType=Group&scopeId="+projectId+ "&objectId="+objectId); */
				linksTable.put("findGroup", "hide");
				linksTable.put("findUserGroup", "emxRouteMembersSearch.jsp?fromPage=QuickRoute&memberType=UserGroup&scopeId="+projectId+ "&objectId="+objectId);
				linksTable.put("findMemberList", "hide");
				/* linksTable.put("findMemberList", "emxRouteMembersSearch.jsp?fromPage=QuickRoute&memberType=MemberList&scopeId="+projectId+ "&objectId="+objectId);	 */			

			} else if( curObjType.equals(DomainObject.TYPE_PROJECT_SPACE) || (curObjType!=null && !"null".equals(curObjType) && !"".equals(curObjType) && mxType.isOfParentType(context,curObjType,DomainConstants.TYPE_PROJECT_SPACE))) {//Modified to handle Sub Type
				linksTable.put("findRole", "hide");
				linksTable.put("findPerson", "emxRouteMembersSearch.jsp?fromPage=QuickRoute&memberType=Person&scopeId="+objectId+ "&objectId="+objectId);
				linksTable.put("findUserGroup", "hide");
				linksTable.put("findGroup", "hide");
				linksTable.put("findMemberList", "hide");				
			} else {
				/*linksTable.put("findRole", "emxRouteMembersSearch.jsp?fromPage=QuickRoute&memberType=Role&scopeId="+objectId); */
				linksTable.put("findRole", "hide");
				linksTable.put("findPerson", "emxRouteMembersSearch.jsp?fromPage=QuickRoute&memberType=Person&scopeId="+objectId);
				/*linksTable.put("findGroup", "emxRouteMembersSearch.jsp?fromPage=QuickRoute&memberType=Group&scopeId="+objectId); */
				linksTable.put("findGroup", "hide");
				linksTable.put("findUserGroup", "emxRouteMembersSearch.jsp?fromPage=QuickRoute&memberType=UserGroup&scopeId="+objectId);
				/* linksTable.put("findMemberList", "emxRouteMembersSearch.jsp?fromPage=QuickRoute&memberType=MemberList&scopeId="+objectId); */
				linksTable.put("findMemberList", "hide");
			}
			//Moved down catch here to hanndle for Project Sub typing
		}catch(Exception e) {}
		return linksTable;
     }
%>
   <%@include file = "../emxUICommonEndOfPageInclude.inc" %>


