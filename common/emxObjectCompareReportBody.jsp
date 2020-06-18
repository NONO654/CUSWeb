<%--  emxObjectCompareReportBody.jsp  
      Copyright (c) 1992-2018 Dassault Systemes.
      All Rights Reserved. 
      This program contains proprietary and trade secret information of MatrixOne,Inc.
      Copyright notice is precautionary only   and does not evidence any actual or intended publication of such program  

    static const char RCSID[] = $Id: emxObjectCompareReportBody.jsp.rca 1.11 Wed Oct 22 15:48:04 2008 przemek Experimental przemek $
--%>
<jsp:useBean id="compare" class="com.matrixone.apps.domain.util.ObjectCompare" scope="session"/>
 
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>


<%
       boolean toExcel=false;
       String acceptLanguage=request.getHeader("Accept-Language");
       String outputAsSpreadsheet= emxGetParameter(request,"outputAsSpreadsheet");
       String browser = request.getHeader("USER-AGENT");

       boolean pivot=true;
       if (compare.pivot)
       {
           pivot = false;
       }

       
       boolean reportMode = false;
       String exportFormat = PersonUtil.getExportFormat(context);
       String reportFormat = emxGetParameter(request, "reportFormat");
       if ("HTML".equals(reportFormat) )
       {
            reportMode = true;
       }

       if (outputAsSpreadsheet != null && !outputAsSpreadsheet.equals("null") && outputAsSpreadsheet.equals("true"))
       {
            toExcel=true;
       }
       boolean isPrinterFriendly = false;
       String printerFriendly=emxGetParameter(request,"PrinterFriendly");
       if (printerFriendly != null && !"null".equals(printerFriendly) && !"".equals(printerFriendly))
       {
          isPrinterFriendly = "true".equals(printerFriendly);
       }
       if ( !(reportMode) ) 
       {
%>
            <%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%
       }

       // export to excel 
       if(toExcel)
        {
          try
          {
            String header=i18nNow.getI18nString("emxFramework.ObjectCompare.PrinterFriendlyHeading", "emxFrameworkStringResource", acceptLanguage);

            header=header.replace(' ','_');

            long startTime = System.currentTimeMillis();
            String fileName = header+ startTime;
            

            String fileEncodeType = UINavigatorUtil.getFileEncoding(context, request);

            if ( "Text".equals(exportFormat))
            {
               StringBuffer exportReport=compare.exportReport(context);
               response.setContentType("text/plain; charset="+fileEncodeType);
               fileName = fileName + ".txt";

               response.setHeader ("Content-Disposition","attachment; filename=\"" + fileName +"\"");
               response.setLocale(request.getLocale());
               out.clear();
               out.println(exportReport);
            } 
            
            else if ( "HTML".equals(exportFormat))
              {
                
%>
                <script>
                  var strFeatures = "location=no,menubar=yes,width=700,height=500,resizable=yes,scrollbars=yes";
                  printDialog = window.open("emxObjectCompareHtmlExport.jsp?reportFormat=HTML", "ExportPage", strFeatures);
                  printDialog.focus();
                 </script>
<%
              }

            else {
                StringBuffer exportReport=compare.exportReport(context);
                String encodeType = "UTF-8";
                response.setContentType("application/csv; charset="+encodeType);
                fileName = fileName+ ".csv";
                response.setHeader ("Content-Disposition","attachment; filename=\"" + fileName +"\"");
                response.setLocale(request.getLocale());
                out.clear();
                out.println(exportReport);
            }
          } //end of try block for export to excel
          catch (Exception ex)
          {
             if(ex.toString() != null && (ex.toString().trim()).length()>0)
             {
                  emxNavErrorObject.addMessage("Compare: " + ex.toString().trim());
             }
          }
        } // end of if for excel 
        else
        {
         try
         {
           MapList objectMapList =null;
           objectMapList =(MapList) compare.getCompareReport(context,(String)session.getAttribute("timeZone"), acceptLanguage);
           if(objectMapList == null)
           {
              objectMapList=new MapList();
           }
           String selectedAttributes[] =(String[]) compare.getselectedAttributes();

           Calendar currServerCal = Calendar.getInstance();
           Date currentDateObj = currServerCal.getTime();
           int iDateFormat = PersonUtil.getPreferenceDateFormatValue(context);
           java.text.DateFormat outDateFrmt= java.text.DateFormat.getDateInstance(iDateFormat, request.getLocale());
           currentDateObj = outDateFrmt.parse(outDateFrmt.format(currentDateObj));
           String currentTime = outDateFrmt.format(currentDateObj);
           String userName = "";
           userName = PersonUtil.getFullName(context);

           String headerNotice="";
           String noticeAppendString="";
           headerNotice=i18nNow.getI18nString("emxFramework.ObjectCompare.ReportMessage", "emxFrameworkStringResource", acceptLanguage);


           // Adding appropriate styles
            if (isPrinterFriendly)
            {
              noticeAppendString=i18nNow.getI18nString("emxFramework.ObjectCompare.ReportMessage2", "emxFrameworkStringResource", acceptLanguage);
%>
             <script>
                  addStyleSheet("emxUICompareReportPF");
            </script>
<%
            }
            else if ( reportMode)
              {
              }
            else
            {
              noticeAppendString=i18nNow.getI18nString("emxFramework.ObjectCompare.ReportMessage1", "emxFrameworkStringResource", acceptLanguage);
%>
             <script>
                  addStyleSheet("emxUICompareReport");
            </script>
<%
            }
%>

           <script language="javascript">

              function goBack() 
              {
                 window.parent.location.href = "emxObjectCompareAttributeSelect.jsp?previous=true";
              }
               function pivotTable() 
              {
            	   //XSSOK
                 window.parent.location.href = "emxObjectCompareReport.jsp?pivot=<%=pivot%>";
              }
           </script>
<%         if ( !(reportMode) )
              {
%>
    </head>
    <body>
<%
              }
%>
           <form name="objcomparereport" id="objcomparereport" target="_top">
<%

            // Header for Printer Friendly Page
             if (isPrinterFriendly)
             {
%>
                <hr noshade>
                <table width="100%">
                   <tr align="left">
                      <td  class="pageHeader"><emxUtil:i18n localize="i18nId">emxFramework.ObjectCompare.PrinterFriendlyHeading</emxUtil:i18n></td>
                      <td width="39%" align="right"></td>
                      <td nowrap align="right">
                        <table>
                          <tr><td nowrap="" ><xss:encodeForHTML><%=userName%></xss:encodeForHTML></td></tr>
                          <tr><td nowrap=""><xss:encodeForHTML><%=currentTime%></xss:encodeForHTML></td></tr>
                        </table>
                      </td>
                   </tr>
                </table>
                <hr noshade>
<%
            }
			if (isPrinterFriendly) {
%>

             <table border="0" cellpadding="5" cellspacing="0" id="tblMain"  width="100%">
<%
			} else {
%>
             <table class="list" width="100%">
<%
			}
%>             
                 <tr>
<%
                 if (reportMode )
                  {
%>
                    <td class="pageHeader"><emxUtil:i18n localize="i18nId">emxFramework.ObjectCompare.PrinterFriendlyHeading</emxUtil:i18n></td>
<%               }
                else
                {
%>
                    <td colspan="<%=selectedAttributes.length%>"><%=headerNotice %> <span class="highlight"><%=noticeAppendString %></span> </td>
<%
                }
%>
                 </tr>
                 <tr>

<%


           Map objDetails=null;
           Map style=null;
           String attrValue="";
           String attrName="";
           String cellStyle="";
           String alias="";
           String typeIcon="";
           int basicAttrSize=Integer.parseInt(selectedAttributes[0]);

           Vector attributes = new Vector();
           for (int i=1;i<selectedAttributes.length;i++ )
           {
              attributes.addElement(selectedAttributes[i]);
           }

           Iterator attrItr = attributes.iterator();
           Iterator listItr = objectMapList.iterator();

           if (!compare.pivot)
           {
                // for displaying selected attributes as table headers in case of non pivot view.
               for (int i=1;i<selectedAttributes.length;i++) 
               {
                     attrName=selectedAttributes[i];
           
                     if (i<basicAttrSize)
                     {
                        attrName="emxFramework.ObjectCompare."+attrName;
%>
                       <th><xss:encodeForHTML><emxUtil:i18n localize="i18nId"><%=attrName%></emxUtil:i18n></xss:encodeForHTML></th>
<%
                     }
                     else
                     {
%>
                        <th><xss:encodeForHTML><%=EnoviaResourceBundle.getAttributeI18NString(context, attrName, request.getHeader("Accept-Language"))%></xss:encodeForHTML>&nbsp;</th>
<%
                      }
               }
           }
           else
           {

              // If pivot view is true swap attributes list iterator and objects list iterator
              listItr=attributes.iterator();
%>
                <!-- \\XSSOK -->
                <tr><td colspan="<%=objectMapList.size()+2%>" class="listCell">&nbsp; </td> </tr>
<%
           }
%>
                 </tr>
<% 
             String nextElement="";
             //Bug Fix 314794
             String orgAttributeName = "";
             AttributeType attrType = null;
             StringList choices =  null;
             String sDataType = "";
			 String sDefaultValue = "";

             int i=0;

             // If pivot view is true loop through attributes. 
             // If pivot view is false loop through object maps list
           while(listItr.hasNext())
           {

              attrItr=attributes.iterator();

              if (compare.pivot)
              {
                 // If pivot view is true swap attributes list iterator and objects list iterator
                 attrItr =objectMapList.iterator();
                //retrieving attribute name for pivot view
                 i++;
                 attrName=selectedAttributes[i];
                 //Bug Fix 314794
                 orgAttributeName = attrName;

                  // displaying the attributes name as a column with table header style.
                 if (i<basicAttrSize)
                 {
%>
                    <tr>
                     <td class="pivotHead"><xss:encodeForHTML><emxUtil:i18n localize="i18nId">emxFramework.ObjectCompare.<%=attrName%></emxUtil:i18n></xss:encodeForHTML></td>
<%
                 }
                 else
                 {
%>
                     <tr>
                         <td class="pivotHead"><xss:encodeForHTML><%=i18nNow.getAdminI18NString("Attribute",attrName,acceptLanguage)%></xss:encodeForHTML>&nbsp;</td>
<%
                        attrName="attribute["+attrName+"]";
                 }
                 // dummy variable for iterating.
                 nextElement=(String)listItr.next();
              }
              else
              {
%>
                 <tr>
<% 
                 i=0;

                 //retrieving object details for normal view
                 objDetails=(HashMap)listItr.next();
         
                 style=(HashMap)listItr.next();
                 if(((String)objDetails.get(DomainObject.SELECT_NAME)).equals("") && ((String)objDetails.get(DomainObject.SELECT_REVISION)).equals("revision"))
                 {
                     throw new Exception("'business object' does not exist");
                 }
              }

              while(attrItr.hasNext())
              {
                   if (compare.pivot)
                   {
                         //retrieving object details for pivot view
                         objDetails=(HashMap)attrItr.next();
                         style=(HashMap)attrItr.next();
                   }
                   else
                   {
                            //retrieving attribute name for normal view
                          i++;
                          attrName=selectedAttributes[i];
                          //Bug Fix 314794
                          orgAttributeName = attrName;       
                          if (i>=basicAttrSize)
                          {
                             attrName="attribute["+attrName+"]";
                          }
                          // dummy variable for iterating.
                          nextElement=(String)attrItr.next();
                   }
           
           attrValue = (String)objDetails.get(attrName);

           //Bug Fix 314794
           if (attrName.startsWith("attribute["))
           {
            attrType = new AttributeType(orgAttributeName);
            attrType.open(context);
            choices = attrType.getChoices();
            sDataType = attrType.getDataType();
            sDefaultValue = attrType.getDefaultValue();
            attrType.close(context);
            if ("boolean".equals(sDataType))
            {
              attrValue = i18nNow.getRangeI18NString("BooleanAttribute", attrValue, acceptLanguage);
            }
            else if (choices != null && choices.contains(attrValue))
            {
              attrValue = i18nNow.getRangeI18NString(orgAttributeName, attrValue, acceptLanguage);
            }
			else if (sDefaultValue != null && !"".equals(sDefaultValue.trim())  && sDefaultValue.equals(attrValue))
			{
				attrValue = i18nNow.getDefaultAttributeValueI18NString(sDefaultValue, acceptLanguage);
			}
            attrType = null;
            choices =  null;
            sDataType = "";
			sDefaultValue = "";
          }

                   cellStyle=(String)style.get(attrName);
                   typeIcon="";

                    // for internationalising type and policy
                    if (attrName.equals("type"))
                    {
                       attrValue=i18nNow.getAdminI18NString("Type",attrValue,acceptLanguage);
                    }
                    else if (attrName.equals("current"))
                    {
                        attrValue = i18nNow.getStateI18NString((String)objDetails.get(DomainObject.SELECT_POLICY), attrValue, acceptLanguage);
                    }
                    String attributeValue =  attrValue.replaceAll("\n","<br/>");
                    
                    //  Display icon if column is of type "Name"
                    if (attrName.equals(DomainObject.SELECT_NAME))
                    {
                       typeIcon = UINavigatorUtil.getTypeIconProperty(context, (String)objDetails.get(DomainObject.SELECT_TYPE));
                        if (typeIcon == null || "null".equals(typeIcon) || (typeIcon.length() ==0)) 
                        {
                            typeIcon="iconSmallDefault.gif";
                        }
%>
                <!-- //XSSOK -->
                <td class="<%=cellStyle%>">
                    <table border="0">
                        <tr>
                            <td >
                                <!-- //XSSOK -->
                                <img src="images/<%=typeIcon%>" border="0" alt="<%=typeIcon%>" />
                            </td>
                            <td class="object">
                                <xss:encodeForHTML><%=attributeValue%></xss:encodeForHTML>&nbsp;
                            </td>
                        </tr>
                    </table>
                  </td>
<%
                    }
                    else
                    {
%>
                       <td class="<%=cellStyle%>"><xss:encodeForHTML><%=attributeValue%></xss:encodeForHTML>&nbsp;</td>
<%
                    }
              }
         }
%>
            </tr>
          </table>
         </form>

<%
       }//end of try block
       catch (Exception ex)
       { 
          if (ex != null && ex.toString().trim().equals("java.lang.Exception: 'business object' does not exist"))
          { 
%>
             <script language = "javascript">
                   alert("<emxUtil:i18nScript localize="i18nId">emxFramework.ObjectCompare.ObjectsDeleted</emxUtil:i18nScript>");
                   parent.window.closeWindow();
             </script>
<%
           }
           else
           {
                 emxNavErrorObject.addMessage(ex.toString());
           } 
       }
     if ( !(reportMode) )
              {
%>
<%@include file = "emxNavigatorBottomErrorInclude.inc" %>
</body>
</html>
<%
              }
     } // end of else conditon of excel 
%> 
