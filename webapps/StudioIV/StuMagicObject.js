define('DS/StudioIV/StuMagicObject', ['DS/StuCore/StuContext', 'DS/StudioIV/StuiVScenario', 'MathematicsES/MathsDef'], function (STU, IVScenario, DSMath) {
    'use strict';

    /**
     * Describes a magic object scenario. <br/>
     * 
     * To use it, you must have the following role: VRS - Marketing Experience Scripter
     *
     * @exports MagicObject
     * @class 
     * @constructor
     * @noinstancector
     * @public
     * @extends {STU.IVScenario}
     * @memberOf STU
     * @alias STU.MagicObject
     */
    var MagicObject = function() {

        IVScenario.call(this);
        this.name = 'MagicObject';

        //////////////////////////////////////////////////////////////////////////
        // Properties that should NOT be visible in UI
        ////////////////////////////////////////////////////////////////////////// 

        this._camTransfoRef = null;

        this._skipFrames = 20;

        this._skipFramesCpt = 0;

        //////////////////////////////////////////////////////////////////////////
        // Properties that should be visible in UI
        //////////////////////////////////////////////////////////////////////////



    };

    MagicObject.prototype = new IVScenario();
    MagicObject.prototype.constructor = MagicObject;
    MagicObject.prototype.protoId = '8234C5FC-7AA4-44EA-BB73-0F5F2B26D443';

    /**
     * Process executed when STU.MagicObject is activating
     *
     * @method
     * @private
     */
    MagicObject.prototype.onActivate = function() {
        IVScenario.prototype.onActivate.call(this);

        this._skipFramesCpt = this._skipFrames;
    };

    /**
     * Process executed when STU.MagicObject is deactivating
     *
     * @method
     * @private
     */
    MagicObject.prototype.onDeactivate = function() {
        IVScenario.prototype.onDeactivate.call(this);
    };


    /**
     * Execute method called each frames
     *
     * @method
     * @private
     */
    MagicObject.prototype.execute = function() {
        if (this.marker === undefined || this.marker === null || !(this.marker instanceof STU.Actor3D)) {
            throw new TypeError('magicActor must reference a 3D Actor');
        }

        if (this._skipFramesCpt > 0) {
            this._skipFramesCpt--;
            return this;
        }

        if (this._camTransfoRef === undefined || this._camTransfoRef === null) {
            var ivMarker = this._markerTransform;
            var ivMarkerInv = ivMarker.getInverse();

            var markerTransfo = this.marker.getTransform();
            var camTransfo = DSMath.Transformation.multiply(markerTransfo, ivMarkerInv);

            this._ARCamera.setTransform(camTransfo);

            //save cam transfo
            this._camTransfoRef = camTransfo;
        }

        var markerTransfo = DSMath.Transformation.multiply(this._camTransfoRef, this._markerTransform);
        this.marker.setTransform(markerTransfo);

        return this;
    };

    // Expose in STU namespace.
    STU.MagicObject = MagicObject;

    return MagicObject;
});

define('StudioIV/StuMagicObject', ['DS/StudioIV/StuMagicObject'], function (MagicObject) {
    'use strict';

    return MagicObject;
});
