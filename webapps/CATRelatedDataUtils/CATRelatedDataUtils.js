/*!  Copyright 2014 Dassault Systemes. All rights reserved. */
define("DS/CATRelatedDataUtils/CATRelatedDataTransientWidget",["UWA/Class","DS/TransientWidget/TransientWidget"],function(b,a){var c=b.extend({init:function(d){var d=d||{};this._parent(d);this.showWidget=function(e){if(e.length){a.showWidget(e)}else{a.showWidget(e.id,e.title,e.data)}}}});return c});define("DS/CATRelatedDataUtils/CATRelatedDataUtils",[],function(){});