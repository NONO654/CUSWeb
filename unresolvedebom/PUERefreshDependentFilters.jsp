<%--  PUERefreshDependentFilters.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "../engineeringcentral/emxDesignTopInclude.inc"%>
<%@ page import="com.matrixone.apps.unresolvedebom.UnresolvedEBOMConstants" %>

<%
out.clear();
String language = request.getLocale().getLanguage();
Locale Local = context.getLocale();
response.setContentType("text/javascript; charset=" + response.getCharacterEncoding()); 
/*String sChangeViewCurrent = i18nNow.getI18nString("emxUnresolvedEBOM.BOMPowerView.ChangeView.Current","emxUnresolvedEBOMStringResource",language);
String strNone = i18nNow.getI18nString("emxUnresolvedEBOM.Default.None","emxUnresolvedEBOMStringResource",language);
String strAll = i18nNow.getI18nString("emxUnresolvedEBOM.UnitRangeNotation.AllUnits.Text","emxUnresolvedEBOMStringResource",language);
String alertEmpty = i18nNow.getI18nString("emxUnresolvedEBOM.ValidateRange.NoneOrEmpty","emxUnresolvedEBOMStringResource",language);
String alertUpdate = i18nNow.getI18nString("emxUnresolvedEBOM.Edit.checkOnPendingChange","emxUnresolvedEBOMStringResource",language);
String alertECO = i18nNow.getI18nString("emxUnresolvedEBOM.Select.WorkUnderChange","emxUnresolvedEBOMStringResource",language);*/
String sChangeViewCurrent = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource",Local,"emxUnresolvedEBOM.BOMPowerView.ChangeView.Current");
String strNone = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource",Local,"emxUnresolvedEBOM.Default.None");
String strAll = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource",Local,"emxUnresolvedEBOM.UnitRangeNotation.AllUnits.Text");
String alertEmpty = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource",Local,"emxUnresolvedEBOM.ValidateRange.NoneOrEmpty");
String alertUpdate = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource",Local,"emxUnresolvedEBOM.Edit.checkOnPendingChange");
String alertECO = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource",Local,"emxUnresolvedEBOM.Select.WorkUnderChange");
String alertIntersectUpdate = i18nStringNowUtil("emxUnresolvedEBOM.Edit.EffectivityMatch","emxUnresolvedEBOMStringResource", language);
String quantityCanNotBeModified = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource",Local,"emxUnresolvedEBOM.validate.QuantityCanNotBeModified");
String quantityCanNotBeDecimal = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource",Local,"emxUnresolvedEBOM.validate.QuantityCanNotBeDecimal");
String uomCanNotBeModified = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource",Local,"emxUnresolvedEBOM.validate.UOMCanNotBeModified");
String uomCanNotBeModifiedWithMoreQuantity = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOMStringResource",Local,"emxUnresolvedEBOM.validate.UOMCanNotBeModifiedWithMoreQuantity");
String rangeEAeach = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource", Local, "emxFramework.Range.Unit_of_Measure.EA_(each)");

String strCyclicDependency = i18nStringNowUtil("emxUnresolvedEBOM.CommonView.Alert.Cyclicdependency","emxUnresolvedEBOMStringResource", language);
//2012
//String isWipBomAllowed = FrameworkProperties.getProperty("emxUnresolvedEBOM.WIPBOM.Allowed");
//String isWipBomAllowed = EnoviaResourceBundle.getProperty(context,"emxUnresolvedEBOM.WIPBOM.Allowed");
//2012
%>
                        
var PUEUEBOMChangeViewFilter = {"ClearCommands":[{"name":"PUEUEBOMECOFilter"}]                              
                                };
var PUEUEBOMProductConfigurationViewFilter = {"ClearCommands":[{"name":"PUEUEBOMProductConfigurationFilter"}]                              
                                };

var PUEUEBOMECOFilter = {"ClearCommands":[{"name":"PUEUEBOMMODFilter"}]                     
                        };

var PUEUEBOMChangeViewFiltersReset = {"ResetCommands":[{"name":"PUEUEBOMECOFilter"}],
                                    "ResetValue":""
                                    };
var PUEUEBOMProductConfigurationViewFiltersReset = {"ResetCommands":[{"name":"PUEUEBOMProductConfigurationFilter"}],
                                    "ResetValue":""
                                    };
//XSSOK                                    
var sNone = "<%=strNone%>";
//XSSOK
var sAlertEmpty = "<%=alertEmpty%>";
//XSSOK
var sAll = "<%=strAll%>";
                                    
//<%
//String fnDisplayLeadingZeros = JSPUtil.getCentralProperty(application, session,"emxEngineeringCentral","FindNumberDisplayLeadingZeros");
//%>

    // Attach onload event to the window, If context part is unresolved
    var isUnresolved = this.location.href.indexOf("&policy=Unresolved&") > -1 //2011x
    var isCopyFrom = this.location.href.indexOf("&From=CopyFrom&") > -1
    //2011x - Starts
    if(isUnresolved){
    //2011x - Ends
        attachEventHandler(window, "resize", refreshFilters);
    }

    function refreshFilters(){
        //Once Toolbar is loaded, load them with initial values
        setTimeout(initialProcessing,100);        
    }

    /*
    * This function loads product filter with initial value
    */
    function initialProcessing(){
        if(uiType=="structureBrowser" && typeof objectId != "undefined" 
            && objectId.length!=0)
        {   
            if(isCopyFrom){
                processCopyFrom();
            }
            checkChangeViewStatus();
        }
    }

    /*
    * This function is invoked when called from copy from operation
    */
    function processCopyFrom(){ 
        var changeView = document.getElementById("PUEUEBOMChangeViewFilter");
        for(var i=0; i < changeView.options.length; i++) {
            if(changeView.options[i].value == 'Current'){
                changeView.selectedIndex = i;
                break;
            }
        }
        //checkChangeViewStatus();    
        // change order of toolbars because one toolbar is not displayed in copyfrom
        var changeView = getTopWindow().document.getElementById("PUEUEBOMChangeViewFilter").value;
        var ECOFilter  = jQuery("#PUEUEBOMContextChangeFilter",getTopWindow().document).parent().parent();        
        disableCommand(changeView);  
        disableCommand(ContextChangeFilterInCopyFrom);        
    }

    /*
    * This function sets ID passed in the URL to hidden field
    * Name of hidden field should be passed here
    */
    function setActualValue(fieldName){
        var paramStart = this.location.href.indexOf('&'+fieldName+'='); 
        var valueStart = this.location.href.substring(paramStart).indexOf('='); 
        var valueEnd = this.location.href.substring(paramStart+1).indexOf('&'); 
        var Id = this.location.href.substring(paramStart+valueStart+1,valueEnd+paramStart+1);
        document.getElementById(fieldName).value = Id;
    }

    /*
    * This function disables ECO Filter, when change view is set to Current or release
    */
    function checkChangeViewStatus(){
        var changeView = getTopWindow().document.getElementById("PUEUEBOMChangeViewFilter").value;
        var ECOFilter  = jQuery("#PUEUEBOMECOFilter",getTopWindow().document).parent().parent();
        
        //Checking for Current value
        if(changeView == 'Current'){
            clearValues('PUEUEBOMChangeViewFilter');             
            disableCommand(ECOFilter); 
                
        } else if(changeView != 'Current'){            
            enableCommand(ECOFilter);
        }
    }



 function enableCommand(cmdName){ 
			var element = jQuery(cmdName);
			element.removeClass('disabled');
			element.addClass('enabled');
			jQuery(":input",element).removeAttr('disabled');			
    }
 
 function disableCommand(cmdName){
		var element = jQuery(cmdName);
		element.removeClass('enabled');
		element.addClass('disabled');
		jQuery(":input",element).attr('disabled','true');		
   }
   



    /*
    * This function clears filters along with their actual value
    */
    function clearValues(field){
        var commandToBeCleared = eval(field+'.ClearCommands');
        for(var index=0; index<commandToBeCleared.length; index++) {
            var displayName = document.getElementById(commandToBeCleared[index].name);
            var displayActual = document.getElementById(commandToBeCleared[index].name+'_actualValue');
            //371841 Starts
            if(displayName != null && displayActual != null  ){
            //371841 Ends
                document.getElementById(commandToBeCleared[index].name).value = "";
                document.getElementById(commandToBeCleared[index].name+'_actualValue').value = "";
            }
        }
    }

    /*
    * This function assign reset values to respective filters
    */
    function resetValues(field){
        var commandToBeReset = field.ResetCommands;
        var resetValue = field.ResetValue;
        for(var index=0; index<commandToBeReset.length; index++) {      
            getTopWindow().document.getElementById(commandToBeReset[index].name).value = resetValue;
            getTopWindow().document.getElementById(commandToBeReset[index].name+'_actualValue').value = resetValue;
        }
    }

    /*
    * This function disables all PUE filters except product filter and context change filter
    */
    function disableOrEnableSlaveCommands(disable){
        if(!isCopyFrom){
            for(var toolbarIndex=0; toolbarIndex<toolbars.length; toolbarIndex++)
            {
                var currentToolbar = toolbars[toolbarIndex];                        
                if(toolbarIndex == 4 || toolbarIndex == 5 || toolbarIndex == 6)
                {
                    for(var itemIndex=0; itemIndex<currentToolbar.items.length; itemIndex++){
                        var toolbarCurrentItem = currentToolbar.items[itemIndex];           
                        if (toolbarCurrentItem.formFieldName != 'PUEUEBOMContextChangeFilter')
                        {
                            disableOrEnableHTMLElement(toolbarCurrentItem, disable);
                        }
                    }
                }
            }
        }
    }


    function isActionAllowed() {
	    
	     if(arguments[1] == "lookup" && arguments[0] == "")
	    {
	        return true;
	    }
	    var status = currentRow.getAttribute("status");
	    //Incase of adding parts context change validation is not required,but at non wip bom case post Process JPO is handling this validation.
	    if (status == "add" || status == "new") {
	    	return true;
	    }
        var contextECOName = getTopWindow().document.getElementById("PUEUEBOMContextChangeFilter").value;
        var addColumnValue = "";
        var valInitialRelease = "";
        var isWipBomAllowed = "";
        //2012x--Starts
        var parentRowID = this.currentRow.parentNode != null?this.currentRow.parentNode.getAttribute("id"):"";
        var parentStateObj = parentRowID != ""?emxEditableTable.getCellValueByRowId(parentRowID,"State"):"";
        var parentReleasePhaseAttrib = parentRowID != ""?emxEditableTable.getCellValueByRowId(parentRowID,"ReleaseProcess"):"";
        var parentReleasePhase = parentRowID != ""?parentReleasePhaseAttrib.value.current.actual:"";
        if(parentReleasePhase == "<%=EngineeringConstants.DEVELOPMENT%>")
        {
       		 isWipBomAllowed = "true";
        }else{
      	 	 isWipBomAllowed = "false";
        }
        
        var parentState = parentRowID != ""?parentStateObj.value.current.actual:"";
        //XSSOK
        if (isWipBomAllowed.toLowerCase()=="false")
        {
         if(colMap.getColumnByName("InitialRelease")) {
	    	valInitialRelease = getValueForColumn("InitialRelease");
	   		 }
            //if (contextECOName == "" && parentState=="<%=UnresolvedEBOMConstants.STATE_PART_RELEASE%>") {
            if (contextECOName == ""){
            //XSSOK
                alert("<%=alertECO%>");
                return false;
            }else {//if (parentState=="<%=UnresolvedEBOMConstants.STATE_PART_PRELIMINARY%>") {
                return true;
            }
         }
         
          if (isWipBomAllowed.toLowerCase()=="true") {
                return true;
         } 
         <%-- if (isWipBomAllowed.toLowerCase()== "false" && contextECOName == "") {
         //XSSOK
                alert("<%=alertECO%>");
                return false;
         }   --%>
        //2012x--Ends
         if(contextECOName == addColumnValue || addColumnValue == valInitialRelease) {
            allowModify = "true";
        } else {
            var selPartId = this.currentRow.getAttribute("o");
            var relId = this.currentRow.getAttribute("r");
            var contextECOId = getTopWindow().document.getElementById("PUEUEBOMContextChangeFilter_actualValue").value;
            if (contextECOId == "") {
            //XSSOK
                alert("<%=alertECO%>");
                return false;
            }
            var allowModify = emxUICore.getData("../unresolvedebom/CheckUpdateAttributes.jsp?contextECOId="+contextECOId+"&selPartId="+selPartId+"&relId="+relId);
            if(allowModify.indexOf("false") != -1) {
            //XSSOK
                alert("<%=alertUpdate%>");
                return false;
            } else if(allowModify.indexOf("alert") != -1){
            //XSSOK
                alert("<%=alertECO%>");
                return false;
            } else if (allowModify.indexOf("cyclic") != -1) {
            //XSSOK
	                alert("<%=strCyclicDependency%>");
	                return false;
            	} else if (allowModify.indexOf("Intersect") != -1) {
            	//XSSOK
                alert("<%=alertIntersectUpdate%>");
                return false;
            }
        }
        return true;
    }


    function validateFindNumber() {
        if(arguments[1] == "lookup" && arguments[0] == "")
    {
        return true;
    }
       return isActionAllowed() ? validateFNByLevel(arguments[0]) : false;
    }

    function validateRefDes() {

	     if(arguments[1] == "lookup" && arguments[0] == "")
	    {
	        return true;
	    }
        return isActionAllowed() ? validateRDByLevel(arguments[0]) : false;
        
    }
    
     function validateUOM() {

	    var sUOMValue    = trim(arguments[0]);
	    var sQtyValue = getValueForColumn("Quantity");
	    var status = currentRow.getAttribute("status");
	    <!-- XSSOK -->
	    if(sQtyValue % 1 != 0 && sUOMValue == "<%=rangeEAeach%>"){
	      <!-- XSSOK -->
     		alert("<%=uomCanNotBeModified %>");
     		return false;
     	}
     	   <!-- XSSOK -->
     	else if(status != "add" && status != "new" && sQtyValue > 1 && sUOMValue == "<%=rangeEAeach%>"){
     		<!-- XSSOK -->
     		alert("<%=uomCanNotBeModifiedWithMoreQuantity %>");
     		return false;
     	}
     	return isActionAllowed()? true : false;
        
    }

    function validateQty() { 

       if(arguments[1] == "lookup" && arguments[0] == "")
                    {
                        return true;
                    }
                    var sUOMValue = getValueForColumn("UOM");
                    var status = currentRow.getAttribute("status");
                    <!-- XSSOK -->
                    if (status != "add" && status != "new" && sUOMValue == "<%=rangeEAeach%>") {
                        <!-- XSSOK -->
                                alert ("<%=quantityCanNotBeModified %>");
                                return false;
                    }
                    <!-- XSSOK -->
                    if((status == "add" || status == "new") && sUOMValue == "<%=rangeEAeach%>") {
                    	if(arguments[0] % 1 != 0){
                    	<!-- XSSOK -->
                    		alert("<%=quantityCanNotBeDecimal %>");
                    		return false;
                    	}
                    	
                    }
                    
        return isActionAllowed() ? validateQuantity(arguments[0]) : false;
        
    }
    function validateDesignCollaboration() { 

       if(arguments[1] == "lookup" && arguments[0] == "")
	    {
	        return true;
	    }
        return isActionAllowed() ? true : false;
        
    }
