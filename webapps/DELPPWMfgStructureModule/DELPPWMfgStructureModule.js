define("DS/DELPPWMfgStructureModule/MfgStructureModule",["UWA/Core"],function(b){var a=function a(q,D,f,H,o,y,x,C,c,I){var w="CreateMfgItemStructure",r="UpdateMfgItemStructure",n=null,i={},p=null,h,z,t,v,d,s,e,B,F,l,u,G,k,g;z=function z(J,K){i={};if(b.is(J)){i.cmdId=J}else{throw new Error("Command ID is null")}i.onOKCallBack=K;i.onCancelCallback=l};d=function d(){if(b.is(n)){if(n.isVisible()){n.destroyUI()}n=void 0}};s=function s(L){var J=true,K=I.getActiveView();if(L.changed.isSelected===false&&L.sourceId!==K){J=false}return J};v=function v(){var Q,O,K,N={},L=[],M,J,P=false;Q=n.getImplementingID();M=n.getImplementedIDs()[0];if(b.is(Q)){O=H.getReferenceId(Q);K=x.getScopeLinksOfImplementing(O);if(K.length>0){N.id=K[0].get("to");L.push(N);if(b.is(M)){J=H.getReferenceId(M);if(J!==N.id){n.updateImplemented(L);P=true}}else{n.updateImplemented(L);P=true}}}return P};t=function t(L){var K,J;if(L.bUpdateImplemented===true){n.updateImplemented(L.selNodes);K="ImplementUI.ImplementedSelectionNotAllowed";J="error"}else{if(L.bUpdateImplementing===true){n.updateImplementing(L.selNodes);K="ImplementUI.ImplementedSelectionChanged";J="info"}}if(v()===true){n.showMessages(f.getNLSValue(K),J)}};e=function e(J){i={};if(b.is(J)){i.cmdId=J}else{throw new Error("Command ID is null")}i.moduleOptions=h;i.onOKCallBack=G;i.onCancelCallback=l};B=function B(L,K){var J=function(M){p.updateImplementedRevnList(K,M,false)};p.updateImplementingLabel(L);H.getMajorRevisions(K,J)};F=function F(){if(b.is(p)){if(p.isVisible()){p.destroyUI()}p=void 0}};u=function u(J){var N={},L,M,O,K;if(b.is(J)){L=H.getReferenceModel(J.implementingId);M=H.getReferenceModel(J.implementedIDs[0]);O=L.get("V_Name");K=M.get("V_Name");N.scopeCreation=J.scopeCreation;N.prefix=J.mfgItemPrefix;N.logMessage=f.getNLSValue("CreateMfgItemStructure.LogMessage",{mbom:O,ebom:K});c.webservice("Create",M.id,L.id,N);d()}};G=function G(J){var K={},L;if(b.is(J)){L=H.getReferenceModel(J.implementingId).get("V_Name");K.backgroundJobFlag=false;K.scopeCreation=J.scopeCreation;K.prefix=J.mfgItemPrefix;K.logMessage=f.getNLSValue("UpdateMfgItemStructure.LogMessage",{mbom:L});c.webservice("Update",J.implementedId,J.implementingId,K);F()}};l=function l(){d();F()};k=function k(){l();z(w,u);i.cmdTitle="Dialog.CreateMfgItemStructure.Title";i.implementingSection=true;i.implementedSection=true;i.optionsSection=true;i.scopeOption="ComboBox";i.mfgItemPrefix=true;i.multiSelectionOfImplementing=false;i.multiSelectionOfImplemented=false;n=D.create("ImplementUI",i);t(n.getSelectionsWithPaths())};g=function g(){var N=C.getSelections()[1][0],M=H.getReferenceModel(N),J,K,L;l();if(!b.is(M)){q.debug(r+": Reference Model not found for pid:"+N);return}L=M.id;J=x.getScopeLinksOfImplementing(L);if(J.length<=0){q.warn(f.getNLSValue("Error.NoProductScopeExists.Title"));return}K=J[0].get("to");e(r,G);i.cmdTitle="Dialog.UpdateMfgItemStructure.Title";i.implementedRevTreeListCSSStyle="implementedSection-container-withChkBox";i.optionsSection=true;i.scopeOption="ComboBox";i.mfgItemPrefix=true;i.defaultHeight="430";i.modalFlag=true;p=D.create("ImplementedRevChooserUI",i);B(L,K)};return{listenTo:function m(){return{select:this.onSelect,CreateMfgItemStructure:k,UpdateMfgItemStructure:g,}},onStart:function A(J){h=J},onStop:function j(){d();F()},onSelect:function E(J){if(b.is(n)&&n.isVisible()){if(b.is(J)){if(s(J)===false){return}if(b.is(J.changed)){t(n.getSelectionsWithPaths())}}}},}};return{behaviors:["UXFactoryBehavior","ResourceBehavior","ModelBehavior","WUXNodeModelBehavior","TreeListViewBehavior","ImplementBehavior","SelectionBehavior","MfgItemBehavior","ViewBehavior"],creator:a}});