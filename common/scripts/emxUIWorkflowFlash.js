//=================================================================
// JavaScript emxUIWorkflowFlash.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
// $Id: emxUIWorkflowFlash.js.rca 1.1.1.1.5.4 Wed Oct 22 15:48:13 2008 przemek Experimental przemek $
//=================================================================
var workflowObj = null;
function resizePlugin(args){
	args = args.split(",");
	var theBigger = workflowObj.parentNode.width || workflowObj.parentNode.clientWidth;
	workflowObj.width = (parseInt(args[0])>parseInt(theBigger))? args[0]:theBigger;
    workflowObj.height = args[1];
}
function rescalePlugin(args){
	if(isIE){
       workflowObj.width *= args;
       workflowObj.height *= args;
	}
}
function workflow_DoFSCommand(command, args) {
    workflowObj = isIE ? document.all.workflow : document.workflow;
	switch(command){
		case "resizePlugin":
		resizePlugin(args);
		break;
		case "rescalePlugin":
		rescalePlugin(args);
		break;
	}
}
// Hook for Internet Explorer.
if (isIE) {
	document.write('<script language=\"VBScript\"\>\n');
	document.write('On Error Resume Next\n');
	document.write('Sub workflow_FSCommand(ByVal command, ByVal args)\n');
	document.write('	Call workflow_DoFSCommand(command, args)\n');
	document.write('End Sub\n');
	document.write('</script\>\n');
}
