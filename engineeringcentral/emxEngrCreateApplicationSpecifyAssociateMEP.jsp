<%--  emxEngrCreateApplicationSpecifyAssociateMEP.jsp   - Displays MEPs associated with context Enterprise Part for selection.
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
<%@ include file = "../emxJSValidation.inc" %>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<head>
  <%@include file = "../common/emxUIConstantsInclude.inc"%>

</head>

<%
Part mePart = (Part)DomainObject.newInstance(context,
                    DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);

Properties createPartprop = (Properties) session.getAttribute("createPartprop_KEY");
      String type                = DomainConstants.TYPE_APPLICATION_PART;

      String partNum             = createPartprop.getProperty("partNum_KEY");
      String policy              = createPartprop.getProperty("policy_KEY");
         String revision            = createPartprop.getProperty("revision_KEY");
      String rev                 = createPartprop.getProperty("rev_KEY");
      String Vault               = createPartprop.getProperty("Vault_KEY");
      String Owner               = createPartprop.getProperty("Owner_KEY");
      String description         = createPartprop.getProperty("description_KEY");
         String checkAutoName       = createPartprop.getProperty("checkAutoName_KEY");
      String locName             = createPartprop.getProperty("locName_KEY");
      String locId               = createPartprop.getProperty("locId_KEY");
         String RDO                 = createPartprop.getProperty("RDO_KEY");
         String RDOId               = createPartprop.getProperty("RDOId_KEY");
      String objectId            = createPartprop.getProperty("objectId_KEY");
      String assemblyPartId      = createPartprop.getProperty("assemblyPartId_KEY");
      String jsTreeID            = createPartprop.getProperty("jsTreeID_KEY");
      String suiteKey            = createPartprop.getProperty("suiteKey_KEY");
      String SuiteDirectory      = createPartprop.getProperty("suiteDirectory_KEY");

      // get the request attributes from previous screen
      String[] methodargs = new String[2];
      String[] Entmethodargs = new String[2];
      MapList equivList = new MapList();
      String[] init = new String[] {};

      if(checkAutoName == null || "null".equals(checkAutoName)){
         checkAutoName="";
      }

      String languageStr  = request.getHeader("Accept-Language");
      String partLabel    = i18nNow.getTypeI18NString(type,languageStr) + " " + partNum + " " + rev;
      String prevmode     = "true";

      String typeIcon;
      String defaultTypeIcon = JSPUtil.getCentralProperty(application, session, "type_Default","SmallIcon");
      String alias           = FrameworkUtil.getAliasForAdmin(context, "type", type, true);

      if ( alias == null || alias.equals("")) {
         typeIcon = defaultTypeIcon;
      }else {
         typeIcon = JSPUtil.getCentralProperty(application, session, alias, "SmallIcon");
      }

%>

<script language="JavaScript">

  function goBack()
  {
	  document.editForm.action="emxEngrCreateApplicationPartAddAttributesFS.jsp?loc=<%=XSSUtil.encodeForJavaScript(context,locName)%>&RDOOID=<%=XSSUtil.encodeForJavaScript(context,RDOId)%>&locOID=<%=XSSUtil.encodeForJavaScript(context,locId)%>";
      document.editForm.submit();
      return;
  }

  function goNext()
  {
      var anySelected = false;
      for(var i = 0; i<document.editForm.elements.length; i++)
      {
        var CheckBoxObj = document.editForm.elements[i];
        if(CheckBoxObj.type == "checkbox" && CheckBoxObj.checked == true)
        {
           anySelected = true;
        }
      }
      if(anySelected)
      {
             document.editForm.action="emxEngrCreateApplicationPart.jsp";
               document.editForm.submit();
               return;
      }
      else {
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.SelectAssociatedMEP</emxUtil:i18nScript>");
              return;
      }

      return;
  }


  function cancel()
  {
    parent.closeWindow();
  }

 </script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="editForm" method="post" action="emxEngrCreateApplicationPart.jsp" target="_parent">
<table border="0" cellpadding="5" cellspacing="2" width="100%">

<%
   String strId = objectId;

   HashMap argsMap = new HashMap();
   argsMap.put("objectId",strId);
   methodargs = JPO.packArgs(argsMap);
   //equivList = (com.matrixone.apps.domain.util.MapList)JPO.invoke(context, "emxPart", init, "getEnterpriseManufacturerEquivalents", methodargs,com.matrixone.apps.domain.util.MapList.class);
   equivList = (com.matrixone.apps.domain.util.MapList)JPO.invoke(context, "emxPart", init, "getEnterpriseValidManufacturerEquivalents", methodargs,com.matrixone.apps.domain.util.MapList.class);

   int mepListSize = equivList.size();

 //Multitenant
   //String strMessage=i18nNow.getI18nString("emxEngineeringCentral.Common.NoObjectsFoundForTheSpecifiedCriteria", "emxEngineeringCentralStringResource",languageStr);
   String strMessage=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.NoObjectsFoundForTheSpecifiedCriteria");



%>
<table class="list" id="UITable" width="100%" border="0" cellpadding="3" cellspacing="2">
<tr>
    <th>
        <input type="checkbox" name="checkAll" onClick="checkMEP();allSelected('editForm');" />
    </th>
    <th class="heading1" nowrap="nowrap">
        <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Name</emxUtil:i18n>
    </th>
    <th class="heading1" nowrap="nowrap">
        <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Revision</emxUtil:i18n>
    </th>
    <th class="heading1" nowrap="nowrap">
        <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Type</emxUtil:i18n>
    </th>
    <th class="heading1" nowrap="nowrap">
        <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Description</emxUtil:i18n>
    </th>
    <th class="heading1" nowrap="nowrap">
        <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Manufacturer</emxUtil:i18n>
    </th>
    <th class="heading1" nowrap="nowrap">
        <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Part.EnterpriseParts</emxUtil:i18n>
    </th>
    <th class="heading1" nowrap="nowrap">
        <!-- //fix for bug 306501 -->
        <emxUtil:i18n localize="i18nId">emxEngineeringCentral.CommonLocation.State</emxUtil:i18n>
    </th>
</tr>

<%
if(mepListSize == 0) {
%>
<!-- XSSOK -->
<tr><td colspan="6"><%=strMessage %></td></tr>
<%
}
%>
<script language="JavaScript">
//added to check whether there exist any MEPs
 function checkMEP(){
     if(document.editForm.checkAll.checked == true){
<%  if(mepListSize == 0) {   %>
        alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.NoObjectsFoundForTheSpecifiedCriteria</emxUtil:i18nScript>");
        document.editForm.checkAll.checked = false;
      <%     }    %>
      }
}

</script>

<%

   Iterator mapItr = equivList.iterator();
   DomainObject doMep = null;

   int k = 0;
   String style="even";

   while(mapItr.hasNext())
         {
            k++;

            if (k % 2 == 0) {
               style="odd";
            }else {
               style="even";
            }

            Map mepMap = (Map)mapItr.next();

            String tempobjid = (String)mepMap.get("id");
      doMep = DomainObject.newInstance(context,tempobjid);

      StringList objectSelects = new StringList();
      objectSelects.add(DomainConstants.SELECT_NAME);
      objectSelects.add(DomainConstants.SELECT_REVISION);
      objectSelects.add(DomainConstants.SELECT_TYPE);
      objectSelects.add(DomainConstants.SELECT_DESCRIPTION);
      objectSelects.add("relationship[Manufacturing Responsibility].from.id");
      objectSelects.add("relationship[Manufacturing Responsibility].from.name");
      objectSelects.add(DomainConstants.SELECT_CURRENT);
      Hashtable tempMap = (Hashtable)doMep.getInfo(context, objectSelects);

	  mePart.setId(tempobjid);

            String newWinURL = "../common/emxTree.jsp?emxSuiteDirectory=engineeringcentral&suiteKey=EngineeringCentral&objectId="+tempobjid;

        // Added for bug # 310791
        String aliasName = FrameworkUtil.getAliasForAdmin(context, "type", (String)tempMap.get(DomainConstants.SELECT_TYPE), true);
        String defaultTypeIconForPart = JSPUtil.getCentralProperty(application, session, "type_Part", "SmallIcon");
        String typeIconForPart = "";

        if ((aliasName == null) || (aliasName.equals("")) || (aliasName.equals("null")))
        {
          typeIconForPart = defaultTypeIconForPart;
        }
        else
        {
          typeIconForPart = JSPUtil.getCentralProperty(application, session, aliasName, "SmallIcon");
          if (typeIconForPart == null || "".equals(typeIconForPart) || "null".equals(typeIconForPart))
          {
              typeIconForPart = defaultTypeIconForPart;
          }
        }
%>
<!-- XSSOK -->
<tr class="<%=style%>">
<td width="3%" ><input type="checkbox" name="<xss:encodeForHTMLAttribute><%="checkBox"+k%></xss:encodeForHTMLAttribute>" value="<xss:encodeForHTMLAttribute><%=tempobjid%></xss:encodeForHTMLAttribute>" onClick="updateSelected('editForm')" /></td>
<td class="listCell" style="text-align: " valign="top">
	<!-- XSSOK -->
   <img src="../common/images/<%=typeIconForPart%>" border="0" alt="Part" />&nbsp;
   <!-- XSSOK -->
   <a href="javascript:emxShowModalDialog('<%=newWinURL%>',700,600,false)"><%=(String)tempMap.get(DomainConstants.SELECT_NAME) %>
   </a>
</td>
<!-- XSSOK -->
<td class="listCell" style="text-align: " valign="top"><%=(String)tempMap.get(DomainConstants.SELECT_REVISION)%></td>
<!-- XSSOK -->
<td class="listCell" style="text-align: " valign="top"><%=i18nNow.getTypeI18NString((String)tempMap.get(DomainConstants.SELECT_TYPE), languageStr)%></td>
<!-- XSSOK -->
<td class="listCell" style="text-align: " valign="top"><%=(String)tempMap.get(DomainConstants.SELECT_DESCRIPTION)%></td>

<%
      String companyId = (String)tempMap.get("relationship[Manufacturing Responsibility].from.id");
      newWinURL = "../common/emxTree.jsp?emxSuiteDirectory=engineeringcentral&suiteKey=EngineeringCentral&objectId="+companyId;
%>

<td class="listCell" style="text-align: " valign="top"><a href="javascript:emxShowModalDialog('<xss:encodeForURL><%=newWinURL%></xss:encodeForURL>',700,600,false)"> <xss:encodeForHTML><%=(String)tempMap.get("relationship[Manufacturing Responsibility].from.name")%></xss:encodeForHTML></a></td>
<td class="listCell" style="text-align: " valign="top">
<table>

<%
    Vector mepEnterpriseParts = mePart.getMEPEnterpriseParts(context);

    if(mepEnterpriseParts.size() > 0) {
       for(int i=0;i<mepEnterpriseParts.size();i++) {
             String epDetails = (String)mepEnterpriseParts.elementAt(i);
             String epDisplay = epDetails.substring(0,epDetails.indexOf("|"));
             StringBuffer epHrefVal = new StringBuffer(epDetails.substring(epDetails.indexOf("|") + 1));
             epHrefVal.append("&jsTreeID=");
             epHrefVal.append(jsTreeID);
             epHrefVal.append("&SuiteDirectory=");
             epHrefVal.append(SuiteDirectory);
             epHrefVal.append("&suiteKey=");
             epHrefVal.append(suiteKey);%>
            <tr>
               <td>
               <!-- XSSOK -->
                  <a href="javascript:emxShowModalDialog('<%=epHrefVal.toString()%>',700,600,false)"><%=epDisplay %></a>
               </td>
            </tr>
<%
       }
    }
%>
</table>
</td>
<!-- XSSOK -->
<td class="listCell" style="text-align: " valign="top"><%=i18nNow.getStateI18NString(DomainConstants.POLICY_MANUFACTURER_EQUIVALENT,(String)tempMap.get(DomainConstants.SELECT_CURRENT),languageStr)%></td>

<%}%>

</tr>
</table>

</table>

<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="type" value="<xss:encodeForHTMLAttribute><%=type%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="partNum" value="<xss:encodeForHTMLAttribute><%=partNum%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="revision" value="<xss:encodeForHTMLAttribute><%=revision%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="policy" value="<xss:encodeForHTMLAttribute><%=policy%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="rev" value="<xss:encodeForHTMLAttribute><%=rev%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="Vault" value="<xss:encodeForHTMLAttribute><%=Vault%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="Owner" value="<xss:encodeForHTMLAttribute><%=Owner%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="description" value="<xss:encodeForHTMLAttribute><%=description%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="RDOId" value="<xss:encodeForHTMLAttribute><%=RDOId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="SuiteDirectory" value="<xss:encodeForHTMLAttribute><%=SuiteDirectory%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="prevmode" value="<xss:encodeForHTMLAttribute><%=prevmode%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="RDO" value="<xss:encodeForHTMLAttribute><%=RDO%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="checkAutoName" value="<xss:encodeForHTMLAttribute><%=checkAutoName%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="assemblyPartId" value="<xss:encodeForHTMLAttribute><%=assemblyPartId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="locName" value="<xss:encodeForHTMLAttribute><%=locName%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="locId" value="<xss:encodeForHTMLAttribute><%=locId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="totalElements" value="<xss:encodeForHTMLAttribute><%=equivList.size()%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>" />

</form>
<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
