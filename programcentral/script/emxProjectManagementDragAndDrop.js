
/*******************************************************************************
* emxProjectManagementDragAndDrop.js
* Drag & Drop Capabilities for Documents in Form
*******************************************************************************/
var emxProjectManagementDragAndDrop={};

function FileDragHover(e, id) {
    e.stopPropagation();
    e.preventDefault();
    var div = document.getElementById(id);
    if(e.type == "dragover")    { div.className = "dropTarget";     }
    else if(e.type == "drop")   { div.className = "dropProgress";   }
    else                        { div.className = "dropArea";       }
}

var DIVLABEL = "";
function FileSelectHandlerForm(e, idTarget, idForm, idDiv, refresh, relationships, divLabel) {
         DIVLABEL = divLabel;
             FileSelectHandler(e, idTarget, idForm, idDiv, refresh, "", "", "", "", relationships, "", "", "", "", "dropArea");
}

/**
 *  PRIVATE function.
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

function FileSelectHandler(e, idTarget, idForm, idDiv, refresh, levelTarget, parentDrop, typeDrop, types, relationships, attributes,  directions,typesStructure,validator, dropZoneClass) {

    e.preventDefault();
    e.stopPropagation();

    var webApp = "webApplication";
    var OS     = "OperatingSystem";

    var files = e.target.files || e.dataTransfer.files;
    try{
        if(isEdge && e.dataTransfer.items[0].kind == "string"){
            files = [];
        }
    } catch(e) {}

    var divMsg = document.getElementById('divMessage');
    divMsg.innerText = '';


    var dragFrom = (files.length == 0) ? webApp : OS;

    var divHeight       = 120;
    var div             = document.getElementById(idDiv);
    div.style.padding   = "0px";
    var filesSize       = 0;
    var filesSizeDone   = 0;

    var data        = e.dataTransfer.getData("Text");
    var obj = {};



    if(dragFrom == webApp) {
        if(data == "" ) {
//          alert(emxUIConstants.UNSUPPORTED_OPERATION);
            return;
        }

        obj = JSON.parse(data);
        var protocol  = obj.protocol;
        var source    = obj.source;

        if(source != "X3DDRIV_AP"  && source != "X3DDRIV_AP" ) {
            document.getElementById(idDiv).className = "dropArea";
            alert(emxUIConstants.UNSUPPORTED_OPERATION);
            return;
        }

        var envId       = obj.data.items[0].envId;
        var serviceId   = obj.data.items[0].serviceId;
        var contextId   = obj.data.items[0].contextId;
        var proxyId     = obj.data.items[0].objectId;
        var objectType  = obj.data.items[0].objectType;
        var displayName = obj.data.items[0].displayName;
        var displayType = obj.data.items[0].displayType;


        // we cant trust this ... the URL moves around depending on the file
        var displayPreview = obj.data.items[0].displayPreview;

        var url = "";
        if (displayPreview != null && displayPreview != undefined && displayPreview != "") {
            url = displayPreview.split("/");
        };
        var urlX = url[0] + "//" + url[2] + "/#dashboard/app:" + source;


        var jsonUpload = {};

        jsonUpload.csrf = {};
        jsonUpload.csrf.name = "ENO_CSRF_TOKEN";
        jsonUpload.csrf.value = "";
        jsonUpload.data = [{}];
        jsonUpload.data[0].type = objectType;
        jsonUpload.data[0].cestamp = "";
        jsonUpload.data[0].updateAction = "CREATE";
        jsonUpload.data[0].id           = proxyId;
        jsonUpload.data[0].service      = serviceId;
        jsonUpload.data[0].tenant       = envId;

        jsonUpload.data[0].dataelements = {};
        jsonUpload.data[0].dataelements.title  = displayName;
        jsonUpload.data[0].dataelements.policy = "ProxyItem";
//        jsonUpload.data[0].dataelements.stateNLS = "Exists";
//        jsonUpload.data[0].dataelements.hasfiles = "FALSE";
        jsonUpload.data[0].dataelements.proxyId = proxyId
        jsonUpload.data[0].dataelements.proxyService = serviceId;
        jsonUpload.data[0].dataelements.proxyType = objectType;
        jsonUpload.data[0].dataelements.proxyTitle = displayName;
        jsonUpload.data[0].dataelements.proxyTenant = envId;
        jsonUpload.data[0].dataelements.URL = envId + ":" + serviceId + ":" + proxyId;
//      jsonUpload.data[0].dataelements.URL = urlX;
        jsonUpload.data[0].dataelements.linkURL = "";


        div.innerHTML = "<div style='width:100%;background:transparent;height:0px'></div><div id='divTarget' class='dropStatusCurrent' style='width:100%;height:" + divHeight + "px'></div>";
        UploadProxy(jsonUpload, 'proxyForm', refresh, div, idTarget);
        div.innerHTML = "<div style='width:100%;background:transparent;height:0px'></div><div id='divTarget' class='dropArea'          style='width:100%;height:" + divHeight + "px'></div>";

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


        div.innerHTML = "<div style='width:100%;background:transparent;height:0px'></div><div id='divTarget' class='dropStatusCurrent' style='width:100%;height:" + divHeight + "px'></div>";
        UploadFile(files, idForm, refresh, div, null, idTarget);
        div.innerHTML = "<div style='width:100%;background:transparent;height:0px'></div><div id='divTarget' class='dropArea'          style='width:100%;height:" + divHeight + "px'></div>";
      }
}

function UploadProxy(jsonUpload, id, idRefresh, dropAreaDiv, idTarget) {

//    var json = jsonUpload;
//    var urlx = document.getElementById('CSRF').action;
//    var XX = $.get(urlx, null, function(data, status, jqXHR){
//                json.csrf.value = data.csrf.value;
//         }, 'json');
//

    var url  = document.getElementById(id).action;
    var csrf_Name = document.getElementsByName('csrfTokenName')[0].value;
    jsonUpload.csrf.value = document.getElementsByName(csrf_Name)[0].value;

    jQuery.ajax({
        url : url,
        type: "POST",
        data : JSON.stringify(jsonUpload),
        dataType: "json",
        cache: false,
        contentType: "application/json",
        processData: false,
        error:  function(qXHR,textStatus,errorThrown){
            uploadProxyError(qXHR, textStatus, errorThrown, JSON.stringify(jsonUpload));
        },

        success: function(data){
            uploadFileDetailsRefresh(idRefresh);
            uploadFileDropZoneRefresh(dropAreaDiv);
         },
    });

}


function UploadFile(files, id, idRefresh, dropAreaDiv, idImage, idTarget) {
    var webApp = "webApplication";
    var OS     = "OperatingSystem";
    var dragFrom = (files.length == 0) ? webApp : OS;

    var url = document.getElementById(id).action;
    if(idRefresh != undefined) {
       url += "&refresh=true";
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
            uploadFileDetailsRefresh(idRefresh);
            uploadFileDropZoneRefresh(dropAreaDiv);
         },
    });

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

function uploadProxyError(qXHR, textStatus, errorThrown, json){
    alert(qXHR.responseText);
    var div = document.getElementById('divMessage');
    var msg = JSON.stringify(json, null, 4);
//  div.innerHTML = msg;
    div.innerText = '\n\nError Information: \n\n' + msg;
    uploadFileDropZoneRefresh('divDrag');

}

function uploadFileError(data, dropAreaDiv, idImage){
    alert(data.trim().substring(5,data.length));
    dropAreaDiv.className = "dropArea";
}

function uploadFileDropZoneRefresh(dropAreaDiv){
    dropAreaDiv.className = "dropArea";
    var div = document.getElementById('divTarget');
    div.innerHTML = DIVLABEL;
}


function uploadFileDetailsRefresh(idRefresh){
    if(idRefresh != undefined) {
        deletePageCache();
//      idRefresh elements ... "detailsDisplay","PMCDeliverable"
        var url = parent.getTopWindow().findFrame(parent.getTopWindow(), idRefresh).location.href;
        url = url.replace("persist=true","");
        parent.getTopWindow().findFrame(parent.getTopWindow(),idRefresh).location.href = url;
     }
}

