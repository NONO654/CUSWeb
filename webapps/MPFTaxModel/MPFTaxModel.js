define("DS/MPFTaxModel/MPFTaxAreaModel",["DS/MPFModel/MPFModel"],function(b){var a=b.extend({setup:function(c,d){this._parent(c,d)}});return a});define("DS/MPFTaxModel/MPFTaxAreaDataProxy",["UWA/Core","DS/MPFDataProxy/DataProxy"],function(a,b){var c=b.extend({init:function(d){this._parent(d,"/mdtaxes/taxAreas")},request:function(e,d){return this._parent(e,d)},url:function(d){return this._parent(d)}});return c});define("DS/MPFTaxModel/MPFTaxAreaCollection",["DS/MPFModel/MPFCollection","DS/MPFTaxModel/MPFTaxAreaModel"],function(b,a){var c=b.extend({model:a,setup:function(e,d){this._parent(e,d)},create:function(d,e){e=e||{};return this._parent(d,e)}});return c});