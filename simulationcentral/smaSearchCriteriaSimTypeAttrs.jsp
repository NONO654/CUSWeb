<%-- (c) Dassault Systemes, 2007, 2008 --%>

<%@page import = "java.util.HashMap"%>
<%@page import = "java.util.Map"%>

<%@page import = "matrix.db.Attribute" %>
<%@page import = "matrix.db.AttributeItr" %>
<%@page import = "matrix.db.AttributeList" %>
<%@page import = "matrix.db.AttributeType" %>
<%@page import = "matrix.db.AttributeTypeList" %>
<%@page import = "matrix.db.BusinessInterface" %>
<%@page import = "matrix.db.BusinessObject" %>
<%@page import = "matrix.db.BusinessObjectAttributes"%>
<%@page import = "matrix.db.Vault" %>
<%@page import = "matrix.db.Context" %>

<%@page import = "matrix.util.MatrixException"%>
<%@page import = "matrix.util.StringList"%>

<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "com.matrixone.apps.framework.ui.UIUtil"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import = "com.matrixone.apps.domain.util.MapList"%>
<%@page import = "com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import = "com.matrixone.apps.domain.util.UOMUtil"%>
<%@page import = "com.matrixone.apps.domain.util.i18nNow"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxI18NMethods.inc"%>

<!------- Servlet code -------->
<table border="0" width="99%" cellpadding="5" cellspacing="2">
<%
    // string operators
    final String BEGINS_WITH = "BeginsWith";
    final String ENDS_WITH = "EndsWith";
    final String INCLUDES = "Includes";
    final String IS_EXACTLY = "IsExactly";
    final String IS_NOT = "IsNot";
    final String MATCHES = "Matches";

    // Real/Integer operators
    final String IS_AT_LEAST = "IsAtLeast";
    final String IS_AT_MOST = "IsAtMost";
    final String DOES_NOT_EQUAL = "DoesNotEqual";
    final String EQUALS = "Equals";
    final String IS_LESS_THAN = "IsLessThan";
    final String IS_MORE_THAN = "IsMoreThan";
    final String IS_BETWEEN = "IsBetween";

    // Date operators
    final String IS_ON = "IsOn";
    final String IS_ON_OR_BEFORE = "IsOnOrBefore";
    final String IS_ON_OR_AFTER = "IsOnOrAfter";

    // multivaue operators
    final String MATCH = "Match";
    final String NMATCH = "NotMatch";
    final String SMATCH = "SMatch";
    final String NSMATCH = "NotSMatch";
    // IS_AT_LEAST, IS_AT_MOST, IS_LESS_THAN, IS_MORE_THAN

    // Logical operators for multivalue
    final String SELECT = "";
    final String OR = "OR";
    final String AND = "AND";

    final String langStr = request.getHeader("Accept-Language");

    String simTypeId = emxGetParameter(request, "simTypeId");
    String simTypeDisplay = emxGetParameter(request,
        "simTypeDisplay");
    simTypeDisplay = simTypeDisplay.trim();
    if (simTypeDisplay.endsWith(";"))
    {
        simTypeDisplay = simTypeDisplay.substring(0, simTypeDisplay
            .length() - 1);
    }
    String sNoAttrMsg = SimulationUtil.getI18NString(context,
        "smaSimulationCentral.AttributeGroups.search.noAttributes");

    String sError = "";

    String intrfcId = SimulationConstants.SYMBOLIC_interface_SimulationAttributes;
    String simOIDs = null;
    String[] attrTitles = null;
    String sIntrfcAttrList = "";
    boolean getTitles = true;

    try
    {
        if (simTypeId != null && simTypeId.length() > 0
            && !simTypeId.equals("*"))
        {
            // we handle mutiple attribute group searches
            // the attribute groups are separated by a "; "
            // This is done in smaSearchUtil.jsp
            simOIDs = simTypeId;
        }
        else if (simTypeDisplay != null
            && simTypeDisplay.length() > 0
            && !simTypeDisplay.equals("*") && "*".equals(simTypeId))
        {
            String[] methodargs3 = { simTypeDisplay };
            try
            {
                simOIDs = (String) JPO.invoke(context,
                    "jpo.simulation.AttributeGroup", null,
                    "getGroupOids", methodargs3, String.class);
            }
            catch (Exception ex)
            {
                sError = ErrorUtil.getMessage(ex);
            }
        }
        if (simOIDs != null)
        {
            intrfcId = simOIDs;
        }
        else if (sError.length() == 0)
        {
            // if not using groups then get global interface name
            intrfcId = SimulationUtil.getSchemaProperty(intrfcId);
            getTitles = false;
        }

        // If an interface is found, get its attributes
        if (intrfcId != null && intrfcId.length() > 0)
        {
            // Add split command to handle mutiple attribute groups
            String[] intrfcIds = intrfcId.split("; ");
            if (getTitles)
                attrTitles = new String[intrfcIds.length];
            // Contains list of form fields so that the search software
            // knows what sim type fields are on the page
            // This is loaded into a hidden field on the form
            for (int idx = 0; idx < intrfcIds.length; idx++)
            {
                if (getTitles)
                {
                    DomainObject DO = new DomainObject();
                    DO.setId(intrfcIds[idx]);
                    attrTitles[idx] = DO.getInfo(context,
                        "attribute[Title]");
                }
                HashMap programMap = new HashMap();
                programMap.put("objectId", intrfcIds[idx]);
                String[] args = JPO.packArgs(programMap);
                MapList attrML = (MapList) JPO.invoke(context,
                    "jpo.simulation.AttributeGroup", null,
                    "getAttributesTable", args, MapList.class);

                //  Create Drop downs for Data types of the Attribute
                final String sOption = "<option name=\"blank\" value=\"*\">*</option>";

                // Set options for string data type
                StringBuffer sbStrOptions = new StringBuffer(1);
                sbStrOptions.append(addOption(context,BEGINS_WITH, false,
                    langStr));
                sbStrOptions.append(addOption(context,ENDS_WITH, false,
                    langStr));
                sbStrOptions.append(addOption(context,INCLUDES, false,
                    langStr));
                sbStrOptions.append(addOption(context,IS_EXACTLY, false,
                    langStr));
                sbStrOptions.append(addOption(context,IS_NOT, false,
                    langStr));
                sbStrOptions.append(addOption(context,MATCHES, true,
                    langStr));

                // Set options for numeric data type
                StringBuffer sbRealOptions = new StringBuffer(1);
                sbRealOptions.append(addOption(context,IS_AT_LEAST, false,
                    langStr));
                sbRealOptions.append(addOption(context,IS_AT_MOST, false,
                    langStr));
                sbRealOptions.append(addOption(context,DOES_NOT_EQUAL,
                    false, langStr));
                sbRealOptions.append(addOption(context,EQUALS, true,
                    langStr));
                sbRealOptions.append(addOption(context,IS_BETWEEN, false,
                    langStr));
                sbRealOptions.append(addOption(context,IS_LESS_THAN, false,
                    langStr));
                sbRealOptions.append(addOption(context,IS_MORE_THAN, false,
                    langStr));
                
                // Set options for numeric data type
                StringBuffer sbBooleanOperators = new StringBuffer(1);
                sbBooleanOperators.append(addOption(context,DOES_NOT_EQUAL,
                    false, langStr));
                sbBooleanOperators.append(addOption(context,EQUALS, true,
                    langStr));

                // set options for date/time data type
                StringBuffer sbTimeOptions = new StringBuffer(1);
                sbTimeOptions
                    .append(addOption(context,IS_ON, true, langStr));
                sbTimeOptions.append(addOption(context,IS_ON_OR_BEFORE,
                    false, langStr));
                sbTimeOptions.append(addOption(context,IS_ON_OR_AFTER,
                    false, langStr));

                StringBuffer sbBoolOptions = new StringBuffer(
                    sOption);
                sbBoolOptions.append(addOption(context,"TRUE", false,
                    langStr));
                sbBoolOptions.append(addOption(context,"FALSE", false,
                    langStr));

                // set options for multivalue string
                StringBuffer sbStrMultiValueOptions = new StringBuffer(
                    1);
                sbStrMultiValueOptions.append(addOption(context,EQUALS,
                    true, langStr));
                sbStrMultiValueOptions.append(addOption(context,
                    DOES_NOT_EQUAL, false, langStr));
                sbStrMultiValueOptions.append(addOption(context,MATCH,
                    false, langStr));
                sbStrMultiValueOptions.append(addOption(context,NMATCH,
                    false, langStr));
                sbStrMultiValueOptions.append(addOption(context,SMATCH,false,langStr));
                sbStrMultiValueOptions.append(addOption(context,NSMATCH,false,langStr));

                // set options for multivalue Numeric
                StringBuffer sbNumMultiValueOptions = new StringBuffer(
                    1);
                sbNumMultiValueOptions.append(addOption(context,EQUALS,
                    true, langStr));
                sbNumMultiValueOptions.append(addOption(context,
                    DOES_NOT_EQUAL, false, langStr));
                sbNumMultiValueOptions.append(addOption(context,
                    IS_LESS_THAN, false, langStr));
                sbNumMultiValueOptions.append(addOption(context,
                    IS_MORE_THAN, false, langStr));
                sbNumMultiValueOptions.append(addOption(context,
                    IS_AT_LEAST, false, langStr));
                sbNumMultiValueOptions.append(addOption(context,IS_AT_MOST,
                    false, langStr));

                StringBuffer sbLogicalOperatorOptions = new StringBuffer(
                    1);
                sbLogicalOperatorOptions.append(addOption(context,SELECT,
                    true, langStr));
                sbLogicalOperatorOptions.append(addOption(context,OR,
                    false, langStr));
                sbLogicalOperatorOptions.append(addOption(context,AND,
                    false, langStr));

                // Output appropriate HTML for each attribute
                for (int ii = 0; ii < attrML.size(); ii++)
                {
                    Map attrObj = (Map) attrML.get(ii);

                    String attrName = (String) attrObj.get("name");
                    sIntrfcAttrList += "," + attrName;
                    String strComboName = "intrfcCombo_" + attrName;
                    String strTxtName = "intrfcTxt_" + attrName;
                    String strHiddenName = "intrfcType_" + attrName;

                    String attrType = (String) attrObj.get("type");
                    String attrValueType = (String) attrObj
                        .get("valuetype");

                    String displayUOM = "";

                    if (UOMUtil.isAssociatedWithDimension(context,
                        attrName))
                    {
                        String selectUnit = UOMUtil.getDBunit(
                            context, attrName);
                        String fieldName = "units_" + attrName;
                        displayUOM = UIUtil.displayUOMComboField(
                            context, attrName, selectUnit,
                            fieldName, langStr);
                        if (!displayUOM.equals(""))
                            displayUOM = "&nbsp;" + displayUOM;
                    }

                    StringBuffer sbText = new StringBuffer();
                    StringBuffer sbQueryBuilderText = new StringBuffer();
                    StringBuffer sbQueryBuilderAdd = new StringBuffer();

                    sbText.append("<input type=\"text\" name=\"");
                    sbText.append(strTxtName);
                    sbText.append("\" ");
                    sbText.append("id=\"");
                    sbText.append(strTxtName);
                    sbText.append("\" ");
                    sbText
                        .append("value=\"*\" size=\"20\" extra=\"yes\">");
                    sbText.append(displayUOM);

                    StringBuffer sbClear = new StringBuffer();

                    StringBuffer sbType = new StringBuffer();
                    sbType.append("<input type=\"hidden\" name=\"");
                    sbType.append(strHiddenName);
                    sbType.append("\" ");
                    sbType.append("value=\"");
                    sbType.append(attrType);
                    sbType.append("\" >");

                    StringBuffer sbSelect = new StringBuffer();
                    StringBuffer sbSelectLogical = new StringBuffer();

                    StringList attrChoices = (StringList) attrObj
                        .get("choicesList");

                    if ("singleval".equalsIgnoreCase(attrValueType))
                    {
                        sbClear
                        .append("&nbsp;<a class=\"dialogClear\" href=\"#\" ");
                    sbClear
                        .append("onclick='javascript:clearInterface(\"");
                    sbClear.append(strTxtName);
                    sbClear.append("\"); return false;");
                    sbClear.append("'>Clear</a>");
                        // If something has choices then just show them
                        if (attrChoices != null
                            && attrChoices.size() > 0)
                        {
                            sbSelect.append("<select name=\"");
                            sbSelect.append(strComboName);
                            sbSelect.append("\" size=\"1\">");
                            sbSelect
                                .append("<option value=\"\" selected>*</option>");

                            for (int j = 0; j < attrChoices.size(); j++)
                            {
                                String choice = (String) attrChoices
                                    .get(j);
                                sbSelect.append(addOption(context,choice,
                                    false, langStr));
                            }
                            sbSelect.append("</select>");

                            sbText.setLength(0);
                            sbClear.setLength(0);
                        }
                        else if (attrType.equals("string"))
                        {
                            // Just do the text box
                        }
                        else if (attrType.equals("real")
                            || attrType.equals("integer"))
                        {
                            sbSelect.append("<select name=\"");
                            sbSelect.append(strComboName);
                            sbSelect.append("\" extra=\"yes\" >");
                            sbSelect.append(sbRealOptions);
                            sbSelect.append("</select>");

                            sbText.insert(0, "&nbsp;");
                        }
                        else if (attrType.equals("timestamp"))
                        {
                            sbSelect.append("<select name=\"");
                            sbSelect.append(strComboName);
                            sbSelect.append("\" extra=\"yes\" >");
                            sbSelect.append(sbTimeOptions);
                            sbSelect.append("</select>");

                            sbText = new StringBuffer();
                            sbText
                                .append("<input READONLY type=\"text\" name=\"");
                            sbText.append(strTxtName);
                            sbText
                                .append("\" value=\"*\" size=\"20\" extra=\"yes\" ");
                            sbText
                                .append("onFocus=\"this.blur()\">&nbsp;&nbsp;");
                            sbText
                                .append("<a href='javascript:showCalendar(\"editDataForm\",\"");
                            sbText.append(strTxtName);
                            sbText.append("\",\"\");'>");
                            sbText
                                .append("<img src=\"../common/images/iconSmallCalendar.gif\" border=0></a>");
                        }
                        else if (attrType.equals("boolean"))
                        {
                            sbSelect.append("<select name=\"");
                            sbSelect.append(strComboName);
                            sbSelect.append("\" extra=\"yes\" >");
                            sbSelect.append(sbBoolOptions);
                            sbSelect.append("</select>");

                            sbText.setLength(0);
                            sbClear.setLength(0);
                        }
                    }
                    else if ("multival"
                        .equalsIgnoreCase(attrValueType))
                    {
                        String strLogicalComboName = "intrfcLogicalCombo_"
                            + attrName;
                        String strQueryTxtName = "intrfcQueryTxt_"
                            + attrName;
                        String strButtonName = "intrfcButton_"
                            + attrName;

                        sbQueryBuilderText = new StringBuffer();
                        sbQueryBuilderText
                            //.append("<input READONLY type=\"text\" name=\"");
                        .append("<input type=\"text\" name=\"");
                        sbQueryBuilderText.append(strQueryTxtName);
                        sbQueryBuilderText.append("\" id=\"");
                        sbQueryBuilderText.append(strQueryTxtName);
                        sbQueryBuilderText
                            .append("\" value=\"*\" size=\"60\" extra=\"yes\" />");

                        sbSelectLogical.append("<select name=\"");
                        sbSelectLogical.append(strLogicalComboName);
                        sbSelectLogical.append("\" id=\"");
                        sbSelectLogical.append(strLogicalComboName);
                        sbSelectLogical
                            .append("\" extra=\"yes\" >");
                        sbSelectLogical
                            .append(sbLogicalOperatorOptions);
                        sbSelectLogical.append("</select>");

                        sbQueryBuilderAdd = new StringBuffer();
                        sbQueryBuilderAdd
                            .append("&nbsp;<a class=\"button\" href=\"#\" ");
                        sbQueryBuilderAdd
                            .append("onclick='javascript:buildQuery(\"");
                        sbQueryBuilderAdd.append(strComboName);
                        sbQueryBuilderAdd.append("\", \"");
                        sbQueryBuilderAdd.append(strTxtName);
                        sbQueryBuilderAdd.append("\", \"");
                        sbQueryBuilderAdd
                            .append(strLogicalComboName);
                        sbQueryBuilderAdd.append("\", \"");
                        sbQueryBuilderAdd.append(strQueryTxtName);
                        sbQueryBuilderAdd.append("\", \"");
                        sbQueryBuilderAdd.append(attrType);
                        sbQueryBuilderAdd.append("\", \"");
                        sbQueryBuilderAdd.append(attrName);
                        sbQueryBuilderAdd.append("\"); return false;");
                        sbQueryBuilderAdd.append("'>Add</a>");

                        sbClear
                        .append("&nbsp;<a class=\"dialogClear\" href=\"#\" ");
                    sbClear
                        .append("onclick='javascript:clearInterface(\"");
                    sbClear.append(strQueryTxtName);
                    sbClear.append("\");  return false;");
                    sbClear.append("'>Clear</a>");
                    /**
                    * Changes for MultiValue Attribute - x86
                    * Adding choices as dropdown for multivalue attributes
                    */
                    if (attrChoices != null
                        && attrChoices.size() > 0)
                    {
                        sbText.setLength(0);
                        sbText.append("<select name=\"");
                        sbText.append(strTxtName);
                        sbText.append("\" id=\"");
                        sbText.append(strTxtName);
                        sbText.append("\" size=\"1\">");
                        sbText
                            .append("<option value=\"\" selected>*</option>");
                        for (int j = 0; j < attrChoices.size(); j++)
                        {
                            String choice = (String) attrChoices
                                .get(j);
                            sbText.append(addOption(context,choice,
                                false, langStr));
                        }
                        sbText.append("</select>");
                    }
                    // Changes ends here - x86
                        if (attrType.equals("real")
                            || attrType.equals("integer"))
                        {
                            sbSelect.append("<select name=\"");
                            sbSelect.append(strComboName);
                            sbSelect.append("\" id=\"");
                            sbSelect.append(strComboName);
                            sbSelect.append("\" extra=\"yes\" >");
                            sbSelect.append(sbNumMultiValueOptions);
                            sbSelect.append("</select>");

                            sbText.insert(0, "&nbsp;");
                        }
                        else if (attrType.equals("string"))
                        {
                            sbSelect.append("<select name=\"");
                            sbSelect.append(strComboName);
                            sbSelect.append("\" id=\"");
                            sbSelect.append(strComboName);
                            sbSelect.append("\" extra=\"yes\" >");
                            sbSelect.append(sbStrMultiValueOptions);
                            sbSelect.append("</select>");

                            sbText.insert(0, "&nbsp;");
                        }
                        else if (attrType.equals("boolean"))
                        {
                            sbSelect.append("<select name=\"");
                            sbSelect.append(strComboName);
                            sbSelect.append("\" id=\"");
                            sbSelect.append(strComboName);
                            sbSelect.append("\" extra=\"yes\" >");
                            sbSelect.append(sbBooleanOperators);
                            sbSelect.append("</select>");

                            sbText.setLength(0);
                            sbText.append("<select name=\"");
                            sbText.append(strTxtName);
                            sbText.append("\" id=\"");
                            sbText.append(strTxtName);
                            sbText.append("\" extra=\"yes\" >");
                            sbText.append(sbBoolOptions);
                            sbText.append("</select>");
                            
                            //sbClear.setLength(0);
                        }
                    }

                    String i18nAttrName = i18nNow.getAttributeI18NString(
                        attrName, langStr);

                    // if attribute is comming from a group selection
                    // prepend the group name to the attribute name
                    if (attrTitles != null)
                    {
                        i18nAttrName = attrTitles[idx] + " | "
                            + i18nAttrName;
                    }
%>
	            <tr>
            <td width="150" class="label"><%=i18nAttrName%></td>
	            <td class="inputField">
	            <%=sbSelect.toString()%>
	            <%=sbText.toString()%>
	            <%=sbSelectLogical.toString()%>
	            <%=sbClear.toString()%>
	            <%=sbType.toString()%>
	            <BR>
	            <%=sbQueryBuilderText.toString()%>
	            <%=sbQueryBuilderAdd.toString()%>
	            </td>
	            </tr>
	            
	            
<%
	            	                }
	            	                        }

	            	                    }
	            	                }
	            	                catch (Exception ex)
	            	                {
	            	                    sError = ErrorUtil.getMessage(ex);
	            	                }
	            	                // Remove leading comma
	            	                if (sIntrfcAttrList.startsWith(","))
	            	                    sIntrfcAttrList = sIntrfcAttrList.substring(1);

	            	                if (sIntrfcAttrList.length() == 0 && sError.length() == 0)
	            	                {
	            	            %>
	        <tr><td colspan="2">
	        <%=sNoAttrMsg%>
	        </td></tr>
	        </table>
<%
    }
    else if (sIntrfcAttrList.length() == 0 && sError.length() > 0)
    {
%>
	            <tr><td colspan="2">
	            <%=sError%>
	            </td></tr>
	            </table>
<%
    }
    else
    {
%>
	        <tr><td colspan="2">
	        <input type="hidden" name="intrfcAttrList" value="<%=sIntrfcAttrList%>">
	        </td></tr>
	        </table>
<%
    }
%>


<%!// Declare class variable

    private StringBuffer addOption(Context context,String option, boolean selected,
        String langStr) throws FrameworkException
    {
        StringBuffer sbOption = new StringBuffer(1);

        try
        {
            final String RESOURCE = "emxFramework.AdvancedSearch";
            String optionTrans = EnoviaResourceBundle.getProperty(context, RESOURCE, context.getLocale(),option);

            sbOption.append("<option name='");
            sbOption.append(option);
            sbOption.append("' value='");
            sbOption.append(option);
            if (selected)
                sbOption.append("' selected>");
            else
                sbOption.append("'>");
            sbOption.append(optionTrans);
            sbOption.append("</option>");
        }
        catch (Exception e)
        {
        }

        return sbOption;
    }%>


<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

