<%--  smaAdviseImportDataSet.jsp - main file for importing a dataset and creating an Analytics case connected to that dataset
 * (c) Dassault Systemes, 2013
 *
--%>
<%-- Common Includes --%>


<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
		
		<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
		<script language="javascript" src="../common/scripts/emxUICore.js"></script>
		
		<script>
          addStyleSheet("emxUIMenu");
          addStyleSheet("emxUIForm");
          addStyleSheet("emxUIDefault");
   		</script>

		<script	src="../plugins/libs/jquery/2.0.0/jquery.min.js" type="text/javascript"></script>
		<script	src="../plugins/libs/jqueryui/1.10.3/js/jquery.ui.custom.min.js"	type="text/javascript"></script>
		<link rel='stylesheet' type="text/css" href="../plugins/libs/jqueryui/1.10.3/css/cupertino/jquery.ui.custom.min.css" />
		
		<link rel="stylesheet" type="text/css" href="./styles/smaAdviseResetAll.css">
		<!--link rel="stylesheet" type="text/css" href="./styles/smaAdviseStyles.css"-->
		
		<script src="./smaAdviseImportDataSet.js" type="text/javascript"></script>
		<link rel="stylesheet" type="text/css" href="./styles/smaAdviseImportDataSet.css">
	</head>

<body>
<div id='sim-ui-importPage-mainDiv'>
	<div id='sim-ui-importPage-head' class="sim-ui-importPage-head">
		<h2 class='sim-ui-importPage-title'>Import Data Set</h2>
	</div>
	<div class="sim-ui-importPage-content">
		<table class="sim-ui-importPage-contentTable">
		<tr style='height:30px;'>
			<td class='titleCell' style='width:80px;'><label>Type</label></td>
			<td class="titleCell">Analytics Case</td>
		</tr>
		<tr style='height:30px;'>
			<td class='titleCell' style='width:80px;'><label>Case Title</label></td>
			<td class='titleCell' id='sim-ui-importPage-caseTitleCell'>
				<input type='text' name='caseTitle' id='sim-ui-importPage-caseTitle' style='width:200px;'></input>
			</td>
		</tr>
		</table>
		<div id='sim-ui-importPage-iframeWrapperDiv'>
			<div id='checkinDiv1' data-index=1 class='checkinWrapperDiv'>
				<iframe name="checkinFrame1" data-index=1 id="checkinFrame1" src="smaAdviseImportDataSetBody.jsp" class='sim-ui-importPage-checkinIFrame'></iframe>
			</div>
			<div id='checkinDiv2' data-index=2 class='checkinWrapperDiv'>
				<iframe name="checkinFrame2" data-index=2 id="checkinFrame2" src="smaAdviseImportDataSetBody.jsp" class='sim-ui-importPage-checkinIFrame'></iframe>
			</div>
			<div id='checkinDiv3' data-index=3 class='checkinWrapperDiv'>
				<iframe name="checkinFrame3" data-index=3 id="checkinFrame3" src="smaAdviseImportDataSetBody.jsp" class='sim-ui-importPage-checkinIFrame'></iframe>
			</div>
			<div id='checkinDiv4' data-index=4 class='checkinWrapperDiv'>
				<iframe name="checkinFrame4" data-index=4 id="checkinFrame4" src="smaAdviseImportDataSetBody.jsp" class='sim-ui-importPage-checkinIFrame'></iframe>
			</div>
			<div id='checkinDiv5' data-index=5 class='checkinWrapperDiv'>
				<iframe name="checkinFrame5" data-index=5 id="checkinFrame5" src="smaAdviseImportDataSetBody.jsp" class='sim-ui-importPage-checkinIFrame'></iframe>
			</div>
		</div>
		<div id='sim-ui-importPage-addMoreDiv'>
			<input type="button" value="Add File" id='sim-ui-importPage-addMoreButton'></input>
		</div>
	</div>
	<div id="sim-ui-importPage-foot" class="sim-ui-importPage-foot">
		<div id="sim-ui-importPage-cancelDiv" class="sim-ui-importPage-cancelDiv">
			<img src='../common/images/buttonDialogCancel.gif' border='0'></img>
			<a>Cancel</a>
		</div>
		<div id="sim-ui-importPage-doneDiv" class="sim-ui-importPage-doneDiv">
			<img src='../common/images/buttonDialogDone.gif' border='0'></img>
			<a>Done</a>
		</div>
	</div>
</div>

<script type="text/javascript">

if(typeof $simjq=='undefined') {
	$simjq = jQuery.noConflict();
}

$simjq(document).ready(function() {
	
	$simjq('#sim-ui-importPage-addMoreButton').on('click', function() {
		addFileCallback();
	});

	$simjq('#sim-ui-importPage-cancelDiv').on('click',function() {
		getTopWindow().closeWindow();
	});

	$simjq('#sim-ui-importPage-doneDiv').on('click',function() {
		$simjq(document.body).append("<div class='blockingDiv'>");
		submitForm();
	});
	

});

</script>
</html>
