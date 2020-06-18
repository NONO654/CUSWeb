<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
 <%
	String objectId = request.getParameter("objectId");
	String iframeTop = "../common/emxIndentedTable.jsp?selection=multiple&isAddExisting=true&submitLabel=emxComponents.Common.Done&cancelLabel=emxComponents.Common.Cancel&cancelButton=true&HelpMarker=emxhelpselectorganization&header=emxComponentsCentral.Common.SelectRegion&suiteKey=Components&table=CSSCShowCreateAssemblyTable&program=CSICGetResources:getResources&expandProgram=CSICGetResources:getExpandResources&submitURL=../csic/csicSelectModel.jsp&findMxLink=false&massPromoteDemote=false&customize=false&showRMB=false&showClipboard=false&objectCompare=false&objectId="+objectId;
	
	
	String systemOperation="../common/emxIndentedTable.jsp?freezePane=Name&program=emxLibraryCentralUtil%3AgetAllLibraries%2CemxLibraryCentralUtil%3AgetAllDocumentLibraries%2CemxLibraryCentralUtil%3AgetAllGeneralLibraries%2CemxLibraryCentralUtil%3AgetAllPartLibraries%2CemxLibraryCentralUtil%3AgetAllInprocessLibraries%2CemxLibraryCentralUtil%3AgetAllActiveLibraries&programLabel=emxDocumentCentral.Common.All%2CemxLibraryCentral.Common.DocumentLibrary%2CemxLibraryCentral.Common.GeneralLibrary%2CemxLibraryCentral.Common.PartLibrary%2CemxLibraryCentral.Common.InProcessLibraries%2CemxLibraryCentral.Common.ActiveLibraries&table=LCLibraryList&selection=multiple&sortColumnName=Name&sortDirection=ascending&toolbar=LCLibrariesToolBar&header=emxDocumentCentral.Common.Libraries&HelpMarker=emxhelplibrarylist&path=Library&suiteKey=LibraryCentral&StringResourceFileId=emxLibraryCentralStringResource&SuiteDirectory=documentcentral";
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
            width: 49%;
            height: 700px;
            float: left;
			margin:0;
			padding:0;
			margin-top:0;
			padding-top:0
        }
        #iframeContent{
            width: 49%;
            height: 700px;
			float: left;
			margin:0;
			padding:0;
			margin-top:0;
			padding-top:0
        }
	
	
    </style>
<body>
<div style="margin: 0">
    <iframe id="iframeLeft" name="iframeLeft" scrolling="auto" frameborder="0" src=""></iframe>
   
    <iframe id="iframeContent" name="iframeContent" scrolling="auto" frameborder="0" src="csscSystemOperationShow.jsp?objectId=<%=objectId%>"></iframe>
</div>
</body>
</html>
