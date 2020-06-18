<% response.setContentType("text/xml; charset=UTF-8"); %> <?xml version="1.0" encoding="UTF-8"?>
<%--  emxMxLinkValidation.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMxLinkValidation.jsp.rca 1.1.1.5 Tue Oct 28 22:59:40 2008 przemek Experimental przemek $
--%>


<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="mxLinkValidateBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<jsp:useBean id="formEditBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<jsp:useBean id="createBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%    
    String timeStamp = emxGetParameter(request, "timeStamp");
    String uiType = emxGetParameter(request, "uiType");

    String mode = emxGetParameter(request, "mode");
    String returnString ="";
    String fieldValue="";
    ArrayList mxLinkObjectList=null;    
    java.util.Set mxLinkObjectSet=new HashSet();
    HashMap paramMap = new HashMap();
    
    String sDynamicURLEnabled = EnoviaResourceBundle.getProperty(context, "emxFramework.DynamicURLEnabled");
    if(!"false".equals(sDynamicURLEnabled) && uiType != null && !"".equals(uiType)) {
        if ( uiType != null && uiType.equalsIgnoreCase("form")) {
            paramMap.put("uiType","form");
            if ( mode != null && mode.equalsIgnoreCase("edit")) {
                mxLinkValidateBean=formEditBean;
            }else {
                mxLinkValidateBean=createBean;  
            }

            MapList fields = mxLinkValidateBean.getFormFields(timeStamp);
            for (int k = 0; k < fields.size(); k++) {
                HashMap field = (HashMap)fields.get(k);
                 if(mxLinkValidateBean.isDynamicURLEnabled(context,field)) {
                    fieldValue= emxGetParameter(request,mxLinkValidateBean.getName(field));                
                    if(fieldValue!=null && (fieldValue.toLowerCase()).indexOf("mxlink")!=-1 ){
                             paramMap.put(mxLinkValidateBean.getName(field), fieldValue);
                    }
                }         
            }
         }else if ( "table".equals(uiType)){
            paramMap.put("uiType","table");
            HashMap tableData = tableBean.getTableData(timeStamp);
            String objCount = emxGetParameter(request,"objCount");
            int count = 0;
            if(objCount != null && !"".equals(objCount))
            {
                count = Integer.parseInt(objCount);
            }
            MapList fields = tableBean.getColumns(tableData);

            for (int k = 0; k < fields.size(); k++)
            {
                HashMap columnMap = (HashMap) fields.get(k);
                if(tableBean.isDynamicURLEnabled(context, columnMap)) {
                    String columnName = tableBean.getName(columnMap);
                    for(int i = 0; i < count; i++)
                    {
                        fieldValue= emxGetParameter(request,columnName + i);
                        if(fieldValue!=null && fieldValue.toLowerCase().indexOf("mxlink") != -1) {
                            paramMap.put(columnName + i, fieldValue);
                        }
                    }
                }
            }
        }

        paramMap.put("language", request.getHeader("Accept-Language"));
            
        try {
                returnString = (String)JPO.invoke(context, "emxUtilBase", null, "validateMxLinkData", JPO.packArgs(paramMap), String.class);
                out.clear();
                out.println(returnString);
        }catch (Exception exJPO) {
            throw (new FrameworkException(exJPO.toString()));
        }
    }else {
        if(uiType == null || "".equals(uiType)) {
            Enumeration eNumParameters = emxGetParameterNames(request);
            while( eNumParameters.hasMoreElements() ) {
                String strParamName = (String)eNumParameters.nextElement();
                String strParamValue = emxGetParameter(request,strParamName);
                paramMap.put(strParamName, strParamValue);
            }
            paramMap.put("language", request.getHeader("Accept-Language"));
            try {
                    returnString = (String)JPO.invoke(context, "emxUtilBase", null, "validateMxLinkData", JPO.packArgs(paramMap), String.class);
                    out.clear();
                    out.println(returnString);
            }catch (Exception exJPO) {
                throw (new FrameworkException(exJPO.toString()));
            }
        }else {
            out.clear();
            out.println("<mxLinkRoot><errorMsg><![CDATA[]]></errorMsg></mxLinkRoot>");
        }
    }
%>







