define("DS/VisuLoaders/StreamVisuLoader",["DS/Visualization/ThreeJS_DS","DS/Visualization/Utils","DS/Mesh/MeshUtils","DS/Visualization/Node3D","DS/Visualization/Mesh3D","DS/Visualization/MaterialManager"],function(d,g,f,e,c,b){var a=function(m){var j=performance.now();var i=(m!==undefined)?m:null;this.modelsToLoad={};this.loadIndex=0;var k=new d.MeshPhongMaterial({side:d.DoubleSide,color:new d.Color(16777215)});var h=new d.MeshBasicMaterial({color:new d.Color(16777215)});var l={};this.createTextures=function(n,o){var p,s;for(p in n){var s=n[p];var r=null;if(o.imagesCallback){r=o.imagesCallback(s,o)}else{var q=s.format;if(!q){q=g.getExtension(s.path)}if(q==="hdr"){r=d.ImageUtils.loadHDRTexture(o.path+s.path+o.urlOptions)}else{if(q==="dds"){var t=false;r=d.ImageUtils.loadCompressedTexture(o.path+s.path+o.urlOptions,undefined,null,null,t)}else{r=d.ImageUtils.loadTexture2(o.path+s.path+o.urlOptions)}}r.wrapS=s.wrapS||1000;r.wrapT=s.wrapT||1000;r.anisotropy=s.anisotropy||8;r.minFilter=s.minFilter||1008;r.magFilter=s.magFilter||1006;r.repeat=s.repeat||{x:1,y:1};r.sRGB=(q==="jpg")||(q==="jpeg")}o.data.textures[s.id]=r}};this.createMaterials=function(n,s,p){var q,t;for(q in n){var t=n[q];var r=null;if(p.materialsCallback){r=p.materialsCallback(t,p)}else{var o={visible:t.visible,force:t.force,side:t.side,enableClipPlanes:t.enableClipPlanes,transparent:t.transparent,opacity:t.opacity,depthTest:t.depthTest,depthWrite:t.depthWrite};if(t.forceSide){o.forceSide=t.forceSide}if(t.NRECompatibility!==undefined){o.NRECompatibility=t.NRECompatibility}if(t.needTangentBinormal){o.needTangentBinormal=t.needTangentBinormal}if(t.alphaTest){o.alphaTest=t.alphaTest}if(t.color){o.color=new d.Color().setRGB(t.color.r,t.color.g,t.color.b)}if(t.ambient){o.ambient=new d.Color().setRGB(t.ambient.r,t.ambient.g,t.ambient.b)}if(t.emissive){o.emissive=new d.Color().setRGB(t.emissive.r,t.emissive.g,t.emissive.b)}if(t.specular){o.specular=new d.Color().setRGB(t.specular.r,t.specular.g,t.specular.b)}if(t.shininess){o.shininess=t.shininess}if(t.vertexColors){o.vertexColors=t.vertexColors}if(t.diffuseMap!==undefined){o.map=s.textures[t.diffuseMap]}if(t.opacityMap!==undefined){o.opacityMap=s.textures[t.opacityMap];o.transparent=true}if(t.normalMap!==undefined){o.normalMap=s.textures[t.normalMap];o.needTangentBinormal=true;if(t.needTangentBinormal!==undefined){o.needTangentBinormal=t.needTangentBinormal}}if(t.normalMapScale!==undefined){o.normalScale=new d.Vector2(t.normalMapScale.x,t.normalMapScale.y)}if(t.normalMapFlipY!==undefined){o.normalMapFlipY=t.normalMapFlipY}if(t.bumpMap!==undefined){o.bumpMap=s.textures[t.bumpMap]}if(t.bumpScale!==undefined){o.bumpScale=t.bumpScale}if(t.glossiness!==undefined){o.glossiness=t.glossiness}if(t.glossinessMap!==undefined){o.glossinessMap=s.textures[t.glossinessMap]}if(t.specularMap!==undefined){o.specularMap=s.textures[t.specularMap]}if(t.specularMap!==undefined){o.specularMap=s.textures[t.specularMap];o.specularMapLinear=!o.specularMap.sRGB}if(t.lightMap!==undefined){o.lightMap=s.textures[t.lightMap]}if(t.type=="Physical"){if(t.emissiveMap!==undefined){o.emissiveMap=s.textures[t.emissiveMap]}if(t.metalnessMap!==undefined){if(t.metalness===undefined){t.metalness=1}o.metalnessMap=s.textures[t.metalnessMap]}if(t.metalness!==undefined){o.metalness=t.metalness}if(t.coating!==undefined){o.coating=t.coating}if(t.coatingGlossiness!==undefined){o.coatingGlossiness=t.coatingGlossiness}}if(t.iterative!==undefined){o.iterative=t.iterative}if(t.sslr!==undefined){o.sslr=t.sslr}r=new d[t.type+"Material"](o)}s.materials[t.id]=r}};this.createGeometries=function(y,r){var J,x;var I=r.data;for(J in y){var x=y[J];var C=new d.BufferGeometryDS();I.geometries[x.id]=C;for(var t in x){var p=x[t];if((t==="vertexPositionArray"||t==="vertexIndexArray"||t==="vertexColorArray"||t==="vertexNormalArray"||t==="vertexBinormalArray"||t==="vertexTangentArray"||t==="vertexUvArray"||t==="vertexUv2Array")&&(p!==null)){if(t==="vertexIndexArray"){if(p.bpe===4){C[t]=new Uint32Array(I.chunks[p.chunk],p.offset,p.byteLength/p.bpe)}else{C[t]=new Uint16Array(I.chunks[p.chunk],p.offset,p.byteLength/p.bpe)}}else{C[t]=new Float32Array(I.chunks[p.chunk],p.offset,p.byteLength/p.bpe)}}}for(var F=0;F<x.dgs.length;F++){var H=x.dgs[F];var s=H.primitives;s=new Uint32Array(I.chunks[s.chunk],s.offset,s.byteLength/s.bpe);var v=H.canonicals;var K=(v!=undefined);var q=null;if(K){q=new Uint8Array(I.chunks[v.chunk],v.offset,v.byteLength/v.bpe)}var A=0;var w=C.vertexNormalArray?k:h;var G=[];if((H.gas!==undefined)&&I.materials[H.gas]){w=I.materials[H.gas]}var u=new f.DrawingGroup(w,null,H.glType,H.start,H.count,G,undefined,d.GeomTypeEnum[H.geomType],0);u.geometry=C;C.drawingGroups.push(u);for(var E=0;E<s.length;E+=4){var z=new f.SGPrimitive({cgmId:s[E],group:u,start:s[E+2],count:s[E+3]});if(r.unstreamReps){var o=s[E+1];var n=I.reps[o];if(!n){n=new f.SGRep({cgmId:o});I.reps[o]=n}z.rep=n;n.primitives.push(z)}if(K){var B=q[A++];if(B){z.decoration=new Array();for(var D=0;D<B;++D){z.decoration.push(q[A++])}}}G.push(z)}}}};this.createNodes=function(o,v){var B,t;var u=v.data;for(B in o){var t=o[B];var q=null;if(t.type==="Node3D"){q=new e();l[q.id]=t.children}else{var n=t.mesh3js.bs.c;var w=t.mesh3js.bs.r;var r=t.mesh3js.bbox.min;var z=t.mesh3js.bbox.max;var D=new d.Box3(new d.Vector3(r[0],r[1],r[2]),new d.Vector3(z[0],z[1],z[2]));var C=new d.Sphere(new d.Vector3(n[0],n[1],n[2]),w);var y=[];y.boundingSphere=C;y.boundingBox=D;for(var s=0;s<t.mesh3js.geometries.length;s++){y.push(u.geometries[t.mesh3js.geometries[s]])}var x=(y.length&&y[0]["vertexNormalArray"])?k:h;if(t.mesh3js.material!==undefined){x=u.materials[t.mesh3js.material]}var p=new d.Mesh(y,x);p.castShadow=(t.mesh3js.castShadow!==undefined)?t.mesh3js.castShadow:true;p.receiveShadow=(t.mesh3js.receiveShadow!==undefined)?t.mesh3js.receiveShadow:true;p.enableNormalDepth=(t.mesh3js.enableNormalDepth!==undefined)?t.mesh3js.enableNormalDepth:true;q=new c(p)}q.name=t.id;if(t.material!==undefined){q.setMaterial(u.materials[t.material])}u.nodes[t.id]=q;if(!u.root){u.root=q}if(t.matrix){var A=new d.Matrix4().setFromArray(t.matrix);q.setMatrix(A)}if(v.nodeCallback){v.nodeCallback(t,v,q)}}};this.createLayers=function(n,u){var r=u.data;for(var A in r.nodes){var o=r.nodes[A];var x=n[A];for(var s in x.occurrences){var w=x.occurrences[s].index;var q=x.occurrences[s];if(!q.layers.length){continue}o._occurrences[w].renderable.layer=new d.BufferLayer();for(var p=0;p<q.layers.length;p++){var t=q.layers[p];var z=r.geometries[t.geometry];var y=new d.DrawableInterval(t.drawableInterval.layerNum,t.drawableInterval.start,t.drawableInterval.count,r.materials[t.drawableInterval.material]);y.primitiveStart=t.drawableInterval.primitiveStart;y.primitiveCount=t.drawableInterval.primitiveCount;var v=new d.LayerInterval(z,z.drawingGroups[t.drawableGroup],y);o._occurrences[w].renderable.layer.addLayerInterval(v)}}}};this.processJSON=function(n){n.data.nbChunks=n.json.nbChunks;var o=n.json.zbin?"zbin":"bin";if(!n.data.chunks.length){this.getChunks(n.data.nbChunks,n,this.processChunks,o)}else{this.processChunks(n)}};this.processChunks=function(n){j=performance.now();var s=n.json;this.createTextures(s.textures,n);this.createMaterials(s.materials,n.data,n);this.createGeometries(s.geometries,n);this.createNodes(s.nodes,n);j=performance.now();for(var p in n.data.nodes){var q=n.data.nodes[p];var r=l[q.id];if(r){for(var o=0;o<r.length;o++){q.add(n.data.nodes[r[o]])}}l[q.id]=null}n.unstreamLayers&&this.createLayers(s.nodes,n);j=performance.now();n.destinationNode.add(n.data.root);if(n.doneCallback){n.doneCallback()}if(n.readyCallback){n.readyCallback()}delete this.modelsToLoad[n.loadIndex]};this.internalLoad=function(o){var p=this;var n=this.modelsToLoad[o];j=performance.now();if(!n.json){UWA.Ajax.request(n.url+".json"+n.urlOptions,{async:true,cors:true,withCredentials:true,onComplete:function(q){j=performance.now();n.json=JSON.parse(q);p.processJSON(n)}})}else{this.processJSON(n)}};this.getChunks=function(p,o,n,q){var s=this;if(!p){n.call(this,o);return}p--;var r=new XMLHttpRequest();r.open("GET",o.url+"__"+p+"__."+q+o.urlOptions,true);r.responseType="arraybuffer";r.withCredentials=true;r.onreadystatechange=function(t){if(r.readyState===4){if(r.status===0||r.status===200){o.data.chunks[p]=this.response;s.getChunks(p,o,n,q)}}};r.send(null)};this.load=function(F,A,n,s,B){var q=F;var D="";var C=null;var u=[];var y=A;var E=n;var t=s;var p=null;var x=null;var w=null;var v=B;var o=false;var r=false;if(F.destinationNode){q=F.url;D=F.urlOptions?F.urlOptions:"";C=F.json;u=F.chunks?F.chunks:[];y=F.readyCallback;E=F.progressCallback;t=F.doneCallback;p=F.nodeCallback;x=F.imageCallback;w=F.materialCallback;v=F.destinationNode;o=!!F.layers;r=!!F.reps}var z={url:q,urlOptions:D,path:q?g.parseUrl(q+".json").directoryPath:null,json:C,readyCallback:y,progressCallback:E,doneCallback:t,imagesCallback:x,materialsCallback:w,nodeCallback:p,destinationNode:v,unstreamLayers:o,unstreamReps:r,loadIndex:this.loadIndex,data:{nbChunks:u?u.length:0,chunks:u,root:null,nodes:{},geometries:{},textures:{},materials:{},reps:{}}};this.modelsToLoad[this.loadIndex]=z;this.internalLoad(this.loadIndex);this.loadIndex++}};return a});define("Visualization/StreamVisuLoader",["DS/Visualization/StreamVisuLoader","DS/DSMigration/DSMigration"],function(b,a){a.deprecateModule("Visualization/StreamVisuLoader");return b});