define("DS/ENOGantt/Data/ResourceStore",["UWA/Class","DS/Foundation2/FoundationV2Data","DS/ENOGantt/Ven/Bryntum"],function(a,d,c){var e;try{e=a.extend({init:function(){Ext.define("DS.ENOGantt.Data.Resource",{extend:"Ext.data.Model",fields:[{name:"Id",mapping:"Id"},{name:"Name",mapping:"Name"},{name:"Username",mapping:"Username"},]});Ext.define("DS.ENOGantt.Data.ResourceStore",{extend:"Ext.data.Store",pageSize:10,model:"DS.ENOGantt.Data.Resource",sendRequest:function(){console.log("==========Working Send Requieset")},proxy:{type:"memory",reader:{type:"json"},},load:function(g){var h=this;var i=g.params.query;var f=Ext.ComponentQuery.query("#dpmprojectgantt")[0];var k=f.crudManager;var j=k.transport.load.url+"&query="+i;d.ajaxRequest({url:j,type:"GET",dataType:"json",callback:function(l){var o=l.data;var s=o[0];if(s.relateddata){var q=s.relateddata.Resources;for(var n=0,m=q.length;n<m;n++){var r=s.relateddata.Resources[n];var p=r.dataelements;h.add(p)}h.commitChanges()}}});this.callParent(arguments)},listeners:{load:function(){console.log("========================ResourceStore Loaded==========");var f=Ext.ComponentQuery.query("#dpmresourceutilizationpanel")[0];var g=f.getResourceStore();this.filterBy(function(h){var i=h.get("Id");i="resource-"+i;var h=g.getModelById(i);if(h!=null){return false}return true})},}})}})}catch(b){console.log(b)}return e});