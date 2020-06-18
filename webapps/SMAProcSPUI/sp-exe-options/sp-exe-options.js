(function(g){var e,i,a,h,l,b,f={STEP:"Step",ACTIVITY:"Activity",SIMULATION:"Simulation"},c=[f.STEP,f.ACTIVITY,f.SIMULATION],k,j={ONCHANGE:"change"};l=function(q){var o,n=0,s,m,p,r=0;o=q.currentTarget;m=o.nextElementSibling.getContentChildren().length-1;p=m*28+o.clientHeight+15;s=this.DOM(this).find('[data-index="'+o.getAttribute("data-target")+'"]').elements()[0];n=this.DOM(this).getCoordinates(o);r=g.innerHeight||document.body.clientHeight||document.documentElement.clientHeight||0;this.DOM(s).addClass("displayFixed");this.DOM(s).removeClass("displayOnTop");s.style.left=n.x+"px";if(r-n.y<p){s.style.bottom=r-n.y+"px";s.style.top="auto"}else{s.style.top=n.y+o.clientHeight+"px";s.style.bottom="auto"}s.visible=true};b=function(p){var m,o,n,q;p=p||g.event;o=p.key;n=["ArrowLeft","ArrowRight","Backspace","Delete","ArrowUp","ArrowDown","Home","End"];q=n.filter(function(r){return r===o});m=q.length>0;m=!m?o==="-"&&p.target.value.indexOf("-")===-1:m;m=!m?!isNaN(o):m;if(!m){p.preventDefault();p.stopPropagation()}};h=function(p){var r,n,q,m,s;r=Polymer.dom(p).localTarget;n=p.model;q=r.value;m=p.currentTarget.id;q=q||n.option.value;s=p.model.option.title;if(n.option.value!==q){this.fire(j.ONCHANGE,{value:this.value})}n.option.value=q;for(var o=0;o<=this.data.length;o+=1){if(this.data[o].id===m){this.set("data."+o+".value",q);break}}if(s==="drmMode"){this.$.exeOptionRepeat.render()}};i=function(n,p,o){var m;if(p.indexOf(n)>-1){m=o[p.indexOf(n)]}else{if(n.search("Information")>-1){m=o[p.indexOf("Information")]}}return m};e=function(n){var m="";if(!n.icon){return m}if(n.icon.indexOf(f.ACTIVITY)>-1){m=f.ACTIVITY}else{if(n.icon.indexOf(f.SIMULATION)>-1){m=f.SIMULATION}else{m=f.STEP}}return m};var d=function(s,q){var n=false,m,r,p={};m=s.indexOf(q)+1;try{for(;s[m]&&c.indexOf(e(s[m]))===-1;m++){r=s[m];if(r.level==="2"&&(r.editableInPS==="true"||r.action!=="hide")){n=true;throw p}}}catch(o){if(o!==p){console.debug("Something went wrong in checkExeOptions");console.warn(o)}}return n};a=function(o){var n,p,m=true;n=e(o);p=o.title_display;switch(n){case f.STEP:p=k+" > "+p;break;case f.ACTIVITY:k=p;break;case f.SIMULATION:break;default:p=""}if(n===f.STEP||n===f.ACTIVITY){m=d(this.data,o);if(!m){p=""}}else{if(n===f.SIMULATION){m=d(this.data,o);if(!m){p="No execution options to configure"}}}return p};Polymer({is:"sp-exe-options",properties:{data:{type:Array,value:function(){return null},notify:true}},showMenu:function(){return l.apply(this,arguments)},onItemSelect:function(){return h.apply(this,arguments)},checkLSFOption:function(r){if(r.title.indexOf("Activity")!==-1&&r.sequence!==undefined){var p;for(p=0;p<this.data.length;p++){if(r.objectId===this.data[p].objectId){break}}var o=parseInt(p);for(;o<this.data.length;o++){var n=this.data[o];if(n.title&&n.title==="drmMode"){this.lsfDRMOption=n.value;break}}}var q=["CosimGroup","JobName","JobGroup","Hosts","CPUs","Resources","BeginTime","EndTime","RunTimeLimit","AdditionalBsubArguments","ExclusiveExecution"];var m=["Group","StationName"];if(q.indexOf(r.title)>-1){if(this.lsfDRMOption==="Lsf"){return true}else{return false}}else{if(m.indexOf(r.title)>-1){if(this.lsfDRMOption==="Lsf"){return false}else{return true}}else{return true}}},filter_choice:function(){return i.apply(this,arguments)},filter_type:function(){return e.apply(this,arguments)},filter_category:function(){return a.apply(this,arguments)},_computeIf:function(m){return m.title!=="Execution"},_computeClass:function(n){var m=this.filter_type(n)+" option level-"+n.level;if(n.editableInPS==="false"&&n.action==="hide"){m+=" is-hidden"}if(n.editableInPS==="false"&&n.action!=="hide"){m+=" is-readonly"}return m},_computeIf2:function(m){return m.syncAssist&&!m.choices},_computeIf3:function(m){return m.syncAssist&&m.choices},_computeDisabled:function(m){return m.editableInPS==="false"},_computeSelected:function(m,n){if(n.choices){return n.choices[m]===n.value}else{return n.value}},_computeType:function(n){var o=["int","integer","real","number"];var m=o.indexOf(n.datatype)>=0;return m?"number":"text"},_computeValue:function(m,n){if(n.choices){return n.choices[m]}else{return n.value}},_computeExpression3:function(m){return m.syncAssist?m.title_display:""},validateInput:function(m){var n;n=m.target.getAttribute("type");if(n==="number"){b(m)}},behaviors:[DS.SMAProcSP.SPBase]})}(this));