/**
 * CATECXPActorsMgr
 * @category Extension
 * @name DS/CATCXPModel/extensions/CATECXPActorsMgr
 * @description Implements {@link DS/CATCXPModel/interfaces/CATICXPActorsMgr CATICXPActorsMgr}
 * @constructor
 */

define('DS/CATCXPModel/extensions/CATECXPActorsMgr',
// dependencies
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl',
	'DS/CAT3DExpModel/CAT3DXModel',
    'UWA/Class/Events',
    'UWA/Class/Listener',
],
function (
	UWA,
	CAT3DXInterfaceImpl,
	CAT3DXModel,
	Events,
    Listener
    ) {
	'use strict';

	var CATECXPActorsMgr = UWA.Class.extend(CAT3DXInterfaceImpl, Events, Listener,
	/** @lends DS/CATCXPModel/extensions/CATECXPActorsMgr.prototype **/
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
			this.listenTo(this.QueryInterface('CATI3DExperienceObject'), 'actors.CHANGED', function (iActors) {
				self.dispatchEvent('ACTORS.CHANGED', [iActors]);
			});
		},

		/**  
		* @public
		*/
		CreateAndAddActor: function (iActorName, iProto) {
			return CAT3DXModel.CreateActor(iProto, iActorName, this.GetObject());
		},

		/**  
		* @public
		*/
		ListActors: function (oActorsList) {
			var experienceObject = this.QueryInterface('CATI3DExperienceObject');
			var actors = experienceObject.GetValueByName('actors');

			if (!(oActorsList instanceof Array)) {
			    UWA.log('StuInstanceExperienceObject.ListActors ERROR : unable to fill parameters, not an array !');
				return;
			}
			oActorsList.splice(0, oActorsList.length);
			oActorsList.length = actors.length;
			var i = actors.length;
			while (i--) { oActorsList[i] = actors[i]; }
		},

		/**  
		* @public
		*/
		RemoveActor: function (iActor) {
		    return CAT3DXModel.DeleteActor(iActor);
		},

		/**  
		* @public
		*/
		AddActor: function (iActor) {
			var experienceObject = this.QueryInterface('CATI3DExperienceObject');
			var actors = experienceObject.GetValueByName('actors');

			actors.push(iActor);
			experienceObject.SetValueByName('actors', actors);
		},

		/**  
		* @public
		*/
		Count: function () {
			var experienceObject = this.QueryInterface('CATI3DExperienceObject');
			var actors = experienceObject.GetValueByName('actors');

			return actors.length;
		}
	});

	return CATECXPActorsMgr;
});



