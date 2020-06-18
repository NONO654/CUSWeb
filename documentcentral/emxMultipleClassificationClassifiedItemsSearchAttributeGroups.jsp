<%-- emMultipleClassificationClassifiedItemsSearchAttributeGroups.jsp
   Copyright (c) 1998-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc. Copyright notice is precautionary only and does not
   evidence any actual or intended publication of such program
   static const char RCSID[] = $Id: emMultipleClassificationClassifiedItemsSearchAttributeGroups.jsp.rca 1.4.4.4 Wed Oct 22 16:54:21 2008 przemek Experimental przemek $
--%>

<%@page import="com.matrixone.apps.classification.*,com.matrixone.apps.domain.util.UOMUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.PersonUtil"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.common.Person"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="java.util.*"%>

<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxJSValidation.inc"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file="../documentcentral/emxLibraryCentralUtils.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<emxUtil:localize id="i18nId" bundle="emxLibraryCentralStringResource"
	locale='<%= request.getHeader("Accept-Language") %>' />
<%
String languageStr = request.getHeader("Accept-Language");
String objectId = emxGetParameter(request, "objectId");
%>
<%!
// constant declarations
    //
    final String MCM_STRING_RESOURCE_FILE = "emxLibraryCentralStringResource";

    final String KEY_ATTRIBUTE_GROUP_NAME = "attributeGroupName";

    final String KEY_ATTRIBUTES = "attributes";

    final String KEY_ATTRIBUTE_NAME = "attributeName";

    final String KEY_ATTRIBUTE_CHOICES = "attributeChoices";

    final String KEY_ATTRIBUTE_DATA_TYPE = "attributeDataType";

    final String KEY_ATTRIBUTE_SELECT_OPERATOR_OPTIONS = "attributeSelectOperatorOptions";

    final String KEY_ATTRIBUTE_SELECT_VALUE_OPTIONS = "attributeSelectValueOptions";

    final String KEY_ATTRIBUTE_TEXTBOX_ENTER_VALUE = "attributeTextboxEnterValue";

    final String DATA_TYPE_STRING = "string";

    final String DATA_TYPE_REAL = "real";

    final String DATA_TYPE_INTEGER = "integer";

    final String DATA_TYPE_TIMESTAMP = "timestamp";

    final String DATA_TYPE_BOOLEAN = "boolean";

    final String WILDCARD_ALL = "*";

    final String TEXTBOX_WIDTH = "20";
    final String MCM_OPERATOR_PREFIX = "MCM_operator_";
    final String MCM_SELECTVALUE_PREFIX = "MCM_selectValue_";
    final String MCM_ENTERVALUE_PREFIX = "MCM_enterValue_";
    final String MCM_ENTERVALUE_UNIT_PREFIX = "MCM_enterValue_units_";

    //string operator conversions
    String strMatrixBeginsWith = "";

    String strMatrixEndsWith = "";

    String strMatrixIncludes = "";

    String strMatrixIsExactly = "";

    String strMatrixIsNot = "";

    String strMatrixMatches = "";

    //real/integer
    String strMatrixIsAtLeast = "";

    String strMatrixIsAtMost = "";

    String strMatrixDoesNotEqual = "";

    String strMatrixEquals = "";

    String strMatrixIsLessThan = "";

    String strMatrixIsMoreThan = "";

    String strMatrixIsBetween = "";

    //timestamp
    String strMatrixIsOn = "";

    String strMatrixIsOnOrBefore = "";

    String strMatrixIsOnOrAfter = "";

    StringBuffer strbufStrInclude = null;

    StringBuffer strbufRealInclude = null;

    StringBuffer strbufTimeInclude = null;

    StringBuffer strbufBooleanInclude = null;

    // Prepare the partial select control for different datatypes
    String strSelectForString = "";

    String strSelectForNumeric = "";

    String strSelectForTimestamp = "";

    String strSelectForBoolean = "";

    String strSelectOptionAll = "<option name=blank value=\"" + WILDCARD_ALL
            + "\"></option>";
%>

<%
//string operator conversions
            strMatrixBeginsWith = EnoviaResourceBundle.getProperty(context,
            		MCM_STRING_RESOURCE_FILE,
            		new Locale(languageStr),
                    "emxMultipleClassification.AdvancedSearchWithClassification.BeginsWith"
                    );
            strMatrixEndsWith = EnoviaResourceBundle.getProperty(context,
            		MCM_STRING_RESOURCE_FILE,
            		new Locale(languageStr),
                    "emxMultipleClassification.AdvancedSearchWithClassification.EndsWith"
                    );
            strMatrixIncludes = EnoviaResourceBundle.getProperty(context,
            		MCM_STRING_RESOURCE_FILE,
            		new Locale(languageStr),
                    "emxMultipleClassification.AdvancedSearchWithClassification.Includes"
                    );
            strMatrixIsExactly = EnoviaResourceBundle.getProperty(context,
            		MCM_STRING_RESOURCE_FILE,
            		new Locale(languageStr),
                    "emxMultipleClassification.AdvancedSearchWithClassification.IsExactly"
                    );
            strMatrixIsNot = EnoviaResourceBundle.getProperty(context,
            		MCM_STRING_RESOURCE_FILE,
            		new Locale(languageStr),
                    "emxMultipleClassification.AdvancedSearchWithClassification.IsNot"
                    );
            strMatrixMatches = EnoviaResourceBundle.getProperty(context,
            		MCM_STRING_RESOURCE_FILE,
            		new Locale(languageStr),
                    "emxMultipleClassification.AdvancedSearchWithClassification.Matches"
                    );
            //real/integer
            strMatrixIsAtLeast = EnoviaResourceBundle.getProperty(context,
            		MCM_STRING_RESOURCE_FILE,
            		new Locale(languageStr),
                    "emxMultipleClassification.AdvancedSearchWithClassification.IsAtLeast"
                    );
            strMatrixIsAtMost = EnoviaResourceBundle.getProperty(context,
            		MCM_STRING_RESOURCE_FILE,
            		new Locale(languageStr),
                    "emxMultipleClassification.AdvancedSearchWithClassification.IsAtMost"
					);
            strMatrixDoesNotEqual = EnoviaResourceBundle.getProperty(context,
            		MCM_STRING_RESOURCE_FILE,
            		new Locale(languageStr),
                    "emxMultipleClassification.AdvancedSearchWithClassification.DoesNotEqual"
                    );
            strMatrixEquals = EnoviaResourceBundle.getProperty(context,
            		MCM_STRING_RESOURCE_FILE,
            		new Locale(languageStr),
                    "emxMultipleClassification.AdvancedSearchWithClassification.Equals"
                    );
            strMatrixIsLessThan = EnoviaResourceBundle.getProperty(context,
            		MCM_STRING_RESOURCE_FILE,
            		new Locale(languageStr),
                    "emxMultipleClassification.AdvancedSearchWithClassification.IsLessThan"
                    );
            strMatrixIsMoreThan = EnoviaResourceBundle.getProperty(context,
            		MCM_STRING_RESOURCE_FILE,
            		new Locale(languageStr),
                    "emxMultipleClassification.AdvancedSearchWithClassification.IsMoreThan"
                    );
            strMatrixIsBetween = EnoviaResourceBundle.getProperty(context,
            		MCM_STRING_RESOURCE_FILE,
            		new Locale(languageStr),
                    "emxMultipleClassification.AdvancedSearchWithClassification.IsBetween"
                    );
            //timestamp
            strMatrixIsOn = EnoviaResourceBundle.getProperty(context,
            		MCM_STRING_RESOURCE_FILE,
            		new Locale(languageStr),
                    "emxMultipleClassification.AdvancedSearchWithClassification.IsOn"
                    );
            strMatrixIsOnOrBefore = EnoviaResourceBundle.getProperty(context,
            		MCM_STRING_RESOURCE_FILE,
            		new Locale(languageStr),
                    "emxMultipleClassification.AdvancedSearchWithClassification.IsOnOrBefore"
                    );
            strMatrixIsOnOrAfter = EnoviaResourceBundle.getProperty(context,
            		MCM_STRING_RESOURCE_FILE,
            		new Locale(languageStr),
                    "emxMultipleClassification.AdvancedSearchWithClassification.IsOnOrAfter"
                    );

            // string
            StringBuffer sbuf = new StringBuffer();
            sbuf.append(strSelectOptionAll);
            sbuf.append("<option name=\"");
            sbuf.append(strMatrixBeginsWith);
            sbuf.append("\" value=\"");
            sbuf.append("BeginsWith");
            sbuf.append("\">");
            sbuf.append(strMatrixBeginsWith);
            sbuf.append("</option>");
            sbuf.append("<option name=\"");
            sbuf.append(strMatrixEndsWith);
            sbuf.append("\" value=\"");
            sbuf.append("EndsWith");
            sbuf.append("\">");
            sbuf.append(strMatrixEndsWith);
            sbuf.append("</option>");
            sbuf.append("<option name=\"");
            sbuf.append(strMatrixIncludes);
            sbuf.append("\" value=\"");
            sbuf.append("Includes");
            sbuf.append("\">");
            sbuf.append(strMatrixIncludes);
            sbuf.append("</option>");
            sbuf.append("<option name=\"");
            sbuf.append(strMatrixIsExactly);
            sbuf.append("\" value=\"");
            sbuf.append("IsExactly");
            sbuf.append("\">");
            sbuf.append(strMatrixIsExactly);
            sbuf.append("</option>");
            sbuf.append("<option name=\"");
            sbuf.append(strMatrixIsNot);
            sbuf.append("\" value=\"");
            sbuf.append("IsNot");
            sbuf.append("\">");
            sbuf.append(strMatrixIsNot);
            sbuf.append("</option>");
            sbuf.append("<option name=\"");
            sbuf.append(strMatrixMatches);
            sbuf.append("\" value=\"");
            sbuf.append("Matches");
            sbuf.append("\">");
            sbuf.append(strMatrixMatches);
            sbuf.append("</option>");
            strSelectForString = sbuf.toString();
            // numeric
            sbuf = new StringBuffer();
            sbuf.append(strSelectOptionAll);
            sbuf.append("<option name=\"");
            sbuf.append(strMatrixIsAtLeast);
            sbuf.append("\" value=\"");
            sbuf.append("IsAtLeast");
            sbuf.append("\">");
            sbuf.append(strMatrixIsAtLeast);
            sbuf.append("</option>");
            sbuf.append("<option name=\"");
            sbuf.append(strMatrixIsAtMost);
            sbuf.append("\" value=\"");
            sbuf.append("IsAtMost");
            sbuf.append("\">");
            sbuf.append(strMatrixIsAtMost);
            sbuf.append("</option>");
            sbuf.append("<option name=\"");
            sbuf.append(strMatrixDoesNotEqual);
            sbuf.append("\" value=\"");
            sbuf.append("DoesNotEqual");
            sbuf.append("\">");
            sbuf.append(strMatrixDoesNotEqual);
            sbuf.append("</option>");
            sbuf.append("<option name=\"");
            sbuf.append(strMatrixEquals);
            sbuf.append("\" value=\"");
            sbuf.append("Equals");
            sbuf.append("\">");
            sbuf.append(strMatrixEquals);
            sbuf.append("</option>");
            sbuf.append("<option name=\"");
            sbuf.append(strMatrixIsLessThan);
            sbuf.append("\" value=\"");
            sbuf.append("IsLessThan");
            sbuf.append("\">");
            sbuf.append(strMatrixIsLessThan);
            sbuf.append("</option>");
            sbuf.append("<option name=\"");
            sbuf.append(strMatrixIsMoreThan);
            sbuf.append("\" value=\"");
            sbuf.append("IsMoreThan");
            sbuf.append("\">");
            sbuf.append(strMatrixIsMoreThan);
            sbuf.append("</option>");
            sbuf.append("<option name=\"");
            sbuf.append(strMatrixIsBetween);
            sbuf.append("\" value=\"");
            sbuf.append("IsBetween");
            sbuf.append("\">");
            sbuf.append(strMatrixIsBetween);
            sbuf.append("</option>");
            strSelectForNumeric = sbuf.toString();
            //timestamp
            sbuf = new StringBuffer();
            sbuf.append(strSelectOptionAll);
            sbuf.append("<option name=\"");
            sbuf.append(strMatrixIsOn);
            sbuf.append("\" value=\"");
            sbuf.append("IsOn");
            sbuf.append("\">");
            sbuf.append(strMatrixIsOn);
            sbuf.append("</option>");
            sbuf.append("<option name=\"");
            sbuf.append(strMatrixIsOnOrBefore);
            sbuf.append("\" value=\"");
            sbuf.append("IsOnOrBefore");
            sbuf.append("\">");
            sbuf.append(strMatrixIsOnOrBefore);
            sbuf.append("</option>");
            sbuf.append("<option name=\"");
            sbuf.append(strMatrixIsOnOrAfter);
            sbuf.append("\" value=\"");
            sbuf.append("IsOnOrAfter");
            sbuf.append("\">");
            sbuf.append(strMatrixIsOnOrAfter);
            sbuf.append("</option>");
            strSelectForTimestamp = sbuf.toString();
            //boolean
            sbuf = new StringBuffer();
            sbuf.append(strSelectOptionAll);
            sbuf.append("<option name=\"");
            sbuf.append(strMatrixIsExactly);
            sbuf.append("\" value=\"");
            sbuf.append("IsExactly");
            sbuf.append("\">");
            sbuf.append(strMatrixIsExactly);
            sbuf.append("</option>");
            sbuf.append("<option name=\"");
            sbuf.append(strMatrixIsNot);
            sbuf.append("\" value=\"");
            sbuf.append("IsNot");
            sbuf.append("\">");
            sbuf.append(strMatrixIsNot);
            sbuf.append("</option>");
            strSelectForBoolean = sbuf.toString();

            %>

<%!
/**
     * Get the partial HTML code for the select options list box.
     *
     * @param strAttributeDataType The data type of the attribute
     * @return the partial HTML code for the select options list box.
     */
    public String getHTMLPartialSelectOptionsForOperator(
            String strAttributeDataType) {
        if (DATA_TYPE_STRING.equals(strAttributeDataType))
            return strSelectForString;

        if (DATA_TYPE_INTEGER.equals(strAttributeDataType))
            return strSelectForNumeric;

        if (DATA_TYPE_REAL.equals(strAttributeDataType))
            return strSelectForNumeric;

        if (DATA_TYPE_TIMESTAMP.equals(strAttributeDataType))
            return strSelectForTimestamp;

        if (DATA_TYPE_BOOLEAN.equals(strAttributeDataType))
            return strSelectForBoolean;

        return "";
    }

    /**
     * Throws the FrameworkException object
     *
     * @param strMessage The message to be notified/exception message.
     * @throws FrameworkException
     */
    public void frameworkException(String strMessage) throws FrameworkException {
        throw new FrameworkException(strMessage);
    }

    /**
     * Checks if the String oblect is either null, "" or "null"
     *
     * @param strValue The string to be checked
     * @return true if the string to be checked is either null, "null" or "" otherwise false
     */
    public boolean isNothing(String strValue) {
        if (strValue == null || "null".equals(strValue) || "".equals(strValue)) {
            return true;
        }
        return false;
    }

    /**
     * Makes the null of "null" string object to "".
     *
     * @param strValue The string object
     * @return The non null string object
     */
    public String makeNonNull(String strValue) {
        if (strValue == null || "null".equals(strValue)) {
            strValue = "";
        }
        return strValue;
    }

    /**
     * Trims the spaces from both ends of the string object. If String object is null then result is "".
     *
     * @param strValue The String object to be processed
     * @return The trimmed String object. If String object is null then result is "".
     */
    public String trim(String strValue) {
        if (strValue == null) {
            return "";
        }
        return strValue.trim();
    }

    /**
     * Gets the name of the 'Operator' list box.
     *
     * @param strAttributeName The name of the attribute
     * @return The name of the 'Operator' list box
     */
    public String getNameOfOperatorListBox(String strAttributeName) {
        return MCM_OPERATOR_PREFIX + strAttributeName;
    }

    /**
     * Gets the name of the 'Select Value' text box.
     *
     * @param strAttributeName The name of the attribute
     * @return The name of the 'Select Value' text box
     */
    public String getNameOfSelectValueListBox(String strAttributeName) {
        return MCM_SELECTVALUE_PREFIX + strAttributeName;
    }

    /**
     * Gets the name of the 'Enter Value' text box.
     *
     * @param strAttributeName The name of the attribute
     * @return The name of the 'Enter Value' text box
     */
    public String getNameOfEnterValueTextBox(String strAttributeName) {
        return MCM_ENTERVALUE_PREFIX + strAttributeName;
    }

    /**
     * Forms the partial HTML code for the Select Value list box.
     *
     * @param strlistChoices The StringList object containing the choices.
     * @return The partial HTML code for the Select Value list box.
     */
    public String getHTMLPartialSelectOptionsForSelectValue(
            Map mapChoices) {
        String strHTML = "";

        if (mapChoices == null || mapChoices.size() <= 0) {
            return strHTML;
        }

        StringBuffer sbuf = new StringBuffer();
        sbuf.append(strSelectOptionAll);
        
        java.util.Set strlistChoices = mapChoices.keySet();
        
        for (Iterator choiceItr = strlistChoices.iterator();choiceItr.hasNext();) {
            String strChoiceOrig = (String) choiceItr.next();
            if (isNothing(strChoiceOrig)) {
            	strChoiceOrig = "";
            }
            
            String strChoice = (String)mapChoices.get(strChoiceOrig);
            sbuf.append("<option name=\"");
            sbuf.append(strChoiceOrig);
            sbuf.append("\" value=\"");
            sbuf.append(strChoiceOrig);
            sbuf.append("\">");
            sbuf.append(strChoice);
            sbuf.append("</option>");
        }//for !

        strHTML = sbuf.toString();
        return strHTML;
    }

    /**
     * Forms the HTML code for the 'Enter Value' text box.
     *
     * @param strAttributeDataType The data type of the attribute
     * @param strEnterValueTextBoxName The name of the 'Enter Value' text box.
     * @return The HTML code for the 'Enter Value' text box.
     */
    // Changes done by PSA11 start 
    public String getHTMLTextBoxForEnterValue(Context context, String strAttributeDataType,
            String strAttributeName, String langStr, int count, String grpName) throws Exception{
        String strEnterValueTextBoxName = getNameOfEnterValueTextBox(strAttributeName);
        String strEnterValueTextBoxHTMLCode = ""; 
        if (DATA_TYPE_TIMESTAMP.equals(strAttributeDataType)) {
            strEnterValueTextBoxHTMLCode = "<input READONLY type=\"text\" id=\"" + grpName + "_text_Date" + count + "\" name=\""
                    + strEnterValueTextBoxName
                    + "\" value=\"\" size=\""
                    + TEXTBOX_WIDTH
                    + "\" extra=\"yes\" onFocus=\"this.blur();generateSelection(this)\""
                    + ">&nbsp;&nbsp;<a href='javascript:showCalendar(\"SearchForm\",\""
                    + strEnterValueTextBoxName
                    + "\",\"\");' id=\"" + grpName + "_text_Date" + count + "\" onFocus=\"return generateSelection(this);\">"
                    + "<img src=\"../common/images/iconSmallCalendar.gif\" border=0></a>";
        } else if (DATA_TYPE_STRING.equals(strAttributeDataType)) {
            strEnterValueTextBoxHTMLCode = "<input type=\"text\" id=\"" + grpName + "_text_String" + count + "\" name=\""
                    + strEnterValueTextBoxName + "\" value=\"" + WILDCARD_ALL
                    + "\" size=\"" + TEXTBOX_WIDTH + "\" extra=\"yes\">";
        } else if(DATA_TYPE_BOOLEAN.equals(strAttributeDataType)) {
        	strEnterValueTextBoxHTMLCode = "<input type=\"text\" id=\"" + grpName + "_text_Bool" + count + "\" name=\""
                    + strEnterValueTextBoxName + "\" value=\"" + WILDCARD_ALL
                    + "\" size=\"" + TEXTBOX_WIDTH + "\" extra=\"yes\">";        	
        } else if(DATA_TYPE_INTEGER.equals(strAttributeDataType) 
        		|| DATA_TYPE_REAL.equals(strAttributeDataType)) {
            String displayUOM = "";
            boolean associateWithDimension = UOMUtil.isAssociatedWithDimension(context, strAttributeName);
            if (associateWithDimension)
            {
                String selectedUnit = UOMUtil.getDBunit(context, strAttributeName);
                String fieldName = getNameOfEnterValueTextBox("units_" + strAttributeName);

                displayUOM = UIUtil.displayUOMComboField(context, strAttributeName, selectedUnit, fieldName, langStr);
                if (!"".equals(displayUOM)) displayUOM = "&nbsp;" + displayUOM;
            }
            if(DATA_TYPE_INTEGER.equals(strAttributeDataType)) {
                strEnterValueTextBoxHTMLCode = "<input type=\"text\" id=\"" + grpName + "_text_Int" + count + "\" name=\""
                        + strEnterValueTextBoxName + "\" value=\"" + WILDCARD_ALL
                        + "\" size=\"" + TEXTBOX_WIDTH + "\" extra=\"yes\" onFocus=\"generateSelection(this)\">" + displayUOM;            	
            } else {
                strEnterValueTextBoxHTMLCode = "<input type=\"text\" id=\"" + grpName + "_text_Real" + count + "\" name=\""
                        + strEnterValueTextBoxName + "\" value=\"" + WILDCARD_ALL
                        + "\" size=\"" + TEXTBOX_WIDTH + "\" extra=\"yes\" onFocus=\"generateSelection(this)\">" + displayUOM;              	
            }
        }
        return strEnterValueTextBoxHTMLCode;
    }
// Changes done by PSA11 end    
%>


<%
String derivedOrDerivative =  emxGetParameter(request, "derivedOrDerivative");

if(derivedOrDerivative==null || "".equals(derivedOrDerivative) || "null".equals(derivedOrDerivative) || (!derivedOrDerivative.equals("true") && !derivedOrDerivative.equals("false")))
{
    derivedOrDerivative = "false";
}
// get the RDO value selected by user from combo box
String selectedRDO = emxGetParameter(request, "RDO");
if(selectedRDO == null)
{
    selectedRDO = "";
}
//set the selected RDO value as a preference for User
Person.setDesignResponsibilityInSearch(context,selectedRDO);

//retrieving the RDO values available in emxMultipleClassification.properties file.
StringList _attributeGrRDO = FrameworkUtil.split(EnoviaResourceBundle.getProperty(context,"emxMultipleClassification.AttributeGroups.OrganizationAttributes"),",");


    boolean hasSpecialAttribute;                             //to check whether the attribute group is having Special attribute or not
    boolean isSpecialAttribute;                              //to check whether the attribute is special or not
    StringList lstSpecialAttr = new StringList();        //to store all Special attributes

ArrayList arrlistAttributes = new ArrayList();
            MapList maplistAttributeGroups = new MapList();
            Map attributeMaps = null;

// IR-055763V6R2011x - Start
        StringList strlistAttributeGroups = new StringList();
        if(derivedOrDerivative.equals("true"))
        {
            attributeMaps = (Map) ClassificationUtil.getSortAttributeGroups(context, objectId, languageStr, true, true, false);
            if (attributeMaps != null) {
                strlistAttributeGroups = (StringList) attributeMaps.get("sortedAttributeGroupList");
            }
        }else {
            attributeMaps = (Map) ClassificationUtil.getSortAttributeGroups(context, objectId, languageStr, false, false, true);
            Map mTemp     = (Map) ClassificationUtil.getSortAttributeGroups(context, objectId, languageStr, true, true, false);
            if (attributeMaps != null) {
                java.util.Set attrSet = new HashSet((StringList) attributeMaps.get("sortedAttributeGroupList"));
                attrSet.removeAll((StringList) mTemp.get("sortedAttributeGroupList"));
                strlistAttributeGroups.addAll(attrSet);
            }
        }
// IR-055763V6R2011x - End

        if (strlistAttributeGroups != null && strlistAttributeGroups.size()>0) {
            for (int i = 0; i < strlistAttributeGroups.size(); i++) {
            hasSpecialAttribute = false;                                // for each group initially 'hasAccess' will be false, by default
            lstSpecialAttr.clear();
                String strAttributeGroupName = trim((String) strlistAttributeGroups
                        .elementAt(i));
                StringList strlistAttributes = new StringList();

                if (strAttributeGroupName != null) {
                    strlistAttributes = (StringList) attributeMaps
                            .get(strAttributeGroupName);
                }
                HashMap mapAttributeGroup = new HashMap(2);
                mapAttributeGroup.clear();
                mapAttributeGroup.put(KEY_ATTRIBUTE_GROUP_NAME,strAttributeGroupName);              
                if (strlistAttributes != null && strlistAttributes.size() > 0) {
                    MapList maplistAttributes = new MapList();
                    // To distinguish two textboxes or select operator boxes of the same datatype, count is required.
                    // To distinguish textboxes from two different attribute groups, its name is also required.
					// Changes done by PSA11 start(IR-537247-3DEXPERIENCER2018x).
					int countString = 0;
                    int countBool = 0;
                    int countInt = 0;
                    int countReal = 0;
                    int countDate = 0;
                    String grpName = "";
                    boolean attributeGroupContainsSpecialCharacter = java.util.regex.Pattern.compile("[-'.!&()/;^_`{}~+]").matcher(strAttributeGroupName).find();
                    if(attributeGroupContainsSpecialCharacter){
                    	grpName = strAttributeGroupName.trim().replaceAll("[-'.!&()/;^_`{}~+]", "");
                    	grpName = (grpName + new Random().nextInt()).replaceAll("-", "");
                    } else {
                    	grpName = strAttributeGroupName.trim();
                    }					
					// Changes done by PSA11 end.
                    for (int j = 0; j < strlistAttributes.size(); j++) {
                        // Find the name of the attribute
                        String strAttributeName = trim((String) strlistAttributes
                                .elementAt(j));

                        if (isNothing(strAttributeName)) {
                            continue;
                        }//if !

                        // Remember this attribute
                        if (!arrlistAttributes.contains(strAttributeName)) {
                            arrlistAttributes.add(strAttributeName);
                        }

                        String strAttributeDataType = "";
                        StringList strlistChoices = new StringList();

                        // Find the type, choices of the attribute
                        try {
                            AttributeType attributeType = new AttributeType(
                                    strAttributeName);
                            attributeType.open(context);
                            strAttributeDataType = trim(attributeType
                                    .getDataType());
                            StringList strlistTempAttributeChoices = attributeType
                                    .getChoices();
                            attributeType.close(context);

                            if (isNothing(strAttributeDataType)) {
                                strAttributeDataType = "";
                            }//if !
                            if (strlistTempAttributeChoices != null) {
                                strlistChoices = strlistTempAttributeChoices;
                            }
                        } catch (Exception exp) {
                            frameworkException("Exception caught while processing attribute group '"
                                    + strAttributeGroupName
                                    + "':"
                                    + exp.getMessage());
                        }

                        HashMap mapAttribute = new HashMap();
                        mapAttribute.put(KEY_ATTRIBUTE_NAME, strAttributeName);
                        mapAttribute.put(KEY_ATTRIBUTE_DATA_TYPE,
                                strAttributeDataType);

                        isSpecialAttribute = false;   // if any attribute name is same as that of the mentioned in the Properties file, then it will be treated as Special attribute
                        for (int z=0 ; z<_attributeGrRDO.size() ; z++)
                        {
                        if (_attributeGrRDO.get(z).toString().equals(strAttributeName))
                            {
                                    isSpecialAttribute = true;
                                    lstSpecialAttr.addElement(strAttributeName);
                            }                       
                        }
                        
                        if(selectedRDO.equals(strAttributeName))
                        {
                            hasSpecialAttribute = true;
                        }
                        
                        DomainObject dObj = new DomainObject(objectId);
                        String attributeValue = dObj.getAttributeValue(context,strAttributeName);
                        // all attributes which are null or special attribute or have value #DENIED1, will NOT be displyed in the Properties file.
                    if (!attributeValue.equals(null) && !(isSpecialAttribute) && !attributeValue.equals("#DENIED!"))
                    {
                        Map mapChoicesTransalated = new HashMap();
                        for (int k = 0; k < strlistChoices.size(); k++) {
                        	String strChoiceOrig = (String) strlistChoices.get(k);
                            String strChoice = i18nNow.getRangeI18NString(
                                    strAttributeName,strChoiceOrig , languageStr);
                            mapChoicesTransalated.put(strChoiceOrig,strChoice);
                        }
                        mapAttribute.put(KEY_ATTRIBUTE_CHOICES,
                        		mapChoicesTransalated);

                        // Form the operator options list box HTML code
                        String strOperatorListBoxName = getNameOfOperatorListBox(strAttributeName);
                        String strOperatorListBoxHTMLCode = getHTMLPartialSelectOptionsForOperator(strAttributeDataType);
						// Changes added by PSA11 start(IR-537247-3DEXPERIENCER2018x).
                        if (!isNothing(strOperatorListBoxHTMLCode)) {
                        	if(DATA_TYPE_TIMESTAMP.equals(strAttributeDataType)){
                                strOperatorListBoxHTMLCode = "<select name=\""
                                        + strOperatorListBoxName
                                        + "\"" 
                                        + " id=\"" + grpName +  "_OperatorDate" + ++countDate + "\">"
                                        + strOperatorListBoxHTMLCode + "</select>";                        		
                        	} else if(DATA_TYPE_STRING.equals(strAttributeDataType)){
                                strOperatorListBoxHTMLCode = "<select name=\""
                                        + strOperatorListBoxName
                                        + "\"" 
                                        + " id=\"" + grpName +  "_OperatorString" + ++countString + "\">"
                                        + strOperatorListBoxHTMLCode + "</select>";                        		
                        	} else if(DATA_TYPE_BOOLEAN.equals(strAttributeDataType)){
                                strOperatorListBoxHTMLCode = "<select name=\""
                                        + strOperatorListBoxName
                                        + "\"" 
                                        + " id=\"" + grpName +  "_OperatorBool" + ++countBool + "\">"
                                        + strOperatorListBoxHTMLCode + "</select>";                        		
                        	} else if(DATA_TYPE_INTEGER.equals(strAttributeDataType)){
                                strOperatorListBoxHTMLCode = "<select name=\""
                                        + strOperatorListBoxName
                                        + "\"" 
                                        + " id=\"" + grpName +  "_OperatorInt" + ++countInt + "\">"
                                        + strOperatorListBoxHTMLCode + "</select>";                        		
                        	} else if(DATA_TYPE_REAL.equals(strAttributeDataType)){
                                strOperatorListBoxHTMLCode = "<select name=\""
                                        + strOperatorListBoxName
                                        + "\"" 
                                        + " id=\"" + grpName +  "_OperatorReal" + ++countReal + "\">"
                                        + strOperatorListBoxHTMLCode + "</select>";                        		
                        	}
                        } else {
                            strOperatorListBoxHTMLCode = "";
                        }
						// Changes done by PSA11 end.
                        mapAttribute.put(KEY_ATTRIBUTE_SELECT_OPERATOR_OPTIONS,
                                strOperatorListBoxHTMLCode);

                        // Form the enter value text box HTML code
                        
                        String strEnterValueTextBoxHTMLCode = null;
                        if(DATA_TYPE_TIMESTAMP.equals(strAttributeDataType)){
                        	strEnterValueTextBoxHTMLCode = getHTMLTextBoxForEnterValue(context,
                                    strAttributeDataType, strAttributeName, languageStr, countDate, grpName);            	
                        } else if(DATA_TYPE_STRING.equals(strAttributeDataType)){
                        	strEnterValueTextBoxHTMLCode = getHTMLTextBoxForEnterValue(context,
                                    strAttributeDataType, strAttributeName, languageStr, countString, grpName);                        	
                        } else if(DATA_TYPE_BOOLEAN.equals(strAttributeDataType)){
                        	strEnterValueTextBoxHTMLCode = getHTMLTextBoxForEnterValue(context,
                                    strAttributeDataType, strAttributeName, languageStr, countBool, grpName);                        	
                        } else if(DATA_TYPE_INTEGER.equals(strAttributeDataType)){
                        	strEnterValueTextBoxHTMLCode = getHTMLTextBoxForEnterValue(context,
                                    strAttributeDataType, strAttributeName, languageStr, countInt, grpName);                        	
                        } else if(DATA_TYPE_REAL.equals(strAttributeDataType)){
                        	strEnterValueTextBoxHTMLCode = getHTMLTextBoxForEnterValue(context,
                                    strAttributeDataType, strAttributeName, languageStr, countReal, grpName);                        	
                        }
                        mapAttribute.put(KEY_ATTRIBUTE_TEXTBOX_ENTER_VALUE,
                                strEnterValueTextBoxHTMLCode);
                        // Form the select value options list box HTML code
                        String strSelectValueListBoxName = getNameOfSelectValueListBox(strAttributeName);
                        String strSelectValueListBoxHTMLCode = getHTMLPartialSelectOptionsForSelectValue((Map) mapAttribute
                                .get(KEY_ATTRIBUTE_CHOICES));
						// Changes added by PSA11 start(IR-537247-3DEXPERIENCER2018x).		
                        if (!isNothing(strSelectValueListBoxHTMLCode)) {
                        	if(DATA_TYPE_TIMESTAMP.equals(strAttributeDataType)){
                                strSelectValueListBoxHTMLCode = "<select name=\""
                                        + strSelectValueListBoxName 
                                        + "\"" 
                                        + " id=\"" + grpName +  "_SelectValueBox_Date_" + countDate + "\"" + " onChange=\"generateSelectionOnSelect(this)\" >"
                                        + strSelectValueListBoxHTMLCode
                                        + "</select>";                        		
                        	} else if(DATA_TYPE_STRING.equals(strAttributeDataType)){
                                strSelectValueListBoxHTMLCode = "<select name=\""
                                        + strSelectValueListBoxName
                                        + "\"" 
                                        + " id=\"" + grpName +  "_SelectValueBox_String_" + countString + "\"" +  " onChange=\"generateSelectionOnSelect(this)\" >"                                        
                                        + strSelectValueListBoxHTMLCode
                                        + "</select>";                        		
                        	} else if(DATA_TYPE_BOOLEAN.equals(strAttributeDataType)){
                                strSelectValueListBoxHTMLCode = "<select name=\""
                                        + strSelectValueListBoxName
                                        + "\""
                                        + " id=\"" + grpName +  "_SelectValueBox_Boolean_" + countBool + "\"" +  " onChange=\"generateSelectionOnSelect(this)\" >"
                                        + strSelectValueListBoxHTMLCode
                                        + "</select>";                        		
                        	} else if(DATA_TYPE_INTEGER.equals(strAttributeDataType)){
                                strSelectValueListBoxHTMLCode = "<select name=\""
                                        + strSelectValueListBoxName
                                        + "\""
                                        + " id=\"" + grpName +  "_SelectValueBox_Int_" + countInt + "\"" +  " onChange=\"generateSelectionOnSelect(this)\" >"
                                        + strSelectValueListBoxHTMLCode
                                        + "</select>";                        		
                        	} else if(DATA_TYPE_REAL.equals(strAttributeDataType)){
                                strSelectValueListBoxHTMLCode = "<select name=\""
                                        + strSelectValueListBoxName
                                        + "\""
                                        + " id=\"" + grpName +  "_SelectValueBox_Real_" + countReal + "\"" +  " onChange=\"generateSelectionOnSelect(this)\" >"
                                        + strSelectValueListBoxHTMLCode
                                        + "</select>";                        		
                        	}
                        } else {
                            strSelectValueListBoxHTMLCode = "";
                        }
						// Changes added by PSA11 end.
                        mapAttribute.put(KEY_ATTRIBUTE_SELECT_VALUE_OPTIONS,
                                strSelectValueListBoxHTMLCode);

                        // Remember all this in a maplist which will be used later for printing the UI HTML code
                        maplistAttributes.add(mapAttribute);
                       } 
                    }//for !

                    // if any attribute group have accessible special RDO attribute, or do not have any special attribute, 
                    // then that attribute group will be displyed in properties file.

                    if((hasSpecialAttribute) || lstSpecialAttr.isEmpty())
                    {
                    mapAttributeGroup.put(KEY_ATTRIBUTE_GROUP_NAME,strAttributeGroupName);
                    mapAttributeGroup.put(KEY_ATTRIBUTES, maplistAttributes);
                    }
                    else
                    {
                    mapAttributeGroup.remove(KEY_ATTRIBUTE_GROUP_NAME);
                    }
                    
                }//if !
                maplistAttributeGroups.add(mapAttributeGroup);
            }//for !

            //
            // Convert the attribute arraylist into a "|" separated string
            //
            StringBuffer sbufAttributes = new StringBuffer(100);
            for (int i = 0; i < arrlistAttributes.size(); i++) {
                String strAttributeName = makeNonNull((String) arrlistAttributes
                        .get(i));
                if (isNothing(strAttributeName)) {
                    continue;
                }

                if (sbufAttributes.length() > 0) {
                    sbufAttributes.append("|");
                }//if !
                sbufAttributes.append(strAttributeName);
            }//for !
            String strMCMAttributes = "";
            if (sbufAttributes.length() > 0) {
                strMCMAttributes = sbufAttributes.toString();
                sbufAttributes = null;
            }//if !

            %>
<input type="hidden" name="MCM_AttributeList"
	value="<xss:encodeForHTMLAttribute><%=strMCMAttributes%></xss:encodeForHTMLAttribute>" />

<%
    String selectedTypes  = emxGetParameter(request,"selectedTypes");
    String andOrFieldDisplayed  = emxGetParameter(request,"andOrFieldDisplayed");


        //When user selects more than one type from typechooser then "And" & "Or" radoi buttons
        //and Type Attributes gets hidden so the following if block is added to show the
        //AdditionAttributes' "And" & "Or" radoi buttons for Attribute groups

        if ((selectedTypes != null && selectedTypes.indexOf(",") != -1) && (andOrFieldDisplayed==null || !"true".equals(andOrFieldDisplayed)))
        {

            String frameWorkStringResource = "emxFrameworkStringResource";
%>
<!-- Change done by PSA11 from class"list" to class="list" -->
<table id="AdditionAttributes" class="list">
	<tr>
		<th colspan="4" align="left"><%=EnoviaResourceBundle.getProperty(context,frameWorkStringResource,new Locale(languageStr),"emxFramework.AdvancedSearch.AdditionAttributes")%>
			<input type="radio" name="andOrField" value="and" checked extra="yes">
			<%=EnoviaResourceBundle.getProperty(context,frameWorkStringResource,new Locale(languageStr),"emxFramework.AdvancedSearch.And")%>
			<input type="radio" name="andOrField" value="or" extra="yes">
			<%=EnoviaResourceBundle.getProperty(context,frameWorkStringResource,new Locale(languageStr),"emxFramework.AdvancedSearch.Or")%>
		</th>
	</tr>
</table>
<%
        }
%>

<%
//
            // Print the attribute group information in HTML table
            //
            for (int i = 0; i < maplistAttributeGroups.size(); i++) {
                HashMap mapAttributeGroup = (HashMap) maplistAttributeGroups
                        .get(i);
                String strAttributeGroupName = trim((String) mapAttributeGroup
                        .get(KEY_ATTRIBUTE_GROUP_NAME));
                if("".equals(strAttributeGroupName))
                {
                    continue;
                }
                MapList maplistAttributes = (MapList) mapAttributeGroup
                        .get(KEY_ATTRIBUTES);
%>
<table class="list">
	<tr>
		<th colspan="4"><xss:encodeForHTML><%=strAttributeGroupName%></xss:encodeForHTML></th>
	</tr>
	<%if (maplistAttributes != null) {

                    %>
	<tr>

		<th width="150" align="left"><%=EnoviaResourceBundle.getProperty(context,
											MCM_STRING_RESOURCE_FILE,
											new Locale(languageStr),
											"emxMultipleClassification.AdvancedSearchWithClassification.Field"
											)%></th>
		<th align="left"><%=EnoviaResourceBundle.getProperty(context,
											MCM_STRING_RESOURCE_FILE,
											new Locale(languageStr),
											"emxMultipleClassification.AdvancedSearchWithClassification.Operator"
                                            )%></th>
		<th align="left"><%=EnoviaResourceBundle.getProperty(context,
											MCM_STRING_RESOURCE_FILE,
											new Locale(languageStr),
                                        	"emxMultipleClassification.AdvancedSearchWithClassification.EnterValue"
                                        	)%></th>
		<th align="left"><%=EnoviaResourceBundle.getProperty(context,
        									MCM_STRING_RESOURCE_FILE,
        									new Locale(languageStr),
                                            "emxMultipleClassification.AdvancedSearchWithClassification.SelectValue"
                                             )%></th>


	</tr>
	<%
                    for (int j = 0; j < maplistAttributes.size(); j++) {
                        HashMap mapAttribute = (HashMap) maplistAttributes
                                .get(j);
                        String strAttributeName = (String) mapAttribute
                                .get(KEY_ATTRIBUTE_NAME);
                        // Internationalize the attribute names
                        //
                        String strAttributeNameTranslated = i18nNow.getAttributeI18NString(
                                strAttributeName, sLanguage);

                        //String strAttributeDataType = (String)mapAttribute.get(KEY_ATTRIBUTE_DATA_TYPE);
                        //StringList strlistChoices       = (StringList)mapAttribute.get(KEY_ATTRIBUTE_CHOICES);
                        String strOperatorListBoxHTMLCode = (String) mapAttribute
                                .get(KEY_ATTRIBUTE_SELECT_OPERATOR_OPTIONS);
                        String strSelectValueListBoxHTMLCode = (String) mapAttribute
                                .get(KEY_ATTRIBUTE_SELECT_VALUE_OPTIONS);
                        String strEnterValueTextBoxHTMLCode = (String) mapAttribute
                                .get(KEY_ATTRIBUTE_TEXTBOX_ENTER_VALUE);

                        ///
                        // write code here to get extra information about the attribute from the hasmap
                        ///

                        %>
	<tr>
		<td width="150" nowrap class="label"><b><%=strAttributeNameTranslated%></b></td>
		<!-- XSSOK - dont encode html, these variables have html inside them -->
		<td class="inputField"><%=strOperatorListBoxHTMLCode%></td>
		<!-- XSSOK -->
		<td class="inputField"><%=strEnterValueTextBoxHTMLCode%></td>
		<!-- XSSOK -->
		<td class="inputField"><%=strSelectValueListBoxHTMLCode%></td>
	</tr>
	<%
}//for !

                %>
</table>
<%
}//for !
    }
        }
        else if(derivedOrDerivative.equals("false"))
        {
%>
<input type="hidden" name="noChildAttributes" value="true">
<%
        }
%>

<script language="JavaScript">
function updateRedundantFields()
    {
        //XSSOK - as these variables are declared on this page itself
        var mcmOperatorValuePrefix = "<%=MCM_OPERATOR_PREFIX%>";
        //XSSOK - as these variables are declared on this page itself
        var mcmEnterValuePrefix = "<%=MCM_ENTERVALUE_PREFIX%>";
        //XSSOK - as these variables are declared on this page itself
        var mcmSelectValuePrefix = "<%=MCM_SELECTVALUE_PREFIX%>";
        //XSSOK - as these variables are declared on this page itself
        var mcmEnterValueUnitPrefix = "<%=MCM_ENTERVALUE_UNIT_PREFIX%>";

		var advAttrOperatorValuePrefix = "comboDescriptor_";
		var advAttrEnterValuePrefix = "txt_";
		var advAttrSelectValuePrefix = "";
		var advAttrEnterValueUnitPrefix = "units_";

		// Keep track of the elements that we mess with
		document.propagateElems = new Array();
		var form = document.forms[0];
		var n = 0;
		for ( var elemNum = 0; elemNum < form.length; elemNum++) {

			var elem = form[elemNum];
			var normalizedElemName = elem.name;

			// if there are any dupes, one of them is definitely #2

			if (elem.type != 'hidden' && elem.type != 'radio') {
				if (normalizedElemName.indexOf(advAttrOperatorValuePrefix) == 0) {
					normalizedElemName = mcmOperatorValuePrefix
							+ normalizedElemName
									.substring(advAttrOperatorValuePrefix.length);
				} else if (normalizedElemName.indexOf(advAttrEnterValuePrefix) == 0) {
					normalizedElemName = mcmEnterValuePrefix
							+ normalizedElemName
									.substring(advAttrEnterValuePrefix.length);
				} else if (normalizedElemName
						.indexOf(advAttrEnterValueUnitPrefix) == 0) {
					normalizedElemName = mcmEnterValueUnitPrefix
							+ normalizedElemName
									.substring(advAttrEnterValueUnitPrefix.length);
				} else if (normalizedElemName.indexOf("MCM_") == -1) {
					normalizedElemName = mcmSelectValuePrefix
							+ normalizedElemName;
				}
				document.propagateElems[n++] = elem;

				/* Renames(normalizes to have MCM prefix that is used for classification attributes) Type specific 
				 * attribute field names that are retrieved by Adv search*/
				elem.normalizedElemName = normalizedElemName;

				// Set the onchange, sort of.
				// The JS onchange does not respond to programmatic value changes,
				// such as by calendar widget, so roll our own onchange.
				if (elem.onchange == null)
					elem.onchange = propagateUpdates;
			}
		}
		for (i = 0; i < document.propagateElems.length; i++) {
			document.propagateElems[i].onchange();
		}
	}

	function propagateUpdates() {
		var sourceElemName = this.normalizedElemName;
		var elems = document.propagateElems;

		for ( var elemNum = 0; elemNum < elems.length; elemNum++) {
			var elem = elems[elemNum];
			if (elem.normalizedElemName == sourceElemName) {
				elem.value = this.value;
			}
		}
	}

	updateRedundantFields();
</script>
<!-- Script added by PSA11(IR-468677) -->
<!-- Second Script added by PSA11(IR-537247-3DEXPERIENCER2018x) -->
<script type="text/javascript" language="JavaScript">
	function generateSelection(elementClicked) {
		var idSplitArray = elementClicked.id.split("_");
		var dataType = idSplitArray[idSplitArray.length - 1];
		var attributeGrpName = idSplitArray[0];
		var selectedOperator = '#' + attributeGrpName + '_Operator' + dataType;
		if (dataType.match('Date') !== null) {
			if ($(selectedOperator).val() === "*") {
				$(selectedOperator).val("IsOn");
			}
		} else if (dataType.match('String') !== null
				|| dataType.match('Bool') !== null) {
			if ($(selectedOperator).val() === "*") {
				$(selectedOperator).val("IsExactly");
			}
		} else if (dataType.match('Real') !== null
				|| dataType.match('Int') !== null) {
			if ($(selectedOperator).val() === "*") {
				$(selectedOperator).val("Equals");
			}
		}
	}
	
	function generateSelectionOnSelect(selectElementClicked){
		var selectClickedId = "#" + selectElementClicked.id;
		var idSplitArray = selectElementClicked.id.split("_");
		var dataType = idSplitArray[idSplitArray.length - 2];
		var selectNo = idSplitArray[idSplitArray.length - 1];
		var attributeGrpName = idSplitArray[0];
		var selectedOperator = '#' + attributeGrpName + '_Operator' + dataType + selectNo;		
		if (dataType.match('Date') !== null) {
			if($(selectClickedId).val() === "*"){
				$(selectedOperator).val("*");
			} else {
				$(selectedOperator).val("IsOn");
			}
		} else if (dataType.match('String') !== null
				|| dataType.match('Bool') !== null) {
			if($(selectClickedId).val() === "*"){
				$(selectedOperator).val("*");
			} else {
				$(selectedOperator).val("IsExactly");
			}
		} else if (dataType.match('Real') !== null
				|| dataType.match('Int') !== null) {
			if($(selectClickedId).val() === "*"){
				$(selectedOperator).val("*");
			} else {
				$(selectedOperator).val("Equals");
			}
		}
	}	
</script>

