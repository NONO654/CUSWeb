define('MathematicsES/TransformationJSImpl',
  ['MathematicsES/MathNameSpace',
   'MathematicsES/MathTypeCheck',
   'MathematicsES/MathTypeCheckInternal',
   'MathematicsES/MathPointJSImpl',
   'MathematicsES/MathVector3DJSImpl',
   'MathematicsES/MathMat3x3JSImpl',
   'MathematicsES/MathLineJSImpl',
   'MathematicsES/MathAxisJSImpl'
  ],
  
  function (DSMath, TypeCheck, TypeCheckInternal, Point, Vector3D, Matrix3x3, Line, Axis)
  {
    'use strict';

    /**
    * @public
    * @exports Transformation
    * @class
    * @classdesc Representation of a transformation in 3D that can be represented by a Matrix3x3 an a Vector3D.
    *
    * @constructor
    * @constructordesc
    * The DSMath.Transformation constructor creates a transformation in 3D, which is represented by a Matrix3x3 and a Vector3D.
    * @param {DSMath.Matrix3x3} [iM] The transformation matrix. Note the content of the matrix given is duplicated so <i>this</i>.matrix!==iM.
    * @param {DSMath.Vector3D}  [iV] The transformation vector. Note the content of the vector given is duplicated so <i>this</i>.vector!==iV.
    * @memberof DSMath
    */
    var Transformation = function (iM, iV)
    {
      DSMath.TypeCheck(iM, false, DSMath.Matrix3x3);
      DSMath.TypeCheck(iV, false, DSMath.Vector3D);

      this.matrix = (iM) ? iM.clone() : Matrix3x3.identity.clone();
      this.vector = (iV) ? iV.clone() : new Vector3D(0, 0, 0);
    };

    Transformation.prototype.constructor = Transformation;

    /**
    * The matrix properties of the Transformation. It represents the change of axes.
    * @public
    * @member
    * @instance
    * @name matrix
    * @type {DSMath.Matrix3x3}
    * @memberOf DSMath.Transformation
    */
    Transformation.prototype.matrix = null;

    /**
    * The vector properties of the Transformation. It represents the translation.
    * @public
    * @member
    * @instance
    * @name vector
    * @type {DSMath.Vector3D}
    * @memberOf DSMath.Transformation
    */
    Transformation.prototype.vector = null;

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method clone
    * @instance
    * @description
    * Clones <i>this</i> Transformation.
    * @example
    * var t0 = DSMath.Transformation.makeRotation(DSMath.Vector3D.zVect, Math.PI/2).setVector(1,2,3);
    * var t1 = t0.clone(); // t1==t0 but t1!==t0;
    * @returns {DSMath.Transformation} The cloned Transformation.
    */
    Transformation.prototype.clone = function ()
    {
      var oT = new Transformation();
      return oT.copy(this);
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method copy
    * @instance
    * @description
    * Copies the given Transformation.
    * @param {DSMath.Transformation} iT The transformation.
    * @example
    * var t0 = DSMath.Transformation.makeRotation(DSMath.Vector3D.zVect, Math.PI/2).setVector(1,2,3);
    * var t1 = new DSMath.Transformation();
    * t1.copy(t0); // t1==t0 but t1!==t0;
    * @returns {DSMath.Transformation} <i>this</i> modified transformation reference.
    */
    Transformation.prototype.copy = function (iToCopy)
    {
      DSMath.TypeCheck(iToCopy, true, DSMath.Transformation);

      this.matrix.copy(iToCopy.matrix);
      this.vector.copy(iToCopy.vector);
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method setRotation
    * @instance
    * @description
    * Sets the transformation matrix coef to represent the rotation specified by an axis and angle.
    * @param {DSMath.Vector3D} iAxis  The axis of the rotation.
    * @param {Number}          iAngle The angle of the rotation
    * @example
    * var t0 = new DSMath.Transformation();
    * t0.setRotation(DSMath.Vector3D.zVect, Math.PI/2); // t0.matrix=[0,-1,0,1,0,0,0,0,1]
    * @returns {DSMath.Transformation} <i>this</i> modified transformation reference
    */
    Transformation.prototype.setRotation = function (iAxis, iAngle)
    {
      DSMath.TypeCheck(iAxis, true, DSMath.Vector3D);
      DSMath.TypeCheck(iAngle, true, 'number');

      this.matrix.makeRotation(iAxis, iAngle);
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method setRotationFromEuler
    * @instance
    * @description
    * <i>This</i> transformation matrix becomes a rotation equals to the rotation combination defined from euler angles ZXY.
    * @param {Number[]} iE The array of euler angles ZXY.
    * @example
    * var t0 = new DSMath.Transformation();
    * var t1 = t0.setRotationFromEuler([-Math.PI/4, Math.PI/4, Math.PI/2]); // t1===t0
    * // t0.matrix=|0.5, 0.5, 1/&#8730;2|
    * //           |0.5, 0.5,-1/&#8730;2|
    * //           |-1/&#8730;2, 1/&#8730;2, 0|
    * @returns {DSMath.Transformation} <i>this</i> modified transformation reference
    */
    Transformation.prototype.setRotationFromEuler = function (iE)
    {
      DSMath.TypeCheck(iE, true, ['number'], 3);

      this.matrix.makeRotationFromEuler(iE);
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method setVector
    * @instance
    * @description
    * Assigns new coordinates values to <i>this</i> transformation vector.
    * @param {Number | DSMath.Vector3D} iX Value for the x coordinate or the vector to copy.
    * @param {Number} [iY=0] Value for the y coordinate. Not used if iX is a Vector3D.
    * @param {Number} [iZ=0] Value for the z coordinate. Not used if iX is a Vector3D.
    * @example
    * var t0 = DSMath.Transformation.makeRotationFromEuler([Math.PI/2,0,0]).setVector(1,2,3);
    * @returns {DSMath.Transformation} <i>this</i> modified transformation reference
    */
    Transformation.prototype.setVector = function (iX, iY, iZ)
    {
      DSMath.TypeCheck(iX, true, ['number', DSMath.Vector3D]);
      DSMath.TypeCheck(iY, false, 'number');
      DSMath.TypeCheck(iZ, false, 'number');

      if (iX.constructor === Vector3D)
        this.vector.copy(iX);
      else
        this.vector.set(iX, iY || 0, iZ || 0);

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method makeScaling
    * @instance
    * @description
    * <i>This</i> transformation becomes a scaling of scale given at the center given.
    * @param {Number}                    iScale            The scale of the scaling.
    * @param {DSMath.Point} [iCenter=(0,0,0)] The center of the scaling.
    * @example
    * var t0 = DSMath.Transformation.makeRotationFromEuler([Math.PI/2,0,0]).setVector(1,2,3);
    * var t1 = t0.makeScaling(2, new DSMath.Point(0,1,0)); // t1===t0 and
    * //t1.matrix=| 2, 0, 0|
    * //          | 0, 2, 0|
    * //          | 0, 0, 2|
    * //t1.vector=[ 0,-1, 0]
    * @returns {DSMath.Transformation} <i>this</i> modified transformation reference.
    */
    Transformation.prototype.makeScaling = function (iScale, iCenter)
    {
      DSMath.TypeCheck(iScale, true, 'number');
      DSMath.TypeCheck(iCenter, false, DSMath.Point);

      this.matrix.makeScaling(iScale);

      if (iCenter)
      {
        iCenter.sub(Point.origin, this.vector);
        this.vector.multiplyScalar(1 - iScale);
      }
      else
      {
        this.vector.set(0, 0, 0);
      }
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method makeRotation
    * @instance
    * @description
    * <i>This</i> transformation becomes a rotation by the angle around the axis given at the given point.
    * @param {DSMath.Vector3D} iAxis             The axis of the rotation.
    * @param {Number}                       iAngle            The angle of the rotation.
    * @param {DSMath.Point} [iCenter=(0,0,0)] The center of the rotation.
    * @example
    * var t0 = new DSMath.Transformation();
    * var t1 = t0.makeRotation(DSMath.Vector3D.zVect, Math.PI/2); // t1===t0 and t1.matrix=[0,-1,0,1,0,0,0,0,1] and t1.vector=[0,0,0]
    * var t2 = new DSMath.Transformation().makeRotation(DSMath.Vector3D.zVect, Math.PI/2, new DSMath.Point(1,1,1)); // t2.matrix==t0.matrix but t2.vector=[2,0,0]
    * @returns {DSMath.Transformation} <i>this</i> modified transformation reference.
    */
    Transformation.prototype.makeRotation = function (iAxis, iAngle, iCenter)
    {
      DSMath.TypeCheck(iAxis, true, DSMath.Vector3D);
      DSMath.TypeCheck(iAngle, true, 'number');
      DSMath.TypeCheck(iCenter, false, DSMath.Point);

      this.setRotation(iAxis, iAngle);
      if (iCenter)
      {
        var tmp = iCenter.clone().applyMatrix3x3(this.matrix);
        
        //this.vector.setFromPoint(iCenter).sub(tmp);
         iCenter.sub(tmp, this.vector); // Q48 (23/01/19): changed for type consistency
      }
      else
      {
        this.vector.set(0, 0, 0);
      }
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method makeRotationFromEuler
    * @instance
    * @description
    * <i>This</i> transformation becomes a rotation combination defined from euler angles ZXY at the given point.
    * @param {Number[]}                 iE                The array of euler angles ZXY.
    * @param {DSMath.Point} [iCenter=(0,0,0)] The center of the rotation.
    * @example
    * var t0 = new DSMath.Transformation();
    * var t1 = t0.makeRotationFromEuler([-Math.PI/4, Math.PI/4, Math.PI/2], new DSMath.Point(1,1,1)); // t1===t0
    * // t1.matrix=|0.5, 0.5, 1/&#8730;2|
    * //           |0.5, 0.5,-1/&#8730;2|
    * //           |-1/&#8730;2, 1/&#8730;2, 0|
    * // t1.vector=[-1/&#8730;2,1/&#8730;2,1]
    * @returns {DSMath.Transformation} <i>this</i> modified transformation reference
    */
    Transformation.prototype.makeRotationFromEuler = function (iE, iCenter)
    {
      DSMath.TypeCheck(iE, true, ['number'], 3);
      DSMath.TypeCheck(iCenter, false, DSMath.Point);

      this.setRotationFromEuler(iE);
      if (iCenter)
      {
        var tmp = iCenter.clone().applyMatrix3x3(this.matrix);
        //this.vector.setFromPoint(iCenter).sub(tmp);
        iCenter.sub(tmp, this.vector); // Q48 (23/01/19: changed for TypeChecking
      } 
      else
      {
        this.vector.set(0, 0, 0);
      }
      return this;
    };

    /**
    * @memberof DSMath.Transformation
    * @method setFromArray
    * @instance
    * @description
    * Modifies the transformation vector and matrix by specifying a set of 12 coefficients.
    * @param {Number[]} iCoef     The array of 12 coefficients.
    * @param {Number}   [iMode=0] 0 if the array is sorted by column [c00,c10,c20,c01,c11,c12,c02,c12,c22,c03,c13,c23], 1 if the array is sorted by line.
    * <br>
    * If the array has a size of 16 (transformation represented by a matrix 4D), then the last line will not be taken into account.
    * @example
    * var t0 = new DSMath.Transformation();
    * var t1 = t0.setFromArray([1,2,3,4,5,6,7,8,9, 10,11,12]);   // t1===t0 and t1.matrix=[1,4,7,2,5,8,3,6,9]   and t1.vector=[10,11,12]
    * var t2 = t0.setFromArray([1,2,3,4,5,6,7,8,9, 10,11,12],1); // t2===t0 and t2.matrix=[1,2,3,5,6,7,9,10,11] and t2.vector=[4,8,12]
    * var t3 = t0.setFromArray([1,2,3, 0,4,5,6, 0,7,8,9, 0,10,11,12,0]);   // t3===t0 and t3.matrix=[1,4,7,2,5,8,3,6,9] and t3.vector=[10,11,12];
    * var t4 = t0.setFromArray([1,2,3,10,4,5,6,11,7,8,9,12, 0, 0, 0,0],1); // t4===t0 and t4.matrix=[1,2,3,4,5,6,7,8,9] and t4.vector=[10,11,12];
    * @returns {DSMath.Transformation} <i>this</i> modified transformation reference
    */
    Transformation.prototype.setFromArray = function (iCoef, iMode)
    {
      DSMath.TypeCheck(iCoef, true, ['number'], 12);
      DSMath.TypeCheck(iMode, false, 'number');

      var c = this.matrix.coef;
      var v = this.vector;
      iMode = iMode || 0;

      if (iMode == 1)
      {
        c[0] = iCoef[0]; c[1] = iCoef[1]; c[2] = iCoef[2]; v.x = iCoef[3];
        c[3] = iCoef[4]; c[4] = iCoef[5]; c[5] = iCoef[6]; v.y = iCoef[7];
        c[6] = iCoef[8]; c[7] = iCoef[9]; c[8] = iCoef[10]; v.z = iCoef[11];
      } else
      {
        var shift = (iCoef.length == 16 && iMode == 0) ? 1 : 0;
        var delta = shift;
        c[0] = iCoef[0]; c[3] = iCoef[1]; c[6] = iCoef[2];
        c[1] = iCoef[3 + delta]; c[4] = iCoef[4 + delta]; c[7] = iCoef[5 + delta]; delta += shift;
        c[2] = iCoef[6 + delta]; c[5] = iCoef[7 + delta]; c[8] = iCoef[8 + delta]; delta += shift;
        v.x = iCoef[9 + delta]; v.y = iCoef[10 + delta]; v.z = iCoef[11 + delta];
      }
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method getArray
    * @instance
    * @description
    * Retrieves the transformation vector and matrix under the form of an array of 12 values.
    * @param {Number} [iMode=0] 0 if the array has to be sorted by column [c00,c10,c20,c01,c11,c12,c02,c12,c22,c03,c13,c23], 1 if it has to be sorted by line.
    * @example
    * var t0 = DSMath.Transformation.makeRotationFromEuler([Math.PI/2,0,0]).setVector(1,2,3);
    * var t0CoefCol  = t0.getArray();  // t0CoefCol =[0,1,0, -1,0,0, 0,0,1, 1,2,3]
    * var t0CoefLine = t0.getArray(1); // t0CoefLine=[0,-1,0,1, 1,0,0,2, 0,0,1,3]
    * @returns { Number[] } oCoef An array of 12 coefficients.
    */
    Transformation.prototype.getArray = function (iMode)
    {
      DSMath.TypeCheck(iMode, false, 'number');

      var c = this.matrix.coef;
      var v = this.vector;
      iMode = iMode || 0;

      var result = null;
      if (iMode == 0)
      {
        result = [c[0], c[3], c[6],
                  c[1], c[4], c[7],
                  c[2], c[5], c[8],
                  v.x, v.y, v.z];
      } else
      {
        result = [c[0], c[1], c[2], v.x,
                  c[3], c[4], c[5], v.y,
                  c[6], c[7], c[8], v.z];
      }

      return result;
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method getEuler
    * @instance
    * @description
    * Computes the ZXY Euler angles (in radian) associated to <i>this</i> rotation matrix.
    * <br>
    * The transformation matrix has to be a rotation to retrieve a consistent result.
    * @example
    * var t0 = DSMath.Transformation.makeRotation(new DSMath.Vector3D(Math.SQRT1_2, Math.SQRT1_2, 0), Math.PI/2);
    * var eulerAngles = t0.getEuler(); // eulerAngles=[Az=-Math.PI/4, Ax=Math.PI/4, Ay=Math.PI/2]
    * @returns {Number[]} The array of euler angles ZXY.
    */
    Transformation.prototype.getEuler = function ()
    {
      return this.matrix.getEuler();
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method inverse
    * @instance
    * @description
    * Inverses <i>this</i> transformation
    * @example
    * var t0 = DSMath.Transformation.makeRotation(new DSMath.Vector3D(Math.SQRT1_2, Math.SQRT1_2, 0), Math.PI/2).setVector(1,2,3);
    * var t1 = t0.inverse(); //t1===t0
    * //t1.matrix=| 0.5, 0.5, -1/&#8730;2|
    * //          | 0.5, 0.5, 1/&#8730;2|
    * //          | 1/&#8730;2, -1/&#8730;2, 0|
    * //t1.vector=[-1.5*(1-&#8730;2),-1.5*(1+&#8730;2),1/&#8730;2]
    * @returns {DSMath.Transformation} <i>this</i> modified transformation reference.
    */
    Transformation.prototype.inverse = function ()
    {
      this.matrix.inverse();
      this.vector.applyMatrix3x3(this.matrix).negate();
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method getInverse
    * @instance
    * @description
    * Returns the inverse of <i>this</i> Transformation
    * <br>
    * If <i>this</i> transformation is not inversible, the returned transformation will be a copy of <i>this</i>
    * @param {DSMath.Transformation} [oT] Reference of the operation result (avoid allocation).
    * @example
    * var t0 = DSMath.Transformation.makeRotation(new DSMath.Vector3D(Math.SQRT1_2, Math.SQRT1_2, 0), Math.PI/2).setVector(1,2,3);
    * var t1 = t0.getInverse(); //t1!=t0
    * //t1.matrix=| 0.5, 0.5, -1/&#8730;2|
    * //          | 0.5, 0.5, 1/&#8730;2|
    * //          | 1/&#8730;2, -1/&#8730;2, 0|
    * //t1.vector=[-1.5*(1-&#8730;2),-1.5*(1+&#8730;2),1/&#8730;2]
    * @returns {DSMath.Transformation} The reference of the operation result.
    */
    Transformation.prototype.getInverse = function (oT)
    {
      DSMath.TypeCheck(oT, false, DSMath.Transformation);

      oT = (oT) ? oT.copy(this) : this.clone();
      return oT.inverse();
    };


    /**
    * @public
    * @memberof DSMath.Transformation
    * @method multiply
    * @instance
    * @description
    * Compose <i>this</i> transformation with another one given.
    * @param {DSMath.Transformation} iT The other transformation <i>this</i> is to be multiplied by.
    * @param {Boolean} [iLeft=false] false if the composition is made on the right of <i>this</i>, true otherwise.
    * @example
    * var t0 = DSMath.Transformation.makeRotationFromEuler([Math.PI/2,0,0]).setVector(1,2,3);
    * var t0bis = t0.clone();
    * var t1 = new DSMath.Transformation();
    * t1.matrix.makeDiagonal(4,5,6);
    * var t2 = t0.multiply(t1); // t2===t0 and
    * //t2.matrix=| 0,-5, 0|
    * //          | 4, 0, 0|
    * //          | 0, 0, 6|
    * //t2.vector=[1 , 2, 3]
    * t2 = t0bis.multiply(t1,true); // <=>t1.multiply(t0);
    * //t2.matrix=| 0,-4, 0|
    * //          | 5, 0, 0|
    * //          | 0, 0, 6|
    * //t2.vector=[4, 10 ,18]
    * @returns {DSMath.Transformation} <i>this</i> modified transformation reference.
    */
    Transformation.prototype.multiply = function (iT, iLeft)
    {
      DSMath.TypeCheck(iT, true, DSMath.Transformation);
      DSMath.TypeCheck(iLeft, false, Boolean);

      iLeft = iLeft || false;

      if (!iLeft)
      {
        var tmpVect = iT.vector.clone().applyMatrix3x3(this.matrix);
        this.vector.add(tmpVect);
      } 
      else
      {
        var vector = (iT.vector === this) ? this.vector.clone() : this.vector;
        vector.applyMatrix3x3(iT.matrix).add(iT.vector);
        this.vector.copy(vector);
      }

      this.matrix.multiply(iT.matrix, iLeft);

      return this;
    };

    /**
    * @memberof DSMath.Transformation
    * @method multiplyByEuler
    * @instance
    * @description
    * Compose <i>this</i> transformation on the right with the rotation defined by euler angles given.
    * @param {Number[]} iE            The array of euler angles ZXY.
    * @param {Boolean}   [iLeft=false] false if the composition is made on the right of <i>this</i>, true otherwise.
    * @example
    * var t0 = new DSMath.Transformation();
    * t0.matrix.makeDiagonal(1,2,3);
    * var t1 = t0.multiplyByEuler([Math.PI/2,0,0]); // t1===t0 and t0.matrix=[0,-1,0, 2,0,0, 0,0,3].
    * @returns {DSMath.Transformation} <i>this</i> modified transformation reference
    */
    Transformation.prototype.multiplyByEuler = function (iE, iLeft)
    {
      DSMath.TypeCheck(iE, true, ['number'], 3);
      DSMath.TypeCheck(iLeft, false, Boolean);

      // A optimiser pour donner de l'interet...
      var tmp = Transformation.makeRotationFromEuler(iE);
      return this.multiply(tmp, iLeft);
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method multiplyByScaling
    * @instance
    * @description
    * Compose <i>this</i> transformation on the right with the scaling at the center given.
    * @param {Number}                    iScale            The scale of the scaling.
    * @param {DSMath.Point} [iCenter=(0,0,0)] The center of the scaling.
    * @param {Boolean}                   [iLeft=false]     false if the composition is made on the right of <i>this</i>, true otherwise.
    * @example
    * var t0 = DSMath.Transformation.makeRotationFromEuler([Math.PI/2,0,0]);
    * var t1 = t0.multiplyByScaling(2, new DSMath.Point(0,1,0)); // t1===t0 and
    * //t1.matrix=| 0,-2, 0|
    * //          | 2, 0, 0|
    * //          | 0, 0, 2|
    * //t1.vector=[1, 0, 0]
    * @returns {DSMath.Transformation} <i>this</i> modified transformation reference.
    */
    Transformation.prototype.multiplyByScaling = function (iScale, iCenter, iLeft)
    {
      DSMath.TypeCheck(iScale, true, 'number');
      DSMath.TypeCheck(iCenter, false, DSMath.Point);
      DSMath.TypeCheck(iLeft, false, Boolean);

      // A optimiser pour donner de l'interet...
      iLeft = iLeft || false;
      var tmp = Transformation.makeScaling(iScale, (iCenter) ? iCenter : undefined);
      return this.multiply(tmp, iLeft);
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method getScaling
    * @instance
    * @description
    * Retrieves the scaling information from <i>this</i> transformation.
    * <br>
    * <i>this</i>.isScaling() must be true to have a consistent result.
    * @example
    * var r2 = Math.SQRT2;
    * var m0 = new DSMath.Matrix3x3(2,0,0, 0,2,0, 0,0,2);  // Scaling
    * var m1 = new DSMath.Matrix3x3(2,0,0, 0,2,0, 0,0,-2);// Reflection*Scaling
    * var m2 = new DSMath.Matrix3x3(0,-2,0, 2,0,0, 0,0,2); // Rotation*Scaling
    * var m3 = new DSMath.Matrix3x3(-r2,-r2,0, -r2,r2,0, 0,0,-2); // Reflection*Rotation*Scaling
    *
    * var t0 = new DSMath.Transformation(m0).setVector(-1,-1,-1);
    * var t1 = new DSMath.Transformation(m1).setVector(-1,-1,-1);
    * var t2 = new DSMath.Transformation(m2).setVector(-1,-1,-1);
    * var t3 = new DSMath.Transformation(m3).setVector(-1,-1,-1);
    *
    * var s0 = t0.getScaling(); // s0.scale=2, s0.center=[1,1,1]
    * var s1 = t1.getScaling(); // s1.scale=2, s1.center=[1,1,-1]
    * var s2 = t2.getScaling(); // s2.scale=2, s2.center=[1,-1,1]
    * var s3 = t3.getScaling(); // s3.scale=2, s3.center=[-&#8731;2,0,-1]
    * @returns {{scale: Number, center:DSMath.Point} } The scaling data information.
    * <br>
    * The scale returns is negative if <i>this</i>.isScaling() is false.
    */
    Transformation.prototype.getScaling = function ()
    {
      var result = { scale: -1, center: new DSMath.Point(0, 0, 0) };
      var epsgRel = DSMath.defaultTolerances.epsgForRelativeTest;

      if (this.matrix.isScaling(result))
      {
        // We compute the center if the scale is different of 1 (otherwise it can be everywhere).
        if (Math.abs(result.scale - 1) >= epsgRel)
        {
          var inv = this.matrix.getTranspose().multiplyScalar(1 / result.scale);
          result.center.set(this.vector.x, this.vector.y, this.vector.z);
          result.center.applyMatrix3x3(inv).divideScalar(1 - result.scale);
        }
      }
      else
      {
        result.scale = -1;
      }

      return result;
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method isScaling
    * @instance
    * @description
    * Determines whether <i>this</i> transformation performs a scaling or not.
    * <br>
    * The transformation performs a scaling if its matrix contains orthogonal vectors of the same norm.
    * @param {Object} [oS] Fill the properties "scale" of oS if <i>this</i> performs a scaling.
    * @example
    * var m0 = new DSMath.Matrix3x3(0,1,2,3,4,-5,-6,-7,-8);
    * var m1 = new DSMath.Matrix3x3(2,0,0, 0,-2,0, 0,0,-2);
    * var t0 = new DSMath.Transformation(m0).setVector(1,2,3);
    * var t1 = new DSMath.Transformation(m1).setVector(1,2,3);
    * var t0IsScaling = t0.isScaling(); // t0IsScaling==false
    * var t1IsScaling = t1.isScaling(); // t1IsScaling==true
    * @returns {Boolean} true if <i>this</i> performs a scaling, false otherwise.
    */
    Transformation.prototype.isScaling = function (oS)
    {
      DSMath.TypeCheck(oS, false, Object);

      return this.matrix.isScaling(oS);
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method isReflecting
    * @instance
    * @description
    * Determines whether <i>this</i> transformation performs a reflection or not.
    * <br>
    * The transformation performs a reflection if it contains orthogonal vectors of the same non null norm and has a negative determinant.
    * @example
    * var m0 = new DSMath.Matrix3x3(2,0,0, 0,2,0, 0,0,2);
    * var m1 = new DSMath.Matrix3x3(2,0,0, 0,2,0, 0,0,-2);
    * var t0 = new DSMath.Transformation(m0).setVector(1,2,3);
    * var t1 = new DSMath.Transformation(m1).setVector(1,2,3);
    * var t0IsReflecting = t0.isReflecting(); // t0IsReflecting==false
    * var t1IsReflecting = t1.isReflecting(); // t1IsReflecting==true
    * @returns {Boolean} true if <i>this</i> performs a reflection, false otherwise.
    */
    Transformation.prototype.isReflecting = function ()
    {
      return this.matrix.isReflecting();
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method isAScaling
    * @instance
    * @description
    * Determines whether <i>this</i> is only a scaling transformation and a translation.
    * <br>
    * The transformation is only a scaling if its matrix contains orthogonal vectors of the same norm and does not any reflection.
    * @param {Object} [oS] Fill the properties "scale" of oS if <i>this</i> performs at least a scaling.
    * @example
    * var m0 = new DSMath.Matrix3x3(2,0,0, 0,2,0, 0,0,2);
    * var m1 = new DSMath.Matrix3x3(2,0,0, 0,-2,0, 0,0,-2);
    *
    * var t0 = new DSMath.Transformation(m0);
    * var t1 = new DSMath.Transformation(m1);
    *
    * var t0IsAScaling = t0.isAScaling(); // t0IsAScaling==true
    * var t1IsAScaling = t1.isAScaling(); // t1IsAScaling==false
    * @returns {Boolean} true if <i>this</i> is a scaling, false otherwise.
    */
    Transformation.prototype.isAScaling = function (oS)
    {
      DSMath.TypeCheck(oS, false, Object);

      return this.matrix.isAScaling(oS);
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method isARotation
    * @instance
    * @description
    * Determines whether the <i>this</i> transformation is only a rotation transformation and a translation.
    * <br>
    * The transformation is only a rotation if its matrix is a direct isometry.
    * @param {RotationData} [oRotationData] Filled if given.
    * @example
    * var m0 = new DSMath.Matrix3x3(2,0,0, 0,2,0, 0,0,2);
    * var m1 = new DSMath.Matrix3x3(0,-1,0, 1,0,0, 0,0,1);
    * var m2 = new DSMath.Matrix3x3(-1,0,0 ,0,1,0, 0,0,1);
    * var t1Data = {angle:0, vector:new DSMath.Vector3D()};
    *
    * var t0 = new DSMath.Transformation(m0).setVector(1,2,3);
    * var t1 = new DSMath.Transformation(m1).setVector(1,2,3);
    * var t2 = new DSMath.Transformation(m2).setVector(1,2,3);
    *
    * var t0IsARotation = t0.isARotation();       // t0IsARotation==false
    * var t1IsARotation = t1.isARotation(t1Data); // t1IsARotation==true and t1Data={angle:PI/2,vector:[0,0,1]};
    * var t2IsARotation = t2.isARotation();       // t2IsARotation==false
    * @returns {Boolean} true if <i>this</i> is a rotation, false otherwise.
    */
    Transformation.prototype.isARotation = function (oRotationData)
    {
      DSMath.TypeCheck(oRotationData, false, Object);

      if (oRotationData)
        return this.matrix.isARotation(oRotationData);
      else
        return this.matrix.isARotation();
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method isIdentity
    * @instance
    * @description
    * Determines whether the <i>this</i> transformation is is the Identity transformation.
    * @example
    * var m0 = new DSMath.Matrix3x3(1,2,3, 4,5,6, 7,8,9);
    * var m1 = new DSMath.Matrix3x3(1,0,0, 0,1,0, 0,0,1);
    *
    * var t0 = new DSMath.Transformation(m0).setVector(1,2,3);
    * var t1 = new DSMath.Transformation(m1).setVector(1,2,3);
    *
    * var t0IsIdentity = t0.isIdentity(); // t0IsIdentity==false
    * var t1IsIdentity = t1.isIdentity(); // t1IsIdentity==true
    * @returns {Boolean} true if <i>this</i> is a the identity transformation, false otherwise.
    */
    Transformation.prototype.isIdentity = function ()
    {
      var boolId = false;
      var coefs = this.matrix.coef;
      var margin = DSMath.defaultTolerances.epsgForRelativeTest;
      var a11Val = Math.abs(coefs[0] - 1.);
      var a22Val = Math.abs(coefs[4] - 1.);
      var a33Val = Math.abs(coefs[8] - 1.);
      var a12Val = Math.abs(coefs[1]);
      var a13Val = Math.abs(coefs[2]);
      var a21Val = Math.abs(coefs[3]);
      var a23Val = Math.abs(coefs[5]);
      var a31Val = Math.abs(coefs[6]);
      var a32Val = Math.abs(coefs[7]);
      if ((a11Val <= margin) && (a22Val <= margin) && (a33Val <= margin)
           && (a12Val <= margin) && (a13Val <= margin)
           && (a21Val <= margin) && (a23Val <= margin)
           && (a31Val <= margin) && (a32Val <= margin))
      {
        boolId = true;
      }
      return boolId;
    };

    /**-----------------------------------------
     * -------------- STATIC -------------------
     * -----------------------------------------
     */

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method makeRotation
    * @static
    * @description
    * Creates a transformation equals to the rotation by the angle around the axis given.
    * @param {DSMath.Vector3D} iAxis             The axis of the rotation.
    * @param {Number}          iAngle            The angle of the rotation
    * @param {DSMath.Point}    [iCenter=(0,0,0)] The center of the rotation.
    * @example
    * var t0 = DSMath.Transformation.makeRotation(DSMath.Vector3D.zVect, Math.PI/2); // t0.matrix=[0,-1,0,1,0,0,0,0,1]
    * var t1 = DSMath.Transformation.makeRotation(DSMath.Vector3D.zVect, Math.PI/2, new DSMath.Point(1,1,1)); // t1.matrix==t0.matrix but t1.vector=[2,0,0]
    * @returns {DSMath.Transformation} The created transformation.
    */
    Transformation.makeRotation = function (iAxis, iAngle, iCenter)
    {
      DSMath.TypeCheck(iAxis, true, DSMath.Vector3D);
      DSMath.TypeCheck(iAngle, true, 'number');
      DSMath.TypeCheck(iCenter, false, DSMath.Point);

      var result = new Transformation();
      return result.makeRotation(iAxis, iAngle, (iCenter) ? iCenter : undefined);
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method makeRotationFromEuler
    * @static
    * @description
    * Creates a Transformation equals to the rotation combination defined from euler angles.
    * @param {Number[]}     iE                The array of euler angles ZXY.
    * @param {DSMath.Point} [iCenter=(0,0,0)] The center of the rotation.
    * @example
    * var t0 = DSMath.Transformation.makeRotationFromEuler([-Math.PI/4, Math.PI/4, Math.PI/2], new DSMath.Point(1,1,1));
    * // t0.matrix=|0.5, 0.5, 1/&#8730;2|
    * //           |0.5, 0.5,-1/&#8730;2|
    * //           |-1/&#8730;2, 1/&#8730;2, 0|
    * // t0.vector=[-1/&#8730;2,1/&#8730;2,1]
    * @returns {DSMath.Transformation} The created transformation.
    */
    Transformation.makeRotationFromEuler = function (iE, iCenter)
    {
      DSMath.TypeCheck(iE, true, ['number'], 3);
      DSMath.TypeCheck(iCenter, false, DSMath.Point);

      var result = new Transformation();
      return result.makeRotationFromEuler(iE, (iCenter) ? iCenter : undefined);
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method makeScaling
    * @static
    * @description
    * Creates a transformation equals to the scaling of scale given at the center given.
    * @param {Number}       iScale            The scale of the scaling.
    * @param {DSMath.Point} [iCenter=(0,0,0)] The center of the scaling.
    * @example
    * var t0 = DSMath.Transformation.makeScaling(2, new DSMath.Point(0,1,0));
    * //t0.matrix=| 2, 0, 0|
    * //          | 0, 2, 0|
    * //          | 0, 0, 2|
    * //t0.vector=[ 0,-1, 0]
    * @returns {DSMath.Transformation} The created transformation.
    */
    Transformation.makeScaling = function (iScale, iCenter)
    {
      DSMath.TypeCheck(iScale, true, 'number');
      DSMath.TypeCheck(iCenter, false, DSMath.Point);

      var result = new Transformation();
      return result.makeScaling(iScale, (iCenter) ? iCenter : undefined);
    };

    /**
    * @public
    * @memberof DSMath.Transformation
    * @method multiply
    * @static
    * @description
    * Composition of two transformations.
    * @param {DSMath.Transformation} iTLeft The transformation on the left of the composition.
    * @param {DSMath.Transformation} iTRight The transformation on the right of the composition.
    * @param {DSMath.Transformation} [oT] Reference of the operation result (avoid allocation);
    * @example
    * var t0 = DSMath.Transformation.makeRotationFromEuler([Math.PI/2.0,0,0]).setVector(1,2,3);
    * var t1 = new DSMath.Transformation();
    * t1.matrix.makeDiagonal(4,5,6);
    * var t2 = DSMath.Transformation.multiply(t1,t0); // t2!=t0 and
    * //t2.matrix=| 0,-4, 0|
    * //          | 5, 0, 0|
    * //          | 0, 0, 6|
    * //t2.vector=[4, 10 ,18]
    * @returns {DSMath.Transformation} The reference of the operation result.
    */
    Transformation.multiply = function (iTLeft, iTRight, oT)
    {
      DSMath.TypeCheck(iTLeft, true, DSMath.Transformation);
      DSMath.TypeCheck(iTRight, true, DSMath.Transformation);
      DSMath.TypeCheck(oT, false, DSMath.Transformation);

      oT = (oT) ? (oT === iTRight) ? oT.multiply(iTLeft, true) : oT.copy(iTLeft).multiply(iTRight)
               : iTLeft.clone().multiply(iTRight);
      return oT;
    };

    DSMath.Transformation = Transformation;

    return Transformation;
  }
);
