define("DS/DELWebMfgAssetsDefDocConnectionModel/DocumentConnectionModel",["UWA/Core","UWA/Class/Model","DS/DELWebMfgAssetsDefModelServices/DocumentUtility","DS/DELWebMfgAssetsDefDocumentModel/DocumentModelUtility"],function(f,e,b,d){var c=e.extend({name:"DocumentConnectionModel",idAttribute:"ID",_modelEvents:{onAdd:function(h,j,g){var i=b.collectionUtils.references.get(h.get("irpcID"));if(f.is(i)){d.appendDocIDsToDisplayModel(i,h.get("docID"))}},onRemove:function(h,j,g){var i=b.collectionUtils.references.get(h.get("irpcID"));if(f.is(i)){d.deleteDocIDsFromDisplayModel(i,h.get("docID"))}}},setup:function a(g,h){this.listenTo(this,this._modelEvents)},});return c});define("DS/DELWebMfgAssetsDefDocConnectionModel/DocumentConnectionCollection",["UWA/Core","UWA/Class/Collection","DS/DELWebMfgAssetsDefDocConnectionModel/DocumentConnectionModel"],function(f,d,c){var b=d.extend({model:c,init:function e(i,h){var g=Array.prototype.slice.call(arguments,0);if(i&&i.data&&!(h&&h.parse)){var j=this.parse(i);g[0]=j}this._parent.apply(this,g)},setup:function a(g,h){if(h){this._objectType=h.objectType}if(!this._dictionary){this._dictionary={}}if(this._objectType){this._dictionary[this._objectType]=this}return this._parent.apply(this,arguments)},});return b});