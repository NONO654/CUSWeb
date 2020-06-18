define("DS/SMAProcWebAdminWidget/SMAProcWebAdminWidget/",function(){return true});define("DS/SMAProcWebAdminWidget/SMAAdminWidgetConnectorTableView",["UWA/Core","UWA/Json","UWA/Controls/Abstract","DS/Tree/TreeListView","DS/Tree/TreeNodeModel","DS/TreeModel/TreeDocument","DS/Controls/ComboBox","DS/Controls/Button","DS/Notifications/NotificationsManagerViewOnScreen","DS/Notifications/NotificationsManagerUXMessages","DS/Windows/Dialog","DS/Controls/TooltipModel","i18n!DS/SMAProcWebAdminWidget/assets/nls/SMAProcWebAdminWidgetNLS","css!DS/SMAProcWebAdminWidget/SMAAdminWidgetConnectorTableView.css",],function(j,a,h,g,f,b,o,m,d,l,n,i,k){var e;var c=h.extend({name:"ConnectorTableView",_initData:function(){e=[{width:20,dataIndex:"tree",isHidden:true},{width:30,dataIndex:"checkbox",type:"selection"},{text:k["OptionsTable.Name"],dataIndex:"name",width:"20%",isEditable:true},{text:k["OptionsTable.Description"],dataIndex:"description",width:"auto",isEditable:true},{text:k["OptionsTable.OptionType"],dataIndex:"optionType",width:145,isEditable:false,onCellRequest:function(p){if(!p.isHeader){var q=new o({actionOnClickFlag:false,enableSearchFlag:false,disabled:this.hasModifyAccess==="TRUE"?false:true,elementsList:["Standalone","Standalone-Value","Option-Value"],value:p.nodeModel._options.grid.optionType});p.cellView.getContent().setContent(q)}}.bind(this)},{text:k["OptionsTable.Choices"],dataIndex:"choices",width:"10%",isEditable:true},{text:k["OptionsTable.DefaultValue"],dataIndex:"defaultValue",width:"10%",isEditable:true},{text:k["OptionsTable.Required"],dataIndex:"required",width:85,isEditable:false,onCellRequest:function(p){if(!p.isHeader){var q=new o({actionOnClickFlag:false,enableSearchFlag:false,elementsList:["True","False"],disabled:this.hasModifyAccess==="TRUE"?false:true,value:p.nodeModel._options.grid.required});p.cellView.getContent().setContent(q)}}.bind(this)},{text:k["OptionsTable.Separator"],dataIndex:"separatorValue",width:80,isEditable:true}]},init:function(p){this._parent(p);this._initData();this._buildToolbarView();this._buildNotifsView()},_buildTableView:function(p,r){var q=this;this.hasModifyAccess=r;e.forEach(function(s){if(s.dataIndex==="name"||s.dataIndex==="description"||s.dataIndex==="choices"||s.dataIndex==="separatorValue"||s.dataIndex==="defaultValue"){if(r!=="TRUE"){s.isEditable=false}else{s.isEditable=true}}});if(r!=="TRUE"){q.elements.addButton.disabled=true}else{q.elements.addButton.disabled=false}q.elements._tableView=new g({columns:e,defaultCellHeight:30,resize:{rows:false,columns:true},showVerticalLines:true,useTransparentScroller:true,alternateRowColor:false,isEditable:true,iconsSize:22,isSortable:false,show:{rowHeaders:false,columnHeaders:true},selection:{nodes:false,cells:false,rowHeaders:true,columnHeaders:true,unselectAllOnEmptyArea:true,toggle:true,canMultiSelect:true},performances:{buildLinks:false,renderingMode:"adaptive",useRequestAnimationFrameRendering:false,debounceCellRequest:true,debounceCellInternalUpdateTimer:10},showLoaderIndicator:true,enableDragAndDrop:false,shouldAcceptDrag:true,height:"auto",apiVersion:"2",allowUnsafeHTMLContent:false});q.elements.body=new j.createElement("div",{"class":"wux-controls-connectors-body",html:[{tag:"div",styles:{position:"relative",height:"100%"},html:q.elements._tableView}]});q.elements.body.inject(q.elements._panel);this._loadDocument(p)},setValidStringValue:function(p){if(typeof p!=="string"){return""}return p},_createOptionTreeDocument:function(p){var q=this;q.connector=p;q.optionTreeDocument=new b();q.optionTreeDocument.onNodeModelUpdate(function(){q.dispatchEvent("updateOption",[p,q.optionTreeDocument])});q.optionTreeDocument._getTrueRoot()._modelEvents.subscribe({event:"removeChild"},function(){q.dispatchEvent("updateOption",[p,q.optionTreeDocument])});q.optionTreeDocument.getXSO().onUpdate(function(){var r=q.optionTreeDocument.getSelectedNodes();if(r&&r.length>0&&q.hasModifyAccess==="TRUE"){q.elements.delButton.disabled=false}else{q.elements.delButton.disabled=true}})},getSelectedOptions:function(){return this.optionTreeDocument&&this.optionTreeDocument.getSelectedNodes()},addDefaultOption:function(){var p=new f({label:"",grid:{name:"newOption",description:"",defaultValue:"",required:"False",optionType:"Option-Value",separatorValue:""}});this.optionTreeDocument.addRoot(p);this.elements._tableView.getManager().scrollToNode(p);p.highlight();if(this.connector){this.dispatchEvent("updateOption",[this.connector,this.optionTreeDocument])}},removeSelectedRows:function(){var p=this;var q=this.optionTreeDocument.getSelectedNodes();q.forEach(function(r){p.optionTreeDocument.removeRoot(r)})},_loadDocument:function(p){var r=this;this._createOptionTreeDocument(p);var u=p.dataelements.options.replace(/\+/g," ");var t=decodeURIComponent(u);var s={Options:{Option:[]}};if(t&&t.length>0){s=a.xmlToJson(t)}if(!s.Options.Option){s.Options.Option=[]}else{if(!s.Options.Option.forEach){s.Options.Option=[s.Options.Option]}}r.optionTreeDocument.prepareUpdate();s.Options.Option.forEach(function(v){var w=new f({label:"",grid:{name:r.setValidStringValue(v.name),description:r.setValidStringValue(v.nodeValue),defaultValue:r.setValidStringValue(v.defaultValue),required:v.required,optionType:v.optionType,separatorValue:r.setValidStringValue(v.separatorValue),choices:r.setValidStringValue(v.Choices).replace(/\n/g,"; ")}});r.optionTreeDocument.addRoot(w)});r.optionTreeDocument.pushUpdate();var q=r.elements._tableView.getManager();q.loadDocument(r.optionTreeDocument)},_unloadDocument:function(){try{this.elements._tableView.getManager().unloadDocument();this.optionTreeDocument=null;this.elements._tableView.destroy();this.elements.body.destroy()}catch(p){logger.warn(p)}},_buildToolbarView:function(){var p=this;p.elements.options=new j.Element("h5",{styles:{"float":"left",fontSize:"16px",textIndent:"10px",marginTop:"10px",color:"rgb(161, 162, 164)"},html:k["Connector.options"]});p.elements.addButton=new m({icon:{iconName:"plus"},displayStyle:"icon",tooltipInfos:new i({shortHelp:k["Connector.options.add"],allowUnsafeHTMLShortHelp:false}),emphasize:"secondary",allowUnsafeHTMLLabel:false,onClick:function(){p.addDefaultOption()}});p.elements.delButton=new m({icon:{iconName:"trash"},displayStyle:"icon",tooltipInfos:new i({shortHelp:k["Connector.options.delete"],allowUnsafeHTMLShortHelp:false}),disabled:true,emphasize:"secondary",allowUnsafeHTMLLabel:false,onClick:function(){var r=p.getSelectedOptions();if(r&&r.length>0){var q=p._buildDialogView();q.buttons.Ok.onClick=function(){p.removeSelectedRows();q.close()}}}});p.elements._panel=new j.Element("div",{styles:{height:"100%",position:"relative"},});p.elements.headerContainer=new j.Element("div",{styles:{position:"relative",display:"flex",padding:"10px","border-bottom":"1px solid rgb(209, 212, 212)"},"class":"header-container"});p.elements.header=new j.Element("h4",{styles:{color:"#77797c",margin:"0",display:"inline-flex",width:"auto"},"class":"header"});p.elements.accessTag=new j.Element("span",{styles:{display:"inline-flex",color:"#ff0000",fontSize:"14px",width:"auto","padding-left":"15px","padding-right":"15px","font-weight":"bold"},"class":"accessTag"});p.elements.header.inject(p.elements.headerContainer);p.elements.accessTag.inject(p.elements.headerContainer);p.elements.headerContainer.inject(p.elements._panel);p.elements.toolbar=new j.Element("div",{styles:{backgroundColor:"#FFFFFF",textAlign:"right"}});p.elements.options.inject(p.elements.toolbar);p.elements.addButton.inject(p.elements.toolbar);p.elements.delButton.inject(p.elements.toolbar);p.elements.toolbar.inject(p.elements._panel);p.elements.landingPageContent=new j.Element("h3",{html:k["Connector.select"],styles:{margin:"50px",color:"#b4b6ba",alignSelf:"center",textAlign:"center",height:"500px"}})},_buildDialogView:function(){var p=new n({title:k["Connector.options.confirmdelete"],content:k["Connector.options.confirmdelete.text"],modalFlag:true,immersiveFrame:this.options.immersiveFrame,buttons:{Ok:new m({label:k.Ok,allowUnsafeHTMLLabel:false}),Cancel:new m({label:k.Cancel,allowUnsafeHTMLLabel:false,onClick:function(){p.close()}})}});return p},_buildNotifsView:function(){this.elements.notifs=d;this.notifsManager=l;this.elements.notifs.setNotificationManager(this.notifsManager)}});return c});define("DS/SMAProcWebAdminWidget/SMAAdminWidgetConnectorListView",["UWA/Core","UWA/Controls/Abstract","DS/CollectionView/ResponsiveTilesCollectionView","DS/Windows/Dialog","DS/Controls/Button","DS/Controls/LineEditor","DS/Controls/Editor","DS/Controls/ComboBox","DS/Controls/TooltipModel","i18n!DS/SMAProcWebAdminWidget/assets/nls/SMAProcWebAdminWidgetNLS","css!DS/SMAProcWebAdminWidget/SMAAdminWidgetConnectorTableView.css"],function(e,b,h,j,g,a,i,k,d,f){var c=b.extend({name:"ConnectorListView",_buildListView:function(){this.elements._tilesView=new h();this.elements._tilesView.selectionBehavior={unselectAllOnEmptyArea:true,toggle:true,canMultiSelect:false,enableShiftSelection:false,enableFeedbackForActiveCell:true}},_buildListToolbarView:function(){var l=this;l.elements.addButton=new g({icon:{iconName:"plus"},displayStyle:"icon",tooltipInfos:new d({shortHelp:f["Connector.add"],allowUnsafeHTMLShortHelp:false}),emphasize:"secondary",allowUnsafeHTMLLabel:false});l.elements.editButton=new g({icon:{iconName:"edit"},displayStyle:"icon",disabled:true,tooltipInfos:new d({shortHelp:f["Connector.edit"],allowUnsafeHTMLShortHelp:false}),emphasize:"secondary",allowUnsafeHTMLLabel:false});l.elements.propButton=new g({icon:require.toUrl("DS/SMAProcWebAdminWidget/assets/icons/I_Properties.png"),displayStyle:"icon",disabled:true,tooltipInfos:new d({shortHelp:f["Connector.properties"],allowUnsafeHTMLShortHelp:false}),emphasize:"secondary",allowUnsafeHTMLLabel:false});l.elements.relExplorerButton=new g({icon:require.toUrl("DS/SMAProcWebAdminWidget/assets/icons/I_Relatedobjects.png"),displayStyle:"icon",disabled:true,tooltipInfos:new d({shortHelp:f["Connector.relatedObjects"],allowUnsafeHTMLShortHelp:false}),emphasize:"secondary",allowUnsafeHTMLLabel:false});l.elements.lifecycleButton=new g({icon:require.toUrl("DS/SMAProcWebAdminWidget/assets/icons/I_Lifecycle.png"),displayStyle:"icon",disabled:true,tooltipInfos:new d({shortHelp:f["Connector.lifecycle"],allowUnsafeHTMLShortHelp:false}),emphasize:"secondary",allowUnsafeHTMLLabel:false});l.elements._panel=new e.Element("div",{"class":"connectorActionPanel"});l.elements.addButton.inject(l.elements._panel);l.elements.editButton.inject(l.elements._panel);l.elements.propButton.inject(l.elements._panel);l.elements.lifecycleButton.inject(l.elements._panel);l.elements.relExplorerButton.inject(l.elements._panel)},_buildCreationDialogView:function(t){var p=60;var n=function(v){return new e.Element("div",{styles:{marginTop:"10px",marginBottom:"1px"},text:v})};var u=new e.Element("div",{"class":"wux-control-inline-container",style:{textAlign:"left"}});var q=n(f["Connector.Title"]);this.elements.titleEditor=new a({sizeInCharNumber:p,requiredFlag:true});q.inject(u);this.elements.titleEditor.inject(u);var o=n(f["Connector.Description"]);this.elements.descriptionEditor=new i({widthInCharNumber:p+2});o.inject(u);this.elements.descriptionEditor.inject(u);var m=n(f["Connector.ApplicationName"]);this.elements.appNameEditor=new a({sizeInCharNumber:p,requiredFlag:true});m.inject(u);this.elements.appNameEditor.inject(u);var s=n(f["Connector.ApplicationVersion"]);this.elements.appVersionEditor=new a({sizeInCharNumber:p,requiredFlag:true});s.inject(u);this.elements.appVersionEditor.inject(u);var l=n(f["Connector.ApplicationType"]);this.elements.appTypeComboBox=new k({actionOnClickFlag:false,enableSearchFlag:false,width:130,elementsList:["Application","Importer","Exporter"],disabled:true});l.inject(u);this.elements.appTypeComboBox.inject(u);this.elements.appTypeComboBox.elements.container.style.width="95px";var r=new j({title:f["Connector.new"],modalFlag:true,content:u,buttons:{Ok:new g({allowUnsafeHTMLLabel:false}),Cancel:new g({allowUnsafeHTMLLabel:false,onClick:function(){r.close()}})},immersiveFrame:t});return r}});return c});define("DS/SMAProcWebAdminWidget/smaAdminWidgetConnector",["UWA/Controls/Abstract","DS/SMAProcWebCMMUtils/SMAJSCMMAuthoringUtils","DS/SMAProcWebAdminWidget/SMAAdminWidgetConnectorListView","DS/SMAProcWebAdminWidget/SMAAdminWidgetConnectorTableView","DS/SMAProcWebCMMUtils/SMAJSCMMConfig","DS/Tree/TreeNodeModel","DS/TreeModel/TreeDocument","DS/WAFData/WAFData","UWA/Json","DS/SMAProcWebCMMUtils/SMAProcWebCMM3DXContentUtils","DS/Windows/DockingElement","DS/Windows/ImmersiveFrame","DS/Logger/Logger","module","i18n!DS/SMAProcWebAdminWidget/assets/nls/SMAProcWebAdminWidgetNLS"],function(n,e,b,p,f,k,h,c,q,l,r,j,s,d,t){var u=s.getLogger(d);var g=function(v){return'<Options lastId="'+v.length+'">\n'+v.map(a).join("")+"</Options>"};var o=function(v){var w=/[&<>"']/g;var x={"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&apos;",};return(v||"").replace(w,function(y){return x[y]})};var i=function(v){return v.charAt(0).toUpperCase()+v.slice(1)};var a=function(y,z){var w=' id="'+(z+1)+'"';var v=' name="'+o(y.name)+'"';var B=' optionType="'+o(y.optionType)+'"';var A=' required="'+o(y.required)+'"';var C=' defaultValue="'+o(y.defaultValue)+'"';var D=o(y.description||"");var x=y.separatorValue?' separatorValue="'+o(y.separatorValue)+'"':"";var E=y.choices?"<Choices>"+o(y.choices)+"</Choices>":"";return"<Option"+w+v+B+A+C+x+">"+D+E+"</Option>\n"};var m=n.extend({init:function(v){this.csrfValue=v;this.tenant=f.getCurrentTenant();this.immersiveFrame=new j();this.immersiveFrame.inject(document.body);this.connectorUrl=e.get3DSpaceUrl()+"/resources/v2/e6w/service/connectors";this.accessUrl=e.get3DSpaceUrl()+"/resources/e6w/service/SMA_Access";this.connectorListView=new b();this.connectorListView._buildListView();this.listView=this.connectorListView.elements._tilesView;this.connectorListView._buildListToolbarView();this.configureListPanelButtons();this.optionTableView=new p({immersiveFrame:this.immersiveFrame,events:{updateOption:function(w,x){this.updateOption(x,w)}.bind(this)}});this.LHSDockingElement=new r({side:WUXDockAreaEnum.LeftDockArea,dockingZoneSize:300,collapsibleFlag:false,useBordersFlag:false,autoExpandFlag:false});this.listToolbarDockingElement=new r({side:WUXDockAreaEnum.TopDockArea,dockingZoneSize:40,resizableFlag:false,collapsibleFlag:false,useBordersFlag:true});this.listToolbarDockingElement.dockingZoneContent=this.connectorListView.elements._panel;this.listToolbarDockingElement.freeZoneContent=this.listView;this.listView.getContent().style.borderRight="1px solid #d1d4d4";this.connectorTreeDoc=new h({shouldAcceptDrag:function(w){return true},shouldAcceptDrop:function(w){return false}});this.listView.model=this.connectorTreeDoc;this.LHSDockingElement.dockingZoneContent=this.listToolbarDockingElement;this.LHSDockingElement.freeZoneContent=this.optionTableView.elements.landingPageContent;this.connectors=[]},initConnector:function(){var v=this.connectorUrl+"?"+this.getSecurityContextParam();var w=this;v+="&tenant="+this.tenant;return new Promise(function(y,x){c.authenticatedRequest(v,{type:"json",onComplete:function(z){w.connectors=z.data;w.connectors.forEach(function(A){var B=w.createConnectorNode(A);w.connectorTreeDoc.addRoot(B);if(A.dataelements.options){var E=A.dataelements.options.replace(/\+/g," ");var D=decodeURIComponent(E);var C=q.xmlToJson(D);if(!C.Options.Option){C.Options.Option=[]}if(!C.Options.Option.forEach){C.Options.Option=[C.Options.Option]}}});y(w)},onFailure:function(z){w.LHSDockingElement.dockingZoneContent.textContent=z;x(z)}})})},getSecurityContextParam:function(){return e.getCurrentContext()?"SecurityContext="+encodeURIComponent(e.getCurrentContext()):""},updateConnector:function(){var w={csrf:{name:"ENO_CSRF_TOKEN",value:this.csrfValue},data:[this.activeConnector],definition:[]};var v=JSON.stringify(w);return new Promise(function(y,x){c.authenticatedRequest(this.connectorUrl+"/"+this.activeConnector.dataelements.id+"?"+this.getSecurityContextParam()+"&tenant="+this.tenant,{method:"PUT",type:"json",headers:{"content-type":"application/json"},data:v,onComplete:function(z){this.optionTableView.notifsManager.addNotif({level:"success",sticky:false,title:t["Save.Successful"]});y(z)}.bind(this),onFailure:function(z){this.optionTableView.notifsManager.addNotif({level:"error",title:t["Update.Failed"],message:z});x(z)}.bind(this)})}.bind(this))},updateOption:function(y,x){var w=[];y.getRoots().forEach(function(D){var E=D._options.grid.choices;if(E){E=E.replace(/ *; */g,"\n")}var C={name:D._options.grid.name,description:D._options.grid.description,defaultValue:D._options.grid.defaultValue,optionType:D._options.grid.optionType,separatorValue:D._options.grid.separatorValue,required:D._options.grid.required,choices:E};w.push(C)});var B=g(w);var A=encodeURIComponent(B);var z={csrf:{name:"ENO_CSRF_TOKEN",value:this.csrfValue},data:[x],definition:[]};z.data[0].dataelements.options=A;var v=JSON.stringify(z);return new Promise(function(D,C){c.authenticatedRequest(this.connectorUrl+"/"+x.dataelements.id+"?"+this.getSecurityContextParam()+"&tenant="+this.tenant,{method:"PUT",type:"json",headers:{"content-type":"application/json"},data:v,onComplete:function(E){x=E.data[0];D(E)}.bind(this),onFailure:function(E){console.error("Failed",E);this.optionTableView.notifsManager.addNotif({level:"error",title:t["Update.Failed"],message:E});C(E)}.bind(this)})}.bind(this))},addConnector:function(y,x,w){var z={csrf:{name:"ENO_CSRF_TOKEN",value:x},data:[w],definition:[]};var v=JSON.stringify(z);return new Promise(function(B,A){c.authenticatedRequest(y+"?"+this.getSecurityContextParam()+"&tenant="+this.tenant,{method:"POST",type:"json",headers:{"content-type":"application/json"},data:v,onComplete:function(C){this.optionTableView.notifsManager.addNotif({level:"success",sticky:false,title:t["Connector.created"]});B(C)}.bind(this),onFailure:function(C){console.error("Failed",C);this.optionTableView.notifsManager.addNotif({level:"error",title:t["Create.Failed"],message:C});A(C)}.bind(this)})}.bind(this))},createConnectorNode:function(v){var x=v.dataelements;var w=new k({label:x.title,subLabel:x["Application Name"]+" "+x["Application Version"],thumbnail:require.toUrl("DS/SMAProcWebAdminWidget/assets/iconLargeDefault.png"),description:x.description,appname:x["Application Name"],appversion:x["Application Version"],connector:v});w.onSelect(function(){this.activeConnector=v;c.authenticatedRequest(this.accessUrl+"?id="+v.dataelements.id+"&"+this.getSecurityContextParam()+"&tenant="+this.tenant,{type:"json",onComplete:function(z){var A=z.datarecords.datagroups[0].dataelements.hasModifyAccess.value[0].value;this.LHSDockingElement.freeZoneContent=this.optionTableView.elements._panel;this.optionTableView._buildTableView(v,A);var y=document.body.getElementsByClassName("accessTag")[0];if(A==="TRUE"){this.connectorListView.elements.editButton.disabled=false;y.innerText=""}else{y.innerText="(Read Only)"}this.connectorListView.elements.propButton.disabled=false;this.connectorListView.elements.lifecycleButton.disabled=false;this.connectorListView.elements.relExplorerButton.disabled=false;this.updateTitleHeader(w.getLabel())}.bind(this),onFailure:function(y){var z="TRUE";this.LHSDockingElement.freeZoneContent=this.optionTableView.elements._panel;this.optionTableView._buildTableView(v,z);this.connectorListView.elements.editButton.disabled=false;this.updateTitleHeader(w.getLabel())}.bind(this)})}.bind(this));w.onUnselect(function(){this.optionTableView._unloadDocument();this.LHSDockingElement.freeZoneContent=this.optionTableView.elements.landingPageContent;this.connectorListView.elements.editButton.disabled=true;this.connectorListView.elements.propButton.disabled=true;this.connectorListView.elements.lifecycleButton.disabled=true;this.connectorListView.elements.relExplorerButton.disabled=true}.bind(this));return w},isConnectorSelected:function(){return !this.connectorTreeDoc.getXSO().isEmpty()},openTransientWidget:function(v,x,w){require(["DS/TransientWidget/TransientWidget"],function(z){var A={mode:"panel",height:800,width:700};var y=window&&window.widget&&window.widget.id;if(/^preview-/.test(y)){this.optionTableView.notifsManager.addNotif({level:"error",title:t["Pin.Widget"]})}else{z.showWidget(v,x,w,A)}}.bind(this),function(y){console.warn("Failed to load transient widget: "+y,y)})},updateTitleHeader:function(w){w=w?w:"";var v=document.body.getElementsByClassName("header")[0];v.setHTML(w)},initConnectorCreationDialog:function(){var v=this.connectorListView._buildCreationDialogView(this.immersiveFrame);v.buttons.Ok.onClick=function(){var A=this.connectorListView.elements;var B=A.titleEditor.value;var w=A.appNameEditor.value;var y=A.appVersionEditor.value;var z=this.connectorListView.elements.descriptionEditor.value;if(!B||!w&&!y){alert(t["Required.fields"]);return}var x={dataelements:{title:B,"Application Name":w,"Application Version":y,kind:this.connectorListView.elements.appTypeComboBox.value.toLowerCase(),description:z,options:""}};this.addConnector(this.connectorUrl,this.csrfValue,x).then(function(E){console.log("Add connector data:",E);var D=E.data[0];this.connectors.push(D);var C=this.createConnectorNode(D);this.connectorTreeDoc.addRoot(C);C.select(true);this.listView.scrollToCellAt(this.listView.getActiveCellID())}.bind(this));v.close()}.bind(this);return v},initConnectorEditionDialog:function(){var w=this.connectorListView._buildCreationDialogView(this.immersiveFrame);var v=this.listView.getActiveCellID();var y=this.connectorTreeDoc.getNthRoot(v);var x=this.connectorListView.elements;x.titleEditor.value=y.getLabel();x.descriptionEditor.value=this.connectorTreeDoc.getSelectedNodes()[0]._options.description;x.appNameEditor.value=this.connectors[v].dataelements["Application Name"];x.appVersionEditor.value=this.connectors[v].dataelements["Application Version"];x.appTypeComboBox.value=i(this.connectors[v].dataelements.kind);w.buttons.Ok.onClick=function(){this.listView.getTreeDocument().prepareUpdate();var z=this.connectorListView.elements;if(this.activeConnector.dataelements.title!==z.titleEditor.value){this.updateTitleHeader(z.titleEditor.value)}y.updateOptions({label:z.titleEditor.value,subLabel:z.appNameEditor.value+" "+z.appVersionEditor.value,description:z.descriptionEditor.value});this.listView.getTreeDocument().pushUpdate();this.activeConnector.dataelements.title=z.titleEditor.value;this.activeConnector.dataelements["Application Name"]=z.appNameEditor.value;this.activeConnector.dataelements["Application Version"]=z.appVersionEditor.value;this.activeConnector.dataelements.description=z.descriptionEditor.value;this.activeConnector.dataelements.kind=z.appTypeComboBox.value.toLowerCase();this.updateConnector();w.close()}.bind(this);return w},configureListPanelButtons:function(){this.connectorListView.elements.addButton.onClick=function(){this.initConnectorCreationDialog()}.bind(this);this.connectorListView.elements.editButton.onClick=function(){if(this.isConnectorSelected()){this.initConnectorEditionDialog()}}.bind(this);this.connectorListView.elements.lifecycleButton.onClick=function(){if(this.isConnectorSelected()){var w=l.get3DXContent({objectId:this.activeConnector.id,objectType:this.activeConnector.type,displayName:this.activeConnector.dataelements.name});var v={X3DContentId:JSON.stringify(w)};this.openTransientWidget("ENOLCMI_AP","Lifecycle",v)}}.bind(this);this.connectorListView.elements.relExplorerButton.onClick=function(){if(this.isConnectorSelected()){var w=l.get3DXContent({objectId:this.activeConnector.id,objectType:this.activeConnector.type,displayName:this.activeConnector.dataelements.name});var v={X3DContentId:JSON.stringify(w)};this.openTransientWidget("ENORIPE_AP","Relational Explorer",v)}}.bind(this);this.connectorListView.elements.propButton.onClick=function(){var y=this.tenant;if(this.isConnectorSelected()){var v=this.activeConnector.id;var w={getSecurityContext:function(){return{SecurityContext:e.getCurrentContext()}},getSelectedNodes:function(){return[{tenant:y,getID:function(){return v}}]}};var x=window&&window.widget&&window.widget.id;if(/^preview-/.test(x)){this.optionTableView.notifsManager.addNotif({level:"error",title:t["Pin.Widget"]})}else{require(["DS/LifecycleControls/EditPropDialog"],function(A){var z=new A();z.launchProperties(w)},function(z){u.warn("Failed to load properties widget: "+z,z)})}}}.bind(this)}});return m});