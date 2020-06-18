/**
 * @author TZW
 */

(function(workerContext) {
    // SAX parser
    //workerContext.importScripts('../AMDLoader/AMDLoader.js');

    require(['DS/Mesh/Mesh', 'DS/Mesh/ThreeJS_Base', 'DS/EasySax/EasySax'], function (Mesh,THREE,EasySAXParser) {
        workerContext.onmessage = function(e) {

      
            Mesh.MeshContextEnum = {
                UNKNOWN: 0,

                // Data
                DATA: 1,
                FLOATBUFFER: 2,

                // Primitive
                PRIMITIVE: 3,
                PRIMITIVESET: 4,
                VERTEXCOMPONENT: 5,
                LINEATTR: 6,
                SURFACEATTR: 7,

                // Other
                BAG: 8,
                MESH: 9,
                LOD: 10
            }

            var computePrimitiveBS = false;

            // list of meshes
            var all_reps = [];
            var node_base = [];

            // part structure associated with the output, for highlight purposes and other features...
            var scene_graph = [];
            var SGRoot = null;

            // intermediate mesh data
            var _sBufferID = 0;

            var primitiveGroup = null;
            var currentMaterialRep = null;

            var context = [];
            var gas = [];

            var currentStyle = null;
            var currentColor = null;

            var currentPrimitiveSet = null;
            var currentGASPrimitiveSet = null;
            var currentMaterialPrimitiveSet = null;

            var currentPrimitive = [];
            var currentGASPrimitive = null;

            var currentIndexBufferData = [];
            var currentPositionBufferData = [];

            var currentTextureChannel = 0;
            var currentTextureDimension = 2;

            var currentData = "";

            function cleanData() {
                all_reps = [];
                node_base = [];

                scene_graph = [];
                SGRoot = new Mesh.SGBag();
                scene_graph.push(SGRoot);

                _sBufferID = 0;

                primitiveGroup = null;
                currentMaterialRep = null;

                context = [Mesh.MeshContextEnum.UNKNOWN];
                gas = [{
                    fill: new Mesh.FillAttributes(new Mesh.Color(1,1,1)),
                    line: new Mesh.LineAttributes(),
                    point: new Mesh.PointAttributes()
                }];

                currentStyle = null;
                currentColor = null;

                currentPrimitiveSet = null;
                currentGASPrimitiveSet = null;
                currentMaterialPrimitiveSet = null;

                currentPrimitive = [];
                currentGASPrimitive = null;

                currentIndexBufferData = [];
                currentPositionBufferData = [];

                currentTextureChannel = 0;
                currentTextureDimension = 2;

                currentData = "";
            }

            function lastElem(array_) {
                return array_[array_.length - 1];
            }

            function getUniqueBufferId() {
                _sBufferID++;
                return _sBufferID - 1;
            }

            function load(url, readyCallback, progressCallback) {

                var parser = new EasySAXParser();

                parser.on('startNode', function(localName, atts, uq, tagend, getStrNode) {

                    if (primitiveGroup !== null) {

                        if (lastElem(context) == Mesh.MeshContextEnum.LOD) // LOD are not handled yet
                            return;

                        if (localName == "PolygonalLOD")
                            context.push(Mesh.MeshContextEnum.LOD);

                        // buffers
                        if (lastElem(context) == Mesh.MeshContextEnum.DATA) {
                            StartFloatBuffer(atts);
                        }

                        // set of primitives
                        if (lastElem(context) == Mesh.MeshContextEnum.PRIMITIVESET) {
                            if (localName == "Face")
                                StartPrimitive(atts, 1);
                            else if (localName == "Polyline")
                                StartPrimitive(atts, 0);
                            //else if (localName == "SurfaceAttributes")
                            //  StartFillStyle(atts);
                            //else if (localName == "LineAttributes")
                            //  StartLineStyle(atts);
                        }

                        // primitive
                        //if (lastElem(context) == Mesh.MeshContextEnum.PRIMITIVE)
                        //{
                        if (localName == "SurfaceAttributes")
                            StartFillStyle(atts);
                        else if (localName == "LineAttributes")
                            StartLineStyle(atts);
                        //}

                        // graphic properties
                        if (localName == "Color")
                            StartColor(atts);
                        else if (localName == "MaterialApplication")
                            StartMaterialApplication(atts);
                        else if (localName == "MaterialId")
                            StartMaterialId(atts);

                        if (localName == "Faces" || localName == "Edges")
                            StartPrimitiveSet(atts);
                        else if (localName == "VertexBuffer")
                            StartData(atts);

                    } else {
                        if (((lastElem(context) == Mesh.MeshContextEnum.UNKNOWN) || (lastElem(context) == Mesh.MeshContextEnum.BAG)) &&
                            ((localName == "XMLRepresentation") || (localName == "Root") || (localName == "Rep"))) {
                            StartNode(atts);
                        }
                    }
                });

                parser.on('endNode', function(localName, uq, tagstart, str) {

                    if (lastElem(context) == Mesh.MeshContextEnum.LINEATTR ||
                        lastElem(context) == Mesh.MeshContextEnum.SURFACEATTR) {
                        if ((localName == "LineAttributes") ||
                            (localName == "SurfaceAttributes"))
                            EndStyle();

                        return;
                    }

                    if (lastElem(context) == Mesh.MeshContextEnum.LOD) {
                        if (localName == "PolygonalLOD")
                            context.pop();

                        return;
                    }

                    switch (lastElem(context)) {
                        // data
                        case Mesh.MeshContextEnum.DATA:
                            EndData();
                            break;

                        case Mesh.MeshContextEnum.FLOATBUFFER:
                            if (localName == "Positions")
                                EndFloatBuffer(null, Mesh.VertexComponentEnum.POSITION);
                            else if (localName == "Normals")
                                EndFloatBuffer(null, Mesh.VertexComponentEnum.NORMAL);
                            else if (localName == "TextureCoordinates")
                                EndFloatBuffer(null, Mesh.VertexComponentEnum.TEX_COORD_0);
                            break;

                            // primitive
                        case Mesh.MeshContextEnum.PRIMITIVESET:
                            EndPrimitiveSet();
                            break;
                        case Mesh.MeshContextEnum.PRIMITIVE:
                            EndPrimitive();
                            break;

                            // geometry
                        case Mesh.MeshContextEnum.GRAPHICPROPERTIES:
                            //case Mesh.MeshContextEnum.APPEARANCE:
                            context.pop();
                            break;

                        default:
                            break;
                    }

                    if ((localName == "XMLRepresentation") || (localName == "Root") || (localName == "Rep"))
                        EndNode(null);
                });

                parser.on('textNode', function(s, uq) {

                    currentData = uq(s);
                });

                //parser.on('cdata', function(data) {
                //});

                parser.parse(url);

                // group all reps in one (or more if indices are >= 65535)
                var reps = [];
                var max_indices = 0;

				var maxIndicePermitted=65535;
				if(uint32Index)
					maxIndicePermitted=524287/*4294967295*/;//limit to smaller batches
                for (var n = 0; n < all_reps.length; n++) {

                    var vbLength = all_reps[n].vertexPositionArray ? (all_reps[n].vertexPositionArray.length / 3) : 0;

                    if (max_indices + vbLength >= maxIndicePermitted) {
                        if (max_indices == 0) {
                            var repGroup = Mesh.divideRep(all_reps[n],uint32Index);

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

                    if (vbLength >= maxIndicePermitted) {
                        var repGroup = Mesh.divideRep(all_reps[n],uint32Index);
                        for (var m = 0; m < repGroup.length; m++)
                            node_base.push(repGroup[m]);
                        continue;
                    }
                    reps.push(all_reps[n]);
                    max_indices += vbLength;
                }

                if (reps.length > 0) {
                    var repGroup = Mesh.processReps(reps);
                    repGroup.sceneGraph = SGRoot;

                    node_base.push(repGroup);
                }

                // associate the scene graph structure to the node_base
                //node_base.sceneGraph = SGRoot;

                // build the bspheres of primitives

                if (computePrimitiveBS) {

                    for (var i = 0; i < node_base.length; i++) {

                        var mesh = node_base[i];
                        var pos = mesh.vertexPositionArray;
                        var idx = mesh.vertexIndexArray;

                        for (var j = 0; j < mesh.drawingGroups.length; j++) {

                            var dg = mesh.drawingGroups[j];

                            for (var k = 0; k < dg.primitives.length; k++) {

                                var prim = dg.primitives[k];

                                var min = [Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE];
                                var max = [-Number.MAX_VALUE, -Number.MAX_VALUE, -Number.MAX_VALUE];

                                for (var n = prim.start; n < prim.start + prim.count; n++) {

                                    var ii = idx[n];

                                    if (pos[3 * ii    ] < min[0]) min[0] = pos[3 * ii];
                                    if (pos[3 * ii + 1] < min[1]) min[1] = pos[3 * ii + 1];
                                    if (pos[3 * ii + 2] < min[2]) min[2] = pos[3 * ii + 2];
                                    if (pos[3 * ii    ] > max[0]) max[0] = pos[3 * ii];
                                    if (pos[3 * ii + 1] > max[1]) max[1] = pos[3 * ii + 1];
                                    if (pos[3 * ii + 2] > max[2]) max[2] = pos[3 * ii + 2];
                                }

                                var radius = (min[0] - max[0]) * (min[0] - max[0]);
                                radius += (min[1] - max[1]) * (min[1] - max[1]);
                                radius += (min[2] - max[2]) * (min[2] - max[2]);
                                radius = 0.5 * Math.sqrt(radius);

                                min[0] = 0.5 * (min[0] + max[0]);
                                min[1] = 0.5 * (min[1] + max[1]);
                                min[2] = 0.5 * (min[2] + max[2]);

                                prim.boundingSphere = {
                                    center: min,
                                    radius: radius
                                };
                            }
                        }
                    }
                }

                if (readyCallback) {
                    readyCallback(node_base);
                }
            };


            function StartNode(atts) {
                var attributes = atts();
                var type = attributes["xsi:type"];

                if (type == "PolygonalRepType") {
                    context.push(Mesh.MeshContextEnum.MESH);

                    primitiveGroup = new Mesh.PrimitiveGroup();

                    currentIndexBufferData = [];
                    currentPositionBufferData = [];

                    //var meshType = attributes["type"];
                    var xmlID = attributes["id"];
                    var accuracy = attributes["accuracy"];
                    var solid = attributes["solid"];

                    primitiveGroup.identifier = xmlID;
                    if (solid !== undefined) {
                        primitiveGroup.fillAttr = new Mesh.FillAttributes();
                        primitiveGroup.fillAttr.solid = solid === "1" ? 1.0 : 0.0;
                    }

                    // update the scene graph

                    var parent = lastElem(scene_graph);

                    var sgRep = new Mesh.SGRep({
                        cgmId: xmlID,
                        parent: parent,
                        solid: solid
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

                    // finalize primitive group

                    var nonIndexedPositionBuffer = null;
                    var indexBuffer = null;

                    var nonIndexedPositionBufferId = -1;
                    var indexBufferId = -1;

                    if (currentPositionBufferData.length > 0) {
                        // non-indexed primitives exist, a new position buffer is created

                        nonIndexedPositionBuffer = new Mesh.Buffer();

                        nonIndexedPositionBuffer.data = _convertToTypedArray(currentPositionBufferData);
                        nonIndexedPositionBuffer.indexBuffer = false;
                        nonIndexedPositionBuffer.size = nonIndexedPositionBuffer.data.length;
                        nonIndexedPositionBuffer.format = Mesh.DataTypeEnum.FLOAT;
                        nonIndexedPositionBuffer.dimension = 3;

                        nonIndexedPositionBufferId = getUniqueBufferId();
                    }

                    // create an index buffer

                    indexBuffer = new Mesh.Buffer();

                    indexBuffer.data = _convertToTypedArray(currentIndexBufferData);
                    indexBuffer.indexBuffer = true;
                    indexBuffer.size = indexBuffer.data.length;
                    indexBuffer.format = Mesh.DataTypeEnum.UINT;
                    indexBuffer.dimension = 1;

                    indexBufferId = getUniqueBufferId();

                    for (var i = 0; i < primitiveGroup.nbPrimitives; i++) {
                        var primitive = primitiveGroup.primitives[i];
                        var component = primitive.vertexComponents[0];

                        if (component !== undefined) {
                            if (component.indices == null) {
                                // non-indexed primitive
                                component.bufferId = nonIndexedPositionBufferId;
                            } else {
                                // indexed primitive
                                component.indices.bufferId = indexBufferId;

                                var bufferId = 0;

                                for (bufferId in primitiveGroup.buffers) {
                                    if (!primitiveGroup.buffers.hasOwnProperty(bufferId))
                                        continue;

                                    var buffer = primitiveGroup.buffers[bufferId];

                                    if (buffer.component == Mesh.VertexComponentEnum.POSITION) {
                                        component.bufferId = bufferId;
                                        continue;
                                    }

                                    // create the corresponding vertex component

                                    var vcomp = new Mesh.VertexComponent();
                                    vcomp.component = buffer.component;
                                    vcomp.nbVertices = component.nbVertices;
                                    vcomp.nbValuesPerVertex = component.nbValuesPerVertex;
                                    vcomp.format = Mesh.DataTypeEnum.FLOAT;
                                    vcomp.bufferId = bufferId;

                                    vcomp.indices = new Mesh.IndexArray();
                                    vcomp.indices.bufferId = indexBufferId;
                                    vcomp.indices.offset = component.indices.offset;

                                    primitive.addVertexComponent(vcomp);
                                }
                            }
                        }
                    }

                    if (nonIndexedPositionBufferId != -1)
                        primitiveGroup.addBuffer(nonIndexedPositionBufferId, nonIndexedPositionBuffer);

                    if (indexBufferId != -1)
                        primitiveGroup.addBuffer(indexBufferId, indexBuffer);

                    // CONVERSION TO pseudo THREE JS
                    var nodeMesh = Mesh.convertToGeometry3js(primitiveGroup, undefined, undefined, false, "mono");

                    var sgRep = lastElem(scene_graph);
                    //test F4L
                    //if (sgRep.type == "SGBag") {
                    //  while (sgRep.type != "SGRep") {
                    //    sgRep = sgRep.children[0];
                    //  }
                    //}
                    nodeMesh.rep = sgRep;

                    all_reps.push(nodeMesh);
                    //--

                    primitiveGroup = null;
                    currentMaterialRep = null;
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
            }

            function EndBag(atts) {
                //scene_graph.pop();

                //gas.pop();
            }

            function StartFillStyle(atts) {
                context.push(Mesh.MeshContextEnum.SURFACEATTR);

                if (lastElem(context) == Mesh.MeshContextEnum.MESH) {
                    currentStyle = lastElem(gas).fill;
                } else if (currentPrimitive.length > 0) // primitive context
                {
                    var prevGAS = lastElem(gas);
                    currentGASPrimitive = {
                        fill: prevGAS.fill.clone(),
                        line: prevGAS.line.clone(),
                        point: prevGAS.point.clone()
                    };

                    for (var i = 0; i < currentPrimitive.length; i++) {
                        var prim = currentPrimitive[i];
                        prim.attr = currentGASPrimitive;
                    }

                    currentStyle = currentGASPrimitive.fill;
                } else // primitive set context
                {
                    currentStyle = lastElem(gas).fill;
                    currentGASPrimitiveSet = lastElem(gas);
                }
            }

            function StartLineStyle(atts) {
                context.push(Mesh.MeshContextEnum.LINEATTR);

                var attributes = atts();
                var thickness = 1; //attributes["thickness"];
                var pattern = Mesh.LinePatternEnum.SOLID; //attributes["lineType"];
                

                if (thickness || pattern) {
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

                    if (lastElem(context) == Mesh.MeshContextEnum.MESH) {
                        currentStyle = lastElem(gas).fill;
                    } else if (currentPrimitive.length > 0) // primitive context
                    {
                        var prevGAS = lastElem(gas);
                        currentGASPrimitive = {
                            fill: prevGAS.fill.clone(),
                            line: prevGAS.line.clone(),
                            point: prevGAS.point.clone()
                        };

                        if (thickness) currentGASPrimitive.line.thickness = parseFloat(thickness);
                        if (pattern) currentGASPrimitive.line.pattern = tmp;

                        for (var i = 0; i < currentPrimitive.length; i++) {
                            var prim = currentPrimitive[i];
                            prim.attr = currentGASPrimitive;
                        }

                        currentStyle = currentGASPrimitive.line;
                    } else // primitive set context
                    {
                        if (thickness) lastElem(gas).line.thickness = parseFloat(thickness);
                        if (pattern) lastElem(gas).line.pattern = tmp;

                        currentStyle = lastElem(gas).line;

                        currentGASPrimitiveSet = lastElem(gas);
                    }
                }
            }

            function EndStyle(atts) {
                if (currentColor && currentStyle) {
                    currentStyle.color = currentColor;
                }

                currentStyle = null;
                currentColor = null;

                context.pop();
            }

            /*
    function StartPointStyle(atts)
    {
      context.push(Mesh.MeshContextEnum.GRAPHICPROPERTIES);

      var color = atts.getValueByName("color");
      var size = atts.getValueByName("size");
      var symbol = atts.getValueByName("symbol");

      if (color || size || symbol)
      {
        var tmp = Mesh.PointSymbolEnum.CROSS;

        if (symbol)
        {
          switch (symbol)
          {
            case "CROSS": tmp = Mesh.PointSymbolEnum.CROSS; break;
            case "PLUS": tmp = Mesh.PointSymbolEnum.PLUS; break;
            case "CONCENTRIC": tmp = Mesh.PointSymbolEnum.CONCENTRIC; break;
            case "COINCIDENT": tmp = Mesh.PointSymbolEnum.COINCIDENT; break;
            case "FULL_CIRCLE": tmp = Mesh.PointSymbolEnum.FULLCIRCLE; break;
            case "FULL_SQUARE": tmp = Mesh.PointSymbolEnum.FULLSQUARE; break;
            case "STAR": tmp = Mesh.PointSymbolEnum.STAR; break;
            case "DOT": tmp = Mesh.PointSymbolEnum.DOT; break;
            case "SMALL_DOT": tmp = Mesh.PointSymbolEnum.SMALLDOT; break;
            default : break;
          }
        }

        if (currentPrimitive != null)
        {
          if (currentPrimitive.attr == null)
          {
            var prevGAS = lastElem(gas);
            currentPrimitive.attr = {fill: prevGAS.fill.clone(), line: prevGAS.line.clone(), point: prevGAS.point.clone()};
          }
          if (color) currentPrimitive.attr.point.color = getColor(color);
          if (size) currentPrimitive.attr.point.size = parseFloat(size);
          if (symbol) currentPrimitive.attr.point.symbol = tmp;
        }
        else
        {
          if (color) lastElem(gas).point.color = getColor(color);
          if (size) lastElem(gas).point.size = parseFloat(size);
          if (symbol) lastElem(gas).point.symbol = tmp;
        }
      }
    }
    */

            function StartColor(atts) {
                var attributes = atts();

                var r = parseFloat(attributes["red"]);
                var g = parseFloat(attributes["green"]);
                var b = parseFloat(attributes["blue"]);
                var a = parseFloat(attributes["alpha"]);

                currentColor = new Mesh.Color(r, g, b, a);
            }

            function StartMaterialApplication(atts) {
                var attributes = atts();
                var channel = attributes["mappingChannel"];
            }

            function StartMaterialId(atts) {
                var material_file = "";
                var attributes = atts();
                var material_id = attributes["id"];

                var temp = [];

                temp = material_id.split('urn:3DXML:');
                material_id = temp[1];
                temp = material_id.split('#');

                material_file = temp[0];
                material_id = temp[1];

                if (lastElem(context) == Mesh.MeshContextEnum.MESH) {
                    currentMaterialRep = {
                        file: material_file,
                        id: material_id
                    };
                } else if (currentPrimitive.length > 0) // primitive context
                {
                    for (var i = 0; i < currentPrimitive.length; i++) {
                        var prim = currentPrimitive[i];
                        prim.material = {
                            file: material_file,
                            id: material_id
                        };
                    }

                    currentStyle = currentGASPrimitive.fill;
                } else // primitive set context
                {
                    currentMaterialPrimitiveSet = {
                        file: material_file,
                        id: material_id
                    };
                }
            }

            function StartPrimitiveSet(atts) {
                context.push(Mesh.MeshContextEnum.PRIMITIVESET);

                currentPrimitiveSet = [];

                var prevGAS = lastElem(gas);
                gas.push({
                    fill: prevGAS.fill.clone(),
                    line: prevGAS.line.clone(),
                    point: prevGAS.point.clone()
                });
            }

            function EndPrimitiveSet(atts) {
                context.pop();

                for (var i = 0; i < currentPrimitiveSet.length; i++) {
                    var prim = currentPrimitiveSet[i];

                    // gas inheritance from primitive set

                    if (prim.attr == null && currentGASPrimitiveSet !== null) {
                        prim.attr = {
                            fill: currentGASPrimitiveSet.fill.clone(),
                            line: currentGASPrimitiveSet.line.clone(),
                            point: currentGASPrimitiveSet.point.clone()
                        };
                    }

                    // material inheritance

                    if (prim.material == null && currentMaterialPrimitiveSet !== null) {
                        if (currentMaterialPrimitiveSet !== null)
                            prim.material = currentMaterialPrimitiveSet;
                        else if (currentMaterialRep !== null)
                            prim.material = currentMaterialRep;
                    } //else //test F4L
                    //prim.material = { file: "", id: -1 }
                    // add primitive to rep

                    primitiveGroup.addPrimitive(prim);
                }

                currentPrimitiveSet = null;
                currentGASPrimitiveSet = null;
                currentMaterialPrimitiveSet = null;

                gas.pop();
            }

            function StartPrimitive(atts, type) {
                context.push(Mesh.MeshContextEnum.PRIMITIVE);

                var attributes = atts();

                if (type == 0) // polylines
                {
                    var tmp = attributes['vertices'];
                    if (tmp !== undefined) {
                        tmp = tmp.replace(/,/g, " ");
                        var vertices = _floats(tmp);
                        var vbOffset = currentPositionBufferData.length / 3;

                        for (var j = 0; j < vertices.length; j++)
                            currentPositionBufferData.push(vertices[j]);

                        var prim = new Mesh.Primitive();
                        prim.connectivity = Mesh.ConnectivityTypeEnum.LINE_STRIP;
                        prim.nbIndices = vertices.length / 3;
                        prim.geomType = "SHARP_EDGE";

                        // create the position component

                        vcomp = new Mesh.VertexComponent();
                        vcomp.nbVertices = vertices.length / 3;
                        vcomp.nbValuesPerVertex = 3;
                        vcomp.format = Mesh.DataTypeEnum.FLOAT;
                        vcomp.bufferId = -1; // will be placed later
                        vcomp.offset = vbOffset;
                        vcomp.indices = null; // polyline is not indexed

                        prim.addVertexComponent(vcomp);

                        currentPrimitive.push(prim);
                        currentPrimitiveSet.push(prim);
                    }
                } else if (type == 1) // faces
                {
                    // triangles

                    var tmp = attributes['triangles'];
                    if (tmp !== undefined) {
                        var triangles = _ints(tmp);
                        if (triangles.length > 0) {
                            var prim = new Mesh.Primitive();
                            prim.connectivity = Mesh.ConnectivityTypeEnum.TRIANGLES;
                            prim.nbIndices = triangles.length;
                            prim.geomType = "FACE";

                            // concatenate the indices in a temporary index buffer

                            var ibOffset = currentIndexBufferData.length;
                            for (var j = 0; j < triangles.length; j++)
                                currentIndexBufferData[ibOffset + j] = triangles[j];

                            // create the position component

                            vcomp = new Mesh.VertexComponent();
                            vcomp.nbVertices = triangles.length;
                            vcomp.nbValuesPerVertex = 3;
                            vcomp.format = Mesh.DataTypeEnum.FLOAT;
                            vcomp.bufferId = -1; // will be placed later

                            vcomp.indices = new Mesh.IndexArray();
                            vcomp.indices.bufferId = -1;
                            vcomp.indices.offset = ibOffset;

                            prim.addVertexComponent(vcomp);

                            currentPrimitive.push(prim);
                            currentPrimitiveSet.push(prim);
                        }
                    }

                    // strips

                    tmp = attributes['strips'];
                    if (tmp !== undefined) {
                        var strips = tmp.split(',');
                        for (var i = 0; i < strips.length; i++) {
                            var item = _ints(strips[i]);

                            if (item.length > 0) {
                                var prim = new Mesh.Primitive();
                                prim.connectivity = Mesh.ConnectivityTypeEnum.TRIANGLE_STRIP;
                                prim.nbIndices = item.length;
                                prim.geomType = "FACE";

                                // concatenate the indices in a temporary index buffer

                                var ibOffset = currentIndexBufferData.length;
                                for (var j = 0; j < item.length; j++)
                                    currentIndexBufferData[ibOffset + j] = item[j];

                                // create the position component

                                vcomp = new Mesh.VertexComponent();
                                vcomp.nbVertices = item.length;
                                vcomp.nbValuesPerVertex = 3;
                                vcomp.format = Mesh.DataTypeEnum.FLOAT;
                                vcomp.bufferId = -1; // will be placed later

                                vcomp.indices = new Mesh.IndexArray();
                                vcomp.indices.bufferId = -1;
                                vcomp.indices.offset = ibOffset;

                                prim.addVertexComponent(vcomp);

                                currentPrimitive.push(prim);
                                currentPrimitiveSet.push(prim);
                            }
                        }
                    }

                    // fans

                    tmp = attributes['fans'];
                    if (tmp !== undefined) {
                        var fans = tmp.split(',');
                        for (var i = 0; i < fans.length; i++) {
                            var item = _ints(fans[i]);

                            if (item.length > 0) {
                                var prim = new Mesh.Primitive();
                                prim.connectivity = Mesh.ConnectivityTypeEnum.TRIANGLE_FAN;
                                prim.nbIndices = item.length;
                                prim.geomType = "FACE";
                                // concatenate the indices in a temporary index buffer

                                var ibOffset = currentIndexBufferData.length;
                                for (var j = 0; j < item.length; j++)
                                    currentIndexBufferData[ibOffset + j] = item[j];

                                // create the position component

                                vcomp = new Mesh.VertexComponent();
                                vcomp.nbVertices = item.length;
                                vcomp.nbValuesPerVertex = 3;
                                vcomp.format = Mesh.DataTypeEnum.FLOAT;
                                vcomp.bufferId = -1; // will be placed later

                                vcomp.indices = new Mesh.IndexArray();
                                vcomp.indices.bufferId = -1;
                                vcomp.indices.offset = ibOffset;

                                prim.addVertexComponent(vcomp);

                                currentPrimitive.push(prim);
                                currentPrimitiveSet.push(prim);
                            }
                        }
                    }

                }
            }

            function EndPrimitive(atts) {
                context.pop();

                currentPrimitive = [];
                currentGASPrimitive = null;
            }

            function StartData(atts) {
                context.push(Mesh.MeshContextEnum.DATA);
            }

            function EndData(atts) {
                context.pop();
            }

            function StartFloatBuffer(atts) {
                context.push(Mesh.MeshContextEnum.FLOATBUFFER);

                currentData = "";

                var attributes = atts();
                var dim = attributes["dimension"];
                if (dim != null) {
                    if (dim == "1D") currentTextureDimension = 1;
                    if (dim == "2D") currentTextureDimension = 2;
                    if (dim == "3D") currentTextureDimension = 3;
                }

                var channel = attributes["channel"];
                if (channel != null) {
                    currentTextureChannel = parseInt(channel, 10);
                }
            }

            function EndFloatBuffer(atts, component) {
                context.pop();

                if (currentData != "") {
                    var buffer = new Mesh.Buffer();
                    buffer.indexBuffer = false;
                    buffer.format = Mesh.DataTypeEnum.FLOAT;
                    buffer.component = component;
                    buffer.dimension = 3;

                    var tmp = currentData.replace(/,/g, " ");

                    if (component == Mesh.VertexComponentEnum.TEX_COORD_0) {
                        buffer.dimension = currentTextureDimension;
                    }

                    if (buffer.dimension < 3)
                        buffer.data = _floats2(tmp, buffer.dimension);
                    else
                        buffer.data = _floats(tmp);

                    buffer.size = buffer.data.length;

                    primitiveGroup.addBuffer(getUniqueBufferId(), buffer);
                }
            }

            // Parsing

            function _floats(str) {
                var raw = _strings(str);
                var data = [];

                for (var i = 0, l = raw.length; i < l; i++)
                    data.push(parseFloat(raw[i]));

                return data;
            };

            function _floats2(str, dimension) {
                var raw = _strings(str);
                var data = [];

                var dim = 3 - dimension;

                for (var i = 0, l = raw.length; i < l; i += dimension) {
                    if (dimension > 0) data.push(parseFloat(raw[i]));
                    if (dimension > 1) data.push(parseFloat(raw[i + 1]));
                    if (dim > 0) data.push(0.0);
                    if (dim > 1) data.push(0.0);
                }

                return data;
            };

            function _ints(str) {
                var raw = _strings(str);
                var data = [];

                for (var i = 0, l = raw.length; i < l; i++)
                    data.push(parseInt(raw[i], 10));

                return data;
            };

            function _strings(str) {
                return (str.length > 0) ? _trimString(str).split(/\s+/) : [];
            };

            function _trimString(str) {
                return str.replace(/^\s+/, "").replace(/\s+$/, "");
            };

            function _convertToTypedArray(jsArray) {
                var data = new Float32Array(jsArray.length);

                for (var i = 0, l = jsArray.length; i < l; i++)
                    data[i] = jsArray[i];

                return data;
            }

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
                                linewidth: gas.line.thickness
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


            var data = e.data;

            var abs_path = data.path ? data.path : data;
            var contextID = data.contextID ? data.contextID : 0;
			var uint32Index = data.uint32Index;

            cleanData();

            load(abs_path, function(mesh) {
                workerContext.postMessage({
                    rep: mesh,
                    node: data.node,
                    contextID: contextID
                });
                //cleanData ();
            });
        };
        workerContext.postMessage({loaded:true});
    });

})(this);
