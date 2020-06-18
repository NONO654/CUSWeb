<%--  emxTableEditHeaderHiddenProcess.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTableEditHeaderHiddenProcess.jsp.rca 1.12 Wed Oct 22 15:48:52 2008 przemek Experimental przemek $
--%>

<html>
<head>
    <title>Table Form processing</title>
    <script language="JavaScript" src="scripts/emxUICore.js" type="text/javascript"></script>
    <script language="JavaScript" src="scripts/emxUIConstants.js" type="text/javascript"></script>
    <script language="javascript" src="scripts/emxUIModal.js"></script>
</head>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%
        String strSelectOne = UINavigatorUtil.getI18nString("emxFramework.Common.PleaseSelectitem", "emxFrameworkStringResource", Request.getLanguage(request));
        String invaliddate = UINavigatorUtil.getI18nString("emxFramework.Common.InvalidDate", "emxFrameworkStringResource", Request.getLanguage(request));
        String isTaskApprovalCommentsOn = EnoviaResourceBundle.getProperty(context, "emxComponents.Routes.ShowCommentsForTaskApproval");
        String invalidApprovalStatusSelection = UINavigatorUtil.getI18nString("emxFramework.ApprovalStatus.Incorrect", "emxFrameworkStringResource", Request.getLanguage(request));

    String valueField = emxGetParameter(request, "valueField");
    String comboValueField = emxGetParameter(request, "comboValueField");
    valueField=FrameworkUtil.findAndReplace(valueField,"\"", "\\\"");
    String valueFieldDisplay = emxGetParameter(request, "valueFieldDisplay");
    String valueFieldOID = emxGetParameter(request, "valueFieldOID");

    String fieldType = emxGetParameter(request, "fieldType");
    String strdepth = emxGetParameter(request, "strdepth");
    String fieldName = emxGetParameter(request, "columnSelect");
    String custValFieldStr = emxGetParameter(request, "isCustomValidateField");

    boolean isPopUpField = false;
    boolean updatefields = true;
    try {
                if("popup".equals(fieldType)) {
                        isPopUpField = true;
                }

                if("manualdate".equals(fieldType) && valueField != null && !"".equals(valueField) ) {
                        java.text.DateFormat df = java.text.DateFormat.getDateInstance(eMatrixDateFormat.getEMatrixDisplayDateFormat(), request.getLocale());
                        df.setLenient(false);
                        java.util.Date formattedDate = df.parse(valueField);

                }
    } catch (Exception ex) {
                if (ex.toString() != null && (ex.toString().trim()).length() > 0) {
                emxNavErrorObject.addMessage(invaliddate);
                }
        updatefields = false;
    }
%>

<script language="JavaScript">
	
	//
	// Sets the form element value to the given value.
	// The code just takes extra care for setting the value for
	// list box.
	// If objElement is multi-select list box, the strValue can be comma separated.
	// if any option(s) in the multi-select list box is selected, the previous selection
	// will be preserved. If from the given set of values, only few values are present in
	// the multi-select list box then only matched values are selected.
	//
		
	function validateFormElementValue(objElement, strValue){
		var iFlag = true;
		if (objElement) {
    		if (strValue == null || !strValue) {
    			strValue = "";
    		}
	        if (objElement.type == "select-one") {
	            for (var i = 0; i < objElement.options.length; i++) {
	                var objOption = objElement.options[i];
	                if (objOption.value == strValue || objOption.text == strValue) {
	                	iFlag = false;
	                	break;
	                }
	            }
	        }
	        return iFlag;
		}
	}
	
	
	
    function setElementValue(objElement, strValue) {
    	if (objElement) {
    		if (strValue == null || !strValue) {
    			strValue = "";
    		}
	        if (objElement.type == "select-one") {
	            for (var i = 0; i < objElement.options.length; i++) {
	                var objOption = objElement.options[i];
	                //Modified for Bug : 346500 & 364054
	                if (objOption.value == strValue || objOption.text == strValue) {
	                    objElement.selectedIndex = i;
	                    break;
	                }
	            }
	        }
	        // If this is multiple selection list box
	        else if (objElement.type == "select-multiple") {
	        	// The multiple values to be selected must be given comma separated
	        	var arValues = strValue.split(",");
	        	
	        	for (var i = 0; i < objElement.options.length; i++) {
	                var objOption = objElement.options[i];
	                
	                // Check for each value in array if the corresponding option in 
	                // multi-select list box is to be selected
	                for (var j = 0; j < arValues.length; j++) {
	                	//Modified for Bug : 346500 & 364054
	                	if (objOption.value == arValues[j] || objOption.text == arValues[j]) {
		                    objOption.selected = true;
		                }
	                }
	            }
	        }
	        else {
	        	// If it is not list boxes then just set the value property of the element
	        	// with given value.
	        	// The "file" form elements cannot be set values, because browsers do not support
	        	// setting values to file control elements due to security reasons.
	            objElement.value = strValue;
	        }
	        var displayFrame = parent.frames['formEditDisplay'];
	        if(displayFrame != null && displayFrame.FormHandler) {
	        	var fieldName = objElement.getAttribute("name");
	        	displayFrame.FormHandler.NotifyFieldChange(fieldName);
	        }
        }
    }

var strDateFieldValue;
<%
        if (updatefields) {
            String strFieldValue = "";
            if("date".equalsIgnoreCase(fieldType)) {
                String timeZone = (String)session.getAttribute("timeZone");
                double iClientTimeOffset = (new Double(timeZone)).doubleValue();
                strFieldValue = eMatrixDateFormat.getFormattedInputDate(context, valueField, iClientTimeOffset,request.getLocale());
                // XSSOK
%>
                strDateFieldValue = "<%=strFieldValue%>";//XSSOK
<%
            }

%>
        //XSSOK
        var popup = <%=isPopUpField%>;
        var textVal = "<xss:encodeForJavaScript><%=valueField%></xss:encodeForJavaScript>";
        var strDepth = "<xss:encodeForJavaScript><%=strdepth%></xss:encodeForJavaScript>";
        var fieldName = "<xss:encodeForJavaScript><%=fieldName%></xss:encodeForJavaScript>";
        var isCusValField = "<xss:encodeForJavaScript><%=custValFieldStr%></xss:encodeForJavaScript>";
        var fieldUOMunitFiled = "<xss:encodeForJavaScript><%=comboValueField%></xss:encodeForJavaScript>";
        var displayframe = parent.frames['formEditDisplay'];
        var rows = displayframe.document.forms[0].objCount.value;

        var showselectOnealert = true;
        var chkboObj;
        if(strDepth == 'all') {
                showselectOnealert = false;
                for(var k = 0; k < rows; k++) {
                        if(popup) {
                                var formElement= displayframe.document.forms[0][fieldName + k];
                                if (formElement){
									setElementValue(formElement, textVal);
                                    displayframe.saveFieldObj(formElement);

                                    var formUOMunitElt = displayframe.document.forms[0]["units_" + fieldName + k];
                                    if(formUOMunitElt) {
                                        setElementValue(formUOMunitElt, fieldUOMunitFiled);
                                        try{
                                        	displayframe.saveFieldObj(fieldUOMunitFiled);
                                        }catch(err){
                                        }
                                    }

                                } else {
                                    formElement= displayframe.document.forms[0][fieldName + k + "AmPm"];
                                if (formElement && strDateFieldValue) {
                                       setElementValue(formElement, strDateFieldValue);
                                }
                                }

                                formElement= displayframe.document.forms[0][fieldName + k + "Display"];
                                if (formElement){
                                       setElementValue(formElement, "<xss:encodeForJavaScript><%=valueFieldDisplay%></xss:encodeForJavaScript>");
                                }

                                formElement = displayframe.document.forms[0][fieldName + k + "OID"];
                                if (formElement){
                                        setElementValue(formElement, "<xss:encodeForJavaScript><%=valueFieldOID%></xss:encodeForJavaScript>");
                                }
                        } else {
                                var formElement= displayframe.document.forms[0][fieldName + k];
                                if (formElement){
                                    setElementValue(formElement, textVal);
                                    displayframe.saveFieldObj(formElement);

                                    var formUOMunitElt = displayframe.document.forms[0]["units_" + fieldName + k];
                                    if(formUOMunitElt) {
                                        setElementValue(formUOMunitElt, fieldUOMunitFiled);
                                        try{
                                        	displayframe.saveFieldObj(fieldUOMunitFiled);
                                        }catch(err){
                                        }
                                    }

                                } else {
                                    formElement= displayframe.document.forms[0][fieldName + k + "AmPm"];
                                if (formElement && strDateFieldValue) {
                                        setElementValue(formElement, strDateFieldValue);
                                }
                                }
                        }
                }
        } else {
                var selectedRows = displayframe.document.forms[0].selectedRows;
                var selRowsArray = new Array();
                if(selectedRows && selectedRows.value.length > 0 &&
                   selectedRows.value != "null" && selectedRows.value != "undefined"){
                    selRowsArray = selectedRows.value.split(",");
                }

                if(selRowsArray.length > 0){
                    for(var k = 0; k < selRowsArray.length; k++) {
                        var nthSelRow = selRowsArray[k];
                        if(!isNaN(nthSelRow)){
                                showselectOnealert = false;
                                if(popup) {

                                        var formElement= displayframe.document.forms[0][fieldName + nthSelRow];
                                        if (formElement){
                                        	if(fieldName == "Approval Status"){
                                        		var validateInfo = validateFormElementValue(formElement, textVal);
                                        		if (validateInfo === true){
                                        			alert("<%=invalidApprovalStatusSelection%>");
                                        			break;
                                        		}
                                        	}
                                            setElementValue(formElement, textVal);
                                            displayframe.saveFieldObj(formElement);

                                            var formUOMunitElt = displayframe.document.forms[0]["units_" + fieldName + nthSelRow];
                                            if(formUOMunitElt) {
                                                setElementValue(formUOMunitElt, fieldUOMunitFiled);
                                            	try{
                                        			displayframe.saveFieldObj(fieldUOMunitFiled);
                                       			}catch(err){
                                        		}
                                            }

                                        } else {
                                            formElement= displayframe.document.forms[0][fieldName + nthSelRow + "AmPm"];
                                        if (formElement && strDateFieldValue) {
                                                setElementValue(formElement, strDateFieldValue);
                                        }
                                        }


                                        formElement= displayframe.document.forms[0][fieldName + nthSelRow + "Display"];
                                        if (formElement){
                                                setElementValue(formElement, "<xss:encodeForJavaScript><%=valueFieldDisplay%></xss:encodeForJavaScript>");
                                        }

                                        formElement= displayframe.document.forms[0][fieldName + nthSelRow + "OID"];
                                        if (formElement){
                                                setElementValue(formElement, "<xss:encodeForJavaScript><%=valueFieldOID%></xss:encodeForJavaScript>");
                                        }
                                } else {
                                        var formElement= displayframe.document.forms[0][fieldName + nthSelRow];
                                        if (formElement){
                                            setElementValue(formElement, textVal);
                                            displayframe.saveFieldObj(formElement);

                                            var formUOMunitElt = displayframe.document.forms[0]["units_" + fieldName + nthSelRow];
                                            if(formUOMunitElt) {
                                                setElementValue(formUOMunitElt, fieldUOMunitFiled);
                                                try{
                                        			displayframe.saveFieldObj(fieldUOMunitFiled);
                                      		  	}catch(err){
                                        		}
                                            }

                                        } else {
                                            formElement= displayframe.document.forms[0][fieldName + nthSelRow + "AmPm"];
                                        if (formElement && strDateFieldValue) {
                                                setElementValue(formElement, strDateFieldValue);
                                        }
                                        }
                                }
                        }
                    } //for
                }
        }

        if(showselectOnealert) {
                //XSSOK
                alert("<%=strSelectOne%>");
        }
<%
        }
%>

    //reset isCustomValidateField variable on massUpdateForm
    parent.document.forms[0].isCustomValidateField.value = "false";

</script>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</html>


