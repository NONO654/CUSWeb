/*
@fullreview CN8 2016:04:20 Creation
*/

define('DS/CSIViewModelComponents/CSIViewModelWebComponent', [
  'DS/CSIViewModelWebProcessor/CSIVMClientManager',
	'DS/CSIViewModelWebInterfaces/CSIVMClientTreeKey',
	'DS/CSIViewModelWebInterfaces/CSIVMClientSelectionObject',
  'DS/WebVisuParameters/WebVisuSceneGraphUpdater'
],

	function (Manager, CSIVMClientTreeKey, CSIVMClientSelectionObject, WebVisuSceneGraphUpdater) {

  'use strict';

  /**
  * @summary ViewModelComponent
  * @desc
  * <p>Component that create the ClientManager and set the 3D view notifier</p>
  * <br><b>Exported by:</b>DS/CSIViewModelWebComponents/CSIViewModelWebComponent
  * @class DS/CSIViewModelWebComponents/CSIViewModelWebComponent
  */
  function CSIViewModelComponent(options) {
  	Object.defineProperty(this, '_options', { 'value': options, 'configurable': false, 'writable': false });
  };

  /**
 * @summary get the client manager notifier.
 * @desc The function get the client manager
 * @memberof DS/CSIViewModelWebComponents/CSIViewModelWebComponent#
 * @return {Object} The client manager, {@link DS/CSIViewModelWebProcessor/CSIVMClientManager}
 */
  CSIViewModelComponent.prototype.getManager = function () {
    return this._manager;
  };

  CSIViewModelComponent.prototype.initialize = function () {
		if (!this._manager) {
			this._manager = Manager.createClientManager();
		}
  	if (!this._manager.getNotifier(CSIVMClientTreeKey.prototype.ViewType.View3D)) {
			var delegateVisu = new WebVisuSceneGraphUpdater();
			this._manager.setNotifier(CSIVMClientTreeKey.prototype.ViewType.View3D, delegateVisu);
		}
		CSIVMClientSelectionObject.prototype._declareType();
    return UWA.Class.Promise.resolve();
  };

  CSIViewModelComponent.prototype.clean = function () {
    return UWA.Class.Promise.resolve();
  };

  CSIViewModelComponent.prototype.destroy = function () {
    this._manager.reload();
    return UWA.Class.Promise.resolve();
  };

  return CSIViewModelComponent;
});
