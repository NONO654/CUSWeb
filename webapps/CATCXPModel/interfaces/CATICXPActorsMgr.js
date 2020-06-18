/**
 * @exports DS/CATCXPModel/interfaces/CATICXPActorsMgr
*/
define('DS/CATCXPModel/interfaces/CATICXPActorsMgr',
// dependencies
[
	'UWA/Class',
	'DS/WebComponentModeler/CATWebInterface'
],

function (
	UWA,
	CATWebInterface) {
	'use strict';

	/**
	* @category Interface
	* @name DS/CATCXPModel/interfaces/CATICXPActorsMgr
	* @interface
	* @description 
	* Interface to manage sub actors of the component.
	*/

	var CATICXPActorsMgr = CATWebInterface.singleton(
	/** @lends DS/CATCXPModel/interfaces/CATICXPActorsMgr.prototype **/
	{
		interfaceName: 'CATICXPActorsMgr',

		/**
		* required methods 
		* @lends DS/CATCXPModel/interfaces/CATICXPActorsMgr.prototype
		*/
		required: {

			/**
			* Create an actor and add it as a sub actor.
			* @public
			* @param {String} actorName - the actor name
			* @param {String} prototype - name of the actor prototype to create
			* @param {Object} createdActor - the created actor
			*/
			CreateAndAddActor: function (iActorName, iProto) {
			},

			/**
			* List sub actors
			* @public
			* @param {Object[]} actors - sub actors array
			*/
			ListActors: function (oActorsList) {
			},

			/**
			* Remove a sub actor
			* @public
			* @param {Object} actor - the actor to remove
			*/
			RemoveActor: function (iActor) {
			},

			/**
			* Add a sub actor
			* @public
			* @param {Object} actor - the actor to add
			*/
			AddActor: function (iActor) {
			},

			/**
			* Count sub actors
			* @public
			* @param {int} count - count of sub actors
			*/
			Count: function (oCount) {
			}
		},

		optional: {

		}
	});

	return CATICXPActorsMgr;
});
