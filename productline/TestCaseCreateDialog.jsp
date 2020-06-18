
<%--
  TestCaseCreateDialog.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /ENOProductLine/CNext/webroot/productline/TestCaseCreateDialog.jsp 1.4.2.1.1.1 Wed Oct 29 22:17:06 2008 GMT przemek Experimental$";

 --%>
<%-- Top error page in emxNavigator --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%--Common Include File --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "GlobalSettingInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@page import= "com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import= "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import  = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import = "com.matrixone.apps.domain.util.i18nNow"%>


<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%><script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
<script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script> 
<%
  boolean bExceptionVal = false;

  String timeZone = (String)session.getValue ("timeZone");
  Locale Local = request.getLocale();
  String Country = Local.getCountry();
   //Retrieves Objectid in context
  String objectId         = emxGetParameter(request, "objectId");
  String treeId           = emxGetParameter(request, "jsTreeID");
  String objId            = emxGetParameter(request, "objId");
  String strUiType        = emxGetParameter(request, "uiType");
  String strTestCaseType  = ProductLineConstants.TYPE_TEST_CASE;
  String openerFrame      = emxGetParameter(request,"openerFrame");
  String strEnforceEstimatedCompletionDate= EnoviaResourceBundle.getProperty(context,"emxProduct.TestCase.EnforceEstimatedCompletionDate");
  boolean isSlideIn = "slidein".equalsIgnoreCase(emxGetParameter(request,"targetLocation"));
  String openNewTR = isSlideIn ? "</TR><TR>" : "";
  try
  {
%>
    <%@include file = "../emxUICommonHeaderEndInclude.inc"%>
    </table>
    <form name="TestCaseCreate" method="post" onsubmit="submitForm(); return false">
    <%@include file="../common/enoviaCSRFTokenInjection.inc" %>    
    <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>">
    <input type="hidden" name="TimeZone" value="<xss:encodeForHTMLAttribute><%=timeZone%></xss:encodeForHTMLAttribute>">
    <input type="hidden" name="RequestLocale" value="<xss:encodeForHTMLAttribute><%=Local%></xss:encodeForHTMLAttribute>">
    <input type="hidden" name="Country" value="<xss:encodeForHTMLAttribute><%=Country%></xss:encodeForHTMLAttribute>">
    <input type="hidden" name="uiType" value="<xss:encodeForHTMLAttribute><%=strUiType%></xss:encodeForHTMLAttribute>">
    <input type="hidden" name="strAutoNamer" value="<xss:encodeForHTMLAttribute><%=strAutoNamer%></xss:encodeForHTMLAttribute>">
     <table border="0" cellpadding="5" cellspacing="2" width="100%">
    <%-- Display the input fields. --%>
<%
    MapList policyList = com.matrixone.apps.domain.util.mxType.getPolicies(context,strTestCaseType,false);
    String strDefaultPolicy = (String)((HashMap)policyList.get(0)).get(DomainConstants.SELECT_NAME);
    String strLocale = context.getSession().getLanguage();
    String strPolicy = ProductLineConstants.POLICY;
    String i18nPolicy  = i18nNow.getMXI18NString(strDefaultPolicy,"",strLocale.toString(),strPolicy);

    String strDisplayBaseType = i18nNow.getTypeI18NString(strTestCaseType, strLocale);

  Map defaultPolicyMap     = null;
  Map PolicyMap            = new HashMap();
  String defaultPolicyName = null;
  StringList PolicyNames   = new StringList();
  Iterator PolicyItr       = null;
  String policyName = null;

  if ( policyList != null && !policyList.isEmpty())
  {
      PolicyItr = policyList.iterator();
      while( PolicyItr.hasNext())
      {
        PolicyMap = (Map)PolicyItr.next();
        policyName        = (String)PolicyMap.get("name");
        PolicyNames.add(policyName);

          defaultPolicyMap = PolicyMap;
      }

      if(defaultPolicyMap == null)
      {
        defaultPolicyMap = (Map) policyList.get(0);
      }

      defaultPolicyName = (String)defaultPolicyMap.get("name");

  }


      defaultPolicyName = strDefaultPolicy;

    //check for autonamer settings and display name field accordingly
    if (!strAutoNamer.equalsIgnoreCase("True") || strAutoNamer.equalsIgnoreCase(DomainConstants.EMPTY_STRING))
    {
%>
        <tr>
          <td width="150" nowrap="nowrap" class="labelRequired">
            <emxUtil:i18n localize="i18nId">
              emxFramework.Basic.Name
            </emxUtil:i18n>
          </td>
		  <%--XSSOK --%>
          <%=openNewTR %>
          <td nowrap="nowrap" class="field">
            <input type="text" name="txtTestCaseName" size="20" onFocus="valueCheck()">
            &nbsp;
<%
      if (strAutoNamer.equalsIgnoreCase(DomainConstants.EMPTY_STRING))
      {
%>
            <input type="checkbox" name="AutoName" onclick="nameDisabled()"><emxUtil:i18n localize="i18nId">emxProduct.Form.Label.Autoname</emxUtil:i18n>
<%
      }
%>
          </td>
        </tr>
<%
    }
    else
    {

%>
            <input type="hidden" name="txtTestCaseName" value="">
<%
    }
%>
        <tr>
          <td width="150" nowrap="nowrap" class="label">
            <emxUtil:i18n localize="i18nId">
              emxFramework.Basic.Type
            </emxUtil:i18n>
          </td>
		  <%--XSSOK --%>
          <%=openNewTR %>
          <td nowrap="nowrap" class="field">
            <xss:encodeForHTML><%=strDisplayBaseType%></xss:encodeForHTML>
          </td>
        </tr>
        <tr>
          <td width="150" class="labelRequired" valign="top">
            <emxUtil:i18n localize="i18nId">emxFramework.Basic.Description</emxUtil:i18n>
          </td>
		  <%--XSSOK --%>
          <%=openNewTR %>
          <td class="field">
            <textarea name="txtTestCaseDescription" rows="5" cols="25"></textarea>
          </td>
        </tr>
        <tr>
          <td width="150" nowrap="nowrap" class="label">
            <emxUtil:i18n localize="i18nId">
              emxFramework.Basic.Owner
            </emxUtil:i18n>
          </td>
		  <%--XSSOK --%>
          <%=openNewTR %>
          <td nowrap="nowrap" class="field">
            <input type="text" name="txtTestCaseOwner" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=context.getUser()%></xss:encodeForHTMLAttribute>">
            <input class="button" type="button" name="btnOwner" size="200" value="..." alt=""  onClick="javascript:showPersonSelector();">
            <input type="hidden" name="txtOwnerId" value="">
          </td>
        </tr>

        <tr>
         <td width="150" class="label" valign="top">
           <framework:i18n localize="i18nId">
             emxFramework.Basic.Notes
           </framework:i18n>
         </td>
		 <%--XSSOK --%>
          <%=openNewTR %>
          <td class="field">
            <textarea name="txtTestCaseNotes" rows="5" cols="25"></textarea>
          </td>
        </tr>

        <tr>
<%

if("true".equalsIgnoreCase(strEnforceEstimatedCompletionDate)){
	%>
          <td width="150" nowrap="nowrap" class="labelRequired">
            <emxUtil:i18n localize="i18nId">
              emxFramework.Attribute.Estimated_Completion_Date
            </emxUtil:i18n>
          </td>
	<%
}
else
{
	%>
	<%--XSSOK --%>
	<%=openNewTR %>
	 <td width="150" nowrap="nowrap" class="label">
            <emxUtil:i18n localize="i18nId">
              emxFramework.Attribute.Estimated_Completion_Date
            </emxUtil:i18n>
          </td>
	<%
}
%>
          <%--XSSOK --%>
          <%=openNewTR %>
          <td nowrap="nowrap" class="field">
            <input type="text" name="txtTestCaseEstimatedCompletionDate" size="20" readonly="readonly" >
            <!-- IR-016104V6R2011 : For Estimated Completion Date validation -->
            <input type="hidden" name="txtTestCaseEstimatedCompletionDate_msvalue" value=""> 
            <a href="javascript:showCalendar('TestCaseCreate','txtTestCaseEstimatedCompletionDate', '')">
              <img src="../common/images/iconSmallCalendar.gif" border="0" valign="bottom">
            </a>
          </td>
        </tr>

 <%
   /*
    *This logic defines if the Policy field is to be made visible to the user or not
    *These setting are based on the global settings for each module made in the
    *application property file.
    */

	 HashMap mapPolicyList = ProductLineCommon.getI18NPolicyList(context,strTestCaseType,acceptLanguage);
	 StringList policyValueList = (StringList)mapPolicyList.get(ProductLineConstants.VALUE);
   if (!bPolicyAwareness)
   {
	   StringList il18NPolicyList = (StringList)mapPolicyList.get(DomainConstants.SELECT_NAME);
	   String strPolicyName="";
	   int intListSize=policyValueList.size();
     %>

  <tr>
    <td width="150" class="label" valign="top">
	   <emxUtil:i18n localize="i18nId">
	      emxFramework.Basic.Policy
       </emxUtil:i18n>
	</td>
<% if (intListSize>1)
	 {
%>
      <%--XSSOK --%>
      <%=openNewTR %>
      <td class="inputField">
      <select name="txtTestCasePolicy"  >
<%
      for (int i=0;i<intListSize;i++)
		 {
%>
        <option value="<%=policyValueList.get(i)%>" ><xss:encodeForHTMLAttribute><%=il18NPolicyList.get(i)%></xss:encodeForHTMLAttribute>
		</option>

<%
         }
%>
   	   </select>
    </td>
  </tr>
<%
	 }
    if(intListSize==1)
	  {
%>
      <%-- XSSOK --%>
      <%=openNewTR %>
       <td class="field">
          <xss:encodeForHTML><%=il18NPolicyList.get(0)%></xss:encodeForHTML>
          <input type="hidden" name="txtTestCasePolicy" value="<xss:encodeForHTMLAttribute><%=policyValueList.get(0)%></xss:encodeForHTMLAttribute>">
       </td>
       </tr>

<%
	  }
    }else
    	 {
  %>
     <input type="hidden" name="txtTestCasePolicy" value="<xss:encodeForHTMLAttribute><%=policyValueList.get(0)%></xss:encodeForHTMLAttribute>">
 <%
	 }
%>

        <tr>
          <td width="150"><img src="../common/images/utilSpacer.gif" width="150" height="1" alt=""/>
          </td>
		  <%--XSSOK --%>
          <%=openNewTR %>
          <td width="90%">&nbsp;
          </td>
        </tr>
      </table>
	  <input type="image" value="" height="1" width="1" border="0" >
    </form>
<%
  }
  catch(Exception e)
  {
    session.putValue("error.message", e.getMessage());
    bExceptionVal = true;
  }
%>
<%@include file = "emxValidationInclude.inc" %>

<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" type="text/javaScript">
//START:LX6 QYG 28 Feb 2013  Manage refresh when Portals are used
var topWindow = getTopWindow().getWindowOpener()? getTopWindow().getWindowOpener() : getTopWindow();
var openerFrame = "<xss:encodeForJavaScript><%=openerFrame%></xss:encodeForJavaScript>";
if(findFrame(getTopWindow().getWindowOpener(),openerFrame)!=null){
	parent.openerFrame = findFrame(getTopWindow().getWindowOpener(),openerFrame);
}else{
	//from a popup window
	parent.openerFrame = findFrame(getTopWindow(),openerFrame);
}
//END:LX6 QYG 28 Feb 2013  Manage refresh when Portals are used
<% if(isSlideIn){ %>  
document.getElementsByTagName("body")[0].className = "slide-in-panel slide-in-panel-uc"; // IR-208774V6R2014
<% } %>
  var strAutoNamer = document.TestCaseCreate.strAutoNamer.value;
  var topWindow = getTopWindow().getWindowOpener()? getTopWindow().getWindowOpener() : getTopWindow();
  var openerFrame = "<xss:encodeForJavaScript><%=openerFrame%></xss:encodeForJavaScript>";
  if(findFrame(getTopWindow().getWindowOpener(),openerFrame)!=null){
	  parent.openerFrame = findFrame(getTopWindow().getWindowOpener(),openerFrame);  
  }else{
	  parent.openerFrame = findFrame(getTopWindow(),openerFrame);  
  }
  var  formName = document.TestCaseCreate;
  var autoNameValue = "<%= strAutoNamer %>";

  if((<%=strAutoNamer.equalsIgnoreCase("False")%>) || strAutoNamer == "" ) {
    document.TestCaseCreate.txtTestCaseName.focus();
  } else {
    document.TestCaseCreate.txtTestCaseDescription.focus();
}
  //<![CDATA[

  //called when user clicks on name field...if autoname is true then focus is transferred to description field
  function valueCheck()
    {
	    //XSSOK
      if (<%=strAutoNamer.equals("")%> == true)
      {
        if (formName.AutoName.checked)
        {
          //formName.txtTestCaseDescription.focus();
          document.TestCaseCreate.txtTestCaseName.blur();

        }
      }
  }

  //called wheen the check box is checked
  function nameDisabled()
  {
	  //XSSOK
    if (<%=strAutoNamer.equals("")%> == true)
    {
      if (formName.AutoName.checked)
      {
        formName.txtTestCaseName.value="";
        formName.AutoName.value="true";
        formName.txtTestCaseDescription.focus();
      }
      else
      {
          formName.txtTestCaseName.focus();
     }
   }
  }
/* Modified by <Tanmoy Chatterjee> On <10th July 2003>
   For the following Bug
   <In Case of Create  if the user has opened any of the choosers before the press of Done button  then when the operation fails then the previously entered values are getting lost>
   Fixed as Follows:
   <added the target as a hidden frame>
*/
  //When Enter Key Pressed on the form
   function submitForm()
   {
	submit();
   }
  //on clicking the done button
  function submit()
  {
    var iValidForm=true;
    var iDateValid = true;
    iValidForm =validateFormValues();
    iDateValid = validateCompletionDate();
    if (!iValidForm)
    {
        return ;
    }
    //IR-016104V6R2011 : Estimated Completion Date validation 
    if(!iDateValid)
    {
        alert("<%=i18nStringNowUtil("emxProduct.TestCase.Alert.InvalidEstimatedDate", bundle,acceptLanguage)%>");
        return;
    }
    formName.action="../productline/TestCaseUtil.jsp?Mode=Create&jsTreeId=<%=XSSUtil.encodeForURL(context,treeId)%>";
    formName.target = "jpcharfooter";
    //To display the Progress clock
    turnOnProgress();
    if (jsDblClick()) {
        formName.submit();
      }
  }


  //on clicking the apply button
  function apply()
  {
    var iValidForm=true;
    var iDateValid = true;
    iValidForm =validateFormValues();
    //IR-028915V6R2011
    iDateValid = validateCompletionDate();
    if (!iValidForm)
    {
        return ;
    }
    //IR-016104V6R2011 : Estimated Completion Date validation 
    if(!iDateValid)
    {
        alert("<%=i18nStringNowUtil("emxProduct.TestCase.Alert.InvalidEstimatedDate", bundle,acceptLanguage)%>");
        return ;
    }
    formName.action="../productline/TestCaseUtil.jsp?Mode=CreateAnother&jsTreeId=<%=XSSUtil.encodeForURL(context,treeId)%>";
    formName.target = "jpcharfooter";
    //To display the Progress clock
    turnOnProgress();

    if (jsDblClick()) {
        formName.submit();
      }

  }

  //checks the mandatory fields
  function validateFormValues()
  {

   var x1 = new Date(document.TestCaseCreate.txtTestCaseEstimatedCompletionDate.value);
   var strEstimated = <%=strEnforceEstimatedCompletionDate%>;
   <%
   String mon = emxGetParameter(request, "mon");
   String day = emxGetParameter(request, "day");
   String year = emxGetParameter(request, "year");
    %>

   //This variable is equal to true if the form is valid
    var iValidForm = true;
    //XSSOK
    if (!(<%=strAutoNamer.equalsIgnoreCase("True")%>))
    {
        //XSSOK
      if ((<%=strAutoNamer.equalsIgnoreCase("False")%>))
      {
        if (iValidForm)
        {
          var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Name", bundle,acceptLanguage)%> ";
          var field = formName.txtTestCaseName;
          iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);
        }
      }else{
        if (!formName.AutoName.checked)
        {
          if (iValidForm)
          {
            var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Name", bundle,acceptLanguage)%> ";
            var field = formName.txtTestCaseName;
            iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);
          }
        }
      }
    }

	//validation for special chars in the description field - The sixth(true) and last parameter 'checkBadChars' specifies which characters have to be blocked (all bad chars, common illegal characters are now Restricted Characters)
    if (iValidForm)
    {
      var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Description", bundle,acceptLanguage)%> ";
      var field = formName.txtTestCaseDescription;
      iValidForm = basicValidation(formName,field,fieldName,true,false,false,false,false,false,checkBadChars);
    }

	//validation for special/Bad chars in the notes field.
    if (iValidForm)
    {
      var fieldName = "<%=i18nStringNowUtil("emxFramework.Attribute.Notes", bundle,acceptLanguage)%> ";
      var field = formName.txtTestCaseNotes;
      iValidForm = basicValidation(formName,field,fieldName,false,false,false,false,false,false,checkBadChars);
    }

if(strEstimated)
{
    if (iValidForm)
    {
      var fieldName = "<%=i18nStringNowUtil("emxFramework.Attribute.Estimated_Completion_Date", bundle,acceptLanguage)%> ";
      var field = formName.txtTestCaseEstimatedCompletionDate;
      iValidForm = basicValidation(formName,field,fieldName,true,false,false,false,false,false,false);
     }
}

    if (!iValidForm)
    {
      return;
    }
    return(iValidForm);
  }

  function closeWindow()
  {
	  getTopWindow().closeSlideInDialog();
  }

  function showPersonSelector()
  {
    //This function is for popping the Person chooser.
 
    var objCommonAutonomySearch = new emxCommonAutonomySearch();

	   objCommonAutonomySearch.txtType = "type_Person";
	   objCommonAutonomySearch.selection = "single";
	   objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitAutonomySearchOwner"; 
	   objCommonAutonomySearch.open();
    }
    function submitAutonomySearchOwner(arrSelectedObjects) 
	{
   
		var objForm = document.forms["TestCaseCreate"];

		var hiddenElement = objForm.elements["txtOwnerId"];
		var displayElement = objForm.elements["txtTestCaseOwner"];

		for (var i = 0; i < arrSelectedObjects.length; i++) 
		{ 
			var objSelection = arrSelectedObjects[i];
			hiddenElement.value = objSelection.name;
			displayElement.value = objSelection.name;
			break;
 
      }

  }

  var txtVault = null;
  var bVaultMultiSelect = false;
  var strTxtVault = formName.txtTestCaseVault;

  function showVaultSelector()
  {
    //This function is for popping the Vault chooser.
    txtVault = eval(strTxtVault);
    showChooser('../common/emxVaultChooser.jsp?fieldNameActual=txtTestCaseVault&fieldNameDisplay=txtTestCaseVaultDisplay&incCollPartners=false&multiSelect=false');
  }
//IR-016104V6R2011 : Estimated Completion Date validation 
  function validateCompletionDate()
  {
       var estimatedCompletionDate_inMilis = document.TestCaseCreate.txtTestCaseEstimatedCompletionDate_msvalue.value;
       var vURL="../productline/TestCaseUtil.jsp?Mode=dateValidation&strDate="+estimatedCompletionDate_inMilis;
       var isDateValid = emxUICore.getData(vURL);
       if(isDateValid.indexOf("EstDateInvalid") > -1)    
       {
           iValidForm = false;
       }else {
           iValidForm = true;
       }
       return (iValidForm);
  }
  //]]>
</script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
//Closing the window if mode is create
if (bExceptionVal == true)
{
%>
<script language="javascript" type="text/javaScript">
//<![CDATA[

parent.window.closeWindow();

//]]>
</script>
<%
}
%>

<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
