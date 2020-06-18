define("DS/CreateSnapshot/WebServices",["UWA/Class","DS/LifecycleServices/LifecycleServicesSettings","DS/LifecycleServices/LifecycleServices"],function(a,d,b){var c=a.singleton({init:function(){this._parent({})},createSnapshot:function(n,i,m,k,l,h){var g={objectid:i,name:m,desc:k};var o="/resources/iteration/snapshot/create";var j=this;b.post(n,o,g,function f(r){var p=r.results.status;if(p=="success"){l()}else{var q=r.results.Message;if(q==null){q=r.results.message}h(q)}},function e(p){h(p)})},getUrl:function(f){var g=null;var e=d.get3DSpaceWSUrl(g,f,null);return e}});return c});define("DS/CreateSnapshot/CreateSnapshotWidget",["UWA/Controls/Abstract","DS/PlatformAPI/PlatformAPI","UWA/Core","DS/UIKIT/SuperModal","DS/LifecycleServices/LifecycleServices","DS/LifecycleServices/LifecycleServicesSettings","DS/CreateSnapshot/WebServices","DS/PADUtils/views/PADAlert","i18n!DS/IterationsWidget/assets/nls/IterationsWidget","i18n!DS/CreateSnapshot/assets/nls/CreateSnapshotNls","i18n!DS/UIKIT/assets/nls/UIKIT","css!DS/LifecycleControls/assets/styles/LifecycleModals","css!DS/LifecycleControls/LifecycleControls"],function(g,l,f,b,e,d,m,a,i,c,k,h,n){var j=g.extend({context:null,init:function(s,o,p,q){var r=this;this._parent(p);this.buildUI();r.context=q},setObject:function(o){if(o!=null){this.tenant=o.tenant}this.object=o;if(o.type!="CATPart"&&o.type!="CATProduct"){throw o.type+i.iterationUnsupportedType}},containsIlegalChars:function(r){var q=["/","\\","|","*","^","(",")","[","]","{","}","=","<",">","$","#","%","&","!","@","?",'"',";",":",",","'","§"];var s=q.length;for(var o=0;o<s;o++){var p=q[o];if(r.indexOf(p)!=-1){return true}}return false},createSnapshot:function(r,w,s){var u=this;var x=c.createFail;var t="[\\/:*?\"<>|#$@%,[]{}=&!;'§]";if(w.trim()==""){var o=c.emptyTitle;u.showError(x+" "+o)}else{if(this.containsIlegalChars(w)){var o=c.replace(c.illegalChar,{label:c.title,illegalChars:t});u.showError(x+" "+o)}else{if(this.containsIlegalChars(s)){var o=c.replace(c.illegalChar,{label:c.description,illegalChars:t});u.showError(x+" "+o)}else{try{m.createSnapshot(this.tenant,r,w,s,function p(){u.showNotification(c.createSuccessfull)},function q(y){u.showError(x+" "+y)})}catch(v){u.showError(x+" "+v)}}}}},showNotification:function(o,p){a.displayNotification({eventID:((typeof p==="string")?p:"info"),msg:o})},showError:function(o){a.displayNotification({eventID:"warning",msg:o})},showDialog:function(q,o,u){var s=this;var p=this.object.physicalid;e.getAssemblyInfo(this.tenant,p,function t(C){var B=C.thumbnailUrl;if(B==null||B==""){B="/snresources/images/icons/large/I_DECAsmCV5108x144.png";B=d.get3DSpaceWSUrl(s.tenant,B)}s.thumbnail.src=B;var v=C.title;var y=new b({closable:true,className:"Lifecycle_Modals",events:{onHide:function(){o()},onShow:function(){u()}},renderTo:q});var x=c.ok;var A=c.cancel;var z=c.dialogTitle;z+=" - "+s.object.displayName;y.dialog({body:s.elements.container,title:z,buttons:[{className:"primary",value:x,action:function(E){var F=s.titleValueDiv.value;var D=s.descValueDiv.value;s.createSnapshot(p,F,D);E.hide()}},{value:A,action:function(D){D.hide()}}]});if(y&&y.modals&&y.modals.current&&y.modals.current.elements){var w=(y.modals.current.elements.header)?y.modals.current.elements.header.getElement(".close.fonticon.fonticon-cancel"):null;if(w){w.setText("\u00D7");w.removeClassName("fonticon");w.removeClassName("fonticon-cancel");w.setAttributes({title:k.close})}if(y.modals.current.elements.closeTooltip&&y.modals.current.elements.closeTooltip.elements){y.modals.current.elements.closeTooltip.elements.container.addClassName("hideDefaultTooltip")}}s.mySuperModal=y;widget.addEvent("onRefresh",function(){if(s.mySuperModal!=null&&s.mySuperModal.modals.current!=null){s.mySuperModal.modals.current.destroy();s.mySuperModal=null}});s.titleValueDiv.focus()},function r(){})},buildUI:function(){this.elements.container=f.createElement("div",{styles:{position:"relative",height:"137px",overflow:"hidden"}});var o=this.elements.container;var v="#368ec4";var w="0px";var p="35px";var q="215px";var s="200px";var x="330px";var t="200px";this.noteDiv=document.createElement("div");this.noteDiv.style.color=v;this.noteDiv.style.fontStyle="italic";this.thumbnail=document.createElement("img");this.thumbnail.style.position="absolute";this.thumbnail.style.width=s;this.thumbnail.style.top=w;o.appendChild(this.thumbnail);var r=document.createElement("div");r.className="required";r.style.position="absolute";r.style.left=q;r.style.top=w;r.innerHTML=c.title;o.appendChild(r);this.titleValueDiv=document.createElement("input");this.titleValueDiv.type="text";this.titleValueDiv.style.position="absolute";this.titleValueDiv.style.left=x;this.titleValueDiv.style.width=t;this.titleValueDiv.style.top=w;o.appendChild(this.titleValueDiv);var u=document.createElement("div");u.style.position="absolute";u.style.left=q;u.style.top=p;u.innerHTML=c.description;o.appendChild(u);this.descValueDiv=document.createElement("textarea");this.descValueDiv.rows="5";this.descValueDiv.style.position="absolute";this.descValueDiv.style.left=x;this.descValueDiv.style.width=t;this.descValueDiv.style.height="100px";this.descValueDiv.style.resize="none";this.descValueDiv.wrap="off";this.descValueDiv.style.top=p;o.appendChild(this.descValueDiv)}});return j});define("DS/CreateSnapshot/Cmd",["DS/ApplicationFrame/Command","DS/ApplicationFrame/CommandsManager","DS/CreateSnapshot/CreateSnapshotWidget","DS/PADUtils/views/PADAlert","DS/LifecycleServices/LifecycleServicesSettings","i18n!DS/CreateSnapshot/assets/nls/CreateSnapshotNls"],function(c,f,g,b,e,a){var d=c.extend({name:"create_snapshot",context:null,activeCommands:{},init:function(h){var i=this;this._parent(h,{mode:"exclusive",isAsynchronous:false});require(["DS/PADUtils/PADContext"],function(j){i.context=j.get();if(null==i.context){i.context=h.context}else{i.context.getPADTreeDocument().getXSO().onChange(i.checkSelect.bind(i))}e.hasPARRole(function(k){i.setCommandAvailability(i.getEnableCmd())});if(h!=null&&h.onLoadPADContextModule!=null){h.onLoadPADContextModule()}},function(j){i.context=h.context});e.hasPARRole(function(j){i.setCommandAvailability(i.getEnableCmd())})},beginExecute:function(){},setCommandAvailability:function(h){var i=f.getCommand(this._id,this);if(!i){i=f.getCommands()[this._id]}if(i){if(h===true){i.enable()}else{i.disable()}}},getEnableCmd:function(){var h=this;var i=false;e.hasPARRole(function(n){if(n==true&&h.context!=null&&(h.context.getPADTreeDocument||h.context.widgetType==="LifecycleWidget")){var m=0;if(h.context.getPADTreeDocument){m=h.context.getPADTreeDocument().getXSO().get().length}else{m=h.context.getSelectedNodes().length}if(m==1){var o=h.context.getSelectedNodes();var l=o[0];var k=null;try{k=l.options.grid["ds6w:type"]}catch(j){k=l.object.type}if(k==null&&l.getType!=null){k=l.getType()}if(k=="CATProduct"||k=="CATPart"){i=true}}}});return i},checkSelect:function(){var h=this;setTimeout(function(){var i=h.getEnableCmd();h.setCommandAvailability(i)})},resetActiveCmd:function(h){delete this.activeCommands[h]},displayNotification:function(i,h){console.log(i);b.displayNotification({msg:i,eventID:h})},execute:function(){var o=this;var z=this._id;if(o.activeCommands[z]){o.showInfo(LifecycleWidgetNls.multiCmdInfo);return}var r=f.getCommand(z,o);if(r!=null){r.disable()}var j=function(w){o.resetActiveCmd(z);if(w!=null){w.enable()}};try{var t=new g(widget,null,{},o.context);var u=o.context.getSelectedNodes();if(u.length==0){o.displayNotification(a.NoSelection,"warning");return}else{if(u.length!=1){o.displayNotification(a.noMultiSelection,"warning");return}}var B=null;if(u.length==1){var x=u[0];var h=x.getID();var l=null;try{l=x.options.grid["ds6w:type"]}catch(q){l=x.object.type}if(l==null&&x.getType!=null){l=x.getType()}var A="";var p;try{p=x.object.revision}catch(q){p=x.options.grid["ds6wg:revision"]}if(p!==null&&p!==undefined){A=p}var s=null;try{s=x.getTenant()}catch(q){}var n;if(typeof x.getDisplayName==="function"){n=x.getDisplayName()}else{if(x.options.display){n=x.options.display}else{n=x.getLabel()}if(A!==""){n=n+" "+A}}B={physicalid:h,name:x.getLabel(),displayName:n,type:l,revision:A,tenant:s}}t.setObject(B);t.showDialog(document.body,function i(){j(r)},function k(){})}catch(y){if(typeof o.context.displayNotification==="function"){var m=y;if(y.hasOwnProperty("message")){m=y.message}var v={eventID:"warning",msg:m};o.context.displayNotification(v)}j(r);console.log(y.message)}},endExecute:function(){},toRefresh:function(h){if(this.options.context){if(typeof this.options.context.RefreshView!=="undefined"){this.options.context.RefreshView(h)}}}});return d});