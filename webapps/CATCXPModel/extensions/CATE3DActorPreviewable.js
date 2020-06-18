/**
 * CATE3DActorPreviewable
*  @category Extension
 * @name DS/CATCXPModel/extensions/CATE3DActorPreviewable
 * @description Implements {@link DS/CAT3DExpModel/interfaces/CATIPreviewable CATIPreviewable}
 * @constructor
 */
define('DS/CATCXPModel/extensions/CATE3DActorPreviewable',
// dependencies
[
    'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl',
    'UWA/Class/Events'
],

function (UWA, CAT3DXInterfaceImpl, Events) {

    'use strict';

    var CATE3DActorPreviewable = UWA.Class.extend(CAT3DXInterfaceImpl, Events,
    /** @lends DS/CATCXPModel/extensions/CATE3DActorPreviewable.prototype **/
    {
        init: function () {
            this._parent();
            this._dirty = true;
            this._PreviewSrc = undefined;
            this._callbackStack = [];
        },

        destroy: function () {
            this._parent();
            this._dirty = false;
            this._PreviewSrc = null;
            this._callbackStack = null;
        },

        /**  
        * @public
        */
        GetPreview: function (iCallback, iCamera, iForceNewRender) {
            var self = this;
            var iCamera = iCamera ? iCamera : null;
            var iForceNewRender = Boolean(iForceNewRender);

            if (iForceNewRender) {
                this._updatePreview(iCallback, iCamera);
                return;
            }

            if (this._dirty) {
                this._callbackStack.push(iCallback);
                if (!this._updatingPreview) {
                    this._updatingPreview = true;
                    this._updatePreview(function (iPreview) {
                        self._PreviewSrc = iPreview;
                        self._executeCallback();
                        self._updatingPreview = false;
                        self._dirty = false;
                    }, iCamera);
                }
            }
            else {
                iCallback(this._PreviewSrc);
            }
        },

        _updatePreview: function (iCallback, iCamera) {
            var previewManager = this.GetObject()._experienceBase.getManager('CAT3DXPreviewManager');
            previewManager.getPreview(this.QueryInterface('CATI3DGeoVisu'), iCallback, iCamera);
        },

        /**  
        * @public
        */
        DirtyPreview: function () {
            this._dirty = true;
            this.dispatchEvent('PreviewDirty');
        },

        _executeCallback: function () {
            while (this._callbackStack.length > 0) {
                this._callbackStack[0](this._PreviewSrc);
                this._callbackStack.splice(0, 1);
            }
        }
    });

    //onPreviewChanged
    return CATE3DActorPreviewable;
});



