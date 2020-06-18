define("DS/DELWebMfgAssetsDefIndexServices/IndexParserNode",["UWA/Core","UWA/Class"],function(c,a){var b=a.extend({init:function(d){var e=this;this._children=[];this._result=d;this._result.attributes.forEach(function(g){var f=g.name,h;if(!c.is(e[f])){e[f]=g}else{if(c.is(e[f].value,"string")){h=e[f].value;e[f].value=[h,g.value]}else{if(c.is(e[f].value,"array")){e[f].value.push(g.value)}}}})},getAttribute:function(d){if(this.hasOwnProperty(d)){return this[d]}},getAttributeValue:function(e){var d=this.getAttribute(e);if(d){return d.value}},addChild:function(d){if(this._children.indexOf(d)===-1){this._children.push(d)}},getChildren:function(){return this._children},getRawResult:function(){return this._result}});return b});define("DS/DELWebMfgAssetsDefIndexServices/IndexParser",["UWA/Core","UWA/Class","DS/Logger/Logger","DS/DELWebMfgAssetsDefIndexServices/IndexParserNode",],function(g,c,b,f){var a=c.singleton({parseNavigateResult:function e(l){var h=null,k={},i=[];if(typeof l==="string"){h=JSON.parse(l)}else{if(typeof l==="object"&&l!==null){h=l}}if(g.is(h)&&g.is(h.results,"array")){h.results.forEach(function j(n){var r,o,m,q,s,p;if(n.hasOwnProperty("attributes")){r=new f(n);o=r.getAttributeValue("did");k[o]=r}else{if(n.hasOwnProperty("path")){for(q=0;q<n.path.length;q++){s=n.path[q];p=k[s];if(!g.is(p)){throw new Error("Result corruption : did not found "+s)}else{if(q===0){if(i.indexOf(p)===-1){i.push(p)}m=p}else{m.addChild(p);m=p}}}}else{throw new Error("Unsupported element "+n)}}})}return i},parseFetchResult:function d(j){var h={attributes:{},ds6w:{}};if(g.is(j)){if(g.is(j.attributes,"array")){j.attributes.forEach(function i(k){var l;if(g.is(k)&&g.is(k.format,"string")){switch(k.format){case"attribute":if(!g.is(h.attributes[k.name])){h.attributes[k.name]=k.value}else{if(g.is(h.attributes[k.name],"string")){l=h.attributes[k.name];h.attributes[k.name]=[l,k.value]}else{if(g.is(h.attributes[k.name],"array")){h.attributes[k.name].push(k.value)}}}break;case"ds6w_facet":h.ds6w[k.name]={value:k.value,dispValue:k.dispValue,type:k.type};break;default:break}}})}}return h}});return a});