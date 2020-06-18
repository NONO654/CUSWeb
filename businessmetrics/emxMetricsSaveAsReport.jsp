<%-- emxMetricsSaveAsReport.jsp - This JSP will be invoked when the user clicks on "Save As"
                                  command in Report Dialog page's Action menu       
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsSaveAsReport.jsp.rca 1.27 Wed Oct 22 16:11:55 2008 przemek Experimental $ 
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxMetricsConstantsInclude.inc"%>
<jsp:useBean id="metricsReportBean" class="com.matrixone.apps.metrics.MetricsReports" scope="request"/>

<html>
<head>
<script>
    var objField = null;
    var jsFromPortalMode = "false";
</script>
<%
    String strMode = emxGetParameter(request, "mode");
    String timestamp = emxGetParameter(request, "timestamp");
    String reporttype = emxGetParameter(request,"reporttype");
    String fromPortalMode = emxGetParameter(request,"fromPortalMode");
    String suiteDirStr = "";
    String sHelpMarker = emxGetParameter(request, "HelpMarker");
    TreeMap reportMap = new TreeMap();
    TreeMap reportResultsMap = new TreeMap();
    String progressImage = "../common/images/utilProgressBlue.gif";
    String webreportName = "";
    String strOwner = context.getUser();
    String currentWebReportName = emxGetParameter(request,"currentWebReportName");

        suiteDirStr = (String)session.getAttribute("passesSuitedir");

    if(suiteDirStr == null || "null".equals(suiteDirStr) || !(suiteDirStr.length() > 0)) {
        suiteDirStr = "businessmetrics";
    }

    try
    {
        ContextUtil.startTransaction(context, true);
        WebReportList webreportList = metricsReportBean.getWebReportObjects(context,reporttype,null,"");

        Iterator webreportIter = webreportList.iterator();
        while(webreportIter.hasNext())
        {
            WebReport webreport = (WebReport)webreportIter.next();
            webreportName = webreport.getName();
            // need not show the current webreport name in the Save As window
            if(webreportName.equalsIgnoreCase(currentWebReportName)){
                continue;
            }
            String strResultsPageTitle = metricsReportBean.getResultsTitle(context,webreportName, strOwner);
            if(strResultsPageTitle==null || "null".equalsIgnoreCase(strResultsPageTitle) || "".equals(strResultsPageTitle))
            {
                strResultsPageTitle = "";
            }
            reportMap.put(webreportName, strResultsPageTitle);
        }
    }
    catch (Exception ex)
    {
        ContextUtil.abortTransaction(context);
        if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        {
            emxNavErrorObject.addMessage(ex.toString().trim());
        }
    }
    finally
    {
        ContextUtil.commitTransaction(context);
    }

    java.util.Set reportEntrySet = reportMap.entrySet();
    Iterator reportEntrySetIter = reportEntrySet.iterator();
%>

    <script type="text/javascript" language="JavaScript" src="emxMetricsUtils.js"></script>
    <script type="text/javascript" language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
    <script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICore.js"></script>
    <script type="text/javascript" language="JavaScript" src="emxMetrics.js"></script>
    <script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICore.js"></script>
    <script type="text/javascript" language="JavaScript" src="../common/scripts/emxUICoreMenu.js"></script>
    <script language="javascript" src="../common/scripts/emxUIToolbar.js"></script>
    <script language="javascript" src="../common/scripts/emxNavigatorHelp.js"></script>

    <%@include file = "../emxJSValidation.inc" %>
    <script type="text/javascript" language="JavaScript">
        //i18n strings
        var STR_METRICS_ERROR_NAME_FIELD = "<%=STR_METRICS_ERROR_NAME_FIELD%>";
        var saveAsSharedMessage="";
        var saveAsNotSharedMessage="";
        
        function doReport()
        {
            var result = "";
            //get saveName value
            var theForm = document.forms[0];
            var formLen = theForm.elements.length;
            var strName = "";
            var strTitle = "";
            var saveType = "";

            var isNewReportName = false;
            for(var i = 0; i < formLen; i++){
                if(theForm.elements[i].type == "radio" && theForm.elements[i].checked){
                    if(theForm.elements[i].value == "txtName"){
                        objField = document.getElementById("txtName");
                        strName = objField.value;
                        //is strName empty?
                        if(trimWhitespace(strName).length == 0){
                            alert(STR_METRICS_ERROR_NAME_FIELD);
                            return;
                        }
                        if(strName.length>0)
                        {
                            if(!checkField(objField)){
                                objField.focus();
                                turnOffProgress("utilProgressBlue.gif");
                                return;
                            }
                        }
                        objTitleField = document.getElementById("txtNewTitle");
                        strTitle = objTitleField.value;
                        if(strTitle.length>0) {
                            if(!checkField(objTitleField)){
                                objTitleField.focus();
                                turnOffProgress("utilProgressBlue.gif");
                                return;
                            }
                        }
                        saveType = "saveas";
                        isNewReportName = true;
                        break;
                    }
                    else
                    {
                        objField = theForm.elements[i];
                        strName = objField.value;
                        objTitleField = document.getElementById("txtNewTitle" + strName);
                        strTitle = objTitleField.value;
                        strTitle = escapeSpecialCharacters(strTitle);
                        saveType = "update";
                        break;
                    }
                }
            }

        var existingReportName;
<%      if((fromPortalMode!=null) && (fromPortalMode.equalsIgnoreCase("true"))){
%>            
            existingReportName = getTopWindow().getWindowOpener().pageControl.getSavedReportName();
            jsFromPortalMode = "true";
<%      }else{
%>            
            existingReportName = getTopWindow().getWindowOpener().pageControl.getSavedReportName();
<%}%>

            
<%
            if ((strMode!=null) && (strMode.equalsIgnoreCase("ResultsSaveAs")))
            {
%>
                try{
                    var saveAsSharedMessage = getTopWindow().STR_METRICS_SAVE_AS_SHARED_MSG;
                    var saveAsNotSharedMessage = getTopWindow().STR_METRICS_SAVE_AS_NOT_SHARED_MSG;
                    var resultsContentFrame = getTopWindow().openerFindFrame(getWindowOpener().parent,"metricsReportResultsContent");
                    if((jsFromPortalMode == "true") && (resultsContentFrame == null)){
                        resultsContentFrame = parent.openerFindFrame(getWindowOpener(),"metricsReportResultsContent")
                    }

                    var objResultsField = document.getElementById(strName);
                    var objShared = document.getElementById(strName);

                    if(objShared)
                    {
                        var vShared = objShared.value;
                        if(vShared == "yes")
                        {
                            if(confirm(saveAsSharedMessage))
                            {
                                 saveAsReportResults(strName,strTitle,saveType,"SaveAsResults","<xss:encodeForJavaScript><%=timestamp%></xss:encodeForJavaScript>",existingReportName);
                            }
                        }
                        else
                        {
                            if(objField)
                            {
                                 if(objField.name != "txtName")
                                 {
                                     if(confirm(saveAsNotSharedMessage))
                                     {
                                         saveAsReportResults(strName,strTitle,saveType,"SaveAsResults","<xss:encodeForJavaScript><%=timestamp%></xss:encodeForJavaScript>",existingReportName);
                                     }
                                 }
                                 else
                                 {
                                     saveAsReportResults(strName,strTitle,saveType,"SaveAsResults","<xss:encodeForJavaScript><%=timestamp%></xss:encodeForJavaScript>",existingReportName);
                                 }
                            }
                        }
                    }
                    else
                    {
                        saveAsReportResults(strName,strTitle,saveType,"SaveAsResults","<xss:encodeForJavaScript><%=timestamp%></xss:encodeForJavaScript>",existingReportName);
                    }
                 }
                 catch(e){
                 }
<%
            }
            else
            {
%>
                var objShared = document.getElementById(strName);

                if(!isNewReportName)
                {
                    var vShared = objShared.value;
                    if(vShared=="yes")
                    {
                        if(confirm(getTopWindow().getWindowOpener().getTopWindow().STR_METRICS_SAVE_AS_SHARED_MSG))
                        {
                            //call save updateNotes for storing only the new definition
                            result = getTopWindow().getWindowOpener().saveReport(strName,strTitle,"updatNotes","criteriaUpdate",existingReportName);
                            try{
                                metricsReportSaveAsHidden.document.write(result);
                            }
                            catch(e){
                            }
                        }
                    }
                    else
                    {
                        if(confirm(getTopWindow().getWindowOpener().getTopWindow().STR_METRICS_SAVE_AS_DIALOG))
                        {
                            //call save updateNotes for storing only the new definition
                            result = getTopWindow().getWindowOpener().saveReport(strName,strTitle,"updateNotes","criteriaUpdate",existingReportName);
                            try{
                                metricsReportSaveAsHidden.document.write(result);
                            }
                            catch(e){
                            }
                        }
                    }
                }
                else
                {
                    //call save updateNotes for storing only the new definition
                    result = getTopWindow().getWindowOpener().saveReport(strName,strTitle,saveType,"criteriaUpdate",existingReportName);
                    try{
                        metricsReportSaveAsHidden.document.write(result);
                    }
                    catch(e){
                    }
                }
<%
            }
%>
        }

        function turnOffProgress(){
            document.images['progress'].src = "../common/images/utilSpacer.gif";
        }
    </script>
    <script>
        var COMMON_HELP     = "<emxUtil:i18n localize="i18nId">emxFramework.Common.Help</emxUtil:i18n>";
        var HELP_MARKER     = "<xss:encodeForJavaScript><%=sHelpMarker%></xss:encodeForJavaScript>";
        var SUITE_DIR       = "<xss:encodeForJavaScript><%=suiteDirStr%></xss:encodeForJavaScript>";
        var LANGUAGE_STRING = "<%=langStr%>";
        objToolbar = new emxUIToolbar(emxUIToolbar.MODE_NORMAL);
        objToolbar.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, "iconActionHelp.gif", COMMON_HELP, "javascript:openHelp(\"" + HELP_MARKER + "\", \"" + SUITE_DIR + "\", \"" + LANGUAGE_STRING + "\")"));

        function doLoad() {
           toolbars.init("divToolbar");
        }
    </script>
    <script type="text/javascript">
        addStyleSheet("emxUIToolbar");
        addStyleSheet("emxUIMetricsDialog");
        addStyleSheet("emxUIForm");
   </script>
   <title>
        <%=STR_METRICS_LABEL_SAVE_AS%>&nbsp;
   </title>
</head>
<body onload="doLoad();turnOffProgress()" class="save">
   <form method="post" name="MetricsSaveAsForm" onsubmit="doReport(); return false">
      <div id="divPageHead">
         <table border="0" cellspacing="0" cellpadding="0" width="100%">
            <tr>
                <td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
            </tr>
            <tr>
                <table border="0" width="100%" cellspacing="0" cellpadding="0">
                   <tr>
                      <td width="1%" nowrap><span class="pageHeader">&nbsp;&nbsp;&nbsp;&nbsp;<%=STR_METRICS_LABEL_SAVE_AS%>&nbsp;&nbsp;&nbsp;&nbsp;</span></td>
                      <%
                          String processingText = UINavigatorUtil.getProcessingText(context, "en");
                      %><!-- //XSSOK -->
                      <td nowrap><div id="imgProgressDiv">&nbsp;<img src="<%=progressImage%>" width="34" height="28" name="progress" align="absmiddle" />&nbsp;<i><%=processingText%></i></div></td>
                      <td width="1%"><img src="images/utilSpacer.gif" width="1" height="28" border="0" alt="" vspace="6" /></td>
                 </tr>
            </table>
        </tr>
        <tr>
        <div class="toolbar-container"><div class="toolbar-frame" id="divToolbar"></div></div>
        </tr>
    </table>
  </div>
  <div id="divPageBody" style="top:86px;">
      <table border="0" cellpadding="3" width="100%" id="tblMain" cellspacing="2">
         <thead>
             <tr>
                 <th width="5%" style="text-align:center"></th>
                 <th align="left"><table><tr><td width ="45px"></td><td><%=STR_METRICS_LABEL_NAME%></td></tr></table></th>
                 <th><%=STR_METRICS_LABEL_TITLE%></th>
             </tr>
         </thead>
         <tbody>
             <tr class="even">
                 <td style="text-align: center; ">
                     <input type="radio" name="savedReportName" id="savedReportName" value="txtName" checked />
                 </td>
                 <td>
                     <table border="0">
                        <tr>
                            <td valign="top">
                                <img src="../common/images/iconSmallFile.gif" border="0" alt="File" />
                            </td>
                            <td>
                                <span class="object"><input type="text" name="txtName" id="txtName" value="" /></span>
                            </td>
                        </tr>
                    </table>
                  </td>
                  <td style="text-align: center; ">
                      <table border="0">
                          <tr class="even">
                              <td style="text-align: center; ">
                                 <span class="object"><input type="text" name="txtNewTitle" id="txtNewTitle" value="" /></span>
                              </td>
                          </tr>
                      </table>
                  </td>
              </tr>
              <%
                  String rowClass = "odd";
                  while(reportEntrySetIter.hasNext()){
                      Map.Entry reportMapEntry = (Map.Entry)reportEntrySetIter.next();
                      String strVal = (String) reportMapEntry.getKey();
                      boolean boolShared = metricsReportBean.isShared(context,strVal,context.getUser());
                      String strShared = "no";
                      if(boolShared)
                      {
                          strShared = "yes";
                      }
                      String strDesc = (String) reportMapEntry.getValue();
                      strDesc = metricsReportBean.escapeSlashes(strDesc);
                      if(strVal != null ){
              %>
              <!-- //XSSOK -->
              <tr class="<%= rowClass %>">
                  <td style="text-align: center; ">
                      <!-- //XSSOK -->
                      <input type="radio" name="savedReportName" id="savedReportName" value="<%= strVal%>" />
                  </td>
                      <!-- //XSSOK -->
                      <input type="hidden" name="<%=strVal%>" id="<%=strVal%>" value="<%=strShared%>" />
                  <td>
                      <table border="0">
                         <tr>
                             <td width="45px" valign="top">
                                 <img src="../common/images/iconSmallFile.gif" border="0" alt="File" />
                             </td>
                             <td>
                                 <!-- //XSSOK -->
                                 <span class="object"><%= strVal%></span>
                             </td>
                         </tr>
                      </table>
                  </td>
                  <td style="text-align: center; ">
                      <table border="0">
                          <tr class="even">
                              <td style="text-align: center; ">
                                  <!-- //XSSOK -->
                                  <span class="object"><input type="text" name="txtNewTitle<%= strVal%>" id="txtNewTitle<%= strVal%>" value="<%= strDesc%>" /></span>
                              </td>
                          </tr>
                      </table>
                  </td>
              </tr>
              <%
                     rowClass = (rowClass == "odd") ? "even" : "odd";
                  }
              }
              %>
              </tbody>
         </table>
         <input type="image" height="1" width="1" border="0" name="inputImage" value=""/>
     </div>
     <div id="divPageFoot">
        <div id="divDialogButtons">
           <table border="0" cellspacing="0" align="right">
              <tr>
                  <td width="80%">&nbsp;&nbsp;</td>  
                  <td><a onclick="javascript:doReport()" class="button"><button class="btn-default" type="button"><%=STR_METRICS_DONE%></button></a></td>
                  <td></td>
                  <td><a onclick="javascript:getTopWindow().closeWindow()" class="button"><button class="btn-default" type="button"><%=STR_METRICS_CANCEL%></button></a></td>
                  <td>&nbsp;&nbsp;</td><td>&nbsp;&nbsp;</td>
              </tr>
           </table>
        </div>
     </div>
     <iframe src="../common/emxBlank.jsp" width="0" height="0" name="metricsReportSaveAsHidden" id="metricsReportSaveAsHidden" frameborder="0" scrolling="no"></iframe>
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
    </form>
  </body>
</html>
