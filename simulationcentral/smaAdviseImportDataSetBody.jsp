<%--  smaAdviseImportDataSetBody.jsp - this file is loaded in a frame of the smaAdviseImportDataSet.jsp and provides the form for file upload
 * (c) Dassault Systemes, 2013
 *
--%>
<%-- Common Includes --%>

<html>


	<head>
		<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
		<script language="javascript" src="../common/scripts/emxUICore.js"></script>
		
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		<script	src="../plugins/libs/jquery/2.0.0/jquery.min.js" type="text/javascript"></script>
		<script	src="../plugins/libs/jqueryui/1.10.3/js/jquery.ui.custom.min.js"	type="text/javascript"></script>
		
		<script src="./smaAdviseImportDataSet.js" type="text/javascript"></script>
		<link rel="stylesheet" type="text/css" href="./styles/smaAdviseImportDataSet.css">
		
	</head>

	<body>
	
		<script>
          addStyleSheet("emxUIMenu");
          addStyleSheet("emxUIForm");
          addStyleSheet("emxUIDefault");
    	</script>
	
		<div id="resIntImportDataSetRootDiv">
		</div>
		
		<form class='sim-ui-importPage-hidden-importForm' id='importForm' name="checkinForm" method="post" enctype="multipart/form-data" action="../servlet/fcs/checkin" target>
			<input type="hidden" name="noOfFiles" value="1">
			<input type="hidden" name="parentId" value>
			<input id="objectIDField" type="hidden" name="objectId" value>
			<input id="ticketfield" type="hidden" name="__fcs__jobTicket" value>
			<input type="hidden" name="__fcs__failurePage" value="./ematrix/components/emxComponentsError.jsp">
			<input type="hidden" name="store" value="STORE">
			<input type="file" name="bfile0" size="30" onpaste="return false;" onkeypress="displaymessage(this);return false;" value="">
			<input type="hidden" name="fileName0" value="MyDatasetFile.zrf">
			<input type="text" name="caseTitle" value="">
		</form>
		
	
	</body>
	
	<script type="text/javascript">
		$simjq(document).ready(function(){
			createImportRow();
		});
	</script>

</html>
