
define('DS/CSIViewModel3DFrame/CSIViewModel3DFrame', ['UWA/Core', 'UWA/Element', 'DS/Core/Core', 'DS/ApplicationFrame/CSIFrameWindow3D',
 'DS/CSIViewModelWebProcessor/CSIVMClientManager', 'DS/CSIViewModelWebInterfaces/CSIVMClientTreeKey', 'DS/WebVisuParameters/WebVisuSceneGraphUpdater'],
 
 function (UWACore, Element, WUXCore, CSIFrameWindow3D, CSIVMClientManager, CSIVMClientTreeKey, WebVisuSceneGraphUpdater) {
  'use strict';
        
  /**
   * Create a CSIFrameWindow3D including a view manager
   *
   * @constructor CSIViewModel3DFrame
   * @alias module:DS/CSIViewModel3DFrame/CSIViewModel3DFrame
   * @augments module:DS/ApplicationFrame/CSIFrameWindow3D
   *
   * @param  {Object} options  see CSIFrameWindow3D
   * @param  {
   *
   */
  var CSIViewModel3DFrame = CSIFrameWindow3D.extend( 
      /**
       * @lends module:DS/CSIViewModel3DFrame/CSIViewModel3DFrame~CSIViewModel3DFrame.prototype
       */
      {
        defaultOptions: {
          uiOptions: {
            displayActionBar: true,
            displayTree: true
          }
        },
				
        init: function (options) {
          options.viewerOptions.newModelIdentification = true;
          if (options.viewerOptions.newModelIdentification && options.uiOptions!=undefined) {
            options.uiOptions.displayTree = false;
          }

          this._parent(options);

          if (options.debug3D === true) {
            var curFrmWindow = this;
            var DebugLoaded = false;
            this.onActionBarReady(function () {
              if (!DebugLoaded) {
                curFrmWindow._actionBar.loadModel({
                  merge: true,
                  file: 'CSI3DWebDebugSection.xml',
                  module: 'CSI3DWebDebugSection',
                  language: 'fr'
                });
                DebugLoaded = true;
              }
            });
          }
          
          if (options.viewerOptions.newModelIdentification) {
            this.cleanCSIManager();
          }
          
        },
				
        getCSIManager : function () {
          return this._clientManager;
        },
				
        setNotifier: function (ViewType, Delegate) {
          if (this._clientManager) {
            this._clientManager.setNotifier(ViewType, Delegate);
            return true;
          }
          return false;
        },
				
        cleanCSIManager: function () {
          var existingMgr = this._clientManager;
          this._clientManager = CSIVMClientManager.createClientManager();
          if (existingMgr !== undefined) {
            var Notif;
            for (var prop in CSIVMClientTreeKey.prototype.ViewType) {
              Notif = existingMgr.getNotifier(CSIVMClientTreeKey.prototype.ViewType[prop]);
              if (Notif !== undefined) {
                this.setNotifier(CSIVMClientTreeKey.prototype.ViewType[prop], Notif);
              }
            }
          }
          else {
            var delegateVisu = new WebVisuSceneGraphUpdater();
            this.setNotifier(CSIVMClientTreeKey.prototype.ViewType.View3D, delegateVisu);
          }
        }
      });
  return UWA.namespace('DS/CSIViewModel3DFrame/CSIViewModel3DFrame', CSIViewModel3DFrame);
});
