<%--  emxEngrFindRelatedDialog.jsp - The content page of the Find Realted search
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "eServiceUtil.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>


<%
  String languageStr = request.getHeader("Accept-Language");

  String appDirectory = (String)FrameworkProperties.getProperty(context, "eServiceSuiteEngineeringCentral.Directory");
//Multitenant
//String lStr = i18nNow.getI18nString("emxFramework.HelpDirectory","emxFrameworkStringResource", languageStr);
String lStr = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.HelpDirectory"); 
  if(lStr == null || "".equals(lStr)){
    lStr = "en";
  }

  String sSearchType = emxGetParameter(request,"ComboType");
  if (sSearchType == null){
    sSearchType = PropertyUtil.getSchemaProperty(context, "type_Part");
  }

  String sRelNames = emxGetParameter(request,"relNames");
  String sHiddenRel = emxGetParameter(request,"relList");
  if (sHiddenRel == null || "null".equals(sHiddenRel)){
    sHiddenRel = "";
  }

  String sToTypeList = emxGetParameter(request,"toArray");
  String sFromTypeList = emxGetParameter(request,"fromArray");

  String mxlimit = JSPUtil.getCentralProperty(application,session,"emxFramework.Search","UpperQueryLimit");
if(mxlimit == null || "null".equals(mxlimit) || "".equals(mxlimit)) {
     mxlimit = "1000";
  }
%>
<script language="Javascript">

function  callDoFind(){
     //footer frame
     var footerFrame = findFrame(getTopWindow(),"searchFoot");
     footerFrame.doFind();
}


 function loadRelationships() {
    var hiddenValue = document.findRelatedForm.relList.value;
    var relValue = document.findRelatedForm.relationship.options[document.findRelatedForm.relationship.selectedIndex].value;
    //XSSOK
    var testValue = "<%=EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.SelectRelationship", languageStr)%>";

    if (relValue == testValue){
      //XSSOK
      alert("<%=EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.PleaseSelectAnItem", languageStr)%>");
      return;
    }else if (hiddenValue != ""){
      document.findRelatedForm.relList.value = hiddenValue + "," + relValue;
    }else{
      document.findRelatedForm.relList.value = relValue;
    }

    var relList = document.findRelatedForm.relList.value;

    document.findRelatedForm.action= fnEncode("emxEngrFindRelatedDialog.jsp?relNames=" + relList);
    document.findRelatedForm.target="";
    document.findRelatedForm.method="post";
    document.findRelatedForm.submit();
 }

var clicked = false;


  function doSearch(){

    if (clicked) {
    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Search.RequestProcessMessage</emxUtil:i18nScript>");
    return;
  }
    //end
    form = document.findRelatedForm;
    var count = document.findRelatedForm.CntCheck.value;
    // if name/ rev entered in a row, and type not, specified then alert the user to select the type.
    for(var i=1;i<=count;i++)
    {
      if((eval('document.findRelatedForm.name'+i+'.value')!="") || (eval('document.findRelatedForm.rev'+i+'.value')!=""))
      {
        if(eval('document.findRelatedForm.typeDisp'+i+'.value')=="")
        {
          //XSSOK
          alert("<%=EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.SelectTypeWithRowNum", languageStr)%>"+i);
          return;
        }
      }
    }

    var strQueryLimit = 100;
    //Added to display search results page.
	if(parent.document.forms['searchFooterForm'] != null) {
		strQueryLimit= parent.document.forms['searchFooterForm'].QueryLimit.value;
		form.target = "searchView";
    } else {
       strQueryLimit = parent.document.bottomCommonForm.QueryLimit.value;
       document.findRelatedForm.specific.value = "true";
    }
     // search limit validation
     //XSSOK
      var searchLimit = '<%=mxlimit%>';
     var limit = 0;
     if(strQueryLimit == limit || (parseInt(strQueryLimit) > parseInt(searchLimit))  )
      {
         strQueryLimit = searchLimit;
      }
    // end


        startProgressBar();
        clicked =true
    // end
    //Added for the Bug No: 332509 1 Begin
	getTopWindow().validateURL();

	getTopWindow().storeFormVals(document.findRelatedForm);
	 //Added for the Bug No: 332509 1 End 
     document.findRelatedForm.queryLimit.value = strQueryLimit;
    document.findRelatedForm.submit();
  }

  function frmChecking(strFocus) {
    var strPage=strFocus;
  }
</script>

<%

  String searchTypes = "";
  searchTypes = (String)FrameworkProperties.getProperty(context, "eServiceEngineeringCentral.FindRelatedTypes");
%>

<script>

  var bAbstractSelect = true;
  var bReload = true;

  function showTypeSelector() {
	//XSSOK  
    var strURL="../common/emxTypeChooser.jsp?fieldNameActual=selType&fieldNameDisplay=selTypeDisp&formName=findRelatedForm&ShowIcons=true&InclusionList=<%=com.matrixone.apps.domain.util.XSSUtil.encodeForURL(searchTypes)%>&ObserveHidden=true&ReloadOpener="+bReload+"&SelectAbstractTypes="+bAbstractSelect;
    showModalDialog(strURL, 450, 350);
  }

  function showRelationshipTypeSelector(docField, dispField) {
    bReload = false;//Page should not be reloaded when Relationship's are changed
    bAbstractSelect = true;
  //XSSOK
    var strURL="../common/emxTypeChooser.jsp?fieldNameActual="+dispField+"&fieldNameDisplay="+docField+"&formName=findRelatedForm&ShowIcons=true&InclusionList=<%=com.matrixone.apps.domain.util.XSSUtil.encodeForURL(searchTypes)%>&ObserveHidden=true&ReloadOpener="+bReload+"&SelectAbstractTypes="+bAbstractSelect;
    showModalDialog(strURL, 450, 350);
  }

  function reload() {
    var varType     = document.findRelatedForm.selType.value;
    var relValue = document.findRelatedForm.relList.value;
    var url = "../engineeringcentral/emxEngrFindRelatedDialog.jsp?ComboType=" + varType + "&relNames=" + relValue + "&relList=" + relValue;
    document.location.href = fnEncode(url);
  }

  var bVaultMultiSelect = true;
  var strTxtVault = "document.forms['findRelatedForm'].Vault";
  var txtVault = null;

  function showVaultSelector() {

    txtVault = eval(strTxtVault);
    showModalDialog('../components/emxComponentsSelectSearchVaultsDialogFS.jsp?multiSelect=true&incCollPartners=true', 300, 350);
  }

  </script>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>



<body onload="turnOffProgress(), getTopWindow().loadSearchFormFields()">
<form name="findRelatedForm" method="get" action="emxEngrFindRelatedQueryFS.jsp" target="_parent" onSubmit="javascript:doSearch(); return false">

<input type="hidden" name="ComboType" value="<xss:encodeForHTMLAttribute><%=sSearchType%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="queryLimit" value="" />
<input type="hidden" name="pagination" value="" />
<input type="hidden" name="relList" value="<xss:encodeForHTMLAttribute><%=sHiddenRel%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="selType" value="<xss:encodeForHTMLAttribute><%=sSearchType%></xss:encodeForHTMLAttribute>" />

<table class="list" id="UITable" >
  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Find</emxUtil:i18n> <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Type</emxUtil:i18n></td>
    <td class="inputField">
    <!-- XSSOK -->
      <input type="text" size="25" name="selTypeDisp" id="selTypeDisp" readonly="readonly" onchange="JavaScript:LoadSearch()" value="<xss:encodeForHTMLAttribute><%=i18nNow.getTypeI18NString(sSearchType,languageStr)%></xss:encodeForHTMLAttribute>" />
      <input type="button" name="TypeSelector" value="..." onClick="showTypeSelector()" />
    </td>
  </tr>
</table>

&nbsp;
<table class="list" id="UITable" >
  <tr>
  <!-- XSSOK -->
    <th colspan="6" class="label" align="left"> <%=EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.ByRelatedItems", languageStr)%>
      <input type="radio" name="andOr" checked value="and" />
      <!-- XSSOK -->
      <%=EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.RelatedAnd", languageStr)%>
      <input type="radio" name="andOr" value="or" />
      <!-- XSSOK -->
      <%=EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.RelatedOr", languageStr)%>
    </th>
  </tr>
  <tr><td></td></tr>
  <tr>
  <!-- XSSOK -->
    <th class="label" align="left"><%=EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.RelationshipMeaning", languageStr)%></th>
    <!-- XSSOK -->
    <th class="label" align="left"><%=EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.Type", languageStr)%></th>
    <!-- XSSOK -->
    <th class="label" align="left" colspan="4"><%=EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.Values", languageStr)%></th>
  </tr>
  <tr>
    <td class="inputField">
      <select name="relationship" >
      <!-- XSSOK -->
          <option value="<%=EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.SelectRelationship", languageStr)%>" ><%=EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.SelectRelationship", languageStr)%></option>
<%
    String relName = null;
    Vault vault = context.getVault();
    BusinessType searchType = new BusinessType(sSearchType, vault);
	//Added for Bug no 340584 Starts
    matrix.db.RelationshipTypeList relTypeList = searchType.getRelationshipTypes(context, true, true, true); 
    relTypeList.sort();
    RelationshipTypeItr relTypeItr = new RelationshipTypeItr(relTypeList);
	//Added for Bug no 340584 Ends
    if (relTypeItr != null)
    {
      while (relTypeItr.next())
      {
          RelationshipType relType = relTypeItr.obj();
          relName = relType.getName();
%>
			<!-- XSSOK -->
          <option value="<%=relName%>" ><%=i18nNow.getAdminI18NString("Relationship",relName,languageStr)%></option>
<%
      }
    }
%>
       </select>
     </td>
     <td class="field" wrap="nowrap">
        <img src="../common/images/buttonPlus.gif" border="0"/>
        <!-- XSSOK -->
        <a href="JavaScript:loadRelationships()"><%=EngineeringUtil.i18nStringNow(context,"emxEngineeringCentral.Common.AddRows", languageStr)%></a>
     </td>
   </tr>
<%
    int cnt = 0;
    int i = 0;
    if ((sRelNames != null) && (!sRelNames.equals("")) )
    {
      StringTokenizer st = new StringTokenizer(sRelNames, ",");
      while (st.hasMoreTokens())
      {
        i = 0;
        cnt++;
        String relNameToken = st.nextToken();
        String relNameDisplay = i18nNow.getAdminI18NString("Relationship",relNameToken,languageStr);

        RelationshipType relType = new RelationshipType(relNameToken);
        relType.open(context);

        boolean allToTypes = relType.getToAllTypesAllowed();
        if (allToTypes){
          //sToTypeList = arrTypeArrayContent.toString();
          sToTypeList = searchTypes;
        }
        else
        {
          BusinessTypeList toTypes = relType.getToTypes(context);
          sToTypeList = "";
          BusinessTypeItr busTypeItr = new BusinessTypeItr(toTypes);
          if (busTypeItr != null)
          {
            while (busTypeItr.next())
            {
               BusinessType busType = busTypeItr.obj();
               if (i == 0){
                 sToTypeList = "\"" + busType.getName() + "\"";
               }
               else
               {
                 sToTypeList += ",";
                 sToTypeList += "\"" + busType.getName() + "\"";
               }
               i++;
            }
          }
        }

        i = 0;
        boolean allFromTypes = relType.getFromAllTypesAllowed();
        if (allFromTypes){
          sFromTypeList = searchTypes;
        }
        else
        {
          BusinessTypeList fromTypes = relType.getFromTypes(context);
          sFromTypeList = "";
          BusinessTypeItr busTypeItr = new BusinessTypeItr(fromTypes);
          if (busTypeItr != null)
          {
            while (busTypeItr.next())
            {
               BusinessType busType = busTypeItr.obj();
               if (i == 0){
                 sFromTypeList = "\"" + busType.getName() + "\"";
               }
               else
               {
                 sFromTypeList += ",";
                 sFromTypeList += "\"" + busType.getName() + "\"";
               }
               i++;
            }
          }
        }

        String relToMeaning = relType.getToMeaning();
      //Multitenant
        //String relToMeaningIntr = UINavigatorUtil.getI18nString(relToMeaning, "emxEngineeringCentralStringResource", request.getHeader("Accept-Language"));
        String relToMeaningIntr = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),relToMeaning); 

        if ((relToMeaning == null) || (relToMeaning.equals(""))){
              relToMeaning = relNameDisplay;
        }else {
              relToMeaning = relToMeaningIntr;
        }


        String sSearchToType = "type" + cnt;
        String sSearchToTypeDisp = "typeDisp" + cnt;
        String sSearchToName = "name" + cnt;
        String sSearchToRev  = "rev" + cnt;
        String sSearchToDir  = "reldir" + cnt;
        String sSearchToRelName = "hiddenRel" + cnt;

        cnt++;
        String sSearchFromType = "type" + cnt;
        String sSearchFromTypeDisp = "typeDisp" + cnt;
        String sSearchFromName = "name" + cnt;
        String sSearchFromRev  = "rev" + cnt;
        String sSearchFromDir  = "reldir" + cnt;
        String sSearchFromRelName = "hiddenRel" + cnt;
        String sTempType = null;
        String sTempHidType = null;
        String sTempName = null;
        String sTempRev  = null;

        if (!sToTypeList.equals(""))
        {
          sTempType = emxGetParameter(request, sSearchToTypeDisp);
          if (sTempType == null || "null".equals(sTempType)) {
            sTempType = "";
          }

          sTempHidType = emxGetParameter(request, sSearchToType);
          if (sTempHidType == null || "null".equals(sTempHidType)) {
            sTempHidType = "";
          }

          sTempName = emxGetParameter(request, sSearchToName);
          if (sTempName == null || "null".equals(sTempName)) {
            sTempName = "";
          }

          sTempRev = emxGetParameter(request, sSearchToRev);
          if (sTempRev == null || "null".equals(sTempRev)) {
            sTempRev = "";
          }
%>
      <tr>
      	<!-- XSSOK -->
         <input type=hidden name="<%=sSearchToDir%>" value="to" />
         <!-- XSSOK -->
         <input type="hidden" name="<%=sSearchToRelName%>" value="<xss:encodeForHTMLAttribute><%=relNameToken%></xss:encodeForHTMLAttribute>" />
         <td class="label"><xss:encodeForHTML><%=relToMeaning%></xss:encodeForHTML></td>
         <td class="label" width="20%"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Type</emxUtil:i18n></td>
         <td class="inputField" wrap="nowrap">
            <input type="text" size="10" name="<%=sSearchToTypeDisp%>" id="<%=sSearchToTypeDisp%>" readonly="readonly" onchange="JavaScript:LoadSearch()" value="<xss:encodeForHTMLAttribute><%=sTempType%></xss:encodeForHTMLAttribute>" />
            <input type="hidden" name="<%=sSearchToType%>" value="<xss:encodeForHTMLAttribute><%=sTempHidType%></xss:encodeForHTMLAttribute>" />
            <input type="button" name="RelTypeSelector" value="..." onClick="showRelationshipTypeSelector('<xss:encodeForHTMLAttribute><%=sSearchToTypeDisp%></xss:encodeForHTMLAttribute>','<xss:encodeForHTMLAttribute><%=sSearchToType%></xss:encodeForHTMLAttribute>')" />
         </td>
         <td class="inputField"><input type="text" size="10" name="<%=sSearchToName%>" id="<%=sSearchToName%>" value="<xss:encodeForHTMLAttribute><%=sTempName%></xss:encodeForHTMLAttribute>" /></td>
         <td class="label" width="20%"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Rev</emxUtil:i18n></td>
         <td class="inputField"><input type="text" size="10" name="<%=sSearchToRev%>" id="<%=sSearchToRev%>" value="<xss:encodeForHTMLAttribute><%=sTempRev%></xss:encodeForHTMLAttribute>" /></td>
      </tr>
<%
        }
        String relFromMeaning = relType.getFromMeaning();
      //Multitenant
        //String relFromMeaningIntr = UINavigatorUtil.getI18nString(relFromMeaning, "emxEngineeringCentralStringResource", request.getHeader("Accept-Language"));
        String relFromMeaningIntr = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),relFromMeaning);

        if ((relFromMeaning == null) || (relFromMeaning.equals(""))){
              relFromMeaning = relNameDisplay;
        }else {
              relFromMeaning = relFromMeaningIntr;
        }

        if (!sFromTypeList.equals(""))
        {
          sTempType = emxGetParameter(request, sSearchFromTypeDisp);
          if (sTempType == null || "null".equals(sTempType)) {
            sTempType = "";
          }

          sTempHidType = emxGetParameter(request, sSearchFromType);
          if (sTempHidType == null || "null".equals(sTempHidType)) {
            sTempHidType = "";
          }

          sTempName = emxGetParameter(request, sSearchFromName);
          if (sTempName == null || "null".equals(sTempName)) {
            sTempName = "";
          }

          sTempRev = emxGetParameter(request, sSearchFromRev);
          if (sTempRev == null || "null".equals(sTempRev)) {
            sTempRev = "";
          }
%>
      <tr>
      <!-- XSSOK -->
         <input type="hidden" name="<%=sSearchFromDir%>" value="from" />
         <input type="hidden" name="<%=sSearchFromRelName%>" value="<xss:encodeForHTMLAttribute><%=relNameToken%></xss:encodeForHTMLAttribute>" />
         <!-- XSSOK -->
         <td class="label"><%=relFromMeaning%></td>
         <td class="label" width="20%"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Type</emxUtil:i18n></td>
         <td class="inputField" wrap="nowrap">
             <input type="text" size="10" name="<%=sSearchFromTypeDisp%>" id="<%=sSearchFromTypeDisp%>" readonly="readonly" onchange="JavaScript:LoadSearch()" value="<xss:encodeForHTMLAttribute><%=sTempType%></xss:encodeForHTMLAttribute>" />
             <input type="hidden" name="<%=sSearchFromType%>" value="<xss:encodeForHTMLAttribute><%=sTempHidType%></xss:encodeForHTMLAttribute>" />
              <!-- XSSOK -->
             <input type="button" value="..." name="RelTypeSelector" onClick="showRelationshipTypeSelector('<%=sSearchFromTypeDisp%>','<%=sSearchFromType%>')" />
         </td>
         <td class="inputField"><input type="text" size="10" name="<%=sSearchFromName%>" id="<%=sSearchFromName%>" value="<xss:encodeForHTMLAttribute><%=sTempName%></xss:encodeForHTMLAttribute>" /></td>
         <td class="label" width="20%"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Rev</emxUtil:i18n></td>
         <td class="inputField"><input type="text" size="10" name="<%=sSearchFromRev%>" id="<%=sSearchFromRev%>" value="<xss:encodeForHTMLAttribute><%=sTempRev%></xss:encodeForHTMLAttribute>" /></td>
      </tr>
<%
        }
      }
    }
%>
<input type="hidden" name="CntCheck" value="<xss:encodeForHTMLAttribute><%=cnt%></xss:encodeForHTMLAttribute>" />
</table>
    <input type="image" name="inputImage" height="1" width="1" src="../common/images/utilSpacer.gif" hidefocus="hidefocus" 
style="-moz-user-focus: none" />

</form>
</body>
<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
