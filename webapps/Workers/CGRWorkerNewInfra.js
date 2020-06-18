/*
@fullreview SVQ 2012:10:01 Creation
*/


(function(workerContext) {

    // IR-360011 : for IE11
    define('DS/Formats/Formats', function () {

        return new Object();
    });

    require(["DS/Formats/CGRFile"], function(CGRFile) {
    
        workerContext.onmessage = function(e) {

            var readyCB = null;
            var expand = false;
            var primWithBS = false;
            var smartStaticBatching = false;
            var withSG = false;
            var i32Idx = undefined;
            var withSAG = false;
            var uvr = false;
            var processText = false;


            function onLoad(e, containersName) {
                var byteArray = new Uint8Array(e.target.response);

                var cgrFile = new CGRFile(new byteArrayReader(byteArray), expand, primWithBS, withSG, i32Idx, smartStaticBatching, withSAG, processText);
                var rep = cgrFile.open(uvr);

                if (containersName && containersName.length) {
                    var resultContainer = {};
                    for (var i = 0; i < containersName.length; i++) {
                        resultContainer[containersName[i]] = cgrFile.getApplicativeContainer(containersName[i], true);
                    }
                    //workerContext.postMessage({ applicativeContainers: resultContainer });
                    if (!rep) {
                        rep = {
                            reps: [],
                            resource: [],
                            material: []
                        }
                    }
                    rep.applicativesContainers = resultContainer;
                }

				if (rep && rep.error) {
                    onError(rep.error);
                    return;
                }
                if (rep != null) {
                    readyCB(rep);
                } else
                    onError();
            }

            function onError(errorMessage) {
                readyCB({
                    reps: [],
                    resource: [],
                    material: [],
                    error: errorMessage ? errorMessage : true
                });
            }

            function openCGR(byteArray) {

                var cgrFile = new CGRFile(byteArray, expand, primWithBS, withSG, i32Idx, smartStaticBatching, withSAG);
                return cgrFile.open(uvr);
            }

            function load(url, readyCallback, progressCallback) {

                readyCB = readyCallback;
                var req = new XMLHttpRequest();
                //req.onprogress = onProgress;
                req.onload = onLoad;
                req.onerror = onError;
                // FLE BEGIN "posthttp:"+realurl+":postparams:"+"__fcs__jobTicket="+encodeURIComponent(fcsparams);
                if (url.slice(0, 8) == "posthttp") {
                    var indexofPostParams = url.indexOf(":postparams:");
                    var fcsurl = url.slice(9, indexofPostParams);
                    var params = url.slice(indexofPostParams + 12, url.length);
                    req.open("POST", fcsurl, false);
                    req.responseType = "arraybuffer";
                    req.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
                    req.send(params);
                } // FLE END
                else {
                    req.open("GET", url, false);
                    req.responseType = "arraybuffer";
                    req.send(null);
                } 

            };

            var buildTransferable = function (data) {
                var transferables = [];
                var mesh = null;
                var meshes = data.reps;
                var resource = data.resource;
                
                var decorations = data.decorations;

                if (decorations) {
                    transferables.push(decorations.buffer);
                }
                
                
                //var decorations = data.decorations;
                //var length = decorations.length;
                //var newDecorations = new Uint8Array(decorations.length);
                //while (length--) newDecorations[length] = decorations[length];
                //transferables.push(newDecorations.buffer);
                //data.decorations = newDecorations;

                for (var j = 0 ; j < resource.length ; ++j) {
                    var texture = resource[j];
                    if (texture.img) {
                        transferables.push(texture.img.buffer);
                    }
                }
                for (var i = 0 ; i < meshes.length ; ++i) {
                    mesh = meshes[i];
                    if (i & 1 || i & 8) {//static
                        for (var j = 0 ; j < mesh.length ; ++j) {
                            var meshStatic = mesh[j].tab;
                            for (var k = 0 ; k < meshStatic.length ; ++k) {
                                var toto = meshStatic[k];
                                transferables.push(toto.vertexPositionArray.buffer);
                                if (toto.vertexNormalArray) {
                                    transferables.push(toto.vertexNormalArray.buffer);
                                }
                                transferables.push(toto.vertexIndexArray.buffer);
                            }
                        }
                        continue;
                    }
                    for (var j = 0 ; j < mesh.length ; ++j) {
                        var toto = mesh[j];
                        transferables.push(toto.vertexPositionArray.buffer);
                        if (toto.vertexNormalArray) {
                        transferables.push(toto.vertexNormalArray.buffer);
                        }
                        transferables.push(toto.vertexIndexArray.buffer);
                        
                        for (var k = 0 ; k < toto.drawingGroups.length ; ++k) {
                            transferables.push(toto.drawingGroups[k].primitives.buffer);
                        }
                    }
                }
                return transferables;
            }
            var onCGRLoaded = function(mesh, target) {
                
                var transferables = [];
                transferables = buildTransferable(mesh);
                workerContext.postMessage({
                    error: mesh.error,
                    loadIndex: e.data.loadIndex,
                    sceneGraph: mesh.sceneGraph,
                    reps: mesh.reps,
                    resource: mesh.resource,
                    material: mesh.material,
                    sgRep: mesh.sgRep,
                    decorations: mesh.decorations,
                    axisSystems : mesh.axisSystems,
                    refPlanes: mesh.refPlanes,
                    texts: mesh.texts,
                    node: target,
                    applicativesContainers: mesh.applicativesContainers,
                    CGR: true
                }, transferables);
            }

            var data = e.data;
            processText = data.processText;
            var abs_path = data.path;
            var isBuffer = (typeof data.inputFile !== "undefined");
            var expandMode = data.expandMode;
            var primitiveWithBS = data.primitiveWithBS;
            var applicativesContainers = data.applicativesContainers;
            var ssb = data.smartStaticBatching;
            var withSceneGraph = data.withSceneGraph;
            withSAG = data.withSAG;
            uvr = data.uvr;
            if (expandMode) {
                expand = true;
            }
            if (primitiveWithBS) {
                primWithBS = true;
            }
            if (withSceneGraph) {
                withSG = true;
            }
            if (ssb) {
                smartStaticBatching = true;
            }
			i32Idx=data.uint32Index;

            if (isBuffer) {
                var tmp = {
                    target: {
                        response: data.inputFile
                    }
                };
                readyCB = function(mesh) {
                    onCGRLoaded(mesh, data.node);
                };
                onLoad(tmp, applicativesContainers);

            } else {
                load(abs_path, function(mesh) {
                    onCGRLoaded(mesh, data.node);
                });
            }

        };
        workerContext.postMessage({loaded:true});
    });

})(this);
