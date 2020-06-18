<%--
  RequirementCopyDialog.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

*@quickreview JX5 LX6 12:10:02 : Add a paremeter "targetLocation" to the URL. Management of "close button" in CATIA (popup)
*@quickreview LX6 QYG 12:10:02 : IR-203122V6R2014  NHI R215-036266 : UseCase and Test case are not taken in account While doing Copy with Link. 
 --%>
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under
      respective scriplet
     @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
     @quickreview T25 OEP 24 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are removed at some scriplet.
     @quickreview JX5 QYG 03 Jun 2013  IR-221981V6R2014x Sub Requirement and Derived Requirement is not translated
     @quickreview T25 DJH 13:10:25  :  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
     @quickreview HAT1 ZUD 14:06:05 :  IR-158681V6R2015 - ST: Special character in "Revision" field are allowed on "Copy Requirement" and "Edit Requirement Specification" form.
     @quickreview HAT1 ZUD 14:06:27 :  ReCorrection IR-158681V6R2015 - ST: Special character in "Revision" field are allowed on "Copy Requirement" and "Edit Requirement Specification" form.
     @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
     @quickreview QYG      15:06:24  IR-380848-3DEXPERIENCER2016x fix close button.
	 @quickreview ZUD      16:11:17  IR-478884-3DEXPERIENCER2018x:R419-STP: Inconsistency in"duplication string" while duplicating structure from Wintop & webtop.
	 @quickreview KIE1 ZUD 23:08:17 :IR-543286-3DEXPERIENCER2018x: duplicate command not using autonaming
--%>
<%-- Include file for error handling --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%-- Common Includes --%>

<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "GlobalSettingInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@page import = "com.dassault_systemes.requirements.ReqConstants"%>

<%@page import="com.matrixone.apps.productline.ProductLineCommon" %>
<%@page import="com.matrixone.apps.productline.ProductLineUtil" %>
<%@page import="com.matrixone.apps.productline.ProductLineConstants" %>
<%@page import="com.matrixone.apps.requirements.RequirementsCommon" %>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants" %>
<%@page import="com.matrixone.apps.domain.DomainObject" %>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>
<%@page import="com.dassault_systemes.requirements.UnifiedAutonamingServices" %>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
  <script language="javascript" type="text/javaScript">
 var options = new Array();
 </script>

<%
String fromWebApp = "";
try{
        String strBaseType = ReqSchemaUtil.getRequirementType(context);
                String strReload = emxGetParameter(request,"ReloadTrue");
                String strObjectId = emxGetParameter(request,"objectId");
                String strMode = emxGetParameter(request,"PRCFSParam2");
                String strRequirementName = emxGetParameter(request,"txtRequirementName");
                String strAutoName = emxGetParameter(request,"chkAutoName");
                String strRequirementType = emxGetParameter(request,"txtReqActualType");
                String strSourceReqType = emxGetParameter(request,"sourceType");
                String strRequirementRevision = emxGetParameter(request,"txtRequirementRevision");
                String strRequirementDescription = emxGetParameter(request,"txtRequirementDescription");
                String strRequirementPolicy = emxGetParameter(request,"txtRequirementPolicy");
                String options = emxGetParameter(request,"options");
                String strTitle = emxGetParameter(request,"txtTitle"); // Add for R210
                String strLocale = context.getSession().getLanguage();
                String strRequirementCopyofName = null;
                
             	// ++ HAT1 ZUD: IR-640730-3DEXPERIENCER2019x  ++
            	
            	fromWebApp = (String) emxGetParameter(request, ReqConstants.FROM_WEB_APP);
            	if(fromWebApp.equals(""))
            	{
            		fromWebApp += "";
            	}
        		// -- HAT1 ZUD: IR-640730-3DEXPERIENCER2019x  --
                		
                		
                String locale = request.getLocale().toString();
                
        		boolean isPlmParameterAvailable = true;
        		String relationshipProperty = "";
      			//LX6: Set Parametrized requirements as a GA feature : suppresion of isParameterersInstalled test
       			//To use PlmParameterType,
        		//START IR-203122V6R2014  NHI R215-036266 : UseCase and Test case are not taken in account While doing Copy with Link.
       			relationshipProperty = EnoviaResourceBundle.getProperty(context, "emxRequirements.CloneTypes.relationship_RequirementWithParameters");               
       		 //END IR-203122V6R2014  NHI R215-036266 : UseCase and Test case are not taken in account While doing Copy with Link.
            String[] symbolicTypes = relationshipProperty.split("[,]");
                
        if(strReload == null || "".equals(strReload) || "null".equalsIgnoreCase(strReload))
        {
                if (strMode.equalsIgnoreCase("DetailsPage"))
                {
                        strObjectId = emxGetParameter(request,"objectId");
                }
                else
                {
                        //extract Table Row ids of the checkbox selected.
            String[] arrTableRowId = emxGetParameterValues(request,"emxTableRowId");
                        String[] arrObjectId = null;
            if (arrTableRowId[0].indexOf("|") >= 0 )
            {
                arrObjectId = (String[])ProductLineUtil.getObjectIds(arrTableRowId);
                                strObjectId = arrObjectId[0];
                        }
                        else {
                                strObjectId = arrTableRowId[0];
                        }
                }

                DomainObject sourceRequirement = DomainObject.newInstance(context,strObjectId);

                StringList lstObjSelects = new StringList();
                lstObjSelects.add(DomainConstants.SELECT_NAME);
                lstObjSelects.add(DomainConstants.SELECT_TYPE);
                lstObjSelects.add(DomainConstants.SELECT_REVISION);
                lstObjSelects.add(DomainConstants.SELECT_DESCRIPTION);
                lstObjSelects.add(DomainConstants.SELECT_POLICY);
                lstObjSelects.add(ReqSchemaUtil.getTitleAttribute(context)); // Added For R210
                
                Map mapAttributeValues = sourceRequirement.getInfo(context,lstObjSelects);

                strRequirementName = (String)mapAttributeValues.get(DomainConstants.SELECT_NAME);
                strRequirementType = (String)mapAttributeValues.get(DomainConstants.SELECT_TYPE);
                strSourceReqType = (String)mapAttributeValues.get(DomainConstants.SELECT_TYPE);
                strRequirementDescription = (String)mapAttributeValues.get(DomainConstants.SELECT_DESCRIPTION);
                strRequirementPolicy = (String)mapAttributeValues.get(DomainConstants.SELECT_POLICY);
                strRequirementRevision = RequirementsCommon.getDefaultRevision(context, sourceRequirement, strRequirementPolicy);
                // Added For R210
                String strTitleQuery = "print bus $1 select $2 dump $3";
                strTitle = MqlUtil.mqlCommand(context, strTitleQuery, strObjectId, "attribute[Title]", "|");
        }
        //Start:oep
        String sStrResName = emxGetParameter(request, "StringResourceFileId");
        String sLanguage = request.getHeader("Accept-Language");
        String suiteKey = (String)emxGetParameter(request,"suiteKey");
        if (suiteKey == null) {
            suiteKey = "eServiceSuiteProgramCentral";
        }
        else {
            if (!suiteKey.startsWith("eServiceSuite")) {
              suiteKey = "eServiceSuite" + suiteKey;    
            }    
        }
        if (sStrResName == null) {
               sStrResName = EnoviaResourceBundle.getProperty(context, suiteKey + ".StringResourceFileId");
                  
              }
        String copyOf =  EnoviaResourceBundle.getProperty(context, sStrResName, context.getLocale(), "emxRequirements.ImportStructure.Prefix.Default");
	//strRequirementCopyofName = copyOf.trim()+" "+strRequirementName;
		// KIE1 Added for Autonaming
    	if(strBaseType.startsWith("type_")){
    		strBaseType = PropertyUtil.getSchemaProperty(context, strBaseType);
		}
    	String strReqName = UnifiedAutonamingServices.autoname(context, strBaseType);
	strTitle = copyOf.trim()+" "+strTitle;
        
        //End:oep
        String strReqTypeDisplay = i18nNow.getTypeI18NString(strRequirementType, strLocale);

%>

        <%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
    
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%><form name="RequirementCopy" action=submit() method="post" onsubmit="submitForm(); return false">
<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="sourceType" value="<xss:encodeForHTMLAttribute><%=strSourceReqType%></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="defaultRevision" value="<xss:encodeForHTMLAttribute><%=strRequirementRevision%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="PRCFSParam1" value="<xss:encodeForHTMLAttribute><%=strMode%></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="ReloadTrue" value="true" />


      <table border="0" cellpadding="5" cellspacing="2" width="100%">
      <%-- Display the input fields. --%>

      <input type="hidden" name="strAutoNamer" value="<xss:encodeForHTMLAttribute><%=strAutoNamer%></xss:encodeForHTMLAttribute>" />
<%
    if (strAutoNamer.equalsIgnoreCase("False") || strAutoNamer.equalsIgnoreCase("") )
    {
    	strAutoNamer = "False";
%>

      <tr>
        <td width="150" nowrap="nowrap" class="labelRequired">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Name
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtRequirementName" size="20" value="<xss:encodeForHTMLAttribute><%=strReqName%></xss:encodeForHTMLAttribute>" readonly />
          &nbsp;
<%
                if (strAutoNamer.equalsIgnoreCase(""))
                {
                        if (strAutoName!=null && !strAutoName.equals("") && !"null".equalsIgnoreCase(strAutoName))
                        {
%>
                        <!-- <input type="checkbox" name="chkAutoName" checked = true onclick="nameDisabled();" />
                        <emxUtil:i18n localize="i18nId">emxRequirements.Form.Label.Autoname</emxUtil:i18n> --!>
<%
                        }else {
%>
                       <!-- <input type="checkbox" name="chkAutoName" onclick="nameDisabled();" />
                        <emxUtil:i18n localize="i18nId">emxRequirements.Form.Label.Autoname</emxUtil:i18n> --!>
<%
                        }
                }
%>
        </td>
      </tr>

<%

    }   else{

%>
      <input type="hidden" name="txtRequirementName" value="" />


<%
                        }
%>
      <tr>
        <td width="150" nowrap="nowrap" class="label">
           <emxUtil:i18n localize="i18nId">
             emxFramework.Basic.Type
           </emxUtil:i18n>
        </td>

         <td class="field">
            <xss:encodeForHTML><%=strReqTypeDisplay%></xss:encodeForHTML>
               <input type="hidden" name="txtReqActualType" value="<xss:encodeForHTMLAttribute><%= strRequirementType %></xss:encodeForHTMLAttribute>" />
         </td>

     </tr>
     
     <!--  Title Field -->
      <tr>
        <td width="150"  class="label" >
          <emxUtil:i18n localize="i18nId">
            emxFramework.Attribute.Title
          </emxUtil:i18n>
        </td>
        <td  class="field">
          <input type="text" name="txtTitle" value="<xss:encodeForHTMLAttribute><%=strTitle%></xss:encodeForHTMLAttribute>" /> 
                  
        </td>
      </tr>


          <tr>
        <td width="150" nowrap="nowrap" class="labelRequired">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Revision
          </emxUtil:i18n>
        </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtRequirementRevision" size="20" value="<xss:encodeForHTMLAttribute><%=strRequirementRevision%></xss:encodeForHTMLAttribute>" />
        </td>
      </tr>
      <tr>
        <td width="150" class="label" >
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Description
          </emxUtil:i18n>
        </td>
        <td  class="field">
          <textarea name="txtRequirementDescription" rows="5" cols="25"><xss:encodeForHTML><%=strRequirementDescription%></xss:encodeForHTML></textarea>
        </td>
      </tr>

         
          
         
<%
        for(int i = 0; i < symbolicTypes.length; i++){
            String symbolicType = symbolicTypes[i].trim();
            String realType = PropertyUtil.getSchemaProperty(context,symbolicType);
            // JX5 : Start IR-221981V6R2014x Sub Requirement and Derived Requirement is not translated
            StringBuffer text = new StringBuffer(80);
            if(symbolicType.contains("relationship"))
            {
            	text.append("emxFramework.Relationship.");
            }
            else{
            	text.append("emxFramework.Type.");
            }
            text.append(realType);
        	String i18nTypeKey =  text.toString().replace(' ', '_');
        	String i18nType = "";
        	if(realType.equalsIgnoreCase(RequirementsUtil.getParameterType(context))){
        		i18nType = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Duplicate."+realType);
        	}else{
        		i18nType = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), i18nTypeKey);
        	}
            // JX5 : End IR-221981V6R2014x Sub Requirement and Derived Requirement is not translated
            String action = EnoviaResourceBundle.getProperty(context, "emxRequirements.CloneTypes." + symbolicType + ".Default");
            if(action == null || action.trim().length() == 0){
                action = "Copy";
            }

 %>
      <tr>
        <td width="200" class="label" >
            <xss:encodeForHTML><%=i18nType%></xss:encodeForHTML>
        </td>
        <td  class="inputField">
          <input type="radio"  name="<xss:encodeForHTMLAttribute><%=symbolicType%></xss:encodeForHTMLAttribute>" value="Copy" <%="Copy".equalsIgnoreCase(action) ? "checked" : "" %> /><emxUtil:i18n localize="i18nId">emxRequirements.Label.CopyReqSpec</emxUtil:i18n>
          <input type="radio"  name="<xss:encodeForHTMLAttribute><%=symbolicType%></xss:encodeForHTMLAttribute>" value="Reference" <%="Reference".equalsIgnoreCase(action) ? "checked" : "" %> /><emxUtil:i18n localize="i18nId">emxRequirements.ImportStructure.Label.Reference</emxUtil:i18n>
          <input type="radio"  name="<xss:encodeForHTMLAttribute><%=symbolicType%></xss:encodeForHTMLAttribute>" value="None" <%="None".equalsIgnoreCase(action) ? "checked" : "" %> /><emxUtil:i18n localize="i18nId">emxRequirements.ImportStructure.Label.None</emxUtil:i18n>
        </td>
      </tr>
<script language="javascript" type="text/javaScript">
    options.push(document.RequirementCopy.<xss:encodeForJavaScript><%=symbolicType%></xss:encodeForJavaScript>);
</script>

<%
        }
 %>
    <tr>
        <td width="200" class="label" >
                <emxUtil:i18n localize="i18nId">emxRequirements.ImportStructure.Label.CopyWithLink</emxUtil:i18n> 
        </td>
       	<td class="inputField">
	    	<input type="checkbox" name="CopyWithLink" checked>
	        <emxUtil:i18n localize="i18nId">emxRequirements.Label.CreateCopyRelation</emxUtil:i18n>
	    </td>
    </tr>	
  </table>
      
    </form>
<%

}
        catch(Exception e)
        {
                        out.println(e);
        }

        %>

<%@include file = "emxValidationInclude.inc" %>
        <script language="javascript" type="text/javaScript">
        
  //<![CDATA[
    var  formName = document.RequirementCopy;

    //if Autoname field is checked, focus goes to Revision field
    function valueCheck()
    {
      if (<xss:encodeForJavaScript><%=strAutoNamer.equals("")%></xss:encodeForJavaScript> == true)
      {
          if (formName.chkAutoName.checked)
          {
             formName.txtRequirementName.blur();
          }
      }
    }

    //For disabling the name field if autoname is checked
    function nameDisabled()
    {
      if (<xss:encodeForJavaScript><%=strAutoNamer.equals("")%></xss:encodeForJavaScript> == true)
      {
        if (formName.chkAutoName.checked)
        {
          formName.txtRequirementName.value="";
          formName.chkAutoName.value="true";

          formName.txtRequirementRevision.focus();
        }else
        {
          formName.txtRequirementName.focus();
        }
      }
    }


          // When "Enter" is pressed in the Copy Dialog page

        function submitForm()
        {
                submit();
        }

        // When "Done" button is pressed in the Copy Dialog page

        function submit()
    {

      //Validation for Required field,Length and Bad characters for Name
          var iValidForm = true;
      if (!(<%=strAutoNamer.equalsIgnoreCase("True")%> == true))<%--XSSOK--%>
      {
        if (<%=strAutoNamer.equalsIgnoreCase("False")%> == true)<%--XSSOK--%>
        {
          if (iValidForm)
          {
            var fieldName = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxFramework.Basic.Name")%> ";
            var field = formName.txtRequirementName;
            iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);
          }
        }else
        {
          if (!formName.chkAutoName.checked)
          {
            if (iValidForm)
            {
              var fieldName = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxFramework.Basic.Name")%> ";
              var field = formName.txtRequirementName;
              iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);
            }
          }
        }
      }

      // Begin of Add by Enovia MatrixOne for Bug # 300597 Date 03/22/2005
          //Validation for Required field, field Length and Bad characters for Revision
          if (iValidForm)
      {
        var fieldName = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxFramework.Basic.Revision")%> ";
        var field = formName.txtRequirementRevision;
        
        //Start IR-158681V6R2015  HAT1 ZUD - validateRevision() is called instead of basicValidation().
        //iValidForm = basicValidation(formName,field,fieldName,true,false,true,false,false,false,false);
        
        var charArray = "<%=EnoviaResourceBundle.getProperty(context,"emxFramework.CustomTable.NameBadChars")%>";

        var alertBadChar = "<%=EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Alert.RemoveInvalidChars")%>";
        
        iValidForm = validateRevision(field, fieldName, alertBadChar, charArray);
        
        //End IR-158681V6R2015  HAT1 ZUD  
      }
      // End of Add by Enovia MatrixOne for Bug # 300597 Date 03/22/2005

          //Validation for Required field for Type

          // Validation for Special characters for Description field

          if (iValidForm)
      {

                var fieldName = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxFramework.Basic.Description")%> ";
        var field = formName.txtRequirementDescription;
        iValidForm = basicValidation(formName,field,fieldName,false,false,false,false,false,false,checkBadChars);
      }

          // If Validation Fails
          if (!iValidForm)
      {
        return ;
      }

      //Submit the form to RequirementUtil.jsp
      formName.action="../requirements/RequirementUtil.jsp?mode=copy";
      formName.action += "&options="; 
      formName.action += "CopyWithLink:" + document.RequirementCopy.CopyWithLink.checked.toString() + ";"; 
      // HAT1 ZUD: IR-640730-3DEXPERIENCER2018x 
      formName.action += "<xss:encodeForJavaScript><%=ReqConstants.FROM_WEB_APP%></xss:encodeForJavaScript>:<xss:encodeForJavaScript><%=fromWebApp%></xss:encodeForJavaScript>;";
      formName.target = "jpcharfooter";
      
      for(var i = 0; i < options.length; i++){
          var option = options[i];
          for(var j = 0; j < option.length; j++){
              if(option[j].checked){
                  switch (j){
                      case 0: 
                          document.RequirementCopy.action += option[j].name + "=" + "Copy;";
                          break;
                      case 1:
                          document.RequirementCopy.action += option[j].name + "=" + "Reference;";
                          break;
                      case 2:
                          document.RequirementCopy.action += option[j].name + "=" + "None;";
                          break;
                  }
                  break;
              }
          }
      }
     

      //To display the Progress clock
        parent.turnOnProgress(); 

          if (jsDblClick())
          {
                        formName.submit();
          }

        }



        </script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="javascript" type="text/javaScript">
//when 'Cancel' button is pressed in Dialog Page
function closeWindow()
{
	<%
    //JX5 : Add a Parameter to the URL for closure in CATIA
    String strTargetLocation = emxGetParameter(request,"targetLocation");
	%>
	
    //Releasing Mouse Events
		if (<xss:encodeForJavaScript><%=strTargetLocation.equalsIgnoreCase("popup")%></xss:encodeForJavaScript>)
		{
	 //KIE1 ZUD TSK447636 
			parent.closeWindow();
		}
		else 
		{
			getTopWindow().closeSlideInDialog();	
		}
     
}

function closeSlideInDialog(){

	getTopWindow().closeSlideInDialog();	
}

</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>



