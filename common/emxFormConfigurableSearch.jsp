
<%--  emxFormConfigurableSearch.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFormConfigurableSearch.jsp.rca 1.1.1.5 Tue Oct 28 22:59:38 2008 przemek Experimental przemek $
--%>

<% response.setContentType("text/xml; charset=UTF-8"); %> 
<?xml version="1.0" encoding="UTF-8"?>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<jsp:useBean id="formEditBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<% 

    String typeAheadEnabled = "true";
    try
    {
        typeAheadEnabled = EnoviaResourceBundle.getProperty(context, "emxFramework.TypeAhead");
    }
    catch (Exception e)
    {
    }
        String form = emxGetParameter(request, "form");
        String timeStamp = emxGetParameter(request, "timeStamp");
        MapList fields = formEditBean.getFormFields(timeStamp);
        String timeZone = (String)session.getAttribute("timeZone");

        HashMap field=new HashMap();
        String fieldallowKeyableDates = (String)formEditBean.getSetting(field, "Allow Manual Edit");
        for (int k = 0; k < fields.size(); k++)
        {
            field = (HashMap) fields.get(k);
            String fieldName = formEditBean.getName(field);
            String strTypeAheadSetting=formEditBean.getSetting(field,"TypeAhead");
            String rangeHelperURL = formEditBean.getRangeHelperURL(field);
            if (strTypeAheadSetting==null||"null".equals(strTypeAheadSetting)||"".equals(strTypeAheadSetting))
            {
                strTypeAheadSetting="true";
            }
            if (((formEditBean.isTextBoxField(field) && formEditBean.isFieldEditable(field))
                ||(formEditBean.isFieldManualEditable(field) && rangeHelperURL != null && rangeHelperURL.length() > 0) 
                || (formEditBean.isDateField(field) && formEditBean.isFieldManualEditable(field))) && "true".equalsIgnoreCase(typeAheadEnabled) && "true".equalsIgnoreCase(strTypeAheadSetting))
            {
                String tagTypeAheadSavedValuesLimit = formEditBean.getSetting(field, "TypeAhead Saved Values Limit");
                String tagDisplayFieldValue;
                String tagHiddenFieldValue;
                tagDisplayFieldValue = emxGetParameter(request, fieldName);
                tagHiddenFieldValue = "";
                if (rangeHelperURL != null && rangeHelperURL.length() > 0)
                {
                    tagDisplayFieldValue = emxGetParameter(request, fieldName + "Display");
                    tagHiddenFieldValue = emxGetParameter(request, fieldName);
                }
                else
                {
                    tagDisplayFieldValue = emxGetParameter(request, fieldName);
                    tagHiddenFieldValue = "";
                    if (formEditBean.isDateField(field))
                    {
                        tagHiddenFieldValue = emxGetParameter(request, fieldName+"_msvalue");
                        if (tagDisplayFieldValue!=null && !"".equals(tagDisplayFieldValue) && !"".equals(tagDisplayFieldValue)){
                        if ((fieldallowKeyableDates != null && "true".equalsIgnoreCase(fieldallowKeyableDates))) {
                                    int iDateFormat = eMatrixDateFormat.getEMatrixDisplayDateFormat();
                                    double iClientTimeOffset = (new Double(timeZone)).doubleValue();
                                    long msvalue=DateUtil.getMilliseconds(context, tagDisplayFieldValue, iDateFormat, iClientTimeOffset, request.getLocale());
                                    Long lgMsvalue=new Long(msvalue);
                                    tagHiddenFieldValue=lgMsvalue.toString();
                             }
                        }
                    }
                }
            %>
			  <!-- //XSSOK -->
              <emxUtil:saveTypeAheadValues context="<%= context %>" form="<%= XSSUtil.encodeForXML(context,form) %>" field="<%= XSSUtil.encodeForXML(context,fieldName) %>" displayFieldValue="<%= XSSUtil.encodeForXML(context,tagDisplayFieldValue) %>" hiddenFieldValue="<%= XSSUtil.encodeForXML(context,tagHiddenFieldValue) %>" count="<%= tagTypeAheadSavedValuesLimit %>"
                />
                <%
                }
        }
        %>
<emxUtil:commitTypeAheadValues context="<%= context %>" />







