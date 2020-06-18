define('DS/StudioIV/StuMagicMirror', ['DS/StuCore/StuContext', 'DS/StudioIV/StuiVScenario', 'MathematicsES/MathsDef'], function (STU, IVScenario, DSMath) {
	'use strict';

	/**
	 * Describes a magic mirror scenario. <br/>
	 * 
	 * To use it, you must have the following role: VRS - Marketing Experience Scripter
	 *
	 * @exports MagicMirror
	 * @class 
	 * @constructor
	 * @noinstancector
	 * @public
	 * @extends {STU.IVScenario}
	 * @memberOf STU
	 * @alias STU.MagicMirror
	 */
	var MagicMirror = function() {

		IVScenario.call(this);
		this.name = 'MagicMirror';


		//////////////////////////////////////////////////////////////////////////
		// Properties that should be visible in UI
		//////////////////////////////////////////////////////////////////////////

		this._mirrorMarker = false;
		Object.defineProperty(this, 'mirrorMarker', {
			enumerable: true,
			configurable: true,
			get: function() {
				if (!!this._iVSUI) {
					return (this._iVSUI.getMirrorState() === 1);
				}

				return false;
			},
			set: function(iMirrorMarker) {
				if (!!this._iVSUI) {
					if (iMirrorMarker === true) {
						this._iVSUI.setMirrorState(1);
					} else {
						this._iVSUI.setMirrorState(0);
					}
				}
				this._mirrorMarker = iMirrorMarker;
			}
		});

	};

	MagicMirror.prototype = new IVScenario();
	MagicMirror.prototype.constructor = MagicMirror;
	MagicMirror.prototype.protoId = '78087273-C5FB-4379-AFF7-B73D471D09B0';

	/**
	 * Process executed when STU.MagicMirror is activating
	 *
	 * @method
	 * @private
	 */
	MagicMirror.prototype.onActivate = function() {
		IVScenario.prototype.onActivate.call(this);

		//Force state refresh 
		this.mirrorMarker = this._mirrorMarker;
	};

	/**
	 * Process executed when STU.MagicMirror is deactivating
	 *
	 * @method
	 * @private
	 */
	MagicMirror.prototype.onDeactivate = function() {
		IVScenario.prototype.onDeactivate.call(this);
	};


	/**
	 * Execute method called each frames
	 *
	 * @method
	 * @private
	 */
	MagicMirror.prototype.execute = function() {
		if (this.marker === undefined || this.marker === null || !(this.marker instanceof STU.Actor3D)) {
			throw new TypeError('magicActor must reference a 3D Actor');
		}

		var cameraTransform = this._ARCamera.getTransform();
		var ivTransform = this._markerTransform;

		if(this._mirrorMarker === true) {
			{
				var vec = ivTransform.matrix.getSecondColumn();
				vec.multiplyScalar(-1);
				ivTransform.matrix.setSecondColumn(vec);
				ivTransform.multiplyByEuler([Math.PI, 0, 0], true);
			}
			{
				var vec = cameraTransform.matrix.getSecondColumn();
				vec.multiplyScalar(-1);
				cameraTransform.matrix.setSecondColumn(vec);
			}
		}
	
		var markerTransform = DSMath.Transformation.multiply(cameraTransform, ivTransform);
		this.marker.setTransform(markerTransform);

		return this;
	};

	// Expose in STU namespace.
	STU.MagicMirror = MagicMirror;

	return MagicMirror;
});

define('StudioIV/StuMagicMirror', ['DS/StudioIV/StuMagicMirror'], function (MagicMirror) {
    'use strict';

    return MagicMirror;
});
