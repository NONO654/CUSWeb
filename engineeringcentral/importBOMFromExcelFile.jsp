<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
</head>
<body>
<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxengchgJavaScript.js"%>
<SCRIPT language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></SCRIPT>
<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<SCRIPT language="JavaScript" src="../common/scripts/emxUIModal.js" type="text/javascript"></SCRIPT>
<SCRIPT language="JavaScript" src="../common/scripts/emxUIPopups.js" type="text/javascript"></SCRIPT>
<SCRIPT language="JavaScript" src="../common/scripts/emxTypeAhead.js" type="text/javascript"></SCRIPT>
<SCRIPT language="JavaScript" src="../common/scripts/emxQuery.js" type="text/javascript"></SCRIPT>
<script type="text/javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIForm");
  function doLoad() {
      if (document.forms[0].elements.length > 0) {
        var objElement = document.forms[0].elements[0];
                                                              
        if (objElement.focus) objElement.focus();
        if (objElement.select) objElement.select();
      }
    }
  
  
  function clearWorkUnderFields() {
	  var varhdnFieldWorkUnderDisplay = document.getElementById("hdnFieldWorkUnderDisplay");	  
	  if (varhdnFieldWorkUnderDisplay != null) { varhdnFieldWorkUnderDisplay.value = ""; }
	  
	  var varhdnFieldWorkUnder = document.getElementById("hdnFieldWorkUnder");	  
	  if (varhdnFieldWorkUnder != null) { varhdnFieldWorkUnder.value = ""; }
	  
	  var varhdnWorkUnderOID = document.getElementById("hdnFieldWorkUnderOID");	  
	  if (varhdnWorkUnderOID != null) { varhdnWorkUnderOID.value = ""; }
  }
  
</script>

<script language="Javascript">

  function submit() {
	  if(document.formConfirmDelete.file.value==""){
		  alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ImportEBOM.ChooseFile</emxUtil:i18nScript>");
	  }else{
		  if(jsDblClick()){
		  document.formConfirmDelete.submit();
		  }
		  else{
			  alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Process.MultiSubmit</emxUtil:i18nScript>");
		  }
	  }
	  
	 /* 
	 var objHTTP = emxUICore.createHttpRequest();
	  objHTTP.open("post", "importBOMFromExcelIntermediate.jsp");
	  objHTTP.setRequestHeader("Content-Type", "multipart/form-data;boundary=_OPERAB__xxx");
	  objHTTP.send();
	  emxUICore.checkResponse(objHTTP);
	  ElapsedTimer.exit(objHTTP.responseText.length + ' chars');
	  var noOfRows = "";
	  try {
	 	 noOfRows =  objHTTP.responseText;
	  } finally {
		objHTTP = null;
	  }

	  alert("noOfRows --> " + noOfRows);*/
    
  }

</script>
<form name="formConfirmDelete" action="importBOMFromExcel.jsp" enctype="multipart/form-data" method="post">
<table class="list">
<%
	String objectId         = emxGetParameter(request,"objectId");
	
	objectId = UIUtil.isNotNullAndNotEmpty(objectId) ? objectId : "";
	
  	String selPartRelId = emxGetParameter(request, "selPartRelId");
  	String selPartObjectId = emxGetParameter(request, "selPartObjectId");
  	String selPartParentOId = emxGetParameter(request, "selPartParentOId");
    String selPartRowId     = emxGetParameter(request, "selPartRowId");

    String commandName = emxGetParameter(request, "commandName");
%>

 <tr>
  <td width="150" class="labelrequired"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.File</emxUtil:i18n></td>
 </tr> 
  <tr>
      <td class="inputField" align="left" width="380">
      <input type="file" name="file" size="30" />
    </td>
  </tr>
  <tr>
      <td class="inputField" align="left" width="300">
      <label><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.WorkUnderChange</emxUtil:i18n><input type="text" name="WorkUnderDisplay" id="hdnFieldWorkUnderDisplay" size="10" readonly="true" /></label>
      <input type="button" enabled="true" name="btnWorkUnderSearch" size="200" value="..." onclick="showChooser('../common/emxFullSearch.jsp?suiteKey=EnterpriseChangeMgt&field=TYPES=type_ChangeAction:CURRENT=policy_ChangeAction.state_InWork&includeOIDprogram=AuthoringMgtUxUtil:getEligibleWorkunderChangeAction&table=AuthoringMgtUXSearchResult&Registered Suite=EnterpriseChangeMgt&selection=single&showInitialResults=false&hideHeader=true&submitURL=../common/AEFSearchUtil.jsp&fieldNameActual=WorkUnder&fieldNameOID=WorkUnderOID&fieldNameDisplay=WorkUnderDisplay&HelpMarker=emxhelpfullsearch','850','630');">
      <input type="hidden" name="WorkUnder" id="hdnFieldWorkUnder" value="">
	 <input  type="hidden" name="WorkUnderOID" id="hdnFieldWorkUnderOID" value="">	
      <a href="javascript:clearWorkUnderFields()"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Clear</emxUtil:i18n></a>
    </td>
  </tr>

 
<tr><td class="label"> &nbsp;</td></tr>

  <tr>
	<td class="inputField">
      <input type="checkbox" name="background" /><emxUtil:i18n localize="i18nId">emxEngineeringCentral.EBOMImport.SubmitInBackground</emxUtil:i18n>
	</td>
  </tr>


</table>
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId %></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="selPartRelId" value="<xss:encodeForHTMLAttribute><%=selPartRelId %></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="selPartObjectId" value="<xss:encodeForHTMLAttribute><%=selPartObjectId %></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="selPartParentOId" value="<xss:encodeForHTMLAttribute><%=selPartParentOId %></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="selPartRowId" value="<xss:encodeForHTMLAttribute><%=selPartRowId %></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="commandName" value="<xss:encodeForHTMLAttribute><%=commandName %></xss:encodeForHTMLAttribute>"/>
 
</form>
</body>
</html>
