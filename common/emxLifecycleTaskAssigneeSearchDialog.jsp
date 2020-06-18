<%--  emxLifecycleTaskAssigneeSearchDialog.jsp   -  Main Dialog page for the search Person/Role/Group

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleTaskAssigneeSearchDialog.jsp.rca 1.5.3.2 Wed Oct 22 15:48:02 2008 przemek Experimental przemek $
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<!-- Java script functions -->

<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<%
  String objectId         = emxGetParameter(request,"objectId"); 
  String strSearchType    = emxGetParameter(request,"searchType"); 
  
  String strHidePersonSearch = emxGetParameter(request,"hidePersonSearch");
  String strHideRoleSearch   = emxGetParameter(request,"hideRoleSearch");
  String strHideGroupSearch  = emxGetParameter(request,"hideGroupSearch");
	
  String actionString     = "emxLifecycleTaskAssigneeSearchResultsFS.jsp"+"?hidePersonSearch="+XSSUtil.encodeForURL(context, strHidePersonSearch)+"&hideRoleSearch="+XSSUtil.encodeForURL(context, strHideRoleSearch)+"&hideGroupSearch="+XSSUtil.encodeForURL(context, strHideGroupSearch);
  Locale locale = context.getLocale();
%>

<script language="Javascript">
  
function doSearch() {
<%
	if ("Person".equals(strSearchType)) {
%>
    //added for the   form  not to submitted more than once
    if (!jsDblClick()) {
    return;
  }
    
    document.formSearch.firstName.focus();
    document.formSearch.userName.value = jsTrim(document.formSearch.userName.value);
    document.formSearch.firstName.value = jsTrim(document.formSearch.firstName.value);
    document.formSearch.lastName.value = jsTrim(document.formSearch.lastName.value);
  
    if(document.formSearch.userName.value == "" ||
       document.formSearch.firstName.value == "" ||
       document.formSearch.lastName.value == "" ||
       document.formSearch.companyName.value == "" )
    {
        clicked = false;
		//XSSOK
        alert("<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context,  "emxFramework.Common.PleaseEnterDetails", locale)%>");
    }
    else
    {    
    	
        startProgressBar();
        document.formSearch.submit();
    }

     return;
 <%
 	} else if ("Role".equals(strSearchType)) {%>
  

	    if(jsIsClicked()) {
	        //XSSOK
			alert("<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Search.RequestProcessMessage", locale)%>");
	        return;
	    }
	    if ( document.formSearch.txtName.value == "" || document.formSearch.txtName.value == null ) {
	      //XSSOK
		  alert("<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.SearchRole.EnterName", locale)%>");
	      document.formSearch.txtName.focus();
	      return;
	    } else {
	      if(jsDblClick())
	      {
	        startSearchProgressBar();
	        document.formSearch.submit();
	      }
	      return;
	    }
<%
	 } 
	else if ("Group".equals(strSearchType)) {%>
    var apostrophePosition;
    var hashPosition ;
    var doublequotesPosition;
    if ( document.formSearch.txtName ) {
       apostrophePosition   = document.formSearch.txtName.value.indexOf("'");
       hashPosition         = document.formSearch.txtName.value.indexOf("#");
       doublequotesPosition = document.formSearch.txtName.value.indexOf("\"");
    }

    if (apostrophePosition != -1 || hashPosition != -1 || doublequotesPosition != -1){
                alert("<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.SpecialCharacters", locale)%>");
                document.formSearch.txtName.value="";
                document.formSearch.txtName.focus();
    return;
  }
    if ( document.formSearch.txtName.value == "" || document.formSearch.txtName.value == null )
    {
          alert("<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.SearchGroup.EnterName", locale)%>");
      	  document.formSearch.txtName.focus();
     	  return;
    }
    else
    {
        if (!jsDblClick()) {
             return;
        }
      if (parent.frames[0].document.progress)
    {
       parent.frames[0].document.progress.src = "common/images/utilProgressBlue.gif";
      }
        startProgressBar(true);
        document.formSearch.submit();
        return;

    }
   <%}
  
 else {
	    throw new Exception("Invalid search type '" + strSearchType + "'");
	}
  %>	    
}
 function jsTrim (valString)
    {
      var trmString = valString;

        // this will get rid of leading spaces
        while (trmString.substring(0,1) == ' ')
        trmString = trmString.substring(1, trmString.length);

        // this will get rid of trailing spaces
        while (trmString.substring(trmString.length-1,trmString.length) == ' ')
        trmString = trmString.substring(0, trmString.length-1);

        return trmString;
    }
    
    
</script>

<form name="formSearch" method="post" action=<%=actionString%> target="_parent" onSubmit="javascript:doSearch(); return false">
	<input type="hidden" name="searchType" value="<xss:encodeForHTMLAttribute><%=strSearchType%></xss:encodeForHTMLAttribute>" />
	
<%
	if ("Person".equals(strSearchType)) {
	    
	    com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
	    String companyName = (person.getCompany(context)).getName();
	    String myCompanyId = (person.getCompany(context)).getId();
	    //Get the list of companies in the system
	    StringList selectList = new StringList();
	    selectList.add(com.matrixone.apps.common.Company.SELECT_NAME);
	    selectList.add(com.matrixone.apps.common.Company.SELECT_ID);
	    MapList companyList = com.matrixone.apps.common.Company.getCompanies(context,
	                                               "*",
	                                               selectList,
	                                               null);
	    Iterator companyItr = companyList.iterator();
	    
	    
%>

	<table cellpadding="5" cellspacing="2" border="0" width="100%" >
	  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
	  
	  <tr>
	    <!-- //XSSOK -->
		<td class="label"><%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.UserName", locale)%></td>
	    <td class="inputField"><input type="text" name="userName" size="16" value="*" /></td>
	  </tr>
	
	  <tr>
	    <!-- //XSSOK -->
		<td class="label"><%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.FirstName", locale)%></td>
	    <td class="inputField"><input type="text" name="firstName" size="16" value="*" /></td>
	  </tr>
	  
	  <tr>
	    <!-- //XSSOK -->
		<td class="label"><%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.LastName", locale)%></td>
	    <td class="inputField"><input type="text" name="lastName" size="16" value="*" /></td>
	  </tr>
	  
	  <tr>
	    <!-- //XSSOK -->
		<td class="label"><%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Type.Organization", locale)%></td>
	    <td class="inputField">
		     <select name="companyName">
		     <option Value="*">*</option>
<%
     while(companyItr.hasNext())
     {
       Map companyMap = (Map)companyItr.next();
       String companyNameStr = (String)companyMap.get(com.matrixone.apps.common.Company.SELECT_NAME);
       String companyId = (String)companyMap.get(com.matrixone.apps.common.Company.SELECT_ID);
%>
      <option value="<%=XSSUtil.encodeForHTMLAttribute(context, companyId)%>" ><%=XSSUtil.encodeForHTML(context, companyNameStr)%> </option>
<%
     }
%>
	    </select>
    </td>
 </tr>
</table>
<%
	}
	else if ("Role".equals(strSearchType)) {
	    %>
	    <table border="0" cellpadding="5" cellspacing="2" width="100%">
	    <tr>
	      <td class="label">
	        <!-- //XSSOK -->
			<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.SearchRole.Type", locale)%>
	        
	      </td>
	      <td class="inputField"><img src="../common/images/iconSmallRole.gif" alt="" name="role" id="role" border="0"/>
	        <!-- //XSSOK -->
			&nbsp;<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.SearchRole.Role", locale)%>
	      </td>
	    </tr>
	    <tr>
	      <td class="label">
	        <!-- //XSSOK -->
			<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.Name", locale)%>
	      </td>
	      <td class="inputField">
	        <input type="text" name="txtName" id="txtName" value="*"/>
	      </td>
	    </tr>
	    <tr>
	      <td class="label">
	        <!-- //XSSOK -->
			<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.SearchRole.Level", locale)%>
	      </td>
	      <td class="inputField">
	        <table>
	          <tr><td>
	            <!-- //XSSOK -->
				<input type="checkbox" name="chkTopLevel" id="chkTopLevel" value="Checked"/><%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.SearchRole.TopLevel", locale)%>
	          </td></tr>
	          <tr><td>
	            <!-- //XSSOK -->
				<input type="checkbox" name="chkSubLevel" id="chkSubLevel" value="Checked" /><%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.SearchRole.SubLevel", locale)%>
	          </td></tr>
	        </table>
	      </td>
	    </tr>
	  </table>
	<%}
	else if ("Group".equals(strSearchType)) {%>
	    	    
	    <table border="0" cellpadding="5" cellspacing="2" width="100%">
	    <tr>
	      <td class="label">
	      <!-- //XSSOK -->
		  <%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.SearchGroup.Type", locale)%>
	      </td>
	      <td class="inputField"><img src="../common/images/iconSmallGroup.gif" alt="" name="group" border="0"/>
	        <!-- //XSSOK -->
			&nbsp;<%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.SearchGroup.Group", locale)%>
	      </td>
	    </tr>
	    <tr>
	      <td class="label">
	      <!-- //XSSOK -->
		  <%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.Name", locale)%>
	      </td>
	      <td class="inputField">
	        <input type="text" name="txtName" id="txtName" value="*"/>
	      </td>
	    </tr>
	    <tr>
	      <td class="label">
	       <!-- //XSSOK -->
		   <%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.SearchGroup.Level", locale)%>
	      </td>
	      <td class="inputField">
	        <table>
	          <tr><td>
	            <!-- //XSSOK -->
				<input type="checkbox" name="chkTopLevel" id="chkTopLevel" value="" /><%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.SearchGroup.TopLevel", locale)%>
	          </td></tr>
	          <tr><td>
	            <!-- //XSSOK -->
				<input type="checkbox" name="chkSubLevel" id="chkSubLevel" value="" /><%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.SearchGroup.SubLevel", locale)%>
	          </td></tr>
	        </table>
	      </td>
	    </tr>
	  </table>
	  
	<%}
	else {
	    throw new Exception("Invalid search type '" + strSearchType + "'");
	}
%>	
</form>


<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
