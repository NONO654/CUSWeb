define("DS/DELPPWInsertCmdModule/InsertUI",["UWA/Core"],function(b){var a=function(p,m,l){var e=m.getComponent("Element"),n=m.getComponent("Button"),f=null,j=new e("div",{"class":"Insert-Command-Container"}),d=null,c={CLOSE:1,CREATEANDCLOSE:2,CREATE:3},k=function k(r,v){var u,s,w,t;t=function t(z){var A=function A(){s=f.validate();if(s.result!==true){d.error(s.message);d.buttons.Ok.disabled=false;return}u=f.getValues();v(u)};var y=function y(){d.close()};switch(z){case c.CLOSE:return function C(){y()};case c.CREATE:return function B(){A()};case c.CREATEANDCLOSE:return function x(){A();y()};default:p.log("wrong option")}};w={No:new n({label:l.getNLSValue("InsertUI.Close.Title"),onClick:t(c.CLOSE)}),Apply:new n({label:l.getNLSValue("InsertUI.Create.Title"),onClick:t(c.CREATE)}),Yes:new n({label:l.getNLSValue("InsertUI.CreateAndClose.Title"),onClick:t(c.CREATEANDCLOSE)})};if(b.is(m)){d=m.create("Dialog",{title:l.getNLSValue("InsertUI.Dialog.Title")+" "+l.getNLSValue(r.split("/")[1]||"",null,"Type"),domId:"InsertUI-dialog",content:j,resizableFlag:true,modalFlag:true,buttons:w});d.close=function(){if(b.is(f)){f.destroy();f=null}if(b.is(j)){j.destroy()}this.destroy();d=null}}else{p.debug("uxFactoryBehavior is not available.")}},h=function g(r){d.title=l.getNLSValue("InsertUI.Dialog.Title")+" "+l.getNLSValue(r,null,"Type");d.clearMessages()};return{createDialog:function q(r,s){if(!b.is(d)){if(!b.is(f)){f=m.create("DataCollectionUI",{type:r,onTypeChange:h,renderTo:j})}k(r,s)}},isActive:function o(){return b.is(d)?d.visibleFlag:false},destroyUI:function i(){if(b.is(d)){d.close()}}}};return a});define("DS/DELPPWInsertCmdModule/InsertCmdModule",["UWA/Core","DS/DELPPWInsertCmdModule/InsertUI"],function(c,a){var b=function b(p,v,w,r,f,u,h,s){var m,e,d,i,n,o,q={},l=null,g;g=function g(){var x,y,z;z=u.getSelections();if(c.is(z,"array")&&z.length>0){for(y=0;y<z.length;y++){x=z[y][0];if(c.is(x)){return x}}}};o=function o(y){var A,z,x=g();if(c.is(x)){z=w.getReferenceModel(x);A=z.id}w.createRefOrInst(y,A)};m=function m(B){var D=B.arguments,G=true,y="",A="",x="",F="",C=[],z,E;if(l.isActive()){l.destroyUI()}if(c.is(D,"array")){z=D.length;if(0<z){D.forEach(function(H){if(!c.is(H)||!c.is(H.ID,"string")||!c.is(H.Value,"string")){return}if("ReferenceType"===H.ID){y=H.Value}if("PPRType"===H.ID){A=H.Value}if("DisplayedInTableView"===H.ID){if(!c.is(this._displayedInTableView,"array")){C=[]}C.push(H.Value)}},this)}}F=y.split("/")[1]||"";G=p.getPreferenceValue("showDialog");if(c.is(G)&&true===G){l.createDialog(y,o)}else{E={V_Type:y,V_Name:f.getNLSValue(F,null,"Type"),type:F};p.log("Create object without dialog: ");p.log(E);o(E)}};e=function e(){n("replaceByLatest")};i=function i(){n("replaceByNewRevision")};d=function d(){var z=u.getSelectedInsts(),A,x,y;A=function A(B){if(c.is(B,"array")&&B.length>0){n("replaceByExisting",B[0].id)}};if(z.length===1){x=z[0];y=w.getReferenceModelFromInstance(x);h.showSearchDialoguAndActivate(A,{title:f.getNLSValue("Dialog.ReplaceByExisting.Title"),searchTitle:f.getNLSValue("Search.ReplaceByExisting.Title"),types:w.getValidChildTypes(y.get("type"))})}};n=function n(z,y){var x=u.getSelectionsWithPaths();if(c.is(x)&&x.length>0){x=x[0];x.forEach(function(E){var B,D,G,A,F,C;B=E.path;D=E.id;G=s.getScopedParent(B);if(c.is(G)&&G.length>0){A=s.getScopeLinksOfImplementing(G);F=A[0].get("to")}C={instancePID:D,replaceType:z,scopedParentPrdRefID:F,existingRefPID:y};w.replace(C)})}};return{listenTo:function k(){return{InsertCmd:m,ReplaceByLatestRevision:e,ReplaceByExistingRevision:d,ReplaceByNewRevision:i}},onStart:function t(y,x){q=c.extend(q,y);if(!c.is(q.insertFormAttributeXML)){p.debug("Insert Module loading failed : insertFormAttributeXML option is undefined");x();return}l=new a(p,v,f);x()},onStop:function j(){if(l.isActive()){l.destroyUI()}l=void 0}}};return{behaviors:["UXFactoryBehavior","ModelBehavior","LinkBehavior","ResourceBehavior","SelectionBehavior","SearchBehavior","ImplementBehavior"],creator:b}});