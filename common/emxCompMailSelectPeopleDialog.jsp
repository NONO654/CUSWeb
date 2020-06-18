<%-- emxCompMailSelectPeopleDialog.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCompMailSelectPeopleDialog.jsp.rca 1.12 Wed Oct 22 15:47:50 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxCompCommonUtilAppInclude.inc"%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<script language="javascript">
  function doSearch() {
<%
  if(PersonUtil.isPersonObjectSchemaExist(context))
  {
%>
      var objOption=document.searchform.FilterOption.value;
      if(objOption=="NotDefault") {
        var checkedFlag = false;
        for( var i = 0; i < document.searchform.queryfilter.length; i++ ){
            if (document.searchform.queryfilter[i].checked ){
              checkedFlag = true;
              break;
            }
        }
        if(document.searchform.queryfilter.length>1){
          if(!checkedFlag){
           alert("<emxUtil:i18nScript localize='i18nId'>emxFramework.IconMail.SelectAValueToSearchIn</emxUtil:i18nScript>");
           return;
          }
         }
       } 
<% 
    }
%>
  if ( document.searchform.txtUsername.value == "" || document.searchform.txtUsername.value == null ) {
      alert("<emxUtil:i18nScript  localize='i18nId'>emxFramework.IconMail.Common.UserNameMessage</emxUtil:i18nScript>");
      document.searchform.txtUsername.focus();
      return;
    } 
<%
  if(PersonUtil.isPersonObjectSchemaExist(context))
  {
%>
    else if ( document.searchform.txtFirstName.value == "" || document.searchform.txtFirstName.value == null ) {
      alert("<emxUtil:i18nScript  localize='i18nId'>emxFramework.IconMail.Common.FirstNameMessage</emxUtil:i18nScript>");
      document.searchform.txtFirstName.focus();
      return;
    } else if ( document.searchform.txtLastName.value == "" || document.searchform.txtLastName.value == null ) {
      alert("<emxUtil:i18nScript  localize='i18nId'>emxFramework.IconMail.Common.LastNameMessage</emxUtil:i18nScript>");
      document.searchform.txtLastName.focus();
      return;
    } 
<% 
  }
%>
    else {
      document.searchform.submit();
      return;
    }
  }

  function closeWindow() {
    parent.window.closeWindow();
    return;
  }

  function clear() {
    document.searchform.txtType.value="";
    document.searchform.txtType.focus();
  }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  // ------------------------ Page content below here  ---------------------
  String sLink = emxGetParameter(request,"page");
  String sToAddress   = emxGetParameter(request,"toAddress");
  String sCCAddress   = emxGetParameter(request,"ccAddress");
 String toPeople   = emxGetParameter(request,"toPeople");
  String ccPeople   = emxGetParameter(request,"ccPeople");

%>

<form name="searchform" id="searchform" method="post" onSubmit="doSearch(); return false" target="_parent" action="emxCompMailSelectPeopleResultsFS.jsp">
  <input type="hidden" name="page" value="<xss:encodeForHTMLAttribute><%=sLink%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="toAddress" value="<xss:encodeForHTMLAttribute><%=sLink%></xss:encodeForHTMLAttribute>" />  

  <table border="0" cellpadding="5" cellspacing="2" width="530">
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.UserName</emxUtil:i18n>
      </td>
      <td class="inputField">
        <input type="text" name="txtUsername" id="txtUsername" value="*"/>
      </td>
    </tr>
<%  
  if(PersonUtil.isPersonObjectSchemaExist(context))
  {   
%>
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.FirstName</emxUtil:i18n>
      </td>
      <td class="inputField">
        <input type="text" name="txtFirstName" id="txtFirstName" value="*"/>
      </td>
    </tr>
    <tr>
      <td class="label">
        <emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.LastName</emxUtil:i18n>
      </td>
      <td class="inputField">
        <input type="text" name="txtLastName" id="txtLastName" value="*"/>
      </td>
    </tr>
  <%
     String sPropertiesSelection = EnoviaResourceBundle.getProperty(context, "emxFramework.IconMail.FindSelection");
     String sPropertiesDisplay = EnoviaResourceBundle.getProperty(context, "emxFramework.IconMail.ShowSelects");

     if( sPropertiesDisplay==null || sPropertiesDisplay.equals("null") || sPropertiesDisplay.equals(""))
     {
              %>
              <input type="hidden" name="FilterOption" value="Default"/>
              <input type="hidden" name="queryfilter" value="Customers|Suppliers|Collaboration Partners|My Company"/>
              <%
     }
     else
     {
            if( sPropertiesSelection==null || sPropertiesSelection.equals("null") || sPropertiesSelection.equals(""))
            {
              %>
              <input type="hidden" name="FilterOption" value="Default"/>
              <input type="hidden" name="queryfilter" value="Customers|Suppliers|Collaboration Partners|My Company"/>
              <%
            }
            else
            {
               StringTokenizer st = new StringTokenizer(sPropertiesSelection, ",");
              if(sPropertiesSelection.equals("Entire Database")){
              %>
              <input type="hidden" name="FilterOption" value="Entire Database"/>
              <input type="hidden" name="queryfilter" value="Entire Database"/>
              <%}else{
              if(sPropertiesDisplay.equalsIgnoreCase("true")) {
               %><tr>
                     <td class="label"><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.SearchIn</emxUtil:i18n></td>
                    <td class="inputField">
               <%while(st.hasMoreTokens())
                {
                 String sActualToken=st.nextToken().trim();
                 String sToken=removeSpace(sActualToken);
                 sToken="emxFramework.IconMail.FindSelection."+sToken;
                %>

                  <input type="checkbox" name="queryfilter" value="<%=sActualToken%>" checked /><emxUtil:i18n localize="i18nId"><%=sToken%></emxUtil:i18n></br>

              <%  }%></td></tr>
              <input type="hidden" name="FilterOption" value="NotDefault"/>
			   <input type="hidden" name="toPeople" value="<%=XSSUtil.encodeForHTMLAttribute(context,toPeople)%>"/>
			   <input type="hidden" name="ccPeople" value="<%=XSSUtil.encodeForHTMLAttribute(context,ccPeople)%>"/>
			   
            <%
              }else{%>
              <input type="hidden" name="FilterOption" value="Default"/>
               <%
               StringTokenizer st2 = new StringTokenizer(sPropertiesSelection, ",");
               while(st2.hasMoreTokens())
                {
                String sToken2=st2.nextToken().trim();
                %>
                  <input type="hidden" name="queryfilter" value="<%=sToken2%>" checked /></br>

              <%  }%>

          <%  }
          }
         }
       }
   }
%>

<%!
static public String removeSpace(String formatStr) {
    int flag1 = 1;
    int strLength = 0;
    int index = 0;
    while  (flag1 != 0)  {
      strLength = formatStr.length();
      index = 0;
      index = formatStr.indexOf(' ');
      if (index == -1) {
        flag1 = 0;
        break;
      }
      String tempStr1 = formatStr.substring(0,index);
      String tempStr2 = formatStr.substring(index+1,strLength);
      formatStr = tempStr1 + tempStr2;
    }
    return formatStr;
  }
%>
    

  </table>
</form>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
