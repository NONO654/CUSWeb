/**
 * @author TZW
 */

(function(workerContext) {

    // SAX parser
    workerContext.importScripts('../AmdLoader/AmdLoader.js');
    workerContext.importScripts('../WebappsUtils/WebappsUtils.js');
    //
    workerContext.onmessage = function(e) {

        require(['DS/Mesh/ThreeJS_Base', 'DS/Mesh/Mesh', 'DS/EasySax/EasySax'], function (THREE,Mesh, EasySAXParser) {
        var data = e.data;
        var abs_path = data.path;
        Mesh.MeshContextEnum = {
            UNKNOWN: 0,

            // Data
            DATA: 1,
            FLOATBUFFER: 2,
            INDEXBUFFER: 3,
            COMPRESSEDBUFFER: 4,

            // Primitive
            PRIMITIVE: 5,
            VERTEXCOMPONENT: 6,
            GRAPHICPROPERTIES: 7,
            APPEARANCE: 8,

            // Other
            BAG: 9,
            MESH: 10,
            TEXT: 11
        }

        // list of meshes
        var all_reps = [];
        var node_base = [];

        // init matrices list
        var matrices = [];
        var normal_matrices = [];
        var ident = new THREE.Matrix4();
        matrices.push(ident);
        normal_matrices.push(ident);

        // part structure associated with the output, for highlight purposes and other features...
        var scene_graph = [];
        var SGRoot = new Mesh.SGBag();
        scene_graph.push(SGRoot);

        // intermediate mesh data
        var primitiveGroup = null;
        var context = [Mesh.MeshContextEnum.UNKNOWN];
        var gas = [{
            fill: new Mesh.FillAttributes(),
            line: new Mesh.LineAttributes(),
            point: new Mesh.PointAttributes()
        }];

        var currentPrimitive = null;

        var currentBufferId = 0;
        var currentBufferDimension = 1;
        var currentBufferType = Mesh.DataTypeEnum.UCHAR;

        var currentData = "";

        // for rotations
        var currentAngle = 0;
        var currentOrigin = new THREE.Vector3();
        var currentAxis = new THREE.Vector3();

        function cleanData() {
            all_reps = [];
            node_base = [];

            scene_graph = [];
            SGRoot = new Mesh.SGBag();
            scene_graph.push(SGRoot);

            matrices = [];
            normal_matrices = [];
            matrices.push(ident);
            normal_matrices.push(ident);

            primitiveGroup = null;
            context = [Mesh.MeshContextEnum.UNKNOWN];
            gas = [{
                fill: new Mesh.FillAttributes(),
                line: new Mesh.LineAttributes(),
                point: new Mesh.PointAttributes()
            }];

            currentPrimitive = null;

            currentBufferId = 0;
            currentBufferDimension = 1;
            currentBufferType = Mesh.DataTypeEnum.UCHAR;

            currentData = "";

            currentAngle = 0;
            currentOrigin = new THREE.Vector3();
            currentAxis = new THREE.Vector3();
        }

        function lastElem(array_) {
            return array_[array_.length - 1];
        }

        function load(url, readyCallback, progressCallback) {

            var parser = new EasySAXParser();

            parser.on('startNode', function(localName, atts, uq, tagend, getStrNode) {
                //alert("localName : " + localName);

                if (primitiveGroup != null) {
                    // buffers
                    if (lastElem(context) == Mesh.MeshContextEnum.DATA) {
                        if (localName == "FloatBuffer")
                            StartFloatBuffer(atts);
                        else if (localName == "IndexBuffer")
                            StartIndexBuffer(atts);
                        else if (localName == "CompressedBuffer")
                            StartCompressedBuffer(atts);
                    }

                    // primitives
                    if (lastElem(context) == Mesh.MeshContextEnum.PRIMITIVE) {
                        if (localName == "Positions")
                            StartVertexComponent(atts, 0);
                        else if (localName == "Normals")
                            StartVertexComponent(atts, 1);
                        else if (localName == "DiffuseColors")
                            StartVertexComponent(atts, 2);
                        else if (localName == "TextureCoordinates")
                            StartVertexComponent(atts, 3);
                    }

                    // graphic properties
                    //if (lastElem(context) == Mesh.MeshContextEnum.GRAPHICPROPERTIES)
                    //{
                    if (localName == "FillStyle")
                        StartFillStyle(atts);
                    else if (localName == "LineStyle")
                        StartLineStyle(atts);
                    else if (localName == "PointStyle")
                        StartPointStyle(atts);
                    //}

                    // appearance
                    //if (lastElem(context) == Mesh.MeshContextEnum.APPEARANCE)
                    //{
                    if (localName == "Appearance")
                        StartAppearance(atts);
                    //}

                    /*if (localName == "Node")
        StartNode(atts);
      else*/
                    if (localName == "Primitive")
                        StartPrimitive(atts);
                    else if (localName == "Data")
                        StartData(atts);
                    else if (localName == "GraphicProperties")
                        context.push(Mesh.MeshContextEnum.GRAPHICPROPERTIES);
                } else {
                    if (lastElem(context) == Mesh.MeshContextEnum.GRAPHICPROPERTIES) {
                        if (localName == "FillStyle")
                            return StartFillStyle(atts);
                        else if (localName == "LineStyle")
                            return StartLineStyle(atts);
                        else if (localName == "PointStyle")
                            return StartPointStyle(atts);
                    }

                    if (lastElem(context) == Mesh.MeshContextEnum.BAG) {
                        StartMatrix(atts);

                        if (localName == "GraphicProperties") {
                            context.push(Mesh.MeshContextEnum.GRAPHICPROPERTIES);
                            return;
                        }
                    }

                    if (((lastElem(context) == Mesh.MeshContextEnum.UNKNOWN) || (lastElem(context) == Mesh.MeshContextEnum.BAG)) &&
                        ((localName == "Geometry3D") || (localName == "Node"))) {
                        StartNode(atts);
                    }
                }
            });

            parser.on('endNode', function(localName, uq, tagstart, str) {

                if (lastElem(context) == Mesh.MeshContextEnum.GRAPHICPROPERTIES) {
                    context.pop();
                    return;
                }

                if (lastElem(context) == Mesh.MeshContextEnum.BAG) {
                    switch (localName) {
                        case "Matrix":
                            EndMatrix();
                            return;
                        case "TranslationVector":
                            EndTranslation();
                            return;
                        case "ScaleFactor":
                            EndScaling();
                            return;
                        case "Angle":
                            EndAngle();
                            return;
                        case "RotationAxis":
                            EndRotationAxis();
                            return;
                        case "Origin":
                            EndOrigin();
                            return;
                        case "Direction":
                            EndDirection();
                            return;
                        default:
                            break;
                    }
                }

                switch (lastElem(context)) {
                    // data
                    case Mesh.MeshContextEnum.DATA:
                        EndData();
                        break;
                    case Mesh.MeshContextEnum.FLOATBUFFER:
                        EndFloatBuffer();
                        break;
                    case Mesh.MeshContextEnum.INDEXBUFFER:
                        EndIndexBuffer();
                        break;
                    case Mesh.MeshContextEnum.COMPRESSEDBUFFER:
                        EndCompressedBuffer();
                        break;

                        // primitive
                    case Mesh.MeshContextEnum.PRIMITIVE:
                        EndPrimitive();
                        break;
                    case Mesh.MeshContextEnum.VERTEXCOMPONENT:
                        EndVertexComponent();
                        break;

                        // geometry
                    case Mesh.MeshContextEnum.GRAPHICPROPERTIES:
                        //case Mesh.MeshContextEnum.APPEARANCE:
                        context.pop();
                        break;

                    default:
                        break;
                }

                if ((localName == "Node") || (localName == "Geometry3D"))
                    EndNode(null);
            });

            parser.on('textNode', function(s, uq) {

                currentData = uq(s);
            });

            if ((url.slice(0, 4) !== "http") && (url.slice(0, 1) !== "/")) {

                url = "../../../" + url;
            }

            var req = new XMLHttpRequest();
            //req.responseType = "text";

            req.onreadystatechange = function() {

                if (req.readyState === 4) {

                    if (req.status === 0 || req.status === 200) {

                        if (req.response) {

                            parser.parse(req.response);

                            //---------------

                            // group all reps in one (or more if indices are >= 65535)

                            var reps = [];
                            var max_indices = 0;
                            for (var n = 0; n < all_reps.length; n++) {
                                if (max_indices + all_reps[n].vertexPositionArray.length / 3 >= 65535) {
                                    if (max_indices == 0) {
                                        var repGroup = Mesh.divideRep(all_reps[n]);

                                        for (var m = 0; m < repGroup.length; m++)
                                            node_base.push(repGroup[m]);

                                        continue;
                                    }

                                    var repGroup = Mesh.processReps(reps);
                                    repGroup.sceneGraph = SGRoot;

                                    node_base.push(repGroup);
                                    max_indices = 0;
                                    reps = [];
                                }

                                reps.push(all_reps[n]);
                                max_indices += all_reps[n].vertexPositionArray.length / 3;
                            }

                            if (reps.length > 0) {
                                var repGroup = Mesh.processReps(reps);
                                repGroup.sceneGraph = SGRoot;

                                node_base.push(repGroup);
                            }

                            // associate the scene graph structure to the node_base
                            //node_base.sceneGraph = SGRoot;

                            if (readyCallback) {
                                readyCallback(node_base);
                            }
                            //---------------
                        }
                    }
                }
            }

            req.open("GET", url, true);
            req.send(null);
        };


        function StartNode(atts) {
            var attributes = atts();
            var type = attributes["xsi:type"];

            if (type == "MeshType") {
                context.push(Mesh.MeshContextEnum.MESH);

                primitiveGroup = new Mesh.PrimitiveGroup();

                var meshType = attributes["type"];
                var xmlID = attributes["id"];

                primitiveGroup.identifier = xmlID;
                if (meshType === 'VOLUME') {
                    primitiveGroup.fillAttr = new Mesh.FillAttributes();
                    primitiveGroup.fillAttr.solid = 1.0;
                }

                // update the scene graph

                var parent = lastElem(scene_graph);

                var sgRep = new Mesh.SGRep({
                    cgmId: xmlID,
                    parent: parent
                });

                if (parent)
                    parent.children.push(sgRep);

                scene_graph.push(sgRep);
            } else {
                context.push(Mesh.MeshContextEnum.BAG);

                StartBag(atts);
            }

            var prevGAS = lastElem(gas);
            gas.push({
                fill: prevGAS.fill.clone(),
                line: prevGAS.line.clone(),
                point: prevGAS.point.clone()
            });

            if (primitiveGroup && primitiveGroup.fillAttr) {
                lastElem(gas).fill.solid = primitiveGroup.fillAttr.solid;
            }
        }

        function EndNode(atts) {
            if (lastElem(context) == Mesh.MeshContextEnum.MESH) {
                var currentGAS = lastElem(gas);
                primitiveGroup.fillAttr = currentGAS.fill;
                primitiveGroup.lineAttr = currentGAS.line;
                primitiveGroup.pointAttr = currentGAS.point;

                //++ CONVERSION TO pseudo THREE JS
                var nodeMesh = Mesh.convertToGeometry3js(primitiveGroup, lastElem(matrices), lastElem(normal_matrices));

                var sgRep = lastElem(scene_graph);
                nodeMesh.rep = sgRep;

                all_reps.push(nodeMesh);
                //--

                primitiveGroup = null;
            } else {
                EndBag(atts);
            }

            scene_graph.pop();

            context.pop();

            gas.pop();
        }

        function StartBag(atts) {
            // Update the scene graph

            var parent = lastElem(scene_graph);

            var bag = new Mesh.SGBag({
                parent: parent
            }); // create a new bag

            if (parent)
                parent.children.push(bag); // update parent

            scene_graph.push(bag); // add it to the stack of bags

            // Prepare new matrix and normal matrix from parent ones

            var mat = new THREE.Matrix4();
            mat.copy(lastElem(matrices));
            matrices.push(mat);

            var normal_mat = new THREE.Matrix4();
            normal_mat.getInverse(lastElem(matrices));
            normal_mat.transpose();
            normal_matrices.push(normal_mat);
        }

        function EndBag(atts) {
            matrices.pop();
            normal_matrices.pop();
        }

        function StartMatrix(atts) {
            if (lastElem(context) == Mesh.MeshContextEnum.BAG) {
                currentData = "";
            }
        }

        function EndMatrix(atts) {
            if ((lastElem(context) == Mesh.MeshContextEnum.BAG) && (currentData != "")) {
                var coefs = _floats(currentData);

                if (coefs.length == 16) {
                    var bag = lastElem(scene_graph);
                    if (bag) {
                        var mat = new THREE.Matrix4(coefs[0], coefs[4], coefs[8], coefs[12],
                            coefs[1], coefs[5], coefs[9], coefs[13],
                            coefs[2], coefs[6], coefs[10], coefs[14],
                            coefs[3], coefs[7], coefs[11], coefs[15]);

                        bag.matrix = mat;

                        matrices.pop();
                        mat.multiplyMatrices(lastElem(matrices), mat);
                        matrices.push(mat);

                        normal_matrices.pop();
                        var normal_mat = new THREE.Matrix4();
                        normal_mat.getInverse(lastElem(matrices));
                        normal_mat.transpose();
                        normal_matrices.push(normal_mat);
                    }
                }

                currentData = "";
            }
        }

        function EndTranslation() {
            if ((lastElem(context) == Mesh.MeshContextEnum.BAG) && (currentData != "")) {
                var coefs = _floats(currentData);

                if (coefs.length == 3) {
                    var bag = lastElem(scene_graph);
                    if (bag) {
                        var mat = new THREE.Matrix4(1, 0, 0, coefs[0],
                            0, 1, 0, coefs[1],
                            0, 0, 1, coefs[2],
                            0, 0, 0, 1);

                        bag.matrix = mat;

                        matrices.pop();
                        mat.multiplyMatrices(lastElem(matrices), mat);
                        matrices.push(mat);

                        normal_matrices.pop();
                        var normal_mat = new THREE.Matrix4();
                        normal_mat.getInverse(lastElem(matrices));
                        normal_mat.transpose();
                        normal_matrices.push(normal_mat);
                    }
                }

                currentData = "";
            }
        }

        function EndScaling() {
            if ((lastElem(context) == Mesh.MeshContextEnum.BAG) && (currentData != "")) {
                var coefs = _floats(currentData);

                if (coefs.length == 1) {
                    var bag = lastElem(scene_graph);

                    if (bag && coefs[0]) {
                        var mat = new THREE.Matrix4(1, 0, 0, 0,
                            0, 1, 0, 0,
                            0, 0, 1, 0,
                            0, 0, 0, 1.0 / coefs[0]);

                        bag.matrix = mat;
                    }
                }

                currentData = "";
            }
        }

        function EndAngle() {
            if ((lastElem(context) == Mesh.MeshContextEnum.BAG) && (currentData != "")) {
                var coefs = _floats(currentData);

                if (coefs.length == 1)
                    currentAngle = coefs[0];

                currentData = "";
            }
        }

        function EndOrigin() {
            if ((lastElem(context) == Mesh.MeshContextEnum.BAG) && (currentData != "")) {
                var coefs = _floats(currentData);

                if (coefs.length == 3)
                    currentOrigin.set(coefs[0], coefs[1], coefs[2]);

                currentData = "";
            }
        }

        function EndDirection() {
            if ((lastElem(context) == Mesh.MeshContextEnum.BAG) && (currentData != "")) {
                var coefs = _floats(currentData);

                if (coefs.length == 3)
                    currentAxis.set(coefs[0], coefs[1], coefs[2]);

                currentData = "";
            }
        }

        function EndRotationAxis() {
            var bag = lastElem(scene_graph);
            // if (bag)
            // {
            // bag.position = {currentOrigin[0], currentOrigin[1], currentOrigin[2]};
            // bag.rotation = {currentAxis, currentAngle};
            // }
        }

        function StartFillStyle(atts) {
            context.push(Mesh.MeshContextEnum.GRAPHICPROPERTIES);

            var attributes = atts();
            var color = attributes["color"];

            if (color) {
                if (currentPrimitive != null) {
                    if (currentPrimitive.attr == null) {
                        var prevGAS = lastElem(gas);
                        currentPrimitive.attr = {
                            fill: prevGAS.fill.clone(),
                            line: prevGAS.line.clone(),
                            point: prevGAS.point.clone()
                        };
                    }
                    currentPrimitive.attr.fill.color = getColor(color);
                } else
                    lastElem(gas).fill.color = getColor(color);
            }
        }

        function StartLineStyle(atts) {
            context.push(Mesh.MeshContextEnum.GRAPHICPROPERTIES);

            var attributes = atts();
            var color = attributes["color"];
            var thickness = 1; //attributes["thickness"];
            var pattern = Mesh.LinePatternEnum.SOLID; //attributes["pattern"];

            if (color || thickness || pattern) {
                var tmp = Mesh.LinePatternEnum.SOLID;

                if (pattern) {
                    switch (pattern) {
                        case "SOLID":
                            tmp = Mesh.LinePatternEnum.SOLID;
                            break;
                        case "DASHED":
                            tmp = Mesh.LinePatternEnum.DASHED;
                            break;
                        case "DOT_DASHED":
                            tmp = Mesh.LinePatternEnum.DOTDASHED;
                            break;
                        case "DOTTED":
                            tmp = Mesh.LinePatternEnum.DOTTED;
                            break;
                        case "JIS_AXIS":
                            tmp = Mesh.LinePatternEnum.JISAXIS;
                            break;
                        case "PHANTOM":
                            tmp = Mesh.LinePatternEnum.PHANTOM;
                            break;
                        case "SMALL_DOT":
                            tmp = Mesh.LinePatternEnum.SMALLDOTTED;
                            break;
                        default:
                            tmp = Mesh.LinePatternEnum.UNKNOWN;
                            break;
                    }
                }

                if (currentPrimitive != null) {
                    if (currentPrimitive.attr == null) {
                        var prevGAS = lastElem(gas);
                        currentPrimitive.attr = {
                            fill: prevGAS.fill.clone(),
                            line: prevGAS.line.clone(),
                            point: prevGAS.point.clone()
                        };
                    }
                    if (color) currentPrimitive.attr.line.color = getColor(color);
                    if (thickness) currentPrimitive.attr.line.thickness = parseFloat(thickness);
                    if (pattern) currentPrimitive.attr.line.pattern = tmp;
                } else {
                    if (color) lastElem(gas).line.color = getColor(color);
                    if (thickness) lastElem(gas).line.thickness = parseFloat(thickness);
                    if (pattern) lastElem(gas).line.pattern = tmp;
                }
            }
        }

        function StartPointStyle(atts) {
            context.push(Mesh.MeshContextEnum.GRAPHICPROPERTIES);

            var attributes = atts();
            var color = attributes["color"];
            var size = attributes["size"];
            var symbol = attributes["symbol"];

            if (color || size || symbol) {
                var tmp = Mesh.PointSymbolEnum.CROSS;

                if (symbol) {
                    switch (symbol) {
                        case "CROSS":
                            tmp = Mesh.PointSymbolEnum.CROSS;
                            break;
                        case "PLUS":
                            tmp = Mesh.PointSymbolEnum.PLUS;
                            break;
                        case "CONCENTRIC":
                            tmp = Mesh.PointSymbolEnum.CONCENTRIC;
                            break;
                        case "COINCIDENT":
                            tmp = Mesh.PointSymbolEnum.COINCIDENT;
                            break;
                        case "FULL_CIRCLE":
                            tmp = Mesh.PointSymbolEnum.FULLCIRCLE;
                            break;
                        case "FULL_SQUARE":
                            tmp = Mesh.PointSymbolEnum.FULLSQUARE;
                            break;
                        case "STAR":
                            tmp = Mesh.PointSymbolEnum.STAR;
                            break;
                        case "DOT":
                            tmp = Mesh.PointSymbolEnum.DOT;
                            break;
                        case "SMALL_DOT":
                            tmp = Mesh.PointSymbolEnum.SMALLDOT;
                            break;
                        default:
                            break;
                    }
                }

                if (currentPrimitive != null) {
                    if (currentPrimitive.attr == null) {
                        var prevGAS = lastElem(gas);
                        currentPrimitive.attr = {
                            fill: prevGAS.fill.clone(),
                            line: prevGAS.line.clone(),
                            point: prevGAS.point.clone()
                        };
                    }
                    if (color) currentPrimitive.attr.point.color = getColor(color);
                    if (size) currentPrimitive.attr.point.size = parseFloat(size);
                    if (symbol) currentPrimitive.attr.point.symbol = tmp;
                } else {
                    if (color) lastElem(gas).point.color = getColor(color);
                    if (size) lastElem(gas).point.size = parseFloat(size);
                    if (symbol) lastElem(gas).point.symbol = tmp;
                }
            }
        }

        function getColor(color) {
            var r = 0,
                g = 0,
                b = 0,
                a = 1;

            var re = new RegExp(/RGB\(\s*([0,1]|(?:[0,1]?\.[0-9]+))\s*,\s*([0,1]|(?:[0,1]?\.[0-9]+))\s*,\s*([0,1]|(?:[0,1]?\.[0-9]+))\s*\)/i);
            var m = re.exec(color);

            if (m != null) {
                r = parseFloat(RegExp.$1);
                g = parseFloat(RegExp.$2);
                b = parseFloat(RegExp.$3);
            } else {
                // '?:' after a parenthesis means that we don't want this element to be backreferenced
                // '/i' at the end means that case is ignored
                re = new RegExp(/RGBA\(\s*([0,1]|(?:[0,1]?\.[0-9]+))\s*,\s*([0,1]|(?:[0,1]?\.[0-9]+))\s*,\s*([0,1]|(?:[0,1]?\.[0-9]+))\s*,\s*([0,1]|(?:[0,1]?\.[0-9]+))\s*\)/i);
                m = re.exec(color);

                if (m != null) {
                    r = parseFloat(RegExp.$1);
                    g = parseFloat(RegExp.$2);
                    b = parseFloat(RegExp.$3);
                    a = parseFloat(RegExp.$4);
                }
            }

            return new Mesh.Color(r, g, b, a);
        }

        function StartAppearance(atts) {
            var attributes = atts();
            var material_id = attributes["linkidref"];

            if (currentPrimitive != null)
                currentPrimitive.material = {
                    file: "",
                    id: material_id
                };
            else
                primitiveGroup.material = {
                    file: "",
                    id: material_id
                };
        }

        function StartData(atts) {
            context.push(Mesh.MeshContextEnum.DATA);
        }

        function EndData(atts) {
            context.pop();
        }

        function StartPrimitive(atts) {
            context.push(Mesh.MeshContextEnum.PRIMITIVE);

            currentPrimitive = new Mesh.Primitive();

            var attributes = atts();
            var xmlID = attributes["id"];
            var connectivity = attributes["connectivityType"];
            var nbVertices = parseInt(attributes["numberOfVertices"]);
            var geomType = attributes["type"];

            currentPrimitive.identifier = xmlID;
            currentPrimitive.connectivity = Mesh.ConnectivityTypeEnum[connectivity];
            currentPrimitive.nbIndices = nbVertices;
            currentPrimitive.geomType = geomType;
        }

        function EndPrimitive(atts) {
            context.pop();

            primitiveGroup.addPrimitive(currentPrimitive);
            currentPrimitive = null;
        }

        function StartFloatBuffer(atts) {
            context.push(Mesh.MeshContextEnum.FLOATBUFFER);

            var attributes = atts();
            currentBufferId = attributes["id"];
            currentBufferDimension = attributes["dimension"];

            currentData = "";
        }

        function EndFloatBuffer() {
            context.pop();

            if (currentData != "") {
                var buffer = new Mesh.Buffer();

                buffer.data = _floatsTypedArray(currentData);
                buffer.indexBuffer = false;
                buffer.size = buffer.data.length;
                buffer.format = Mesh.DataTypeEnum.FLOAT;
                buffer.dimension = currentBufferDimension;

                primitiveGroup.addBuffer(currentBufferId, buffer);
            }
        }

        function StartCompressedBuffer(atts) {
            context.push(Mesh.MeshContextEnum.COMPRESSEDBUFFER);

            var attributes = atts();
            currentBufferId = attributes["id"];
            currentBufferDimension = attributes["dimension"];
            currentBufferType = getDataTypeFromBufferType(attributes["type"]);

            currentData = "";
        }

        function EndCompressedBuffer() {
            context.pop();

            if (currentData != "") {
                var buffer = new Mesh.Buffer();

                buffer.data = base64TypedArray(currentData, currentBufferType);
                buffer.indexBuffer = false;
                buffer.size = buffer.data.length;
                buffer.format = currentBufferType;
                buffer.dimension = currentBufferDimension;

                primitiveGroup.addBuffer(currentBufferId, buffer);
            }
        }

        function getDataTypeFromBufferType(bufferType) {
            switch (bufferType) {
                case "FLOAT":
                    return Mesh.DataTypeEnum.FLOAT;
                case "INT32":
                    return Mesh.DataTypeEnum.INT;
                default:
                    break;
            }

            return Mesh.DataTypeEnum.UCHAR;
        }

        function base64TypedArray(data, dataType) {
            var result = null;

            var byteArray = base64ToArrayBuffer(data);

            if (dataType == Mesh.DataTypeEnum.FLOAT)
                result = new Float32Array(byteArray, 0, byteArray.byteLength / 4);
            else if (dataType == Mesh.DataTypeEnum.INT)
                result = new Int32Array(byteArray, 0, byteArray.byteLength / 4);

            return result;
        }

        function base64ToArrayBuffer(data) {
            var encodings = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

            if (data.length % 4) return null;

            var byteLength = 3 * (data.length / 4);
            var charsNotUsed = 0;

            if (data[data.length - 1] == '=') {
                charsNotUsed++;
                byteLength--;
                if (data[data.length - 2] == '=') {
                    charsNotUsed++;
                    byteLength--;
                }
            }

            var charLength = (!charsNotUsed) ? data.length : data.length - 4;

            var originalBuffer = new ArrayBuffer(byteLength);
            var bytes = new Uint8Array(originalBuffer, 0, byteLength);

            var i = 0,
                j = 0;
            for (i = 0; i < charLength; i += 4) {
                var chunk = (encodings.indexOf(data[i]) << 18) |
                    (encodings.indexOf(data[i + 1]) << 12) |
                    (encodings.indexOf(data[i + 2]) << 6) |
                    encodings.indexOf(data[i + 3]);

                bytes[j++] = (chunk & 16711680) >> 16; // 16 711 680 = (2^8 - 1) << 16
                bytes[j++] = (chunk & 65280) >> 8; //     65 280 = (2^8 - 1) <<  8
                bytes[j++] = (chunk & 255); //        255 = (2^8 - 1)
            }

            // last group of 4 chars
            if (charsNotUsed == 2) {
                var chunk = (encodings.indexOf(data[i]) << 18) |
                    (encodings.indexOf(data[i + 1]) << 12);

                bytes[j++] = (chunk & 16711680) >> 16; // 16 711 680 = (2^8 - 1) << 16
            } else if (charsNotUsed == 1) {
                var chunk = (encodings.indexOf(data[i]) << 18) |
                    (encodings.indexOf(data[i + 1]) << 12) |
                    (encodings.indexOf(data[i + 2]) << 6);

                bytes[j++] = (chunk & 16711680) >> 16; // 16 711 680 = (2^8 - 1) << 16
                bytes[j++] = (chunk & 65280) >> 8; //     65 280 = (2^8 - 1) <<  8
            }

            return originalBuffer;
        }

        function StartIndexBuffer(atts) {
            context.push(Mesh.MeshContextEnum.INDEXBUFFER);

            var attributes = atts();
            currentBufferId = attributes["id"];

            currentData = "";
        }

        function EndIndexBuffer() {
            context.pop();

            //if (currentData != "")
            {
                var buffer = new Mesh.Buffer();

                buffer.data = _intsTypedArray(currentData);
                buffer.indexBuffer = true;
                buffer.size = buffer.data.length;
                buffer.format = Mesh.DataTypeEnum.UINT;
                buffer.dimension = 1;

                primitiveGroup.addBuffer(currentBufferId, buffer);
            }
        }

        function StartVertexComponent(atts, type) {
            context.push(Mesh.MeshContextEnum.VERTEXCOMPONENT);

            var channel = 0;
            var attributes = atts();

            if (type >= 3) {
                channel = parseInt(attributes["channel"], 10);
                channel--;
            }

            var component = type + channel;

            var dataOffset = 0;
            var indexOffset = 0;

            var hasIndex = false;

            var vertexBuffer = null;
            var indexBuffer = null;

            if (attributes["offset"] != null)
                dataOffset = parseInt(attributes["offset"], 10);

            // get vertex buffer
            var bufferId = attributes["buffer"];
            if (bufferId != null)
                vertexBuffer = primitiveGroup.buffers[bufferId];

            var indexBufferId = attributes["indexBuffer"];
            if (indexBufferId != null)
                hasIndex = true;

            if (hasIndex) {
                indexOffset = dataOffset;
                dataOffset = 0;
            }

            // create vertex component
            var vertexComponent = new Mesh.VertexComponent();

            vertexComponent.component = component;
            vertexComponent.nbVertices = currentPrimitive.nbIndices;
            vertexComponent.nbValuesPerVertex = vertexBuffer.dimension;
            vertexComponent.format = vertexBuffer.format;
            vertexComponent.bufferId = bufferId;
            vertexComponent.offset = dataOffset;

            if (hasIndex) {
                indexBuffer = primitiveGroup.buffers[indexBufferId];

                var indexArray = new Mesh.IndexArray();
                indexArray.format = indexBuffer.format;
                indexArray.bufferId = indexBufferId;
                indexArray.offset = indexOffset;

                vertexComponent.indices = indexArray;
            }

            currentPrimitive.addVertexComponent(vertexComponent);
        }

        function EndVertexComponent(atts) {
            context.pop();
        }

        // Parsing

        function _bools(str) {
            var raw = _strings(str);
            var data = [];

            for (var i = 0, l = raw.length; i < l; i++)
                data.push((raw[i] == 'true' || raw[i] == '1') ? true : false);

            return data;
        };

        function _floats(str) {
            var raw = _strings(str);
            var data = [];

            for (var i = 0, l = raw.length; i < l; i++)
                data.push(parseFloat(raw[i]));

            return data;
        };

        function _floatsTypedArray(str) {
            var raw = _strings(str);
            var data = new Float32Array(raw.length);

            for (var i = 0, l = raw.length; i < l; i++)
                data[i] = raw[i];

            return data;
        };

        function _ints(str) {
            var raw = _strings(str);
            var data = [];

            for (var i = 0, l = raw.length; i < l; i++)
                data.push(parseInt(raw[i], 10));

            return data;
        };

        function _intsTypedArray(str) {
            var raw = _strings(str);
            var data = new Uint32Array(raw.length);

            for (var i = 0, l = raw.length; i < l; i++)
                data[i] = raw[i];

            return data;
        };

        function _strings(str) {
            return (str.length > 0) ? _trimString(str).split(/\s+/) : [];
        };

        function _trimString(str) {
            return str.replace(/^\s+/, "").replace(/\s+$/, "");
        };

        function isEqualGAS(gas1, gas2) {
            if ((gas1 == null) && (gas2 == null)) return true;

            if (((gas1 == null) && (gas2 != null)) ||
                ((gas1 != null) && (gas2 == null)))
                return false;

            return (gas1.fill.isEqual(gas2.fill) &&
                gas1.line.isEqual(gas2.line) &&
                gas1.point.isEqual(gas2.point));
        };

        function convertToMaterial3js(gas, type) {
            if (gas == null) return null;

            var material = null;

            var opacity = 1;
            var color = null;

            switch (type) {
                case 0:
                    break; // point
                case 1: // line
                    opacity = gas.line.color.a || 1;
                    color = new THREE.Color();

                    if (gas.line.color) {
                        color.setRGB(gas.line.color.r, gas.line.color.g, gas.line.color.b);
                        material = {
                            color: color,
                            opacity: opacity,
                            lineWidth: gas.line.thickness
                        };
                    }
                    break;
                case 2: // surface
                    opacity = gas.fill.color.a || 1;
                    color = new THREE.Color();

                    if (gas.fill.color) {
                        color.setRGB(gas.fill.color.r, gas.fill.color.g, gas.fill.color.b);
                        material = {
                            color: color,
                            opacity: opacity
                        };
                    }
                    break;
                default:
                    break;
            }

            return material;
        }


        load(abs_path, function(mesh) {
            workerContext.postMessage({
                rep: mesh,
                node: data.node
            });
            cleanData();
        });

      });
    };
})(this);
