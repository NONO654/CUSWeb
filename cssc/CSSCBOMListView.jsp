<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
 <%
	String objectId = request.getParameter("objectId");
	String iframeTop = "../common/emxVPLMLogon.jsp?urlLogon=emxIndentedTable.jsp%3FexpandProgramMenu%3DVPLMProdStrucDisplayFormat&table=VPLMIndentedSummary&reportType=BOM&sortColumnName=none&HelpMarker=emxhelppartbom&PrinterFriendly=true&editRootNode=false&massPromoteDemote=false&triggerValidation=false&&emxSuiteDirectory=.&otherTollbarParams=&suiteKey=VPLMProductEditor&StringResourceFileId=emxVPLMProductEditorStringResource&SuiteDirectory=.&objectId="+objectId+"&widgetId=null";
	String bomList = "../common/emxIndentedTable.jsp?initialQueryLimit=50&table=ENCEngineeringView&header=emxEngineeringCentral.Common.Parts&&sortColumnName=Last+Modified&program=enoENGView%3AfindMyViewObjects&selection=multiple&sortDirection=descending&HelpMarker=emxhelpmyviewparts&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&mode=view&type=type_Part&customFormName=EngineeringDashboardFilter&initialState=&excludePolicy=Manufacturing+Part&includeState=&checkOriginator=true&checkUserPreferences=true&freezePane=Name%2CTitle&suiteKey=EngineeringCentral&customSearchCriteria=true&initialQueryLimit=5000";
	%>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Home</title>
    <style>
        #iframeTop{
            width: 100%;
            height: 360px;
			margin:0;
			padding:0;
			margin-top:0;
			padding-top:0
        }
        #iframeLeft{
            width: 15%;
            height: 700px;
            float: left;
        }
        #iframeContent{
            width: 100%;
            height: 400px;
			margin-top:0;
			padding-top:0
			margin:0;
			padding:0;
        }
		
		body{
		margin: 0;
		}
		

    </style>
<body>
<div style="margin: 0">
    <iframe id="iframeTop" name="iframeTop" scrolling="auto" frameborder="0" src="cssc3DLive.jsp?objectId=<%=objectId%>"></iframe>
   
    <iframe id="iframeContent" name="iframeContent" scrolling="auto"  frameborder="0" src="csscBomView.jsp?objectId=<%=objectId%>"></iframe>
</div>
</body>
</html>
