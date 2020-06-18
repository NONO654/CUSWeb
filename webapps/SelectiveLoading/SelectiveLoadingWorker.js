this.importScripts("../AmdLoader/AmdLoader.js");var that=this;require.config({baseUrl:"../"});require(["SelectiveLoading/SelectiveLoadingImpl"],function(p){var d=["workerStarted","autoLoad","autoUnload","load","unload","ready","error"];var g=[];var i=function(E){g.push(E);if(d.indexOf(E[0])!=-1){if(g.length>1){that.postMessage(["pack",g])}else{that.postMessage(g[0])}g.length=0}};p.Helpers.prototype.buildBox=function(F,E,J,I,H,G){return{min:{x:F,y:E,z:J},max:{x:I,y:H,z:G}}};p.Helpers.prototype.buildMatrix=function(E){return{elements:new Float64Array(E)}};var v=function(E){this.unused=[]};v.prototype.getBoxId=function(E){if(this.unused.length==0){i(["error","all boxes are used!"]);return -1}var F=this.unused.pop();return F};v.prototype.updateBox=function(F,E){i(["updateBox",F,E.min,E.max])};v.prototype.updateBoxFromCoordinates=function(F,J,I,H,E,M,L){var G={x:J,y:I,z:H};var K={x:E,y:M,z:L};i(["updateBox",F,G,K])};v.prototype.hideBox=function(E){i(["hideBox",E])};v.prototype.showBox=function(E){i(["showBox",E])};v.prototype.yieldBox=function(E){this.hideBox(E);i(["yieldBox",E])};p.Context.prototype.enableLoadingBoxes=function(E){var F=new v(E);this.boxPool=F;this.cppContext.setBoxPool(F)};p.Context.prototype._notifyLoading=function(E){return this.cppContext.notifyLoading(E)};var s=new p.Helpers();var A=new p.Context();A.cppContext.setIsWorker(true);var c={};var f=function(J){var G=JSON.parse(J[1]);G.camera.getLookAt=function(){return J[2]};var H=J[3];A.cppContext.setAutoLoad(true);var K=[G.viewer.canvas.offsetHeight,G.viewer.canvas.offsetWidth];var I;if(0==K[0]||0==K[1]){I=[]}else{I=A.getLoadCandidates(G,H)}A.cppContext.setAutoLoad(false);if(I==undefined){i(["error","Error in autoLoad: getLoadCandidates failed",p.error.eInvalidArg])}else{var F=A._notifyLoading(I);if(F!==p.error.sOk){i(["error","Error in autoLoad: _notifyLoading failed",F])}else{var E=[];I.forEach(function(M){if(M.object.length!=undefined){var L=[];M.object.forEach(function(N){L.push(N.id)});E.push(L)}else{E.push(M.object.id)}});i(["autoLoad",E])}}};var k=function(J){var G=JSON.parse(J[1]);G.camera.getLookAt=function(){return J[2]};var H=J[3];var K=[G.viewer.canvas.offsetHeight,G.viewer.canvas.offsetWidth];var I;if(0==K[0]||0==K[1]){I=[]}else{I=A.getUnloadCandidates(G,H)}if(I==undefined){i(["error","Error in autoUnload: getUnloadCandidates failed",p.error.eInvalidArg])}else{var F=A.notifyUnload(I);if(F!==p.error.sOk){i(["error","Error in autoUnload: notifyUnload failed",F])}else{var E=[];I.forEach(function(M){if(M.object.length!=undefined){var L=[];M.object.forEach(function(N){L.push(N.id)});E.push(L)}else{E.push(M.object.id)}});i(["autoUnload",E])}}};var C=function(F,G,J,E){if(A.boxPool!=undefined){A.boxPool.unused.push(E)}var H=p.LDHJsModule._malloc(4*6);p.LDHJsModule.HEAPF32.set(G,H/4);var N=0;if(J!=undefined){N=p.LDHJsModule._malloc(8*16);p.LDHJsModule.HEAPF64.set(J,N/8)}var M=A.registerObjectFromTypedArrays(F,H,N);p.LDHJsModule._free(H);if(J!=undefined){p.LDHJsModule._free(N)}if(M==p.error.eAlreadyLoading){if(F.selectiveLoadingNodeId==undefined){i(["error","Error in onRegisterObjectMessageHelper: missing id",p.error.eInvalidArg])}else{var I=F.selectiveLoadingNodeId;var L=F.ldhBoxId;delete F.selectiveLoadingNodeId;delete F.ldhBoxId;i(["alreadyLoading",F.id,I,L])}}else{if(M!==p.error.sOk){var K=0;if(A.boxPool!=undefined){K=A.boxPool.unused.pop()}if(K!==E&&A.boxPool!=undefined){A.boxPool.unused.push(E)}i(["error","Error in registerObject: registerObject failed",M,F.id,E,G]);c[F.id]=null}}};var r=function(J){var E=J[1];var H=J[2];var G={uri:H,id:E};c[E]=G;var I=new Float32Array(J[3]);var F=(J[4]!=undefined?s.buildMatrix(J[4]).elements:undefined);var K=J[5];C(G,I,F,K)};var e=function(I){var F=new Uint32Array(I[1]);var M=I[2];var L=new Float32Array(I[3]);var O=undefined;if(I[4]!=undefined){O=new Float64Array(I[4])}var G=new Int32Array(I[5]);for(var J=0;J<F.length;J+=1){var H={uri:M[J],id:F[J]};c[F[J]]=H;var N=(O!=undefined?s.buildMatrix(O.buffer.slice(16*J*O.BYTES_PER_ELEMENT,(16*J+16)*O.BYTES_PER_ELEMENT)):undefined);var E=G[J];var K=new Float32Array(L.buffer,6*J*L.BYTES_PER_ELEMENT,6);C(H,K,(N!=undefined?N.elements:undefined),E)}};var j=function(H){var E=H[1];var G=c[E];if(G==undefined){i(["error","Error in unregisterObject: invalid object",p.error.eInvalidArg])}else{var F=A.unregisterObject(G);if(F!==p.error.sOk){i(["error","Error in unregisterObject: unregisterObject failed",F])}else{c[E]=null}}};var x=function(){c={};var E=A.unregisterAllObjects();A.boxPool.unused=[];if(E!==p.error.sOk){i(["error","Error in unregisterAllObjects: unregisterAllObjects failed",E])}};var q=function(H,G,F){if(H==undefined){i(["error","Error in updateObject: onUpdateObjectMessageHelper failed, object is invalid",p.error.eInvalidArg]);return}var J=0;var I=0;if(G!=undefined){J=p.LDHJsModule._malloc(4*6);p.LDHJsModule.HEAPF32.set(G,J/4)}if(F!=undefined){I=p.LDHJsModule._malloc(8*16);p.LDHJsModule.HEAPF64.set(F,I/8)}var E=A.updateObjectFromTypedArrays(H,H.composites,J,I);if(G!=undefined){p.LDHJsModule._free(J)}if(F!=undefined){p.LDHJsModule._free(I)}if(E!==p.error.sOk){i(["error","Error in updateObject: onUpdateObjectMessageHelper failed",E])}};var b=function(I){var E=I[1];var G=c[E];if(G==undefined){i(["error","Error in updateObject: invalid object",p.error.eInvalidArg])}else{var H=undefined;var F=undefined;if(I[2]!=undefined){H=new Float32Array(I[2])}if(I.length===4){F=(I[3]!=undefined?s.buildMatrix(I[3]).elements:undefined)}q(G,H,F)}};var h=function(H){var E=JSON.parse(H[1]);E.camera.getLookAt=function(){return H[2]};var F=H[3];var G=A.getLoadCandidates(E,F);if(G==undefined){i(["error","Error in getLoadCandidates: getLoadCandidates failed",p.error.eInvalidArg])}else{G.forEach(function(L,J,I){if(I[J].object.length!=undefined){var K=[];I[J].object.forEach(function(M){K.push(M.id)});I[J]=K}else{I[J]=I[J].object.id}});i(["load",G])}};var m=function(H){var E=JSON.parse(H[1]);E.camera.getLookAt=function(){return H[2]};var F=H[3];var G=A.getUnloadCandidates(E,F);if(G==undefined){i(["error","Error in getUnloadCandidates: getUnloadCandidates failed",p.error.eInvalidArg])}else{G.forEach(function(L,J,I){if(I[J].object.length!=undefined){var K=[];I[J].object.forEach(function(M){K.push(M.id)});I[J]=K}else{I[J]=I[J].object.id}});i(["unload",G])}};var u=function(H){var F=H[1];var G=[];F.forEach(function(I){var J=c[I];if(J!=undefined){G.push(J)}});var E=A.notifyLoad(G);if(E!==p.error.sOk){i(["error","Error in notifyLoad: notifyLoad failed",E])}};var a=function(H){var F=H[1];var G=[];F.forEach(function(I){var J=c[I];if(J!=undefined){G.push(J)}});var E=A.notifyUnload(G);if(E!==p.error.sOk){i(["error","Error in notifyUnload: notifyUnload failed",E])}};var o=function(E){i(["ready"])};var l=function(F){var E=A.toggleClippingPlanes(F[1]);if(E!==p.error.sOk){i(["error","Error in onToggleClippingPlanes: toggleClippingPlanes failed",E])}};var B=function(F){var E=A.addClippingPlane({normal:{x:F[1][0],y:F[1][1],z:F[1][2]},constant:F[1][3]});if(E!==p.error.sOk){i(["error","Error in onAddClippingPlane: addClippingPlane failed",E])}};var t=function(F){var E=A.removeClippingPlane({normal:{x:F[1][0],y:F[1][1],z:F[1][2]},constant:F[1][3]});if(E!==p.error.sOk){i(["error","Error in onRemoveClippingPlane: removeClippingPlane failed",E])}};var D=function(){var E=A.emptyClippingPlanes();if(E!==p.error.sOk){i(["error","Error in onEmptyClippingPlanes: emptyClippingPlanes failed",E])}};var z=function(E){A.enableLoadingBoxes(E[1])};var y=function(K){var J=K[1][0];var L=K[1][1];var H=J.length;var I=[];for(var G=0;G<H;G+=1){var F=c[J[G]];if(F==undefined){i(["error","Error in onModifyURL: invalid object",p.error.eInvalidArg])}I.push(F)}var E=A.modifyURL(I,L);if(E!==p.error.sOk){i(["error","Error in onModifyURL: modifyURL failed",E])}};var n=function(L){var K=L[1][0];var F=L[1][1];var I=K.length;var J=[];for(var H=0;H<I;H+=1){var G=c[K[H]];if(G==undefined){i(["error","Error in onForceLoad: invalid object",p.error.eInvalidArg])}J.push(G)}var E=A.forceLoad(J,F);if(E!==p.error.sOk){i(["error","Error in onForceLoad: forceLoad failed",E])}i(["autoLoad",K])};var w=function(G){var H=G[0];switch(H){case"pack":var F=G[1];for(var E=0;E<F.length;++E){w(F[E])}break;case"autoLoad":f(G);break;case"autoUnload":k(G);break;case"registerObject":r(G);break;case"registerObjects":e(G);break;case"unregisterObject":j(G);break;case"unregisterAllObjects":x(G);break;case"updateObject":b(G);break;case"getLoadCandidates":h(G);break;case"getUnloadCandidates":m(G);break;case"notifyLoad":u(G);break;case"notifyUnload":a(G);break;case"ready":o(G);break;case"addClippingPlane":B(G);break;case"toggleClippingPlanes":l(G);break;case"removeClippingPlane":t(G);break;case"emptyClippingPlanes":D(G);break;case"enableLoadingBoxes":z(G);break;case"modifyURL":y(G);break;case"forceLoad":n(G);break;case"profile":console.profile(G[1]);break;case"profileEnd":console.profileEnd();break;default:i(["error","Unsupported command: "+H,p.error.eFail]);break}};that.onmessage=function(F){var E=F.data;w(E)};i(["workerStarted",p.LDHJsModule.TOTAL_MEMORY])});