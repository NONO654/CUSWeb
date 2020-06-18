define('MathematicsES/MathVector3DJSImpl',
  ['MathematicsES/MathNameSpace',
   'MathematicsES/MathTypeCheck',
   'MathematicsES/MathTypeCheckInternal',
  ],
   
  function (DSMath, TypeCheck, TypeCheckInternal)
  {
    'use strict';

    /**
     * @public
     * @exports Vector3D
     * @class
     * @classdesc Representation of a vector in 3D.
     *
     * @constructor
     * @constructordesc Create a new Vector3D with given (x, y, z) coordinates.
     * @param {Number} [x=0] The x coordinate of the vector.
     * @param {Number} [y=0] The y coordinate of the vector.
     * @param {Number} [z=0] The z coordinate of the vector.
     * @memberof DSMath
     */
    var Vector3D = function (x, y, z)
    {
      DSMath.TypeCheck(x, false, 'number');
      DSMath.TypeCheck(y, false, 'number');
      DSMath.TypeCheck(z, false, 'number');

      this.x = x || 0;
      this.y = y || 0;
      this.z = z || 0;
    };

    /**
    * The x coordinate of a Vector3D.
    * @public
    * @member
    * @instance
    * @name x
    * @type {Number}
    * @memberOf DSMath.Vector3D
    */
    Vector3D.prototype.x = null;

    /**
    * The y coordinate of a Vector3D.
    * @public
    * @member
    * @instance
    * @name y
    * @type {Number}
    * @memberOf DSMath.Vector3D
    */
    Vector3D.prototype.y = null;

    /**
    * The z coordinate of a Vector3D.
    * @public
    * @member
    * @instance
    * @name z
    * @type {Number}
    * @memberOf DSMath.Vector3D
    */
    Vector3D.prototype.z = null;

    Vector3D.prototype.constructor = Vector3D;

    /**
    * @public
    * @description Clones <i>this</i> vector.
    * @memberof DSMath.Vector3D
    * @method clone
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(0.5, 0.1, 0.0); //v1=(0.5, 0.1, 0.)
    * var clonedV1 = v1.clone();                   //clonedV1=(0.5, 0.1, 0.)
    * @returns {DSMath.Vector3D} The clone of <i>this</i>.
    */
    Vector3D.prototype.clone = function ()
    {
      var v_out = new Vector3D(this.x, this.y, this.z);
      return v_out;
    };

    /**
    * @public
    * @description Copies value of iV to <i>this</i> vector.
    * @param {DSMath.Vector3D} iV The Vector3D to copy.
    * @memberof DSMath.Vector3D
    * @method copy
    * @instance
    * @example
    * var v0 = new DSMath.Vector3D();             // v0 = (0. , 0. , 0.)
    * var v1 = new DSMath.Vector3D(0.5, 0.1, 0.); // v1 = (0.5, 0.1, 0.)
    * v0.copy(v1);                                // v0 = (0.5, 0.1, 0.)
    * @returns {DSMath.Vector3D} <i>this</i> modified vector reference.
    */
    Vector3D.prototype.copy = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);

      this.x = iV.x;
      this.y = iV.y;
      this.z = iV.z;
      return this;
    };

    /**
    * @public
    * @description Assigns new coordinates values to <i>this</i> vector.
    * @param {Number} iX Value for the x coordinate.
    * @param {Number} iY Value for the y coordinate.
    * @param {Number} iZ Value for the z coordinate.
    * @memberof DSMath.Vector3D
    * @method set
    * @instance
    * @example
    * var v0 = new DSMath.Vector3D(); // v0=(0.0, 0.0, 0.0)
    * v0.set(1.0, 2.0, 3.0);          // v0=(1.0, 2.0, 3.0)
    * @returns {DSMath.Vector3D } <i>this</i> modified vector reference.
    */
    Vector3D.prototype.set = function (iX, iY, iZ)
    {
      DSMath.TypeCheck(iX, true, 'number');
      DSMath.TypeCheck(iY, true, 'number');
      DSMath.TypeCheck(iZ, true, 'number');

      this.x = iX;
      this.y = iY;
      this.z = iZ;
      return this;
    };

    /**
    * @public
    * @description Assigns new coordinates values to <i>this</i> vector.
    * @param {Number[]} iA The array of size 3 containing the new vector coordinates.
    * @memberof DSMath.Vector3D
    * @method setFromArray
    * @instance
    * @example
    * var v0 = new DSMath.Vector3D(); // v0=(0,0,0)
    * var coord = [1,2,3];
    * v0.setFromArray(coord);         // v0=(1,2,3)
    * @returns {DSMath.Vector3D } <i>this</i> modified vector reference.
    */
    Vector3D.prototype.setFromArray = function (iA)
    {
      DSMath.TypeCheck(iA, true, ['number'], 3);

      this.x = iA[0];
      this.y = iA[1];
      this.z = iA[2];
      return this;
    };

    /**
    * @public
    * @description
    * Assigns new coordinates values to <i>this</i> vector.
    * <br>
    * The vector equals to the difference between the given point and the origin.
    * @param {DSMath.Point} iP The point.
    * @memberof DSMath.Vector3D
    * @method setFromPoint
    * @instance
    * @example
    * var v0 = new DSMath.Vector3D();   // v0=(0,0,0)
    * var p0 = new DSMath.Point(1,2,3); // p0=(1,2,3)
    * v0.setFromPoint(p0);              // v0=(1,2,3)
    * @returns {DSMath.Vector3D } <i>this</i> modified vector reference.
    */
    Vector3D.prototype.setFromPoint = function (iP)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point);

      this.x = iP.x;
      this.y = iP.y;
      this.z = iP.z;
      return this;
    };

    /**
    * @public
    * @description Assigns new x coordinates values to <i>this</i> vector.
    * @param {Number} iX Value for the x coordinate.
    * @memberof DSMath.Vector3D
    * @method setX
    * @instance
    * @example
    * var v0 = new DSMath.Vector3D(); // v0=(0,0,0)
    * v0.setX(1);                     // v0=(1,0,0)
    * @returns {DSMath.Vector3D } <i>this</i> modified vector reference.
    */
    Vector3D.prototype.setX = function (iX)
    {
      DSMath.TypeCheck(iX, true, 'number');

      this.x = iX;
      return this;
    };

    /**
    * @public
    * @description Assigns new y coordinates values to <i>this</i> vector.
    * @param {Number} iY Value for the y coordinate.
    * @memberof DSMath.Vector3D
    * @method setY
    * @instance
    * @example
    * var v0 = new DSMath.Vector3D(); // v0=(0,0,0)
    * v0.setY(1);                     // v0=(0,1,0)
    * @returns {DSMath.Vector3D } <i>this</i> modified vector reference.
    */
    Vector3D.prototype.setY = function (iY)
    {
      DSMath.TypeCheck(iY, true, 'number');

      this.y = iY;
      return this;
    };

    /**
    * @public
    * @description Assigns new z coordinates values to <i>this</i> vector.
    * @param {Number} iZ Value for the z coordinate.
    * @memberof DSMath.Vector3D
    * @method setZ
    * @instance
    * @example
    * var v0 = new DSMath.Vector3D(); // v0=(0,0,0)
    * v0.setZ(1);                     // v0=(0,0,1)
    * @returns {DSMath.Vector3D } <i>this</i> modified vector reference.
    */
    Vector3D.prototype.setZ = function (iZ)
    {
      DSMath.TypeCheck(iZ, true, 'number');

      this.z = iZ;
      return this;
    };

    /**
    * @public
    * @description Retrieves <i>this</i> vector coordinates values into an array of size 3.
    * @param {DSMath.Vector3D} [oA] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Vector3D
    * @method getArray
    * @instance
    * @example
    * var v0 = new DSMath.Vector3D(1,2,3);
    * var coord = v0.getArray();          // coord=[1,2,3]
    * @returns {Number[]} The reference of the operation result - array of size 3 containing this vector coordinates.
    */
    Vector3D.prototype.getArray = function (oA)
    {
      DSMath.TypeCheck(oA, false, ['number'], 3);

      oA = oA || new Array(3);
      oA[0] = this.x;
      oA[1] = this.y;
      oA[2] = this.z;
      return oA;
    };

    /**
    * @public
    * @description Computes the squared norm of <i>this</i> vector (x<sup>2</sup> + y<sup>2</sup> + z<sup>2</sup>).
    * @memberof DSMath.Vector3D
    * @method squareNorm
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(1,1,1);
    * var v1SquaredNorm = v1.squareNorm(); // = 3
    * @returns {Number} The square norm.
    */
    Vector3D.prototype.squareNorm = function ()
    {
      var sqNorm = this.x * this.x + this.y * this.y + this.z * this.z;
      return sqNorm;
    };

    /**
    * @public
    * @description Computes the norm of <i>this</i> vector &#8730;(x<sup>2</sup> + y<sup>2</sup> + z<sup>2</sup>).
    * @memberof DSMath.Vector3D
    * @method norm
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(1,1,1)
    * var normVal = v1.norm(); // = &#8730;3
    * @returns {Number} The norm.
    */
    Vector3D.prototype.norm = function ()
    {
      return Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
    };

    /**
    * @public
    * @description Normalizes <i>this</i> vector.
    * <br>
    * Divides the vector coordinates by the vector norm.
    * @memberof DSMath.Vector3D
    * @method normalize
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(1,1,1)
    * v1.normalize(); // v1=(1.0/&#8730;3,1.0/&#8730;3,1.0/&#8730;3)
    * @returns {DSMath.Vector3D} <i>this</i> modified vector reference.
    */
    Vector3D.prototype.normalize = function ()
    {
      var Tol = DSMath.defaultTolerances.epsilonForRelativeTest;
      var sqNorm = this.x * this.x + this.y * this.y + this.z * this.z;
      var inv_norm = (Math.abs(sqNorm - 1) <= 2 * Tol) ? 1. : 1. / Math.sqrt(sqNorm);

      this.x *= inv_norm;
      this.y *= inv_norm;
      this.z *= inv_norm;

      return this;
    };

    /**
    * @public
    * @description Reverses the direction of <i>this</i> vector.
    * @memberof DSMath.Vector3D
    * @method negate
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(1, 0, 0);
    * var v2 = v1.negate(); // v1===v2 and v1=(-1,0,0)
    * @returns {DSMath.Vector3D} <i>this</i> modified vector reference.
    */
    Vector3D.prototype.negate = function ()
    {
      this.x *= -1.0;
      this.y *= -1.0;
      this.z *= -1.0;
      return this;
    };

    /**
    * @public
    * @description Add a vector to <i>this</i> vector.
    * @param {DSMath.Vector3D} iV The vector to add.
    * @memberof DSMath.Vector3D
    * @method add
    * @instance
    * @example
    * var v0 = new DSMath.Vector3D(1,2,3);
    * var v1 = new DSMath.Vector3D(4,5,6);
    * var v2 = v0.add(v1); // v2===v0 and v2=v0+v1=(5,7,9);
    * @returns {DSMath.Vector3D} <i>this</i> modified vector reference.
    */
    Vector3D.prototype.add = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);

      this.x += iV.x;
      this.y += iV.y;
      this.z += iV.z;
      return this;
    };

    /**
    * @public
    * @description Add a vector multiplied by a value to <i>this</i> vector.
    * @param {DSMath.Vector3D} iV The vector to add.
    * @param {Number}                       iS The scale.
    * @memberof DSMath.Vector3D
    * @method addScaledVector
    * @instance
    * @example
    * var v0 = new DSMath.Vector3D(1,2,3);
    * var v1 = new DSMath.Vector3D(2,4,6);
    * var v2 = v0.addScaledVector(v1, 0.5); // v2===v0 is true and v2=v0+0.5*v1=(2,4,6);
    * @returns {DSMath.Vector3D} <i>this</i> modified vector reference.
    */
    Vector3D.prototype.addScaledVector = function (iV, iS)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);
      DSMath.TypeCheck(iS, true, 'number');

      this.x += iS * iV.x;
      this.y += iS * iV.y;
      this.z += iS * iV.z;
      return this;
    };

    /**
    * @public
    * @description Add a scalar to each coordinate of <i>this</i> Vector3D.
    * @param {Number} iS The scalar to add.
    * @memberof DSMath.Vector3D
    * @method addScalar
    * @instance
    * @example
    * var v0 = new DSMath.Vector3D(1,2,3);
    * var v1 = v0.addScalar(2); // v1===v0 and v0=(3,4,5);
    * @returns {DSMath.Vector3D} <i>this</i> modified vector reference.
    */
    Vector3D.prototype.addScalar = function (iS)
    {
      DSMath.TypeCheck(iS, true, 'number');

      this.x += iS;
      this.y += iS;
      this.z += iS;
      return this;
    };

    /**
    * @public
    * @description Subtract a vector from <i>this</i> vector.
    * @param {DSMath.Vector3D} iV The vector.
    * @memberof DSMath.Vector3D
    * @method sub
    * @instance
    * @example
    * var v0 = new DSMath.Vector3D(1,2,3);
    * var v1 = new DSMath.Vector3D(4,5,6);
    * var v2 = v0.sub(v1); // v2===v0 is true and v2=v0-v1=(-3,-3,-3);
    * @returns {DSMath.Vector3D} <i>this</i> modified vector reference.
    */
    Vector3D.prototype.sub = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);

      this.x -= iV.x;
      this.y -= iV.y;
      this.z -= iV.z;
      return this;
    };

    /**
    * @public
    * @description Subtract a vector multiplied by a value from <i>this</i> vector.
    * @param {DSMath.Vector3D} iV The vector.
    * @param {Number}                       iS The scale.
    * @memberof DSMath.Vector3D
    * @method subScaledVector
    * @instance
    * @example
    * var v0 = new DSMath.Vector3D(1,2,3);
    * var v1 = new DSMath.Vector3D(2,4,6);
    * var v2 = v0.subScaledVector(v1, 0.5); // v2===v0 is true and v2=v0-0.5*v1=(0,0,0);
    * @returns {DSMath.Vector3D} <i>this</i> modified vector reference.
    */
    Vector3D.prototype.subScaledVector = function (iV, iS)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);
      DSMath.TypeCheck(iS, true, 'number');

      this.x -= iS * iV.x;
      this.y -= iS * iV.y;
      this.z -= iS * iV.z;
      return this;
    };

    /**
    * @public
    * @description Subtract a scalar to each coordinate of <i>this</i> vector.
    * @param {Number} iS The scalar to sub.
    * @memberof DSMath.Vector3D
    * @method subScalar
    * @instance
    * @example
    * var v0 = new DSMath.Vector3D(1,2,3);
    * var v1 = v0.subScalar(2); // v1===v0 and v0=(-1,0,1);
    * @returns {DSMath.Vector3D} <i>this</i> modified vector reference.
    */
    Vector3D.prototype.subScalar = function (iS)
    {
      DSMath.TypeCheck(iS, true, 'number');

      this.x -= iS;
      this.y -= iS;
      this.z -= iS;
      return this;
    };


    /**
    * @public
    * @description Multiplies <i>this</i> vector by a given scalar.
    * @param {Number} iS The scalar.
    * @memberof DSMath.Vector3D
    * @method multiplyScalar
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(1,2,3);
    * var v2 = v1.multiplyScalar(2); // v1=v2=(2,4,6);
    * @returns {DSMath.Vector3D} <i>this</i> modified vector reference.
    */
    Vector3D.prototype.multiplyScalar = function (iS)
    {
      DSMath.TypeCheck(iS, true, 'number');

      this.x *= iS;
      this.y *= iS;
      this.z *= iS;
      return this;
    };

    /**
    * @public
    * @description Divides <i>this</i> vector by a scalar.
    * @param {Number} iS The scalar.
    * @memberof DSMath.Vector3D
    * @method divideScalar
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(1,0,0);
    * var v2 = v1.divideScalar(2); // v1===v2 and v1=(0.5,0,0);
    * @returns {DSMath.Vector3D} <i>this</i> modified vector reference.
    */
    Vector3D.prototype.divideScalar = function (iS)
    {
      DSMath.TypeCheck(iS, true, 'number');

      this.x /= iS;
      this.y /= iS;
      this.z /= iS;
      return this;
    };

    /**
    * @public
    * @description Computes the cross product of <i>this</i> vector with a given one.
    * @param {DSMath.Vector3D} iV The vector to be cross-multiplied by <i>this</i>.
    * @memberof DSMath.Vector3D
    * @method cross
    * @instance
    * @example
    * var v1 = DSMath.Vector3D.xVect.clone(); // v1=(1,0,0)
    * var v2 = DSMath.Vector3D.yVect.clone(); // v2=(0,1,0)
    * var v3 = v1.cross(v2);                  // v3=v1=(0,0,1)
    * @returns {DSMath.Vector3D } <i>this</i> modified vector reference.
    */
    Vector3D.prototype.cross = function (v2)
    {
      DSMath.TypeCheck(v2, true, DSMath.Vector3D);

      var v1y = this.y;
      var v1x = this.x;
      var v1z = this.z;
      this.x = v1y * v2.z - v1z * v2.y;
      this.y = v1z * v2.x - v1x * v2.z;
      this.z = v1x * v2.y - v1y * v2.x;
      return this;
    };

    /**
    * @public
    * @description Computes the dot product between <i>this</i> and a given vector.
    * @param {DSMath.Vector3D} iV The vector.
    * @memberof DSMath.Vector3D
    * @method dot
    * @instance
    * @example
    * var v1 = DSMath.Vector3D.xVect;
    * var v2 = new DSMath.Vector3D(0.1,2,3);
    * var dot = v1.dot(v2); // dot = 0.1;
    * @returns {Number } The dot product of <i>this</i> and iV.
    */
    Vector3D.prototype.dot = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);

      var result = this.x * iV.x + this.y * iV.y + this.z * iV.z;
      return result;
    };

    /**
    * @public
    * @description Determines whether <i>this</i> vector is orthogonal with a given vector.
    * <br>
    * Note if one vector is ~=(0, 0, 0), the vector are considered as orthogonal.
    * @param {DSMath.Vector3D} iV The other vector.
    * @memberof DSMath.Vector3D
    * @method isOrthogonal
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(0.0, 1.0, 1.0);
    * var boolOrtho = DSMath.Vector3D.xVect.isOrthogonal(v1); // true.
    * @returns {boolean} true if the vector is orthogonal with <i>this</i> vector, false otherwise.
    */
    Vector3D.prototype.isOrthogonal = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);

      var boolOrtho = false;
      var sqNorm = this.squareNorm();
      var sqNormU = iV.squareNorm();
      var sqRelTol = DSMath.defaultTolerances.epsilonForSquareAngleTest;
      var sqScal = this.dot(iV);
      sqScal = sqScal * sqScal;

      boolOrtho = (sqNorm <= sqRelTol * Math.max(1, sqNormU) ||
                   sqNormU <= sqRelTol * Math.max(1, sqNorm));
      boolOrtho = (boolOrtho) ? boolOrtho :
                               (sqScal <= sqNorm * sqNormU * sqRelTol);

      return boolOrtho;
    };

    /**
    * @public
    * @description Determines whether <i>this</i> vector is colinear with a given vector.
    * <br>
    * Note if one vector is ~=(0, 0, 0) the vector are considered as colinear.
    * @param {DSMath.Vector3D} iV The other vector.
    * @memberof DSMath.Vector3D
    * @method isParallel
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(1.2, 0, 0);
    * var boolParalx = DSMath.Vector3D.xVect.isParallel(v1); // true.
    * var boolParaly = DSMath.Vector3D.yVect.isParallel(v1); // false.
    * @returns {boolean} true if the vector is colinear with <i>this</i> vector, false otherwise.
    */
    Vector3D.prototype.isParallel = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);

      var boolParal = false;
      var sqNorm = this.squareNorm();
      var sqNormU = iV.squareNorm();
      var sqRelTol = DSMath.defaultTolerances.epsilonForSquareAngleTest;
      var sqTol = 1 - sqRelTol;
      var sqScal = this.dot(iV);
      sqScal = sqScal * sqScal;

      boolParal = (sqNorm <= sqRelTol * Math.max(1, sqNormU) ||
                   sqNormU <= sqRelTol * Math.max(1, sqNorm));
      boolParal = (boolParal) ? boolParal :
                               (sqScal >= sqNorm * sqNormU * sqTol);

      return boolParal;
    }

    /**
    * @public
    * @description Retrieves the orthogonal decomposition of <i>this</i> vector related to a given reference vector.
    * @param {DSMath.Vector3D} iVRef The reference vector.
    * @memberof DSMath.Vector3D
    * @method orthoComponents
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(0.5, 0.1, 0.0);
    * var orthoComp = v1.orthoComponents(DSMath.Vector3D.xVect); // orthoComp = [(0.5,0,0), (0,0.1,0)].
    * @returns {DSMath.Vector3D[]} Array made up of the parallel (id=0) and normal components(id=1).
    */
    Vector3D.prototype.orthoComponents = function (iVRef)
    {
      DSMath.TypeCheck(iVRef, true, DSMath.Vector3D);

      var oParallelComponent = Vector3D.project(this, iVRef);
      var oNormalComponent = Vector3D.sub(this, oParallelComponent);
      var oResult = [oParallelComponent, oNormalComponent];
      return oResult;
    };

    /**
    * @public
    * @description Project <i>this</i> vector on another vector.
    * @param {DSMath.Vector3D} iVSupport The projection vector support.
    * @memberof DSMath.Vector3D
    * @method project
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(0.1,0.2,0.3);
    * var vX = v1.project(DSMath.Vector3D.xVect); // vX===v1 and v1=(0.1,0,0).
    * @return {DSMath.Vector3D} <i>this</i> modified vector reference.
    */
    Vector3D.prototype.project = function (iVSupport)
    {
      DSMath.TypeCheck(iVSupport, true, DSMath.Vector3D);

      var vSupportSqNorm = iVSupport.squareNorm();
      var projLength = this.dot(iVSupport) / vSupportSqNorm;
      this.copy(iVSupport);
      this.multiplyScalar(projLength);
      return this;
    };

    /**
    * @public
    * @description Project <i>this</i> vector on the vector defined by the intersection between iVRef orthogonal plane and the plane defined by (<i>this</i>, iVRef).
    * <br>
    * <i>this</i> and iVref shall not be colinear.
    * @param {DSMath.Vector3D} iVRef The reference vector.
    * @memberof DSMath.Vector3D
    * @method projectOrthogonal
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(1.1, 2.2, 3.3);
    * var vProjOrtho = v1.projectOrthogonal(DSMath.Vector3D.xVect); // vProjOrtho===v1 and v1=(0, 2.2, 3.3).
    * @return {DSMath.Vector3D} <i>this</i> modified vector reference.
    */
    Vector3D.prototype.projectOrthogonal = function (iVRef)
    {
      DSMath.TypeCheck(iVRef, true, DSMath.Vector3D);

      var vSupportSqNorm = iVRef.squareNorm();
      var projLength = this.dot(iVRef) / vSupportSqNorm;
      this.subScaledVector(iVRef, projLength);
      return this;
    };


    /**
    * @public
    * @description Project <i>this</i> vector on the Plane given.
    * @param {DSMath.Plane} iPlane The plane support of the projection.
    * @memberof DSMath.Vector3D
    * @method projectOnPlane
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(1.1, 2.2, 3.3);
    * var plane = new DSMath.Plane(); // plane Oxy
    * var v1ProjPlane = v1.projectOnPlane(plane); // v1ProjPlane===v1 and v1ProjPlane=(1.1, 2.2, 0).
    * @return {DSMath.Vector3D} <i>this</i> modified vector reference.
    */
    Vector3D.prototype.projectOnPlane = function (iPlane)
    {
      DSMath.TypeCheck(iPlane, true, DSMath.Plane);

      var vect = iPlane.getDirectionsNotCloned();

      var u = this.dot(vect[0]);
      var v = this.dot(vect[1]);

      this.x = u * vect[0].x + v * vect[1].x;
      this.y = u * vect[0].y + v * vect[1].y;
      this.z = u * vect[0].z + v * vect[1].z;

      return this;
    };

    /**
    * @public
    * @description Project <i>this</i> vector on the plane defined by the two vectors given.
    * <br>
    * The vectors shall not be colinear.
    * @param {DSMath.Vector3D} iV1 The first vector.
    * @param {DSMath.Vector3D} iV2 The second vector.
    * @memberof DSMath.Vector3D
    * @method projectOnPlaneFromVectors
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(1.1, 2.2, 3.3);
    * var v1ProjPlane = v1.projectOnPlaneFromVectors(DSMath.Vector3D.xVect, DSMath.Vector3D.yVect); // v1ProjPlane===v1 and v1ProjPlane=(1.1, 2.2, 0).
    * @return {DSMath.Vector3D} <i>this</i> modified vector reference.
    */
    Vector3D.prototype.projectOnPlaneFromVectors = function (iV1, iV2)
    {
      DSMath.TypeCheck(iV1, true, DSMath.Vector3D);
      DSMath.TypeCheck(iV2, true, DSMath.Vector3D);

      // We duplicate the inputs only if we need to orthonormalize them.
      if (!iV1.isOrthogonal(iV2) || !iV1.isNormalized() || !iV2.isNormalized())
      {
        iV1 = iV1.clone();
        iV2 = iV2.clone();
        Vector3D.orthoNormalize(iV1, iV2);
      }

      var u = this.dot(iV1);
      var v = this.dot(iV2);

      this.x = u * iV1.x + v * iV2.x;
      this.y = u * iV1.y + v * iV2.y;
      this.z = u * iV1.z + v * iV2.z;

      return this;
    };

    /**
    * @public
    * @description Compares <i>this</i> vector with another one for equality.
    * @param {DSMath.Vector3D} iV       The vector to be compared with <i>this</i>.
    * @param {Number}          [iTol=0] The comparaison accuracy. If not given, strict comparaison is performed.
    * @memberof DSMath.Vector3D
    * @method isEqual
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(1.0011,0,0);
    * var v2 = new DSMath.Vector3D(1.0001,0,0);
    * var vX = DSMath.Vector3D.xVect;
    * var boolV1VX = v1.isEqual(vX, 0.001); //boolV1VX = FALSE;
    * var boolV2VX = v2.isEqual(vX, 0.001); // boolV2VX = TRUE;
    * @returns {boolean} true if the vectors have equal coordinates at the given tolerance, false otherwise.
    */
    Vector3D.prototype.isEqual = function (iV, iTol)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);
      DSMath.TypeCheck(iTol, false, 'number');

      var bEq = false;
      if ((arguments.length < 2))
      {
        bEq = (this.x == iV.x) && (this.y == iV.y) && (this.z == iV.z);
      }
      else
      {
        bEq = !((Math.abs(this.x - iV.x) > iTol) || (Math.abs(this.y - iV.y) > iTol) || (Math.abs(this.z - iV.z) > iTol));
      }
      return bEq;
    };

    /**
    * @public
    * @description Check if <i>this</i> vector is normalized or not.
    * @memberof DSMath.Vector3D
    * @method isNormalized
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(1,0,0);
    * var v2 = new DSMath.Vector3D(1.0001,0,0);
    * var v1IsNormalized = v1.isNormalized(); // v1IsNormalized=true
    * var v2IsNormalized = v2.isNormalized(); // v2IsNormalized=false
    * @returns {boolean} true if <i>this</i> vector is normalized, false otherwise.
    */
    Vector3D.prototype.isNormalized = function ()
    {
      var Tol = DSMath.defaultTolerances.epsilonForRelativeTest;
      var sqNorm = this.squareNorm();
      return (Math.abs(sqNorm - 1) <= 2 * Tol);
    };

    /**
    * @public
    * @description Computes the linear interpolation between <i>this</i> vector and another one.
    * @param {DSMath.Vector3D} iV The Vector3D reference for the interpolation.
    * @param {Number}                       iR The ratio in [0, 1].
    * @memberof DSMath.Vector3D
    * @method lerp
    * @instance
    * @example
    * var v1 = DSMath.Vector3D.xVect.clone(); // v1=(1,0,0)
    * var v2 = DSMath.Vector3D.yVect;         // v2=(0,1,0)
    * var intV = v1.lerp(v2, 0.4);            // v1=intV=(0.6,0.4,0)
    * @returns {DSMath.Vector3D } <i>this</i> modified vector reference.
    */
    Vector3D.prototype.lerp = function (iV, iR)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);
      DSMath.TypeCheck(iR, true, 'number');

      this.x += iR * (iV.x - this.x);
      this.y += iR * (iV.y - this.y);
      this.z += iR * (iV.z - this.z);

      return this;
    };

    /**
    * @public
    * @description Get the angle between <i>this</i> vector and another one.
    * @param {DSMath.Vector3D} iV The other Vector3D.
    * @memberof DSMath.Vector3D
    * @method getAngleTo
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(Math.cos(Math.PI/4.0), Math.sin(Math.PI/4.0), 0.0);
    * var v2 = new DSMath.Vector3D(Math.cos(Math.PI/3.0), Math.sin(Math.PI/3.0), 0.0);
    * var angleV1V2 = v1.getAngleTo(v2); // PI/12
    * var angleV1Vx = v1.getAngleTo(DSMath.Vector3D.xVect); // PI/4
    * @returns {Number} the angle in [0, PI].
    */
    Vector3D.prototype.getAngleTo = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);

      var angle = 0;
      var sqNorm1 = this.squareNorm();
      var sqNorm2 = iV.squareNorm();
      if (sqNorm1 != 0 && sqNorm2 != 0)
      {
        var x = this.dot(iV);
        var y = Vector3D.cross(this, iV).norm();
        angle = Math.atan2(y, x);
      }
      return angle;
    };

    /**
    * @public
    * @description Get the signed angle between <i>this</i> vector and another one.
    * <br>
    * The angle sign is the same as this.cross(iV).dot(iVRef) sign.
    * @param {DSMath.Vector3D} iV The other Vector3D.
    * @param {DSMath.Vector3D} iVRef The reference vector to determine the angle sign.
    * @memberof DSMath.Vector3D
    * @method getSignedAngleTo
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(Math.cos(Math.PI/4.0), Math.sin(Math.PI/4.0), 0.0);
    * var v2 = new DSMath.Vector3D(Math.cos(Math.PI/3.0), Math.sin(Math.PI/3.0), 0.0);
    * var vRef = DSMath.Vector3D.zVect;
    * var angleV1V2 = v1.getSignedAngleTo(v2, vRef); // PI/12
    * var angleV2V1 = v2.getSignedAngleTo(v1, vRef); // -PI/12
    * var angleV1Vx = v1.getSignedAngleTo(DSMath.Vector3D.xVect, vRef); // -PI/4
    * @returns {Number} the angle in [-PI, PI].
    */
    Vector3D.prototype.getSignedAngleTo = function (iV, iVRef)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);
      DSMath.TypeCheck(iVRef, true, DSMath.Vector3D);

      var angle = 0;
      var sqNorm1 = this.squareNorm();
      var sqNorm2 = iV.squareNorm();
      if (sqNorm1 != 0 && sqNorm2 != 0)
      {
        var vect = Vector3D.cross(this, iV);
        var ori = vect.dot(iVRef);
        var sign = Math.sign(ori);
        var x = this.dot(iV);
        var y = vect.norm();
        angle = Math.atan2(sign * y, x);
      }
      return angle;
    };

    /**
    * @public
    * @description Clamps <i>this</i> vector coordinates between two vector coordinates.
    * @param {DSMath.Vector3D} iMin The vector containing the min coordinates.
    * @param {DSMath.Vector3D} iMax The vector containing the max coordinates.
    * @memberof DSMath.Vector3D
    * @method clamp
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(2,1,3);
    * var minV = new DSMath.Vector3D(1.4, 1.5, 1.6);
    * var maxV = new DSMath.Vector3D(2.4, 2.5, 2.6);
    * var vClamp = v1.clamp(minV, maxV); // vClamp===v1 and vClamp=(2, 1.5, 2.6);
    * @returns {DSMath.Vector3D} <i>this</i> modified vector reference.
    */
    Vector3D.prototype.clamp = function (iMin, iMax)
    {
      DSMath.TypeCheck(iMin, true, DSMath.Vector3D);
      DSMath.TypeCheck(iMax, true, DSMath.Vector3D);

      this.x = this.x < iMin.x ? iMin.x : (this.x > iMax.x ? iMax.x : this.x);
      this.y = this.y < iMin.y ? iMin.y : (this.y > iMax.y ? iMax.y : this.y);
      this.z = this.z < iMin.z ? iMin.z : (this.z > iMax.z ? iMax.z : this.z);
      return this;
    };

    /**
    * @public
    * @description Clamps <i>this</i> vector coordinates between two Number values
    * @param {Number} iMin The min value.
    * @param {Number} iMax The max value.
    * @memberof DSMath.Vector3D
    * @method clampScalar
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(2,1,3);
    * var vClamp = v1.clampScalar(1.5, 2.5); // vClamp===v1 and vClamp=(2, 1.5, 2.5);
    * @returns {DSMath.Vector3D} <i>this</i> modified vector reference.
    */
    Vector3D.prototype.clampScalar = function (iMin, iMax)
    {
      DSMath.TypeCheck(iMin, true, 'number');
      DSMath.TypeCheck(iMax, true, 'number');

      this.x = this.x < iMin ? iMin : (this.x > iMax ? iMax : this.x);
      this.y = this.y < iMin ? iMin : (this.y > iMax ? iMax : this.y);
      this.z = this.z < iMin ? iMin : (this.z > iMax ? iMax : this.z);
      return this;
    };

    /**
    * @public
    * @description Transforms <i>this</i> vector by multiplying it by a given matrix.
    * @param {DSMath.Matrix3x3} iM The matrix.
    * @memberof DSMath.Vector3D
    * @method applyMatrix3x3
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(1,0,0);
    * var m = new DSMath.Matrix3x3();
    * m.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
    * var vRot = v1.applyMatrix3x3(m); // vRot===v1 and v1=(0,1,0).
    * @returns {DSMath.Vector3D } <i>this</i> modified vector reference.
    */
    Vector3D.prototype.applyMatrix3x3 = function (iM)
    {
      DSMath.TypeCheck(iM, true, DSMath.Matrix3x3);

      var c = iM.coef;
      var x = this.x;
      var y = this.y;
      var z = this.z;

      this.x = c[0] * x + c[1] * y + c[2] * z;
      this.y = c[3] * x + c[4] * y + c[5] * z;
      this.z = c[6] * x + c[7] * y + c[8] * z;

      return this;
    };

    /**
    * @public
    * @description Transforms <i>this</i> vector by multiplying it with a transformation.
    * <br>
    * Note only the transformation matrix is applied on the vector.
    * @param {DSMath.Transformation} iT The transformation.
    * @memberof DSMath.Vector3D
    * @method applyTransformation
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(1,0,0);
    * var t = new DSMath.Transformation();
    * t.setRotation(DSMath.Vector3D.zVect, Math.PI/2);
    * t.vector.set(1,2,3);
    * var vT = v1.applyTransformation(t); // vT===v1 and v1=(0,1,0).
    * @returns {DSMath.Vector3D } <i>this</i> modified vector reference.
    */
    Vector3D.prototype.applyTransformation = function (iT)
    {
      DSMath.TypeCheck(iT, true, DSMath.Transformation);

      this.applyMatrix3x3(iT.matrix);
      return this;
    };

    /**
    * @public
    * @description Transforms <i>this</i> vector by multiplying it with a quaternion.
    * <br>
    * If the quaternion is not a unit quaternion, the computation will used its normalized form.
    * @param {DSMath.Quaternion} iQ The unit quaternion.
    * @memberof DSMath.Vector3D
    * @method applyQuaternion
    * @instance
    * @example
    * var v1 = new DSMath.Vector3D(1,0,0);
    * var q = DSMath.Quaternion.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
    * var vT = v1.applyQuaternion(q); // vT===v1 and v1=(0,1,0).
    * @returns {DSMath.Vector3D } <i>this</i> modified vector reference.
    */
    Vector3D.prototype.applyQuaternion = function (iQ)
    {
      DSMath.TypeCheck(iQ, true, DSMath.Quaternion);

      var sqNorm = iQ.squareNorm();

      var x = this.x;
      var y = this.y;
      var z = this.z;

      var qx = iQ.x;
      var qy = iQ.y;
      var qz = iQ.z;
      var qs = iQ.s;

      // calculate quat * vector
      var is = -qx * x - qy * y - qz * z;
      var ix = qs * x + qy * z - qz * y;
      var iy = qs * y + qz * x - qx * z;
      var iz = qs * z + qx * y - qy * x;

      // calculate result * inverse quat
      this.x = (ix * qs + is * -qx + iy * -qz - iz * -qy) / sqNorm;
      this.y = (iy * qs + is * -qy + iz * -qx - ix * -qz) / sqNorm;
      this.z = (iz * qs + is * -qz + ix * -qy - iy * -qx) / sqNorm;

      return this;
    }

    /**-----------------------------------------
     * -------------- STATIC -------------------
     * -----------------------------------------
     */

    /**
    * @public
    * @name xVect
    * @type {Number}
    * @readonly
    * @memberOf DSMath.Vector3D
    * @description The (1, 0, 0) vector.
    */
    Object.defineProperty(Vector3D, "xVect", {
      value: new Vector3D(1.0, 0, 0),
      writable: false,
      enumerable: true,
      configurable: false
    });
    Object.freeze(Vector3D.xVect); // We need to freeze the object. Only the value was read only.

    /**
    * @public
    * @name yVect
    * @type {Number}
    * @readonly
    * @memberOf DSMath.Vector3D
    * @description The (0, 1, 0) vector.
    */
    Object.defineProperty(Vector3D, "yVect", {
      value: new Vector3D(0, 1.0, 0),
      writable: false,
      enumerable: true,
      configurable: false
    });
    Object.freeze(Vector3D.yVect); // We need to freeze the object. Only the value was read only.

    /**
    * @public
    * @name zVect
    * @type {Number}
    * @readonly
    * @memberOf DSMath.Vector3D
    * @description The (0, 0, 1) vector.
    */
    Object.defineProperty(Vector3D, "zVect", {
      value: new Vector3D(0, 0, 1.0),
      writable: false,
      enumerable: true,
      configurable: false
    });
    Object.freeze(Vector3D.zVect); // We need to freeze the object. Only the value was read only.

    /**
    * @public
    * @description Creates a new vector equals to the normalized form of a vector.
    * @param {DSMath.Vector3D} iV   The vector to clone and normalize.
    * @param {DSMath.Vector3D} [oV] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Vector3D
    * @method normalize
    * @static
    * @example
    * var v1 = new DSMath.Vector3D(1,1,1)
    * var v1Normalized = DSMath.Vector3D.normalize(v1); // v1Normalized=(1.0/&#8730;3,1.0/&#8730;3,1.0/&#8730;3)
    * @returns {DSMath.Vector3D} The reference of the operation result.
    */
    Vector3D.normalize = function (iV, oV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);
      DSMath.TypeCheck(oV, false, DSMath.Vector3D);

      oV = (oV) ? oV.copy(iV) : iV.clone();
      return oV.normalize();
    };

    /**
    * @public
    * @description Creates a new vector equals to the addition of two vectors.
    * @param {DSMath.Vector3D} iV1 The first vector.
    * @param {DSMath.Vector3D} iV2 The second vector.
    * @param {DSMath.Vector3D} [oV] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Vector3D
    * @method add
    * @static
    * @example
    * var v0 = new DSMath.Vector3D(1,2,3);
    * var v1 = new DSMath.Vector3D(4,5,6);
    * var v2 = DSMath.Vector3D.add(v0, v1); // v2!=v0 and v2=v0+v1=(5,7,9);
    * @returns {DSMath.Vector3D} The reference of the operation result.
    */
    Vector3D.add = function (iV1, iV2, oV)
    {
      DSMath.TypeCheck(iV1, true, DSMath.Vector3D);
      DSMath.TypeCheck(iV2, true, DSMath.Vector3D);
      DSMath.TypeCheck(oV, false, DSMath.Vector3D);

      oV = (oV) ? oV : new Vector3D();

      oV.x = iV1.x + iV2.x;
      oV.y = iV1.y + iV2.y;
      oV.z = iV1.z + iV2.z;

      return oV;
    };

    /**
    * @public
    * @description Creates a new vector equals to the subtraction of two vectors.
    * @param {DSMath.Vector3D} iV1 The first vector.
    * @param {DSMath.Vector3D} iV2 The second vector.
    * @param {DSMath.Vector3D} [oV] The reference of the operation result (avoid allocation).
    * @memberof DSMath.Vector3D
    * @method sub
    * @static
    * @example
    * var v0 = new DSMath.Vector3D(1,2,3);
    * var v1 = new DSMath.Vector3D(4,5,6);
    * var v2 = DSMath.Vector3D.sub(v0, v1); // v2!=v1 and v2=v0-v1=(-3,-3,-3);
    * @returns {DSMath.Vector3D} The reference of the operation result.
    */
    Vector3D.sub = function (iV1, iV2, oV)
    {
      DSMath.TypeCheck(iV1, true, DSMath.Vector3D);
      DSMath.TypeCheck(iV2, true, DSMath.Vector3D);
      DSMath.TypeCheck(oV, false, DSMath.Vector3D);

      oV = (oV) ? oV : new Vector3D();

      oV.x = iV1.x - iV2.x;
      oV.y = iV1.y - iV2.y;
      oV.z = iV1.z - iV2.z;

      return oV;
    };

    /**
    * @public
    * @description Creates a new vector equals to the reversed direction of a vector.
    * @param {DSMath.Vector3D} iV   The vector to be reversed.
    * @param {DSMath.Vector3D} [oV] The reference of the operation result (avoid allocation).
    * @memberof DSMath.Vector3D
    * @method negate
    * @static
    * @example
    * var v1 = DSMath.Vector3D.xVect;
    * var v2 = DSMath.Vector3D.negate(v1); // v1 = (1, 0, 0) and  v2=(-1, 0, 0)
    * @returns {DSMath.Vector3D} The reference of the operation result.
    */
    Vector3D.negate = function (iV, oV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);
      DSMath.TypeCheck(oV, false, DSMath.Vector3D);

      oV = (oV) ? oV.copy(iV) : iV.clone();
      return oV.negate();
    };

    /**
    * @public
    * @description Creates a new vector equals to the multiplication of a vector by a scalar.
    * @param {DSMath.Vector3D} iV   The vector to be multiplied.
    * @param {Number}                       iS   The scalar.
    * @param {DSMath.Vector3D} [oV] The reference of the operation result (avoid allocation).
    * @memberof DSMath.Vector3D
    * @method multiplyScalar
    * @static
    * @example
    * var v1 = new DSMath.Vector3D(1,2,3);
    * var v2 = DSMath.Vector3D.multiplyScalar(v1, 2); // v2=(2,4,6);
    * @returns {DSMath.Vector3D} The reference of the operation result.
    */
    Vector3D.multiplyScalar = function (iV, iS, oV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);
      DSMath.TypeCheck(iS, true, 'number');
      DSMath.TypeCheck(oV, false, DSMath.Vector3D);

      oV = (oV) ? oV.copy(iV) : iV.clone();
      return oV.multiplyScalar(iS);
    };

    /**
    * @public
    * @description Creates a new vector equals to the division of a vector by a scalar.
    * @param {DSMath.Vector3D} iV   The vector to be divided.
    * @param {Number}                       iS   The scalar.
    * @param {DSMath.Vector3D} [oV] The reference of the operation result (avoid allocation).
    * @memberof DSMath.Vector3D
    * @method divideScalar
    * @static
    * @example
    * var v1 = DSMath.Vector3D.xVect;
    * var v2 = DSMath.Vector3D.divideScalar(v1, 2); // v2=(0.5,0,0);
    * @returns {DSMath.Vector3D} The reference of the operation result.
    */
    Vector3D.divideScalar = function (iV, iS, oV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);
      DSMath.TypeCheck(iS, true, 'number');
      DSMath.TypeCheck(oV, false, DSMath.Vector3D);

      oV = (oV) ? oV.copy(iV) : iV.clone();
      return oV.divideScalar(iS);
    };

    /**
    * @public
    * @description Creates a new vector equals to the projection of a vector on another vector.
    * @param {DSMath.Vector3D} iV        The vector to project.
    * @param {DSMath.Vector3D} iVSupport The projection vector support.
    * @param {DSMath.Vector3D} [oV]      The reference of the operation result (avoid allocation).
    * @memberof DSMath.Vector3D
    * @method project
    * @static
    * @example
    * var v1 = new DSMath.Vector3D(0.1,0.2,0.3);
    * var vX = DSMath.Vector3D.project(v1, DSMath.Vector3D.xVect); // vX!==v1 and vx=(0.1,0,0), v1=(0.1,0.2,0.3).
    * @return {DSMath.Vector3D} The reference of the operation result.
    */
    Vector3D.project = function (iV, iVSupport, oV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);
      DSMath.TypeCheck(iVSupport, true, DSMath.Vector3D);
      DSMath.TypeCheck(oV, false, DSMath.Vector3D);

      oV = (oV) ? oV : new Vector3D();

      var vSupportSqNorm = iVSupport.squareNorm();
      var projLength = iV.dot(iVSupport) / vSupportSqNorm;

      return oV.copy(iVSupport).multiplyScalar(projLength);
    };

    /**
    * @public
    * @description Creates a new vector equals to the cross product of two vector.
    * @param {DSMath.Vector3D} iV1  First vector.
    * @param {DSMath.Vector3D} iV2  Second vector.
    * @param {DSMath.Vector3D} [oV] The reference of the operation result (avoid allocation).
    * @memberof DSMath.Vector3D
    * @method cross
    * @static
    * @example
    * var v1 = DSMath.Vector3D.xVect.clone(); // v1=(1,0,0)
    * var v2 = DSMath.Vector3D.yVect.clone(); // v2=(0,1,0)
    * var v3 = DSMath.Vector3D.cross(v1, v2); // v3=(0,0,1)
    * @returns {DSMath.Vector3D } The reference of the operation result.
    */
    Vector3D.cross = function (iV1, iV2, oV)
    {
      DSMath.TypeCheck(iV1, true, DSMath.Vector3D);
      DSMath.TypeCheck(iV2, true, DSMath.Vector3D);
      DSMath.TypeCheck(oV, false, DSMath.Vector3D);

      oV = (oV) ? oV : new Vector3D();

      var v1x = iV1.x;
      var v1y = iV1.y;
      var v1z = iV1.z;

      var v2x = iV2.x;
      var v2y = iV2.y;
      var v2z = iV2.z;

      oV.x = v1y * v2z - v1z * v2y;
      oV.y = v1z * v2x - v1x * v2z;
      oV.z = v1x * v2y - v1y * v2x;

      return oV;
    };

    /**
    * @public
    * @description Creates a new vector equals to the linear interpolation between two vectors.
    * @param {DSMath.Vector3D} iV1  The first  vector reference for the interpolation.
    * @param {DSMath.Vector3D} iV2  The second vector reference for the interpolation.
    * @param {Number}                       iR   The ratio in [0, 1].
    * @param {DSMath.Vector3D} [oV] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Vector3D
    * @method lerp
    * @static
    * @example
    * var v1 = DSMath.Vector3D.xVect; // v1=(1,0,0)
    * var v2 = DSMath.Vector3D.yVect; // v2=(0,1,0)
    * var intV = DSMath.Vector3D.lerp(v1, v2, 0.4); // intV=(0.6,0.4,0)
    * @returns {DSMath.Vector3D } The reference of the operation result.
    */
    Vector3D.lerp = function (iV1, iV2, iR, oV)
    {
      DSMath.TypeCheck(iV1, true, DSMath.Vector3D);
      DSMath.TypeCheck(iV2, true, DSMath.Vector3D);
      DSMath.TypeCheck(iR, true, 'number');
      DSMath.TypeCheck(oV, false, DSMath.Vector3D);

      oV = (oV) ? oV : new Vector3D();

      oV.x = iV1.x + iR * (iV2.x - iV1.x);
      oV.y = iV1.y + iR * (iV2.y - iV1.y);
      oV.z = iV1.z + iR * (iV2.z - iV1.z);

      return oV;
    };

    /**
    * @public
    * @description
    * Orthonormalize the given vectors.
    * <br>
    * If two vectors are provided, they shall not be colinear. If three vectors are provided, they shall not be coplanar. In such case, the vectors will be changed by a default behavior.
    * @param {DSMath.Vector3D} ioV1   The first vector to be normalized.
    * @param {DSMath.Vector3D} ioV2   The second vector to be normalized and change such as iV2.isOrthogonal(iV1) is true.
    * @param {DSMath.Vector3D} [ioV3] The third vector to be normalized and change such as iV3.isOrthogonal(iV1) is true and iV3.isOrthogonal(iV2) is true.
    * @memberof DSMath.Vector3D
    * @method orthoNormalize
    * @static
    * @example
    * var v1 = new DSMath.Vector3D(1,1,0);
    * var v2 = new DSMath.Vector3D(0,1,0);
    * DSMath.Vector3D.orthoNormalize(v1, v2); //v1=(1/&#8730;2, 1/&#8730;2, 0) and v2=(-1/&#8730;2, 1/&#8730;2, 0)
    * v1.set(1,1,0);
    * v2.set(0,1,0);
    * var v3 = new DSMath.Vector3D(1,1,1);
    * DSMath.Vector3D.orthoNormalize(v1, v2, v3); //v1=(1/&#8730;2, 1/&#8730;2, 0) and v2=(-1/&#8730;2, 1/&#8730;2, 0) and v3(0,0,1);
    */
    Vector3D.orthoNormalize = function (ioV1, ioV2, ioV3)
    {
      DSMath.TypeCheck(ioV1, true, DSMath.Vector3D);
      DSMath.TypeCheck(ioV2, true, DSMath.Vector3D);
      DSMath.TypeCheck(ioV3, false, DSMath.Vector3D);

      if (!ioV1.isParallel(ioV2))
      {
        ioV1.normalize();
        ioV2.projectOrthogonal(ioV1);
        ioV2.normalize();
      } else
      {
        ioV1.normalize();
        if (ioV1.x > DSMath.defaultTolerances.epsilonForRelativeTest)
          ioV2.set(-ioV1.y, ioV1.x, 0);
        else
          ioV2.set(1, 0, 0);
        ioV2.normalize();
      }

      if (ioV3)
      {
        var N = Vector3D.cross(ioV1, ioV2);
        var sign = N.dot(ioV3);
        ioV3.copy(N);
        if (sign < -DSMath.defaultTolerances.epsilonForRelativeTest)
          ioV3.multiplyScalar(-1);
      }
    };

    DSMath.Vector3D = Vector3D;
    return Vector3D;
  }
);
