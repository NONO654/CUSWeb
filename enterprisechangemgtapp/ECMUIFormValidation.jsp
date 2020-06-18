<%--  ECMUIFormValidation.jsp

	Copyright (c) 1992-2018 Dassault Systemes.
	ECMUIFormValidation.jsp which is validation jsp for all edit forms in ECM.
--%>

<%@include file = "ECMDesignTopInclude.inc"%>


<%
			String accLanguage  	= request.getHeader("Accept-Language");
			Person person 			= Person.getPerson(context);
			Company company 		= person.getCompany(context);
			boolean isChangeAdmin 	= ChangeUtil.hasChangeAdministrationAccess(context);
			String sFunctionality = (String) session.getAttribute("functionality");
			String userName = "";
			String userFullName = "";
			String languageStr 		= context.getSession().getLanguage();
			DomainObject dmObj 		= DomainObject.newInstance(context);

			String sConnectedType 		= "";
			String sConnectedName 		= "";
			String sConnectedID   		= "";
			String sConnectedRO			= "";
			String sConnectedROID		= "";
			String sAvailability  		= "";
			String sPersonBussinessUnitId 	= "";
			String sPersonBussinessUnitName = "";
			Map resultMap = null;
			boolean isBusinessUnitEmployee 	= false;
			
			boolean hasAvailability = false;

			String companyName    		= company.getName();
			String companyId      		= company.getId();
			
			
			String loggedInPersonId 	= PersonUtil.getPersonObjectID(context);
			
			String objectID 			=(String)request.getParameter("objectId");
			

			SelectList selectStmts = new SelectList();
			selectStmts.addElement("to["+ChangeConstants.RELATIONSHIP_CHANGE_TEMPLATES+"].from.type");
			selectStmts.addElement("to["+ChangeConstants.RELATIONSHIP_CHANGE_TEMPLATES+"].from.name");
			selectStmts.addElement("to["+ChangeConstants.RELATIONSHIP_CHANGE_TEMPLATES+"].from.id");


			if(!UIUtil.isNullOrEmpty(objectID)){
				dmObj.setId(objectID);
				
				resultMap 			= dmObj.getInfo(context, selectStmts);
				
				sConnectedType 		= (String)resultMap.get("to["+ChangeConstants.RELATIONSHIP_CHANGE_TEMPLATES+"].from.type");
				sConnectedName 		= (String)resultMap.get("to["+ChangeConstants.RELATIONSHIP_CHANGE_TEMPLATES+"].from.name");
				sConnectedID 		= (String)resultMap.get("to["+ChangeConstants.RELATIONSHIP_CHANGE_TEMPLATES+"].from.id");
				
				
					
				if("Person".equals(sConnectedType))
				{
					sAvailability 	= "Personal";
					hasAvailability = true;
					
				}
				else
				{
					sAvailability 	= "Enterprise";
					hasAvailability = false;
				}
			}

			if(!UIUtil.isNullOrEmpty(loggedInPersonId)){
				dmObj.setId(loggedInPersonId);
				sPersonBussinessUnitId 	= dmObj.getInfo(context, "to["+DomainConstants.RELATIONSHIP_BUSINESS_UNIT_EMPLOYEE+"].from.id");
				sPersonBussinessUnitName= dmObj.getInfo(context, "to["+DomainConstants.RELATIONSHIP_BUSINESS_UNIT_EMPLOYEE+"].from.name");
				
				
			}


			if(!UIUtil.isNullOrEmpty(sPersonBussinessUnitId)){
				isBusinessUnitEmployee 	= true;
			}

			String functionality = (String)request.getParameter("sfunctionality");
			if(functionality != null){
				String ParentOID = (String)request.getParameter("parentOID");
				String Selectitem ="";
				dmObj.setId(ParentOID);
				selectStmts.clear();
				selectStmts.addElement(DomainConstants.SELECT_OWNER);
				if("transferOwnershipToChangeCoordinator".equals(functionality)||"transferOwnershipToChangeCoordinatorForCR".equals(functionality)){
					Selectitem = "from["+ChangeConstants.RELATIONSHIP_CHANGE_COORDINATOR+"].to.name";
					selectStmts.addElement(Selectitem);
				}
				else if("transferOwnershipToSrTechnicalAssignee".equals(functionality)){
					Selectitem = "from["+ChangeConstants.RELATIONSHIP_SENIOR_TECHNICAL_ASSIGNEE+"].to.name";
					selectStmts.addElement(Selectitem);
				}
				else if("transferOwnershipToTechnicalAssignee".equals(functionality)){
					Selectitem="from["+ChangeConstants.RELATIONSHIP_TECHNICAL_ASSIGNEE+"].to.name";
					selectStmts.addElement(Selectitem);
				}
				resultMap 			= dmObj.getInfo(context, selectStmts);
				userName = (String)resultMap.get(Selectitem);
				if(!UIUtil.isNullOrEmpty(userName)){
					userFullName = PersonUtil.getFullName(context, userName);
				}
				else{
					userName = (String)resultMap.get(DomainConstants.SELECT_OWNER);
					if(!UIUtil.isNullOrEmpty(userName))
						userFullName = PersonUtil.getFullName(context, userName);
					else
					userFullName = "";
				}
			}

			
%>
<emxUtil:localize id="i18nIdn" bundle="emxEnterpriseChangeMgtStringResource" locale='<%= XSSUtil.encodeForHTML(context, accLanguage) %>' />
<script language=javascript>	

/******************************************************************************/
/* function clearAll() - clear all the field on Edit Change Page        */
/*                                                                            */
/******************************************************************************/
function clearAll()
{
	var sChangeTemplateDisplay  		= document.forms['editDataForm'].elements["ChangeTemplateDisplay"].value;
	if(sChangeTemplateDisplay==""){
		basicClear("ResponsibleOrganization");
		basicClear("ReviewersList");
		basicClear("ChangeCoordinator");
		basicClear("ApprovalList");
		basicClear("DistributionList");
		basicClear("ReportedAgainst");
	}
}

/******************************************************************************/
/* function setDefaultPolicy() - set Default Change Policy on Create Change Template page*/
/*                                                                            */
/******************************************************************************/
function setDefaultPolicy(){
	emxFormReloadField("DefaultCOPolicy");
}

/******************************************************************************/
/* function preProcessInEditCO() - set RO in Create page*/
/*                                                                            */
/******************************************************************************/
function preProcessInEditCO(){
	var sChangeTemplateRO  = document.forms['editDataForm'].elements["ResponsibleOrganization"].value;
	if(sChangeTemplateRO==""){
	//XSSOK
	document.forms['editDataForm'].elements["ResponsibleOrganization"].value				=	"<%=companyName%>";
	//XSSOK
	document.forms['editDataForm'].elements["ResponsibleOrganizationOID"].value			=	"<%=companyId%>";
	//XSSOK
	document.forms['editDataForm'].elements["ResponsibleOrganizationDisplay"].value		=	"<%=companyName%>";
	}
}

/******************************************************************************/
/* function setOwningOrganization() - set Owning Org on Create Change Template page*/
/*                                                                            */
/******************************************************************************/
function setOwningOrg()
{
	//XSSOK
	document.forms['editDataForm'].elements["OwningOrganization"].value				=	"<%=companyName%>";
	//XSSOK
	document.forms['editDataForm'].elements["OwningOrganizationOID"].value			=	"<%=companyId%>";
	//XSSOK
	document.forms['editDataForm'].elements["OwningOrganizationDisplay"].value		=	"<%=companyName%>";
}

function setPersonOrg()
{
	//XSSOK
	document.forms['editDataForm'].elements["OwningOrganization"].value				=	"<%=sPersonBussinessUnitName%>";
	//XSSOK
	document.forms['editDataForm'].elements["OwningOrganizationOID"].value			=	"<%=sPersonBussinessUnitId%>";
	//XSSOK
	document.forms['editDataForm'].elements["OwningOrganizationDisplay"].value		=	"<%=sPersonBussinessUnitName%>";
}

function setConnectedOrg()
{
	//XSSOK
	document.forms['editDataForm'].elements["OwningOrganization"].value				=	"<%=sConnectedName%>";
	//XSSOK
	document.forms['editDataForm'].elements["OwningOrganizationOID"].value			=	"<%=sConnectedID%>";
	//XSSOK
	document.forms['editDataForm'].elements["OwningOrganizationDisplay"].value		=	"<%=sConnectedName%>";
}

function disableOwningOrgButton()
{
	document.forms['editDataForm'].elements["OwningOrganizationDisplay"].disabled	=	true;
	document.forms['editDataForm'].elements["btnOwningOrganization"].disabled		=	true;
	document.forms['editDataForm'].elements["OwningOrganization"].disabled			=	true;
}

function enableOwningOrgButton()
{
	document.forms['editDataForm'].elements["OwningOrganizationDisplay"].disabled	=	false;
	document.forms['editDataForm'].elements["btnOwningOrganization"].disabled		=	false;
}

function setOwningOrgEmpty()
{
	document.forms['editDataForm'].elements["OwningOrganization"].value				=	"";
	document.forms['editDataForm'].elements["OwningOrganizationOID"].value			=	"";
	document.forms['editDataForm'].elements["OwningOrganizationDisplay"].value		=	"";
}

function setOwningOrganization(){	
	
	preProcessInEditCO();
	//XSSOK
	var sAvailabilityVar = "<%=sAvailability%>";
	//XSSOK
	if(<%=isChangeAdmin%>){
		//XSSOK
		if(<%=isBusinessUnitEmployee%>){
			//XSSOK
			if(<%=hasAvailability%>){
				disableOwningOrgButton();
    		}
			else{ 
				setPersonOrg();
			}
	    }
		else{
			//XSSOK
			if(<%=hasAvailability%>){
				disableOwningOrgButton();
    		}
			else{
				setConnectedOrg();
			}
		} 
	 }
	else{
		disableOwningOrgButton();
		 
	}
	
}

/******************************************************************************/
/* function disableOrganizationField() - disable Owning Org on Create Change Template page upon selection of Availability as Personal*/
/*                                                                            */
/******************************************************************************/
function disableOrganizationField(elem){
	var availability = elem.value;
	//XSSOK
	var sConnectType = "<%=sConnectedType%>";
	//XSSOK
	if(<%=isChangeAdmin%>){
		if(availability == "Enterprise"){
			enableOwningOrgButton();
			if(sConnectType=="Person"){
				//XSSOK
				if(<%=isBusinessUnitEmployee%>){
					setPersonOrg();
				}
				else{
					setOwningOrg();
				}
			}
			else{
				setConnectedOrg();
			}
		}
		else{
			setOwningOrgEmpty();
			disableOwningOrgButton();
		}
	}
	else{
		disableOwningOrgButton();
	}
	
}

/******************************************************************************/
/* function validateCancelCO() - validates Cancel CO Process*/
/*                                                                            */
/******************************************************************************/
function validateCancelCO() { 
	var reason    			= document.forms['editDataForm'].elements["Reason"].value;
    if(reason!="")  {
		   var confirmmessage="<emxUtil:i18nScript localize="i18nIdn">EnterpriseChangeMgt.CancelCODialog.CancelCOConfirm</emxUtil:i18nScript>"; 		   
           if (confirm(confirmmessage)){
               return true;        
            } else {
               return false;
            }
                    
    } else {
           return true;
    }
    
}

/******************************************************************************/
/* function validateCancelCA() - validates Cancel CA Process*/
/*                                                                            */
/******************************************************************************/
function validateCancelCA() { 
	var reason    			= document.forms['editDataForm'].elements["Reason"].value;
    if(reason!="")  {
		   var confirmmessage="<emxUtil:i18nScript localize="i18nIdn">EnterpriseChangeMgt.CancelCADialog.CancelCAConfirm</emxUtil:i18nScript>"; 		   
           if (confirm(confirmmessage)){
               return true;        
            } else {
               return false;
            }
                    
    } else {
           return true;
    }
    
}

/******************************************************************************/
/* function validateCancelCR() - validates Cancel CR Process*/
/*                                                                            */
/******************************************************************************/
function validateCancelCR() { 
	var reason    			= document.forms['editDataForm'].elements["Reason"].value;
    if(reason!="")  {
		   var confirmmessage="<emxUtil:i18nScript localize="i18nIdn">EnterpriseChangeMgt.CancelCRDialog.CancelCRConfirm</emxUtil:i18nScript>"; 		   
           if (confirm(confirmmessage)){
               return true;        
            } else {
               return false;
            }
                    
    } else {
           return true;
    }
    
}
/******************************************************************************/
/* function preProcessForCancelandHoldCO() - disable Warning field in Hold & Cancel Proess */
/*                                                                            */
/******************************************************************************/
function preProcessForCancelandHoldCO() {
	document.forms['editDataForm'].elements["Warning"].disabled = true;	
}


/******************************************************************************/
/* function validateHoldCO() - validates Hold CO Process*/
/*                                                                            */
/******************************************************************************/
function validateHoldCO() { 
	var reason    			= document.forms['editDataForm'].elements["Reason"].value;
	if(reason!="")  {
		   var confirmmessage="<emxUtil:i18nScript localize="i18nIdn">EnterpriseChangeMgt.HoldCO.ConfirmMsg</emxUtil:i18nScript>"; 		   
           if (confirm(confirmmessage)){
               return true;        
            } else {
               return false;
            }
                    
    } else {
           return true;
    }
    
}

/******************************************************************************/
/* function validateHoldCA() - validates Hold CA Process*/
/*                                                                            */
/******************************************************************************/
function validateHoldCA() { 
	var reason    			= document.forms['editDataForm'].elements["Reason"].value;
	if(reason!="")  {
		   var confirmmessage="<emxUtil:i18nScript localize="i18nIdn">EnterpriseChangeMgt.HoldCA.ConfirmMsg</emxUtil:i18nScript>"; 		   
           if (confirm(confirmmessage)){
               return true;        
            } else {
               return false;
            }
                    
    } else {
           return true;
    }
    
}


/******************************************************************************/
/* function validateHoldCR() - validates Hold CR Process*/
/*                                                                            */
/******************************************************************************/
function validateHoldCR() { 
	var reason    			= document.forms['editDataForm'].elements["Reason"].value;
	if(reason!="")  {
		   var confirmmessage="<emxUtil:i18nScript localize="i18nIdn">EnterpriseChangeMgt.HoldCRDialog.WarningMsg</emxUtil:i18nScript>"; 		   
           if (confirm(confirmmessage)){
               return true;        
            } else {
               return false;
            }
                    
    } else {
           return true;
    }
    
}


/******************************************************************************/
/* function checkPositiveInteger() - Checks for Positive Integer value of the field*/
/*                                                                            */
/******************************************************************************/
function checkPositiveInteger(fieldname)
{
    if(!fieldname) {
        fieldname=this;
    }    

    if( isNaN(fieldname.value) || fieldname.value < 0 || parseInt(fieldname.value) != fieldname.value )
    {
       msg = "Please enter a positive integer value in the field.";
        alert(msg);
        fieldname.focus();
        return false;
    }
    return true;
}

/******************************************************************************/
/* function checkPositiveReal() - Checking for Positive Real value of the field*/
/*                                                                            */
/******************************************************************************/
function checkPositiveReal(fieldname)
{
    if(!fieldname) {
        fieldname=this;
    }    
    if( isNaN(fieldname.value) || fieldname.value < 0 )
    {       
        msg = "Please enter a positive numeric value in the field.\\n Field Name =";
        alert(msg);
        fieldname.focus();
        return false;
    }
    return true;
}

/******************************************************************************/
/* function enableLists() - enable ReviewerList & ApprovalList on CO Edit Page        */
/*                                                                            */
/******************************************************************************/
function enableListFields()
{
			document.forms['editDataForm'].elements["ReviewerListDisplay"].disabled     =      false;
            document.forms['editDataForm'].elements["ReviewerList"].disabled            =     false;
            document.forms['editDataForm'].elements["btnReviewerList"].disabled		=	false;
            
            var flag=document.forms['editDataForm'].elements["ApprovalListDisplay"];
            if(flag=!'undefined'){
            	document.forms['editDataForm'].elements["ApprovalListDisplay"].disabled      =      false;
            	document.forms['editDataForm'].elements["ApprovalList"].disabled             =      false;
            	document.forms['editDataForm'].elements["btnApprovalList"].disabled		=	false;
            }
            document.forms['editDataForm'].elements["ChangeCoordinatorDisplay"].disabled      =      false;
            document.forms['editDataForm'].elements["ChangeCoordinator"].disabled             =      false;
            document.forms['editDataForm'].elements["btnChangeCoordinator"].disabled		=	false;
}

/******************************************************************************/
/* function disableLists() - disable ReviewerList & ApprovalList on CO Edit Page           */
/*                                                                            */
/******************************************************************************/
function disableListFields()
{
			document.forms['editDataForm'].elements["ReviewerListDisplay"].disabled     =      true;
            document.forms['editDataForm'].elements["ReviewerList"].disabled            =      true;
            document.forms['editDataForm'].elements["btnReviewerList"].disabled			=	   true;
            
            var flag=document.forms['editDataForm'].elements["ApprovalListDisplay"];
            if(flag=!'undefined'){
	            document.forms['editDataForm'].elements["ApprovalListDisplay"].disabled      =      true;
	            document.forms['editDataForm'].elements["ApprovalList"].disabled             =      true;
	            document.forms['editDataForm'].elements["btnApprovalList"].disabled			 =	    true;
	        }
            document.forms['editDataForm'].elements["ChangeCoordinatorDisplay"].disabled      =      true;
            document.forms['editDataForm'].elements["ChangeCoordinator"].disabled             =      true;
            document.forms['editDataForm'].elements["btnChangeCoordinator"].disabled		=	true;
}

/******************************************************************************/
/* function clearAllRO() - Clears the RO field on CO Edit Page           */
/*                                                                            */
/******************************************************************************/
function clearAllRO()
{
	var sResponsibleOrganization              = document.forms['editDataForm'].elements["ResponsibleOrganization"].value;
    
    if(sResponsibleOrganization=="")
    {
          basicClear("ReviewerList");
          basicClear("ChangeCoordinator");
          basicClear("ApprovalList");
          basicClear("DistributionList");
          basicClear("ReportedAgainst");
          disableListFields();
          
    } else {
    
          enableListFields();
    
    }
    
	return true;
}
/******************************************************************************/
/* function clearTemplateRO() - Clears the ApproverList, ReviewerList & Change Coordinator on Template Edit page           */
/*                                                                            */
/******************************************************************************/
function clearTemplateRO()
{
	var sResponsibleOrganization              = document.forms['editDataForm'].elements["ResponsibleOrganization"].value;
      if(sResponsibleOrganization==""){
    	  	basicClear("ChangeCoordinator");
    	  	basicClear("ReviewerList");
    	  	basicClear("ApprovalList");
    	  	basicClear("DistributionList");
            basicClear("ReportedAgainst");
      		disableListFields();
      }
      else{
      		enableListFields();
      }
	
}

function AutoFillUserName()
{
	//XSSOK
	document.forms['editDataForm'].elements["NameDisplay"].value = "<%=userFullName%>";
	document.forms['editDataForm'].elements["Name"].value = "<%=userName%>";
}

/******************************************************************************/
/* function pastEstDateCheck() - Validates Estimated dates           
/*                                                                            
/******************************************************************************/
	function pastEstDateCheck()
{
	var strStartDate = "";
	var strCompletionDate = "";
	var strEstStartDate = "";
	var strEstCompletionDate = "";
	var fieldEstStartDate = '';
	var fieldEstCompletionDate = '';
	var fieldEstStartMod ='';
	var fieldEstCompletionMod = '';
	var fieldEstStartDay = '';
	var fieldEstCompletionDay = '';
	
	var editDataFormObj = document.forms['editDataForm'];
	if(editDataFormObj != "" && editDataFormObj != undefined){
		if(editDataFormObj.elements["Estimated Start Date"] != "" 
			&& editDataFormObj.elements["Estimated Start Date"] != undefined){
			strStartDate = editDataFormObj.elements["Estimated Start Date"].value; 
		}

		if(editDataFormObj.elements["Estimated Completion Date"] != "" 
			&& editDataFormObj.elements["Estimated Completion Date"] != undefined){
			strCompletionDate = editDataFormObj.elements["Estimated Completion Date"].value; 
		}

		if(editDataFormObj.elements["Estimated Start Date_msvalue"] != "" 
			&& editDataFormObj.elements["Estimated Start Date_msvalue"] != undefined){
			strEstStartDate = editDataFormObj.elements["Estimated Start Date_msvalue"].value; 
		}

		if(editDataFormObj.elements["Estimated Completion Date_msvalue"] != "" 
			&& editDataFormObj.elements["Estimated Completion Date_msvalue"] != undefined){
			strEstCompletionDate = editDataFormObj.elements["Estimated Completion Date_msvalue"].value; 
		}
	}

	
	if (trimWhitespace(strStartDate) != '') {
		fieldEstStartDate = new Date(new Date(parseInt(strEstStartDate)).toLocaleDateString());
		fieldEstStartDay = fieldEstStartDate.getDate();
		fieldEstStartMod = Date.parse(fieldEstStartDate);
		}
		
	if (trimWhitespace(strCompletionDate) != '') {
		fieldEstCompletionDate = new Date(new Date(parseInt(strEstCompletionDate)).toLocaleDateString());
		fieldEstCompletionDay = fieldEstCompletionDate.getDate();
		fieldEstCompletionMod = Date.parse(fieldEstCompletionDate);
		}
	
	var currentDate = new Date();
  	var currentDay = currentDate.getDate();
  	var currentDateMod = Date.parse(currentDate);
	
	if(trimWhitespace(strStartDate) != '' && (fieldEstStartMod < currentDateMod) && (fieldEstStartDay!=currentDay)){
  		var errormessage="<emxUtil:i18nScript localize="i18nIdn">EnterpriseChangeMgt.Alert.EstimatedStartDate</emxUtil:i18nScript>";
		alert(errormessage);
  		return false;
  	}
	
	if (trimWhitespace(strStartDate) == '' && trimWhitespace(strCompletionDate) != ''){
		var errormessage="<emxUtil:i18nScript localize="i18nIdn">EnterpriseChangeMgt.Alert.DueDateCheckStartDate</emxUtil:i18nScript>";
		alert(errormessage);
		return false;
		}
	
	
	if (trimWhitespace(strCompletionDate) != '' && (fieldEstStartMod > fieldEstCompletionMod)) {
		var errormessage="<emxUtil:i18nScript localize="i18nIdn">EnterpriseChangeMgt.Alert.DueDate</emxUtil:i18nScript>";
		alert(errormessage);
		return false;
		}
	return true;
}
/*****************************************************************************************************************************/
/* function validateEstimatedStartDate() - Validates Estimated Start Date which should be greater than today's date
/*                                                                            
/*****************************************************************************************************************************/
function validateEstimatedStartDate() {
	var strStartDate_msvalue = "";
	var strStartDate = "";

	var editDataFormObj = document.forms['editDataForm'];
	if(editDataFormObj != '' && editDataFormObj != undefined){
		if(editDataFormObj.elements["EstimatedStartDate_msvalue"] != "" 
			&& editDataFormObj.elements["EstimatedStartDate_msvalue"] != undefined){
			strStartDate_msvalue = editDataFormObj.elements["EstimatedStartDate_msvalue"].value; 
		}

		if(editDataFormObj.elements["EstimatedStartDate"] != "" 
			&& editDataFormObj.elements["EstimatedStartDate"] != undefined){
			strStartDate = editDataFormObj.elements["EstimatedStartDate"].value; 
		}
	}
	
    var currentDate = new Date();
    currentDate.setHours(0,0,0,0);
    var eDate = new Date(new Date(parseInt(strStartDate_msvalue)).toDateString());
    eDate.setHours(0,0,0,0);
   if(trimWhitespace(strStartDate) != "" && strStartDate != undefined) {
	    if(eDate<currentDate) {
	    	var errormessage="<emxUtil:i18nScript localize="i18nIdn">EnterpriseChangeMgt.Alert.EstimatedStartDate</emxUtil:i18nScript>";
	        alert(errormessage);
	        return false;
	    }
    }
    
    return true;
}

/*****************************************************************************************************************************/
/* function validateEstimatedCompletionDate() - Validates Estimated Completion date which should be greater than today's date
/*                                              and greater than or equal to Estimated Start Date (if entered)                              
/*****************************************************************************************************************************/
function validateEstimatedCompletionDate() {

	var strCompletionDate_msvalue = "";
	var strCompletionDate = "";
	var strStartDate_msvalue = "";
	var strStartDate = "";
	var startDate = '';

	var editDataFormObj = document.forms['editDataForm'];
	if(editDataFormObj != "" && editDataFormObj != undefined){
		if(editDataFormObj.elements["Estimated Completion Date_msvalue"] != "" 
			&& editDataFormObj.elements["Estimated Completion Date_msvalue"] != undefined){
			strCompletionDate_msvalue = editDataFormObj.elements["Estimated Completion Date_msvalue"].value; 
		}

		if(editDataFormObj.elements["Estimated Completion Date"] != "" 
			&& editDataFormObj.elements["Estimated Completion Date"] != undefined){
			strCompletionDate = editDataFormObj.elements["Estimated Completion Date"].value; 
		}

		if(editDataFormObj.elements["EstimatedStartDate_msvalue"] != "" 
			&& editDataFormObj.elements["EstimatedStartDate_msvalue"] != undefined){
			strStartDate_msvalue = editDataFormObj.elements["EstimatedStartDate_msvalue"].value; 
		}

		if(editDataFormObj.elements["EstimatedStartDate"] != "" 
			&& editDataFormObj.elements["EstimatedStartDate"] != undefined){
			strStartDate = editDataFormObj.elements["EstimatedStartDate"].value; 
		}
	}

    var currentDate = new Date();
    currentDate.setHours(0,0,0,0);

    var dueDate = new Date(new Date(parseInt(strCompletionDate_msvalue)).toDateString());
    dueDate.setHours(0,0,0,0);

	if (trimWhitespace(strStartDate) != '') {
		startDate = new Date(new Date(parseInt(strStartDate_msvalue)).toDateString());	
		startDate.setHours(0,0,0,0);
	}

   if(trimWhitespace(strCompletionDate) != "" && strCompletionDate != undefined) {
	    if(dueDate<currentDate) {
	    	var errormessage="<emxUtil:i18nScript localize="i18nIdn">EnterpriseChangeMgt.Alert.DueDateGreaterThanCurrent</emxUtil:i18nScript>";
	        alert(errormessage);
	        return false;
	    }

	    if(trimWhitespace(strStartDate) != '' && strStartDate != undefined) {
	    	if(startDate>dueDate){
				var errormessage="<emxUtil:i18nScript localize="i18nIdn">EnterpriseChangeMgt.Alert.DueDate</emxUtil:i18nScript>";
				alert(errormessage);
				return false;	    		
	    	}
	    }
    }
    
    return true;
}
function addReviewSelectors(){
	var ReviewersHidden = document.getElementById("ReviewersHidden");
	var sURL=	'../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active&excludeOID='+ReviewersHidden.value+'&table=AEFGeneralSearchResults&selection=multiple&hideHeader=true&submitURL=../enterprisechangemgtapp/ECMUtil.jsp?mode=searchUtilReviewer&targetTag=select&selectName=Reviewers';
	showChooser(sURL, 850, 630);
}
function addRouteSelectors(){
	var ReviewersHidden = document.getElementById("ReviewersHidden");
	var sURL=	'../common/emxFullSearch.jsp?field=TYPES=type_RouteTemplate:ROUTE_BASE_PURPOSE=Approval:CURRENT=policy_RouteTemplate.state_Active:LATESTREVISION=TRUE&table=APPECRouteTemplateSearchList&includeOIDprogram=emxRouteTemplate:getRouteTemplateIncludeIDs&selection=single&excludeOID='+ReviewersHidden.value+'&hideHeader=true&submitURL=../enterprisechangemgtapp/ECMUtil.jsp?mode=searchUtilReviewer&targetTag=select&selectName=Reviewers';
	showChooser(sURL, 850, 630);
}
	
function removeReviewers() {
	var selectTag = document.getElementsByName("Reviewers");
	var selectedOptionsValue = "";
	var bIsReviewerFieldModified = "false";
	for (var i=selectTag[0].options.length-1;i>=0;i--) {
		if (selectTag[0].options[i].selected) {
			if (selectedOptionsValue!="") {
				selectedOptionsValue += ",";
			}
			selectedOptionsValue += selectTag[0].options[i].value;
			selectTag[0].remove(i);
			bIsReviewerFieldModified = "true";
		}
	}
	//To make the decision of calling connect/disconnect method only on field modification.
	if(bIsReviewerFieldModified==="true"){
		var isReviewerFieldModified = document.getElementById("IsReviewerFieldModified");
		isReviewerFieldModified.value = "true";
	}	
	var reviewersHidden = document.getElementById("ReviewersHidden");
	var reviewersHiddenType = document.getElementById("ReviewersHiddenType");
	var reviewersHiddenValues = reviewersHidden.value.split(",");
	var reviewersHiddenTypeValues = reviewersHiddenType.value.split(",");
	var selectedOptionsValues = selectedOptionsValue.split(",");
	var reviewersHiddenNewValue = "";
	var reviewersHiddenTypeNewValue = "";
	for (var j=0;j<reviewersHiddenValues.length;j++) {
		var reviewersHiddenValue = reviewersHiddenValues[j];
		var reviewersHiddenTypeValue = reviewersHiddenTypeValues[j];		
		var contains = "false";
		for (var k=0;k<selectedOptionsValues.length;k++) {
    		var selectedOptionValue = selectedOptionsValues[k];
    		if (reviewersHiddenValue == selectedOptionValue) {
    			contains = "true";
    		}
    	}
		if (contains == "false") {
			if (reviewersHiddenNewValue!="") {
				reviewersHiddenNewValue += ",";
				reviewersHiddenTypeNewValue+=",";
    		}
			reviewersHiddenNewValue += reviewersHiddenValue;
			reviewersHiddenTypeNewValue += reviewersHiddenTypeValue;
		}
	}
	reviewersHidden.value = reviewersHiddenNewValue;
	reviewersHiddenType.value = reviewersHiddenTypeNewValue;
	if(reviewersHiddenTypeNewValue!="")
	{
		var reviewersHiddenValues = reviewersHiddenTypeNewValue.split(",");
		var reviewerTypePresent = reviewersHiddenValues[0];
		if(reviewerTypePresent=="Person")
		{
			hideReviewers("RouteTemplate");
		}
		else if(reviewerTypePresent=="Route Template"){
			hideReviewers("Person");
		}
		
	}else
	{
		hideReviewers("None");
	}
}	



function hideReviewers(hidebutton){
	var hideReviewerPerson = document.getElementById("ReviewrHidePerson");
	var hideReviewerRouteTemplate = document.getElementById("ReviewrHideRouteTemplate");
	if(hidebutton=="None")
	{
		hideReviewerPerson.style.display= "block";
		hideReviewerRouteTemplate.style.display= "block";
		
	}else if(hidebutton=="Person")
	{
		hideReviewerPerson.style.display= "none";
		}
	else if(hidebutton=="RouteTemplate"){
		hideReviewerRouteTemplate.style.display= "none";
		}
}
function addPersonAsFollower(){
	var followerHidden = document.getElementById("FollowerHidden");
	var sURL=	'../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active&excludeOID='+followerHidden.value+'&table=AEFGeneralSearchResults&selection=multiple&hideHeader=true&submitURL=../enterprisechangemgtapp/ECMUtil.jsp?mode=searchUtilPerson&targetTag=select&selectName=Follower&&inputFieldHidden=FollowerHidden';
	showChooser(sURL, 850, 630);
}
function removeFollower(){
	var selectTag = document.getElementsByName("Follower");
	var selectedOptionsValue = "";
	var bIsFollowerFieldModified = "false";
	for (var i=selectTag[0].options.length-1;i>=0;i--) {
		if (selectTag[0].options[i].selected) {
			if (selectedOptionsValue!="") {
				selectedOptionsValue += ",";
			}
			selectedOptionsValue += selectTag[0].options[i].value;
			selectTag[0].remove(i);
			bIsFollowerFieldModified = "true";
		}
	}
	//To make the decision of calling connect/disconnect method only on field modification.
	if(bIsFollowerFieldModified==="true"){
		var isFollowerFieldModified = document.getElementById("IsFollowerFieldModified");
		isFollowerFieldModified.value = "true";
	}	
	var followerHidden = document.getElementById("FollowerHidden");
	var followerHiddenValues = followerHidden.value.split(",");
	var selectedOptionsValues = selectedOptionsValue.split(",");
	var followerHiddenNewValue = "";
	for (var j=0;j<followerHiddenValues.length;j++) {
		var followerHiddenValue = followerHiddenValues[j];
		var contains = "false";
		for (var k=0;k<selectedOptionsValues.length;k++) {
    		var selectedOptionValue = selectedOptionsValues[k];
    		if (followerHiddenValue == selectedOptionValue) {
    			contains = "true";
    		}
    	}
		if (contains == "false") {
			if (followerHiddenNewValue!="") {
				followerHiddenNewValue += ",";
    		}
			followerHiddenNewValue += followerHiddenValue;
		}
	}
	followerHidden.value = followerHiddenNewValue;
}
function addPersonAsContributor(){
	var contributorHidden = document.getElementById("ContributorHidden");
	var sURL=	'../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active&excludeOID='+contributorHidden.value+'&table=AEFGeneralSearchResults&selection=multiple&hideHeader=true&submitURL=../enterprisechangemgtapp/ECMUtil.jsp?mode=searchUtilPerson&targetTag=select&selectName=Contributor&inputFieldHidden=ContributorHidden';
	showChooser(sURL, 850, 630);
}
function removeContributor(){
	var selectTag = document.getElementsByName("Contributor");
	var selectedOptionsValue = "";
	var bIsContributorFieldModified = "false";
	for (var i=selectTag[0].options.length-1;i>=0;i--) {
		if (selectTag[0].options[i].selected) {
			if (selectedOptionsValue!="") {
				selectedOptionsValue += ",";
			}
			selectedOptionsValue += selectTag[0].options[i].value;
			selectTag[0].remove(i);
			bIsContributorFieldModified = "true";
		}
	}
	//To make the decision of calling connect/disconnect method only on field modification.
	if(bIsContributorFieldModified==="true"){
		var isContributorFieldModified = document.getElementById("IsContributorFieldModified");
		isContributorFieldModified.value = "true";
	}
	var contributorHidden = document.getElementById("ContributorHidden");
	var contributorHiddenValues = contributorHidden.value.split(",");
	var selectedOptionsValues = selectedOptionsValue.split(",");
	var contributorHiddenNewValue = "";
	for (var j=0;j<contributorHiddenValues.length;j++) {
		var contributorHiddenValue = contributorHiddenValues[j];
		var contains = "false";
		for (var k=0;k<selectedOptionsValues.length;k++) {
    		var selectedOptionValue = selectedOptionsValues[k];
    		if (contributorHiddenValue == selectedOptionValue) {
    			contains = "true";
    		}
    	}
		if (contains == "false") {
			if (contributorHiddenNewValue!="") {
				contributorHiddenNewValue += ",";
    		}
			contributorHiddenNewValue += contributorHiddenValue;
		}
	}
	contributorHidden.value = contributorHiddenNewValue;
}
/******************************************************************************/
/* function checkIsNumeric() - Validates Name as non-numeric              
/*                                                                              
/******************************************************************************/
function checkIsNumeric(fieldname){
	if(!fieldname){
		 fieldname=this;
	}
	var filedvalue=fieldname.value.split(".").join("");
	if(isNaN(filedvalue)){
		return true;	
	}
	alert("<emxUtil:i18nScript localize="i18nIdn">EnterpriseChangeMgt.Alert.AlphanumericValueAlert</emxUtil:i18nScript> : "+this.name);
	fieldname.focus();
	return false;
	
}

function loadDelegatedUIEditChange(portalMode,targetWindow){
	
		console.log("loadDelegatedUIEditChange ");
		if(portalMode =='true'){
			parent.parent.parent.parent.window.launchDelegatedUI(targetWindow);
		}else{
			parent.parent.window.launchDelegatedUI(targetWindow);
		}
		
}


/*****************************************************************************************************************************/
/* function validateReviewerListAndApprovalList() - Validates Reviewer List and Approval List for CO are distince
/*                                                                            
/*****************************************************************************************************************************/
function validateReviewerListAndApprovalList() {
	var editDataForm = document.forms["editDataForm"];
	var reviewerListOid = "";
	var approvalListOid = "";
	var reviewerList = "";
	var approvalList = "";
	if(typeof editDataForm != 'undefined' && editDataForm != ""){

		reviewerList = editDataForm.elements["ReviewersListOID"];
		approvalList = editDataForm.elements["ApprovalListOID"];
		
		if(typeof reviewerList == 'undefined' || reviewerList == ''){
			reviewerList = editDataForm.elements["ReviewerListOID"];
		}
		
		if(typeof reviewerList != 'undefined' && reviewerList != '' && reviewerList.value != ''){
			reviewerListOid = reviewerList.value;
		}
		
		if(typeof approvalList != 'undefined' && approvalList != '' && approvalList.value != ''){
			approvalListOid = approvalList.value;
		}
		
		if(reviewerListOid != "" && approvalListOid != "" && reviewerListOid == approvalListOid){
			var errormessage="<emxUtil:i18nScript localize="i18nIdn">EnterpriseChangeMgt.Alert.SameReviewerApprovalListRouteTemplateCO</emxUtil:i18nScript>";
		   	alert(errormessage);
		   	return false;
		}	
	}
    return true;
}

</script>

