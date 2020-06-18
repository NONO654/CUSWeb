<%--  emxIssueCloseDialog.jsp

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxIssueCloseDialog.jsp.rca 1.14 Tue Oct 28 19:01:08 2008 przemek Experimental przemek $";

--%>
 <%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

 <%-- Common Includes --%>
 <%@include file = "emxComponentsCommonInclude.inc"%>
 <%@include file = "../emxUICommonAppInclude.inc"%>
 <%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
 <%@include file = "emxValidationInclude.inc" %>
 <%@include file = "emxIssueGlobalSettingInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
  <%@include file = "../emxUICommonHeaderEndInclude.inc"%>

 <%@page import="com.matrixone.apps.domain.DomainConstants"%>
 <%@page import  = "com.matrixone.apps.common.Issue"%>
 <%

     String strContext       = "";
     String strTreeId        = "";
     String strSuiteKey      = "";
     String strObjectId         = "";
     //Added for Bug 350849 Starts
//   For formating the dates
     String strTimeZone = "";
    strTimeZone =(String)session.getValue ("timeZone");
    Locale Local = request.getLocale();
        String strCountry = "";
       strCountry = Local.getCountry();
       //Added for Bug 350849 Ends
     try
     {
         //Retrieves Objectid in context
         strObjectId                = emxGetParameter(request, "objectId");
         //getting tree id from common FS
         strTreeId               = emxGetParameter(request, "jsTreeID");
         //getting suite key from common FS
         strSuiteKey             = emxGetParameter(request, "suiteKey");

         //getting the context User
         //String strContextUser   = context.getUser();
   Map mpObjects = (Map) Issue.getCloseIssueInfo(context,strObjectId);
   String strName = "";
   String strActionTaken = "";
   String strResolutionStatement = "";

   String strResolutionDate =  "";
   String strAttribActionTaken = PropertyUtil.getSchemaProperty(context, Issue.SYMBOLIC_attribute_ActionTaken);
   String strAttribReslStatement = PropertyUtil.getSchemaProperty(context, Issue.SYMBOLIC_attribute_ResolutionStatement);

/* Start Adding for New Attributes in Raise Issue feature */
   String strAttribReslDate = PropertyUtil.getSchemaProperty(context, Issue.SYMBOLIC_attribute_ResolutionDate);

/* End Adding for New Attributes in Raise Issue feature */


   if(mpObjects!=null && mpObjects.size()!=0) {
    strName = (String) mpObjects.get(DomainConstants.SELECT_NAME);
    strActionTaken = (String) mpObjects.get(strAttribActionTaken);
    strResolutionStatement = (String) mpObjects.get(strAttribReslStatement);
// Added for Adding Resolution Date Column 
    strResolutionDate=(String) mpObjects.get(strAttribReslDate);
   }
 
    if(strResolutionDate == null || "null".equals(strResolutionDate))
    {
        strResolutionDate = "";
    }
// End Added for Adding Resolution Date Column 
 %>

<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js">
</script>

  <script language="javascript" src="../common/scripts/emxUIModal.js"></script>

 <form name = "IssueClose" method = "post" onsubmit="submitForm(); return false">
<!-- Added for Bug 355162 Starts-->
 <input type="hidden" name="TimeZone" value="<%=strTimeZone%>" />
   <input type="hidden" name="RequestLocale" value="<%=Local%>" />
      <input type="hidden" name="Country" value="<%=strCountry%>" />
  <!-- Added for Bug 355162 Ends-->
   <table border="0" cellpadding="5" cellspacing="2" width="100%">
   <%-- Display the input fields. --%>

   <tr>
     <td width="150" class="label" width="200" align="left">
         <framework:i18n localize="i18nId">
         <%="emxComponents.Common.Name"%>
       </framework:i18n>
     </td>
     <td class="field">
         <%=strName%>
     </td>
   </tr>

   <tr>
     <td width="150" class="labelRequired">
	  <%// Begin of modify by Infosys, for bug#300453 dated 03/24/2005 %>
      <framework:i18n localize="i18nId">
      <%="emxComponents.Attribute.ActionTaken"%>
      </framework:i18n>
	  <%// End of modify by Infosys, for bug#300453 dated 03/24/2005 %>
     </td>
     <td class="field">
       <textarea name="txtIssueActionTaken" rows="5" cols="25"><%=strActionTaken%></textarea>
     </td>
   </tr>

   <tr>
     <td width="150" class="labelRequired">
	  <%// Begin of modify by Infosys, for bug#300453 dated 03/24/2005 %>
      <framework:i18n localize="i18nId">
      <%="emxComponents.Attribute.ResolutionStatement"%>
      </framework:i18n>
	  <%// End of modify by Infosys, for bug#300453 dated 03/24/2005 %>
     </td>
     <td class="field">
       <textarea name="txtIssueResolutionStatement" rows="5" cols="25"><%=strResolutionStatement%></textarea>
     </td>
   </tr>
<!-- Added code for adding new Field ResolutionDate in Form --> 
   <tr>
    <td width="150" nowrap="nowrap" class="labelRequired">
         <framework:i18n localize="i18nId">
         <%="emxComponents.Attribute.ResolutionDate"%>
       </framework:i18n>
    </td>
        <td class="field">
          <input type="text" name="txtIssueResolutionDate" size="20"  readonly="readonly" value="<%=strResolutionDate%>" />
              <a href="javascript:showCalendar('IssueClose','txtIssueResolutionDate', '')">
                <img src="../common/images/iconSmallCalendar.gif" border="0" valign="bottom" /></a>
           <input type="hidden" name="txtIssueResolutionDate_msvalue" value="" />
         </td>
      </tr>
<!-- Added code for adding new Field ResolutionDate --> 
      <tr>
   <tr>
     <td width="150"><img src="../common/images/utilSpacer.gif" width="150" height="1" alt=""/></td>
     <td width="90%">&nbsp;</td>
   </tr>

   </table>
 </form>

 <%
     }catch(Exception ex)
     {
         session.putValue("error.message", ex.getMessage());
     }
 %>


 <script language="javascript" type="text/javaScript">
 //<![CDATA[
 var  formname = document.IssueClose;

 //validates dialog form for required field

 function validateForm()
 {
  var iValidForm = true;
     //var msg = "<%=DomainConstants.EMPTY_STRING%>";

   //Validation for Required field Action Taken for bad characters .as well as required field
     if (iValidForm)
       {
         var fieldName = "<%=i18nNow.getI18nString("emxComponents.Attribute.ActionTaken", bundle,acceptLanguage)%> ";
         var field = formname.txtIssueActionTaken;
         iValidForm = basicValidation(formname,field,fieldName,true,false,false,false,false,false,checkBadChars)
       }

   //Validation for Required field Resolution Statement for bad characters .as well as required field
     if (iValidForm)
       {
         var fieldName = "<%=i18nNow.getI18nString("emxComponents.Attribute.ResolutionStatement", bundle,acceptLanguage)%> ";
         var field = formname.txtIssueResolutionStatement;
         iValidForm = basicValidation(formname,field,fieldName,true,false,false,false,false,false,checkBadChars)
       }
   //Validation for Required field Resolution Date for required field
     if (iValidForm)
       {
         var fieldName = "<%=i18nNow.getI18nString("emxComponents.Form.Label.ResolutionDate", bundle,acceptLanguage)%> ";
         var field = formname.txtIssueResolutionDate;

         iValidForm = basicValidation(formname,field,fieldName,true,false,false,false,false,false)
        if (iValidForm)
        {
             iValidForm = validateDate();
        }
       }

     if (!iValidForm)
     {
         return ;
     }
     if (jsDblClick()) {
        formname.submit();
     }

 }


 //when Cancel button is pressed in Dialog Page
 function closeWindow()
 {
     window.closeWindow();
 }

 //When Enter Key Pressed on the form
 function submitForm()
 {
 submit();
 }
// Check if the Date is Previous date or current Date.
function validateDate()
{
    var fieldName = "<%=i18nNow.getI18nString("emxComponents.Form.Label.ResolutionDate", bundle,acceptLanguage)%> ";
    var msg = "<%=i18nNow.getI18nString("emxComponents.Alert.checkDate",bundle,acceptLanguage)%>";

	var field = formname.txtIssueResolutionDate_msvalue;
    var fieldDate = new Date(parseInt(field.value));
    var sFieldDate = fieldDate.getDate();
    var sFieldMonth = fieldDate.getMonth();
    var sFieldYear = fieldDate.getFullYear();
    var resDate = new Date(sFieldYear, sFieldMonth, sFieldDate);
    
    var tempDay = new Date();
    var sTempDate = tempDay.getDate();
    var sTempMonth = tempDay.getMonth();
    var sTempYear = tempDay.getFullYear();
    var today = new Date(sTempYear, sTempMonth, sTempDate);

	if(resDate > today) {
        alert(msg);
        return false;
    }
    else {
        return true;
    }
 }

 //when Done button is pressed in Close Dialog Page
 function submit()
 {
     strURL = "../components/emxIssueUtil.jsp?mode=Close";
     strURL = strURL + "&jsTreeID=<%=XSSUtil.encodeForURL(context,strTreeId)%>&suiteKey=<%=XSSUtil.encodeForURL(context,strSuiteKey)%>";
     strURL = strURL + "&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>";
     formname.action = strURL;
     validateForm();
 }
 //]]>
 </script>
 <!-- to handle the error.messages-->
 <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

 <!--to include the Html body closing tag -->
 <%@include file = "../emxUICommonEndOfPageInclude.inc"%>

