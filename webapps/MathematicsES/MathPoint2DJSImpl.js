define('MathematicsES/MathPoint2DJSImpl',
  ['MathematicsES/MathNameSpace',
   'MathematicsES/MathTypeCheck',
   'MathematicsES/MathTypeCheckInternal',
   'MathematicsES/MathVector2DJSImpl'
  ],
   
  function (DSMath, TypeCheck, TypeCheckInternal, Vector2D)
  {
    'use strict';

    /**
     * @public
     * @exports Point2D
     * @class
     * @classdesc Representation of a point in 2D.
     *
     * @constructor
     * @constructordesc Create a new Point2D with given (x, y) coordinates.
     * @param {Number} [x=0] The x coordinate of the point.
     * @param {Number} [y=0] The y coordinate of the point.
     * @memberof DSMath
     */
    var Point2D = function (x, y)
    {
      DSMath.TypeCheck(x, false, 'number');
      DSMath.TypeCheck(y, false, 'number');

      this.x = x || 0.;
      this.y = y || 0.;
    };

    /**
    * The x coordinate of a Point2D.
    * @public
    * @member
    * @instance
    * @name x
    * @type {Number}
    * @memberOf DSMath.Point2D
    */
    Point2D.prototype.x = null;

    /**
    * The y coordinate of a Point2D.
    * @public
    * @member
    * @instance
    * @name y
    * @type {Number}
    * @memberOf DSMath.Point2D
    */
    Point2D.prototype.y = null;

    Point2D.prototype.constructor = Point2D;

    /**
    * @public
    * @description Clones <i>this</i> point.
    * @memberof DSMath.Point2D
    * @method clone
    * @instance
    * @example
    * var p1 = new DSMath.Point2D(0.5, 0.1); //p1=(0.5, 0.1)
    * var clonedP1 = p1.clone();             //clonedP1=(0.5, 0.1)
    * @returns {DSMath.Point2D} The clone of <i>this</i>.
    */
    Point2D.prototype.clone = function ()
    {
      var p_out = new DSMath.Point2D(this.x, this.y);
      return p_out;
    };

    /**
    * @public
    * @description Copies value of iP to <i>this</i> point.
    * @param {DSMath.Point2D} iP The Point2D to copy.
    * @memberof DSMath.Point2D
    * @method copy
    * @instance
    * @example
    * var v0 = new DSMath.Point2D();             // v0 = (0. , 0. )
    * var v1 = new DSMath.Point2D(0.5, 0.1, 0.); // v1 = (0.5, 0.1)
    * v0.copy(v1);                               // v0 = (0.5, 0.1)
    * @returns {DSMath.Point2D} <i>this</i> modified point reference.
    */
    Point2D.prototype.copy = function (iPoint2DToCopy)
    {
      DSMath.TypeCheck(iPoint2DToCopy, true, DSMath.Point2D);

      this.x = iPoint2DToCopy.x;
      this.y = iPoint2DToCopy.y;
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Point2D
    * @method set
    * @instance
    * @description Assigns new coordinates values to <i>this</i> point.
    * @param {Number} iX Value for the x coordinate.
    * @param {Number} iY Value for the y coordinate.
    * @example
    * var p0 = new DSMath.Point2D(); // p0=(0,0)
    * p0.set(1.0, 2.0);              // p0=(1,2)
    * @returns {DSMath.Point2D } <i>this</i> modified point reference.
    */
    Point2D.prototype.set = function (iX, iY)
    {
      DSMath.TypeCheck(iX, true, 'number');
      DSMath.TypeCheck(iY, true, 'number');

      this.x = iX;
      this.y = iY;
      return this;
    };

    /**
    * @public
    * @description Assigns new coordinates values to a 2D point.
    * @param {Number[]} iA The array of size 2 containing the new point coordinates.
    * @memberof DSMath.Point2D
    * @method setFromArray
    * @instance
    * @example
    * var p0 = new DSMath.Point2D(); // p0=(0,0)
    * var coord = [1,2];
    * p0.setFromArray(coord);        // p0=(1,2)
    * @returns {DSMath.Point2D } <i>this</i> modified point reference.
    */
    Point2D.prototype.setFromArray = function (iA)
    {
      DSMath.TypeCheck(iA, true, ['number'], 2);

      this.x = iA[0];
      this.y = iA[1];
      return this;
    };

    /**
    * @public
    * @description
    * Assigns new coordinates values to <i>this</i> point.
    * <br>
    * The point coordinates will equals the vector one.
    * @param {DSMath.Vector2D} iV The vector.
    * @memberof DSMath.Point2D
    * @method setFromVector
    * @instance
    * @example
    * var p0 = new DSMath.Point2D();     // p0=(0,0)
    * var v0 = new DSMath.Vector2D(1,2); // v0=(1,2)
    * p0.setFromVector(v0);              // p0=(1,2)
    * @returns {DSMath.Point2D } <i>this</i> modified point reference.
    */
    Point2D.prototype.setFromVector = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);

      this.x = iV.x;
      this.y = iV.y;
      return this;
    };

    /**
    * @public
    * @description Retrieves <i>this</i> point coordinates values into an array of size 2.
    * @param {DSMath.Point2D} [oA] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Point2D
    * @method getArray
    * @instance
    * @example
    * var p0 = new DSMath.Point2D(1,2);
    * var coord = p0.getArray(); // coord=[1,2]
    * @returns {Number[]} The reference of the operation result - array of size 2 containing this point coordinates.
    */
    Point2D.prototype.getArray = function (oA)
    {
      DSMath.TypeCheck(oA, false, [DSMath.Point2D], 2);

      oA = oA || new Array(2);
      oA[0] = this.x;
      oA[1] = this.y;
      return oA;
    };


    /**
    * @public
    * @description Adds a point to <i>this</i> point.
    * @param {DSMath.Point2D} iP The Point2D.
    * @memberof DSMath.Point2D
    * @method add
    * @instance
    * @example
    * var p0 = new DSMath.Point2D(1,2);
    * var p1 = new DSMath.Point2D(1,1);
    * var p2 = p0.add(p1); // p2===p0 and p2=(2,3) and p1=(1,1).
    * @returns { DSMath.Point2D } <i>this</i> modified point reference.
    */
    Point2D.prototype.add = function (iP)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point2D);

      this.x += iP.x;
      this.y += iP.y;
      return this;
    };

    /**
    * @public
    * @description Adds a point multiplied by a value to <i>this</i> point.
    * @param {DSMath.Point2D} iP The point.
    * @param {Number} iS The scale.
    * @memberof DSMath.Point2D
    * @method addScaledPoint
    * @instance
    * @example
    * var p0 = new DSMath.Point2D(1,2);
    * var p1 = new DSMath.Point2D(1,1);
    * var p2 = p0.addScaledPoint(p1,0.5); // p2===p0 and p2=(1.5,2.5) and p1=(1,1).
    * @returns { DSMath.Point2D } <i>this</i> modified point reference.
    */
    Point2D.prototype.addScaledPoint = function (iP, iS)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point2D);
      DSMath.TypeCheck(iS, true, 'number');

      this.x += iS * iP.x;
      this.y += iS * iP.y;
      return this;
    };

    /**
    * @public
    * @description Adds a vector to <i>this</i> point.
    * @param {DSMath.Vector2D} iV The vector.
    * @memberof DSMath.Point2D
    * @method addVector
    * @instance
    * @example
    * var p0 = new DSMath.Point2D(1,2);
    * var v0 = new DSMath.Vector2D(1,1);
    * var p1 = p0.addVector(v0); // p0===p1 and p1=(2,3)
    * @returns {DSMath.Point2D } <i>this</i> modified point reference.
    */
    Point2D.prototype.addVector = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);

      this.x += iV.x;
      this.y += iV.y;
      return this;
    };

    /**
    * @public
    * @description Adds a vector multiplied by a value to <i>this</i> point.
    * @param {DSMath.Vector2D} iV The vector to add.
    * @param {Number} iS The scale.
    * @memberof DSMath.Point2D
    * @method addScaledVector
    * @instance
    * @example
    * var p0 = new DSMath.Point2D(1,2);
    * var v0 = new DSMath.Vector2D(1,1);
    * var p1 = p0.addScaledVector(v0,2); // p0===p1 and p1=(3,4)
    * @returns {DSMath.Point2D } <i>this</i> modified point reference.
    */
    Point2D.prototype.addScaledVector = function (iV, iS)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);
      DSMath.TypeCheck(iS, true, 'number');

      this.x += iV.x * iS;
      this.y += iV.y * iS;
      return this;
    };

    /**
    * @public
    * @description Subtract a point from <i>this</i> point.
    * @param {DSMath.Point2D}  iP   The point.
    * @param {DSMath.Vector2D} [oV] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Point2D
    * @method sub
    * @instance
    * @example
    * var p0 = new DSMath.Point2D(1,2);
    * var p1 = new DSMath.Point2D(1,1);
    * var v0 = p0.sub(p1); // p0=(1,2) and p1=(1,1) and v0=(0,1).
    * @returns { DSMath.Vector2D } The reference of the operation result.
    */
    Point2D.prototype.sub = function (iP, oV)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point2D);
      DSMath.TypeCheck(oV, false, DSMath.Vector2D);

      oV = oV || new Vector2D();
      oV.x = this.x - iP.x;
      oV.y = this.y - iP.y;
      return oV;
    };

    /**
    * @public
    * @description Subtract a vector from <i>this</i> point.
    * @param {DSMath.Vector2D} iV The vector.
    * @memberof DSMath.Point2D
    * @method subVector
    * @instance
    * @example
    * var p0 = new DSMath.Point2D(1,2);
    * var v0 = new DSMath.Vector2D(1,1);
    * var p1 = p0.subVector(v0); // v1===v0 and v1=(0,1);
    * @returns {DSMath.Point2D } <i>this</i> modified point reference.
    */
    Point2D.prototype.subVector = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);

      this.x -= iV.x;
      this.y -= iV.y;
      return this;
    };

    /**
    * @public
    * @description Subtract a vector multiplied by a value from <i>this</i> point.
    * @param {DSMath.Vector2D} iV The vector.
    * @param {Number}                       iS The scale.
    * @memberof DSMath.Point2D
    * @method subScaledVector
    * @instance
    * @example
    * var p0 = new DSMath.Point2D(1,2);
    * var v0 = new DSMath.Vector2D(1,1);
    * var p1 = p0.subScaledVector(v0,2); // p0===p1 and p1=(-1,0)
    * @returns {DSMath.Point2D } <i>this</i> modified point reference.
    */
    Point2D.prototype.subScaledVector = function (iV, iS)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);
      DSMath.TypeCheck(iS, true, 'number');

      this.x -= iV.x * iS;
      this.y -= iV.y * iS;
      return this;
    };

    /**
    * @public
    * @description Multiplies <i>this</i> Point2D by a scalar.
    * @param {Number} iS The scalar.
    * @memberof DSMath.Point2D
    * @method multiplyScalar
    * @instance
    * @example
    * var p0 = new DSMath.Point2D(1,2);
    * var s = 2;
    * var p1 = p0.multiplyScalar(s); // p0===p1 and p1=(2,4) and s=2
    * @returns { DSMath.Point2D } <i>this</i> modified point reference.
    */
    Point2D.prototype.multiplyScalar = function (iS)
    {
      DSMath.TypeCheck(iS, true, 'number');

      this.x *= iS;
      this.y *= iS;
      return this;
    };

    /**
    * @public
    * @description Divides <i>this</i> point by a scalar.
    * @param {Number} iS The scalar.
    * @memberof DSMath.Point2D
    * @method divideScalar
    * @instance
    * @example
    * var p0 = new DSMath.Point2D(1,2);
    * var s = 2;
    * var p1 = p0.divideScalar(s); // p0===p1 and p1=(0.5,1) and s=2
    * @returns { DSMath.Point2D } <i>this</i> modified point reference.
    */
    Point2D.prototype.divideScalar = function (iS)
    {
      DSMath.TypeCheck(iS, true, 'number');

      this.x /= iS;
      this.y /= iS;
      return this;
    };

    /**
    * @public
    * @description Returns the distance between <i>this</i> point and another point.
    * @param {DSMath.Point2D} iP The Point2D.
    * @memberof DSMath.Point2D
    * @method distanceTo
    * @instance
    * @example
    * var p0 = new DSMath.Point2D(1,3);
    * var p1 = new DSMath.Point2D(1,1);
    * var dist = p0.distanceTo(p1); // sqDist=2
    * @returns { Number } The distance between <i>this</i> and the given point.
    */
    Point2D.prototype.distanceTo = function (iP)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point2D);

      var dx = this.x - iP.x;
      var dy = this.y - iP.y;
      return Math.sqrt(dx * dx + dy * dy);
    };

    /**
    * @public
    * @description Returns the square distance between <i>this</i> point and another point.
    * @param {DSMath.Point2D} iP The Point2D.
    * @memberof DSMath.Point2D
    * @method squareDistanceTo
    * @instance
    * @example
    * var p0 = new DSMath.Point2D(1,3);
    * var p1 = new DSMath.Point2D(1,1);
    * var sqDist = p0.squareDistanceTo(p1); // sqDist=4
    * @returns { Number } The square distance between <i>this</i> point and the given one.
    */
    Point2D.prototype.squareDistanceTo = function (iP)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point2D);

      var dx = this.x - iP.x;
      var dy = this.y - iP.y;
      return (dx * dx + dy * dy);
    };

    /**
    * @public
    * @description Returns the square distance between <i>this</i> point and the origin.
    * @param {DSMath.Point2D} iP The point.
    * @memberof DSMath.Point2D
    * @method squareDistanceToOrigin
    * @instance
    * @example
    * var p0 = new DSMath.Point2D(1,2);
    * var sqDistp0 = p0.squareDistanceToOrigin(); // sqDistp0=5
    * var sqDistp02 = p0.squareDistanceTo(DSMath.Point2D.origin); // sqDistp02==sqDistp0
    * @returns { Number } The square distance of <i>this</i> point to the origin.
    */
    Point2D.prototype.squareDistanceToOrigin = function ()
    {
      var d_out = this.x * this.x + this.y * this.y;
      return d_out;
    };

    /**
    * @public
    * @description Returns the min distance between <i>this</i> point and an array of points.
    * @param {DSMath.Point2D[]} iAPts The array of points.
    * @param {Number[]}                      [oId] The array to be fill by the indices realizing the min distance.
    * @memberof DSMath.Point2D
    * @method distanceToPoint2DArray
    * @instance
    * @example
    * var p0 = new DSMath.Point2D(2,2);
    * var p1 = new DSMath.Point2D(1,0);
    * var p2 = new DSMath.Point2D(0,1);
    * var tabOfPoint2Ds = [p0, p1, p2];
    * var pRef = new DSMath.Point2D(1,1);
    * var minId = [];
    * var dist = pRef.distanceToPoint2DArray(tabOfPoint2Ds, minId); // dist=1 and minId = [1,2].
    * @returns { Number } The min distance between <i>this</i> point and the array of points.
    */
    Point2D.prototype.distanceToPoint2DArray = function (aP, oId)
    {
      DSMath.TypeCheck(aP, true, [DSMath.Point2D], []);
      DSMath.TypeCheck(oId, false, ['number'], []);

      var minIds = new Array(1);
      var minIdsSize = 0;
      var i = 0;
      var oDist = 0.;
      var nbPt = aP.length;
      var dist = Infinity;

      for (i = 0; i < nbPt; i++)
      {
        oDist = (this.x - aP[i].x) * (this.x - aP[i].x)
               + (this.y - aP[i].y) * (this.y - aP[i].y);
        if (oDist < dist)
        {
          dist = oDist;
          minIds[0] = i;
          minIdsSize = 1;
        }
        else if (oDist == dist)
        {
          minIds[minIdsSize] = i;
          minIdsSize++;
        }
      }

      if (oId)
      {
        for (i = minIdsSize - 1; i > -1; i--)
          oId[i] = minIds[i];
      }

      oDist = Math.sqrt(dist);
      return oDist;
    };

    /** 
    * @public
    * @description Project <i>this</i> point on the given Line2D.
    * @param {DSMath.Line2D} iLine The Line2D support of the projection.
    * @memberof DSMath.Point2D
    * @method projectOnLine
    * @instance
    * @example
    * var l0 = new DSMath.Line2D().setDirection(1,1);
    * var p0 = new DSMath.Point2D(1,0);
    * var p1 = p0.projectOnLine(l0); // p1===p0 and p1=(0.5,0.5)
    * @returns { DSMath.Point2D } <i>this</i> modified point reference.
    */
    Point2D.prototype.projectOnLine = function (iLine)
    {
      DSMath.TypeCheck(iLine, true, DSMath.Line2D);

      var diff = this.sub(iLine.origin);
      diff.project(iLine.direction);
      this.copy(iLine.origin);
      this.addVector(diff);
      return this;
    };

    /**
    * @public
    * @description Compares <i>this</i> point with another one for equality.
    * @param {DSMath.Point2D} iP       The point to be compared with <i>this</i>.
    * @param {Number}         [iTol=0] The comparison accuracy. If not given, strict comparison is performed.
    * @memberof DSMath.Point2D
    * @method isEqual
    * @instance
    * @example
    * var p1 = new DSMath.Point2D(1.0011,0);
    * var p2 = new DSMath.Point2D(1.0001,0);
    * var pX = new DSMath.Point2D(1,0);
    * var boolP1PX = p1.isEqual(pX, 0.001); // boolP1PX = FALSE;
    * var boolP2PX = p2.isEqual(pX, 0.001); // boolP2PX = TRUE;
    * @returns {boolean} true if the points have equal coordinates at the given tolerance, false otherwise.
    */
    Point2D.prototype.isEqual = function (iP, iTol)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point2D);
      DSMath.TypeCheck(iTol, false, 'number');

      var areEqual = false;
      if ((arguments.length < 2))
      {
        areEqual = (this.x == iP.x) && (this.y == iP.y);
      }
      else
      {
        areEqual = !((Math.abs(this.x - iP.x) > iTol) || (Math.abs(this.y - iP.y) > iTol));
      }
      return areEqual;
    };

    /**
    * @public
    * @description Computes the linear interpolation between <i>this</i> point and another point.
    * @param {DSMath.Point2D} iP The point reference for the interpolation.
    * @param {Number} iR The ratio in [0, 1].
    * @memberof DSMath.Point2D
    * @method lerp
    * @instance
    * @example
    * var p1 = new DSMath.Point2D(1,0);
    * var p2 = new DSMath.Point2D(0,1);
    * var intP = p1.lerp(p2, 0.4);      // p1=intP=(0.6,0.4)
    * @returns {DSMath.Point2D} <i>this</i> modified point reference.
    */
    Point2D.prototype.lerp = function (iP, iR)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point2D);
      DSMath.TypeCheck(iR, true, 'number');

      this.x += iR * (iP.x - this.x);
      this.y += iR * (iP.y - this.y);

      return this;
    };

    /**
    * @public
    * @description Clamps <i>this</i> point coordinates between two points coordinates.
    * @param {DSMath.Point2D} iMin The point containing the min coordinates.
    * @param {DSMath.Point2D} iMax The point containing the max coordinates.
    * @memberof DSMath.Point2D
    * @method clamp
    * @instance
    * @example
    * var p1 = new DSMath.Point2D(3,1);
    * var minP = new DSMath.Point2D(1.4, 1.5);
    * var maxP = new DSMath.Point2D(2.4, 2.5);
    * var pClamp = p1.clamp(minP, maxP); // pClamp===p1 and pClamp=(2.4, 1.5);
    * @returns {DSMath.Point2D} <i>this</i> modified point reference.
    */
    Point2D.prototype.clamp = function (iMin, iMax)
    {
      DSMath.TypeCheck(iMin, true, DSMath.Point2D);
      DSMath.TypeCheck(iMax, true, DSMath.Point2D);

      this.x = this.x < iMin.x ? iMin.x : (this.x > iMax.x ? iMax.x : this.x);
      this.y = this.y < iMin.y ? iMin.y : (this.y > iMax.y ? iMax.y : this.y);
      return this;
    };

    /**
    * @public
    * @description Clamps the point coordinates between two Number values
    * @param {Number} iMin The min value.
    * @param {Number} iMax The max value.
    * @memberof DSMath.Point2D
    * @method clampScalar
    * @instance
    * @example
    * var p1 = new DSMath.Point2D(3,1);
    * var pClamp = p1.clampScalar(1.5, 2.5); // pClamp===p1 and pClamp=(2.5, 1.5);
    * @returns {DSMath.Point2D} <i>this</i> modified point reference.
    */
    Point2D.prototype.clampScalar = function (iMin, iMax)
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
    * @name origin
    * @type {Number}
    * @readonly
    * @memberOf DSMath.Point2D
    * @description The (0, 0) Point2D.
    */
    Object.defineProperty(Point2D, "origin", {
      value: new Point2D(0, 0),
      writable: false,
      enumerable: true,
      configurable: false
    });
    Object.freeze(Point2D.origin); // We need to freeze the object. Only the value was read only.

    /**
    * @public
    * @description Creates a new point equals to the addition of two points.
    * @param {DSMath.Point2D} iP1 The first point.
    * @param {DSMath.Point2D} iP2 The second point.
    * @param {DSMath.Point2D} [oP] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Point2D
    * @method add
    * @static
    * @example
    * var p0 = new DSMath.Point2D(1,2);
    * var p1 = new DSMath.Point2D(1,1);
    * var p2 = DSMath.Point2D.add(p0, p1); // p0=(1,2) and p1=(1,1) and p2=(2,3).
    * @returns { DSMath.Point2D } The reference of the operation result.
    */
    Point2D.add = function (iP1, iP2, oP)
    {
      DSMath.TypeCheck(iP1, true, DSMath.Point2D);
      DSMath.TypeCheck(iP2, true, DSMath.Point2D);
      DSMath.TypeCheck(oP, false, DSMath.Point2D);

      oP = (oP) ? oP : new Point2D();

      oP.x = iP1.x + iP2.x;
      oP.y = iP1.y + iP2.y;

      return oP;
    };

    /**
    * @public
    * @description Creates a new point equals to the addition of a a vector to a point.
    * @param {DSMath.Vector2D} iV   The vector.
    * @param {DSMath.Point2D}  [oP] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Point2D
    * @method addVector
    * @static
    * @example
    * var p0 = new DSMath.Point2D(1,2);
    * var v0 = new DSMath.Vector2D(1,1);
    * var p1 = DSMath.Point2D.addVector(p0, v0); // p0=(1,2) and p1=(2,3)
    * @returns { DSMath.Point2D } The reference of the operation result.
    */
    Point2D.addVector = function (iP, iV, oP)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point2D);
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);
      DSMath.TypeCheck(oP, false, DSMath.Point2D);

      oP = (oP) ? oP.copy(iP) : iP.clone();
      return oP.addVector(iV);
    };

    /**
    * @public
    * @description Creates a new point equals to the subtraction of a vector from point.
    * @param {DSMath.Point2D}  iP   The point to be translated.
    * @param {DSMath.Vector2D} iV   The vector.
    * @param {DSMath.Point2D}  [oP] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Point2D
    * @method subVector
    * @static
    * @example
    * var p0 = new DSMath.Point2D(1,2);
    * var v0 = new DSMath.Vector2D(1,1);
    * var p1 = DSMath.Point2D.subVector(p0, v0); // p0=(1,2) and p1=(0,1)
    * @returns { DSMath.Point2D } The reference of the operation result.
    */
    Point2D.subVector = function (iP, iV, oP)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point2D);
      DSMath.TypeCheck(iV, true, DSMath.Vector2D);
      DSMath.TypeCheck(oP, false, DSMath.Point2D);

      oP = (oP) ? oP.copy(iP) : iP.clone();
      return oP.subVector(iV);
    };

    /**
    * @public
    * @description Creates a new point equals to the multiplication of a point by a scalar.
    * @param {DSMath.Point2D} iP   The point.
    * @param {Number}                      iS   The scalar.
    * @param {DSMath.Point2D} [oP] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Point2D
    * @method multiplyScalar
    * @static
    * @example
    * var p0 = new DSMath.Point2D(1,2);
    * var s = 2;
    * var p1 = DSMath.Point2D.multiplyScalar(p0, s); // p0=(1,2) and s=2 and p1=(2,4);
    * @returns { DSMath.Point2D } The reference of the operation result.
    */
    Point2D.multiplyScalar = function (iP, iS, oP)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point2D);
      DSMath.TypeCheck(iS, true, 'number');
      DSMath.TypeCheck(oP, false, DSMath.Point2D);

      oP = (oP) ? oP.copy(iP) : iP.clone();
      return oP.multiplyScalar(iS);
    };

    /**
    * @public
    * @description Creates a new point equals to the division of a point by a scalar.
    * @param {DSMath.Point2D} iP The Point2D.
    * @param {Number} iS The scalar.
    * @memberof DSMath.Point2D
    * @method divideScalar
    * @static
    * @example
    * var p0 = new DSMath.Point2D(1,2);
    * var s = 2;
    * var p1 = DSMath.Point2D.divideScalar(p0, s); // p0=(1,2) and s=2 and p1=(0.5,1);
    * @returns { DSMath.Point2D } The reference of the operation result.
    */
    Point2D.divideScalar = function (iP, iS, oP)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point2D);
      DSMath.TypeCheck(iS, true, 'number');
      DSMath.TypeCheck(oP, false, DSMath.Point2D);

      oP = (oP) ? oP.copy(iP) : iP.clone();
      return oP.divideScalar(iS);
    };

    /**
    * @public
    * @description Creates a new point equals to the linear interpolation between two points.
    * @param {DSMath.Point2D} iP1  The first  point reference for the interpolation.
    * @param {DSMath.Point2D} iP2  The second point reference for the interpolation.
    * @param {Number}                      iR   The ratio in [0, 1].
    * @param {DSMath.Point2D} [oP] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Point2D
    * @method lerp
    * @static
    * @example
    * var p1 = new DSMath.Point2D(1,0);
    * var p2 = new DSMath.Point2D(0,1);
    * var intP = DSMath.Point2D.lerp(p1, p2, 0.4); // intV=(0.6,0.4)
    * @returns {DSMath.Point2D } The reference of the operation result.
    */
    Point2D.lerp = function (iP1, iP2, iR, oP)
    {
      DSMath.TypeCheck(iP1, true, DSMath.Point2D);
      DSMath.TypeCheck(iP2, true, DSMath.Point2D);
      DSMath.TypeCheck(iR, true, 'number');
      DSMath.TypeCheck(oP, false, DSMath.Point2D);

      oP = (oP) ? oP : new Point2D();

      oP.x = iP1.x + iR * (iP2.x - iP1.x);
      oP.y = iP1.y + iR * (iP2.y - iP1.y);

      return oP;
    };

    DSMath.Point2D = Point2D;

    return Point2D;
  }
);

