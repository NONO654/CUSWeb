<%--  emxpartRaiseAnECOAssignDetailsDialog.jsp   -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxengchgJavaScript.js"%>
<%@ page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%
  ECO ecrId = (ECO)DomainObject.newInstance(context,DomainConstants.TYPE_ECO,DomainConstants.ENGINEERING);
  Part ecrableObj = (Part)DomainObject.newInstance(context,DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);

  String ecrableId            ="";

  String sRelType             = "";
  String sECRType             = PropertyUtil.getSchemaProperty(context, "type_ECO");
  String strEcrId             = "";
  boolean connectedBoolean=false;

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String mode=emxGetParameter(request,"mode");//    IR-068172V6R2012
  String selectedParts      = (String)session.getAttribute("selectedParts");

String rdoId      = (String)session.getAttribute("rdoId");
String rdoName      = (String)session.getAttribute("rdoName");

  String selectedType =emxGetParameter(request,"selectedType");
  String checkedButtonValue=emxGetParameter(request,"checkedButtonValue");
  String checkboxValue=emxGetParameter(request,"checkboxValue");
  String Create = emxGetParameter(request,"Create");
  String prevmode  = emxGetParameter(request,"prevmode");
  String Relationship=emxGetParameter(request,"Relationship");
  String policy=emxGetParameter(request,"policy");
  String partsConnected="";
  String URLtoECRRaisedPage="";

  boolean blnIsDynamic = true;

	DomainObject doECO = new DomainObject(selectedType);

	String strPolicy = doECO.getInfo(context, DomainConstants.SELECT_POLICY);
	String strPolicyClassification = FrameworkUtil.getPolicyClassification(context, strPolicy);

	//if ("StaticApproval".equals(strPolicyClassification))
	//{
	//	blnIsDynamic = false;
	//}

	if (Relationship == null || Relationship.indexOf("null") != -1)
	{
		//if (blnIsDynamic)
		//{
			Relationship =  PropertyUtil.getSchemaProperty(context,"relationship_AffectedItem");
		//}
		//else
		//{
		//	Relationship = DomainConstants.RELATIONSHIP_NEW_PART_PART_REVISION;
		//}
	}


  String attrSpecificDescriptionofChange = PropertyUtil.getSchemaProperty(context, "attribute_SpecificDescriptionofChange");

  if(Create==null || "null".equals(Create)){
      Create="";
   }

   String backActionUrl    ="";
   if(Create.equals("true")){
    backActionUrl="emxpartCreateRaiseECOWizardFS.jsp?prevmode=true&Relationship="+Relationship;
   }
 //Added for   IR-068172V6R2012 starts
   else if(null!=mode&&"ExistingECO".equals(mode))
   {  
       //i18nNow i18nnow = new i18nNow();
       //Multitenant
		//String someString =i18nnow.GetString("emxEngineeringCentralStringResource", context.getSession().getLanguage(), "emxEngineeringCentral.RaiseECO.SearchAnECO");// IR:042045
		String someString =EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.RaiseECO.SearchAnECO");
       //backActionUrl=  "../common/emxFullSearch.jsp?field=TYPES=type_ECO:Policy!=policy_DECO,policy_TeamECO&HelpMarker=emxhelpfullsearch&table=ENCGeneralSearchResult&selection=single&submitURL=../engineeringcentral/emxEngrRaiseECRECOHiddenProcess.jsp&calledMethod=RaiseECO&jsTreeID=" + jsTreeID + "&objectId=" + objectId + "&suiteKey=" + suiteKey + "&Relationship="+Relationship+ "&header="+ someString +"&hideHeader =false";   
       backActionUrl=  "../common/emxFullSearch.jsp?field=TYPES=type_ECO:Policy!=policy_DECO,policy_TeamECO:CURRENT=policy_ECO.state_Create,policy_ECO.state_DefineComponents,policy_ECO.state_DesignWork&HelpMarker=emxhelpfullsearch&table=ENCGeneralSearchResult&selection=single&submitURL=../engineeringcentral/emxEngrRaiseECRECOHiddenProcess.jsp&calledMethod=RaiseECO&jsTreeID=" + jsTreeID + "&objectId=" + objectId + "&suiteKey=" + suiteKey + "&Relationship="+Relationship+ "&header="+ someString +"&hideHeader =false";
       
    }
   //Added for   IR-068172V6R2012 ends
   else
   {	backActionUrl="emxpartRaiseECOSearchResultsFS.jsp?prevmode=true";
   }

%>

<%
  String languageStr = request.getHeader("Accept-Language");

  String sName = emxGetParameter(request,"Name");
  sName = (((sName == null) || (sName.equalsIgnoreCase("null"))) ? "*" : sName.trim().equals("") ? "*" : sName.trim());
  String sRev = emxGetParameter(request,"Rev");


  String sSelected = "Selected";
  String sVault = JSPUtil.getVault(context, session);
  Vault vault = new Vault(sVault);

  ecrId.setId(selectedType);

  if(!(Create.equals("true"))) {


    //String relPattern =   DomainConstants.RELATIONSHIP_MAKE_OBSOLETE + ","+   DomainConstants.RELATIONSHIP_NEW_PART_PART_REVISION + ","+   DomainConstants.RELATIONSHIP_NEW_SPECIFICATION_REVISION;
    String relPattern =  PropertyUtil.getSchemaProperty(context,"relationship_AffectedItem");


   //if (blnIsDynamic)
  // {
	//   relPattern =  PropertyUtil.getSchemaProperty(context,"relationship_AffectedItem");
  // }
    StringList objSelect = new StringList();
    objSelect.add(  DomainConstants.SELECT_ID);


    // Get all Parts,Specs connected with the ECR

    if (!(Create.equals("true")))
    {
    MapList mapListofRaiseAgainst = ecrId.getRelatedObjects(context,
                                   relPattern,
                                   "*",
                                   objSelect,
                                   null,
                                   false,
                                   true,
                                   (short) 1,
                                   null,
                                   null);



    // Iterate thru all the selected items and check any of them are already connectd with
    // the current ECR.

    StringTokenizer st = new StringTokenizer(selectedParts, ",");
    while(st.hasMoreTokens())
    {
      ecrableId=st.nextToken();

      Iterator itrMapList =  mapListofRaiseAgainst.iterator();
      while(itrMapList.hasNext()) {
        Map map =  (Map)itrMapList.next();
        if(ecrableId.equals((String)map.get(DomainConstants.SELECT_ID))) {
          partsConnected += ecrableId+"|";
          connectedBoolean=true;
          break;
        }
      }
    }
    URLtoECRRaisedPage="emxpartRaiseECRAlreadyRaisedFS.jsp";
	}

  }


%>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

    <form name="relattrFrm" method="post" action="" onSubmit="javascript:submitForm(); return false">
      <input type="hidden" name="FieldName" value="" />
      <input type="hidden" name="attributeArray" value="" />
      <input type="hidden" name="rdoId" value="<xss:encodeForHTMLAttribute><%=rdoId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="rdo" value="<xss:encodeForHTMLAttribute><%=rdoName%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="policy" value="<xss:encodeForHTMLAttribute><%=policy%></xss:encodeForHTMLAttribute>" />
      <%
  if(connectedBoolean)
  {
%>
      <table border="0" cellpadding="5" cellspacing="2" width="100%">
        <tr>
          <td class="labelRequired"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Warning</emxUtil:i18n> </td>
          <td class="field"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.RaiseECO.WarningMessage</emxUtil:i18n></td>
        </tr>
        <tr>
          <td width="25%" class="label">&nbsp;</td>
          <td class="field"><a href="JavaScript:ECORaisedWindow()"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.RaiseECO.ItemsExistingECOHref</emxUtil:i18n></a></td>
        </tr>
      </table>
<%
  }
%>
      <table border="0" cellspacing="0" cellpadding="0" width="100%">
        <tr>
          <td class="pageBorder"><img src="../common/images/utilSpacer.gif" width="1" height="1" /></td>
        </tr>
      </table>

      <table border="0" cellpadding="5" cellspacing="2" width="100%">
        <tr>
          <td colspan="2"><B><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Parts</emxUtil:i18n></B></td>
        </tr>
        <tr>
<%

    Map attrMap = null;
    String key;
    String attrName;
    String attrDataType;
    if(null!=prevmode && (prevmode.equalsIgnoreCase("true")))
    {
    attrMap =(Map) session.getAttribute("dispAttribs");

    }
    if (blnIsDynamic)
    {
		Relationship=PropertyUtil.getSchemaProperty(context,"relationship_AffectedItem");
	}
	attrMap=null;
	String strAttrStartDate = PropertyUtil.getSchemaProperty(context,"attribute_StartDate");
    if(attrMap==null){
      attrMap = DomainRelationship.getTypeAttributes(context,Relationship);
      if(attrMap.containsKey(DomainObject.ATTRIBUTE_WHERE_USED_COMPONENT_REFERENCE)) {
        attrMap.remove(DomainObject.ATTRIBUTE_WHERE_USED_COMPONENT_REFERENCE);
      }
      session.setAttribute("dispAttribs",attrMap);
    }
    else
    {
    //Relationship=emxGetParameter(request,"Relationship");
    }
    Iterator itr = attrMap.keySet().iterator();
    while(itr.hasNext())
    {

      key = (String) itr.next();
      Map mapinfo = (Map) attrMap.get(key);
      attrName = (String)mapinfo.get("name");
      if (!(attrSpecificDescriptionofChange.equals(attrName))
			&& !(strAttrStartDate.equals(attrName))){

%>
        <tr>
        <!-- XSSOK -->
        <td width="150" class="label"><%=i18nNow.getAttributeI18NString(attrName,languageStr)%></td>
        <td class="inputField">
<%
        //check to see if we need to display a list box or a text area or a text box
        //if the datatype is string and has Choices is true the show a list box
        //else if the attribute is multiline then show a text area
        //else show a text box

        attrDataType = (String) mapinfo.get("type");
        StringList attrOptions = (StringList) mapinfo.get("choices");
        if(attrDataType.equalsIgnoreCase("string") && attrOptions != null)
        {
          StringItr sChoicesItr = new StringItr(attrOptions);
%>
		  <!-- XSSOK -->
          <select name="<%=attrName%>">
<%
          String sDefault = (String) mapinfo.get("value");
          while(sChoicesItr.next())
          {
            String sChoice = sChoicesItr.obj();

            if (!"None".equals(sChoice) && !"For Release".equals(sChoice))
            {


            if(sChoice.equals(sDefault))
            {
%>
			  <!-- XSSOK -->
              <option VALUE="<%=sChoice%>" <%=sSelected%>><%=i18nNow.getRangeI18NString(attrName,(sChoice).trim(), languageStr)%></option>
<%
            }
            else
            {
%>
			   <!-- XSSOK -->
              <option VALUE="<%=sChoice%>"><%=i18nNow.getRangeI18NString(attrName,(sChoice).trim(), languageStr)%></option>
<%
            }
          }
          }
%>
          </select>
<%
        }

        // Since we cannot determine isMultiline() from attribute type we display everything as textarea
        else
        {
%>
          <textarea name="<xss:encodeForHTMLAttribute><%=attrName%></xss:encodeForHTMLAttribute>" style="font-size: 8pt; color:black" rows="3" cols="40"  wrap="soft"><xss:encodeForHTML><%=mapinfo.get("value")%></xss:encodeForHTML></textarea>
<%

        }
%>
        </td>
        </tr>
<%
      }
      }

%>

<%
    // if the source page is connected data then selected the select the passes relationship id as selected
    // relationship and display the specific attributes or else select the first relationship as default
%>
    <tr>
      <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Relationship</emxUtil:i18n></td>
      <td class="inputField">
      <select name = "Relationship" >
		<!-- XSSOK -->
        <option value="<%=PropertyUtil.getSchemaProperty(context,"relationship_AffectedItem")%>">
        <!-- XSSOK -->
        <%=i18nNow.getAdminI18NString("Relationship",PropertyUtil.getSchemaProperty(context,"relationship_AffectedItem"),languageStr)%>
        </option>
      </select>
      </td>
    </tr>
    </table>
    <table border="0" cellspacing="0" cellpadding="0" width="100%">
      <tr>
        <td class="pageBorder"><img src="../common/images/utilSpacer.gif" width="1" height="1" /></td>
      </tr>
    </table>
    <table border="0" cellpadding="5" cellspacing="2" width="100%">
      <tr>
        <td colspan="2"><B><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Specifications</emxUtil:i18n></B></td>
      </tr>
      <tr>
        <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Relationship</emxUtil:i18n></td>
        <!-- XSSOK -->
		<td class="inputField"><%=i18nNow.getAdminI18NString("Relationship",PropertyUtil.getSchemaProperty(context,"relationship_AffectedItem"),languageStr)%></td>

      </tr>
    </table>
    <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="Name" value="<xss:encodeForHTMLAttribute><%=sName%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="Rev" value="<xss:encodeForHTMLAttribute><%=sRev%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="Create" value="<xss:encodeForHTMLAttribute><%=Create%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="checkboxValue" value="<xss:encodeForHTMLAttribute><%=checkboxValue%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="selectedParts" value="<xss:encodeForHTMLAttribute><%=selectedParts%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="prevmode" value="<xss:encodeForHTMLAttribute><%=prevmode%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="selectedType" value="<xss:encodeForHTMLAttribute><%=selectedType%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="checkedButtonValue" value="<xss:encodeForHTMLAttribute><%=checkedButtonValue%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="partsConnected" value="<xss:encodeForHTMLAttribute><%=partsConnected%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="mode" value="<xss:encodeForHTMLAttribute><%=mode%></xss:encodeForHTMLAttribute>" />
    <input type="image" name="inputImage" height="1" width="1" src="../common/images/utilSpacer.gif" hidefocus="hidefocus"
style="-moz-user-focus: none" />

</form>
<script language="Javascript">

  function goBack()
    {
         document.relattrFrm.target="_parent";
         //XSSOK
       document.relattrFrm.action="<%=XSSUtil.encodeForJavaScript(context,backActionUrl)%>";
       document.relattrFrm.submit();
       return;
    }


  function submitForm() {
	document.relattrFrm.target="_parent";
	document.relattrFrm.action="emxpartReasonForChangeAnECOWizardFS.jsp";
    document.relattrFrm.submit();
    return;
  }

  function ECRRaisedWindow() {
	 var newWin1 = window.open('about:blank','newWin1','height=600,width=700');
	 document.relattrFrm.target="newWin1";
	 //XSSOK
	 document.relattrFrm.action='<%=XSSUtil.encodeForJavaScript(context,URLtoECRRaisedPage)%>';
     document.relattrFrm.submit();
     newWin1.focus();
     return;

  }

  function cleanUp() {
      document.relattrFrm.action="emxpartRaiseECRCleanup.jsp";
      document.relattrFrm.submit();
      return;
  }

</script>
<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
