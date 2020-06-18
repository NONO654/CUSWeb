<%--
  ConfigurationFeatureCopyFromFSDialog.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@page import="com.matrixone.apps.domain.DomainObject" %>

<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>

<% 
  String appendParams = emxGetQueryString(request);
  String contextObjId = emxGetParameter(request, "objIdContext");
  //check propety setting for enabling across the level selection
  String strEnableMultilvel = EnoviaResourceBundle.getProperty(context,"emxConfiguration.Copy.MultiLevelSelection.Enabled");  
 %>

<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><html>
<form name="CopyFrom" method="post" id="VariantFSDialogPage">
<%@include file = "../common/enoviaCSRFTokenInjection.inc" %>

<input type="hidden" name="emxTableRowId" value="null" />
<div id="copyfrom" style="visibility: hidden;">
<TABLE>
	<TR>
		<TD>1</TD>
	</TR>
</TABLE>
</div>
</form>
<SCRIPT language="javascript" type="text/javaScript">     
	
	var formName = document.forms['CopyFrom'];
	if (formName == 'undefined' || formName == null) {
		var formName = document.getElementById('VariantFSDialogPage');
	}
	var selectedFeatures = "";
	var action = "";
	var isAll = "";
	var detailsDisplayFrame = findFrame(getTopWindow().window,
			"FTRConfigurationFeatureCopyFromFirstStep");
	var firstStepFrame = detailsDisplayFrame.document.forms["ProductCopy"];
	var the_inputs = self.parent.document.forms['emxTableForm']
			.getElementsByTagName("input");
	var temp_oXML = self.parent.oXML;
	var aSelectedCheckboxes = emxUICore.selectNodes(temp_oXML.documentElement,
			"/mxRoot/rows//r[@checked='checked']");
	var selectedStuff = "";
	var isRoot = false;

	if (firstStepFrame.Clone.checked == 0) {
		isAll = "&clone=off&share=on";
		action = "share";
	} else {
		isAll = "&clone=on&share=off";
		action = "clone";
	}

	for ( var n = 0; n < aSelectedCheckboxes.length; n++) {
		var objID = aSelectedCheckboxes[n].getAttribute("o");
		var relID = aSelectedCheckboxes[n].getAttribute("r");
		var levelID = aSelectedCheckboxes[n].getAttribute("id");
		// Added for CR-213
		var parentID = aSelectedCheckboxes[n].getAttribute("p");
		selectedStuff += "&emxTableRowId=" + relID + "|" + objID + "|"
				+ parentID + "|" + levelID;
		// Added for CR-213 && (strEnableMultilvel == "Yes" || strEnableMultilvel=="yes") 
		if ((relID == null || relID == "") && levelID == "0") {
			isRoot = true;
			break;
		}
	}
	var levels = new Array();
	var Flevels = new Array();
	//HF2 BUG 353054 END
	for ( var n = 0; n < the_inputs.length && !isRoot; n++) {
		if (the_inputs[n].name == 'emxTableRowIdActual'
				|| the_inputs[n].name == 'emxTableRowId') {
			if (the_inputs[n].checked == 1) {
				//HF2 BUG 353054 START
				levels[n] = the_inputs[n].value
				//HF2 BUG 353054 END
				selectedFeatures += "&emxTableRowId=" + the_inputs[n].value;
			}
		}
	}
	//HF2 BUG 353054 START
	var outer = true;
	var k = 0;
	for ( var i = 0; i < levels.length && !isRoot; i++) {
		var inner = true;
		if (levels[i] != null && levels[i] != "") {
			var index = levels[i].lastIndexOf("|");
			var lev = levels[i].substring(index + 1);
			Flevels[k] = lev;
			k++;
		}
	}
	var ocurrent = 0;
	var ocurrentNext = 0;
	for ( var iX = 0; iX < Flevels.length && !isRoot; iX++) {
		var inner = true;
		for ( var jX = iX; jX < Flevels.length; jX++) {
			if (jX != (Flevels.length - 1)) {
				var current = Flevels[iX];
				var currentNext = Flevels[jX + 1];
				//code set 2 start
				while (current.length > 0) {
					var cIn = current.indexOf(",");
					if (cIn != (-1)) {
						ocurrent++;
						current = current.substring(cIn + 1);
					} else {
						break;
					}
				}
				while (currentNext.length > 0) {
					var cInx = currentNext.indexOf(",");
					if (cInx != (-1)) {
						ocurrentNext++;
						currentNext = currentNext.substring(cInx + 1);
					} else {
						break;
					}
				}
				if (ocurrent != ocurrentNext) {
					inner = false;
					break;
				}
			}

		}
		if (inner == false) {
			outer = false;
			break;
		}
	}
	//Added for CR-213
	if (isRoot) {
		var alertMsg = "<%=i18nNow.getI18nString("emxConfiguration.Alert.DontSelectRootNode",bundle,acceptLanguage)%>";
		findFrame(getTopWindow(),"FTRConfigurationFeatureCopySecondStep").setSubmitURLRequestCompleted();
		alert(alertMsg);
	}
	//HF2 BUG 353054 END
	else if(selectedFeatures==null || selectedFeatures=="")
    {
        var alertMsg = "<%=i18nNow.getI18nString("emxConfiguration.CopyFrom.NoSelection.Confirm",bundle,acceptLanguage)%>";
        findFrame(getTopWindow(),"FTRConfigurationFeatureCopySecondStep").setSubmitURLRequestCompleted();
        alert(alertMsg);
    }
	//HF2 BUG 353054 START
	// Modified for CR-213
	else if(inner == false && (action != "clone" || ("<%=strEnableMultilvel%>" != "Yes" && "<%=strEnableMultilvel%>"!="yes"))){
		var alertMg = "<%=i18nNow.getI18nString("emxProduct.Alert.CopyFrom.SelectionAcrossLevel",bundle,acceptLanguage)%>";
		findFrame(getTopWindow(),"FTRConfigurationFeatureCopySecondStep").setSubmitURLRequestCompleted();
        alert(alertMg);
	}
	//HF2 BUG 353054 END
    else{
	     var url = "../configuration/ConfigurationFeatureCopyFromPostProcess.jsp?";	     
	     url += "&action=";
	     url += action;
		 url += "&";
		 url += "<%=XSSUtil.encodeURLwithParsing(context,appendParams)%>";		 
		 url += "&objIdContext=<%=XSSUtil.encodeForURL(context,contextObjId)%>";
		 formName.emxTableRowId.value = selectedStuff;	 
		 		 
	     var i = 0;	          
	     
	     while (typeof(firstStepFrame[i])!=='undefined')
	     {
	          if(firstStepFrame[i].type =="checkbox")
	          {
	             if(firstStepFrame[i].checked == 0)
	             {
	                 var temp = "&" + firstStepFrame[i].name + "=off" ;
	                 isAll += temp;
	             }
	             else
	             {
	                 var temp = "&" + firstStepFrame[i].name + "=on" ;
	                 isAll += temp;
	             }
	          }
	          i++;
	     }    
	     url += isAll;
	   formName.action = url;
	    formName.submit();	  
		 window.close();
	 }

 
</SCRIPT>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
   </body>
</html>
