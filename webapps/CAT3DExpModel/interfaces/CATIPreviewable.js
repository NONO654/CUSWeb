/**
 * @exports DS/CAT3DExpModel/interfaces/CATIPreviewable
*/
define('DS/CAT3DExpModel/interfaces/CATIPreviewable',
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
	* @name DS/CAT3DExpModel/interfaces/CATIPreviewable
    * @interface
	* @description 
    * Interface to manage preview of component representation.
	*/

	var CATIPreviewable = CATWebInterface.singleton(
    /** @lends DS/CAT3DExpModel/interfaces/CATIPreviewable.prototype **/
    {

        interfaceName: 'CATIPreviewable',

        /**
        * required methods 
        * @lends DS/CAT3DExpModel/interfaces/CATIPreviewable.prototype
        */
        required: {
            /**
            * Get preview
            * @public
            * @param {function(source)} iCallback - callback executed when preview is done, getting the source argument as a base64 image or an url to fill a <i>src</i> attribute of an img tag
            * @param {Object} iCamera - viewpoint to use for the preview
            * @param {boolean} iForceNewRender - true to force render on the renderManager, false otherwise
            */
            GetPreview: function (iCallback, iCamera, iForceNewRender) {
                console.log("interface using these variables : " + iCallback + iCamera + iForceNewRender);
            },

            /**
            * Dispatch 'PreviewDirty' event.
            * @public
            */
            DirtyPreview: function () {
            }
        },

        optional: {

        }
    });

	return CATIPreviewable;
});
