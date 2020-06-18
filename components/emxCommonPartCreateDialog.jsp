<%--  emxCommonPartCreateDialog.jsp.  -  The dialog page for creating a new part and assigning it to a buyer desk.

  Copyright (c) 1992-2018  Dassault Systemes.
  All Rights Reserved.
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "emxComponentsUtil.inc" %>

<%
	//Added for the bug 346004
	String partType = PropertyUtil.getSchemaProperty(context,"type_Part");
	String languageStr = request.getHeader("Accept-Language");
	BusinessType partBusType = new BusinessType(partType, context.getVault());
	partBusType.open(context);
	PolicyList partPolicyList = partBusType.getPoliciesForPerson(context, false);//getPolicies(context);
	PolicyItr partPolicyItr = new PolicyItr(partPolicyList);
	partBusType.close(context);
	//End for the bug 346004
%>

<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>

<!-- content begins here -->
<script language="javascript">
	var numAttr ="";
	var isValidNumberFields = 'true';
	//Added for the Bug No:349567 starts
	var policySeqArr = new Array;
	//Added for the Bug No:349567 ends
	function isNumber(textBox){
    	var varValue = textBox.value;
    	textBox.value = toNumeric(textBox.value);
    	if(!isNumeric(varValue) || varValue < 0) {
      		isValidNumberFields = 'false';
      		alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Alert.checkNumeric</emxUtil:i18nScript>");
      		textBox.value="";
      		textBox.focus();
      		return false;
    	} else {
      		isValidNumberFields = 'true';    
    	}
  	}

	function trim (textBox) {
		while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) == "\n" )
	    	textBox = textBox.substring(0,textBox.length - 1);
	    while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n")
	      	textBox = textBox.substring(1,textBox.length);
	    return textBox;
	}

  	function cancel(){
    	getTopWindow().closeWindow();
  	}

  	function submitform() {
    	var partName =  trim( document.CreatePartForm.partName.value ) ;
    	var description =  trim( document.CreatePartForm.description.value ) ;

	    if ( partName == "" ) {
	      alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.CreatePartDialog.NameMessage</emxUtil:i18nScript>");
	      document.CreatePartForm.partName.value = "";
	      document.CreatePartForm.partName.focus();
	      return;
	    } else if ( description == "" ) {
	      alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.CreatePartDialog.DescriptionMessage</emxUtil:i18nScript>");
	      document.CreatePartForm.description.value = "";
	      document.CreatePartForm.description.focus();
	      return;
	    }

    	var namebadCharacters = checkForNameBadCharsList(document.CreatePartForm.partName);
      	if(namebadCharacters.length != 0){
	        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CreatePartDialog.AlertValidName</emxUtil:i18nScript>"+namebadCharacters);
	        return;
    	}
    	var badCharacters = checkForBadChars(document.CreatePartForm.description);
	    if(badCharacters.length != 0){
	      	alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CreatePartDialog.AlertValidDescription</emxUtil:i18nScript>"+badCharacters);
	      	return;
	    }

      	var arrayOfNumAttr = numAttr.split(";");
      	numField = "";
      	for( j=0;j<arrayOfNumAttr.length;j++) { 
        	if(arrayOfNumAttr[j] != "") {
            	numField = eval('document.CreatePartForm[\"'+arrayOfNumAttr[j]+'\"]');
            	isNumber(numField);   

            	if(isValidNumberFields == 'false')
                	break;
        		}
      		}

	    	if(isValidNumberFields == 'false'){
	      		return;
	    	}
	  		document.CreatePartForm.submit();
  		}
    var bAbstractSelect = false;
    var txtTypeChange = false;

  function showTypeSelector() {
      txtTypeChange = true;
      //XSSOK
      var strURL="../common/emxTypeChooser.jsp?fieldNameActual=type&fieldNameDisplay=typeDisp&formName=CreatePartForm&ShowIcons=true&InclusionList=<%=com.matrixone.apps.domain.util.XSSUtil
					.encodeForURL(partType)%>&ExclusionList=<%=com.matrixone.apps.domain.util.XSSUtil.encodeForURL("type_ShopperProduct")%>&ObserveHidden=true&ReloadOpener=true&SelectAbstractTypes="+bAbstractSelect;
      showModalDialog(strURL, 450, 350);
    }
</script>

<%
	//String partType     = PropertyUtil.getSchemaProperty(context, "type_Part");
	Hashtable hashDateTime = new Hashtable();
	String parentObjId = emxGetParameter(request, "parentObjId");
	String partId = emxGetParameter(request, "busId");
	BusinessObject partObj = null;
	boolean isEdit = false;
	if (partId != null) {
		isEdit = true;
		partObj = new BusinessObject(partId);
		partObj.open(context);
	} else {
		partId = "";
	}

	String strPartType = PropertyUtil.getSchemaProperty(context, "type_Part");
	String strOriginatorAttribute = PropertyUtil.getSchemaProperty(context, "attribute_Originator");
	BusinessType busType = new BusinessType(strPartType, new Vault(JSPUtil.getCompanyVault(context, session)));
	busType.open(context);

	String jsTreeID = emxGetParameter(request, "jsTreeID");
	String initSource = emxGetParameter(request, "initSource");
	String suiteKey = emxGetParameter(request, "suiteKey");
%>
  <%@include file="../emxUICommonHeaderEndInclude.inc" %>  
  <form name="CreatePartForm" method="post" action="emxCommonPartCreateProcess.jsp" onSubmit="submitform(); return false" >
  <input type="hidden" name="parentObjId" value=<xss:encodeForHTMLAttribute><%=parentObjId%></xss:encodeForHTMLAttribute> />
  <input type="hidden" name="jsTreeID" value=<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute> />
  <input type="hidden" name="initSource" value=<xss:encodeForHTMLAttribute><%=initSource%></xss:encodeForHTMLAttribute> />
  <input type="hidden" name="suiteKey" value=<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute> />

    
      <table border="0" width="100%" cellpadding="5" cellspacing="2">
      <!-- //Added for the bug 346004 -->
      <tr>
      <td class="label" width="150" ><emxUtil:i18n localize="i18nId">emxComponents.Common.Type</emxUtil:i18n></td>
      <td class="inputField">
        <input type="hidden" name="type" value="<%=XSSUtil.encodeForHTMLAttribute(context, (String) partType)%>" />
        <input type="text" size="20" name="typeDisp" value="<%=i18nNow.getTypeI18NString(partType, languageStr)%>" readonly="readonly" />
        <input type="button" name="" value="..." onClick="Javascript:showTypeSelector()" />
      </td>
  	  </tr>
      <!-- //End for the bug 346004 -->

        <tr>
          <td  width="150" class="labelRequired"><emxUtil:i18n localize = "i18nId">emxComponents.Common.Name</emxUtil:i18n>&nbsp;&nbsp;</td>
          <td  class="inputField"  colspan="2">
<%
	String description = "";
	if (isEdit) {
		description = partObj.getDescription();
%>
          <input type="hidden" name="partName" value="<%=XSSUtil.encodeForHTMLAttribute(context,
						(String) partObj.getName())%>" /><%=XSSUtil.encodeForHTML(context,
						(String) partObj.getName())%>
<%
	} else {
%>
          <input type="text" name="partName" value="" />
<%
	}
%>
          <input type="hidden" name="partId" value="<%=XSSUtil.encodeForHTMLAttribute(context, (String) partId)%>" />
          </td>
        </tr>
        <tr>
          <td width="150" class="labelRequired"><emxUtil:i18n localize="i18nId">emxComponents.Common.Description</emxUtil:i18n></td>
          <td valign="top" class="inputField" colspan="2"><textarea name="description" rows="5" cols="25" wrap><%=XSSUtil.encodeForHTML(context, description)%></textarea></td>
        </tr>
<%
	char decimalSeparatorChar = PersonUtil.getDecimalSymbol(context);
	Boolean hasDigitSeparator = FrameworkUtil
			.hasDigitSeparator(context);

	// Modified to fix IR HF376155V6R2010x_
	// Praveen Voggu
	String strDefaultPartPolicy = "";
	if (parentObjId != null) {
		DomainObject dom = new DomainObject(parentObjId);

		strDefaultPartPolicy = dom.getInfo(
				context,
				"attribute["
						+ PropertyUtil.getSchemaProperty(context,
								"attribute_DefaultPartPolicy") + "]");
	}
	// end of modification for IR HF376155V6R2010x_
%>

      <!-- //Added for the bug 346004 -->
  <tr>
    <td class="label" width="150" ><emxUtil:i18n localize="i18nId">emxComponents.Common.Policy</emxUtil:i18n></td>
    <td class="inputField">
      <select name="policy"  >
<%
	String selected = "";
	String firstRevSeq = "";
	int idx = 0;
	while (partPolicyItr.next()) {
		Policy partPolicy = partPolicyItr.obj();
		String policyName = partPolicy.getName();
		firstRevSeq = partPolicy.getFirstInSequence(context);
%>
        <script language="javascript">
	       	policySeqArr["<%=idx%>"] = "<%=XSSUtil.encodeForJavaScript(context,(String) firstRevSeq)%>";
        </script>
<%
	// Modified to fix IR HF376155V6R2010x_
		// Praveen Voggu
		String defaultPolicy = "policy_DevelopmentPart";
		if (!strDefaultPartPolicy.equals("")) {
			defaultPolicy = strDefaultPartPolicy;
		}
		// End of Modification for IR 

		if (defaultPolicy.equalsIgnoreCase(FrameworkUtil
				.getAliasForAdmin(context, "policy", policyName, true))) {
			selected = "selected";
		}
%>
		<%
		if(!policyName.equalsIgnoreCase("EC Part")){
		%>
				<!-- //XSSOK -->
        <option value="<%=XSSUtil.encodeForHTMLAttribute(context,(String) policyName)%>" <%=selected%>><%=i18nNow.getAdminI18NString("Policy", policyName,languageStr)%></option>
        <%} %>
<%
	selected = "";
		idx++;
	}
%>
      </select>
    </td>
  </tr>
      <!-- //End for the bug 346004 -->

<%
	AttributeTypeItr attrTypeItr = new AttributeTypeItr(
			busType.getAttributeTypes(context));
	busType.close(context);
	while (attrTypeItr.next()) {
		AttributeType attrType = attrTypeItr.obj();
		attrType.open(context);

		String sAttrName = attrType.getName();
		if (sAttrName.equals(strOriginatorAttribute)) {
			continue;
		}
		String attrNameI18 = i18nNow.getAttributeI18NString(sAttrName,
				request.getHeader("Accept-Language"));
%>
    <tr>
      <td width="150" class="label"><%=attrNameI18%></td>
<%
	StringList strList = attrType.getChoices();
		String sDataType = attrType.getDataType();
		String sDefaultValue = "";

		if (isEdit) {
			sDefaultValue = partObj.getAttributeValues(context,
					sAttrName).getValue();
		} else {
			sDefaultValue = attrType.getDefaultValue();
		}
		boolean hasChoices = false;
		if (strList != null && strList.size() > 0)
			hasChoices = FrameworkUtil.attributeHasChoicesOnly(context,
					sAttrName);
		if (hasChoices) {
%>
      <td colspan="1" class="inputField" >
        <select name="<%=XSSUtil.encodeForHTMLAttribute(context, (String) sAttrName)%>">
<%
			StringItr strItr = new StringItr(attrType.getChoices());
			boolean hasValue = false;

			MapList ml = AttributeUtil.sortAttributeRanges(context, sAttrName, strList, request.getHeader("Accept-Language"));
			Iterator mlItr = ml.iterator();
			while (mlItr.hasNext()) {
				Map choiceMap = (Map) mlItr.next();
				String choice = (String) choiceMap.get("choice");
				String translation = (String) choiceMap.get("translation");
				if (choice.equals(sDefaultValue)) {
					hasValue = true;
%>
                <option value="<%=XSSUtil.encodeForHTMLAttribute(context,
									choice)%>" selected><%=XSSUtil.encodeForHTML(context,
									translation)%></option>
<%
	} else {
%>
                <option value="<%=XSSUtil.encodeForHTMLAttribute(context,
									choice)%>"><%=XSSUtil.encodeForHTML(context,
									translation)%></option>
<%
	}
			}
%>
      </select></td>
<%
	String strTextDesc = "";
			if (!hasValue) {
				strTextDesc = sDefaultValue;
			}
		} else if (sDataType.equals("real")
				|| sDataType.equals("integer")) {
%>
      <td colspan="1" class="inputField">
      	<!-- //XSSOK -->
      	<framework:UOMAttribute name="<%=sAttrName%>" objectId="<%=XSSUtil.encodeForHTMLAttribute(context, partId)%>" format="preference" mode="Edit" fieldName="<%=sAttrName%>"/>
      </td>
<script>
numAttr = numAttr + "<%=XSSUtil.encodeForJavaScript(context, (String) sAttrName)%>"+";";
</script>

<%
	} else if (sDataType.equals("timestamp")) {
%>
      <td colspan="1" class="inputField">
      	<!--//XSSOK-->
      	<input type="text" name="<%=XSSUtil.encodeForHTMLAttribute(context,	(String) sAttrName)%>" value="<emxUtil:lzDate displaydate="true" displaytime="true" localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm%>'><%=sDefaultValue%></emxUtil:lzDate>" readonly="readonly" />&nbsp;&nbsp;
        <a href="javascript:showCalendar('CreatePartForm','<%=XSSUtil.encodeForJavaScript(context,
							(String) sAttrName)%>','<%=XSSUtil.encodeForJavaScript(context,
							(String) sDefaultValue)%>')">
        	<img src="../common/images/iconSmallCalendar.gif" border="0" />
        </a>
      </td>
<%
	} else {
%>
      <td colspan="1" class="inputField"><input type="text" name="<%=XSSUtil.encodeForHTMLAttribute(context,
							(String) sAttrName)%>" value="<%=XSSUtil.encodeForHTMLAttribute(context,
							(String) sDefaultValue)%>" /></td>
<%
	}
%>
    </tr>
<%
	attrType.close(context);
	}
%>
</table>

</form>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
