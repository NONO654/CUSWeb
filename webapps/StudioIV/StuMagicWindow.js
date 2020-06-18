define('DS/StudioIV/StuMagicWindow', ['DS/StuCore/StuContext', 'DS/StudioIV/StuiVScenario', 'MathematicsES/MathsDef'], function (STU, IVScenario, DSMath) {
    'use strict';

    /**
     * Describes a magic window scenario. <br/>
     * 
     * To use it, you must have the following role: VRS - Marketing Experience Scripter
     *
     * @exports MagicWindow
     * @class 
     * @constructor
     * @noinstancector
     * @public
     * @extends {STU.IVScenario}
     * @memberOf STU
     */
    var MagicWindow = function() { 

        IVScenario.call(this);
        this.name = 'MagicWindow';

        //////////////////////////////////////////////////////////////////////////
        // Properties that should NOT be visible in UI
        ////////////////////////////////////////////////////////////////////////// 

        this._actorTransforRef = null;
        this._positionMetric = null;

        //////////////////////////////////////////////////////////////////////////
        // Properties that should be visible in UI
        //////////////////////////////////////////////////////////////////////////

    };

    MagicWindow.prototype = new IVScenario();
    MagicWindow.prototype.constructor = MagicWindow;
    MagicWindow.prototype.protoId = '76434BFD-456E-4FD7-9F3F-6877AA4AC3D4';

    /**
     * Process executed when STU.MagicWindow is activating
     *
     * @method
     * @private
     */
    MagicWindow.prototype.onActivate = function() {
        IVScenario.prototype.onActivate.call(this);
        this._positionMetric = new DSMath.Vector3D();
    };

    /**
     * Process executed when STU.MagicWindow is deactivating
     *
     * @method
     * @private
     */
    MagicWindow.prototype.onDeactivate = function() {
        IVScenario.prototype.onDeactivate.call(this);
    };


    /**
     * Execute method called each frames
     *
     * @method
     * @private
     */
    MagicWindow.prototype.execute = function() {

        var ivMarker = this._markerTransform;
        var ivMarkerInv = ivMarker.getInverse();

        var markerTransfo = this.marker.getTransform();
        var camTransfo = DSMath.Transformation.multiply(markerTransfo, ivMarkerInv);

        this._ARCamera.setTransform(camTransfo);
    };

    // Expose in STU namespace.
    STU.MagicWindow = MagicWindow;

    return MagicWindow;
});

define('StudioIV/StuMagicWindow', ['DS/StudioIV/StuMagicWindow'], function (MagicWindow) {
    'use strict';

    return MagicWindow;
});
