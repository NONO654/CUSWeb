

var viewer;
var channel3dPlayFrame 	= null;

var shiftMode = false; 
var ctrlMode = false;

function docOnKey(ev) {
	  var e = ev || window.event;
	  var keycode = e.keyCode || e.which || 0;
	  switch (e.keyCode) {
	    case 16:
	      shiftMode = (e.type == "keydown"); 
	      break;
	    case 17:
	      ctrlMode = (e.type == "keydown");
	      break;
	  }
	}



function subscribe(curViewer, status) {
	
	
	if (curViewer != undefined)	
		viewer = curViewer;
	if (viewer != undefined) {
		
		if(status)
			viewer.addSelectionCB(selectCB);
		else
			viewer.removeSelectionCB(selectCB);	
	}			
}





function checkParent(id,oXML){
	var ids = id.split("/");
	var path ="";
	var ids1 =[];
	
	for(var k=ids.length-4;k>=0;k--) {
		
		path=ids[k]+"/"+path;
		ids1.push(ids[k]);
	}
	
	var checkObject = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r//c[text()='"+path.substring(0,path.lastIndexOf("/"))+":3dPlayKeyIdPath']/parent::r");

	if(checkObject == null || typeof checkObject =='undefined' && ids1.length>=3) {
		checkObject = checkParent(path,oXML);
	}
	
	return checkObject;
}




function getIdFromIdPath3dPlay(idPath1, EventName) {
	console.log('inside the getIdPatj');
	
	
	
	var sbFrame;
	var oXML;
	var checkObject;
	var tempAddRowIds = new Array();
	var tempDelRowIds = new Array();
	var addCounter = 0;
	var deleteCounter = 0;
	
	//var idPath = "";
	var tempArr;
	var strRel = "";
	var flag = false;
	var tempIdArr;
	
	sbFrame =findFrame(getTopWindow(), "ENCBOM");
	
	
		oXML 	= sbFrame.oXML;
	
	
  	
for(var k = 0; k<idPath1.length;k++){
	
	
	
				idPath 	= idPath1[k];
				
				
					tempArr = idPath.split("/");
					
					strRel 	= tempArr[tempArr.length-1];
					
					tempIdArr = strRel.split(".");
					if(tempIdArr.length == 5) {
						strRel = strRel.substring(0, strRel.lastIndexOf("."));
					}
					var id="";
					var ids= []
					
					if(tempArr.length%2 == 0) {
					
					for(var i=0;i<tempArr.length-3;i++) {
						
						id+=tempArr[i]+"/";
						ids.push(tempArr[i]);
					}
					
					}else {
						
						for(var i=0;i<tempArr.length;i++) {
							
							id+=tempArr[i]+"/";
							ids.push(tempArr[i]);
						}
						
					}
					
					
					checkObject = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r//c[text()='"+id.substring(0,id.lastIndexOf("/"))+":3dPlayKeyIdPath']/parent::r");
					
					
					
					var path ="";
					var parent;
					if(checkObject == null || typeof checkObject =='undefined') {
					
						parent = checkParent(id,oXML);
					
					
					}
					
					//checkObject(ids);
					
					
					console.log("path "+path);
					
					
					
					var nSelRow = checkObject;
					
					//Check the node and expand nodes
					if(sbFrame.isStructureCompare != "TRUE") { 
							
							var expandRow = parent;
							if(expandRow != null) {
								var expandC = expandRow.getAttribute("expand");
								if(expandC == null || (typeof expandC == 'undefined')){
									var parentLevel = expandRow.getAttribute("level");
									var parentRowIdArr = new Array();
									parentRowIdArr[0] = expandRow.getAttribute("id");
									sbFrame.emxEditableTable.expand(parentRowIdArr, parentLevel);
								} else if(expandC == 'true') {
									expandRow.setAttribute("display","block");
								}
		
								checkObject = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r//c[text()='"+id.substring(0,id.lastIndexOf("/"))+":3dPlayKeyIdPath']/parent::r");

							}
		
					
					}
					
					/*if(tempArr.length != 1) {
						nSelRow = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@r = '" + strRel + "']");
						if(!nSelRow) {
							nSelRow = emxUICore.selectSingleNode(oXML, "/mxRoot/rows//r[@r2 = '" + strRel + "']");
						}
					}*/
					
	
				//	if(typeof nSelRow!='undefined' && nSelRow!=null) {
						var nSelRowId = checkObject.getAttribute("id");
						if (EventName == "ADD") {
							tempAddRowIds[addCounter++] = nSelRowId;
						} else if (EventName == "REMOVE") {
							tempDelRowIds[deleteCounter++] = nSelRowId;
						}
				//	}
						
					if(tempDelRowIds.length > 0) {
						sbFrame.emxEditableTable.unselect(tempDelRowIds, false);
					}
					
					if(tempAddRowIds.length > 0) {
						sbFrame.emxEditableTable.select(tempAddRowIds, false);
					}
				 
			
			}
			
	
	return true;
	
	
}


toggle = true;


function selectCB(CSOaction, idPathTable) {
	
	
	getIdFromIdPath3dPlay(idPathTable,CSOaction);
	
}


function toggleSelect(viewer, flag, idPath) {
	
	var idTable = [];
	idTable.push(idPath);
	
	if(flag) {
		toggle = false;
		try {
		viewer.selectNode(idTable);
		}catch(e) {
			console.log(e);
		}
	
	}else {
		toggle = false;
		try {
		viewer.unselectNode(idPath);
		}catch(e) {
			console.log(e);
		}
		
	}
	
}




function crossHighlight3DPlay(rowIds, flag) {
		
	
	var strIDs = rowIds.split(":");
	
	var aId = "";
	var rowId = "";
	var rowNode = null;
	var idPath = "";
	var idPath1 = "";
	var idTable = [];
	if(channel3dPlayFrame == null) {
		
		channel3dPlayFrame 	= findFrame(getTopWindow(),"APPLaunch3DPlayChannel");
		viewer = channel3dPlayFrame.viewer;
		}
	
	if(typeof channel3dPlayFrame != 'undefined' && channel3dPlayFrame != null) {
		for (var i = 0; i < strIDs.length; i++) {
			
			
			aId = strIDs[i].split("|");
		    rowId = aId[3];
		    
		    console.log('aId is '+aId+', and rowId is '+rowId);
		    
		    
		    var enc =findFrame(getTopWindow(), "ENCBOM");
		    
			rowNode = emxUICore.selectSingleNode(enc.oXML, "/mxRoot/rows//r[@id = '" + rowId + "']");
			
			subscribe(viewer, false);	
			
			var children = rowNode.children;
		
			for(var j=0;j<children.length;j++) {
				var attr = children[j].getAttribute("a");
				if(attr!=null && typeof attr != 'undefined' && attr.contains("3dPlayKeyIdPath")){
				idPath1 = attr.substring(0,attr.indexOf(":3dPlayKeyIdPath"));
				console.log(idPath1);
				idTable.push(idPath1);
				}
			}
			
			
			if(flag) {
			
			
			viewer.selectNode(idTable);
			
			} else {
			
				viewer.unselectNode(idPath1);
			}
			
		
			subscribe(viewer, true);	
			
		
			
			
			
		}
	
	}

}



function getCurrentValue(colName, currentObj,flag) {
	 var aRows = new Array();
   aRows[0] = currentObj;

   var objColumn = colMap.getColumnByName(colName);

   var colIndex = objColumn.index;
   var lastobj = emxUICore.selectSingleNode(currentObj, "c[" + colIndex + "]").lastChild;
   var retValue = "";
   if (lastobj) {
       retValue = emxUICore.getText(lastobj);
   }
   return (retValue);
	}

