<%--  emxEngrCreateMfrEquivalentPartFromMPNDialog.jsp   - Dialog page to take input for creating an ME Part.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "eServiceUtil.inc" %>
<%@include file = "emxengchgUtil.inc"%>
<%@include file = "emxengchgJavaScript.js"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxJSValidation.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%

  String languageStr  = request.getHeader("Accept-Language");

  String partType = DomainConstants.TYPE_PART;
  String type             = partType;
  String partNum          = "";
  String description      = "";
  String policy = "";
  String srev   = "";

  String attrOrgId               = Framework.getPropertyValue(session, "attribute_OrganizationID");
  String attrCageCode            = Framework.getPropertyValue(session, "attribute_CageCode");
  String CageCode = "";
  String CompId = "";
  String customRevision = FrameworkProperties.getProperty(context, "emxManufacturerEquivalentPart.MEP.allowCustomRevisions"); 
  String uniqueIdentifier = FrameworkProperties.getProperty(context, "emxManufacturerEquivalentPart.MEP.UniquenessIdentifier");
  if (uniqueIdentifier != null)
    {
        uniqueIdentifier = uniqueIdentifier.trim();
    }
  if( customRevision == null)
    {
        customRevision = "false";
    }
  else
    {
        customRevision = customRevision.trim();
    }
  if (!"attribute_CageCode".equals(uniqueIdentifier) && !"Policy".equals(uniqueIdentifier) )
    {
        uniqueIdentifier = "attribute_OrganizationID";
    }

    com.matrixone.apps.common.Person contextPerson = com.matrixone.apps.common.Person.getPerson(context);
    Company contextCompany = contextPerson.getCompany(context);
    StringList objSelectList = new StringList(2);
    objSelectList.addElement("attribute["+attrOrgId+"]");
    objSelectList.addElement("attribute["+attrCageCode+"]");
    Map companyMap = contextCompany.getInfo(context, objSelectList);
    CompId = (String)companyMap.get("attribute["+attrOrgId+"]");
    CageCode = (String)companyMap.get("attribute["+attrCageCode+"]");

%>

<script language="JavaScript">

    function closeThis() {
      //parent.window.close();
      getTopWindow().closeSlideInDialog();
    }

    var bAbstractSelect = false;
    var bReload = false;
    
    function showTypeSelector() {
    	//XSSOK
    	var strURL="../common/emxTypeChooser.jsp?fieldNameActual=partType&fieldNameDisplay=partTypeDisp&formName=tempForm&ShowIcons=true&InclusionList=<%=com.matrixone.apps.domain.util.XSSUtil.encodeForURL(PropertyUtil.getSchemaProperty(context, "type_Part"))%>&ReloadOpener="+bReload+"&SelectAbstractTypes="+bAbstractSelect;
    	
        showModalDialog(strURL, 450, 350);
      }
    
    function checkInput() {
    		//XSSOK
           var id ="<%=uniqueIdentifier%>";
        	//XSSOK
           var revision = "<%=customRevision%>";
           var namebadCharName = checkForNameBadCharsList(document.tempForm.partNum);

           if (namebadCharName.length != 0){
             alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");      
             document.tempForm.partNum.focus();
             return;
           }

           if(document.tempForm.partNum.value != "")
           {
             var CMN = document.tempForm.partNum.value;

             // this will get rid of leading spaces
             while (CMN.substring(0,1) == ' ')
             CMN = CMN.substring(1, CMN.length);

             // this will get rid of trailing spaces
             while (CMN.substring(CMN.length-1,CMN.length) == ' ')
             CMN = CMN.substring(0, CMN.length-1);

             eval("document.tempForm.partNum.value = CMN");
           }

           if (!(jsValidate('tempForm', 'partNum'))) {
             return;
           }

           if(jsTrim(document.tempForm.partNum.value) == "")
           {
             alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.PleaseEnterAPartName</emxUtil:i18nScript>");
           }
            else if(document.tempForm.rev.value.length == 0 && revision == "true")
            {
                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.PleaseEnterAPartRevision</emxUtil:i18nScript>");
                return;
            }
           else if(document.tempForm.rev.value.length == 0)
           {
                if(id == "attribute_CageCode")
                {
                    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.MEP.CageCodeEmpty</emxUtil:i18nScript>");
                    return;
                }
                else if (id == "attribute_OrganizationID")
                {
                    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.MEP.CompanyIDEmpty</emxUtil:i18nScript>");
                    return;
                }
                else if (id == "Policy")
                {
                    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.MEP.PolicySequenceEmpty</emxUtil:i18nScript>");
                    return;
                }
           }
            else if (document.tempForm.rev.value.length > 0 && !isAlphanumeric(document.tempForm.rev.value, true))
            {
                 alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.MEP.PleaseTypeAlphaNumeric</emxUtil:i18nScript>");
                  document.tempForm.rev.focus();
                    return;
            }
           else
           {
             document.tempForm.submit();
           }
    }

    var policySeqArr = new Array;
<%
   // get the Policies of Part     TODO: need to get all 'Equivalent' policies
   BusinessType partBusType = new BusinessType(partType, new Vault(Person.getPerson(context).getVaultName(context)));
   partBusType.open(context,false);
   PolicyList policyList  = partBusType.getPoliciesForPerson(context,false);
   partBusType.close(context);
   Policy policyObj = null;

   StringList polList = EngineeringUtil.getPoliciesforTypeClassification(context, partType, "Equivalent");

   StringItr polItr   = new StringItr(polList);

   //set up the array of values for the first revision sequence
   int idx = 0;
   while(polItr.next())
   {
     Policy partPolicy = new Policy (polItr.obj());
	 for(int i=0; i<policyList.size(); i++) {
		 policyObj = (Policy)policyList.elementAt(i);
		 String policyObjName = policyObj.getName().trim();
		 String partPolicyName = partPolicy.getName().trim();
         if(policyObjName.equals(partPolicyName)) {
            String firstRevSeq = partPolicy.getFirstInSequence(context);
%>
	   //XSSOK
       policySeqArr[<%=idx%>] = "<%=firstRevSeq%>";
<%     
         }
    }    
    idx++;
   }
   polItr.reset();
%>

  function loadFirstRevision()
       {
         var idx = document.tempForm.policy.selectedIndex;
         var policyName = document.tempForm.policy.options[idx].value;
       //XSSOK
         var revision = "<%=customRevision%>";
       //XSSOK
         var id = "<%=uniqueIdentifier%>";
       //XSSOK
         var ccode = "<%=CageCode%>";
       //XSSOK
         var cid = "<%=CompId%>";
         if( id == "attribute_OrganizationID")
            {
                document.tempForm.rev.value = cid;
            }
         else if (id == "attribute_CageCode")
            {
                document.tempForm.rev.value = ccode;
            }
         else
            {
                document.tempForm.rev.value = policySeqArr[idx];
            }
        }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<body  onLoad="loadFirstRevision();">
<%
  String suiteKey = emxGetParameter(request, "suiteKey");
  String jsTreeID = emxGetParameter(request, "jsTreeID");
  String sSelected="selected";

  String objectId = emxGetParameter(request, "objectId");
  String defaultPolicy = DomainConstants.POLICY_MANUFACTURER_EQUIVALENT;

  DomainObject dom = new DomainObject(objectId);
  description = dom.getInfo(context, DomainConstants.SELECT_DESCRIPTION);

%>

<form name="tempForm" method="post" action="emxEngrCreateMfrEquivalentPartFromMPN.jsp" target="_parent" onsubmit="javascript:checkInput(); return false">
<input type="hidden" name="partType" value="<xss:encodeForHTMLAttribute><%=PropertyUtil.getSchemaProperty(context, "type_Part")%></xss:encodeForHTMLAttribute>" />
<table border="0" cellpadding="5" cellspacing="2" width="100%">
  <tr>
    <td width="25%" class="labelRequired"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.PartName</emxUtil:i18n> </td>
    <td class="inputField">
      <input type="text" name="partNum" value="<xss:encodeForHTMLAttribute><%=partNum%></xss:encodeForHTMLAttribute>" />
    </td>
  </tr>

  <tr>
      <td width="25%" class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Type</emxUtil:i18n></td>
      
      <td class="inputField" ><input type="text" name="partTypeDisp" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=i18nNow.getTypeI18NString(PropertyUtil.getSchemaProperty(context, "type_Part"),languageStr)%></xss:encodeForHTMLAttribute>"/>&nbsp;<input class="button" type="button" name="typeButton" size = "200" value="..."  onClick="javascript:showTypeSelector(); ">
      </td>
  </tr>
  <tr>
<%
        if (customRevision.equals("true"))
        {
%>
            <td class="labelRequired"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.CustomRevisionLevel</emxUtil:i18n></td>
            <td class="inputField" align="left"><input type="text" name="rev" size="30" value="<xss:encodeForHTMLAttribute><%=srev%></xss:encodeForHTMLAttribute>" /></td>
<%
        }
        else
        {
%>
            <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Revision</emxUtil:i18n></td>
            <td class="inputField" align="left"><input type="text" name="rev" size="30" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=srev%></xss:encodeForHTMLAttribute>" /></td>
<%
        }
%>
  </tr>
  <tr>
    <td width="25%" class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Policy</emxUtil:i18n></td>
    <td class="inputField">
      <select name="policy" onChange="loadFirstRevision()">
<%
      String selected = "";
      Policy policyObject = null;
      while(polItr.next())
      {
        String policyName = polItr.obj();
   	    for(int i=0; i<policyList.size(); i++) {
            policyObject = (Policy)policyList.elementAt(i);
            String policyObjectName = policyObject.getName().trim();
            if(policyObjectName.equals(policyName)) {
        	String policy_Names = policyName.replace(" ", "_"); // BUG:306505 Issue 12
        	//Multitenant
        	/* policyName = i18nNow.getI18nString("emxFramework.Policy." + policy_Names, 
                        "emxFrameworkStringResource", languageStr); // BUG:306505 Issue 12 */
            policyName = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Policy." + policy_Names); 

			//Get the policy name from english library
			//Multitenant
			/* String policyNameActual = i18nNow.getI18nString("emxFramework.Policy." + policy_Names,
						"emxFrameworkStringResource", "en-us"); */
			String policyNameActual = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale("en"),"emxFramework.Policy." + policy_Names);

                if (defaultPolicy.equals(policyName))
                {
                   selected = "selected";
                }
%>
	<!-- XSSOK -->
      <option value="<%=policyNameActual%>" <%=selected%>><%=policyName%></option>
<%
                selected = "";
            }
        }
      }
%>
      </select>
    </td>
  </tr>

  <tr>
    <td class="label"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Description</emxUtil:i18n></td>
    <td class="inputField" align="left"><textarea name="description" rows="6" cols="55" wrap="soft"><xss:encodeForHTML><%=description%></xss:encodeForHTML></textarea></td>
  </tr>

  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />



</table>
  <input type="image" height="1" width="1" border="0" />
</form>
</body>
<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "emxEngrVisiblePageButtomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

