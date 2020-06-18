 <!--  emxEngMassChangeECOECRIntermediate.jsp -  This is an intermediate jsp.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
-->

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxengchgJavaScript.js"%>
<%@ include file = "../emxJSValidation.inc" %>

<%

     String strMode = emxGetParameter(request, "mode");
     String objectId = emxGetParameter(request, "objectId");
     String suiteKey  = XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"suiteKey"));

     String actionURL = "../engineeringcentral/emxpartRaiseAnECRCheck.jsp?closeParentWindow=true&sContextMode=true&suiteKey="+suiteKey;

     if ("ECO".equals(strMode)) {
         actionURL = "../engineeringcentral/emxpartRaiseAnECOForMassChangeCheck.jsp?closeParentWindow=true&sContextMode=true&suiteKey="+suiteKey;
     }
     
     String propAllowLevel = JSPUtil.getCentralProperty(application, session, "emxEngineeringCentral" ,"AllowMassEBOMChangeUptoLevel");
     String strEBOMSubRel = PropertyUtil.getSchemaProperty(context,"relationship_EBOMSubstitute");
     
     if (propAllowLevel != null && !"null".equalsIgnoreCase(propAllowLevel) && !"".equals(propAllowLevel) ) {
         propAllowLevel = propAllowLevel.trim();
     } else {
         propAllowLevel = "1";
     }
     
%>

<html>
	<body>
		<form name="MassChangeECRECO" method="post">
		
		    <input type="hidden" name="selectedParts" value="" />
		            
		    <script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
            <script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
			<script language="javascript">

			     //XSSOK
			     var propLevelVal = "<%=propAllowLevel%>";

			     try {
			         propVal = parseInt(propLevelVal, 10).toString();
			         if (propVal != propLevelVal) {
			             propLevelVal = "1";
			         }
			     } catch (e) {
			       propLevelVal = "1";
			     }

			     if ((isNaN(propLevelVal) == true) || propLevelVal < 0) {
			         alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.CommonAlert.ERROR</emxUtil:i18nScript><emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.RaiseECR.InvalidLevelPropertyAlert</emxUtil:i18nScript>");			         
			         self.closeWindow();			         
			     } else {
			         var parseIntVal = parseInt(propLevelVal, 10).toString();
			         if (parseIntVal.length != propLevelVal.length) {
			             alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.CommonAlert.ERROR</emxUtil:i18nScript><emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.RaiseECR.InvalidLevelPropertyAlert</emxUtil:i18nScript>");
			             self.closeWindow();			             
			        }
			     }

			     sbReference = getTopWindow().getWindowOpener();
			     var dupemxUICore = sbReference.emxUICore;    
			     var oXML         = sbReference.oXML;
			     var isIncrement  = false;
			     try {
			         var checkedRows = dupemxUICore.selectNodes(oXML.documentElement, "/mxRoot/rows//r[@checked='checked']");
			         
			         var breakLoop = false;
			         var temp = false;
			         var paramTo="";
			         //X3 Start- Modified for EBOM Substitute Mass Change
			         var samRelType = true;
			         var temRelType = "";
			         //X3 End- Modified for EBOM Substitute Mass Change

			         for (var i = 0; i < checkedRows.length; i++) {
			              temp = true;         
				          var objectId = checkedRows[i].getAttribute("o");
				          var rowId    = checkedRows[i].getAttribute("id");
				          
				          var level = sbReference.emxEditableTable.getCellValueByRowId(rowId, "Levels").value.current.actual;				          
				          var fn = sbReference.emxEditableTable.getCellValueByRowId(rowId, "FindNumber").value.current.actual;
				          var reltype = checkedRows[i].getAttribute("rel");
				          			             
			              if (temRelType == "") {
			                  temRelType = reltype;
			              }

				          if (temRelType != reltype) {
				              samRelType = false;
				              break;
				          }

				          //End- Modified for EBOM Substitute Mass Change
				          if(propLevelVal != 0) {             
				            if(level != "#") {              
				              if(level.length > 0  && level.charAt(0) == '-') {
				                level = level.substring(1, level.length);
				              }
								try{
								level = parseInt(level, 10);
								}
								catch(e){
									level ="1";
								}
				              if(level > propLevelVal) {                             
				                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.CommonAlert.ERROR</emxUtil:i18nScript><emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.WhereUsedSumary.LevelCheckAlert</emxUtil:i18nScript> "+propLevelVal);
				                breakLoop = true;
				                break;
				              }
				            }
				          }
				          
				          paramTo +=  objectId +"|"+ fn +",";
			         }
			         
			           
			         if (!samRelType) {
			        	 alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.WhereUsedSumary.SubsituteMassChangeAlert</emxUtil:i18nScript>");
			        	 self.closeWindow();
			             //return;
			         }
			       //XSSOK
			     if (temRelType == "<%=strEBOMSubRel%>") {
			         ebomSubstituteChange = "true";
			     } else {
			         ebomSubstituteChange = "false";
			     }
			     //X3 End- Modified for EBOM Substitute Mass Change
			     if (!temp) {
			       alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.WhereUsedSumary.NotSelectedAlert</emxUtil:i18nScript>");
			       self.closeWindow();
			       //return;
			     }    
			     if (breakLoop == false) {
			    	 paramTo = paramTo.substring(0, paramTo.lastIndexOf(','));			       
			     	//XSSOK
			         var sURL = "<%= actionURL%>&ebomSubstituteChange=" + ebomSubstituteChange + "&objectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>";
			         document.MassChangeECRECO.selectedParts.value = paramTo;			         
			         document.MassChangeECRECO.action = sURL;
	                 document.MassChangeECRECO.submit();
			     }			     
			     } catch (e) {
			         alert("Exception Occurred:"  +e.message);
			         self.closeWindow();       
			     }     
			                        
			</script> 
		
		</form>
	</body>
</html>

