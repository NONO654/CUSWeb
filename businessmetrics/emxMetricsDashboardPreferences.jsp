<%-- emxMetricsDashboardPreferences.jsp - This JSP displays the Metrics Dashboard Preferences setting page
   
   Copyright (c) 2005-2018 Dassault Systemes. All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsDashboardPreferences.jsp.rca 1.15 Wed Oct 22 16:11:56 2008 przemek Experimental $
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxMetricsConstantsInclude.inc"%>

<%
    String PIPE_SEPARATOR_WITH_SPACE = " | ";
    String strBundle    = "emxMetricsStringResource";
    String languageStr  = request.getHeader("Accept-Language");

    String strSelectTemplate    = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.Dashboard.SelectTemplate");
    String strAssignReport      = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.Dashboard.AssignReport");
    String strUnassignedReports = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.Dashboard.UnassignedReports");
    String strAssignedReports   = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.Dashboard.AssignedReports");

    String strChannel1Display = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.Dashboard.Channel1");
    String strChannel2Display = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.Dashboard.Channel2");
    String strChannel3Display = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.Dashboard.Channel3");
    String strChannel4Display = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.Dashboard.Channel4");
    String strUnassign = EnoviaResourceBundle.getProperty(context, strBundle,context.getLocale(), "emxMetrics.label.Dashboard.Unassign");

    String layout1 = EnoviaResourceBundle.getProperty(context, "emxMetrics.Name.Dashboard.Layout1");
    String layout2 = EnoviaResourceBundle.getProperty(context, "emxMetrics.Name.Dashboard.Layout2");
    String layout3 = EnoviaResourceBundle.getProperty(context, "emxMetrics.Name.Dashboard.Layout3");
    String layout4 = EnoviaResourceBundle.getProperty(context, "emxMetrics.Name.Dashboard.Layout4");
    String layout5 = EnoviaResourceBundle.getProperty(context, "emxMetrics.Name.Dashboard.Layout5");

    WebReportList webreportList =  com.matrixone.apps.metrics.MetricsDashboard.getAllwebreports(context);
    int size = webreportList.size();

    StringList channelList = new StringList(5);
    channelList.addElement("Channel 1");
    channelList.addElement("Channel 2");
    channelList.addElement("Channel 3");
    channelList.addElement("Channel 4");


    String prefSelectedLayout = PersonUtil.getSelectedLayout(context);
    String prefChannelReports = com.matrixone.apps.metrics.MetricsDashboard.getConsolidatedChannelReports(context, channelList);

    String channel1Reports = "";
    String channel2Reports = "";
    String channel3Reports = "";
    String channel4Reports = "";
    String strSelectedLayout = layout3;

    if((prefChannelReports != null) && !(prefSelectedLayout.equals(layout1) || prefSelectedLayout.equals(layout2) || prefSelectedLayout.equals(layout3)|| prefSelectedLayout.equals(layout4) || prefSelectedLayout.equals(layout5)))
    {
        prefSelectedLayout = strSelectedLayout;
        prefChannelReports = "";
    }

    strSelectedLayout = prefSelectedLayout;
    StringTokenizer tempChannelReports = new StringTokenizer(prefChannelReports,"~");
    int count = 1;

    String sChannel = "";

    while(tempChannelReports.hasMoreTokens())
    {
        if(count == 1) {
            channel1Reports = tempChannelReports.nextToken();
            if(channel1Reports.indexOf(PIPE_SEPARATOR_WITH_SPACE) != -1){
              sChannel = channel1Reports.substring(0,channel1Reports.indexOf(PIPE_SEPARATOR_WITH_SPACE));
              sChannel = sChannel.trim();
              // to i18nize Channel 1 label
              channel1Reports= FrameworkUtil.findAndReplace(channel1Reports, sChannel, strChannel1Display);
            }
        }
        else if(count == 2) {
            channel2Reports = tempChannelReports.nextToken();
            if(channel2Reports.indexOf(PIPE_SEPARATOR_WITH_SPACE) != -1){
              sChannel = channel2Reports.substring(0,channel2Reports.indexOf(PIPE_SEPARATOR_WITH_SPACE));
              sChannel = sChannel.trim();
              // to i18nize Channel 2 label
              channel2Reports= FrameworkUtil.findAndReplace(channel2Reports, sChannel, strChannel2Display);
            }
        }
        else if(count == 3) {
            channel3Reports = tempChannelReports.nextToken();
            if(channel3Reports.indexOf(PIPE_SEPARATOR_WITH_SPACE) != -1){
              sChannel = channel3Reports.substring(0,channel3Reports.indexOf(PIPE_SEPARATOR_WITH_SPACE));
              sChannel = sChannel.trim();
              // to i18nize Channel 3 label
              channel3Reports= FrameworkUtil.findAndReplace(channel3Reports, sChannel, strChannel3Display);
            }
        }
        else {
            channel4Reports = tempChannelReports.nextToken();
            if(channel4Reports.indexOf(PIPE_SEPARATOR_WITH_SPACE) != -1){
              sChannel = channel4Reports.substring(0,channel4Reports.indexOf(PIPE_SEPARATOR_WITH_SPACE));
              sChannel = sChannel.trim();
              // to i18nize Channel 4 label
              channel4Reports= FrameworkUtil.findAndReplace(channel4Reports, sChannel, strChannel4Display);
            }
        }
        ++count;
    }

    StringBuffer webreportBuffer = new StringBuffer ();

    String consolidatedPrefReports = com.matrixone.apps.metrics.MetricsDashboard.getConsolidatedChannelReports(context, channelList);
    consolidatedPrefReports =  com.matrixone.apps.metrics.MetricsDashboard.removeChannelNamefromReports(consolidatedPrefReports);

    String consolidatedValidReports = "";

    //Added TreeMap implementation for sorting of the unassigned reports list box.
    Map keyMap = new java.util.TreeMap();
    try
    {
        for(int i=0; i<size; i++)
        {
            WebReport webReport = (WebReport) webreportList.get(i);

            String strOwner = webReport.getOwner();
            String webreportName = webReport.getName();

            String strOptionValue = webreportName + "|" + strOwner;
            keyMap.put(strOptionValue,webReport);
        }

        java.util.Set keySet = keyMap.keySet();
        Iterator itr = keySet.iterator();
        while(itr.hasNext())
        {
            String strOptionValue = (String) itr.next();
            WebReport webReport = (WebReport) keyMap.get(strOptionValue);
            String webreportName = webReport.getName();
            String strOwner = webReport.getOwner();

            consolidatedValidReports += webreportName+",";

            if((webreportName.indexOf(".last") != -1) || consolidatedPrefReports.indexOf(webreportName + "|" + strOwner)!= -1)
            {
                continue;
            }
            webreportBuffer.append("<option value =\"");
            webreportBuffer.append(strOptionValue);
            webreportBuffer.append("\">");
            webreportBuffer.append(webreportName);
            webreportBuffer.append("</option>");
        }
    }
    catch(Exception ex)
    {
        if(ex.toString()!=null && ex.toString().length()>0) {
            emxNavErrorObject.addMessage(ex.toString());
        }
    }
%>

<html>
<head>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
<script language="JavaScript" src="emxMetricsDashboard.js"></script>
<script type="text/javascript">
    addStyleSheet("emxUIDefault");
    addStyleSheet("emxUIForm");
    addStyleSheet("emxUIMetricsDashboard");

    // these variables are defined in the emxMetricsDashboard.js file
    maxReportsInWideChannels = '<%=EnoviaResourceBundle.getProperty(context, "emxMetrics.Dashboard.WideChannelLimit")%>';
    maxReportsInNarrowChannels = '<%=EnoviaResourceBundle.getProperty(context, "emxMetrics.Dashboard.NarrowChannelLimit")%>';

    layout1Format = '<%=EnoviaResourceBundle.getProperty(context, "emxMetrics.Dashboard.Layout1")%>';
    layout2Format = '<%=EnoviaResourceBundle.getProperty(context, "emxMetrics.Dashboard.Layout2")%>';
    layout3Format = '<%=EnoviaResourceBundle.getProperty(context, "emxMetrics.Dashboard.Layout3")%>';
    layout4Format = '<%=EnoviaResourceBundle.getProperty(context, "emxMetrics.Dashboard.Layout4")%>';
    layout5Format = '<%=FrameworkProperties.getProperty(context, "emxMetrics.Dashboard.Layout5")%>';
    totalLayouts  = '<%=EnoviaResourceBundle.getProperty(context, "emxMetrics.Dashboard.TotalLayouts")%>';


    channel1prefreports = "<%=XSSUtil.encodeForJavaScript(context, channel1Reports)%>";
    channel2prefreports = "<%=XSSUtil.encodeForJavaScript(context, channel2Reports)%>";
    channel3prefreports = "<%=XSSUtil.encodeForJavaScript(context, channel3Reports)%>";
    channel4prefreports = "<%=XSSUtil.encodeForJavaScript(context, channel4Reports)%>";
    validReports        = "<%=XSSUtil.encodeForJavaScript(context, consolidatedValidReports)%>";

    channel1Display = "<%=strChannel1Display%>";
    channel2Display = "<%=strChannel2Display%>";
    channel3Display = "<%=strChannel3Display%>";
    channel4Display = "<%=strChannel4Display%>";

</script>
</head>

<body onload="turnOffProgress();javascript:setStoredSelectedLayout()">

<script>
	//XSSOK
    var storedSelectedLayout = "<%=strSelectedLayout%>";
</script>

<form name="MetricsDashboardForm" method="post" action="emxMetricsDashboardCreateProcess.jsp"  onSubmit="javascript:createDashboard();">

    <input type="hidden" name=channel1reports value="<%=channel1Reports%>" />
    <input type="hidden" name=channel2reports value="<%=channel2Reports%>" />
    <input type="hidden" name=channel3reports value="<%=channel3Reports%>" />
    <input type="hidden" name=channel4reports value="<%=channel4Reports%>" />
    <input type="hidden" name=prevlayout value="<%=strSelectedLayout%>" />

  <table border="0" cellpadding="5" cellspacing="2" width="100%" />
    <tr>
      <td class="label" /><%=strSelectTemplate%></td>
    </tr>
    <tr>
      <td class="inputField"> <table border="0">
          <tr>
            <td align="center"> <div id="layout1" class="notSelected">
                <div class="page">
                  <div class="wide"><span class="channel1">1</span></div>
                  <div class="wide"><span class="channel2">2</span></div>
                  <div class="wide"><span class="channel3">3</span></div>
                  <div class="wide"><span class="channel4">4</span></div>
                </div>
              </div>
              <input name="template" type="radio" value="<%=layout1%>" onClick="changeSelection(this,'layout1',layout1Format)" />
            </td>
            <td>&nbsp;</td>
            <td align="center"> <div id="layout2" class="selected">
                <div class="page">
                  <div class="wide"><span class="channel1">1</span></div>
                  <div class="narrow"><span class="channel2">2</span></div>
                  <div class="narrow"><span class="channel3">3</span></div>
                  <div class="wide"><span class="channel4">4</span></div>
                </div>
              </div>
              <input name="template" type="radio" value="<%=layout2%>" onClick="changeSelection(this,'layout2',layout2Format)" />
            </td>
            <td>&nbsp;</td>
            <td align="center"> <div id="layout3" class="notSelected" >
                <div class="page">
                  <div class="wide"><span class="channel1">1</span></div>
                  <div class="wide"><span class="channel2">2</span></div>
                  <div class="narrow"><span class="channel3">3</span></div>
                  <div class="narrow"><span class="channel4">4</span></div>
                </div>
              </div>
              <input name="template" type="radio" value="<%=layout3%>"    onClick="changeSelection(this,'layout3',layout3Format)" />
            </td>
            <td>&nbsp;</td>
            <td align="center"> <div id="layout4" class="notSelected">
                <div class="page">
                  <div class="narrow"><span class="channel1">1</span></div>
                  <div class="narrow"><span class="channel2">2</span></div>
                  <div class="wide"><span class="channel3">3</span></div>
                  <div class="wide"><span class="channel4">4</span></div>
                </div>
              </div>
              <input name="template" type="radio" value="<%=layout4%>"    onClick="changeSelection(this,'layout4',layout4Format)" />
            </td>
            <td>&nbsp;</td>
            <td align="center"> <div id="layout5" class="notSelected">
                <div class="page">
                  <div class="narrow"><span class="channel1">1</span></div>
                  <div class="narrow"><span class="channel2">2</span></div>
                  <div class="narrow"><span class="channel3">3</span></div>
                  <div class="narrow"><span class="channel4">4</span></div>
                </div>
              </div>
              <input name="template" type="radio" value="<%=layout5%>"    onClick="changeSelection(this,'layout5',layout5Format)" />
              </td>
            <td>&nbsp;</td>
          </tr>
        </table></td>
    </tr>
    <tr>
      <td class="label"><%=strAssignReport%></td>
    </tr>
    <tr>
      <td class="inputField"> <table border="0">
          <tr>
            <td><%=strUnassignedReports%></td>
            <td>&nbsp;</td>
            <td><%=strAssignedReports%></td>
          </tr>
          <tr>
            <td> <select name="UnassignedReports" multiple size="10" onChange="javascript:deselectOption(this)">
                <%=webreportBuffer.toString()%>
              </select> </td>
            <td><table border="0" cellpadding="0" cellspacing="2">
                <tr>
                  <td><span class="button">
                    <input type="button" name="Channel 1" value="<%=strChannel1Display%>" onclick="javascript:assignwebreport(this)" class="channel1" />
                    </span></td>
                </tr>
                <tr>
                  <td><span class="button">
                    <input type="button" name="Channel 2" value="<%=strChannel2Display%>" onclick="javascript:assignwebreport(this)" class="channel2" />
                    </span></td>
                </tr>
                <tr>
                  <td><span class="button">
                    <input type="button" name="Channel 3" value="<%=strChannel3Display%>" onclick="javascript:assignwebreport(this)" class="channel3" />
                    </span></td>
                </tr>
                <tr>
                  <td><span class="button">
                    <input type="button" name="Channel 4" value="<%=strChannel4Display%>" onclick="javascript:assignwebreport(this)" class="channel4" />
                    </span></td>
                </tr>
                <tr>
                  <td>&nbsp;</td>
                </tr>
                <tr>
                  <td><span class="button">
                    <input type="button" name="unassign" value="<%=strUnassign%>" onclick="javascript:unassignwebreport()" />
                    </span></td>
                </tr>
              </table></td>
            <td> <select name="AssignedReports" multiple size="10" onChange="javascript:deselectOption(this)">
              </select></td>
          </tr>
        </table></td>
    </tr>
  </table>

<iframe src="../common/emxBlank.jsp" class="hidden-frame" name="hiddenPreferenceFrame" id="hiddenPreferenceFrame" scrolling="no" frameborder="0"></iframe>
</form>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</body>
</html>
