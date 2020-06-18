<%--  emxPackagesConfigurationRefreshChannels.jsp  --  refresh channels on KWd and DMA
  Copyright (c) 1992-2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
 --%>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>

<script language="Javascript" >
var sbWindow = null;
var sbWindowBas= null;
var index;
var channel= ["PackageConfigTypesCmd","PackageConfigExtsCmd","DeploymentExtensionsCmd"];
for (index = 0; index < channel.length; index++) {
	sbWindow = findFrame(top,channel[index]);
	if(sbWindow && typeof sbWindow.emxEditableTable != 'undefined' && sbWindow.emxEditableTable.refreshStructureWithOutSort){
		   sbWindow.emxEditableTable.refreshStructureWithOutSort();  
		   break;
	}
}
var channelBas = ["PackageConfigAttributesCmd","DeploymentAttributesCmd"];
for(index = 0; index < channelBas.length; index++){
	sbWindowBas = findFrame(top, channelBas[index]);
	if(sbWindowBas && typeof sbWindowBas.emxEditableTable != 'undefined' && sbWindowBas.emxEditableTable.refreshStructureWithOutSort){
		sbWindowBas.emxEditableTable.refreshStructureWithOutSort();  
		   break;
	}
}
</script>
