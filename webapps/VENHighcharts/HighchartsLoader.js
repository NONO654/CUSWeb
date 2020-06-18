/**
* @fullreview  KB9 19:06:20
*/


define('DS/VENHighcharts/HighchartsLoader',
[
  'UWA/Class',
  'UWA/Core',
  'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices',
  'DS/WebappsUtils/WebappsUtils'
],
function
(
  Class,
  UWA,
  i3DXCompassPlatformServices,
  WebappsUtils
)
{
  //global no choice
  Highcharts = null;
  'use strict';

  UWA.Promise(function(resolve, reject) {
         // Retrieve the Service URL
         i3DXCompassPlatformServices.getPlatformServices({
             platformId:  widget.getValue('x3dPlatformId'),
             onComplete:  function onRetrieveServiceComplete(iServicesInfos) {
                 if (UWA.is(iServicesInfos, 'array')) {
                     iServicesInfos = iServicesInfos[0];
                 }
				  
                  var l3DSpaceURL = "";
				  if (WebappsUtils.getWebappsBaseUrl() != "/../")
					l3DSpaceURL = iServicesInfos["3DSpace"] + "/webapps";
  require.config({
    packages: [{
      name: 'highcharts',
      main: 'highcharts'
    }],
    paths: {
						  'highcharts': l3DSpaceURL + '/VENHighcharts/highcharts.7.1.2',
						  'highcharts-modules': l3DSpaceURL + '/VENHighcharts/highcharts.7.1.2/modules'
    }
  });

  require(['highcharts',
  'highcharts/highcharts-more',
  'highcharts/highcharts-3d',
  'highcharts/modules/accessibility',
  'highcharts/modules/annotations',
  'highcharts/modules/annotations-advanced',
  'highcharts/modules/arrow-symbols',
  'highcharts/modules/boost',
  'highcharts/modules/boost-canvas',
  'highcharts/modules/broken-axis',
  'highcharts/modules/bullet',
  'highcharts/modules/current-date-indicator',
  'highcharts/modules/cylinder',
  'highcharts/modules/data',
  'highcharts/modules/datagrouping',
  'highcharts/modules/drilldown',
					  'highcharts/modules/export-data',
					  'highcharts/modules/exporting',
					  'highcharts/modules/offline-exporting',
  'highcharts/modules/funnel'
],function(highcharts,
  more,
					  highchartsthreeD,
  accessibility,
  annotations,
  annotationsadvanced,
  arrowsymbols,
  boost,
  boostcanvas,
  brokenaxis,
  bullet,
  currentdateindicator,
  cylinder,
  data,
  datagrouping,
  drilldown,
					  exportdata,
					  exporting,
					  offlineexporting,
  funnel)
  {
    Highcharts = highcharts;
						 resolve("getPlatformServices OK");
  });
             },
             onFailure:   function onRetrieveServiceFailure() {

                 reject("getPlatformServices KO");
    }
         });
     });

});
