define("DS/ENOFloatingPanel/ENOFloatingPanel-Webrecord",["DS/WebRecordEnabler/Adapter"],function(a){return{customReplay:function(e){a.TraceManager.info(e);delete e.target;delete e.DOMelem;if(e.data.source==="ENOFloatingPanel Interaction"){var g=null;if(e.data.data.type==="resize"){g=document.querySelector(".EditPropPopup_Resize");g.style.display="block"}else{g=document.querySelector("[data-rec-id=FloatingPanelComponent-modalHeader")}var f={x:e.data.data.type==="move"?g.getParent().getParent().getParent().getPosition().x:g.getPosition().x,y:e.data.data.type==="move"?g.getParent().getParent().getParent().getPosition().y:g.getPosition().y};var c=document.createEvent("MouseEvents");var d=document.createEvent("MouseEvents");var b=document.createEvent("MouseEvents");b.initEvent("mouseup",true,true);c.initMouseEvent("mousedown",true,true,window,1,f.x,f.y,f.x,f.y,false,false,false,false,0,null);d.initMouseEvent("mousemove",true,true,window,1,f.x+e.data.data.percentages.x*window.innerWidth,f.y+e.data.data.percentages.y*window.innerHeight,f.x+e.data.data.percentages.x*window.innerWidth,f.y+e.data.data.percentages.y*window.innerHeight,false,false,false,false,0,null);g.dispatchEvent(c);document.dispatchEvent(d);g.dispatchEvent(b);return(g.getParent().getParent().getParent().getPosition().x+g.getPosition().x!==f.x)||(g.getParent().getParent().getParent().getPosition().y+g.getPosition().x!==f.y)}},}});define("DS/ENOFloatingPanel/ENOFloatingPanel-RecordHelper",["DS/WebRecordEnabler/Adapter","DS/UIKIT/Modal"],function(b,a){return{overrideMethods:function(f){var c={_lastAction:f._lastAction,_showResizeContainer:f._showResizeContainer,_firstActionOnHeaderMove:f._firstActionOnHeaderMove};var d={source:"ENOFloatingPanel Interaction",data:{coordinates:{original:{},newCoordinates:{}},percentages:{},offsetPercentages:{},type:"resize"}};f._lastAction=function(g){if(g.type==="mouseup"){c._lastAction.apply(this,arguments);d.data.coordinates.newCoordinates.pageX=g.pageX;d.data.coordinates.newCoordinates.pageY=g.pageY;d.data.percentages.x=(d.data.coordinates.newCoordinates.pageX-d.data.coordinates.original.pageX)/window.innerWidth;d.data.percentages.y=(d.data.coordinates.newCoordinates.pageY-d.data.coordinates.original.pageY)/window.innerHeight;b.addCustomInteraction(this.elements.container,d,"DS/ENOFloatingPanel/ENOFloatingPanel-Webrecord",false)}};f._firstActionOnHeaderMove=function(g){c._firstActionOnHeaderMove.apply(this,arguments);d.data.coordinates.original.pageX=g.pageX;d.data.coordinates.original.pageY=g.pageY;d.data.offsetPercentages.x=((g.pageX-document.querySelector("[data-rec-id=FloatingPanelComponent-modalContainer").getPosition().x)/window.innerWidth);d.data.offsetPercentages.y=((g.pageY-document.querySelector("[data-rec-id=FloatingPanelComponent-modalContainer").getPosition().y)/window.innerHeight);d.data.type="move"};f._showResizeContainer=function(){c._showResizeContainer.apply(this,arguments);this.resizeContainer.show();document.querySelector(".EditPropPopup_Resize").addEventListener("mousedown",function(){d.data.type="resize";d.data.coordinates.original.pageX=this.getParent().getParent().getParent().getPosition().x+this.getPosition().x;d.data.coordinates.original.pageY=this.getParent().getParent().getParent().getPosition().y+this.getPosition().y})};var e=a.extend(f);b.register(e,"DS/ENOFloatingPanel/ENOFloatingPanel-Webrecord");return e}}});define("DS/ENOFloatingPanel/ENOFloatingPanel",["UWA/Core","DS/WebappsUtils/WebappsUtils","DS/W3DDComponents/Views/PinView","DS/WidgetServices/WidgetServices","DS/UIKIT/Modal","DS/UIKIT/Scroller",typeof window.DSWebRecord!=="undefined"?"DS/ENOFloatingPanel/ENOFloatingPanel-RecordHelper":null,"css!DS/ENOFloatingPanel/ENOFloatingPanel.css","i18n!DS/ENOFloatingPanel/assets/nls/ENOFloatingPanel"],function(m,h,f,o,n,i,d,l,k){var c=40;var e="span";var j=0;function g(s,r){var q=document.getElementsByClassName("ENOFloatingStyle"+s+"_js");var p=null;if(q&&q.length>0){p=q[0]}if(!p){p=document.createElement("style");p.type="text/css";p.className="ENOFloatingStyle"+s+"_js";document.getElementsByTagName("head")[0].appendChild(p)}p.appendChild(document.createTextNode(r))}function b(q){var p=document.getElementsByClassName("ENOFloatingStyle"+q+"_js");if(p&&p.length>0){p[0].parentNode.removeChild(p[0])}}var a={defaultOptions:{className:" floatingPanelComponent",header:"",title:"",pinOptions:null,pinCallback:null,body:"",overlay:false,closable:false,animate:false,resizable:false,maximizable:false,persistId:null,limitParent:false,autocenter:true,appNamePosition:1},launchPin:function(p){if(typeof this.options.pinCallback==="function"){this.options.pinCallback.call(null,p.options)}p.container.firstChild.click();this._close()},init:function(p){var r=this;j++;this.floating_id=j;this.parentElement=o.getWidgetBody();this.headerContainer=p.header;this.listOfTitleElement=[];if(!this.headerContainer){this.headerContainer=UWA.createElement("div",{"class":"floatingPanel_Header"});this.rightButtons=UWA.createElement("div",{"class":"floatingPanel_RightButtons"}).inject(this.headerContainer);this.titleContainer=UWA.createElement(e,{"class":"floatingPanel_title"});this.titleContainer.inject(this.headerContainer);if(p.title){this._fillTitleList(p.title,p)}this.permanentTitle=UWA.createElement("span",{text:p.title}).inject(this.titleContainer);if(p.pinOptions){var q=new f(p.pinOptions);q.render();UWA.createElement("span",{"class":"right-actions  fonticon fonticon-publish ",title:k.get("EFP_PinWidget"),events:{click:function(){r.launchPin(q)},touchstart:function(){r.launchPin(q)}}}).inject(this.rightButtons)}if(p.maximizable===true){this.minimizeButton=UWA.createElement("span",{"class":"right-actions fonticon fonticon-resize-small",title:k.get("EFP_RestorePanel"),events:{click:function(){r._restore();r.minimizeButton.setStyle("display","none");r.maximizeButton.setStyle("display",r.origMaximizeStyle)},touchstart:function(){r._restore();r.minimizeButton.setStyle("display","none");r.maximizeButton.setStyle("display",r.origMaximizeStyle)}}}).inject(this.rightButtons);this.maximizeButton=UWA.createElement("span",{"class":"right-actions fonticon fonticon-resize-full",title:k.get("EFP_MaximizePanel"),events:{click:function(){r._maximize();r.maximizeButton.setStyle("display","none");r.minimizeButton.setStyle("display",r.origMinimizeStyle)},touchstart:function(){r._maximize();r.maximizeButton.setStyle("display","none");r.minimizeButton.setStyle("display",r.origMinimizeStyle)}}}).inject(this.rightButtons)}if(p.closable===true){p.closable=false;UWA.createElement("span",{"class":"right-actions  fonticon fonticon-cancel",title:k.get("EFP_ClosePanel"),events:{click:function(){r._close()},touchstart:function(){r._close()}}}).inject(this.rightButtons)}p.header=this.headerContainer}p.className=p.className?p.className:"";if(p){p.className+=this.defaultOptions.className}if(p.overlay!==true){p.className+=" EFP_noOverlay"}if(p.animate!==true){p.className+=" EFP_unanimated"}p.className+=" EFP_Number"+this.floating_id;this._parent(p);this._getSavedDimension();this.initUI();this._handleWidgetResize=function(){r._fixMaxWidthAndHeight();r._resizeContainer(false)};o.addWidgetResizeEvent(this._handleWidgetResize)},_fixMaxWidthAndHeight:function(){var s=this.elements.container;var r=this.elements.header;var w=r.getSize();var t=this.elements.body;var u=this.parentElement.getSize();var q=this.elements.footer;var v={width:0,height:0};if(q){v=q.getSize()}var p=u.height-w.height-v.height-2;r.setAttribute("data-rec-id","FloatingPanelComponent-modalHeader");t.setStyle("max-height",p+"px");t.setStyle("max-width",u.width+"px");t.setAttribute("data-rec-id","FloatingPanelComponent-modalBody");s.setStyle("max-height",u.height+"px");s.setStyle("max-width",u.width+"px");s.setAttribute("data-rec-id","FloatingPanelComponent-modalContainer")},_changeWidth:function(p){this.__changeValue("width",p)},_changeHeight:function(p){this.__changeValue("height",p)},_changeTop:function(p){this.__changeValue("top",p)},_changeLeft:function(p){this.__changeValue("left",p)},__changeValue:function(t,s){var q=this.elements.container;var p=s==="auto";q.setStyle(t,p?s:s+"px");if(!p){var r={};r[t]=s;this._saveDimensionAndPosition(r)}},isDimensionSaved:function(){return this.dimensionSaved},_getSavedDimension:function(){var p=null;if(this.options.persistId){p=localStorage.getItem("EFP_"+this.options.persistId)}this.dimensionSaved=!!p;return !!p?JSON.parse(p):null},_setSavedDimension:function(p){if(this.options.persistId){localStorage.setItem("EFP_"+this.options.persistId,JSON.stringify(p))}},_saveDimensionAndPosition:function(q){var r=this;if(r.elements.container){var p=this._getSavedDimension();this._setSavedDimension(null);p=p?p:{};if(q.width){p.width=q.width}if(q.height){p.height=q.height}if(q.top){p.top=q.top}if(q.left){p.left=q.left}this._setSavedDimension(p)}},_fillTitleList:function(v,s){if(!s){s=this.options}this._removeTitleElements();var u=v;var q=" - ";var t=q.length;var r=-1;var p=UWA.createElement(e,{"class":"titleElement_toHide floatingPanel_title"}).inject(this.headerContainer);this.listOfTitleElement.push(UWA.createElement("span",{text:u}).inject(p));while((r=u.indexOf(q))>=0){var u=u.substring(r+t);p=UWA.createElement(e,{"class":"titleElement_toHide floatingPanel_title"}).inject(this.headerContainer);this.listOfTitleElement.push(UWA.createElement("span",{text:u}).inject(p))}if(this.listOfTitleElement.length>s.appNamePosition){this.listOfTitleElement.pop()}},setTitle:function(p){this._fillTitleList(p);this._managerTitleContent()},_replaceTitle:function(p){this.permanentTitle.setText(p.getText())},_close:function(){this.dispatchEvent("onClose");if(this.options&&(!this.options.events||typeof this.options.events.onClose!=="function")){this.destroy()}},_maximize:function(){var q=this.parentElement;var s=q.getSize();var p=s.height;var r=s.width;this.setNewSize({width:r,height:p})},_restore:function(){if(this.lastResizeHeight>=0&&this.lastResizeWidth>=0){var p=this.lastResizeHeight;var q=this.lastResizeWidth;this.setNewSize({width:q,height:p})}else{this._setAutoWidthAndHeight()}},initialClient:{x:0,y:0},dragging:false,resizing:false,_getCurrentClientPosition:function(q){var r={};var p=q.changedTouches;if(p!=null){r={x:q.changedTouches[0].clientX,y:q.changedTouches[0].clientY}}else{r={x:q.clientX,y:q.clientY}}return r},setNewSizeWithDiff:function(r){this.previousHeight=-1;this.previousWidth=-1;var p=this.elements.container;var q=p.getSize();if(r.x!=null){q.width+=r.x}else{q.width=null}if(r.y!=null){q.height+=r.y}else{q.height=null}this.setNewSize(q)},setNewBodySize:function(r){this.previousHeight=-1;this.previousWidth=-1;var q=this.elements.body;if(q){var s=q.getDimensions();var p=s.outerWidth-s.innerWidth;var t=s.outerHeight-s.innerHeight;this._setAutoWidthAndHeight();if(r.width){q.setStyle("width",(r.width+p)+"px")}if(r.height){q.setStyle("height",(r.height+t)+"px")}this._resizeContainer(true)}},_setAutoWidthAndHeight:function(){var q=this.elements.body;var p=this.elements.container;q.setStyle("height","auto");q.setStyle("width","auto");this._changeWidth("auto");this._changeHeight("auto")},setNewSize:function(t){this.previousHeight=-1;this.previousWidth=-1;var q=this.elements.container;if(!q){return}var r=q.getSize();var s=this.parentElement.getSize();this._setAutoWidthAndHeight();if(t.width!=null){var u=this._minWidth;var v=t.width;if(u!=null&&u>v){v=u}if(v>s.width-15){v=s.width-15}this._changeWidth(v)}if(t.height){var w=this._minHeight;var p=t.height;if(w!=null&&w>p){p=w}if(p>s.height-15){p=s.height-15}this._changeHeight(p)}this._resizeContainer(false)},getContainerHeight:function(){var r=0;var p=this.elements.container;var q=p.getSize();if(q){r=q.height}return r},_actionMove:function(s){var r=this._getCurrentClientPosition(s);var A=this.elements.container;if(this.dragging===true){if(r.x>0&&r.y>0){var w=this.parentElement.getSize();var B={x:r.x-this.initialClient.x+this.currentLeft,y:r.y-this.initialClient.y+this.currentTop};var v=A.getSize();var z=v.width;var u=v.height;if(this.options.limitParent!==true){z=c;u=c}var y=w.width-z;if(B.x>y){B.x=y}if(B.x>=0&&B.x<=y){this._changeLeft(B.x)}var t=w.height-u;if(B.y>t){B.y=t}if(B.y>=0&&B.y<=t){this._changeTop(B.y)}}this.dispatchEvent("onMove")}if(this.resizing===true){if(r.x>0&&r.y>0){this.previousHeight=-1;this.previousWidth=-1;var B={x:this.initialClient.x-r.x,y:this.initialClient.y-r.y};var C=A.getSize();var q=this._minWidth;var D=this._minHeight;var E=this.parentElement.getSize();var p=this.initialSize.height-B.y;if((D==null||D<p)&&r.y<E.height-15){this._changeHeight(p)}var x=this.initialSize.width-B.x;if((q==null||q<x)&&r.x<E.width-15){this._changeWidth(x)}this.lastResizeHeight=p;this.lastResizeWidth=x;this._resizeContainer()}}},_firstActionResize:function(q){q.preventDefault();this.resizing=true;var p=this.elements.container;this.initialSize=p.getSize();this.initialClient=this._getCurrentClientPosition(q)},_firstActionOnHeaderMove:function(s){s.preventDefault();this.dragging=true;var p=this.elements.container;this.initialClient=this._getCurrentClientPosition(s);var r=p.getStyle("left");this.currentLeft=parseInt(r.replace("px",""));var q=p.getStyle("top");this.currentTop=parseInt(q.replace("px",""))},_lastAction:function(p){this.dragging=false;this.resizing=false},__showResizeContainerCB:function(p){this._showResizeContainer(true)},_hideResizeContainerCB:function(p){this._showResizeContainer(false)},_showResizeContainer:function(p){if(p===true){this.resizeContainer.show()}else{this.resizeContainer.hide()}},centerIt:function(){var p=this.elements.container;if(!p){return}var s=this.parentElement;if(this.parent){s=this.parent}var u=s.getSize();var q=p.getSize();var r=u.width/2-q.width/2;var t=u.height/2-q.height/2;this._changeLeft(r);this._changeTop(t)},setMinSize:function(r,s){if(!r){r=50}if(!s){var p=this.elements.header;var q=p?p.getSize():{height:0,width:0};s=q.height}this._minWidth=r;this._minHeight=s},initUI:function(){var v=this;b(this.floating_id);var r=this.elements.container;var t=this.elements.body;var q=this.elements.header;var u=this.elements.content;var p=this.elements.overlay;if(p){p.addClassName("EFP_overlay")}var s=h.getWebappsAssetUrl("EditPropPopup","icon_Resize.png");var w=UWA.createElement("div",{"class":"EditPropPopup_Resize",attributes:{"data-rec-id":"resizeContainerFloatingPanel"},html:[{tag:"img","class":"PopUpResizeImage",src:s}]});if(this.options.resizable===true){w.inject(u).hide()}this.resizeContainer=w;this._handlerMove=function(x){v._actionMove(x)};this._handlerResizeShow=function(x){v.__showResizeContainerCB(x)};this._handlerResizeHide=function(x){v._hideResizeContainerCB(x)};this._handlerFirstActionResize=function(x){v._firstActionResize(x)};this._handlerFirstActionOnHeaderMove=function(x){v._firstActionOnHeaderMove(x)};this._handlerLastAction=function(x){v._lastAction(x)};this._handlerKeyUp=function(x){if(x.which==27){v._close()}};document.addEventListener("mousemove",this._handlerMove);document.addEventListener("touchmove",this._handlerMove);r.addEventListener("mouseenter",this._handlerResizeShow);r.addEventListener("touchend",this._handlerResizeShow);r.addEventListener("mouseleave",this._handlerResizeHide);r.addEventListener("touchleave",this._handlerResizeHide);w.addEventListener("mousedown",this._handlerFirstActionResize);w.addEventListener("touchstart",this._handlerFirstActionResize);q.addEventListener("mousedown",this._handlerFirstActionOnHeaderMove);q.addEventListener("touchstart",this._handlerFirstActionOnHeaderMove);document.addEventListener("mouseup",this._handlerLastAction);document.addEventListener("touchend",this._handlerLastAction);document.addEventListener("mouseleave",this._handlerLastAction);document.addEventListener("touchleave",this._handlerLastAction);setTimeout(function(){if(!v.elements||!v.elements.container){return}if(v.options.escapeToClose!==false){UWA.extendElement(document).addEvent("keyup",v._handlerKeyUp)}C=v.elements.container;var B=C.className.replace(/(^ *| +)/g,".");var y=null;if(v.options.minWidth!==undefined){y=this.options.minWidth}else{y=C.getStyle("min-width");y=y.replace("px","");y=parseInt(y)}g(v.floating_id,B+" { min-width :0px !important }");var G=null;if(v.options.minHeight!==undefined){G=this.options.minHeight}else{G=C.getStyle("min-height");G=G.replace("px","");G=parseInt(v._minHeight)}g(v.floating_id,B+" { min-height :0px !important }");v.setMinSize(y,G);v._fixMaxWidthAndHeight();var F=C.getSize();var H=null;var z=null;if(v.options.resizable===true){H=F.height;z=F.width}var D=UWA.clone(v._getSavedDimension());v.setNewSize({width:z,height:H});var E=true;if(D){if(D.width){v._changeWidth(D.width)}if(D.height){v._changeHeight(D.height)}if(D.left){v._changeLeft(D.left)}if(D.top){v._changeTop(D.top)}E=!D.left&&!D.top}if(v.options.autocenter===true&&E===true){v.centerIt()}if(v.options.maximizable===true){v.lastResizeHeight=H;v.lastResizeWidth=z;var x=v.parentElement;var C=v.elements.container;var I=x.getSize();var F=C.getSize();v.origMinimizeStyle=v.minimizeButton.getStyle("display");v.origMaximizeStyle=v.maximizeButton.getStyle("display");var A=15+10;if(I.height>F.height+A&&I.width>F.width+A){v.minimizeButton.setStyle("display","none")}else{v.maximizeButton.setStyle("display","none")}}v.onResize()},0)},onResize:function(){this._resizeContainer(!this.options.resizable)},lockWidth:function(){var p=this.elements.container;if(p){var q=p.getSize();this._changeWidth(q.width)}},lastResizeHeight:-1,lastResizeWidth:-1,previousHeight:-1,previousWidth:-1,previousMaxWidth:null,previousMaxHeight:null,_resizeContainer:function(s){var t=this;var r=this.elements.container;var G=this.elements.footer;var z=this.elements.body;var B=this.parentElement.getSize();var p=this.elements.header;var D=p.getSize();if(z.getSize().height===0||B.height===0||B.height<D.height){return}var q=r.getSize();q=r.getSize();var A=q.height;var w=q.width;var x={width:0,height:0};if(G){x=G.getSize()}var C=z.getSize();if(s===false){z.setStyle("width","100%")}if(t.options.resizable&&s!==true){var v=A-D.height-x.height-2;z.setStyle("height",v+"px")}if(A<D.height){r.setStyle("min-height",D.height+"px")}var u=r.getPosition().y;var H=r.getPosition().x;var E=r.getSize();var F=E.width;var y=E.height;if(this.options.limitParent!==true){F=c;y=c}if(u>B.height-y){this._changeTop(B.height-y)}if(H>B.width-F){this._changeLeft(B.width-F)}if(this.listOfTitleElement.length>0){t._managerTitleContent()}setTimeout(function(){t.dispatchEvent("onResizeFloating")},0)},getModalBodySize:function(){var p=this.elements.body;return p.getDimensions()},_managerTitleContent:function(){var s=this;var p=this.elements.header;var q=this.titleContainer.getSize();var r=this.listOfTitleElement.length;this.listOfTitleElement.every(function(v,t){var u=v.getSize();if(u.width+25<=q.width||t===r-1){if(u.width+25>q.width){}s._replaceTitle(v);return false}return true})},destroy:function(){var q=this.elements.container;var p=this.elements.header;document.removeEventListener("mousemove",this._handlerMove);document.removeEventListener("touchmove",this._handlerMove);q.removeEventListener("mouseenter",this._handlerResizeShow);q.removeEventListener("touchend",this._handlerResizeShow);q.removeEventListener("mouseleave",this._handlerResizeHide);q.removeEventListener("touchleave",this._handlerResizeHide);if(this.options.escapeToClose!==false){UWA.extendElement(document).removeEvent("keyup",this._handlerKeyUp)}this.resizeContainer.removeEventListener("mousedown",this._handlerFirstActionResize);this.resizeContainer.removeEventListener("touchstart",this._handlerFirstActionResize);p.removeEventListener("mousedown",this._handlerFirstActionOnHeaderMove);p.removeEventListener("touchstart",this._handlerFirstActionOnHeaderMove);document.removeEventListener("mouseup",this._handlerLastAction);document.removeEventListener("touchend",this._handlerLastAction);document.removeEventListener("mouseleave",this._handlerLastAction);document.removeEventListener("touchleave",this._handlerLastAction);o.removeWidgetResizeEvent(this._handleWidgetResize);this._removeTitleElements();this.hide();b(this.floating_id);this._parent()},_removeTitleElements:function(){var p=this.headerContainer.getElements(".titleElement_toHide");p.forEach(function(q){q.remove()});this.listOfTitleElement=[]}};if(d){return d.overrideMethods(a)}else{return n.extend(a)}});