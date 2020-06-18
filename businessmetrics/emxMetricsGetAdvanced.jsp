<%-- emxMetricsGetAdvanced.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsGetAdvanced.jsp.rca 1.12 Wed Oct 22 16:11:56 2008 przemek Experimental $
--%>

<html>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@ page import="com.matrixone.apps.domain.util.FrameworkUtil" %>

<head>
    <script type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
    <script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
    <script type="text/javascript" src="../common/scripts/emxJSValidationUtil.js"></script>
    <script type="text/javascript" src="emxMetrics.js"></script>
</head>

<%
    String emxType = emxGetParameter(request,"type");
    String formName = emxGetParameter(request,"frmName");
    // string operators
    String sMatrixBeginsWith   = "BeginsWith";
    String sMatrixEndsWith     = "EndsWith";
    String sMatrixIncludes     = "Includes";
    String sMatrixIsExactly    = "IsExactly";
    String sMatrixIsNot        = "IsNot";
    String sMatrixMatches      = "Matches";

    // Real/Integer operators
    String sMatrixIsAtLeast    = "IsAtLeast";
    String sMatrixIsAtMost     = "IsAtMost";
    String sMatrixDoesNotEqual = "DoesNotEqual";
    String sMatrixEquals       = "Equals";
    String sMatrixIsLessThan   = "IsLessThan";
    String sMatrixIsMoreThan   = "IsMoreThan";
    String sMatrixIsBetween    = "IsBetween";

    // Date operators
    String sMatrixIsOn         = "IsOn";
    String sMatrixIsOnOrBefore = "IsOnOrBefore";
    String sMatrixIsOnOrAfter  = "IsOnOrAfter";
    String sMatrixInBetween    = "InBetween";

    String strBundle = "emxMetricsStringResource"; 
    String languageStr = request.getHeader("Accept-Language");
    // string operator conversions
    String sMatrixBeginsWithTrans   = FrameworkUtil.i18nStringNow("emxFramework.AdvancedSearch.BeginsWith", languageStr);
    String sMatrixEndsWithTrans     = FrameworkUtil.i18nStringNow("emxFramework.AdvancedSearch.EndsWith",languageStr);
    String sMatrixIncludesTrans     = FrameworkUtil.i18nStringNow("emxFramework.AdvancedSearch.Includes",languageStr);
    String sMatrixIsExactlyTrans    = FrameworkUtil.i18nStringNow("emxFramework.AdvancedSearch.IsExactly",languageStr);
    String sMatrixIsNotTrans        = FrameworkUtil.i18nStringNow("emxFramework.AdvancedSearch.IsNot",languageStr);
    String sMatrixMatchesTrans      = FrameworkUtil.i18nStringNow("emxFramework.AdvancedSearch.Matches",languageStr);

    String sMatrixIsAtLeastTrans    = FrameworkUtil.i18nStringNow("emxFramework.AdvancedSearch.IsAtLeast",languageStr);
    String sMatrixIsAtMostTrans     = FrameworkUtil.i18nStringNow("emxFramework.AdvancedSearch.IsAtMost",languageStr);
    String sMatrixDoesNotEqualTrans = FrameworkUtil.i18nStringNow("emxFramework.AdvancedSearch.DoesNotEqual",languageStr);
    String sMatrixEqualsTrans       = FrameworkUtil.i18nStringNow("emxFramework.AdvancedSearch.Equals",languageStr);
    String sMatrixIsLessThanTrans   = FrameworkUtil.i18nStringNow("emxFramework.AdvancedSearch.IsLessThan",languageStr);
    String sMatrixIsMoreThanTrans   = FrameworkUtil.i18nStringNow("emxFramework.AdvancedSearch.IsMoreThan",languageStr);
    String sMatrixIsBetweenTrans    = FrameworkUtil.i18nStringNow("emxFramework.AdvancedSearch.IsBetween",languageStr);

    String sMatrixIsOnTrans         = FrameworkUtil.i18nStringNow("emxFramework.AdvancedSearch.IsOn",languageStr);
    String sMatrixIsOnOrBeforeTrans = FrameworkUtil.i18nStringNow("emxFramework.AdvancedSearch.IsOnOrBefore",languageStr);
    String sMatrixIsOnOrAfterTrans  = FrameworkUtil.i18nStringNow("emxFramework.AdvancedSearch.IsOnOrAfter",languageStr);

    String sMatrixInBetweenTrans    = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.InBetween");
    String strAttribute             = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.Attribute");
    String strOperator              = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.Operator");
    String strValue                 = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.Value");
    String strFrom                  = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.From");
    String strTo                    = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.To");
    StringBuffer sbStrInclude     = null;
    StringBuffer sbRealInclude    = null;
    StringBuffer sbTimeInclude    = null;
    StringBuffer sbBooleanInclude = null;

    AttributeItr attrItrObj = null;
    StringList sListStates = new StringList();
    StringList sListPolicy = new StringList();
    String objectPolicy = "";

    if(emxType.indexOf(',') < 0) {
        BusinessType btType = new BusinessType(emxType, context.getVault());
        btType.open(context, false);

        //To get the Find Like information of the business type selected
        matrix.db.FindLikeInfo flLikeObj = btType.getFindLikeInfo(context);
        btType.close(context);

        //To get the attribute list of the business type
        AttributeList attrListObj = flLikeObj.getAttributes();
        attrItrObj = new AttributeItr(attrListObj);
        try {


            sListStates = flLikeObj.getStates();
            sListPolicy = flLikeObj.getPolicies();
            objectPolicy = (String)sListPolicy.elementAt(0);
        } catch(Exception e) {
            sListStates = sListStates = new StringList();
            sListPolicy = new StringList();
            objectPolicy = "";
        }
    }
    String sName      = "";
    String sDataType  = "";
    String sShowHiddenAttr  = "FALSE";
    if(sShowHiddenAttr == null )  {
        sShowHiddenAttr ="";
    } else if(sShowHiddenAttr.equals("null")) {
        sShowHiddenAttr ="";
    }
    HashMap attrMap = null;
    MapList attrMapList = new MapList();
    String attrList = "";
    String searchBasics = (String)EnoviaResourceBundle.getProperty(context, "emxFramework.Search.AdditionalBasicAttributes");
    if(searchBasics != null && !"".equals(searchBasics))
    {
        StringList basicList = FrameworkUtil.split(searchBasics, ",");
        for(int l=0; l < basicList.size(); l++) {
            String basicStr = (String) basicList.get(l);
            if(emxType.indexOf(',') >= 0 && basicStr.equalsIgnoreCase("current"))
                continue;
            attrMap = new HashMap();
            if(basicStr.equalsIgnoreCase("owner")) {
                sName = "Owner";
                sDataType = "string";
                attrList += "Owner,";
            }
            if(basicStr.equalsIgnoreCase("current")) {
                sName = "Current";
                sDataType = "string";
                attrMap.put("Choices", sListStates);
                attrMap.put("isState", "true");
                attrList += "Current,";
            }
            if(basicStr.equalsIgnoreCase("description")) {
                sName = "Description";
                sDataType = "string";
                attrList += "Description,";
            }
            if(basicStr.equalsIgnoreCase("originated")) {
                sName = "Originated";
                sDataType = "timestamp";
                attrList += "Originated,";
            }
            if(basicStr.equalsIgnoreCase("modified")) {
                sName = "Modified";
                sDataType = "timestamp";
                attrList += "Modified,";
            }
            attrMap.put("Name", sName);
            attrMap.put("Type", sDataType);
            attrMap.put("FieldType", "Basic");
            attrMapList.add(attrMap);
        }
    }
    if(emxType.indexOf(',') < 0) {
        while (attrItrObj.next()) {
            attrMap = new HashMap();
            Attribute attrObj = attrItrObj.obj();
            //Store name of the attribute in vector if Attribute is not hidden
            sName             = attrObj.getName();
            if(sShowHiddenAttr.equals("TRUE") || !FrameworkUtil.isAttributeHidden(context, sName)) {
                attrMap.put("Name", sName);
                attrList += sName + ",";
                //To get the attribute choices
                if (attrObj.hasChoices()) {
                        attrMap.put("Choices", attrObj.getChoices());
                }
                //To get the Data type of the attribute
                AttributeType attrTypeObj = attrObj.getAttributeType();
                attrTypeObj.open(context);
                sDataType = attrTypeObj.getDataType();
                attrTypeObj.close(context);
                //Store datatype in vector
                attrMap.put("Type", sDataType);
                attrMapList.add(attrMap);
            }
        }
    }

    //  Create Drop downs for Data types of the Attribute
    String sOption = "<option name=blank value=\"*\"></option><option name='";

    //To set options for string data type
    sbStrInclude    = new StringBuffer(sOption);
    sbStrInclude.append(sMatrixBeginsWith + "' value='" + sMatrixBeginsWith + "'>" + sMatrixBeginsWithTrans + " </option>");
    sbStrInclude.append("<option name='" + sMatrixEndsWith + "' value='" + sMatrixEndsWith + "'>" + sMatrixEndsWithTrans + " </option>");
    sbStrInclude.append("<option name='" + sMatrixIncludes + "' value='" + sMatrixIncludes + "'>" + sMatrixIncludesTrans + " </option>");
    sbStrInclude.append("<option name='" + sMatrixIsExactly + "' value='" + sMatrixIsExactly + "'>" + sMatrixIsExactlyTrans + " </option>");
    sbStrInclude.append("<option name='" + sMatrixIsNot + "' value='" + sMatrixIsNot + "'>" + sMatrixIsNotTrans + " </option>");
    sbStrInclude.append("<option name='" + sMatrixMatches + "' value='" + sMatrixMatches + "'>" + sMatrixMatchesTrans + " </option>");

    //To set options for numeric data type
    sbRealInclude   = new StringBuffer(sOption);
    sbRealInclude.append(sMatrixIsAtLeast + "' value='" + sMatrixIsAtLeast + "'>" + sMatrixIsAtLeastTrans + "</option>");
    sbRealInclude.append("<option name='" + sMatrixIsAtMost + "' value='" + sMatrixIsAtMost + "'>" + sMatrixIsAtMostTrans + "</option>");
    sbRealInclude.append("<option name='" + sMatrixDoesNotEqual + "' value='" + sMatrixDoesNotEqual + "'>" + sMatrixDoesNotEqualTrans + "</option>");
    sbRealInclude.append("<option name='" + sMatrixEquals + "' value='" + sMatrixEquals + "'>" + sMatrixEqualsTrans + "</option>");
    sbRealInclude.append("<option name='" + sMatrixIsBetween + "' value='" + sMatrixIsBetween + "'>" + sMatrixIsBetweenTrans + "</option>");
    sbRealInclude.append("<option name='" + sMatrixIsLessThan + "' value='" + sMatrixIsLessThan + "'>" + sMatrixIsLessThanTrans + "</option>");
    sbRealInclude.append("<option name='" + sMatrixIsMoreThan + "' value='" + sMatrixIsMoreThan + "'>" + sMatrixIsMoreThanTrans + "</option>");

    //To set options for date/time data type
    sbTimeInclude   = new StringBuffer(sOption);
    sbTimeInclude.append(sMatrixIsOn + "' value='" + sMatrixIsOn + "'>" + sMatrixIsOnTrans + "</option>");
    sbTimeInclude.append("<option name='" + sMatrixIsOnOrBefore + "' value='" + sMatrixIsOnOrBefore + "'>" + sMatrixIsOnOrBeforeTrans + "</option>");
    sbTimeInclude.append("<option name='" + sMatrixIsOnOrAfter + "' value='" + sMatrixIsOnOrAfter + "'>" + sMatrixIsOnOrAfterTrans + "</option>");
    sbTimeInclude.append("<option name='" + sMatrixInBetween + "' value='" + sMatrixInBetween + "'>" + sMatrixInBetweenTrans + "</option>");


    //To set options for boolean data type
    sbBooleanInclude    = new StringBuffer(sOption);
    sbBooleanInclude.append(sMatrixIsExactly + "' value='" + sMatrixIsExactly + "'>" + sMatrixIsExactlyTrans + " </option>");
    sbBooleanInclude.append("<option name='" + sMatrixIsNot + "' value='" + sMatrixIsNot + "'>" + sMatrixIsNotTrans + " </option>");
%>

    <input type="hidden" name="attrList" value="<%=XSSUtil.encodeForHTMLAttribute(context, attrList)%>" />
    <input type="hidden" name="timeZone" value="<xss:encodeForHTMLAttribute><%=session.getValue("timeZone")%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="reqLocaleLang" value="<xss:encodeForHTMLAttribute><%=request.getLocale().getLanguage()%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="reqLocaleCty" value="<xss:encodeForHTMLAttribute><%=request.getLocale().getCountry()%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="reqLocaleVar" value="<xss:encodeForHTMLAttribute><%=request.getLocale().getVariant()%></xss:encodeForHTMLAttribute>" />

    <table class="list">
        <tr>
            <th colspan="4">
                <emxUtil:i18n localize="i18nId">emxFramework.AdvancedSearch.AdditionAttributes</emxUtil:i18n>
                <input type="radio" name="andOrField" value="and" checked extra="yes" />
                <emxUtil:i18n localize="i18nId">emxFramework.AdvancedSearch.And</emxUtil:i18n>
                <input type="radio" name="andOrField" value="or" extra="yes" />
                <emxUtil:i18n localize="i18nId">emxFramework.AdvancedSearch.Or</emxUtil:i18n>
            </th>
        </tr>
        <tr>
            <th><%=strAttribute%></th>
            <th><%=strOperator%></th>
            <th><%=strValue%></th>
        </tr>
<%
        for (int i = 0; i < attrMapList.size(); i++)
        {
            StringList attrChoices = null; 
            attrMap = (HashMap)attrMapList.get(i);
            String attrName = (String) attrMap.get("Name");
            String strComboName  = "comboDescriptor_" + attrName;
            String strTxtName    = "txt_" + attrName;
            String sTxtOrgVal   = "";
            String sComboOrgval = "";
            String sOrgVal      = "";
            String isState = (String) attrMap.get("isState");
            String attrType = (String) attrMap.get("Type");
            StringBuffer strSelect = new StringBuffer();
            String strText = "<td class=\"inputField\"><input type=\"text\" name=\"" + XSSUtil.encodeForHTMLAttribute(context, strTxtName) + "\" value=\"*\" size=\"20\" extra=\"yes\" /></td>";
            if (attrType.equals("string")) {
                strSelect = sbStrInclude;
            } else if(attrType.equals("real") || attrType.equals("integer")) {
                strSelect = sbRealInclude;
            } else if(attrType.equals("timestamp")) {
                strSelect = sbTimeInclude;
                StringBuffer sbFromToDate = new StringBuffer("");
                sbFromToDate.append("<td nowrap class=\"inputField\">");
                sbFromToDate.append(strFrom);
                sbFromToDate.append("&nbsp;&nbsp;<input READONLY type=\"text\" name=\"" + XSSUtil.encodeForHTMLAttribute(context, strTxtName) + "From" + "\" value=\"\" size=\"15\" extra=\"yes\" onFocus=\"this.blur()\">&nbsp;&nbsp;<a href='javascript:showCalendar(\""+XSSUtil.encodeForJavaScript(context, formName)+"\",\"" + XSSUtil.encodeForJavaScript(context, strTxtName) + "From" +  "\",\"\");'><img src=\"../common/images/iconSmallCalendar.gif\" border=\"0\" /></a>&nbsp;&nbsp;");
                sbFromToDate.append("<input type=\"hidden\" name=\"" + XSSUtil.encodeForHTMLAttribute(context, strTxtName) + "From_msvalue" + "\" id=\"" + XSSUtil.encodeForHTMLAttribute(context, strTxtName) + "From_msvalue" + "\" value=\"\" />");
                sbFromToDate.append(strTo);
                sbFromToDate.append("&nbsp;&nbsp;<input READONLY type=\"text\" name=\"" + XSSUtil.encodeForHTMLAttribute(context, strTxtName) + "To" + "\" value=\"\" size=\"15\" extra=\"yes\" onFocus=\"this.blur()\">&nbsp;&nbsp;<a href='javascript:showCalendar(\""+XSSUtil.encodeForJavaScript(context, formName)+"\",\"" + XSSUtil.encodeForJavaScript(context, strTxtName)  + "To" +  "\",\"\");'><img src=\"../common/images/iconSmallCalendar.gif\" border=\"0\" /></a>");
                sbFromToDate.append("<input type=\"hidden\" name=\"" + XSSUtil.encodeForHTMLAttribute(context, strTxtName) + "To_msvalue" + "\" id=\"" + XSSUtil.encodeForHTMLAttribute(context, strTxtName) + "To_msvalue" + "\" value=\"\" />");
                sbFromToDate.append("</td>");
                strText = sbFromToDate.toString();
            } else if(attrType.equals("boolean")) {
                strSelect = sbBooleanInclude;
                StringBuffer sbBooleanValues = new StringBuffer("");
                sbBooleanValues.append("<td nowrap class=\"inputField\"><select name=\"" + XSSUtil.encodeForHTMLAttribute(context, attrName) + "\" size=\"1\"><option value=\"\"></option>");
                String strBooleanFalse = EnoviaResourceBundle.getProperty(context, "emxMetricsStringResource",context.getLocale(), "emxMetrics.Boolean.False");
                String strBooleanTrue = EnoviaResourceBundle.getProperty(context, "emxMetricsStringResource",context.getLocale(), "emxMetrics.Boolean.True");
                sbBooleanValues.append("<option value=\"FALSE\">" + strBooleanFalse + "</option>");
                sbBooleanValues.append("<option value=\"TRUE\">" + strBooleanTrue + "</option></td>");
                strText = sbBooleanValues.toString();
            }
            attrChoices = (StringList) attrMap.get("Choices");
            String strChoiceSelect = "&nbsp;";
            if(attrChoices != null && attrChoices.size() > 0) {
                strChoiceSelect = "<select name=\"" + attrName + "\" size=\"1\"><option value=\"\"></option>";
                for(int j =0; j < attrChoices.size();j++)
                {
                    strChoiceSelect += "<option value=\"" + attrChoices.get(j) +"\">";
                    if(isState != null && "true".equals(isState)) {
                        strChoiceSelect += i18nNow.getStateI18NString(objectPolicy,(String)attrChoices.elementAt(j),languageStr);
                    } else {
                        strChoiceSelect += i18nNow.getRangeI18NString(attrName, (String)attrChoices.get(j), languageStr);
                    }
                    strChoiceSelect += "</option>";
                }
                strChoiceSelect += "</select>";
            }
            String i18nAttrName = "";
            String fieldType = (String) attrMap.get("FieldType");
            if(fieldType != null && "Basic".equals(fieldType)) {
                i18nAttrName = i18nNow.getBasicI18NString(attrName,languageStr);
            } else {
                i18nAttrName = i18nNow.getAttributeI18NString(attrName,languageStr);
            }
            if(attrType.equals("timestamp")){
%>
                <tr>
                    <td width="150" class="label"><%=i18nAttrName%></td>
                    <td class="inputField">
                        <select name="<%=XSSUtil.encodeForHTMLAttribute(context, strComboName)%>" extra="yes" onChange="javascript:disableFromAndToDate('<%=XSSUtil.encodeForJavaScript(context, attrName)%>');">
                        <!-- //XSSOK -->
                            <%=strSelect%>
                        </select></td>
                        <!-- //XSSOK -->
                        <%=strText%>
                    </td>
                </tr>
<%
            } else if(attrType.equals("string") && attrChoices != null && attrChoices.size() > 0){
                String strChoiceSelectSpace = "&nbsp;";
                StringBuffer sbChoiceSelect = new StringBuffer();
                sbChoiceSelect.append(strText.substring(0,strText.indexOf("</td>")));
                sbChoiceSelect.append(strChoiceSelectSpace);
                sbChoiceSelect.append(strChoiceSelectSpace);
                sbChoiceSelect.append(strChoiceSelect);
                sbChoiceSelect.append("</td>");
                strText = sbChoiceSelect.toString();
%> 
                <tr>
                    <td width="150" class="label"><%=i18nAttrName%></td>
                    <td class="inputField">
                        <select name="<%=XSSUtil.encodeForHTMLAttribute(context, strComboName)%>" extra="yes" onChange="javascript:checkEmpty('<%=XSSUtil.encodeForJavaScript(context, attrName)%>');">
                        <!-- //XSSOK -->
                            <%=strSelect%>
                        </select></td>
                        <!-- //XSSOK -->
                        <%=strText%>
                </tr>
<%
            }
            else{
%>
                <tr>
                    <td width="150" class="label"><%=i18nAttrName%></td>
                    <td class="inputField">
                        <select name="<%=XSSUtil.encodeForHTMLAttribute(context, strComboName)%>" extra="yes" onChange="javascript:checkEmpty('<%=XSSUtil.encodeForJavaScript(context, attrName)%>');">
                        <!-- //XSSOK -->
                            <%=strSelect%>
                        </select></td>
                        <!-- //XSSOK -->
                        <%=strText%>
                    </td>
                </tr>
<%
            }
        }
%>

    </table>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
