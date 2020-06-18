/*!  Copyright 2016 Dassault Systemes. All rights reserved. */
(function(j){var g=j.Polymer,i=j.DS;var n=null,l=null,f=null,t={selectionsChanged:"selectionsChanged",jobEdited:"jobEdited"},m={all:"all",running:"Running",paused:"Paused",completed:"Completed",failed:"Failed",aborted:"Aborted"},p={all:"all",tools:"tool",uploads:"upload",downloads:"download"},s=null,q=null,k=null,d=null,b=null,h=null,a=null,e=null,c=null,u=null,o=null,r=null;n=function(){for(var v=0;v<this.jobInstanceListViews.length;v++){this.jobInstanceListViews[v].jobLogSidepanel=this.jobLogSidepanel}};l=function(x){if(!x.detail.jobInstanceListView){return}var v=this.jobInstanceListViews.indexOf(x.detail.jobInstanceListView);if(!x.detail.ctrlKey&&!x.detail.shiftKey){o.call(this);c.call(this,x.detail.jobInstanceListView);this.lastSelected=v}else{if(x.detail.ctrlKey&&!x.detail.shiftKey){r.call(this,x.detail.jobInstanceListView);this.lastSelected=v}else{if(x.detail.shiftKey){if(!x.detail.ctrlKey){o.call(this)}if(v>this.lastSelected){for(var w=v;w>=this.lastSelected;w--){if(!d(this.jobInstanceListViews[w])){c.call(this,this.jobInstanceListViews[w])}}}else{for(var w=v;w<=this.lastSelected;w++){if(!d(this.jobInstanceListViews[w])){c.call(this,this.jobInstanceListViews[w])}}}}}}this.fire(t.selectionsChanged,{selectedJobInstanceListViews:this.selectedJobInstanceListViews})};f=function(w){var x=w.detail.jobInstanceListView;if(!x){return}var v=this.jobInstanceListViews.indexOf(x);o.call(this);c.call(this,x);this.lastSelected=v;this.fire(t.jobEdited,{selectedJob:x})};s=function(y){var x,w=0;for(x=0;x<this.jobInstanceListViews.length;x++){var z=true;var v=true;if(y.status){z=v=(y.status.indexOf(m.all)>=0)||(y.status.indexOf(this.jobInstanceListViews[x].jobInstance.jobState)>=0)}if(v&&y.type){z=v=(y.type.indexOf(p.all)>=0)||(y.type.indexOf(this.jobInstanceListViews[x].jobInstance.jobType)>=0)}if(v&&y.startAfter){z=v=(y.startAfter<=this.jobInstanceListViews[x].jobInstance.jobStartTime)}if(v&&y.startBefore){z=v=(y.startBefore>=this.jobInstanceListViews[x].jobInstance.jobStartTime)}if(z){q.call(this,this.jobInstanceListViews[x]);w++}else{k.call(this,this.jobInstanceListViews[x]);u.call(this,this.jobInstanceListViews[x])}}this.fire(t.selectionsChanged,{selectedJobInstanceListViews:this.selectedJobInstanceListViews});return w};q=function(v){g.dom(v).classList.remove("hidden")};k=function(v){g.dom(v).classList.add("hidden")};d=function(v){if(g.dom(v).classList.contains("hidden")){return true}else{return false}};b=function(v){v.addEventListener(i.SMAProcADUI.ADJobInstanceListView.EVENTS.select,l.bind(this));v.addEventListener(i.SMAProcADUI.ADJobInstanceListView.EVENTS.edit,f.bind(this));this.jobInstanceListViews.push(v);this.DOM(this.$.list).append(v);this.fire(t.selectionsChanged,{selectedJobInstanceListViews:this.selectedJobInstanceListViews})};h=function(x){var v,w;for(v=0;v<this.jobInstanceListViews.length;v++){w=this.jobInstanceListViews[v];if(w===x){g.dom(g.dom(w).parentNode).removeChild(w);this.jobInstanceListViews.splice(v,1);break}}};a=function(){var v=this.$.list;while(v.hasChildNodes()){g.dom(v).removeChild(g.dom(v).lastChild)}this.jobInstanceListViews.splice(0,this.jobInstanceListViews.length);this.selectedJobInstanceListViews.splice(0,this.selectedJobInstanceListViews.length)};e=function(){var v=this.DOM(this.$.list),w=this.$.list;var x=document.createTextNode("No Jobs have been run");if(w.children.length===0){v.append(x)}};c=function(w){w.selectJob();var v=this.selectedJobInstanceListViews.indexOf(w);if(v===-1){this.selectedJobInstanceListViews.push(w)}};u=function(w){w.unselectJob();var v=this.selectedJobInstanceListViews.indexOf(w);if(v>-1){this.selectedJobInstanceListViews.splice(v,1)}};o=function(){for(var v=0;v<this.selectedJobInstanceListViews.length;v++){this.selectedJobInstanceListViews[v].unselectJob()}this.selectedJobInstanceListViews=[]};r=function(v){if(v.selected){u.call(this,v)}else{c.call(this,v)}};i.SMAProcADUI=i.SMAProcADUI||{};i.SMAProcADUI.ADJobListView=g({is:"ad-job-list-view",properties:{jobInstanceListViews:{type:Array,value:function(){return[]}},jobLogSidepanel:{value:null,observer:"jobLogSidepanelChanged"},lastSelected:{value:function(){return -1}},selectedJobInstanceListViews:{type:Array,value:function(){return[]}}},onSelectJob:function(){return l.apply(this,arguments)},onEditJob:function(){return f.apply(this,arguments)},filterListJobs:function(){return s.apply(this,arguments)},show:function(){return q.apply(this,arguments)},hide:function(){return k.apply(this,arguments)},isHidden:function(){return d.apply(this,arguments)},addJob:function(){return b.apply(this,arguments)},removeJob:function(){return h.apply(this,arguments)},clearJobs:function(){return a.apply(this,arguments)},setNoJobsMessage:function(){return e.apply(this,arguments)},selectJob:function(){return c.apply(this,arguments)},unselectJob:function(){return u.apply(this,arguments)},unselectAll:function(){return o.apply(this,arguments)},switchJob:function(){return r.apply(this,arguments)},jobLogSidepanelChanged:function(){n.call(this)},behaviors:[i.SMAProcSP.SPBase]});i.SMAProcADUI.ADJobListView.EVENTS=i.SMAProcADUI.ADJobListView.EVENTS||t;i.SMAProcADUI.ADJobListView.TYPE_CRITERIA=i.SMAProcADUI.ADJobListView.TYPE_CRITERIA||p;i.SMAProcADUI.ADJobListView.STATUS_CRITERIA=i.SMAProcADUI.ADJobListView.STATUS_CRITERIA||m}(this));