define("DS/DMUBaseUI/DMUContextualBarAdapter",["UWA/Class","DS/DMUBaseExperience/EXPManagerSet"],function(b,c){var a=b.extend({register:function(e){if(e){var d=c.getManager({name:"DMUUserExperienceManager",context:e.frmWindow});if(d){d.registerContextualBar(e)}}}});return a});define("DS/DMUBaseUI/DMUToolsLeader",["DS/DMUMeasurable/DMUToolsMaths","DS/DMUMeasurable/DMUMathsInfiniteGeometry","DS/DMUBaseExperience/EXPToolsVisualization","DS/Visualization/ThreeJS_DS","DS/Mesh/MeshUtils","DS/SceneGraphNodes/ArrowNode","DS/DMUBaseExperience/EXPToolsMaterial"],function(h,b,a,d,g,e,c){var f={modifyLeaderNode:function(w,A,j,z,B,v,s,i,y,m,u,l){var t;var q={};q.vBreak=z.clone();q.vAttach=z.clone();if(j){q=this._computeNewPoints(w,z,B,v,u,l)}if(q.vBreak===null&&q.vAttach===null){return t}var x=c.getDashPattern(y,null,true);var k=2;var p={arrowWidth:s,headLength:Math.max(2*s+4,10),viewpoint:w.currentViewpoint,arrowDashType:x,arrowScale:k,color:i};var r=!h.areEqual(q.vBreak,B,"Vector3");var n=A.getChildByName("attach");if(!n){if(r){p.initialPoint=q.vBreak.clone();p.finalPoint=B.clone();p.head=m;n=new e(p);n.name="attach";n.setPickable(g.NOPICKABLE);A.add(n);t+="(redraw attach)"}}else{if(r){n.updateInitialPosition(q.vBreak);n.updateFinalPosition(B);n.updateColor(i);n.setArrowWidth(s);n.setHeadSize(Math.max(2*s+4,10));n.setHeadType(m);n.setArrowPattern(x);n.setArrowPatternScale(k);t+="(modify attach)"}else{A.remove(n);t+="(delete attach)"}}var C=r&&!h.areEqual(q.vBreak,q.vAttach,"Vector3");var o=A.getChildByName("step");if(!o){if(C){p.initialPoint=q.vBreak.clone();p.finalPoint=q.vAttach.clone();p.head=0;o=new e(p);o.name="step";o.setPickable(g.NOPICKABLE);A.add(o);t+="(redraw step)"}}else{if(C){o.updateInitialPosition(q.vBreak);o.updateFinalPosition(q.vAttach);o.updateColor(i);o.setArrowWidth(s);o.setHeadSize(Math.max(2*s+4,10));o.setHeadType(0);n.setArrowPattern(x);n.setArrowPatternScale(k);t+="(modify step)"}else{A.remove(o);t+="(delete step)"}}return t},_computeNewPoints:function(z,l,D,v,t,m){var B={};B.vBreak=l.clone();B.vAttach=l.clone();var w=105*(Math.PI/180);var r=15;var x;var k;if(t.offsetHeight){k=t.offsetHeight/2}else{if(t.style.pixelHeight){k=t.style.pixelHeight/2}}if(t.offsetWidth){x=t.offsetWidth/2}else{if(t.style.pixelWidth){x=t.style.pixelWidth/2}}var A=a.getWindowPositionFromPoint(z,l,m);var j=a.getWindowPositionFromPoint(z,D,m);var o=j.left-A.left;var i=j.top-A.top;var p=x+r;var s=(i>0)?f.AttachmentSide.BOTTOM:f.AttachmentSide.TOP;if(o>0){if(v&&v.width!==undefined){r=t.offsetWidth*v.width;p=x+r}if(o>p){var u=new d.Vector3(-p,0,0);var q=new d.Vector3(o-p,i,0);var y=u.angleTo(q);if(y>w){s=f.AttachmentSide.RIGHT}}}else{if(-o>p){if(v&&v.width!==undefined){r=t.offsetWidth*v.width;p=x+r}var u=new d.Vector3(p,0,0);var q=new d.Vector3(o+p,i,0);var y=u.angleTo(q);if(y>w){s=f.AttachmentSide.LEFT}}}if(o<0){o=-o}var i=j.top-A.top;if(i<0){i=-i}if(i<k&&o<x){B.vBreak=null;B.vAttach=null;return B}if((s===f.AttachmentSide.RIGHT)||(s===f.AttachmentSide.LEFT)){var n=x;if(s===f.AttachmentSide.LEFT){n=-n}B.vAttach=this._computeProjection(z,l,A.left+n,A.top);n=x+r;if(s===f.AttachmentSide.LEFT){n=-n}B.vBreak=this._computeProjection(z,l,A.left+n,A.top)}else{if((s===f.AttachmentSide.TOP)||(s===f.AttachmentSide.BOTTOM)){var C=k;if(s===f.AttachmentSide.TOP){C=-C}B.vAttach=this._computeProjection(z,l,A.left,A.top+C);if(v&&v.height!==undefined){r=t.offsetHeight*v.height;C=k+r;if(s===f.AttachmentSide.TOP){C=-C}B.vBreak=this._computeProjection(z,l,A.left,A.top+C)}else{B.vBreak=B.vAttach.clone()}}}return B},_computeProjection:function(n,m,k,l){var o=a.getViewpointInfo(n.currentViewpoint);var p=o.sight.negate();var j=a.getLineFromWindowPosition(n,k,l);var i=b.computeLinePlaneDistance(j.position.toArray(),j.direction.toArray(),m.toArray(),p.toArray());return new d.Vector3(i.aPosition[0],i.aPosition[1],i.aPosition[2])}};f.AttachmentSide={CENTER:0,LEFT:1,RIGHT:2,TOP:3,BOTTOM:4};return f});define("DS/DMUBaseUI/DMUUserExperienceManager",["UWA/Class","DS/DMUBaseExperience/EXPUtils","DS/Selection/CSOManager","DS/DMUBaseExperience/DMUContextManager","DS/ApplicationFrame/CommandsManager"],function(a,e,c,d,b){var f=a.extend({init:function(j){var k=[],i=j.frmWindow;var l=this;var h=null;function g(n){if(n.key==="Delete"||n.keyCode===46){var s=c.get();var t=[];var m=d.getReviewContext({viewer:i.getViewer()});if(!m){return}var q=d.getContextViewer({reviewContext:m});if(!q){return}var p=m?m.getCurrentReview():null;if(s.length&&p){for(var u=0;u<s.length;u++){var r=p.getDMUObjectFromPathElement(s[u].pathElement,true);if(r){t.push(r)}}if(t.length===1&&t[0].isTextEdited&&t[0].isTextEdited()){return}}if(n.shiftKey||m.isSwitchedReviewCtx){var o=b.getCommand("DMUQuickDeleteHdr",q.getCommandContext());if(!o){require(["DS/DMUBaseCtxCommands/DMUDeleteCmd"],function(v){var w=new v({ID:"tmpQuickDelete",context:q.getCommandContext()});w.begin();w.destroy();w=null})}else{o.begin()}}else{var o=b.getCommand("DMUDeleteHdr",q.getCommandContext());if(!o){require(["DS/DMUBaseCtxCommands/DMUDeleteCmd"],function(v){var w=new v({ID:"tmpDelete",context:q.getCommandContext()});w.begin();w.destroy();w=null})}else{o.begin()}}}}this.unInitialize=function(){if(!i){return}for(var m=k.length-1;m>=0;m--){i.getContextualUIManager().unregister(k[m])}if(h){i.getContextualUIManager().unregister(h);document.removeEventListener("keyup",g)}h=null;k.length=0;i=null};this.registerContextualBar=function(n){if(i&&!l.isContextualBarRegistred(n.type)){var m=d.getContextViewer({viewer:i.getViewer()});if(!m){return}if(!h){h="3DReviewContextualMenu";document.addEventListener("keyup",g);i.getContextualUIManager().register({subscriberId:h,workbenchName:"DMUBaseCtxCommands",module:"DMUBaseCtxCommands",context:m.getCommandContext(),cmdPrefix:"",directory:"assets/afr/",merge:true,onContextualMenuReady:function(){var q=d.getReviewContext({viewer:i.getViewer()});if(q&&!q.isSwitchedReviewCtx){var p=c.get();var o=q.getUIManager().getSelectedObjects();if(p.length&&o.length===p.length){return{cmdList:[{line:1,name:"DMUHideShowStr",hdr_list:["DMUHideShowHdr"]},{line:1,name:"DMUDeleteStr",hdr_list:["DMUDeleteHdr"]}]}}}}})}i.getContextualUIManager().register({subscriberId:n.type,workbenchName:n.workbenchName,module:n.module,context:m.getCommandContext(),cmdPrefix:"",directory:"assets/afr/",merge:true,onContextualBarReady:function(){var r=d.getReviewContext({viewer:i.getViewer()});if(r){var o=r.getUIManager().getSelectedObjects();var p=c.get();if(p.length&&o.length===p.length){for(var q=0;q<o.length;q++){if(o[q].GetType().indexOf(n.type)!==-1){if(!o[q].getSharedContextualCommandList){return{cmdList:[]}}return{cmdList:o[q].getSharedContextualCommandList(o)}}}}}return{cmdList:[]}}});k.push(n.type)}};this.isContextualBarRegistred=function(n){for(var m=k.length-1;m>=0;m--){if(k[m]===n){return true}}return false}}});return f});define("DS/DMUBaseUI/DMUTools3DCompare",["DS/Visualization/ThreeJS_DS","DS/Visualization/Node3D","DS/Visualization/Mesh3D"],function(c,d,b){var a={addGeometryToPass:function(o,n,m,f,j){var h=new d();h.name=(j)?j:"DMUCompare";h.productType="Reference3D";h.toBeSectionned=true;h.setVisibilityInTree(false);var e=n.length;for(var l=0;l<e;l++){var k=n[l];var g=new b(new c.Mesh(k.geometry));g.setMatrix(k.matrix);h.add(g)}h.setMaterial(m);if(f){h.setRenderPasses(f)}h.forceUpdate();o.add(h);return h}};return a});define("DS/DMUBaseUI/DMUNode3D",["DS/Visualization/Node3D","DS/DMUBaseExperience/EXPControllerEvents","DS/DMUBaseExperience/EXP3DReviewWidgetSingleton","DS/DMUBaseExperience/DMUContextManager","DS/DMUMeasurable/DMUToolsSceneGraph","DS/Selection/HSOManager"],function(f,a,e,d,g,c){var b=f.extend({init:function(k){this._parent();var j=true;var m=e.get();var i="VPM";if(m){i=m.getValue("appModelerType")}var h;var l=this;this.getDMUType=function(){return k.GetType()};this.setClippingControlPoints=function(o){if(i!=="VPM"){var p;var q=d.giveEventsController({viewer:k._viewer});if(q){var n=function(r){if(l.id===r.id){j=r.visibility;if(k.getAttribute("bVisible")){l.setVisibility(r.visibility);l.setVisibilityFree(!r.visibility)}}};p=q.addEvent(a.Events.EXPClippingPlaneEvent,n,{point:o,id:l.id})}if(k._viewer._expClippingManager){k._viewer._expClippingManager._dispatchClippingPlane()}return p}};this.removeClippingControlPoints=function(n){if(i!=="VPM"){var o=d.giveEventsController({viewer:k._viewer});if(o){o.removeEvent(n)}j=k.getAttribute("bVisible")}};this.getClippingVisibility=function(){return j};this.setPointHandleVisibility=function(r,n,q,p){if(r){r.setVisibility(n);var o=n?p!==0:p===0;if(o===true&&q===false&&p===0){o=false}if(n===true&&q===true&&p===0){o=true}r.setVisibilityFree(!o)}};this.highlightIfNeeded=function(){if(!h){h={pathElement:g.buildPathElement(l)}}if(c.isIn(h)){c.remove(h)}if(k.isInEdition()&&!k.manipulate){c.add(h)}};this.mergeParams=function(q,n){var r=function(w){if(w!==null&&w!==undefined){return w.clone?w.clone():w}return w};var v=Object.keys(n);for(var u=0;u<v.length;u++){if(v[u]!=="graphicProperties"){q[v[u]]=r(n[v[u]])}else{var p=Object.keys(n[v[u]]);for(var s=0;s<p.length;s++){if(p[s]==="fontStyle"||p[s]==="fillStyle"||p[s]==="fillStyle"){var t=Object.keys(n[v[u]][p[s]]);for(var o=0;o<t.length;o++){q[v[u]][p[s]][t[o]]=r(n[v[u]][p[s]][t[o]])}}else{q[v[u]][p[s]]=r(n[v[u]][p[s]])}}}}return q}},setVisibility:function(h){if(h&&this.getClippingVisibility()===false){this._parent(false)}else{this._parent(h)}}});return b});define("DS/DMUBaseUI/DMUNode2D",["DS/DMUBaseUI/DMUNode3D","DS/DMUBaseExperience/EXPToolsVisualization","DS/Visualization/ThreeJS_DS"],function(d,a,c){var b=d.extend({init:function(e){this._parent(e);this.convertCoordsInPixels=function(g){var h=e._viewer.SCREEN_WIDTH/2,f=e._viewer.SCREEN_HEIGHT/2;if(g.anchor==="center"){return new c.Vector2(h+g.coords.x*f,(1-g.coords.y)*f)}return new c.Vector2(g.coords.x*f,g.coords.y*f)};this.convertPixelsInCoords=function(g){var f=e._viewer.SCREEN_HEIGHT/2;if(g.anchor==="center"){return new c.Vector2(g.coords.x/f,(1-g.coords.y)/f)}return new c.Vector2(g.coords.x/f,g.coords.y/f)};this.get3DPositionFromScreenCoordinates=function(h){if(h.coords){var g=new c.Vector2().copy(h.coords);var i=e._viewer.SCREEN_WIDTH/2,f=e._viewer.SCREEN_HEIGHT/2;if(!h.proportionalPosition&&h.anchor==="center"){g.x+=i;g.y+=f}else{if(h.proportionalPosition){g.x=i+g.x*f;g.y=(1-g.y)*f}}return a.get3DPositionFromScreenCoordinates({coords:g,viewer:e._viewer})}return new c.Vector3(1,0,0)}}});return b});define("DS/DMUBaseUI/DMUUIManager",["UWA/Class","DS/Selection/CSOManager","DS/ApplicationFrame/CommandsManager","DS/DMUBaseCommands/EXPToolsWUX","DS/Core/Events","DS/DMUBaseExperience/DMUContextManager","DS/DMUBaseUI/DMUUserExperienceManager","DS/DMUBaseExperience/EXPManagerSet","DS/CATWebUXTooltipManager/CATWebUXTooltipManager"],function(d,f,c,b,e,h,g,a,i){return d.extend({init:function(n){var p=this;var m=null;var l=[];var u=n.context.getFrameWindow();var k=[],w=[];var t,s;var r={};this.clearUI=function(){if(l.length){l.forEach(function(x){x.setInEdition(false)})}l.length=0;u.getContextualUIManager().getContextualBar().hide();u.getViewer().render()};function v(){p.clearUI(true);a.removeManager({name:"DMUUserExperienceManager",context:u});if(r.onAdd){f.unsubscribe(r.onAdd)}if(r.onPostRemove){f.unsubscribe(r.onPostRemove)}if(r.onEmpty){f.unsubscribe(r.onEmpty)}s.unregister(t);i.unreferenceTooltipManager(n);e.unsubscribe(m);r=m=l=p=null}function j(){p.clearUI();var C=h.getReviewContext(n);if(C){var y=f.get();var x=C.getCurrentReview(),B,z=false;for(var A=0;A<y.length;A++){B=x.getDMUObjectFromPathElement(y[A].pathElement,true);if(!B){continue}if(B.manipulate){z=true}if(l.indexOf(B)===-1){l.push(B)}B.setInEdition(true)}if(l.length&&!z){u.getContextualUIManager().showContextualBar({hideWithDistance:true,backMAB:function(){f.empty()}})}else{e.publish({event:"/"+u.options.context+"/WUX/ContextualBar/Hide/"})}u.getViewer().render()}}r.onAdd=f.onAdd(j);r.onPostRemove=f.onPostRemove(j);r.onEmpty=f.onEmpty(j);if(!m){m=e.subscribe({event:"/VISU/onWindowResized"},function(){p.clearUI()})}if(!a.getManager({name:"DMUUserExperienceManager",context:u})){a.addManager({name:"DMUUserExperienceManager",context:u,manager:new g({frmWindow:u})})}else{a.increaseRefCount({name:"DMUUserExperienceManager",context:u})}function q(x){if(!x||!x.completed){return}if(!x.arrayPath||x.arrayPath.length!==1||!x.token||!x.arrayPath[0].getLastElement(true).getTooltip){x.completed();return}x.completed({token:x.token,div:x.arrayPath[0].getLastElement(true).getTooltip(),interactiveContent:true})}function o(y){var x=y;while(x&&x.getLastElement(true).getPickParent()){x=x.getParentPath()}return x}s=i.getTooltipManager(n);t=s.register({onTooltipReady:q,filterPath:o});this.getSelectedObjects=function(){return l};this.disableAllCmds=function(){if(w.length||k.length){return}var A=c.getCommands(n.context.getCommandContext());var z,y;for(z in A){if(A.hasOwnProperty(z)){y=A[z];k.push({id:y.getId(),isEnabled:y.isEnabled()})}}var x=c.getCommandCheckHeaders(n.context.getCommandContext());for(z in x){if(x.hasOwnProperty(z)){y=x[z];w.push({id:y._id,isEnabled:y.isEnabled()})}}c.disableAll(n.context.getCommandContext())};this.restoreCmds=function(){if(k){k.forEach(function(x){var y=c.getCommand(x.id,n.context.getCommandContext());if(y){if(x.isEnabled){y.enable()}else{y.disable()}}});k.length=0}if(w){w.forEach(function(y){var x=c.getCommandCheckHeader(y.id,n.context.getCommandContext());if(y){if(y.isEnabled){x.enable()}else{x.disable()}}});w.length=0}};this.remove=function(){if(v){v()}}}})});define("DS/DMUBaseUI/DMUInitialization",["UWA/Class","DS/DMUBaseExperience/DMUContextManager","DS/DMUBaseUI/DMUUIManager","DS/DMUBaseReview/DMUExperience"],function(b,e,d,c){var a=b.singleton({init:function(){var h=this;var g=0;function f(j,i){var k=new c(j.context.getFrameWindow(),g.toString());g++;k.initReviewContext(new d({context:j.context}),e.getEventsController({context:j.context}),i);if(!j.context.getFrameWindow().removeReviewModel){j.context.getFrameWindow().removeReviewModel=function(o){if(!o){h.stopSwitchExperience(j);e.removeReviewContext(j)}else{var p=e.getReviewContext(j);if(p&&p.isSwitchedReviewCtx){var m=p.getCurrentReview();if(m){var l=m.getChildren(o);for(var n=l.length-1;n>=0;n--){m.removeChild(l[n]);l[n].remove()}if(!m.getChildren().length){h.stopSwitchExperience(j);e.removeReviewContext(j)}}}}}}return k}this.createReviewContext=function(j){if(!j.context){return}var i=e.getReviewContext(j);if(!i){i=f(j);if(i){e.setReviewContext({context:j.context,controller:i})}}return i};this.startSwitchExperience=function(j){var k=e.getReviewContext(j);if(!k||(k&&!k.isSwitchedReviewCtx)){if(k){k.setActiveFlag(false)}var i=f(j,k?k.getDMUPreferenceRepository():undefined);i.isSwitchedReviewCtx=true;if(i){e.setSwitchedReviewContext({context:j.context,controller:i})}}};this.stopSwitchExperience=function(i){var j=e.getReviewContext(i);if(j&&j.isSwitchedReviewCtx){e.removeSwitchedReviewContext(i);j=e.getReviewContext(i);if(j){j.setActiveFlag(true)}}}}});a.init();return a});