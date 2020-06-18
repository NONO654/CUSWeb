<%--  emxFormUtil.inc

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFormUtil.inc.rca 1.47 Wed Oct 22 15:48:59 2008 przemek Experimental przemek $
--%>

<%!
    static private String getInternationalizedDefaultValue (Context context, String strFieldValue,
            String strAdminType, String languageStr, String strAdditionalInfo) throws Exception {
 
         UIForm formBean = new UIForm();

        return  formBean.getInternationalizedDefaultValue (context,strFieldValue,strAdminType, languageStr, strAdditionalInfo);
    }

%>

<%!
    static public String drawFormEditElement(   Context context,
                                                HashMap requestMap,
                                                HashMap field,
                                                HashMap inputMap,
                                                String timeZone,
                                                boolean drawLabel,
                                                int maxCols)
        throws FrameworkException
    {
                return drawFormEditElement(context, requestMap, field, inputMap, timeZone, drawLabel, maxCols, -1, false);
    }
%>

<%!
        static public String drawFormEditElement (Context context, HashMap requestMap,
            HashMap field, HashMap inputMap, String timeZone, boolean drawLabel, int maxCols, int fieldCounter, boolean isReadonly) throws FrameworkException {

        UIForm formEditBean = new UIForm();

        return formEditBean.drawFormEditElement (context, requestMap, field, inputMap, timeZone, drawLabel, maxCols,  fieldCounter, isReadonly);

    }

%>

<%!
    static public String drawFormViewElement (Context context, HashMap requestMap,
            HashMap field, String timeZone, String sPFmode, boolean drawLabel,
            int maxCols) throws FrameworkException {

        UIForm formViewBean = new UIForm();

        return formViewBean.drawFormViewElement (context, requestMap, field, timeZone, sPFmode, drawLabel, maxCols);

    }

%>
<%// Added for web form row span layout%>
<%!
    static public String drawFormViewElement (Context context, HashMap requestMap,
            HashMap field, String timeZone, String sPFmode, boolean drawLabel,
            int maxCols, int iRowSpan) throws FrameworkException {

        UIForm formViewBean = new UIForm();

        return formViewBean.drawFormViewElement (context, requestMap, field, timeZone, sPFmode, drawLabel, maxCols, iRowSpan);
    }
%>

<%!
    static public String drawFormEditElement (Context context, HashMap requestMap,
            HashMap field, HashMap inputMap, String timeZone, boolean drawLabel, int maxCols, int fieldCounter, 
            boolean isReadonly,int rowspan) throws FrameworkException {

        UIForm formEditBean = new UIForm();

        return formEditBean.drawFormEditElement (context, requestMap, field, inputMap, timeZone, drawLabel, maxCols,  fieldCounter, isReadonly, rowspan);

    }

%>
<%// Ended%>
