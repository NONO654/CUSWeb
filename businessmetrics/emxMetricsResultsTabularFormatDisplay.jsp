<%--  emxMetricsResultsTabularFormatDisplay.jsp

   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsResultsTabularFormatDisplay.jsp.rca 1.23 Wed Oct 22 16:11:56 2008 przemek Experimental $
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ include file="emxMetricsConstantsInclude.inc"%>

<html>
<head>
<jsp:useBean id="metricsReportUIBean" class="com.matrixone.apps.metrics.ui.UIMetricsReports" scope="request"/>
<jsp:useBean id="metricsReportBean" class="com.matrixone.apps.metrics.MetricsReports" scope="session"/>

<%
    String timeStamp = emxGetParameter(request, "timeStamp");
    String objectDetails = emxGetParameter(request, "objectDetails");
    String strRefresh = emxGetParameter(request, "refresh");
    if("".equals(objectDetails)){
        objectDetails = "TRUE";
    }
    if(strRefresh==null || "null".equals(strRefresh)){
        strRefresh = "";
    }
    String strLanguage  = request.getHeader("Accept-Language");    
    boolean noLimitsApplied = false;
    String strResultTruncated = EnoviaResourceBundle.getProperty(context, "emxMetricsStringResource",context.getLocale(), "emxMetrics.ErrorMsg.ResultTruncated");
    try
    {
        String mode = emxGetParameter(request, "mode");
       
        Map tabularFormatMap =  (TreeMap) metricsReportUIBean.getMetricsTabularFormatData(timeStamp);
        if(tabularFormatMap==null || tabularFormatMap.size()==0)
        {            
            String strNoResult = (String) metricsReportBean.getResultString(timeStamp);
        %>
            <table border="0" cellpadding="3" cellspacing="2" width="100%">
                <tr>
                     <td style="text-align:center">
                         <b><%=strNoResult%></b><!-- XSSOK -->
                     </td>
                </tr>
            </table>
        <%
        }
        else
        {
            //Read the tabular format settings to display.
            Map tabularFormatSettings = (TreeMap) tabularFormatMap.get(metricsReportUIBean.KEY_TABULAR_FORMAT_SETTINGS);
            
            StringList strColHeaders = (StringList) tabularFormatSettings.get(metricsReportUIBean.KEY_COLUMN_HEADERS);
            StringList strRowHeaders = (StringList) tabularFormatSettings.get(metricsReportUIBean.KEY_ROW_HEADERS);
            int cols = strColHeaders.size();
            int rows = strRowHeaders.size();        
        
            int iColumnLimit = metricsReportUIBean.getColumnLimitToComputeTotal(tabularFormatSettings);
            int iRowLimit = metricsReportUIBean.getRowLimitToComputeTotal(tabularFormatSettings);
            if(metricsReportUIBean.NO_COLUMN_LIMIT_APPLIED==true && metricsReportUIBean.NO_ROW_LIMIT_APPLIED==true)
            {
                noLimitsApplied = true;
            }
            //Columns to be wrapped selected by user        
            String colWrapSize = (String)tabularFormatSettings.get(metricsReportUIBean.KEY_WRAP_COL_SIZE);
        
            String strRowLimit = "";
            String strColumnLimit = "";
            if(iRowLimit == 0)
            {
                //User have configured the row limit in property file    
                strRowLimit = EnoviaResourceBundle.getProperty(context, "emxMetrics.Configuration.RowLimitResultsDisplay");
                if(strRowLimit==null)
                {
                    iRowLimit = 0;
                }
                //If the user  has specified the row limit
                if(strRowLimit!=null && !strRowLimit.equals("") && !"null".equalsIgnoreCase(strRowLimit))
                {
                    try
                    {
                        iRowLimit = Integer.parseInt(strRowLimit);
                        if(iRowLimit<0 || iRowLimit==0)
                        {
                            iRowLimit = strRowHeaders.size();
                        }
                    }
                    catch(Exception e)
                    {
                        iRowLimit = rows;
                    }
                } 
       
            }
            if(iColumnLimit == 0)
            {        
                //User have configured the Coulmn limit in property file
                strColumnLimit = EnoviaResourceBundle.getProperty(context, "emxMetrics.Configuration.ColumnLimitResultsDisplay");
                if(strColumnLimit==null)
                {
                    iColumnLimit = 0;
                }
                if(strColumnLimit!=null && !strColumnLimit.equals("") && !"null".equalsIgnoreCase(strColumnLimit))
                {
                    try
                    {
                        iColumnLimit = Integer.parseInt(strColumnLimit);
                        if(iColumnLimit<0 || iColumnLimit==0)
                        {
                            iColumnLimit = cols;
                        }
                        else
                        {
                            iColumnLimit = iColumnLimit + 1;                
                        }
                    }
                    catch(Exception e)
                    {
                        iColumnLimit = cols;
                    }
                }           
            }

            //To remember the column count while wrapping.
            int rememberColCount = 1;
            //To remember the row count while wrapping.
            int rememberRowCount = 0;
            //To remember the 'Total' column count while wrapping.
            int rememberTotalColCount = 0;
            //To remember the 'Total Objects' column count while wrapping.
            int rememberTotalObjectCount = 0;
            int iColWrapSize = 0;
        
            if(mode==null)
            {
                mode = "";
            }
            
            try
            { 
                iColWrapSize = new Integer(colWrapSize).intValue();
                if(iColWrapSize<0 || iColWrapSize==0)
                {
                    iColWrapSize = 0;
                }
                else if(iColWrapSize>iColumnLimit)
                {
                    iColWrapSize = 0;
                }
                else
                {            
                    iColWrapSize = iColWrapSize + 1;
                }
            }
            catch(Exception e)
            {
                iColWrapSize = 0;
            }

            //if the column wrap size is null assign 
            //column limit configured from property file by the user
            if(colWrapSize==null)
            {
                iColWrapSize = 0;
            }
            else if(colWrapSize!=null && colWrapSize.equals("0"))
            {
                iColWrapSize = 0;
            }
            else if(iColWrapSize<0 || iColWrapSize==0)
            {
                iColWrapSize = 0;
            }        

            // Assign the style sheet to be used based on the input
            String cssFile = EnoviaResourceBundle.getProperty(context, "emxNavigator.UITable.Style.List");
            boolean useDefaultCSS=false;
            if ( cssFile == null || cssFile.trim().length() == 0)
            {
                useDefaultCSS=true;
            }
%>
            <%@include file = "../common/emxUIConstantsInclude.inc"%>
            <%@include file = "../emxStyleDefaultInclude.inc"%>
<%
            if(mode!=null && mode.equalsIgnoreCase("Print"))        
            {
%>
                <script>
                    addStyleSheet("emxUIDefaultPF");
                    addStyleSheet("emxUIListPF");
                </script>   
<%
            }
            else if(useDefaultCSS)
            {
%>
                <%@include file = "../emxStyleListInclude.inc"%>
<%
            }
            else
            {
%>
                <script>
                    addStyleSheet("<%=cssFile%>");
                    addStyleSheet("emxUIDefault");
                </script>
<% 
            }
%>
            <script language="JavaScript" src="../common/scripts/emxUIModal.js" type="text/javascript"></script>
            <script language="JavaScript" src="emxMetrics.js"></script>        
</head>
<body onload="turnOffProgress();">
<%
           // if the tabular format configured for showing a message.
           String showMessage = (String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_MESSAGE);
           if(showMessage!=null && !"".equals(showMessage))
           {
%>
               <table style="margin-left: 6px;">
                    <tr class="odd">
                         <td style="color:#990000;font-family: Arial, Helvetica, Sans-Serif;font-size: 12px;font-weight: bold;"><%=XSSUtil.encodeForHTML(context,showMessage)%></td>
                    </tr>
               </table>
<%
           }
%>
           <form name="emxMetricsResultsTableForm" method="post" onSubmit="javascript:submitTable(); return false">
<%
           int lowerValue = iColWrapSize;
           // Pickup the value of least columns to be displayed.
           int lowerRowValue = strRowHeaders.size()<iRowLimit?strRowHeaders.size():iRowLimit;
           //Get the complete tabular format data map
           Map tabularFormatDataMap = (TreeMap) tabularFormatMap.get(metricsReportUIBean.KEY_TABULAR_FORMAT_DATA_MAP);
           Map tabularDataHrefsMap  = (TreeMap) tabularFormatDataMap.get(metricsReportUIBean.KEY_CUSTOM_DATA_HREFS_LIST);
           String showTotalColumn = (String) tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_COLUMN_TOTAL);
           //Get the setting to show a reference link for each and every cell data.
           String showHrefLink = (String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_DATA_HREF_LINK);
           //Get the setting to show a reference link for Total information being displayed.
           String showTotalHrefLink = (String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_TOTAL_HREF_LINK);
           //to allot the hrefs for total row (showing the total of each column in a row)
           Map totalRowCellMap = (TreeMap)tabularFormatDataMap.get(metricsReportUIBean.KEY_COLUMN_SUMMARY_HREFS_LIST);
           //to allot the hrefs for total object count
           String totalObjectsCellHref = (String)tabularFormatDataMap.get(metricsReportUIBean.KEY_TOTAL_SUMMARY_HREFS_LIST);           
           //to allot the hrefs for total column (showing the total of each row in a column)
           Map totalColCellMap = (TreeMap)tabularFormatDataMap.get(metricsReportUIBean.KEY_ROW_SUMMARY_HREFS_LIST);
           
           //No Wrapping applied
           if(iColWrapSize == 0)
           {
               int counter = rememberColCount;
%>
               <table id="emxMetricsTabularFormat" border="1" cellpadding="3" cellspacing="2" width="100%" style="margin-left: 6px;">
                   <tr class="odd">
<%   
                    String strColHeading = (String) strColHeaders.get(0);

%>
                        <th width="10%" style="text-align:center" ><%=XSSUtil.encodeForHTML(context,strColHeading)%>&nbsp;</th>
<%
                        for(int i=1; i<iColumnLimit; i++)
                        {
                            strColHeading = (String) strColHeaders.get(i);
%>
                            <th width="10%" style="text-align:center" ><%=XSSUtil.encodeForHTML(context,strColHeading)%>&nbsp;</th>
<%
                            counter++;
                        }
                        rememberColCount = counter;
                        
                        String strTotalColHeading = (String)tabularFormatSettings.get(metricsReportUIBean.TOTAL_ROW_HEADING);
                        
                        //to show total column header
                        if((rememberColCount == iColumnLimit) && (showTotalColumn!=null) && showTotalColumn.equalsIgnoreCase("true"))
                        {
%>
                            <th width="10%" style="text-align:center" >&nbsp;<%=XSSUtil.encodeForHTML(context,strTotalColHeading)%>&nbsp;</th>
<%
                        }
%>   
                   </tr>
<%            
                   counter = 0;
                   // Draw the data rows along with row headers
                   for(int j=0; j<iRowLimit; j++)
                   {
                       String rowHeader = (String) strRowHeaders.get(j); // row headers
                       // Draw row header
%>
                       <tr class="odd">
                           <td width="10%" style="text-align: center" ><b><%=XSSUtil.encodeForHTML(context,rowHeader)%></b></td>
            <%
                           //Get the row wise data to be displayed.
                           StringList arrRowList = (StringList)tabularFormatDataMap.get(new Integer(j).toString());
                          //Get Row-wise Href URLs
                          StringList arrRowHrefList = new StringList();
                          if(tabularDataHrefsMap!=null && tabularDataHrefsMap.size()!=0)
                          {
                              arrRowHrefList = (StringList)tabularDataHrefsMap.get(new Integer(j).toString());
                          }
                          //initialize total column value
                          double totalColData = 0.0;
                          // Draw row data
                          for(int k=0; k<(iColumnLimit-1); k++)
                          {
                              double tempColData = 0.0;
                              String rowData = "";
                              String tempRowData = "";
                              String cellHref = "";
                              rowData = (String)arrRowList.get(k);
                              tempRowData = rowData;
                              if(arrRowHrefList!=null && arrRowHrefList.size()!=0)
                              {
                                  cellHref = (String)arrRowHrefList.get(k);
                              }                    
                    
                              tempColData = Float.parseFloat(rowData);
                              totalColData = totalColData + tempColData;
                    
                              // Show a column wise percentage difference between two cells
                              String showPercentageDiff = (String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_DIFFERENCE_IN_PERCENTAGE);
                              // Check the configuration column wise percentage difference set
                              // and currently this is not the first column
                              if(showPercentageDiff.equalsIgnoreCase("true") && k!=0)
                              {
                                  String prevRowData = (String)arrRowList.get(k-1);
                                  rowData = metricsReportUIBean.computePercentageDiff(rowData,prevRowData);
                              }
                              else
                              {
                                  rowData = "&nbsp;" + rowData + "&nbsp;";
                              }
                              if(showHrefLink.equals("true") && cellHref!=null && !"".equals(cellHref) && !mode.equals("Print"))
                              {
                                  cellHref = metricsReportUIBean.setCellNumberAsZeroIfApplicable(tempRowData,cellHref);
                                  cellHref = FrameworkUtil.encodeURL(cellHref,"UTF-8");
%>
                                  <td width="10%" style="text-align: center" ><a href="javascript:showCellInfo('<%=cellHref%>','<xss:encodeForJavaScript><%=objectDetails%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strRefresh%></xss:encodeForJavaScript>');"><%=rowData%></a></td>
<%
                              }
                              else
                              {
%>
                                  <td width="10%" style="text-align: center" ><%=rowData%></td>
<%
                              }
                          }//end of for loop
                
                          //to show total column data
                         if((rememberColCount == iColumnLimit) && (showTotalColumn!=null) && showTotalColumn.equalsIgnoreCase("true"))
                         {                        
                             //Get the Column Total List
                             StringList columnTotalList  = (StringList) tabularFormatDataMap.get(metricsReportUIBean.KEY_TOTAL_COLUMN);
                             String cellHref = (String) totalColCellMap.get(rowHeader);
                             String cellData = (String)columnTotalList.get(j);
                             if(showTotalHrefLink!=null && showTotalHrefLink.equals("true") && cellHref!=null && !"".equals(cellHref) && !mode.equals("Print") && (noLimitsApplied || (((cols - 1)<=(iColumnLimit-1)) && (rows<=iRowLimit))))
                             {
                                 cellHref = metricsReportUIBean.setCellNumberAsZeroIfApplicable(cellData,cellHref);
                                 cellHref = FrameworkUtil.encodeURL(cellHref,"UTF-8");
%>
                                 <td width="10%" style="text-align: center" ><a href="javascript:showCellInfo('<%=cellHref%>','<xss:encodeForJavaScript><%=objectDetails%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strRefresh%></xss:encodeForJavaScript>');"><%=cellData%></a></td>
<%
                             }
                             else
                             {
%>     
                                 <td width="10%" style="text-align: center"><%=XSSUtil.encodeForHTML(context,cellData)%></td>
<%
                             }                                
                        }
%>
                 </tr>
<%
                 // if the last row is reached
                 if(j == iRowLimit - 1) 
                 {
                     Map columnHeaderMappings = (Map)tabularFormatSettings.get(metricsReportUIBean.KEY_ORG_COLUMN_HEADERS);
                     // Get the setting to show the 'Total' row
                     String showTotalRow = (String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_ROW_TOTAL);
                     // Get the setting to show the 'Object Count' row
                     String showObjectCount = (String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_OBJECT_COUNT);
                     // If configured to show the 'Total' row
                     if(showTotalRow!=null && showTotalRow.equals("true"))
                     {
                         StringList arrTotalRowList = (StringList)tabularFormatDataMap.get(metricsReportUIBean.KEY_TOTAL);                        
                         // If configured to show a row separator before 'Total' row
                         String showSeparator = (String)(String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_ROW_SEPARATOR);
                         if(showSeparator!=null && showSeparator.equals("true"))
                         {
%>
                             <tr class="odd">
                                  <td colspan="<%=iColumnLimit%>" rowspan="0" class="blackrule"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
                             </tr>
<%
                         }
%>
                         <tr class="odd">
<%
                             // Get the value if configured to show the custom 'Total' row heading
                             String strTotalHeading = (String)tabularFormatSettings.get(metricsReportUIBean.TOTAL_ROW_HEADING);
%>
                             <td width="5%" style="text-align: center" ><b><%=XSSUtil.encodeForHTML(context,strTotalHeading)%></b></td>
<%
                             int totalCellCounter = rememberTotalColCount;
                             for(int h=0; h<(iColumnLimit-1); h++)
                             {
                                  String dataElem = "";
                                  if(totalCellCounter==cols - 1)
                                  {
                                       dataElem = (String)arrTotalRowList.get(rememberTotalColCount);
                                  }
                                  else
                                  {
                                       dataElem = (String)arrTotalRowList.get(h);
                                  } 
                                  String actualDataElem = "";
                                  String showPercentageDiff = (String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_DIFFERENCE_IN_PERCENTAGE);
                                  // Check the configuration column wise percentage difference set
                                  // and currently this is not the first column
                                  if(showPercentageDiff.equalsIgnoreCase("true") && h!=0)
                                  {
                                      String prevDataElem = (String)arrTotalRowList.get(h-1);
                                      actualDataElem = dataElem;
                                      dataElem = metricsReportUIBean.computePercentageDiff(dataElem,prevDataElem);
                                  }
                                  else
                                  {
                                      actualDataElem = dataElem;
                                      dataElem = "&nbsp;" + dataElem + "&nbsp;";
                                  }
                                  String strKey = (String) strColHeaders.get(h+1);
                                  //if columnHeaderMappings is not null, then retrieve the actual key
                                  //with the current internationalized key
                                  if(columnHeaderMappings!=null && columnHeaderMappings.size()>0)
                                  {
                                     strKey = (String) columnHeaderMappings.get(strKey);
                                  }
                                  String cellHref = (String) totalRowCellMap.get(strKey);
                                  if(arrTotalRowList!=null && arrTotalRowList.size()==1)
                                  {
                                      cellHref = totalObjectsCellHref;
                                  }
                                  if(showTotalHrefLink!=null && showTotalHrefLink.equals("true") && cellHref!=null && !"".equals(cellHref) && !mode.equals("Print") && (noLimitsApplied || (((cols - 1)<=(iColumnLimit-1)) && (rows<=iRowLimit))))
                                  {
                                       cellHref = metricsReportUIBean.setCellNumberAsZeroIfApplicable(actualDataElem,cellHref);
                                       cellHref = FrameworkUtil.encodeURL(cellHref,"UTF-8");
%>
                                       <td width="10%" style="text-align: center" ><a href="javascript:showCellInfo('<%=cellHref%>','<xss:encodeForJavaScript><%=objectDetails%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strRefresh%></xss:encodeForJavaScript>');"><%=dataElem%></a></td>
<%
                                  }
                                  else
                                  {
%>     
                                       <td width="10%" style="text-align: center"><%=XSSUtil.encodeForHTML(context,dataElem)%></td>
<%
                                  }
                                  totalCellCounter++;
                             }
                             rememberTotalColCount = totalCellCounter;
                                    
                             //to show total column data
                             if((rememberColCount == iColumnLimit) && (showTotalColumn!=null) && showTotalColumn.equalsIgnoreCase("true"))
                             {                                        
                                 //Get the Column Total List
                                 StringList columnTotalList  = (StringList) tabularFormatDataMap.get(metricsReportUIBean.KEY_TOTAL_COLUMN);                                 
                                 if(showTotalHrefLink!=null && showTotalHrefLink.equals("true") && totalObjectsCellHref!=null && !"".equals(totalObjectsCellHref) && !mode.equals("Print") && (noLimitsApplied || (((cols - 1)<=(iColumnLimit-1)) && (rows<=iRowLimit))))
                                 {
                                     totalObjectsCellHref = FrameworkUtil.encodeURL(totalObjectsCellHref,"UTF-8");
%>
                                     <td width="10%" style="text-align: center" ><a href="javascript:showCellInfo('<%=totalObjectsCellHref%>','<xss:encodeForJavaScript><%=objectDetails%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strRefresh%></xss:encodeForJavaScript>');"><%=(String)columnTotalList.get(j + 1)%></a></td>
<%
                                 }
                                 else
                                 {
%>     
                                     <td width="10%" style="text-align: center"><%=XSSUtil.encodeForHTML(context,(String)columnTotalList.get(j + 1))%></td>
<%
                                 }
                             }
%>
                       </tr>
<%
                   }// end of if condition
                   // If configured to show the 'Object Count' row
                   if(showObjectCount!=null && showObjectCount.equals("true"))
                   {
                       StringList arrTotalRowList = (StringList)tabularFormatDataMap.get(metricsReportUIBean.KEY_OBJECT_COUNT);
                       if(arrTotalRowList!=null && arrTotalRowList.size()!=0)
                       {
%>
                           <tr class="odd">
<%
                               String strObjectCountHeading = (String)tabularFormatSettings.get(metricsReportUIBean.OBJECT_COUNT_ROW_HEADING);
%>
                               <td width="10%" style="text-align: center"><b><%=XSSUtil.encodeForHTML(context,strObjectCountHeading)%></b></td>
<%                        
                               for(int h=0; h<(iColumnLimit-1); h++)
                               {
                                   String dataElem = "";
                                   dataElem = (String)arrTotalRowList.get(h);
                                   String actualDataElem = "";
                                   String showPercentageDiff = (String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_DIFFERENCE_IN_PERCENTAGE);
                                   // Check the configuration column wise percentage difference set
                                   // and currently this is not the first column
                                   if(showPercentageDiff.equalsIgnoreCase("true") && h!=0)
                                   {
                                       String prevDataElem = (String)arrTotalRowList.get(h-1);
                                       actualDataElem = dataElem;
                                       dataElem = metricsReportUIBean.computePercentageDiff(dataElem,prevDataElem);
                                   }
                                   else
                                   {
                                       actualDataElem = dataElem;
                                       dataElem = "&nbsp;" + dataElem + "&nbsp;";
                                   }                                   
                                   String strKey = (String) strColHeaders.get(h+1);
                                  //if columnHeaderMappings is not null, then retrieve the actual key
                                  //with the current internationalized key
                                  if(columnHeaderMappings!=null && columnHeaderMappings.size()>0)
                                  {
                                     strKey = (String) columnHeaderMappings.get(strKey);
                                  }
                                  String cellHref = (String) totalRowCellMap.get(strKey);
                                  if(showTotalHrefLink!=null && showTotalHrefLink.equals("true") && cellHref!=null && !"".equals(cellHref) && !mode.equals("Print"))
                                  {
                                       cellHref = metricsReportUIBean.setCellNumberAsZeroIfApplicable(actualDataElem,cellHref);
                                       cellHref = FrameworkUtil.encodeURL(cellHref,"UTF-8");

%>
                                       <td width="10%" style="text-align: center" ><a href="javascript:showCellInfo('<%=cellHref%>','<xss:encodeForJavaScript><%=objectDetails%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strRefresh%></xss:encodeForJavaScript>');"><%=dataElem%></a></td>
<%
                                  }
                                  else
                                  {
%>     
                                       <td width="10%" style="text-align: center"><%=XSSUtil.encodeForHTML(context,dataElem)%></td>
<%
                                  }
                               }
                                
                               //to show total column data
                               if((rememberColCount == iColumnLimit) && (showTotalColumn!=null) && showTotalColumn.equalsIgnoreCase("true"))
                               {                        
                                   //Get the Column Total List                                   
                                   StringList columnTotalList  = (StringList) tabularFormatDataMap.get(metricsReportUIBean.KEY_TOTAL_COLUMN);
                                   if(showTotalHrefLink!=null && showTotalHrefLink.equals("true") && totalObjectsCellHref!=null && !"".equals(totalObjectsCellHref) && !mode.equals("Print") && (noLimitsApplied || (((cols - 1)<=(iColumnLimit-1)) && (rows<=iRowLimit))))
                                   {
                                        totalObjectsCellHref = FrameworkUtil.encodeURL(totalObjectsCellHref,"UTF-8");
%>
                                        <td width="10%" style="text-align: center" ><a href="javascript:showCellInfo('<%=totalObjectsCellHref%>','<xss:encodeForJavaScript><%=objectDetails%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strRefresh%></xss:encodeForJavaScript>');"><%=(String)columnTotalList.get(j + 2)%></a></td>
<%
                                   }
                                   else
                                   {
%>     
                                        <td width="10%" style="text-align: center"><%=XSSUtil.encodeForHTML(context,(String)columnTotalList.get(j + 2))%></td>
<%
                                   }    
                               }
%>
                           </tr>
<%
                        }
                     }// end of if objectcount condition
                  } //end of if last row
               } // end of for (drawing rows)
%>
               </table>
<%
               //if column or row limits applied and not print mode, shw a message that result truncated
               if(!noLimitsApplied && !mode.equals("Print") && (((cols - 1)>(iColumnLimit-1)) || (rows>iRowLimit)))
               {
%> 
                   <script language="javascript">
                       alert("<%=strResultTruncated%>");
                   </script>
<%
               }
           } 
           else // when wrapping is specified apply this logic
           {
               int tempColCountSniffer = 0;
               boolean totalColAlreadyDrawn = false;
              
              //While this is not the last column to be displayed.    
              while(rememberColCount!=iColumnLimit)
              {
                  // To balance the number of columns and rows
                  int colCountSniffer = 0;
                  String tableId = "emxMetricsTabularFormat" + rememberColCount;
%>
                  <table id="<%=XSSUtil.encodeForHTMLAttribute(context,tableId)%>" border="1" cellpadding="3" cellspacing="2" width="100%" style="margin-left: 6px;">
                      <tr class="odd">
<%
                       int counter = rememberColCount;
                       //to compare with rememberColCount's value before iteration 
                       int counterForComp = rememberColCount;
                       String strColHeading = (String) strColHeaders.get(0);
                       colCountSniffer++;
%>
                          <th width="10%" style="text-align:center" ><%=XSSUtil.encodeForHTML(context,strColHeading)%>&nbsp;</th>
<%
                       int limit = lowerValue - 1;
                       int limitCounter = 0;
                       // if the remember column count is not empty
                       if(rememberColCount!=1)
                       {
                           limitCounter = 1;
                           limit = lowerValue;
                       }
            
                       for(int i=rememberColCount; (limitCounter<limit && counter<iColumnLimit); i++)
                       {
                           strColHeading = (String) strColHeaders.get(i);
%>
                           <th width="10%" style="text-align:center" ><%=XSSUtil.encodeForHTML(context,strColHeading)%>&nbsp;</th>
<%
                           counter++;
                           limitCounter++;
                           colCountSniffer++;
                       }
                       String strTotalColHeading = (String)tabularFormatSettings.get(metricsReportUIBean.TOTAL_ROW_HEADING);            
                       rememberColCount = counter;
                      
                       //to show total column header, handling all possible wrap related, column limit cases                       
                       if((showTotalColumn!=null) && showTotalColumn.equalsIgnoreCase("true") && (rememberColCount == iColumnLimit) && (lowerValue!=2) && (lowerValue!=iColumnLimit) && ((lowerValue==iColumnLimit) || (((iColumnLimit-1)%(lowerValue-1))!=0)) && ((((iColumnLimit-1)%(lowerValue-1))==1) || (lowerValue-1)!=2) && (((lowerValue-1)!=2) || (lowerValue==iColumnLimit) || ((iColumnLimit-1)%2!=0)))
                       {
                           totalColAlreadyDrawn = true;
%>
                           <th width="10%" style="text-align:center" >&nbsp;<%=XSSUtil.encodeForHTML(context,strTotalColHeading)%>&nbsp;</th>
<%
                           colCountSniffer++;
                       }
            
                       //If the column count equals to number of columns available
                       //then draw extra columns upto the wrap column limit.
                       if(colCountSniffer<lowerValue)
                       {
                           for(int i=0; i<lowerValue-colCountSniffer;i++)
                           {
%>
                              <th width="10%" style="text-align:center" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
<%
                           }
                       }
%>
                       </tr>
<%            
                       counter = 0;
                       // Draw the data rows along with row headers
                       for(int j=0; j<lowerRowValue; j++)
                       {
                           String rowHeader = (String) strRowHeaders.get(j); // row headers
                           // Draw row header
%>
                           <tr class="odd">
                               <td width="10%" style="text-align: center" ><b><%=XSSUtil.encodeForHTML(context,rowHeader)%></b></td>
<%
                               int cellCounter = 0;
                               //Get the row wise data to be displayed.
                               StringList arrRowList = (StringList)tabularFormatDataMap.get(new Integer(counter).toString());
                               //Get Row-wise Href URLs
                               StringList arrRowHrefList = new StringList();
                               if(tabularDataHrefsMap!=null && tabularDataHrefsMap.size()!=0)
                               {
                                   arrRowHrefList = (StringList)tabularDataHrefsMap.get(new Integer(counter).toString());
                               }
                               
                               limit = lowerValue - 1;
                               limitCounter = rememberRowCount;
                               
                               if(rememberRowCount!=0)
                               {                    
                                   if(limit==1)
                                   {                        
                                       cellCounter = 1;
                                       limit = lowerValue;
                                   }
                               }
                               //initialize total column value
                               double totalColData = 0.0;
                               // Draw row data
                               for(int k=rememberRowCount; ((cellCounter<limit) && (limitCounter<iColumnLimit-1)); k++)
                               {
                                   double tempColData = 0.0;
                                   String rowData = "";
                                   String tempRowData = "";
                                   String cellHref = "";
                                   if(limitCounter==iColumnLimit - 1)
                                   {
                                       rowData = (String)arrRowList.get(rememberRowCount);
                                       if(arrRowHrefList!=null && arrRowHrefList.size()!=0)
                                       {
                                           cellHref = (String)arrRowHrefList.get(rememberRowCount);
                                       }
                                   }
                                   else
                                   {
                                       rowData = (String)arrRowList.get(k);
                                       if(arrRowHrefList!=null && arrRowHrefList.size()!=0)
                                       {                       
                                           cellHref = (String)arrRowHrefList.get(k);
                                       }
                                   }
                    
                                   tempRowData = rowData;
                                   tempColData = Float.parseFloat(rowData);
                                   totalColData = totalColData + tempColData;
                    
                                   // Show a column wise percentage difference between two cells
                                   String showPercentageDiff = (String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_DIFFERENCE_IN_PERCENTAGE);
                                   // Check the configuration column wise percentage difference set
                                   // and currently this is not the first column
                                   if(showPercentageDiff.equalsIgnoreCase("true") && k!=0)
                                   {
                                       String prevRowData = (String)arrRowList.get(k-1);
                                       rowData = metricsReportUIBean.computePercentageDiff(rowData,prevRowData);
                                   }
                                   else
                                   {
                                       rowData = "&nbsp;" + rowData + "&nbsp;";
                                   }
                                   
                                   if(showHrefLink.equals("true") && cellHref!=null && !"".equals(cellHref) && !mode.equals("Print"))
                                   {
                                       cellHref = metricsReportUIBean.setCellNumberAsZeroIfApplicable(tempRowData,cellHref);
                                       cellHref = FrameworkUtil.encodeURL(cellHref,"UTF-8");
%>
                                       <td width="10%" style="text-align: center" ><a href="javascript:showCellInfo('<%=cellHref%>','<xss:encodeForJavaScript><%=objectDetails%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strRefresh%></xss:encodeForJavaScript>');"><%=rowData%></a></td>
<%
                                   }
                                   else
                                   {
%>
                                       <td width="10%" style="text-align: center" ><%=XSSUtil.encodeForHTML(context,rowData)%></td>
<%
                                   }                

                                   cellCounter++;
                                   limitCounter++;
                               }//end of for loop
                
                               //to show total column data, handling all possible wrap and column limit cases                               
                               if((showTotalColumn!=null) && showTotalColumn.equalsIgnoreCase("true") && (rememberColCount == iColumnLimit) && (lowerValue!=2) && (lowerValue!=iColumnLimit) && ((lowerValue==iColumnLimit) || (((iColumnLimit-1)%(lowerValue-1))!=0)) && ((((iColumnLimit-1)%(lowerValue-1))==1) || (lowerValue-1)!=2) && (((lowerValue-1)!=2) || (lowerValue==iColumnLimit) || ((iColumnLimit-1)%2!=0)))
                               {   
                                   //Total Column Drawn boolean updated
                                   totalColAlreadyDrawn = true;
                                   //Get the Column Total List
                                   StringList columnTotalList  = (StringList) tabularFormatDataMap.get(metricsReportUIBean.KEY_TOTAL_COLUMN);
                                   String cellData = (String)columnTotalList.get(j);
                                   String cellHref = (String) totalColCellMap.get(rowHeader);

                                   if(showTotalHrefLink!=null && showTotalHrefLink.equals("true") && cellHref!=null && !"".equals(cellHref) && !mode.equals("Print") && (noLimitsApplied || (((cols - 1)<=(iColumnLimit-1)) && (rows<=iRowLimit))))
                                   {
                                       cellHref = metricsReportUIBean.setCellNumberAsZeroIfApplicable(cellData,cellHref);
                                       cellHref = FrameworkUtil.encodeURL(cellHref,"UTF-8");
%>
                                       <td width="10%" style="text-align: center" ><a href="javascript:showCellInfo('<%=cellHref%>','<xss:encodeForJavaScript><%=objectDetails%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strRefresh%></xss:encodeForJavaScript>');"><%=cellData%></a></td>
<%
                                   }
                                   else
                                   {
%>     
                                       <td width="10%" style="text-align: center"><%=XSSUtil.encodeForHTML(context,cellData)%></td>
<%
                                   }                                
                               }

                               //If the column count equals to number of columns available
                               //then draw extra row
                               if(colCountSniffer<lowerValue)
                               {
                                   for(int i=0; i<lowerValue-colCountSniffer;i++)
                                   {
%>
                                       <td width="10%" style="text-align: center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
<%
                                   }
                               }
%>
<% 
                               // if the last row is reached
                               if(j == lowerRowValue - 1)
                               {
                                   Map columnHeaderMappings = (Map)tabularFormatSettings.get(metricsReportUIBean.KEY_ORG_COLUMN_HEADERS);
                                   rememberRowCount = limitCounter;
                                   // Get the setting to show the 'Total' row
                                   String showTotalRow = (String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_ROW_TOTAL);
                                   // Get the setting to show the 'Object Count' row
                                   String showObjectCount = (String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_OBJECT_COUNT);
                                   // If configured to show the 'Total' row
                                   if(showTotalRow!=null && showTotalRow.equals("true"))
                                   {
                                       StringList arrTotalRowList = (StringList)tabularFormatDataMap.get(metricsReportUIBean.KEY_TOTAL);
                                       // If configured to show a row separator before 'Total' row
                                       String showSeparator = (String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_ROW_SEPARATOR);
                                       if(showSeparator!=null && showSeparator.equals("true"))
                                       {
                                           int tempLowerValue = 0;
                                           tempLowerValue = lowerValue;
                                           if(lowerValue==(iColumnLimit-1) && (showTotalColumn!=null) && showTotalColumn.equalsIgnoreCase("true") && (lowerValue-1)!=2)
                                           {
                                               tempLowerValue=lowerValue+1;
                                           }
%>
                                           <tr class="odd">
											   <!-- //XSSOK -->
                                               <td colspan="<%=tempLowerValue%>" rowspan="0" class="blackrule"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
                                           </tr>
<%
                                       }
%>
                                       <tr class="odd">
<%
                                           // Get the value if configured to show the custom 'Total' row heading
                                           String strTotalHeading = (String)tabularFormatSettings.get(metricsReportUIBean.TOTAL_ROW_HEADING);
%> 
                                           <td width="10%" style="text-align: center" ><b><%=XSSUtil.encodeForHTML(context,strTotalHeading)%></b></td>
<%
                                           int totalCellCounter = rememberTotalColCount;
                                           limit = lowerValue - 1;
                                           limitCounter = 0;
                                           if(rememberTotalColCount!=0)
                                           {                                        
                                               if(limit==1)
                                               {
                                                   limitCounter = 1;
                                                   limit = lowerValue;
                                               }
                                           }
 
                                           for(int h=rememberTotalColCount; ((limitCounter<limit) && (totalCellCounter<iColumnLimit-1)); h++)
                                           {
                                               String dataElem = "";
                                               if(totalCellCounter==iColumnLimit - 1)
                                               {
                                                   dataElem = (String)arrTotalRowList.get(rememberTotalColCount);
                                               }
                                               else
                                               {
                                                   dataElem = (String)arrTotalRowList.get(h);
                                               }

                                               String actualDataElem = "";
                                               // Show a column wise percentage difference between two cells
                                               String showPercentageDiff = (String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_DIFFERENCE_IN_PERCENTAGE);
                                               // Check the configuration column wise percentage difference set
                                               // and currently this is not the first column
                                               if(showPercentageDiff.equalsIgnoreCase("true") && h!=0)
                                               {
                                                   String prevDataElem = (String)arrTotalRowList.get(h-1);
                                                   actualDataElem = dataElem;
                                                   dataElem = metricsReportUIBean.computePercentageDiff(dataElem,prevDataElem);
                                               }
                                               else
                                               {
                                                   actualDataElem = dataElem;
                                                   dataElem = "&nbsp;" + dataElem + "&nbsp;";
                                               }
                                               
                                               String strKey = (String) strColHeaders.get(h+1);
                                               //if columnHeaderMappings is not null, then retrieve the actual key
                                               //with the current internationalized key
                                               if(columnHeaderMappings!=null && columnHeaderMappings.size()>0)
                                               {
                                                   strKey = (String) columnHeaderMappings.get(strKey);
                                               }
                                               
                                               String cellHref = (String) totalRowCellMap.get(strKey);
                                               if(arrTotalRowList!=null && arrTotalRowList.size()==1)
                                               {
                                                  cellHref = totalObjectsCellHref;
                                               }
                                               if(showTotalHrefLink!=null && showTotalHrefLink.equals("true") && cellHref!=null && !"".equals(cellHref) && !mode.equals("Print") && (noLimitsApplied || (((cols - 1)<=(iColumnLimit-1)) && (rows<=iRowLimit))))
                                               {
                                                   cellHref = metricsReportUIBean.setCellNumberAsZeroIfApplicable(actualDataElem,cellHref);
                                                   cellHref = FrameworkUtil.encodeURL(cellHref,"UTF-8");
%>
                                                   <td width="10%" style="text-align: center" ><a href="javascript:showCellInfo('<%=cellHref%>','<xss:encodeForJavaScript><%=objectDetails%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strRefresh%></xss:encodeForJavaScript>');"><%=dataElem%></a></td>
<%
                                               }
                                               else
                                               {
%>     
                                                   <td width="10%" style="text-align: center"><%=XSSUtil.encodeForHTML(context,dataElem)%></td>
<% 
                                               }                               
                                               totalCellCounter++;
                                               limitCounter++;
                                           }
                                           rememberTotalColCount = totalCellCounter;

                                          //to show total column data, handling all possible wrap or column limit cases
                                          if((showTotalColumn!=null) && showTotalColumn.equalsIgnoreCase("true") && (rememberColCount == iColumnLimit) && (lowerValue!=2) && (lowerValue!=iColumnLimit) && ((lowerValue==iColumnLimit) || (((iColumnLimit-1)%(lowerValue-1))!=0)) && ((((iColumnLimit-1)%(lowerValue-1))==1) || (lowerValue-1)!=2) && (((lowerValue-1)!=2) || (lowerValue==iColumnLimit) || ((iColumnLimit-1)%2!=0)))
                                          {                                        
                                              //Total Column Drawn boolean updated
                                              totalColAlreadyDrawn = true;
                                              //Get the Column Total List
                                              StringList columnTotalList  = (StringList) tabularFormatDataMap.get(metricsReportUIBean.KEY_TOTAL_COLUMN);                                              
                                              if(showTotalHrefLink!=null && showTotalHrefLink.equals("true") && totalObjectsCellHref!=null && !"".equals(totalObjectsCellHref) && !mode.equals("Print") && (noLimitsApplied || (((cols - 1)<=(iColumnLimit-1)) && (rows<=iRowLimit))))
                                              {
                                                  totalObjectsCellHref = FrameworkUtil.encodeURL(totalObjectsCellHref,"UTF-8");
%>
                                                  <td width="10%" style="text-align: center" ><a href="javascript:showCellInfo('<%=totalObjectsCellHref%>','<xss:encodeForJavaScript><%=objectDetails%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strRefresh%></xss:encodeForJavaScript>');"><%=(String)columnTotalList.get(j + 1)%></a></td>
<%
                                              }
                                              else
                                              {
%>     
                                                  <td width="10%" style="text-align: center"><%=XSSUtil.encodeForHTML(context,(String)columnTotalList.get(j + 1))%></td>
<%
                                              }
                                          }
  
                                          if(colCountSniffer<lowerValue)
                                          {
                                              for(int i=0; i<lowerValue-colCountSniffer;i++)
                                              {
%>
                                                  <td width="10%" style="text-align: center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
<%
                                              }
                                          }
%>
                                     </tr>
<%
                                  }// end of if condition
               
                                  // If configured to show the 'Object Count' row
                                  if(showObjectCount!=null && showObjectCount.equals("true"))
                                  {
                                      StringList arrTotalRowList = (StringList)tabularFormatDataMap.get(metricsReportUIBean.KEY_OBJECT_COUNT);
                                      if(arrTotalRowList!=null && arrTotalRowList.size()!=0)
                                      {
%>
                                          <tr class="odd">
<%
                                              String strObjectCountHeading = (String)tabularFormatSettings.get(metricsReportUIBean.OBJECT_COUNT_ROW_HEADING);
%>
                                              <td width="10%" style="text-align: center"><b><%=XSSUtil.encodeForHTML(context,strObjectCountHeading)%></b></td>
<%
                                              int totalCellCounter = rememberTotalObjectCount;
                                              limit = lowerValue - 1;
                                              limitCounter = 0;
                                              if(rememberTotalObjectCount!=0)
                                              {                           
                                                  if(limit==1)
                                                  {
                                                      limitCounter = 1;
                                                      limit = lowerValue;
                                                  }
                                              }

                                              for(int h=rememberTotalObjectCount; ((limitCounter<limit) && (totalCellCounter<iColumnLimit-1)); h++)
                                              {
                                                  String dataElem = "";
                                                  if(totalCellCounter==iColumnLimit-1)
                                                  {
                                                      dataElem = (String)arrTotalRowList.get(rememberTotalObjectCount);
                                                  }
                                                  else
                                                  {
                                                      dataElem = (String)arrTotalRowList.get(h);
                                                  }
                                                  String actualDataElem = "";
                                                  String showPercentageDiff = (String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_DIFFERENCE_IN_PERCENTAGE);
                                                  // Check the configuration column wise percentage difference set
                                                  // and currently this is not the first column
                                                  if(showPercentageDiff.equalsIgnoreCase("true") && h!=0)
                                                  {
                                                      String prevDataElem = (String)arrTotalRowList.get(h-1);
                                                      actualDataElem = dataElem;
                                                      dataElem = metricsReportUIBean.computePercentageDiff(dataElem,prevDataElem);
                                                  }
                                                  else
                                                  {
                                                      actualDataElem = dataElem;
                                                      dataElem = "&nbsp;" + dataElem + "&nbsp;";
                                                  }
                                                  String strKey = (String) strColHeaders.get(h+1);
                                                  //if columnHeaderMappings is not null, then retrieve the actual key
                                                  //with the current internationalized key
                                                  if(columnHeaderMappings!=null && columnHeaderMappings.size()>0)
                                                  {
                                                      strKey = (String) columnHeaderMappings.get(strKey);
                                                  }
                                                  String cellHref = (String) totalRowCellMap.get(strKey);
                                                  if(showTotalHrefLink!=null && showTotalHrefLink.equals("true") && cellHref!=null && !"".equals(cellHref) && !mode.equals("Print"))
                                                  {
                                                       cellHref = metricsReportUIBean.setCellNumberAsZeroIfApplicable(actualDataElem,cellHref);
                                                       cellHref = FrameworkUtil.encodeURL(cellHref,"UTF-8");
%>
                                                       <td width="10%" style="text-align: center" ><a href="javascript:showCellInfo('<%=cellHref%>','<xss:encodeForJavaScript><%=objectDetails%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strRefresh%></xss:encodeForJavaScript>');"><%=dataElem%></a></td>
<%     
                                                  }
                                                  else
                                                  {
%>      
                                                       <td width="10%" style="text-align: center"><%=XSSUtil.encodeForHTML(context,dataElem)%></td>
<% 
                                                  }
                                                  
                                                  totalCellCounter++;
                                                  limitCounter++;
                                              }
                                              
                                              rememberTotalObjectCount = totalCellCounter;
                       
                                              //to show total column data, handling all possible wrap or column limit cases
                                              if((showTotalColumn!=null) && showTotalColumn.equalsIgnoreCase("true") && (rememberColCount == iColumnLimit) && (lowerValue!=2) && (lowerValue!=iColumnLimit) && ((lowerValue==iColumnLimit) || (((iColumnLimit-1)%(lowerValue-1))!=0)) && ((((iColumnLimit-1)%(lowerValue-1))==1) || (lowerValue-1)!=2) && (((lowerValue-1)!=2) || (lowerValue==iColumnLimit) || ((iColumnLimit-1)%2!=0)))
                                              {                                        
                                                  //Total Column Drawn boolean updated
                                                  totalColAlreadyDrawn = true;
                                                  //Get the Column Total List
                                                  StringList columnTotalList  = (StringList) tabularFormatDataMap.get(metricsReportUIBean.KEY_TOTAL_COLUMN);                                                  
                                                  if(showTotalHrefLink!=null && showTotalHrefLink.equals("true") && totalObjectsCellHref!=null && !"".equals(totalObjectsCellHref) && !mode.equals("Print") && (noLimitsApplied || (((cols - 1)<=(iColumnLimit-1)) && (rows<=iRowLimit))))
                                                  {
                                                       totalObjectsCellHref = FrameworkUtil.encodeURL(totalObjectsCellHref,"UTF-8");
%>
                                                      <td width="10%" style="text-align: center" ><a href="javascript:showCellInfo('<%=totalObjectsCellHref%>','<xss:encodeForJavaScript><%=objectDetails%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strRefresh%></xss:encodeForJavaScript>');"><%=(String)columnTotalList.get(j + 1)%></a></td>
<%
                                                  }
                                                  else
                                                  {
%>     
                                                      <td width="10%" style="text-align: center"><%=XSSUtil.encodeForHTML(context,(String)columnTotalList.get(j + 1))%></td>
<%
                                                  }
                                             }

                                             if(colCountSniffer<lowerValue)
                                             {
                                                 for(int i=0; i<lowerValue-colCountSniffer;i++)
                                                 {
%>
                                                     <td width="10%" style="text-align: center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
<%
                                                 }
                                             }
%>
                                       </tr>
<%
                                     }
                                 }// end of if condition
                              }// end of last row if condition
                              
                              counter++;               
                              
                          }// end of for loop
           
                          //if number of columns drawn has reached the wrap column limit
                          if(colCountSniffer==lowerValue)
                          {
                              colCountSniffer = 0;
                          }
%>
                  </table>
                  <br/>
<%
                  if(rememberColCount==iColumnLimit && totalColAlreadyDrawn)
                  {      
                      if(!noLimitsApplied && !mode.equals("Print") && (((cols - 1)>(iColumnLimit-1)) || (rows>iRowLimit)))
                      {
%>
                          <script language="javascript">
                              alert("<%=strResultTruncated%>");
                          </script>
<%
                      }      
                  }
                  tempColCountSniffer++;           
               }
               if(!totalColAlreadyDrawn)
               {
                  //if no. of columns is not 2, but the wrapping size is 2, then to prevent addition columns getting added      
                  if(iColumnLimit!=2  && ((iColumnLimit - 1) % 2)!=0 && (lowerValue!=iColumnLimit) && lowerValue==2 && (showTotalColumn!=null) && showTotalColumn.equalsIgnoreCase("true"))
                  {
                      String strTotalColHeading = (String)tabularFormatSettings.get(metricsReportUIBean.TOTAL_ROW_HEADING);
%>
                      <table id="emxMetricsTabularFormat" border="1" cellpadding="3" cellspacing="2" width="100%" style="margin-left: 6px;">
                          <tr class="odd">
                              <th width="10%" style="text-align:center" ><%=XSSUtil.encodeForHTML(context,(String) strColHeaders.get(0))%>&nbsp;</th>
                              <th width="10%" style="text-align:center" ><%=XSSUtil.encodeForHTML(context,strTotalColHeading)%>&nbsp;</th>
                          </tr>             
<%
                          for(int j=0; j<lowerRowValue; j++)
                          {
                              String rowHeader = (String) strRowHeaders.get(j); // row headers
                              // Draw row header
%>
                              <tr class="odd">
                                  <td width="10%" style="text-align: center" ><b><%=XSSUtil.encodeForHTML(context,rowHeader)%></b></td>
<%
                                  if((rememberColCount == iColumnLimit) && (showTotalColumn!=null) && showTotalColumn.equalsIgnoreCase("true"))
                                  {                        
                                      //Get the Column Total List
                                      StringList columnTotalList  = (StringList) tabularFormatDataMap.get(metricsReportUIBean.KEY_TOTAL_COLUMN);
                                      String cellData = (String)columnTotalList.get(j);
                                      String cellHref = (String) totalColCellMap.get(rowHeader);

                                      if(showTotalHrefLink!=null && showTotalHrefLink.equals("true") && cellHref!=null && !"".equals(cellHref) && !mode.equals("Print") && (noLimitsApplied || (((cols - 1)<=(iColumnLimit-1)) && (rows<=iRowLimit))))
                                      {
                                          cellHref = metricsReportUIBean.setCellNumberAsZeroIfApplicable(cellData,cellHref);
                                          cellHref = FrameworkUtil.encodeURL(cellHref,"UTF-8");
%>
                                          <td width="10%" style="text-align: center" ><a href="javascript:showCellInfo('<%=cellHref%>','<xss:encodeForJavaScript><%=objectDetails%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strRefresh%></xss:encodeForJavaScript>');"><%=cellData%></a></td>
<%
                                      }
                                      else
                                      {
%>     
                                          <td width="10%" style="text-align: center"><%=XSSUtil.encodeForHTML(context,cellData)%></td>
<%
                                      }                                
                                  }
             
                                  if(j == lowerRowValue - 1)
                                  {
                                      // Get the setting to show the 'Total' row
                                      String showTotalRow = (String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_ROW_TOTAL);
                                      // Get the setting to show the 'Object Count' row
                                      String showObjectCount = (String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_OBJECT_COUNT);
                                      // If configured to show the 'Total' row
                                      if(showTotalRow!=null && showTotalRow.equals("true"))
                                      {
                                          String showSeparator = (String)(String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_ROW_SEPARATOR);
                                          if(showSeparator!=null && showSeparator.equals("true"))
                                          {
%>
                                              <tr class="odd">
												  <!-- //XSSOK -->
                                                  <td colspan="<%=lowerValue%>" rowspan="0" class="blackrule"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
                                              </tr>
<%
                                          }
%>
                                          <tr class="odd">
<%
                                          // Get the value if configured to show the custom 'Total' row heading
                                          String strTotalHeading = (String)tabularFormatSettings.get(metricsReportUIBean.TOTAL_ROW_HEADING);
%>  
                                          <td width="5%" style="text-align: center" ><b><%=XSSUtil.encodeForHTML(context,strTotalHeading)%></b></td>
<%     
                                          //to show total column data, handling all possible wrap or column limit cases
                                          if((showTotalColumn!=null) && showTotalColumn.equalsIgnoreCase("true"))
                                          {                                        
                                              //Total Column Drawn boolean updated
                                              totalColAlreadyDrawn = true;
                                              //Get the Column Total List
                                              StringList columnTotalList  = (StringList) tabularFormatDataMap.get(metricsReportUIBean.KEY_TOTAL_COLUMN);
                                              if(showTotalHrefLink!=null && showTotalHrefLink.equals("true") && totalObjectsCellHref!=null && !"".equals(totalObjectsCellHref) && !mode.equals("Print") && (noLimitsApplied || (((cols - 1)<=(iColumnLimit-1)) && (rows<=iRowLimit))))
                                              {
                                                  totalObjectsCellHref = FrameworkUtil.encodeURL(totalObjectsCellHref,"UTF-8");
%>
                                                  <td width="10%" style="text-align: center" ><a href="javascript:showCellInfo('<%=totalObjectsCellHref%>','<xss:encodeForJavaScript><%=objectDetails%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strRefresh%></xss:encodeForJavaScript>');"><%=(String)columnTotalList.get(j + 1)%></a></td>
<%
                                              }
                                              else
                                              {
%>     
                                                  <td width="10%" style="text-align: center"><%=XSSUtil.encodeForHTML(context,(String)columnTotalList.get(j + 1))%></td>
<%
                                              }
                                          } 
                                      }
                 
                                      // If configured to show the 'Object Count' row
                                      if(showObjectCount!=null && showObjectCount.equals("true"))
                                      {
%>
                                          <tr class="odd">
<%
                                               String strObjectCountHeading = (String)tabularFormatSettings.get(metricsReportUIBean.OBJECT_COUNT_ROW_HEADING);
%>
                                              <td width="10%" style="text-align: center"><b><%=XSSUtil.encodeForHTML(context,strObjectCountHeading)%></b></td>
<%                 

                                              //Get the Column Total List
                                              StringList columnTotalList  = (StringList) tabularFormatDataMap.get(metricsReportUIBean.KEY_TOTAL_COLUMN);
%>
                                              <td width="10%" style="text-align: center" ><%=XSSUtil.encodeForHTML(context,(String)columnTotalList.get(j + 2))%></td>
                                          </tr>
<%
                                     } 
%>
                               </tr>
<%
                              }// end of if condition
%>
                         </tr>
<%
                         }
                     }
                     else if((lowerValue!=iColumnLimit || !totalColAlreadyDrawn) && (showTotalColumn!=null) && showTotalColumn.equalsIgnoreCase("true"))
                     {
                         String strTotalColHeading = (String)tabularFormatSettings.get(metricsReportUIBean.TOTAL_ROW_HEADING);          
%>
                         <table id="emxMetricsTabularFormat" border="1" cellpadding="3" cellspacing="2" width="100%" style="margin-left: 6px;">
                             <tr class="odd">
                                 <th width="10%" style="text-align:center" ><%=XSSUtil.encodeForHTML(context,(String)strColHeaders.get(0))%>&nbsp;</th>
                                 <th width="10%" style="text-align:center" ><%=XSSUtil.encodeForHTML(context,strTotalColHeading)%>&nbsp;</th>
<%                                 
                                 for(int i=0; i<lowerValue-2;i++)
                                 {
%>
                                     <th width="10%" style="text-align: center" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
<%
                                 }                 
%>           
                            </tr>             
<%
                            for(int j=0; j<lowerRowValue; j++)
                            {
                                String rowHeader = (String) strRowHeaders.get(j); // row headers
                                // Draw row header
%>
                                <tr class="odd">
                                    <td width="10%" style="text-align: center" ><b><%=XSSUtil.encodeForHTML(context,rowHeader)%></b></td>
<%
                                    if((rememberColCount == iColumnLimit) && (showTotalColumn!=null) && showTotalColumn.equalsIgnoreCase("true"))
                                    {                        
                                        //Get the Column Total List
                                        StringList columnTotalList  = (StringList) tabularFormatDataMap.get(metricsReportUIBean.KEY_TOTAL_COLUMN);
                                        String cellData = (String)columnTotalList.get(j);
                                        String cellHref = (String) totalColCellMap.get(rowHeader);

                                        if(showTotalHrefLink!=null && showTotalHrefLink.equals("true") && cellHref!=null && !"".equals(cellHref) && !mode.equals("Print") && (noLimitsApplied || (((cols - 1)<=(iColumnLimit-1)) && (rows<=iRowLimit))))
                                        {
                                            cellHref = metricsReportUIBean.setCellNumberAsZeroIfApplicable(cellData,cellHref);
                                            cellHref = FrameworkUtil.encodeURL(cellHref,"UTF-8");
%>
                                            <td width="10%" style="text-align: center" ><a href="javascript:showCellInfo('<%=cellHref%>','<xss:encodeForJavaScript><%=objectDetails%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strRefresh%></xss:encodeForJavaScript>');"><%=cellData%></a></td>
<%
                                        }
                                        else
                                        {
%>     
                                            <td width="10%" style="text-align: center"><%=XSSUtil.encodeForHTML(context,cellData)%></td>
<%
                                        }                                
                                    }

                                    for(int i=0; i<lowerValue-2;i++)
                                    {
%>
                                        <td width="10%" style="text-align: center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
<%
                                    }
             
                                    if(j == lowerRowValue - 1)
                                    {
                                        // Get the setting to show the 'Total' row
                                        String showTotalRow = (String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_ROW_TOTAL);
                                        // Get the setting to show the 'Object Count' row
                                        String showObjectCount = (String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_OBJECT_COUNT);
                                        // If configured to show the 'Total' row
                                        if(showTotalRow!=null && showTotalRow.equals("true"))
                                        {
                                            String showSeparator = (String)(String)tabularFormatSettings.get(metricsReportUIBean.KEY_SHOW_ROW_SEPARATOR);
                                            if(showSeparator!=null && showSeparator.equals("true"))
                                            {
%>
                                                <tr class="odd">
													<!-- //XSSOK -->
                                                    <td colspan="<%=lowerValue%>" rowspan="0" class="blackrule"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
                                                </tr>
<%
                                            }
%>
                                            <tr class="odd">
<%
                                            // Get the value if configured to show the custom 'Total' row heading
                                             String strTotalHeading = (String)tabularFormatSettings.get(metricsReportUIBean.TOTAL_ROW_HEADING);
%>
                                             <td width="5%" style="text-align: center" ><b><%=XSSUtil.encodeForHTML(context,strTotalHeading)%></b></td>
<%    

                                             //to show total column data, handling all possible wrap or column limit cases
                                             if((showTotalColumn!=null) && showTotalColumn.equalsIgnoreCase("true"))
                                             {   
                                                 //Get the Column Total List
                                                 StringList columnTotalList  = (StringList) tabularFormatDataMap.get(metricsReportUIBean.KEY_TOTAL_COLUMN);                                                 
                                                 if(showTotalHrefLink!=null && showTotalHrefLink.equals("true") && totalObjectsCellHref!=null && !"".equals(totalObjectsCellHref) && !mode.equals("Print") && (noLimitsApplied || (((cols - 1)<=(iColumnLimit-1)) && (rows<=iRowLimit))))
                                                 {
                                                     totalObjectsCellHref = FrameworkUtil.encodeURL(totalObjectsCellHref,"UTF-8");
%>
                                                     <td width="10%" style="text-align: center" ><a href="javascript:showCellInfo('<%=totalObjectsCellHref%>','<xss:encodeForJavaScript><%=objectDetails%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strRefresh%></xss:encodeForJavaScript>');"><%=(String)columnTotalList.get(j + 1)%></a></td>
<% 
                                                 }
                                                 else
                                                 {
%>     
                                                     <td width="10%" style="text-align: center"><%=XSSUtil.encodeForHTML(context,(String)columnTotalList.get(j + 1))%></td>
<%
                                                 }
                                            }
                                       } 
                 
                                       // If configured to show the 'Object Count' row
                                       if(showObjectCount!=null && showObjectCount.equals("true"))
                                       {
%>
                                           <tr class="odd">
<%
                                               String strObjectCountHeading = (String)tabularFormatSettings.get(metricsReportUIBean.OBJECT_COUNT_ROW_HEADING);
%>
                                               <td width="10%" style="text-align: center"><b><%=XSSUtil.encodeForHTML(context,strObjectCountHeading)%></b></td>
<%                
                          
                                               //Get the Column Total List
                                               //to show total column data, handling all possible wrap or column limit cases
                                               if((showTotalColumn!=null) && showTotalColumn.equalsIgnoreCase("true"))
                                               {   
                                                   //Get the Column Total List
                                                   StringList columnTotalList  = (StringList) tabularFormatDataMap.get(metricsReportUIBean.KEY_TOTAL_COLUMN);                                                   
                                                   if(showTotalHrefLink!=null && showTotalHrefLink.equals("true") && totalObjectsCellHref!=null && !"".equals(totalObjectsCellHref) && !mode.equals("Print") && (noLimitsApplied || (((cols - 1)<=(iColumnLimit-1)) && (rows<=iRowLimit))))
                                                   {
%>
                                                        <td width="10%" style="text-align: center" ><a href="javascript:showCellInfo('<%=totalObjectsCellHref%>','<xss:encodeForJavaScript><%=objectDetails%></xss:encodeForJavaScript>','<xss:encodeForJavaScript><%=strRefresh%></xss:encodeForJavaScript>');"><%=(String)columnTotalList.get(j + 2)%></a></td>
<%  
                                                   }
                                                   else
                                                   {
%>       
                                                        <td width="10%" style="text-align: center"><%=XSSUtil.encodeForHTML(context,(String)columnTotalList.get(j + 2))%></td>
<%
                                                   }
                                               }
%>                                            
                                          </tr>
<%
                                      }
                     
                                      for(int i=0; i<lowerValue-2;i++)
                                      {
%>
                                          <td width="10%" style="text-align: center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
<%
                                      }            
%>
                                      </tr>
<%
                                  }
                                  // end of if condition
                                  //draw empty column data
%>
                             </tr>
<%
                             if(j==(lowerRowValue - 1))
                             {
                                 if(!noLimitsApplied && !mode.equals("Print") && (((cols - 1)>(iColumnLimit-1)) || (rows>iRowLimit)))
                                 {
%>
                                     <script language="javascript">
                                          alert("<%=strResultTruncated%>");
                                     </script>
<%
                                 }
                             }
                          }
                       }
                    } // end of if no total column is drawn
                 }
              }
           }
           catch (Exception ex)
           {
               ex.printStackTrace();
               if(ex.toString()!=null && (ex.toString().trim()).length()>0)
               {
                   emxNavErrorObject.addMessage("Tabular Format Display Failed :" + ex.toString().trim());
               }
           }
%>
       </form>
       <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
    </body>
</html>
