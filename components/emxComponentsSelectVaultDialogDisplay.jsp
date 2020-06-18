<%--
  emxComponentsSelectVaultDialogDisplay.jsp-  This page Dialog Page for Vault Selection

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsSelectVaultDialogDisplay.jsp.rca 1.13 Wed Oct 22 16:18:26 2008 przemek Experimental przemek $
--%>


<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "eServiceUtil.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<script>
  var bMultiSelect = parent.getWindowOpener().bVaultMultiSelect;
  var varType = ""
  if(bMultiSelect) {
    varType = "checkbox";
  }
  else {
    varType = "radio";
  }

<%
  String languageStr = request.getHeader("Accept-Language");
  StringList strListVaults= new StringList();
  String strVaults="";
  String sAll = i18nStringNow("emxComponents.Common.All", languageStr);
  String objectType = emxGetParameter(request,"objectType");
  String isFromSearchForm = emxGetParameter(request,"isFromSearchForm");
  String frameName = emxGetParameter(request,"frameName");
  if(isFromSearchForm == null) {
  isFromSearchForm="false";
  }
  String fieldNameActual = emxGetParameter(request,"fieldNameActual");
  if(fieldNameActual == null) {
  fieldNameActual="dummyVar";
  }

  if(vaultAwarenessString.equalsIgnoreCase("true")){
    try
    {
      strListVaults = com.matrixone.apps.common.Person.getCollaborationPartnerVaults(context,objectType);
      StringItr strItr = new StringItr(strListVaults);
      if(strItr.next()){
        strVaults =strItr.obj().trim();
      }
      while(strItr.next())
      {
        strVaults += "," + strItr.obj().trim();
      }

    }
    catch (Exception ex) {
      throw ex;
    }

  }else {
    VaultItr vItr = new VaultItr(Vault.getVaults(context, true));
    while(vItr.next())
    {
      if (strVaults.equals("")){
       strVaults = (vItr.obj()).getName().trim();
      } else {
       strVaults += "," + (vItr.obj()).getName().trim();
      }
    }
  }
%>

function submitForm()
{
  var selectedVaults="";

  for(k=0;k<document.selectVault.elements.length;k++)
  {
    var obj = document.selectVault.elements[k];
    if(obj.type == varType && obj.checked == true )
    {
      if(selectedVaults != "") {
        selectedVaults += ",";
      }
      selectedVaults += obj.value;
    }
  }
  if(selectedVaults == "")
  {
    alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.PleaseSelectAnItem</emxUtil:i18nScript>");
    return;
  }
  if(selectedVaults.substr(0,1) == "*") {
    if('<%=XSSUtil.encodeForJavaScript(context, vaultAwarenessString)%>'=="true"){
      selectedVaults = "<%=XSSUtil.encodeForJavaScript(context, strVaults)%>";
    } else{
      selectedVaults = "*";
    }
  }

  if(<%=XSSUtil.encodeForJavaScript(context, isFromSearchForm)%>) {
    var frame = "<%=XSSUtil.encodeForJavaScript(context, frameName)%>";
    if(frame=="") 
    var topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"searchContent");
    else
    var topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),frame);
    var temp = topFrameObj.document.forms[0].<%=XSSUtil.encodeForJavaScript(context, fieldNameActual)%>;
  if(selectedVaults == "*") {
   temp.value = "<%=XSSUtil.encodeForJavaScript(context, sAll)%>";
  } else {
   temp.value = selectedVaults;
  }
  } else {
   if(selectedVaults == "*") {
    parent.getWindowOpener().txtVault.value = "<%=XSSUtil.encodeForJavaScript(context, sAll)%>";
    if(parent.getWindowOpener().selectOption) {
      parent.getWindowOpener().selectOption.value = "ALL_VAULTS";
    }
  } else {
    parent.getWindowOpener().txtVault.value = selectedVaults;
    if(parent.getWindowOpener().selectOption) {
      parent.getWindowOpener().selectOption.value = selectedVaults;
    }
  }
  }
  window.closeWindow();
}

</script>

<form name="selectVault" onSubmit="submitForm(); return false;">
  <table width="100%" border="0">

<script>
  var bMultiSelect = parent.getWindowOpener().bVaultMultiSelect;
    if(bMultiSelect)
    {
      document.write("<tr>");
      document.write("<td width=\"5%\">");
      document.write("<input name=\"selectedVault\" type=\"checkbox\" value=\"*\" />");
      document.write("<\/td>");
      document.write("<td>  [<%=XSSUtil.encodeForJavaScript(context, sAll)%>]   <\/td>");
      document.write("<\/tr>");

    }
</script>

<%
  StringList strlistVaults = new StringList();
  // Get the selected vaults & show those checkboxes as checked.
  String selectedVaults = emxGetParameter(request,"selectedVaults");
  if (selectedVaults != null && !"null".equals(selectedVaults) &&  !"".equals(selectedVaults)){
    if(selectedVaults.indexOf(',')>0){
      StringTokenizer sVaults = new StringTokenizer(selectedVaults,",");
        while(sVaults.hasMoreTokens())
        {
          String selVault = sVaults.nextToken();
          if(!strlistVaults.contains(selVault)){
            strlistVaults.addElement(selVault);
          }
        }
    } else{
      strlistVaults.addElement(selectedVaults);

    }
  }

  StringTokenizer vaults = new StringTokenizer(strVaults,",");
  while(vaults.hasMoreTokens())
  {
    String name = vaults.nextToken();
%>
   <!--  <tr> -->
   <tr class='<framework:swap id ="1" />'>
      <td width="5%">
      <script>
        var bMultiSelect = parent.getWindowOpener().bVaultMultiSelect;

    if(bMultiSelect)
    {
<%
      if(strlistVaults.contains(name)){
%>
      document.write("<input name=\"selectedVault\"  checked type=\"checkbox\" value=\"<%=XSSUtil.encodeForHTMLAttribute(context, name)%>\" />");
<%
      } else{
%>
      document.write("<input name=\"selectedVault\" type=\"checkbox\" value=\"<%=XSSUtil.encodeForHTMLAttribute(context, name)%>\" />");
<%
      }
%>
    }
    else
    {
        document.write("<input name=\"selectedVault\" type=\"radio\" value=\"<%=XSSUtil.encodeForHTMLAttribute(context, name)%>\" />");
    }
    </script>
      </td>
      <td align="left"><%=XSSUtil.encodeForHTML(context, i18nNow.getAdminI18NString("Vault",name,languageStr))%></td>
    </tr>
<%
  }
%>
  </table>
</form>

<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
