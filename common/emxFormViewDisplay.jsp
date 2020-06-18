<%--  emxFormViewDisplay.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFormViewDisplay.jsp.rca 1.37.2.2 Tue Dec  9 06:53:31 2008 ds-arajendiran Experimental $
--%>


<%@page import="com.matrixone.apps.domain.util.EnoviaBrowserUtility.Browsers"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil,com.matrixone.apps.framework.ui.UIUtil"%>
<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxFormUtil.inc"%>
<script src="../plugins/libs/jqueryui/1.10.3/js/jquery-ui.js"></script>
<jsp:useBean id="formViewBean" class="com.matrixone.apps.framework.ui.UIForm" scope="request"/>
<jsp:useBean id="formViewCommonBean" class="com.matrixone.apps.framework.ui.UIFormCommon" scope="request"/>
<%!
static public String replaceCharacters(String source, char[] charList, char replacementChar)
{
  String retString = source;
  if(retString==null)
  {
    retString="";
  }
  if(charList !=null && charList.length>0 )
  {
       for (int index = 0; index < charList.length; index++)
         {
            char sElement = charList[index];
            retString=retString.replace(sElement,replacementChar);
         }

    }

return retString;

}

%>
<%
String form = emxGetParameter(request, "form");
String title ="";
String suiteKey = emxGetParameter(request, "suiteKey");
String header = emxGetParameter(request, "header");
String objectId = emxGetParameter(request, "objectId");
String originalHeader =emxGetParameter(request, "originalHeader");

String strResourceFile = UINavigatorUtil.getStringResourceFileId(context,suiteKey);
if(UIUtil.isNullOrEmpty(header)){
	title = "body_" + form;
}else{
	   title = UIForm.getFormHeaderString(context, pageContext, originalHeader, objectId, suiteKey, request.getHeader("Accept-Language"));
}

String objectName = emxGetParameter(request, "objectName");
String relId = emxGetParameter(request, "relId");
String timeStamp = emxGetParameter(request, "timeStamp");
String jsTreeID = emxGetParameter(request, "jsTreeID");
String sPFmode = emxGetParameter(request, "PFmode");
String treeUpdate = emxGetParameter(request, "treeUpdate");

String targetLocation = emxGetParameter(request,"targetLocation");
String slideinType = emxGetParameter(request,"slideinType");
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
	String fileEncodeType = UINavigatorUtil.getFileEncoding(context, request);
	response.setContentType("text/html; charset="+fileEncodeType);
	String fileCreateTimeStamp = Long.toString(System.currentTimeMillis());
	String filename = parsedHeader + fileCreateTimeStamp + ".html";
	String badChars=":><[]|*/\\; ";
	char[] charArray=badChars.toCharArray();
	char repchar='_';
	
	String encFileName = replaceCharacters(filename, charArray, repchar);
	
	boolean canHandleUTF_8 = EnoviaBrowserUtility.is(request,Browsers.FIREFOX);//anything except FF
	if (canHandleUTF_8) {
		encFileName = "=?UTF-8?B?" + new String(FrameworkUtil.encodeBase64(encFileName.getBytes("UTF-8"),false), "UTF-8") + "?=";
	}else{
		encFileName = FrameworkUtil.encodeURL(encFileName, "UTF8");
	}
	response.setHeader ("Content-Disposition","attachment; filename=\"" + encFileName +"\"");
	response.setLocale(request.getLocale());
}

//to get the dateformat
String DateFrm = PersonUtil.getPreferenceDateFormatString(context);
%>
<%
if ( sPFmode != null && sPFmode.equals("true") )
{
%>
<html>
<head>
<title><xss:encodeForHTML><%=title%></xss:encodeForHTML></title>

<%@include file = "emxUIConstantsInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUIObjMgr.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>

<script language="JavaScript" src="../common/scripts/jquery-latest.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/jshashtable/jshashtable.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/jquery-numberformatter/jquery-numberformatter.js" type="text/javascript"></script>
<script language="javascript" src="../common/scripts/emxUIFormUtil.js"></script>
<script language="JavaScript" src="../common/scripts/emxUITableUtil.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIPopups.js" type="text/javascript"></script>
</head>

<%@include file = "../emxStyleDefaultPFInclude.inc"%>
<%@include file = "../emxStylePropertiesPFInclude.inc"%>
<%@include file = "../emxStyleListPFInclude.inc"%>
<%
if ( altCSS != null && !"".equals(altCSS)){
  if (altCSS.indexOf(".css") > -1)
    altCSS = altCSS.substring(0,altCSS.indexOf(".css"));
%>
<script type="text/javascript">

  addStyleSheet("<%=XSSUtil.encodeForJavaScript(context, altCSS)%>");

</script>
<%
}
}
int maxCols = 2;
// Added for web form rowspan layout
int imaxVerticalRows = 1;
try {

    String transactionType = emxGetParameter(request, "TransactionType");
    boolean updateTransaction = (transactionType != null && transactionType.equalsIgnoreCase("update")); 

    ContextUtil.startTransaction(context, updateTransaction);
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
        <body class="properties" onunload="JavaScript:purgeViewFormData('<%=XSSUtil.encodeForHTML(context, timeStamp)%>')">
        <hr noshade>
        <table>
        <tr>
            <td class="pageHeader" width="60%"><xss:encodeForHTML> <%=parsedHeader%></xss:encodeForHTML></td>
            <td width="1%"><img src="images/utilSpacer.gif" width="1" height="28" alt="" /></td>
            <td width="39%" align="right"></td>
            <td nowrap>
                <table>
                <tr><td nowrap=""><xss:encodeForHTML> <%=userName%> </xss:encodeForHTML></td></tr>
                <tr><td nowrap=""><xss:encodeForHTML> <%=currentTime%> </xss:encodeForHTML></td></tr>
                <!-- //XSSOK -->
				<%--<tr><td nowrap=""><emxUtil:lzDate localize="i18nId" tz='<%=(String)session.getAttribute("timeZone")%>' format='<%=DateFrm %>' displaydate ="true" displaytime ="true"><%=currentTime%></emxUtil:lzDate></td></tr> --%>
                </table>
            </td>
        </tr>
        </table>
        <hr noshade>

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
        if(UIComponent.getUIAutomationStatus(context)){
%>
<form data-aid="<%=XSSUtil.encodeForHTML(context, form)%>" name="frmFormView">
<%
    	} else{
%>
<form name="frmFormView">
<%
    	}
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
                final String val = formViewBean.getSetting(field, "Data Type").toString();
            boolean isNumeric = "numeric".equals(val);

            boolean isNFEnabled = Boolean.parseBoolean(formViewBean.getSetting(field, "isNF").toString());

            String arithExpr = formViewBean.getSetting(field, "Arithmetic Expression");
            String jsFieldName = formViewBean.getSetting(field,"jsFieldName");
            String decprec = formViewBean.getSetting(field,"Decimal Precision");
            if(isNumeric){
                String jsFieldValue = fieldValue;
                if(jsFieldValue == null || "".equals(jsFieldValue)){
                    jsFieldValue = "0";
                }
            %><script>
            eval("var <%=XSSUtil.encodeForJavaScript(context, jsFieldName)%> = <%=XSSUtil.encodeForJavaScript(context, jsFieldValue)%>;");
            </script>
            <input type="hidden" name = "<%=fieldName%>" jsname="<%=jsFieldName%>" nfenabled="<%=isNFEnabled%>"  expression="<%=arithExpr%>" datatype="numeric" value="<%=fieldValue%>" /><%
            }else if(arithExpr != null && !"".equals(arithExpr)){
                %>
                <input type="hidden" name = "<%=fieldName%>" decprec="<%=decprec%>" expression="<%=arithExpr%>" value="<%=fieldValue%>" /><%
            }

            if (fieldValueDisplayList != null && fieldValueDisplayList.size() > 0)
                fieldValueDisplay = (String)fieldValueDisplayList.firstElement();

            if (formViewBean.showIcon(field))
                objectIcons = formViewBean.getFieldIcons(field);

            if (formViewBean.isFieldHyperLinked(field))
                fieldHrefList = formViewBean.getFieldHRefValues(field, request, context, objectId, relId);

            if (formViewBean.isFieldSectionHeader(field))
            {
            	if ((formViewBean.getSectionLevel(field) == 1) && "wider".equals(slideinType) )
            {
            	%>
            	<tr id="calc_<%=XSSUtil.encodeForHTML(context, fieldName)%>" ><td colspan="<%=maxCols+1%>" class="heading1"><%=XSSUtil.encodeForHTML(context, fieldLabel,false)%></td></tr>
            	<%
            	                }else if (formViewBean.getSectionLevel(field) == 1)
                {
%>
<tr id="calc_<%=XSSUtil.encodeForHTML(context, fieldName)%>" ><td colspan="<%=maxCols%>" class="heading1"><%=XSSUtil.encodeForHTML(context, fieldLabel,false)%></td></tr>
<%
                } else {
%>
<tr id="calc_<%=XSSUtil.encodeForHTML(context, fieldName)%>"><td colspan="<%=maxCols%>" class="heading2"><%=XSSUtil.encodeForHTML(context, fieldLabel,false)%></td></tr>
<%
                }
            } else if (formViewBean.isFieldSectionSeparator(field))
            {
%>
<tr id="calc_<%=XSSUtil.encodeForHTML(context, fieldName)%>"><td colspan="<%=maxCols%>">&nbsp;</td></tr> <!-- XSSOK : getting from form bean -->
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
                    <!-- //XSSOK -->
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
	     		      java.util.List<Integer> strlDisplayedFields = new ArrayList<Integer>();

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

	    	 	            	if(strlDisplayedFields.contains(new Integer(itemp))) {
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
			    		              strlDisplayedFields.add(new Integer(itemp));

			                          if ( !formViewBean.hasAccessToFiled(field) )
			                              continue;
									   %>
			                          <!-- //XSSOK -->
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
	     		        field = (HashMap)fields.get(i);	     		        
	                	int itemsInSameGrp= formViewCommonBean.getFieldGroupCount(field);
		                for (int j = 0; j < iGroup.intValue(); j++,i++) {
			                    field = (HashMap)fields.get(i);
			                   	while(!formViewBean.hasAccessToFiled(field) && j<=itemsInSameGrp){
			                    	i++;
			                    	field = (HashMap)fields.get(i);
			                    }
			                    if ( !formViewBean.hasAccessToFiled(field) )
			                        continue;
			                    if ( (iGroup.intValue()*2 < maxCols) && (j == iGroup.intValue()-1) ){
			                        grpMaxCols = maxCols - (iGroup.intValue()*2)+2;
			                    }
			                    fieldLabel = formViewBean.getFieldLabel(field);
			                  	fieldValueList = formViewBean.getFieldValues(field);
			                    fieldValueDisplayList = formViewBean.getFieldDisplayValues(field);

			                    if (fieldValueList != null && fieldValueList.size() > 0)
			                        fieldValue = (String)fieldValueList.firstElement();

			                    if (fieldValueDisplayList != null && fieldValueDisplayList.size() > 0)
			                        fieldValueDisplay = (String)fieldValueDisplayList.firstElement();
								%>
								<!-- //XSSOK -->
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
                <tr id="calc_<%=XSSUtil.encodeForHTML(context, fieldName)%>">
                    <!-- //XSSOK -->
					<%=drawFormViewElement(context, requestMap, field, timeZone, sPFmode, showLabel, tempMaxCols)%>
                </tr>
<%
                }
            } else if (formViewBean.isClassificationAttributesField(field)  )
            {
                int tempMaxCols = maxCols;
                tempMaxCols++;

%>
                    <!-- //XSSOK -->
					<%=drawFormViewElement(context, requestMap, field, timeZone, sPFmode, false, tempMaxCols)%>
<%
           }
           else if (formViewBean.isTableField(field))
            {
                String table = formViewBean.getSetting(field, "table");
                reportFormat = "";
                String printerFriednly = "false";
                String isEmbeddedTable="true";
                if ( sPFmode != null && sPFmode.equals("true") )
                {
                    printerFriednly = sPFmode;
                    reportFormat = "HTML";
                }
%>
<tr><td colspan="<%=maxCols%>" class="heading1"><!-- XSSOK : getting from form bean-->
<!-- //XSSOK : used in JSP include -->
<jsp:include page = "emxFormTableInclude.jsp" flush="true"><jsp:param name="timeStamp" value='<%=timeStamp + fieldName%>'/><jsp:param name="jsTreeID" value='<%=jsTreeID%>'/><jsp:param name="objectId" value='<%=objectId%>'/><jsp:param name="relId" value='<%=relId%>'/><jsp:param name="table" value='<%=table%>'/><jsp:param name="inquiry" value='<%=formViewBean.getSetting(field, "inquiry")%>'/><jsp:param name="program" value='<%=formViewBean.getSetting(field, "program")%>'/><jsp:param name="sortColumnName" value='<%=formViewBean.getSetting(field, "sortColumnName")%>'/><jsp:param name="sortDirection" value='<%=formViewBean.getSetting(field, "sortDirection")%>'/><jsp:param name="pagination" value="0"/><jsp:param name="isfromFORMPagination" value="true"/><jsp:param name="selection" value="none"/><jsp:param name="reportFormat" value='<%=reportFormat%>'/><jsp:param name="printerFriednly" value='<%=printerFriednly%>'/><jsp:param name="isEmbeddedTable" value='<%=isEmbeddedTable%>'/>
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
	     		      java.util.List<Integer> strlDisplayedFields = new ArrayList<Integer>();

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

	    	 	            	if(strlDisplayedFields.contains(new Integer(itemp))) {
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
			    		              strlDisplayedFields.add(new Integer(itemp));

			                          if ( !formViewBean.hasAccessToFiled(field) )
			                              continue;
									   %>
									   <!-- //XSSOK -->
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
	     		        <tr id="calc_<%=XSSUtil.encodeForHTML(context, fieldName)%>">
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
								<!-- //XSSOK -->
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

                colHeader = EnoviaResourceBundle.getProperty(context,stringResourceFile,context.getLocale(), colHeader); 
                rowHeader = EnoviaResourceBundle.getProperty(context,stringResourceFile,context.getLocale(), rowHeader); 

                StringList colHeaderList = FrameworkUtil.split(colHeader, ",");
                StringList rowHeaderList = FrameworkUtil.split(rowHeader, ",");

                int cols = (Integer.valueOf(colCount)).intValue();
                int rows = (Integer.valueOf(rowCount)).intValue();
                i++;
if(UIComponent.getUIAutomationStatus(context)){
%>
<tr id="calc_<%=XSSUtil.encodeForHTML(context, fieldName)%>"><td data-aid="<%=XSSUtil.encodeForHTML(context, fieldName)%>" colspan="<%=maxCols%>"><table  class="list"><tr>  <!-- XSSOK : getting from form bean -->
<%
} else {
%>
<tr id="calc_<%=XSSUtil.encodeForHTML(context, fieldName)%>"><td colspan="<%=maxCols%>"><table  class="list"><tr>  <!-- XSSOK : getting from form bean -->
<% 		
}
%>
<td class="label" >&nbsp;</td><%
                String colHeaderName = "";
                String i18nColHeaderValue = "";
                for (int j = 0; j < cols; j++)
                {
                                        try {
                                                colHeaderName = (String)colHeaderList.get(j);
                                                i18nColHeaderValue = EnoviaResourceBundle.getProperty(context,stringResourceFile,context.getLocale(), colHeaderName);
                                        } catch (Exception e) {
                                                i18nColHeaderValue = "&nbsp;";
                                        }
%>
<td class="label" ><%=XSSUtil.encodeForHTML(context, i18nColHeaderValue,false)%></td>
<%
                }

                for (int r = 0; r < rows; r++)
                {
                    String rowHeaderName = (String)rowHeaderList.get(r);
                    String i18nRowHeaderValue = EnoviaResourceBundle.getProperty(context,stringResourceFile,context.getLocale(), rowHeaderName);

%></tr><td class="label" ><%=XSSUtil.encodeForHTML(context, i18nRowHeaderValue,false)%></td>
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
<tr id="calc_<%=XSSUtil.encodeForHTML(context, fieldName)%>"><td class="label" ><%=XSSUtil.encodeForHTML(context, fieldLabel,false)%></td>
<%
if("slidein".equals(targetLocation) && !"wider".equals(slideinType)){
%>
</tr><tr>
<%
} if(UIComponent.getUIAutomationStatus(context)){
%>
<td class="field" data-aid="<%=XSSUtil.encodeForHTML(context, fieldName)%>" colspan="<%=(maxCols-1)%>">&nbsp;</td></tr>
<%
} else {
%>
<td class="field" colspan="<%=(maxCols-1)%>">&nbsp;</td></tr>
<%
}	
            } else {
              String strHideLabel = formViewBean.getSetting(field, "Hide Label");
              int tempMaxCols = maxCols;
              boolean showLabel = true;
              if ("true".equalsIgnoreCase(strHideLabel)){
                showLabel = false;
                tempMaxCols++;
              }
%>
<tr id="calc_<%=XSSUtil.encodeForHTML(context, fieldName)%>">
	<!-- //XSSOK -->
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
<td width="150"><img src="images/utilSpacer.gif" width="150" height="1" alt="" border="0" /></td>
<td class="smallSpace" width="90%" colspan="<%=maxCols-1%>">&nbsp;</td>
-->
</tr>
</table>

<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="objectName" value="<xss:encodeForHTMLAttribute> <%=objectName%> </xss:encodeForHTMLAttribute>" />
<input type="hidden" name="relId" value="<xss:encodeForHTMLAttribute><%=relId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="form" value="<xss:encodeForHTMLAttribute> <%=form%> </xss:encodeForHTMLAttribute>" />
<input type="hidden" name="timeStamp" value="<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="parseHeader" value="" />
<input type="hidden" name="emxSuiteDirectory" value="<xss:encodeForHTMLAttribute> <%=emxSuiteDirectory%> </xss:encodeForHTMLAttribute>" />
<input type="hidden" name="parsedHeader" value="<xss:encodeForHTMLAttribute> <%=parsedHeader%> </xss:encodeForHTMLAttribute>" />
<input type="hidden" name="subHeader" value="<xss:encodeForHTMLAttribute><%=subHeader%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="originalHeader" value="<xss:encodeForHTMLAttribute> <%=originalHeader%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="slideinType" value="<xss:encodeForHTMLAttribute> <%=slideinType%></xss:encodeForHTMLAttribute>" />


</form>
<iframe class='hidden-frame' name='formViewHidden' HEIGHT='0' WIDTH='0'></iframe>
<%
    //
    // Include the file summary
    //
    String strDisplayCDMFileSummary = emxGetParameter(request, "displayCDMFileSummary");

    if ("true".equalsIgnoreCase(strDisplayCDMFileSummary)) {
%>
<div class="inline-table">
        <%@include file = "emxFormCDMFileSummaryInclude.inc"%>
</div>        
<%
    }
%>
<%
if ( sPFmode != null && sPFmode.equals("true") )
{
%>
</body>
</html>
<%
}
%>

