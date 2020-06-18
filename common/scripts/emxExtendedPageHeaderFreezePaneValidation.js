
/*******************************************************************************
 * emxExtendedPageHeaderFreezePaneValidation.js
* Drag & Drop Capabilities for Documents in Page Header
*******************************************************************************/
var emxExtendedPageHeaderFreezePaneValidation={};

var onDropBefore;
var onDropProgress = function(){alert(emxUIConstants.STR_FILE_UPLOAD_IN_PROGRESS); return};

function FileDragHover(e, id) {
	e.stopPropagation();
	e.preventDefault();
	var div = document.getElementById(id);
	if(div.className == "dropProgressColumn") {return;}
	if(e.type == "dragover") 	{ div.className = "dropTarget";		}
	else if(e.type == "drop")	{ div.className = "dropProgress";	}
	else 						{ div.className = "dropArea";		}
}
function FileDragHoverColumn(e, id) {
	e.stopPropagation();
	e.preventDefault();
	var div = document.getElementById(id);
	if(div.className == "dropProgressColumn") {return;}
	if(e.type == "dragover") 	{ div.className = "dropTargetColumn";	}
	else if(e.type == "drop")	{ div.className = "dropProgressColumn";	}
	else 						{ div.className = "dropAreaColumn";		}
}
document.addEventListener("dragenter", function(event) {
event.preventDefault(); 
	event.stopPropagation();
});
document.addEventListener("ondragover", function(event) {
event.preventDefault(); 
event.stopPropagation();
});
document.addEventListener("ondragleave", function(event) {
event.preventDefault(); 
event.stopPropagation();
}); 


function FileSelectHandlerHeader(e, idTarget, idForm, idDiv, refresh, relationships) {
	onDropBefore = document.getElementById(idDiv).ondrop;
	document.getElementById(idDiv).ondrop = onDropProgress;
	FileDragHover(e, idDiv);
	FileSelectHandler(e, idTarget, idForm, idDiv, refresh, "", "", "", "", relationships, "", "", "", "", "dropArea");
}
function FileSelectHandlerColumn(e, idTarget, idForm, idDiv, refresh, levelTarget, parentDrop, typeDrop, types, relationships, attributes,directions,typesStructure,validator) {
	
	onDropBefore = document.getElementById(idDiv).ondrop;
	document.getElementById(idDiv).ondrop = onDropProgress;

	FileDragHoverColumn(e, idDiv);
	FileSelectHandler(e, idTarget, idForm, idDiv, refresh, levelTarget, parentDrop, typeDrop, types, relationships, attributes, directions,
			typesStructure,validator, "dropAreaColumn");
}

/**
 * 	PRIVATE function.
 *
 *  Do no invoke directly. Configure Validate=yourFunction setting on the table column instead.
 *
 * @param validator is a name of function.
 * @param inputs is a collection of arguments.
 * @returns if validation is ok, return success otherwise return error.
 */
function validate(validator, inputs){
	var isValidated = {
			status: "",
			error: ""
	};

	//If there is no validate function defined, assume success
	if(validator == "" || validator == undefined || validator == null) {
		isValidated.status = "success";

	} else {
		var fn = eval(validator);
		isValidated = fn(inputs);
		//the Validate function configured on the setting Validate must return a JSON similar to isValidated var of this function.
	}

	return isValidated;
}

function FileSelectHandler(e, idTarget, idForm, idDiv, refresh, levelTarget, parentDrop, typeDrop, types, relationships, attributes,
		directions,typesStructure,validator, dropZoneClass) {

	e.preventDefault();
	e.stopPropagation();

	var webApp = "webApplication";
	var OS = "OperatingSystem";

	var files = e.target.files || e.dataTransfer.files;
	try{
		if(isEdge && e.dataTransfer.items[0].kind == "string"){
			files = [];
		}
	}catch(e){}
	var dragFrom = (files.length == 0) ? webApp : OS;
    
	if(dragFrom == webApp && refresh == "divExtendedHeaderDocuments") {
		document.getElementById(idDiv).className = "dropArea";
		alert(emxUIConstants.UNSUPPORTED_OPERATION);
		return;
	}
	

	if(dragFrom == webApp) {
		var data		= e.dataTransfer.getData("Text");
		var params 		= data.split("_param=");
		var idDiv 		= params[1];
		var idDrag 		= params[2];
		var relDrag		= params[3];
		var levelDrag	= params[4];
		var parentDrag	= params[5];
		var typeDrag	= params[6];
		var kindDrag	= params[7];
		var refSave		= refresh;

		var inputs = {
				targetObjectId: idTarget,
				targetObjectLevel: levelTarget,
				targetObjectType: typeDrop,
				parentDropObjectId: parentDrop,

				draggedObjectId: idDrag,
				draggedObjectLevel: levelDrag,
				draggedObjectType: typeDrag,
				parentDragObjectId: parentDrag
		};

		var isValidated = validate(validator, inputs);

		if(isValidated.status === "error"){
			alert(isValidated.error);
			var level = refresh.substring(10);

			if((refresh.indexOf(".refreshRow") != -1)) {
				level = level.replace(".refreshRow", "");
				emxEditableTable.refreshRowByRowId(level);
			} else {
				level = level.replace(".expandRow", "");
				emxEditableTable.refreshRowByRowId(level);
			}
			return;
		}else if(isValidated.status === "success"){
		if(idDiv != idDrag) {

			var frameElement;
			var ctrlKey = "false";
			if(e.ctrlKey) { ctrlKey = "true"; }

			if(refresh.indexOf("id[level]=") == -1) {
				refresh = "header";
				frameElement = getTopWindow().document.getElementById("hiddenFrame");
			} else {
				frameElement = document.getElementById("listHidden");
			}

			var url = "../common/emxColumnDropProcess.jsp?idDrag=" + idDrag +
				"&idTarget=" + idTarget +
				"&relDrag=" + relDrag +
				"&levelDrag=" + levelDrag +
				"&levelTarget=" + levelTarget +
				"&parentDrag=" + parentDrag +
				"&parentDrop=" + parentDrop +
				"&typeDrag=" + typeDrag +
				"&kindDrag=" + kindDrag +
				"&typeDrop=" + typeDrop +
				"&relType=" +
				"&types=" + types +
				"&relationships=" + relationships +
				"&attributes=" + attributes +
				"&directions=" + directions +
				"&refresh=" + refresh +
				"&ctrlKey=" + ctrlKey +
				"&typesStructure=" + typesStructure;

				frameElement.src = encodeAllHREFParameters(url);

			if(refresh.indexOf("id[level]=") == -1) {
				refreshPageHeader(refSave);
			}
		}

		var div = document.getElementById(idDiv);
		div.className = "dropAreaColumn";
		}
		 deletePageCache();
	var url = parent.getTopWindow().findFrame(parent.getTopWindow(),"detailsDisplay").location.href;
	url = url.replace("persist=true","");
	parent.getTopWindow().findFrame(parent.getTopWindow(),"detailsDisplay").location.href = url;
	} else {

		var restrictedFileFormats = emxUIConstants.RESTRICTED_FILE_FORMATS;
		var supportedFileFormats = emxUIConstants.SUPPORTED_FILE_FORMATS;
		restrictedFileFormats = restrictedFileFormats.toLowerCase();
		supportedFileFormats = supportedFileFormats.toLowerCase();

		var restrictedFileFormatArr = restrictedFileFormats.split(",");
	    var supportedFileFormatArr;

	    if(supportedFileFormats != ""){
	    	supportedFileFormatArr = supportedFileFormats.split(",");
	    }

	    for (var i = 0, ff; ff = files[i]; i++) {
	    	 var fileName = ff.name;
	    	 var badchar=emxUIConstants.FILENAME_BAD_CHARACTERS;
	    	 badchar = badchar.split(" ");
	    	 var badCharName = checkStringForChars(fileName,badchar,false);
	    	    if (badCharName.length != 0)
	    	    {
	    	        alert(emxUIConstants.INVALID_FILENAME_INPUTCHAR + badCharName + emxUIConstants.FILENAME_CHAR_NOTALLOWED + emxUIConstants.FILENAME_BAD_CHARACTERS + emxUIConstants.FILENAME_INVALIDCHAR_ALERT);
	    	        document.getElementById(idDiv).className = dropZoneClass;
	    	        return;
	    	    }
	    	 var fileExt = fileName.substring(fileName.lastIndexOf(".")+1, fileName.length);
			 // check file extn with ignore case
	    	 if(jQuery.inArray(fileExt.toLowerCase(), restrictedFileFormatArr) >= 0){
	    		 alert(emxUIConstants.RESTRICTED_FORMATS_ALERT + restrictedFileFormats);
	    		 document.getElementById(idDiv).className = dropZoneClass;
	    		 return;
	    	 }

	    	 if( supportedFileFormatArr && jQuery.inArray(fileExt.toLowerCase(), supportedFileFormatArr) < 0){
	    		 alert(emxUIConstants.SUPPORTED_FORMATS_ALERT + supportedFileFormats);
	    		 document.getElementById(idDiv).className = dropZoneClass;
		    	 return;
	    	 }
		}

		var divHeight		= 60;
		var div 			= document.getElementById(idDiv);
		div.style.padding 	= "0px";
		var filesSize 		= 0;
		var filesSizeDone	= 0;

		if(div.className == "dropProgressColumn") { divHeight = "20"; }
		if(dropZoneClass === "dropAreaColumn"){
			div.innerHTML = "<div style='width:100%;'></div><div class='dropProgressColumn' style='width:100%;" + divHeight + "px'></div>";
		}else{
			div.innerHTML = "<div style='width:100%;'></div><div class='dropProgressHeader' style='width:100%;" + divHeight + "px'></div>";
		}

			UploadFile(files, idForm, refresh, div, null, idTarget);
			}
	}

function UploadFile(files, id, idRefresh, dropAreaDiv, idImage, idTarget) {
	var webApp = "webApplication";
	var OS = "OperatingSystem";
	var dragFrom = (files.length == 0) ? webApp : OS;
	if(dragFrom == webApp && idRefresh == "divExtendedHeaderImage"){
		alert(emxUIConstants.UNSUPPORTED_OPERATION);	
	}
	var url = document.getElementById(id).action;
	if(idRefresh != undefined) {
		if(idRefresh.indexOf(".refreshRow") == -1 && idRefresh.indexOf(".expandRow") == -1) {
			url += "&refresh=true";
		}
	}
		var formData = new FormData();
		jQuery.each(files, function(k, file) {
			formData.append('file_'+k, file);
		});

	jQuery.ajax({
		url : url,
		type: "POST",
		data : formData,
		cache: false,
		contentType: false,
		processData: false,
		success: function(data){
			if(data.trim().match("^ERROR")){
				uploadFileError(data, dropAreaDiv, idImage);
				return;
			}
			uploadFileExtendedPageHeaderRefresh(data, idRefresh, idTarget);
			uploadFileDetailsRefresh(idRefresh);
		},
	});

	}


/*******************************************************************************
* Drag & Drop Capabilities for Images in Page Hader
*******************************************************************************/
function ImageDragHover(e, id) {

	e.stopPropagation();
	e.preventDefault();

	var div 	= document.getElementById(id);

	if(e.type == "dragover") 	{ div.className = "dropTarget";			}
	else if(e.type == "drop")	{ div.className = "dropProgressImage";	}
	else 						{ div.className = "dropArea";			}

}
function ImageDragHoverWithImage(e, id, idImage) {

	e.preventDefault();
	e.stopPropagation();

	var div 		= document.getElementById(id);
	var divImage 	= document.getElementById(idImage);

	if(e.type == "dragover") 	{ div.className = "dropTargetWithImage";	divImage.style.opacity = '0.2';	}
	else if(e.type == "drop")	{ div.className = "dropProgressWithImage";	divImage.style.opacity = '0.0';	}
	else 						{ div.className = "dropAreaWithImage";		divImage.style.opacity = '1.0';	}

}
function ImageDrop(e, idForm, idDiv) {
	ImageDragHover(e, idDiv);
	FileSelectHandlerImage(e, idForm, idDiv, "divExtendedHeaderImage");
}
function ImageDropOnImage(e, idForm, idDiv, idImage) {
	ImageDragHoverWithImage(e, idDiv, idImage);
	FileSelectHandlerImage(e, idForm, idDiv, "divExtendedHeaderImage", idImage);
}
function FileSelectHandlerImage(e, idForm, idDiv, idRefresh, idImage) {

	var div 			= document.getElementById(idDiv);
	var onlyImages 		= true;
	var files 			= e.target.files || e.dataTransfer.files;
	for (var i = 0, f; f = files[i]; i++) {
		var filename 		= f.name;
		var fileSuffix 		= filename.split('.').pop();
		var fileExtensions	= emxUIConstants.IMAGE_ALLOWED_FORMATS;
		if(fileExtensions.indexOf(fileSuffix.toLowerCase()) == -1) {
			alert(emxUIConstants.INVALID_IMAGE_EXTENSION_MESSAGE + fileExtensions);
			onlyImages = false;
			break;
		}
	}
		if(onlyImages) {
			UploadFile(files, idForm, idRefresh, div, idImage);
		} else {
			if(div.className == "dropProgressWithImage"){
				div.className = "dropAreaWithImage";
				jQuery('#'+idImage).css('opacity','1.0');
			}else{
			div.className = "dropArea";
		}
		}
}

/*******************************************************************************
* Additions for Drag & Drop Capabilities for Images in Columns
*******************************************************************************/
function ImageDropColumn(e, idForm, idDiv, rowId) {
	ImageDragHover(e, idDiv);
	FileSelectHandlerImageColumn(e, idForm, idDiv, rowId);
}
function ImageDropOnImageColumn(e, idForm, idDiv, idImage, rowId) {
	ImageDragHoverWithImage(e, idDiv, idImage);
	FileSelectHandlerImageColumn(e, idForm, idDiv, rowId);
}
function FileSelectHandlerImageColumn(e, idForm, idDiv, rowId) {

	var div 			= document.getElementById(idDiv);
	var onlyImages 		= true;
	var files 			= e.target.files || e.dataTransfer.files;

	for (var i = 0, f; f = files[i]; i++) {
		var filename 		= f.name;
		var fileSuffix 		= filename.split('.').pop();
		var fileExtensions	= "jpg,jpeg,png,gif,JPG,JPEG,Jpeg,GIF,BMP,bmp";
		if(fileExtensions.indexOf(fileSuffix) == -1) {
			alert("Only files of format JPG, PNG or GIF are supported!");
			onlyImages = false;
			break;
		}
	}

	if(onlyImages) {

        UploadFile(files, idForm);
		if(rowId != "") {
			emxEditableTable.refreshRowByRowId(rowId);
		} else {
			document.location.href = document.location.href;
		}
	} else {
		div.className = "dropAreaImage";
	}
}

/*******************************************************************************
* Drag & Drop Capabilities for Database Objects
*******************************************************************************/
function handleNoDropBusinessObject(e, id) {

	alert("You cannot drop this item here!");


	hideTarget(e, id);

}
function handleDropBusinessObject(e, id, idTarget, levelTarget, parentDrop, typeDrop, types, relationships, attributes, from) {

	e.preventDefault();
	e.stopPropagation();

	var data		= e.dataTransfer.getData("Text");
	var params 		= data.split("_param=");
	var idDiv 		= params[1];
	var idDrag 		= params[2];
	var relDrag		= params[3];
	var levelDrag	= params[4];
	var parentDrag	= params[5];
	var typeDrag	= params[6];
	var kindDrag	= params[7];

	if(idDiv != id) {

		var url = "../common/GNVColumnMoveProcess.jsp?idDrag=" + idDrag +
			"&idTarget=" + idTarget +
			"&relDrag=" + relDrag +
			"&levelDrag=" + levelDrag +
			"&levelTarget=" + levelTarget +
			"&parentDrag=" + parentDrag +
			"&parentDrop=" + parentDrop +
			"&typeDrag=" + typeDrag +
			"&kindDrag=" + kindDrag +
			"&typeDrop=" + typeDrop +
			"&relType=" +
			"&types=" + types +
			"&relationships=" + relationships +
			"&attributes=" + attributes +
			"&from=" + from;

		document.getElementById("listHidden").src = url;

	}

	hideTarget(e, id);

}
function toggleDropZone(e, id, color) {

	e.stopPropagation();
	e.preventDefault();

	var div			= document.getElementById(id);
	var imgDrag		= document.getElementById("imgDrag" + id);
	if(color == null) { color = "green"; }

	if(e.type == "dragover") {
		div.style.background 		= color;
		imgDrag.style.display 		= "none";
		imgDrag.style.visibility 	= "hidden";
	} else {
		div.style.background 		= "transparent";
		imgDrag.style.display 		= "block";
		imgDrag.style.visibility 	= "visible";
	}

}

function hideTarget(e, id) {

	e.stopPropagation();
	e.preventDefault();

	$("#drag" + id).html("&#xe008;");
	$("#drag" + id).css("color", "#336699");
}

function showTarget(e, id) {

	e.stopPropagation();
	e.preventDefault();

	var data		= e.dataTransfer.getData("Text");
	var params 		= data.split("_param=");
	var idDiv 		= params[1];

	if(idDiv != id) {
		$("#drag" + id).html("&#xe033;");
		$("#drag" + id).css("color", "#cc0000");
	} else {
		//$("#drag" + id).css("color", "#cc0000");
	}

}
function setDropTarget(e, id, text, color) {

	e.stopPropagation();
	e.preventDefault();

	$("#drag" + id).html(text);
	$("#drag" + id).css("color", color);

}

/*******************************************************************************
* Dynamic ranges for Structure Browser
*******************************************************************************/
function reloadRangeValuesForType()   { emxEditableTable.reloadCell("Type");   }
function reloadRangeValuesForPolicy() { emxEditableTable.reloadCell("Policy"); }


function refreshWholeTree(e, oID, documentDropRelationship, documentCommand, showStatesInHeader, sMCSURL, imageDropRelationship, headerOnly, imageManagerToolbar, imageUploadCommand,showDescriptionInHeader){

		if(e.data && e.data.headerOnly){
			headerOnly=e.data.headerOnly;
		} 
		if(imageManagerToolbar == undefined || imageManagerToolbar == null){
			imageManagerToolbar = "";
		}
		if(imageUploadCommand == undefined || imageUploadCommand == null){
			imageUploadCommand = "";
		}

		var url = "../common/emxExtendedPageHeaderAction.jsp?action=refreshHeader&objectId="+oID+"&documentDropRelationship="
					+documentDropRelationship+"&documentCommand="+documentCommand+"&showStatesInHeader="+showStatesInHeader
					+"&imageDropRelationship="+imageDropRelationship+"&MCSURL="+sMCSURL+"&imageManagerToolbar="+imageManagerToolbar+"&imageUploadCommand="+imageUploadCommand+"&showDescriptionInHeader="+showDescriptionInHeader;

		jQuery.ajax({
		    url : url,
		    cache: false
		})
		.success( function(text){
			if (text.indexOf("#5000001")>-1) {
				var wndContent = getTopWindow().findFrame(getTopWindow(), "detailsDisplay");
				if (wndContent) {
					var tempURL ="../common/emxTreeNoDisplay.jsp";
					wndContent.location.href = tempURL;
				}

			}else {
			jQuery('#ExtpageHeadDiv').html(text);
			if(!headerOnly){
			getTopWindow().emxUICategoryTab.redrawPanel();
			}

			var extpageHeadDiv = jQuery("#ExtpageHeadDiv");
			if(extpageHeadDiv.hasClass("page-head")){
				jQuery(".mini").addClass("hide");
				jQuery(".full").removeClass("hide");
			}
			else{


				jQuery(".full").addClass("hide");
				jQuery(".mini").removeClass("hide");
			}
			adjustNavButtons();
			if (!headerOnly) {
				var objStructureFancyTree = getTopWindow().objStructureFancyTree;
				if(objStructureFancyTree && getTopWindow().bclist && getTopWindow().bclist.getCurrentBC().fancyTreeData){
					objStructureFancyTree.reInit(getTopWindow().bclist.getCurrentBC().fancyTreeData, true);
				}else{
				refreshStructureTree();
				}
				var wndContent = getTopWindow().findFrame(getTopWindow(), "detailsDisplay");
				if (wndContent) {
					var tempURL = wndContent.location.href;
					tempURL = tempURL.replace("persist=true","persist=false");
					if(isIE){
						/*for (var property in wndContent)
						{
						   if (property != 'name' && wndContent.hasOwnProperty(property))
								   wndContent[property] = null;
						}*/
						wndContent.document.body.innerHTML = "";
						wndContent.document.head.innerHTML = "";
					}
					wndContent.location.href = tempURL;
				}
			}
		}
		});
}

function showAppMenu() {

    var position    = $("#buttonAppMenu").offset();
    var posLeft     = position.left + $("#buttonAppMenu")[0].offsetWidth;
    var posTop = position.top + $("#buttonAppMenu")[0].offsetHeight;

    $('#mydeskpanel').bind("mouseenter", function() {
        $("#mydeskpanel").show();
    });

    this.fnTemp = fnTemp = function (e) {
  		var target= e.target;
  		if(target && jQuery(target).closest(".appMenu").length ==0) {
  			hideAppMenu();
  		}
								};


    emxUICore.iterateFrames(function (objFrame) {
    	if(objFrame){
    		 emxUICore.addEventHandler(objFrame,"mousedown", fnTemp, false);
                if (!isUnix)  emxUICore.addEventHandler(objFrame,"resize", fnTemp, false);
    	}
    });



    $('#mydeskpanel').css("top", posTop + "px");
    $('#mydeskpanel').css("left", posLeft);
    $('#mydeskpanel').addClass("appMenu");
    $("#mydeskpanel").show();

}
function hideAppMenu() {

	 emxUICore.iterateFrames(function (objFrame) {
     	if(objFrame){
     		  emxUICore.removeEventHandler(objFrame, "mousedown", fnTemp, false);
				  if (!isUnix)emxUICore.removeEventHandler(objFrame, "resize", fnTemp, false);
     	}
     });
	 if($('#mydeskpanel').hasClass("appMenu")){
		 $("#mydeskpanel").hide(); }
}


//To show or hide extended page header
function toggleExtendedPageHeader(){
	var extpageHeadDiv = jQuery("#ExtpageHeadDiv");
	if(extpageHeadDiv.hasClass("page-head")){
		localStorage.setItem('minHeaderView',true);
		extpageHeadDiv.toggleClass("page-head").toggleClass("page-head-mini");
		extpageHeadDiv.css("height","");

		jQuery(".full").addClass("hide");
		jQuery(".mini").removeClass("hide");
	}else{
		localStorage.removeItem("minHeaderView");
		extpageHeadDiv.toggleClass("page-head-mini").toggleClass("page-head");
		jQuery(".mini").addClass("hide");
		jQuery(".full").removeClass("hide");
	}
	var offsetTop = parseInt(extpageHeadDiv.css("top"),10);
	if(offsetTop === 0)
	{
		offsetTop = extpageHeadDiv.offset().top;
	}
	var contentDiv = offsetTop + parseInt(extpageHeadDiv.css("height"),10);
	jQuery("#panelToggle").css("top",contentDiv);
	jQuery("#pageContentDiv").css("top",contentDiv);
	jQuery("#leftPanelMenu").css("top",contentDiv);
}

function showLifeCycleIcons(obj, showIcons){
	if(showIcons){
		$(obj).find("td#lifeCycleSectionId").css('visibility','visible');
	}else{
		$(obj).find("td#lifeCycleSectionId").css('visibility','hidden');
	}
}

function showIconMailDialog() {
	var searchURL = "../common/emxCompInboxDialogFS.jsp?suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common&widgetId=null&targetLocation=popup&mx.page.filter=unread";
	showModalDialog(searchURL, 500, 400);
}

//API to Refresh the Extended page header
function RefreshHeader() {
    var RefreshButton        = $(".refresh button");
	var cEvent  = $.Event("click");
    cEvent.data = {"headerOnly":true};
    if(isIE){
	setTimeout(function(){
    RefreshButton.parent().trigger(cEvent);
	}, 10);
	}else{
		RefreshButton.parent().trigger(cEvent);
	}
}

//API to delete the Page Cache
function deletePageCache() {
    var contentFrame = emxUICore.findFrame(getTopWindow(), "content");
    for(var ii = 0; ii < getTopWindow().CACHE_CATEGORIES_COUNT ; ii++){
        var temTab = contentFrame.document.getElementById("unique"+ii);
        if(temTab){	
			temTab.setAttribute("cachePage","false");
		}
    }
}

var clickOnExtHdState = false;
function lockPromoteOrDemote(promoteOrDemotelink, target) {
	turnOnProgress();
	if (!clickOnExtHdState) {
		clickOnExtHdState = true;
		jQuery('#' + target)[0].src = promoteOrDemotelink;
	}
}

function uploadFileError(data, dropAreaDiv, idImage){
	alert(data.trim().substring(5,data.length));
	var classNameBeforeUpload = dropAreaDiv.className;
	if(classNameBeforeUpload == "dropProgressWithImage"){
		dropAreaDiv.className = "dropAreaWithImage";
		jQuery('#'+idImage).css('opacity','1.0');
	}else if(classNameBeforeUpload == "dropProgressColumn"){
		dropAreaDiv.className = "dropAreaColumn";
		dropAreaDiv.ondrop = onDropBefore;
		var divElement =document.getElementsByClassName("dropProgressColumn")[0];
		if(divElement)
		{
			divElement.parentNode.removeChild(divElement);

		}
	}else {
		dropAreaDiv.className = "dropArea";
		dropAreaDiv.ondrop = onDropBefore;
	}
}

function uploadFileExtendedPageHeaderRefresh(data, idRefresh, idTarget){
	if(idRefresh != undefined) {
		if(idRefresh.indexOf(".refreshRow") == -1 && idRefresh.indexOf(".expandRow") == -1) {

			var headerDocCount;
			var regexPattern = /\(\s*(\d*)\s*\)$/;
			var headerDocId = "ext-doc-count";
			if(document.getElementById(headerDocId) !== null){
				headerDocCount = document.getElementById(headerDocId).value;
			}
			document.getElementById(idRefresh).innerHTML = data.trim();
			var objStructureFancyTree = getTopWindow().objStructureFancyTree;
			if(objStructureFancyTree && objStructureFancyTree.isActive && document.getElementById(headerDocId) !== null){
				var nodeExists = objStructureFancyTree.getNodeById(idTarget);
				var docCount  = document.getElementById(headerDocId).value;
				if(nodeExists){
					var nodeLabel = $('span.fancytree-title',nodeExists.li)[0].textContent;
					var rootNodeId = objStructureFancyTree.getRootNode().key;
					var matches = nodeLabel.match(regexPattern);
					var currentNodeCount;
					var incrCount;
					var updatedNodeLabel;
					if(headerDocCount == null){
						headerDocCount = 0;
					}
					incrCount = parseInt(docCount) - parseInt(headerDocCount);
					if(matches != null){
						currentNodeCount = matches[1];			
						docCount = incrCount + parseInt(currentNodeCount);
						updatedNodeLabel = nodeLabel.replace(regexPattern, "("+docCount+")");
					}else{
						updatedNodeLabel = nodeLabel+"("+incrCount+")";
					}

					getTopWindow().changeObjectLabelInTree(idTarget, updatedNodeLabel);
					var parentNodeList = nodeExists.getParentList();
					if(typeof parentNodeList != 'undefined' && parentNodeList && parentNodeList.length > 0){
						for(var j = 0; j < parentNodeList.length; j++){
							var nodeId = parentNodeList[j].key;
							if(nodeId != rootNodeId){
								var nodeTitle = $('span.fancytree-title',parentNodeList[j].li)[0].textContent;
								matches = nodeTitle.match(regexPattern);
								var updatedCount;
								if(matches != null){
									currentNodeCount = matches[1];
									updatedCount = parseInt(currentNodeCount) + parseInt(incrCount);
									updatedNodeLabel = nodeTitle.replace(regexPattern, "("+updatedCount+")");
								}else{
									updatedNodeLabel = nodeTitle+"("+incrCount+")";
								}
								getTopWindow().changeObjectLabelInTree(nodeId, updatedNodeLabel);
							}
						}
					}
				}
			}

		}
	}
}

function uploadFileDetailsRefresh(idRefresh){
	if(idRefresh != undefined) {
		if(idRefresh.indexOf("id[level]=") == 0) {
			var level = idRefresh.substring(10);
			// identify drop events in column with row refresh only
			//For both refreshrow and expandRow actions, the level has to be corrected.
			if((idRefresh.indexOf(".refreshRow") != -1)) {
				level = level.replace(".refreshRow", "");
				emxEditableTable.refreshRowByRowId(level);
			} else {
				level = level.replace(".expandRow", "");
				emxEditableTable.refreshRowByRowId(level);
				manualExpand=true;
				emxEditableTable.expand([level], "1");
			}
		}
		deletePageCache();
		var url = parent.getTopWindow().findFrame(parent.getTopWindow(),"detailsDisplay").location.href;
		url = url.replace("persist=true","");
		parent.getTopWindow().findFrame(parent.getTopWindow(),"detailsDisplay").location.href = url;
		div.ondrop = onDropBefore;
		var divElement = document.getElementById('tempDivForDropImage');
		if(divElement)
		{
			divElement.parentNode.removeChild(divElement);

		}
	}
}
