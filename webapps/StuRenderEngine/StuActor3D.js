/*
* * @quickReview IBS 18:11:26 IBS getBoundingSphere with iRef
* * @quickReview IBS 18:02:01 correction API GetMaterial
* * @quickReview IBS 18:08:11 cleanup API pour passer par objets STUMaterial (CATECXPMaterial_StuIBuilder, CATEPrototypeBuildCXPMaterial) 
* * @quickReview IBS 17:07:24 méthodes pour modifier materials en cours de play (StuMaterialsManager)
* * @quickReview IBS 17:04:21 RenderManager fonctionne en repère world
*						+ gestion scaling globe
*/

define('DS/StuRenderEngine/StuActor3D', ['DS/StuCore/StuContext', 'DS/StuModel/StuActor', 'MathematicsES/MathsDef', 'DS/StuClickable/StuClickableManager',
    'DS/StuRenderEngine/StuMaterialsManager', 'DS/StuMath/StuBox', 'DS/StuRenderEngine/StuColor'],
    function (STU, Actor, DSMath, ClickableManager,StuMaterialsManagerJS, Box ) {
    'use strict';

	/**
	 * Describe a STU.Actor which represents a 3D object with a position, an orientation and a scale in the 3D space. 
	 * These information can be evaluated with one matrix transformation.
	 * This class provides the possibility to interact and manipulate them through different kind of APIs.
	 * This object can have a geometric representation which is required by some specific STU.Behavior.
	 *
	 * @exports Actor3D
	 * @class
	 * @constructor
	 * @noinstancector
	 * @public
	 * @extends STU.Actor
	 * @memberof STU
	 * @alias STU.Actor3D
	 */
	var Actor3D = function() {

		Actor.call(this);

		this.CATI3DExperienceObject;
		this.CATIMovable;
		this.CATI3DXGraphicalProperties;
		this.CATI3DGeoVisu;
		this.StuIRepresentation;

		/**
		 * Whether this STU.Actor3D responds to a click.
		 *
		 * @member
		 * @instance
		 * @name clickable
		 * @public
		 * @type {boolean}
		 * @memberOf STU.Actor3D
		 */
		Object.defineProperty(this, 'clickable', {
			enumerable: true,
			configurable: true,
			get: function() {
				if (this.CATI3DXGraphicalProperties !== null && this.CATI3DXGraphicalProperties !== undefined){
					return this.CATI3DXGraphicalProperties.GetPickMode();
				} else {
					return false;
				}
			},
			set: function(iClickable) {
				if (iClickable != 0 && iClickable != 1) {
					throw new TypeError('iClickable argument is not a boolean');
				}

				if (iClickable === true) {
					STU.ClickableManager.getInstance().addClickable(this);
				} else {
					STU.ClickableManager.getInstance().removeClickable(this);
				}

				if (this.CATI3DXGraphicalProperties !== null && this.CATI3DXGraphicalProperties !== undefined){
					this.CATI3DXGraphicalProperties.SetPickMode(iClickable == 1);
				}
			}
		});


		/**
		 * Whether this STU.Actor3D is visible.
		 *
		 * @member
		 * @instance
		 * @name visible
		 * @public
		 * @type {boolean}
		 * @memberOf STU.Actor3D
		 */
		Object.defineProperty(this, 'visible', {
			enumerable: true,
			configurable: true,
			get: function() {
				if (this.CATI3DXGraphicalProperties !== null && this.CATI3DXGraphicalProperties !== undefined){
					return this.CATI3DXGraphicalProperties.GetShowMode();
				} else {
					return false;
				}
			},
			set: function(iVisible) {
				if (iVisible != 1 && iVisible != 0) {
					throw new TypeError('iVisible argument is not a boolean');
				}

				if (this.CATI3DXGraphicalProperties !== null && this.CATI3DXGraphicalProperties !== undefined){
					this.CATI3DXGraphicalProperties.SetShowMode(iVisible == 1);
				}
			}
		});


		/**
		 * The opacity level of this STU.Actor3D.
		 * The value must be included between 0 and 255.
		 *
		 * @member
		 * @instance
		 * @name opacity
		 * @public
		 * @type {number}
		 * @memberOf STU.Actor3D
		 */
		Object.defineProperty(this, 'opacity', {
			enumerable: true,
			configurable: true,
			get: function() {
				if (this.CATI3DXGraphicalProperties !== null && this.CATI3DXGraphicalProperties !== undefined){
					return this.CATI3DXGraphicalProperties.GetOpacity();
				} else {
					return 0;
				}
			},
			set: function(iOpacity) {
				if (typeof iOpacity !== 'number') {
					throw new TypeError('iOpacity argument is not a number');
				}

				if (iOpacity < 0 || iOpacity > 255) {
					throw new RangeError('iOpacity argument is outside of the pixel value range 0-255');
				}

				if (this.CATI3DXGraphicalProperties !== null && this.CATI3DXGraphicalProperties !== undefined){
					this.CATI3DXGraphicalProperties.SetOpacity(iOpacity);
				}
			}
		});


		/**
		 * The color of this STU.Actor3D.
		 *
		 * @member
		 * @instance
		 * @name color
		 * @public
		 * @type {STU.Color}
		 * @memberOf STU.Actor3D
		 */
		Object.defineProperty(this, 'color', {
			enumerable: true,
			configurable: true,
			get: function() {
				if (!!this.CATI3DXGraphicalProperties){
					return new STU.Color(this.CATI3DXGraphicalProperties.GetRed(), this.CATI3DXGraphicalProperties.GetGreen(), this.CATI3DXGraphicalProperties.GetBlue());
				} else {
					return new STU.Color(0, 0, 0);
				}
			},
			set: function(iColor) {
				var color;

				if(iColor instanceof STU.Color){
					color = [iColor.getRed(), iColor.getGreen(), iColor.getBlue()];
				}
				else if(Array.isArray(iColor) && iColor.length >= 3 ){
					color = iColor;
				}
				else{
					throw new TypeError('iColor argument is not a STU.Color');
				}

				if (!!this.CATI3DXGraphicalProperties) {
					this.CATI3DXGraphicalProperties.SetColor(color[0], color[1], color[2]);
				}
			}
		});
	};

	Actor3D.prototype = new Actor();
	Actor3D.prototype.constructor = Actor3D;

	var _ArrayBuffer = null;// new Float64Array(12);
    
	Actor3D.prototype.getLocation = function () {
	    var ancestor = this.getParent();
	    if (ancestor !== undefined && ancestor !== null && (ancestor instanceof Actor3D)) {
	    	return ancestor.getLocation();
		} else {
	    	return null;
	    }
	};

    // IBS TODO :
    // dans getTransform / setTransform
    // il faut distinguer 2 repères "World" différents
    // le repère root Visu, dans lequel l'expérience peut avoir une position (scaling 1/1000 pour globe)
    // le repère root Experience
    // les behaviors travaillant dans la visu (picking, followMouse) utilise le repère RootVisu
    // les behaviors ne s'appuyant pas sur des données issues de la visu (mimic, rotate) utilisent le repère RootExperience
    // RootExperience == RootVisu si il n'y a pas de globe.

	/**
	 * Returns the matrix transformation of this STU.Actor3D.
	 * By default, the function uses the world referential.
	 *
	 * @method
	 * @public
	 * @param {STU.Actor3D} [iRef] STU.Actor3D corresponding to the referential.
	 * @return {DSMath.Transformation} the matrix transformation.
	 * @see STU.Actor3D#setTransform
	 */
	Actor3D.prototype.getTransform = function (iRef) {

	    // IBS pour globe
	    var refWorldTransform = new DSMath.Transformation();

	    if (iRef === undefined || iRef === null || iRef === "Location") {
	        var myLoc = this.getLocation();
	        if (myLoc !== undefined && myLoc !== null) {
	            return this.getTransform(myLoc);
			} else { // on demande la position scene mais on ne trouve pas de scene => scene=world
	            iRef = "World";
	        }
	    }
	    // position world = position par rapport au root de l'experience
        // le root de l'experience peut être scalé par rapport au root de la visu (globe)
	    if (iRef === "World") {
	        var expScale = STU.RenderManager.getInstance().getExperienceScaleFactor();
	        refWorldTransform = DSMath.Transformation.makeScaling(expScale, new DSMath.Point(0, 0, 0));
	        iRef = null;
	    }
	    // position visu = position par rapport au root de la visu
	    // le root de l'experience peut être scalé par rapport au root de la visu (globe)
	    if (iRef === "Visu") {
	        refWorldTransform = DSMath.Transformation.makeScaling(1.0, new DSMath.Point(0, 0, 0));
	        iRef = null;
	    }

	   var outputTransform = new DSMath.Transformation();

		if (STU.isEKIntegrationActive()) {
		    outputTransform = this.getTransform_NoBinding(iRef);
		} else {
			if (this.CATIMovable !== undefined && this.CATIMovable !== null) {
				if (_ArrayBuffer === null) {
                    _ArrayBuffer = new Float64Array(12);
                    this.CATIMovable.ExternalizeArray(_ArrayBuffer);
                }
			    // ça c'est un cas particulier, mais on obtiendrait le mm resultat avec le calcul fait dans le cas
			    // général (iRef !== undefined && iRef !== null)
			    if (iRef === this.getParent()) {
			        this.CATIMovable.GetLocalPosition();
					outputTransform.setFromArray(_ArrayBuffer);
			        return outputTransform;
			    }

			    var myWorldTransform = new DSMath.Transformation();
			    this.CATIMovable.GetAbsPosition();
				myWorldTransform.setFromArray(_ArrayBuffer);
			    // myWorldTransform est la transfo telle que :
			    // Pt_DéfiniDansMonrepere.applyTransformation(myWorldTransform) == Pt_DéfiniDansLeRepereMonde

			    if(iRef !== undefined && iRef !== null) {
                    // quelle est ma position dans le referrentiel de iRef ?
			        iRef.CATIMovable.GetAbsPosition();
					refWorldTransform.setFromArray(_ArrayBuffer);
			        // refWorldTransform est la transfo telle que :
			        // Pt_DéfiniDansRepereiRef.applyTransformation(refWorldTransform) == Pt_DéfiniDansLeRepereMonde

			        var invRefWorldTransform = refWorldTransform.getInverse();
			        // invRefWorldTransform est la transfo telle que :
			        // Pt_DéfiniDansRepereMonde.applyTransformation(invRefWorldTransform) == Pt_DéfiniDansRepereiRef

			        var myPosRelToRefIniRef = invRefWorldTransform.multiply(myWorldTransform);

			        // en fait ici on s'en fout de la scene.
			        // si je veux ma position par rapport à l'objet iRef dans le repere scene, je fait simplement :
			        // Moi.getPosition("Location") - iRef.getPosition("Location")
			        //
			        // ici je veux retourner ma position dans le repère de iRef, la scène n'intervient pa
			        outputTransform = myPosRelToRefIniRef;
				} else { // iRef === null
			        var invRefWorldTransform = refWorldTransform.getInverse();
			        var myPosRelToRefIniRef = invRefWorldTransform.multiply(myWorldTransform);
			        outputTransform = myPosRelToRefIniRef;
			    } 
		    }
		}
		return outputTransform;
	};


    var _arrayToBuffer = function (array) {
        _ArrayBuffer[0] = array[0]; _ArrayBuffer[1]  = array[1];  _ArrayBuffer[2]  = array[2];
        _ArrayBuffer[3] = array[3]; _ArrayBuffer[4]  = array[4];  _ArrayBuffer[5]  = array[5];
        _ArrayBuffer[6] = array[6]; _ArrayBuffer[7]  = array[7];  _ArrayBuffer[8]  = array[8];
        _ArrayBuffer[9] = array[9]; _ArrayBuffer[10] = array[10]; _ArrayBuffer[11] = array[11];
    };
    
    // IBS TODO :
    // dans getTransform / setTransform
    // il faut distinguer 2 repères "World" différents
    // le repère root Visu, dans lequel l'expérience peut avoir une position (scaling 1/1000 pour globe)
    // le repère root Experience
    // les behaviors travaillant dans la visu (picking, followMouse) utilise le repère RootVisu
    // les behaviors ne s'appuyant pas sur des données issues de la visu (mimic, rotate) utilisent le repère RootExperience
    // RootExperience == RootVisu si il n'y a pas de globe.

	/**
	 * Sets a new matrix transformation for this STU.Actor3D.
	 * By default, the function uses the world referential.
	 *
	 * @method
	 * @public
	 * @param {DSMath.Transformation} iTransform Matrix transformation.
	 * @param {STU.Actor3D} [iRef] Actor3D corresponding to the referential.
	 * @see STU.Actor3D#getTransform
	 */
	Actor3D.prototype.setTransform = function (iTransform, iRef) { 
	    // IBS pour globe
	    var refWorldTransform = new DSMath.Transformation();

	    if (iRef === undefined || iRef === null || iRef === "Location") {
	        var myLoc = this.getLocation();
	        if (myLoc !== undefined && myLoc !== null) {
	            //return this.setTransform(iTransform, myLoc);
	            return Actor3D.prototype.setTransform.call(this, iTransform, myLoc);
			} else { // on demande la position scene mais on ne trouve pas de scene => scene=world
	            iRef = "World";
	        }
	    }
	    if (iRef === "World") {
	        var expScale = STU.RenderManager.getInstance().getExperienceScaleFactor();
	        refWorldTransform = DSMath.Transformation.makeScaling(expScale, new DSMath.Point(0, 0, 0));
	        iRef = null;
	    }
	    if (iRef === "Visu") {
	        refWorldTransform = DSMath.Transformation.makeScaling(1.0, new DSMath.Point(0, 0, 0));
	        iRef = null;
	    }

	    if (STU.isEKIntegrationActive()) {
	        this.setTransform_NoBinding(iTransform, iRef);
		} else {

	        //Check transform's validity
	        if (!(iTransform instanceof DSMath.Transformation)) {
	            throw new TypeError('iTransform argument is not a DSMath.Transformation');
	        }
	        var coef = iTransform.getArray();
	        for (var i = coef.length - 1; i >= 0; i--) {
	            var e = coef[i];
	            if (!isFinite(e) || isNaN(e)) {
	                throw new Error('iTransform argument contains NaN or infinite elements');
	            }
	        }

	        var inputTransform = iTransform;

	        if (this.CATIMovable !== undefined && this.CATIMovable !== null) {
				if (_ArrayBuffer === null) {
                    _ArrayBuffer = new Float64Array(12);
                    this.CATIMovable.ExternalizeArray(_ArrayBuffer);
                }

	            // ça c'est un cas particulier, mais on obtiendrait le mm resultat avec le calcul fait dans le cas
	            // général (iRef !== undefined && iRef !== null)
	            if (iRef === this.getParent()) {
					var array = inputTransform.getArray();
                    _arrayToBuffer(array);
	                this.CATIMovable.SetLocalPosition(this.CATIMovable);
	                return;
	            }

	            if (iRef !== undefined && iRef !== null) {
	                // je veux que ma position dans le referrentiel de iRef soit inputTransform

	                //iRef.CATIMovable.GetAbsPosition(refWorldTransform);
                    iRef.CATIMovable.GetAbsPosition(); // fill _ArrayBuffer
                    refWorldTransform.setFromArray(_ArrayBuffer);
	                // refWorldTransform est la transfo telle que :
	                // Pt_DéfiniDansRepereiRef.applyTransformation(refWorldTransform) == Pt_DéfiniDansLeRepereMonde

	                inputTransform = DSMath.Transformation.multiply(refWorldTransform, inputTransform);
	                //this.CATIMovable.SetAbsPosition(inputTransform);
					var array = inputTransform.getArray();
                    _arrayToBuffer(array);
                    this.CATIMovable.SetAbsPosition(); // has a pointer to _ArrayBuffer
				} else { // iRef === null
	                inputTransform = DSMath.Transformation.multiply(refWorldTransform, inputTransform);

	                //this.CATIMovable.SetAbsPosition(inputTransform);
					var array = inputTransform.getArray();
                    _arrayToBuffer(array);
                    this.CATIMovable.SetAbsPosition(); // has a pointer to _ArrayBuffer
	            }
	        }
	    }
	};

	/**
	 * Returns the position of this STU.Actor3D.
	 * By default, the function uses the world referential.
	 * Values are expressed in millimeters.
	 *
	 * @method
	 * @public
	 * @param {STU.Actor3D} [iRef] STU.Actor3D corresponding to the referential.
	 * @return {DSMath.Vector3D} the position of this STU.Actor3D.
	 * @see STU.Actor3D#setPosition
	 * @see STU.Actor3D#translate
	 */
	Actor3D.prototype.getPosition = function(iRef) {
		var transform = this.getTransform(iRef);
		return transform.vector.clone();
	};

	/**
	 * Sets a new position for this STU.Actor3D.
	 * By default, the function uses the world referential.
	 * Values are expressed in millimeters.
	 *
	 * @method
	 * @public
	 * @param {DSMath.Vector3D} iPos Vector3D corresponding to the new position in 3D.
	 * @param {STU.Actor3D} [iRef] Actor3D corresponding to the referential.
	 * @see STU.Actor3D#getPosition
	 * @see STU.Actor3D#translate
	 */
	Actor3D.prototype.setPosition = function(iPos, iRef) {
		if (!(iPos instanceof DSMath.Vector3D)) {
			throw new TypeError('iPos argument is not a DSMath.Vector3D');
		}

		var transform = this.getTransform(iRef);
		transform.vector = iPos.clone();
		this.setTransform(transform, iRef);
	};


    // IBS GLOBE REVIVAL ACHTUNG : this et iDestActor dans la meme scene ?
    // normallement c'est OK mm si ils ne sont pas dans la mm scene
	/**
	 * Teleport this STU.Actor3D to another Stu.Actor3D transform
	 *
	 * @method
	 * @private
	 * @see STU.Actor3D#getTransform
	 */
	Actor3D.prototype.teleport = function(iDestActor) {
		if (!(iDestActor instanceof STU.Actor3D)) {
			throw new TypeError('iDestActor argument is not a STU.Actor3D');
		}

		var destTransfo = iDestActor.getTransform("World");
		var myScale = this.getScale();

		this.setTransform(destTransfo, "World");
		this.setScale(myScale);
	}; 

	/**
	 * Translates this STU.Actor3D.
	 * By default, the function uses the world referential.
	 *
	 * @method
	 * @public
	 * @param {DSMath.Vector3D} iVec Vector3D corresponding to the translation value in 3D to apply.
	 * @param {STU.Actor3D} [iRef] Actor3D corresponding to the referential.
	 * @see STU.Actor3D#getPosition
	 * @see STU.Actor3D#setPosition
	 */
	Actor3D.prototype.translate = function(iVec, iRef) {
		if (!(iVec instanceof DSMath.Vector3D)) {
			throw new TypeError('iVec argument is not a DSMath.Vector3D');
		}

		var translationVector = new DSMath.Vector3D();
		translationVector.set(iVec.x, iVec.y, iVec.z);

		if (iRef === "Location") {
		    var transform = this.getTransform("Location");
		    transform.vector.add(translationVector);
		    this.setTransform(transform, "Location");
		} else if (iRef === "World") {
		    var transform = this.getTransform("World");
		    transform.vector.add(translationVector);
		    this.setTransform(transform, "World");
		} else if (iRef === "Visu") {
		    var transform = this.getTransform("Visu");
		    transform.vector.add(translationVector);
		    this.setTransform(transform, "Visu");
		} else if (iRef !== undefined && iRef !== null) {
		    // iVec est exprimé dans le repère iRef
		    // exprimons le dans le repère monde

		    var refWorldTransfo = iRef.getTransform("World");
		    translationVector.applyTransformation(refWorldTransfo);
		    // refWorldTransfo est la transfo telle que :
		    // Pt_DéfiniDansRepereIRef.applyTransformation(refWorldTransfo) == Pt_DéfiniDansLeRepereMonde

		    var myWorldTransform = this.getTransform("World");
		    myWorldTransform.vector.add(translationVector);

		    this.setTransform(myWorldTransform, "World");
		} else { // iRef===NULL
		    // on prend le repère scene / monde de this
		    var transform = this.getTransform();
		    transform.vector.add(translationVector);
		    this.setTransform(transform);
		}
	};

	/**
	 * Returns the euler rotation of this STU.Actor3D.
	 * By default, the function uses the world referential.
	 * Values are in radian.
	 *
	 * @method
	 * @public
	 * @param {STU.Actor3D} [iRef] STU.Actor3D corresponding to the referential.
	 * @return {DSMath.Vector3D}  the euler rotation of this STU.Actor3D.
	 * @see STU.Actor3D#setRotation
	 * @see STU.Actor3D#rotate
	 */
	Actor3D.prototype.getRotation = function(iRef) {
		var transform = this.getTransform(iRef);
		// Begin Set Scale to 1.0
		var currentScale = this.getScale();

		var coefScale = 1.0 / currentScale;

		var matrix3x3 = transform.matrix;
		var coefMatrix3x3 = matrix3x3.getArray();
		for (var i = 0; i < coefMatrix3x3.length; i++) {
			coefMatrix3x3[i] *= coefScale;
		}
		matrix3x3.setFromArray(coefMatrix3x3);
		transform.matrix = matrix3x3;
		// End Set Scale to 1.0

		var euler = transform.getEuler();
		var rot = new DSMath.Vector3D();
		rot.x = euler[1];
		rot.y = euler[2];
		rot.z = euler[0];
		return rot;
	};

	/**
	 * Sets a new euler rotation for this STU.Actor3D.
	 * By default, the function uses the world referential.
	 * Values are in radian.
	 *
	 * @method
	 * @public
	 * @param {DSMath.Vector3D} iRot Vector3D corresponding to the new euler rotation in 3D.
	 * @param {STU.Actor3D} [iRef] STU.Actor3D corresponding to the referential.
	 * @see STU.Actor3D#getRotation
	 * @see STU.Actor3D#rotate
	 */
	Actor3D.prototype.setRotation = function (iRot, iRef) {
		if (!(iRot instanceof DSMath.Vector3D)) {
			throw new TypeError('iRot argument is not a DSMath.Vector3D');
		}

		var transform = this.getTransform(iRef);
		var currentScale = 1;

		if (iRef !== this) {
			currentScale = this.getScale();
		}

		var euler = [];
		euler[0] = iRot.z;
		euler[1] = iRot.x;
		euler[2] = iRot.y;
		transform.setRotationFromEuler(euler);//transform.setEuler(euler);

		// Begin Set Scale
		var coefScale = currentScale / transform.getScaling().scale;
		var matrix3x3 = transform.matrix;
		var coefMatrix3x3 = matrix3x3.getArray();
		for (var i = 0; i < coefMatrix3x3.length; i++) {
			coefMatrix3x3[i] *= coefScale;
		}
		matrix3x3.setFromArray(coefMatrix3x3);
		transform.matrix = matrix3x3;
		// End Set Scale

		this.setTransform(transform, iRef);
	};

	/**
	 * Rotates this STU.Actor3D around itself.
	 * By default, the function uses the world referential.
	 * Values are in radian.
	 *
	 * @method
	 * @public
	 * @param {DSMath.Vector3D} iRot Vector3D corresponding to the euler rotation in 3D to apply.
	 * @param {STU.Actor3D} [iRef] STU.Actor3D corresponding to the referential.
	 * @see STU.Actor3D#getRotation
	 * @see STU.Actor3D#setRotation
	 */
	Actor3D.prototype.rotate = function (iRot, iRef) {
	    // NewWorld = Ref x Rotate x Local (ignore position to rotate)
	    // WORLD Axis : NewWorld = Ref (= ID) x Rotate x Local (= World)
	    // LOCAL Axis : NewWorld = Ref (= World) x Rotate x Local (= ID)
	    // REF Axis : NewWorld = Ref x Rotate x Local

	    if (!(iRot instanceof DSMath.Vector3D)) {
	        throw new TypeError('iRot argument is not a DSMath.Vector3D');
	    }

	    var myTransform;
	    var keepPos;
	    var rotTransform;

	    rotTransform = new DSMath.Transformation();
	    var euler = [];
	    euler[0] = iRot.z;
	    euler[1] = iRot.x;
	    euler[2] = iRot.y;
	    rotTransform.setRotationFromEuler(euler);

	    // ma pos dans le repere de iRef
	    myTransform = this.getTransform(iRef);
	    
        // sauvegarde position
	    keepPos = myTransform.vector.clone();
	    myTransform.vector = new DSMath.Vector3D();

        // applique rotation
	    myTransform = DSMath.Transformation.multiply(rotTransform, myTransform);

	    // rétabli position
	    myTransform.vector = keepPos;
	   
	    // ma nouvelle pos dans le repere de iRef
	    this.setTransform(myTransform, iRef);
	};


    // IBS GLOBE REVIVAL OK ?
    // on suppose que iOrigin / iVector est defini dans la scene de this (si il y a une scene)
    // si pas de scene : iOrigin interpreté dans repere monde
	/**
	 * Rotates this STU.Actor3D around a vector.
	 *
	 * @method
	 * @public
	 * @param  {DSMath.Vector3D} iOrigin Center of the rotation.
	 * @param  {DSMath.Vector3D} iVector Vector to rotate around.
	 * @param  {Number} iAngle  Angle in radian.
	 */
	Actor3D.prototype.rotateAround = function (iOrigin, iVector, iAngle) {
		var actorCenterToOrigin = new DSMath.Vector3D();
		actorCenterToOrigin = DSMath.Vector3D.sub(this.getPosition(), iOrigin); // dans repere scene / world

		var quat = new DSMath.Quaternion();

		quat.makeRotation(iVector, iAngle);

		var actorTransform = this.getTransform(); // dans repere scene / world

		var rotTransform = actorTransform.clone();
		rotTransform.matrix = DSMath.Matrix3x3.multiply(quat.getMatrix(), actorTransform.matrix);

		var newPosCenter = actorCenterToOrigin.applyQuaternion(quat); 
		var finalactorPos = iOrigin.clone();
		finalactorPos.set(finalactorPos.x + newPosCenter.x, finalactorPos.y + newPosCenter.y, finalactorPos.z + newPosCenter.z);

		rotTransform.vector = finalactorPos;
		this.setTransform(rotTransform); // dans repere scene / world
	};

	/**
	 * Returns the scale of this STU.Actor3D.
	 * By default, the function uses the world referential.
	 *
	 * @method
	 * @public
	 * @param {STU.Actor3D} [iRef] STU.Actor3D corresponding to the referential.
	 * @return {number} the scale value.
	 * @see STU.Actor3D#setScale
	 */
	Actor3D.prototype.getScale = function(iRef) {
		var transform = this.getTransform(iRef);

		var scale3 = transform.matrix.determinant();
		var scale = Math.pow(Math.abs(scale3), 1 / 3);
		if (scale3 < 0){
			scale = -scale;
		}
		return scale;
	};

	/**
	 * Sets a new scale for this STU.Actor3D.
	 * By default, the function uses the world referential.
	 *
	 * @method
	 * @public
	 * @param {number} iScale New scale value.
	 * @param {STU.Actor3D} [iRef] STU.Actor3D corresponding to the referential.
	 * @see STU.Actor3D#getScale
	 */
	Actor3D.prototype.setScale = function (iScale, iRef) {
		if (iScale === 0) {
			throw new Error('iScale argument cannot be zero');
		}
		var transform = this.getTransform(iRef);
		var currentScale = this.getScale();
		if (currentScale === 0) {
			throw new Error('currentScale cannot be zero');
		}

		var coefScale = iScale / currentScale;

		var matrix3x3 = transform.matrix;
		var coefMatrix3x3 = matrix3x3.getArray();
		for (var i = 0; i < coefMatrix3x3.length; i++) {
			coefMatrix3x3[i] *= coefScale;
		}
		matrix3x3.setFromArray(coefMatrix3x3);
		transform.matrix = matrix3x3;

		this.setTransform(transform, iRef);
	};

	/**
	 * Return the opacity of this STU.Actor3D.
	 * Range value is between 0 and 255.
	 * (deprecate use this.opacity instead)
	 *
	 * @method
	 * @private
	 * @return {number} corresponding to the opacity value
	 * @see STU.Actor3D#setOpacity
	 */
	Actor3D.prototype.getOpacity = function() {
		return this.opacity;
	};

	/**
	 * Set a new opacity for this STU.Actor3D.
	 * Range value is between 0 and 255.
	 * (deprecate use this.opacity instead)
	 *
	 * @method
	 * @private
	 * @param {number} iOpacity corresponding to the new opacity value
	 * @see STU.Actor3D#getOpacity
	 */
	Actor3D.prototype.setOpacity = function(iOpacity) {
		this.opacity = iOpacity;
	};

	/**
	 * Return the color of this STU.Actor3D.
	 * (deprecate use Actor3D.color instead)
	 * @method
	 * @private
	 * @return {STU.Color} instance object corresponding to the color
	 * @see STU.Actor3D#setColor
	 */
	Actor3D.prototype.getColor = function() {
		console.info('Deprecate use Actor3D.color instead');
		return this.color;
	};

	/**
	 * Set a new color for this STU.Actor3D.
	 * (deprecate use Actor3D.color instead)
	 * @method
	 * @private
	 * @param {STU.Color} iColor instance object corresponding to the new color
	 * @see STU.Actor3D#getColor
	 */
	Actor3D.prototype.setColor = function(iColor) {
		console.info('Deprecate use Actor3D.color instead');
		this.color = iColor;
	};

	/**
	 * Returns true if this STU.Actor3D is visible.
	 *
	 * @method
	 * @public
	 * @return {boolean} true if this STU.Actor3D is visible.<br/>
	 * 					 false otherwise.
	 * @see STU.Actor3D#setVisible
	 */
	Actor3D.prototype.isVisible = function() {
		return this.visible;
	};

	/**
	 * Set a new visible information for this STU.Actor3D.
	 * True to make it visible or false to hide.
	 *
	 * @method
	 * @private
	 * @param {boolean} iVisible
	 * @see STU.Actor3D#isVisible
	 */
	Actor3D.prototype.setVisible = function(iVisible) {
		this.visible = iVisible;
	};

	/**
	 * Hide this STU.Actor3D.
	 *
	 * @method
	 * @private
	 * @see STU.Actor3D#isVisible
	 */
	Actor3D.prototype.hide = function() {
		this.visible = false;
	};

	/**
	 * Show this STU.Actor3D.
	 *
	 * @method
	 * @private
	 * @see STU.Actor3D#isVisible
	 */
	Actor3D.prototype.show = function() {
		this.visible = true;
	};

	/**
	 * Returns true if this STU.Actor3D responds to a click.
	 *
	 * @method
	 * @public
	 * @return {boolean} true if this STU.Actor3D responds to a click.<br/>
	 * 					 false otherwise.
	 * @see STU.Actor3D#setClickable
	 */
	Actor3D.prototype.isClickable = function() {
		return this.clickable;
	};

	/**
	 * Sets the clickable state of this STU.Actor3D.
	 * 
	 *
	 * @method
	 * @public

	 * @param {boolean} iClickable true to make it clickable. <br/> 
	 *                             false to ignore picking action.
	 * @see STU.Actor3D#isClickable
	 */
	Actor3D.prototype.setClickable = function(iClickable) {
		this.clickable = iClickable;
	};


	/**
	 * Returns a bounding sphere which is enclosing this STU.Actor3D geometry.
	 *
	 * The sphere position is given in world referential.
	 *
	 * @method
	 * @public
	 * @return {STU.Sphere} instance object corresponding to the bounding sphere
	 */
	Actor3D.prototype.getBoundingSphere = function (iRef) {
		var sphere = new STU.Sphere();
		this.StuIRepresentation.GetBoundingSphere(sphere);

	    if (iRef === "Parent") {
		return sphere;
	    }
	    // sphere exprimé¥ dans le repè²¥ "local" de this = par rapport à ³on parent
	    // on veut la position de sont parent par rapport à ©Ref
	    var parentActor = this.getParent();
	    var T = null;
	    if (parentActor !== undefined && parentActor !== null && parentActor instanceof STU.Actor3D) {
	        T = parentActor.getTransform(iRef);
	    }
	        // this n'a pas de parent : il est sous le root
	        // c'est comme si il é´¡it sous un parent qui porte sa position, avec une BS qui compense pour cet offset
	    else {
	        var MyPosRelToParent = this.getTransform("World"); // because I have no parent
	        var MyPosRelToRef = this.getTransform(iRef);

	        // MyPosRelToRef = MyPosRelToParent x MyParentPosRelToRef
	        // => MyParentPosRelToRef = inv(MyPosRelToParent) x MyPosRelToRef
	        var InvMyPosRelToParent = MyPosRelToParent.getInverse();
	        T = DSMath.Transformation.multiply(MyPosRelToRef, InvMyPosRelToParent);
	    }
	    if (T !== undefined && T !== null) {
	        sphere.center.applyTransformation(T);
	        sphere.radius = T.getScaling().scale * (sphere.radius);
	    }
	    return sphere;
	};


	/**
	 * Returns a bounding box which is enclosing this STU.Actor3D geometry.
	 *
	 * The box corner points are given in world referential.
	 *
	 * @method
	 * @private
	 * @return {STU.Box} instance object corresponding to the bounding box
	 */
	Actor3D.prototype.getBoundingBox = function() {
		  var box = new STU.Box();
		  
		  var absTransfo = this.getTransform();
		
        // si il y a une scene, je veux renvoyer la bbox dans le referrentiel de la scene
	    var myLoc = this.getLocation();
	    if (myLoc !== undefined && myLoc !== null) {
	    	this.StuIRepresentation.GetBoundingBox(box, absTransfo, 1); // bbox dans ref local 


	        var myLocTransform = this.getTransform(); // si pas de scene, scene==monde
	        // myLocTransform est la transfo telle que :
	        // Pt_DéfiniDansMonrepere.applyTransformation(myLocTransform) == Pt_DéfiniDansLeRepereScene


	        var LowPoint = new DSMath.Point();
	        LowPoint.x = box.low.x;
	        LowPoint.y = box.low.y;
	        LowPoint.z = box.low.z;

	        var HighPoint = new DSMath.Point();
	        HighPoint.x = box.high.x;
	        HighPoint.y = box.high.y;
	        HighPoint.z = box.high.z;

	        LowPoint.applyTransformation(myLocTransform);
	        HighPoint.applyTransformation(myLocTransform);

	        box.low.x = LowPoint.x;
	        box.low.y = LowPoint.y;
	        box.low.z = LowPoint.z;

	        box.high.x = HighPoint.x;
	        box.high.y = HighPoint.y;
	        box.high.z = HighPoint.z;
		} else {
	    	this.StuIRepresentation.GetBoundingBox(box, absTransfo, 0); // par défaut dans le repère monde
	    }
		return box;
	};


    /**
	 * Returns a bounding box, with a user-defined orientation, which contains the actor's geometry. <br/> 
     * 
	 *
	 * @method
	 * @public
     * @param {Object} iParams
     * @param {DSMath.Transformation} [iParams.orientation] Defines the orientation of the box <br/> 
	 * 														if is undefined or equal to Identity : the box is oriented along the world canonical axes <br/> 
	 * 														if set the box is oriented along the transformation's local axes
     * @param {boolean} iParams.excludeChildren - if true, the box contains the given actor only, without the geometry of its subactors
	 * @return {STU.Box} instance object corresponding to the bounding box in the referential defined by iParams.orientation
	 */
	Actor3D.prototype.getOrientedBoundingBox = function (iParams) {
		var box = new STU.Box();
		var absTransfo = this.getTransform();
		this.StuIRepresentation.GetOrientedBoundingBox(box, iParams, absTransfo);
	  return box;
	};
     

	/**
	 * Returns the actor in the given collection which is the closest (in distance) to this STU.Actor3D.
	 * 
	 *
	 * @method
	 * @public
	 * @param {STU.Collection} iCollection Target collection.
	 * @return {STU.Actor3D} the closest actor in the given collection.
	 */
	Actor3D.prototype.getNearestActor = function(iCollection) {
		var objCount = iCollection.getObjectCount();

		var nearestIndex = -1;
		var nearestDist = -1;

		var pos = this.getPosition();

		for (var i = 0; i < objCount; i++) {
			var obj = iCollection.getObjectAt(i);
			if (obj instanceof STU.Actor3D && obj !== this) {
				var pos2 = obj.getPosition();
				pos2.sub(pos);
				var dist = pos2.squareNorm();
				if (nearestDist === -1 || dist < nearestDist) {
					nearestDist = dist;
					nearestIndex = i;
				}
			}
		}

		if (nearestIndex !== -1) {
			return iCollection.getObjectAt(nearestIndex);
		}

		return null;
	};

	Actor3D.prototype.onInitialize = function () {
		Actor.prototype.onInitialize.call(this);
		
		if(this.uniqueID !== undefined){
			STU.RenderManager.getInstance().registerActor(this.uniqueID, this);
		}
	};

	/**
	 * Process to execute when this STU.Actor3D is activating.
	 *
	 * @method
	 * @private
	 */
	Actor3D.prototype.onActivate = function() {
		Actor.prototype.onActivate.call(this);

		if (this.isClickable()) {
			STU.ClickableManager.getInstance().addClickable(this);
		}
	};

	/**
	 * Process to execute when this STU.Actor3D is deactivating.
	 *
	 * @method
	 * @private
	 */
	Actor3D.prototype.onDeactivate = function() {
		STU.ClickableManager.getInstance().removeClickable(this);
		Actor.prototype.onDeactivate.call(this);
	};

	/**
     * @private
     */
    Actor3D.prototype.onDispose = function () {
        // we set the pickmode to true so the user can click 
        // on the actor during authoring
        this.clickable = true;

        if (_ArrayBuffer !== null) {
            this.CATIMovable.CleanArray(_ArrayBuffer);
            _ArrayBuffer = null;
        }
        Actor.prototype.onDeactivate.call(this);
        Actor.prototype.onDispose.call(this);
    };

	//->SVV : EK Drop 1
	/**
	 * getTransform implementing without binding on CATIMovable
	 *
	 * @method
	 * @private
	 */
	/* jshint camelcase : false */
	Actor3D.prototype.getTransform_NoBinding = function (iRef) {
		var transform = new DSMath.Transformation();

		if (iRef !== this) {
			var parentActor = this.getParent();
			transform.setFromArray(this._varposition);//Deprecated: transform.setCoefficients(this._varposition);

			if (iRef === parentActor /*|| (!(parentActor instanceof STU.Actor3D))*/) {
				return transform;
			} else {
				//var parentAbsPos = parentActor.getTransform_NoBinding();
				var parentAbsPos;
				if (parentActor instanceof STU.Actor3D) {
					parentAbsPos = parentActor.getTransform_NoBinding();
				} else {
					parentAbsPos = new DSMath.Transformation();
				}

				var actorAbsPos = DSMath.Transformation.multiply(parentAbsPos, transform);

				var invRefTransform = new DSMath.Transformation();
				if (iRef !== null && iRef !== undefined && (iRef instanceof STU.Actor3D)) {
					invRefTransform = iRef.getTransform_NoBinding().getInverse();
				}
			   
				transform = DSMath.Transformation.multiply(invRefTransform, actorAbsPos);
			}            
		}
		return transform;
	};

	/**
	 * setTransform implementing without binding on CATIMovable
	 *
	 * @method
	 * @private
	 */
	Actor3D.prototype.setTransform_NoBinding = function (iTransform, iRef) {
		if (!(iTransform instanceof DSMath.Transformation)) {
			throw new TypeError('iTransform argument is not a DSMath.Transformation');
		}

		//Check transform's validity
		var coef = iTransform.getArray();
		for (var i = coef.length - 1; i >= 0; i--) {
			var e = coef[i];
			if (!isFinite(e) || isNaN(e)) {
				throw new Error('iTransform argument contains NaN or infinite elements');
			}
		}

		var parentActor = this.getParent();
		var transform = iTransform;

		if (iRef !== undefined && iRef !== null) {
			if (iRef === parentActor /*|| (!(parentActor instanceof STU.Actor3D))*/) {
				this._varposition = transform.getArray();
				return;
			} else {
				if (iRef === this) {
					//if parentActor is not a STU.Actor3D, the getTransform will check it and traet as it was null
					var refTransform = iRef.getTransform(parentActor);
					transform = DSMath.Transformation.multiply(refTransform, transform);
					this._varposition = transform.getArray();
					return;
				} else {
						if (parentActor instanceof STU.Actor3D) {
							var refAbsPos = iRef.getTransform_NoBinding();
							var invParentAbsPos = parentActor.getTransform_NoBinding().getInverse();
							transform = DSMath.Transformation.multiply(refAbsPos, transform);
							transform = DSMath.Transformation.multiply(invParentAbsPos, transform);
							this._varposition = transform.getArray();
							return;
					} else {
							this._varposition = transform.getArray();
							return;
					}
					}
				}
		} else {
				if (parentActor instanceof STU.Actor3D) {
					var invParentAbsPos = parentActor.getTransform_NoBinding().getInverse();
					transform = DSMath.Transformation.multiply(invParentAbsPos,transform);
					this._varposition = transform.getArray();
					return;
			} else {
					//consider the transform as the  Absolute Position
					////transform = ThreeDS.Mathematics.multiplyTransfo(refTransform, transform);
					//transform = ThreeDS.Mathematics.multiplyTransfo(transform,refTransform);
					this._varposition = transform.getArray();
					return;
				}
			}
	};
	//SVV<-


    ////////////////////////////////
    ////// IBS JS APIs for MATERIALS
    
    /**
	 * Returns the name of the applied material.
	 *
	 * @method
	 * @public
	 * @return {string} the material name; empty string if no material is found.
	 */
	Actor3D.prototype.getMaterialName = function () {
	    var myMaterialsManager = null;
	    try {
	        myMaterialsManager = new StuMaterialsManager();
	        return myMaterialsManager.getMaterialName(this.CATI3DExperienceObject);
	    }
	    catch (e) {
	        myMaterialsManager = new StuMaterialsManagerJS();
	        return myMaterialsManager.getMaterialName(this.CATI3DExperienceObject);
	    }
	};

    /**
	 * Returns the material applied to this STU.Actor3D.
	 *
	 * @method
	 * @public
	 * @return {STU.Material} the applied material 
	 */
	Actor3D.prototype.getMaterial = function () {
		var myMaterialsManager = null;
	    try {	  
			myMaterialsManager = new StuMaterialsManager(); 
			return myMaterialsManager.getMaterial(this.CATI3DExperienceObject);
		}
		catch (e) {
	        myMaterialsManager = new StuMaterialsManagerJS();
	        return myMaterialsManager.getMaterial(this.CATI3DExperienceObject);
	    }
	};

    /**
	 * Removes all materials applied to this STU.Actor3D.
	 *
	 * @method
	 * @public
	 */
	Actor3D.prototype.removeMaterials = function () {
	    var myMaterialsManager = null;
        try {
            myMaterialsManager = new StuMaterialsManager();
            myMaterialsManager.removeMaterials(this.CATI3DExperienceObject);
	    }
	    catch(e) {
	        myMaterialsManager = new StuMaterialsManagerJS();
	        myMaterialsManager.removeMaterials(this.CATI3DExperienceObject);
	    }
	};

    /**
	 * Applies a material, identified by its name, to this STU.Actor3D.
	 *
	 * @method
	 * @public
     * @param {string} iName Name of the material to apply to this actor.
	 */
	Actor3D.prototype.setMaterialByName = function (iName) {
	    var myMaterialsManager = null;
	    try {
	        myMaterialsManager = new StuMaterialsManager();
	        myMaterialsManager.setMaterialByName(this.CATI3DExperienceObject, iName);
	    }
	    catch(e) {
	        myMaterialsManager = new StuMaterialsManagerJS();
	        myMaterialsManager.setMaterialByName(this.CATI3DExperienceObject, iName);
	    }
	};

    /**
	 * Applies a material to this STU.Actor3D.
	 *
	 * @method
	 * @public
     * @param {STU.Material} iMaterial Material to apply to this actor.
	 */
	Actor3D.prototype.setMaterial = function (iMaterial) {
	    var myMaterialsManager = null;
	    try {
	        myMaterialsManager = new StuMaterialsManager();
	        myMaterialsManager.setMaterial(this.CATI3DExperienceObject, iMaterial.CATICXPMaterial);
	    }
	    catch (e) {
	        myMaterialsManager = new StuMaterialsManagerJS();
	        myMaterialsManager.setMaterial(this.CATI3DExperienceObject, iMaterial.CATICXPMaterial);
	    }	    
	};

    /**
	 * Returns true if this STU.Actor3D has iMaterial applied.
	 *
	 * @method
	 * @public
     * @param {STU.Material} iMaterial STU.Material to check.
     * @return {boolean} true if this STU.Actor3D has the material. <br/>
	 *                   false otherwise.
	 */
	Actor3D.prototype.hasMaterial = function (iMaterial) {
	    // return this.materials[0].linktomaterial == iMaterial;

 		var myMaterialsManager = null;
	    try {
	        myMaterialsManager = new StuMaterialsManager();
		    return iMaterial == myMaterialsManager.getMaterial(this.CATI3DExperienceObject);
	    }
	    catch (e) {
	        myMaterialsManager = new StuMaterialsManagerJS();
   		    return iMaterial == myMaterialsManager.getMaterial(this.CATI3DExperienceObject);
	    }	
	
	};

    ////// ~IBS JS APIs for MATERIALS
    ////////////////////////////////
    

	// Expose in STU namespace.
	STU.Actor3D = Actor3D;

	return Actor3D;
});

define('StuRenderEngine/StuActor3D', ['DS/StuRenderEngine/StuActor3D'], function (Actor3D) {
    'use strict';

    return Actor3D;
});
