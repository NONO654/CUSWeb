<%--  emxMetricsOpenViewDeleteReportProcess.jsp - This JSP is used to process the Open, View and Delete features

   Copyright (c) 2005-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsOpenViewDeleteReportProcess.jsp.rca 1.19 Wed Oct 22 16:11:56 2008 przemek Experimental $
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="javascript" src="../common/scripts/emxNavigatorHelp.js"></script>
<script language="javascript" src="../common/scripts/emxJSValidationUtil.js"></script>

<jsp:useBean id="metricsReportBean" class="com.matrixone.apps.metrics.MetricsReports" scope="request"/>

<%      
    String selectedFilter = "";
    String strName = emxGetParameter(request,"emxTableRowId");
    String strMode = emxGetParameter(request,"mode");
    String strShared = "";
    String strOwner = "";
    if(strName!=null && !"".equals(strName) && !"null".equalsIgnoreCase(strName))
    {
        strShared =  strName.substring(strName.lastIndexOf("|") + 1,strName.length());
        strOwner =  strName.substring(strName.indexOf("|") + 1,strName.lastIndexOf("|"));
        strName = strName.substring(0,strName.indexOf("|"));
      
        if(strMode.equalsIgnoreCase("open"))
        {
            if(strName != null && !"null".equals(strName) && !"".equals(strName))
            {            
               if(strShared!=null && !"null".equalsIgnoreCase(strShared) && !"".equals(strShared))
               {
                   if(strOwner!=null && !"null".equalsIgnoreCase(strOwner) && !"".equals(strOwner))
                   {
                       // clean up all the outdated archives on the webreport
                       String strTimeStamp = Long.toString(System.currentTimeMillis());
                       WebReport webreport = new WebReport(strName,strOwner);
                       try
                       {
                           metricsReportBean.removeOutDatedReportArchives(context,webreport,strTimeStamp);                        
                       }                       
                       catch(Exception e){
                            // do nothing..just pass by as only those archives for which 
                            // access is available will be deleted
                       }
                       // cleanup operation ends..

                       if(strShared.equals("yes") && strOwner.equalsIgnoreCase(context.getUser()))
                       {
                   %>
                          <script language="javascript">
                              var contentFrame = getTopWindow().findFrame(getTopWindow().getWindowOpener().getTopWindow(), "metricsReportContent");
                              getTopWindow().getWindowOpener().pageControl.setSharedAndOwned(true);
                              getTopWindow().getWindowOpener().pageControl.setSharedAndNotOwned(false);
                              getTopWindow().getWindowOpener().enableFunctionality(contentFrame.STR_METRICS_SAVE_COMMAND,true);
                              getTopWindow().getWindowOpener().enableFunctionality(contentFrame.STR_METRICS_DELETE_COMMAND,true);
                              getTopWindow().getWindowOpener().pageControl.setOwner("<%=XSSUtil.encodeForURL(context, strOwner)%>");
                          </script>
                   <%
                       }
                       else if(strShared.equals("yes") && !strOwner.equalsIgnoreCase(context.getUser()))
                       {
                   %>
                          <script language="javascript">
                              var contentFrame = getTopWindow().findFrame(getTopWindow().getWindowOpener().getTopWindow(), "metricsReportContent"); 
                              getTopWindow().getWindowOpener().pageControl.setSharedAndNotOwned(true);
                              getTopWindow().getWindowOpener().pageControl.setSharedAndOwned(false);
                              getTopWindow().getWindowOpener().enableFunctionality(contentFrame.STR_METRICS_DELETE_COMMAND,false);
                              getTopWindow().getWindowOpener().enableFunctionality(contentFrame.STR_METRICS_SAVE_COMMAND,false);                                                      
                              getTopWindow().getWindowOpener().pageControl.setOwner("<%=XSSUtil.encodeForURL(context, strOwner)%>");
                          </script>
                   
                   <%
                       }
                       else if(strShared.equals("no"))
                       {
                   %>
                          <script language="javascript">
                              var contentFrame = getTopWindow().findFrame(getTopWindow().getWindowOpener().getTopWindow(), "metricsReportContent");
                              getTopWindow().getWindowOpener().pageControl.setSharedAndOwned(false);                       
                              getTopWindow().getWindowOpener().pageControl.setSharedAndNotOwned(false);
                              getTopWindow().getWindowOpener().enableFunctionality(contentFrame.STR_METRICS_SAVE_COMMAND,true);
                              getTopWindow().getWindowOpener().enableFunctionality(contentFrame.STR_METRICS_DELETE_COMMAND,true);
                              getTopWindow().getWindowOpener().pageControl.setOwner("<%=XSSUtil.encodeForURL(context, strOwner)%>");
                          </script>                   
                   <%
                       }
                   }
               }            
%>
               <script language="javascript">        
                   getTopWindow().getWindowOpener().pageControl.setSavedReportName("<%=strName%>");                   
                   getTopWindow().getWindowOpener().getTopWindow().openReport();                   
                   getTopWindow().getWindowOpener().pageControl.setOpenedLast(false);
                   getTopWindow().getWindowOpener().pageControl.setLatestSavedReportName("<%=XSSUtil.encodeForURL(context, strName)%>");
               </script>
<%
          }
      } 
      else if(strMode.equalsIgnoreCase("view"))
      {
          if("null".equals(strName) || strName == null || "".equals(strName)){
 
          }
          else
          {
              if(strShared.equals("yes") && !strOwner.equalsIgnoreCase(context.getUser()))
              {
%>
                   <script language="javascript">
                       getTopWindow().getWindowOpener().pageControl.setSharedAndNotOwned(true);
                       getTopWindow().getWindowOpener().pageControl.setOwner("<%=XSSUtil.encodeForURL(context, strOwner)%>");
                   </script>
<%
              }
              else
              {
%>              
                   <script language="javascript">
                       getTopWindow().getWindowOpener().pageControl.setSharedAndNotOwned(false);
                       getTopWindow().getWindowOpener().pageControl.setOwner("<%=XSSUtil.encodeForURL(context, strOwner)%>");
                   </script>
<%
               }
%>
                  <script language="javascript">
                      getTopWindow().getWindowOpener().pageControl.setLatestSavedReportName("<%=XSSUtil.encodeForURL(context, strName)%>");
                      var objContentWindow = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "metricsReportHidden");
                      //XSSOK Using javscript encodeURI API
					  var strURL = "emxMetricsResults.jsp?mode=reportView&defaultReport="+getTopWindow().getWindowOpener().pageControl.getCommandName()+"&resultsTitle=" + encodeURI(getTopWindow().getWindowOpener().pageControl.getResultsTitle())+"&reportName=" + encodeURI("<%=strName%>") + "&owner=" + encodeURI("<%=strOwner%>") + "&showRefresh=true" + "&isSharedAndNotOwned=" + getTopWindow().getWindowOpener().pageControl.isSharedAndNotOwned();
                      getTopWindow().getWindowOpener().frames[0].document.forms[0].action = "../businessmetrics/emxMetricsViewResultsAction.jsp?strURL="+encodeHREF(strURL);
                      getTopWindow().getWindowOpener().frames[0].document.forms[0].target = objContentWindow.name;
                      getTopWindow().getWindowOpener().frames[0].document.forms[0].submit();
                      getTopWindow().closeWindow();
                  </script>
<%
          }
      }
    }
    
    if(strMode.equalsIgnoreCase("delete"))
    {
        String strReportName = emxGetParameter(request,"reportName");
        String strReporttype = emxGetParameter(request, "reporttype");        
        String closeWindow = "true";
        
        try
        {
            metricsReportBean.deleteReport(context,strReportName,strReporttype);
        }
        catch (Exception ex)
        {
            closeWindow = "false";
            if(ex.toString() != null && (ex.toString().trim()).length()>0){
                emxNavErrorObject.addMessage("emxReport:" + ex.toString().trim());
            }
        }
%>
        <script language="javascript">
            if("true" == "<%=closeWindow%>")
              getTopWindow().closeWindow();
        </script>
<%
    }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script>
    var mode = "<xss:encodeForJavaScript><%=strMode%></xss:encodeForJavaScript>";
    if (mode == "open")
    {
        getTopWindow().closeWindow();
    }    
</script>
