<%--  TestExecutionCreateDialog.jsp

  Copyright (c) 2005-2018 Dassault Systemes.  All Rights Reserved.

  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /ENOProductLine/CNext/webroot/productline/TestExecutionCreateDialog.jsp 1.3.2.1.1.1 Wed Oct 29 22:17:06 2008 GMT przemek Experimental$"
--%>
<%--

@quickreview T25 DJH 13:08:20 : IR IR-248494V6R2014x : "Test Execution creation window is KO" : Modified code to open slidein window instead of pop up for Test Execution Creation.
@quickreview T25 DJH 13:09:11 : IR IR-254002V6R2014x  : "Extra Line displayed on Test Execution creation form.
@quickreview T25 DJH 13:12:11 : Correction promoted against IR IR-269989V6R2015 for  replacing old search on “Test Execution” creation slide in page for “owner” attribute. Modifed showPersonSelector()".
@quickreview T25 T25 14:04:23 : HL Parameter under Test Case. Added one checked box in Form.
@quickreview LX6 JX5 14:06:06 : IR-302553-3DEXPERIENCER2015x R216-STP: Creation of Test Execution display script error and tree view does not show newly create Test Execution.
--%>
 <%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

   <%-- Common Includes --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
   <%@include file = "emxProductCommonInclude.inc" %>   
   <%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
   <%@include file = "GlobalSettingInclude.inc"%>
   <%@include file = "../common/emxUIConstantsInclude.inc"%>

   <%@page import  = "com.matrixone.apps.domain.util.FrameworkUtil"%>
   <%@page import  = "com.matrixone.apps.domain.DomainConstants"%>
   <%@page import  = "com.matrixone.apps.productline.ProductLineConstants"%>

<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
<script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script>
<%
    //to store the Tree Id
    String strTreeId    = null;
    //to store the Suite Directory
    String strSuiteKey  = null;
    //to store the parent id
    String busId        = null;
    //T25 DJH : To Create slidein during Test Execution Creation.
    boolean isSlideIn = "slidein".equalsIgnoreCase(emxGetParameter(request,"targetLocation"));
    String openNewTR = isSlideIn ? "</TR><TR>" : "";
    try
    {
        //Retrieves Parent ObjectId in context
        busId                   = emxGetParameter(request, "objectId");
        strTreeId               = emxGetParameter(request, "jsTreeID");
        strSuiteKey             = emxGetParameter(request, "suiteKey");

    // Begin of Add by Enovia MatrixOne for Bug # 300701 Date- 05/10/2005
    //displaying Owner name in Last Name,First Name format
    Person person = Person.getPerson(context);
    String strFirstName = person.getInfo(context,Person.SELECT_FIRST_NAME);
    String strLastName = person.getInfo(context,Person.SELECT_LAST_NAME);
    String strOwnerDisplay = strLastName + "," + strFirstName;
    // End of Add by Enovia MatrixOne for Bug # 300701 Date- 05/10/2005

    //Added by Enovia MatrixOne on 18-May-05 for Bug# 304697
    String strTimeZone = (String)session.getValue ("timeZone");

%>
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>


  <form name="TestExecutionCreate"  method="post" onsubmit="submitForm(); return false" >
  <%@include file="../common/enoviaCSRFTokenInjection.inc" %>  
  <input type="hidden" name="busId" value="<xss:encodeForHTMLAttribute><%=busId%></xss:encodeForHTMLAttribute>">
  <input type="hidden" name="strAutoNamer" value="<xss:encodeForHTMLAttribute><%=strAutoNamer%></xss:encodeForHTMLAttribute>">
  <input type="hidden" name="TimeZone" value="<xss:encodeForHTMLAttribute><%=strTimeZone%></xss:encodeForHTMLAttribute>">
    <table border="0" cellpadding="5" cellspacing="2" width="100%">
    <%-- Display the input fields. --%>

<%
    //check for autonamer settings and display name field accordingly
    if (!strAutoNamer.equalsIgnoreCase("True") || strAutoNamer.equalsIgnoreCase(DomainConstants.EMPTY_STRING)) {
%>
        <tr>
          <td width="150" nowrap="nowrap" class="labelRequired">
            <emxUtil:i18n localize="i18nId">
              emxFramework.Basic.Name
            </emxUtil:i18n>
			<%--XSSOK --%>
            <%=openNewTR %>    <%--breaking the row into two rows --%> 
          </td>
          <td nowrap="nowrap" class="field">
            <input type="text" name="txtTEName" size="20" onFocus="valueCheck()">
            &nbsp;
<%
      if (strAutoNamer.equalsIgnoreCase(DomainConstants.EMPTY_STRING)) {
%>
            <input type="checkbox" name="AutoName" onclick="nameDisabled()"><emxUtil:i18n localize="i18nId">emxProduct.Form.Label.Autoname</emxUtil:i18n>
<%
      }
%>
          </td>
        </tr>
<%
    } else {

%>
            <input type="hidden" name="txtTEName" value="">
<%
    }
%>
    <tr>
      <td width="150" class="label">
        <framework:i18n localize="i18nId">
          emxFramework.Basic.Description
        </framework:i18n>
      </td>
	  <%--XSSOK --%>
      <%=openNewTR %>
      <td class="field">
        <textarea name="txtTEDescription" rows="5" cols="25" ></textarea>
      </td>
    </tr>
    
        <tr>
      <td width="150" class="label">
      <b>
        <emxUtil:i18n localize="i18nId">emxProduct.Form.Label.CopyParameter</emxUtil:i18n>
      </b>
         &nbsp;
         <input type="checkbox" name="CopyParameter">
      </td>
    </tr>

    <tr>
      <td width="150" nowrap="nowrap" class="labelRequired">
        <framework:i18n localize="i18nId">
          emxFramework.Basic.Owner
        </framework:i18n>
      </td>
	  <%--XSSOK --%>
      <%=openNewTR %>
      <td nowrap="nowrap" class="field">
        <input type="text" name="txtTEOwnerId" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strOwnerDisplay%></xss:encodeForHTMLAttribute>">
        <input class="button" type="button" name="btnOwner" size="200" value="..." alt=""  onClick="javascript:showPersonSelector();">
        <input type="hidden" name="txtTEOwner" value="<xss:encodeForHTMLAttribute><%=context.getUser()%></xss:encodeForHTMLAttribute>">
      </td>
    </tr>

    </tr>
      <td width="150" nowrap="nowrap" class="label">
        <emxUtil:i18n localize="i18nId">
          emxFramework.Attribute.Estimated_Start_Date
        </emxUtil:i18n>
      </td>
	  <%--XSSOK --%>
      <%=openNewTR %>
      <td nowrap="nowrap" class="field">
        <input type="text" name="txtTEEstStartDt" size="20" readonly="readonly" >
        <a href="javascript:showCalendar('TestExecutionCreate','txtTEEstStartDt', '')">
          <img src="../common/images/iconSmallCalendar.gif" border="0" valign="bottom"></a>
        <input type="hidden" name="txtTEEstStartDt_msvalue" value="">
      </td>
    </tr>

    </tr>
      <td width="150" nowrap="nowrap" class="label">
        <emxUtil:i18n localize="i18nId">
          emxFramework.Attribute.Estimated_End_Date
        </emxUtil:i18n>
      </td>
	  <%--XSSOK --%>
      <%=openNewTR %>
      <td nowrap="nowrap" class="field">
        <input type="text" name="txtTEEstEndDt" size="20" readonly="readonly" >
        <a href="javascript:showCalendar('TestExecutionCreate','txtTEEstEndDt', '')">
          <img src="../common/images/iconSmallCalendar.gif" border="0" valign="bottom"></a>
        <input type="hidden" name="txtTEEstEndDt_msvalue" value="">
      </td>
    </tr>
<%
    }
    catch(Exception e) {
        session.putValue("error.message", e.getMessage());
    }
%>


   <%@include file = "emxValidationInclude.inc" %>
   <script language="javascript" type="text/javaScript">
   <% if(isSlideIn){ %>  
   document.getElementsByTagName("body")[0].className = "slide-in-panel slide-in-panel-uc"; // IR-248494V6R2014x
   <% } %>
   var  formName = document.TestExecutionCreate;
   var strAutoNamer = document.TestExecutionCreate.strAutoNamer.value;
   //XSSOK
   if((<%=strAutoNamer.equalsIgnoreCase("False")%>) || strAutoNamer == "" ) {
     document.TestExecutionCreate.txtTEName.focus();
   } else {
     document.TestExecutionCreate.txtTEDescription.focus();
   }
  //<![CDATA[
  var autoNameValue = "<xss:encodeForJavaScript><%= strAutoNamer %></xss:encodeForJavaScript>";

   //called when user clicks on name field...if autoname is true then focus is transferred to description field
   function valueCheck() {
	   //XSSOK
       if (<%=strAutoNamer.equals("")%> == true) {
         if (formName.AutoName.checked) {
           //formName.txtTEDescription.focus();
           document.TestExecutionCreate.txtTEName.blur();
         }
       }
   }

   //called wheen the check box is checked
   function nameDisabled() {
	   //XSSOK
     if (<%=strAutoNamer.equals("")%> == true) {
       if (formName.AutoName.checked) {
         formName.txtTEName.value="";
         formName.AutoName.value="true";
         formName.txtTEDescription.focus();
       } else {
           formName.txtTEName.focus();
       }
     }
   }

   //validates dialog form for its fields
   function validateForm() {
       var iValidForm = true;
       var msg = "";
       //This variable is equal to true if the form is valid
       var iValidForm = true;
       //XSSOK
       if (!(<%=strAutoNamer.equalsIgnoreCase("True")%>))  {
           //XSSOK
         if ((<%=strAutoNamer.equalsIgnoreCase("False")%>)) {
           if (iValidForm) {
             var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Name", bundle,acceptLanguage)%> ";
             var field = formName.txtTEName;
             iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);
           }
         }else{
           if (!formName.AutoName.checked) {
             if (iValidForm) {
               var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Name", bundle,acceptLanguage)%> ";
               var field = formName.txtTEName;
               iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);
             }
           }
         }
       }
       //validation for special chars in the description field - The sixth(true/false) and last parameter 'checkBadChars' specifies which characters have to be blocked (all bad chars, common illegal characters are now Restricted Characters)
       if (iValidForm)
       {
         var fieldName = "<%=i18nStringNowUtil("emxFramework.Basic.Description", bundle,acceptLanguage)%> ";
         var field = formName.txtTEDescription;
         iValidForm = basicValidation(formName,field,fieldName,false,false,false,false,false,false,checkBadChars);
       }
       //Validating for Estimated start date to be lesser that Estimated end date.
       if (iValidForm)
       {
         var fieldTEEstStartDt = formName.txtTEEstStartDt_msvalue;
         var fieldTEEstEndDt = formName.txtTEEstEndDt_msvalue;
         //Checking if estimated start date or estimated end date is not entered
         if( !(trimWhitespace(fieldTEEstStartDt.value) == '' || trimWhitespace(fieldTEEstEndDt.value) == '') )
         {
            if(fieldTEEstStartDt.value>fieldTEEstEndDt.value)
            {
                msg = "<%=i18nStringNowUtil("emxProduct.Alert.InvalidEstimatedExecutionDate",bundle,acceptLanguage)%>";
                alert(msg);
                iValidForm = false;
            }
         }
       }

       if (!iValidForm) {
         return ;
       }

       //For displaying process clock
      turnOnProgress();
       if (jsDblClick()) {
        formName.submit();
       }
   }

   //when 'Cancel' button is pressed in Dialog Page
   function closeWindow() {
	   getTopWindow().closeSlideInDialog();
       parent.window.closeWindow();
   }
   //When Enter Key Pressed on the form
   function submitForm() {
       submit();
   }
   //when 'Done' button is pressed in Dialog Page
   function submit() {
       var sURL        = "../productline/TestExecutionUtil.jsp?mode=create";
       sURL            = sURL + "&jsTreeID=<%=XSSUtil.encodeForURL(context,strTreeId)%>&suiteKey=<%=XSSUtil.encodeForURL(context,strSuiteKey)%>"+"&Checkedparameter=" + formName.CopyParameter.checked;

       formName.action = sURL;
       formName.target = "jpcharfooter";
       validateForm();
   }

   /*
    *This function is for popping the Person chooser.
    */
   
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
 		 var objForm = document.forms["TestExecutionCreate"];

 		 var hiddenElement = objForm.elements["txtTEOwnerId"];
 		 var displayElement = objForm.elements["txtTEOwner"];

 		 for (var i = 0; i < arrSelectedObjects.length; i++) 
 		 { 
 		   var objSelection = arrSelectedObjects[i];
 		   hiddenElement.value = objSelection.name;
 			 displayElement.value = objSelection.name;
 			 break;
     }
   }

   </script>

   <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
   <%@include file = "../emxUICommonEndOfPageInclude.inc"%>



