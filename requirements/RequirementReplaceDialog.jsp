<%--

  RequirementReplaceDialog.jsp

  Performs the actions that replaces a Requirement under the context of Feature/Product/Requirement/Model.

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

--%>
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under
      respective scriplet
     @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
     @quickreview T25 DJH 13:10:25  :  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
     @quickreview HAT1 ZUD 17:11:30  :  IR-559737-3DEXPERIENCER2018x: R420-STP: In Requirements under Model/ Product, Replace Requirement window does not show all controls by default. 
--%>
 <%-- Common Includes --%>
  <%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
  <%@include file = "emxProductCommonInclude.inc" %>
  <%@include file = "../emxUICommonAppInclude.inc"%>
  <%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
  <%@include file = "emxValidationInclude.inc" %>
  <%@include file = "../emxTagLibInclude.inc"%>

  <%@page import="com.matrixone.apps.productline.ProductLineUtil" %>
  <%@page import="com.matrixone.apps.requirements.RequirementsCommon" %>
  <%@page import="com.matrixone.apps.common.Search" %>
  <%@page import="com.matrixone.apps.productline.ProductLineConstants" %>
  <%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
  <%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
  <%@page import="com.matrixone.apps.domain.DomainConstants" %>
  <%@page import="com.matrixone.apps.domain.DomainObject" %>
  <%@page import="com.matrixone.apps.common.util.FormBean" %>
  <%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
  <%@page import="java.util.List"%>
  <%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>

<%
   String strContextObjectId="";
   boolean bIsModel = false;
   try{
     //Getting the Object Id of the Parent
     strContextObjectId = emxGetParameter(request, "objectId");
     DomainObject domObj = DomainObject.newInstance(context,strContextObjectId);
     String strType = domObj.getInfo(context,DomainConstants.SELECT_TYPE);
     List lstModelChildTypes=ProductLineUtil.getChildrenTypes(
                    context,
                    ReqSchemaUtil.getModelType(context));
     lstModelChildTypes.add((Object)ReqSchemaUtil.getModelType(context));

     if(lstModelChildTypes.contains((Object)strType))
     {
         bIsModel = true;
     }
    //Instantiating the FormBean
     FormBean formBean = new FormBean();

     //Processing the form using FormBean.processForm
     formBean.processForm(session,request);
     String[] arrRowId = formBean.getElementValues("emxTableRowId");
     Map reqMap = ProductLineUtil.getObjectIdsRelIdsR213(arrRowId);
     String[] arrSourceObjectId = (String[])reqMap.get("ObjId");
     String[] arrRelId = (String[])reqMap.get("RelId");

     /*
     *These methods are used to display the Name and Revision of the source Requirement.
     */
    String strSourceFieldString = EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Form.Value.SourceProduct"); 
    String strSourceValue = UINavigatorUtil.getParsedHeaderWithMacros(context,acceptLanguage,strSourceFieldString,arrSourceObjectId[0]);


    DomainObject domSourceReq = DomainObject.newInstance(context,arrSourceObjectId[0]);
    BusinessObject boReplaceWithDefault = RequirementsCommon.getLastRevision(context, domSourceReq);
    String strObjectId = boReplaceWithDefault.getObjectId();
    Search searchBean = new Search();
    String strReplaceWithDefault = searchBean.getObjectNameWithRevision(context,strObjectId);

  %>

  <%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script type="text/javascript">
		// HAT1 ZUD IR-559737-3DEXPERIENCER2018x fix.
		getTopWindow().document.getElementById("rightSlideIn").style.width = "500px"; 
</script>
   <!-- Requirement Replace form -->

   <form name="ReqReplace" method="post" onsubmit="submitForm(); return false">
   <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
       <input type="hidden" name="txtRelId" value="<xss:encodeForHTMLAttribute><%=arrRelId[0]%></xss:encodeForHTMLAttribute>" />
       <input type="hidden" name="txtContextObjectId" value="<xss:encodeForHTMLAttribute><%=strContextObjectId%></xss:encodeForHTMLAttribute>" />

     <!-- IR-201162V6R2014  -->
     <table border="0" cellpadding="5" cellspacing="2" width="90%">
     <!-- END IR-201162V6R2014  -->

     <%-- Display the input fields. --%>

     <tr>
       <td width="150" nowrap="nowrap" class="label">
         <emxUtil:i18n localize="i18nId">
           emxRequirements.Form.Label.Source
         </emxUtil:i18n>
       </td>
       <td valign="top" nowrap="nowrap" class="field"><img src="../common/images/iconReqTypeRequirement.png" border="0" alt="Requirement" />&nbsp;<xss:encodeForHTML><%=strSourceValue%></xss:encodeForHTML></td>
       <input type="hidden" name="txtSourceReqId" value="<xss:encodeForHTMLAttribute><%= arrSourceObjectId[0] %></xss:encodeForHTMLAttribute>" />
     </tr>


     <tr>
       <td width="150" nowrap="nowrap" class="labelRequired">
         <emxUtil:i18n localize="i18nId">
           emxRequirements.Form.Label.ReplaceWith
         </emxUtil:i18n>
       </td>
       <td nowrap="nowrap" class="field">
         <input type="text" name="txtNewRequirementName" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%= strReplaceWithDefault %></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="txtNewRequirementId" value="<xss:encodeForHTMLAttribute><%= strObjectId %></xss:encodeForHTMLAttribute>" />
         <input class="button" type="button" name="btnType" size="200" value="..." alt=""  onClick="javascript:findRequirement();" />
       </td>
     </tr>


     <tr>
       <td width="150"><img src="../common/images/utilSpacer.gif" width="150" height="1" alt=""/></td>
       <td width="90%">&nbsp;</td>
     </tr>

     </table>
     <input type="image" value="" height="1" width="1" border="0" />
   </form>

   <%
   }catch(Exception e)
   {
     emxNavErrorObject.addMessage(e.toString().trim());
     session.putValue("error.message", e.toString().trim());
   }
    %>
      <script language="javascript" type="text/javaScript">
         <!-- hide JavaScript from non-JavaScript browsers -->
         //<![CDATA[
         var  formName = document.ReqReplace;

         // checking mandatory field validations before submiting
          // close button
         function closeWindow()
         {
        	  getTopWindow().closeSlideInDialog();
         }

         //When Enter Key Pressed on the form
        function submitForm()
        {
            submit();
        }

         // submit button
         function submit()
         {
           // Field Validations for the form before submitting
           var iValidForm = true;
           var strMsg = "";

           // check if Replacing Requirement is selected
           if(iValidForm)
           {
             var fieldName = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Form.Label.ReplaceWith")%> ";
             var field = formName.txtNewRequirementName;
             iValidForm = basicValidation(formName,field,fieldName,true,true,false,false,false,false,false);
           }
           // check if source and destination Requirement are different.
           if (iValidForm && formName.txtNewRequirementId.value==formName.txtSourceReqId.value)
           {
             iValidForm=false;
             strMsg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.ReplaceRequirementSourceDestinationSame")%> ";
             alert(strMsg);
             formName.txtNewRequirementId.value = "";
             formName.txtNewRequirementName.value = "";
             return;
           }

           if (!iValidForm)
           {
             return;
           }


           //Submit the form to RequirementUtil.jsp
           formName.action="../requirements/RequirementUtil.jsp?mode=replace";
           formName.target = "jpcharfooter";

           if (jsDblClick()) {
                formName.submit();
            }

         }

         // chooser for Requirement
         function findRequirement()
         {

           //This function is for popping the Type chooser.
           //The value chosen by the type chooser is returned to the corresponding field.
           //April 05,2006: Modified by Enovia MatrixOne for Bug# 317903
           var bModel = "<xss:encodeForJavaScript><%=bIsModel%></xss:encodeForJavaScript>";
           if(bModel == false)
           {
            showChooser('../common/emxFullSearch.jsp?formName=ReqReplace&field=TYPES=type_Requirement&table=RMTGlobalSearchRequirementsTable&selection=single&suiteKey=Requirements&cancelButton=true&cancelLabel=emxRequirements.Button.Cancel&showSavedQuery=True&searchCollectionEnabled=True&HelpMarker=emxhelpfullsearch&submitURL=../requirements/MultiObjectSelect.jsp?frameName=pageContent&fieldNameActual=txtNewRequirementId&fieldNameDisplay=txtNewRequirementName', 700, 500)
           }
           else
           {
            showChooser('../common/emxFullSearch.jsp?formName=ReqReplace&field=TYPES=type_Requirement&table=RMTGlobalSearchRequirementsTable&selection=single&suiteKey=Requirements&cancelButton=true&cancelLabel=emxRequirements.Button.Cancel&showSavedQuery=True&searchCollectionEnabled=True&HelpMarker=emxhelpfullsearch&submitURL=../requirements/MultiObjectSelect.jsp?frameName=pageContent&fieldNameActual=txtNewRequirementId&fieldNameDisplay=txtNewRequirementName', 700, 500)
           }
         }


         //]]>
      </script>
      <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
      <%@include file = "../emxUICommonEndOfPageInclude.inc"%>

