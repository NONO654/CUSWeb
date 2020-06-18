<%--  emxProgramCentralUIFreezePaneValidation.jsp

   Copyright (c) 1999-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

 --%>
  <%@include file = "../emxContentTypeInclude.inc"%>
  <%@ include file="emxProgramTags.inc" %>
  <%@include file = "../emxUICommonAppInclude.inc"%>
  <%@page import="com.matrixone.apps.program.Task"%>
  <%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
  <%@page import="com.matrixone.apps.domain.DomainConstants"%>
  <%@page import="com.matrixone.apps.domain.DomainObject"%>
  <%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
  <%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
  <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
  <script src="../plugins/libs/jqueryui/1.10.3/js/jquery-ui.js"></script> 
<%
	String strmode = emxGetParameter(request, "strmode");
	String strSFDependencyType = Task.START_TO_FINISH;
	String strFFDependencyType = Task.FINISH_TO_FINISH;
	String strLanguage = context.getSession().getLanguage();
    String strI18Days = EnoviaResourceBundle.getProperty(context, "ProgramCentral","emxProgramCentral.DurationUnits.Days", strLanguage);
	String strI18Hours = EnoviaResourceBundle.getProperty(context, "ProgramCentral","emxProgramCentral.DurationUnits.Hours", strLanguage);
	
	boolean isENOGridActive = false;
	try {
		String gridVal = EnoviaResourceBundle.getProperty(context, "emxFramework.Activate.GridView");
		isENOGridActive = ProgramCentralUtil.isNotNullString(gridVal)?Boolean.valueOf(gridVal):false;
	} catch (FrameworkException e) {
		isENOGridActive = false;
	}
	
	strI18Days = strI18Days.toLowerCase();
	strI18Hours = strI18Hours.toLowerCase();
	
	 response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
	response.setHeader("Pragma", "no-cache");
	response.setDateHeader("Expires", (new java.util.Date()).getTime()); 
    
    	if(request.getQueryString() != null && !(request.getQueryString().isEmpty()) ) {
            response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
            response.setHeader("Pragma", "no-cache");
            response.setDateHeader("Expires", (new java.util.Date()).getTime());
        }else {
            response.setHeader("Cache-Control", "private,immutable, max-age="+String.valueOf(session.getMaxInactiveInterval()));
        }

	if ("checkIsSummaryTask".equalsIgnoreCase(strmode)) {
		String sTaskId = emxGetParameter(request, "taskId");
		boolean isSummaryTask = false;
		if (ProgramCentralUtil.isNotNullString(sTaskId)) {
			StringList busSelects = new StringList();
			busSelects.add(DomainConstants.SELECT_NAME);
			busSelects.add(DomainConstants.SELECT_ID);
			Task taskObj = new Task();
			taskObj.setId(sTaskId);
			MapList mlSubTaskList = taskObj.getTasks(context, taskObj,
					1, busSelects, null);
			if (null != mlSubTaskList && mlSubTaskList.size() > 0) {
				isSummaryTask = true;
			}
		}
		out.clear();
		out.write(String.valueOf(isSummaryTask));
		out.flush();
		return;
	} else if ("getForDep".equalsIgnoreCase(strmode)) {
		out.clear();
		String sParentTaskId = emxGetParameter(request, "taskId");
		Task task = new Task();
		boolean isToShowDependencyAlert = task.isToshowDependencyMessage(context, sParentTaskId);
		out.write(((Boolean) isToShowDependencyAlert).toString());
		out.flush();
		return;
	}
out.clear();
response.setContentType("text/javascript; charset=" + response.getCharacterEncoding());
String accLanguage  = request.getHeader("Accept-Language");
String strDefaultDependency = EnoviaResourceBundle.getProperty(context,"emxProgramCentral.KeyinDependency.Default");
%>
/**
* function validateQualityMetric(
* validate fields of Quality Metrics
*/
 
 function validateQualityMetric(obj)
{		
	if(!isNumeric(obj)){
		alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.ValueMustBeReal</emxUtil:i18nScript>");
		obj.value = "";
		return false;
	}
	else if (obj > 2147483647){		
		alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.ValueMustBeSmallerThan</emxUtil:i18nScript>");
		obj.value = "";
		return false;
	}else{
		return true;
	}
}

//Added to validate QualityMetric field DPU of Quality Metrics
 function validateQualityMetricDPU(obj)
{	
	if(!isNumeric(obj)){
		alert(arguments[2] +" "+"<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.ValueMustBeReal</emxUtil:i18nScript>");
		obj = "";
		return false;
	}else if (obj > 2147483647){		
		alert(arguments[2] +" "+"<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.ValueMustBeSmallerThan</emxUtil:i18nScript>");
		obj= "";
		return false;
	}else{
	    obj=Number(obj);
		return true;
	}
}
/**
* function validateTaskReq(
* Validate Task requirement Value for the change task
*/
function validateTaskReq() {
	var taskReq = arguments[0];
	var objectType = getActualValueForColumn("Type");
	if(objectType == "<%=com.matrixone.apps.domain.DomainConstants.TYPE_CHANGE_TASK %>" && taskReq == "Optional") {
		alert("<framework:i18nScript localize="i18nId">emxProgramCentral.EnterpriseChange.TaskRequirementMandatory</framework:i18nScript>");
		return false;
	}
	return true;
}

/*******************************************************************************/
/* function checkRepetativeDependancy()                                                 */
/* Checks if there are repetative depedancies for external Projet taskas and internal   */
/* project tasks, if YES then returns true                                              */
/*******************************************************************************/

function checkRepetativeDependancy(strEnteredDependancy){

			// ADDED FOR BUG : 355924

	     	var dependancies = strEnteredDependancy.split(',');
	     	var prevDepedencyIds = new Array();

			for(var i = 0; i < dependancies.length; i++) {
				var strIndividualDep = new Array();
				strIndividualDep = dependancies[i].split(':');

				var strCurrentDependecyId = "";

				if (strIndividualDep.length > 2) {
					// External task dependency
					strCurrentDependecyId = strIndividualDep[0] + ":" + strIndividualDep[1];
				}
				else {
					// Internal task dependency
					strCurrentDependecyId = strIndividualDep[0];
				}

				// Check if dependency on this task is already added?
				var isAlreadyPresent = false;
				for (var j = 0; j < prevDepedencyIds.length; j++) {
					if (prevDepedencyIds[j] == strCurrentDependecyId) {
						isAlreadyPresent = true;
						break;
					}
				}

				if (isAlreadyPresent) {
					//Error
					alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.InValidRepetitionDependency</framework:i18nScript>");
					return true;
				}
				else {
					prevDepedencyIds.push(strCurrentDependecyId);
				}
			}
			return false;

			// ADDED FOR BUG : 355924 ENDS
}

/*******************************************************************************/
/* function checkTransitiveDependancy()                                                 */
/* Checks if there is any transitive depedancy on Tasks   */
/*Cyclic & Transitive Dependency(i.e. A->B->A and A->B->C->A) */
/* if YES then returns false                                              */
/*******************************************************************************/
function checkTransitiveDependancy(strEnteredDependancy,currentCellIdValue,editatedRowId){
	var expectedRowId = "";
	if(<%=isENOGridActive%>){
		var matchedNode = emxEditableTable.getNodeFromAttribute("ID", strEnteredDependancy);
	    expectedRowId = emxEditableTable.getAttribute(matchedNode ,"rowId");
	} else {
		var table = document.getElementById("bodyTable");
	var tableRows = table.rows;
	
	var headerTable = document.getElementById("headTable");
	var headerRows = headerTable.rows;
	var cellInd = headerRows[2].cells["ID"].cellIndex;
	var IdCellIndex = cellInd/2;
	
	var i;
	for (i = 0, tableRows; tableRows = table.rows[i]; i++) {
	var cell = tableRows.cells[IdCellIndex];
	var cValue = cell.innerHTML;
	if(cValue === strEnteredDependancy){
				expectedRowId = cell.getAttribute("rmbrow");
			break;
		}
	}
	} 
	var expectedRow = emxEditableTable.getCellValueByRowId(expectedRowId,"Dependency");
		if(null!=expectedRow){
			var expectedValue = expectedRow.value.current.display;
			if(""!=expectedValue){
				 var allVals = expectedValue.split(",");
				 for(var i=0; i < allVals.length ; i++) {
				  var value = allVals[i].trim();
				  var returnDependencyArray = (value.split(":"));
				  var dep = returnDependencyArray[0];
				  if(dep==currentCellIdValue){
					var taskName = emxEditableTable.getCellValueByRowId(editatedRowId,"Name").value.current.display; 
					var errorUrl = "../programcentral/emxProgramCentralUtil.jsp?mode=errorMessageWithPlaceHolder&errorKey=emxComponents.Task.CircularDependancyDetected&msgValue="+taskName;
					var errorMessage = emxUICore.getData(errorUrl);
					alert(errorMessage);
					return false;
				  }else if(null!=dep){
				  checkTransitiveDependancy(dep,currentCellIdValue,editatedRowId);
				  }
		 	}
		}
	}
	return true;
}

/*******************************************************************************/
/* function validateDependancy()                                                 */
/* Validates the Dependency entered from indented table edit                     */
/*******************************************************************************/

function validateDependancy()
{
    var dependencyVal = arguments[0];
    var isValid = true;

    // ADDED FOR BUG : 355924
	//var IndividualDep = new Array();
	var tempExtProjTask = null;
	var tempIntProjTask = null;
	var Flags = false;
    // ENDS

	dependencyVal = dependencyVal.trim();
	
	var currCell = emxEditableTable.getCurrentCell();
	var cCellValue = currCell.value.old.display;
	var uid = currCell.rowID;

/* --------------------------- Validate circular dependency Start ---------------------------------- */
   
   	var allDepValues = dependencyVal.split(",");
   	var currentCellIdValue = emxEditableTable.getCellValueByRowId(uid,"ID").value.current.display;
   	 for(var j=0; j < allDepValues.length ; j++) {
   	    var valueDep = allDepValues[j].trim();
  		var getDepArray = (valueDep.split(":"));
  		if(getDepArray.length>1){
  		var dependencyNumber = getDepArray[0];	
  		
  	/*---------------------------- Validate self dependency--------------------------- */

		if(dependencyNumber==currentCellIdValue){
		var taskName = emxEditableTable.getCellValueByRowId(uid,"Name").value.current.display; 
		var errorUrl = "../programcentral/emxProgramCentralUtil.jsp?mode=errorMessageWithPlaceHolder&errorKey=emxComponents.Task.CircularDependancyDetected&msgValue="+taskName;
		var errorMessage = emxUICore.getData(errorUrl);
		alert(errorMessage);
		return false;
		}else{
	/*---------------------------- Validate Transitive dependency--------------------- */
		var noCirculatDependency = checkTransitiveDependancy(dependencyNumber,currentCellIdValue,uid);
		if(!noCirculatDependency){
		return false;
				}
			}
		}	
	}
	
/* ---------------------------- Validate circular dependency End ------------------------------------------ */

	var columnName = getColumn();
	var colName = columnName.name;
	
	if(<%=isENOGridActive%>){
	   colName = currCell.columnName;
	}
	
    if("" != dependencyVal){
  	  var dependencyJSONObj = parseDependencyString(dependencyVal); //Parse to proper format.
      dependencyVal=dependencyJSONObj.validationValue;
    }
    if(!isEmpty(dependencyVal))
    {
        //var regexp = /^(((\w+((\s\w+)+)?:)?\d+:[FSfs]{2}([\+\-]\d+(\.\d+)?\s[DdHh])?)(\,((\w+((\s\w+)+)?:)?\d+:[FSfs]{2}([\+\-]\d+(\.\d+)?\s[DdHh])?))*)?$/;
		var STR_DEC_SYM = "<%=FrameworkProperties.getProperty( "emxFramework.DecimalSymbol")%>";
		if(STR_DEC_SYM == ",")
		{
			var regexp = /^((([a-zA-Z0-9_-]+((\s\w+)+)?:)?\d+:[FSfs]{2}([\+\-]\d+(\,\d+)?\s[DdHh])?)(\,((\w+((\s\w+)+)?:)?\d+:[FSfs]{2}([\+\-]\d+(\,\d+)?\s[DdHh])?))*)?$/;
		}
		else
		{
        var regexp = /^((([a-zA-Z0-9_-]+((\s\w+)+)?:)?\d+:[FSfs]{2}([\+\-]\d+(\.\d+)?\s[DdHh])?)(\,((\w+((\s\w+)+)?:)?\d+:[FSfs]{2}([\+\-]\d+(\.\d+)?\s[DdHh])?))*)?$/;
 		}       
        isValid = regexp.test(dependencyVal.trim());
       
       if(isValid){
      dependencyVal = dependencyJSONObj.actualValue;
       }
       
        if(null==cCellValue){
            cCellValue = "";
        }
        if(!isValid) {
            emxEditableTable.setCellValueByRowId(uid,colName,cCellValue,cCellValue);
            alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.InValidProjectSpaceDependency</framework:i18nScript>");
            return false;
        }
        // ADDED FOR BUG : 355924
        else {
	     	var isAlreadyPresent = false;
	     	isAlreadyPresent = checkRepetativeDependancy(dependencyVal);
	     	if(isAlreadyPresent==true){
	     	return false;
	     	}
		}
		// ADDED FOR BUG: ENDS
		//Added for validate SF and FF dependency
		var tmpDependencyVal = dependencyVal.toUpperCase();
		if(tmpDependencyVal.indexOf("<%=strSFDependencyType%>") != -1 || tmpDependencyVal.indexOf("<%=strFFDependencyType%>") != -1) {
			var currentCellObj = emxEditableTable.getCurrentCell();
			if(currentCellObj != null) {
				var currentTaskObjectId = currentCellObj.objectid;
				var url="../programcentral/emxProgramCentralUIFreezePaneValidation.jsp?strmode=checkIsSummaryTask&taskId="+currentTaskObjectId;
				var vtest=emxUICore.getData(url);
				if(vtest.indexOf("true") != -1 ) {
					var nameColumnCurrCellObj = emxEditableTable.getCellValueByRowId(currentCellObj.rowID,"Name");
					var taskName = nameColumnCurrCellObj.value.current.display
					alert(" '<%=strSFDependencyType%>' and '<%=strFFDependencyType%>' "+"<framework:i18nScript localize="i18nId">emxProgramCentral.WBS.editDependency.errorMessage</framework:i18nScript> "+taskName);
					return false;
				}	
			}
		}
		//Added for validate SF and FF dependency End
    }
    
    emxEditableTable.setCellValueByRowId(uid,colName,dependencyVal,dependencyVal);
    return true;
}

/*******************************************************************************/
/* function parseDependencyString()                                            */
/* Adds default dependency if user enters just Task ID i.e. 1,2 = 1:FS,2:FS    */
/*******************************************************************************/

function parseDependencyString(dependencyVal){
	var returnDependencyArray = new Array("","");
    var defaultDependency = ":"+"<%=strDefaultDependency%>";
    var tempDepVal = new String(dependencyVal);
    var comma = ",";
    var isMultiple = tempDepVal.search(",");
    if("-1" == isMultiple){
    
        var isNumber = isNumeric(dependencyVal);
        if(isNumber){
            dependencyVal = tempDepVal+defaultDependency; 
            returnDependencyArray[0] = dependencyVal;
            returnDependencyArray[1] = dependencyVal;
        }else{
        returnDependencyArray[0] = tempDepVal;
        var occurenceOfChar = (tempDepVal.split(":").length - 1);
        if(occurenceOfChar ==2){
    		tempDepVal = "TestPRJ:"+tempDepVal.substring(tempDepVal.indexOf(":")+1,tempDepVal.length);
   		 }
   		 returnDependencyArray[1] = tempDepVal;
   		 
        }
        
    }else{
    
        var allVals = tempDepVal.split(",");
		for(var i=0; i < allVals.length ; i++) {
		    var value = trim(allVals[i]);
		    var isNumber = isNumeric(value);
		    if(isNumber){
			    allVals[i]=value+defaultDependency;
	            value = allVals[i];
		    }else{
		        var occurenceOfColloninVal = (value.split(":").length - 1);
			    if(occurenceOfColloninVal==2){
			   		value = "TestPRJ:"+ value.substring(value.indexOf(":")+1,value.length);
			   	}
	        }
	        if(i==0){
	        returnDependencyArray[0]=allVals[i];
	        returnDependencyArray[1] = value;
            }else{
            returnDependencyArray[0]+=comma+allVals[i];
            returnDependencyArray[1]+= comma+value;
            }
		}
		
        
    }
    var DepJSonStr = {"actualValue":returnDependencyArray[0] ,"validationValue":returnDependencyArray[1]};
    return DepJSonStr;
}
/*******************************************************************************/
/* function validateTemplateDependancy()                                                 */
/* Validates the Dependency entered from indented table edit                     */
/*******************************************************************************/

function validateTemplateDependancy()
{
    var dependencyVal = arguments[0];
    
    var currCell = emxEditableTable.getCurrentCell();
    var cCellValue = currCell.value.old.display;
    var uid = currCell.rowID;
    var columnName = getColumn();
    var colName = columnName.name;
    
    if(<%=isENOGridActive%>){
	   colName = currCell.columnName;
	}
    
    var flag="";
	dependencyVal = dependencyVal.trim();
	
	if("" != dependencyVal){
      var dependencyJSONObj = parseDependencyString(dependencyVal); //Parse to proper format.
      dependencyVal=dependencyJSONObj.validationValue;
    }
    
    if(!isEmpty(dependencyVal))
    {
        var STR_DEC_SYM = "<%=FrameworkProperties.getProperty( "emxFramework.DecimalSymbol")%>";
		if(STR_DEC_SYM == ",")
		{
			var regexp = /^((\d+:[FSfs]{2}([\+\-]\d+(\,\d+)?\s[DdHh])?)(\,(\d+:[FSfs]{2}([\+\-]\d+(\,\d+)?\s[DdHh])?))*)?$/;
		}
		else
		{
        	var regexp = /^((\d+:[FSfs]{2}([\+\-]\d+(\.\d+)?\s[DdHh])?)(\,(\d+:[FSfs]{2}([\+\-]\d+(\.\d+)?\s[DdHh])?))*)?$/;
 		}       
        flag = regexp.test(dependencyVal.trim());
        if(null==cCellValue){
            cCellValue = "";
        }
        if(!flag)
        {
            emxEditableTable.setCellValueByRowId(uid,colName,cCellValue,cCellValue);
            alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.InValidProjectTemplateDependency</framework:i18nScript>");
            return false;
        }
        // ADDED FOR BUG : 355924
        else {

	     	var isAlreadyPresent = false;
	     	isAlreadyPresent = checkRepetativeDependancy(dependencyVal);
	     	if(isAlreadyPresent==true){
	     	return false;
	     	}
		}
		// ADDED FOR BUG: ENDS
		//Added for validate SF and FF dependency
		var tmpDependencyVal = dependencyVal.toUpperCase();
		if(tmpDependencyVal.indexOf("<%=strSFDependencyType%>") != -1 || tmpDependencyVal.indexOf("<%=strFFDependencyType%>") != -1) {
			var currentCellObj = emxEditableTable.getCurrentCell();
			if(currentCellObj != null) {
				var currentTaskObjectId = currentCellObj.objectid;
				var url="../programcentral/emxProgramCentralUIFreezePaneValidation.jsp?strmode=checkIsSummaryTask&taskId="+currentTaskObjectId;
				var vtest=emxUICore.getData(url);
				if(vtest.indexOf("true") != -1 ) {
					var nameColumnCurrCellObj = emxEditableTable.getCellValueByRowId(currentCellObj.rowID,"Task Name");
					var taskName = nameColumnCurrCellObj.value.current.display
					alert(" '<%=strSFDependencyType%>' and '<%=strFFDependencyType%>' "+"<framework:i18nScript localize="i18nId">emxProgramCentral.WBS.editDependency.errorMessage</framework:i18nScript> "+taskName);
					return false;
				}
			}
		}
		//Added for validate SF and FF dependency End
    }
    
    emxEditableTable.setCellValueByRowId(uid,colName,dependencyVal,dependencyVal);
    return true;
}

/******************************************************************************/
/* function isValidNumeric() - checks whether the value is Valid numeric or not based on Current decimal symbol  */
/*                                                                            */
/******************************************************************************/

function isValidNumeric(varValue)
{
    
  	var decSymb 	= "<%=FrameworkProperties.getProperty( "emxFramework.DecimalSymbol")%>";
  	var isDot 		= varValue.indexOf(".") != -1;
  	var isComma 	= varValue.indexOf(",") != -1;
  	var result		= false;
  	
  	if(decSymb == "," && isComma && !isDot)
  		{
  			result= !isNaN( varValue.replace(/,/, '.') );
		} 
  	  	
  	if(decSymb == "." && isDot && !isComma)
  		{
  			result= !isNaN( varValue );
		} 
  	
  	if (decSymb == "." && !isComma && !isDot)
  		{
  			result= !isNaN( varValue );
  		}
  	
  	if (decSymb == "," && !isComma && !isDot)
  		{
  			result= !isNaN( varValue );
  		}
  	
  	return result;
}


/*******************************************************************************/
/* function validateDuration()                                                 */
/* Validates the Duration entered from indented table edit                     */
/*******************************************************************************/

function validateDuration()
{
    var durationVal = arguments[0];
    //Input unit can be "D" for day or "H" for hour, that needs to be converted to lowercase 
     durationVal = durationVal.toLowerCase();
     
    var STR_DECIMAL_SYM = "<%=FrameworkProperties.getProperty( "emxFramework.DecimalSymbol")%>";
    var Error1  =" <framework:i18nScript localize="i18nId">emxProgramCentral.Common.InvalidDuration</framework:i18nScript>";
    var Error2 = "<framework:i18nScript localize="i18nId">emxProgramCentral.Common.MustEnterAValidNumericValueForDuaration</framework:i18nScript>";
    var Error3 = "<framework:i18nScript localize="i18nId">emxProgramCentral.Common.CurrentDecimalSymbol</framework:i18nScript>";
    var errmsg =""+Error1+ Error2 +Error3+STR_DECIMAL_SYM;
     
    var days = "<%=strI18Days%>";
    var hours = "<%=strI18Hours%>";
      
    if(durationVal.indexOf(days) != -1){
    	durationVal = durationVal.replace(days,"d");
    } else if(durationVal.indexOf(hours) != -1) {
        durationVal = durationVal.replace(hours,"h");
    }
	/* flagValid=0 means the entered duration is valid Else its invalid*/
	var flagValid=0;

	/* The below condition will check if the entered duration contains Days / Hours. If not Its not a valid duration*/
    if(!durationVal.endsWith(' h') && !durationVal.endsWith(' d')&&!isValidNumeric(durationVal)){
		alert(errmsg);
		flagValid=1;
		return false;
	}
	else
	{
		if(durationVal.lastIndexOf(' d') != -1 ){
			durationVal = durationVal.substring(0,durationVal.lastIndexOf(' d'));
		}else if(durationVal.lastIndexOf(' h') != -1 ){
			durationVal = durationVal.substring(0,durationVal.lastIndexOf(' h'));
		}

	}

	
    if(durationVal != null)
    {
    
    		if(!isValidNumeric(durationVal))
		{
		alert(errmsg);
		return false;
		}
	
      if( isEmpty(durationVal) || durationVal == " ") {
        alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.InvalidDuration</framework:i18nScript>");
        return false;
      }
      
      
      var objectId = emxEditableTable.getCurrentCell().objectid;
	  var strURL = "../programcentral/emxProgramCentralUtil.jsp?mode=checkObjectPolicy&objectId="+objectId;
	  var responseTxt = emxUICore.getData(strURL);
	  var responseJSONObj = emxUICore.parseJSON(responseTxt);
	  var isSummaryTask = responseJSONObj["SummaryTask"];
	  var policyName = responseJSONObj["Policy"];
	  
	  	  
	  if("True" == isSummaryTask || "TRUE" == isSummaryTask){
		  	if(durationVal < 0){
		     alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.ValueMustBeNonNegavtive</framework:i18nScript>");
        return false;
      }
	  } else {
      
		  if(durationVal < 0 && "Project Review" == policyName){
		     alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.ValueMustBeNonNegavtive</framework:i18nScript>");
			 return false;
		  } else if(durationVal <= 0 && "Project Task" == policyName) {
        alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.ValueMustBeAPositiveReal</framework:i18nScript>");
        return false;
      }
	  }
       
	  
	  if(durationVal >=10000) {
		alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.PleaseEnterADurationValueLessThan</framework:i18nScript>");
		return false;
	  }
    }
    return true;
}


/******************************************************************************/
/* function isEmpty() - checks whether the value is blank or not              */
/*                                                                            */
/******************************************************************************/

function isEmpty(s)
{
  return ((s == null)||(s.length == 0));
}

/******************************************************************************/
/* function isNumeric() - checks whether the value is numeric or not          */
/*                                                                            */
/******************************************************************************/

function isNumeric(varValue)
{
    if (!isValidNumeric(varValue))
    {
        return false;
    } else {
        return true;
    }
}

/******************************************************************************/
/* function chkLength() - returns true is length of the text field             */
/* is below the specified length.                                              */
/******************************************************************************/

function chkLength(validLength,txtLength)
{
     return((validLength!=0 && txtLength.length>validLength));

}

 /******************************************************************************/
 /* function trim() - removes any leading spaces                               */
 /*                                                                            */
 /******************************************************************************/

/* function trim(str)
 {
	 if(str){
	 while(str.length != 0 && str.substring(0,1) == ' ')
	 {
        str = str.substring(1);
     }
     while(str.length != 0 && str.substring(str.length -1) == ' ')
     {
       str = str.substring(0, str.length -1);
     }
	return str;
    }
	   else if(str==""){
	       return "";
	   }
	   else{
	       return null;
	   }
 } */

/********************************************************************************* /
/* function isAlphaNumeric(string) - returns the valid format of alphaNumeric  */
/*   . It returns true if it is valid else false    */
/********************************************************************************/
function isAlphaNumeric(string)
{
    var format=string.match(/^[a-zA-Z]+[0-9]+$/g);
    if(format)
    {
      return true;
    }
    else
    {
      return false;
    }
    return true;
}

//Added:14-May-2010:s4e:R210 PRG:WBSEnhancement
function doValidationForPercentAllocation()
{
       var percentAllocation = arguments[0];
    
      if (!isValidNumeric(percentAllocation) || percentAllocation.length==0 )
      {
        alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Effort.UpdateAllocationValidNumber</emxUtil:i18nScript>");
        return false;
      } 
      else if (parseInt(percentAllocation,10) < 1 )
      {
        alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Effort.UpdateAllocationPositive</emxUtil:i18nScript>");
        return false;
      }
      else if (percentAllocation > 100)
      {
        alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Effort.UpdateAllocationLimit</emxUtil:i18nScript>");
        return false;
      }
      else
      {
        return true;       
      }
  
}
//End:14-May-2010:s4e:R210 PRG:WBSEnhancement-

/********************************************************************************* /
/* Allows only numbers from 0 to 1000
/********************************************************************************/

function doValForPerAllocTaskAssignmentMatrix()
{
       var percentAllocation = arguments[0];
    
      if (!isValidNumeric(percentAllocation))
      {
        alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Effort.UpdateAllocationValidNumber</emxUtil:i18nScript>");
        return false;
      } 
      else if (parseInt(percentAllocation,10) < 0 )
      {
        alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.TaskAssignment.UpdateAllocationPositive</emxUtil:i18nScript>");
        return false;
      }
      else if (percentAllocation > 1000)
      {
        alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Effort.UpdateAllocationLimit</emxUtil:i18nScript>");
        return false;
      }
      else
      {
        return true;       
      }
  
}

//Start:15-Oct-2010:ms9:R211 PRG:WBSEnhancement-
/********************************************************************************* /
/* function reloadRangeValues() - call reload function on cell edit of state column in WBS */
/*   . It returns true if it is valid else false    */
/********************************************************************************/
function reloadRangeValues()
{
    emxEditableTable.reloadCell("State");
}

function reloadTypeRangeValues()
{
    emxEditableTable.reloadCell("Type");
    emxEditableTable.reloadCell("Task Type");
    
}
//End:17-Nov-2010:NR2:R210:PRG:HF-081753V6R2011x_


function reloadTypeRangeValuesForTemplate()
{
    emxEditableTable.reloadCell("Task Type");
}

/********************************************************************************* /
/* function reloadTaskConstraintRangeValues() - call reload function on cell edit of Constraint Type column in WBS */
/*   . It returns true if it is valid else false    */
/********************************************************************************/
function reloadTaskConstraintRangeValues()
{
    emxEditableTable.reloadCell("ConstraintType");
}

//Added : 28-FEB-2011:MS9:R211:IR-093884  start
function reloadRangeValuesForResponse()
{
    emxEditableTable.reloadCell("Response");
}

//Added : 23-APR-2018:IR-566359-3DEXPERIENCER2019x 
function reloadValuesForResponse()
{
	var topFrame = findFrame(getTopWindow(), "PMCChecklist");
	
	if(topFrame){
       topFrame.refreshStructureWithOutSort();
    }
}
//Added : 28-FEB-2011:MS9:R211:IR-093884 end

/*******************************************************************************/
/* function validateEffortsOnADay()                                                 */
/* Validates the total efforts on Day                     */
/*******************************************************************************/

function validateEffortsOnADay()
{
   var effortVal = arguments[0];
   effortVal = trim(effortVal);

    var currCell = emxEditableTable.getCurrentCell();
	
	 if(currCell != null) {	
    var uid = currentCell.target.parentNode.getAttribute("id");
    var currCellLevel = currCell.level;
    var columnName = getColumn();
    var colName = columnName.name;
    var colIndex = columnName.index;
    var oldEffortValue = currCell.value.old.display;

    if(oldEffortValue.contains)
	var STR_DECIMAL_SYM = "<%=FrameworkProperties.getProperty( "emxFramework.DecimalSymbol")%>";
	
    if(STR_DECIMAL_SYM==".")
	{
    var regexp = /^\d*\.{0,1}\d+$/;
	}
	else
	{
	var regexp = /^\d*\,{0,1}\d+$/;
	}

    isValid = regexp.test(effortVal);
     if(!isValid)
     {
       alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.WeeklyTimeSheetReports.PMCPlzEntValNo</emxUtil:i18nScript>");
       emxEditableTable.setCellValueByRowId(uid,colName,oldEffortValue,oldEffortValue);
       return false;
     }

     if(currCellLevel == 2 && colName != "Total")  // change for detailed view and default view
    {
		 var currCellRowId = currCell.rowID;
		var imdParentRowId = emxEditableTable.getParentRowId(currCellRowId);
		var timesheetRowId = emxEditableTable.getParentRowId(imdParentRowId);

		var level = "2";
		var arrTaskChildren = emxEditableTable.getChildrenColumnValues(timesheetRowId,colName,level);
		var totalTasks =  arrTaskChildren.length;
		var totalEffortsForADay = 0.0;
        for(var m=0; m< totalTasks; m++)
        {
            var cell = arrTaskChildren[m];
            var nwEffortVal = cell.getAttribute("newA");
            var oldEffortVal = cell.getAttribute("a")

            if(nwEffortVal == null)
            {
                totalEffortsForADay = totalEffortsForADay + parseFloat(oldEffortVal);
            }
            else
            {
                totalEffortsForADay = totalEffortsForADay + parseFloat(nwEffortVal);
            }
        }

        if( (totalEffortsForADay > 24.0))
        {
	        alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.WeeklyTimeSheet.Effort.validateEffortEntry</emxUtil:i18nScript>");
	        emxEditableTable.setCellValueByRowId(uid,colName,oldEffortValue,oldEffortValue);
	        return false;
        }
    }
}
    return true;
}

/*******************************************************************************/
/* function validateCost()                                                 */
/* Validates the input cost and benefit values */
/*******************************************************************************/

function validateCost()
{
   var costVal = arguments[0];
    if(costVal != null){
      if((costVal).substr(0,1) == '-'){ 
        alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.ValueMustBeNonNegavtive</framework:i18nScript>");
        return false;
      }
      if(costVal.indexOf("#") != -1){
        alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.ValueMustBeNonNegavtive</framework:i18nScript>");
        return false;
      }else{      0
        var url = "../programcentral/emxProgramCentralUtil.jsp?mode=validateCost&costValue="+costVal;
        var responseText = emxUICore.getData(url);
   	    var responseJSONObject = emxUICore.parseJSON(responseText);
	    for (var key in responseJSONObject){
		 if(key=="isValidCurrency" && responseJSONObject[key]=="false"){
			 alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.ValueMustBeNonNegavtive</framework:i18nScript>");
             return false;
		 }
        }
        return true;
      }
   }
}
/*Reload Percentage value for policy specific */
function reloadPercentValues()
{
    emxEditableTable.reloadCell("Complete");
}
/*******************************************************************************/
/* function validateNumberofPerson()                                                 */
/* Validates the input FTE values */
/*******************************************************************************/
function validateNumberofPersonSB(){
    var NumberofPersonvalue = arguments[0];
    if(!isValidNumeric(NumberofPersonvalue)|| (parseFloat(NumberofPersonvalue,10) < 0 )){
       alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Validate.ValidatePeople</framework:i18nScript>");
       return false;
    }else{
       return true;    
     }
}

//Deprecated. Please use validateNumberofPersonSB for Structur Browser validations 
function validateNumberofPerson(){
    var NumberofPersonvalue = arguments[0];
    if(!isValidNumeric(NumberofPersonvalue)|| (parseFloat(NumberofPersonvalue,10) < 0 )){
       alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Validate.ValidatePeople</framework:i18nScript>");
       return false;
    }else{
       return true;    
     }
}

/*******************************************************************************/
/* function validLagTime()                                                     */
/* Validates the input for Slack Time column.                                  */
/*******************************************************************************/

 function validLagTime(obj)
 {
  	lagTime = obj.value;
 	var lagString = new String(lagTime);
 	if (lagTime != "" )
 	{
 	if (!isValidNumeric(lagTime))
 	{
 	alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.DependancyNumbersOnly</emxUtil:i18nScript>");
	obj.value = "";
 	return true;
 	}
 	} 
 	return false;
 }
/*******************************************************************************/
/* function validateDependancy()                                                 */
/* Populate DurationUnit(Slack Time) On change of Duration Keyword*/
/*******************************************************************************/



 function populateDurationUnit(checkBoxValue)
    {
       	var durationKeyword = "durationKeyword_"+checkBoxValue;
    	var lag = "lag_"+checkBoxValue;
        var unit = "unit_"+checkBoxValue;
        var durationKeywordVal = document.getElementById(durationKeyword).value;
        if(durationKeywordVal!="NotSelected")
        {
            var temp = new Array();
            temp = durationKeywordVal.split('|');
            document.getElementById(lag).value = temp[1];
            document.getElementById(unit).value = temp[2];
        }
        else
        {
        	document.getElementById(lag).value = "";
        }
    }
	
	/*******************************************************************************/
/* function validateConstraintType()                                                     */
/* Validates the input for constraint type in PMCWBSViewTable for planning view.         */
/*******************************************************************************/
 function validateConstraintType()
{
 	
 	var currCell = emxEditableTable.getCurrentCell();
 	if(!currCell)
 	{
 	return true;
 	}
 	var sCurrentConstraintTypeValue = currCell.value.current.actual;
    var sRowID = currCell.rowID;
    var colName = currCell.columnName;
	var sColumnName = "Constraint Date";
   	var sConstraintDate = emxEditableTable.getCellValueByRowId(sRowID,sColumnName);
   	var sContraintDateValue = sConstraintDate.value.current.display;
   	sContraintDateValue = trim(sContraintDateValue);
   	   	var sConstraintTypeASAP = "As Soon As Possible";
   	var sConstraintTypeALAP = "As Late As Possible";
   	var sConstraintTypeFNET = "Finish No Earlier Than";
   	var sConstraintTypeFNLT = "Finish No Later Than";
   	var sConstraintTypeMSON = "Must Start On";
   	var sConstraintTypeMFON = "Must Finish On";
   	var sConstraintTypeSNET = "Start No Earlier Than";
   	var sConstraintTypeSNLT = "Start No Later Than";
   	var startDateColName = "PhaseEstimatedStartDate";
   	var finishDateColName = "PhaseEstimatedEndDate";
   	var startDate = emxEditableTable.getCellValueByRowId(sRowID,startDateColName);
   	var startDateDisplayValue = startDate.value.current.display;
   	
   	var finishDate = emxEditableTable.getCellValueByRowId(sRowID,finishDateColName);
   	var finishDateDisplayValue = finishDate.value.current.display;

   	if(sConstraintTypeMSON == sCurrentConstraintTypeValue || sConstraintTypeSNET == sCurrentConstraintTypeValue || sConstraintTypeSNLT == sCurrentConstraintTypeValue)
   	{
   		if(sContraintDateValue == "" || sContraintDateValue==finishDateDisplayValue){
   			emxEditableTable.setCellValueByRowId(sRowID,sColumnName,startDateDisplayValue,startDateDisplayValue);
   		}
   	}
   	else if(sConstraintTypeFNET == sCurrentConstraintTypeValue || sConstraintTypeFNLT == sCurrentConstraintTypeValue || sConstraintTypeMFON == sCurrentConstraintTypeValue)
   	{
   		if(sContraintDateValue == "" || sContraintDateValue==startDateDisplayValue ){
   			emxEditableTable.setCellValueByRowId(sRowID,sColumnName,finishDateDisplayValue,finishDateDisplayValue);
   		}
   	}
   	else if((sConstraintTypeASAP == sCurrentConstraintTypeValue || sConstraintTypeALAP == sCurrentConstraintTypeValue) && !(sContraintDateValue == ""))
   	{
   		emxEditableTable.setCellValueByRowId(sRowID,sColumnName,"","");
   	}

   	return true;
}


function isBadNameCharsSB(){
    var fieldValue = arguments[0];
    var hastabs = hasTabChar(fieldValue);
	if(hastabs){
		alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.InvalidCharacters</framework:i18nScript>" + "\n" + "tab");
       	return false;
	}
    var url = "../programcentral/emxProgramCentralUtil.jsp?mode=getBadChars";
   	var responseText = emxUICore.getData(url);
   	var responseJSONObject = emxUICore.parseJSON(responseText);
	var sBadChars = "";
	for (var key in responseJSONObject){
		sBadChars = responseJSONObject[key]; 
		break;
	}
   	var ARR_NAME_BAD_CHARS = sBadChars.split(" ");
   	var sValue = arguments[0];
	var strBadChars  = "";

    for (var i=0; i < ARR_NAME_BAD_CHARS.length; i++){
		if (fieldValue.indexOf(ARR_NAME_BAD_CHARS[i]) > -1){
           	strBadChars += ARR_NAME_BAD_CHARS[i] + " ";
        }
	}		
    if (strBadChars.length > 0){
    	alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.InvalidCharacters</framework:i18nScript>" + " " + strBadChars);
       	return false;
	}else{
		return true;
	}                        
}

function hasTabChar(nameString) {
  var regExp = /\t/;
  return regExp.test(nameString);
 }

//Deprecated. Please use isBadNameCharsSB for Structur Browser validations.
function isBadNameChars(){
	    var fieldValue = arguments[0];
<%
    String emxNameBadChars = EnoviaResourceBundle.getProperty(context, "emxFramework.Javascript.NameBadChars");
	emxNameBadChars = emxNameBadChars.trim();
%>
	    var STR_NAME_BAD_CHARS = "<%= emxNameBadChars %>";
		var ARR_NAME_BAD_CHARS = "";
		if (STR_NAME_BAD_CHARS != "") 
		{    
		  ARR_NAME_BAD_CHARS = STR_NAME_BAD_CHARS.split(" ");   
		}
		var strBadChars  = "";
	    for (var i=0; i < ARR_NAME_BAD_CHARS.length; i++) 
        {
            if (fieldValue.indexOf(ARR_NAME_BAD_CHARS[i]) > -1) 
            {
            	strBadChars += ARR_NAME_BAD_CHARS[i] + " ";
            }
        }		
        if (strBadChars.length > 0) 
        {
        	alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.InvalidCharacters</framework:i18nScript>" + " " + STR_NAME_BAD_CHARS);
        	return false;
        }                        
		return true;
}

 function validateRPN()
{
 var contentFrame   = findFrame(getTopWindow(),"PMCProjectRisk");
	var fieldValue = arguments[0];
 	var currCell = contentFrame.emxEditableTable.getCurrentCell();
 	 if(currCell!=null){
    var sRowID = currCell.rowID;
    var sImpactColumnName = "Impact";
    var sProbabilityColumnName = "Probability";
    var sRPNColumnName = "RisksRPN";
   	var sImpact = contentFrame.emxEditableTable.getCellValueByRowId(sRowID,sImpactColumnName);
	var sProbabilty = contentFrame.emxEditableTable.getCellValueByRowId(sRowID,sProbabilityColumnName);
	var sRPNOldValue = contentFrame.emxEditableTable.getCellValueByRowId(sRowID,sRPNColumnName);

// FUN071553 - NX5 - changed from display to actual
	var sImpactValue = sImpact.value.current.actual;
	var sProbabiltyValue = sProbabilty.value.current.actual;
        var sRPN = parseFloat(sImpactValue) * parseFloat(sProbabiltyValue);
	emxEditableTable.setCellValueByRowId(sRowID,sRPNColumnName,sRPN,sRPN,true);
	}
	return true;
}

function validateKeywordDuration()
{
    var contentFrame   = findFrame(getTopWindow(),"PMCKeywordDuration");
	var fieldValue = arguments[0];
 	var currCell = contentFrame.emxEditableTable.getCurrentCell();
    var sRowID = currCell.rowID;
	var theDuration = fieldValue;
    var ColumnName = "Type";
   	var sValue = contentFrame.emxEditableTable.getCellValueByRowId(sRowID,ColumnName);
	var DurationMapValue = sValue.value.current.display;
  if (((!(/^[+]?[0-9]+(\.[0-9]*)?$/.test(fieldValue)))) && DurationMapValue!="SlackTime" ||
	             ((!(/^[+-]?[0-9]+(\.[0-9]*)?$/.test(fieldValue)) && DurationMapValue=="SlackTime")))
      {
        alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Task.PleaseEnterOnlyNumbers</framework:i18nScript>");
        return false;
      }

       if (theDuration != "" && theDuration >= 10000)
        {
            alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.PleaseEnterADurationValueLessThan</framework:i18nScript>");
            return false;
        }
    return true;
}
	/*******************************************************************************/
/* function isGateApproved()                                                     */
/* Validates the input for constraint type in PMCWBSViewTable for planning view.         */
/*******************************************************************************/
 var isAlreadyCalled = false;
 function isGateApproved()
{
	var currCell = emxEditableTable.getCurrentCell();
 	if(!currCell){
 		return true;
 	}
    var sRowID 		= currCell.rowID;
    var colName 	= currCell.columnName;
    var type 		= currCell.type
    var colValue 	= currCell.value.old.display;
   
    if(colValue == null || colValue == ""){
    	return true;
    }
    
    if(colValue != null && colValue != ""){
    	colValue = colValue.trim();
    }
    
    if("Phase" != type && "Task" != type && "Milestone" != type && !colValue){
	    var objectId = emxEditableTable.getCurrentCell().objectid;
		var strURL = "../programcentral/emxProgramCentralUtil.jsp?mode=GateApproved&objectId="+objectId;
		var responseTxt = emxUICore.getData(strURL);
		var responseJSONObj = emxUICore.parseJSON(responseTxt);
		var action = responseJSONObj.Action;
		
		if(action === "stop"){
			var msg = responseJSONObj.Error;
			alert(msg);
			
			var rows = emxUICore.selectNodes(postDataXML, "/mxRoot//object[@rowId = '" + sRowID + "']");
			var row = emxUICore.selectSingleNode(postDataXML, "/mxRoot//object[@rowId = '" + sRowID + "']");
			var modifiedCols = row.childNodes;
			if(modifiedCols.length == 1){
				var modifiedcol = modifiedCols[0]; 
				row.removeChild(modifiedcol);
				row.removeAttribute("markup");
			}
			
			if(rows.length == 1 && modifiedCols.length == 0){
				postDataXML.loadXML("<mxRoot/>");
			}
			
			var objColumn 	= colMap.getColumnByName(colName);
			var columnIndex = objColumn.index -1;
			
			var oXMLRow = emxUICore.selectSingleNode(oXML,"/mxRoot/rows//r[@id='"+sRowID+"']");

			var childNodes = oXMLRow.childNodes;
			childNodes[columnIndex].removeAttribute("edited");
			childNodes[columnIndex].setAttribute("date", '');
			childNodes[columnIndex].setAttribute("newA",'');
			childNodes[columnIndex].setAttribute("msValueNew", '');
			childNodes[columnIndex].setAttribute("d",'');
			emxUICore.setText(childNodes[columnIndex],'');
			
			if(modifiedCols.length == 0){
				oXMLRow.removeAttribute("status");
				oXMLRow.removeAttribute("edited");
			}
			//RefreshView();
			rebuildView(false);
			
	   		return false;
		}
    }
   	
	return true;
}



function loadDialog(url,title,closeTitle){

    var div = document.createElement("div");
	div.id= "divPhaseGateViewDialog";
	div.style.overflow = "hidden";
	div.innerHTML = '<iframe style="border:1px solid #BCBCBC; width:100%" src=' + url + ' />';
	window.document.body.appendChild(div);
	//var pgv_list_frame = window.parent.parent.document.getElementById("pageContentDiv");
	//var width = $(pgv_list_frame).width();
	var width = findFrame(getTopWindow(), "content").outerWidth;
	width = width * 0.70;
	//var width = 700;
	
	window.$("#divPhaseGateViewDialog").dialog({
		autoOpen: true,
		height: 550,
		width: width,
		modal: true,
		show: {
	        duration: 200
	    },
  	        hide: {
	        duration: 200
	      },
	    close: function(event, ui) {
	    	//document.onresize = null;
	    	window.$("#divPhaseGateViewDialog").remove();
        }
	}).dialog("widget");
	
	//Change the Close button icon
	window.$(".ui-dialog-titlebar-close").attr("title",closeTitle).css('background-image', 'url(../common/images/iconActionClosePanel.png)');
	window.$(".ui-widget-header").css('background-color', 'white');
	window.$(".ui-widget-header").css('border', '0px solid');
	window.$(".ui-dialog-title").text(title);
	
	
	/*$(window).resize(function(){
		var width = $(pgv_list_frame).width();
		width = width * 0.80;
	});*/
			
}


//method to check whether name contains BadChar or not and also maximum length allowed for name
function isValidName() {
	var fieldValue = arguments[0];
	
	if(!isBadNameCharsSB(fieldValue)){
		return false;
	}
	if(!checkForNameLength128(fieldValue,false)){
    	alert("<%=EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource",
                    new Locale(request.getHeader("Accept-Language")),"emxFramework.Create.NameColumn")%>");
		return false;
	}
	
	return true;
}

function setScopListVal(){
	var currCell = emxEditableTable.getCurrentCell();
 	if(!currCell){
 		return true;
 	}
	var sRowID = currCell.rowID;
    var colName = currCell.columnName;
	var sColumnName = "CSSCCreateAssemblyShipType";
   	var shipType = emxEditableTable.getCellValueByRowId(sRowID,sColumnName);
	var shipVal = shipType.value.current.display;
	var scopeList = emxEditableTable.getCellValueByRowId(sRowID,"CSSCCreateAssemblyShipScope");
	
	
	
}


