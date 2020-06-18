<%--  emxFormViewDisplay.jsp

   Copyright (c) 1992-2011 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFormViewDisplay.jsp.rca 1.37.2.2 Tue Dec  9 06:53:31 2008 ds-arajendiran Experimental $
--%>

<!-- This is a copy of the source ..common/emxFormViewDisplay.jsp provided by ENOVIA to accommodate UI3 changes on our "Properties" page for a document (made by m6d)-->

<%@page import="com.matrixone.apps.domain.util.FrameworkUtil,com.matrixone.apps.framework.ui.UIUtil"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@include file = "emxNavigatorInclude.inc"%>

<html>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxFormUtil.inc"%>
<%@ page import ="com.matrixone.apps.domain.util.*" %>
<jsp:useBean id="formViewBean" class="com.matrixone.apps.framework.ui.UIForm" scope="request"/>

<%
String form = emxGetParameter(request, "form");
String title ="";
String suiteKey = emxGetParameter(request, "suiteKey");
String header = emxGetParameter(request, "header");
Locale loc = context.getLocale();
String strResourceFile = UINavigatorUtil.getStringResourceFileId(context,suiteKey);
if(UIUtil.isNullOrEmpty(header))
    title = "body_" + form;
else
    title = EnoviaResourceBundle.getProperty(context,strResourceFile,loc,header);
String objectId = emxGetParameter(request, "objectId");
String objectName = emxGetParameter(request, "objectName");
String relId = emxGetParameter(request, "relId");
String timeStamp = emxGetParameter(request, "timeStamp");
String jsTreeID = emxGetParameter(request, "jsTreeID");
String sPFmode = emxGetParameter(request, "PFmode");
String treeUpdate = emxGetParameter(request, "treeUpdate");

String originalHeader =emxGetParameter(request, "originalHeader");
String targetLocation = emxGetParameter(request,"targetLocation");
String parsedHeader = UIForm.getFormHeaderString(context, pageContext, originalHeader, objectId, suiteKey, request.getHeader("Accept-Language"));

parsedHeader=FrameworkUtil.findAndReplace(parsedHeader,"\'","\\\'");

parsedHeader=FrameworkUtil.findAndReplace(parsedHeader,"\"","\\\"");


String subHeader = emxGetParameter(request, "subHeader");


//This Param will use an alternative stylesheet for displaying the page
String altCSS = emxGetParameter(request, "altCSS");

String emxSuiteDirectory = emxGetParameter(request, "emxSuiteDirectory");

HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
HashMap imageData = UINavigatorUtil.getImageData(context, pageContext);
requestMap.put("ImageData", imageData);

HashMap formMap = new HashMap();

// time zone to be used for the date fields
String timeZone = (String)session.getAttribute("timeZone");

String emxErrorString = "";

    String reportFormat = emxGetParameter(request, "reportFormat");

    if (reportFormat == null || reportFormat.length() == 0)
        reportFormat = "HTML";

    if (reportFormat.equals("ExcelHTML"))
    {
        sPFmode="true";
        response.setContentType("application/vnd.ms-excel");
    }

//to get the dateformat
String DateFrm = PersonUtil.getPreferenceDateFormatString(context);
%>

<head>
<title><%=title%></title>
<%@include file = "emxUIConstantsInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUIObjMgr.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../common/scripts/emxUIFormUtil.js"></script>
<script language="JavaScript" src="../common/scripts/emxUITableUtil.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIPopups.js" type="text/javascript"></script>
</head>
<%
if ( sPFmode != null && sPFmode.equals("true") )
{
  //added list
%>

<%@include file = "../emxStyleDefaultPFInclude.inc"%>
<%@include file = "../emxStylePropertiesPFInclude.inc"%>
<%@include file = "../emxStyleListPFInclude.inc"%>
<%
}   else {
%>

<%@include file = "../emxStyleDefaultInclude.inc"%>
<%@include file = "../emxStylePropertiesInclude.inc"%>
<%@include file = "../emxStyleListInclude.inc"%>
<%
}

if ( altCSS != null && !"".equals(altCSS)){
  if (altCSS.indexOf(".css") > -1)
    altCSS = altCSS.substring(0,altCSS.indexOf(".css"));
%>
<script type="text/javascript">

  addStyleSheet("<%=altCSS%>");

</script>
<%
}
%>

    <script>
          addStyleSheet("emxUIMenu");
    </script>
<%


int maxCols = 2;
// Added for web form rowspan layout
int imaxVerticalRows = 1;
try {

    ContextUtil.startTransaction(context, false);
    Vector userRoleList = PersonUtil.getAssignments(context);

    HashMap formData = new HashMap();
    MapList fields = new MapList();

    if (form != null)
    {
        formMap = formViewBean.getForm(context, form);
        if (formMap != null)
        {
                formData = formViewBean.setFormData(requestMap, context, timeStamp, userRoleList, false);
                fields = formViewBean.getFormFields(formData);
                maxCols = ((Integer)formData.get("max cols")).intValue();
        }
        //Added for BUG 344952
        for (int j = 0; j < fields.size(); j++){
            HashMap fieldTemp = (HashMap)fields.get(j);
            String strTempaccess = (String) fieldTemp.get("hasAccess");
            if(formViewBean.isGroupHolderField(fieldTemp) || formViewBean.isGroupField(fieldTemp)){
                if(strTempaccess!=null && !"".equals(strTempaccess)&& strTempaccess.equalsIgnoreCase("false"))
                    fields.remove(fieldTemp);
            }
     }
  }

    // Show the header if the mode is "PrinterFriendly"
    if ( sPFmode != null && sPFmode.equals("true") )
    {
        String userName = PersonUtil.getFullName(context);
        // Get the calendar on server
        Calendar currServerCal = Calendar.getInstance();
        Date currentDateObj = currServerCal.getTime();

        // Date Format initialization
        int iDateFormat = PersonUtil.getPreferenceDateFormatValue(context);
        String prefTimeDisp = PersonUtil.getPreferenceDisplayTime(context);

        java.text.DateFormat outDateFrmt = null;
        if (prefTimeDisp != null && prefTimeDisp.equalsIgnoreCase("true"))
        {
            outDateFrmt = DateFormat.getDateTimeInstance(iDateFormat, iDateFormat, request.getLocale());
        } else {
            outDateFrmt = DateFormat.getDateInstance(iDateFormat, request.getLocale());
        }

        currentDateObj = outDateFrmt.parse(outDateFrmt.format(currentDateObj));
        String currentTime = outDateFrmt.format(currentDateObj);
    %>
        <body class="properties" onunload="JavaScript:purgeViewFormData('<%=timeStamp%>')">
        <hr noshade>
        <table>
        <tr>
            <td class="pageHeader" width="60%"><%=parsedHeader%></td>
            <td width="1%"><img src="images/utilSpacer.gif" width="1" height="28" alt=""></td>
            <td width="39%" align="right"></td>
            <td nowrap>
                <table>
                <tr><td nowrap=""><%=userName%></td></tr>
                <tr><td nowrap=""><%=currentTime%></td></tr>
                <%--<tr><td nowrap=""><emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getAttribute("timeZone")%>' format='<%=DateFrm %>' displaydate ="true" displaytime ="true"><%=currentTime%></emxUtil:lzDate></td></tr> --%>
                </table>
            </td>
        </tr>
        </table>
        <hr noshade>

    <%
    } else {
          String bdcls = "properties";
          if("slidein".equals(targetLocation)){
              bdcls = "slide-in-panel properties";
          }
%>
        <body class="<%=bdcls%>" onload="buildNumericFieldValues('view');turnOffProgress();">
<%
    }

    if (fields == null || fields.size() == 0)
    {
%>
<script language="javascript">
        parent.document.location.href = "emxFormNoDisplay.jsp";
</script>
<%
        return;

    } else {
%>
<form name="frmFormView">
<%
if ( sPFmode != null && sPFmode.equals("true") )
{
%>
<%@include file = "../emxStyleDefaultPFInclude.inc"%>
<%@include file = "../emxStylePropertiesPFInclude.inc"%>
<%
}
%>
<table class="form"><%


        for (int i=0; i < fields.size(); i++)
        {
            HashMap field = (HashMap)fields.get(i);
            if ( !formViewBean.hasAccessToFiled(field) )
                continue;

            String fieldName = formViewBean.getName(field);
            String fieldLabel = formViewBean.getFieldLabel(field);
            String fieldValue = "";
            String fieldValueDisplay = "";

            StringList objectIcons = new StringList();
            StringList fieldHrefList = new StringList();

            StringList fieldValueList = formViewBean.getFieldValues(field);
            StringList fieldValueDisplayList = formViewBean.getFieldDisplayValues(field);

            if (fieldValueList != null && fieldValueList.size() > 0)
                fieldValue = (String)fieldValueList.firstElement();
            boolean isNumeric = formViewBean.getSetting(field, "Data Type") == "numeric";
            String arithExpr = formViewBean.getSetting(field, "Arithmetic Expression");
            String jsFieldName = formViewBean.getSetting(field,"jsFieldName");
            String decprec = formViewBean.getSetting(field,"Decimal Precision");
            if(isNumeric){
                String jsFieldValue = fieldValue;
                if(jsFieldValue == null || "".equals(jsFieldValue)){
                    jsFieldValue = "0";
                }
            %><script>
            eval("var <%=jsFieldName%> = <%=jsFieldValue%>;");
            </script>
            <input type="hidden" name = "<%=fieldName%>" jsname="<%=jsFieldName%>" expression="<%=arithExpr%>" datatype="numeric" value="<%=fieldValue%>"><%
            }else if(arithExpr != null && !"".equals(arithExpr)){
                %>
                <input type="hidden" name = "<%=fieldName%>" decprec="<%=decprec%>" expression="<%=arithExpr%>" value="<%=fieldValue%>"><%
            }

            if (fieldValueDisplayList != null && fieldValueDisplayList.size() > 0)
                fieldValueDisplay = (String)fieldValueDisplayList.firstElement();

            if (formViewBean.showIcon(field))
                objectIcons = formViewBean.getFieldIcons(field);

            if (formViewBean.isFieldHyperLinked(field))
                fieldHrefList = formViewBean.getFieldHRefValues(field, request, context, objectId, relId);

            if (formViewBean.isFieldSectionHeader(field))
            {
                if (formViewBean.getSectionLevel(field) == 1)
                {
%>
<tr id="calc_<%=fieldName%>" ><td colspan="<%=maxCols%>" class="heading1"><%=fieldLabel%></td></tr>
<%
                } else {
%>
<tr id="calc_<%=fieldName%>"><td colspan="<%=maxCols%>" class="heading2"><%=fieldLabel%></td></tr>
<%
                }
            } else if (formViewBean.isFieldSectionSeparator(field))
            {
%>
<tr id="calc_<%=fieldName%>"><td colspan="<%=maxCols%>">&nbsp;</td></tr>
<%
            }  else if (formViewBean.isProgramHTMLOutputField(field)  )
            {
                String strHideLabel = formViewBean.getSetting(field, "Hide Label");
                int tempMaxCols = maxCols;
                boolean showLabel = true;
                if ("true".equalsIgnoreCase(strHideLabel)){
                  showLabel = false;
                  tempMaxCols++;
                }

                //show Multiple Fields
                String strMultipleFields = formViewBean.getSetting(field, formViewBean.SETTING_MULTIPLE_FIELDS);
                //If strMultipleFields is true, the do not add <tr> tags
                if(strMultipleFields != null && "true".equalsIgnoreCase(strMultipleFields))
                {
                    // pass show label as false
%>
                    <%=drawFormViewElement(context, requestMap, field, timeZone, sPFmode, false, tempMaxCols)%>
<%
                } else if (formViewBean.isGroupHolderField(field) || formViewBean.isGroupField(field))
            {
        int iTEMP = 0;
                Integer iGroup = new Integer(formViewBean.getFieldGroupCount(field));
              HashMap mapTotalVerticalGroups = new HashMap();
              StringList strlVerticalGroupNames = new StringList();
                // Added for web form row span layout
                if(formViewBean.isGroupHolderField(field))
                    i++;
                int grpMaxCols = 2;
                for (int j = 0; j < iGroup.intValue(); j++,i++){
                     field = (HashMap)fields.get(i);
                     if ( !formViewBean.hasAccessToFiled(field) )
                         continue;
                     Integer iVerticalGroup = new Integer(formViewBean.getFieldVerticalGroupCount(field));
                     String strVerticalGroupName = (String) formViewBean.getSetting(field,"Vertical Group Name");

                     if(iVerticalGroup.intValue()>0){
                         strlVerticalGroupNames.add(strVerticalGroupName);
                         mapTotalVerticalGroups.put(strVerticalGroupName,iVerticalGroup);
                    }
                }
                i=i-iGroup.intValue();
                if(mapTotalVerticalGroups!=null && mapTotalVerticalGroups.size()>0) {
                     for(int c=0;c<strlVerticalGroupNames.size();c++) {
                        Integer integer = (Integer)mapTotalVerticalGroups.get(strlVerticalGroupNames.get(c).toString());
                        if(iTEMP<integer.intValue()) {
                            iTEMP = integer.intValue();
                        }
                     }
                }

                if(strlVerticalGroupNames.size()>0) {
                      int itemp = i;
                      int itempCopy = i;
                      int iLoopExecforRowSpan = 0;
                      StringList strlDisplayedFields = new StringList();

                      for(int m = 0;m <iGroup.intValue();) {
                            grpMaxCols = 2;
                            iLoopExecforRowSpan++;
                            %>
                            <tr>
                            <%

                            for(int n=0;n<strlVerticalGroupNames.size()&& m<iGroup.intValue() && itemp<i+iGroup.intValue();n++) {
                                int iRowSpan = 1;
                                grpMaxCols = 2;
                                field = (HashMap) fields.get(itemp);

                                if(strlDisplayedFields.contains(""+itemp)) {
                                     String strnGrpName = (String) strlVerticalGroupNames.get(n);
                                     Integer intGrpcount = (Integer)mapTotalVerticalGroups.get(strnGrpName);
                                     itemp = itemp + intGrpcount.intValue();
                                     continue;
                                }
                                else {
                                     m++;
                                     // For calculating the next element
                                     String strVerGrpName = (String) strlVerticalGroupNames.get(n);
                                     Integer IVerticalGrpCnt = (Integer)mapTotalVerticalGroups.get(strVerGrpName);
                                     // To get the next vertical group first value

                                      // Calculating RowSpan
                                      int iNextSetFirstValue = IVerticalGrpCnt.intValue();

                                      // To check teh setting Hide label for displaying the label
                                     String strHideLabel1 = formViewBean.getSetting(field, "Hide Label");
                                     boolean showLabel1 = true;
                                     if ("true".equalsIgnoreCase(strHideLabel1)){
                                        showLabel1 = false;
                                       grpMaxCols =grpMaxCols + 1;
                                     }

                                      if(iNextSetFirstValue<iTEMP){
                                          iRowSpan = 1;
                                      }

                                      if(iLoopExecforRowSpan != iTEMP && iLoopExecforRowSpan == IVerticalGrpCnt.intValue()) {
                                          iRowSpan = iTEMP - IVerticalGrpCnt.intValue()+1;
                                      }
                                      // Ended calc

                                      if ( (strlVerticalGroupNames.size()*2 < maxCols) && (n == strlVerticalGroupNames.size()-1) ){
                                         grpMaxCols = maxCols - (strlVerticalGroupNames.size()*2)+2;
                                         if(showLabel1 == false)
                                             grpMaxCols = grpMaxCols + 1;
                                      }
                                      strlDisplayedFields.add(""+itemp);

                                      if ( !formViewBean.hasAccessToFiled(field) )
                                          continue;
                                       %>
                                      <%=drawFormViewElement(context, requestMap, field, timeZone, sPFmode, showLabel1, grpMaxCols,iRowSpan)%>
                                      <%
                                      // To get the next vertical group first value
                                      itemp = itemp+IVerticalGrpCnt.intValue();
                                }
                           }
                           itemp = ++itempCopy;
                           %>
                           </tr>
                           <%
                      }
                      i+=iGroup.intValue();
                  }
                  else{
                        %>
                        <tr id="calc_<%=fieldName%>">
                        <%
                        for (int j = 0; j < iGroup.intValue(); j++,i++) {
                                field = (HashMap)fields.get(i);
                                if ( !formViewBean.hasAccessToFiled(field) )
                                    continue;

                                if ( (iGroup.intValue()*2 < maxCols) && (j == iGroup.intValue()-1) )
                                    grpMaxCols = maxCols - (iGroup.intValue()*2)+2;

                                fieldLabel = formViewBean.getFieldLabel(field);
                                fieldValueList = formViewBean.getFieldValues(field);
                                fieldValueDisplayList = formViewBean.getFieldDisplayValues(field);

                                if (fieldValueList != null && fieldValueList.size() > 0)
                                    fieldValue = (String)fieldValueList.firstElement();

                                if (fieldValueDisplayList != null && fieldValueDisplayList.size() > 0)
                                    fieldValueDisplay = (String)fieldValueDisplayList.firstElement();
                                %>
                                <%=drawFormViewElement(context, requestMap, field, timeZone, sPFmode, true, grpMaxCols)%>
                                <%
                        }
                }
                i--;
%></tr><%
            }
                else
                {
%>
                <tr id="calc_<%=fieldName%>">
                    <%=drawFormViewElement(context, requestMap, field, timeZone, sPFmode, showLabel, tempMaxCols)%>
                </tr>
<%
                }
            } else if (formViewBean.isClassificationAttributesField(field)  )
            {
                int tempMaxCols = maxCols;
                tempMaxCols++;

%>
                    <%=drawFormViewElement(context, requestMap, field, timeZone, sPFmode, false, tempMaxCols)%>
<%
           }
           else if (formViewBean.isTableField(field))
            {
                String table = formViewBean.getSetting(field, "table");
                reportFormat = "";
                String printerFriednly = "false";
                if ( sPFmode != null && sPFmode.equals("true") )
                {
                    printerFriednly = sPFmode;
                    reportFormat = "HTML";
                }
%>
<tr><td colspan="<%=maxCols%>" class="heading1">
<jsp:include page = "emxFormTableInclude.jsp" flush="true">
    <jsp:param name="timeStamp" value='<%=timeStamp + fieldName%>'/>
    <jsp:param name="jsTreeID" value='<%=jsTreeID%>'/>
    <jsp:param name="objectId" value='<%=objectId%>'/>
    <jsp:param name="relId" value='<%=relId%>'/>
    <jsp:param name="table" value='<%=table%>'/>
    <jsp:param name="inquiry" value='<%=formViewBean.getSetting(field, "inquiry")%>'/>
    <jsp:param name="program" value='<%=formViewBean.getSetting(field, "program")%>'/>
    <jsp:param name="sortColumnName" value='<%=formViewBean.getSetting(field, "sortColumnName")%>'/>
    <jsp:param name="sortDirection" value='<%=formViewBean.getSetting(field, "sortDirection")%>'/>
    <jsp:param name="pagination" value="0"/>
    <jsp:param name="isfromFORMPagination" value="true"/>
    <jsp:param name="selection" value="none"/>
    <jsp:param name="reportFormat" value='<%=reportFormat%>'/>
    <jsp:param name="printerFriednly" value='<%=printerFriednly%>'/>
</jsp:include>
</td></tr>
<%
            } else if (formViewBean.isGroupHolderField(field) || formViewBean.isGroupField(field))
            {
        int iTEMP = 0;
                Integer iGroup = new Integer(formViewBean.getFieldGroupCount(field));
              HashMap mapTotalVerticalGroups = new HashMap();
              StringList strlVerticalGroupNames = new StringList();
                // Added for web form row span layout
                if(formViewBean.isGroupHolderField(field))
                    i++;
                int grpMaxCols = 2;
                for (int j = 0; j < iGroup.intValue(); j++,i++){
                     field = (HashMap)fields.get(i);
                     if ( !formViewBean.hasAccessToFiled(field) )
                         continue;
                     Integer iVerticalGroup = new Integer(formViewBean.getFieldVerticalGroupCount(field));
                     String strVerticalGroupName = (String) formViewBean.getSetting(field,"Vertical Group Name");

                     if(iVerticalGroup.intValue()>0){
                         strlVerticalGroupNames.add(strVerticalGroupName);
                         mapTotalVerticalGroups.put(strVerticalGroupName,iVerticalGroup);
                    }
                }
                i=i-iGroup.intValue();
                if(mapTotalVerticalGroups!=null && mapTotalVerticalGroups.size()>0) {
                     for(int c=0;c<strlVerticalGroupNames.size();c++) {
                        Integer integer = (Integer)mapTotalVerticalGroups.get(strlVerticalGroupNames.get(c).toString());
                        if(iTEMP<integer.intValue()) {
                            iTEMP = integer.intValue();
                        }
                     }
                }

                if(strlVerticalGroupNames.size()>0) {
                      int itemp = i;
                      int itempCopy = i;
                      int iLoopExecforRowSpan = 0;
                      StringList strlDisplayedFields = new StringList();

                      for(int m = 0;m <iGroup.intValue();) {
                            grpMaxCols = 2;
                            iLoopExecforRowSpan++;
                            %>
                            <tr>
                            <%

                            for(int n=0;n<strlVerticalGroupNames.size()&& m<iGroup.intValue() && itemp<i+iGroup.intValue();n++) {
                                int iRowSpan = 1;
                                grpMaxCols = 2;
                                field = (HashMap) fields.get(itemp);

                                if(strlDisplayedFields.contains(""+itemp)) {
                                     String strnGrpName = (String) strlVerticalGroupNames.get(n);
                                     Integer intGrpcount = (Integer)mapTotalVerticalGroups.get(strnGrpName);
                                     itemp = itemp + intGrpcount.intValue();
                                     continue;
                                }
                                else {
                                     m++;
                                     // For calculating the next element
                                     String strVerGrpName = (String) strlVerticalGroupNames.get(n);
                                     Integer IVerticalGrpCnt = (Integer)mapTotalVerticalGroups.get(strVerGrpName);
                                     // To get the next vertical group first value

                                      // Calculating RowSpan
                                      int iNextSetFirstValue = IVerticalGrpCnt.intValue();

                                      // To check teh setting Hide label for displaying the label
                                     String strHideLabel = formViewBean.getSetting(field, "Hide Label");
                                     boolean showLabel = true;
                                     if ("true".equalsIgnoreCase(strHideLabel)){
                                        showLabel = false;
                                       grpMaxCols =grpMaxCols + 1;
                                     }

                                      if(iNextSetFirstValue<iTEMP){
                                          iRowSpan = 1;
                                      }

                                      if(iLoopExecforRowSpan != iTEMP && iLoopExecforRowSpan == IVerticalGrpCnt.intValue()) {
                                          iRowSpan = iTEMP - IVerticalGrpCnt.intValue()+1;
                                      }
                                      // Ended calc

                                      if ( (strlVerticalGroupNames.size()*2 < maxCols) && (n == strlVerticalGroupNames.size()-1) ){
                                         grpMaxCols = maxCols - (strlVerticalGroupNames.size()*2)+2;
                                         if(showLabel == false)
                                             grpMaxCols = grpMaxCols + 1;
                                      }
                                      strlDisplayedFields.add(""+itemp);

                                      if ( !formViewBean.hasAccessToFiled(field) )
                                          continue;
                                       %>
                                      <%=drawFormViewElement(context, requestMap, field, timeZone, sPFmode, showLabel, grpMaxCols,iRowSpan)%>
                                      <%
                                      // To get the next vertical group first value
                                      itemp = itemp+IVerticalGrpCnt.intValue();
                                }
                           }
                           itemp = ++itempCopy;
                           %>
                           </tr>
                           <%
                      }
                      i+=iGroup.intValue();
                  }
                  else{
                        %>
                        <tr id="calc_<%=fieldName%>">
                        <%
                        int hideLabelCount =0;
                        for (int j = 0; j < iGroup.intValue(); j++,i++) {
                                field = (HashMap)fields.get(i);
                                if ( !formViewBean.hasAccessToFiled(field) )
                                    continue;
                                // To check the setting Hide label for displaying the label
                                String strHideLabel1 = formViewBean.getSetting(field, "Hide Label");
                                boolean showLabel1 = true;
                                if ("true".equalsIgnoreCase(strHideLabel1)){
                                  showLabel1 = false;
                                  hideLabelCount ++;
                                }
                                if ( (iGroup.intValue()*2 <= maxCols) && (j == iGroup.intValue()-1) ){

                                    grpMaxCols = maxCols - (iGroup.intValue()*2)+2 +hideLabelCount;
                                }

                                fieldLabel = formViewBean.getFieldLabel(field);
                                fieldValueList = formViewBean.getFieldValues(field);
                                fieldValueDisplayList = formViewBean.getFieldDisplayValues(field);

                                if (fieldValueList != null && fieldValueList.size() > 0)
                                    fieldValue = (String)fieldValueList.firstElement();

                                if (fieldValueDisplayList != null && fieldValueDisplayList.size() > 0)
                                    fieldValueDisplay = (String)fieldValueDisplayList.firstElement();
                                %>
                                <%=drawFormViewElement(context, requestMap, field, timeZone, sPFmode, showLabel1, grpMaxCols)%>
                                <%
                        }
                }
                i--;
%></tr><%
            } else if (formViewBean.isTableHolderField(field) )
            {
                String languageStr = request.getHeader("Accept-Language");
                String colCount = formViewBean.getSetting(field, "Field Table Columns");
                String rowCount = formViewBean.getSetting(field, "Field Table Rows");
                String colHeader = formViewBean.getSetting(field, "Field Column Headers");
                String rowHeader = formViewBean.getSetting(field, "Field Row Headers");

                String fieldSuite = formViewBean.getSetting(field, "Registered Suite");
                String stringResourceFile = UINavigatorUtil.getStringResourceFileId(context,fieldSuite);

                colHeader = EnoviaResourceBundle.getProperty(context,stringResourceFile,context.getLocale(),colHeader);
                rowHeader = EnoviaResourceBundle.getProperty(context,stringResourceFile,context.getLocale(),rowHeader);

                StringList colHeaderList = FrameworkUtil.split(colHeader, ",");
                StringList rowHeaderList = FrameworkUtil.split(rowHeader, ",");

                int cols = (Integer.valueOf(colCount)).intValue();
                int rows = (Integer.valueOf(rowCount)).intValue();
                i++;

%><tr id="calc_<%=fieldName%>"><td colspan="<%=maxCols%>"><table  class="list"><tr>
<td class="label" >&nbsp;</td><%
                String colHeaderName = "";
                String i18nColHeaderValue = "";
                for (int j = 0; j < cols; j++)
                {
                                        try {
                                                colHeaderName = (String)colHeaderList.get(j);
                                                i18nColHeaderValue = EnoviaResourceBundle.getProperty(context,stringResourceFile,context.getLocale(),colHeaderName);
                                        } catch (Exception e) {
                                                i18nColHeaderValue = "&nbsp";
                                        }
%>
<td class="label" ><%=i18nColHeaderValue%></td>
<%
                }

                for (int r = 0; r < rows; r++)
                {
                    String rowHeaderName = (String)rowHeaderList.get(r);
                    String i18nRowHeaderValue = EnoviaResourceBundle.getProperty(context,stringResourceFile,context.getLocale(),rowHeaderName);

%></tr><td class="label" ><%=i18nRowHeaderValue%></td>
<%
                    for (int k = 0; k < cols; k++,i++)
                    {
                        field = (HashMap)fields.get(i);
                        if ( !formViewBean.hasAccessToFiled(field) )
                        {
                             field.put("field_display_value","");
                             field.put("field_value","");
                     }

%><%=drawFormViewElement(context, requestMap, field, timeZone, sPFmode, false, 2)%><%
                    }
                }

                i--;
%></tr></table></td></tr><%
            } else if (fieldValueList == null || fieldValueList.isEmpty())
            {
%>
<tr id="calc_<%=fieldName%>"><td class="label" ><%=fieldLabel%></td>
<%
if("slidein".equals(targetLocation)){
%>
</tr><tr>
<%
}
%>
<td class="field" colspan="<%=(maxCols-1)%>">&nbsp;</td></tr>
<%
            } else {
              String strHideLabel = formViewBean.getSetting(field, "Hide Label");
              int tempMaxCols = maxCols;
              boolean showLabel = true;
              if ("true".equalsIgnoreCase(strHideLabel)){
                showLabel = false;
                tempMaxCols++;
              }
%>
<tr id="calc_<%=fieldName%>">
    <%=drawFormViewElement(context, requestMap, field, timeZone, sPFmode, showLabel, tempMaxCols)%>
</tr>
<%
            }
        }
    }

} catch (Exception ex) {

    ContextUtil.abortTransaction(context);
    ex.printStackTrace();
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage("emxFormViewDisplay:" + ex.toString().trim());

} finally {
    ContextUtil.commitTransaction(context);
}
%>

<!-- commented for bug 370006
<td width="150"><img src="images/utilSpacer.gif" width="150" height="1" alt="" border="0"></td>
<td class="smallSpace" width="90%" colspan="<%=maxCols-1%>">&nbsp;</td>
-->
</tr>
</table>

<input type="hidden" name="objectId" value="<%=objectId%>">
<input type="hidden" name="objectName" value="<%=objectName%>">
<input type="hidden" name="relId" value="<%=relId%>">
<input type="hidden" name="form" value="<%=form%>">
<input type="hidden" name="timeStamp" value="<%=timeStamp%>">
<input type="hidden" name="parseHeader" value="">
<input type="hidden" name="emxSuiteDirectory" value="<%=emxSuiteDirectory%>">
<input type="hidden" name="parsedHeader" value="<%=parsedHeader%>">
<input type="hidden" name="subHeader" value="<%=subHeader%>">
<input type="hidden" name="suiteKey" value="<%=suiteKey%>">
<input type="hidden" name="originalHeader" value="<%=originalHeader%>">


</form>
<%
    //
    // Include the file summary
    //
    String strDisplayCDMFileSummary = emxGetParameter(request, "displayCDMFileSummary");

    if ("true".equalsIgnoreCase(strDisplayCDMFileSummary)) {
%>
<div class="inline-table">

<!--  Fix for IR-094681V6R2012x by m6d starts -->

<!-- Code added from ..common/emxFormCDMFileSummary.inc file in our new jsp  -->

        <!--Begin:Addition:Form Single Page Properties and Files-->
<%
            final String ATTRIBUTE_IS_VERSION_OBJECT = PropertyUtil.getSchemaProperty(context, "attribute_IsVersionObject");
            final String SELECT_ATTRIBUTE_IS_VERSION_OBJECT = "attribute[" + ATTRIBUTE_IS_VERSION_OBJECT + "]";

            StringList slBusSelect = new StringList();
            slBusSelect.add("vcfile");
            slBusSelect.add("vcfolder");
            slBusSelect.add(DomainObject.SELECT_TYPE);
            slBusSelect.add(SELECT_ATTRIBUTE_IS_VERSION_OBJECT);

            DomainObject dmoObject = new DomainObject(objectId);
            Map mapObjectInfo = dmoObject.getInfo(context, slBusSelect);

            String vcfile = (String)mapObjectInfo.get("vcfile");
            String vcfolder = (String)mapObjectInfo.get("vcfile");
            String busType = (String)mapObjectInfo.get(DomainObject.SELECT_TYPE);
            String strIsVersionObject = (String)mapObjectInfo.get(SELECT_ATTRIBUTE_IS_VERSION_OBJECT);

            String languageStr = request.getHeader("Accept-Language");

            // Is the page invoked in Printer Friendly mode ?
            boolean isPrinterFriendly = "true".equalsIgnoreCase(emxGetParameter(request, "PFmode"));

            //
            // Following code will show the file summary table for the document object which is not DSFA document.
            // Depending on if the document is versionable or non-versionable the corresponding file summary will be shown.
            // To show the file summary existing UI table objects will be used. The emxTable.jsp page will be rendered inside iframe tag.
            //

            // Check if it is not DesignSync File
            if ("false".equalsIgnoreCase(vcfile) && "false".equalsIgnoreCase(vcfolder))
            {
                // Decide if versioning is allowed
                boolean allowVersioning = false;
                String parentType = com.matrixone.apps.common.CommonDocument.getParentType(context, busType);

                if( com.matrixone.apps.common.CommonDocument.TYPE_DOCUMENTS.equals(parentType) )
                {
                    String property = PropertyUtil.getAdminProperty(context, "Type", busType, "DISALLOW_VERSIONING");
                    allowVersioning = !("true".equalsIgnoreCase(property));
                }

                String strTableURL = null;
                if(allowVersioning)
                {
                    if (!"True".equalsIgnoreCase(strIsVersionObject))
                    {
                        if (!isPrinterFriendly) {
                            strTableURL = "../common/emxTable.jsp?program=emxCommonFileUI:getFiles&table=APPFileSummary&selection=multiple&sortColumnName=Name&sortDirection=ascending&HelpMarker=emxhelpdocumentfilelist&objectId="+ objectId + "&StringResourceFileId=emxComponentsStringResource&pagination=0&Export=false&objectCompare=false&PrinterFriendly=false&suiteKey=Components&FilterFramePage=../components/emxCommonDocumentCheckoutUtil.jsp&FilterFrameSize=1&header=emxComponents.Menu.Files&treePopup=true&showClipboard=false";
                        }
                        else {
                            strTableURL = "";
                        }
                    }
                    else
                    {
                        // Do nothing
                        // No files table will be shown
                    }
                }
                else
                {
                    if (!isPrinterFriendly) {
                        strTableURL = "../common/emxTable.jsp?program=emxCommonFileUI:getNonVersionableFiles&table=APPNonVersionableFileSummary&selection=multiple&HelpMarker=emxhelpdocumentfilelist&objectId="+ objectId + "&StringResourceFileId=emxComponentsStringResource&pagination=0&Export=false&objectCompare=false&PrinterFriendly=false&objectBased=false&suiteKey=Components&AppendFileName=true&FilterFrameSize=1&header=emxComponents.Menu.Files&sortColumnName=Name&sortDirection=ascending&showClipboard=false";
                    }
                    else {
                        strTableURL = "";
                    }
                }

                // If table url is formed then show the table
                if (strTableURL != null)
                {
        %>
                    <iframe src="<%=strTableURL%>" name="frameFilesTable" id="frameFilesTable" frameborder="0"></iframe>
        <%
                }
        %>
                <SCRIPT LANGUAGE="JavaScript">
                <!--
                    //
                    // The command handler functions required when user clicks "Delete All Versions", "Delete This Version" and "Delete Selected Files" commands
                    // on document properties page.
                    //

                    function checkinUpload_onclick() {
                        showModalDialog("<%=Framework.encodeURL(response, "../components/emxCommonDocumentPreCheckin.jsp?objectAction=checkin&objectId=" + objectId +"&suiteKey=" + suiteKey)%>" , 780, 570, true);
                    }

                    function updateFiles_onclick() {
                        showModalDialog("<%=Framework.encodeURL(response, "../components/emxCommonDocumentPreCheckin.jsp?objectAction=update&showFormat=readonly&showComments=required&objectId=" + objectId +"&suiteKey=" + suiteKey)%>" , 875, 525, true);
                    }

                    function download_onclick() {
                        callCheckout("<%=objectId%>","download");
                    }

                    function checkout_onclick() {
                        callCheckout("<%=objectId%>","checkout");
                    }

                    function deleteThisVersion_onclick() {
                        commonDeleteFileUtil('deleteVersion');
                    }

                    function deleteAllVersions_onclick() {
                        commonDeleteFileUtil('deleteFile');
                    }

                    function deleteSelectedFiles_onclick() {
                        commonDeleteFileUtil('deleteNonVersionableFile');
                    }

                    function renderPDF_onclick() {
                        if (!isFileSelected()) {
                            alert("<%=EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource",loc,"emxComponents.Common.SelectFile")%>");
                            return;
                        }

                        var tableForm = getFilesTableForm();
                        if (tableForm == null) {
                            return;
                        }

                        tableForm.action = "<%=Framework.encodeURL(response, "../batchprintpdf/emxBatchPrintPDFRenderProcess.jsp?objectId=" + objectId +"&suiteKey=" + suiteKey)%>";
                        tableForm.target = "formViewHidden";
                        tableForm.submit();
                    }

                    function getFilesTableForm() {
                        var frameFilesTable = findFrame(window, 'frameFilesTable');
                        if (frameFilesTable) {

                            // Find the frame in which the files listing is shown
                            var frameListDisplay = findFrame(frameFilesTable, 'listDisplay');
                            if (frameListDisplay) {

                                // Find the name of the form in table
                                var emxTableForm = frameListDisplay.document.forms['emxTableForm'];
                                if (emxTableForm) {
                                    return emxTableForm;
                                }
                            }
                        }

                        return null;
                    }
                    function checkoutSelectedFiles(action) {
                        // Find the name of the form in table
                        var emxTableForm = getFilesTableForm();
                        if (emxTableForm != null) {
                            //Find if user has selected at least one file
                            var emxTableFormElements = emxTableForm.elements;
                            var selectedIds = "";
                            for (var i = 0; i < emxTableFormElements.length; i++) {
                                var emxTableFormElement = emxTableFormElements[i];
                                if (emxTableFormElement.type == "checkbox" && emxTableFormElement.name == "emxTableRowId" && emxTableFormElement.checked) {
                                    selectedIds = selectedIds + emxTableFormElement.value + ",";
                                }
                            }
                            // If no file is selected then show error
                            if (selectedIds == "") {
                                alert("<%=EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource",loc,"emxComponents.Common.SelectFile")%>");
                                return;
                            }
                            selectedIds = selectedIds.substring(0, selectedIds.length-1);
                            var contentStoreURL = "../components/emxComponentsStoreFormDataToSession.jsp" ;
                            var queryString = "emxTableRowId="+selectedIds+"&action="+action+"&parentOID=<%=objectId%>&objectId=<%=objectId%>"+
                                "&StringResourceFileId=emxComponentsStringResource&SuiteDirectory=components&suiteKey=Components";
                            var xmlResult = emxUICore.getXMLDataPost(contentStoreURL, queryString);
                            var root = xmlResult.documentElement;
                            var sessionKey = emxUICore.getText(emxUICore.selectSingleNode(root, "/mxFormData/sessionKey"));
                            callCheckout("","","","","","","","","","","","","","","","true",sessionKey);
                        } else {
                            callCheckout("<%=objectId%>","checkout");
                        }
                    }

                    function commonDeleteFileUtil(sAction) {

                        // Find the name of the form in table
                        var emxTableForm = getFilesTableForm();
                        if (emxTableForm != null) {
                            // If no file is selected then show error
                            if (!isFileSelected()) {
                                alert("<%=EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource",loc,"emxComponents.Common.SelectFile")%>");
                                return;
                            }

                            // Confirm for deletion and then delete
                            if (window.confirm("<%=EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource",loc,"emxComponents.Alert.RemoveFile")%>")) {
                                // Submit the form in hidden frame

                                emxTableForm.action = "../components/emxCommonDocumentRemove.jsp?action="+sAction;
                                //Fix for IR-094681V6R2012x by m6d starts
                                emxTableForm.target = "pagecontent"; //(target frame changed from "formViewHidden" to "pagecontent" to target our custom frame)
                                //Fix for IR-094681V6R2012x by m6d ends

                                emxTableForm.submit();

                            }
                        }
                    }

                    function isFileSelected() {
                        // Find the name of the form in table
                        var emxTableForm = getFilesTableForm();
                        if (emxTableForm != null) {

                            //Find if user has selected at least one file
                            var emxTableFormElements = emxTableForm.elements;
                            for (var i = 0; i < emxTableFormElements.length; i++) {
                                var emxTableFormElement = emxTableFormElements[i];
                                if (emxTableFormElement.type == "checkbox" && emxTableFormElement.name == "emxTableRowId" && emxTableFormElement.checked) {
                                    return true;
                                }
                            }
                        }

                        return false;
                    }
        <%
                    // If the page is opened in printer friendly mode, get the timestamp of the ui table
                    // from the already opened table page and then load the printer friendly table in the iframe.
                    if (isPrinterFriendly) {
        %>
                        var strTimestamp = "";

                        // Find the reference of the window where the document properties are displayed
                        var objPageContentWnd = findFrame(window.getWindowOpener().parent, "formViewDisplay");
                        if (objPageContentWnd) {
                            // Find the reference of the iframe where the document files are displayed
                            var objIframe = objPageContentWnd.frames["frameFilesTable"];
                            if (objIframe) {
                                // Find the reference of the window where the document files table is displayed
                                var objListDisplayWnd = objIframe.frames['listDisplay'];
                                if (objListDisplayWnd) {
                                    // Find the reference of the form emxTableForm in window where the document files table is displayed
                                    var emxTableForm = objListDisplayWnd.document.forms['emxTableForm'];
                                    if (emxTableForm) {
                                        // Find the value of timestamp input element from the form found
                                        for (var i = 0; i < emxTableForm.elements.length; i++) {
                                            if (emxTableForm.elements[i].name == 'timeStamp') {
                                                strTimestamp = emxTableForm.elements[i].value;
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        var iFrameFilesTable = window.frames["frameFilesTable"];
                        if (iFrameFilesTable && strTimestamp != "") {
                            iFrameFilesTable.location.href = "../common/emxTableReportView.jsp?timeStamp=" + strTimestamp + "&reportFormat=HTML&TransactionType=read";
                        }
        <%
                    }
        %>
                //-->
                </SCRIPT>
        <%
            }
            else {
                // Do nothing
                // No files table will be shown
                // DSFA summary is not supported
            }
        %>
        <script language="JavaScript">
        <!--
            turnOffProgress();
        //-->
        </script>

<!--  Fix for IR-094681V6R2012x by m6d ends -->
</div>
<%
    }
%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>

<%
UIUtil.logConfigurations(context, request, requestMap);
%>

