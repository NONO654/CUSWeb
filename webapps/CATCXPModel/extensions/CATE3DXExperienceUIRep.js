/**
 * CATE3DXExperienceUIRep
*  @category Extension
 * @name DS/CATCXPModel/extensions/CATE3DXExperienceUIRep
 * @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DXUIRep CATI3DXUIRep}
 * @constructor
 */

define('DS/CATCXPModel/extensions/CATE3DXExperienceUIRep',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl',
	'UWA/Class/Listener',
	'DS/Core/Events'
],

// Declaration
function (
    UWA,
	CAT3DXInterfaceImpl,
	Listener,
	WUXEvent
    ) {
	'use strict';

	var CATE3DXExperienceUIRep = CAT3DXInterfaceImpl.extend(Listener,
	/** @lends DS/CATCXPModel/extensions/CATE3DXExperienceUIRep.prototype **/
    {

    	init: function () {
    		this._parent();
    		this._experienceUIRep = null;
    		this.frameUIChanges = [];
    	},

    	destroy: function () {
    	    this._parent();
    	    this.stopListening();

    	    this._experienceUIRep = null;
    	    this.frameUIChanges = [];
    	},

    	// --- Interface CATE3DXExperienceUIRep
    	_Create: function () {
    		var self = this;

    		var rep = UWA.createElement('div');
    		rep.style.position = 'absolute';
    		rep.style.left = '0px';
    		rep.style.right = '0px';
    		rep.style.top = '0px';
    		rep.style.bottom = '0px';
    		rep.style.pointerEvents = 'none';

    		this.listenTo(this.QueryInterface('CATI3DExperienceObject'), 'actors.CHANGED', function () {
    			self.frameUIChanges.push(self._addUIChildren);
    			self.RequestUIRefresh();
    		});

    		this.frameUIChanges.push(this._addUIChildren);
    		this.RequestUIRefresh();

    		return rep;
    	},

    	Refresh: function () {
    		for (var i = 0; i < this.frameUIChanges.length; ++i) {
    			this.frameUIChanges[i].call(this);
    		}
    		this.frameUIChanges.length = 0;
    	},

    	RequestUIRefresh: function () {
    		// notify VisuManager
    		var iUIRep = this.GetObject().QueryInterface('CATI3DXUIRep');
    		if (UWA.is(iUIRep)) {
    			WUXEvent.publish({
    				event: 'STU_UI_CHANGED',
    				data: {
    					CATI3DXUIRep: iUIRep
    				}
    			});
    		}
    	},

    	_addUIChildren: function () {
    		while (this._experienceUIRep.firstChild) {
    			this._experienceUIRep.firstChild.remove();
    		}

    		var subActors = this.QueryInterface('CATI3DExperienceObject').GetValueByName('actors');
    		for (var i = 0; i < subActors.length; i++) {
    			var uiRep = subActors[i].QueryInterface('CATI3DXUIRep');
    			if (UWA.is(uiRep)) {
    				var child = uiRep.Get();
    				child.inject(this._experienceUIRep);
    			}
    		}
    	},


    	/**  
        * @public
        */
    	Get: function () {
    		if (this._experienceUIRep === null) {
    			this._experienceUIRep = this._Create();
    		}
    		return this._experienceUIRep;
    	},

    	Show: function () {
    		this.Get().show();
    		var subActors = this.QueryInterface('CATI3DExperienceObject').GetValueByName('actors');
    		for (var i = 0; i < subActors.length; i++) {
    			var uiRep = subActors[i].QueryInterface('CATI3DXUIRep');
    			if (UWA.is(uiRep)) {
    				uiRep.Show();
    			}
    		}
    	},

    	Hide: function () {
    		this.Get().hide();
    		var subActors = this.QueryInterface('CATI3DExperienceObject').GetValueByName('actors');
    		for (var i = 0; i < subActors.length; i++) {
    			var uiRep = subActors[i].QueryInterface('CATI3DXUIRep');
    			if (UWA.is(uiRep)) {
    				uiRep.Hide();
    			}
    		}
    	}
    });

	return CATE3DXExperienceUIRep;
}
);

