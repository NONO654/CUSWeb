<%--  DesignEffectivityReviseDialog.jsp

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /web/dmcplanning/DesignEffectivityReviseDialog.jsp 1.1 Thu Dec 18 14:36:21 2008 GMT ds-pborgave Experimental$";

--%>

<%-- Top error page in emxNavigator --%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%--Common Include File --%>
<%@include file="DMCPlanningCommonInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file="ValidationInclude.inc"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.productline.Product"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>

<script language="javascript" type="text/javascript"
	src="../components/emxComponentsJSFunctions.js"></script>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>

<jsp:useBean id="tableBean"
	class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<%
String strLastRevId = null;
String jsTreeId = emxGetParameter(request, "jsTreeID");
String relId = emxGetParameter(request, "relId");
String strAction = null;

           try {

                
        	   
                String objectId = emxGetParameter(request, "objectId");
                String strFunctionality = (String) emxGetParameter(request,"functionality");
                String mode = emxGetParameter(request,"PRCFSParam3");
                strAction = emxGetParameter(request,"PRCFSParam2");
                String strParentObjectId = objectId;

               
    //Gets the mode with which the revise dialog is opened up.
    String strMode = emxGetParameter(request,"PRCFSParam1");
    String strProductRevId = "";

    //Product bean is initialized
    com.matrixone.apps.productline.Product productBean = (com.matrixone.apps.productline.Product) com.matrixone.apps.domain.DomainObject.newInstance(context,ManufacturingPlanConstants.TYPE_PRODUCTS,"ProductLine");

    //We need to check here whether Model is having any Product Revision connected to it
    DomainObject domainParentObj = new DomainObject(objectId);
    Boolean checkProductRev = domainParentObj.hasRelatedObjects(context,ManufacturingPlanConstants.RELATIONSHIP_PRODUCTS,true);
    
    
   Map revisionInfoMap = new HashMap(); 
   if (checkProductRev)
   {
    DomainObject domainObj = new DomainObject(objectId);
    Map hMap = new HashMap();
    StringList slist = new StringList();
    slist.add("from["+ManufacturingPlanConstants.RELATIONSHIP_PRODUCTS+"].to.id");
    hMap = domainObj.getInfo(context,slist);
    strProductRevId = (String)hMap.get("from["+ManufacturingPlanConstants.RELATIONSHIP_PRODUCTS+"].to.id");
    DomainObject domProductRevId = new DomainObject(strProductRevId);
    revisionInfoMap = productBean.getRevisionInfoUnderContext(context,strParentObjectId,strProductRevId);
    strLastRevId  = (domProductRevId.getLastRevision(context)).getObjectId();
   }
  
    String strName = (String) revisionInfoMap.get(DomainConstants.SELECT_NAME);
    String strType = (String) revisionInfoMap.get(DomainConstants.SELECT_TYPE);
    String strRevision = (String) revisionInfoMap.get(DomainConstants.SELECT_REVISION);
    String strDescription = (String) revisionInfoMap.get(DomainConstants.SELECT_DESCRIPTION);
    
    

    if (mode != null && mode.equalsIgnoreCase("getfromsession"))
    {
        strDescription = (String)session.getAttribute("Description");
        strRevision = (String)session.getAttribute("Revision"); 
    }

%>
           
  <%@include file = "../emxUICommonHeaderEndInclude.inc"%>

    <form name="ProductRevise" action=submit() method="post">

      <input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeId%></xss:encodeForHTMLAttribute>">
      <table border="0" cellpadding="5" cellspacing="2" width="100%">
      <%-- Display the input fields. --%>

      
    <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            DMCPlanning.Form.Name
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
		      <input type="text" name="txtProductName" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strName%></xss:encodeForHTMLAttribute>"
		                  > 
		      <input type="hidden" name="hidProductId" id="hidProductId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"> 
        </td>
	</tr>
      
    <tr>
        <td width="150" nowrap="nowrap" class="labelRequired">
          <emxUtil:i18n localize="i18nId">
            DMCPlanning.Form.Revision
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtRevision" size="20" value="<xss:encodeForHTMLAttribute><%=strRevision%></xss:encodeForHTMLAttribute>">
        </td>
      </tr>

      <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            DMCPlanning.Form.Type
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <%=XSSUtil.encodeForHTML(context,i18nNow.getTypeI18NString(strType,acceptLanguage))%>
        </td>
      </tr>

      <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            DMCPlanning.Form.Description
          </emxUtil:i18n>
        </td>
        <td  class="field">
          <textarea name="txtProductDescription" rows="5" cols="25"><xss:encodeForHTML><%=strDescription%></xss:encodeForHTML></textarea>
        </td>
      </tr>

      <tr>
        <td width="150"><img src="../common/images/utilSpacer.gif" width="150" height="1" alt=""/></td>
        <td width="90%">&nbsp;</td>
      </tr>

      </table>
    </form>



<script language="javascript" type="text/javaScript">
        var  formName = document.ProductRevise;
        
        var closing = true;

        
        function moveNext() 
        {
         		closing = false;
         		var isDuplicateName = "false";
                var iValidForm = true;
                var msg = "";
                var sTextValue =  trimWhitespace(formName.txtProductName.value);
                formName.txtProductName.value = sTextValue;
                formName.action="../dmcplanning/DesignEffectivityUtil.jsp?mode=featureSelect&functionality=ProductRevisionCreateFlatViewContentFSInstance&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeId)%>&relId=<%=XSSUtil.encodeForURL(context,relId)%>&objectId=<%=XSSUtil.encodeForURL(context,objectId)%>&strRevision=<%=XSSUtil.encodeForURL(context,strRevision)%>&parentProductId=<%=XSSUtil.encodeForURL(context,strLastRevId)%>&createRevise=revise";
                formName.submit();        
                
	 
        }

        function closeWindow()
         {
                document.ProductRevise.action="../dmcplanning/DesignEffectivityUtil.jsp?mode=cleanupsession"
                
                getTopWindow().window.closeWindow();
            }

        function submit()
        {
            
            formName.action="../dmcplanning/DesignEffectivityUtil.jsp?mode=createRevise&functionality=ProductRevisionCreateFlatViewContentFSInstance&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeId)%>&relId=<%=XSSUtil.encodeForURL(context,relId)%>&objectId=<%=XSSUtil.encodeForURL(context,objectId)%>&strRevision=<%=XSSUtil.encodeForURL(context,strRevision)%>&parentProductId=<%=XSSUtil.encodeForURL(context,strLastRevId)%>&createRevise=create";
            if (jsDblClick()) {
                formName.submit();
              }
        }

      </script>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%
  }
           catch(Exception e)
           {
             String alertString = "DMCPlanning.Alert." + e.getMessage();
             String strErrorMessage = i18nStringNowUtil(alertString,bundle,acceptLanguage);

             if ("".equals(strErrorMessage))
               strErrorMessage = e.getMessage();

             session.putValue("error.message", strErrorMessage);
             
       }
%>
