
<%--
  UseCaseCreateDialog.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /web/requirements/UseCaseCreateDialog.jsp 1.3.2.1.1.1.1.2 Fri Dec 19 19:24:27 2008 GMT ds-srickus Experimental$";

 --%>
 <%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under
       respective scriplet
      @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
      @quickreview LX6 QYG 28 Feb 2013  Manage refresh when Portals are used
      @quickreview T25 DJH 13:10:18  :  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included. 
      @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
 --%>
<%-- Top error page in emxNavigator --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%--Common Include File --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "GlobalSettingInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<%@page import= "com.matrixone.apps.domain.util.PropertyUtil"%>

<%@page import  = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>

<%
    //Retrieves Objectid in context
    String objectId = emxGetParameter(request, "objectId");
    String uiType =      emxGetParameter(request,"uiType");
    boolean isSlideIn = "slidein".equalsIgnoreCase(emxGetParameter(request,"targetLocation"));
    //START:LX6 QYG 28 Feb 2013  Manage refresh when Portals are used
    String openerFrame      = emxGetParameter(request,"openerFrame");
    //END:LX6 QYG 28 Feb 2013  Manage refresh when Portals are used
    String openNewTR = isSlideIn ? "</TR><TR>" : "";

    boolean bExceptionVal = false;
    String strType  = ReqSchemaUtil.getUseCaseType(context);
try
{
    MapList policyList = com.matrixone.apps.domain.util.mxType.getPolicies(context,strType,false);
    String strDefaultPolicy = (String)((HashMap)policyList.get(0)).get(DomainConstants.SELECT_NAME);
   	String strLocale = context.getSession().getLanguage();
    String strPolicy = ProductLineConstants.POLICY;
    String i18nPolicy  = i18nNow.getMXI18NString(strDefaultPolicy,"",strLocale.toString(),strPolicy);
%>
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

	<!-- IR-208774V6R2014 -->
	<style type="text/css">
		body.slide-in-panel-uc,
		div.slide-in-panel-uc {overflow:auto;}
	</style>
	<!-- END IR-208774V6R2014 -->
	
    <form name="useCaseCreate" method="post" onsubmit="submitForm(); return false">
    <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
    <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
	<input type="hidden" name="uiType" value="<xss:encodeForHTMLAttribute><%=uiType%></xss:encodeForHTMLAttribute>" />
    <table border="0" cellpadding="5" cellspacing="2" width="100%">
    <%-- Display the input fields. --%>
<%
//check for autonamer settings and display name field accordingly
    if (strAutoNamer.equalsIgnoreCase("False") || strAutoNamer.equalsIgnoreCase(DomainConstants.EMPTY_STRING) )
    {
%>
        <tr>
          <td width="150" nowrap="nowrap" class="createLabelRequired">
            <framework:i18n localize="i18nId">
              emxFramework.Basic.Name
            </framework:i18n>
          </td>
        <%=openNewTR %><%--XSSOK--%>
          <td  nowrap="nowrap" class="createInputField">
            <input type="text" name="txtUseCaseName" size="20" onFocus="valueCheck()" />
            &nbsp;
<%
    if (strAutoNamer.equalsIgnoreCase(DomainConstants.EMPTY_STRING))
    {
%>
            <input type="checkbox" name="AutoName" onclick="nameDisabled()" /><emxUtil:i18n localize="i18nId">emxRequirements.Form.Label.Autoname</emxUtil:i18n>
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
            <input type="hidden" name="txtUseCaseName" value="" />
<%
    }
%>
        </tr>

        <tr>
          <td width="150" class="createLabelRequired" valign="top">
            <framework:i18n localize="i18nId">emxFramework.Basic.Description</framework:i18n>
          </td>
        <%=openNewTR %><%--XSSOK--%>
          <td class="createInputField">
            <textarea name="txtUseCaseDescription" rows="5" cols="25"></textarea>
          </td>
        </tr>
        <tr>
          <td width="150" nowrap="nowrap" class="createLabel">
            <framework:i18n localize="i18nId">
              emxFramework.Basic.Owner
            </framework:i18n>
          </td>
        <%=openNewTR %><%--XSSOK--%>
          <td nowrap="nowrap" class="createInputField">
            <input type="text" name="txtUseCaseOwner" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=context.getUser()%></xss:encodeForHTMLAttribute>" />
            <input class="button" type="button" name="btnOwner" size="200" value="..." alt=""  onClick="javascript:showPersonSelector();" />
            <input type="hidden" name="txtOwnerId" value="" />
         </td>
       </tr>
       <tr>
         <td width="150" class="createLabel" valign="top">
           <framework:i18n localize="i18nId">
             emxFramework.Basic.Notes
           </framework:i18n>
         </td>
        <%=openNewTR %><%--XSSOK--%>
         <td  class="createInputField">
           <textarea name="txtUseCaseNotes" rows="5" cols="25"></textarea>
         </td>
      </tr>

      <tr>
        <td width="150" nowrap="nowrap" class="createLabelRequired">
          <framework:i18n localize="i18nId">
            emxFramework.Attribute.Estimated_Duration
          </framework:i18n>
        </td>
        <%=openNewTR %><%--XSSOK--%>
        <td  nowrap="nowrap" class="createInputField">
          <input type="text" name="txtUseCaseEstimatedDuration" size="20" />
          &nbsp;
        </td>
      </tr>

<%
    if (!bPolicyAwareness)
    {
      if( policyList.size() > 1)
      {
%>
      <tr>
        <td width="150" class="createLabel" valign="top">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Policy
          </emxUtil:i18n>
        </td>
        <%=openNewTR %><%--XSSOK--%>
        <td class="createInputField">
          <select name="txtUseCasePolicy">
            <emxUtil:optionList
              optionMapList="<xss:encodeForHTMLAttribute><%=policyList%></xss:encodeForHTMLAttribute>"
              optionKey="<xss:encodeForHTMLAttribute><%=DomainConstants.SELECT_NAME%></xss:encodeForHTMLAttribute>"
              valueKey="<xss:encodeForHTMLAttribute><%=DomainConstants.SELECT_NAME%></xss:encodeForHTMLAttribute>"
              selected = ""/>
            </emxUtil>
          </select>
        </td>
      </tr>
<%
      }else{
%>
      <tr>
        <td width="150" class="createLabel" valign="top">
          <framework:i18n localize="i18nId">
            emxFramework.Basic.Policy
          </framework:i18n>
        </td>
        <%=openNewTR %><%--XSSOK--%>
        <td  class="createInputField">
          <%=i18nPolicy%>
          <input type="hidden" name="txtUseCasePolicy" value="" />
        </td>
      </tr>
<%
      }
    }else{
%>
          <input type="hidden" name="txtUseCasePolicy" value="" />
<%
    }
%>

<%
    if (bShowVault)
    {
%>
      <tr>
        <td width="150" class="createLabel" valign="top">
          <framework:i18n localize="i18nId">
            emxFramework.Basic.Vault
          </framework:i18n>
        </td>
        <%=openNewTR %><%--XSSOK--%>
        <td  class="createInputField">
          <input type="text" name="txtUseCaseVaultDisplay" size="20" value="<xss:encodeForHTMLAttribute><%=strUserVaultDisplay%></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="txtUseCaseVault" size="15" value="<xss:encodeForHTMLAttribute><%=strUserVault%></xss:encodeForHTMLAttribute>" />
          <input class="button" type="button" name="btnVault" size="200" value="..." alt=""  onClick="javascript:showVaultSelector();" />
          <a name="ancClear" href="#ancClear" class="dialogClear" onclick="document.useCaseCreate.txtUseCaseVault.value='';document.useCaseCreate.txtUseCaseVaultDisplay.value=''"><framework:i18n localize="i18nId">emxRequirements.Button.Clear</framework:i18n></a>
        </td>
      </tr>
<%
    }else{
%>
          <input type="hidden" name="txtUseCaseVault" value="<xss:encodeForHTMLAttribute><%=strUserVault%></xss:encodeForHTMLAttribute>"/>
<%
    }
%>
      <tr>
        <td width="150"><img src="../common/images/utilSpacer.gif" width="150" height="1" alt=""/>
        </td>
        <%=openNewTR %><%--XSSOK--%>
        <td width="90%">&nbsp;
        </td>
      </tr>

    </table>
	<input type="image" value="" height="1" width="1" border="0" />
    </form>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>


<%
}
catch(Exception e)
{
  session.putValue("error.message", e.getMessage());
  bExceptionVal = true;
}
  String treeId = emxGetParameter(request, "jsTreeID");
  String objId = emxGetParameter(request, "objId");
%>

<%@include file = "emxValidationInclude.inc" %>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" type="text/javaScript">
    //START:LX6 QYG 28 Feb 2013  Manage refresh when Portals are used
     //KIE1 ZUD TSK447636 
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
  //Added:28-Apr-09:kyp:R207:RMT Bug 370643
       // A variable is used to remember the window to be refreshed
     var _tableWindowToRefresh = null;
     var _contentFrameToRefresh = null;
  //End:R207:RMT Bug 370643
  
  
  var  formName = document.useCaseCreate;
  var autoNameValue = "<xss:encodeForJavaScript><%=strAutoNamer%></xss:encodeForJavaScript>";

  //called when user clicks on name field...if autoname is true then focus is transferred to description field
  function valueCheck()
  {
    if (<xss:encodeForJavaScript><%=strAutoNamer.equals("")%></xss:encodeForJavaScript> == true)
    {
      if (formName.AutoName.checked)
      {
        formName.txtUseCaseDescription.focus();
      }
    }
  }

  //called wheen the check box is checked
  function nameDisabled()
  {
    if (<xss:encodeForJavaScript><%=strAutoNamer.equals("")%></xss:encodeForJavaScript> == true)
    {
      if (formName.AutoName.checked)
      {
        formName.txtUseCaseName.value="";
        formName.AutoName.value="true";
        formName.txtUseCaseDescription.focus();
      }
      else
      {
        formName.txtUseCaseName.focus();
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
    iValidForm =validateFormValues();
    if (!iValidForm)
    {
        return ;
    }

    formName.action="../requirements/UseCaseUtil.jsp?Mode=Create&jsTreeId=<xss:encodeForJavaScript><%=treeId%></xss:encodeForJavaScript>";
    formName.target = "jpcharfooter";
    //To display the Progress clock
    parent.turnOnProgress();
  if (jsDblClick()) {
        formName.submit();
      }
  }


  //on clicking the apply button
  function apply()
  {
    var iValidForm=true;
    iValidForm =validateFormValues();
    if (!iValidForm)
    {
        return ;
    }

    formName.action="../requirements/UseCaseUtil.jsp?Mode=CreateAnother&jsTreeId=<xss:encodeForJavaScript><%=treeId%></xss:encodeForJavaScript>";
    formName.target = "jpcharfooter";
    //To display the Progress clock
    parent.turnOnProgress();

    if (jsDblClick()) {
        formName.submit();
      }
  }

  //checks the mandatory fields
  function validateFormValues()
  {
    //This variable is equal to true if the form is valid
    var iValidForm = true;
    if (!(<xss:encodeForJavaScript><%=strAutoNamer.equalsIgnoreCase("True")%></xss:encodeForJavaScript>))
    {
      if ((<xss:encodeForJavaScript><%=strAutoNamer.equalsIgnoreCase("False")%></xss:encodeForJavaScript>))
      {
        if (iValidForm)
        {
          var fieldName = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxFramework.Basic.Name")%> ";
          var field = formName.txtUseCaseName;
          iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);
        }
      }else{
        if (!formName.AutoName.checked)
        {
          if (iValidForm)
          {
            var fieldName = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxFramework.Basic.Name")%> ";
            var field = formName.txtUseCaseName;
            iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);
          }
        }
      }
    }

    //validation for special chars in the description field - The sixth(true) and last parameter 'checkBadChars' specifies which characters have to be blocked (all bad chars, common illegal characters are now Restricted Characters)
    if (iValidForm)
    {
      var fieldName = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxFramework.Basic.Description")%> ";
      var field = formName.txtUseCaseDescription;
      iValidForm = basicValidation(formName,field,fieldName,true,false,false,false,false,false,checkBadChars);
    }

    if (iValidForm)
    {
      var fieldName = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxFramework.Attribute.Notes")%> ";
      var field = formName.txtUseCaseNotes;
      iValidForm = basicValidation(formName,field,fieldName,false,false,false,false,false,false,checkBadChars);
    }

    if (iValidForm)
    {
      var fieldName = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxFramework.Attribute.Estimated_Duration")%> ";
      var field = formName.txtUseCaseEstimatedDuration;
      iValidForm = basicValidation(formName,field,fieldName,true,false,false,true,true,false,false);
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
    //The value chosen by the type chooser is returned to the corresponding field.
    showChooser("../common/emxFullSearch.jsp?field=TYPES%3Dtype_Person&table=APPPersonSearchResults&selection=single&cancelLabel=emxFramework.Button.Cancel&hideHeader=true&submitAction=refreshCaller&submitURL=../requirements/FullSearchUtil.jsp&mode=Chooser&chooserType=PersonChooser&fieldNameActual=txtOwnerId&fieldNameDisplay=txtUseCaseOwner&HelpMarker=emxhelpfullsearch", 700, 500)
  }

  var txtVault = null;
  var bVaultMultiSelect = false;
  var strTxtVault = formName.txtUseCaseVault;

  function showVaultSelector()
  {
    //This function is for popping the Vault chooser.
    txtVault = eval(strTxtVault);
    showChooser("../common/emxVaultChooser.jsp?fieldNameActual=txtUseCaseVault&fieldNameDisplay=txtUseCaseVaultDisplay&incCollPartners=false&multiSelect=false");
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
 //KIE1 ZUD TSK447636 
parent.closeWindow();

//]]>
</script>
<%
}
%>
