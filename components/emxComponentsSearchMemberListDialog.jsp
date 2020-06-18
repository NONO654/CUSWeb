<%--  emxComponentsSearchMemberListDialog.jsp 
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsSearchMemberListDialog.jsp.rca 1.7 Wed Oct 22 16:17:48 2008 przemek Experimental przemek $
--%>


<%@include file = "emxComponentsCommonUtilAppInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@ page import = "com.matrixone.apps.domain.DomainConstants" %>
<%@ page import = "com.matrixone.apps.domain.util.PersonUtil"%>
<%@ page import = "com.matrixone.apps.common.EngineeringChange" %>

<script language="javascript" src="../common/scripts/emxUIFormUtil.js"></script>
<script language="javascript">

    /*This function is needed to support AEF Global Search*/
    function doSearch() {
        var objForm = document.editDataForm;
        objForm.action="../common/emxTable.jsp?selection=single";
        objForm.submit();
    }

    /* This function is added for the Enter Key functionality*/
    function submitForm() {
        bottomFrame = findFrame(getTopWindow(),"BottomFrame");
        if(bottomFrame == null) 
        {
            parent.doFind();
        } else 
        {
            bottomFrame.validateLimit();
        }
    }

    function showMemberListOwner() {
        var sURL    = "../components/emxCommonSearch.jsp?formName=editDataForm&";
        sURL        = sURL + "frameName=pageContent&searchmode=chooser&suiteKey=Components";
        sURL        = sURL + "&searchmenu=APPMemberSearchInMemberList&searchcommand=APPFindPeople";
        sURL        = sURL + "&fieldNameActual=HiddenMemberListOwner&fieldNameDisplay=MemberListOwner";
        showChooser(sURL, 700, 500);
    }

    function  ShowBU()
    {
        showModalDialog('../components/emxComponentsSelectBusinessUnitDialogFS.jsp?fieldNameDisplay=owningBU&fieldNameOID=objectId&strFormPopUp=false',400,500);
        return;
    }

    function clearOwningBU() { 
        document.editDataForm.owningBU.value = ""; 
        document.editDataForm.objectId.value = ""; 
    }

</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
    String vaultDefaultSelection  = PersonUtil.getSearchDefaultSelection(context);
    String selDisplayVault        = "";
    String selVaultOptionAll      = "";
    String selVaultOptionLocal    = "";
    String selVaultOptionDefault  = "";
    String selVaultOptionSelected = "";
    String strVaults              = "";

    if (  PersonUtil.SEARCH_DEFAULT_VAULT.equals(vaultDefaultSelection) ) {
        selVaultOptionDefault = "checked";
    } else if (  PersonUtil.SEARCH_LOCAL_VAULTS.equals(vaultDefaultSelection) ) {
        selVaultOptionLocal = "checked";
    } else if (  PersonUtil.SEARCH_ALL_VAULTS.equals(vaultDefaultSelection) ) {
        selVaultOptionAll = "checked";
    } else if (!PersonUtil.SEARCH_DEFAULT_VAULT.equals(vaultDefaultSelection) &&
           !PersonUtil.SEARCH_LOCAL_VAULTS.equals(vaultDefaultSelection) &&
           !PersonUtil.SEARCH_ALL_VAULTS.equals(vaultDefaultSelection) ) {
        selVaultOptionSelected = "checked";
        strVaults = vaultDefaultSelection;
        selDisplayVault = i18nNow.getI18NVaultNames(context, vaultDefaultSelection, request.getHeader("Accept-Language"));
    }

    String paramName = null;
    String paramValue = null;
    Enumeration enumParamNames = emxGetParameterNames(request);

    String timeStamp = Request.getParameter(request, "timeStamp");
    String queryLimit = emxGetParameter(request,"queryLimit");
    String pagination = emxGetParameter(request,"pagination");
    String selVaultName = emxGetParameter(request,"vaultName");

    if(queryLimit == null || queryLimit.trim().length() == 0 ) {
      queryLimit = "100";
    }

    String typeMemberList = EngineeringChange.TYPE_MEMBER_LIST;
    String typeI18N = i18nNow.getTypeI18NString(typeMemberList,sLanguage);
    String typeIcon = UINavigatorUtil.getTypeIconProperty(context,typeMemberList);

    String sObjectId = emxGetParameter(request,"objectId");
    String sECRECOUI = emxGetParameter(request,"ecrEcoUi");
	/** Added For X3 */
   	String TYPE_PLANT = PropertyUtil.getSchemaProperty(context,"type_Plant");
    String stype=emxGetParameter(request,"type");
	String sLocationId =null;
	String splantId=emxGetParameter(request,"objPlantId");
	/** End */
    String sOwningOrganizationName = "";

    if (sECRECOUI != null && "true".equalsIgnoreCase(sECRECOUI) && (sObjectId != null && !"".equals(sObjectId) && !" ".equals(sObjectId) && !"null".equals(sObjectId))) {
    
      DomainObject oOwningOrgObj = DomainObject.newInstance(context, sObjectId);
      sOwningOrganizationName = oOwningOrgObj.getInfo(context, DomainConstants.SELECT_NAME);
    }
	/** Added For X3 */
    if(splantId!=null && splantId.length()!=0)
	{   
		MapList mlLocationList =null;

		StringList busSelList = new StringList();
		String PLANT_ID = PropertyUtil.getSchemaProperty(context,"attribute_PlantID");
                StringList relSelList = new StringList();
                busSelList.add(DomainObject.SELECT_ID);
                busSelList.add(DomainObject.SELECT_NAME);
                String sWherecondition ="attribute["+PLANT_ID+"]"+" == '"+splantId+"'";
				mlLocationList=DomainObject.findObjects(context, // eMatrix context
                                                        stype,  // type pattern
                                                        "*",
                                                        DomainConstants.QUERY_WILDCARD,     // revision pattern
                                                        DomainConstants.QUERY_WILDCARD,     // owner pattern
                                                        DomainConstants.QUERY_WILDCARD,     // vault pattern
                                                        sWherecondition,        // where expression
                                                        false,               // expand types
                                                        busSelList);     // object selects
			if( (mlLocationList !=null) && (mlLocationList.size()>0) )
            {
                sLocationId=(String)((Map)mlLocationList.get(0)).get(DomainObject.SELECT_ID);
			}
            DomainObject oOwningOrgObj = DomainObject.newInstance(context, sLocationId);
      sOwningOrganizationName = oOwningOrgObj.getInfo(context, DomainConstants.SELECT_NAME);
			
	}
%>
<body onload="turnOffProgress(),getTopWindow().loadSearchFormFields()">
<form name="editDataForm" method="post" onSubmit="submitForm(); return false">

    <input type="hidden" name ="queryLimit" value ="<xss:encodeForHTMLAttribute><%=queryLimit%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name ="QueryLimit" value ="<xss:encodeForHTMLAttribute><%=queryLimit%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="timeStamp" value="<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" value ="<xss:encodeForHTMLAttribute><%=pagination%></xss:encodeForHTMLAttribute>" name ="pagination"/>
    <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=sObjectId%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="table" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "table")%></xss:encodeForHTMLAttribute>"/>


    <table border="0" cellpadding="5" cellspacing="2" width="100%">
        <tr>
            <td width="150" class="label"><label for="Type"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Type</emxUtil:i18n></label></td>
            <td width="550" class="inputField"><img src="../common/images/<%=typeIcon%>"/><%=typeI18N%></td>
        </tr>
        <tr>
            <td width="150" class="label"><label for="Type"><emxUtil:i18n localize="i18nId">emxFramework.Basic.Name</emxUtil:i18n></label></td>
            <td width="550" class="inputField">
                <input type="text" name="Name" id="" value="<%=DomainObject.QUERY_WILDCARD%>"/>
            </td>
        </tr>
        <tr>
            <td width="150" class="label">
                <framework:i18n localize="i18nId">
                    emxFramework.Basic.Description
                </framework:i18n>
            </td>
            <td class="field">
                <textarea name="Description"></textarea>
            </td>
        </tr>
        <tr>
            <td width="150" nowrap="nowrap" class="label">
                <framework:i18n localize="i18nId">
                    emxComponents.Common.Owner
                </framework:i18n>
            </td>
            <td nowrap="nowrap" class="field">
                <input type="text" name="MemberListOwner" size="20" value="*" readonly="readonly"/>
                <input class="button" type="button" name="selectOrganization" size="200" value="..." alt=""  onClick="javascript:showMemberListOwner();"/>
                <input type="hidden" name="HiddenMemberListOwner" size="20" value="*"/>
            </td>
        </tr>
<!-- ADDED FOR X3 -->
     <%if(TYPE_PLANT.equals(stype))
{
%>
<input type="hidden" name="PlantId" size="20" value="<%=sLocationId%>"/>
<%}%>
<!-- END FOR X3 -->
        <tr>
          <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.OwningOrganization</emxUtil:i18n></td>
          <td class="inputField"><input type="text" name="owningBU" size="20" onfocus="blur()" value="<xss:encodeForHTMLAttribute><%=sOwningOrganizationName %></xss:encodeForHTMLAttribute>" />
          <input type="button" name="" value="..." onclick="javascript:ShowBU();" />
          <a href onClick="clearOwningBU();return false;"><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
          </td>
      </tr>

        <tr>
            <td nowrap="nowrap" class="label">
                <framework:i18n localize="i18nId">emxComponents.Common.Vault</framework:i18n>
            </td>
            <td nowrap="nowrap" class="field">
<%
            String vaultAwareness = EnoviaResourceBundle.getProperty(context,"eServiceSuiteComponents.VaultAwareness");

            if (vaultAwareness.equalsIgnoreCase("FALSE")) {
%>
                 <input type="radio"  value="<%=PersonUtil.SEARCH_DEFAULT_VAULT%>" <%=selVaultOptionDefault%> name="vaultOption"/><emxUtil:i18n localize="i18nId">emxComponents.Common.Default</emxUtil:i18n><br>
                 <input type="radio"  value="<%=PersonUtil.SEARCH_LOCAL_VAULTS%>" <%=selVaultOptionLocal%> name="vaultOption" /><emxUtil:i18n localize="i18nId">emxComponents.Common.Local</emxUtil:i18n><br>
                 <input type="radio"  value="Selected" <%=selVaultOptionSelected%> name="vaultOption"/><emxUtil:i18n localize="i18nId">emxComponents.Common.Selected</emxUtil:i18n>
                 <input type="text" name="vaultNameDisplay" id="" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=selDisplayVault%></xss:encodeForHTMLAttribute>"/>
                 <input type="button" name="btn" value="..." onclick="javascript:document.forms[0].vaultOption[2].checked=true;showChooser('../common/emxVaultChooser.jsp?multiSelect=false&fieldNameActual=vaultName&fieldNameDisplay=vaultNameDisplay&isFromSearchForm=true','700','500');" />
                 <input type="hidden" name="vaultName" id="" size="20" value="<xss:encodeForHTMLAttribute><%=strVaults%></xss:encodeForHTMLAttribute>"/><br>
                 <input type="radio"  value="<%=PersonUtil.SEARCH_ALL_VAULTS%>"  <%=selVaultOptionAll%> name="vaultOption"/><emxUtil:i18n localize="i18nId">emxComponents.Common.All</emxUtil:i18n>
<%
            } else {
%>
              <%=strVaults%>
<%
            }
%>
            </td>
        </tr>
    </table>&nbsp;
<%
    enumParamNames = emxGetParameterNames(request);
    while(enumParamNames.hasMoreElements()) {
        paramName = (String) enumParamNames.nextElement();
        paramValue = (String)emxGetParameter(request, paramName);
        if(!paramName.equals("Name") &&
           !paramName.equals("MemberListOwner") &&
           !paramName.equals("vaultOption") &&
           !paramName.equals("vaultName") &&
           !paramName.equals("vaultNameDisplay") &&
           !paramName.equals("queryLimit") &&
           !paramName.equals("timeStamp") &&
           !paramName.equals("pagination") && !paramName.equals("objectId") && !paramName.equals("table")) {
%>
            <input type="hidden" name="<xss:encodeForHTMLAttribute><%=paramName%></xss:encodeForHTMLAttribute>" value="<xss:encodeForHTMLAttribute><%=paramValue%></xss:encodeForHTMLAttribute>"/>
<%
        }
    }
%>
</form>
</body>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
