<%--  ProductReviseDialog.jsp

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /ENOProductLine/CNext/webroot/productline/ProductReviseDialog.jsp 1.3.2.1.1.1 Wed Oct 29 22:17:06 2008 GMT przemek Experimental$";


--%>
<%-- Include file for error handling --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%-- Common Includes --%>

<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import="com.matrixone.apps.productline.*"%>
<%@ page import="com.matrixone.apps.domain.util.i18nNow" %>
<%@ page import="com.matrixone.apps.domain.DomainConstants" %>
<%@ page import = "com.matrixone.apps.domain.DomainObject"%>

<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<%

  //Exception variable is used to check if the dialog is to be closed in case of exception.
  boolean bException = false;
  String jsTreeID = "";

  String  strName = "";
  String  strType = "";
  String  strRevision = "";
  String  strDescription = "";
  String strProductId = "";


  try{
    //Retrieves Objectid to make use for the revise process
    String objectId = emxGetParameter(request, "objectId");
    // Added by Mayukh, Enovia MatrixOne Bug # 300719 Date 03/18/2005
    String strParentObjectId = objectId;

    //Retreives the tree node id to open the tree appropriately after revising.
    jsTreeID = emxGetParameter(request, "jsTreeID");

    //Gets the mode with which the revise dialog is opened up.
    String strMode = emxGetParameter(request,"PRCFSParam1");

    //Gets the mode with which the revise dialog is opened up.
    String strContextMode = emxGetParameter(request,"PRCFSParam2");


    //Product bean is initialized
    Product productBean = (Product) com.matrixone.apps.domain.DomainObject.newInstance(context,ProductLineConstants.TYPE_PRODUCTS,"ProductLine");

   if (strContextMode.equalsIgnoreCase("contextModel"))
   {
    DomainObject domainObj = new DomainObject(objectId);
    Map hMap = new HashMap();
    StringList slist = new StringList();
    slist.add("from[Products].to.id");
    hMap = domainObj.getInfo(context,slist);
    strProductId = (String)hMap.get("from[Products].to.id");
    objectId = strProductId;
   }

    /*If the revise dialog is opened from a property page, then validation is done to check
     *if the object has revision already. If yes then the revise will not be carried out.
     */
    if (strMode.equalsIgnoreCase("Property"))
    {
      //Function call to check if the context product object has been revised.
      boolean bHasRevisions= productBean.hasRevisions(context,objectId);
      if (bHasRevisions){
        String alertString = "emxProduct.Alert.Revision-Exists" ;
        String strErrorMessage = i18nStringNowUtil(alertString,bundle,acceptLanguage);
        throw new FrameworkException(strErrorMessage);
      }
    }
    //Function call to retrieve the field values that are to be displayed in the dialog
    // Begin of Modify Mayukh, Enovia MatrixOne Bug # 300719 Date 03/18/2005
    Map revisionInfoMap = new HashMap();

	if (strContextMode.equalsIgnoreCase("contextModel"))
    {

		revisionInfoMap = productBean.getRevisionInfoUnderContext(context,strParentObjectId,objectId);
	}
	else
	{
		revisionInfoMap = productBean.getRevisionInfo(context,objectId);
	}
	// End of Modify Mayukh, Enovia MatrixOne Bug # 300719 Date 03/18/2005
    /*
     *The individual element values are retrieved on to suitable variables.
     */
    strName = (String) revisionInfoMap.get(DomainConstants.SELECT_NAME);
    strType = (String) revisionInfoMap.get(DomainConstants.SELECT_TYPE);
    strRevision = (String) revisionInfoMap.get(DomainConstants.SELECT_REVISION);
    strDescription = (String) revisionInfoMap.get(DomainConstants.SELECT_DESCRIPTION);
    // HDM: Check we have some DesignSync stores and HDM (actually, SCC) is installed.
    Boolean hasDesignSync =(Boolean)JPO.invoke(context, "emxVCDocumentUI", null, "hasDesignSyncServer", null, Boolean.class);
    Boolean hasHDM = (Boolean)FrameworkUtil.isSuiteRegistered(context,"appVersionTeamCollaboration",false,"","");



%>
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<body onload="return getFocus();">
    <form name="ProductRevise" action=submit() method="post">
<%
   if (strContextMode.equalsIgnoreCase("contextModel"))
   {
%>
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>">
      <input type="hidden" name="ContextMode" value="Model">
      <!--Added by Enovia MatrixOne for Bug #298000 on 5/12/2005 -->
      <input type="hidden" name="contextParentId" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "objectId")%></xss:encodeForHTMLAttribute>">
<% }
   else{
  %>
     <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>">
     <input type="hidden" name="ContextMode" value="Product">
     <!--Added by Enovia MatrixOne for Bug #298000 on 5/12/2005 -->
     <input type="hidden" name="contextParentId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>">
<%
   }
%>
      <input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>">
      <table border="0" cellpadding="5" cellspacing="2" width="100%">
      <%-- Display the input fields. --%>

      <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Name
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <%=XSSUtil.encodeForHTML(context,strName)%>
        </td>
      </tr>

      <tr>
        <td width="150" nowrap="nowrap" class="labelRequired">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Revision
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtRevision" size="20" value="<xss:encodeForHTMLAttribute><%=strRevision%></xss:encodeForHTMLAttribute>">
        </td>
      </tr>
      <% // HDM: Add HDM specific fields.
      if(hasHDM){ 
      %>
          <tr>
              <td width="150" nowrap="nowrap" class="label">
                  <%=i18nStringNowUtil("emxSemiTeamCollab.Label.Tags", "emxSemiTeamCollabStringResource",acceptLanguage)%>
              </td>
              <td  nowrap="nowrap" class="field">
                  <input type="text" name="txtTags" size="20" value="">
              </td>
          </tr>
          <tr>
              <td width="150" nowrap="nowrap" class="label">
                  <%=i18nStringNowUtil("emxSemiTeamCollab.Label.TagsComments", "emxSemiTeamCollabStringResource",acceptLanguage)%>
              </td>
              <td  nowrap="nowrap" class="field">
                  <input type="text" name="txtTagsComments" size="20" value="">
              </td>
          </tr>
          <!--HDM R213: KP2 Start  -->
          <tr>
              <td width="150" nowrap="nowrap" class="label">
                  <%=i18nStringNowUtil("emxSemiTeamCollab.Label.DerivationType", "emxSemiTeamCollabStringResource",acceptLanguage)%>
              </td>
              <td  nowrap="nowrap" class="field">
                  <select id="DerivationType" name="DerivationType">
                    <option value=""></option>
                    <option value="Derived">
                        <%=i18nStringNowUtil("emxSemiTeamCollab.DerivationType.Derived", "emxSemiTeamCollabStringResource",acceptLanguage)%>
                    </option>
                    <option value="Branched">
                        <%=i18nStringNowUtil("emxSemiTeamCollab.DerivationType.Branched", "emxSemiTeamCollabStringResource",acceptLanguage)%>
                    </option>
                  </select>
              </td>
          </tr>
          <tr>
              <td width="150" nowrap="nowrap" class="label">
                  <%=i18nStringNowUtil("emxSemiTeamCollab.Label.DerivationContext", "emxSemiTeamCollabStringResource",acceptLanguage)%>
              </td>
              <td  nowrap="nowrap" class="field">
                  <input type="text" name="DerivationContextDisplay" size="20" value="" readonly>
                  <input type="hidden" name="DerivationContextActual" size="20" value="">
                  <input type="button" onclick="showModalDialog('../common/emxFullSearch.jsp?field=TYPES=<%=XSSUtil.encodeForURL(context,strType)%>&objectId=<%=XSSUtil.encodeForURL(context,objectId)%>&includeOIDprogram=emxSCCHDMProducts:getRevisionList&table=PLCSearchProductsTable&selection=single&submitURL=../semiteamcollab/emxSCCHDMFullSearchUtil.jsp?appendRevision=true&fieldNameActual=DerivationContextActual&fieldNameDisplay=DerivationContextDisplay',850,630);" value="...">
                  <a class="dialogClear" name="ancClear" href="#ancClear" onclick="document.ProductRevise.DerivationContextActual.value='';document.ProductRevise.DerivationContextDisplay.value=''">
                    <emxUtil:i18n localize="i18nId">
                        emxProduct.Button.Clear
                    </emxUtil:i18n>
                  </a>
              </td>
          </tr>
          <tr>
              <td width="150" nowrap="nowrap" class="label">
                  <%=i18nStringNowUtil("emxSemiTeamCollab.SCCHDM.MergedFrom", "emxSemiTeamCollabStringResource",acceptLanguage)%>
              </td>
              <td  nowrap="nowrap" class="field">
                  <input type="text" name="MergedFromDisplay" size="20" value="" readonly>
                  <input type="hidden" name="MergedFromActual" size="20" value="">
                  <input type="button" onclick="showModalDialog('../common/emxFullSearch.jsp?field=TYPES=<%=XSSUtil.encodeForURL(context,strType)%>&objectId=<%=XSSUtil.encodeForURL(context,objectId)%>&includeOIDprogram=emxSCCHDMProducts:getRevisionList&table=PLCSearchProductsTable&selection=multiple&submitURL=../semiteamcollab/emxSCCHDMFullSearchUtil.jsp?appendRevision=true&fieldNameActual=MergedFromActual&fieldNameDisplay=MergedFromDisplay',850,630);" value="...">
                  <a class="dialogClear" name="ancClear" href="#ancClear" onclick="document.ProductRevise.MergedFromActual.value='';document.ProductRevise.MergedFromDisplay.value=''">
                    <emxUtil:i18n localize="i18nId">
                        emxProduct.Button.Clear
                    </emxUtil:i18n>
                  </a>
              </td>
          </tr>
          <!--HDM R213: KP2 End  -->
      <%} // HDM: HDM Specific field section ends.
      // commented teh else code for the IR-150984V6R2013
     //* else{ 
    	  %>
    	  <!--  
    	  <tr>
              <td width="150" nowrap="nowrap" class="label">
                  <%=i18nStringNowUtil("emxProduct.Label.DerivedFrom", "emxProductLineStringResource",acceptLanguage)%>
              </td>
              <td  nowrap="nowrap" class="field">
                  <input type="text" name="DerivedFromDisplay" size="20" value="" readonly>
                  <input type="hidden" name="DerivedFromActual" size="20" value="">
                  <input type="button" onclick="showModalDialog('../common/emxFullSearch.jsp?field=TYPES=<%=XSSUtil.encodeForJavaScript(context,strType)%>:NAME=<%=XSSUtil.encodeForJavaScript(context,strName)%>&table=PLCSearchProductsTable&selection=single&submitURL=../productline/SearchUtil.jsp?mode=Chooser&chooserType=FormChooser&appendRevision=true&fieldNameActual=DerivedFromActual&fieldNameDisplay=DerivedFromDisplay',850,630);" value="...">
                  <a class="dialogClear" name="ancClear" href="#ancClear" onclick="document.ProductRevise.DerivedFromActual.value='';document.ProductRevise.MergedFromDisplay.value=''">
                    <emxUtil:i18n localize="i18nId">
                        emxProduct.Button.Clear
                    </emxUtil:i18n>
                  </a>
              </td>
          </tr>
          -->
    	  <%
     //* }
      %>
      <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Type
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <%=i18nNow.getTypeI18NString(strType,acceptLanguage)%>
        </td>
      </tr>

      <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Description
          </emxUtil:i18n>
        </td>
        <td  class="field">
          <textarea name="txtProductDescription" rows="5" cols="25"><xss:encodeForHTML><%=strDescription%></xss:encodeForHTML></textarea>
        </td>
      </tr>

      <%
// HDM: Code to add fields for the HDM product.
      if(hasDesignSync && hasHDM){
    
      %>
      <tr>

      <jsp:include page="../semiteamcollab/emxSCCHDMProductRevisionDesignSyncInformation.jsp">
          <jsp:param name="path" value="null"/>
          <jsp:param name="vcDocumentType" value="null"/>
          <jsp:param name="selector" value="null"/>
          <jsp:param name="server" value="null"/>
          <jsp:param name="format" value="null"/>
          <jsp:param name="showFormat" value="null"/>
          <jsp:param name="populateDefaults" value="null"/>
          <jsp:param name="objectAction" value="createAndConnect"/>
          <jsp:param name="FormName" value="ProductRevise"/>
          <jsp:param name="disableFileFolder" value="null"/>
          <jsp:param name="defaultDocumentPolicyName" value="Product"/>
          <jsp:param name="reloadPage" value="null"/>
      </jsp:include>
      </tr>
      <tr>
          <td width="150"><img src="../common/images/utilSpacer.gif" width="150" height="1" alt=""/></td>
          <td width="90%">&nbsp;</td>
      </tr>


      <%}else{%>

      <tr>
        <td width="150"><img src="../common/images/utilSpacer.gif" width="150" height="1" alt=""/></td>
        <td width="90%">&nbsp;</td>
      </tr>
      <%
      }
// HDM: HDM specific section ends here.
      %>

      </table>
    </form>
    </body>
<%
  }catch(Exception e)
  {
    String alertString = "emxProduct.Alert." + e.getMessage();
    String strErrorMessage = i18nStringNowUtil(alertString,bundle,acceptLanguage);

    if ("".equals(strErrorMessage))
      strErrorMessage = e.getMessage();

    session.putValue("error.message", strErrorMessage);
    bException = true;
  }
%>

  <%@include file = "emxValidationInclude.inc" %>

  <script language="javascript" type="text/javaScript">
  //<![CDATA[
    var  formName = document.ProductRevise;
    //START - Added for bug no. 0623125V6R2011x
    function getFocus()
    {
        formName.txtRevision.focus();
        return true;
    }
    // END - Added for bug no. 0623125V6R2011x
    //After pressing 'Cancel'
    function closeWindow()
    {
      //Releasing Mouse Events
      parent.window.closeWindow();
    }

    //After Pressing 'Done'
    function submit()
    {
      var iValidForm = true;

      //Validation check for Required field, Max Length and Bad characters for field Revision
      if (iValidForm)
      {
        var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Revision", bundle,acceptLanguage)%> ";
        var field = formName.txtRevision;
        iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);
      }

      //Validation check for  Max Length and Bad characters for field  Description
      if (iValidForm)
      {
        var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Description", bundle,acceptLanguage)%> ";
        var field = formName.txtProductDescription;
        iValidForm = basicValidation(formName,field,fieldName,false,false,true,false,false,false,checkBadChars);
      }

      //If Validation fails
      if (!iValidForm)
      {
        return ;
      }
      formName.action="../productline/ProductUtil.jsp?mode=reviseProduct&jsTreeID=<xss:encodeForJavaScript><%=jsTreeID%></xss:encodeForJavaScript>";
      //If Validation succeeds
      if (jsDblClick()) {
        formName.submit();
      }
    }
  //]]>
  </script>
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
  //In case of exception in dialog the window is to be closed.
  if (bException)
  {
%>
  <script language="javascript" type="text/javaScript">
  //<![CDATA[
     //Releasing Mouse Events
     parent.window.closeWindow();
  //]]>
  </script>
<%
  }
%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
