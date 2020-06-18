<%-- emxComponentsPersonSearch.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsPersonSearch.jsp.rca 1.12 Wed Oct 22 16:18:53 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<%
String languageStr = request.getHeader("Accept-Language");
//Added for Organization Feature
String companyId   = emxGetParameter(request,"objectId");
String selection= emxGetParameter(request,"selection");
String showCompanyAsLabel = emxGetParameter(request,"showCompanyAsLabel");
String defaultCompany = emxGetParameter(request,"defaultCompany");
//Added for Bug Id : 358563
CharSequence chrAttheRate="@";
if(defaultCompany!=null && defaultCompany.contains(chrAttheRate))
{
    defaultCompany=defaultCompany.replaceAll("@","&");
}
String formName   = emxGetParameter(request,"formName");
String fieldNameDisplay  = emxGetParameter(request,"fieldNameDisplay");
String fieldNameActual  = emxGetParameter(request,"fieldNameActual");
String fromChooser  = emxGetParameter(request,"fromChooser");
String submitURL  = emxGetParameter(request,"submitURL");

String fromSubscriptions = emxGetParameter(request,"fromSubscriptions");

if(selection == null || "null".equalsIgnoreCase(selection) || "".equalsIgnoreCase(selection))
{
      selection="multiple";
}
//end

String BAD_CHAR_SET = EnoviaResourceBundle.getProperty(context, "emxNavigator.UIMenuBar.FullSearchBadCharList");
String BADCHAR_ALERT_MSG = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",context.getLocale(), "emxFramework.AdminProperty.BadChars"); 

%>



<script language="JavaScript" type="text/javascript">
    function doSearch()
    {
    	var caseSensitiveSearch = "";
    	if(getTopWindow().getWindowOpener().document.getElementById("caseSensitiveSearch")){
        caseSensitiveSearch = getTopWindow().getWindowOpener().document.getElementById("caseSensitiveSearch").value;
       }
        if(jsIsClicked()) {
            alert("<emxUtil:i18nScript  localize="i18nId">emxComponents.Search.RequestProcessMessage</emxUtil:i18nScript>");
            return;
        }

        //get the form
        var theForm = document.forms[0];

        //set case sensitive value
        theForm.caseSensitiveSearch.value = caseSensitiveSearch;

        //set form target
        theForm.target = "searchView";

        // If the page need to do some pre-processing before displaying the results
        // Use the "searchHidden" frame for target
        // theForm.target = "searchHidden";

        //validate()??
        if(validateForm(document.forms[0]))
        {
            theForm.action = "../common/emxTable.jsp";
            if(jsDblClick())
            {
<%
              //Added for Organization Feature:call this function only when we use chooser button to call FS page(emxComponentsPersonSearchFS.jsp)
              if(fromChooser != null && !"null".equalsIgnoreCase(fromChooser) && "true".equalsIgnoreCase(fromChooser))
              {
%>                theForm.target ="_parent";
<%         }
              //end
%>
              theForm.submit();
            }
        }
    }

    function trim (textBox)
    {
        while (textBox.charAt(textBox.length-1) == ' ' || textBox.charAt(textBox.length-1) == "\r" || textBox.charAt(textBox.length-1) == "\n" )
          textBox = textBox.substring(0,textBox.length - 1);
        while (textBox.charAt(0) == ' ' || textBox.charAt(0) == "\r" || textBox.charAt(0) == "\n")
          textBox = textBox.substring(1,textBox.length);
          return textBox;
    }

    var BADCHAR_ALERT_MSG = "<%=BADCHAR_ALERT_MSG%>";
    var BAD_CHAR_LIST = '<%=BAD_CHAR_SET %>';
    var BAD_CHAR_ARRAY = BAD_CHAR_LIST.split(" ");
    function validateSearchBarChar(iValue){
        var iLeng = iValue.length;
        for (index = 0; index < iLeng; index++){
            var charVar = iValue.charAt(index);
            for(var k=0; k < BAD_CHAR_ARRAY.length; k++){
                if(charVar == BAD_CHAR_ARRAY[k]){
                    return false;
                }
            }
        }
        return true;
    } 
       
    function validateForm(form)
    {
        var varLastName  = trim(form.lastName.value);
        var varFirstName = trim(form.firstName.value);
        var varUserName  = trim(form.userName.value);

        if(varUserName=="") {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.PersonDialog.UserNameRequired</emxUtil:i18nScript>");
          form.userName.focus();
	        stopProgressClock();
	        return false;
        } else if(!validateSearchBarChar(varUserName)){
        	alert(BADCHAR_ALERT_MSG+BAD_CHAR_LIST);
        	form.userName.focus();
        	stopProgressClock();
          return false;
        } else if(varLastName=="") {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CreatePeopleDialog.LastNameRequired</emxUtil:i18nScript>");
          form.lastName.focus();
            stopProgressClock();
            return false;
        } else if(!validateSearchBarChar(varLastName)){
            alert(BADCHAR_ALERT_MSG+BAD_CHAR_LIST);
            form.lastName.focus();
            stopProgressClock();
          return false;
        } else if(varFirstName=="") {
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.CreatePeopleDialog.FirstNameRequired</emxUtil:i18nScript>");
          form.firstName.focus();
            stopProgressClock();
            return false;
        } else if(!validateSearchBarChar(varFirstName)){
            alert(BADCHAR_ALERT_MSG+BAD_CHAR_LIST);
            form.firstName.focus();
            stopProgressClock();
          return false;
        } else {
          form.lastName.value =  varLastName;
          form.firstName.value = varFirstName;
          form.userName.value = varUserName;
          return true;
        }
    }

    function doSubmit(){
         parent.doFind();
    }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

    <form method="post" name="SearchForm" onSubmit="doSubmit(); return false;">
          <table border="0" cellpadding="5" cellspacing="2" width="100%">
        <tr>
          <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Type</emxUtil:i18n></td>
          <td class="inputField"><img src="../common/images/iconPerson16.png" border="0"name="imgPerson" id="imgPerson" alt="<emxUtil:i18n localize='i18nId'>emxComponents.Common.Person</emxUtil:i18n>" /><emxUtil:i18n localize="i18nId">emxComponents.Common.Person</emxUtil:i18n></td>
        </tr>
        <tr>
          <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.UserName</emxUtil:i18n></td>
          <td class="inputField"><input type="Text" name="userName" value="*" size="20" /></td>
        </tr>
        <tr>
          <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.LastName</emxUtil:i18n></td>
          <td class="inputField"><input type="Text" name="lastName" value="*" size="20" /></td>
        </tr>
        <tr>
          <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.FirstName</emxUtil:i18n></td>
          <td class="inputField"><input type="Text" name="firstName" value="*" size="20" /></td>
        </tr>
        <tr>
          <td nowrap  width="150" class="label"><emxUtil:i18n localize="i18nId">emxComponents.Common.Organization</emxUtil:i18n></td>
          <td nowrap width="380" class="inputField">
<%
          //Added for Organization Feature V11
          if(showCompanyAsLabel != null && !"null".equalsIgnoreCase(showCompanyAsLabel) && "true".equalsIgnoreCase(showCompanyAsLabel))
          {
%>
             <%=XSSUtil.encodeForHTML(context, defaultCompany) %>&nbsp;
             <!-- //XSSOK -->
             <input type="hidden" name="orgId" value="<%=XSSUtil.encodeForHTMLAttribute(context,companyId)%>" />
<%
          }
          else if(fromSubscriptions != null && "true".equalsIgnoreCase(fromSubscriptions))
          {
%>
        	  <input type="Text" name="orgId" value="*" size="20" />
<%
          }
          else
          {
          //end for Organization Feature V11
             String relCollaborationPartners = PropertyUtil.getSchemaProperty(context, "relationship_CollaborationPartner");
             String relBusinessUnitEmployee  = PropertyUtil.getSchemaProperty(context, "relationship_BusinessUnitEmployee");

             Person person  = (Person) com.matrixone.apps.common.Person.getPerson(context);
             Company myOrganization = (Company) person.getCompany(context);

             String myOrganizationId   = myOrganization.getInfo(context,DomainObject.SELECT_ID);
             String myOrganizationName = myOrganization.getInfo(context,DomainObject.SELECT_NAME);

             String str = "relationship["+relBusinessUnitEmployee+"].from.id";
             String strBusUnitId = person.getInfo(context,str);

             BusinessUnit myBusinessUnit = null;
             if(strBusUnitId != null && !"".equals(strBusUnitId))
             {
                myBusinessUnit = new BusinessUnit(strBusUnitId);
             }

             // to store all the org name and id, key is orgname
             HashMap orgMap = new HashMap();

             //sorting of company names to be done by this vector
             Vector orgVect = new Vector();
             Vector orgDetails = null;

             String orgName = "";
             String orgId   = "";

             boolean isHostRep = Company.isHostRep(context,Person.getPerson(context));

             if(isHostRep)
             {
                StringList strList = new StringList(2);
                strList.addElement(DomainObject.SELECT_ID);
                strList.addElement(DomainObject.SELECT_NAME);

                MapList allCompMapList = Company.getCompanies(context,DomainObject.QUERY_WILDCARD,strList,null);
                int mapListSize = 0;
                if(allCompMapList != null && (mapListSize = allCompMapList.size()) > 0)
                {
                    Map compMap = null;
                    for(int i = 0 ; i < mapListSize; i++ )
                    {
                        compMap = (Map)allCompMapList.get(i);
                        orgName = (String)compMap.get(DomainObject.SELECT_NAME);
                        orgDetails = new Vector(2);
                        orgDetails.add(orgName);
                        orgDetails.add(compMap.get(DomainObject.SELECT_ID));
                        orgMap.put(orgName,orgDetails);
                        orgVect.add(orgName);
                    }
                }
             }
             else
             {
                 orgDetails = new Vector(2);
                 orgDetails.add(myOrganizationName);
                 orgDetails.add(myOrganizationId);

                 orgMap.put(myOrganizationName,orgDetails);

                 orgVect.add(myOrganizationName);

                 // add the list of companies collaborating with your Parent Comapny
                 StringList strListOfCollaborationPartnersId   = myOrganization.getInfoList(context,"from["+relCollaborationPartners+"].to.id");
                 StringList strListOfCollaborationPartnersName = myOrganization.getInfoList(context,"from["+relCollaborationPartners+"].to.name");

                 int size = 0;

                 if(strListOfCollaborationPartnersId != null && (size = strListOfCollaborationPartnersId.size()) > 0)
                 {
                    for(int i = 0 ; i < size ; i++)
                    {
                        orgId = strListOfCollaborationPartnersId.get(i).toString();
                        orgName = strListOfCollaborationPartnersName.get(i).toString();
                        orgDetails = new Vector(2);
                        orgDetails.add(orgName);
                        orgDetails.add(orgId);
                        orgMap.put(orgName,orgDetails);
                        orgVect.add(orgName);
                    }
                }

                // add the list of companies collaborating with BusinessUnit if you are a BU employee
                if ( myBusinessUnit != null )
                {
                    strListOfCollaborationPartnersId   = myBusinessUnit.getInfoList(context,"from["+relCollaborationPartners+"].to.id");
                    strListOfCollaborationPartnersName = myBusinessUnit.getInfoList(context,"from["+relCollaborationPartners+"].to.name");
                    if(strListOfCollaborationPartnersId != null && (size = strListOfCollaborationPartnersId.size()) > 0)
                    {
                        for(int i = 0 ; i < size ; i++)
                        {
                            orgId = strListOfCollaborationPartnersId.get(i).toString();
                            orgName = strListOfCollaborationPartnersName.get(i).toString();
                            orgDetails = new Vector(2);
                            orgDetails.add(orgName);
                            orgDetails.add(orgId);
                            orgMap.put(orgName,orgDetails);
                            orgVect.add(orgName);
                        }
                   }
                }
             }

             //sort Vector
             java.util.Collections.sort(orgVect);

             int vecSize = orgVect.size();

             String orgKey = "";

             //sorting of company names ends.
             if(vecSize>1)
             {
%>
               <select name="orgId" size="1">
<%
               for (int i=0 ; i < orgVect.size() ; i++)
               {
                   orgKey       = (String)orgVect.elementAt(i);
                   orgDetails   = (Vector)orgMap.get(orgKey);
                   orgName      = (String)orgDetails.elementAt(0);
                   orgId        = (String)orgDetails.elementAt(1);
                   if ( orgId.equals( myOrganizationId ) )
                   {
%>
                       <option value="<%=XSSUtil.encodeForHTMLAttribute(context, orgId)%>" selected><%=XSSUtil.encodeForHTML(context, orgName)%></option>
<%
                   } else {
%>
                       <option value="<%=XSSUtil.encodeForHTMLAttribute(context, orgId)%>" ><%=XSSUtil.encodeForHTML(context, orgName)%></option>
<%
                   }
               }
%>
               </select>
<%
             }
             else
             {
%>
              <xss:encodeForHTML><%=myOrganizationName %></xss:encodeForHTML>&nbsp;
                <input type="hidden" name="orgId" value="<xss:encodeForHTMLAttribute><%=myOrganizationId%></xss:encodeForHTMLAttribute>" />
<%
            }
          //Start for Organization Feature V11
          } // end of else
          //end for Organization Feature V11
%>
          </td>
        </tr>
      </table>

    <input type="hidden" name="caseSensitiveSearch" value="" />
    <input type="hidden" name="Style" value="dialog" />
    <input type="hidden" name="header" value="emxComponents.FindLike.Common.Results" />
    <input type="hidden" name="selection" value="<xss:encodeForHTMLAttribute><%=selection%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="QueryLimit" value="" />
    <input type="hidden" name="pagination" value="" />
    <input type="hidden" name="listMode" value="search" />
    <input type="hidden" name="CancelButton" value="true" />
    <input type="hidden" name="CancelLabel" value="emxComponents.Button.Close" />
    <input type="hidden" name="HelpMarker" value="emxhelppeopleresults" />
    <input type="hidden" name="languageStr" value="<xss:encodeForHTMLAttribute><%=languageStr%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="sortColumnName" value="Name" />
    <input type="hidden" name="sortDirection" value="ascending" />
    <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"suiteKey")%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="StringResourceFileId" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"StringResourceFileId")%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="SuiteDirectory" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"SuiteDirectory")%></xss:encodeForHTMLAttribute>" />
   <!-- Added for Organization Feature V11-->
<%
      if(fromChooser != null && !"null".equalsIgnoreCase(fromChooser) && "true".equalsIgnoreCase(fromChooser))
      {
%>
    	<input type="hidden" name="table" value="APPPersonSearchResults" />
    	<input type="hidden" name="program" value="emxPerson:getPersonSearchResult" />
        <input type="hidden" name="formName" value="<xss:encodeForHTMLAttribute><%= formName%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="fieldNameDisplay" value="<xss:encodeForHTMLAttribute><%= fieldNameDisplay%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="fieldNameActual" value="<xss:encodeForHTMLAttribute><%= fieldNameActual%></xss:encodeForHTMLAttribute>" />
        <!-- XSSOK -->
        <input type="hidden" name="SubmitURL" value="<%=XSSUtil.encodeForHTMLAttribute(context,submitURL)%>" />
        <input type="hidden" name="SubmitButton" value="true" />
<%
	  }
	  else if(fromSubscriptions != null && "true".equalsIgnoreCase(fromSubscriptions))
	  {
		  String timeStamp   = emxGetParameter(request,"timeStamp");
		  String objectId   =  emxGetParameter(request,"objectId");
		  String eventName   = "";
		  if(timeStamp != null && !"".equals(timeStamp))
		  {
			  HashMap requestMap = null;
			  if(UINavigatorUtil.isMobile(context)){
			  	  requestMap = indentedTableBean.getRequestMap(timeStamp);
			  }else{
				  requestMap = tableBean.getRequestMap(timeStamp); 
			  }
			  objectId   = (String)requestMap.get("objectId");
			  eventName   = (String)requestMap.get("eventName");
		  }
		  submitURL = "../components/emxPushSubscriptionProcess.jsp";
%>
    	<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
    	<input type="hidden" name="eventName" value="<xss:encodeForHTMLAttribute><%=eventName%></xss:encodeForHTMLAttribute>" />
    	<input type="hidden" name="table" value="APPSubscriptionPersonSearchResults" />
    	<!-- Fix for 370784 for push subscriptions invoke getPushSubscriptionPersonSearchResult-->
    	<input type="hidden" name="program" value="emxSubscriptionUtil:getPushSubscriptionPersonSearchResult" />
        <!-- XSSOK -->
        <input type="hidden" name="SubmitURL" value="<%= submitURL%>" />
        <input type="hidden" name="SubmitButton" value="true" />
<%

	  }
      else
      {
%>
    	<input type="hidden" name="table" value="APPPersonSearchResults" />
    	<input type="hidden" name="program" value="emxPerson:getPersonSearchResult" />
		<input type="hidden" name="toolbar" value="APPResultPersonToolbar" />
<%
 	  }
%>
  <!-- end-->
</form>

<script language="JavaScript" type="text/javascript">
function stopProgressClock() {
	var frame = findFrame(parent.parent, "searchView");
	frame.document.getElementById("imgProgressDiv").style.visibility = "hidden";
}
</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
