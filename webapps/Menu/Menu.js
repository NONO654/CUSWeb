define("DS/Menu/Menu",["DS/WebRecordEnabler/Adapter","DS/Core/PointerEvents","DS/Utilities/TouchUtils","DS/Utilities/Dom","css!DS/Menu/assets/css/Menu.css"],function(h,f,D,E){var b=document.createElement("div");b.innerHTML=['<div class="wux-menu">','<div class="wux-menu-parent">','<div class="wux-menu-parent-up"></div>','<div class="wux-menu-parent-title"></div>',"</div>",'<div class="wux-menu-scroll-up wux-menu-scroll-disabled"></div>','<div class="wux-menu-scrollable">','<div class="wux-menu-container">','<div class="wux-menu-column wux-menu-column-left"></div>','<div class="wux-menu-column wux-menu-column-icon"></div>','<div class="wux-menu-column wux-menu-column-title"></div>','<div class="wux-menu-column wux-menu-column-accelerator"></div>','<div class="wux-menu-column wux-menu-column-submenu"></div>',"</div>","</div>",'<div class="wux-menu-scroll-down"></div>',"</div>",'<div class="wux-menu-cell"></div>','<div class="wux-menu-overlap"></div>','<div class="wux-menu-overlap-submenu"></div>','<div class="wux-menu-collection-item"></div>',].join("");var H=b.querySelector(".wux-menu");var o=b.querySelector(".wux-menu-cell");var X=b.querySelector(".wux-menu-overlap");var r=b.querySelector(".wux-menu-overlap-submenu");var P=b.querySelector(".wux-menu-collection-item");var V={};var W=[];var i=-1;var Z=-1;var aa=-1;var d=-1;var n=50;var N=undefined;var B=undefined;var k=-1;var j=-1;var F=0;var v=0;var u=0;var c=false;const l=0;const O=1;const ab=2;var Y=l;var s=[];var y=function y(ad,ae){this.content=ad;this.menu_uid=ae;this.previous_uid=-1;this.next_uid=-1;this.submenu_uid=-1;this.cells=[];this.uid=s.push(this)-1};var Q=function Q(af,ad,ah,ai,ag,ae){this.parent=af;this.parentRecId=ah;this.parentTitle=ai;this.content=ag;this.config=ae;this.parent_item_uid=(ad?ad.uid:-1);this.first_uid=-1;this.focus_uid=-1;this.uid=W.push(this)-1};function G(ad){if(ad.substr(0,4)==="url("){return ad}return'url("'+ad+'")'}function e(){var ad=undefined;if(h.isRecording()||h.isReplaying()){ad=document.getElementById("menu_record");if(!ad){ad=document.createElement("div");ad.setAttribute("id","menu_record");ad.setAttribute("data-rec-id","menu_record");ad.style.display="none";document.body.appendChild(ad);h.register(ad,"DS/MenuRec/MenuRec")}}return ad}Q.prototype.buildView=function z(){if(this.parent&&!(this.parent instanceof Q)){throw new Error("Invalid parent, parent must be a Menu instance.")}this.useTouchInput=false;if(this.config){if(this.config.input){if(this.config.input==="touch"){this.useTouchInput=true}else{if(this.config.input!=="mouse"){throw new Error("Invalid config, 'input' property must be either 'mouse' or 'touch'.")}}}}this.useTouchInput=D.getTouchMode();if(!this.content||!this.content.length){throw new Error("Invalid content, menu must contain at least one item.")}this.showIcons=false;this.showTitles=false;this.showAccelerators=false;this.showSubMenuSeparators=false;this.showSubMenus=false;this.view=H.cloneNode(true);this.view.dataset.wuxMenuUid=this.uid;var ak=e();if(ak){this.view.dataset.recId="menu_"+this.uid;ak.markForRecord(this.view)}if(this.uid>0){if(Y===ab){this.view.classList.add("wux-menu-replace");this.view.querySelector(".wux-menu-parent-title").textContent=this.parentTitle}}var af=this.view.querySelector(".wux-menu-column-left");var aj=this.view.querySelector(".wux-menu-column-icon");var ai=this.view.querySelector(".wux-menu-column-title");var ag=this.view.querySelector(".wux-menu-column-accelerator");var ad=this.view.querySelector(".wux-menu-column-submenu");var ae=this;var al=-1;this.content.forEach(function ah(aE,aw,ax){if(!aE||!aE.type){throw new Error("Invalid item, 'type' property is mandatory.")}if(aE.icon&&aE.fonticon){throw new Error("Invalid item, 'icon' and 'fonticon' properties cannot be set together.")}if(aE.icon&&!((typeof aE.icon==="string")||((aE.icon instanceof Object)&&((typeof aE.icon.iconClasses==="string")||(typeof aE.icon.iconPath==="string")||(typeof aE.icon.iconName==="string"))))){throw new Error("Invalid item, 'icon' property must be a string or an object compliant with an icon definition")}if(aE.fonticon&&(!(aE.fonticon instanceof Object)||!aE.fonticon.content||typeof aE.fonticon.content!=="string")){throw new Error("Invalid item, 'fonticon' property must be an object with a 'content' string property.")}if(aE.submenu&&(!(aE.submenu instanceof Array)||!aE.submenu.length)){throw new Error("Invalid item, 'submenu' property must be an non empty array of menu items.")}if(aE.action&&typeof aE.action.callback!=="function"){throw new Error("Invalid item, 'action.callback' property must be a function.")}var aB=false;var aA=false;if(aE.state){var au=aE.state.toLowerCase().split("|");aB=(au.indexOf("disabled")>=0);aA=(au.indexOf("selected")>=0)}var aD=af.appendChild(o.cloneNode(true));var ay=aj.appendChild(o.cloneNode(true));var an=ai.appendChild(o.cloneNode(true));var av=ag.appendChild(o.cloneNode(true));var ao=ad.appendChild(o.cloneNode(true));var az=aD.appendChild(X.cloneNode(true));var aq=[aD,ay,an,av,ao];if(aE.type==="SeparatorItem"){aq.forEach(function(aG,aF,aH){aG.classList.add("wux-menu-separator")})}else{if(aE.type==="TitleItem"){aq.forEach(function(aG,aF,aH){aG.classList.add("wux-menu-title");if(aB){aG.classList.add("wux-menu-disabled")}});if(aE.title){az.textContent=aE.title}if(aE.tooltip){az.setAttribute("title",aE.tooltip)}}else{if(aE.type==="PushItem"){var ar,at;if(!aB){ar=new y(aE,ae.uid);if(aE.submenu&&aE.action){if(al!=-1){ar.previous_uid=al;s[al].next_uid=ar.uid}al=ar.uid;ar.cells.push(aD,ay,an,av);at=new y(aE,ae.uid);at.previous_uid=al;s[al].next_uid=at.uid;al=at.uid;at.cells.push(ao);az.dataset.wuxMenuItemUid=ar.uid;ao.dataset.wuxMenuItemUid=at.uid}else{if(al!=-1){ar.previous_uid=al;s[al].next_uid=ar.uid}al=ar.uid;ar.cells.push(aD,ay,an,av,ao);az.dataset.wuxMenuItemUid=ar.uid}if(this.first_uid==-1){this.first_uid=ar.uid}}aq.forEach(function(aG,aF,aH){aG.classList.add("wux-menu-push");if(aB){aG.classList.add("wux-menu-disabled")}});if(aE.icon){this.showIcons=true;ay.appendChild(E.generateIcon(aE.icon))}else{if(aE.fonticon){this.showIcons=true;if(aE.fonticon.content.substr(0,2)==="&#"){ay.innerHTML=aE.fonticon.content}else{var am=aE.fonticon.content.split(" ");am.forEach(function(aG,aF,aH){ay.classList.add(aG)})}if(aE.fonticon.family){ay.style.fontFamily=aE.fonticon.family}}}if(aE.title){this.showTitles=true;an.textContent=aE.title}if(aE.accelerator){this.showAccelerators=true;av.textContent=aE.accelerator}if(aE.submenu){this.showSubMenus=true;if(aE.action){this.showSubMenuSeparators=true;az.classList.add("wux-menu-submenu-separator");ao.classList.add("wux-menu-submenu-separator")}ao.classList.add("wux-menu-submenu");var aC=new Q(this,at?at:ar,aE.recId,aE.title,aE.submenu,this.config);aC.buildView();if(at){at.submenu_uid=aC.uid}else{if(ar){ar.submenu_uid=aC.uid}}}if(aE.tooltip){az.setAttribute("title",aE.tooltip)}}else{if(aE.type==="CheckItem"||aE.type==="RadioItem"){var ar;if(!aB){ar=new y(aE,ae.uid);if(al!=-1){ar.previous_uid=al;s[al].next_uid=ar.uid}al=ar.uid;ar.cells.push(aD,ay,an,av,ao);az.dataset.wuxMenuItemUid=ar.uid;if(this.first_uid==-1){this.first_uid=ar.uid}}aq.forEach(function(aG,aF,aH){aG.classList.add(aE.type==="CheckItem"?"wux-menu-check":"wux-menu-radio");if(aB){aG.classList.add("wux-menu-disabled")}if(aA){aG.classList.add("wux-menu-selected")}});if(aE.icon){this.showIcons=true;ay.appendChild(E.generateIcon(aE.icon))}else{if(aE.fonticon){this.showIcons=true;if(aE.fonticon.content.substr(0,2)==="&#"){ay.innerHTML=aE.fonticon.content}else{var am=aE.fonticon.content.split(" ");am.forEach(function(aG,aF,aH){ay.classList.add(aG)})}if(aE.fonticon.family){ay.style.fontFamily=aE.fonticon.family}}}if(aE.title){this.showTitles=true;an.textContent=aE.title}if(aE.accelerator){this.showAccelerators=true;av.textContent=aE.accelerator}if(aE.tooltip){az.setAttribute("title",aE.tooltip)}}else{if(aE.type==="CollectionItem"){aq.forEach(function(aG,aF,aH){aG.classList.add("wux-menu-collection");if(aB){aG.classList.add("wux-menu-disabled")}});if(aE.items){aE.items.forEach(function ap(aH,aG,aM){if(aH.icon&&aH.fonticon){throw new Error("Invalid item, 'icon' and 'fonticon' properties cannot be set together.")}if(aH.icon&&typeof aH.icon!=="string"){throw new Error("Invalid item, 'icon' property must be a string.")}if(aH.fonticon&&(!(aH.fonticon instanceof Object)||!aH.fonticon.content||typeof aH.fonticon.content!=="string")){throw new Error("Invalid item, 'fonticon' property must be an object with a 'content' string property.")}if(aH.action&&typeof aH.action.callback!=="function"){throw new Error("Invalid item, 'action.callback' property must be a function.")}var aK=false;if(aH.state){var aL=aH.state.toLowerCase().split("|");aK=(aL.indexOf("disabled")>=0)}var aJ=P.cloneNode(true);if(aB||aK){aJ.classList.add("wux-menu-disabled")}if(aH.icon){aJ.style.backgroundImage=G(aH.icon)}else{if(aH.fonticon){if(aH.fonticon.content.substr(0,2)==="&#"){aJ.innerHTML=aH.fonticon.content}else{var aF=aH.fonticon.content.split(" ");aF.forEach(function(aO,aN,aP){aJ.classList.add(aO)})}if(aH.fonticon.family){aJ.style.fontFamily=aH.fonticon.family}}}if(aH.tooltip){aJ.setAttribute("title",aH.tooltip)}var aI;if(!aB&&!aK){aI=new y(aH,ae.uid);if(al!=-1){aI.previous_uid=al;s[al].next_uid=aI.uid}al=aI.uid;aI.cells.push(aJ);aJ.dataset.wuxMenuItemUid=aI.uid;if(this.first_uid==-1){this.first_uid=aI.uid}}this.appendChild(aJ)},az)}}else{throw new Error("Invalid item, '"+aE.type+"' is an unsupported 'type' property.")}}}}}},this);if(this.first_uid!=-1){s[this.first_uid].previous_uid=al;s[al].next_uid=this.first_uid}if(this.useTouchInput){this.view.classList.add("wux-menu-touch")}else{this.view.classList.add("wux-menu-mouse")}if(!this.showIcons){aj.parentNode.removeChild(aj)}if(!this.showTitles){ai.parentNode.removeChild(ai)}if(!this.showAccelerators){ag.parentNode.removeChild(ag)}if(!this.showSubMenus){ad.parentNode.removeChild(ad)}if(!this.showIcons){ai.classList.add("wux-menu-column-left-margin")}if(this.showAccelerators||!this.showSubMenus||this.showSubMenuSeparators){if(this.showTitles){ai.classList.add("wux-menu-column-right-margin")}else{aj.classList.add("wux-menu-column-right-margin")}}if(this.showAccelerators&&(!this.showSubMenus||this.showSubMenuSeparators)){ag.classList.add("wux-menu-column-right-margin")}};Q.prototype.updateSize=function q(){var aq=true;if(this.view){var ai=this.view.getBoundingClientRect().width;if(ai<160||ai>320){var ap=this.view.querySelector(".wux-menu-column-title");if(ap){var am=ap.getBoundingClientRect().width;if(ai>320){am+=(320-ai)}else{am+=(160-ai)}ap.style.width=am+"px";ai=this.view.getBoundingClientRect().width}}var ak=this.view.querySelectorAll(".wux-menu-overlap");for(var ag=0;ag<ak.length;ag++){if(ak[ag].classList.contains("wux-menu-submenu-separator")){var ae=this.view.querySelector(".wux-menu-column-submenu");var aj=(ae?ae.getBoundingClientRect().width:0);ak[ag].style.width=(ai-aj)+"px"}else{ak[ag].style.width=ai+"px"}}var ad=this.view.querySelectorAll(".wux-menu-column");var al=this.view.querySelectorAll(".wux-menu-collection .wux-menu-overlap");for(var ag=0;ag<al.length;ag++){var ah=Array.prototype.indexOf.call(al[ag].parentNode.parentNode.children,al[ag].parentNode);var ao=al[ag].getBoundingClientRect().height;for(var af=0;af<ad.length;af++){ad[af].children[ah].style.height=ao+"px"}}var an=document.documentElement.clientWidth;if(this.config&&this.config.display){if(this.config.display.paddingLeft){an-=this.config.display.paddingLeft}if(this.config.display.paddingRight){an-=this.config.display.paddingRight}}if((ai+320)>an){aq=false}}return aq};Q.prototype.setHoverState=function a(ad,af){if(ad>=0&&ad<s.length){if(af){this.focus_uid=ad;if(this.parent&&this.parent_item_uid>=0){this.parent.setHoverState(this.parent_item_uid,true)}}var ae=s[ad].cells;for(var ag=0;ag<ae.length;ag++){if(af){ae[ag].classList.add("wux-menu-hover")}else{ae[ag].classList.remove("wux-menu-hover")}}}if(!af&&this.focus_uid==ad){this.focus_uid=-1}};function ac(ae){var ag=s[ae].cells;var af=((ag.length>1||ag[0].classList.contains("wux-menu-collection-item"))?ag[0]:s[s[ae].previous_uid].cells[0]);var ah=ag[ag.length-1];var ak=af.getBoundingClientRect();var ai=ah.getBoundingClientRect();var ad=(af.previousElementSibling!==null?(ak.height-af.clientHeight):0);var aj={};aj.top=ak.top-ad;aj.right=ai.right;aj.bottom=ak.bottom;aj.left=ak.left;aj.width=ai.right-ak.left;aj.height=ak.height+ad;return aj}Q.prototype.makeItemVisible=function M(af){if(this.view&&this.view.classList.contains("wux-menu-with-scroll")){var ag=ac(af);var ah=this.view.querySelector(".wux-menu-scroll-up");var ae=this.view.querySelector(".wux-menu-scrollable");var ad=this.view.querySelector(".wux-menu-scroll-down");var am=this.view.querySelector(".wux-menu-container");var al=ae.getBoundingClientRect();var ak=am.getBoundingClientRect();var aj=ak.height-al.height;if(ag.top<al.top){var ai=ak.top-ag.top;if(ai>=0){ai=0;ah.classList.add("wux-menu-scroll-disabled")}am.style.top=ai+"px";ad.classList.remove("wux-menu-scroll-disabled")}else{if(ag.bottom>al.bottom){var ai=ak.top-al.top-(ag.bottom-al.bottom);if((al.height-ai)>=ak.height){ai=al.height-ak.height;ad.classList.add("wux-menu-scroll-disabled")}am.style.top=ai+"px";ah.classList.remove("wux-menu-scroll-disabled")}}}};Q.prototype.onKeyDown=function g(ag){if(this.first_uid==-1){return}var ai=this.focus_uid;var ah=this.focus_uid;var af=false;if(ag==13){if(this.focus_uid!=-1){var ad=s[this.focus_uid].submenu_uid;if(ad!=-1){var ae={};ae.parentItemRect=ac(this.focus_uid);W[ad].show(ae);af=true}else{A(s[this.focus_uid])}}}else{if(ag==27){if(this.parent){this.hide();i=this.parent.uid}else{V.hide()}}else{if(ag==37){if(i==0){af=true}else{this.hide();i=this.parent.uid}}else{if(ag==38){if(this.focus_uid==-1){ah=s[this.first_uid].previous_uid}else{ah=s[this.focus_uid].previous_uid}if(ah===ai){af=true}}else{if(ag==39){if(this.focus_uid!=-1){var ad=s[this.focus_uid].submenu_uid;if(ad!=-1){var ae={};ae.parentItemRect=ac(this.focus_uid);W[ad].show(ae)}af=true}}else{if(ag==40){if(this.focus_uid==-1){ah=this.first_uid}else{ah=s[this.focus_uid].next_uid}if(ah===ai){af=true}}}}}}}if(!af){this.setHoverState(ai,false)}if(ah!==ai){this.setHoverState(ah,true);this.makeItemVisible(ah)}};Q.prototype.show=function K(aw){if(this.view){var aj=0,ai=0;var ad=document.documentElement.clientWidth;var af=document.documentElement.clientHeight;var an=false;if(this.uid>0&&Y===ab){an=true;var ag=this.parent.view.getBoundingClientRect();aj=ag.left;ai=ag.top}else{if(aw&&aw.position){aj=aw.position.x;ai=aw.position.y}if(aw&&aw.parentItemRect&&!c){aj=aw.parentItemRect.right;ai=aw.parentItemRect.top}}this.view.style.left=aj+"px";this.view.style.top=ai+"px";document.body.appendChild(this.view);if(!this.updateSize()){if(Y===l&&this.uid===0){Y=ab;var ap=this.config||{};ap.submenu="replace";V.show(this.content,ap)}}var aq=0;var ak=0;var ae=ad;var al=af;if(aw&&aw.display){if(aw.display.paddingLeft){aq=aw.display.paddingLeft}if(aw.display.paddingTop){ak=aw.display.paddingTop}if(aw.display.paddingRight){ae-=aw.display.paddingRight}if(aw.display.paddingBottom){al-=aw.display.paddingBottom}}var au=ae-aq;var ar=al-ak;var am=this.view.getBoundingClientRect();if(!an&&aw&&aw.parentItemRect&&c){aj=aw.parentItemRect.left-am.width;ai=aw.parentItemRect.top;this.view.style.left=aj+"px";this.view.style.top=ai+"px"}if(!an&&aw&&aw.layout){var av=aw.layout.toLowerCase().split("|");for(var at=0;at<av.length;at++){if(av[at]==="topleft"){this.view.style.left=aj+"px";this.view.style.top=ai+"px"}else{if(av[at]==="topright"){this.view.style.left=(aj-am.width)+"px";this.view.style.top=ai+"px"}else{if(av[at]==="bottomleft"){this.view.style.left=aj+"px";this.view.style.top=(ai-am.height)+"px"}else{if(av[at]==="bottomright"){this.view.style.left=(aj-am.width)+"px";this.view.style.top=(ai-am.height)+"px"}}}}am=this.view.getBoundingClientRect();if(am.left>=aq&&am.right<ae&&am.top>=ak&&am.bottom<al){break}}}am=this.view.getBoundingClientRect();if(am.left<aq||am.right>=ae||am.top<ak||am.bottom>=al){var ah=am.left;var ao=am.top;if(am.right>ae){if(aw&&aw.parentItemRect&&!c&&(aw.parentItemRect.left-am.width)>=aq){ah=aw.parentItemRect.left-am.width;ao=aw.parentItemRect.top;c=true}else{ah-=am.width;if((ah+am.width)>ae){ah=ae-am.width}}}if(am.bottom>al){ao-=am.height;if((ao+am.height)>al){ao=al-am.height}}if(ah<aq){ah=aq}if(ao<ak){ao=ak}if(!an){this.view.style.left=ah+"px";this.view.style.top=ao+"px"}if(am.height>(al-ao)){this.view.style.height=ar+"px";this.view.classList.add("wux-menu-with-scroll")}}i=this.uid;if(an){this.parent.view.style.display="none";aa=this.uid}}};Q.prototype.hide=function U(){if(this.view&&this.view.parentNode){this.view.parentNode.removeChild(this.view);this.setHoverState(-1,false);if(this.parent&&this.parent.view.style.display==="none"){this.parent.view.style.display="";i=this.parent.uid;aa=this.parent.uid;if(this.parent.focus_uid>=0){var ad=ac(this.parent.focus_uid);if(k<ad.left||k>ad.right||j<ad.top||j>ad.bottom){this.parent.setHoverState(this.parent.focus_uid,false)}}}}};function p(ad){if(!ad){return -1}if(!ad.dataset||ad.dataset.wuxMenuUid===undefined){return p(ad.parentNode)}return Number(ad.dataset.wuxMenuUid)}function m(ad){if(ad>=0){return W[s[ad].menu_uid]}}function w(ae){var ad=ae.target.dataset.wuxMenuItemUid;if(ad>=0){var af=m(ad);if(af){af.setHoverState(W[s[ad].menu_uid].focus_uid,false);af.setHoverState(ad,true)}d=ad}else{d=-1}Z=p(ae.target);if(Z!=-1){aa=Z}}function L(ae){var ad=ae.target.dataset.wuxMenuItemUid;if(ad>=0){var af=m(ad);if(af){af.setHoverState(ad,false)}}}function S(ad){if(ad.clientX!=k||ad.clientY!=j){k=ad.clientX;j=ad.clientY;var ae=p(ad.target);if(ae==-1){if(B===undefined){B=window.setTimeout(J,n)}}else{if(B!==undefined){window.clearTimeout(B);B=undefined}}if(N!==undefined){window.clearTimeout(N);N=undefined}N=window.setTimeout(t,n)}}function I(ag){if(f.isTouchEvent(ag)){w(ag);ag.target.style.cursor="pointer"}if(ag.touches&&ag.touches.length===1){var ai=new Date().getTime();var af=ai-F;var ae=Math.abs(v-ag.touches[0].clientX);var ad=Math.abs(u-ag.touches[0].clientY);if(ae<10&&ad<10&&af<500){ag.preventDefault()}v=ag.touches[0].clientX;u=ag.touches[0].clientY;F=ai}var ah=p(ag.target);if(ah==-1){V.hide()}}function x(ah){if(ah.button===0||f.isTouchEvent(ah)){var ad=ah.target.dataset.wuxMenuItemUid;if(ad>=0){var af=s[ad];if(af){var ai=W[af.menu_uid];if(af.submenu_uid!=-1){var ag=i;while(ag!=af.menu_uid){W[ag].hide();ag=W[ag].parent.uid}var ae={};ae.parentItemRect=ac(ad);W[af.submenu_uid].show(ae)}else{A(af)}}}else{if(ah.target.classList.contains("wux-menu-scroll-up")){R({deltaY:-20,target:ah.target})}else{if(ah.target.classList.contains("wux-menu-scroll-down")){R({deltaY:20,target:ah.target})}else{if(ah.target.classList.contains("wux-menu-parent-up")){if(i!=-1){W[i].hide()}}}}}}}function g(ad){if(i!=-1){W[i].onKeyDown(ad.keyCode||ad.location)}}function C(ad){ad.stopPropagation();ad.preventDefault()}function A(ag){var ae=e();if(h.isRecording()&&ae){var ad=ag.content.recId;if(!ad){h.TraceManager.error('Menu item "'+ag.content.title+"\" doesn't have a record identifier, this is not compatible with WebRecord")}else{var af=W[ag.menu_uid];while(af.uid>0){if(!af.parentRecId){h.TraceManager.error('Menu item "'+af.parentTitle+"\" doesn't have a record identifier, this is not compatible with WebRecord");ad=undefined;break}ad=af.parentRecId+"/"+ad;af=af.parent}}if(ad){h.addCustomInteraction(ae,{recVersion:1,recType:"MenuAction",recIdPath:ad},"DS/MenuRec/MenuRec",{checkVisibility:false})}}V.hide();if(ag&&ag.content&&ag.content.action&&ag.content.action.callback){ag.content.action.callback.call(ag.content.action["this"],{context:ag.content.action.context})}}function T(ad){V.hide()}function R(ae){var aj=ae.target;while(aj&&aj.dataset&&aj.dataset.wuxMenuUid===undefined){aj=aj.parentNode}if(aj&&aj.dataset){var ah=aj.dataset.wuxMenuUid;if(ah>=0){var af=W[ah];if(af&&af.view&&af.view.classList.contains("wux-menu-with-scroll")){var ai=af.view.querySelector(".wux-menu-scroll-up");var ag=af.view.querySelector(".wux-menu-scrollable");var ad=af.view.querySelector(".wux-menu-scroll-down");var ao=af.view.querySelector(".wux-menu-container");var an=ag.getBoundingClientRect();var am=ao.getBoundingClientRect();var al=am.height-an.height;if(ae.deltaY>0){var ak=am.top-an.top-20;if((an.height-ak)>=am.height){ak=an.height-am.height;ad.classList.add("wux-menu-scroll-disabled")}ao.style.top=ak+"px";ai.classList.remove("wux-menu-scroll-disabled")}else{var ak=am.top-an.top+20;if(ak>=0){ak=0;ai.classList.add("wux-menu-scroll-disabled")}ao.style.top=ak+"px";ad.classList.remove("wux-menu-scroll-disabled")}}}}}function t(){N=undefined;if(Z<0){var ag=aa>=0?aa:0;var ah=i;while(ah!=ag){W[ah].hide();ah=W[ah].parent.uid}i=ag}else{if(Y!==ab){var ad=-1;if(d>=0){ad=s[d].submenu_uid}var ah=i;while(ah!=Z&&ah!=ad){W[ah].hide();ah=W[ah].parent.uid}if(ad>=0&&ah!=ad){var af=s[d];if(af){var ae={};ae.parentItemRect=ac(d);W[ad].show(ae)}}i=ad>=0?ad:Z}}}function J(){B=undefined;var ad=aa>=0?aa:0;var ae=i;while(ae!=ad){W[ae].hide();ae=W[ae].parent.uid}i=ad}V.show=function K(ag,ae){V.hide();Y=l;if(ae&&ae.submenu==="replace"){Y=ab}else{if(ae&&ae.submenu==="outside"){Y=O}}var af=new Q(undefined,undefined,undefined,undefined,ag,ae);af.buildView();af.show(ae);var ad=e();if(ad&&W.length>0){ad.menus=W[0].content}document.addEventListener("mouseover",w,true);document.addEventListener(f.POINTEROUT,L);document.addEventListener(f.POINTERMOVE,S);document.addEventListener(f.POINTERDOWN,I);document.addEventListener(f.POINTERHIT,x);document.addEventListener("keydown",g,true);document.addEventListener("resize",T,false);document.addEventListener("contextmenu",C,false);document.addEventListener("wheel",R,true);this._onShow();return af.view.getBoundingClientRect()};V.hide=function U(){var ae=e();if(h.isRecording()&&ae){h.addCustomInteraction(ae,{recVersion:1,recType:"MenuHide"},"DS/MenuRec/MenuRec",{checkVisibility:false})}document.removeEventListener("mouseover",w,true);document.removeEventListener(f.POINTEROUT,L);document.removeEventListener(f.POINTERMOVE,S);document.removeEventListener(f.POINTERDOWN,I);document.removeEventListener(f.POINTERHIT,x);document.removeEventListener("keydown",g,true);document.removeEventListener("resize",T,false);document.removeEventListener("contextmenu",C,false);document.removeEventListener("wheel",R,true);if(N!==undefined){window.clearTimeout(N);N=undefined}if(B!==undefined){window.clearTimeout(B);B=undefined}for(var af=0;af<W.length;af++){if(W[af].view){var ad=W[af].view.parentNode;if(ad){ad.removeChild(W[af].view)}}}W=[];i=-1;Z=-1;aa=-1;d=-1;s=[];c=false};V._onShow=function(){};return V});define("DS/Menu/ContextualMenu",["DS/Menu/Menu","DS/WebRecordEnabler/Adapter","UWA/Class/Promise","DS/Core/PointerEvents"],function(j,c,k,i){var h=undefined;var l="mouse";var n="auto";function a(o){return !isNaN(parseFloat(o))&&isFinite(o)}function m(o){if(i.isTouchEvent(o)){d(o)}}function d(r){var z=[];var s=r.target;while(s){if(s["wux-data-contextual"]){var v=s.getBoundingClientRect?s.getBoundingClientRect():{left:0,top:0};var w=r.pageX-v.left;var u=r.pageY-v.top;var t=s["wux-data-contextual"];for(var p=0;p<t.length;p++){var o=t[p].params.callback.call(t[p].params["this"],{context:t[p].params.context,info:{position:{x:w,y:u},target:r.target},data:{event:r,listener:s,listenerPosition:{x:w,y:u},target:r.target,targetPosition:{x:r.offsetX,y:r.offsetY},windowPosition:{x:r.clientX,y:r.clientY}}});if(o&&(o instanceof Promise)){z.push(o)}else{if(o&&o.length>0){z.push(k.resolve(o))}}}}if(z.length>0||!r.target||r.target.tagName.toLowerCase()!=="input"&&r.target.tagName.toLowerCase()!=="textarea"){r.preventDefault()}if(s===window){s=undefined}else{s=s.parentNode?s.parentNode:window}}if(z&&z.length>0){var q=c.WaitManager.addWaitCondition(20*1000,"Wait context menu to be displayed");k.allSettled(z).then(function(x){var A=[];var B=0;if(x&&x.length>0){for(var y=0;y<x.length;y++){if(x[y].value&&x[y].value.length>0){if(A.length>B){A.push({type:"SeparatorItem"});B=A.length}A=A.concat(x[y].value)}}}if(A&&A.length>0){j.show(A,{display:h,input:l,position:{x:r.pageX,y:r.pageY},submenu:n})}c.WaitManager.removeWaitCondition(q)})}return false}var g={};g.setGlobalConfig=function e(o){if(!o){throw new Error("Invalid configuration.")}if(o.display){h=o.display}if(o.input){if(o.input!=="mouse"&&o.input!=="touch"){throw new Error("Invalid input configuration, expected values are 'mouse' or 'touch'.")}l=o.input}if(o.submenu){if(o.submenu!=="replace"&&o.submenu!=="outside"&&o.submenu!=="auto"){throw new Error("Invalid submenu configuration, expected values are 'replace', 'outside' or 'auto'.")}n=o.submenu}};g.addEventListener=function f(o,p){if(!o||!p){throw new Error("Invalid parameters.")}if(o!==window&&!(o instanceof HTMLElement)){throw new Error("Invalid parameters, 'target' must be the window or an HTMLElement.")}if(!p.callback||!(p.callback instanceof Function)){throw new Error("Invalid parameters, 'params.callback' must be a function.")}var q=o["wux-data-contextual"];if(!q){q=[];q.next=0;o["wux-data-contextual"]=q;o.addEventListener("contextmenu",d);o.addEventListener(i.LONGHOLD,m)}q.push({uid:q.next,params:p});return q.next++};g.removeEventListener=function b(q,p){if(!q||!a(p)){throw new Error("Invalid parameters.")}var r=q["wux-data-contextual"];if(!r){throw new Error("Invalid target.")}var o=0;while(o<r.length&&r[o].uid!=p){o++}if(o>=r.length){throw new Error("Invalid uid.")}if(r.length>1){r.splice(o,1);r.next=r[r.length-1].uid+1}else{q.removeEventListener("contextmenu",d);q.removeEventListener(i.LONGHOLD,m);delete q["wux-data-contextual"]}};return g});