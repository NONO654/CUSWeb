define('MathematicsES/MathVector2DJSImpl',
  ['MathematicsES/MathNameSpace',
   'MathematicsES/MathTypeCheck',
   'MathematicsES/MathTypeCheckInternal',
  ],
  
  function (DSMath, TypeCheck, TypeCheckInternal)
  {
    'use strict';

    /**
    * @public
    * @exports Vector2D
    * @class
    * @classdesc Representation of a vector in 2D.
    *
    * @constructor
    * @constructordesc Create a new Vector2D with given (x, y) coordinates.
    * @param {Number} [x=0] The x coordinate of the vector.
    * @param {Number} [y=0] The y coordinate of the vector.
    * @memberof DSMath
    */
    var Vector2D = function (x, y)
    {
      DSMath.TypeCheck(x, false, 'number');
      DSMath.TypeCheck(y, false, 'number');

      this.x = x || 0;
      this.y = y || 0;
    };

    /**
    * The x coordinate of a Vector2D.
    * @public
    * @member
    * @instance
    * @name x
    * @type {Number}
    * @memberOf DSMath.Vector2D
    */
    Vector2D.prototype.x = null;

    /**
    * The y coordinate of a Vector2D.
    * @public
    * @member
    * @instance
    * @name y
    * @type {Number}
    * @memberOf DSMath.Vector2D
    */
    Vector2D.prototype.y = null;

    Vector2D.prototype.constructor = Vector2D;

    /**
    * @public
    * @description Clones <i>this</i> vector.
    * @memberof DSMath.Vector2D
    * @method clone
    * @instance
    * @example
    * var v1 = new DSMath.Vector2D(0.5, 0.1); //v1=(0.5, 0.1)
    * var clonedV1 = v1.clone();              //clonedV1=(0.5, 0.1)
    * @returns {DSMath.Vector2D} The clone of <i>this</i>.
    */
    Vector2D.prototype.clone = function ()
    {
      var v_out = new Vector2D(this.x, this.y);
      return v_out;
    };

    /**
    * @public
    * @description Copies value of iV to <i>this</i> vector.
    * @memberof DSMath.Vector2D
    * @method copy
    * @instance
    * @example
    * var v0 = new DSMath.Vector2D();
    * var v1 = new DSMath.Vector2D(0.5, 0.1); //v1=(0.5, 0.1)
    * v0.copy(v1); // v0!==v1 and v0=(0.5, 0.1)
    * @returns {DSMath.Vector2D} <i>this</i> modified vector reference.
    */
    Vector2D.prototype.copy = function (iToCopy)
    {
      DSMath.TypeCheck(iToCopy, true, DSMath.Vector2D);

      this.x = iToCopy.x;
      this.y = iToCopy.y;
      return this;
    };

    /**
    * @public
    * @description Assigns new coordinates values to <i>this</i> vector.
    * @param {Number} iX Value for the x coordinate.
    * @param {Number} iY Value for the y coordinate.
    * @memberof DSMath.Vector2D
    * @method set
    * @instance
    * @example
    * var v0 = new DSMath.Vector2D(); // v0=(0.0, 0.0)
    * v0.set(1.0, 2.0);               // v0=(1.0, 2.0)
    * @returns {DSMath.Vector2D } <i>this</i> modified vector reference.
    */
    Vector2D.prototype.set = function (iX, iY)
    {
      DSMath.TypeCheck(iX, true, 'number');
      DSMath.TypeCheck(iY, true, 'number');

      this.x = iX;
      this.y = iY;
      return this
    };

    /**
    * @public
    * @description Assigns new x coordinates values to <i>this</i> vector.
    * @param {Number} iX Value for the x coordinate.
    * @memberof DSMath.Vector2D
    * @method setX
    * @instance
    * @example
    * var v0 = new DSMath.Vector2D(); // v0=(0.0, 0.0)
    * v0.setX(1.0);                   // v0=(1.0, 0.0)
    * @returns {DSMath.Vector2D } <i>this</i> modified vector reference.
    */
    Vector2D.prototype.setX = function (iX)
    {
      DSMath.TypeCheck(iX, true, 'number');

      this.x = iX;
      return this;
    };

    /**
    * @public
    * @description Assigns new y coordinates values to <i>this</i> vector.
    * @param {Number} iY Value for the y coordinate.
    * @memberof DSMath.Vector2D
    * @method setY
    * @instance
    * @example
    * var v0 = new DSMath.Vector2D(); // v0=(0.0, 0.0)
    * v0.setY(1.0);                   // v0=(0.0, 1.0)
    * @returns {DSMath.Vector2D } <i>this</i> modified vector reference.
    */
    Vector2D.prototype.setY = function (iY)
    {
      DSMath.TypeCheck(iY, true, 'number');

      this.y = iY;
      return this;
    };

    /**
    * @public
    * @description Assigns new coordinates values to a vector.
    * @param {Number[]} iA The array of size 2 containing the new vector coordinates.
    * @memberof DSMath.Vector2D
    * @method setFromArray
    * @instance
    * @example
    * var v0 = new DSMath.Vector2D(); // v0=(0,0)
    * var coord = [1,2];
    * v0.setFromArray(coord);         // v0=(1,2)
    * @returns {DSMath.Vector2D } <i>this</i> modified vector reference.
    */
    Vector2D.prototype.setFromArray = function (iA)
    {
      DSMath.TypeCheck(iA, true, ['number'], 2);

      this.x = iA[0];
      this.y = iA[1];
      return this;
    };

    /**
    * @public
    * @description
    * Assigns new coordinates values to a vector.
    * <br>
    * The vector equals to the difference between the given point and the origin.
    * @param {DSMath.Point2D} iP The point.
    * @memberof DSMath.Vector2D
    * @method setFromPoint
    * @instance
    * @example
    * var v0 = new DSMath.Vector2D();   // v0=(0,0)
    * var p0 = new DSMath.Point2D(1,2); // p0=(1,2)
    * v0.setFromPoint(p0);              // v0=(1,2)
    * @returns {DSMath.Vector2D } <i>this</i> modified vector reference.
    */
    Vector2D.prototype.setFromPoint = function (iP)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point2D);

      this.x = iP.x;
      this.y = iP.y;
      return this;
    };

    /**
    * @public
    * @description Retrieves <i>this</i> vector coordinates values into an array of size 2.
    * @param {Number[]} [oA] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Vector2D
    * @method getArray
    * @instance
    * @example
    * var v0 = new DSMath.Vector2D(1,2);
    * var coord = v0.getArray();         // coord=[1,2]
    * @returns {Number[]} The reference of the operation result - array of size 2 containing this vector coordinates.
    */
    Vector2D.prototype.getArray = function (oA)
    {
      DSMath.TypeCheck(oA, false, ['number'], 2);

      oA = oA || new Array(2);
      oA[0] = this.x;
      oA[1] = this.y;
      return oA;
    };

    /**
    * @public
    * @description Computes the squared norm of a vector (x<sup>2</sup> + y<sup>2</sup>).
    * @memberof DSMath.Vector2D
    * @method squareNorm
    * @instance
    * @example
    * var v1 = new DSMath.Vector2D(0.5, 0.1);
    * var sqNormV1 = v1.squareNorm(); // sqNormV1 = 0.26
    * @returns {Number} The square norm of <i>this</i> vector.
    */
    Vector2D.prototype.squareNorm = function ()
    {
      var sqNorm = this.x * this.x + this.y * this.y;
      return sqNorm;
    };

    /**
    * @public
    * @description Computes the norm of a vector &#8730;<span style="text-decorationverline;">(x<sup>2</sup> + y<sup>2</sup>)</span>.
    * @memberof DSMath.Vector2D
    * @method norm
    * @instance
    * @example
    * var v1 = new DSMath.Vector2D(0.5, 0.1);
    * var normV1 = v1.norm(); // normV1 ~= 0.5099
    * @returns {Number} The norm of <i>this</i> Vector2D.
    */
    Vector2D.prototype.norm = function ()
    {
      return Math.sqrt(this.x * this.x + this.y * this.y);
    };

    /**
    * @public
    * @description Normalizes <i>this</i> vector.
    * @memberof DSMath.Vector2D
    * @method normalize
    * @instance
    * @example
    * var v1 = new DSMath.Vector2D(1, 1);
    * v1.normalize(); // v1=(1/&#8730;2, 1/&#8730;2);
    * @returns {DSMath.Vector2D} <i>this</i> modified vector reference.
    */
    Vector2D.prototype.normalize = function ()
    {
      var Tol = DSMath.defaultTolerances.epsilonForRelativeTest;
      var sqNorm = this.x * this.x + this.y * this.y;
      var inv_norm = (Math.abs(sqNorm - 1) <= 2 * Tol) ? 1. : 1. / Math.sqrt(sqNorm);

      this.x *= inv_norm;
      this.y *= inv_norm;

      return this;
    }

    /**
    * @public
    * @description Reverses the direction of <i>this</i> vector.
    * @memberof DSMath.Vector2D
    * @method negate
    * @instance
    * @example
    * var v1 = new DSMath.Vector2D(1, 0);
    * var v2 = v1.negate(); // v1===v2 and v1=(-1,0)
    * @returns {DSMath.Vector2D} <i>this</i> modified vector reference.
    */
    Vector2D.prototype.negate = function ()
    {
      this.x *= -1.0;
      this.y *= -1.0;
      return this;
    };

    /**
    * @public
    * @description Add a vector to <i>this</i> vector.
    * @param {DSMath.Vector2D} iV The vector to add.
    * @memberof DSMath.Vector2D
    * @method add
    * @instance
    * @example
    * var v0 = new DSMath.Vector2D(1,2);
    * var v1 = new DSMath.Vector2D(4,5);
    * var v2 = v0.add(v1); // v2===v0 and v2=v0+v1=(5,7);
    * @returns {DSMath.Vector2D} <i>this</i> modified vector reference.
    */
    Vector2D.prototype.add = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);

      this.x += iV.x;
      this.y += iV.y;
      return this;
    };

    /**
    * @public
    * @description Add a vector multiplied by a value to <i>this</i> vector.
    * @param {DSMath.Vector2D} iV The vector to add.
    * @param {Number} iS The scale.
    * @memberof DSMath.Vector2D
    * @method addScaledVector
    * @instance
    * @example
    * var v0 = new DSMath.Vector2D(1,2);
    * var v1 = new DSMath.Vector2D(2,4);
    * var v2 = v0.addScaledVector(v1, 0.5); // v2===v0 is true and v2=v0+0.5*v1=(2,4);
    * @returns {DSMath.Vector2D} <i>this</i> modified vector reference.
    */
    Vector2D.prototype.addScaledVector = function (iV, iS)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);
      DSMath.TypeCheck(iS, true, 'number');

      this.x += iS * iV.x;
      this.y += iS * iV.y;
      return this;
    };

    /**
    * @public
    * @description Add a scalar to each coordinate of <i>this</i> Vector2D.
    * @param {Number} iS The scalar to add.
    * @memberof DSMath.Vector2D
    * @method addScalar
    * @instance
    * @example
    * var v0 = new DSMath.Vector2D(1,2);
    * var v1 = v0.addScalar(2); // v1===v0 and v0=(3,4);
    * @returns {DSMath.Vector2D} <i>this</i> modified vector reference.
    */
    Vector2D.prototype.addScalar = function (iS)
    {
      DSMath.TypeCheck(iS, true, 'number');

      this.x += iS;
      this.y += iS;
      return this;
    };

    /**
    * @public
    * @description Subtract a vector to <i>this</i> vector.
    * @param {DSMath.Vector2D} iV The vector to sub.
    * @memberof DSMath.Vector2D
    * @method sub
    * @instance
    * @example
    * var v0 = new DSMath.Vector2D(1,2);
    * var v1 = new DSMath.Vector2D(4,5);
    * var v2 = v0.sub(v1); // v2===v0 is true and v2=v0-v1=(-3,-3);
    * @returns {DSMath.Vector2D} <i>this</i> modified vector reference.
    */
    Vector2D.prototype.sub = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);

      this.x -= iV.x;
      this.y -= iV.y;
      return this;
    };

    /**
    * @public
    * @description Subtract a vector multiplied by a value to <i>this</i> vector.
    * @param {DSMath.Vector2D} iV The vector to sub.
    * @param {Number}          iS The scale.
    * @memberof DSMath.Vector2D
    * @method subScaledVector
    * @instance
    * @example
    * var v0 = new DSMath.Vector2D(1,2);
    * var v1 = new DSMath.Vector2D(2,4);
    * var v2 = v0.subScaledVector(v1, 0.5); // v2===v0 is true and v2=v0-0.5*v1=(0,0);
    * @returns {DSMath.Vector2D} <i>this</i> modified vector reference.
    */
    Vector2D.prototype.subScaledVector = function (iV, iS)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);
      DSMath.TypeCheck(iS, true, 'number');

      this.x -= iS * iV.x;
      this.y -= iS * iV.y;
      return this;
    };

    /**
    * @public
    * @description Subtract a scalar to each coordinate of <i>this</i> vector.
    * @param {Number} iS The scalar to sub.
    * @memberof DSMath.Vector2D
    * @method subScalar
    * @instance
    * @example
    * var v0 = new DSMath.Vector2D(1,2);
    * var v1 = v0.subScalar(2); // v1===v0 and v0=(-1,0);
    * @returns {DSMath.Vector2D} <i>this</i> modified vector reference.
    */
    Vector2D.prototype.subScalar = function (iS)
    {
      DSMath.TypeCheck(iS, true, 'number');

      this.x -= iS;
      this.y -= iS;
      return this;
    };

    /**
    * @public
    * @description Multiplies <i>this</i> vector by a given scalar.
    * @param {Number} iS The scalar.
    * @memberof DSMath.Vector2D
    * @method multiplyScalar
    * @instance
    * @example
    * var v1 = new DSMath.Vector2D(1,2);
    * var v2 = v1.multiplyScalar(2); // v1=v2=(2,4);
    * @returns {DSMath.Vector2D} <i>this</i> modified vector reference.
    */
    Vector2D.prototype.multiplyScalar = function (iS)
    {
      DSMath.TypeCheck(iS, true, 'number');

      this.x *= iS;
      this.y *= iS;
      return this;
    };

    /**
    * @public
    * @description Divides <i>this</i> vector by a scalar.
    * @param {Number} iS The scalar.
    * @memberof DSMath.Vector2D
    * @method divideScalar
    * @instance
    * @example
    * var v1 = new DSMath.Vector2D(1,0);
    * var v2 = v1.divideScalar(2); // v1===v2 and v1=(0.5,0);
    * @returns {DSMath.Vector2D} <i>this</i> modified vector reference.
    */
    Vector2D.prototype.divideScalar = function (iS)
    {
      DSMath.TypeCheck(iS, true, 'number');

      this.x /= iS;
      this.y /= iS;
      return this;
    };

    /**
    * @public
    * @description Computes the dot product between <i>this</i> and a given vector.
    * @param {DSMath.Vector2D} iV The vector.
    * @memberof DSMath.Vector2D
    * @method dot
    * @instance
    * @example
    * var v1 = DSMath.Vector2D.xVect;
    * var v2 = new DSMath.Vector2D(0.1,2);
    * var dot = v1.dot(v2); // dot = 0.1;
    * @returns {Number } The dot product of <i>this</i> and iV.
    */
    Vector2D.prototype.dot = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);

      var result = this.x * iV.x + this.y * iV.y;
      return result;
    };

    /**
    * @public
    * @description Computes the cross product of two vectors.
    * @param {DSMath.Vector2D} iV The Vector2D to be cross-multiplied by <i>this</i>.
    * @memberof DSMath.Vector2D
    * @method cross
    * @instance
    * @example
    * var v0 = DSMath.Vector2D.xVect;
    * var v1 = DSMath.Vector2D.yVect;
    * var crossProd = v0.cross(v1); // crossProd=1.0
    * @returns {Number } The cross product of <i>this</i> and iV.
    */
    Vector2D.prototype.cross = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);

      var result = this.x * iV.y - this.y * iV.x;
      return result;
    };

    /**
    * @public
    * @description Determines whether of <i>this</i> vector with a given one.
    * <br>
    * Note if one vector is ~=(0, 0, 0) the vector are considered as orthogonal.
    * @param {DSMath.Vector2D} iV The other vector.
    * @memberof DSMath.Vector2D
    * @method isOrthogonal
    * @instance
    * @example
    * var v1 = new DSMath.Vector2D(0.0, 1.0);
    * var boolOrtho = DSMath.Vector2D.xVect.isOrthogonal(v1); // true.
    * @returns {boolean} true if the vector is orthogonal with <i>this</i> vector, false otherwise.
    */
    Vector2D.prototype.isOrthogonal = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);

      var boolOrtho = false;
      var sqNorm = this.squareNorm();
      var sqNormU = iV.squareNorm();
      var sqRelTol = DSMath.defaultTolerances.epsilonForSquareAngleTest;
      var sqScal = this.dot(iV);
      sqScal = sqScal * sqScal;

      boolOrtho = (sqNorm <= sqRelTol * Math.min(1, sqNormU) ||
                   sqNormU <= sqRelTol * Math.min(1, sqNorm));
      boolOrtho = (boolOrtho) ? boolOrtho :
                               (sqScal <= sqNorm * sqNormU * sqRelTol);

      return boolOrtho;
    };

    /**
    * @public
    * @description Determines whether <i>this</i> vector is colinear with another one.
    * <br>
    * Note if one vector is ~=(0, 0) the vector are considered as colinear.
    * @param {DSMath.Vector2D} iV The other vector.
    * @memberof DSMath.Vector2D
    * @method isParallel
    * @instance
    * @example
    * var v1 = new DSMath.Vector2D(1.2, 0);
    * var boolParalx = DSMath.Vector2D.xVect.isParallel(v1); // true.
    * var boolParaly = DSMath.Vector2D.yVect.isParallel(v1); // false.
    * @returns {boolean} true if the vector is colinear with <i>this</i> vector, false otherwise.
    */
    Vector2D.prototype.isParallel = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);

      var boolParal = false;
      var sqNorm = this.squareNorm();
      var sqNormU = iV.squareNorm();
      var sqRelTol = DSMath.defaultTolerances.epsilonForSquareAngleTest;
      var sqTol = 1 - sqRelTol;
      var sqScal = this.dot(iV);
      sqScal = sqScal * sqScal;

      boolParal = (sqNorm <= sqRelTol * Math.min(1, sqNormU) ||
                   sqNormU <= sqRelTol * Math.min(1, sqNorm));
      boolParal = (boolParal) ? boolParal :
                               (sqScal >= sqNorm * sqNormU * sqTol);

      return boolParal;
    }

    /**
    * @public
    * @description Retrieves the orthogonal decomposition of <i>this</i> vector related to a given reference vector.
    * @param {DSMath.Vector2D} iVRef The reference vector.
    * @memberof DSMath.Vector2D
    * @method orthoComponents
    * @instance
    * @example
    * var v1 = new DSMath.Vector2D(0.5, 0.1);
    * var orthoComp = v1.orthoComponents(DSMath.Vector2D.xVect); // orthoComp = [(0.5,0), (0,0.1)].
    * @returns {DSMath.Vector2D[]} Array made up of the parallel and normal components.
    */
    Vector2D.prototype.orthoComponents = function (iVRef)
    {
      DSMath.TypeCheck(iVRef, true, DSMath.Vector2D);

      var oParallelComponent = Vector2D.project(this, iVRef);
      var oNormalComponent = Vector2D.sub(this, oParallelComponent);
      var oResult = [oParallelComponent, oNormalComponent];
      return oResult;
    };

    /**
    * @public
    * @description Compares <i>this</i> vector with another one for equality.
    * @param {DSMath.Vector2D} iV       The vector to be compared with <i>this</i>.
    * @param {Number}                       [iTol=0] The comparaison accuracy. If not given, strict comparaison is performed.
    * @memberof DSMath.Vector2D
    * @method isEqual
    * @instance
    * @example
    * var v1 = new DSMath.Vector2D(1.0011,0);
    * var v2 = new DSMath.Vector2D(1.0001,0);
    * var vX = DSMath.Vector2D.xVect;
    * var boolV1VX = v1.isEqual(vX, 0.001); // boolV1VX = FALSE;
    * var boolV2VX = v2.isEqual(vX, 0.001); // boolV2VX = TRUE;
    * @returns {boolean} true if the vectors have equal coordinates at the given tolerance, false otherwise.
    */
    Vector2D.prototype.isEqual = function (iV, iTol)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);
      DSMath.TypeCheck(iTol, false, 'number');

      var bEq = false;
      if ((arguments.length < 2))
      {
        bEq = (this.x == iV.x) && (this.y == iV.y);
      }
      else
      {
        bEq = !((Math.abs(this.x - iV.x) > iTol) || (Math.abs(this.y - iV.y) > iTol));
      }
      return bEq;
    };

    /**
    * @public
    * @description Check if <i>this</i> vector is normalized or not.
    * @memberof DSMath.Vector2D
    * @method isNormalized
    * @instance
    * @example
    * var v1 = new DSMath.Vector2D(1,0);
    * var v2 = new DSMath.Vector2D(1.0001,0);
    * var v1IsNormalized = v1.isNormalized(); // v1IsNormalized=true
    * var v2IsNormalized = v2.isNormalized(); // v2IsNormalized=false
    * @returns {boolean} true if <i>this</i> vector is normalized, false otherwise.
    */
    Vector2D.prototype.isNormalized = function ()
    {
      var Tol = DSMath.defaultTolerances.epsilonForRelativeTest;
      var sqNorm = this.squareNorm();
      return (Math.abs(sqNorm - 1) <= 2 * Tol);
    };


    /**
    * @public
    * @description Project <i>this</i> vector on another vector.
    * @param {DSMath.Vector2D} iVSupport The vector projection vector support.
    * @memberof DSMath.Vector2D
    * @method project
    * @instance
    * @example
    * var v1 = new DSMath.Vector2D(0.1,0.2);
    * var vX = v1.project(DSMath.Vector2D.xVect); // vX===v1 and v1=(0.1,0).
    * @return {DSMath.Vector2D} <i>this</i> modified vector reference.
    */
    Vector2D.prototype.project = function (iVSupport)
    {
      DSMath.TypeCheck(iVSupport, true, DSMath.Vector2D);

      var vSupportSqNorm = iVSupport.squareNorm();
      var projLength = this.dot(iVSupport) / vSupportSqNorm;
      this.copy(iVSupport);
      this.multiplyScalar(projLength);
      return this;
    };

    /**
    * @public
    * @description Project <i>this</i> vector on the orthogonal vector of iVRef.
    * <br>
    * this and iVref shall not be colinear.
    * @param {DSMath.Vector2D} iVRef The reference vector.
    * @memberof DSMath.Vector2D
    * @method projectOrthogonal
    * @instance
    * @example
    * var v1 = new DSMath.Vector2D(1.1, 2.2);
    * var vProjOrtho = v1.projectOrthogonal(DSMath.Vector2D.xVect); // vProjOrtho===v1 and v1=(0, 2.2).
    * @return {DSMath.Vector2D} <i>this</i> modified vector reference.
    */
    Vector2D.prototype.projectOrthogonal = function (iVRef)
    {
      DSMath.TypeCheck(iVRef, true, DSMath.Vector2D);

      var vSupportSqNorm = iVRef.squareNorm();
      var projLength = this.dot(iVRef) / vSupportSqNorm;
      this.subScaledVector(iVRef, projLength);
      return this;
    };

    /**
    * @public
    * @description Computes the linear interpolation between <i>this</i> vector and another one.
    * @param {DSMath.Vector2D} iV The vector reference for the interpolation.
    * @param {Number}                       iR The ratio in [0, 1].
    * @memberof DSMath.Vector2D
    * @method lerp
    * @instance
    * @example
    * var v1 = DSMath.Vector2D.xVect.clone(); // v1=(1,0)
    * var v2 = DSMath.Vector2D.yVect;         // v2=(0,1)
    * var intV = v1.lerp(v2, 0.4);             // v1=intV=(0.6,0.4)
    * @returns {DSMath.Vector2D } <i>this</i> modified vector reference.
    */
    Vector2D.prototype.lerp = function (iV, iR)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);
      DSMath.TypeCheck(iR, true, 'number');
      this.x += iR * (iV.x - this.x);
      this.y += iR * (iV.y - this.y);

      return this;
    };

    /**
    * @public
    * @description Get the angle between <i>this</i> vector and another one.
    * @param {DSMath.Vector2D} iV The other vector.
    * @memberof DSMath.Vector2D
    * @method getAngleTo
    * @instance
    * @example
    * var v1 = new DSMath.Vector2D(Math.cos(Math.PI/4.0), Math.sin(Math.PI/4.0));
    * var v2 = new DSMath.Vector2D(Math.cos(Math.PI/3.0), Math.sin(Math.PI/3.0));
    * var angleV1V2 = v1.getAngleTo(v2); // PI/12
    * var angleV1Vx = v1.getAngleTo(DSMath.Vector2D.xVect); // PI/4
    * @returns {Number} the angle in [0, PI].
    */
    Vector2D.prototype.getAngleTo = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);

      return Math.abs(this.getSignedAngleTo(iV));
    };

    /**
    * @public
    * @description Get the signed angle between <i>this</i> vector and another one.
    * <br>
    * The angle sign is the same as this.cross(iV) sign.
    * @param {DSMath.Vector2D} iV The other Vector2D.
    * @memberof DSMath.Vector2D
    * @method getSignedAngleTo
    * @instance
    * @example
    * var v1 = new DSMath.Vector2D(Math.cos(Math.PI/4.0), Math.sin(Math.PI/4.0));
    * var v2 = new DSMath.Vector2D(Math.cos(Math.PI/3.0), Math.sin(Math.PI/3.0));
    * var angleV1V2 = v1.getSignedAngleTo(v2); // PI/12
    * var angleV2V1 = v2.getSignedAngleTo(v1); // -PI/12
    * var angleV1Vx = v1.getSignedAngleTo(DSMath.Vector2D.xVect); // -PI/4
    * @returns {Number} the angle in [-PI, PI].
    */
    Vector2D.prototype.getSignedAngleTo = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);

      var angle = 0;
      var sqNorm1 = this.squareNorm();
      var sqNorm2 = iV.squareNorm();
      if (sqNorm1 != 0 && sqNorm2 != 0)
      {
        var x = this.dot(iV);
        var y = this.cross(iV);
        angle = Math.atan2(y, x);
      }
      return angle;
    };

    /**
    * @public
    * @description Clamps <i>this</i> vector coordinates between two vectors coordinates.
    * @param {DSMath.Vector2D} iMin The vector containing the min coordinates.
    * @param {DSMath.Vector2D} iMax The vector containing the max coordinates.
    * @memberof DSMath.Vector2D
    * @method clamp
    * @instance
    * @example
    * var v1 = new DSMath.Vector2D(2,1);
    * var minV = new DSMath.Vector2D(1.4, 1.5);
    * var maxV = new DSMath.Vector2D(1.8, 2.5);
    * var vClamp = v1.clamp(minV, maxV); // vClamp===v1 and vClamp=(1.8, 1.5);
    * @returns {DSMath.Vector2D} <i>this</i> modified vector reference.
    */
    Vector2D.prototype.clamp = function (iMin, iMax)
    {
      DSMath.TypeCheck(iMin, true, DSMath.Vector2D);
      DSMath.TypeCheck(iMax, true, DSMath.Vector2D);

      this.x = this.x < iMin.x ? iMin.x : (this.x > iMax.x ? iMax.x : this.x);
      this.y = this.y < iMin.y ? iMin.y : (this.y > iMax.y ? iMax.y : this.y);
      return this;
    };

    /**
    * @public
    * @description Clamps <i>this</i> vector coordinates between two Number values
    * @param {Number} iMin The min value.
    * @param {Number} iMax The max value.
    * @memberof DSMath.Vector2D
    * @method clampScalar
    * @instance
    * @example
    * var v1 = new DSMath.Vector2D(2,1);
    * var vClamp = v1.clampScalar(1.5, 1.8); // vClamp===v1 and vClamp=(1.8, 1.5);
    * @returns {DSMath.Vector2D} <i>this</i> modified vector reference.
    */
    Vector2D.prototype.clampScalar = function (iMin, iMax)
    {
      DSMath.TypeCheck(iMin, true, 'number');
      DSMath.TypeCheck(iMax, true, 'number');

      this.x = this.x < iMin ? iMin : (this.x > iMax ? iMax : this.x);
      this.y = this.y < iMin ? iMin : (this.y > iMax ? iMax : this.y);
      return this;
    };

    /**-----------------------------------------
     * -------------- STATIC -------------------
     * -----------------------------------------
     */
    /**
    * @public
    * @name xVect
    * @type {Number}
    * @readonly
    * @memberOf DSMath.Vector2D
    * @description The (1, 0) vector.
    */
    Object.defineProperty(Vector2D, "xVect", {
      value: new Vector2D(1.0, 0),
      writable: false,
      enumerable: true,
      configurable: false
    });
    Object.freeze(Vector2D.xVect); // We need to freeze the object. Only the value was read only.

    /**
    * @public
    * @name yVect
    * @type {Number}
    * @readonly
    * @memberOf DSMath.Vector2D
    * @description The (0, 1) vector.
    */
    Object.defineProperty(Vector2D, "yVect", {
      value: new Vector2D(0, 1.0),
      writable: false,
      enumerable: true,
      configurable: false
    });
    Object.freeze(Vector2D.yVect); // We need to freeze the object. Only the value was read only.

    /**
    * @public
    * @description Creates a new vector equals to the normalized form of a vector.
    * @param {DSMath.Vector2D} iV   The vector to clone and normalize.
    * @param {DSMath.Vector2D} [oV] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Vector2D
    * @method normalize
    * @static
    * @example
    * var v1 = new DSMath.Vector2D(1,1)
    * var v1Normalized = DSMath.Vector2D.normalize(v1); // v1Normalized=(1.0/&#8730;2,1.0/&#8730;2)
    * @returns {DSMath.Vector2D} The reference of the operation result.
    */
    Vector2D.normalize = function (iV, oV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);
      DSMath.TypeCheck(oV, false, DSMath.Vector2D);

      oV = (oV) ? oV.copy(iV) : iV.clone();
      return oV.normalize();
    };

    /**
    * @public
    * @description Creates a new vector equals to the addition of two vectors.
    * @param {DSMath.Vector2D} iV1 The first vector.
    * @param {DSMath.Vector2D} iV2 The second vector.
    * @param {DSMath.Vector2D} [oV] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Vector2D
    * @method add
    * @static
    * @example
    * var v0 = new DSMath.Vector2D(1,2);
    * var v1 = new DSMath.Vector2D(4,5);
    * var v2 = DSMath.Vector2D.add(v0, v1); // v2!==v0 and v2=v0+v1=(5,7);
    * @returns {DSMath.Vector2D} The reference of the operation result.
    */
    Vector2D.add = function (iV1, iV2, oV)
    {
      DSMath.TypeCheck(iV1, true, DSMath.Vector2D);
      DSMath.TypeCheck(iV2, true, DSMath.Vector2D);
      DSMath.TypeCheck(oV, false, DSMath.Vector2D);

      if (arguments.length < 3) oV = new Vector2D();
      oV.x = iV1.x + iV2.x;
      oV.y = iV1.y + iV2.y;
      return oV;
    };

    /**
    * @public
    * @description Creates a new vector equals to the subtraction of two vectors.
    * @param {DSMath.Vector2D} iV1 The first vector.
    * @param {DSMath.Vector2D} iV2 The second vector.
    * @param {DSMath.Vector2D} [oV] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Vector2D
    * @method sub
    * @static
    * @example
    * var v0 = new DSMath.Vector2D(1,2);
    * var v1 = new DSMath.Vector2D(4,5);
    * var v2 = DSMath.Vector2D.sub(v0, v1); // v2!==v0 and v2=v0-v1=(-3,-3);
    * @returns {DSMath.Vector2D} The reference of the operation result.
    */
    Vector2D.sub = function (iV1, iV2, oV)
    {
      DSMath.TypeCheck(iV1, true, DSMath.Vector2D);
      DSMath.TypeCheck(iV2, true, DSMath.Vector2D);
      DSMath.TypeCheck(oV, false, DSMath.Vector2D);

      if (arguments.length < 3) oV = new Vector2D();
      oV.x = iV1.x - iV2.x;
      oV.y = iV1.y - iV2.y;
      return oV;
    };


    /**
    * @public
    * @description Creates a new vector equals to the reversed direction of a vector.
    * @param {DSMath.Vector2D} iV   The vector to be reversed.
    * @param {DSMath.Vector2D} [oV] The reference of the operation result (avoid allocation).
    * @memberof DSMath.Vector2D
    * @method negate
    * @static
    * @example
    * var v1 = DSMath.Vector2D.xVect;
    * var v2 = DSMath.Vector2D.negate(v1); // v1 = (1, 0) and  v2=(-1, 0)
    * @returns {DSMath.Vector2D} The reference of the operation result.
    */
    Vector2D.negate = function (iV, oV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);
      DSMath.TypeCheck(oV, false, DSMath.Vector2D);

      oV = (oV) ? oV.copy(iV) : iV.clone();
      return oV.negate();
    };

    /**
    * @public
    * @description Creates a new vector equals to the multiplication of a vector by a scalar.
    * @param {DSMath.Vector2D} iV   The vector to be multiplied.
    * @param {Number}          iS   The scalar.
    * @param {DSMath.Vector2D} [oV] The reference of the operation result (avoid allocation).
    * @memberof DSMath.Vector2D
    * @method multiplyScalar
    * @static
    * @example
    * var v1 = new DSMath.Vector2D(1,2);
    * var v2 = DSMath.Vector2D.multiplyScalar(v1, 2); // v2=(2,4);
    * @returns {DSMath.Vector2D} The reference of the operation result.
    */
    Vector2D.multiplyScalar = function (iV, iS, oV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);
      DSMath.TypeCheck(iS, true, 'number');
      DSMath.TypeCheck(oV, false, DSMath.Vector2D);

      oV = (oV) ? oV.copy(iV) : iV.clone();
      return oV.multiplyScalar(iS);
    };

    /**
    * @public
    * @description Creates a new vector equals to the division of a vector by a scalar.
    * @param {DSMath.Vector2D} iV   The vector to be divided.
    * @param {Number}          iS   The scalar.
    * @param {DSMath.Vector2D} [oV] The reference of the operation result (avoid allocation).
    * @memberof DSMath.Vector2D
    * @method divideScalar
    * @static
    * @example
    * var v1 = DSMath.Vector2D.xVect;
    * var v2 = DSMath.Vector2D.divideScalar(v1, 2); // v2=(0.5,0);
    * @returns {DSMath.Vector2D} The reference of the operation result.
    */
    Vector2D.divideScalar = function (iV, iS, oV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);
      DSMath.TypeCheck(iS, true, 'number');
      DSMath.TypeCheck(oV, false, DSMath.Vector2D);

      oV = (oV) ? oV.copy(iV) : iV.clone();
      return oV.divideScalar(iS);
    };

    /**
    * @public
    * @description Creates a new vector equals to the projection of a vector on another vector.
    * @param {DSMath.Vector2D} iV        The vector to project.
    * @param {DSMath.Vector2D} iVSupport The projection vector support.
    * @param {DSMath.Vector2D} [oV] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Vector2D
    * @method project
    * @static
    * @example
    * var v1 = new DSMath.Vector2D(0.1,0.2);
    * var vX = DSMath.Vector2D.project(v1, DSMath.Vector2D.xVect); // vX!==v1 and vx=(0.1,0), v1=(0.1,0.2).
    * @return {DSMath.Vector2D} The reference of the operation result - the projection result.
    */
    Vector2D.project = function (iV, iVSupport, oV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);
      DSMath.TypeCheck(iVSupport, true, DSMath.Vector2D);
      DSMath.TypeCheck(oV, false, DSMath.Vector2D);

      oV = (oV) ? oV : new Vector2D();

      var vSupportSqNorm = iVSupport.squareNorm();
      var projLength = iV.dot(iVSupport) / vSupportSqNorm;

      return oV.copy(iVSupport).multiplyScalar(projLength);
    };

    /**
    * @public
    * @description Creates a new vector equals to the linear interpolation between two vectors.
    * @param {DSMath.Vector2D} iV1  The first  vector reference for the interpolation.
    * @param {DSMath.Vector2D} iV2  The second vector reference for the interpolation.
    * @param {Number}                       iR   The ratio in [0, 1].
    * @param {DSMath.Vector2D} [oV] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Vector2D
    * @method lerp
    * @static
    * @example
    * var v1 = DSMath.Vector2D.xVect; // v1=(1,0)
    * var v2 = DSMath.Vector2D.yVect; // v2=(0,1)
    * var intV = DSMath.Vector2D.lerp(v1, v2, 0.4); // intV=(0.6,0.4)
    * @returns {DSMath.Vector2D } The reference of the operation result.
    */
    Vector2D.lerp = function (iV1, iV2, iR, oV)
    {
      DSMath.TypeCheck(iV1, true, DSMath.Vector2D);
      DSMath.TypeCheck(iV2, true, DSMath.Vector2D);
      DSMath.TypeCheck(iR, true, 'number');
      DSMath.TypeCheck(oV, false, DSMath.Vector2D);

      oV = (oV) ? oV : new Vector2D();

      oV.x = iV1.x + iR * (iV2.x - iV1.x);
      oV.y = iV1.y + iR * (iV2.y - iV1.y);

      return oV;
    };

    /**
    * @public
    * @description Normalize iV1 and iV2 and change iV2 such as iV2.isOrthogonal(iV1) is true.
    * <br>
    * The two inputs vectors shall not be colinear.
    * @param {DSMath.Vector2D} ioV1 The first vector to be normalized.
    * @param {DSMath.Vector2D} ioV2 The second vector to be normalized and change such as iV2.isOrthogonal(iV1) is true.
    * @memberof DSMath.Vector2D
    * @method orthoNormalize
    * @static
    * @example
    * var v1 = new DSMath.Vector2D(1,1);
    * var v2 = new DSMath.Vector2D(0,1);
    * DSMath.Vector2D.orthoNormalize(v1, v2); //v1=(1/&#8730;2, 1/&#8730;2) and v2=(-1/&#8730;2, 1/&#8730;2)
    */
    Vector2D.orthoNormalize = function (ioV1, ioV2)
    {
      DSMath.TypeCheck(ioV1, true, DSMath.Vector2D);
      DSMath.TypeCheck(ioV2, true, DSMath.Vector2D);

      ioV1.normalize();
      ioV2.projectOrthogonal(ioV1);
      ioV2.normalize();
    };

    DSMath.Vector2D = Vector2D;

    return Vector2D;
  }
);

