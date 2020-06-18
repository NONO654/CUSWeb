<%--  emxSelectVaultDialogDisplay.jsp -  This page Dialog Page for Vault Selection
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>


<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>

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
  StringList strListVaults= new StringList();
  String strVaults="";
  String sAll = EngineeringUtil.i18nStringNow("emxEngineeringCentral.Common.All", request.getHeader("Accept-Language"));
  String objectType = emxGetParameter(request,"objectType");

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
    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.PleaseSelectAnItem</emxUtil:i18nScript>");
    return;
  }
  if(selectedVaults.substr(0,1) == "*") {
	  //XSSOK
    if("<%=vaultAwarenessString%>"=="true"){
    	//XSSOK
      selectedVaults = "<%=strVaults%>";
    } else{
      selectedVaults = "*";
    }
  }

  if(selectedVaults == "*") {  
	  //XSSOK
    parent.getWindowOpener().txtVault.value = "<%=sAll%>";
    if(parent.getWindowOpener().selectOption) {
      parent.getWindowOpener().selectOption.value = "ALL_VAULTS";
    }
  } else {
    parent.getWindowOpener().txtVault.value = selectedVaults;
    if(parent.getWindowOpener().selectOption) {
      parent.getWindowOpener().selectOption.value = selectedVaults; 
    }
  }
  parent.closeWindow();
}

</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="selectVault">
  <table width="100%" border="0">

<script>
    if(bMultiSelect)
    {
      document.write("<tr>");
      document.write("<td width=\"5%\">");
      document.write("<input name=\"selectedVault\" type=\"checkbox\" value=\"*\" />");
      document.write("<\/td>");
      //XSSOK
      document.write("<td>  [<%=sAll%>]   <\/td>");
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
    <tr>
      <td width="5%">
      <script>
    if(bMultiSelect)
    {
<%
      if(strlistVaults.contains(name)){
%>
	//XSSOK
      document.write("<input name=\"selectedVault\"  checked type=\"checkbox\" value=\"<%=name%>\" />");
<%
      } else{
%>
//XSSOK
      document.write("<input name=\"selectedVault\" type=\"checkbox\" value=\"<%=name%>\" />");
<%
      }
%>
    }
    else
    {
    	//XSSOK
        document.write("<input name=\"selectedVault\" type=\"radio\" value=\"<%=name%>\" />");
    }
    </script>
      </td>
      <td align="left"><xss:encodeForHTML><%=name%></xss:encodeForHTML></td>
    </tr>
<%
  }
%>
  </table>
  <input type="image" name="inputImage" height="1" width="1" src="../common/images/utilSpacer.gif" hidefocus="hidefocus" 
style="-moz-user-focus: none" />
</form>

<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
