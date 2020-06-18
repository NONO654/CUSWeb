<%--  emxFormViewDisplay.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%@page import="com.matrixone.apps.domain.util.EnoviaBrowserUtility.Browsers"%>
<%@include file = "emxNavigatorInclude.inc"%>
<html>

<jsp:useBean id="formViewBean" class="com.matrixone.apps.framework.ui.UIForm" scope="request"/>

<head>
<title>Properties</title>
<meta http-equiv="imagetoolbar" content="no" />
<meta http-equiv="Pragma" content="no-cache" />
<%@include file = "emxUIConstantsInclude.inc"%>
<script language="javascript" src="scripts/emxUIFormUtil.js"></script>
<script language="javascript" src="scripts/emxUIObjMgr.js"></script>
<script language="javascript" src="scripts/emxUIModal.js"></script>
<%
String form = Request.getParameter(request, "form");
String objectId = Request.getParameter(request, "objectId");
String relId = Request.getParameter(request, "relId");
String timeStamp = Request.getParameter(request, "timeStamp");
String jsTreeID = Request.getParameter(request, "jsTreeID");
String sPFmode = emxGetParameter(request, "PFmode");
String suiteKey = emxGetParameter(request, "suiteKey");
String originalHeader =emxGetParameter(request, "originalHeader");
String parseHeader = UIForm.getFormHeaderString(context, pageContext, originalHeader, objectId, suiteKey, request.getHeader("Accept-Language"));
String languageStr = request.getHeader("Accept-Language");


String subHeader = emxGetParameter(request, "subHeader");
//bug no: 313369
String sCharSet = request.getCharacterEncoding();
if ("".equals(sCharSet) || sCharSet == null || sCharSet.equals("null")){
	sCharSet = UINavigatorUtil.getFileEncoding(context, request);
}

if ( (subHeader != null) && (subHeader.trim().length() > 0) )
{
 subHeader = UINavigatorUtil.parseHeader(context, pageContext, subHeader, objectId, suiteKey, request.getHeader("Accept-Language"));
}

String strQuerystring = "";
strQuerystring=emxGetQueryString(request);

   if(strQuerystring != null && strQuerystring.length() > 0 )
   {
     strQuerystring=com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(strQuerystring);
     //strQuerystring=com.matrixone.apps.domain.util.XSSUtil.encodeForURL(strQuerystring);

   }

    // Get the preference settings
    // Type of the export "HTML, ExcelHTML, ExcelCSV, TXT"
    String exportFormat = XSSUtil.encodeForJavaScript(context, emxGetParameter(request, "exportFormat"));
	if(UIUtil.isNullOrEmpty(exportFormat))
    {
        exportFormat = PersonUtil.getExportFormat(context);
    }
    String delimiter = PersonUtil.getFieldSeparator(context);
    String recordSeparator = PersonUtil.getRecordSeparator(context);
    String scarriageReturn = PersonUtil.getRemoveCarriageReturns(context);


    // Get the preference settings
    // Type of the export "HTML, HTML, CSV, TXT"


     if (exportFormat == null || exportFormat.trim().length() == 0)
        exportFormat = "CSV";

    String sDQuote=""; //use to put quotes around dates in the case of EXcelCSV only
    boolean canHandleUTF_8 = EnoviaBrowserUtility.is(request,Browsers.FIREFOX);//anything except FF

    if ( exportFormat.equals("HTML"))
    {%>
    <script language="JavaScript">
        exportToExcelHTML('<%=XSSUtil.encodeForURL(context, timeStamp)%>','<%=XSSUtil.encodeForURL(context, objectId)%>','<%=XSSUtil.encodeForURL(context, relId)%>','<%=XSSUtil.encodeForURL(context, form)%>','<%=XSSUtil.encodeForURL(context, parseHeader)%>');
    </script>
  <%
    } else {


    if (exportFormat == null || exportFormat.trim().length() == 0)
        exportFormat = "CSV";

    String sRecordSepPropValue = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.Preferences.FieldSeparator.New_Line",request.getLocale());

    // Adjust record separator
    if (recordSeparator == null
            || recordSeparator.trim().length() == 0
            || recordSeparator.equalsIgnoreCase(sRecordSepPropValue) )
    {
        recordSeparator = "\r\n";
    }

    // Adjust field separator
    if (delimiter != null)
    {
        if ( delimiter.equalsIgnoreCase("Pipe") )
            delimiter = "|";
        else if ( delimiter.equalsIgnoreCase("Comma") )
            delimiter = ",";
        else if ( delimiter.equalsIgnoreCase("Tab") )
            delimiter = "\t";
        else if ( delimiter.equalsIgnoreCase("Semicolon") )
            delimiter = ";";

    }

    if (delimiter == null || delimiter.trim().length() == 0)
        delimiter = ",";

    boolean isRemoveCarriageReturn=false;

    if(scarriageReturn != null && scarriageReturn.equalsIgnoreCase("Yes"))
        isRemoveCarriageReturn=true;

        String delimiter2="|";

        // For netscape ExcelHTML option is not supported
        if ( exportFormat.equals("HTML"))
            exportFormat = "CSV";

        out.clear();
        if ( exportFormat.equals("CSV") )
        {
            sDQuote="\"";
            delimiter2="\n";
            recordSeparator = "\r\n";
        }

  String displayHeader = parseHeader;
  String badChars=":><[]|*; ";
  char[] charArray=badChars.toCharArray();
  char repchar='_';

        parseHeader=replaceCharacters(parseHeader, charArray, repchar);
        StringBuffer filename = new StringBuffer(50);
        String fileCreateTimeStamp = Long.toString(System.currentTimeMillis());
        if ( exportFormat.equals("CSV"))
        {
            response.setContentType("application/vnd.ms-excel;charset="+sCharSet);
            filename.append(parseHeader);
            filename.append(fileCreateTimeStamp);
            filename.append(".csv");
        } else {
            response.setContentType("text/plain;charset="+sCharSet);
            filename.append(parseHeader);
            filename.append(fileCreateTimeStamp);
            filename.append(".txt");
        }

        String encFileName = filename.toString();
        if (canHandleUTF_8) {
			// Fix for bug 372595 , updated by PW at 2009-05-26
			encFileName = "=?UTF-8?B?" + new String(FrameworkUtil.encodeBase64(encFileName.getBytes("UTF-8"),false), "UTF-8") + "?=";
        } else {
            encFileName = FrameworkUtil.encodeURL(encFileName, "UTF8");
		}
        response.setHeader ("Content-Disposition","attachment; filename=\"" + encFileName +"\"");


HashMap formMap = new HashMap();

// format to be used for the date columns
String DateFormat = (new Integer(java.text.DateFormat.SHORT)).toString();
String timeZone = (String)session.getAttribute("timeZone");
String emxErrorString = "";
int maxCols = 2;
try {

    ContextUtil.startTransaction(context, false);
    Vector userRoleList = PersonUtil.getAssignments(context);
    HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
    HashMap imageData = UINavigatorUtil.getImageData(context, pageContext);
    requestMap.put("ImageData", imageData);
    //Added the Reportformat to requestMap and  can be used in the JPOs to show hrefs as test in Printer riendly format
    requestMap.put("reportFormat",exportFormat);
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
 }
        out.clear();
		out.print(UIComponent.BOM_UTF8);
        out.print(displayHeader + recordSeparator);
        if (subHeader != null)
        {
        	//XSS OK	
         out.print(subHeader + recordSeparator);
        }
        for (int i=0; i < fields.size(); i++)
        {
            HashMap field = (HashMap)fields.get(i);
            if ( !formViewBean.hasAccessToFiled(field) )
                continue;

            String fieldSuite = formViewBean.getSetting(field, "Registered Suite");
            String stringResourceFile = UINavigatorUtil.getStringResourceFileId(context, fieldSuite);

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

            if (fieldValueDisplayList != null && fieldValueDisplayList.size() > 0)
                fieldValueDisplay = (String)fieldValueDisplayList.firstElement();

            if (formViewBean.showIcon(field))
                objectIcons = formViewBean.getFieldIcons(field);

            if (formViewBean.isFieldHyperLinked(field))
                fieldHrefList = formViewBean.getFieldHRefValues(field, request, context, objectId, relId);

            if (formViewBean.isFieldSectionHeader(field))
            {

                  out.print(fieldLabel);

            } else if (formViewBean.isFieldSectionSeparator(field))
            {
               //out.print(recordSeparator);

            }  else if (formViewBean.isTableField(field))
            {
                String table = formViewBean.getSetting(field, "table");
                String reportFormat = "ViewForm";
                String printerFriednly = "false";
                if ( sPFmode != null && sPFmode.equals("true") )
                {
                    printerFriednly = sPFmode;
                    reportFormat = "HTML";
                }
                request.setAttribute("outString",out.toString());%><%-- XSSOK --%><jsp:include page = "emxTableExport.jsp" flush="true"> <jsp:param name="timeStamp" value='<%=XSSUtil.encodeForURL(context, timeStamp) + fieldName%>'/> <jsp:param name="objectId" value='<%=XSSUtil.encodeForURL(context, objectId)%>'/> <jsp:param name="relId" value='<%=XSSUtil.encodeForURL(context, relId)%>'/> <jsp:param name="table" value='<%=table%>'/> <jsp:param name="inquiry" value='<%=formViewBean.getSetting(field, "inquiry")%>'/> <jsp:param name="program" value='<%=formViewBean.getSetting(field, "program")%>'/> <jsp:param name="sortColumnName" value='<%=formViewBean.getSetting(field, "sortColumnName")%>'/> <jsp:param name="sortDirection" value='<%=formViewBean.getSetting(field, "sortDirection")%>'/> <jsp:param name="pagination" value="0"/> <jsp:param name="selection" value="none"/> <jsp:param name="reportFormat" value='<%=reportFormat%>'/> <jsp:param name="printerFriednly" value='<%=printerFriednly%>'/> <jsp:param name="component" value='emxForm'/></jsp:include><%
            } else if (formViewBean.isGroupHolderField(field) )
            {
                Integer iGroup = new Integer(formViewBean.getFieldGroupCount(field));
                i++;
                int grpMaxCols = 2;

                for (int j = 0; j < iGroup.intValue(); j++,i++)
                {
                    field = (HashMap)fields.get(i);
                    if ( !formViewBean.hasAccessToFiled(field) )
                        continue;

                    if ( (iGroup.intValue()*2 < maxCols) && (j == iGroup.intValue()-1) )
                        grpMaxCols = maxCols - iGroup.intValue();

                    fieldLabel = formViewBean.getFieldLabel(field);
                    fieldValueList = formViewBean.getFieldValues(field);
                    fieldValueDisplayList = formViewBean.getFieldDisplayValues(field);

                    if (fieldValueList != null && fieldValueList.size() > 0)
                        fieldValue = (String)fieldValueList.firstElement();

                    if (fieldValueDisplayList != null && fieldValueDisplayList.size() > 0)
                        fieldValueDisplay = (String)fieldValueDisplayList.firstElement();

                    if (formViewBean.isDateField(field) && fieldValueDisplay != null && fieldValueDisplay.length() > 0)
                    {
                       out.print(fieldLabel+delimiter);out.print(sDQuote);%><emxUtil:lzDate localize="i18nId" tz='<%=XSSUtil.encodeForHTMLAttribute(context, timeZone)%>' format='<%=DateFormat%>'><%=fieldValueDisplay%></emxUtil:lzDate><%out.print(sDQuote);
                        if(j < iGroup.intValue()-1)
                         out.print(delimiter);
                    }

// Added for IR-015005V6R2011 Dated 23/10/2009 Begins.
					else if (formViewBean.isProgramHTMLOutputField(field))
					{
						String isExport = formViewBean.getSetting(field, "Export");
						if(isExport != null && isExport.equalsIgnoreCase("true"))
						{
						   String sFunctionValue=drawFormViewElement(context, request, field, objectId, relId, sPFmode, true, maxCols,delimiter,delimiter2,recordSeparator,exportFormat,languageStr);
						   out.print(sFunctionValue);
						   if(j < iGroup.intValue()-1)
		                                   out.print(delimiter);
						}

					}
// Added for IR-015005V6R2011 Dated 23/10/2009 Ends.

					else {
                       out.print(drawFormViewElement(context, request, field, objectId, relId, sPFmode, true, grpMaxCols,delimiter,delimiter2,recordSeparator,exportFormat,languageStr));
                       if(j < iGroup.intValue()-1)
                         out.print(delimiter);
                    }
                }

                i--;
               //out.print(recordSeparator);
            } else if (formViewBean.isTableHolderField(field) )
            {
                String colCount = formViewBean.getSetting(field, "Field Table Columns");
                String rowCount = formViewBean.getSetting(field, "Field Table Rows");
                String colHeader = formViewBean.getSetting(field, "Field Column Headers");
                String rowHeader = formViewBean.getSetting(field, "Field Row Headers");

                colHeader = EnoviaResourceBundle.getProperty(context,stringResourceFile, new Locale(languageStr), colHeader);
                rowHeader = EnoviaResourceBundle.getProperty(context, stringResourceFile, new Locale(languageStr), rowHeader);

                StringList colHeaderList = FrameworkUtil.split(colHeader, delimiter);
                StringList rowHeaderList = FrameworkUtil.split(rowHeader, delimiter);

                int cols = (Integer.valueOf(colCount)).intValue();
                int rows = (Integer.valueOf(rowCount)).intValue();
                i++;
                 out.print(delimiter);
                for (int j = 0; j < cols; j++)
                {
                    String headerValue = EnoviaResourceBundle.getProperty(context,stringResourceFile, new Locale(languageStr), (String)colHeaderList.get(j));
                    out.print(headerValue);
                    if(j < cols - 1) {
                     out.print(delimiter);
                    }
                }
                 out.print(recordSeparator);
                  //System.out.print("delimiter=" + delimiter);
                for (int r = 0; r < rows; r++)
                {
                    String headerValue = EnoviaResourceBundle.getProperty(context,stringResourceFile, new Locale(languageStr), (String)rowHeaderList.get(r));
                    out.print(headerValue + delimiter);

                    for (int k = 0; k < cols; k++,i++)
                    {
                        field = (HashMap)fields.get(i);
                        if ( !formViewBean.hasAccessToFiled(field) )
                            continue;

                        if (formViewBean.isDateField(field) && fieldValueDisplay != null && fieldValueDisplay.length() > 0)
                        {
                           out.print(fieldLabel + delimiter + sDQuote);%><emxUtil:lzDate localize="i18nId" tz='<%=XSSUtil.encodeForHTMLAttribute(context, timeZone)%>' format='<%=DateFormat%>'><%=fieldValueDisplay%></emxUtil:lzDate><%
                             out.print(sDQuote);
                             if(k < cols - 1)
                              out.print(delimiter);

                        }

// Added for IR-015005V6R2011 Dated 23/10/2009 Begins.
						else if (formViewBean.isProgramHTMLOutputField(field))
						{
							String isExport = formViewBean.getSetting(field, "Export");
							if(isExport != null && isExport.equalsIgnoreCase("true"))
							{
							   String sFunctionValue=drawFormViewElement(context, request, field, objectId, relId, sPFmode, true, maxCols,delimiter,delimiter2,recordSeparator,exportFormat,languageStr);
							   out.print(sFunctionValue);
							}

						}
// Added for IR-015005V6R2011 Dated 23/10/2009 Ends.

						else {
							//XSS OK
                            out.print(drawFormViewElement(context, request, field, objectId, relId, sPFmode, false, 2,delimiter,delimiter2,recordSeparator,exportFormat,languageStr));
                           // out.print(delimiter);
                             if(k < cols - 1)
                              out.print(delimiter);

                        }
                    }
                    out.print(recordSeparator);
                }
                i--;

            } else if (fieldValueList == null || fieldValueList.isEmpty())
            {
               out.print(fieldLabel+delimiter);

           }
            else if (formViewBean.isProgramHTMLOutputField(field))
            {
                String isExport = formViewBean.getSetting(field, "Export");
                if(isExport != null && isExport.equalsIgnoreCase("true"))
                {
                   String sFunctionValue=drawFormViewElement(context, request, field, objectId, relId, sPFmode, true, maxCols,delimiter,delimiter2,recordSeparator,exportFormat,languageStr);
                   out.print(sFunctionValue);
                }

            } else {

                if (formViewBean.isDateField(field) && fieldValueDisplay != null && fieldValueDisplay.length() > 0)
                {
                   out.print(fieldLabel+delimiter+sDQuote);%><emxUtil:lzDate localize="i18nId" tz='<%=XSSUtil.encodeForHTMLAttribute(context, timeZone)%>' format='<%=DateFormat%>'><%=fieldValueDisplay%></emxUtil:lzDate><%out.print(sDQuote);
                }

// Added for IR-015005V6R2011 Dated 23/10/2009 Begins.
				else if (formViewBean.isProgramHTMLOutputField(field))
				{
					String isExport = formViewBean.getSetting(field, "Export");
					if(isExport != null && isExport.equalsIgnoreCase("true"))
					{
					   String sFunctionValue=drawFormViewElement(context, request, field, objectId, relId, sPFmode, true, maxCols,delimiter,delimiter2,recordSeparator,exportFormat,languageStr);
					   out.print(sFunctionValue);
					}

				}
// Added for IR-015005V6R2011 Dated 23/10/2009 Ends.

				else {
                  //System.out.println("OTHERS=="+formViewBean.isRowExport(field));
                  if(formViewBean.isRowExport(field)){
                       String sFunctionValue=drawFormViewElement(context, request, field, objectId, relId, sPFmode, true, maxCols,delimiter,delimiter2,recordSeparator,exportFormat,languageStr);
                       out.print(sFunctionValue);
                  }
                }
            }
          out.print(recordSeparator);

    }

} catch (Exception ex) {

    ContextUtil.abortTransaction(context);
    ex.printStackTrace();
    //if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        //emxNavErrorObject.addMessage("emxFormViewDisplay:" + ex.toString().trim());

} finally {
    ContextUtil.commitTransaction(context);
}

}%><%!
    /**
    *  drawFormViewElement
    *
    * @param Context the context object
    * @param HttpServletRequest the request object
    * @param HashMap field - field map object
    * @param String DateFormat
    * @param String timeZone
    * @param String objectId - object id
    * @param String relId - relationship id
    * @param String sPFmode - Printer Friendly
    * @param boolean drawLabel
    * @return String - formated HTML string to draw the element
    * @since AEF Rossini
    * @grade 0
    */
    static public String drawFormViewElement(   Context context,
                                                HttpServletRequest request,
                                                HashMap field,
                                                String objectId,
                                                String relId,
                                                String sPFmode,
                                                boolean drawLabel,
                                                int maxCols,
                                                String delimiter,
                                                String delimiter2,
                                                String recordSeparator,
                                                String exportFormat,String languageStr)
        throws FrameworkException
    {

      //Determine whether this is ExcellCSV or TEXT


        StringBuffer outStr = new StringBuffer("");
        UIForm formViewBean = new UIForm();

        try {
            String fieldName = formViewBean.getName(field);
            String fieldLabel = formViewBean.getFieldLabel(field);

            String fieldValue = "";
            String fieldValueDisplay = "";

            StringList objectIcons = new StringList();
            StringList fieldHrefList = new StringList();
            StringList fieldValueList = new StringList();
            StringList fieldValueDisplayList = new StringList();

            if (formViewBean.getFieldValues(field) != null)
                fieldValueList = formViewBean.getFieldValues(field);
            if (formViewBean.getFieldDisplayValues(field) != null)
                fieldValueDisplayList = formViewBean.getFieldDisplayValues(field);

            String rteExpression = (String)field.get(formViewBean.RTE_EXPRESSION);
            if(rteExpression != null && !"".equals(rteExpression)){
            	 try
                 {
            		 fieldValueList = (StringList) field.get(formViewBean.FIELD_NONRTE_VALUE);
                 }
                 catch (Exception ex)
                 {
                	 fieldValueList = new StringList(1);
                     String fldValue = (String)field.get(formViewBean.FIELD_NONRTE_VALUE);
                     if (fldValue.length() > 0)
                     {
                    	 fieldValueList.addElement(fldValue);
                     }
                 }
                 fieldValueDisplayList = fieldValueList;
            }

            String fieldFormat = (String)formViewBean.getSetting(field, "format");

            if (formViewBean.showIcon(field))
                objectIcons = formViewBean.getFieldIcons(field);

            if (formViewBean.isFieldHyperLinked(field))
                fieldHrefList = formViewBean.getFieldHRefValues(field, request, context, objectId, relId);

            if (fieldValueList != null && fieldValueList.size() > 0)
            {
                fieldValue = (String)fieldValueList.firstElement();

                if (fieldValueDisplayList == null || fieldValueDisplayList.size() == 0 )
                {
                    fieldValueDisplayList = fieldValueList;
                    fieldValueDisplay = fieldValue;
                } else {
                    fieldValueDisplay = (String)fieldValueDisplayList.firstElement();
                }
            }

            if (drawLabel)
                outStr.append( fieldLabel + delimiter);

            String objectIcon =  "";
            String fieldHREF = "";

            if (fieldValueList == null || fieldValueList.isEmpty())
            {
                outStr.append( fieldValueDisplay);

             //} else if (formViewBean.isProgramHTMLOutputField(field)){
              //do nothing
            } else {

               String sreturnValue="";
               if(fieldFormat.equalsIgnoreCase("user"))
               {
                    String fullName = "";
                    if(fieldValueDisplay != null && !"".equalsIgnoreCase(fieldValueDisplay))
                    {
                        fullName = PersonUtil.getFullName(context,fieldValueDisplay);
                    }
                    fieldValueDisplayList = new StringList(fullName);
               }

               String uomDisplay = (String)field.get(com.matrixone.apps.framework.ui.UIFormCommon.UOM_DISPLAY_VALUE);
               if (uomDisplay != null && !"".equals(uomDisplay))
               {
                    fieldValueDisplayList = new StringList(uomDisplay);
               }
                String sDynamicUrl = "";
               if(formViewBean.isDynamicURLEnabled(context,field))
               {
                   sDynamicUrl = "enabled";
               }

               if (exportFormat != null &&(exportFormat.equalsIgnoreCase("ExcelCSV") || exportFormat.equalsIgnoreCase("CSV")))
               {
                 // sreturnValue=getCSVFormatString(fieldValueDisplayList);
                  sreturnValue=getCSVFormatString(context,fieldValueDisplayList,sDynamicUrl,languageStr);
                  outStr.append(sreturnValue);
               }else{
                 // sreturnValue=getTextFormatString(fieldValueDisplayList, delimiter2);
                 sreturnValue=getTextFormatString(context,fieldValueDisplayList,delimiter2,sDynamicUrl,languageStr);
                  outStr.append(sreturnValue);
               }
            }


        } catch (Exception ex) {
            // System.out.print("UINavigatorUtil:parseHeader : " + ex.toString() );
            throw (new FrameworkException("UINavigatorUtil:parseHeader : " + ex.toString()) );
        }

        // System.out.print("FORM Element :: " + outStr.toString());
        return outStr.toString();
    }%><%!
static public String getCSVFormatString(Context context, StringList colValueList, String sDynamicURL, String languageStr) throws Exception
{

    StringBuffer formatedColValues = new StringBuffer("\"");

    // Test if the the value is a number and has one value in the list
    if (colValueList.size() == 1)
    {
        String columnValue = (String)colValueList.get(0);
        try {
          // float colValuNumber = Float.parseFloat(columnValue);
           //added for the bug 321708
            if(sDynamicURL.equals("enabled")) {
                columnValue = UINavigatorUtil.formatEmbeddedURL(context, columnValue, false, languageStr);
                columnValue = FrameworkUtil.findAndReplace(columnValue, "&amp;", "&");
                columnValue = FrameworkUtil.findAndReplace(columnValue, "&quot;", "\"");
            }else{
            	columnValue = FrameworkUtil.findAndReplace(columnValue, "\"", "\"\"");            	
            }
            
                if(columnValue.indexOf(',')==-1)
                {
                  formatedColValues = new StringBuffer("=\"");
                }
                else
                    formatedColValues = new StringBuffer("\"");
        //till here
        } catch (Exception ex1) {
            // System.out.println("formatedColValues : " + formatedColValues.toString());
            // do nothing
        }
        /***IR-056121V6R2011x***/
        if (columnValue.indexOf('"') >= 0 || columnValue.indexOf('\n') != -1)
        {
            formatedColValues = new StringBuffer("\"");
            columnValue = FrameworkUtil.findAndReplace(columnValue ,"\"", "\"\"");
        }
        columnValue = columnValue.replace('\r', ' ');
        /***IR-056121V6R2011x***/
        formatedColValues.append(columnValue);

    } else {
        for (int i = 0; i < colValueList.size(); i++)
        {
            String columnValue = (String)colValueList.get(i);
            if(sDynamicURL.equals("enabled")) {
            columnValue = UINavigatorUtil.formatEmbeddedURL(context, columnValue, false, languageStr);
            columnValue = FrameworkUtil.findAndReplace(columnValue, "&amp;", "&");
            columnValue = FrameworkUtil.findAndReplace(columnValue, "&quot;", "\"");
       }
            if(i == colValueList.size()-1 )
                formatedColValues.append(columnValue);
             else
                formatedColValues.append(columnValue + "\n");
         }
     }

     formatedColValues.append("\"");
     return (formatedColValues.toString());
}%><%!
static public String getTextFormatString(Context context, StringList colValueList, String delimiter, String sDynamicURL, String languageStr)throws Exception
{

    StringBuffer formatedColValues = new StringBuffer("");
    // Test if the the value is a number and has one value in the list
    if (colValueList.size() == 1)
    {
        String columnValue = (String)colValueList.get(0);
        if(sDynamicURL.equals("enabled")) {
            columnValue = UINavigatorUtil.formatEmbeddedURL(context, columnValue, false, languageStr);
            columnValue = FrameworkUtil.findAndReplace(columnValue, "&amp;", "&");
            columnValue = FrameworkUtil.findAndReplace(columnValue, "&quot;", "\"");
        }
        columnValue = columnValue.replace('\n', ' ');

        formatedColValues.append(columnValue);
    } else {
        for (int i = 0; i < colValueList.size(); i++)
        {
            String columnValue = (String)colValueList.get(i);
            if(sDynamicURL.equals("enabled")) {
            columnValue = UINavigatorUtil.formatEmbeddedURL(context, columnValue, false, languageStr);
            columnValue = FrameworkUtil.findAndReplace(columnValue, "&amp;", "&");
            columnValue = FrameworkUtil.findAndReplace(columnValue, "&quot;", "\"");
        }
            columnValue = columnValue.replace('\n', ' ');

            if(i == colValueList.size()-1 )
                formatedColValues.append(columnValue);
             else
                formatedColValues.append(columnValue + delimiter);
        }
    }

     return (formatedColValues.toString());
}%><%!
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

}%>
