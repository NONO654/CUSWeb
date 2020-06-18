<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
 <%
	String objectId = request.getParameter("objectId");
	String iframeTop = "../common/emxVPLMLogon.jsp?urlLogon=emxIndentedTable.jsp%3FexpandProgramMenu%3DVPLMProdStrucDisplayFormat&table=CSSCVPLMIndentedSummary&reportType=BOM&sortColumnName=none&HelpMarker=emxhelppartbom&PrinterFriendly=true&editRootNode=false&massPromoteDemote=false&triggerValidation=false&&emxSuiteDirectory=.&otherTollbarParams=&suiteKey=VPLMProductEditor&StringResourceFileId=emxVPLMProductEditorStringResource&SuiteDirectory=.&objectId="+objectId+"&widgetId=null&v=12321321";
	//String bomList = "../common/emxIndentedTable.jsp?initialQueryLimit=50&table=ENCEngineeringView&header=emxEngineeringCentral.Common.Parts&&sortColumnName=Last+Modified&program=enoENGView%3AfindMyViewObjects&selection=multiple&sortDirection=descending&HelpMarker=emxhelpmyviewparts&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&mode=view&type=type_Part&customFormName=EngineeringDashboardFilter&initialState=&excludePolicy=Manufacturing+Part&includeState=&checkOriginator=true&checkUserPreferences=true&freezePane=Name%2CTitle&suiteKey=EngineeringCentral&customSearchCriteria=true&initialQueryLimit=5000";
	%>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Home</title>
    <style>
        #iframeTop{
            width: 100%;
            height: 400px;
        }
        #iframeLeft{
            width: 62%;
            height: 350px;
            float: left;
			margin:0;
			padding:0;
			margin-top:0;
			padding-top:0
        }
        #iframeContent{
            width: 36%;
            height: 350px;
			float: left;
			margin:0;
			padding:0;
			margin-top:0;
			padding-top:0
        }
	
	
    </style>
<body>
<div style="margin: 0">
    <iframe id="iframeLeft" name="iframeLeft" scrolling="auto" frameborder="0" src="<%=iframeTop%>"></iframe>
   
    <iframe id="iframeContent" name="iframeContent" scrolling="auto" frameborder="0" src="csscCaptures.jsp?objectId=<%=objectId%>"></iframe>
</div>
</body>
</html>
