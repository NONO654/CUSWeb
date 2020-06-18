<html>
    <head>
    <%
    String objectId =  request.getParameter("objectId"); 
    String table = "SMACommon_AttributeGroups";
    String selection= "multiple";
    String program= "jpo.simulation.AttributeGroup=getAttributeGroupsTable";
    String objectBased= "false";
    String suiteKey= "SimulationCentral";
    String header= "Common.AttributeGroup.PageHeading";
    String HelpMarker= "SMACommon_NavTreeAttributeGroups";
    String toolbar="SMACommon_NavTreeAttributeGroupsToolbar";
    String emxSuiteDirectory="simulationcentral";
    String StringResourceFileId="smaSimulationCentralStringResource";
    String SuiteDirectory= "simulationcentral";
    %>
    
    </head>
    <body >
        <iframe id='attributeGroup' frameborder="0"  height="100%" width="100%"></iframe>
    </body>
    <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
	<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
	<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
	<script language="Javascript" src="../common/scripts/emxUISlideIn.js"></script>

	<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUIToolbar.js"></script>
    <script type="text/JavaScript">

        window.addEventListener("beforeunload", function(event) { 
            var opener = window.opener.top;
            model = {};
                 model.refresh = true;
            opener.postMessage(JSON.stringify(model),'*');
        });
        function setURL(){
            var url =  '../common/emxTable.jsp?' +toQueryString({
						objectId: "<%= objectId%>",
						table: "<%= table%>",
						selection: "<%= selection%>",
						program: "<%= program%>",
						objectBased: "<%= objectBased%>",
						suiteKey: "<%= suiteKey%>",
						header: "<%= header%>",
						HelpMarker: "<%= HelpMarker%>",
						toolbar:"<%= toolbar%>",
						emxSuiteDirectory:"<%= emxSuiteDirectory%>",
						StringResourceFileId:"<%= StringResourceFileId%>",
						SuiteDirectory: "<%= SuiteDirectory%>"
                    });
        document.getElementById("attributeGroup").src = url;
        } 
        
    function toQueryString (o) {
      var query = '', p;
      for (p in o) {
        if (o.hasOwnProperty(p)) {
          query += (query ? '&' : '') + encodeURIComponent(p) + '=' + encodeURIComponent(o[p]);
        }
      }
      return query;
    }
  setURL();

    </script>

</html>
