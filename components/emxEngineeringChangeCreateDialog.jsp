<%--  emxEngineeringChangeCreateDialog.jsp

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxEngineeringChangeCreateDialog.jsp.rca 1.14 Tue Oct 28 23:01:04 2008 przemek Experimental przemek $";

--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%-- Common Includes --%>

<%@include file = "emxComponentsCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxEngineeringChangeGlobalSettingInclude.inc"%>


<%@page import  = "com.matrixone.apps.domain.DomainConstants,com.matrixone.apps.domain.DomainRelationship"%>
<%@page import  = "com.matrixone.apps.common.EngineeringChange"%>
<%@page import  = "com.matrixone.apps.domain.util.i18nNow"%>

<%

    //to store the Tree Id
    String strTreeId    = null;
    //to store the Suite Directory
    String strSuiteKey  = null;
    //to store the 'Type' of the Parent object
    String strType      = "";
    //to store the parent id
    String busId        = null;
    //To set the default type to be created using this page
    String strBaseType = "";
    String strFunctionality = null;
    String strOpenerFrame   = null;
    String strSrcDestRelName = null;
    String strConnectAtFrom = null;
    String strEmxTableRowId = null;
    String strMultipleTableRowId = null;
    String strInclusionType = null;
    String key = null;

    try {
        //Retrieves Parent ObjectId in context
        busId                   = emxGetParameter(request, "objectId");
        strTreeId               = emxGetParameter(request, "jsTreeID");
        strSuiteKey             = emxGetParameter(request, "suiteKey");
        strFunctionality        = emxGetParameter(request, "functionality");
        strSrcDestRelName       = emxGetParameter(request, "srcDestRelName");
        strConnectAtFrom        = emxGetParameter(request, "connectAtFrom");
        strEmxTableRowId        = emxGetParameter(request, "emxTableRowId");
        strOpenerFrame          = emxGetParameter(request, "portalCmdName");
        //START:OEP:2013x:IR-174856V6R2013x
        if(strEmxTableRowId ==  null){
        	key = emxGetParameter(request, "key"); 
    		if(key != null){ 
    	  		 strEmxTableRowId = (String)session.getAttribute(key);
    		}
        }
        //END:OEP:2013x:IR-174856V6R2013x
        
        strMultipleTableRowId   = emxGetParameter(request, "multipleTableRowId");

        String[] arrAttributeRanges = new String[3];
        arrAttributeRanges[0]                = DomainConstants.ATTRIBUTE_VALIDATION_REQUIRED;
        arrAttributeRanges[1]                = DomainConstants.ATTRIBUTE_CATEGORY_OF_CHANGE;
        arrAttributeRanges[2]                = DomainConstants.ATTRIBUTE_SEVERITY;

        Map attrRangeMap                     = EngineeringChange.getAttributeChoices(context,arrAttributeRanges);


        MapList attrMapListValidationRequired   = (MapList) attrRangeMap.get(arrAttributeRanges[0]);
        MapList attrMapListCategoryOfChange  = (MapList) attrRangeMap.get(arrAttributeRanges[1]);
        MapList attrMapListSeverity          = (MapList) attrRangeMap.get(arrAttributeRanges[2]);

        //Getting the default range values
        HashMap mapDefaultAttributeValue     = (HashMap) ((MapList) attrRangeMap.get(EngineeringChange.DEFAULT_ATTRIBUTES)).get(0);

        //Getting the default range value of Validation Required.
        String strValidationRequiredDefault     = (String)mapDefaultAttributeValue.get(arrAttributeRanges[0]);

        //Getting the default range value of Category Of Change.
        String strCategoryOfChangeDefault    = (String)mapDefaultAttributeValue.get(arrAttributeRanges[1]);
        strCategoryOfChangeDefault           = i18nNow.getRangeI18NString(arrAttributeRanges[1], strCategoryOfChangeDefault, acceptLanguage);
        //Getting the Internationalized values for Category Of Change.
        attrMapListCategoryOfChange          = EngineeringChange.getI18nValues(attrMapListCategoryOfChange, arrAttributeRanges[1], acceptLanguage);

        //Getting the default range value of Severity.
        String strSeverityDefault            = (String)mapDefaultAttributeValue.get(arrAttributeRanges[2]);
        strSeverityDefault                   = i18nNow.getRangeI18NString(arrAttributeRanges[2], strSeverityDefault, acceptLanguage);
        //Getting the Internationalized values for Severity.
        attrMapListSeverity                  = EngineeringChange.getI18nValues(attrMapListSeverity, arrAttributeRanges[2], acceptLanguage);


        strBaseType               = DomainConstants.TYPE_ENGINEERING_CHANGE;
        String strLocale          = context.getSession().getLanguage();
        String strDisplayBaseType = i18nNow.getTypeI18NString(strBaseType, strLocale);
        MapList policyList        = com.matrixone.apps.domain.util.mxType.getPolicies(context,strBaseType,false);
        
        // Modofied for the bug#IR-014390       
        strInclusionType = (String)DomainRelationship.getAllowedTypes(context, DomainConstants.RELATIONSHIP_REPORTED_AGAINST_EC,true,false).get(DomainRelationship.KEY_INCLUDE);
       // FrameworkProperties.getProperty("eServiceSuiteComponents.ECCreateFSInstance.ReportedAgainst.IncludeTypes")
%>

<!-- Autonomy search integration -->
<script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script>  

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>


        <form name="EngineeringChangeCreate"  method="post" onsubmit="submitForm(); return false" >
        <%@include file = "../common/enoviaCSRFTokenInjection.inc" %>
        <input type="hidden" name="busId" value="<%=busId%>"/>
        <input type="hidden" name="functionality" value="<xss:encodeForHTMLAttribute><%=strFunctionality%></xss:encodeForHTMLAttribute>"/>
        <input type="hidden" name="srcDestRelName" value="<xss:encodeForHTMLAttribute><%=strSrcDestRelName%></xss:encodeForHTMLAttribute>"/>
        <input type="hidden" name="connectAtFrom" value="<xss:encodeForHTMLAttribute><%=strConnectAtFrom%></xss:encodeForHTMLAttribute>"/>
        <input type="hidden" name="multipleTableRowId" value="<%=strMultipleTableRowId%>"/>
        <input type="hidden" name="emxTableRowId" value="<%=strEmxTableRowId%>"/>
        <input type="hidden" name="openerFrame" value="<xss:encodeForHTMLAttribute><%=strOpenerFrame%></xss:encodeForHTMLAttribute>"/>
        <table border="0" cellpadding="5" cellspacing="2" width="100%">
        <!-- Display the input fields. -->

<%
        /*
         *This logic defines if the name field is to be made visible to the user or not
         *These setting are based on the global settings for each module made in the
         *application property file.
         */
%>
        <input type="hidden" name="strAutoNamer" value="<xss:encodeForHTMLAttribute><%=strAutoNamer%></xss:encodeForHTMLAttribute>" />
<%
        if (strAutoNamer.equalsIgnoreCase("False") || strAutoNamer.equalsIgnoreCase(DomainConstants.EMPTY_STRING) ) {
%>
            <tr>
                <td width="150" nowrap="nowrap" class="labelRequired">
                    <framework:i18n localize="i18nId">
                        emxFramework.Basic.Name
                    </framework:i18n>
                </td>
                <td nowrap="nowrap" class="field">
                    <input type="text" name="txtECName" size="20" onFocus="valueCheck()"/>
                    &nbsp;
<%
                if (strAutoNamer.equalsIgnoreCase(DomainConstants.EMPTY_STRING)) {
%>
                    <input type="checkbox" name="chkAutoName" onclick="nameDisabled()"/><emxUtil:i18n localize="i18nId">emxComponents.Common.AutoName</emxUtil:i18n>
<%
                }
%>
                </td>
            </tr>
<%

        } else {
%>
            <input type="hidden" name="txtECName" value=""/>
<%
        }
%>

            <tr>
                <td width="150" nowrap="nowrap" class="labelRequired">
                    <framework:i18n localize="i18nId">
                        emxFramework.Basic.Type
                    </framework:i18n>
                </td>
                <td nowrap="nowrap" class="field">
                    <input type="text" name="txtECType" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%= strDisplayBaseType %></xss:encodeForHTMLAttribute>" />
                    <input class="button" type="button" name="btnType" size="200" value="..." alt=""  onClick="javascript:showTypeSelector();"/>
                    <input type="hidden" name="txtSelectedTypeName" value="<xss:encodeForHTMLAttribute><%= strBaseType %></xss:encodeForHTMLAttribute>"/>
                </td>
            </tr>

            <tr>
                <td width="150" class="labelRequired">
                    <framework:i18n localize="i18nId">
                        emxFramework.Basic.Description
                    </framework:i18n>
                </td>
                <td class="field">
                    <textarea name="txtECDescription" rows="5" cols="25" ></textarea>
                </td>
            </tr>

            <tr>
                <td width="150" nowrap="nowrap" class="label">
                    <framework:i18n localize="i18nId">
                        emxFramework.Attribute.ValidationRequiredFlag
                    </framework:i18n>
                </td>
                <td nowrap="nowrap" class="field">
<%
                //size of the ranges in the attribute
                int iListSize = attrMapListValidationRequired.size();
                for ( int iCount = 0; iCount < iListSize; iCount++ ) {
                    //get the ValidationRequiredFlag Value from the attribute maplist
                    String strValueValidationRequired = ((String)((HashMap)attrMapListValidationRequired.get(iCount)).get("name"));

                    //if the Validation Required Flag value is not default
                    if (! strValueValidationRequired.equals (strValidationRequiredDefault)) {
%>
                        <input type="radio" name="radECValidationRequired" size="20" value=<xss:encodeForHTMLAttribute><%=strValueValidationRequired%></xss:encodeForHTMLAttribute> /><%=i18nNow.getRangeI18NString(DomainConstants.ATTRIBUTE_VALIDATION_REQUIRED,strValueValidationRequired,request.getHeader("Accept-Language"))%><br>
<%
                    } else if (strValueValidationRequired.equals (strValidationRequiredDefault)) {
                      //if the Validation Required Flag value is the default
%>
                        <input type="radio" name="radECValidationRequired" size="20" value=<xss:encodeForHTMLAttribute><%=strValueValidationRequired%></xss:encodeForHTMLAttribute> checked /><%=i18nNow.getRangeI18NString(DomainConstants.ATTRIBUTE_VALIDATION_REQUIRED,strValueValidationRequired,request.getHeader("Accept-Language"))%>
<%
                    }
                }//end of for
%>
                </td>
            </tr>

            <tr>
                <td width="150" class="label" width="200" align="left">
                    <framework:i18n localize="i18nId">
                        emxFramework.Attribute.CategoryOfChange
                    </framework:i18n>
                </td>
                <td class="field">
                    <select name="lstECCategoryOfChange">
					<!-- //XSSOK -->
                        <framework:optionList optionMapList="<%= attrMapListCategoryOfChange%>" optionKey="<%= DomainConstants.SELECT_NAME%>" valueKey="<%=EngineeringChange.VALUE%>" selected = "<%=strCategoryOfChangeDefault%>"/>
                    </select>
                </td>
            </tr>

            <tr>
                <td width="150" nowrap="nowrap" class="label">
                    <framework:i18n localize="i18nId">
                        emxComponents.Form.Label.ReportedAgainst
                    </framework:i18n>
                </td>
                <td nowrap="nowrap" class="field">
                    <input type="text" name="txtECReportedAgainst" size="20" value="" readonly="readonly"/>
                    <input class="button" type="button" name="btnECReportedAgainstChooser" size="200" value="..." alt=""  onClick="javascript:showECReportedAgainst();"/>
                    <input type="hidden" name="HiddenECReportedAgainst" size="20" value=""/>
                    <a name="ancClear" href="#ancClear" class="dialogClear" onclick="document.EngineeringChangeCreate.txtECReportedAgainst.value='';document.EngineeringChangeCreate.HiddenECReportedAgainst.value=''"><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
                </td>
            </tr>

            <tr>
                <td width="150" nowrap="nowrap" class="label">
                    <framework:i18n localize="i18nId">
                        emxComponents.Common.DistributionList
                    </framework:i18n>
                </td>
                <td nowrap="nowrap" class="field">
                    <input type="text" name="txtECDistributionList" size="20" value="" readonly="readonly"/>
                    <input class="button" type="button" name="btnECDistributionListChooser" size="200" value="..." alt=""  onClick="javascript:showECDistributionList();"/>
                    <input type="hidden" name="HiddenECDistributionList" size="20" value=""/>
                    <a name="ancClear" href="#ancClear" class="dialogClear" onclick="document.EngineeringChangeCreate.txtECDistributionList.value='';document.EngineeringChangeCreate.HiddenECDistributionList.value=''"><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
                </td>
            </tr>

            <tr>
                <td width="150" nowrap="nowrap" class="label">
                    <framework:i18n localize="i18nId">
                        emxComponents.Form.Label.ReviewerList
                    </framework:i18n>
                </td>
                <td nowrap="nowrap" class="field">
                    <input type="text" name="txtECReviewerList" size="20" value="" readonly="readonly"/>
                    <input class="button" type="button" name="btnECReviewerListChooser" size="200" value="..." alt=""  onClick="javascript:showECReviewerList();"/>
                    <input type="hidden" name="HiddenECReviewerList" size="20" value=""/>
                    <a name="ancClear" href="#ancClear" class="dialogClear" onclick="document.EngineeringChangeCreate.txtECReviewerList.value='';document.EngineeringChangeCreate.HiddenECReviewerList.value=''"><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
                </td>
            </tr>

            <tr>
                <td width="150" nowrap="nowrap" class="label">
                    <framework:i18n localize="i18nId">
                        emxComponents.Form.Label.ApprovalList
                    </framework:i18n>
                </td>
                <td nowrap="nowrap" class="field">
                    <input type="text" name="txtECApprovalList" size="20" value="" readonly="readonly"/>
                    <input class="button" type="button" name="btnECApprovalListChooser" size="200" value="..." alt=""  onClick="javascript:showECApprovalList();"/>
                    <input type="hidden" name="HiddenECApprovalList" size="20" value=""/>
                    <a name="ancClear" href="#ancClear" class="dialogClear" onclick="document.EngineeringChangeCreate.txtECApprovalList.value='';document.EngineeringChangeCreate.HiddenECApprovalList.value=''"><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
                </td>
            </tr>

            <tr>
                <td width="150" class="label" width="200" align="left">
                    <framework:i18n localize="i18nId">
                        emxFramework.Attribute.Severity
                </framework:i18n>
                </td>
                <td class="field">
                    <select name="lstECSeverity">
						<!-- //XSSOK -->
                        <framework:optionList optionMapList="<%= attrMapListSeverity%>" optionKey="<%= DomainConstants.SELECT_NAME%>" valueKey="<%=EngineeringChange.VALUE%>" selected = "<%=strSeverityDefault%>"/>
                    </select>
                </td>
            </tr>
<%
            /*
             *This logic defines the Policy combo to be made visible to the user
             */

            HashMap mapPolicyList = EngineeringChange.getI18NPolicyList(context,strBaseType,acceptLanguage);
            StringList policyValueList = (StringList)mapPolicyList.get(EngineeringChange.VALUE);
            if (bPolicyAwareness) {
                StringList il18NPolicyList = (StringList)mapPolicyList.get(DomainConstants.SELECT_NAME);
                String strPolicyName="";
                int intListSize=policyValueList.size();
%>

                <tr>
                    <td width="150" class="label" valign="top">
                        <emxUtil:i18n localize="i18nId">
                            emxFramework.Basic.Policy
                        </emxUtil:i18n>
                    </td>
<%              if (intListSize>1) {
%>
                    <td class="inputField">
                        <select name="txtECPolicy">
<%
                    for (int i=0;i<intListSize;i++) {
                        strPolicyName = (String) policyValueList.get(i);
                        String policySymbName = FrameworkUtil.getAliasForAdmin(context, "policy", (String)il18NPolicyList.get(i), true);
                        if(strPolicyName.equals(EngineeringChange.POLICY_ENGINEERING_CHANGE_STANDARD)) {
%>
                            <option value="<xss:encodeForHTMLAttribute><%=policySymbName%></xss:encodeForHTMLAttribute>" selected><xss:encodeForHTML><%=il18NPolicyList.get(i)%></xss:encodeForHTML> </option>

<%
                        } else {
%>
                            <option value="<xss:encodeForHTMLAttribute><%=policySymbName%></xss:encodeForHTMLAttribute>"><xss:encodeForHTML><%=il18NPolicyList.get(i)%></xss:encodeForHTML> </option>
<%
                        }
                    }
%>
                        </select>
                    </td>
                </tr>
<%
                }
                if(intListSize==1) {
%>
                    <td class="field">
                        <xss:encodeForHTMLAttribute><%=il18NPolicyList.get(0)%></xss:encodeForHTMLAttribute>
                        <input type="hidden" name="txtECPolicy" value="<%=EngineeringChange.POLICY_ENGINEERING_CHANGE_STANDARD%>"/>
                    </td>
                </tr>

<%
                }
            } else {
%>
                <input type="hidden" name="txtECPolicy" value="<%=EngineeringChange.POLICY_ENGINEERING_CHANGE_STANDARD%>"/>
<%
            }
            if(bShowVault) {
%>
                <tr>
                    <td width="150" class="label" valign="top">
                        <framework:i18n localize="i18nId">
                            emxFramework.Basic.Vault
                        </framework:i18n>
                    </td>
                    <td class="field">
                        <input type="text" name="txtECVaultDisplay" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strUserVaultDisplay%></xss:encodeForHTMLAttribute>"/>
                        <input type="hidden" name="txtECVault" size="15" value="<xss:encodeForHTMLAttribute><%=strUserVault%></xss:encodeForHTMLAttribute>"/>
                        <input class="button" type="button" name="btnVault" size="200" value="..." alt=""  onClick="javascript:showVaultSelector();"/>&nbsp;
                        <a name="ancClear" href="#ancClear" class="dialogClear" onclick="document.EngineeringChangeCreate.txtECVault.value='';document.EngineeringChangeCreate.txtECVaultDisplay.value=''"><emxUtil:i18n localize="i18nId">emxComponents.Common.Clear</emxUtil:i18n></a>
                    </td>
                </tr>
<%
            } else {
%>
                <input type="hidden" name="txtECVault" value="<%=strUserVault%>"/>
<%
            }
            
          //START:OEP:2013x:IR-174856V6R2013x. Removing from session
            if(key!= null){
    			session.removeAttribute(key);
    		}
          //END:OEP:2013x:IR-174856V6R2013x
            
    }catch(Exception ex){
        session.putValue("error.message", ex.getMessage());
    }
%>
<%@include file = "emxValidationInclude.inc" %>
   <script language="javascript" type="text/javaScript">
       var  formName = document.EngineeringChangeCreate;
       var  autoNameValue = "<%= strAutoNamer %>";

       //if Autoname field is checked, focus goes to Description field
       function valueCheck()
       {
           if (autoNameValue == "<%=DomainConstants.EMPTY_STRING%>")
           {
               if (formName.chkAutoName.checked)
               {
                   formName.txtECName.blur();
               }
           }
       }

       //for disabling the name field if autoname is checked
       function nameDisabled()
       {
           if (autoNameValue == "<%=DomainConstants.EMPTY_STRING%>")
           {
               if (formName.chkAutoName.checked)
               {
                   formName.txtECName.value = "<%=DomainConstants.EMPTY_STRING%>";
                   formName.chkAutoName.value = "true";
                   formName.txtECDescription.focus();
               } else {
                   formName.txtECName.focus();
               }
           }
       }

       //validates dialog form for required fields
       function validateForm()
       {
           var iValidForm = true;
           //XSSOK
           if(!(<%=strAutoNamer.equalsIgnoreCase("True")%>))
           {
        	   //XSSOK
               if(<%=strAutoNamer.equalsIgnoreCase("False")%>)
               {
                   if (iValidForm)
                   {
                       var fieldName = "<%=i18nNow.getI18nString("emxFramework.Basic.Name", bundle,acceptLanguage)%> ";
                       var field = formName.txtECName;
                       iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);
                   }
               } else {
                   if (!formName.chkAutoName.checked)
                   {
                       if (iValidForm)
                       {
                           var fieldName = "<%=i18nNow.getI18nString("emxFramework.Basic.Name", bundle,acceptLanguage)%> ";
                           var field = formName.txtECName;
                           iValidForm = basicValidation(formName,field,fieldName,true,true,true,false,false,false,false);
                       }
                   }
               }
           }

           //Validation for Required field for Description
           if (iValidForm)
           {
                var fieldName = "<%=i18nNow.getI18nString("emxFramework.Basic.Description", bundle,acceptLanguage)%> ";
                var field = formName.txtECDescription;
                iValidForm = basicValidation(formName,field,fieldName,true,false,false,false,false,false,checkBadChars);
           }

           if (iValidForm)
           {
               if (jsDblClick())
               {
                   formName.submit();
               }
           }
       }

       //when 'Cancel' button is pressed in Dialog Page
       function closeWindow()
       {
           window.closeWindow();
       }

       //When Enter Key Pressed on the form
       function submitForm()
       {
           submit();
       }

       //when 'Done' button is pressed in Dialog Page
       function submit()
       {
           var sURL        = "../components/emxEngineeringChangeUtil.jsp?mode=create";
           sURL            = sURL + "&jsTreeID=<%= XSSUtil.encodeForURL(context, strTreeId)%>&suiteKey=<%= XSSUtil.encodeForURL(context, strSuiteKey)%>";
           formName.action = sURL;
           formName.target = "jpcharfooter";
           validateForm();
       }

       //when 'Apply' button is pressed in Dialog Page
       function apply()
       {
           var sURL        = "../components/emxEngineeringChangeUtil.jsp?mode=apply";
           sURL            = sURL + "&jsTreeID=<%=XSSUtil.encodeForURL(context, strTreeId)%>&suiteKey=<%=XSSUtil.encodeForURL(context, strSuiteKey)%>";
           formName.action = sURL;
           formName.target = "jpcharfooter";
           validateForm();
       }

       /*
        *This function is for popping the Type chooser.
        *The value chosen by the type chooser is returned to the corresponding field.
        */
       function showTypeSelector()
       {
           var sURL    = '../common/emxTypeChooser.jsp?fieldNameDisplay=txtECType';
           sURL        = sURL + '&fieldNameActual=txtSelectedTypeName&formName=EngineeringChangeCreate&SelectType=single';
           sURL        = sURL + '&SelectAbstractTypes=true&InclusionList=<%= XSSUtil.encodeForURL(context, strBaseType)%>&ObserveHidden=true';
           sURL        = sURL + '&SuiteKey=Components&ShowIcons=true';
           showChooser(sURL,500,400);
       }
/*
       //This function is for displaying the available Reported Against Items
       function showECReportedAgainst()
       {
       	
           var sURL    = '../components/emxCommonSearch.jsp?formName=EngineeringChangeCreate';
           sURL        = sURL + '&frameName=pageContent&fieldNameActual=HiddenECReportedAgainst';
           sURL        = sURL + '&fieldNameDisplay=txtECReportedAgainst&searchmode=chooser';
           sURL        = sURL + '&suiteKey=Components&searchmenu=APPECSearchAddExistingChooser';
           sURL        = sURL + '&searchcommand=APPSearchECReportedAgainstItemsCommand';
           sURL        = sURL + '&srcDestRelName=relationship_ReportedAgainstEC&isTo=true';
           showChooser(sURL, 700, 500);
          
       }

       //This function is for displaying the available Member List objects
       function showECDistributionList()
       {
           var sURL    = '../components/emxCommonSearch.jsp?formName=EngineeringChangeCreate';
           sURL        = sURL + '&frameName=pageContent&fieldNameActual=HiddenECDistributionList';
           sURL        = sURL + '&fieldNameDisplay=txtECDistributionList&searchmode=chooser';
           sURL        = sURL + '&suiteKey=Components&searchmenu=APPECSearchAddExistingChooser';
           sURL        = sURL + '&searchcommand=APPSearchECMemberListCommand';
           showChooser(sURL, 700, 500);
       }

       //This function is for displaying the available Reviewer List objects
       function showECReviewerList()
       {
           var sURL    = '../components/emxCommonSearch.jsp?formName=EngineeringChangeCreate';
           sURL        = sURL + '&frameName=pageContent&fieldNameActual=HiddenECReviewerList';
           sURL        = sURL + '&fieldNameDisplay=txtECReviewerList&searchmode=chooser';
           sURL        = sURL + '&suiteKey=Components&searchmenu=APPECSearchAddExistingChooser';
           sURL        = sURL + '&searchcommand=APPSearchECRouteTemplatesCommand&restrictToPurpose=Review&restrictAvailability=';
           showChooser(sURL, 700, 500);
       }

       //This function is for displaying the available Approval List objects
       function showECApprovalList()
       {
           var sURL    = '../components/emxCommonSearch.jsp?formName=EngineeringChangeCreate';
           sURL        = sURL + '&frameName=pageContent&fieldNameActual=HiddenECApprovalList';
           sURL        = sURL + '&fieldNameDisplay=txtECApprovalList&searchmode=chooser';
           sURL        = sURL + '&suiteKey=Components&searchmenu=APPECSearchAddExistingChooser';
           sURL        = sURL + '&searchcommand=APPSearchECRouteTemplatesCommand&restrictToPurpose=Approval&restrictAvailability=';
           showChooser(sURL, 700, 500);
       }
*/

/////////
// Autonomy search integration
//
		//This function is for displaying the available Reported Against Items
       function showECReportedAgainst()
       {
            var objCommonAutonomySearch = new emxCommonAutonomySearch();

			objCommonAutonomySearch.field = "TYPES=<xss:encodeForJavaScript><%=strInclusionType%></xss:encodeForJavaScript>";	
			objCommonAutonomySearch.selection = "single";
			objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitECReportedAgainst"; 
				
			objCommonAutonomySearch.open();
       }
       function submitECReportedAgainst (arrSelectedObjects) {
       		var objForm = document.forms["EngineeringChangeCreate"];
       		if (!objForm) {
       			return;
       		}
       		
		    for (var i = 0; i < arrSelectedObjects.length; i++) {
		        var objSelection = arrSelectedObjects[i];
		        
		        if (objForm.elements["HiddenECReportedAgainst"]) {
		        	objForm.elements["HiddenECReportedAgainst"].value = objSelection.objectId;
		        }
		        if (objForm.elements["txtECReportedAgainst"]) {
		        	objForm.elements["txtECReportedAgainst"].value = objSelection.name;
		        }
		    }
		}
		       

       //This function is for displaying the available Member List objects
       function showECDistributionList()
       {
            var objCommonAutonomySearch = new emxCommonAutonomySearch();

			objCommonAutonomySearch.field = "TYPES=type_MemberList";
			objCommonAutonomySearch.selection = "single";
			objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitECDistributionList"; 
				
			objCommonAutonomySearch.open();
          
       }
       function submitECDistributionList (arrSelectedObjects) {
       		var objForm = document.forms["EngineeringChangeCreate"];
       		if (!objForm) {
       			return;
       		}
       		
		    for (var i = 0; i < arrSelectedObjects.length; i++) {
		        var objSelection = arrSelectedObjects[i];
		        
		        if (objForm.elements["HiddenECDistributionList"]) {
		        	objForm.elements["HiddenECDistributionList"].value = objSelection.objectId;
		        }
		        if (objForm.elements["txtECDistributionList"]) {
		        	objForm.elements["txtECDistributionList"].value = objSelection.name;
		        }
		    }
		}

       //This function is for displaying the available Reviewer List objects
       function showECReviewerList()
       {
           var objCommonAutonomySearch = new emxCommonAutonomySearch();

			// Updated for bug 349911 rev3
			//objCommonAutonomySearch.field = "TYPES=type_RouteTemplate:CURRENT=state_Active:ROUTE_BASE_PURPOSE=Review";
			objCommonAutonomySearch.field = "TYPES=type_RouteTemplate:CURRENT=policy_Organization.state_Active:ROUTE_BASE_PURPOSE=Review";
			
			objCommonAutonomySearch.selection = "single";
			objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitECReviewerList"; 
				
			objCommonAutonomySearch.open();
       }
       function submitECReviewerList (arrSelectedObjects) {
       		var objForm = document.forms["EngineeringChangeCreate"];
       		if (!objForm) {
       			return;
       		}
       		
		    for (var i = 0; i < arrSelectedObjects.length; i++) {
		        var objSelection = arrSelectedObjects[i];
		        
		        if (objForm.elements["HiddenECReviewerList"]) {
		        	objForm.elements["HiddenECReviewerList"].value = objSelection.objectId;
		        }
		        if (objForm.elements["txtECReviewerList"]) {
		        	objForm.elements["txtECReviewerList"].value = objSelection.name;
		        }
		    }
		}

       //This function is for displaying the available Approval List objects
       function showECApprovalList()
       {
           var objCommonAutonomySearch = new emxCommonAutonomySearch();

			// Updated for bug 349911 rev3
			//objCommonAutonomySearch.field = "TYPES=type_RouteTemplate:CURRENT=state_Active:ROUTE_BASE_PURPOSE=Approval";
			objCommonAutonomySearch.field = "TYPES=type_RouteTemplate:CURRENT=policy_Organization.state_Active:ROUTE_BASE_PURPOSE=Approval";
			objCommonAutonomySearch.selection = "single";
			objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitECApprovalList"; 
				
			objCommonAutonomySearch.open();
       }
       function submitECApprovalList (arrSelectedObjects) {
       		var objForm = document.forms["EngineeringChangeCreate"];
       		if (!objForm) {
       			return;
       		}
       		
		    for (var i = 0; i < arrSelectedObjects.length; i++) {
		        var objSelection = arrSelectedObjects[i];
		        
		        if (objForm.elements["HiddenECApprovalList"]) {
		        	objForm.elements["HiddenECApprovalList"].value = objSelection.objectId;
		        }
		        if (objForm.elements["txtECApprovalList"]) {
		        	objForm.elements["txtECApprovalList"].value = objSelection.name;
		        }
		    }
		}
//
// Autonomy search integration
///////////

       //This function is for popping the Vault chooser.
       function showVaultSelector()
       {
           var sURL    = '../common/emxVaultChooser.jsp?fieldNameActual=txtECVault';
           sURL        = sURL + '&fieldNameDisplay=txtECVaultDisplay&incCollPartners=false';
           sURL        = sURL + '&multiSelect=false';
           showChooser(sURL);
       }

       // Focus on the first editable field in the create page has been incorporated here
       var strAutoNamer = document.EngineeringChangeCreate.strAutoNamer.value;
       //XSSOK
       if(!(<%=strAutoNamer.equalsIgnoreCase("True")%>)  || strAutoNamer == "" )
       {
           document.EngineeringChangeCreate.txtECName.focus();
       }else {
           document.EngineeringChangeCreate.txtECDescription.focus();
       }

   </script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>



