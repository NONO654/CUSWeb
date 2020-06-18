<%--
  ManufacutringFeatureCopyDialog.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="emxProductCommonInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<%@include file="emxValidationInclude.inc"%>
<%@page import="java.util.*"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.apps.domain.*"%>
<%@page import="com.matrixone.apps.domain.util.*"%>
<%@page import="com.matrixone.apps.framework.ui.*"%>
<%@page import="com.matrixone.apps.productline.*"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="matrix.util.StringList"%>
<html>
<%
   String strParentSymType = EnoviaResourceBundle.getProperty(context, "Configuration.ConfigurationCompareTypesForObject2.type_Products");
   String strInvalidStatesTypes = EnoviaResourceBundle.getProperty(context,"Configuration.FrozenState."+strParentSymType);
 
    boolean bIsError = false;
        String action = "";
        String msg = "";

        int i = 0;
        String languageStr = context.getSession().getLanguage();
        String functionality = emxGetParameter(request, "functionality");
        //String[] strTableRowIds = emxGetParameterValues(request,"tableIdArray");
        String[] strTableRowIds = emxGetParameterValues(request,
                "emxTableRowId");
        String sSuiteKey = "eServiceSuite"
                + emxGetParameter(request, "suiteKey");
        String sObjectId = emxGetParameter(request, "objectId");
        String fromPrevious = emxGetParameter(request, "fromPrevious");
        String objectIdTobeconnected = emxGetParameter(request,
                "objectIdTobeconnected");
        String type = "";
        String share = "off";
        String clone = "";
        String strInclusionFeatureTypes = "";
        DomainObject bus = null;
        StringList selectedTableIDList = new StringList();
        HashMap selValuesMap = null;
        String sSelObjId = "";
        String sSelObjName = "";
        boolean disableShareOption = false;
%>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script>
             var action = "<%=XSSUtil.encodeForJavaScript(context,functionality)%>";
             var rootNodeSelected = "false";
</script>
<%
    if (fromPrevious != null
                && fromPrevious.equalsIgnoreCase("true")) {
            bus = new DomainObject(objectIdTobeconnected);
%>
<script> 
                 var objID = "<%=XSSUtil.encodeForJavaScript(context,objectIdTobeconnected)%>";
             </script>
<%
    selValuesMap = (java.util.HashMap) session
                    .getAttribute("selectedValues");
        } else {
            bus = new DomainObject(sObjectId);
%>
<script> 
                 var objID = "<%=XSSUtil.encodeForJavaScript(context,sObjectId)%>";
             </script>
<%
    if (functionality != null
                    && functionality.equals("ManufacturingFeatureCopyTo")) {
                StringTokenizer strTokenizer;
                String strPrevParentId = "";
                String strParentId = "";
                String strFeatureId = "";

                for (int iCount = 0; iCount < strTableRowIds.length; iCount++) {
                    if (strTableRowIds[iCount].indexOf("|") > 0) {
                        strTokenizer = new StringTokenizer(
                                strTableRowIds[iCount], "|");
                        strTokenizer.nextToken();
                        strFeatureId = strTokenizer.nextToken();
                        selectedTableIDList.add(strTableRowIds[iCount]);
                        strParentId = strTokenizer.nextToken();
                        if (!strParentId.equals(strPrevParentId)
                                && !strPrevParentId.equals("")) {
                            disableShareOption = true;
                        }
                        strPrevParentId = strParentId;
                    } else {
%>
<script> 
                                   rootNodeSelected = "true";
                               </script>
<%
    }
                }
                HashMap selectedValues = new java.util.HashMap();
                selectedValues.put("selectedTableIDList",
                        selectedTableIDList);
                session.setAttribute("selectedValues", selectedValues);
            }
        }

        if (selValuesMap != null) {
            sSelObjId = (String) selValuesMap.get("selObjId");
            sSelObjName = (String) selValuesMap.get("selObjName");
            clone = (String) selValuesMap.get("clone");
            share = (String) selValuesMap.get("share");
        }
        type = EnoviaResourceBundle.getProperty(context,
                        "Configuration.ConfigurationCompareTypesForObject2.type_Products");

        if (functionality != null
                && (functionality.equals("ManufacturingFeatureCopyFrom") || functionality
                        .equals("ManufacturingFeatureCopyTo"))) {
            strInclusionFeatureTypes = EnoviaResourceBundle.getProperty(context, sSuiteKey + "." + functionality
                            + "AllowedSourceTypesForDestination."
                            + type);
        }

        String strEnableMultilvel = EnoviaResourceBundle.getProperty(context,"emxConfiguration.Copy.MultiLevelSelection.Enabled");

        if (strEnableMultilvel == null
                || strEnableMultilvel.equalsIgnoreCase("No")) {
            disableShareOption = false;
        }

        String strDisableParam = "";
        String strFont = "black";

        if (disableShareOption) {
            strDisableParam = "DISABLED";
            strFont = "gainsboro";
        }

        String IncludedData = EnoviaResourceBundle.getProperty(context,sSuiteKey
                + "." + functionality + ".IncludedData");
        StringTokenizer st = new StringTokenizer(IncludedData, ",");
        ArrayList includedOption = new ArrayList();

        while (st.hasMoreTokens()) {
            includedOption.add(st.nextToken());
        }

        int RowSpan = includedOption.size();
        RowSpan += 2;
%>
<body>
<form name="ProductCopy" method="post" action="moveNext()">
<%@include file = "../common/enoviaCSRFTokenInjection.inc" %>
<input type="hidden" name="sourceObjectId" value="" />

<table border="0" cellpadding="5" cellspacing="2" width="100%">
    <%-- Display the input fields. --%>

    <%
        if (functionality.equalsIgnoreCase("ManufacturingFeatureCopyFrom")) {
    %>
    <tr>
        <td width="150" nowrap="nowrap" class="labelRequired"><emxUtil:i18n
            localize='i18nId'>emxConfiguration.CopyDialog.Source</emxUtil:i18n></td>
        <%
            } else {
        %>
    
    <tr>
        <td width="150" nowrap="nowrap" class="labelRequired"><emxUtil:i18n
            localize='i18nId'>emxConfiguration.CopyDialog.Destination</emxUtil:i18n>
        </td>
        <%
            }
        %>

        <td nowrap="nowrap" class="field"><input type="text" id="txtSourceObject" name="txtSourceObject" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=sSelObjName%></xss:encodeForHTMLAttribute>" /> <input type="hidden" id="txtToFeatureId" name="txtToFeatureId" value="<xss:encodeForHTML><%=sSelObjId%></xss:encodeForHTML>" /> <input class="button" type="button"
            name="btnProduct" size="200" value="..." alt=""
            onClick="javascript:showProductChooser()" /></td>    

</tr>

    <tr>
        <td width="150" nowrap="nowrap" class="label" rowspan="2"><emxUtil:i18n
            localize='i18nId'>emxConfiguration.CopyDialog.CopyOptions</emxUtil:i18n>
        </td>
        <td nowrap="nowrap" class="field">
        <%
            if (clone != null && clone.equals("on")) {
        %> <input type="radio" name="Clone" size="20" checked="checked"
            onClick="Disable(this,'')" /> <%
    } else if (share.equals("off")) {
 %> <input type="radio" name="Clone" size="20" checked="checked"
            onClick="Disable(this,'')" /> <%
    } else {
 %> <input type="radio" name="Clone" size="20"
            onClick="Disable(this,'')" /> <%
    }
 %> <emxUtil:i18n localize='i18nId'>emxConfiguration.CopyDialog.CloneSelectedFeatures</emxUtil:i18n>
        </td>
    </tr>

    <tr>
        <td nowrap="nowrap" class="field">
        <%
            if (share != null && share.equals("on")) {
        %> <input type="radio" name="Share" size="200" checked="checked"
            alt="" onClick="Disable(this,'true')" <%=XSSUtil.encodeForHTMLAttribute(context,strDisableParam)%> /> <%
    } else {
 %> <input type="radio" name="Share" size="20"
            onClick="Disable(this,'true')" <xss:encodeForHTMLAttribute><%=strDisableParam%></xss:encodeForHTMLAttribute> /> <%
    }
 %> <!-- Added for CR-213 --> <font color="<xss:encodeForHTMLAttribute><%=strFont%></xss:encodeForHTMLAttribute>"><emxUtil:i18n
            localize='i18nId'>emxConfiguration.CopyDialog.ShareSelectedFeatures</emxUtil:i18n></font>
        <input type="hidden" name="destinationObjectId" value="" /></td>

    </tr>
    <tr>
        <td width="150" nowrap="nowrap" class="label" rowspan="<xss:encodeForHTMLAttribute><%=RowSpan%></xss:encodeForHTMLAttribute>">
        <emxUtil:i18n localize='i18nId'>emxConfiguration.CopyDialog.IncludeRelatedData</emxUtil:i18n>
        </td>
    </tr>


    <tr>
        <td nowrap="nowrap" class="field">
        <%
            String sAll = "";
                if (selValuesMap != null) {
                    sAll = (String) selValuesMap.get("All");
                }
                if (sAll != null && sAll.equals("on")) {
        %> <input type="checkbox" name="All" size="20" onClick="checkAll()"
            checked="true" /><%=XSSUtil.encodeForHTML(context,EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.CoptFunctionality.All",languageStr))%></td>
    </tr>

    <%
        } else if (share != null && share.equalsIgnoreCase("on")) {
    %>
    <input type="checkbox" name="All" size="20" onClick="checkAll()"
        disabled="true" /><%=XSSUtil.encodeForHTML(context,EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.CoptFunctionality.All",languageStr))%>
    </td>
    </tr>

    <%
        } else {
    %>
    <input type="checkbox" name="All" size="20" onClick="checkAll()" /><%=XSSUtil.encodeForHTML(context,EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.CoptFunctionality.All",languageStr))%>
    </td>
    </tr>

    <%
        }

            String sOptionValue = "";
            String strOptions = null;
            String sOption = null;
            String strDisplayValue = null;
            for (int row = includedOption.size() - 1; row >= 0; row--) {
                sOption = (String) includedOption.get(row);
                strDisplayValue = sOption;

                strDisplayValue =EnoviaResourceBundle.getProperty(context,"Configuration",
                        "emxConfiguration.CoptFunctionality."
                                + strDisplayValue.replaceAll(" ", "_"),languageStr);
                if (selValuesMap != null) {
                    sOptionValue = (String) selValuesMap.get(sOption);
                }
                String sChecked = "false";

                if (sOptionValue != null && sOptionValue.equals("on")) {
    %>
    <tr>
        <td nowrap="nowrap" class="field"><input type="checkbox"
            name="<xss:encodeForHTMLAttribute><%=sOption%></xss:encodeForHTMLAttribute>" size="20" checked="true" onclick="deselectALL();selectALL()"/><%=XSSUtil.encodeForHTML(context,strDisplayValue)%>
        </td>
    </tr>
    <%
        } else if (share != null && share.equalsIgnoreCase("on")) {
    %>

    <tr>
        <td nowrap="nowrap" class="field"><input type="checkbox"
            name="<xss:encodeForHTMLAttribute><%=sOption%></xss:encodeForHTMLAttribute>" size="20" disabled="true" /><%=XSSUtil.encodeForHTML(context,strDisplayValue)%>
        </td>
    </tr>
    <%
        } else {
    %>

    <tr>
        <td nowrap="nowrap" class="field"><input type="checkbox"
            name="<xss:encodeForHTMLAttribute><%=sOption%></xss:encodeForHTMLAttribute>" size="20" onclick="deselectALL();selectALL()"/><%=XSSUtil.encodeForHTML(context,strDisplayValue)%></td>
    </tr>
    <%
        }
            }
    %>
</table>
</form>

<script language="javascript" type="text/javaScript">
  //<![CDATA[
    var  formName = document.ProductCopy;

  function checkAll()
  { 
    for (var i = 8; i<formName.elements.length; i++) 
    { 
        formName.elements[i].checked = true;    
    }
  }

  function Disable(form,value1)
  { 
     if(value1 == "")
     {
         formName.elements[5].checked = false;
         for (var i = 7; i<formName.elements.length; i++) 
         { 
          if(formName.elements[i].type == "checkbox")  
           formName.elements[i].disabled=value1;      
         } 
     }
     else
     {
        formName.elements[4].checked = false;
        for (var i = 7; i<formName.elements.length; i++) 
        { 
        if(formName.elements[i].type == "checkbox"){    
          formName.elements[i].checked = false;
          formName.elements[i].disabled=value1;
         }      
        } 
     }
    
 } 

    
 function showProductChooser()
 {
     showModalDialog('../common/emxFullSearch.jsp?field=TYPES=<%=XSSUtil.encodeForURL(context,strInclusionFeatureTypes.toString())%>:Type!=type_ProductVariant:CURRENT!=<%=XSSUtil.encodeForURL(context,strInvalidStatesTypes)%>&table=FTRLogicalFeatureSearchResultsTable&Registered Suite=Configuration&showInitialResults=false&selection=single&showSavedQuery=true&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../configuration/SearchUtil.jsp?mode=Chooser&chooserType=CustomChooser&fieldNameActual=txtToFeatureId&fieldNameDisplay=txtSourceObject&excludeOID=<%=XSSUtil.encodeForURL(context,sObjectId)%>',850,630); 
 }

    //when 'Cancel' button is pressed in Dialog Page
 function closeWindow()
 {
    parent.window.closeWindow();
 }
 
 function moveNext()
 {
    var formName = document.ProductCopy;
    if(formName.txtSourceObject.value=="")
    {
        if(action == "ManufacturingFeatureCopyTo")
        {
            var alertMsg = "<%=i18nNow.getI18nString(
                                "emxProduct.Alert.CopyDialog.Destination",
                                bundle, acceptLanguage)%>"
            alert(alertMsg);
        }
        else if(action == "ManufacturingFeatureCopyFrom")
        {
            var alertMsg = "<%=i18nNow.getI18nString(
                                "emxProduct.Alert.CopyDialog.Source", bundle,
                                acceptLanguage)%>"
            alert(alertMsg);
        }
    
    }
    else
    {
        var formName = document.ProductCopy;
        var strId = formName.txtToFeatureId.value;
        formName.target="_top";
        var a;
        
        if(action == "ManufacturingFeatureCopyTo")
        {  
            a = "../components/emxCommonFS.jsp?functionality=ManufacturingFeatureCopyToSecondStep&suiteKey=Configuration&objectId="+strId+"&objectIdTobeconnected=" + objID + "&selObjName=" + document.ProductCopy.txtSourceObject.value; 
        }
        else if(action == "ManufacturingFeatureCopyFrom")
        { 
            a = "../components/emxCommonFS.jsp?functionality=ManufacturingFeatureCopyFromSecondStep&suiteKey=Configuration&objectId="+strId+"&objectIdTobeconnected=" + objID + "&selObjName=" + document.ProductCopy.txtSourceObject.value; ;
        }
        
        var isClone, isShare, isAll, isDocs, isFeature, isCases, isDesignVariants, isRules;
        var i, j, args, els;
        isAll = "";
        els = document.forms["ProductCopy"]
        i=0
        if(document.forms["ProductCopy"].Clone.checked ==0)
        {
            isAll = "&clone=off&share=on";
        }
        else
        {
            isAll = "&clone=on&share=off";
        }
        while (typeof(els[i])!=='undefined')
        {
             if(els[i].type =="checkbox")
             {
                if(els[i].checked == 0)
                {
                    var temp = "&" + els[i].name + "=off" ;
                    isAll += temp;
                }
                else
                {
                    var temp = "&" + els[i].name + "=on" ;
                    isAll += temp;
                }
             }
             i++;
        }    
        formName.action= a+ isAll;            
        formName.submit();
    }
}
    
   function submitForm()
   {
       submit();
   }

   
    function submit()
    {
        var iValidForm = true;
        if (iValidForm)
        {
            var fieldName = "gh ";
            var field = formName.txtDestinationProduct;
            iValidForm = basicValidation(formName,field,fieldName,true,false,false,false,false,false,false);
        }
        if (iValidForm && formName.destinationObjectId.value==formName.sourceObjectId.value)
        {
            iValidForm=false;
            strMsg = " Destibnation ";
            formName.destinationObjectId.value = "";
            formName.txtDestinationProduct.value = "";
         }
        if (!iValidForm)
        {
            return ;
        }
        if (jsDblClick()) 
        {
                formName.submit();
        }
    }
  //]]>
  </script>
</body>
</html>
