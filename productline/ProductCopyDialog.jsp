<%--  ProductCopyDialog.jsp

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /ENOProductLine/CNext/webroot/productline/ProductCopyDialog.jsp 1.7.2.2.1.1 Wed Oct 29 22:17:06 2008 GMT przemek Experimental$";

--%>
<%-- Include file for error handling --%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%-- Common Includes --%>

<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@page import="com.matrixone.apps.productline.*"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="java.lang.StringBuffer"%>



<%

  try{
    /*Retrieves Objectid that has been selected by the user and
     *this will be used as the Source product object
     */

    StringBuffer sb = new StringBuffer(200);
    String objectId = "";
    String   arrTableRowIds[]=null;
    String arrObjectIds[] = null;
    String strMode = emxGetParameter(request,"PRCFSParam1");
    ProductLineUtil utilbean=new ProductLineUtil();
    if (strMode.equalsIgnoreCase("DetailsPage"))
    {
      objectId = emxGetParameter(request, "objectId");
    }
    else
    {
    	arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");     
    	arrObjectIds = (String[])utilbean.getObjectIdsRelIdsR213(arrTableRowIds).get("ObjId");
    	objectId=(String)arrObjectIds[0];
    }

    DomainObject domObj = new DomainObject(objectId);
    String strName = domObj.getInfo(context, "name");
    String strRev = domObj.getInfo(context, "revision");
    
    String strType = domObj.getInfo(context, DomainConstants.SELECT_TYPE);
    StringList lstProductChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ProductLineConstants.TYPE_PRODUCTS);
    String strLanguage = context.getSession().getLanguage();   
    String strCopyProduct = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.CopyProduct", strLanguage);
    if(!lstProductChildTypes.contains(strType))
    {
%>
        <script language="javascript" type="text/javaScript">
            alert("<%=strCopyProduct%>");
            getTopWindow().closeWindow();
        </script>
<%    	
    }
    
    String strRevLabel = i18nStringNowUtil("emxProduct.Form.Label.Revision",bundle, acceptLanguage);
    
	sb =  sb.append(strName)
	        .append(" ")		
	        .append(strRevLabel)
 	        .append(" ")
			.append(strRev);

	String strNameRev = sb.toString();
    /*
     *These methods are used tp display the Name and Revision of the source product.
     */
    String strSourceFieldString = i18nStringNowUtil("emxProduct.Form.Value.SourceProduct",bundle, acceptLanguage);
    String strSourceValue = com.matrixone.apps.framework.ui.UINavigatorUtil.getParsedHeaderWithMacros(context,acceptLanguage,strNameRev,objectId);
%>
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

    <form name="ProductCopy" action=submit() method="post" onsubmit="submitForm(); return false">
    <%@include file="../common/enoviaCSRFTokenInjection.inc" %>
    
      <input type="hidden" name="sourceObjectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>">

      <table border="0" cellpadding="5" cellspacing="2" width="100%">
      <%-- Display the input fields. --%>

      <tr>
        <td width="150" nowrap="nowrap" class="label">
          <emxUtil:i18n localize="i18nId">
            emxProduct.Form.Label.Source
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <%=XSSUtil.encodeForHTML(context,strSourceValue)%>
        </td>
      </tr>

      <tr>
        <td width="150" nowrap="nowrap" class="labelRequired">
          <framework:i18n localize="i18nId">
            emxProduct.Form.Label.Destination
          </framework:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtDestinationProduct" size="20" readonly="readonly">
          <input class="button" type="button" name="btnProduct" size="200" value="..." alt=""  onClick="javascript:showProductChooser()">
          <input type="hidden" name="destinationObjectId" value="">
        </td>
      </tr>

      <tr>
        <td width="150"><img src="../common/images/utilSpacer.gif" width="150" height="1" alt=""/></td>
        <td width="90%">&nbsp;</td>
      </tr>

      </table>
      <!-- NextGen UI Adoption : Commented below image-->
      <!-- Modified for removing unnecessary link on Page -->
      <!-- <input type="image" value="" height="1" width="1" border="0" > -->
    
    </form>
<%
  }catch(Exception e)
  {
    session.putValue("error.message", e.getMessage());
  }
%>

  <%@include file = "emxValidationInclude.inc" %>

  <script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
  <script language="javascript" type="text/javaScript">
  //<![CDATA[
    var  formName = document.ProductCopy;

    function showProductChooser()
    {
      //This function is for popping the Model chooser.
      showChooser('../common/emxFullSearch.jsp?field=TYPES=type_Products&table=PLCSearchProductsTable&selection=single&formName=modelCreate&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../productline/SearchUtil.jsp?&mode=Chooser&chooserType=FormChooser&fieldNameActual=destinationObjectId&fieldNameDisplay=txtDestinationProduct', 850, 630)
    }

    //when 'Cancel' button is pressed in Dialog Page
    function closeWindow()
    {

      parent.window.closeWindow();
    }

    //When Enter Key Pressed on the form
   function submitForm()
   {
	submit();
   }

    //when 'Done' button is pressed
    function submit()
    {

      var iValidForm = true;
      //var msg = "";

      if (iValidForm)
      {
        var fieldName = "<%=i18nStringNowUtil("emxProduct.Form.Label.Destination", bundle,acceptLanguage)%> ";
        var field = formName.txtDestinationProduct;
        iValidForm = basicValidation(formName,field,fieldName,true,false,false,false,false,false,false);
         }
      if (iValidForm && formName.destinationObjectId.value==formName.sourceObjectId.value)
	             {
	               iValidForm=false;
	               strMsg = "<%=i18nStringNowUtil("emxProduct.Alert.CopyProductSourceDestinationSame", bundle,acceptLanguage)%> ";
	               alert(strMsg);
	               formName.destinationObjectId.value = "";
	               formName.txtDestinationProduct.value = "";

           }

      if (!iValidForm)
      {
        return ;
      }

     <%
            StringBuffer strTest = new StringBuffer("");
            String strURL="../productline/ProductUtil.jsp?mode=copyProduct";
            String strContextWindow = emxGetParameter(request, "PRCFSParam1");

            if (strContextWindow.equalsIgnoreCase("DetailsPage") )
                strTest.append("&PRCFSParam1=DetailsPage");
            else if (strContextWindow.equalsIgnoreCase("ListPage") )
                strTest.append("&PRCFSParam1=ListPage");
            strURL = strURL + strTest;
     %>
      formName.action="<xss:encodeForJavaScript><%=strURL%></xss:encodeForJavaScript>";
      formName.target = "jpcharfooter";
      //After Validation is passed.

		if (jsDblClick()) {
			    formName.submit();
		   	 }
 }
  //]]>
  </script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
