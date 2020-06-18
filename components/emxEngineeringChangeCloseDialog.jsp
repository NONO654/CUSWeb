<%--  emxEngineeringChangeCloseDialog.jsp

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxEngineeringChangeCloseDialog.jsp.rca 1.5 Wed Oct 22 16:18:01 2008 przemek Experimental przemek $";

--%>
 <%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
 
 <%-- Common Includes --%>
 <%@include file = "emxComponentsCommonInclude.inc" %>
 <%@include file = "../emxUICommonAppInclude.inc"%>
 <%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
 
 <%@page import  = "com.matrixone.apps.domain.*"%>
 <%@page import  = "matrix.util.Pattern"%>
 <%@page import  = "com.matrixone.apps.common.RouteTemplate"%>
 <%
     String strTreeId        = "";
     String strSuiteKey      = "";
     String objectId         = "";
     String objectName       = "";
     try {
 
         //Retrieves Objectid in context
         objectId                = emxGetParameter(request, "objectId");
         //getting tree id from common FS
         strTreeId               = emxGetParameter(request, "jsTreeID");
         //getting suite key from common FS
         strSuiteKey             = emxGetParameter(request, "suiteKey");
 
         DomainObject domObj = DomainObject.newInstance(context,objectId);
         objectName = domObj.getInfo(context,DomainConstants.SELECT_NAME);
%>
 
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
 
<form name = "EngineeringChangeClose" action = "" method = "post">
    <%@include file = "../common/enoviaCSRFTokenInjection.inc" %>
    <table border="0" cellpadding="5" cellspacing="2" width="100%">
    <%-- Display the input fields. --%>

        <tr>
            <td width="150" nowrap="nowrap" class="label">
                <framework:i18n localize="i18nId">
                    emxFramework.Basic.Name
                </framework:i18n>
            </td>
            <td class="field">
                <%=XSSUtil.encodeForHTML(context, objectName)%>
            </td>
        </tr>

        <tr>
            <td width="150" class="labelRequired">
                <framework:i18n localize="i18nId"><%=XSSUtil.encodeForHTML(context, "emxFramework.Attribute.Reason_For_Closure")%></framework:i18n>
            </td>
            <td class="field">
                <textarea name="txtECReasonForClosure" rows="5" cols="25"></textarea>
            </td>
        </tr>

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
 <%@include file = "emxValidationInclude.inc" %>
 
 <script language="javascript" type="text/javaScript">
     var  formname = document.EngineeringChangeClose;

     //validates dialog form for required field
     function validateForm()
     {
         var iValidForm = true;
         //Validation for Required field Reason for closure
         if (iValidForm)
         {
             var fieldName = "<%=XSSUtil.encodeForJavaScript(context, i18nNow.getI18nString("emxFramework.Attribute.Reason_For_Closure", bundle,acceptLanguage))%> ";
             var field = formname.txtECReasonForClosure;
             iValidForm = basicValidation(formname,field,fieldName,true,false,false,false,false,false,false);
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

     //when Done button is pressed in Close Dialog Page
     function submit()
     {
         strURL = "emxEngineeringChangeUtil.jsp?mode=close";
         strURL = strURL + "&jsTreeID=<%=XSSUtil.encodeForURL(context, strTreeId)%>&suiteKey=<%=XSSUtil.encodeForURL(context, strSuiteKey)%>";
         strURL = strURL + "&objectId=<%=XSSUtil.encodeForURL(context, objectId)%>";
         formname.action = strURL;
         validateForm();
     }
 </script>
 <!--to include the Html body closing tag -->
 <%@include file = "../emxUICommonEndOfPageInclude.inc"%>
 
