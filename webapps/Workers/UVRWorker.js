/**
 * @author TZW
 */

// Three js basic types
importScripts('DS/Mesh/ThreeJS_Base.js');
importScripts('DS/Mesh/Mesh.js');
importScripts('DS/Formats/CGRFile.js');
importScripts('DS/Mesh/MeshUtils.js');


var readyCB = null;
function onProgress() {
}

var toto = 0;
function onLoad(e) {
//    debugger;
    var byteArray, rep;

    // CHANGE 2: convert string object into a binary object
    byteArray = new Uint8Array(e.target.response);
    /*
    var response = e.target.response;
    var length = response.length - 1;
    while (length--) {
        byteArray[length] = response.charCodeAt(length)//; & 0xff;
    }
    */
    rep = openUVR(byteArray);
    readyCB(rep);
}

function onError() {

    readyCB(null);
}

function openUVR(byteArray) {

    var uvrFile = new CGRFile(byteArray);
    return uvrFile.open();

    //var end = new Date().getTime();
    //console.log(end -start);
}

function loadUVR(url, readyCallback, progressCallback) {

    readyCB = readyCallback;
    var req = new XMLHttpRequest();
    req.onprogress = onProgress;
    //req.overrideMimeType('text/plain; charset=x-user-defined');
    req.responseType = "arraybuffer";
    req.onload = onLoad;
    req.onerror = onError;

    req.open("GET", url, false); // it seems to be an absolute path...

    req.send(null);
}

var toto = 0;

this.onmessage = function (e) {

    var data = e.data,
        abs_path = data.path;


    loadUVR(abs_path, function (mesh) {

        postMessage({ rep: mesh.mesh, resource : mesh.resource, material : mesh.material,  node: data.node });
    });
};
