
//=================================================================
// JavaScript DerivationCmd.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
//=================================================================

//@fullreview 	JX5 T94  14:01:31 HL RMT Create Derivation links between Requirements
//@quickreview 	JX5 	 14:06:19 Correct expand all, contextual menu and resize issue 
//@quickreview  JX5      14:08:07 Support of special characters
//@quickreview  LX6      14:08:22 IR-321644-3DEXPERIENCE2015x table does not refresh count of requirements
//@quickreview  JX5      14:08:29 IR-320911-3DEXPERIENCE2015x Deleting derivation link is KO
//@quickreview  JX5      14:08:29 IR-320043-3DEXPERIENCER2015x, IR-320038-3DEXPERIENCER2015x, IR-320035-3DEXPERIENCER2015x
//@quickreview  JX5      14:09:01 IR-319817-3DEXPERIENCER2015x, IR-319809-3DEXPERIENCER2015x
//@quickreview  JX5      14:09:16 In IE10, mouseover event are not fired with on empty part of a div
//@quickreview  JX5      14:10:03 n IE 10, Source or Target section is not resizeable + VNLS: Covers and Refined into pop up winow not translated
//@quickreview  JX5		 14:10:10 IR-333470 There is no tooltip on the objects displayed in the source and targets trees.
//@quickreview  JX5 	 14:11:28 IR-341738 Adding target in "Covers" or "Refined Into" pop up dialogue box is KO after invoking "Requirement Tracability Report" from icon. 
//@quickreview  HAT1 ZUD 14:12:22 HL Requirement Specification Dependency
//@quickreview  JX5      15:01:05 IR-341753 The columns �Covered Requirements� and �Refining Requirements� cells does not get refresh after deletion of "Derivation Links".
//@quickreview  JX5		 15:01:05 IR-337521 On Covers or Refined Requirement form "Delete Derivations Links" button should be deactivated, when no link is there. 
//@quickreview  HAT1 ZUD 15:02:12 HL Requirement Specification Dependency UI changes
//@quickreview  JX5  T94 15:03:18 Adapt to new level of jquery-ui and jquery-dialogextend for TMC project
//@quickreview  JX5      15:04:07 IR-363767 Special Characters in the title field of Requirement Specification make Traceability authoring command KO.
//@quickreview  JX5  T94 15:04:10 Correct dialog events
//@quickreview  JX5	     15:04:17  : IR-366466-3DEXPERIENCER2016x : R418:STP:Expand all on tree display of traceability authoring command window is KO.
//quickreview   HAT1 ZUD 15:04:22  : IR-364298-3DEXPERIENCER2016x- FUN048478:Preference under Tree display option are not getting applied. 
//@quickreview  ZUD HAT1 15:04:23   : IR-364087-3DEXPERIENCER2016x : All target Req spec for existing dependency is not available in the traceability authoring...
//@quickreview  ZUD HAT1 15:05:04 : Relationship direction modification for covered and refined requirements.
//@quickreview  JX5 T94  15:05:20 : IR-370825-3DEXPERIENCER2016x : Create links to cover requirements, it's need to take a long time.
//@quickreview  ZUD HAT1 15:07:15 : IR-364087-3DEXPERIENCER2016x - All target Req spec for existing dependency is not available in the traceability authoring command. 
//@quickreview  HAT1 ZUD 15:07:15 : IR-379612-3DEXPERIENCER2016x - NLS transformation is not getting applied on the Requirement Specification Dependency Pop up.
//@quickreview  JX5      15:07:15 : IR-388644-3DEXPERIENCER2016x - [Android Chrome] Incomplete UI for create link to cover requirement and Create Link to refine requirement command window panels. 
//quickreview   HAT1 ZUD 15:08:04  : LA Settings for ReqSpec Dependency HL
//@quickreview  HAT1 ZUD 15:08:07  : IR-381835-3DEXPERIENCER2016x R418-FUN048478-Creation of Requirement specification traceability dependency is KO with some preference.
//@quickreview  HAT1 ZUD 15:08:19  : IR-363246-3DEXPERIENCER2016x FUN048478:No option available to remove the target Requirement Specification from Create likn to cover\refine requirement pop upso that persistent dependencies can be deleted.
//@quickreview  HAT1 ZUD 15:10:12  : IR-393850-3DEXPERIENCER2017x: R418:FUN048478-"|" Field separator is not getting applied between title and revision on tree display. 
//@quickreview  HAT1 ZUD 15:12:16  : IR-382342-3DEXPERIENCER2017x: R418-FUN048478:While creating derivation link between the requirements which  belongs to the  Requirement Specification structure, source Requirement specification is not hidden from the add target search result.
//@quickreview  HAT1 ZUD 15:12:16  : IR-394861-3DEXPERIENCER2017x: R418:STP:Default size of the traceability Authoring command is too small as compare to space available and accessing multiple targets by dragging horizontal scroll bar is KO. 

//@quickreview  QYG      05:03:16    javascript refactoring, location moved
//@quickreview  HAT1 ZUD 16:05:18  : IR-398826-3DEXPERIENCER2017x: R418: Cover & Refined dilaogue box does not display all Requirement Specification when user use scroll bar to navigate. 
//@quickreview  HAT1 ZUD 16:11:04  : IR-480762-3DEXPERIENCER2018x: R418-STP: Same object can be attached as a Cover/ Refined object multiple times.
//@quickreview KIE1 ZUD  16:12:13  :	IR-484700-3DEXPERIENCER2018x: R419-FUN055951: In Envoia Preferences user is unable to unselect options in Tree Display section once they are selected by user.
//@quickreview  HAT1 ZUD 17:07:06  : IR-531749-3DEXPERIENCER2018x: R20-FUN067990-NLS:Tooltip of objects on Links Creation window is not translated. 
//@quickreview KIE1 ZUD  17:07:20  : IR-531703-3DEXPERIENCER2018x: The requirement specification(CHINESE Word) we created in CATIA client side , but it  can not  be loaded in the enovia web side .
//@quickreview  HAT1 ZUD 17:08:17  : IR-477856-3DEXPERIENCER2018x: R418-STP: Disturbed Contextual menu is displayed on Cover / Refine option panel. 

/* Contains code for the new dynaTree used in derivation command */
define('DS/ENORMTCustoSB/DerivationCmd', [], function(){
	return {};
});

var ctx = null;
var mDown = {
		x : 0,
		y : 0
};
var isDown = false;

var mMove = {
	x : 0,
	y : 0,
};

//Initialize Tree(s)
function goDynatreeDerivation(treeSource)
{
	var c = $("#dCanvas");
	ctx = c[0].getContext('2d');
	//Initialize Dynatree
	$(treeSource).dynatree({
		imagePath: '../common/',
		debugLevel: 2,
		checkbox:true,
		selectMode:2,
		onLazyRead: function(dtnode){
				toggleDynatree(dtnode , "Source", treeSource);

		},
		onExpand: function(flag, dtnode){
		},
		onCreate: function(dtnode,nodeSpan){
			bindContextMenu(nodeSpan,treeSource);
	
		},
		onRender: function(dtnode,nodeSpan)
		{
			var objectId	= getObjectIdfromKey(dtnode.data['key']);
			var objectColor = dtnode.data['legend'];
			//add color code
			var legend  = null;
			if(dtnode.data['kindOf'] == "Requirement"){
				switch(objectColor){
					case "yellow" : 
						legend = '<img class="rmtLegend" src="../requirements/images/legendCoveredReq.gif"alt style="height:12px;width:4px;margin-left:2px;margin-top:2px">';
						//enable delete links button
						$(".ui-dialog-buttonpane button:contains('"+DeleteLinksButton+"')").button('enable');
						break;
					case "fushia" :
						legend = '<img class="rmtLegend" src="../requirements/images/legendSatisfiedReq.gif"alt style="height:12px;width:4px;margin-left:2px;margin-top:2px">';
						//enable delete links button
						$(".ui-dialog-buttonpane button:contains('"+DeleteLinksButton+"')").button('enable');
						break;
					case "cyan"   : 
						legend = '<img class="rmtLegend" src="../requirements/images/legendSubReq.gif"alt style="height:12px;width:4px;margin-left:2px;margin-top:2px">';
						break;
					default		  :
						legend = null;
				}
				
			}
		},
		dnd : {
			onDragStart : function(node){
				logMsg("tree.onDragStart(%o)", node);
				//Prevent dragging another object than requirement
				if(node.data['kindOf'] != "Requirement"){
					return false;
				}
				
				//Prevent dragging derived requirement
				else if(node.data['isDerived'] == 'true')
				{
					return false;
				}

				//Canvas
				var canvas = $("#dCanvas")[0];
				
					//While mouse is down and mouse move
					//Get the coordinates of the mouse during move
					$('#derivationDialog').mousemove(function(e){
						mMove.x = e.clientX - $(this).parent().position().left - $(this).position().left;;
						mMove.y = e.clientY - $(this).parent().position().top - $(this).position().top;;
						
						if(isDown)
						{
							var canvas = $("#dCanvas")[0];
							//clear the canvas of previous drawing
							ctx.clearRect(0,0,canvas.width,canvas.height);
							var color = 'yellow';
							if(derivationMode == 'satisfy')
								color = 'magenta';
							else
								color = 'orange';
							drawDnDArrow(canvas, color, {x:mDown.x,y:mDown.y}, {x:mMove.x,y:mMove.y});
						}

					});
					
				return true;
			},
			onDragStop : function(node){
				logMsg("tree.onDragStop(%o)", node);
				var canvas = $("#dCanvas")[0];
			    ctx.clearRect(0,0,canvas.width,canvas.height);
			    $("#derivationDialog").unbind("mousemove");
			}
		}
				
	});
	

	
}

function refreshTable(fromId,toId){
	var arrIds=[];
	var fromObjects = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o='"+fromId+"']");
	var toObjects = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o='"+toId+"']");
	for(var i=0;i<fromObjects.length;i++){
		var id = fromObjects[i].getAttribute("id");
		arrIds.push(id);
	}
	for(var i=0;i<toObjects.length;i++){
		var id = toObjects[i].getAttribute("id");
		arrIds.push(id);
	}
	emxEditableTable.refreshRowByRowId(arrIds);
}



function goDynatreeTarget(treeTarget,derivationMode)
{
	//Initialize Dynatree
	$(treeTarget).dynatree({
		imagePath: '../common/',
		debugLevel: 2,
		selectMode:1,
		checkbox:true,
		onLazyRead: function(dtnode){
				toggleDynatree(dtnode, "Target" , treeTarget);

		},
		onExpand: function(flag, dtnode){
			
		},
		onCreate: function(dtnode,nodeSpan){
			bindContextMenu(nodeSpan, treeTarget);

		},
		onRender: function(dtnode,nodeSpan)
		{
			
			var objectId	= getObjectIdfromKey(dtnode.data['key']);
			var objectColor = dtnode.data['legend'];
			//add color code
			var legend  = null;
			if(dtnode.data['kindOf'] == "Requirement"){
				switch(objectColor){
					case "yellow" : 
						legend = '<img class="rmtLegend" src="../requirements/images/legendCoveredReq.gif"alt style="height:12px;width:4px;margin-left:2px;margin-top:2px">';
						//enable delete links button
						$(".ui-dialog-buttonpane button:contains('"+DeleteLinksButton+"')").button('enable');
						break;
					case "fushia" :
						legend = '<img class="rmtLegend" src="../requirements/images/legendSatisfiedReq.gif"alt style="height:12px;width:4px;margin-left:2px;margin-top:2px">';
						//enable delete links button
						$(".ui-dialog-buttonpane button:contains('"+DeleteLinksButton+"')").button('enable');
						break;
					case "cyan"   : 
						legend = '<img class="rmtLegend" src="../requirements/images/legendSubReq.gif"alt style="height:12px;width:4px;margin-left:2px;margin-top:2px">';
						break;
					default		  :
						legend = null;
				}
			}
		},
		dnd : {
			autoExpandMS:1000,
			preventVoidMoves: true,
			onDragEnter: function(node, sourceNode){
				logMsg("tree.onDragEnter(%o, %o)", node,
                        sourceNode);
                return true;
			},
			onDragOver: function(node, sourceNode, hitMode, ui, draggable){
				
				logMsg("tree.onDragOver(%o, %o, %o)", node,
                        sourceNode, hitMode);

				//Prevent Dropping before or after
				if(hitMode == "before" || hitMode == "after")
				{
					return false;
				}
				//
                // Prevent dropping a parent below it's own child
                if (node.isDescendantOf(sourceNode)||sourceNode.isDescendantOf(node)) {
                    return false;
                }
                if( getObjectIdfromKey(node.data['key']) == getObjectIdfromKey(sourceNode.getParent().data['key']))
                {
                	return false;
                }
                
                // Prevent dorpping an object on itself
                if(getObjectIdfromKey(node.data['key']) == getObjectIdfromKey(sourceNode.data['key']))
                {
                	return false;
                }
                
                //Prevent dropping on another object than requirement
				if(node.data['kindOf'] != "Requirement"){
					return false;
				}
				
				//Prevent dropping on derived requirement
				if(node.data['isDerived'] == 'true')
				{
					return false;
				}
				
				//Prevent dopping on children
				var children = sourceNode.childList;
				
				// ++ HAT1 ZUD: IR-480762-3DEXPERIENCER2017x: FIX
				if(children == null)
				{
					toggleDynatree(sourceNode, "Source" , treeTarget);
					children = sourceNode.childList;
				}
				// -- HAT1 ZUD: IR-480762-3DEXPERIENCER2017x

				if(children != null)
				{
					for(var n=0;n<children.length;n++){
						var childnode = getObjectIdfromKey(children[n].data['key']);
						if(getObjectIdfromKey(node.data['key']) == childnode)
							return false;
					}
				}
				
				return true;
			},
			onDrop : function(node, sourceNode, hitMode, ui,
                    draggable){
				// ++ HAT1 ZUD HL Requirement Specification Dependency 				
				//Finds the Requirement Specification obj node.
				
				//Getting root Req Spec id.
				var reqSpecTargetNodeKeyPath = node.getKeyPath();
				var idEndIndex      = reqSpecTargetNodeKeyPath.indexOf( "||" );
				var reqSpecTargetId = reqSpecTargetNodeKeyPath.substr(1,idEndIndex-1);
				
				var reqSpecSourceId = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o]")[0].getAttribute("o");
				
		        // ++ Relationship direction modification for covered and refined requirements.
				var dataXMLPreference = emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=TraceabilityMgtSettings&alwaysPrompt=AlwaysPromptRelationship");
				var rows1 	   = $(dataXMLPreference).find("r");
				var traceabilityMgtSettingsValue   = rows1[0].getAttribute('selectedTraceabilityMgtSettings');
				        
					    if(traceabilityMgtSettingsValue == "AlwaysPromptRelationship" || traceabilityMgtSettingsValue == "AlwaysCreateDelete")
		        {	
			    	var dataXMListLinkExist = emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=checkForReqSpecsDerivationLink&reqSpecSourceId=" + reqSpecSourceId + "&reqSpecTargetId=" + reqSpecTargetId+ "&derivationMode=" + derivationMode);
			    	var rows2 	   = $(dataXMListLinkExist).find("r");
        	        var isReqSpecsDerivationLinkExists = rows2[0].getAttribute('isReqSpecsDerivLinkExists');

						        	if(traceabilityMgtSettingsValue == "AlwaysPromptRelationship" && isReqSpecsDerivationLinkExists == "No Derivation Link")
					        		{
						 $(document).ready(function() 
						 {
						       var $dialog = $("#reqSpecDependencyPromptDiv");
						    	//.html('This dialog will show every time!')
						       $dialog.dialog({
						    		  autoOpen: false,
						    		  //title: 'Basic Dialog'
												      resizable: false,
												      height: 200,
												      width: 600,
												      modal: true,
												      buttons: {
												    	  CreateDependencyYesButton:
												    	  {
												    		  click: function() {
												        	$( this ).dialog( "close" );
												        	setReqSpecDependencyPromptValueTrue(node, sourceNode, hitMode, ui, draggable, reqSpecSourceId, reqSpecTargetId, true); 
												        },
										       				text: CreateDependencyYesButton
												        },
												        CreateDependencyNoButton:{
												      
												        	click: function() {
												          $( this ).dialog( "close" );
												            setReqSpecDependencyPromptValueFalse(node, sourceNode, hitMode, ui, draggable, false); 
												        },
												        text: CreateDependencyNoButton
												        }
												      }
						       
												    });
						    	$dialog.dialog('open');
										 });
					        		}
    		        // -- Relationship direction modification for covered and refined requirements.
						        	
						        	else if(traceabilityMgtSettingsValue == "AlwaysPromptRelationship" && isReqSpecsDerivationLinkExists != "No Derivation Link")
					        		{
							            setReqSpecDependencyPromptValueFalse(node, sourceNode, hitMode, ui, draggable, false); 
					        		}
						        	
						        	else if(traceabilityMgtSettingsValue == "AlwaysCreateDelete" && isReqSpecsDerivationLinkExists == "No Derivation Link")
					        		{
							        	setReqSpecDependencyPromptValueTrue(node, sourceNode, hitMode, ui, draggable,  reqSpecSourceId, reqSpecTargetId, true); 
					        		}
						        	
						        	else if(traceabilityMgtSettingsValue == "AlwaysCreateDelete" && isReqSpecsDerivationLinkExists != "No Derivation Link")
					        		{
							        	setReqSpecDependencyPromptValueFalse(node, sourceNode, hitMode, ui, draggable, false); 
					        		}
						        	
				        	    }
				        else //if(traceabilityMgtSettingsValue == "NeverPrompt")
			        	{
				        	setReqSpecDependencyPromptValueFalse(node, sourceNode, hitMode, ui, draggable, false); 
			        	}
				// -- HAT1 ZUD HL Requirement Specification Dependency
			},
			onDragLeave : function(node, sourceNode){
				logMsg("tree.onDragLeave(%o, %o)", node,
                        sourceNode);
			}
		}
				
	});
}

// ++ HAT1 ZUD HL Requirement Specification Dependency 				
function setReqSpecDependencyPromptValueTrue(node, sourceNode, hitMode, ui, draggable, reqSpecSourceId, reqSpecTargetId, reqSpecDependencyPromptValue)
{
	//HAT1 ZUD: IR-381835-3DEXPERIENCER2016x fix 
	var dataXMListLinkExist = emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=createReqSpecsDerivationLink&reqSpecSourceId=" + reqSpecSourceId + "&reqSpecTargetIds=" + reqSpecTargetId+ "&derivationMode=" + derivationMode);
	
	reqSpecDependencyPromptValue = false;
	setReqSpecDependencyPromptValueFalse(node, sourceNode, hitMode, ui, draggable, reqSpecDependencyPromptValue);
	
}


function setReqSpecDependencyPromptValueFalse(node, sourceNode, hitMode, ui, draggable, reqSpecDependencyPromptValue)
{
				logMsg("tree.onDrop(%o, %o, %s)", node,
                        sourceNode, hitMode);
					//clear the canvas
					var canvas = $("#dCanvas")[0];
					//ctx.beginPath();
				    ctx.clearRect(0,0,canvas.width,canvas.height);
				    $("#derivationDialog").unbind("mousemove");
					//
					switch(derivationMode){
					case "satisfy":

						var fromId 		= getObjectIdfromKey(sourceNode.data['key']);
						var toId 		= getObjectIdfromKey(node.data['key']);
						var dataXML 	= emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=createDerivationLink&fromId="+fromId+"&toId="+toId+"");
						// OSLC Traceability Authoring Cmd 
						if($(dataXML).find("r")[0].getAttribute("errorMsg").indexOf("Error") != -1)
						{
							alert($(dataXML).find("r")[0].getAttribute("errorMsg"));
							break;
						}
						
						refreshTable(fromId,toId);
						var rows 		= $(dataXML).find("r");
						var objectId;
						var objectRelId;
						var objectName;
						var objectImage;
						var objectKeySas;
						var objectKeyCov;
						var objectTitle;
						var objectRevision;
						var objectCText;
						var objectTooltip;
						if(rows.length>0){
							objectId 		= rows[0].getAttribute("id");
							objectRelId		= rows[0].getAttribute("relId");
							objectName 		= rows[0].getAttribute("name");
							objectName      = decodeSpecialCharAsHTML(objectName);
							objectImage 	= rows[0].getAttribute("image");
							objectKeySas	= toId+"|"+ objectRelId + "|" + fromId;
							objectKeyCov	= fromId+"|"+objectRelId+"|"+toId;
							objectTitle		= rows[0].getAttribute('title');
							objectTitle		= decodeSpecialCharAsHTML(objectTitle);
							objectCText		= String(rows[0].getAttribute('contentText'));
							objectCText		= decodeSpecialCharAsHTML(objectCText);
							objectRevision  = rows[0].getAttribute('revision');
							if(objectTitle =="" || objectTitle =="null")
								objectTitle = "-";
							if(objectCText == "" || objectTitle =="null")
								objectCText = "-";

							//objectTooltip			= "Title : " + objectTitle +"\n Revision : " + objectRevision +"\n Content Text: "+objectCText+"";

							// HAT1 ZUD IR-531749-3DEXPERIENCER2018x fix
							objectTooltip 	=  strTitle + " : " + objectTitle;
							objectTooltip 	+= "\n"  + strRevision + " : " + objectRevision;
							objectTooltip 	+= "\n"  + strContent_Text + " : " + objectCText;
						}
						//add Satisfied Requirement on the left
						sourceNode.addChild({
				            key: objectKeySas,
				            title: objectTitle ,
				            tooltip: node.data['tooltip'],
				            isLazy: false,
				            icon: 'images/iconReqTypeDerivedRequirement.png',
				            isDerived: 'true',
				            legend:'fushia',
				            kindOf:'Requirement'
		
				          });
						sourceNode.expand(true);
						
						//add covering Requirements on the right
						node.addChild({
							key: objectKeyCov,
							title: sourceNode.data['title'],
							tooltip: sourceNode.data['tooltip'],
							isLazy:false,
							icon: 'images/iconReqTypeCoveredRequirement.png',
							isDerived: 'true',
							legend:'yellow',
							kindOf:'Requirement',
				    	    hideCheckbox: true
						});
						node.expand(true);
						
			
						break;					
					case "cover":

						var fromId 			= getObjectIdfromKey(node.data['key']);
						var toId 			= getObjectIdfromKey(sourceNode.data['key']);
						var dataXML 		= emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=createDerivationLink&fromId="+fromId+"&toId="+toId+"");
						// OSLC Traceability Authoring Cmd 
						if($(dataXML).find("r")[0].getAttribute("errorMsg").indexOf("Error") != -1)
						{
							alert($(dataXML).find("r")[0].getAttribute("errorMsg"));
							break;
						}
						
						refreshTable(fromId,toId);	
						var rows 			= $(dataXML).find("r");
						var objectId;
						var objectRelId;
						var objectName;
						var objectImage;
						var objectKeySas;
						var objectKeyCov;
						var objectTitle;
						var objectCText;
						var objectRevision;
						var objectTooltip;
						if(rows.length>0){
							objectId 		= rows[0].getAttribute("id");
							objectRelId		= rows[0].getAttribute("relId");
							objectName 		= rows[0].getAttribute("name");
							objectName		= decodeSpecialCharAsHTML(objectName);
							objectImage 	= rows[0].getAttribute("image");
							objectKeySas	= toId+"|"+ objectRelId + "|" + fromId;
							objectKeyCov	= fromId+"|"+objectRelId+"|"+toId;
							objectTitle		= rows[0].getAttribute('title');
							objectTitle		= decodeSpecialCharAsHTML(objectTitle);
							objectCText		= String(rows[0].getAttribute('contentText'));
							objectCText		= decodeSpecialCharAsHTML(objectCText);
							objectRevision  = rows[0].getAttribute('revision');
							
							if(objectTitle =="" || objectTitle =="null")
								objectTitle = "-";
							if(objectCText == "" || objectTitle =="null")
								objectCText = "-";
					
							
							//objectTooltip			= "Title : " + objectTitle +"\n Revision : " + objectRevision +"\n Content Text: "+objectCText+"";
							// HAT1 ZUD IR-531749-3DEXPERIENCER2018x fix
							objectTooltip 	=  strTitle + " : " + objectTitle;
							objectTooltip 	+= "\n"  + strRevision + " : " + objectRevision;
							objectTooltip 	+= "\n"  + strContent_Text + " : " + objectCText;
							
						}
						
						//add Covering Requirement on the left
						sourceNode.addChild({
				            key: objectKeyCov,
				            title: node.data['title'],
				            tooltip: node.data['tooltip'],
				            isLazy: false,
				            icon: 'images/iconReqTypeCoveredRequirement.png',
				            isDerived: 'true',
				            legend:'yellow',
				            kindOf:'Requirement',
		
				          });
						sourceNode.expand(true);
						
						//add Satisfied Requirement on the right
						node.addChild({
							key: objectKeySas,
							title: objectTitle,
							tooltip: sourceNode.data['tooltip'],
							isLazy:false,
							icon: 'images/iconReqTypeDerivedRequirement.png',
							isDerived: 'true',
							legend:'fushia',
							kindOf:'Requirement',
				    	    hideCheckbox: true
						});
						node.expand(true);
						
						break;
					default:
						alert("unhandle command");
					}
					

}

// -- HAT1 ZUD HL Requirement Specification Dependency 				

// A custom Stack used to build the tree, to stock the nodes
function Stack(){
	
	this.stac = new Array();
	this.lastElement = null;
	this.pop = function(){
		return this.stac.pop();
	};
	this.push = function(item){
		this.stac.push(item);
		this.lastElement = item;
	};
	this.getLast = function() {
        return this.lastElement;
    };
    this.isRoot = function() {
        if (this.stac.length == 1)
        	return true;
        return false;
    };
    this.getRoot = function() {
        if (this.stac.length >= 1)
            return this.stac[0];
        return null;
    };
}
//Used for first Construction
function construcFirstDerivTree(tree, objectId ,isTarget)
{
	var rootMasterNodeDyna;
	rootMasterNodeDyna = $(tree).dynatree("getRoot");
	var treeDyna = $(tree).dynatree("getTree");
	treeDyna.enableUpdate(false);

	var nodeStack = new Stack();
	var isVirtualRoot = true;
	nodeStack.push(rootMasterNodeDyna); // The virtual root for the moment*/
			
	// get the rows
	var strDerivMode = derivationMode;
	var strTreeMode = "";
	var expandLevel = "";
	var hideCheckboxValue = true;

	// IR-364087-3DEXPERIENCER2016x : Performance issue don't expand Target tree
	if(isTarget == "yes")
	{
		strTreeMode = "Target";
		expandLevel = 0; 
	}
	else
	{
		strTreeMode = "Source";
		expandLevel = 1;
	}
	
	var rootSeqOrder 	= "";
	var rootType	 	= "";

	//Target trees with expand level 0
	var dataXML = emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=expandStructure&strObjID="+objectId+"&strDerivMode="+strDerivMode+"&strTreeMode="+strTreeMode+"&strExpandLevel="+expandLevel);
	
	//HAT1 ZUD : HL Requirement Specificaiton Dependency
	if(strTreeMode == "Target")
	{
		//Getting Source and Target root Req Spec id.
		var reqSpecTargetId = objectId;
		var reqSpecSourceId = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o]")[0].getAttribute("o");
		
	}
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
		
		objectName			= decodeSpecialCharAsHTML(objectName);
		objectName 			= jQuery('<div />').text(objectName).html(); 
		var objectImage 	= rows[i].getAttribute('icon');
		var sKindOf			= rows[i].getAttribute('kindOf');
		var objectExpand 	= false;
		var oldLevel 		= 1;
		var currentLevel 	= parseInt(rows[i].getAttribute('level'));
		var sDerived 		= "false";
		var objectColor     = rows[i].getAttribute('colorCode');
		var objectKey		= objectId+ "|" + objectRelId + "|" + objectParentId;
		var isExpandedAll   = "N/A";
		
		var objectCText		= String(rows[i].getAttribute('contentText'));
		objectCText			= decodeSpecialCharAsHTML(objectCText);
		if(objectTitle =="")
			objectTitle = "-";
		if(objectCText == "")
			objectCText = "-";
		
		//var objectTooltip			= "Title : " + objectTitle +"\n Revision : " + objectRevision +"\n Content Text: "+objectCText+"";
		// HAT1 ZUD IR-531749-3DEXPERIENCER2018x fix
		var	objectTooltip 	= strTitle + " : " + objectTitle;
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
            // IR-364087-3DEXPERIENCER2016x : Performance issue don't expand Target tree
            if(strTreeMode == "Source")
            objectExpand = true;
            else
            	objectExpand = false;
            
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
		if(sDerived == "true" && strTreeMode == "Source")
		{	
			sLazy = false;
			hideCheckboxValue = false;
		}
		
		if(rows[i].getAttribute('type') == "Requirement Specification" && strTreeMode == "Target")
		{
			hideCheckboxValue = false;
		}

        attachedNode = nodeToAttach.addChild({
            key: objectKey,
            title: objectName,
            tooltip: objectTooltip,
            isLazy: sLazy,
            icon: objectImage,
            expand: objectExpand,
            hideCheckbox: hideCheckboxValue,
            isDerived: sDerived,
            legend : objectColor,
            isExpandedAll : isExpandedAll,
            kindOf:sKindOf,
          });
        objectExpand = true;
        hideCheckboxValue = true;
        
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
	
	treeDyna.redraw();
	treeDyna.enableUpdate(true);	
	
}

// ++ Relationship direction modification for covered and refined requirements.
function reqSpecsCreateRelationShip(reqSpecTargetIds)
{
	var reqSpecSourceId = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o]")[0].getAttribute("o");
	
	var dataXMLPreference = emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=TraceabilityMgtSettings&alwaysPrompt=AlwaysPromptTargets");
	var rows1 	   = $(dataXMLPreference).find("r");
	var traceabilityMgtSettingsValue   = rows1[0].getAttribute('selectedTraceabilityMgtSettings');
	
	var dataXMListLinkExist = emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=checkForReqSpecsDerivationLink&reqSpecSourceId=" + reqSpecSourceId + "&reqSpecTargetId=" + reqSpecTargetIds+ "&derivationMode=" + derivationMode);
	var rows2 	   = $(dataXMListLinkExist).find("r");
	
	var isReqSpecsDerivLinkExists   = rows2[0].getAttribute('isReqSpecsDerivLinkExists');
	
    if(traceabilityMgtSettingsValue == "AlwaysPromptTargets" && isReqSpecsDerivLinkExists == "No Derivation Link")
    {
		$(document).ready(function() 
		{
		    var $dialog = $("#reqSpecDependencyPromptDiv");
		    	//.html('This dialog will show every time!')
		       $dialog.dialog({
		    		  autoOpen: false,
		    		  //title: 'Basic Dialog'
		    		  resizable: false,
				      height: 200,
				      width: 600,
				      modal: true,
				      buttons: {
				    	  CreateDependencyYesButton:
				    	  {
				    		  click: function() {
				        	$( this ).dialog( "close" );
			        		createReqSpecDependency(reqSpecSourceId, reqSpecTargetIds);
				        },
		       				text: CreateDependencyYesButton
				        },
				        CreateDependencyNoButton:{
				      
				        	click: function() {
				            $( this ).dialog( "close" );
				        },
				        text: CreateDependencyNoButton
				        }
				      }
		    	});
		    	$dialog.dialog('open');
		});
    }
    
    // HAT1 ZUD: IR-381835-3DEXPERIENCER2016x fix 
    else if(traceabilityMgtSettingsValue == "AlwaysCreateDelete" && isReqSpecsDerivLinkExists == "No Derivation Link")
	{
    	createReqSpecDependency(reqSpecSourceId, reqSpecTargetIds);
	}
        
}
// -- Relationship direction modification for covered and refined requirements.

//++ HAT1 ZUD HL IR-364298-3DEXPERIENCER2016x- FUN048478:Preference under Tree display option are not getting applied. 

function getTreeDisplay(rows)
{
	//var objectId 		= rows[i].getAttribute('o');
	//var objectRelId		= rows[i].getAttribute('r');
	//var objectParentId	= rows[i].getAttribute('p');
	var objectName 		= decodeSpecialCharAsHTML(rows.getAttribute('name'));
	var objectTitle		= decodeSpecialCharAsHTML(rows.getAttribute('title'));
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
	
// ++ IR-393850-3DEXPERIENCER2017x
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
// -- IR-393850-3DEXPERIENCER2017x
}

// -- HAT1 ZUD HL IR-364298-3DEXPERIENCER2016x- FUN048478:Preference under Tree display option are not getting applied. 

// ++ HAT1 ZUD HL Requirement Specification Dependency

function createReqSpecDependency(reqSpecSourceId, reqSpecTargetIds)
{
    //Relationship direction modification for covered and refined requirements.
    // ++ HAT1 ZUD: IR-381835-3DEXPERIENCER2016x fix 
	var dataXMListLinkExist = emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=createReqSpecsDerivationLink&reqSpecSourceId=" + reqSpecSourceId + "&reqSpecTargetIds=" + reqSpecTargetIds+ "&derivationMode=" + derivationMode);	
	
}


function constructCompleteDerivationTree(tree, objectId, isTarget)
{
	var rootMasterNodeDyna;
	rootMasterNodeDyna = $(tree).dynatree("getRoot");
	
	var treeDyna = $(tree).dynatree("getTree");
	treeDyna.enableUpdate(false);
	
	var nodeStack = new Stack();
	var isVirtualRoot = true;
	nodeStack.push(rootMasterNodeDyna); // The virtual root for the moment*/
	var hideCheckboxValue = true;
			
	// get the rows
	var strDerivMode = derivationMode;
	var strTreeMode = "";
	if(isTarget == "yes")
		strTreeMode = "Target";
	else
		strTreeMode = "Source";
	
	var rootSeqOrder 	= "";
	var rootType	 	= "";

	var dataXML 		= emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=expandStructure&strObjID="+objectId+"&strDerivMode="+strDerivMode+"&strTreeMode="+strTreeMode+"&strExpandLevel=All");
	var rows 			= $(dataXML).find("r");
	var oldLevel 		= 0;
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
		
		objectName			= decodeSpecialCharAsHTML(objectName);
		objectName 			= jQuery('<div />').text(objectName).html(); 
		var objectImage 	= rows[i].getAttribute('icon');
		var sKindOf			= rows[i].getAttribute('kindOf');
		var objectExpand 	= false;
		var currentLevel 	= parseInt(rows[i].getAttribute('level'));
		var sDerived 		= "false";
		var objectColor     = rows[i].getAttribute('colorCode');
		var objectKey		= objectId+ "|" + objectRelId + "|" + objectParentId;
		var sExpandedAll   = "N/A";

		var objectCText		= String(rows[i].getAttribute('contentText'));
		objectCText			= decodeSpecialCharAsHTML(objectCText);
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
            sExpandedAll = "true";
		}else if(currentLevel==1){
			nodeToAttach = nodeStack.getRoot();
			sDerived = rows[i].getAttribute('isDerived');
		}
		else if(currentLevel == oldLevel){
			nodeToAttach = nodeStack.getLast().getParent();
            sDerived = rows[i].getAttribute('isDerived');
		}else if (currentLevel < oldLevel) {
            var nbLevels = oldLevel - currentLevel;
            var nodeToAttach = nodeStack.getLast();
            for(var k=0;k<=nbLevels;k++){
            	nodeToAttach = nodeToAttach.getParent();
            }
            sDerived = rows[i].getAttribute('isDerived');
            
        }else if (currentLevel > oldLevel) {
            nodeToAttach = nodeStack.getLast();
            sDerived = rows[i].getAttribute('isDerived');
            
        }
		// We can now create the new child, and attach it to the current root
		var sLazy	= true;
		if(sDerived == "true")
		{
			sLazy = false;
			if(strTreeMode == "Source")
				hideCheckboxValue = false;
		}
		
		if(rows[i].getAttribute('type') == "Requirement Specification" && strTreeMode == "Target")
		{
			hideCheckboxValue = false;
		}
        attachedNode = nodeToAttach.addChild({
            key: objectKey,
            title: objectName,
            tooltip: objectTooltip,
            isLazy: sLazy,
            icon: objectImage,
            expand: objectExpand,
            isDerived: sDerived,
			hideCheckbox: hideCheckboxValue,
            legend : objectColor,
            isExpandedAll : sExpandedAll,
            kindOf: sKindOf,
          });
        objectExpand = false;
		hideCheckboxValue = true;
       
        
        // Post-process - Root case
        if (currentLevel == 0) {
            nodeStack.push(attachedNode);
            oldLevel = currentLevel;
        } else if (currentLevel <= oldLevel) {
            nodeStack.push(attachedNode);
            oldLevel = currentLevel;
        } else if (currentLevel > oldLevel) {
            nodeStack.push(attachedNode);
            oldLevel = currentLevel;
        }
	}
	
	treeDyna.redraw();
	treeDyna.enableUpdate(true);

}
// Expand one node
function toggleDynatree(dtnode , treeMode , tree)
{
	var strDerivMode 		= derivationMode;
	var strTreeMode 		= treeMode;
	var objectIdRoot 		= getObjectIdfromKey(dtnode.data['key']);
	//We check if the selected object is expandable
	var sDerived 			= dtnode.data['isDerived'];
	var hideCheckboxValue = true;
	
	if(sDerived == 'false')
	{
		// get the rows
		var dataXML = emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=expandStructure&strObjID="+objectIdRoot+"&strDerivMode="+strDerivMode+"&strTreeMode="+strTreeMode+"&strExpandLevel=1");
		var rows 	= $(dataXML).find("r");
		
		
		// we exclude the root node
		for(var i=1; i < rows.length;i++)
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

			objectName			= decodeSpecialCharAsHTML(objectName);
			objectName 			= jQuery('<div />').text(objectName).html(); 
			var objectImage 	= rows[i].getAttribute('icon');
			var sKindOf			= rows[i].getAttribute('kindOf');
			sDerived 			= rows[i].getAttribute('isDerived');
			var objectColor     = rows[i].getAttribute('colorCode');
			var sLazy			= true;
			var objectKey		= objectId + "|" + objectRelId + "|"+objectParentId;
			
			var objectCText		= String(rows[i].getAttribute('contentText'));
			objectCText			= decodeSpecialCharAsHTML(objectCText);
			if(objectTitle =="")
				objectTitle = "-";
			if(objectCText == "")
				objectCText = "-";
			
			//var objectTooltip			= "Title : " + objectTitle +"\n Revision : " + objectRevision +"\n Content Text: "+objectCText+"";
			// HAT1 ZUD IR-531749-3DEXPERIENCER2018x fix
			var	objectTooltip 	= strTitle + " : " + objectTitle;
				objectTooltip 	+= "\n"  + strRevision + " : " + objectRevision;
				objectTooltip 	+= "\n"  + strContent_Text + " : " + objectCText;
			
			if(sDerived == "true")
			{
				sLazy = false;
				if(strTreeMode != "Target")
					hideCheckboxValue = false;
			}
					
			dtnode.addChild({
			        key: objectKey,
			        title: objectName,
			        tooltip: objectTooltip,
			        isLazy: sLazy,
			        hideCheckbox: hideCheckboxValue,
			        icon: objectImage,
			        isDerived: sDerived,
			        legend: objectColor,
			        kindOf: sKindOf,
			
			 });
			
			hideCheckboxValue = true;
		}
	}

	dtnode.setLazyNodeStatus(DTNodeStatus_Ok);

}

function ExpandCollapseAll(action, tree)
{

	switch(action) {
	case "expandAll":
				
		var isExpandedAll = $(tree).dynatree("getRoot").childList[0].data['isExpandedAll'];
		if(isExpandedAll == 'false')
		{
			//The structure is not completed loaded. We need to retrieve all children from database.
			 var rootObjectId 	= getObjectIdfromKey($(tree).dynatree("getRoot").childList[0].data['key']);
			 var isTarget		= 'no';
			 if(tree.indexOf("Source") ==-1)
			 	isTarget		= 'yes';
			 
			
			 $(tree).dynatree('destroy');
			 $(tree).resizable('destroy');
			 $(tree).empty();
			 
			 $(tree).parent().append('<img src="../common/images/loading.gif">');
			
			 if(isTarget == 'no'){
				 $(tree).resizable({
					 handles: 'e,w',
					 resize: function(event,ui){
						 var derivContainerWidth = $("#derivationDialog").width() - ui.size.width - 40;
						  $("#derivationContainer").css('width',derivContainerWidth);
						
					}
				 });
			 }else{
			 $(tree).resizable({
					handles: 'e,w',
				});
			 }
			 
			 if(isTarget == 'no')
			 {
			 		goDynatreeDerivation(tree);
			 }
			 else
			 {
			 		goDynatreeTarget(tree, derivationMode);
			 }
			 
			 
			 constructCompleteDerivationTree(tree, rootObjectId, isTarget);
			 
			 $(tree).dynatree("getRoot").visit(function(node){
					node.expand(true);
					
				});
			 
			 $('img[src*="loading.gif"]').remove();
			 
		}
		else{
			//The structure was completely loaded.
			$(tree).dynatree("getRoot").visit(function(node){
				node.expand(true);
				
			});
		}

		break;
	case "collapseAll":
		$(tree).dynatree("getRoot").visit(function(node){
			node.expand(false);
		});
		break;
	default:
		alert("Unhandled command");
			
	};
}


function bindContextMenu(span, tree)
{
	//Add Context menu to this node
	$(span).contextMenu({menu : "derivMenu"}, function(action, el, pos){
		
		switch(action){
		case "expandAll" :
			ExpandCollapseAll(action, tree);
		break;
		case "collapseAll":
			ExpandCollapseAll(action, tree);
		break;
		case "DeleteDependencylink":
			deleteDependencylinks(action, tree);
		break;
		default:
			alert("no action !");
		}
	});
}

// ++ HAT1 ZUD: IR-363246-3DEXPERIENCER2016x FIX
function deleteDependencylinks(action, tree)
{
	var treeDivs = $("div[id^='tree']");
	var treeTgts = $("div[id^='treeTarget']");
	var treeSrc  = $("div[id^='treeSource']");
	
	 var sourceRootId 	= getObjectIdfromKey($(treeSrc[0]).dynatree("getRoot").childList[0].data['key']);	 
	
	var sIdString  = "";
	var countSelectedReqSpecs = 0;
	
	// We check the selected nodes of all trees
	for(var i = 0; i < treeTgts.size(); i ++)
	{
		var selectedNodes = $(treeTgts[i]).dynatree("getSelectedNodes");
		
		if(selectedNodes.length == 1)
		{
			var sNode 		= selectedNodes[0];
			var sKey  		= sNode.data['key'];
			var sKeys		= sKey.split('|');
			var sId 		= sKeys[0]; // object Id
			//var sRelId		= sKeys[1]; // relationship Id
			//var sParentId	= sKeys[2]; // Parent Id
			
			
			if(countSelectedReqSpecs == 0)
				sIdString += sId;  
			else
				sIdString += "|" + sId;
			
			countSelectedReqSpecs++;
						
		}
	}
	
	if(sIdString == "")
	{		
		alert(DeleteDependencylinkAlert);
	}
	else
	{
		var dataXML = emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=DeleteDependencyLinks&sIdString="+sIdString+"&sourceRootId="+sourceRootId);
		var rows 	= $(dataXML).find("r");
		var isDeletedReqSpecName      = true;
		var isNoDependencyReqSpecName = false;
		
		var deletedReqSpecNameList = ""; 
		var noDependencyReqSpecNameList = ""; 
		
		var deletedReqSpecIndex = 1;
		var noDependencyReqSpecIndex = 1;

		for(var i=1; i < rows.length; i++)
		{	
			var targetReqSpecName 		= rows[i].getAttribute('name');
			
			if(targetReqSpecName == "|NoDependency|")
				isNoDependencyReqSpecName = true;

			if(!isNoDependencyReqSpecName)
			{
				deletedReqSpecNameList += deletedReqSpecIndex + ". " + targetReqSpecName + "\n";
				deletedReqSpecIndex ++;
			}
			else if(isNoDependencyReqSpecName && targetReqSpecName != "|NoDependency|")	
			{
				noDependencyReqSpecNameList += noDependencyReqSpecIndex + ". " + targetReqSpecName + "\n";
				noDependencyReqSpecIndex ++;
			}
		}
		
		var str1 = "";
		if(deletedReqSpecNameList != "")
			str1 = DeletedDependencyAlert + "\n"  + deletedReqSpecNameList;
		if(noDependencyReqSpecNameList != "")
			str1 += NoDependencyAlert + "\n" + noDependencyReqSpecNameList;
		
		alert(str1);

	}
}
//-- HAT1 ZUD: IR-363246-3DEXPERIENCER2016x FIX

function getObjectIdfromKey(key){
	
	var ids = key.split("|");
	return ids[0];
	
}

function getRelIdfromKey(key){
	
	var ids = key.split("|");
	return ids[1];
}

function getParentIdfromKey(key){
	
	var ids = key.split("|");
	return ids[2];
}

function addEnpoint(span, pos)
{
	
	jsPlumb.Defaults.Container = $("#dCont");
	jsPlumb.addEndpoint(span, {anchor:pos});	
	
}

/*
 * Create Derivation Dialog
 */
function createDerivationDialog()
{
	var marginTopSrc 		= "";
	var marginTopSrcLabel 	= "";
	var marginTopTgtLabel	= "";
	var treeHeightSrc		= "";
	var derivationHeader	= "";
	var dlgTitle			= "";
	var dlgHeight			= getDerivationDlgHeight();
	var dlgWidth			= getDerivationDlgWidth();
	
	var legendWidth			= (32*dlgWidth/100) + 'px';
	
	if(derivationMode == "satisfy")
	{
		marginTopSrc 		= "30px";
		marginTopSrcLabel 	= "1px";
		marginTopTgtLabel	= "20px";
		//treeHeightSrc		= "340px";
		treeHeightSrc		= (65*dlgHeight/100) + 'px';
		
		derivationHeader	= '<div id="derivationHeader" style="height:10px;margin-top:0px;">'+
		'<div id="derivationLegend" style="position:absolute;right:0px;width:'+legendWidth+';">'+
    		'<h3 style="font-size:14px">'+LegendDlgLabel+'</h3>'+
    		'<div>'+
    			'<li><img src="../requirements/images/Rparent_refined_into.gif" style="height:48px;width:88px"><p style="margin-left:88px;margin-top:-30px">' + refineLegLabel + ' - ' + isRefinedLegLabel + '</p> </li>'+
    			'<li><img src="../requirements/images/Rparent_covered_by.gif" style="height:48px;width:88px"><p style="margin-left:88px;margin-top:-30px">'+coverLegLabel+' - '+isCoveredLegLabel+'</p></li>'+
    		'</div>'+
    	'</div>'+
		'<div id="sourceLabel" style="width:50px;height:5px;margin-left:50px;margin-top:'+marginTopSrcLabel+';">'+
			'<h3 style="font-size:11px;font-weight:bold;font-family:Arial, sans-serif;margin-top:'+marginTopSrcLabel+'">'+SourceDlgLabel+'</h3>'+
		'</div>'+
		'<div id="targetLabel" style="width:50px;height:5px;margin-left:320px;margin-top:'+marginTopTgtLabel+';">'+
			'<h3 style="font-size:11px;font-weight:bold;font-family:Arial, sans-serif;margin-top:'+marginTopTgtLabel+'">'+TargetDlgLabel+'</h3>'+
		'</div>'+
		'</div>';
		
		dlgTitle 			= RefdlgTitle;
		
	}
	else
	{
		marginTopSrc 		= "95px";
		marginTopSrcLabel	= "40px";
		marginTopTgtLabel	= "10px";
		//treeHeightSrc		= "260px";
		treeHeightSrc		= (50*dlgHeight/100) + 'px';
		derivationHeader	= '<div id="derivationHeader" style="height:10px;margin-top:1px;">'+
		'<div id="derivationLegend" style="position:absolute;right:0px;width:'+legendWidth+'">'+
	    	'<h3 style="font-size:11px;font-weight:bold;font-family:Arial, sans-serif">'+LegendDlgLabel+'</h3>'+
	    	'<div>'+
				'<li><img src="../requirements/images/Rparent_refined_into.gif" style="height:48px;width:88px"><p style="margin-left:88px;margin-top:-30px">'+ refineLegLabel + ' - ' + isRefinedLegLabel + '</p> </li>'+
				'<li><img src="../requirements/images/Rparent_covered_by.gif" style="height:48px;width:88px"><p style="margin-left:88px;margin-top:-30px">'+coverLegLabel+' - '+isCoveredLegLabel+'</p></li>'+
			'</div>'+
	    '</div>'+
		'<div id="targetLabel" style="width:50px;height:5px;margin-left:440px;margin-top:'+marginTopTgtLabel+';">'+
			'<h3 style="font-size:11px;font-weight:bold;font-family:Arial, sans-serif;margin-top:'+marginTopTgtLabel+'">'+TargetDlgLabel+'</h3>'+
		'</div>'+
		'<div id="sourceLabel" style="width:50px;height:5px;margin-left:50px;margin-top:'+marginTopSrcLabel+';">'+
			'<h3 style="font-size:11px;font-weight:bold;font-family:Arial, sans-serif;margin-top:'+marginTopSrcLabel+'">'+SourceDlgLabel+'</h3>'+
		'</div>'+
		'</div>';
		
		dlgTitle 			= CovDlgTitle;

	}
	
	var verticalLineHeight = (63*dlgHeight/100) + 'px';
	
	var derivationDiv = '<div id="derivationDialog" style ="display: none;background:rgba(255,0,0,0);">'+
							'<div id="dCont">'+
								derivationHeader+
								'<div id="treeSource" style = "float : left;margin-top:'+marginTopSrc+';height:'+treeHeightSrc+';width:200px;scroll:auto"></div>'+
								'<div class = "verticalLineRMT" style="margin-left:20px;margin-top:50px;height:'+verticalLineHeight+'"></div>'+
							'</div>'+
							'<canvas id="dCanvas" height="400" width="900" style="z-index:-1;position:absolute;top:0px;left:0px"></canvas>'+
						'</div>';
	// ++ HAT1 ZUD HL Requirement Specification Dependency 
	//hat1  zud: adding style ="display: none;"
	// HAT1 ZUD: IR-477856-3DEXPERIENCER2018x fix. Added padding.
	var  reqSpecDependencyPromptDiv = '<div id="reqSpecDependencyPromptDiv" title="'+ ReqSpecDependecyAlertTitle +'" style ="display: none;">'+
	            '<p>"' + ReqSpecDependecyCreateDependencyDlg + '"</p>'+
	        '</div>';
	
	//HAT1 ZUD: Making Dependency link context menu LA.
	var deleteDependencyLinksCmd = '';
	var contextMenuUL  = '<ul id="derivMenu" class="contextMenu" style="display:none;height:50px;width:150px;padding:0px;">';
	
	if(ManageReqSpecDependencies == "true")
	{
		deleteDependencyLinksCmd = '<li class="DeleteDependencylink"><a href="#DeleteDependencylink">' + DeleteDependencylinkButton + '</a></li>';
		contextMenuUL  = '<ul id="derivMenu" class="contextMenu" style="display:none;height:80px;width:220px;padding:0px">';
	}
	
	// -- HAT1 ZUD HL Requirement Specification Dependency 
	var contextMenu = contextMenuUL +
	'<li class="ExpandAll"><a href="#expandAll">' + ExpandAllButton + '</a></li>'+
	'<li class="CollapseAll"><a href="#collapseAll">' + CollapseAllButton + '</a></li>'+
	deleteDependencyLinksCmd +
	'</ul>';
	
	// display derivation dialog
	var derivDialogExtendOptions = {
			"closable":true,
			"maximizable":true,
			"minimizable":true,
			"dblclick": 'maximize',
			"maximize" : function(evt){
				maximizeDerivationDialog(evt,evt.target);
			},
			"restore" : function(evt){
			
				restoreDerivationDialog(evt, evt.target);
	        	
			},
			"beforeMaximize": function(evt){
				beforeMaxDerivationDlg();
			},
			"beforeRestore":function(evt){
			},
				
	};
	
	var derivDialogOptions = {
			modal: true,
			resizable: false,
			//height: 500,
			height: getDerivationDlgHeight(),
			//width: 930,
			width:getDerivationDlgWidth(),
			title : dlgTitle,
			buttons:derivationDlgButtons,
	        close: function () {
	        		$("#treeSource").dynatree('destroy').remove();
	        		for(var i =1; i <= derivTreeNumber;i++)
	        		{
	        			var tempTree = '#treeTarget'+ i +'';
	        			$(tempTree).dynatree('destroy').remove();
	        		}
	                $(this).dialog('destroy').remove();
	                derivTreeNumber =1 ;

	        },
	        resizeStop: function(event, ui){

	        	resizeStopDerivationDialog(event,ui);

	        }
	};
	
	$("#mx_divBody").append(derivationDiv);
	// HAT1 ZUD HL Requirement Specification Dependency 
	$("#mx_divBody").append(reqSpecDependencyPromptDiv);

	$("#derivationDialog").css({"overflow-y" : "hidden" , "overflow-x" : "hidden"});
	
	$('#derivationDialog').dialog(derivDialogOptions).dialogExtend(derivDialogExtendOptions);
		
	$('#derivationDialog').append(contextMenu);
	
	//Get the coordinates of the mouse and set isDown
	$('#derivationDialog').mousedown(function(e){
		isDown = true;
		mDown.x = e.clientX - $(this).parent().position().left - $(this).position().left; 
		mDown.y = e.clientY - $(this).parent().position().top - $(this).position().top;
		
	});
		
	//Reset isDown
	$('#derivationDialog').mouseup(function(e){
		isDown = false;
	});
	
	//disable Delete Links button by default
	$(".ui-dialog-buttonpane button:contains('"+DeleteLinksButton+"')").button('disable');
		
}

function getDerivationDlgHeight(){
	
	var maxHeight = $("#mx_divBody").height();
	
	var dlgHeight = (70*maxHeight/100);
	
	return dlgHeight;
	
}

function getDerivationDlgWidth(){
	
	var maxWidth = $("#mx_divBody").width();
	
	var dlgWidth = (65*maxWidth/100);
	
	return dlgWidth;
}

// ++ HAT1 ZUD: IR-382342-3DEXPERIENCER2017x: finding object ids which are to excluded in search window.
/*
 * Exclusion list of Req Spec objects in Search window.
 */
function exclusion_List()
{
	var treeSrc  = $("div[id^='treeSource']");
	var treeTgts = $("div[id^='treeTarget']");
	
	var sourceRootId 	= getObjectIdfromKey($(treeSrc[0]).dynatree("getRoot").childList[0].data['key']);
	var exclusionIDList = sourceRootId;
	var targetID = "";	
	
	for(var i = 0; i < treeTgts.size(); i ++)
	{
		targetID = getObjectIdfromKey($(treeTgts[i]).dynatree("getRoot").childList[0].data['key']);
		exclusionIDList = exclusionIDList + "," + targetID;
	}
	
	//return exclusion_IDList;
	return exclusionIDList;
}
//-- HAT1 ZUD: IR-382342-3DEXPERIENCER2017x fix

/*
 * Definition of Buttons for Derivation Dialog
 */
var derivationDlgButtons = {};
derivationDlgButtons[AddTargetButton] = function(){
	
	//HAT1 ZUD: IR-382342-3DEXPERIENCER2017x : populating the exclusion_list with the object ids which are to excluded in search window.
	var exclusionList = exclusion_List();
	
	showChooser(
			'../common/emxFullSearch.jsp?field=TYPES%3Dtype_SoftwareRequirementSpecification&sortColumnName=none&'+
			'table=RMTGlobalSearchRequirementsTable&selection=multiple&suiteKey=Requirements'+
			'&cancelButton=true&header=emxRequirements.Heading.SearchResult&cancelLabel=emxRequirements.Button.Cancel'+
			'&showInitialResults=true&HelpMarker=emxhelpfullsearch'+
			'&formInclusionList=CONTAINED_IN_PRODUCTS,CONTAINED_IN_SPECIFICATIONS&includeOIDprogram=null&'+
			'excludeOID='+exclusionList+'&'+ 
			'showClipboard=True&PrinterFriendly=True&objectCompare=True&Export=True&multiColumnSort=True'+
			'&triggerValidation=True&expandLevelFilter=True&autoFilter=True&searchCollectionEnabled=True'+
			'&showSavedQuery=True&submitURL=../requirements/FullSearchUtil.jsp?mode=AddDerivationTarget'+
			'&targetLocation=popup',
            '600', '600', 'true', '');
};

derivationDlgButtons[DeleteLinksButton] = function(){
	removeSelectedObjects();
};


/*
 * Resize every component in the derivation during resize
 */
function beforeMaxDerivationDlg(evt, dlg)
{
	//find all tree divs
	var treeDivs = $("div[id^='tree']");
	for(var i = 0; i < treeDivs.size(); i ++)
	{
		$(treeDivs[i]).resizable('destroy');
	}
	
}

function maximizeDerivationDialog(evt, dlg)
{

	var height = $(dlg).height();
	var height_old = $("#derivationContainer").height();
	
	var ratio_h = height - height_old;
	var containerWidth = $(dlg).width() - $("#treeSource").width() - 40;
	var containerHeight = height - 20;
	
	//find all tree divs
	var treeDivs = $("div[id^='tree']");
	//find the separator
	var sepLine = $("div[class^='verticalLineRMT']");
	
	//resize container
	$("#derivationContainer").css('height',containerHeight + 'px');
	$("#derivationContainer").css('width', containerWidth + 'px');
	
	//resize canvas
	$("#dCanvas")[0].height = height;
	$("#dCanvas")[0].width  = $(dlg).width();
	
	//resize trees
	for(var i = 0; i < treeDivs.size(); i ++)
	{
		var cur_div = treeDivs[i];									        		
		$(cur_div).css('height',($(cur_div).height()+ratio_h-20) + 'px');
		
		if($(cur_div).attr('id') == 'treeSource')
		{
			// makes the source resizable horizontal only
			$("#treeSource").resizable({
				handles: 'e,w',
				resize: function(event,ui){
					  var derivContainerWidth = $("#derivationDialog").width() - ui.size.width - 40;
					  $("#derivationContainer").css('width',derivContainerWidth);
					
				}
				});
		}
		else
		{
			$(cur_div).resizable({
				handles: 'e,w',
			});
			
		}
	
	}

	//resize separator
	$(sepLine).css('height', ($(sepLine).height()+ratio_h)+'px');

}

function restoreDerivationDialog(evt, dlg)
{

	var height = $(dlg).height();
	var height_old = $("#derivationContainer").height();
	
	var ratio_h = height - height_old;
	var containerWidth = $(dlg).width() - $("#treeSource").width() - 40;
	var containerHeight = height - 20;
	
	//find all tree divs
	var treeDivs = $("div[id^='tree']");
	//find the separator
	var sepLine = $("div[class^='verticalLineRMT']");
	
	//resize container
	$("#derivationContainer").css('height',containerHeight);
	$("#derivationContainer").css('width', containerWidth + 'px');
	
	//resize canvas
	$("#dCanvas")[0].height = height;
	$("#dCanvas")[0].width  = $(dlg).width();
	
	//resize trees
	for(var i = 0; i < treeDivs.size(); i ++)
	{
		var cur_div = treeDivs[i];									        		
		$(cur_div).css('height',($(cur_div).height()+ratio_h-20) + 'px');
	}
	
	//resize separator
	$(sepLine).css('height', ($(sepLine).height()+ratio_h-20)+'px');
}

function resizeStopDerivationDialog(event,ui)
{
	var height_old = $("#derivationContainer").height();
	var height = $("#derivationDialog").height();
									        	
	var ratio_h = height - height_old;
	var containerWidth = $("#derivationDialog").width() - $("#treeSource").width() - 40;
	
	//find all tree divs
	var treeDivs = $("div[id^='tree']");
	//find the separator
	var sepLine = $("div[class^='verticalLineRMT']");
	
	//resize container
	$("#derivationContainer").css('height',height + 'px');
	$("#derivationContainer").css('width', containerWidth + 'px');
	
	//resize trees
	for(var i = 0; i < treeDivs.size(); i ++)
	{
		var cur_div = treeDivs[i];									        		
		$(cur_div).css('height',($(cur_div).height()+ratio_h) + 'px');
	}
	
	//resize separator
	$(sepLine).css('height', ($(sepLine).height()+ratio_h)+'px');
}

function finishDerivDialogConstruction()
{
	
	var derivContainerHeight = (72*getDerivationDlgHeight()/100) + 'px';
	var derivContainerWidth = $("#derivationDialog").width() - $("#treeSource").width() - 40;
	var derivContainer = '<div id="derivationContainer" style = "float:left;height:'+derivContainerHeight+';width:'+ derivContainerWidth + 'px;background:rgba(255,0,0,0);">'+
	'<div id="derivationSubContainer" style="height:200px;"></div>'+
	'</div>';

	// Add Derivation Container that will contain the scrollbar for the target(s)
	$("#dCont").append(derivContainer);
	//The scrollbar is visible only on mouseover
	$("#derivationContainer").mouseover(function(){
			$("#derivationContainer").css({"overflow-y" : "hidden" , "overflow-x" : "auto"});
	});
	$("#derivationContainer").mouseout(function(){
		$("#derivationContainer").css({"overflow-y" : "hidden" , "overflow-x" : "hidden"});
	});
	
	
	// makes the source resizable horizontal only
	$("#treeSource").resizable({
		handles: 'e,w',
		resize: function(event,ui){
			var derivContainerWidth = $("#derivationDialog").width() - ui.size.width - 40;
			$("#derivationContainer").css('width',derivContainerWidth);
			
		}
		}
	);
	
	//Display legend as accordion
	$("#derivationLegend").accordion({
		collapsible:true,
		header: "h3",
		heightStyle: "content",
		active:false
	});
	$(".ui-accordion-content").css("height","auto");
	$(".ui-accordion-header").find(".ui-icon").css("float","left");	
}


/*
 * Detach a derived requirement from the structure
 */
function removeSelectedObjects()
{
	var treeDivs = $("div[id^='tree']");
	var treeTgts = $("div[id^='treeTarget']");
	var treeSrc  = $("div[id^='treeSource']");
	// We check the selected nodes of all trees
	for(var i = 0; i < treeDivs.size(); i ++)
	{
		var selectedNodes = $(treeSrc[i]).dynatree("getSelectedNodes");
		if(selectedNodes != null && selectedNodes.length >0)
		{
			//if at least one of the objects isn't a derived we display an error message
			if(!isNodeDerivedReq(selectedNodes))
			{
				alert("This command is not available for this kind of object(s)");
				break;
			}
			else{
				// We detach the objects
				for(var k=0; k < selectedNodes.length; k++)
				{
					var sNode 		= selectedNodes[k];
					var sKey  		= sNode.data['key'];
					var sKeys		= sKey.split('|');
					var sId 		= sKeys[0]; // object Id
					var sRelId		= sKeys[1]; // relationship Id
					var sParentId	= sKeys[2]; // Parent Id
					var srcKey		= "";
					var tgtKey		= "";
					
					if(derivationMode == 'satisfy')
					{
						//The key is to/relId/from
						srcKey = sKey;
						//The key is from/relId/to
						tgtKey = sParentId + '|' + sRelId + '|' + sId;
					}
					else if(derivationMode == 'cover')
					{
					
						//The key is from/relId/to
						srcKey = sKey;
						//The key is to/relId/from
						tgtKey = sParentId + '|' + sRelId + '|' + sId;
					}
					
					//If the current tree is the source
					if((treeDivs[i].getAttribute('id')).indexOf("Source") != -1)
					{
						
						//Disconnect relationship
						emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=DeleteDerivationLinks&relId="+sRelId+"");
						
						//We need to remove the selected node ... 
						sNode.remove();
						
						//...but also all its occurence in the targets trees
						if(treeTgts != null && treeTgts.length>0)
						{
							for(var j=0; j < treeTgts.length ; j++)
							{
								var nodeToRemove = $(treeTgts[j]).dynatree("getTree").getNodeByKey(tgtKey);
								if(nodeToRemove != null)
									nodeToRemove.remove();
							}
						}

					    //Refresh Derived Count
						refreshTable(sParentId,sId);
						
					}
					//The current tree is a Target
					else{
						//Disconnect relationship
						emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=DeleteDerivationLinks&relId="+sRelId+"");
						
						//We need to remove the selected node ... 
						sNode.remove();
						
						//...but also all its occurence in the source tree
						if(treeSrc != null && treeSrc.length>0)
						{
							for(var j=0; j < treeSrc.length ; j++)
							{
								var nodeToRemove = $(treeSrc[j]).dynatree("getTree").getNodeByKey(srcKey);
								if(nodeToRemove != null)
									nodeToRemove.remove();
							}
						}

					    //Refresh Derived Count
						refreshTable(sParentId, sId);
					}
					
				}
			}
			
		}
	}
}

/*
 * Check if selected nodes contains only derived requirement
 * Returns False if at least one object is not a derived requirement
 */
function isNodeDerivedReq(selectedNodes)
{
	var isSelectionOK = true;
	//we verify that all objects selected are derived requirement
	for(var n=0; n < selectedNodes.length; n++)
	{
		var isDerivedReq = selectedNodes[n].data['isDerived'];
		if(isDerivedReq == null || isDerivedReq == 'false')
		{
			isSelectionOK = false;
		}
		
	}
	return isSelectionOK;
}

function drawDnDArrow(canvas, color , startPoint , EndPoint){
	
	ctx.beginPath();
	// line style
	ctx.strokeStyle = color;
	ctx.fillStyle = color;
	//draw the line
	ctx.moveTo(startPoint.x,startPoint.y);
	ctx.lineTo(EndPoint.x,EndPoint.y);
	ctx.stroke();
	
	//draw the starting arrowhead
	var radians = Math.atan((EndPoint.y - startPoint.y)/(EndPoint.x - startPoint.x));
	radians += ((EndPoint.x > startPoint.x) ? 90 : -90)*Math.PI / 180;
	
	drawArrowHead(EndPoint.x, EndPoint.y, radians);
		
}

function drawArrowHead(x, y, radians){
	ctx.save();
	ctx.beginPath();
	ctx.translate(x,y);
	ctx.rotate(radians);
	ctx.moveTo(0,0);
	ctx.lineTo(8,20);
	ctx.lineTo(-8,20);
	ctx.closePath();
	ctx.fill();
	ctx.restore();
}; 


String.prototype.chunk = function(n) {
    var ret = [];
    for(var i=0, len=this.length; i < len; i += n) {
       ret.push(this.substr(i, n));
    }
    return ret;
}; 

/*
 * Creates a new target div., initialises dynatree functionnalities and displays the structure.
 */
function initandDisplayTarget(objectId) {
    var marginTopTgt = "";
    var marginTopTgtLabel = "";
    if (derivationMode == "satisfy") {
        marginTopTgt = "75";
        marginTopTgtLabel = "20";
    } else {
        marginTopTgt = "55";
        marginTopTgtLabel = "15";
    }

    var derivTreeTarget = '#treeTarget' + derivTreeNumber + '';
    var targetHeight = (60*getDerivationDlgHeight()/100) - marginTopTgtLabel;
    //var targetHeight = $("#derivationContainer").height() - 87 - marginTopTgtLabel;

    // HAT1 ZUD: IR-398826-3DEXPERIENCER2017x: fix
    //Width of sub container as per number of tree in di #derivationSubContainer.
    var widthSubContainer = (195 * (derivTreeNumber)) + "px";
    $("#derivationSubContainer").css("min-width", widthSubContainer);
    
    
    if (derivTreeNumber == 1) {
        $("#derivationSubContainer").append('<div id="treeTarget' + derivTreeNumber +
            '" style="float:left;list-style-type:none;margin-left:20px;margin-top:' + marginTopTgt +
            'px;height:' + targetHeight + 'px;scroll:auto; width:180px"></div>');

        goDynatreeTarget(derivTreeTarget, derivationMode);
        construcFirstDerivTree(derivTreeTarget, objectId, 'yes');

    } else {
        $("#derivationSubContainer").append('<div id="treeTarget' + derivTreeNumber +
            '" style="float:left;list-style-type:none;margin-left:10px;margin-top:' + marginTopTgt +
            'px;height:' + targetHeight + 'px;scroll:auto; width:180px"></div>');

        goDynatreeTarget(derivTreeTarget, derivationMode);
        construcFirstDerivTree(derivTreeTarget, objectId, 'yes');

    }

    // makes the source resizable horizontal only
    $("#treeTarget" + derivTreeNumber).resizable({
        handles: 'e,w'
    });



    derivTreeNumber++;

}

function decodeSpecialCharAsHTML(encoded){
	
	return decodeURIComponent(encoded);
}

// ++ IR-364087-3DEXPERIENCER2016x existing dependency Target Reqspecs
function existingDependTargetReqSpecs(objectId)
{

	var dataXML = emxUICore.getXMLData("../requirements/RequirementUtil.jsp?mode=existingDependTargetReqSpecs&objectId="+objectId+"&derivationMode="+derivationMode);

	var rows 	= $(dataXML).find("r");

	for(var i=0; i < rows.length;i++)
	{	var relatedReqSpecIds 		= rows[i].getAttribute('o');
		initandDisplayTarget(relatedReqSpecIds);	
	}
	
	
}

$(window).resize(function(event){
	if(window != event.target) { //IR-532314-3DEXPERIENCER2018x: resizing trees somehow triggers window resize event
		return;
	}
	var newDlgHeight 	= getDerivationDlgHeight();
	var newDlgWidth 	= getDerivationDlgWidth();
	$('#derivationDialog').dialog('option', 'height', newDlgHeight);
	$('#derivationDialog').dialog('option', 'width', newDlgWidth);
	resizeStopDerivationDialog();
	
	
});
// -- IR-364087-3DEXPERIENCER2016x existing dependency Target Reqspecs
getTopWindow().sb.initandDisplayTarget = initandDisplayTarget;
