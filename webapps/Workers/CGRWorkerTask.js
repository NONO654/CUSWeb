/*
@fullreview TZW 2014:03:05 Creation
*/

// Three js basic types
importScripts('DS/Mesh/ThreeJS_Base.js');
importScripts('DS/Mesh/Mesh.js');
importScripts('DS/Formats/CGRFile.js');
importScripts('DS/Mesh/MeshUtils.js');

onmessage = function(e)
{
    var data = new Uint8Array(e.data.buffer);
    var contextID = e.data.contextID ? e.data.contextID : 0;

    var cgrFile = new CGRFile(new byteArrayReader(data));
    var rep = cgrFile.open();

    postMessage({ rep: rep.mesh, resource : rep.resource, material : rep.material, contextID: contextID });
};
