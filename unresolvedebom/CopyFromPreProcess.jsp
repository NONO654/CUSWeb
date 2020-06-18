<%-- CopyFromProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
   
<%@page import="com.matrixone.apps.engineering.EngineeringConstants"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%-- <jsp:useBean id="unresolvedEBOM" class="com.matrixone.apps.unresolvedebom.UnresolvedEBOM" scope="session"/> --%>
<%@ page import="com.matrixone.apps.unresolvedebom.*,com.matrixone.apps.domain.DomainObject" %>

<%
String language = request.getHeader("Accept-Language");
//String isWipBomAllowed   = FrameworkProperties.getProperty("emxUnresolvedEBOM.WIPBOM.Allowed");
String isWipBomAllowed   = EnoviaResourceBundle.getProperty(context, "emxUnresolvedEBOM.WIPBOM.Allowed");
String STATEPRELIMINARY  = PropertyUtil.getSchemaProperty(context,"policy",UnresolvedEBOMConstants.POLICY_CONFIGURED_PART,"state_Preliminary");
//String strTarPartId      = unresolvedEBOM.getSTargetPartId();
String strTarPartId      ="";
//String selectedPartState = (String)DomainObject.newInstance(context,strTarPartId).getInfo(context,com.matrixone.apps.domain.DomainConstants.SELECT_CURRENT);

Map targetPartInfoMap = DomainObject.newInstance(context,strTarPartId).getInfo(context,StringList.create(DomainObject.SELECT_CURRENT, EngineeringConstants.ATTRIBUTE_RELEASE_PHASE_VALUE));
String selectedPartState = (String)targetPartInfoMap.get(DomainObject.SELECT_CURRENT);
//String releaseProcess = UnresolvedEBOM.isWipBomAllowedForParts(context, strTarPartId);
String releaseProcess ="";

String isWipMode = EngineeringConstants.DEVELOPMENT.equals(releaseProcess) ? "true" : "false";
String strSelectAnItem          = i18nStringNowUtil("emxFramework.Common.PleaseSelectitem","emxFrameworkStringResource", language);
String strInvalidSelectionMsg   = i18nStringNowUtil("emxUnresolvedEBOM.Alert.BadStructureSelection","emxUnresolvedEBOMStringResource", language);
String invalidSelectionInWIPBOM = i18nStringNowUtil("emxUnresolvedEBOM.CopyFrom.WIPBOMAlert","emxUnresolvedEBOMStringResource", language);

%>
<script language="javascript">
var isSuccess    = true;
var sbReference  = findFrame(getTopWindow(),"content");
if (sbReference == null || sbReference == undefined){
	sbReference = getTopWindow();
}
var dupemxUICore = sbReference.emxUICore;
var oXML         = sbReference.oXML;
var isIncrement  = false;
var selectedParts="";

try {
	var checkedRows = dupemxUICore.selectNodes(oXML.documentElement, "/mxRoot/rows//r[@checked='checked']");
	var postDataXML = dupemxUICore.createXMLDOM();
	postDataXML.loadXML("<mxRoot/>");
	var eleRows     = postDataXML.createElement("rows"); 
	var rootElement = postDataXML.documentElement; 
	var rowsLength  = checkedRows.length; 
	
	var currRowId = "";
	var nextRowId = "";
	var parentState = "";
	//XSSOK
	var isWipMode   = "<%=isWipMode%>";
	rootElement.appendChild(eleRows);
	if (checkedRows != null && rowsLength > 0){
		for(var i=0; i<rowsLength; i++){
			
		    var eleRow = postDataXML.createElement("row");		    
			nextRowId = checkedRows[i].getAttribute("id");        
		    eleRow.setAttribute("id",nextRowId);
		    selObjId = checkedRows[i].getAttribute("o");
		    selectedParts += selObjId+"~";
		    eleRow.setAttribute("o",selObjId);
		    eleRow.setAttribute("r",checkedRows[i].getAttribute("r"));
		    eleRow.setAttribute("p",checkedRows[i].getAttribute("p"));
		    currLevel = checkedRows[i].getAttribute("level");
	        eleRow.setAttribute("level",currLevel);
	        if (currRowId != "" && nextRowId.indexOf(currRowId) > -1 && parseInt(nextRowId.length) != parseInt(currRowId.length) + 2) {
	        	//XSSOK
               alert("<%=strInvalidSelectionMsg%>");
               isSuccess=false;
               break; 
	        }

            var colEle = postDataXML.createElement("column");
            var colFindNumber     = sbReference.emxEditableTable.getCellValueByRowId(nextRowId,"Find Number");
            colEle.setAttribute("FindNo",colFindNumber.value.current.actual);
            
            var colRefDesignator  = sbReference.emxEditableTable.getCellValueByRowId(nextRowId,"Reference Designator");
            colEle.setAttribute("RefDes",colRefDesignator.value.current.actual);
            
            var columnQuantity    = sbReference.emxEditableTable.getCellValueByRowId(nextRowId,"Quantity");
            colEle.setAttribute("Qty",columnQuantity.value.current.actual);
            var columnUOM    = sbReference.emxEditableTable.getCellValueByRowId(nextRowId,"UOM");
            colEle.setAttribute("UOM",columnUOM.value.current.actual);
            
            var colComponentLoc   = sbReference.emxEditableTable.getCellValueByRowId(nextRowId,"Component Location");
            if(colComponentLoc!=undefined && colComponentLoc!= null )
            {
            		colEle.setAttribute("CompLoc",colComponentLoc.value.current.actual);
            }
            
            var colUsage   = sbReference.emxEditableTable.getCellValueByRowId(nextRowId,"Usage");
	    if(colUsage!=undefined && colUsage!=null)
	    {
		colEle.setAttribute("Usage",colUsage.value.current.actual);
	    }
        //XSSOK    	
            	if (isWipMode == "true" && parentState == "<%=UnresolvedEBOMConstants.STATE_PART_RELEASE%>" && nextRowId.indexOf(currRowId) > -1) {
            	//XSSOK
                alert("<%=invalidSelectionInWIPBOM%>");
                isSuccess=false;
                break
            }
            parentState = sbReference.emxEditableTable.getCellValueByRowId(nextRowId,"State").value.current.actual;
            eleRow.appendChild(colEle);
	        eleRows.appendChild(eleRow);

	        currRowId = nextRowId;
	    }
	 
	}else{
		//XSSOK
		alert("<%=strSelectAnItem%>");
		isSuccess=false;
	}
  }catch (e) {
	    alert("Exception Occurred:"  +e.message);
	    isSuccess=false;
  }	
</script>
<html>
<head>
</head>
<body>
<form name="copyForm" method="post" action="CopyFromProcess.jsp" target="_parent">
<input type=hidden name="oXML" value=""/>
<input type=hidden name="rowsSelected" value=""/>
<input type="hidden" name="isWipMode" value="<xss:encodeForHTMLAttribute><%=isWipMode%></xss:encodeForHTMLAttribute>"/>
<input type=hidden name="selectedParts" value=""/>
<script language="Javascript">
	    if (isSuccess) {
	    selectedParts = selectedParts != ""?selectedParts.substring(0,selectedParts.lastIndexOf('~')):"";      
	    document.copyForm.oXML.value=postDataXML.xml;
	    document.copyForm.rowsSelected.value=rowsLength;
	    document.copyForm.selectedParts.value=selectedParts;
	    document.copyForm.submit();  
	    }
</script>
</form>
</body>
</html>

   
