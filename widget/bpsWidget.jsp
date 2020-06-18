<!DOCTYPE html>
<%@page import="com.matrixone.servlet.Framework"%>
<%@include file = "../common/emxNavigatorComponentSideDoorInclude.inc"%>
<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file="bpsWidgetConstants.inc"%>
<html>
<head>
<title>Enovia Widget</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no" />
  <!--  Libraries -->
  <link href="../plugins/treetable/stylesheets/jquery.treetable.css" rel="stylesheet" type="text/css">
  <link rel="stylesheet" type="text/css" href="../plugins/libs/jqueryui/1.10.3/css/cupertino/jquery.ui.custom.min.css">
  <link href="../plugins/dynatree/1.2.4/skin-vista/ui.dynatree.css" rel="stylesheet" type="text/css">
  <script src="../plugins/libs/jquery/2.0.0/jquery.min.js"></script>
  <script src="../plugins/libs/jqueryui/1.10.3/js/jquery.ui.custom.min.js"></script>
  <script src="../plugins/libs/jquerycookie/jquery.cookie.js"></script>
  <script src="../plugins/dynatree/1.2.4/jquery.dynatree.min.js"></script>
  <script src="../plugins/highchart/3.0.2/js/highcharts.js"></script>
  <script src="../plugins/treetable/javascripts/src/jquery.treetable.js"></script>
  <script src="../plugins/hammer/jquery.hammer.js"></script>

  <!-- UWA 2 Libraries  -->
  <script src="../plugins/UWA/js/UWA_Swym_Alone_full.js"></script>
  <script src="../plugins/tagnavigator/js/TagNavigatorProxy-min.js"></script>

   
  <!--  Our code -->
  <link href="./timeline/css/timeline.css" rel="stylesheet" type="text/css">
  <script src="./timeline/js/Timeline.js"></script>
  <script src="./timeline/js/Dateline.js"></script>
  <script src="./scripts/bpsWidgetConversion.js"></script>

<link rel="stylesheet" type="text/css" href="./styles/bpsWidget.css" />
<!--script src="../common/scripts/dsTouchEvents.js"></script-->
<script src="../common/scripts/bpsTagNavConnector.js"></script>
<script src="./scripts/bpsWidgetUtils.js"></script>
<script src="./scripts/bpsWidgetTagNavInit.js"></script>
<script src="./scripts/bpsWidgetAPIs.js"></script>
<script src="./scripts/bpsWidgetSave.js"></script>
<script src="./scripts/bpsWidgetChart.js"></script>
<script src="./scripts/bpsWidgetTemplate.js"></script>
<script src="./scripts/bpsWidgetEngine.js"></script>
<script src="./scripts/bpsWidgetPreferences.js"></script>
</head>
<body>
<div id="widgetPageBody">
<div id="widgetContent"></div>
<script>
    jQuery.noConflict(); 
    <%= widgetConst %>
    var isIFWE = false;
    window.enoviaServer = {
        params: location.search.substring(1),
        getUrl: function() {
            return '<%=sRealURL%>';
        },
        getParams: function() {
            return this.params;
        }
    };
    jQuery(function() {
        var widget_name = '<%= XSSUtil.encodeForURL(request.getParameter("bps_widget")) %>',
        initObj = {
            name: widget_name,
            div: "widgetContent",
            params: enoviaServer.getParams()
        };
        bpsWidgetEngine.widget(initObj).init();
        if(getTopWindow().isMobile) {
            jQuery('#widgetPageBody').width(jQuery('#widgetPageBody').width() - 2);
        }
    }); 
</script>
</div>
</body>
</html>
