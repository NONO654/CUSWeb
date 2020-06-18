define(["UWA/Core","DS/SMAPoweredByState/ad-state-domain-managed-data/actions","i18n!DS/SMAPoweredByViews/assets/nls/ADDropZone","css!DS/SMAPoweredByViews/ad-drop-zone/ADDropZone"],function(h,d,g){var c={},f=null,a=null;function e(k){var n=document.createElement("div"),i=document.createElement("div"),j=document.createElement("div"),l=document.createElement("span"),m=document.createElement("span");n.className=(k)?"parent invisible-overlay":"parent";i.className="empty-table-overlay";j.className="empty-drop-note drop-note-text";l.className="fonticon fonticon-drag-drop";if(!k){m.textContent=g.get("DropNote");j.appendChild(m);j.appendChild(l);n.appendChild(j);n.appendChild(i)}return n}function b(){if(f!==null){f.parentElement.removeChild(f);f=null}}c.isDragWithinApp=false;c.handleDrop=function(k,m){var n=m.dataTransfer;m.stopPropagation();m.cancelBubble=true;m.preventDefault();this.destroyDropZone();var j=(n.files&&n.files.length>0)||(n.types&&n.types.contains&&n.types.contains("Files"))||(n.items&&n.items.length>0&&n.items[0].kind==="file");if(j){if(k.localFileCallBack){k.localFileCallBack(n.files,m)}}else{if(n&&n.getData("text")){var l=JSON.parse(n.getData("text")),i=l.data&&l.data.items&&l.data.items.length>0?l.data.items[0]:null;if(i){if(k.dashboardContentCallBack){k.dashboardContentCallBack(i,m)}}}}};c.createDropZone=function(i,j){j.stopPropagation();j.cancelBubble=true;j.preventDefault();if(a!==j.currentTarget){b()}if(f===null){a=j.currentTarget;f=e(this.isDragWithinApp);j.currentTarget.appendChild(f);f.addEventListener("dragover",function(k){k.stopPropagation();k.cancelBubble=true;k.preventDefault()});f.addEventListener("dragleave",c.destroyDropZone.bind(c));f.addEventListener("dragexit",c.destroyDropZone.bind(c));f.addEventListener("drop",c.handleDrop.bind(c,i))}};c.destroyDropZone=function(){this.isDragWithinApp=false;b()};return c});