/**
 * CATECXPBehaviorsMgr
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATECXPBehaviorsMgr
 * @description Implements {@link DS/CATCXPModel/interfaces/CATICXPBehaviorsMgr CATICXPBehaviorsMgr}
 * @constructor
 */

define('DS/CATCXPModel/extensions/CATECXPBehaviorsMgr',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl',
    'DS/CAT3DExpModel/CAT3DXModel',
    'UWA/Class/Events',
    'UWA/Class/Listener',
],

// Declaration
function (
    UWA,
	CAT3DXInterfaceImpl,
    CAT3DXModel,
    Events,
    Listener
    ) {
    'use strict';

    var CATECXPBehaviorsMgr = UWA.Class.extend(CAT3DXInterfaceImpl, Events, Listener,
	/** @lends DS/CATCXPModel/extensions/CATECXPBehaviorsMgr.prototype **/
    {
    	init: function () {
    		this._parent();
    	},

    	destroy: function () {
    	    this._parent();
    	    this.stopListening();
    	},


		Build: function () {
			var self = this;
			this.listenTo(this.QueryInterface('CATI3DExperienceObject'), 'behaviors.CHANGED', function (iBehaviors) {
				self.dispatchEvent('BEHAVIORS.CHANGED', [iBehaviors]);
			});
		},

        // interface CATICXPBehaviorsMgr
        /**  
        * @public
        */
		ListBehaviors: function (oBehaviorsList) {
		    if (!(oBehaviorsList instanceof Array)) {
		        console.log('CATECXPBehaviorsMgr.ListBehaviors ERROR : unable to fill parameters, not an array !');
		        return;
		    }

		    oBehaviorsList.length = 0;
		    var ExpObj = this.QueryInterface('CATI3DExperienceObject');
		    var behaviors = ExpObj.GetValueByName('behaviors');

		    for (var i = 0; i < behaviors.length;i++) {
		        oBehaviorsList.push(behaviors[i]);
		    }
		},

        /**  
        * @public
        */
		RemoveBehavior: function (iBehavior) {
		    return CAT3DXModel.DeleteBehavior(iBehavior);
		},

		CreateAndAddBehavior: function (iBehaviorName, iProto) {
		    return CAT3DXModel.CreateBehavior(iProto, iBehaviorName, this.GetObject());
		},

        /**  
        * @public
        */
		AddBehavior: function (iBehavior) {
		    var ExpObj = this.QueryInterface('CATI3DExperienceObject');
		    var behaviors = ExpObj.GetValueByName('behaviors');
		    behaviors.push(iBehavior);
		    ExpObj.SetValueByName('behaviors', behaviors); //activate listener
		}
	});

    return CATECXPBehaviorsMgr;
});

