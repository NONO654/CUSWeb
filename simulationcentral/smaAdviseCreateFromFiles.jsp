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
	<div class="sim-ui-importPage-content" style='top:0px;bottom:1px;'>
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
</div>

<div id="divPageFoot">
				  <table width="100%" border="0" align="center" cellspacing="2" cellpadding="3">
					<tr>
					  <td class="buttons" align="right">
						<table border="0" cellspacing="0">
						  <tr>
						    
								<td>
									<a class="footericon" href="javascript:this.frames['checkinFrame'].goBack()">
										<img src="../common/images/buttonDialogPrevious.gif" border="0" alt=""/>
									</a>
								</td>
							<td>
								<a class="footericon" href="javascript:this.frames['checkinFrame'].checkinFile()">
									<img src="../common/images/buttonDialogDone.gif" border="0" alt=""/>
								</a>
								
							</td>
							<td>
									<!-- a href="javascript:this.frames['checkinFrame'].checkinFile()" class="button"><button class="btn-primary" type="button" -->
									<a class="button"><button id="sim-ui-importPage-doneDiv" class="btn-primary" type="button">
										Done</button>
									</a>
							</td>
						  	<td>
									<a class="footericon" href="javascript:this.frames['checkinFrame'].checkinCancel()">
										<img src="../common/images/buttonDialogCancel.gif" border="0" alt=""/>
									</a>
							</td>
							<td>
									<!-- a href="javascript:this.frames['checkinFrame'].checkinCancel()" class="button"><button class="btn-default" type="button"-->
									<a class="button"><button id="sim-ui-importPage-cancelDiv" class="btn-default" type="button">
										Cancel</button>
									</a>
							</td>
						  </tr>
						</table>
					  </td>
					</tr>
				  </table>
				</div>	

<div id="nonImmediateFilter">
                    <a href="javascript:FullSearch.refreshTaxonomies();"><img vspace="2" hspace="2" src="../common/images/buttonMiniDone.gif" class="miniDone"/></a>
        </div>
<script type="text/javascript">

if(typeof $simjq=='undefined') {
	$simjq = jQuery.noConflict();
}

$simjq(document).ready(function() {
	
	// Added for IR-345257-3DEXPERIENCER2015x
	//configureCreateFromFilesDialog();
	//loadParentDialogAndCreateFilesDialog();
	
	$simjq('#sim-ui-importPage-addMoreButton').on('click', function() {
		addFileCallback();
	});
	document.querySelector('#sim-ui-importPage-cancelDiv').onclick = closeTopWindow;
	document.querySelector('#sim-ui-importPage-doneDiv').onclick = submitFromFiles;
/*
	$simjq('#sim-ui-importPage-cancelDiv').on('click',function() {
		//getTopWindow().closeWindow();
		closeTopWindow();
	});
	
	$simjq('#sim-ui-importPage-doneDiv').on('click',function() {
		//$simjq(document.body).append("<div class='blockingDiv'>");
		//submitForm();
		submitFromFiles();
	});*/
});

</script>
</html>
