<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SMAUrlUtils,java.util.Set,java.net.URLEncoder"%>

<%!
  static String urlWithParameterBackup(final HttpServletRequest request, final String url, final String paramName, final String backupParamName)
  {
    final String alreadyBackupedValue=request.getParameter(backupParamName);
    final String actualValue=request.getParameter(paramName);
    final String backupedValue=((null==alreadyBackupedValue || "".equals(alreadyBackupedValue)) ? actualValue : alreadyBackupedValue);
    final String result=(backupedValue!=null && !backupedValue.equals("")) ? SMAUrlUtils.addParameterToUrl(url,backupParamName,backupedValue) : url;
    return result;
  }
%>

<%
    //gather saved search label prefix
  final String headerPrefix="My Search : ";
  //get base url
  String url=(request.getParameter("savedSearchBaseUrl").indexOf("?")>0) ? request.getParameter("savedSearchBaseUrl").substring(0, request.getParameter("savedSearchBaseUrl").indexOf("?")) : request.getParameter("savedSearchBaseUrl");
  //forward authorized parameter values (but skip programs, inquiries and header as they will be treated latter)
  final Set<String> authorizedTableParameters=(url.contains("emxIndentedTable.jsp")) ? SMAUrlUtils.getAcceptedParameterNamesForEmxTableIndented() : SMAUrlUtils.getAcceptedParameterNamesForEmxTable();
  final Enumeration paramNames=request.getParameterNames();
  while (paramNames.hasMoreElements())
  {
    final String paramName=(String)paramNames.nextElement();
    if ("program".equals(paramName) || "programLabel".equals(paramName) || "header".equals(paramName) || !authorizedTableParameters.contains(paramName)) continue;
    final String paramValue=request.getParameter(paramName);
    if (null==paramValue || paramValue.trim().length()==0) continue;
    url=SMAUrlUtils.addParameterToUrl(url,paramName,paramValue);
  }
  //backup original parameters in order to be able to restore original behavior
  url=urlWithParameterBackup(request,url,"header","originalHeader");
  url=urlWithParameterBackup(request,url,"program","originalProgram");
  url=urlWithParameterBackup(request,url,"programLabel","originalProgramLabel");
  //url=urlWithParameterBackup(request,url,"inquiry","inquiry");
  //url=urlWithParameterBackup(request,url,"inquiryLabel","originalInquiryLabel");
//encode savedSearchName parameter so it can be passed as a URL parameter with special characters (such as '&')
  String savedSearchName=URLEncoder.encode(request.getParameter("savedSearchName"),"UTF-8");
  String savedSearchDisplayName=URLEncoder.encode(request.getParameter("savedSearchDisplayName"),"UTF-8");
  
  final String savedSearchProgram=request.getParameter("savedSearchProgram");
  if (savedSearchName.indexOf("inquiry") != -1) 
  {
      savedSearchName = request.getParameter("savedSearchName");
      savedSearchDisplayName = request.getParameter("savedSearchDisplayName");
      String[] arr = savedSearchName.split(":");
      savedSearchName =  arr[1];
      url=SMAUrlUtils.addParameterToUrl(url, "inquiry", savedSearchName);
      url=SMAUrlUtils.addParameterToUrl(url,"header", savedSearchDisplayName);
  } else {
        //if several programs already defined, add the saved search program on first position.
        //ignore inquiries as (programs + inquiries) configuration is not supported by emxTables 10.7
        final String actualProgram = request
            .getParameter("program");
        final String runSavedSearchProgram = "jpo.simulation.SMASearchDialog:runSavedSearch";
        if (actualProgram != null && actualProgram.contains(","))
        {
            url = SMAUrlUtils.addParameterToUrl(url, "program",
                runSavedSearchProgram + "," + actualProgram);
            url = SMAUrlUtils.addParameterToUrl(url,
                "programLabel",
                request.getParameter("savedSearchName") + ","
                    + request.getParameter("programLabel"));
        }
        else
        {
            url = SMAUrlUtils.addParameterToUrl(url, "program",
                runSavedSearchProgram);
        }
        //add saved search method parameter (if no specific saved search method is provided, use the original one)

        url = SMAUrlUtils.addParameterToUrl(
            url,
            "savedSearchProgram",
            ((null == savedSearchProgram || ""
                .equals(savedSearchProgram)) ? actualProgram
                .split(",")[0] : savedSearchProgram));
        //add saved search name parameter
        url = SMAUrlUtils.addParameterToUrl(url, "savedSearchName",
            savedSearchName);
        url=SMAUrlUtils.addParameterToUrl(url,"header", headerPrefix+savedSearchName);
        //add saved search combobox name parameter
        final String savedSearchCombo = request
            .getParameter("savedSearchCombo");
        url = SMAUrlUtils.addParameterToUrl(url,
            "savedSearchCombo", savedSearchCombo);
    }

    //check recursion and run saved search => prevents an infinite recursion and then a stack overflow
    if (!"SMASearchDialog:runSavedSearch"
        .equals(savedSearchProgram))
    {
%><script language="Javascript" type="text/javascript">document.location.href="<%=url%>";</script><%
    out.flush();
  }
  else
  {
    emxNavErrorObject.addMessage("No recursion allowed for 'SMASearchDialog:runSavedSearch'.");
  }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
