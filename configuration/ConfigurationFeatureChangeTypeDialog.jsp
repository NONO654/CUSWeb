
<%--

  ConfigurationFeatureChangeTypeDialog.jsp

  Performs the actions for changing the type of a Feature.

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/ConfigurationFeatureChangeTypeDialog.jsp 1.3.2.1.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";

--%>

 <%-- Common Includes --%>
 <%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
 <%@include file = "emxProductCommonInclude.inc" %>
 <%@include file = "../emxUICommonAppInclude.inc"%>
 <%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

 <%@page import="com.matrixone.apps.productline.*" %>
 <%@page import = "com.matrixone.apps.configuration.*"%>
 <%@page import="com.matrixone.apps.domain.*" %>

 <%

    //Retrieves Objectid in context
    String strObjectId = emxGetParameter(request, "objectId");
    DomainObject bus = new DomainObject(strObjectId); 
    String strObjectType = bus.getType(context);
    String strLocale = context.getSession().getLanguage();
    String strType = "";
    if(bus.isKindOf(context, ConfigurationConstants.TYPE_CONFIGURATION_FEATURE)){
    	strType = ConfigurationConstants.TYPE_CONFIGURATION_FEATURE;
    }
    else{
    	strType = ConfigurationConstants.TYPE_CONFIGURATION_OPTION;
    }
 %>


 <%@include file = "../emxUICommonHeaderEndInclude.inc"%>

  <!-- feature create form -->
  <form name="FeatureChangeType" method="post" onsubmit="submitForm(); return false">
    <!--Passing the object id as a hidden field-->
    <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />


    <table border="0" cellpadding="5" cellspacing="2" width="100%">

    <!-- Display the input fields. -->

    <tr>
      <td width="150" nowrap="nowrap" class="label">
        <emxUtil:i18n localize="i18nId">
          emxFramework.Basic.Type
        </emxUtil:i18n>
      </td>
      <td nowrap="nowrap" class="field"><%= XSSUtil.encodeForHTML(context,i18nNow.getTypeI18NString(strObjectType, strLocale)) %></td>
    </tr>


    <tr>
      <td width="150" nowrap="nowrap" class="labelRequired">
        <emxUtil:i18n localize="i18nId">
          emxProduct.Form.Label.NewType
        </emxUtil:i18n>
      </td>
      <td nowrap="nowrap" class="field">
        <input type="text" name="txtFeatureType" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%= i18nNow.getTypeI18NString(strType, strLocale) %></xss:encodeForHTMLAttribute>" />
        <input class="button" type="button" name="btnType" size="200" value="..." alt=""  onClick="javascript:showTypeSelector();" />
        <input type="hidden" name="txtFeatureActualType" value="<xss:encodeForHTMLAttribute><%= strType %></xss:encodeForHTMLAttribute>" />
      </td>
    </tr>


    <tr>
      <td width="150"><img src="../common/images/utilSpacer.gif" width="150" height="1" alt=""/></td>
      <td width="90%">&nbsp;</td>
    </tr>

    </table>
    <input type="image" value="" height="1" width="1" border="0" />
  </form>

     <!-- <script language="javascript" src="../common/scripts/emxJSValidationUtil.js"></script> -->
     <script language="javascript" type="text/javaScript">
        <!-- hide JavaScript from non-JavaScript browsers -->
        //<![CDATA[
        var  formname = document.FeatureChangeType;

        // checking mandatory field validations before submiting
        function validateFeature()
        {
          var iValidForm = 0;
          var strMsg = "";

          // check if source and destination feature types are different.
          if (formname.txtFeatureType.value=='<%=XSSUtil.encodeForJavaScript(context,strObjectType)%>')
          {
            iValidForm ++ ;
            strMsg = "<%=i18nNow.getI18nString("emxProduct.Alert.ChangeTypeSourceDestinationSame", bundle,acceptLanguage)%> ";
          }

          if (iValidForm > 0 )
          {
            alert(strMsg);
            return;
          }
          //alert(formname.action);
          strMsg= "<%=i18nNow.getI18nString("emxProduct.Alert.ChangeTypeConfirmation", bundle,acceptLanguage)%> ";
          if (confirm(strMsg))
      {
        if (jsDblClick()) {
            formname.submit();
            }
      }
          else
            return;
        }

        // close button
        function closeWindow()
        {
          parent.window.closeWindow();
        }

       //When Enter Key Pressed on the form
      function submitForm()
      {
      submit();
      }

        // submit button
        function submit()
        {
          formname.action="../configuration/FeatureUtil.jsp?mode=changeType";
          validateFeature();
          return;
        }

        // This function is for popping the Type chooser.
        function showTypeSelector()
        {
          //The value chosen by the type chooser is returned to the corresponding field.

          var sURL = '../common/emxTypeChooser.jsp?fieldNameDisplay=txtFeatureType';
          sURL = sURL + '&fieldNameActual=txtFeatureActualType';
          sURL = sURL + '&formName=FeatureChangeType&SelectAbstractTypes=false&ShowIcons=true';
          sURL = sURL + '&InclusionList=<%=XSSUtil.encodeForURL(context,strType)%>&ObserveHidden=true';
          sURL = sURL + '&ExclusionList=<%=XSSUtil.encodeForURL(context,ProductLineConstants.TYPE_MASTER_FEATURE)%>';
          sURL = sURL + '&SelectType=single&SuiteKey=eServiceSuiteConfiguration';
          showChooser(sURL,500,400);
        }

        //]]>
     </script>
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
     <%@include file = "../emxUICommonEndOfPageInclude.inc"%>
