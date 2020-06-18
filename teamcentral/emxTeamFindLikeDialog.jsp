<%--  emxTeamFindLikeDialog.jsp   - This page allows the user to do advance search of any business type.
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

--%>

<%@ include file  = "eServiceUtil.inc" %>
<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>

<jsp:useBean id="emxMenuObject" class="com.matrixone.apps.framework.ui.UIMenu" scope="request"/>

<script language="JavaScript">
  function doSearch(){
    document.findLikeForm.submit();
  }

  //Function to reload the page
  function reload() {
    var varType     = document.findLikeForm.ComboType[document.findLikeForm.ComboType.selectedIndex].value;
    var varRepType  = "";
    var iCount      = 0;
    for (i = 0; i < varType.length; i++) {
      if (varType[i] == ' ') {
        varRepType += varType.substring(iCount,i) + "%20";
        iCount = i + 1 ;
      }
    }
    varRepType += varType.substring(iCount,varType.length);
    document.location.href = "emxQuoteFindLikeDialog.jsp?ComboType=" + varRepType;
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

      if (document.findLikeForm.elements[varCount].type == "select-one" && document.findLikeForm.elements[varCount].selectedIndex != 0
        && document.findLikeForm.elements[varCount].name != "ComboType") {
        document.findLikeForm.elements[varCount][0].selected = true;
      }
    }
  }

</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  String languageStr = request.getHeader("Accept-Language");
  String sLink = emxGetParameter(request,"page");

  // get the current suite properties.

  String sTypeValues = "";
  String sShowHidden = "FALSE";
  String sShowHiddenAttr = "FALSE";

  //To get the Business Type for search
  String sSearchType  = emxGetParameter(request,"searchType");
  String sBizType = emxGetParameter(request, "ComboType");
  String sBizTypeSymbolic = sBizType;
  String returnSearchFrameset = com.matrixone.apps.domain.util.XSSUtil.encodeForURL(emxGetParameter(request, "returnSearchFrameset"));

  String objectIconParam = emxGetParameter(request, "objectIcon");
  String objectIcon = "";
  if ((objectIconParam == null) || ("".equals(objectIconParam))){
    String mappedTypeName = emxMenuObject.getTypeToTreeNameMapping(sBizType);
    if (mappedTypeName != null){
    HashMap menuMap = emxMenuObject.getMenu(context,mappedTypeName );
    objectIcon = emxMenuObject.getSetting(menuMap, "Image");
      if (objectIcon != null){
        objectIcon = UINavigatorUtil.parseImageURL(context, objectIcon , "" );
      }
    }
  }else{
    objectIcon =  "../common/images/" + XSSUtil.encodeForHTMLAttribute(context, objectIconParam);
  }


  //get name from symbolic name
  sBizType = Framework.getPropertyValue(session,sBizType);

  if (sBizType == null) {
    sBizType   = "";
  }
  boolean useTitle = false;
  if(Framework.getPropertyValue(session, "type_Document").equals(sBizType)) {
    useTitle = true;
  }

  String sTypeVal            = "";
  String sTruncVal           = "";


  int iCount = 0;
  BusinessTypeItr btItrObj = null;
  StringList sListType = new StringList();

  //If the TypeNames property value is not set then get all the business types
  if(sTypeValues == null || sTypeValues.trim().equals("")) {

    // Set the show hidden types flag value from the properties.
    boolean bShowHiddenTypes = false;
    if(sShowHidden != null) {
      if(sShowHidden.equals("TRUE")) {
        bShowHiddenTypes = true;
      }
    }

    //To get the business type list from the context
    BusinessTypeList btListObj = BusinessType.getBusinessTypes(context, bShowHiddenTypes);
    // To sort the business type in alphabetical order
    btListObj.sort();
    btItrObj   = new BusinessTypeItr(btListObj);
  }

  String sSelected           = "";
  String preTypeString = emxGetParameter(request,"typeString");
  String typeString = i18nNow.getI18nString(preTypeString,"emxTeamCentralStringResource",languageStr);
  
  
  
%>

<form name="findLikeForm" action="emxTeamFindLikeQueryFS.jsp" method="post" onSubmit="doSearch()" target="_parent" >
<input type="hidden" name="ComboTypeSymbolic" value="<xss:encodeForHTMLAttribute><%=sBizTypeSymbolic%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="ComboType" value="<xss:encodeForHTMLAttribute><%=sBizType%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="TypeString" value="<xss:encodeForHTMLAttribute><%=preTypeString%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="returnSearchFrameset" value="<xss:encodeForHTMLAttribute><%=returnSearchFrameset%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="page" value="<xss:encodeForHTMLAttribute><%=sLink%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="searchType" value="<xss:encodeForHTMLAttribute><%=sSearchType%></xss:encodeForHTMLAttribute>" />


 <input type="hidden" name="QueryLimit" value="" />
    
<table class="list">
  <tr>
    <td class="label"><%=i18nNow.getI18nString("emxTeamCentral.FindLike.Type","emxTeamCentralStringResource",languageStr)%></td>
    <td  class="inputField">
      <table border="0">
        <tr>
          <td>
          	<!-- //XSSOK -->
			<img src="<%=objectIcon%>" />&nbsp;<span class="object"><%=XSSUtil.encodeForHTML(context,typeString)%></span>
          </td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td  class="label"><%=i18nNow.getI18nString("emxTeamCentral.FindLike.CreatedAfter","emxTeamCentralStringResource",languageStr)%></td>
    <td class="inputField" >
      <input type="text" readonly="readonly" name = "dateBegin" value="" size="15" />
      <a href="javascript:showCalendar('findLikeForm','dateBegin',document.findLikeForm.dateBegin.value)"><img src="../common/images/iconSmallCalendar.gif" border="0" /></a>
    </td>
  </tr>
  <tr>
    <td  class="label"><%=i18nNow.getI18nString("emxTeamCentral.FindLike.CreatedBefore","emxTeamCentralStringResource",languageStr)%></td>
    <td class="inputField">
      <input type="text" readonly="readonly" name = "dateEnd" value="" size="15" />
      <a href="javascript:showCalendar('findLikeForm','dateEnd',document.findLikeForm.dateEnd.value)"><img src="../common/images/iconSmallCalendar.gif" border="0" /></a>
    </td>
  </tr>
</table>

<%
  if ((!sBizType.equals(""))) {

    String sTxtKeyword      = emxGetParameter(request, "txtKeyword");
    String sTxtFormat       = emxGetParameter(request, "txtFormat");
    String sFormat          = emxGetParameter(request, "comboFormat");

    if (sFormat == null){
      sFormat = "*";
    }
    if (sTxtFormat == null){
      sTxtFormat = "";
    }
    if (sTxtKeyword == null){
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

    String sMatrixIncludesTrans     = i18nNow.getI18nString("emxTeamCentral.FindLike.Includes","emxTeamCentralStringResource",languageStr);
    String sMatrixIsExactlyTrans    = i18nNow.getI18nString("emxTeamCentral.FindLike.IsExactly","emxTeamCentralStringResource",languageStr);
    String sMatrixIsNotTrans        = i18nNow.getI18nString("emxTeamCentral.FindLike.IsNot","emxTeamCentralStringResource",languageStr);
    String sMatrixMatchesTrans      = i18nNow.getI18nString("emxTeamCentral.FindLike.Matches","emxTeamCentralStringResource",languageStr);
    String sMatrixBeginsWithTrans   = i18nNow.getI18nString("emxTeamCentral.FindLike.BeginsWith","emxTeamCentralStringResource",languageStr);
    String sMatrixEndsWithTrans     = i18nNow.getI18nString("emxTeamCentral.FindLike.EndsWith","emxTeamCentralStringResource",languageStr);
    String sMatrixEqualsTrans       = i18nNow.getI18nString("emxTeamCentral.FindLike.Equals","emxTeamCentralStringResource",languageStr);
    String sMatrixDoesNotEqualTrans = i18nNow.getI18nString("emxTeamCentral.FindLike.DoesNotEqual","emxTeamCentralStringResource",languageStr);
    String sMatrixIsBetweenTrans    = i18nNow.getI18nString("emxTeamCentral.FindLike.IsBetween","emxTeamCentralStringResource",languageStr);
    String sMatrixIsAtMostTrans     = i18nNow.getI18nString("emxTeamCentral.FindLike.IsAtMost","emxTeamCentralStringResource",languageStr);
    String sMatrixIsAtLeastTrans    = i18nNow.getI18nString("emxTeamCentral.FindLike.IsAtLeast","emxTeamCentralStringResource",languageStr);
    String sMatrixIsMoreThanTrans   = i18nNow.getI18nString("emxTeamCentral.FindLike.IsMoreThan","emxTeamCentralStringResource",languageStr);
    String sMatrixIsLessThanTrans   = i18nNow.getI18nString("emxTeamCentral.FindLike.IsLessThan","emxTeamCentralStringResource",languageStr);
    String sMatrixIsOnTrans         = i18nNow.getI18nString("emxTeamCentral.FindLike.IsOn","emxTeamCentralStringResource",languageStr);
    String sMatrixIsOnOrBeforeTrans = i18nNow.getI18nString("emxTeamCentral.FindLike.IsOnOrBefore","emxTeamCentralStringResource",languageStr);
    String sMatrixIsOnOrAfterTrans  = i18nNow.getI18nString("emxTeamCentral.FindLike.IsOnOrAfter","emxTeamCentralStringResource",languageStr);

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


    if(sShowHiddenAttr == null )  {
      sShowHiddenAttr ="";
    } else if(sShowHiddenAttr.equals("null")) {
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
    StringList sListStates = flLikeObj.getStates();

    //To get the list of persons role and Groups
    StringList sListUser      = new StringList();
    StringList sListOwner     = new StringList();

    PersonList personListObj  = matrix.db.Person.getPersons(context, true);
    PersonItr personItrObj    = new PersonItr(personListObj);
    while (personItrObj.next()) {
      sListUser.addElement(personItrObj.obj().toString());
      sListOwner.addElement(personItrObj.obj().toString());
    }
    GroupList groupListObj    = Group.getGroups(context, true);
    GroupItr groupItrObj      = new GroupItr(groupListObj);
    while (groupItrObj.next()) {
      sListUser.addElement(groupItrObj.obj().toString());
      sListOwner.addElement(groupItrObj.obj().toString());
    }
    RoleList roleListObj      = Role.getRoles(context, true);
    RoleItr roleItrObj        = new RoleItr(roleListObj);

    while (roleItrObj.next()) {
      sListOwner.addElement(roleItrObj.obj().toString());
    }

    sListUser.sort();
    sListOwner.sort();

    //To add the Policy basics in the vector to search
    StringList sListPolicy = flLikeObj.getPolicies();
    String objectPolicy = (String)sListPolicy.elementAt(0);

    // get all the vaults into an iterator.
    VaultItr vaultItrObj     = new VaultItr(Vault.getVaults(context, true));
    StringList sListVault    = new StringList();
    while (vaultItrObj.next()) {
      sListVault.addElement((vaultItrObj.obj()).getName());
    }

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
    sbRealInclude.append("<option name='" + sMatrixMatches + "' value='" + sMatrixMatches + "'>" + sMatrixMatchesTrans + " </option>");

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
    <table class="list">
      <tr>
        <th><%=i18nNow.getI18nString("emxTeamCentral.FindLike.Field","emxTeamCentralStringResource",languageStr)%></th>
        <th><%=i18nNow.getI18nString("emxTeamCentral.FindLike.Operator","emxTeamCentralStringResource",languageStr)%></th>
        <th><%=i18nNow.getI18nString("emxTeamCentral.FindLike.Value","emxTeamCentralStringResource",languageStr)%></th>
      </tr>
    <tr  class="even" >
      <td  ><%=i18nNow.getBasicI18NString("Name",  sLanguage)%></td>
      <!-- //XSSOK -->
      <td   ><select name="comboDescriptor_Name"><%=sbStrInclude.toString()%></select></td>
      <td   ><input type="text" name="txt_Name"  value=""/></td>
    </tr>
    <tr  class="odd" >
      <td ><%=i18nNow.getBasicI18NString("Description",  sLanguage)%></td>
      <!-- //XSSOK -->
      <td   ><select name="comboDescriptor_Description"><%=sbStrInclude.toString()%></select></td>
      <td   ><input type="text" name="txt_Description"  value=""/></td>
    </tr>
    <tr  class="even" >
      <td ><%=i18nNow.getBasicI18NString("Revision",  sLanguage)%></td>
      <!-- //XSSOK -->
      <td  ><select name="comboDescriptor_Revision"><%=sbStrInclude.toString()%></select></td>
      <td  ><input type="text" name="txt_Revision"  value=""/></td>
    </tr>
    <tr  class="odd" >
      <td  ><%=i18nNow.getBasicI18NString("Owner",  sLanguage)%></td>
      <!-- //XSSOK -->
      <td  ><select name="comboDescriptor_Owner"><%=sbStrInclude.toString()%></select></td>
      <td  ><input type="text" name="txt_Owner"  value=""/></td>
    </tr>
<%
    //show Current option only if there are more than 1 state
    if(sListStates.size() > 1) {
%>
    <tr  class="even" >
      <td ><%=i18nNow.getBasicI18NString("Current",  sLanguage)%></td>
      <!-- //XSSOK -->
      <td ><select name="comboDescriptor_Current"><%=sbStrInclude.toString()%></select></td>
      <td ><select name="Current">
      <option value=""></option>
<%
       for (int i=0;i<sListStates.size();i++){
%>
       <option value="<%=XSSUtil.encodeForHTMLAttribute(context, (String)sListStates.elementAt(i))%>"><xss:encodeForHTML><%=i18nNow.getStateI18NString(objectPolicy,(String)sListStates.elementAt(i),sLanguage)%></xss:encodeForHTML></option>

<%
       }
%>
      </select></td>
    </tr>
<%
    }
    String sAttName    = "";
    String sAttType    = "";
    String rowClass = (sListStates.size() > 1) ? "odd" : "even";

    for (iIndex = 0; iIndex < vectHolder.size(); iIndex = iIndex+3) {
      sAttName = (String) vectHolder.elementAt(iIndex);
      String sCombovalue  = "comboDescriptor_"+sAttName;
      String sTxtvalue    = "txt_"+sAttName;
      String sTxtOrgVal   = "";
      String sComboOrgval = "";
      String sOrgVal      = "";

      if (vectParamName.contains(sTxtvalue)) {
        sTxtOrgVal=emxGetParameter(request, sTxtvalue);
      }
      if (vectParamName.contains(sCombovalue)) {
        sComboOrgval=emxGetParameter(request, sCombovalue);
      }
      if (vectParamName.contains(sAttName)) {
        sOrgVal=emxGetParameter(request, sAttName);
      }

      String i18nAttName = "";
      //if type is Document, dont show Title, instead show Title
      if(sAttName.equals(Framework.getPropertyValue(session, "attribute_Title")) && (useTitle)) {
        continue;
      } else {
        i18nAttName = i18nNow.getAttributeI18NString(sAttName, sLanguage);
      }
%><!-- //XSSOK -->
      <tr class="<%=rowClass%>" >
        <td ><xss:encodeForHTML><%=i18nAttName%></xss:encodeForHTML>&nbsp;</td>
<%
  String sComboName  = "comboDescriptor_"+sAttName;
  String sAttDisplay = "";
  sAttType = (String)vectHolder.elementAt(iIndex+2);
  if (sAttType.equals("timestamp")) {
    sAttDisplay = sAttName.replace(' ','_');
    sComboName  = "comboDescriptor_"+sAttDisplay;
  }

%>
        <!-- //XSSOK -->
		<td  align="left"><select name="<%=XSSUtil.encodeForHTMLAttribute(context, sComboName)%>" size="1">
<%

      if (sAttType.equals("string")) {
        if (sComboOrgval.length() > 2) {
          StringBuffer sbSelect = new StringBuffer(sbStrInclude.toString());
          int ilength           = sbSelect.toString().indexOf(sComboOrgval);
          int iClength          = sComboOrgval.length();
          int iActlen           = ilength + 10+2*iClength;

          sbSelect.insert(iActlen," selected");
%>
          <xss:encodeForHTML><%=sbSelect%></xss:encodeForHTML></select></td>
<%
         } else {
%>
          <!-- //XSSOK -->
          <%=sbStrInclude%></select></td>
<%      }
      } else if ((sAttType.equals("real")) || (sAttType.equals("integer")) ) {
        if (sComboOrgval.length() > 2) {
          StringBuffer sbSelect = new StringBuffer(sbRealInclude.toString());
          int ilength           = sbSelect.toString().indexOf(sComboOrgval);
          int iClength          = sComboOrgval.length();
          int iActlen           = ilength + 10+2*iClength;

          sbSelect.insert(iActlen," selected");

%>
          <xss:encodeForHTML><%=sbSelect%></xss:encodeForHTML></select></td>
<%
        } else {
%>
          <xss:encodeForHTML><%=sbRealInclude%></xss:encodeForHTML></select></td>
<%
        }
      } else if (sAttType.equals("timestamp")) {
        String sAttValue = "";
        if (sComboOrgval.length() > 2) {
          StringBuffer sbSelect = new StringBuffer(sbTimeInclude.toString());
          int ilength           = sbSelect.toString().indexOf(sComboOrgval);
          int iClength          = sComboOrgval.length();
          int iActlen           = ilength + 10+2*iClength;

          sbSelect.insert(iActlen," selected");

%>
          <xss:encodeForHTML><%=sbSelect%></xss:encodeForHTML></select></td>
<%
        } else {

%>
          <xss:encodeForHTML><%=sbTimeInclude%></xss:encodeForHTML></select></td>
<%
        }

        if (emxGetParameter(request, sAttName)!= null) {
          sAttValue = emxGetParameter(request, sAttName);
        }

%>
        <td  nowrap align="left" class="inputField" ><input type="text" readonly="readonly" name="<%=XSSUtil.encodeForHTMLAttribute(context,sAttDisplay)%>" id="test" value="<xss:encodeForHTMLAttribute><%=sAttValue%></xss:encodeForHTMLAttribute>" />&nbsp;&nbsp;<a href="javascript:showCalendar('findLikeForm','<%=XSSUtil.encodeForJavaScript(context,sAttDisplay)%>','<%=XSSUtil.encodeForJavaScript(context,sAttValue)%>');"><img src="../common/images/iconSmallCalendar.gif" border="0" /></a></td>
<%
      } else if (sAttType.equals("boolean")) {
        if (sComboOrgval.length() > 2) {
          StringBuffer sbSelect = new StringBuffer(sbBooleanInclude.toString());
          int ilength           = sbSelect.toString().indexOf(sComboOrgval);
          int iClength          = sComboOrgval.length();
          int iActlen           = ilength + 10+2*iClength;

          sbSelect.insert(iActlen," selected");

%>
          <xss:encodeForHTML><%=sbSelect%></xss:encodeForHTML></select></td>
<%
        } else {
%>
          <xss:encodeForHTML><%=sbBooleanInclude%></xss:encodeForHTML></select></td>
<%
        }


      }

      //To get the attribute value's  choices
      StringList sListAttrVal = (StringList)(vectHolder.elementAt(iIndex+1));
      if ((sListAttrVal != null) && (sListAttrVal.size() != 0)) {
    	  
// Added for IR72160V6R2011 Dated 28/12/2009 Begins.
        sListAttrVal.sort();
// Added for IR72160V6R2011 Dated 28/12/2009 Ends.

        StringItr sItrObj     = new StringItr(sListAttrVal);
%>
      <td>
        <select name="<xss:encodeForHTMLAttribute><%=sAttName%></xss:encodeForHTMLAttribute>"  size="1"><option name="" value="">
<%
        while (sItrObj.next()) {
          String sSelect  = "";
          String sTempStr = sItrObj.obj();
          String sRange  = i18nNow.getRangeI18NString( sAttName,sTempStr,request.getHeader("Accept-Language"));
          if (sTempStr.equals(sOrgVal)) {
            sSelect = "selected";
          }
%><!-- //XSSOK -->
          <option value="<%= XSSUtil.encodeForHTMLAttribute(context,sTempStr)%>" <%= XSSUtil.encodeForHTMLAttribute(context,sSelect)%> ><%= XSSUtil.encodeForHTML(context,sRange)%></option>
<%
        }
%>
        </select>
      </td>
<%
      } else {

        if (!sAttType.equals("timestamp")) {
%>
          <td align="left"  ><input type="text" name="txt_<%=sAttName%>" value="<xss:encodeForHTMLAttribute><%=sTxtOrgVal%></xss:encodeForHTMLAttribute>"/></td>
<%
        }
      }
%>
    </tr>
<%
      //swap row class
      if (rowClass.equals("odd")){
        rowClass = "even";
      }else{
        rowClass = "odd";
      }
    }
%>
<!-- //XSSOK -->
  <!--   <tr class="<%=rowClass%>" >
      <td ><emxUtil:i18n localize="i18nId" >emxTeamCentral.FindLike.Keyword</emxUtil:i18n></td>
      <!-- //XSSOK -->
	  <!--<td colspan="2"><input type="text" name="txtKeyword"  value="<%=sTxtKeyword%>" /></td>
    </tr>
    -->
<%
  String showAssociatedObjects = JSPUtil.getApplicationProperty(context,application,"eServiceSupplierCentral.RelatedObjects.Use");


  if (showAssociatedObjects != null && !"".equals(showAssociatedObjects) && "true".equalsIgnoreCase(showAssociatedObjects)){
    //swap row class again
    if (rowClass.equals("odd")){
      rowClass = "even";
    }else{
      rowClass = "odd";
    }

%>
    <tr>
      <th colspan="3" align="center" ><emxUtil:i18n localize="i18nId" >emxTeamCentral.FindLike.AssociatedObjects</emxUtil:i18n></th>
    </tr>
<%
  //this code approaches 2k limit on url's. We need a better way to post data. Possibly a form that gets 'Posted'
  String appprop = JSPUtil.getApplicationProperty(context,application,"eServiceSupplierCentral.RelatedObjects." + sBizTypeSymbolic);

    if (appprop != null && !"".equals(appprop) && !"null".equals(appprop)){
      StringTokenizer st = new StringTokenizer(appprop,",");
      String symbolicType = "";
      String assocSymbolicType = "";
      while (st.hasMoreTokens()) {
        symbolicType = st.nextToken().trim();
        assocSymbolicType = symbolicType;
        //get framework representation of string
        symbolicType = Framework.getPropertyValue(session,symbolicType);
        //test if not null or "", if so may be an incorrectly entered type or unknown type
        if (symbolicType != null && !"".equals(symbolicType) && !"null".equals(symbolicType)){
          //get translated version of string
          symbolicType = i18nNow.getTypeI18NString(symbolicType,languageStr);
%><!-- //XSSOK -->
        <tr class="<%=rowClass%>" >
          <td ><%=symbolicType%></td>
          <td ><emxUtil:i18n localize="i18nId" >emxTeamCentral.FindLike.Name</emxUtil:i18n></td>
          <td  ><select name="comboDescriptorName_<%=assocSymbolicType%>"><%=sbStrInclude.toString()%></select></td>
          <td  ><input type="text" name="assocTypeName_<%=assocSymbolicType%>"  value=""/></td>
        </tr>
<%
        if (rowClass.equals("odd")){
          rowClass = "even";
        }else{
          rowClass = "odd";
        }
%><!-- //XSSOK -->
        <tr class="<%=rowClass%>" >
          <td ><%=symbolicType%></td>
          <td ><emxUtil:i18n localize="i18nId" >emxTeamCentral.FindLike.Description</emxUtil:i18n></td>
          <td ><select name="comboDescriptorDes_<%=assocSymbolicType%>"><%=sbStrInclude.toString()%></select></td>
          <td ><input type="text" name="assocTypeDes_<%=assocSymbolicType%>"  value=""/></td>
        </tr>
<%
        }
        if (rowClass.equals("odd")){
          rowClass = "even";
        }else{
          rowClass = "odd";
        }
      }
    }
  }
%>

<%--   --%>
    <tr>
      <td colspan="4" align="center">
        <input type="radio" name="andOrParam" value="and" checked /><emxUtil:i18n localize="i18nId">emxTeamCentral.FindLike.And</emxUtil:i18n>
        <input type="radio" name="andOrParam" value="or" /><emxUtil:i18n localize="i18nId">emxTeamCentral.FindLike.Or</emxUtil:i18n>
      </td>
    </tr>
  </table>

<%
  }
%>


</form>
<script language="Javascript" >
  function refreshURL(){
    document.location = getTopWindow().url;
  }
</script>
&nbsp;<a href="javascript:refreshURL()" ><img src="../common/images/utilSearchMinus.gif" border="0" align="absmiddle" /></a>&nbsp;<a href="javascript:refreshURL()" ><%=i18nNow.getI18nString("emxTeamCentral.FindLike.More","emxTeamCentralStringResource",request.getHeader("Accept-Language"))%></a>&nbsp;

<!-- content ends here -->
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

<script language="javascript" type="text/javaScript">
parent.document.getElementById("imgProgressDiv").style.visibility = "hidden";
</script>

<!-- /////////////////////////  -->
