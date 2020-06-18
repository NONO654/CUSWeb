<%-- emxMetricsDashboardCreateProcess.jsp - This file is used to create the Metrics Dashboard
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxMetricsDashboardCreateProcess.jsp.rca 1.8 Wed Oct 22 16:11:58 2008 przemek Experimental $
--%>
<html>
<head>
<body>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxMetricsConstantsInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
</head>
<%
    String strChannel1Reports  = emxGetParameter(request,"channel1reports");
    String strChannel2Reports  = emxGetParameter(request,"channel2reports");
    String strChannel3Reports  = emxGetParameter(request,"channel3reports");
    String strChannel4Reports  = emxGetParameter(request,"channel4reports");

    String strBundle    = "emxMetricsStringResource";
    String languageStr  = request.getHeader("Accept-Language");

    String layout1 = EnoviaResourceBundle.getProperty(context, "emxMetrics.Name.Dashboard.Layout1");
    String layout2 = EnoviaResourceBundle.getProperty(context, "emxMetrics.Name.Dashboard.Layout2");
    String layout3 = EnoviaResourceBundle.getProperty(context, "emxMetrics.Name.Dashboard.Layout3");
    String layout4 = EnoviaResourceBundle.getProperty(context, "emxMetrics.Name.Dashboard.Layout4");
    String layout5 = EnoviaResourceBundle.getProperty(context, "emxMetrics.Name.Dashboard.Layout5");

    String channelHeight = EnoviaResourceBundle.getProperty(context, "emxMetrics.Dashboard.ChannelHeight");
        
    String prefSelectedLayout = PersonUtil.getSelectedLayout(context);
    String strSelectedLayout   = emxGetParameter(request,"prevlayout");

    String strChannel1ReportsProcess  = "";
    String strChannel2ReportsProcess  = "";
    String strChannel3ReportsProcess  = "";
    String strChannel4ReportsProcess  = "";

    strChannel1ReportsProcess = com.matrixone.apps.metrics.MetricsDashboard.removeChannelNamefromReports(strChannel1Reports);
    strChannel2ReportsProcess = com.matrixone.apps.metrics.MetricsDashboard.removeChannelNamefromReports(strChannel2Reports);
    strChannel3ReportsProcess = com.matrixone.apps.metrics.MetricsDashboard.removeChannelNamefromReports(strChannel3Reports);
    strChannel4ReportsProcess = com.matrixone.apps.metrics.MetricsDashboard.removeChannelNamefromReports(strChannel4Reports);

    try
    {
        if (strSelectedLayout != null)
        {
          PersonUtil.setSelectedLayout(context, strSelectedLayout);
        }
    }
    catch (Exception ex) 
    {
        if (ex.toString()!=null && ex.toString().length()>0){ 
            emxNavErrorObject.addMessage(ex.toString()); 
        }      
    }
    
    // This mode will be "create" for the very first time for every user
    // since there will be no dashboard configured for that user.
    // If any user specific dashboard is present, mode will be "update"
    String strMode = "create";
    
    StringList layoutList = new StringList(5);
    layoutList.addElement(layout1);
    layoutList.addElement(layout2);
    layoutList.addElement(layout3);
    layoutList.addElement(layout4);
    layoutList.addElement(layout5);

    Map hmChannelDetailsMap = new TreeMap();
    hmChannelDetailsMap.put("Channel 1",strChannel1ReportsProcess);
    hmChannelDetailsMap.put("Channel 2",strChannel2ReportsProcess);
    hmChannelDetailsMap.put("Channel 3",strChannel3ReportsProcess);
    hmChannelDetailsMap.put("Channel 4",strChannel4ReportsProcess);
    
    if(!(prefSelectedLayout==null || prefSelectedLayout.trim().length()== 0))
    {
      strMode = "update";
    }
    
    com.matrixone.apps.metrics.MetricsDashboard.createChannels(context, hmChannelDetailsMap, strMode, strSelectedLayout, channelHeight, layoutList );
    
   
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</body>
</html>
