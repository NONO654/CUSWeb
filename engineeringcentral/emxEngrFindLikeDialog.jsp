<%--  emxEngrFindLikeDialog.jsp   - This page allows the user to do advance search of any business type.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@ include file  = "emxDesignTopInclude.inc" %>
<%@ include file  = "emxEngrVisiblePageInclude.inc" %>
<%@ include file  = "../emxUICommonHeaderBeginInclude.inc" %>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<head>
  <%@include file = "../common/emxUIConstantsInclude.inc"%>
  <script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>

</head>


<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  String estimatedCost = PropertyUtil.getSchemaProperty(context, "attribute_EstimatedCost");
  String typeECO = PropertyUtil.getSchemaProperty(context, "type_ECO");
  String attrPriority = PropertyUtil.getSchemaProperty(context, "attribute_Priority");
  String effectivityDate = PropertyUtil.getSchemaProperty(context, "attribute_EffectivityDate");
  String targetSearchPage = emxGetParameter(request,"targetSearchPage");
  String page1Heading = emxGetParameter(request,"page1Heading");
  String page2Heading = emxGetParameter(request,"page2Heading");
  String objectId = emxGetParameter(request,"objectId");
  String omitSpareParts = emxGetParameter(request,"omitSpareParts");
  String omitAllRevisions = emxGetParameter(request,"omitAllRevisions");
  String isAVLReport = emxGetParameter(request,"AVLReport");
  String searchType = emxGetParameter(request,"searchType");

  String targetResultsPage = emxGetParameter(request,"targetResultsPage");
  String multiSelect = emxGetParameter(request,"multiSelect");
  String table = emxGetParameter(request,"table");
  String program = emxGetParameter(request,"program");

  if(isAVLReport == null || "".equals(isAVLReport) || "null".equals(isAVLReport)) {
     isAVLReport = "FALSE";
  }

  if(searchType == null || "".equals(searchType) || "null".equals(searchType)) {
    searchType = "";
  }

  String languageStr   = request.getHeader("Accept-Language");

  String appDirectory = (String)FrameworkProperties.getProperty(context, "eServiceSuiteEngineeringCentral.Directory");
  //Multitenant
  //String lStr = i18nNow.getI18nString("emxFramework.HelpDirectory","emxFrameworkStringResource", languageStr);
  String lStr = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.HelpDirectory"); 
  if(lStr == null || "".equals(lStr) ||"null".equals(lStr)){
    lStr = "en";
  }

  // get the current suite properties.
  String sShowHiddenAttr  = "FALSE";

  //To get the Business Type for search
  String sBizType = emxGetParameter(request, "ComboType");

  if (sBizType == null || "".equals(sBizType) || "null".equals(sBizType)) {
    sBizType = PropertyUtil.getSchemaProperty(context, "type_Part");
  }

  String sSelected           = "";
  boolean findPart = false;

  if(searchType.equals("eBomFindLike")) {
    findPart = true;
  }


  String searchTypes = "";
  if(findPart) {
     //setting the search type to PART and its childs.
     searchTypes = PropertyUtil.getSchemaProperty(context, "type_Part");
  }else {
     // Dynamically pick up the types defined in the emxComponents.properties
     searchTypes = (String)FrameworkProperties.getProperty(context, "eServiceEngineeringCentral.Types");
     
     //Added for IR-272922
     String searchCOCACRTypes = (String)FrameworkProperties.getProperty(context, "eServiceEngineeringCentral.TypesInFindLike");     
     searchTypes +=  "," + searchCOCACRTypes;
  }

  /*********************************Vault Code Start*****************************************/
  // Display Vault Field as options
  String sGeneralSearchPref ="";
  String allCheck ="";
  String defaultCheck ="";
  String localCheck ="";
  String selectedVaults ="";
  String selectedVaultsValue ="";

  try{
    sGeneralSearchPref = com.matrixone.apps.common.Person.getPropertySearchVaults(context);
  } catch(Exception ex){
    throw ex;
  }

  // Check the User SearchVaultPreference Radio button
  if(sGeneralSearchPref.equals("ALL_VAULTS")) {
    allCheck="checked";
  } else if (sGeneralSearchPref.equals("LOCAL_VAULTS")){
    localCheck="checked";
  } else if (sGeneralSearchPref.equals("DEFAULT_VAULT")  || sGeneralSearchPref.equals("")) {
    defaultCheck="checked";
  } else {
    selectedVaults="checked";
    com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
    selectedVaultsValue = person.getSearchDefaultVaults(context);
  }
  /***********************************Vault Code End***************************************/
  String mxlimit = JSPUtil.getCentralProperty(application,session,"emxFramework.Search","UpperQueryLimit");
  if(mxlimit == null || "null".equals(mxlimit) || "".equals(mxlimit)) {
     mxlimit = "1000";
  }
%>
<%@include file = "../emxJSValidation.inc"%>
<script language="JavaScript">

  function  callDoFind(){
     //footer frame
     var footerFrame = findFrame(getTopWindow(),"searchFoot");
     footerFrame.doFind();
}
    function validate()
    {
      for ( varCount = 0; varCount < document.findLikeForm.elements.length; varCount++) {
        var name = document.findLikeForm.elements[varCount].name;
        if(name.indexOf("txt_") >= 0)
        {
          var check = checkForBadChars(document.findLikeForm.elements[varCount]);
          if(check.length != 0) {
            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.AlertInValidChars</emxUtil:i18nScript>"+check+"<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");
            document.findLikeForm.elements[varCount].value="";
              document.findLikeForm.elements[varCount].focus();
            return check;
          }
        }
      }
      return "";
    }
var clicked = false;

    function doSearch(){
      if (clicked) {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Search.RequestProcessMessage</emxUtil:i18nScript>");
        return;
      }
      var check1 = validate();
      if(check1.length != 0) {
        turnOffProgress();
        return;
      }
      form = document.findLikeForm;
      if((document.findLikeForm.Vault[3].checked==true) && (document.findLikeForm.selVaults.value=="")) {
            alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.VaultOptions.PleaseSelectVault</emxUtil:i18nScript>");
            turnOffProgress();
            return;
      }
    if(document.findLikeForm.Vault[3].checked==true) {
        document.findLikeForm.Vault[3].value=document.findLikeForm.selVaults.value;
    }

      var strQueryLimit = 100;
      //Added to display search results page.
	if(parent.document.forms['searchFooterForm'] !=null) {
		strQueryLimit= parent.document.forms['searchFooterForm'].QueryLimit.value;
		form.target = "searchView";
    } else {
       strQueryLimit = parent.document.bottomCommonForm.QueryLimit.value;
    }
     // search limit validation
     //XSSOK
     var searchLimit = '<%=mxlimit%>';
     var limit = 0;
     if(strQueryLimit == limit || (parseInt(strQueryLimit) > parseInt(searchLimit))) {
         strQueryLimit = searchLimit;
     }
    // end
     document.findLikeForm.queryLimit.value = strQueryLimit;
      //check that the url is the same in both the pageController and bodyFrame
      //if not then reset
      //349592 - Starts
      getTopWindow().validateURL();
      //349592 - Ends
	  //Added for the Bug No: 332509 1 Begin
	 getTopWindow().storeFormVals(document.findLikeForm);
	  //Added for the Bug No: 332509 1 End 
      if(checkBooleanAttributes()) {
         startProgressBar();
         clicked =true;
         document.findLikeForm.submit();
      }

    }

    //Function to submit the page
    function compose() {
      document.findLikeForm.submit();
    }

    //Function to reset the page with default values.
    function clear() {
      for ( varCount = 0; varCount < document.findLikeForm.elements.length; varCount++) {
        if (document.findLikeForm.elements[varCount].type == "text" && document.findLikeForm.elements[varCount].value != "")  {
          document.findLikeForm.elements[varCount].value = "";
        }

        if (document.findLikeForm.elements[varCount].type == "select-one" &&
                                document.findLikeForm.elements[varCount].selectedIndex != 0 &&
                                document.findLikeForm.elements[varCount].name != "ComboType") {
          document.findLikeForm.elements[varCount][0].selected = true;
        }
      }
    }
    //Function to load values for vault on clicking the ellipses button.
    var bVaultMultiSelect = true;
    var strTxtVault = "document.forms['findLikeForm'].selVaults.value";
    var txtVault = null;

    <!----------------------------------Vault Code Start--------------------------------------->
    var strSelectOption = "document.forms['findLikeForm'].Vault[3]";
    var selectOption = null;

    function showVaultSelector() {
      txtVault = eval(strTxtVault);
      selectOption = eval(strSelectOption);
      showModalDialog("../components/emxComponentsSelectSearchVaultsDialogFS.jsp?multiSelect="+bVaultMultiSelect+"&fieldName=selVaults&selectedVaults="+txtVault+"&incCollPartners=true", 300, 350);
    }

    function clearSelectedVaults() {
     document.findLikeForm.tempStore.value=document.findLikeForm.selVaults.value
     document.findLikeForm.Vault[3].value="";
      document.findLikeForm.selVaults.value="";
    }

    function showSelectedVaults() {
      document.findLikeForm.Vault.value=document.findLikeForm.tempStore.value;
    }
    function selectSelectedVaultsOption() {
      document.findLikeForm.Vault[3].checked=true;
    }

  <!-----------------------------------Vault Code End-------------------------------------->


  var bAbstractSelect = true;
  var bReload = true;

  function showTypeSelector() {
	//XSSOK
    var strURL="../common/emxTypeChooser.jsp?fieldNameActual=selType&fieldNameDisplay=selTypeDisp&formName=findLikeForm&ShowIcons=true&InclusionList=<%=com.matrixone.apps.domain.util.XSSUtil.encodeForURL(searchTypes)%>&ObserveHidden=true&ReloadOpener="+bReload+"&SelectAbstractTypes="+bAbstractSelect;
    showModalDialog(strURL, 450, 350);
  }


  function reload() {
    var varType     = document.findLikeForm.selType.value;
    var url =  "../engineeringcentral/emxEngrFindLikeDialog.jsp?ComboType=" + varType;
<%
    if(searchType.equals("eBomFindLike")){
%>
    url +="&objectId=<xss:encodeForURL><%=objectId%></xss:encodeForURL>&searchType=<xss:encodeForURL><%=searchType%></xss:encodeForURL>&targetSearchPage=<xss:encodeForURL><%=targetSearchPage%></xss:encodeForURL>&page1Heading=<xss:encodeForURL><%=page1Heading%></xss:encodeForURL>&page2Heading=<xss:encodeForURL><%=page2Heading%></xss:encodeForURL>&omitSpareParts=<xss:encodeForURL><%=omitSpareParts%></xss:encodeForURL>&omitAllRevisions=<xss:encodeForURL><%=omitAllRevisions%></xss:encodeForURL>&AVLReport=<xss:encodeForURL><%=isAVLReport%></xss:encodeForURL>";
<%
    }

%>
  // document.location.href = fnEncode(url);
   document.forms[0].action = url;
   document.forms[0].target = "";
   document.forms[0].submit();
  }

</script>

<!-- XSSOK -->
<body onload="turnOffProgress()<%=(objectId == null)?", getTopWindow().loadSearchFormFields()":""%>">

<form name="findLikeForm" action="emxEngrFindLikeQueryFS.jsp" method="post" target="_parent" onSubmit="javascript:doSearch(); return false" />
<input type="hidden" name="ComboType" value="<xss:encodeForHTMLAttribute><%=sBizType%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="queryLimit" value="" />
<input type="hidden" name="pagination" value="" />
<input type="hidden" name="selType" value="<xss:encodeForHTMLAttribute><%=sBizType%></xss:encodeForHTMLAttribute>" />
<table class="list" id="UITable">
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Type</emxUtil:i18n></td>
    <td class="inputField">
    <!-- XSSOK -->
      <input type="text" size="16" name="selTypeDisp" id="selTypeDisp" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=i18nNow.getTypeI18NString(sBizType,languageStr)%></xss:encodeForHTMLAttribute>" />
      <input type="button" name="TypeSelector" value="..." onClick="showTypeSelector()" />
    </td>
  </tr>
</table>

<%
  if ((!sBizType.equals(""))) {
    String sTxtKeyword      = emxGetParameter(request, "txtKeyword");
    String sFormat          = emxGetParameter(request, "comboFormat");

    if (sFormat == null || "".equals(sFormat) || "null".equals(sFormat)){
      sFormat = "*";
    }
    if (sTxtKeyword == null || "".equals(sTxtKeyword) || "null".equals(sTxtKeyword)){
      sTxtKeyword = "";
    }

    // Translated string operators
    String sMatrixIncludes     = "Includes";
    String sMatrixIsExactly    = "IsExactly";
    String sMatrixIsNot        = "IsNot";
    String sMatrixMatches      = "Matches";
    String sMatrixBeginsWith   = "BeginsWith";
    String sMatrixEndsWith     = "EndsWith";
    String sMatrixEquals       = "Equals";
    String sMatrixDoesNotEqual = "DoesNotEqual";
    String sMatrixIsBetween    = "IsBetween";
    String sMatrixIsAtMost     = "IsAtMost";
    String sMatrixIsAtLeast    = "IsAtLeast";
    String sMatrixIsMoreThan   = "IsMoreThan";
    String sMatrixIsLessThan   = "IsLessThan";
    String sMatrixIsOn         = "IsOn";
    String sMatrixIsOnOrBefore = "IsOnOrBefore";
    String sMatrixIsOnOrAfter  = "IsOnOrAfter";

    String sMatrixIncludesTrans     = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.Includes",languageStr);
    String sMatrixIsExactlyTrans    = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.IsExactly",languageStr);
    String sMatrixIsNotTrans        = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.IsNot",languageStr);
    String sMatrixMatchesTrans      = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.Matches",languageStr);
    String sMatrixBeginsWithTrans   = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.BeginsWith", languageStr);
    String sMatrixEndsWithTrans     = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.EndsWith",languageStr);
    String sMatrixEqualsTrans       = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.Equals",languageStr);
    String sMatrixDoesNotEqualTrans = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.DoesNotEqual",languageStr);
    String sMatrixIsBetweenTrans    = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.IsBetween",languageStr);
    String sMatrixIsAtMostTrans     = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.IsAtMost",languageStr);
    String sMatrixIsAtLeastTrans    = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.IsAtLeast",languageStr);
    String sMatrixIsMoreThanTrans   = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.IsMoreThan",languageStr);
    String sMatrixIsLessThanTrans   = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.IsLessThan",languageStr);
    String sMatrixIsOnTrans         = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.IsOn",languageStr);
    String sMatrixIsOnOrBeforeTrans = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.IsOnOrBefore",languageStr);
    String sMatrixIsOnOrAfterTrans  = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.IsOnOrAfter",languageStr);

    String sOption             = "";
    String sFiller             = "";

    //Array to find the max length of the options
    String sArrayOperator []   = { sMatrixIncludes,sMatrixIsExactly,sMatrixIsNot,sMatrixMatches,
                                   sMatrixBeginsWith,sMatrixEndsWith,sMatrixEquals,sMatrixDoesNotEqual,
                                   sMatrixIsBetween,sMatrixIsAtMost,sMatrixIsAtLeast,sMatrixIsMoreThan,
                                   sMatrixIsLessThan,sMatrixIsOn,sMatrixIsOnOrBefore,sMatrixIsOnOrAfter};
    int iMax    = 0;
    int iIndex  = 0;

    //To get the parameters passed
    Enumeration eNumObj     = emxGetParameterNames(request);
    Vector  vectParamName   = new Vector();
    String sParam           = "";
    if(eNumObj!=null) {
      while (eNumObj.hasMoreElements()) {
        sParam = (String)eNumObj.nextElement();
        vectParamName.add(sParam);
      }
    }
    //To store the Attribute's name,data type and the value.
    Vector vectHolder             = new Vector();
    //To store the Attribute's choices.
    StringList sListAttribute     = null;

    StringBuffer sbStrInclude     = null;
    StringBuffer sbRealInclude    = null;
    StringBuffer sbTimeInclude    = null;
    StringBuffer sbBooleanInclude = null;

    StringList arrlistAttTypeBoolean =new StringList();
    String sAttTypeBooleanValues ="";

    //To find the max length of the options.
    for (int i = 0; i < (sArrayOperator.length)-1; i++) {
      for (int j = i+1;j<sArrayOperator.length; j++) {
        if (sArrayOperator[i].length() < sArrayOperator[j].length()) {
          iMax = sArrayOperator[j].length();
        }
      }
    }

    //To Create fill space to equalize all drop downs for descriptors
    //and add 12 because &nbsp not = to constant #
    iMax = iMax+20;
    while (iIndex != iMax) {
      sFiller += "&nbsp;";
      iIndex++;
    }
    BusinessType btType              = new BusinessType(sBizType,context.getVault());
    btType.open(context, false);
    //To get the Find Like information of the business type selected

    matrix.db.FindLikeInfo flLikeObj = btType.getFindLikeInfo(context);
    btType.close(context);
    //To get the attribute list of the business type
    AttributeList attrListObj        = flLikeObj.getAttributes();
    AttributeItr attrItrObj          = new AttributeItr(attrListObj);

    String sName      = "";
    String sDataType  = "";


    if(sShowHiddenAttr == null)  {
      sShowHiddenAttr ="";
    }else if(sShowHiddenAttr.equals("null")) {
      sShowHiddenAttr ="";
    }

    while (attrItrObj.next()) {
      sListAttribute    = new StringList();

      Attribute attrObj = attrItrObj.obj();
      //Store name of the attribute in vector if Attribute is not hidden
      sName             = attrObj.getName();
      if(sShowHiddenAttr.equals("TRUE") || !FrameworkUtil.isAttributeHidden(context, sName)) {
        vectHolder.addElement(sName);

        //To get the attribute choices
        if (attrObj.hasChoices()) {
          sListAttribute  = attrObj.getChoices();
          vectHolder.addElement(sListAttribute);
        } else {
          vectHolder.addElement(sListAttribute);
        }

        //To get the Data type of the attribute
        AttributeType attrTypeObj = attrObj.getAttributeType();
        attrTypeObj.open(context);
        sDataType                 = attrTypeObj.getDataType();
        attrTypeObj.close(context);
        //Store datatype in vector
        vectHolder.addElement(sDataType);
      }
    }

    //Get states for the Business Type and add it to the vector
    //StringList sListStates = flLikeObj.getStates();

    // To add the Modified basics in the vector to search
    vectHolder.addElement("Modified");
    vectHolder.addElement(null);
    vectHolder.addElement("timestamp");

    // To add the Modified basics in the vector to search
    vectHolder.addElement("Originated");
    vectHolder.addElement(null);
    vectHolder.addElement("timestamp");

    //To add the Policy basics in the vector to search
    StringList sListPolicy = new StringList();
    sListPolicy = flLikeObj.getPolicies();

    Hashtable statesTable = getStateNames(context, btType, sListPolicy, languageStr);
    Enumeration objEnum = statesTable.keys();

    StringList sListVault    = new StringList();
    //To add the Vault basics in the vector to search
    vectHolder.addElement("Vault");
    vectHolder.addElement(sListVault);
    vectHolder.addElement("string");

    //  Create Drop downs for Data types of the Attribute
    sOption             = "<option name=blank value=\"*\">"+sFiller+"</option><option name='";

    //To set options for string data type
    sbStrInclude    = new StringBuffer(sOption);
    sbStrInclude.append(sMatrixBeginsWith + "' value='" + sMatrixBeginsWith + "'>" + sMatrixBeginsWithTrans + " </option>");
    sbStrInclude.append("<option name='" + sMatrixEndsWith + "' value='" + sMatrixEndsWith + "'>" + sMatrixEndsWithTrans + " </option>");
    sbStrInclude.append("<option name='" + sMatrixIncludes + "' value='" + sMatrixIncludes + "'>" + sMatrixIncludesTrans + " </option>");
    sbStrInclude.append("<option name='" + sMatrixIsExactly + "' value='" + sMatrixIsExactly + "'>" + sMatrixIsExactlyTrans + " </option>");
    sbStrInclude.append("<option name='" + sMatrixIsNot + "' value='" + sMatrixIsNot + "'>" + sMatrixIsNotTrans + " </option>");
    sbStrInclude.append("<option name='" + sMatrixMatches + "' value='" + sMatrixMatches + "'>" + sMatrixMatchesTrans + " </option>");

    //To set options for numeric data type
    sbRealInclude   = new StringBuffer(sOption);
    sbRealInclude.append(sMatrixIsAtLeast + "' value='" + sMatrixIsAtLeast + "'>" + sMatrixIsAtLeastTrans + "</option>");
    sbRealInclude.append("<option name='" + sMatrixIsAtMost + "' value='" + sMatrixIsAtMost + "'>" + sMatrixIsAtMostTrans + "</option>");
    sbRealInclude.append("<option name='" + sMatrixDoesNotEqual + "' value='" + sMatrixDoesNotEqual + "'>" + sMatrixDoesNotEqualTrans + "</option>");
    sbRealInclude.append("<option name='" + sMatrixEquals + "' value='" + sMatrixEquals + "'>" + sMatrixEqualsTrans + "</option>");
    sbRealInclude.append("<option name='" + sMatrixIsBetween + "' value='" + sMatrixIsBetween + "'>" + sMatrixIsBetweenTrans + "</option>");
    sbRealInclude.append("<option name='" + sMatrixIsLessThan + "' value='" + sMatrixIsLessThan + "'>" + sMatrixIsLessThanTrans + "</option>");
    sbRealInclude.append("<option name='" + sMatrixIsMoreThan + "' value='" + sMatrixIsMoreThan + "'>" + sMatrixIsMoreThanTrans + "</option>");

    //To set options for date/time data type
    sbTimeInclude   = new StringBuffer(sOption);
    sbTimeInclude.append(sMatrixIsOn + "' value='" + sMatrixIsOn + "'>" + sMatrixIsOnTrans + "</option>");
    sbTimeInclude.append("<option name='" + sMatrixIsOnOrBefore + "' value='" + sMatrixIsOnOrBefore + "'>" + sMatrixIsOnOrBeforeTrans + "</option>");
    sbTimeInclude.append("<option name='" + sMatrixIsOnOrAfter + "' value='" + sMatrixIsOnOrAfter + "'>" + sMatrixIsOnOrAfterTrans + "</option>");


    //To set options for boolean data type
    sbBooleanInclude    = new StringBuffer(sOption);
    sbBooleanInclude.append(sMatrixIsExactly + "' value='" + sMatrixIsExactly + "'>" + sMatrixIsExactlyTrans + " </option>");
    sbBooleanInclude.append("<option name='" + sMatrixIsNot + "' value='" + sMatrixIsNot + "'>" + sMatrixIsNotTrans + " </option>");


%>
    &nbsp;
    <table class="list" id="UITable">
      <tr>
        <!-- XSSOK -->
        <th nowrap="nowrap"><%=EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.Field",languageStr)%></th>
        <!-- XSSOK -->
        <th nowrap="nowrap"><%=EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.Operator",languageStr)%></th>
        <!-- XSSOK -->
        <th nowrap="nowrap"><%=EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.EnterValue",languageStr)%></th>
        <!-- XSSOK -->
        <th nowrap="nowrap"><%=EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.SelectValue",languageStr)%></th>
      </tr>
    <tr>
<%
     String sComboval  = "comboDescriptor_Name";
     String sTxtVal    = "txt_Name";
     String sTxtOrgVal   = "";
     String sComboOrgval = "";
     String sOrgVal      = "";

     sTxtOrgVal = emxGetParameter(request, sTxtVal);
     sComboOrgval = emxGetParameter(request, sComboval);

     sTxtOrgVal = sTxtOrgVal == null ? "" : sTxtOrgVal;
     sComboOrgval = sComboOrgval == null ? "" : sComboOrgval;
     StringBuffer sbSelect = new StringBuffer(sbStrInclude.toString());
     if(sComboOrgval.length() > 2) {
       sbSelect = new StringBuffer(sbStrInclude.toString());
           int ilength           = sbSelect.toString().indexOf(sComboOrgval);
           int iClength          = sComboOrgval.length();
           int iActlen           = ilength + 10+2*iClength;

           sbSelect.insert(iActlen," selected");
     }

 %>
 	  <!-- XSSOK -->
      <td class="label" ><%=i18nNow.getBasicI18NString("Name",  languageStr)%></td>
      <td class="field"  ><select name="comboDescriptor_Name">
      <!-- XSSOK -->
      <%=sbSelect.toString()%></select></td>
      <td class="field" colspan=2 ><input type="text" name="txt_Name" id="txt_Name" value="<xss:encodeForHTMLAttribute><%=sTxtOrgVal%></xss:encodeForHTMLAttribute>" /></td>
    </tr>
    <tr>
<%
    sComboval  = "comboDescriptor_Revision";
    sTxtVal    = "txt_Revision";
    sTxtOrgVal   = "";
    sComboOrgval = "";
    sOrgVal      = "";

    sTxtOrgVal = emxGetParameter(request, sTxtVal);
    sComboOrgval = emxGetParameter(request, sComboval);

    sTxtOrgVal = sTxtOrgVal == null ? "" : sTxtOrgVal;
    sComboOrgval = sComboOrgval == null ? "" : sComboOrgval;
    sbSelect = new StringBuffer(sbStrInclude.toString());
    if(sComboOrgval.length() > 2) {
       sbSelect = new StringBuffer(sbStrInclude.toString());
        int ilength           = sbSelect.toString().indexOf(sComboOrgval);
        int iClength          = sComboOrgval.length();
        int iActlen           = ilength + 10+2*iClength;

        sbSelect.insert(iActlen," selected");
    }
%>	  <!-- XSSOK -->
      <td class="label" ><%=i18nNow.getBasicI18NString("Revision",  languageStr)%></td>
      <td class="field"  ><select name="comboDescriptor_Revision">
      <!-- XSSOK -->
      <%=sbSelect.toString()%></select></td>
      <td class="field" colspan=2 ><input type="text" name="txt_Revision" id="txt_Revision" value="<xss:encodeForHTMLAttribute><%=sTxtOrgVal%></xss:encodeForHTMLAttribute>" /></td>
    </tr>
    <tr>
<%
    sComboval  = "comboDescriptor_Description";
    sTxtVal    = "txt_Description";
    sTxtOrgVal   = "";
    sComboOrgval = "";
    sOrgVal      = "";

    sTxtOrgVal = emxGetParameter(request, sTxtVal);
    sComboOrgval = emxGetParameter(request, sComboval);

    sTxtOrgVal = sTxtOrgVal == null ? "" : sTxtOrgVal;
    sComboOrgval = sComboOrgval == null ? "" : sComboOrgval;
    sbSelect = new StringBuffer(sbStrInclude.toString());
    if(sComboOrgval.length() > 2) {
       sbSelect = new StringBuffer(sbStrInclude.toString());
        int ilength           = sbSelect.toString().indexOf(sComboOrgval);
        int iClength          = sComboOrgval.length();
        int iActlen           = ilength + 10+2*iClength;

        sbSelect.insert(iActlen," selected");
    }
%>	  <!-- XSSOK -->
      <td class="label"><%=i18nNow.getBasicI18NString("Description",  languageStr)%></td>
      <td class="field"  ><select name="comboDescriptor_Description">
      <!-- XSSOK -->
      <%=sbSelect.toString()%></select></td>
      <td class="field" colspan=2 ><input type="text" name="txt_Description" id="txt_Description" value="<xss:encodeForHTMLAttribute><%=sTxtOrgVal%></xss:encodeForHTMLAttribute>" /></td>
    </tr>
    <tr>
<%
    sComboval  = "comboDescriptor_Owner";
    sTxtVal    = "txt_Owner";
    sTxtOrgVal   = "";
    sComboOrgval = "";
    sOrgVal      = "";

    sTxtOrgVal = emxGetParameter(request, sTxtVal);
    sComboOrgval = emxGetParameter(request, sComboval);

    sTxtOrgVal = sTxtOrgVal == null ? "" : sTxtOrgVal;
    sComboOrgval = sComboOrgval == null ? "" : sComboOrgval;
    sbSelect = new StringBuffer(sbStrInclude.toString());
    if(sComboOrgval.length() > 2) {
       sbSelect = new StringBuffer(sbStrInclude.toString());
        int ilength           = sbSelect.toString().indexOf(sComboOrgval);
        int iClength          = sComboOrgval.length();
        int iActlen           = ilength + 10+2*iClength;

        sbSelect.insert(iActlen," selected");
    }
%>	<!-- XSSOK -->
      <td class="label" ><%=i18nNow.getBasicI18NString("Owner",  languageStr)%></td>
      <td class="field"  ><select name="comboDescriptor_Owner">
      <!-- XSSOK -->
      <%=sbSelect.toString()%></select></td>
      <td class="field" colspan=2 ><input type="text" name="txt_Owner" id="txt_Owner" value="<xss:encodeForHTMLAttribute><%=sTxtOrgVal%></xss:encodeForHTMLAttribute>" /></td>
    </tr>
    <tr>
<%
    sComboval  = "comboDescriptor_Current";
    sTxtVal    = "txt_Current";
    String sCmbVal = "Current";
    String sCmbOrgVal = "";
    sTxtOrgVal = emxGetParameter(request, sTxtVal);
    sComboOrgval = emxGetParameter(request, sComboval);
    sCmbOrgVal = emxGetParameter(request, sCmbVal);

    sTxtOrgVal = sTxtOrgVal == null ? "" : sTxtOrgVal;
    sComboOrgval = sComboOrgval == null ? "" : sComboOrgval;
    sCmbOrgVal = sCmbOrgVal == null ? "" : sCmbOrgVal;

    sbSelect = new StringBuffer(sbStrInclude.toString());
    if(sComboOrgval.length() > 2) {
       sbSelect = new StringBuffer(sbStrInclude.toString());
        int ilength           = sbSelect.toString().indexOf(sComboOrgval);
        int iClength          = sComboOrgval.length();
        int iActlen           = ilength + 10+2*iClength;

        sbSelect.insert(iActlen," selected");
    }
%>	<!-- XSSOK -->
      <td class="label" ><%=i18nNow.getBasicI18NString("Current",  languageStr)%></td>
      <td class="field"  ><select name="comboDescriptor_Current">
      <!-- XSSOK -->
      <%=sbSelect.toString()%></select></td>
      <td class="field"  ><input type="text" name="txt_Current" id="txt_Current" value="<xss:encodeForHTMLAttribute><%=sTxtOrgVal%></xss:encodeForHTMLAttribute>" /></td>
      <td class="field" ><select name="Current">
      <option value=""></option>
<%
        // Modified/Added for bug no. 305777
        String stateRealName = "";
        String stateDisplayName = "";

        while(objEnum.hasMoreElements())
        {
           stateRealName = (String)objEnum.nextElement();
           stateDisplayName = (String)statesTable.get(stateRealName);
%>		<!-- XSSOK -->
       <option value="<%=stateRealName%>" "<%=stateRealName.equals(sCmbOrgVal)? "selected" : ""%>"><%=stateDisplayName%></option>
<%
       }
%>
      </select></td>
    </tr>
<%
    String sAttName    = "";
    String sAttType    = "";



    for (iIndex = 0; iIndex < vectHolder.size(); iIndex = iIndex+3) {
      sAttName = (String) vectHolder.elementAt(iIndex);
      
      if (sBizType.equals(typeECO) && sAttName.equals(attrPriority)) {
          continue;
      }
      
      String sCombovalue  = "comboDescriptor_"+sAttName;
      String sTxtvalue    = "txt_"+sAttName;
      sTxtOrgVal   = "";
      sComboOrgval = "";
      sOrgVal      = "";

      if (vectParamName.contains(sTxtvalue)) {
        sTxtOrgVal=emxGetParameter(request, sTxtvalue);
      }
      if (vectParamName.contains(sCombovalue)) {
        sComboOrgval=emxGetParameter(request, sCombovalue);
      }
      if (vectParamName.contains(sAttName)) {
        sOrgVal=emxGetParameter(request, sAttName);
      }
      if(!sAttName.equalsIgnoreCase("Vault")) {
%>
      <tr>
<%
        if (sAttName.equals("Modified") || sAttName.equals("Originated")) {
%>	<!-- XSSOK -->
            <td class="label"><%=i18nNow.getBasicI18NString( sAttName,  languageStr)%>&nbsp;</td>
<%
        }else {
        	if (sAttName.equals(effectivityDate)) {
%>  
                <td class="label"><emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.TargetReleaseDate</emxUtil:i18nScript>&nbsp;</td>
<%        		
        	} else {
%><!-- XSSOK -->
                <td class="label"><%=i18nNow.getAttributeI18NString( sAttName,  languageStr)%>&nbsp;</td>
<%          }
        }
%><!-- XSSOK -->
        <td class="field" align="left"><select name="comboDescriptor_<%=sAttName%>" size="1">
<%
       sAttType = (String)vectHolder.elementAt(iIndex+2);
       if (sAttType.equals("string")) {
         if (sComboOrgval.length() > 2) {
           sbSelect = new StringBuffer(sbStrInclude.toString());
           int ilength           = sbSelect.toString().indexOf(sComboOrgval);
           int iClength          = sComboOrgval.length();
           int iActlen           = ilength + 10+2*iClength;

          sbSelect.insert(iActlen," selected");
%><!-- XSSOK -->
          <%=sbSelect%></select></td>
<%
        }else {
%><!-- XSSOK -->
        <%=sbStrInclude%></select></td>
<%      }
      }else if ((sAttType.equals("real")) || (sAttType.equals("integer"))) {
        if (sComboOrgval.length() > 2) {
          sbSelect = new StringBuffer(sbRealInclude.toString());
          int ilength           = sbSelect.toString().indexOf(sComboOrgval);
          int iClength          = sComboOrgval.length();
          int iActlen           = ilength + 10+2*iClength;

          sbSelect.insert(iActlen," selected");

%><!-- XSSOK -->
          <%=sbSelect%></select></td>
<%
        }else {
%><!-- XSSOK -->
          <%=sbRealInclude%></select></td>
<%
        }
      }else if (sAttType.equals("timestamp")) {
        String sAttValue = "";
        if (sComboOrgval.length() > 2) {
          sbSelect = new StringBuffer(sbTimeInclude.toString());
          int ilength           = sbSelect.toString().indexOf(sComboOrgval);
          int iClength          = sComboOrgval.length();
          int iActlen           = ilength + 10+2*iClength;

          sbSelect.insert(iActlen," selected");

%><!-- XSSOK -->
          <%=sbSelect%></select></td>
<%
        }else {
%><!-- XSSOK -->
          <%=sbTimeInclude%></select></td>
<%
        }

        if (emxGetParameter(request, sAttName)!= null) {
          sAttValue = emxGetParameter(request, sAttName);
          sAttValue = sAttValue== null ? "" : sAttValue;
          Locale locale1 = request.getLocale();
          double iClientTimeOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();
          
        }
%><!-- XSSOK -->
        <td  nowrap align="left"  class="field" ><input type="text" name="<%=sAttName%>" id="<%=sAttName%>" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=sAttValue%></xss:encodeForHTMLAttribute>">&nbsp;&nbsp;<a href='javascript:showCalendar("findLikeForm","<%=sAttName%>","<xss:encodeForHTMLAttribute><%=sAttValue%></xss:encodeForHTMLAttribute>");'><img src="../common/images/iconSmallCalendar.gif" border="0" /></a></td>

<%
      }else if (sAttType.equals("boolean")) {
        if (sComboOrgval.length() > 2) {
          sbSelect = new StringBuffer(sbBooleanInclude.toString());
          int ilength           = sbSelect.toString().indexOf(sComboOrgval);
          int iClength          = sComboOrgval.length();
          int iActlen           = ilength + 10+2*iClength;

          sbSelect.insert(iActlen," selected");

%><!-- XSSOK -->
          <%=sbSelect%></select></td>
<%
        }else {
%><!-- XSSOK -->
          <%=sbBooleanInclude%></select></td>
<%
        }
      }

      if (!sAttType.equals("timestamp")) {
%>  <!-- XSSOk -->
        <td align="left"  class="field" ><input type="text" name="txt_<%=sAttName%>" id="txt_<%=sAttName%>" value="<xss:encodeForHTMLAttribute><%=sTxtOrgVal%></xss:encodeForHTMLAttribute>" /></td>
<%
      }
%>
      <td  class="field" >
<%
      //To get the attribute value's  choices
      StringList sListAttrVal = null;
	  String trueString = "";
	  String falseString = "";
      if(sAttType.equalsIgnoreCase("boolean")) {
        sListAttrVal = new StringList(2);
        trueString = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.True",request.getHeader("Accept-Language"));
        falseString = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.False",request.getHeader("Accept-Language"));
        sAttTypeBooleanValues=trueString +"," + falseString ;
        arrlistAttTypeBoolean.add(sAttName);

        sListAttrVal.addElement(trueString);
        sListAttrVal.addElement(falseString);

      } else {
        sListAttrVal  = (StringList)(vectHolder.elementAt(iIndex+1));
      }
      if ((sListAttrVal != null) && (sListAttrVal.size() != 0)) {
        StringItr sItrObj     = new StringItr(sListAttrVal);
%><!-- XSSOK -->
          <select name="<%=sAttName%>"  size="1"><option name="" value="">
<%
        while (sItrObj.next()) {
          String sSelect  = "";
          String sTempStr = sItrObj.obj();
          if (sTempStr.equals(sOrgVal)) {
            sSelect = "selected";
          }
          if(sAttName.equals(estimatedCost)){
%><!-- XSSOK -->
              <option value="<%=sTempStr%>" <%=sSelect%> ><%=sTempStr%></option>
<%
          } else{
              if(sTempStr.equals(trueString)){
            	//XSSOK
%>                  <option value="true" <%=sSelect%> ><%=i18nNow.getRangeI18NString(sAttName, sTempStr.trim(), languageStr)%></option>
<%            }
              else if(sTempStr.equals(falseString)){
            	//XSSOK
%>                  <option value="false" <%=sSelect%> ><%=i18nNow.getRangeI18NString(sAttName, sTempStr.trim(), languageStr)%></option>
<%            }
              else{
%>				<!-- XSSOK -->
                  <option value="<%=sTempStr%>" <%=sSelect%> ><%=i18nNow.getRangeI18NString(sAttName, sTempStr.trim(), languageStr)%></option>
<%                 
              }
          }
       }
%>
       </select>
<%
      }else {
%>
        &nbsp;
<%
      }
%>
      </td>
    </tr>
<%
      }else {
        // Vault awareness check
        String companyVault = (String)session.getAttribute("emxEngineeringCentral.companyVault");
        if(companyVault != null) {
%>
            <input type="hidden" name="comboDescriptor_Vault" value="Matches" />
            <input type="hidden" name="Vault" value="<xss:encodeForHTMLAttribute><%=companyVault%></xss:encodeForHTMLAttribute>" />
<%
        }else {
%>
    <tr>
    <!-- XSSOK -->
      <td class="label"><%=i18nNow.getBasicI18NString( sAttName,  languageStr)%>&nbsp;</td>
      <!-- XSSOK -->
      <td class="field" align="left"><select name="comboDescriptor_<%=sAttName%>" size="1">
<%
          if (sComboOrgval.length() > 2) {
            sbSelect = new StringBuffer(sbStrInclude.toString());
            int ilength           = sbSelect.toString().indexOf(sComboOrgval);
            int iClength          = sComboOrgval.length();
            int iActlen           = ilength + 10+2*iClength;

            sbSelect.insert(iActlen," selected");
%>		<!-- XSSOK -->
          <%=sbSelect%></select></td>
<%
          }else {
%><!-- XSSOK -->
          <%=sbStrInclude%></select></td>
<%
          }
%>
      <td align="left"  class="field" ><input type="text" name="txt_<%=sAttName%>" id="txt_<%=sAttName%>" value="<xss:encodeForHTMLAttribute><%=sTxtOrgVal%></xss:encodeForHTMLAttribute>" /></td>
      <td class="inputField">
        <table  class="list" id="UITable">
          <tr>
            <td>
            <!-- XSSOK -->
              <input type="radio" <%=allCheck%> value="ALL_VAULTS" name="Vault" onClick="javascript:clearSelectedVaults();" />
            </td>
            <!-- XSSOK -->
            <td><%=i18nNow.getI18nString("emxEngineeringCentral.VaultOptions.All", "emxEngineeringCentralStringResource", languageStr)%></td>
          </tr>
          <tr>
            <td>
            <!-- XSSOK -->
              <input type="radio"  <%=localCheck%> value="LOCAL_VAULTS" name="Vault" onClick="javascript:clearSelectedVaults();" />
            </td>
            <!-- XSSOK -->
            <%--Multitenant--%>
            <%-- <td><%=i18nNow.getI18nString("emxEngineeringCentral.VaultOptions.Local", "emxEngineeringCentralStringResource", languageStr)%></td>--%>
            <td><%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.VaultOptions.Local")%></td>
          </tr>
          <tr>
            <td>
            <!-- XSSOK -->
              <input type="radio" <%=defaultCheck%> value="DEFAULT_VAULT" name="Vault" onClick="javascript:clearSelectedVaults();" />
            </td>
            <!-- XSSOK -->
            <%--Multitenant--%>
            <%-- <td><%=i18nNow.getI18nString("emxEngineeringCentral.VaultOptions.Default", "emxEngineeringCentralStringResource", languageStr)%></td>--%>
            <td><%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.VaultOptions.Default")%></td>
          </tr>
          <tr>
            <td>
            <!-- XSSOK -->
              <input type="radio" <%=selectedVaults%> value="<%=selectedVaultsValue%>" name="<%=sAttName%>" onClick="javascript:showSelectedVaults();" />
            </td>
            <td>
            <!-- XSSOK -->
              <%--Multitenant--%>
            <%--<%=i18nNow.getI18nString("emxEngineeringCentral.VaultOptions.Selected", "emxEngineeringCentralStringResource", languageStr)%>--%>
              <%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.VaultOptions.Selected")%>
              <input type="text" name="selVaults" id="selVaults" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=selectedVaultsValue%></xss:encodeForHTMLAttribute>" />
              <input class="button" type="button" name="VaultSelector" size = "200" value="..." alt="..." onClick="javascript:showVaultSelector();selectSelectedVaultsOption()" />
              <input type="hidden" name="tempStore" value="<xss:encodeForHTMLAttribute><%=selectedVaultsValue%></xss:encodeForHTMLAttribute>" />
            </td>
           </tr>
        </table>
      </td>
    </tr>
<%
        }
      }
    }
%>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId" >emxEngineeringCentral.FindLike.Keyword</emxUtil:i18n></td>
      <td class="field" colspan="3"><input type="text" name="txtKeyword" id="txtKeyword" value="<xss:encodeForHTMLAttribute><%=sTxtKeyword%></xss:encodeForHTMLAttribute>" /></td>
    </tr>
    <tr>
      <td class="label"><emxUtil:i18n localize="i18nId" >emxEngineeringCentral.Common.Format</emxUtil:i18n></td>
      <td colspan="3"  class="field" >
        <select name="comboFormat" >
          <option value="*"></option>
<%
        String sFormatName = "";
        matrix.db.FormatItr formatItr   = new matrix.db.FormatItr(matrix.db.Format.getFormats(context));
        //iterate through and list all the formats
        while (formatItr.next()) {
          sFormatName = (formatItr.obj()).getName();
          sSelected = "";
          if (sFormatName.equals(sFormat)) {
            sSelected = "selected";
          }
%>    <!-- XSSOK -->
              <option value= "<%=sFormatName%>" <%=sSelected%>><%=sFormatName%></option>
<%
        }
%>
        </select>
       </td>
    </tr>
  </table>


<script language="javascript">
function checkBooleanAttributes() {
<%
       //if attribute Type is boolean it contain attribute names else zero
       int arrSize=arrlistAttTypeBoolean.size();
       if(arrSize>0) {
           
           //Added for BUG 356326-Starts
           String trueString = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.True","en");
           String falseString = EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.FindLike.False","en");
           String sAttTypeTempBooleanValues=trueString +"," + falseString ;
%>              
//XSSOK
	var booleanAttributesList = "<%=FrameworkUtil.join(arrlistAttTypeBoolean,",")%>" ;
//XSSOK	
	var booleanValues = "<%=sAttTypeTempBooleanValues%>" ;
           //Added for BUG 356326-Ends
	
	//contain true and false values
	var arrayBooleanValue = booleanValues.split(",");
	var arrayAttrBoolean = booleanAttributesList.split(",");
	for(var i=0;i<arrayAttrBoolean.length;i++) {
	    var txtFieldVal = document.findLikeForm.elements['txt_'+arrayAttrBoolean[i]].value;
	    if(txtFieldVal.length >0) {
		if(txtFieldVal.toUpperCase() != arrayBooleanValue[0] &&
				    txtFieldVal.toUpperCase() != arrayBooleanValue[1] ) {
		    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.PartFamilyNameGeneratorOn.PleaseEnterBooleanValue</emxUtil:i18nScript>");
		   document.findLikeForm.elements['txt_'+arrayAttrBoolean[i]].focus();
		   return false;
		}else {
		   continue;
		}
	   }
	}

<%
    }
%>
return true;
}//end of function
</script>

<%
  }
%>
  <input type="image" name="inputImage" height="1" width="1" src="../common/images/utilSpacer.gif" hidefocus="hidefocus" style="-moz-user-focus: none" />
  <input type="hidden" name="targetSearchPage" value="<xss:encodeForHTMLAttribute><%=targetSearchPage%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="page1Heading" value="<xss:encodeForHTMLAttribute><%=page1Heading%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="page2Heading" value="<xss:encodeForHTMLAttribute><%=page2Heading%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="omitSpareParts" value="<xss:encodeForHTMLAttribute><%=omitSpareParts%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="omitAllRevisions" value="<xss:encodeForHTMLAttribute><%=omitAllRevisions%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="AVLReport" value="<xss:encodeForHTMLAttribute><%=isAVLReport%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="searchType" value="<xss:encodeForHTMLAttribute><%=searchType%></xss:encodeForHTMLAttribute>" />

  <input type="hidden" name="targetResultsPage" value="<xss:encodeForHTMLAttribute><%=targetResultsPage%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="multiSelect" value="<xss:encodeForHTMLAttribute><%=multiSelect%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="table" value="<xss:encodeForHTMLAttribute><%=table%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="program" value="<xss:encodeForHTMLAttribute><%=program%></xss:encodeForHTMLAttribute>" />

</form>
</body>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
<%!

    /**
     * Get a list of all the states related to an object for each of the policies
     * of the object type itself or derived/child types
     * @param context the current user
     * @param Business Type. Business type of the object selected
     * @param policy The list of policies to get the states for
     * @param language for internationalization
     * @return a Hashtable of states with display and real values
     */
    private static Hashtable getStateNames(Context context, BusinessType busType, StringList policyList, String languageStr)
    throws Exception
    {
        // get a list of all derived types
        BusinessTypeList busTypeList = busType.getChildren(context);
        String policyName = "";
        String sPolicy = "";
        String sState = "";
        String results = "";
        StringList statesList = new StringList();
        Hashtable returnTable = new Hashtable();
        int busTypeListSize = busTypeList.size();
        if(policyList == null)
        {
            policyList = new StringList();
        }
        // foreach derived type get a list of all related policies
        for (int i=0; i<busTypeListSize; i++)
        {
            BusinessType childBusType = (BusinessType)busTypeList.get(i);
            PolicyList childPolicyList = childBusType.getPolicies(context);
            int childPolicyListSize = childPolicyList.size();

            for (int j=0; j<childPolicyListSize; j++)
            {
                Policy childPolicy = (Policy)childPolicyList.get(j);
                policyName = childPolicy.getName();
                if (!policyList.contains(policyName))
                {
                    policyList.addElement(policyName);
                }
            }
        }
        int policyListSize = policyList.size();
        String stateDisplayName = "";

        for (int k=0; k < policyListSize; k++)
        {
            sPolicy = (String) policyList.get(k);
            results = MqlUtil.mqlCommand(context,"print policy $1 select $2 dump $3", sPolicy, "state", "|");
            statesList = FrameworkUtil.split(results, "|");
            int statesListSize = statesList.size();
            for (int l=0; l < statesListSize; l++)
            {
                sState = (String)statesList.get(l);
                if (!returnTable.containsKey(sState))
                {
                    stateDisplayName = (String)i18nNow.getStateI18NString(sPolicy, sState, languageStr);
                    returnTable.put(sState, stateDisplayName);
                }
            }

        }

        return returnTable;
    }

%>
