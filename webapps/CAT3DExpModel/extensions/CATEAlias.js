/**
 * CATEAlias
 * @category Extension
 * @name DS/CAT3DExpModel/extensions/CATEAlias
 * @description Implements {@link DS/CAT3DExpModel/interfaces/CATIAlias CATIAlias}
 * @constructor
 */
define('DS/CAT3DExpModel/extensions/CATEAlias',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl',
    'UWA/Class/Events',
    'UWA/Class/Listener',
],

// Declaration
function (
    UWA,
	CAT3DXInterfaceImpl,
    Events,
    Listener
    ) {
    'use strict';

    var CATEAlias = UWA.Class.extend(CAT3DXInterfaceImpl, Events, Listener,
	/** @lends DS/CAT3DExpModel/extensions/CATEAlias.prototype **/
    {

        Build: function () {
            var self = this;
            this.listenTo(this.QueryInterface('CATI3DExperienceObject'), '_varName.CHANGED', function (iName) {
                self.dispatchEvent('NAME_CHANGED', [iName]);
            });
        },

    	destroy: function () {
    	    this._parent();
    	    this.stopListening();
    	},

        // Interface CATIAlias
		SetAlias: function (iName) {
		    this.QueryInterface('CATI3DExperienceObject').SetValueByName('_varName', iName);
		},

		GetAlias: function () {
		    return this.QueryInterface('CATI3DExperienceObject').GetValueByName('_varName');
		}
	});

    return CATEAlias;
}
);

