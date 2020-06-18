//=================================================================
// JavaScript CheckConsistencyCmd.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================
//quickreview HAT1 ZUD 14:12:10 HL Requirement Specification Dependency 
//quickreview HAT1 ZUD 15:02:11 HL - Requirement Specification dependency. Tabs and buttons support in checkConsistency dialog.
//quickreview JX5  T94 15:03:18 Adapt to new level of jquery-ui and jquery-dialogextend for TMC project
//quickreview JX5      15:04:07 IR-363767 Special Characters in the title field of Requirement Specification make Traceability authoring command KO.
//quickreview HAT1 ZUD 15:04:22  : IR-364298-3DEXPERIENCER2016x- FUN048478:Preference under Tree display option are not getting applied. 
//quickreview HAT1 ZUD 15:04:22  : IR-364298-3DEXPERIENCER2016x- FUN048478:Preference under Tree display option are not getting applied. 
//quickreview HAT1 ZUD 15:07:15  : IR-379618-3DEXPERIENCER2016x - NLS transformation is not getting applied to �Solving Warning and inconsistency�  and �solving error  inconsistency pop up� . 
//quickreview HAT1 ZUD 15:07:15  : IR-379609-3DEXPERIENCER2016x - NLS transformation is not getting applied on Check Consistency pop up window.
//quickreview HAT1 ZUD 15:07:15  : IR-381800-3DEXPERIENCER2016x - Solving inconsistency with create link command is KO.  
//quickreview HAT1 ZUD 15:07:16  : IR-381584-3DEXPERIENCER2016x - Wrong Tree structure is displayed in Create Link to Covered Requirement and check consistency pop-up windows. 
//quickreview JX5      15:07:20  : Replace old error and warning icons by new ones
//quickreview QYG      16:05:03  : javascript refactoring, location moved
//quickreview KIE1 ZUD 16:12:13  :	IR-484700-3DEXPERIENCER2018x: R419-FUN055951: In Envoia Preferences user is unable to unselect options in Tree Display section once they are selected by user.
//quickreview HAT1 ZUD 17:07:06  : IR-531749-3DEXPERIENCER2018x: R20-FUN067990-NLS:Tooltip of objects on Links Creation window is not translated. 

define('DS/ENORMTCustoSB/CheckConsistencyCmd', [], function(){
	return {};
});

var listChildNodeCoveredWarning = new Array();
var listChildNodeCoveredError   = new Array();
var mainTreeDiv    = "";
var errorWarningTreeDiv = "";
var independentReqSpecCount = 0;
var tab = "";

var ctx = null;

function getObjectIdfromKey(key){
	
	var ids = key.split("|");
	return ids[0];
	
}

/*
 * Create Check Consistency Dialog
 */
function createCheckConsistencyDialog(objectId)
{	
	var marginTopCover 		    = "";
	var marginTopCoverLabel 	= "";
	var marginTopRefineLabel	= "";
	var treeHeightCover		    = "";
	var checkConsistencyHeader	= "";
	var dlgTitle			    = "";
	
	marginTopCover 		    = "30px";
	marginTopCoverLabel 	= "1px";
	marginTopRefineLabel	= "-10px";
	treeHeightCover		    = "340px";
	
	// ++ Creating DIVs required for Tree dialog Tabs and Warnings and Error++
	checkConsistencyHeader	= '<div id="checkConsistencyHeader" style="height:10px;margin-top:0px;">'+
	
	'<div id="checkConsistencyLegend" style="position:absolute;right:0px;left:640px;width:260px">'+
	'<h3 style="font-size:11px;font-weight:bold;font-family:Arial, sans-serif">'+"Legend"+'</h3>'+
		'<div>'+
			'<li><img src="../requirements/images/Rparent_refined_into.gif" style="height:48px;width:88px"><p style="margin-left:88px;">'+ refineLegLabel + ' - ' + isRefinedLegLabel + '</p> </li>'+
			'<li><img src="../requirements/images/Rparent_covered_by.gif" style="height:48px;width:88px"><p style="margin-left:88px;">'+coverLegLabel+' - '+isCoveredLegLabel+'</p></li>'+
		'</div>'+
	'</div>'+

	'</div>';

	dlgTitle 			= CheckConsistencyTitle;
	
	var checkConsistencyDiv = '<div id="checkConsistencyDialog" style ="display: none;background:rgba(255,0,0,0);">'+
	            checkConsistencyHeader + 
				'<div id="consistencyTabs" style="position:absolute;right:340px;left:10px;height:370px;width:600px">'+
				 '<ul>'+
				    '<li><a href="#coveredRequirementTab">' + CoveredRequirements + '<div id = "coverErrorAndWarningCount" style="display: inline"></div></a></li>'+
				    '<li><a href="#refinedRequirementTab">' + RefiningRequirements + '<div id = "refinedErrorAndWarningCount" style="display: inline"></div></a></li>'+
				  '</ul>'+
				  '<div id="coveredRequirementTab">'+ 
				  '<div id="coveredRequirementContainer"> </div> </div>'+
				  '<div id="refinedRequirementTab">'+
				  '<div id="refinedRequirementContainer"> </div> </div>'+
				'</div>'+
				
				'<canvas id="dCanvas" height="350" width="900" style="z-index:-1;position:absolute;top:0px;left:0px"></canvas>'+
			'</div>';
	
	var contextMenu = '<ul id="checkConsistencyMenu" class="contextMenu" style="display:none;height:50px;width:150px;">'+
	'<li class="ExpandAll"><a href="#expandAll">Expand All</a></li>'+
	'<li class="CollapseAll"><a href="#collapseAll">Collapse All</a></li>'+
	'</ul>';
	
	var solveWarningInConsistencyDiv = '<div id="solveWarningInConsistencyDiv" title="'+ SolveWarningInConsistencyDlgTitle +'" style="display : none;">'+
										'<span id="requirementNameWarningAlert" style="display: inline; font-weight: bold;">  </span>'+
											'  '+ SolveWarningInConsistencyAlert +' '+
										'<span id="reqSpecNameWarningAlert" style="display: inline; font-weight: bold;"></span>.'+
										'</div>';
	
	var solveErrorInConsistencyDiv = '<div id="solveErrorInConsistencyDiv" title="'+ SolveErrorInConsistencyDlgTitle +'" style="display : none;">'+
	 								  '<span id="requirementNameErrorAlert" style="display: inline; font-weight: bold;">  </span>'+
										'  '+ SolveErrorInConsistencyAlert +
									   '<span id="reqSpecNameErrorAlert" style="display: inline ; font-weight: bold;"></span>.'+ 
									 '</div>';

	
	
	
	var treeMainCoveredRequirementTab         = '<div id="treeCoveredRequirement" style = "width:230px; height:300px; scroll:auto"> </div>';
	var treeErrorWarningCoveredRequirementTab = '<div id="treeCoveredInConsistency" style = "float:right; width:230px; height:300px; scroll:auto">  </div>';	
	
	var treeMainRefinedRequirementTab         = '<div id="treeRefinedRequirement" style = "width:230px; height:300px; scroll:auto;"> </div>'; 
	var treeErrorWarningRefinedRequirementTab = '<div id="treeRefinedInConsistency" style = "float:right; width:230px; height:300px; scroll:auto"> </div>';
	
	// --  Creating DIVs required for Tree dialog Tabs and Warnings and Error --
	
	// ++ Creating Options and handlers for checkConsistencyDialog ++
	var checkConsistencyDialogExtendOptions = {
			"closable":true,
	};
	
	var checkConsistencyDialogOptions = {
			modal: true,
			resizable: false,
			height: 500,
			width: 900,
			title : dlgTitle,
			buttons:derivationDlgButtons,
	        close: function () {
	        		//$("#coveredRequirementContainer").dynatree('destroy').remove();
	        		for(var i =1; i <= derivTreeNumber;i++)
	        		{
	        			var tempTree = '#treeRefinedRequirement'+ i +'';
	        			$(tempTree).dynatree('destroy').remove();
	        		}
	                $(this).dialog('destroy').remove();
	                derivTreeNumber =1 ;

	        },
	        resizeStop: function(event, ui){

	        	//resizeStopDerivationDialog(event,ui);

	        }
	};
	
	// Handles Switching of Tabs in Dialog.
	 function handleSelect(event, ui) {
	
		  tab = ui.newTab;
		         if(tab.index() == 0)
		        	 {
		        	 	listChildNodeCoveredWarning = [];
		        	 	listChildNodeCoveredError   = [];
		        	 	
		        	    $("#refinedRequirementContainer").empty();
		        	 	$("#refinedRequirementContainer").hide();
		        	 	$("#coveredRequirementContainer").append(treeMainCoveredRequirementTab);
		        		$("#coveredRequirementContainer").append(treeErrorWarningCoveredRequirementTab); 
		        	 	$("#coveredRequirementContainer").append(treeMainRefinedRequirementTab);		// To be removed
		        	 	$("#coveredRequirementContainer").show();
		        	 	
                     	//for Covered Requirement
                     	goDynaMainCoveredTree("#treeCoveredRequirement", objectId);
                     	construcFirstCheckConsistencyTree("#treeCoveredRequirement", objectId, 'yes');
                     	finishCheckConsistencyDlgConstruction("coveredRequirementContainer");
                     	
                     	mainTreeDiv    =  "treeCoveredRequirement";
                     	errorWarningTreeDiv =  "treeCoveredInConsistency";
                     	
                     	//Disabling the "Create Link(s)" and "Delete Link" Buttons.
                    	$(".ui-dialog-buttonpane button:contains('"+ CreateLinkButton +"')").button('disable');
                    	$(".ui-dialog-buttonpane button:contains('"+ DeleteLinkButton +"')").button('disable');
                     	
	                	$("#treeCoveredInConsistency").css({"margin-top" : "-600px"});
		        	 }
		         else
		        	 {
		        	 	 listChildNodeCoveredWarning = [];
		        	 	 listChildNodeCoveredError   = [];
		        	 	
		        	 	 $("#coveredRequirementContainer").empty();
		        	 	 $("#coveredRequirementContainer").hide();
		        	 	 $("#refinedRequirementContainer").append(treeMainRefinedRequirementTab);
   		        	 	 $("#refinedRequirementContainer").append(treeErrorWarningRefinedRequirementTab);
		        	 	 $("#refinedRequirementContainer").show();
		        	 	 
                         //for Refined Requirement 
		        	 	 goDynaMainRefinedTree("#treeRefinedRequirement", objectId);
                         construcFirstCheckConsistencyTree("#treeRefinedRequirement", objectId, 'no');
                      	 finishCheckConsistencyDlgConstruction("refinedRequirementContainer");
                      	 
                      	 mainTreeDiv    =  "treeRefinedRequirement";
                      	errorWarningTreeDiv =  "treeRefinedInConsistency";
                     	 
                     	//Disabling the "Create Link(s)" and "Delete Link" Buttons.
                     	$(".ui-dialog-buttonpane button:contains('"+ CreateLinkButton +"')").button('disable');
                     	$(".ui-dialog-buttonpane button:contains('"+ DeleteLinkButton +"')").button('disable');
                      	 
	                	$("#treeRefinedInConsistency").css({"margin-top" : "-600px"});
		        	 }
		         }

	  var tabOpts = {
			            activate : handleSelect     
	  				};

	  // -- Creating Options and handlers for checkConsistencyDialog --
	  
	// ++ Appending DIV to main Page and cascading of DIVs ++
	$("#mx_divBody").append(checkConsistencyDiv);
	
	
	$("#checkConsistencyDialog").css({"overflow-y" : "hidden" , "overflow-x" : "hidden"});
	
	$("#checkConsistencyDialog").append(solveWarningInConsistencyDiv);
	
	$("#checkConsistencyDialog").append(solveErrorInConsistencyDiv);

	
	$("#coveredRequirementContainer").append(treeMainCoveredRequirementTab);
	$("#coveredRequirementContainer").append(treeErrorWarningCoveredRequirementTab);
	// -- Appending DIV to main Page and cascading of DIVs --
		
 	// Create Check Consistency Dialog
	$('#checkConsistencyDialog').dialog(checkConsistencyDialogOptions).dialogExtend(checkConsistencyDialogExtendOptions);	
	$('#consistencyTabs').tabs(tabOpts);		
	$('#checkConsistencyDialog').append(contextMenu);
	
 	//Disabling the "Create Link(s)" and "Delete Link" Buttons.
	$(".ui-dialog-buttonpane button:contains('"+ CreateLinkButton +"')").button('disable');
	$(".ui-dialog-buttonpane button:contains('"+ DeleteLinkButton +"')").button('disable');
	// -- Appending DIV to main Page and cascading of DIVs --

	$("#consistencyTabs").tabs("option", "active", 1); 
	$("#consistencyTabs").tabs("option", "active", 0);
}

// ++ Creation of Button CreateLink and Delete Link ++
var derivationDlgButtons = {};

derivationDlgButtons[CreateLinkButton] = function(){
	createLinkBwReqSpecs(mainTreeDiv, errorWarningTreeDiv);
};

derivationDlgButtons[DeleteLinkButton] = function(){
	removeSelectedObjects(mainTreeDiv, errorWarningTreeDiv);
};
// -- Creation of Button CreateLink and Delete Link --

/*
 * Detach a derived requirement from the structure
 */
function removeSelectedObjects(mainTreeDiv, errorWarningTreeDiv) // To Change the Name of Function
{
		var mainTree         = $("div[id^='"+mainTreeDiv+"']");
		var errorWarningTree = $("div[id^='"+errorWarningTreeDiv+"']");

	    // We check the selected nodes of all trees
		var selectedNodes = $(mainTree).dynatree("getSelectedNodes");

		// We detach the objects
		var sNode 		= selectedNodes[0];
		var sKey  		= sNode.data['key'];
		var sKeys		= sKey.split('|');
		var sId 		= sKeys[0]; // object Id
		var sRelId		= sKeys[1]; // relationship Id
		var sParentId	= sKeys[2]; // Parent Id
		var srcKey		= "";
		var tgtKey		= "";
		
		//Disconnect relationship
		emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=DeleteDerivationLinks&relId="+sRelId+"");
		
		//We need to remove the selected node ... 
		sNode.remove();
		//var nodeToRemove = $(treeDivs[i]).dynatree("getTree").getNodeByKey(tgtKey);
		
		//if(nodeToRemove != null)
			//nodeToRemove.remove();
		
	 	$(errorWarningTree).empty();
	 	$(errorWarningTree).hide();
	 	
		$("#consistencyTabs").tabs("option", "active", Math.abs(tab.index()-1));
		$("#consistencyTabs").tabs("option", "active", Math.abs(tab.index()-1));
	 	
}

/*
 * Creates Derived Requirement Specification relationship Between dependent Requirement Specification(s).
*/ 
 
function createLinkBwReqSpecs(mainTreeDiv, warningTreeDiv)
{
	var warningTree     = $("div[id^='"+warningTreeDiv+"']");
	var mainTree        = $("div[id^='"+mainTreeDiv+"']");
	var rootObjectId 	= getObjectIdfromKey($(mainTree).dynatree("getRoot").childList[0].data['key']);

	var selectedWarningTreeReqSpecNodes = $(warningTree).dynatree("getSelectedNodes");
	var selectedMainTreeNodes           = $(mainTree).dynatree("getSelectedNodes");
	
	if(selectedWarningTreeReqSpecNodes != null && selectedWarningTreeReqSpecNodes.length >0)
	{

		for(var n=0; n < selectedWarningTreeReqSpecNodes.length; n++)
		{
			// We detach the objects
			var sNode 		= selectedWarningTreeReqSpecNodes[n];
			var sKey  		= sNode.data['key'];
			var sKeys		= sKey.split('|');
			var sId 		= sKeys[0]; // object Id
			//var sRelId		= sKeys[1]; // relationship Id
			//var sParentId	= sKeys[2]; // Parent Id
			
			var reqSpecSourceId = rootObjectId;
			var reqSpecTargetId = sId;
			
			$.ajax({
			    type: "GET",
			    url: "../requirements/RequirementUtil.jsp?mode=createReqSpecsDerivationLink&reqSpecSourceId=" + reqSpecSourceId + "&reqSpecTargetIds=" + reqSpecTargetId + "&derivationMode=" + derivationMode +
			        "&" + csrfParams,
			    dataType: "text",
			    cache: true,
			    success: function(txt) {
			        var newpostDataXML = emxUICore.createXMLDOM();
			        newpostDataXML.loadXML(txt);
			        emxUICore.checkDOMError(newpostDataXML);
			    }
			});
			
			//We need to remove the selected node ... 
			sNode.remove();
			var nodeToRemove = $(warningTree).dynatree("getTree").getNodeByKey(reqSpecTargetId);
			
			if(nodeToRemove != null)
				nodeToRemove.remove();
			
			var seNode 		= selectedMainTreeNodes[0];
			
		}
		
		independentReqSpecCount = independentReqSpecCount - selectedWarningTreeReqSpecNodes.length;
		
		if(independentReqSpecCount == 0)
		{				
			$("#consistencyTabs").tabs("option", "active", Math.abs(tab.index()-1));			
			$("#consistencyTabs").tabs("option", "active", Math.abs(tab.index()-1));
		}

	}
	else
	{
		alert("Please select atleast 1 Requirement Specification!");
	}
	
}

/*
 * Checks if a node in Dynatree is Derived Req-Spec
*/ 
function isNodeDerivedReqSpec()
{
	var isSelectionOK = true;
	//we verify that all objects selected are derived requirement
	for(var n=0; n < selectedNodes.length; n++)
	{
		var isRootReqSpec = selectedNodes[n].data['isDerived'];
		if(isRootReqSpec == null || isRootReqSpec == 'false')
		{
			isSelectionOK = false;
		}
	}
	return isSelectionOK;
}

/*
 * Places DynaTree inside Floating Div.
*/ 
function finishCheckConsistencyDlgConstruction(containerId)
{

	var derivContainerWidth =  $("#checkConsistencyDialog").width() - $("#treeCoveredRequirement").width();
	var derivContainer =  '<div id="checkConsistencyContainer" style = "float:left;height:460px;width:'+ derivContainerWidth + 'px;background:rgba(255,0,0,0);">'+
	'<div id="checkConsistencySubContainer" style="height:200px;width:99999999999px;"></div>'+
	'</div>';
	
	$(containerId).append(derivContainer);
		
	// makes the source resizable horizontal only
	$("#treeCoveredRequirement").resizable({
		handles: 'e,w',
		resize: function(event,ui){
			var derivContainerWidth = $("#checkConsistencyDialog").width() - ui.size.width - 40;
			$("#checkConsistencyContainer").css('width',derivContainerWidth);
			
		}
		}
	);
	
	//Display legend as accordion
	$("#checkConsistencyLegend").accordion({
		collapsible:true,
		header: "h3",
		heightStyle: "content",
		active:false
	});
	
	$(".ui-accordion-content").css("height","auto");
	$(".ui-accordion-header").find(".ui-icon").css("float","left");	
}

/*
 * Creates Listener for Main Covered Dyna  Tree.
*/ 
function goDynaMainCoveredTree(treeCoveredRequirement, rootReqSpecId)
{
	var c = $("#dCanvas");
	ctx = c[0].getContext('2d');

	//Initialize Dynatree
	$(treeCoveredRequirement).dynatree({
		imagePath: '../common/',
		debugLevel: 2,
		checkbox:true,
		selectMode:1,
		onLazyRead: function(dtnode){
				toggleDynatree(dtnode , "covered", treeCoveredRequirement, rootReqSpecId);
		},
		onExpand: function(flag, dtnode){
		},
		onCreate: function(dtnode,nodeSpan){
			bindContextMenu(nodeSpan,treeCoveredRequirement);
	
		},
		
		onSelect: function(flag, node) {
			if(flag)
			{	
				document.getElementById("requirementNameErrorAlert").innerHTML = node.data['objectNameValue'];
				document.getElementById("requirementNameWarningAlert").innerHTML = node.data['objectNameValue'];
				
				var mainTree        = $("div[id^='treeCoveredRequirement']");
				var warningTree     = $("div[id^='treeCoveredInConsistency']");
				
				document.getElementById("reqSpecNameErrorAlert").innerHTML   = $(mainTree).dynatree("getRoot").childList[0].data['objectNameValue'];
				document.getElementById("reqSpecNameWarningAlert").innerHTML = $(mainTree).dynatree("getRoot").childList[0].data['objectNameValue'];

	        	var selectedNodeObjId = getObjectIdfromKey(node.data['key']);
				var nodeStatus = node.data['warningOrError'];
				var treeCoveredInConsistency = "#treeCoveredInConsistency";
				
				//Handling nodes with error and warning. 
				if(nodeStatus == "error" || nodeStatus == "warning")
				{
					if(nodeStatus == "error")
					{
	    

						$(function() {
							 $( "#solveErrorInConsistencyDiv" ).dialog({
							          autoOpen: false,
								      resizable: false,
								      height: 200,
								      width: 600,
								      modal: true,
								      buttons:{
								    	  ConsistencyDlgSolveButton:
								    	  {
								    		  click: function() 
								          {
									        	$( this ).dialog( "close" );

									        	//disabling the "Create Link" Button and enabling the "Delete Link"
									        	$(".ui-dialog-buttonpane button:contains('"+ CreateLinkButton +"')").button('disable');
									        	$(".ui-dialog-buttonpane button:contains('"+ DeleteLinkButton +"')").button('enable');
									        	
								        	    $("#treeCoveredInConsistency").empty();
								        	 	$("#treeCoveredInConsistency").hide();
								        	 	$("#coveredRequirementContainer").append(warningTree);
								        	 	$("#treeCoveredInConsistency").show();
									        									        	 	
									        	goCoveredCheckConsistencyTree("#treeCoveredInConsistency", "coveredReqError", selectedNodeObjId, rootReqSpecId);
							                	$("#treeCoveredInConsistency").css({"margin-top" : "-600px"});
							                	constructCoveredErrorInConsistencyTree("#treeCoveredInConsistency", selectedNodeObjId, 'no', rootReqSpecId);
							                	
											},
											   text:ConsistencyDlgSolveButton
								    	   },
								    	  
								    	   ConsistencyDlgCancelButton:
								    	   {
								    		   click: function() {
								          $( this ).dialog( "close" );
								          	$("#treeCoveredInConsistency").empty();
							        	 	$("#treeCoveredInConsistency").hide();
								           }, 
								           text:ConsistencyDlgCancelButton
								        }
								      }
								    });
							 $( "#solveErrorInConsistencyDiv" ).dialog('open');
						 });

					}
					else if(nodeStatus == "warning")
					{
						$(function() {
							 $( "#solveWarningInConsistencyDiv" ).dialog({
								      autoOpen: false,
								      resizable: false,
								      height: 200,
								      width: 600,
								      modal: true,
								      buttons: 
								      {
								    	  ConsistencyDlgSolveButton:
								    	  {
								    		  click: function()
								          {
									        	$( this ).dialog( "close" );
									        	
									        	//enabling the "Create Link(s)" and "Delete Link" Button.
									        	$(".ui-dialog-buttonpane button:contains('"+ CreateLinkButton +"')").button('enable');
									        	$(".ui-dialog-buttonpane button:contains('"+ DeleteLinkButton +"')").button('enable');

									        										        	
								        	    $("#treeCoveredInConsistency").empty();
								        	 	$("#treeCoveredInConsistency").hide();
								        	 	$("#coveredRequirementContainer").append(warningTree);
								        	 	$("#treeCoveredInConsistency").show();
								        	 	
									        	goCoveredCheckConsistencyTree("#treeCoveredInConsistency", "coveredReqWarning", selectedNodeObjId, rootReqSpecId);
							                	$("#treeCoveredInConsistency").css({"margin-top" : "-600px"});
							                	constructCoveredWarningInConsistencyTree("#treeCoveredInConsistency", selectedNodeObjId, rootReqSpecId, 'no'); //adding rootReqSpecId to find allDependent reqSpecs.

											},
								    		  text: ConsistencyDlgSolveButton
								    	   },
								    	   ConsistencyDlgCancelButton:
								    	   {
								    		   click: function()
								    		   {
								          $( this ).dialog( "close" );
							        	    $("#treeCoveredInConsistency").empty();
							        	 	$("#treeCoveredInConsistency").hide();
								    			},
								    			text: ConsistencyDlgCancelButton
								        }
								      }
								    });
							 $( "#solveWarningInConsistencyDiv" ).dialog('open');
						 });
						
					}
				}
			}
			else
			{
	        	//disabling the "Create Link(s)" and "Delete Link" Button.
	        	$(".ui-dialog-buttonpane button:contains('"+ CreateLinkButton +"')").button('disable');
	        	$(".ui-dialog-buttonpane button:contains('"+ DeleteLinkButton +"')").button('disable');
	        	
        	    $("#treeCoveredInConsistency").empty();
        	 	$("#treeCoveredInConsistency").hide();
      
			}
            
        },
		
/*        onActivate: function(node) {
            if( node.data.url )
                window.open(node.data.url);
            alert("node.data.title - " + node.data.title);
        },
        onDeactivate: function(node) {
            //$("#echoActive").text("-");
        },*/
		
		onRender: function(dtnode,nodeSpan)
		{
			
			var objectId	= getObjectIdfromKey(dtnode.data['key']);
			var objectColor = dtnode.data['legend'];
			
			var objectWarningOrError = dtnode.data['warningOrError'];
			
			//add color code
			var legend  = null;
			var status  = null;
			if(dtnode.data['kindOf'] == "Requirement"){
				
				switch(objectColor){
					case "yellow" : 
						legend = '<img class="rmtLegend" src="../requirements/images/legendCoveredReq.gif"alt style="height:12px;width:4px;margin-left:2px;margin-top:2px">';
						break;
					case "fushia" :
						legend = '<img class="rmtLegend" src="../requirements/images/legendSatisfiedReq.gif"alt style="height:12px;width:4px;margin-left:2px;margin-top:2px">';
						break;
					case "cyan"   : 
						legend = '<img class="rmtLegend" src="../requirements/images/legendSubReq.gif"alt style="height:12px;width:4px;margin-left:2px;margin-top:2px">';
						break;
					default		  :
						legend = null;
				}
				
				switch(objectWarningOrError){
				case "error" : 
				    status = '<img class="rmtStatus" src="../requirements/images/iconReqInfoTypeConsistencyValueError.png"alt >';
					break;
				case "warning" :
				    status = '<img class="rmtStatus" src="../requirements/images/iconReqInfoTypeConsistencyValueWarning.png"alt >';
					break;
				default		  :
					status = null;
				}
				
				/*if(legend != null){
					//insert legend before iconReq img
					$(nodeSpan).find("img[src*=iconReq]").before(legend);
				}*/
				
				if(status != null){
					//insert status before iconReq img
					$(nodeSpan).find("img[src*=iconReq]").before(status);
				}
			}
		}
	});

}

 
/*
 *  Creates Listener for inConsistency Dyna tree for covered/Refined requirements with errors or warning.
*/ 
function goCoveredCheckConsistencyTree(treeCoveredConsistency, coveredInConsistency, selectedNodeObjId, rootReqSpecId)
{
	var c = $("#dCanvas");
	ctx = c[0].getContext('2d');
	
	//Initialize Dynatree
	$(treeCoveredConsistency).dynatree({
		imagePath: '../common/',
		debugLevel: 2,
		selectMode:2,
		checkbox:true,
		onLazyRead: function( dtnode ){
				if(coveredInConsistency == "coveredReqWarning")
				{
					toggleCoveredWarningInConsistencyDT(dtnode, treeCoveredConsistency, selectedNodeObjId);
				}
				else if(coveredInConsistency == "coveredReqError")
				{
					toggleCoveredErrorInConsistencyDT(dtnode, treeCoveredConsistency, selectedNodeObjId, rootReqSpecId);
				}
		},
		onExpand: function(flag, dtnode){
			
		},
		onCreate: function(dtnode,nodeSpan){
			bindContextMenu(nodeSpan, treeCoveredConsistency);

		},
		onRender: function(dtnode,nodeSpan)
		{
			
			var objectId	= getObjectIdfromKey(dtnode.data['key']);
			var objectColor = dtnode.data['legend'];
			
			var objectWarningOrError = dtnode.data['warningOrError'];
			var status  = null;
			
			//add color code
			var legend  = null;
			if(dtnode.data['kindOf'] == "Requirement"){
				switch(objectColor){
					case "yellow" : 
						legend = '<img class="rmtLegend" src="../requirements/images/legendCoveredReq.gif"alt style="height:12px;width:4px;margin-left:2px;margin-top:2px">';
						break;
					case "fushia" :
						legend = '<img class="rmtLegend" src="../requirements/images/legendSatisfiedReq.gif"alt style="height:12px;width:4px;margin-left:2px;margin-top:2px">';
						break;
					case "cyan"   : 
						legend = '<img class="rmtLegend" src="../requirements/images/legendSubReq.gif"alt style="height:12px;width:4px;margin-left:2px;margin-top:2px">';
						break;
					default		  :
						legend = null;
				}
				
				switch(objectWarningOrError){
				case "error" : 
					status = '<img class="rmtLegend" src="../requirements/images/iconReqInfoTypeConsistencyValueError.png"alt style="height:16px;width:16px;margin-left:2px;padding:1px">';
					break;
				case "warning" :
				    status = '<img class="rmtLegend" src="../requirements/images/iconReqInfoTypeConsistencyValueWarning.png"alt style="height:16px;width:16px;margin-left:2px;padding:1px">';
					break;
				default		  :
					status = null;
				}
				
				/*if(legend != null){
					//insert legend before iconReq img
					$(nodeSpan).find("img[src*=iconReq]").before(legend);
				}*/
				
				if(status != null){
					//insert status before iconReq img
					$(nodeSpan).find("img[src*=iconReq]").before(status);
				}
				
			}
		}

	});
	$(treeCoveredConsistency).dynatree("getTree").reload();
}


/*
 *  Expand/Collapse Error inconsistency Dyna Tree
*/ 
function toggleCoveredErrorInConsistencyDT(dtnode, treeCoveredConsistency, selectedNodeObjId, rootReqSpecId)
{
	var rows = listChildNodeCoveredError;
	var nextNodeIndex = parseInt(dtnode.data['indexInTree']);
	
	if(rows[nextNodeIndex].getAttribute('o') != selectedNodeObjId)
	{
		var i = nextNodeIndex + 1;
		
		var objectId 		= rows[i].getAttribute('o');
		var objectRelId		= rows[i].getAttribute('r');
		var objectParentId	= rows[i].getAttribute('p');
		var objectName 		= rows[i].getAttribute('name');
		
		//HAT1 ZUD HL IR-364298-3DEXPERIENCER2016x- FUN048478:Preference under Tree display option are not getting applied. 
		objectName = getTreeDisplay(rows[i]);
		
		//for displaying in solve alert message
		var objectNameValue = rows[i].getAttribute('name');
		
		var objectTitle		= rows[i].getAttribute('title');
		var objectRevision  = rows[i].getAttribute('revision');
		
		objectName 			= objectName.replace("%26","&");
		objectName			= objectName.replace("%3C","<");
		objectName			= objectName.replace("%3E",">");
		objectName 			= jQuery('<div />').text(objectName).html(); 
		var objectImage 	= rows[i].getAttribute('icon');
		var sKindOf			= rows[i].getAttribute('kindOf');
		sDerived 			= rows[i].getAttribute('isDerived');
		var objectColor     = rows[i].getAttribute('colorCode');
		
		// HAT1 ZUD HL Requirement Specification Dependency
		var objWarningOrError = rows[i].getAttribute('warningOrError');
		var indexInTree     = rows[i].getAttribute('indexInTree');
		
		var sLazy			= true;
		var objectKey		= objectId + "|" + objectRelId + "|"+objectParentId;
		
		var objectCText		= String(rows[i].getAttribute('contentText'));

		if(objectTitle =="")
			objectTitle = "-";
		if(objectCText == "")
			objectCText = "-";
		
		//var objectTooltip			= "Title : " + objectTitle +"\n Revision : " + objectRevision +"\n Content Text: "+objectCText+"";
		// HAT1 ZUD IR-531749-3DEXPERIENCER2018x fix
		var	objectTooltip 	=  strTitle + " : " + objectTitle;
			objectTooltip 	+= "\n"  + strRevision + " : " + objectRevision;
			objectTooltip 	+= "\n"  + strContent_Text + " : " + objectCText;
		
		if(sDerived == "true")
			sLazy = false;
				
		dtnode.addChild({
		        key: objectKey,
		        title: objectName,
		        tooltip: objectTooltip,
	            //expand: objectExpand,
		        isLazy: sLazy,
		        icon: objectImage,
		        isDerived: sDerived,
		        legend: objectColor,
		        kindOf: sKindOf,
		        warningOrError: objWarningOrError,
		        indexInTree: indexInTree,
		        hideCheckbox: true,
		        objectNameValue: objectNameValue,
		        
		        
		 });
	}

	dtnode.setLazyNodeStatus(DTNodeStatus_Ok);
}

/*
 *  Creates inConsistency Dyna tree for covered/Refined requirements with errors .
*/ 
function constructCoveredErrorInConsistencyTree(tree, objectId ,isCovered, rootReqSpecId)
{
	var rootMasterNodeDyna;
	
	rootMasterNodeDyna = $(tree).dynatree("getRoot");
	var nodeStack = new Stack();
	var isVirtualRoot = true;
	nodeStack.push(rootMasterNodeDyna); // The virtual root for the moment*/

	
	// get the rows
	var dataXML 		= emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=errorInconsistency&strObjID="+objectId+"&rootReqSpecId="+rootReqSpecId+"&nodeStatus=error");
	var rows 			= $(dataXML).find("r");

	for(var i = -1; i < rows.length-1; i++)
	{
		        //Saving all the rows
			    listChildNodeCoveredError[i+1] = rows[i+1];

				//last element(root element i.e. Requirement Specification) 
				var flagRootNode = false;
				var hideCheckboxValue = true;
				var hideCheckbox = hideCheckboxValue;
				if(i == -1)
				{
					i = rows.length-1;
					flagRootNode      = true;
					hideCheckboxValue = false;
				}
				
				//Adding only those node which are 
				if(parseInt(rows[i].getAttribute('level')) == 1 || parseInt(rows[i].getAttribute('level')) == 0)
				{							
					var objectId 		= rows[i].getAttribute('o');
					var objectRelId		= rows[i].getAttribute('r');
					var objectParentId	= rows[i].getAttribute('p');
					var objectName 		= rows[i].getAttribute('name');
					var objectTitle		= rows[i].getAttribute('title');
					var objectRevision  = rows[i].getAttribute('revision');
					
					//HAT1 ZUD HL IR-364298-3DEXPERIENCER2016x- FUN048478:Preference under Tree display option are not getting applied. 
					objectName = getTreeDisplay(rows[i]);
			        
					//for displaying in solve alert message
					var objectNameValue = rows[i].getAttribute('name');
					
					
					objectName			= objectName.replace("%26","&");
					objectName			= objectName.replace("%3C","<");
					objectName			= objectName.replace("%3E",">");
					objectName 			= jQuery('<div />').text(objectName).html(); 
					var objectImage 	= rows[i].getAttribute('icon');
					var sKindOf			= rows[i].getAttribute('kindOf');
					//var objectExpand 	= false;
					var oldLevel 		= 1;
					var currentLevel 	= parseInt(rows[i].getAttribute('level'));
					var sDerived 		= "false";
					var objectColor     = rows[i].getAttribute('colorCode');
					
					// HAT1 ZUD HL Requirement Specification Dependency
					var objWarningOrError = rows[i].getAttribute('warningOrError');
					var indexInTree     = rows[i].getAttribute('indexInTree');
					
					var objectKey		= objectId+ "|" + objectRelId + "|" + objectParentId;
					var isExpandedAll   = "N/A";

					var objectCText		= String(rows[i].getAttribute('contentText'));
					var objectExpand = false;
					
					if(objectTitle =="")
						objectTitle = "-";
					if(objectCText == "")
						objectCText = "-";
					
					//var objectTooltip			= "Title : " + objectTitle +"\n Revision : " + objectRevision +"\n Content Text: "+objectCText+"";
					// HAT1 ZUD IR-531749-3DEXPERIENCER2018x fix
					var	objectTooltip 	=  strTitle + " : " + objectTitle;
						objectTooltip 	+= "\n"  + strRevision + " : " + objectRevision;
						objectTooltip 	+= "\n"  + strContent_Text + " : " + objectCText;
					
					var nodeToAttach = null;
					var attachedNode = null;
		
					//Pre-Process - Root case
					if (currentLevel == 0) {
			            // We can remove the virtual root, and set the real one
			            if (isVirtualRoot) { 
			                nodeToAttach = nodeStack.pop(); 
			                isVirtualRoot = false;
		
			            }
			            objectExpand = true;
			            isExpandedAll = "false";
					}else if (currentLevel <= oldLevel) {
			            nodeToAttach = nodeStack.getRoot();
			            sDerived = rows[i].getAttribute('isDerived');
			            
			        }else if (currentLevel > oldLevel) {
			            nodeToAttach = nodeStack.getLast();
			            sDerived = rows[i].getAttribute('isDerived');
			            
			        }
					// We can now create the new child, and attach it to the current root
					var sLazy			= true;
					if(sDerived == "true")
						sLazy = false;
	
						attachedNode = nodeToAttach.addChild({
			            key: objectKey,
			            title: objectName,
			            tooltip: objectTooltip,
			            isLazy: sLazy,
			            icon: objectImage,
			            isDerived: sDerived,
			            legend : objectColor,
			            expand: objectExpand,
			            isExpandedAll : isExpandedAll,
			            kindOf:sKindOf,
				        warningOrError: objWarningOrError,
				        hideCheckbox: hideCheckboxValue,
				        indexInTree: indexInTree,
				        objectNameValue: objectNameValue,
				        
						});
						
						objectExpand = true;
					
			        // Post-process - Root case
			        if (currentLevel == 0) {
			            nodeStack.push(attachedNode);
			        } else if (currentLevel <= oldLevel) {
			            nodeStack.push(attachedNode);
			        } else if (currentLevel > oldLevel) {
			            nodeStack.push(attachedNode);
			            oldLevel = currentLevel;
			        }
			        
			        //resetting the value of i to 0
			        if(flagRootNode == true)
		        	{
			        	i = -1;
		        	}
			}
		}
}


 
/*
 *  Expand/Collapse Warning inconsistency Dyna Tree
*/ 
function toggleCoveredWarningInConsistencyDT(dtnode, treeCoveredConsistency, selectedNodeObjId)
{
	var rows = listChildNodeCoveredWarning;
	
	for(var i=0; i < rows.length-1; i++)
	{
		var hideCheckboxValue = true;
		
		if(rows[i].getAttribute('o') == getObjectIdfromKey(dtnode.data['key']))
		{
			if((i == 0))
			{
				i = rows.length-1;
			}
			else if(rows[i-1].getAttribute('type') == "Requirement Specification")
			{
				i = rows.length-1;
			}
			else
			{
				i--;
			}
			
			var objectId 		= rows[i].getAttribute('o');
			var objectRelId		= rows[i].getAttribute('r');
			var objectParentId	= rows[i].getAttribute('p');
			var objectName 		= rows[i].getAttribute('name');
			var objectTitle		= rows[i].getAttribute('title');
			var objectRevision  = rows[i].getAttribute('revision');
			
			//HAT1 ZUD HL IR-364298-3DEXPERIENCER2016x- FUN048478:Preference under Tree display option are not getting applied. 
			objectName = getTreeDisplay(rows[i]);
			
			//for displaying in solve alert message
			var objectNameValue = rows[i].getAttribute('name');
			
			objectName 			= objectName.replace("%26","&");
			objectName			= objectName.replace("%3C","<");
			objectName			= objectName.replace("%3E",">");
			objectName 			= jQuery('<div />').text(objectName).html(); 
			var objectImage 	= rows[i].getAttribute('icon');
			var sKindOf			= rows[i].getAttribute('kindOf');
			sDerived 			= rows[i].getAttribute('isDerived');
			var objectColor     = rows[i].getAttribute('colorCode');
			// HAT1 ZUD HL Requirement Specification Dependency
			var objWarningOrError = rows[i].getAttribute('warningOrError');

			var sLazy			= true;
			var objectKey		= objectId + "|" + objectRelId + "|"+objectParentId;
			
			var objectCText		= String(rows[i].getAttribute('contentText'));

			if(objectTitle =="")
				objectTitle = "-";
			if(objectCText == "")
				objectCText = "-";
			
			//var objectTooltip			= "Title : " + objectTitle +"\n Revision : " + objectRevision +"\n Content Text: "+objectCText+"";
			// HAT1 ZUD IR-531749-3DEXPERIENCER2018x fix
			var	objectTooltip 	=  strTitle + " : " + objectTitle;
				objectTooltip 	+= "\n"  + strRevision + " : " + objectRevision;
				objectTooltip 	+= "\n"  + strContent_Text + " : " + objectCText;
			
			if(sDerived == "true")
				sLazy = false;
					
			dtnode.addChild({
			        key: objectKey,
			        title: objectName,
			        tooltip: objectTooltip,
		            //expand: objectExpand,
			        isLazy: sLazy,
			        icon: objectImage,
			        isDerived: sDerived,
			        legend: objectColor,
			        kindOf: sKindOf,
			        warningOrError: objWarningOrError,
			        hideCheckbox: hideCheckboxValue,
			        objectNameValue: objectNameValue,

			 });
			
			i++;
			break;
			
		}
		//hideCheckbox = true;
	}
	dtnode.setLazyNodeStatus(DTNodeStatus_Ok);
}

  
/*
 *  Creates inConsistency Dyna tree for covered/Refined requirements with  warning.
*/ 
function constructCoveredWarningInConsistencyTree(tree, objectId, rootReqSpecId, isCovered)
{
	
	var rootMasterNodeDyna;
	rootMasterNodeDyna = $(tree).dynatree("getRoot");
	var nodeStack = new Stack();
	var isVirtualRoot = true;
	nodeStack.push(rootMasterNodeDyna); // The virtual root for the moment*/
	
	// get the rows
	var dataXML 		= emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=warningInconsistency&strObjID="+objectId+ "&rootReqSpecId=" + rootReqSpecId + "&nodeStatus=warning");
	var rows 			= $(dataXML).find("r");

    // Reinitializing the count of non-dependent Req-Spec
	independentReqSpecCount = 0;
	for(var i = 0; i < rows.length; i++)
	{		
		if(rows[i].getAttribute('type') == "Requirement Specification")
		{
			independentReqSpecCount ++; //counting the independent reqspecs
			var objectId 		= rows[i].getAttribute('o');
			var objectRelId		= rows[i].getAttribute('r');
			var objectParentId	= rows[i].getAttribute('p');
			var objectName 		= rows[i].getAttribute('name');
			var objectTitle		= rows[i].getAttribute('title');
			var objectRevision  = rows[i].getAttribute('revision');
			
			//HAT1 ZUD HL IR-364298-3DEXPERIENCER2016x- FUN048478:Preference under Tree display option are not getting applied. 
			objectName = getTreeDisplay(rows[i]);
			
			//for displaying in solve alert message
			var objectNameValue = rows[i].getAttribute('name');
			
			objectName			= objectName.replace("%26","&");
			objectName			= objectName.replace("%3C","<");
			objectName			= objectName.replace("%3E",">");
			objectName 			= jQuery('<div />').text(objectName).html(); 
			var objectImage 	= rows[i].getAttribute('icon');
			var sKindOf			= rows[i].getAttribute('kindOf');
			var objectExpand 	= false;
			var oldLevel 		= 1;
			var currentLevel 	= parseInt(rows[i].getAttribute('level'));
			
			
			var sDerived 		= "false";
			var objectColor     = rows[i].getAttribute('colorCode');
			
			// HAT1 ZUD HL Requirement Specification Dependency
			var objWarningOrError = rows[i].getAttribute('warningOrError');
	
			var objectKey		= objectId+ "|" + objectRelId + "|" + objectParentId;
			var isExpandedAll   = "N/A";

			var objectCText		= String(rows[i].getAttribute('contentText'));
	
			if(objectTitle =="")
				objectTitle = "-";
			if(objectCText == "")
				objectCText = "-";
			
			//var objectTooltip			= "Title : " + objectTitle +"\n Revision : " + objectRevision +"\n Content Text: "+objectCText+"";
			// HAT1 ZUD IR-531749-3DEXPERIENCER2018x fix
			var	objectTooltip 	=  strTitle + " : " + objectTitle;
				objectTooltip 	+= "\n"  + strRevision + " : " + objectRevision;
				objectTooltip 	+= "\n"  + strContent_Text + " : " + objectCText;
			
			var nodeToAttach = null;
			var attachedNode = null;
	
			//Pre-Process - Root case
			if (currentLevel == 0) {
	            // We can remove the virtual root, and set the real one
	            if (isVirtualRoot) { 
	                nodeToAttach = nodeStack.pop(); 
	                isVirtualRoot = false;
	
	            }
	            objectExpand = true;
	            isExpandedAll = "false";
			}else if (currentLevel <= oldLevel) {
	            nodeToAttach = nodeStack.getRoot();
	            sDerived = rows[i].getAttribute('isDerived');
	            
	        }else if (currentLevel > oldLevel) {
	            nodeToAttach = nodeStack.getLast();
	            sDerived = rows[i].getAttribute('isDerived');
	            
	        }
			// We can now create the new child, and attach it to the current root
			var sLazy			= true;
			if(sDerived == "true")
				sLazy = false;
	        attachedNode = nodeToAttach.addChild({
	            key: objectKey,
	            title: objectName,
	            tooltip: objectTooltip,
	            isLazy: sLazy,
	            icon: objectImage,
	            expand: objectExpand,
	            isDerived: sDerived,
	            legend : objectColor,
	            isExpandedAll : isExpandedAll,
	            kindOf:sKindOf,
		        warningOrError: objWarningOrError,
		        hideCheckbox: false,
		        objectNameValue: objectNameValue,
	          });
	        
	        objectExpand = true;
	       
	        
	        // Post-process - Root case
	        if (currentLevel == 0) {
	            nodeStack.push(attachedNode);
	        } else if (currentLevel <= oldLevel) {
	            nodeStack.push(attachedNode);
	        } else if (currentLevel > oldLevel) {
	            nodeStack.push(attachedNode);
	            oldLevel = currentLevel;
	        }
		 }
			
			var childNodeIndex 		= parseInt(rows[i].getAttribute('childNodeIndex'));
			listChildNodeCoveredWarning[childNodeIndex] = rows[i];
	}
	
}

// -- Check consistency tree for covered requirements with errors or warning. 


 
/*
 *  Expand/Collapse Main Refined/Covered Dyna Tree.
*/ 
function toggleDynatree(dtnode , treeMode , tree, rootReqSpecId)
{
	var strCheckConsistencyMode 		= "checkConsistency";
	var strTreeMode 					= treeMode;
	var objectIdRoot 					= getObjectIdfromKey(dtnode.data['key']);
	//We check if the selected object is expandable
	var sDerived 			= dtnode.data['isDerived'];
	
	if(sDerived == 'false')
	{
		// get the rows
		var dataXML = emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=expandStructure&strObjID="+objectIdRoot+"&strCheckConsistencyMode="+strCheckConsistencyMode+"&strTreeMode="+strTreeMode+"&rootReqSpecId="+rootReqSpecId+"&strExpandLevel=1");
		var rows 	= $(dataXML).find("r");
		
		
		// we exclude the root node
		for(var i=1; i < rows.length;i++)
		{
			var hideCheckboxValue = true;
			var objectId 		= rows[i].getAttribute('o');
			var objectRelId		= rows[i].getAttribute('r');
			var objectParentId	= rows[i].getAttribute('p');
			var objectName 		= rows[i].getAttribute('name');
			var objectTitle		= rows[i].getAttribute('title');
			objectTitle			= decodeSpecialCharAsHTML(objectTitle);
			var objectRevision  = rows[i].getAttribute('revision');
			
			//HAT1 ZUD HL IR-364298-3DEXPERIENCER2016x- FUN048478:Preference under Tree display option are not getting applied. 
			objectName = getTreeDisplay(rows[i]);
			
			//for displaying in solve alert message
			var objectNameValue = rows[i].getAttribute('name');
			
			objectName			= decodeSpecialCharAsHTML(objectName);
			objectName 			= jQuery('<div />').text(objectName).html(); 
			var objectImage 	= rows[i].getAttribute('icon');
			var sKindOf			= rows[i].getAttribute('kindOf');
			sDerived 			= rows[i].getAttribute('isDerived');
			var objectColor     = rows[i].getAttribute('colorCode');
			
			// HAT1 ZUD HL Requirement Specification Dependency
			var objWarningOrError = rows[i].getAttribute('warningOrError');

			var sLazy			= true;
			var objectKey		= objectId + "|" + objectRelId + "|"+objectParentId;
			
			var objectCText		= String(rows[i].getAttribute('contentText'));

			if(objectTitle =="")
				objectTitle = "-";
			if(objectCText == "")
				objectCText = "-";
			
			//var objectTooltip			= "Title : " + objectTitle +"\n Revision : " + objectRevision +"\n Content Text: "+objectCText+"";
			// HAT1 ZUD IR-531749-3DEXPERIENCER2018x fix
			var	objectTooltip 	=  strTitle + " : " + objectTitle;
				objectTooltip 	+= "\n"  + strRevision + " : " + objectRevision;
				objectTooltip 	+= "\n"  + strContent_Text + " : " + objectCText;

			
			if(objWarningOrError == "warning" || objWarningOrError == "error")
			{
				hideCheckboxValue = false;
			}
			
			if(sDerived == "true")
				sLazy = false;
					
			dtnode.addChild({
			        key: objectKey,
			        title: objectName,
			        tooltip: objectTooltip,
			        isLazy: sLazy,
			        icon: objectImage,
			        isDerived: sDerived,
			        legend: objectColor,
			        kindOf: sKindOf,
			        warningOrError: objWarningOrError,
			        hideCheckbox: hideCheckboxValue,
			        objectNameValue: objectNameValue,

			 });
			
		}
	}

	dtnode.setLazyNodeStatus(DTNodeStatus_Ok);

}

/*
 *  Expand Collapse All Nodes of All Dyna Tree To be implemented
*/ 
function bindContextMenu(span, tree)
{
	//Add Context menu to this node
	$(span).contextMenu({menu : "derivMenu"}, function(action, el, pos){
		
		switch(action){
		case "expandAll" :
			//ExpandCollapseAll(action, tree);
		break;
		case "collapseAll":
			//ExpandCollapseAll(action, tree);
		break;
		default:
			alert("no action !");
		}
	});
}

/*
 *  Create Main Refined/Covered dyna tree.
*/ 

var strTreeMode = "";
var derivationMode = "";

function construcFirstCheckConsistencyTree(tree, objectId ,isCovered)
{
	var rootMasterNodeDyna;
	rootMasterNodeDyna = $(tree).dynatree("getRoot");
	var nodeStack = new Stack();
	var Level_Node_Stack = new Stack();
	 
	var isVirtualRoot = true;
	nodeStack.push(rootMasterNodeDyna); // The virtual root for the moment*/
	
	// get the rows
	var strCheckConsistencyMode = "checkConsistency";
	var strTreeMode = "";
	if(isCovered == "yes")
	{
		strTreeMode = "covered";
		derivationMode = "cover";
	}
	else
	{
		derivationMode = "refine";
		strTreeMode = "refined";
	}
		
	var errorCount   = "0";
	var warningCount = "0";
	
	var rootSeqOrder 	= "";
	var rootType	 	= "";

	var rootReqSpecId = "empty"; //ChkConsistency
	
	var dataXML 		= emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=expandStructureChkConsistency&strObjID="+objectId+"&strCheckConsistencyMode="+strCheckConsistencyMode+"&strTreeMode=" + strTreeMode+ "&rootReqSpecId=" + rootReqSpecId + "&strExpandLevel=2"); //"&rootReqSpecId=" + rootReqSpecId +
	var rows 			= $(dataXML).find("r");
	

	for(var i = 0; i < rows.length; i++)
	{		
		var objectId 		= rows[i].getAttribute('o');
		var objectRelId		= rows[i].getAttribute('r');
		var objectParentId	= rows[i].getAttribute('p');
		var objectName 		= rows[i].getAttribute('name');
		var objectTitle		= rows[i].getAttribute('title');
		objectTitle			= decodeSpecialCharAsHTML(objectTitle);
		var objectRevision  = rows[i].getAttribute('revision');
		
		//HAT1 ZUD HL IR-364298-3DEXPERIENCER2016x- FUN048478:Preference under Tree display option are not getting applied. 
		objectName = getTreeDisplay(rows[i]);

		//for displaying in solve alert message
		var objectNameValue = rows[i].getAttribute('name');
		
		objectName			= decodeSpecialCharAsHTML(objectName);
		objectName 			= jQuery('<div />').text(objectName).html(); 
		var objectImage 	= rows[i].getAttribute('icon');
		var sKindOf			= rows[i].getAttribute('kindOf');
		var objectExpand 	= false;
		var oldLevel 		= 1;
		var currentLevel 	= parseInt(rows[i].getAttribute('level'));
		var sDerived 		= "false";
		var objectColor     = rows[i].getAttribute('colorCode');
		
		// HAT1 ZUD HL Requirement Specification Dependency
		var objWarningOrError = rows[i].getAttribute('warningOrError');

		var objectKey		= objectId+ "|" + objectRelId + "|" + objectParentId;
		var isExpandedAll   = "N/A";

		var objectCText		= String(rows[i].getAttribute('contentText'));

		if(objectTitle =="")
			objectTitle = "-";
		if(objectCText == "")
			objectCText = "-";
		
		//var objectTooltip			= "Title : " + objectTitle +"\n Revision : " + objectRevision +"\n Content Text: "+objectCText+"";
		// HAT1 ZUD IR-531749-3DEXPERIENCER2018x fix
		var	objectTooltip 	=  strTitle + " : " + objectTitle;
			objectTooltip 	+= "\n"  + strRevision + " : " + objectRevision;
			objectTooltip 	+= "\n"  + strContent_Text + " : " + objectCText;
		
		var nodeToAttach = null;
		var attachedNode = null;

		//Pre-Process - Root case
		var Last_Level =0;
		//Populating Last_Level with the top node Level value
		if (currentLevel != 0)
			Last_Level = Level_Node_Stack.getLast();
		
		if (currentLevel == 0) {
            // We can remove the virtual root, and set the real one
            if (isVirtualRoot) { 
                nodeToAttach = nodeStack.pop(); 
                isVirtualRoot = false;

            }
            objectExpand = true;
            isExpandedAll = "false";
			}
		//
		else if(Last_Level<currentLevel)
		{
			nodeToAttach = nodeStack.getLast();
		}
		else if(Last_Level >= currentLevel)
		{
				do
				{
					nodeStack.pop();
					Level_Node_Stack.pop();
					Last_Level = Level_Node_Stack.getLast();				
				}
				while(currentLevel <= Last_Level)
				nodeToAttach = nodeStack.getLast();
			
		}
		/*else if (currentLevel <= oldLevel) {
            nodeToAttach = nodeStack.getRoot();
            sDerived = rows[i].getAttribute('isDerived');
            
        }else if (currentLevel > oldLevel) {
            nodeToAttach = nodeStack.getLast();
            sDerived = rows[i].getAttribute('isDerived');
            
        }*/
		// We can now create the new child, and attach it to the current root
		var sLazy			= true;
		var hideCheckboxValue = true;
		sDerived = rows[i].getAttribute('isDerived');
		if(sDerived == "true")
		{
			sLazy = false;
			isExpandedAll = true;
			
			if(objWarningOrError == "warning" || objWarningOrError == "error")
			{
				hideCheckboxValue = false;
			}
			
			errorCount   = rows[i].getAttribute('errorCount');
		    warningCount = rows[i].getAttribute('warningCount');

		}
		
        attachedNode = nodeToAttach.addChild({
            key: objectKey,
            title: objectName,
            tooltip: objectTooltip,
            isLazy: sLazy,
            icon: objectImage,
            expand: true,
            //expand: objectExpand,
            isDerived: sDerived,
            legend : objectColor,
            isExpandedAll : isExpandedAll,
            kindOf:sKindOf,
	        warningOrError: objWarningOrError,
	        hideCheckbox: hideCheckboxValue,
	        objectNameValue: objectNameValue,
          });
        objectExpand = true;
		hideCheckboxValue = true;
        isExpandedAll = "false";
        
        // Post-process - Root case
       /* if (currentLevel == 0) {
            nodeStack.push(attachedNode);
        } else if (currentLevel <= oldLevel) {
            nodeStack.push(attachedNode);
        } else if (currentLevel > oldLevel) {
            nodeStack.push(attachedNode);
            oldLevel = currentLevel;
        }
       */ 
        nodeStack.push(attachedNode);
        Level_Node_Stack.push(currentLevel);
	}
	
	
	if(strTreeMode == "covered")
	{
	    document.getElementById("coverErrorAndWarningCount").innerHTML = '<img class="rmtLegend" src="../requirements/images/iconReqInfoTypeConsistencyValueError.png"alt style="height:16px;width:16px;margin-left:2px;padding:1px">' + errorCount
		   + '<img class="rmtLegend" src="../requirements/images/iconReqInfoTypeConsistencyValueWarning.png"alt style="height:16px;width:16px;margin-left:2px;padding:1px">' + warningCount;
	}
	else
	{
	    document.getElementById("refinedErrorAndWarningCount").innerHTML = '<img class="rmtLegend" src="../requirements/images/iconReqInfoTypeConsistencyValueError.png"alt style="height:16px;width:16px;margin-left:2px;padding:1px">' + errorCount
        + '<img class="rmtLegend" src="../requirements/images/iconReqInfoTypeConsistencyValueWarning.png"alt style="height:16px;width:16px;margin-left:2px;padding:1px">' + warningCount;
	}
}

//++ HAT1 ZUD HL IR-364298-3DEXPERIENCER2016x- FUN048478:Preference under Tree display option are not getting applied. 

function getTreeDisplay(rows)
{
	//var objectId 		= rows[i].getAttribute('o');
	//var objectRelId		= rows[i].getAttribute('r');
	//var objectParentId	= rows[i].getAttribute('p');
	var objectName 		= rows.getAttribute('name');
	var objectTitle		= rows.getAttribute('title');
	var objectRevision  = rows.getAttribute('revision');

	// ++ KIE1 ZUD HL Requirement Specification Dependency
	
	var treeDisplaySettings = rows.getAttribute('treeDisplaySettings');
		
	var itrTreeDisplaySettings = treeDisplaySettings.split("|");

	var isName      = (itrTreeDisplaySettings[0].split("="))[1];
	var isTitle     = (itrTreeDisplaySettings[1].split("="))[1];
	var isRevision  = (itrTreeDisplaySettings[2].split("="))[1];
	var isSeperator = (itrTreeDisplaySettings[3].split("="))[1];
	var titleMaxWidth = (itrTreeDisplaySettings[4].split("="))[1];
	titleMaxWidth = Math.floor(titleMaxWidth);
	
	if(objectTitle.length > titleMaxWidth)
	{
		objectTitle = objectTitle.substring(0, titleMaxWidth);
	}
	
	var seperator = "  ";
	if((isSeperator != "false" || isSeperator != "") && objectTitle.length != 0 && (isName != "false" ||isName != "") && (isTitle != "false" || isTitle != ""))
	{
		seperator = " | ";
	}
	
	if((isName != "false" ||isName != "") && (isTitle != "false" || isTitle != "") && objectTitle.length != 0)
	{
		objectName = objectName + seperator + objectTitle;
	}
	
	if((isName == "false" || isName == "") && (isTitle != "false"||isTitle != "") && objectTitle.length != 0)
	{
		objectName = objectTitle;
	}
	
	if(isRevision != "false" || isRevision != "")
	{
		objectName = objectName + "  " + objectRevision;
	}
	
	if((isName == "false"||isName == "") && (isTitle == "false"||isTitle == "") && (isRevision == "false" || isRevision == "false"))
	{
		objectName = objectTitle + " "+objectRevision;
	}
	return objectName;
}

//-- HAT1 ZUD HL IR-364298-3DEXPERIENCER2016x- FUN048478:Preference under Tree display option are not getting applied. 


/*
 *  Listeners of Main Refined dyna Tree. 
*/ 
function goDynaMainRefinedTree(treeRefinedRequirement, rootReqSpecId)
{	
	var c = $("#dCanvas");
	ctx = c[0].getContext('2d');
	
	//Initialize Dynatree
	$(treeRefinedRequirement).dynatree({
		imagePath: '../common/',
		debugLevel: 2,
		selectMode:1,
		checkbox:true,
		onLazyRead: function( dtnode ){
				toggleDynatree( dtnode, "refined" , treeRefinedRequirement, rootReqSpecId);
		},
		onExpand: function(flag, dtnode){
			
		},
		onCreate: function(dtnode,nodeSpan){
			bindContextMenu(nodeSpan, treeRefinedRequirement);

		},
		
		onSelect: function(flag, node) {
			if(flag)
			{	
				document.getElementById("requirementNameErrorAlert").innerHTML   = node.data['objectNameValue'];
				document.getElementById("requirementNameWarningAlert").innerHTML = node.data['objectNameValue'];

				var mainTree         = $("div[id^='treeRefinedRequirement']");
				var errorWarningTree = $("div[id^='treeRefinedInConsistency']");
				
				document.getElementById("reqSpecNameErrorAlert").innerHTML   = $(mainTree).dynatree("getRoot").childList[0].data['objectNameValue'];
				document.getElementById("reqSpecNameWarningAlert").innerHTML = $(mainTree).dynatree("getRoot").childList[0].data['objectNameValue'];

	        	var selectedNodeObjId = getObjectIdfromKey(node.data['key']);
				var nodeStatus = node.data['warningOrError'];
				var treeCoveredConsistency = "#treeRefinedInConsistency";
				
				//Handling nodes with error and warning. 
				if(nodeStatus == "error" || nodeStatus == "warning")
				{
					if(nodeStatus == "error")
					{
						$(function() {
							 $( "#solveErrorInConsistencyDiv" ).dialog({
								     autoOpen: false,
								      resizable: false,
								      height: 200,
								      width: 600,
								      modal: true,
								     buttons: 
								      {
								    	  ConsistencyDlgSolveButton:
								    	  {
								    		  click: function()
								          {
									        	$( this ).dialog( "close" );
									        	

									        	//disabling the "Create Link" Button and enabling the "Delete Link"
									        	$(".ui-dialog-buttonpane button:contains('"+ CreateLinkButton +"')").button('disable');
									        	$(".ui-dialog-buttonpane button:contains('"+ DeleteLinkButton +"')").button('enable');
									        	
								        	    $("#treeRefinedInConsistency").empty();
								        	 	$("#treeRefinedInConsistency").hide();
								        	 	$("#refinedRequirementContainer").append(errorWarningTree);
								        	 	$("#treeRefinedInConsistency").show();
									        	
									        	
									        	goCoveredCheckConsistencyTree("#treeRefinedInConsistency", "coveredReqError", selectedNodeObjId, rootReqSpecId);
							                	$("#treeRefinedInConsistency").css({"margin-top" : "-300px"});
							                	constructCoveredErrorInConsistencyTree("#treeRefinedInConsistency", selectedNodeObjId, 'no', rootReqSpecId);
								    			}, text: ConsistencyDlgSolveButton
											},
											ConsistencyDlgCancelButton:
											{
												click: function() 
												{
								          $( this ).dialog( "close" );
								          
								        	$(".ui-dialog-buttonpane button:contains('Create Link')").button('disable','false');

								          	$("#treeRefinedInConsistency").empty();
							        	 	$("#treeRefinedInConsistency").hide();
												}, text: ConsistencyDlgCancelButton
								        }
								      }
								    });
							 $( "#solveErrorInConsistencyDiv" ).dialog('open');
						 });
						
						
	
					}
					else if(nodeStatus == "warning")
					{
						$(function() {
							 $( "#solveWarningInConsistencyDiv" ).dialog({	
								      autoOpen:false,
								      resizable: false,
								      height: 200,
								      width: 600,
								      modal: true,
								      buttons: 
								      {
								    	ConsistencyDlgSolveButton:
								    	{
								    		  click: function()
								          {
									        	$( this ).dialog( "close" );
									        	
									        	//enabling the "Create Link(s)" and "Delete Link" Button.
									        	$(".ui-dialog-buttonpane button:contains('"+ CreateLinkButton +"')").button('enable');
									        	$(".ui-dialog-buttonpane button:contains('"+ DeleteLinkButton +"')").button('enable');
									        	
								        	    $("#treeRefinedInConsistency").empty();
								        	 	$("#treeRefinedInConsistency").hide();
								        	 	$("#refinedRequirementContainer").append(errorWarningTree);
								        	 	$("#treeRefinedInConsistency").show();
									        	
									        	goCoveredCheckConsistencyTree("#treeRefinedInConsistency", "coveredReqWarning", selectedNodeObjId, rootReqSpecId);
							                	$("#treeRefinedInConsistency").css({"margin-top" : "-300px"});
								    			  constructCoveredWarningInConsistencyTree("#treeRefinedInConsistency", selectedNodeObjId, rootReqSpecId, 'no'); //adding rootReqSpecId to find allDependent reqSpecs.

											},
								    		  text: ConsistencyDlgSolveButton
								          },
								          
								          ConsistencyDlgCancelButton:
								          {
								        	  click: function() 
								        	  {
								          $( this ).dialog( "close" );
								          	$("#treeRefinedInConsistency").empty();
							        	 	$("#treeRefinedInConsistency").hide();
								        	  },
								        	  text: ConsistencyDlgCancelButton
								        }
								      }
								    });
							 $( "#solveWarningInConsistencyDiv" ).dialog('open');
						 });
						
					}
				}
			}
			else
			{
	        	//disabling the "Create Link(s)" and "Delete Link" Button.
	        	$(".ui-dialog-buttonpane button:contains('"+ CreateLinkButton +"')").button('disable');
	        	$(".ui-dialog-buttonpane button:contains('"+ DeleteLinkButton +"')").button('disable');
	        	
	        	//removing error or warning tree.
        	    $("#treeRefinedInConsistency").empty();
        	 	$("#treeRefinedInConsistency").hide();
			}
        
        },
		
		onRender: function(dtnode,nodeSpan)
		{
			
			var objectId	= getObjectIdfromKey(dtnode.data['key']);
			var objectColor = dtnode.data['legend'];
			
			var objectWarningOrError = dtnode.data['warningOrError'];
			var status  = null;
			
			//add color code
			var legend  = null;
			if(dtnode.data['kindOf'] == "Requirement"){
				switch(objectColor){
					case "yellow" : 
						legend = '<img class="rmtLegend" src="../requirements/images/legendCoveredReq.gif"alt style="height:12px;width:4px;margin-left:2px;margin-top:2px">';
						break;
					case "fushia" :
						legend = '<img class="rmtLegend" src="../requirements/images/legendSatisfiedReq.gif"alt style="height:12px;width:4px;margin-left:2px;margin-top:2px">';
						break;
					case "cyan"   : 
						legend = '<img class="rmtLegend" src="../requirements/images/legendSubReq.gif"alt style="height:12px;width:4px;margin-left:2px;margin-top:2px">';
						break;
					default		  :
						legend = null;
				}
				
				switch(objectWarningOrError){
				case "error" : 
				    status = '<img class="rmtLegend" src="../requirements/images/iconReqInfoTypeConsistencyValueError.png"alt >';
					break;
				case "warning" :
				    status = '<img class="rmtLegend" src="../requirements/images/iconReqInfoTypeConsistencyValueWarning.png"alt >';
					break;
				default		  :
					status = null;
				}
				
				/*if(legend != null){
					//insert legend before iconReq img
					$(nodeSpan).find("img[src*=iconReq]").before(legend);
				}*/
				
				if(status != null){
					//insert legend before iconReq img
					$(nodeSpan).find("img[src*=iconReq]").before(status);
				}
				
			}
		}

	});
	
}

function decodeSpecialCharAsHTML(encoded){
	
	return decodeURIComponent(encoded);
}
