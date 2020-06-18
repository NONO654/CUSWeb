<%-- emxSearchGetAdvanced.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxSearchGetAdvanced.jsp.rca 1.13 Wed Oct 22 15:47:48 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%
        String emxType = emxGetParameter(request,"type");

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
                AttributeList attrListObj        = flLikeObj.getAttributes();
                attrItrObj          = new AttributeItr(attrListObj);
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
                                try{
                                attrTypeObj.open(context);
                                sDataType = attrTypeObj.getDataType();
                                attrTypeObj.close(context);
                                }catch(Exception ex){
                                	//Do nothing
                                }
                                //Store datatype in vector
                                attrMap.put("Type", sDataType);
                                attrMapList.add(attrMap);
                        }
                }
        }


        //  Create Drop downs for Data types of the Attribute
        String sOption             = "<option name=blank value=\"*\"></option><option name='";

        //To set options for string data type
        sbStrInclude    = new StringBuffer(sOption);
        sbStrInclude.append(sMatrixBeginsWith);
        sbStrInclude.append("' value='");
        sbStrInclude.append(sMatrixBeginsWith);
        sbStrInclude.append("'>");
        sbStrInclude.append(sMatrixBeginsWithTrans);
        sbStrInclude.append("</option>");

        sbStrInclude.append("<option name='");
        sbStrInclude.append(sMatrixEndsWith);
        sbStrInclude.append("' value='");
        sbStrInclude.append(sMatrixEndsWith);
        sbStrInclude.append("'>");
        sbStrInclude.append(sMatrixEndsWithTrans);
        sbStrInclude.append(" </option>");

        sbStrInclude.append("<option name='");
        sbStrInclude.append(sMatrixIncludes);
        sbStrInclude.append("' value='");
        sbStrInclude.append(sMatrixIncludes);
        sbStrInclude.append("'>");
        sbStrInclude.append(sMatrixIncludesTrans);
        sbStrInclude.append(" </option>");

        sbStrInclude.append("<option name='");
        sbStrInclude.append(sMatrixIsExactly);
        sbStrInclude.append("' value='");
        sbStrInclude.append(sMatrixIsExactly);
        sbStrInclude.append("'>");
        sbStrInclude.append(sMatrixIsExactlyTrans);
        sbStrInclude.append(" </option>");

        sbStrInclude.append("<option name='");
        sbStrInclude.append(sMatrixIsNot);
        sbStrInclude.append("' value='");
        sbStrInclude.append(sMatrixIsNot);
        sbStrInclude.append("'>");
        sbStrInclude.append(sMatrixIsNotTrans);
        sbStrInclude.append(" </option>");

        sbStrInclude.append("<option name='");
        sbStrInclude.append(sMatrixMatches);
        sbStrInclude.append("' value='");
        sbStrInclude.append(sMatrixMatches);
        sbStrInclude.append("'>");
        sbStrInclude.append(sMatrixMatchesTrans);
        sbStrInclude.append(" </option>");


        //To set options for numeric data type
        sbRealInclude   = new StringBuffer(sOption);
        sbRealInclude.append(sMatrixIsAtLeast);
        sbRealInclude.append("' value='");
        sbRealInclude.append(sMatrixIsAtLeast);
        sbRealInclude.append("'>");
        sbRealInclude.append(sMatrixIsAtLeastTrans);
        sbRealInclude.append(" </option>");

        sbRealInclude.append("<option name='");
        sbRealInclude.append(sMatrixIsAtMost);
        sbRealInclude.append("' value='");
        sbRealInclude.append(sMatrixIsAtMost);
        sbRealInclude.append("'>");
        sbRealInclude.append(sMatrixIsAtMostTrans);
        sbRealInclude.append(" </option>");

        sbRealInclude.append("<option name='");
        sbRealInclude.append(sMatrixDoesNotEqual);
        sbRealInclude.append("' value='");
        sbRealInclude.append(sMatrixDoesNotEqual);
        sbRealInclude.append("'>");
        sbRealInclude.append(sMatrixDoesNotEqualTrans);
        sbRealInclude.append(" </option>");

        sbRealInclude.append("<option name='");
        sbRealInclude.append(sMatrixEquals);
        sbRealInclude.append("' value='");
        sbRealInclude.append(sMatrixEquals);
        sbRealInclude.append("'>");
        sbRealInclude.append(sMatrixEqualsTrans);
        sbRealInclude.append(" </option>");

        sbRealInclude.append("<option name='");
        sbRealInclude.append(sMatrixIsBetween);
        sbRealInclude.append("' value='");
        sbRealInclude.append(sMatrixIsBetween);
        sbRealInclude.append("'>");
        sbRealInclude.append(sMatrixIsBetweenTrans);
        sbRealInclude.append(" </option>");

        sbRealInclude.append("<option name='");
        sbRealInclude.append(sMatrixIsLessThan);
        sbRealInclude.append("' value='");
        sbRealInclude.append(sMatrixIsLessThan);
        sbRealInclude.append("'>");
        sbRealInclude.append(sMatrixIsLessThanTrans);
        sbRealInclude.append(" </option>");

        sbRealInclude.append("<option name='");
        sbRealInclude.append(sMatrixIsMoreThan);
        sbRealInclude.append("' value='");
        sbRealInclude.append(sMatrixIsMoreThan);
        sbRealInclude.append("'>");
        sbRealInclude.append(sMatrixIsMoreThanTrans);
        sbRealInclude.append(" </option>");

        //To set options for date/time data type
        sbTimeInclude   = new StringBuffer(sOption);
        sbTimeInclude.append(sMatrixIsOn);
        sbTimeInclude.append("' value='");
        sbTimeInclude.append(sMatrixIsOn);
        sbTimeInclude.append("'>");
        sbTimeInclude.append(sMatrixIsOnTrans);
        sbTimeInclude.append(" </option>");

        sbTimeInclude.append("<option name='");
        sbTimeInclude.append(sMatrixIsOnOrBefore);
        sbTimeInclude.append("' value='");
        sbTimeInclude.append(sMatrixIsOnOrBefore);
        sbTimeInclude.append("'>");
        sbTimeInclude.append(sMatrixIsOnOrBeforeTrans);
        sbTimeInclude.append(" </option>");

        sbTimeInclude.append("<option name='");
        sbTimeInclude.append(sMatrixIsOnOrAfter);
        sbTimeInclude.append("' value='");
        sbTimeInclude.append(sMatrixIsOnOrAfter);
        sbTimeInclude.append("'>");
        sbTimeInclude.append(sMatrixIsOnOrAfterTrans);
        sbTimeInclude.append(" </option>");


        //To set options for boolean data type
        sbBooleanInclude    = new StringBuffer(sOption);
        sbBooleanInclude.append(sMatrixIsExactly);
        sbBooleanInclude.append("' value='");
        sbBooleanInclude.append(sMatrixIsExactly);
        sbBooleanInclude.append("'>");
        sbBooleanInclude.append(sMatrixIsExactlyTrans);
        sbBooleanInclude.append(" </option>");

        sbBooleanInclude.append("<option name='");
        sbBooleanInclude.append(sMatrixIsNot);
        sbBooleanInclude.append("' value='");
        sbBooleanInclude.append(sMatrixIsNot);
        sbBooleanInclude.append("'>");
        sbBooleanInclude.append(sMatrixIsNotTrans);
        sbBooleanInclude.append(" </option>");

%>

<input type="hidden" name="attrList" value="<%=XSSUtil.encodeForHTMLAttribute(context, attrList)%>" />
<input type="hidden" name="timeZone" value="<xss:encodeForHTMLAttribute><%=session.getValue("timeZone")%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="reqLocaleLang" value="<xss:encodeForHTMLAttribute><%=request.getLocale().getLanguage()%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="reqLocaleCty" value="<xss:encodeForHTMLAttribute><%=request.getLocale().getCountry()%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="reqLocaleVar" value="<xss:encodeForHTMLAttribute><%=request.getLocale().getVariant()%></xss:encodeForHTMLAttribute>"/>

<table border="0" cellpadding="5" cellspacing="2" width="100%">
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
<th><emxUtil:i18n localize="i18nId">emxFramework.AdvancedSearch.Field</emxUtil:i18n></th>
<th><emxUtil:i18n localize="i18nId">emxFramework.AdvancedSearch.Operator</emxUtil:i18n></th>
<th><emxUtil:i18n localize="i18nId">emxFramework.AdvancedSearch.EnterValue</emxUtil:i18n></th>
<th><emxUtil:i18n localize="i18nId">emxFramework.AdvancedSearch.SelectValue</emxUtil:i18n></th>
</tr>

<%
    for (int i = 0; i < attrMapList.size(); i++)
    {
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

        String displayUOM = "";
        String selectUnit = "";
        String fieldType = (String) attrMap.get("FieldType");

		if (!"Basic".equals(fieldType) && UOMUtil.isAssociatedWithDimension(context, attrName))
		{
			selectUnit = UOMUtil.getDBunit(context, attrName);
			String fieldName = "units_" + attrName;
			displayUOM = UIUtil.displayUOMComboField(context, attrName, selectUnit, fieldName, languageStr);
			if (!"".equals(displayUOM)) displayUOM = "&nbsp;" + displayUOM;
		}

        StringBuffer strText = new StringBuffer();
        strText.append("<td nowrap class=\"inputField\"><input type=\"text\" name=\"");
        strText.append(strTxtName);
        strText.append("\" value=\"*\" size=\"20\" extra=\"yes\" />");
        strText.append(displayUOM);
        strText.append("</td>");

        if (attrType.equals("string")) {
                strSelect = sbStrInclude;
        } else if(attrType.equals("real") || attrType.equals("integer")) {
                strSelect = sbRealInclude;
        } else if(attrType.equals("timestamp")) {
                strSelect = sbTimeInclude;
                strText = new StringBuffer();
                strText.append("<td nowrap class=\"inputField\"><input READONLY type=\"text\" name=\"");
                strText.append(strTxtName);
                strText.append("\" value=\"\" size=\"20\" extra=\"yes\" onFocus=\"this.blur()\" />&nbsp;&nbsp;<a href='javascript:showCalendar(\"SearchForm\",\"");
                strText.append(strTxtName);
                strText.append("\",\"\");'><img src=\"../common/images/iconSmallCalendar.gif\" border=0></a>&nbsp;&nbsp;<a href='javascript:getTopWindow().clearField(\""+strTxtName+"\");'>"+FrameworkUtil.i18nStringNow("emxFramework.Common.Clear", languageStr)+"</a></td> ");

        } else if(attrType.equals("boolean")) {
                strSelect = sbBooleanInclude;
        }

        StringList attrChoices = (StringList) attrMap.get("Choices");
        
// Added for IR72160V6R2011 Dated 11/12/2009 Begins.        
        if(null != attrChoices)
        {
            attrChoices.sort();
        }
// Added for IR72160V6R2011 Dated 11/12/2009 Ends.

        StringBuffer strChoiceSelect = new StringBuffer(16);
        
        StringList StateList = new StringList();
        strChoiceSelect.append("&nbsp;");
        if(attrChoices != null && attrChoices.size() > 0) {
            strChoiceSelect = new StringBuffer(150);
            strChoiceSelect.append("<select name=\"");
            strChoiceSelect.append(attrName);
            strChoiceSelect.append("\" size=\"1\"><option value=\"\"></option>");
            for(int ir=0;ir<sListPolicy.size();ir++){
            	StringList PolicyStateList = new StringList();
        		Policy mxPolicyObj = new Policy((String)sListPolicy.elementAt(ir));
        		Iterator stateItr = mxPolicyObj.getStateRequirements(context).iterator();
            	while (stateItr.hasNext()) {
            	try{
                    StateRequirement stateReq = (StateRequirement) stateItr.next();
                    PolicyStateList.addElement((String)stateReq.getName());
            	  }
            	  catch(Exception e){}
              }   
            
        	
            for(int j =0; j < attrChoices.size();j++)
            {
            	if(!(StateList.contains((String)attrChoices.elementAt(j))))
            	if(isState != null && "true".equals(isState)) {
            		
                  	if((PolicyStateList.contains((String)attrChoices.elementAt(j)))){
                  		strChoiceSelect.append("<option value=\"");
                        strChoiceSelect.append(attrChoices.get(j));
                        strChoiceSelect.append("\">");
                  		StateList.add((String)attrChoices.elementAt(j));
                  		strChoiceSelect.append(i18nNow.getStateI18NString((String)sListPolicy.elementAt(ir),(String)attrChoices.elementAt(j),languageStr));
                  		strChoiceSelect.append("</option>");
                  	}       
                   } else {
                	   StateList.add((String)attrChoices.elementAt(j));
                	   strChoiceSelect.append("<option value=\"");
                       strChoiceSelect.append(attrChoices.get(j));
                       strChoiceSelect.append("\">");
                       strChoiceSelect.append(i18nNow.getRangeI18NString(attrName, (String)attrChoices.get(j), languageStr));
                       strChoiceSelect.append("</option>");
                    }
                    
            }
         }
                strChoiceSelect.append("</select>");
        }

        String i18nAttrName = "";
        if(fieldType != null && "Basic".equals(fieldType)) {
                i18nAttrName = i18nNow.getBasicI18NString(attrName,languageStr);
        } else {
                i18nAttrName = i18nNow.getAttributeI18NString(attrName,languageStr);
        }
%>
        <tr>
        <td width="150" class="label"><%=i18nAttrName%></td>
        <td class="inputField">
        <!-- //XSSOK -->
        <select name="<%=strComboName%>" extra="yes">
        <!-- //XSSOK -->
        <%=strSelect%>
        </select></td>
        <!-- //XSSOK -->
        <%=strText.toString()%>
        <td class="inputField" nowrap>
        <!-- //XSSOK -->
        <%=strChoiceSelect.toString()%>
        </td>
        </tr>
<%
    }
%>

</table>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
