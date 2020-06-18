define('MathematicsES/MathQuaternionJSImpl',
  ['MathematicsES/MathNameSpace',
   'MathematicsES/MathTypeCheck',
   'MathematicsES/MathTypeCheckInternal',
   'MathematicsES/MathPointJSImpl',
   'MathematicsES/MathVector3DJSImpl',
   'MathematicsES/MathMat3x3JSImpl'
  ],
  
  function (DSMath, TypeCheck, TypeCheckInternal, Point, Vector3D, Matrix3x3)
  {
    'use strict';

    /**
    * @public
    * @exports Quaternion
    * @class
    * @classdesc Representation of a Quaternion.
    *
    * @constructor
    * @constructordesc
    * The DSMath.Quaternion constructor creates a quaternion.
    * <br>
    * The quaternion data is made up of a scalar s and a vector of x, y, z coordinates.
    * @param {Number} [iS=1] s coordinate.
    * @param {Number} [iX=0] x coordinate.
    * @param {Number} [iY=0] y coordinate.
    * @param {Number} [iZ=0] z coordinate.
    * @memberof DSMath
    */
    var Quaternion = function (iS, iX, iY, iZ)
    {
      DSMath.TypeCheck(iS, false, 'number');
      DSMath.TypeCheck(iX, false, 'number');
      DSMath.TypeCheck(iY, false, 'number');
      DSMath.TypeCheck(iZ, false, 'number');

      this.s = (iS === undefined || iS === null) ? 1 : iS;
      this.x = iX || 0;
      this.y = iY || 0;
      this.z = iZ || 0;
    };

    /**
    * The x coordinate of a Quaternion.
    * @public
    * @member
    * @instance
    * @name x
    * @type {Number}
    * @memberOf DSMath.Quaternion
    */
    Quaternion.prototype.x = null;

    /**
    * The y coordinate of a Quaternion.
    * @public
    * @member
    * @instance
    * @name y
    * @type {Number}
    * @memberOf DSMath.Quaternion
    */
    Quaternion.prototype.y = null;

    /**
    * The z coordinate of a Quaternion.
    * @public
    * @member
    * @instance
    * @name z
    * @type {Number}
    * @memberOf DSMath.Quaternion
    */
    Quaternion.prototype.z = null;

    /**
    * The s coordinate of a Quaternion representing the scale.
    * @public
    * @member
    * @instance
    * @name s
    * @type {Number}
    * @memberOf DSMath.Quaternion
    */
    Quaternion.prototype.s = null;

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method clone
    * @instance
    * @description
    * Clones a quaternion.
    * @example
    * var q0 = new DSMath.Quaternion();
    * q0.makeRotation(DSMath.Vector3D.zVect, Math.PI/2); // q0=(s=1/&#8730;2,x=0,y=0,z=1/&#8730;2)
    * var clonedQ0 = q0.clone();                              // q0!==q1 and q1=(s=1/&#8730;2,x=0,y=0,z=1/&#8730;2)
    * @returns {DSMath.Quaternion} The cloned quaternion.
    */
    Quaternion.prototype.clone = function ()
    {
      var oQ = new Quaternion(this.s, this.x, this.y, this.z);
      return oQ;
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method copy
    * @instance
    * @description
    * Copies a quaternion.
    * @param {DSMath.Quaternion} iToCopy Quaternion to copy.
    * @example
    * var q0 = new DSMath.Quaternion();
    * var q1 = new DSMath.Quaternion();                  // q1=(s=1,x=0,y=0,z=0)
    * q0.makeRotation(DSMath.Vector3D.zVect, Math.PI/2); // q0=(s=1/&#8730;2,x=0,y=0,z=1/&#8730;2)
    * q1.copy(q0);                                        // q0!==q1 and q1=(s=1/&#8730;2,x=0,y=0,z=1/&#8730;2)
    */
    Quaternion.prototype.copy = function (iToCopy)
    {
      DSMath.TypeCheck(iToCopy, true, DSMath.Quaternion);

      this.s = iToCopy.s;
      this.x = iToCopy.x;
      this.y = iToCopy.y;
      this.z = iToCopy.z;

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method set
    * @instance
    * @description
    * Assigns new coordinate values to a quaternion.
    * @param {Number} iS The scale
    * @param {Number} iX The x coordinate
    * @param {Number} iY The y coordinate
    * @param {Number} iZ The z coordinate
    * @example
    * var q0 = new DSMath.Quaternion(); // q0=(s=1,x=0,y=0,z=0)
    * q0.set(0.1,0.2,0.3,0.4);           // q0=(s=0.1,x=0.2,y=0.3,z=0.4)
    * @returns {DSMath.Quaternion } <i>this</i> modified quaternion reference.
    */
    Quaternion.prototype.set = function (iS, iX, iY, iZ)
    {
      DSMath.TypeCheck(iS, true, 'number');
      DSMath.TypeCheck(iX, true, 'number');
      DSMath.TypeCheck(iY, true, 'number');
      DSMath.TypeCheck(iZ, true, 'number');

      this.s = iS;
      this.x = iX;
      this.y = iY;
      this.z = iZ;
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method setFromArray
    * @instance
    * @description
    * Assigns new coordinate values to a quaternion.
    * <br>
    * @param {Number[]} iA Array of coordinates:
    * <ul>
    * <li> val = [s, (x, y, z)] according to the mathematical convention</li>
    * <li> val = [(x, y, z), s] according to the game convention </li>
    * </ul>
    * @param {Number} convention 
    * <ul>
    * <li> 1 for the mathematical convention. The coordinates are expressed under the form [s, (x, y, z)]</li>
    * <li> 0 for the game convention. The coordinates are expressed under the form [(x, y, z), s]</li>
    * </ul>
    * @example
    * var q0 = new DSMath.Quaternion();  // q0=(s=1,x=0,y=0,z=0)
    * var newCoef = [0.1, 0.2, 0.3, 0.4];
    * q0.setFromArray(newCoef, 1);            // q0=(s=0.1,x=0.2,y=0.3,z=0.4)
    * q0.setFromArray(newCoef, 0);            // q0=(s=0.4,x=0.1,y=0.2,z=0.3)
    * @returns {DSMath.Quaternion } <i>this</i> modified quaternion reference.
    */
    Quaternion.prototype.setFromArray = function (iA, convention)
    {
      DSMath.TypeCheck(iA, true, ['number'], 4);
      DSMath.TypeCheck(convention, true, 'number');

      if (convention === 1)
      {
        this.set(iA[0], iA[1], iA[2], iA[3]);
      }
      else
      {
        this.set(iA[3], iA[0], iA[1], iA[2]);
      }

      return this;
    };


    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method getArray
    * @instance
    * @description
    * Retrieves the data of a quaternion.
    * @param {Number} convention
    * <ul>
    * <li> 1 for the mathematical convention. The coordinates are expressed under the form [s, (x, y, z)]</li>
    * <li> 0 for the game convention. The coordinates are expressed under the form [(x, y, z), s]</li>
    * </ul>
    * @example
    * var q0 = new DSMath.Quaternion(1,2,3,4); // q0=(s=1,x=2,y=3,z=4)
    * var arrayOfCoordMath = q0.getArray(1); // arrayOfCoordMath=[1,2,3,4]
    * var arrayOfCoordGame = q0.getArray(0); // arrayOfCoordGame=[2,3,4,1]
    * @returns { Number[] } The quaternion data.
    */
    Quaternion.prototype.getArray = function (convention)
    {
      DSMath.TypeCheck(convention, true, 'number');

      if (convention === 1)
        return new Array(this.s, this.x, this.y, this.z);
      else
        return new Array(this.x, this.y, this.z, this.s);
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method setVector
    * @instance
    * @description
    * Assigns a new vector to a quaternion.
    * @param {DSMath.Vector3D} iV The Vector3D containing the quaternion coordinates x,y,z.
    * @example
    * var q0 = new DSMath.Quaternion();
    * var v0 = new DSMath.Vector3D(1.1, 2.2, 3.3);
    * q0.setVector(v0); // q0 = [1, 1.1, 2.2, 3.3]
    * @returns { DSMath.Quaternion } The modified quaternion reference.
    */
    Quaternion.prototype.setVector = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);

      this.x = iV.x;
      this.y = iV.y;
      this.z = iV.z;
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method getVector
    * @instance
    * @description
    * Retrieves the vector of a quaternion.
    * @param {DSMath.Vector3D} [oV] Reference of the operation result (avoid allocation).
    * @example
    * var q0 = new DSMath.Quaternion(1,2,3,4);
    * var vectorQ0 = q0.getVector(); // vectorQ0=(2,3,4);
    * @returns {DSMath.Vector3D} The reference of the operation result.
    */
    Quaternion.prototype.getVector = function (oV)
    {
      DSMath.TypeCheck(oV, false, DSMath.Vector3D);

      oV = oV || new Vector3D();
      oV.set(this.x, this.y, this.z);
      return oV;
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method makeRotation
    * @instance
    * @description
    * Sets <i>this</i> quaternion from the rotation specified by an axis and angle.
    * @param {DSMath.Vector3D} iAxis The axis of the rotation.
    * @param {Number} iAngle The angle of the rotation in radian.
    * @example
    * var q0 = new DSMath.Quaternion();
    * var axis = new DSMath.Vector3D(Math.SQRT1_2, Math.SQRT1_2, 0);
    * q0.makeRotation(axis, Math.PI/2.0); //q0=(s=1/&#8730;2,x=1/2,y=1/2,z=0)
    * @returns { DSMath.Quaternion } The modified quaternion reference.
    */
    Quaternion.prototype.makeRotation = function (iAxis, iAngle)
    {
      DSMath.TypeCheck(iAxis, true, DSMath.Vector3D);
      DSMath.TypeCheck(iAngle, true, 'number');

      var norm = iAxis.norm();
      var sinA = Math.sin(iAngle / 2.0);
      var cosA = Math.cos(iAngle / 2.0);
      this.s = cosA;
      this.x = iAxis.x * sinA / norm;
      this.y = iAxis.y * sinA / norm;
      this.z = iAxis.z * sinA / norm;
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method makeRotationFromVectors
    * @instance
    * @description
    * Sets <i>this</i> quaternion from the rotation specified by two vectors
    * @param {DSMath.Vector3D} iFromVector The vector before.
    * @param {DSMath.Vector3D} iToVector The vector after.
    * @example
    * var q0 = new DSMath.Quaternion();
    * var v0 = new DSMath.Vector3D(1,0,0);
    * var v1 = new DSMath.Vector3D(0,1,0);
    * q0.makeRotationFromVectors(v0,v1); //q0=(s=1/&#8730;2,x=0,y=0,z=1/&#8730;2) <=> rotation PI/2 of (0,0,1) axis.
    * @returns { DSMath.Quaternion } The modified quaternion reference.
    */
    Quaternion.prototype.makeRotationFromVectors = function (iFromVector, iToVector)
    {
      DSMath.TypeCheck(iFromVector, true, DSMath.Vector3D);
      DSMath.TypeCheck(iToVector, true, DSMath.Vector3D);

      if (!iFromVector.isParallel(iToVector))
      {
        var iFromVectorNorm = iFromVector.norm();
        var iToVectorNorm = iToVector.norm();
        var axis = Vector3D.cross(iFromVector, iToVector).divideScalar(iFromVectorNorm * iToVectorNorm);
        var sinA = axis.norm();
        var angle = Math.asin(sinA);
        axis.divideScalar(sinA);

        this.makeRotation(axis, angle);
      }
      else
      {
        this.set(1, 0, 0, 0);
      }

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method norm
    * @instance
    * @description
    * Computes the norm of <i>this</i> quaternion.
    * @example
    * var q0 = new DSMath.Quaternion(1,2,3,4)
    * var q0Norm = q0.norm(); // q0Norm = &#8730;30
    * @returns { Number } The quaternion norm.
    */
    Quaternion.prototype.norm = function ()
    {
      return Math.sqrt(this.s * this.s + this.x * this.x + this.y * this.y + this.z * this.z);
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method squareNorm
    * @instance
    * @description
    * Computes the squared norm of <i>this</i> quaternion.
    * @example
    * var q0 = new DSMath.Quaternion(1,2,3,4);
    * var q0SqNorm = q0.squareNorm(); // q0SqNorm=30
    * @returns {Number} The squared norm of a quaternion.
    */
    Quaternion.prototype.squareNorm = function ()
    {
      var s = this.s;
      var x = this.x;
      var y = this.y;
      var z = this.z;
      var sqNorm = s * s + x * x + y * y + z * z;
      return sqNorm;
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method normalize
    * @instance
    * @description
    * Normalizes <i>this</i> quaternion.
    * @example
    * var q0 = new DSMath.Quaternion(1,1,1,1);
    * q0.normalize(); // q0=[1/&#8730;4, 1/&#8730;4, 1/&#8730;4, 1/&#8730;4]
    * @returns {DSMath.Quaternion} <i>this</i> modified quaternion reference.
    */
    Quaternion.prototype.normalize = function ()
    {
      var Tol = DSMath.defaultTolerances.epsilonForRelativeTest;
      var sqNorm = this.s * this.s + this.x * this.x + this.y * this.y + this.z * this.z;
      var inv_norm = (Math.abs(sqNorm - 1) <= 2 * Tol) ? 1. : 1. / Math.sqrt(sqNorm);

      this.s = this.s * inv_norm;
      this.x = this.x * inv_norm;
      this.y = this.y * inv_norm;
      this.z = this.z * inv_norm;

      return this;
    };

    /**
     * @typedef RotationData
     * @type Object
     * @property {Number} angle The angle of the quaternion rotation
     * @property {DSMath.Vector3D} vector The axis of the quaternion rotation
     */

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method getRotationData
    * @instance
    * @description
    * Retrieves the rotation data (angle and vector).
    * <br>
    * If <i>this</i> is not a unit quaternion, the computation will used its normalized form.
    * @param {RotationData} [oRotationData] Reference of the operation result (avoid allocation).
    * @example
    * var q0 = new DSMath.Quaternion();
    * var axis = new DSMath.Vector3D(Math.SQRT1_2, Math.SQRT1_2, 0);
    * q0.makeRotation(axis, Math.PI/2.0);
    * var rotData = q0.getRotationData(); // rotData={angle: PI/2, vector: Vector3D(1/&#8730;2,1/&#8730;2,0)}
    * @returns { RotationData } The quaternion rotation data.
    */
    Quaternion.prototype.getRotationData = function (rotationData)
    {
      DSMath.TypeCheck(rotationData, false, Object);

      rotationData = rotationData || { angle: 0, vector: new Vector3D() };
      var norm = this.norm();
      this.getVector(rotationData.vector); // qVect = (this.x, this.y, this.z)

      // Angle computation (this.s=cos(angle/2)).
      var W = this.s / norm;
      if (W < -1) W = -1;
      if (W > 1) W = 1;
      rotationData.angle = 2 * Math.acos(W);

      // Axe computation (this.x=x*sin(angle/2), ...).
      var SquareSin = 1 - W * W;
      if (SquareSin > 0)
      {
        var Sin = Math.sqrt(SquareSin);
        rotationData.vector.divideScalar(norm * Sin);
      }
      else
      {
        rotationData.angle = 0.;
        rotationData.vector.set(1, 0, 0);
      }

      return rotationData;
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method getMatrix
    * @instance
    * @description
    * Computes the rotation matrix from a quaternion q = [ s, x, y, z ].
    * <br>
    * If this is not a unit quaternion, the computation will used its normalized form.
    * @param {DSMath.Matrix3x3} [oM] Reference of the operation result (avoid allocation).
    * @example
    * var q0 = new DSMath.Quaternion();
    * q0.makeRotation(DSMath.Vector3D.zVect, Math.PI/2.0);
    * var Mq0 = q0.getMatrix();
    * // Mq0 = | 0, -1,  0|
    * //       | 1,  0,  0|
    * //       | 0,  0,  1|
    * @returns {DSMath.Matrix3x3} The reference of the operation result.
    */
    Quaternion.prototype.getMatrix = function (oM)
    {
      DSMath.TypeCheck(oM, false, DSMath.Matrix3x3);

      oM = oM || new Matrix3x3();

      var coef = oM.coef;
      var n2 = this.squareNorm();

      var s2 = this.s * this.s / n2;
      var x2 = this.x * this.x / n2;
      var y2 = this.y * this.y / n2;
      var z2 = this.z * this.z / n2;

      var sx = this.s * this.x / n2;
      var sy = this.s * this.y / n2;
      var sz = this.s * this.z / n2;

      var xy = this.x * this.y / n2;
      var xz = this.x * this.z / n2;

      var yz = this.y * this.z / n2;

      coef[0] = s2 + x2 - y2 - z2;
      coef[1] = 2.0 * (xy - sz);
      coef[2] = 2.0 * (xz + sy);
      coef[3] = 2.0 * (xy + sz);
      coef[4] = s2 - x2 + y2 - z2;
      coef[5] = 2.0 * (yz - sx);
      coef[6] = 2.0 * (xz - sy);
      coef[7] = 2.0 * (yz + sx);
      coef[8] = s2 - x2 - y2 + z2;

      return oM;
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method add
    * @instance
    * @description
    * Adds <i>this</i> quaternion by another quaternion.
    * @param {DSMath.Quaternion} iQ The quaternion <i>this</i> is to be added by.
    * @example
    * var q0 = new DSMath.Quaternion(1,2,3,4)
    * var q1 = new DSMath.Quaternion(5,6,7,8);
    * var q2 = q0.add(q1); // q0===q2 and q2=(6,8,10,12);
    * @returns {DSMath.Quaternion} <i>this</i> modified quaternion reference.
    */
    Quaternion.prototype.add = function (iQ)
    {
      DSMath.TypeCheck(iQ, true, DSMath.Quaternion);

      this.s += iQ.s;
      this.x += iQ.x;
      this.y += iQ.y;
      this.z += iQ.z;

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method addScaledQuaternion
    * @instance
    * @description
    * Adds <i>this</i> quaternion by another quaternion multiplied by a scale on all its coordinates.
    * @param {DSMath.Quaternion} iQ The quaternion <i>this</i> is to be added by.
    * @param {Number}                         iS The scalar to multiply iQ during the computation.
    * @example
    * var q0 = new DSMath.Quaternion(1,2,3,4)
    * var q1 = new DSMath.Quaternion(5,6,7,8);
    * var q2 = q0.addScaledQuaternion(q1,0.1); // q0===q2 and q2=(1.5,2.6,3.7,4.8);
    * @returns {DSMath.Quaternion} <i>this</i> modified quaternion reference
    */
    Quaternion.prototype.addScaledQuaternion = function (iQ, iS)
    {
      DSMath.TypeCheck(iQ, true, DSMath.Quaternion);
      DSMath.TypeCheck(iS, true, 'number');

      this.s += iQ.s * iS;
      this.x += iQ.x * iS;
      this.y += iQ.y * iS;
      this.z += iQ.z * iS;

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method multiply
    * @instance
    * @description
    * Multiplies <i>this</i> quaternion by another quaternion.
    *<br>
    * The multiplication is not commutative.
    * @param {DSMath.Quaternion} iQ            The quaternion <i>this</i> is to be multiplied by.
    * @param {Boolean}                        [iLeft=false] false if the multiplication is made on the right of <i>this</i>, true otherwise.
    * @example
    * var q0 = new DSMath.Quaternion();
    * q0.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
    * var q1 = new DSMath.Quaternion();
    * q1.makeRotation(DSMath.Vector3D.xVect, Math.PI);
    * var q2 = q0.multiply(q1); // q2===q0 and q2=(s=0,x=1/&#8730;2,y=1/&#8730;2,z=0)
    * @returns {DSMath.Quaternion} <i>this</i> modified quaternion reference.
    */
    Quaternion.prototype.multiply = function (iQ, iLeft)
    {
      DSMath.TypeCheck(iQ, true, DSMath.Quaternion);
      DSMath.TypeCheck(iLeft, false, Boolean);

      iLeft = iLeft || false;

      var left = (iLeft) ? iQ : this;
      var right = (iLeft) ? this : iQ;

      var s = left.s;
      var x = left.x;
      var y = left.y;
      var z = left.z;

      var qs = right.s;
      var qx = right.x;
      var qy = right.y;
      var qz = right.z;

      this.s = s * qs - x * qx - y * qy - z * qz;
      this.x = s * qx + x * qs + y * qz - z * qy;
      this.y = s * qy - x * qz + y * qs + z * qx;
      this.z = s * qz + x * qy - y * qx + z * qs;

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method multiplyScalar
    * @instance
    * @description
    * Multiplies <i>this</i> quaternion coordinate by a value.
    * @param {Number}   iS                The value.
    * @param {Boolean} [iMultScalar=true] true if this.s has to be multiplied to, false otherwise.
    * @example
    * var q0 = new DSMath.Quaternion(1,2,3,4);
    * var q1 = q0.multiplyScalar(2,false);  // q1===q0 and q1=(s=1,x=4,y=6,z=8)
    * var q2 = q0.multiplyScalar(0.5,true); // q2===q1===q0 and q2=(s=0.5,x=2,y=3,z=4)
    * @returns {DSMath.Quaternion} <i>this</i> modified quaternion reference.
    */
    Quaternion.prototype.multiplyScalar = function (iS, iMultScalar)
    {
      DSMath.TypeCheck(iS, true, 'number');
      DSMath.TypeCheck(iMultScalar, true, Boolean);

      iMultScalar = (arguments.length < 2) ? true : iMultScalar;
      if (iMultScalar)
        this.s *= iS;

      this.x *= iS;
      this.y *= iS;
      this.z *= iS;

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method divideScalar
    * @instance
    * @description
    * Divides <i>this</i> quaternion coordinate by a value.
    * @param {Number}  iS The value.
    * @param {Boolean} [iDivScalar=true] true if this.s has to be divided to, false otherwise.
    * @example
    * var q0 = new DSMath.Quaternion(1,2,3,4);
    * var q1 = q0.divideScalar(0.5,false); // q1===q0 and q1=(s=1,x=4,y=6,z=8)
    * var q2 = q0.divideScalar(2,true);    // q2===q1===q0 and q2=(s=0.5,x=2,y=3,z=4)
    * @returns {DSMath.Quaternion} <i>this</i> modified quaternion reference.
    */
    Quaternion.prototype.divideScalar = function (iS, iDivScalar)
    {
      DSMath.TypeCheck(iS, true, 'number');
      DSMath.TypeCheck(iDivScalar, false, Boolean);

      iDivScalar = (arguments.length < 2) ? true : iDivScalar;
      if (iDivScalar)
        this.s /= iS;

      this.x /= iS;
      this.y /= iS;
      this.z /= iS;

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method conjugate
    * @instance
    * @description
    * Calculates the conjugate of a quaternion.
    * <pre>
    * q_conj = [ s, -x, -y, -z ]
    * </pre>
    * @example
    * var q0 = new DSMath.Quaternion(1,2,3,4);
    * var q1 = q0.conjugate(); // q1===q0 and q1=(s=1,x=-2,y=-3,z=-4)
    * @returns {DSMath.Quaternion} <i>this</i> modified quaternion reference.
    */
    Quaternion.prototype.conjugate = function ()
    {
      this.x *= -1;
      this.y *= -1;
      this.z *= -1;
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method dot
    * @instance
    * @description
    * Dot product between <i>this</i> quaternion and another one.
    * @param {DSMath.Quaternion} iQ The quaternion.
    * @example
    * var q0 = new DSMath.Quaternion(1,2,3,4);
    * var q1 = new DSMath.Quaternion(5,6,7,8);
    * var dotq0q1 = q0.dot(q1); // dotq0q1=70
    * @returns {Number} the dot product result
    */
    Quaternion.prototype.dot = function (iQ)
    {
      DSMath.TypeCheck(iQ, true, DSMath.Quaternion);

      var dotResult = this.s * iQ.s + this.x * iQ.x + this.y * iQ.y + this.z * iQ.z;
      return dotResult;
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method lerp
    * @instance
    * @description
    * Computes a linear interpolation from <i>this</i> unit quaternion to another unit quaternion which is normalized.
    * <br>
    * If the quaternions are not a unit quaternion, the computation will use their normalized form.
    * <br>
    * This is faster than slerp but looks worse if the rotations are far apart.
    * @example
    * var q0 = new DSMath.Quaternion();
    * q0.makeRotationFromVectors(DSMath.Vector3D.xVect, DSMath.Vector3D.yVect);
    * var q1 = new DSMath.Quaternion();
    * q1.makeRotationFromVectors(DSMath.Vector3D.yVect, DSMath.Vector3D.zVect);
    * var qInt = q0.lerp(q1,0.5); // q0===qInt and qInt=(s=2/&#8730;6,x=1/&#8730;6,y=0,z=1/&#8730;6)
    * @param {DSMath.Quaternion} iQ               The unit quaternion to be used with <i>this</i> in the slerp computation.
    * @param {Number}            iT               The scalar between [0,1]. If equals to 0 <i>this</i> stays unchanged, if equals to 1 <i>this</i> becomes a copy of iQ.
    * @param {Boolean}           [iShorter=true]  If true, the interpolation will use -iQ instead of iQ if it is closer to <i>this</i>. Note -iQ and iQ represent the same rotation. If false, basic lerp is performed.
    * @returns {DSMath.Quaternion } <i>this</i> modified quaternion reference.
    */
    Quaternion.prototype.lerp = function (iQ, iT, iShorter)
    {
      DSMath.TypeCheck(iQ, true, DSMath.Quaternion);
      DSMath.TypeCheck(iT, true, 'number');
      DSMath.TypeCheck(iShorter, false, Boolean);

      iShorter = (arguments.length < 3) ? true : iShorter;

      var norm = this.norm();
      var qNorm = iQ.norm();

      var cosTheta = this.dot(iQ) / (norm * qNorm);
      var sign = (cosTheta <= -DSMath.defaultTolerances.epsgForAngleTest && iShorter) ? -1 : 1;

      var a = (1 - iT) / norm;
      var b = sign * iT / qNorm;

      this.s = sign * (this.s * a + iQ.s * b);
      this.x = sign * (this.x * a + iQ.x * b);
      this.y = sign * (this.y * a + iQ.y * b);
      this.z = sign * (this.z * a + iQ.z * b);

      return this.normalize();
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method slerp
    * @instance
    * @description
    * Computes a spherical interpolation from <i>this</i> unit quaternion to another unit quaternion.
    * <br>
    * If the quaternion are not a unit quaternion, the computation will use their normalized form.
    * <br>
    * If the quaternion are colinear then the interpolation not possible so <i>this</i> stays unchanged.
    * @param {DSMath.Quaternion} iQ               The unit quaternion to be used with <i>this</i> in the slerp computation.
    * @param {Number}            iT               The scalar in [0,1]. If equals to 0 this stays unchanged, if equals to 1 <i>this</i> becomes a copy of iQ.
    * @param {Boolean}           [iShorter=true] If true, the interpolation will use -iQ instead of iQ if it is closer to <i>this</i>. Note -iQ and iQ represent the same rotation. If false, basic slerp is performed.
    
    * @example
    * var q0 = new DSMath.Quaternion();
    * q0.makeRotationFromVectors(DSMath.Vector3D.xVect, DSMath.Vector3D.yVect);
    * var q1 = new DSMath.Quaternion();
    * q1.makeRotationFromVectors(DSMath.Vector3D.yVect, DSMath.Vector3D.zVect);
    * var qInt = q0.slerp(q1,0.4); // q0===qInt and qInt=(s=0.812023,x=0.3320,y=0,z=0.479924)
    * @returns {DSMath.Quaternion } <i>this</i> modified quaternion reference.
    */
    Quaternion.prototype.slerp = function (iQ, iT, iShorter)
    {
      DSMath.TypeCheck(iQ, true, DSMath.Quaternion);
      DSMath.TypeCheck(iT, true, 'number');
      DSMath.TypeCheck(iShorter, false, Boolean);

      iShorter = (arguments.length < 3) ? true : iShorter;

      var norm = this.norm();
      var normQ = iQ.norm();

      // cos(angle) between the two unit quaternions.
      var cosTheta = this.dot(iQ) / (norm * normQ);

      // Colinear quaternion represent the same rotation so no interpolation is needed.
      if (cosTheta * cosTheta < 1 - DSMath.defaultTolerances.epsgForSquareAngleTest)
      {
        var invSign = (cosTheta <= -DSMath.defaultTolerances.epsgForAngleTest && iShorter) ? -1 : 1; // We choose the shorter path.
        var Theta = Math.acos(invSign * cosTheta);
        var sinTheta = Math.sqrt(1.0 - cosTheta * cosTheta);

        var ratioA = Math.sin((1 - iT) * Theta) / (sinTheta * norm);
        var ratioB = invSign * Math.sin(iT * Theta) / (sinTheta * normQ);

        this.s = invSign * (this.s * ratioA + iQ.s * ratioB);
        this.x = invSign * (this.x * ratioA + iQ.x * ratioB);
        this.y = invSign * (this.y * ratioA + iQ.y * ratioB);
        this.z = invSign * (this.z * ratioA + iQ.z * ratioB);
      } else
      {
        if (iT == 1 && !iShorter)
          this.copy(iQ).divideScalar(normQ);
        else
          this.divideScalar(norm);
      }

      return this;
    };

    /**-----------------------------------------
     * -------------- STATIC -------------------
     * -----------------------------------------
     */
    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method makeRotation
    * @static
    * @description
    * Creates a Quaternion than represents the rotation by the angle around the axis given.
    * @param {DSMath.Vector3D} iAxis The axis of the rotation.
    * @param {Number} iAngle The angle of the rotation
    * @example
    * var q0 = DSMath.Quaternion.makeRotation(DSMath.Vector3D.zVect, Math.PI/2); // q0=(s=1/&#8730;2,x=0,y=0,z=1/&#8730;2)
    * @returns {DSMath.Quaternion} The created quaternion.
    */
    Quaternion.makeRotation = function (iAxis, iAngle)
    {
      DSMath.TypeCheck(iAxis, true, DSMath.Vector3D);
      DSMath.TypeCheck(iAngle, true, 'number');

      var result = new Quaternion();
      return result.makeRotation(iAxis, iAngle);
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method makeRotationFromVectors
    * @static
    * @description
    * Creates a Quaternion than represents the rotation which transforms iFromVector to iToVector.
    * @param {DSMath.Vector3D} iFromVector The vector before the transformation.
    * @param {DSMath.Vector3D} iToVector The vector after the transformation.
    * @example
    * var v0 = new DSMath.Vector3D(1,0,0);
    * var v1 = new DSMath.Vector3D(0,1,0);
    * var q0 = DSMath.Quaternion.makeRotationFromVectors(v0, v1); // q0=(s=1/&#8730;2,x=0,y=0,z=1/&#8730;2) <=> rotation PI/2 of (0,0,1) axis.
    * @returns {DSMath.Quaternion} The created quaternion.
    */
    Quaternion.makeRotationFromVectors = function (iFromVector, iToVector)
    {
      DSMath.TypeCheck(iFromVector, true, DSMath.Vector3D);
      DSMath.TypeCheck(iToVector, true, DSMath.Vector3D);

      var result = new Quaternion();
      return result.makeRotationFromVectors(iFromVector, iToVector);
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method multiply
    * @static
    * @description
    * Multiplies two quaternions.
    * <br>
    * The multiplication is not commutative.
    * @param {DSMath.Quaternion} iQLeft  The first quaternion.
    * @param {DSMath.Quaternion} iQRight The second quaternion.
    * @param {DSMath.Quaternion} [oQ]    Reference of the operation result (avoid allocation)
    * @example
    * var q0 = new DSMath.Quaternion();
    * q0.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
    * var q1 = new DSMath.Quaternion();
    * q1.makeRotation(DSMath.Vector3D.xVect, Math.PI);
    * var q2 = DSMath.Quaternion.multiply(q0, q1); // q2!==q0 and q2=(s=0,x=1/&#8730;2,y=1/&#8730;2,z=0)
    * @returns {DSMath.Quaternion} The reference of the operation result.
    */
    Quaternion.multiply = function (iQLeft, iQRight, oQ)
    {
      DSMath.TypeCheck(iQLeft, true, DSMath.Quaternion);
      DSMath.TypeCheck(iQRight, true, DSMath.Quaternion);
      DSMath.TypeCheck(oQ, false, DSMath.Quaternion);

      oQ = (oQ) ? (oQ === iQRight) ? oQ.multiply(iQLeft, true) : oQ.copy(iQLeft).multiply(iQRight)
               : iQLeft.clone().multiply(iQRight);
      return oQ;
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method lerp
    * @static
    * @description
    * Computes a linear interpolation between two unit quaternions which is normalized after.
    * <br>
    * If the quaternions are not a unit quaternions, the computation will use their normalized form.
    * <br>
    * This is faster than slerp but looks worse if the rotations are far apart.
    * @param {DSMath.Quaternion} iQStart          The quaternion when the interpolation begins.
    * @param {DSMath.Quaternion} iQEnd            The quaternion when the interpolation ends.
    * @param {Number}            iT               The scalar in [0,1].
    * @param {Boolean}           [iShorter=true]  If true, the interpolation will use -iQ instead of iQ if it is closer to <i>this</i>. Note -iQ and iQ represent the same rotation. If false, basic lerp is performed.
    * @param {DSMath.Quaternion} [oQ]             Reference of the operation result (avoid allocation)
    * @example
    * var q0 = new DSMath.Quaternion();
    * q0.makeRotationFromVectors(DSMath.Vector3D.xVect, DSMath.Vector3D.yVect);
    * var q1 = new DSMath.Quaternion();
    * q1.makeRotationFromVectors(DSMath.Vector3D.yVect, DSMath.Vector3D.zVect);
    * var qInt = DSMath.Quaternion.lerp(q0,q1,0.5); // q0!==qInt and qInt=(s=2/&#8730;6,x=1/&#8730;6,y=0,z=1/&#8730;6)
    * @returns {DSMath.Quaternion } The reference of the operation result.
    */
    Quaternion.lerp = function (iQStart, iQEnd, iT, iShorter, oQ)
    {
      DSMath.TypeCheck(iQStart, true, DSMath.Quaternion);
      DSMath.TypeCheck(iQEnd, true, DSMath.Quaternion);
      DSMath.TypeCheck(iT, true, 'number');
      DSMath.TypeCheck(iShorter, false, Boolean);
      DSMath.TypeCheck(oQ, false, DSMath.Quaternion);

      iShorter = (arguments.length < 4) ? true : iShorter;
      oQ = (oQ) ? (oQ === iQEnd) ? oQ.lerp(iQStart, 1 - iT, iShorter) : oQ.copy(iQStart).lerp(iQEnd, iT, iShorter)
               : iQStart.clone().lerp(iQEnd, iT, iShorter);
      return oQ;
    };

    /**
    * @public
    * @memberof DSMath.Quaternion
    * @method slerp
    * @static
    * @description
    * Computes a sherical interpolation between two unit quaternions.
    * <br>
    * If the quaternion are not a unit quaternion, the computation will use their normalized form.
    * <br>
    * If the quaternion are colinear then the interpolation not possible so this stays unchanged.
    * @param {DSMath.Quaternion} iQStart          The quaternion when the interpolation begins.
    * @param {DSMath.Quaternion} iQEnd            The quaternion when the interpolation ends;
    * @param {Number}            iT               The scalar in [0,1]. If equals to 0 return iQStart, 1 return iQEnd.
    * @param {Boolean}           [iShorter=true]  If true, the interpolation will use -iQ instead of iQ if it is closer to <i>this</i>. Note -iQ and iQ represent the same rotation. If false, basic slerp is performed.
    * @param {DSMath.Quaternion} [oQ]             Reference of the operation result (avoid allocation)
    * @example
    * var q0 = new DSMath.Quaternion();
    * q0.makeRotationFromVectors(DSMath.Vector3D.xVect, DSMath.Vector3D.yVect);
    * var q1 = new DSMath.Quaternion();
    * q1.makeRotationFromVectors(DSMath.Vector3D.yVect, DSMath.Vector3D.zVect);
    * var qInt = DSMath.Quaternion.slerp(q0,q1,0.4); // q0!==qInt and qInt=(s=0.812023,x=0.3320,y=0,z=0.479924)
    * @returns {DSMath.Quaternion } The reference of the operation result.
    */
    Quaternion.slerp = function (iQStart, iQEnd, iT, iShorter, oQ)
    {
      DSMath.TypeCheck(iQStart, true, DSMath.Quaternion);
      DSMath.TypeCheck(iQEnd, true, DSMath.Quaternion);
      DSMath.TypeCheck(iT, true, 'number');
      DSMath.TypeCheck(iShorter, false, Boolean);
      DSMath.TypeCheck(oQ, false, DSMath.Quaternion);

      iShorter = (arguments.length < 4) ? true : iShorter;
      oQ = (oQ) ? (oQ === iQEnd) ? oQ.slerp(iQStart, 1 - iT, iShorter) : oQ.copy(iQStart).slerp(iQEnd, iT, iShorter)
               : iQStart.clone().slerp(iQEnd, iT, iShorter);
      return oQ;
    };

    DSMath.Quaternion = Quaternion;

    return Quaternion;
  }
);

