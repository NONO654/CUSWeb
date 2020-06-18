<%--

  RevisionCreateDialog.jsp

  Performs the actions that creates a New Revision of objects is PLC

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  @quickreview T25 DJH 16 Oct 2013  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
--%>
<%-- Include JSP for error handling --%>
    <%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
    <%@include file = "emxProductCommonInclude.inc" %>
    <%@include file = "../emxUICommonAppInclude.inc"%>
    <%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
    <%@include file = "../emxUICommonHeaderEndInclude.inc"%>
    <%@include file = "emxValidationInclude.inc" %>

    <%@page import = "java.util.Map"%>
    <%@page import = "com.matrixone.apps.productline.ProductLineConstants" %>
    <%@page import = "com.matrixone.apps.productline.ProductLineUtil" %>

    <%@page import = "com.matrixone.apps.domain.DomainConstants" %>
    <%@page import = "com.matrixone.apps.domain.DomainObject" %>
    <%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
     <%
    String strTreeId = "";
    String strSuiteKey = "";
    String strObjectId = "";
	String strParentId = "";
    String strRelId = "";
    String strName = "";
    String strRevision = "";
    String strType = "";
    String strDescription = "";
    Map attribMaps = null;
    Map attribMaps1 = null;
    MapList attribMap = null;
    String attribRange = null;
    boolean bIsError=false;
    String strParamName="";
    String paramValue="";

     try
     {
         //Retrieves the relationship id 
         strRelId = emxGetParameter(request, "relId");
                            
         //Retrieves Objectid in context
        strObjectId = emxGetParameter(request, "objectId");
        //getting tree id from common FS
        strTreeId = emxGetParameter(request, "jsTreeID");
        //getting suite key from common FS
        strSuiteKey = emxGetParameter(request, "suiteKey");
        //instanciating the Product Central common Bean to retrieve information about the Revision
        ProductLineCommon commonBean = new ProductLineCommon();
        //This method returns a map containing information about Type, name next revision sequence and description.
        //it is used to populate the default values in the dialog box
        Map mpObjectInfo = (HashMap)commonBean.getRevisionInfo(context,strObjectId);

        DomainObject domObj =  DomainObject.newInstance(context, strObjectId);
        
        boolean isMajorRevisionable = ProductLineCommon.isMajorPolicy(context, domObj);       
        
        if(isMajorRevisionable){
        	strRevision = domObj.getNextMajorSequence(context);	
        }else{
        	strRevision = domObj.getNextSequence(context);
        }
        
        if(mpObjectInfo!=null && mpObjectInfo.size()!=0) {
            //Retrieving the Name,Type,Next Revision Sequence and Description of the context object
            strName = (String) mpObjectInfo.get(DomainConstants.SELECT_NAME);
            strType = (String) mpObjectInfo.get(DomainConstants.SELECT_TYPE);
            strDescription = (String) mpObjectInfo.get(DomainConstants.SELECT_DESCRIPTION);
        }
		// Added in X+5
        // Getting the range values for Float Effectivity
        	String[] attribList = {ProductLineConstants.ATTRIBUTE_DEFAULT_SELECTION};

           attribMaps = ProductLineUtil.getAttributeChoices(context, attribList);

    %>

 <form name = "CommonRevisionControl" method = "post" onsubmit="submitForm(); return false">
 <%@include file="../common/enoviaCSRFTokenInjection.inc" %> 
   <table border="0" cellpadding="5" cellspacing="2" width="100%">
   <%-- Display the input fields. --%>

<%-- Name of the object --%>
   <tr>
     <td width="150" class="label" width="200" align="left">
         <framework:i18n localize="i18nId">
          emxFramework.Basic.Name
       </framework:i18n>
     </td>
     <td class="field">
         <%=XSSUtil.encodeForHTML(context,strName)%>
     </td>
   </tr>

<%-- Type of the object --%>
   <tr>
     <td width="150" class="label" width="200" align="left">
         <framework:i18n localize="i18nId">
          emxFramework.Basic.Type
       </framework:i18n>
     </td>
     <td class="field">
         <%=XSSUtil.encodeForHTML(context,strType)%>
     </td>
   </tr>
<%-- Latest Revision Sequence of the object --%>
   <tr>
     <td width="150" class="labelRequired" width="200" align="left">
         <framework:i18n localize="i18nId">
          emxFramework.Basic.Revision
       </framework:i18n>
     </td>
     <td class="field">
       <input type="text" readonly name="txtRevision" rows="5" cols="25" value="<xss:encodeForHTMLAttribute><%=strRevision%></xss:encodeForHTMLAttribute>">
     </td>
   </tr>

<%-- Description of the object --%>
   <tr>
     <td width="150" class="label" width="200" align="left">
         <framework:i18n localize="i18nId">
          emxFramework.Basic.Description
       </framework:i18n>
     </td>
     <td class="field">
       <textarea name="txtDescription" rows="5" cols="25"><xss:encodeForHTML><%=strDescription%></xss:encodeForHTML></textarea>
     </td>
   </tr>

   <tr>
     <td width="150"><img src="../common/images/utilSpacer.gif" width="150" height="1" alt=""/></td>
     <td width="90%">&nbsp;</td>
   </tr>
  </table>
   <input type="image" height="1" width="1" border="0" value="">
 </form>
    <%
     }catch(Exception ex){
        bIsError=true;
        ex.printStackTrace();
        emxNavErrorObject.addMessage(ex.getMessage().toString().trim());
     }
    %>
  <script language="javascript" type="text/javaScript">
  //<![CDATA[
  var  formname = document.CommonRevisionControl;

  //validates form for required field
  function validateForm()
  {
   var iValidForm = true;
    //Validation for Required field Revision field for bad characters as well as required field.Also length check added
      if (iValidForm)
        {
          var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Revision", bundle,acceptLanguage)%> ";
          var field = formname.txtRevision;
          // Modified by Enovia MatrixOne Date 03/22/2005
          iValidForm = basicValidation(formname,field,fieldName,true,true,true,false,false,false,false)
        }
    //Validation for Required field Description for bad characters .as well as required field
      if (iValidForm)
        {
          var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Description", bundle,acceptLanguage)%> ";
          var field = formname.txtDescription;
          iValidForm = basicValidation(formname,field,fieldName,false,false,true,false,false,false,checkBadChars)
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
      parent.window.closeWindow();
  }
  //When Enter Key Pressed on the form
  function submitForm()
  {
  submit();
  }
  //when Done button is pressed in Dialog Page
  function submit()
  {
      strURL = "../productline/RevisionUtil.jsp?mode=Create";
      strURL = strURL + "&jsTreeID=<%=XSSUtil.encodeForURL(context,strTreeId)%>&suiteKey=<%=XSSUtil.encodeForURL(context,strSuiteKey)%>";
      strURL = strURL + "&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&relId=<%=XSSUtil.encodeForURL(context,strRelId)%>";
      formname.action = strURL;
      validateForm();
  }
  //]]>
  </script>

     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
     <%@include file = "../emxUICommonEndOfPageInclude.inc"%>

<%
  if (bIsError)

  {
%>

    <script language="javascript" type="text/javaScript">
    var pc =findFrame(parent,"pagecontent");
    pc.clicked = false;
    parent.turnOffProgress();
      
      history.back();
    </script>
<%
  }
%>
