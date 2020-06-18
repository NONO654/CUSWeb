define('MathematicsES/MathPointJSImpl',
  ['MathematicsES/MathNameSpace',
   'MathematicsES/MathTypeCheck',
   'MathematicsES/MathTypeCheckInternal',
   'MathematicsES/MathVector2DJSImpl',
   'MathematicsES/MathVector3DJSImpl'
  ],
  
  function (DSMath, TypeCheck, TypeCheckInternal, Vector2D, Vector3D)
  {
    'use strict';

    /**
     * @public
     * @exports Point
     * @class
     * @classdesc Representation of a point in 3D.
     *
     * @constructor
     * @constructordesc Create a new Point with given (x, y, z) coordinates.
     * @param {Number} [x=0] The x coordinate of the point.
     * @param {Number} [y=0] The y coordinate of the point.
     * @param {Number} [z=0] The z coordinate of the point.
     * @memberof DSMath
     */
    var Point = function (x, y, z)
    {
      DSMath.TypeCheck(x, false, 'number');
      DSMath.TypeCheck(y, false, 'number');
      DSMath.TypeCheck(z, false, 'number');

      this.x = x || 0.;
      this.y = y || 0.;
      this.z = z || 0.;
    };

    /**
    * The x coordinate of a Point.
    * @public
    * @member
    * @instance
    * @name x
    * @type {Number}
    * @memberOf DSMath.Point
    */
    Point.prototype.x = null;

    /**
    * The y coordinate of a Point.
    * @public
    * @member
    * @instance
    * @name y
    * @type {Number}
    * @memberOf DSMath.Point
    */
    Point.prototype.y = null;

    /**
    * The z coordinate of a Point.
    * @public
    * @member
    * @instance
    * @name z
    * @type {Number}
    * @memberOf DSMath.Point
    */
    Point.prototype.z = null;

    Point.prototype.constructor = Point;

    /**
    * @public
    * @description Clones <i>this</i> point.
    * @memberof DSMath.Point
    * @method clone
    * @instance
    * @example
    * var p1 = new DSMath.Point(0.5, 0.1, 0.0); //p1=(0.5, 0.1, 0.)
    * var clonedP1 = p1.clone();                //clonedP1=(0.5, 0.1, 0.)
    * @returns {DSMath.Point} The clone of <i>this</i>.
    */
    Point.prototype.clone = function ()
    {
      var p_out = new DSMath.Point(this.x, this.y, this.z);
      return p_out;
    };

    /**
    * @public
    * @description Copies value of iP to <i>this</i> point.
    * @param {DSMath.Point} iP The point to copy.
    * @memberof DSMath.Point
    * @method copy
    * @instance
    * @example
    * var v0 = new DSMath.Point();             // v0 = (0. , 0. , 0.)
    * var v1 = new DSMath.Point(0.5, 0.1, 0.); // v1 = (0.5, 0.1, 0.)
    * v0.copy(v1);                             // v0 = (0.5, 0.1, 0.)
    * @returns {DSMath.Point} <i>this</i> modified point reference.
    */
    Point.prototype.copy = function (iPointToCopy)
    {
      DSMath.TypeCheck(iPointToCopy, true, DSMath.Point);

      this.x = iPointToCopy.x;
      this.y = iPointToCopy.y;
      this.z = iPointToCopy.z;
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Point
    * @method set
    * @instance
    * @description Assigns new coordinates values to <i>this</i> point.
    * @param {Number} iX Value for the x coordinate.
    * @param {Number} iY Value for the y coordinate.
    * @param {Number} iZ Value for the z coordinate.
    * @example
    * var p0 = new DSMath.Point(); // p0=(0,0,0)
    * p0.set(1.0, 2.0, 3.0);       // p0=(1,2,3)
    * @returns {DSMath.Point } <i>this</i> modified point reference.
    */
    Point.prototype.set = function (iX, iY, iZ)
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
    * @description Assigns new coordinates values to <i>this</i> point.
    * @param {Number[]} iA The array of size 3 containing the new point coordinates.
    * @memberof DSMath.Point
    * @method setFromArray
    * @instance
    * @example
    * var p0 = new DSMath.Point(); // p0=(0,0,0)
    * var coord = [1,2,3];
    * p0.setFromArray(coord);      // p0=(1,2,3)
    * @returns {DSMath.Point } <i>this</i> modified point reference.
    */
    Point.prototype.setFromArray = function (iA)
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
    * Assigns new coordinates values to <i>this</i> point.
    * <br>
    * The point coordinates will equals the vector one.
    * @param {DSMath.Vector3D} iV The vector.
    * @memberof DSMath.Point
    * @method setFromVector
    * @instance
    * @example
    * var p0 = new DSMath.Point();         // p0=(0,0,0)
    * var v0 = new DSMath.Vector3D(1,2,3); // v0=(1,2,3)
    * p0.setFromVector(v0);                // p0=(1,2,3)
    * @returns {DSMath.Point} <i>this</i> modified point reference.
    */
    Point.prototype.setFromVector = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);

      this.x = iV.x;
      this.y = iV.y;
      this.z = iV.z;
      return this;
    };

    /**
    * @public
    * @description Retrieves <i>this</i> point coordinates values into an array of size 3.
    * @param {Number[]} [oA] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Point
    * @method getArray
    * @instance
    * @example
    * var p0 = new DSMath.Point(1,2,3);
    * var coord = p0.getArray(); // coord=[1,2,3]
    * @returns {Number[]} The reference of the operation result - array of size 3 containing <i>this</i> point coordinates.
    */
    Point.prototype.getArray = function (oA)
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
    * @description Adds a point to <i>this</i> point.
    * @param {DSMath.Point} iP The point.
    * @memberof DSMath.Point
    * @method add
    * @instance
    * @example
    * var p0 = new DSMath.Point(1,2,3);
    * var p1 = new DSMath.Point(1,1,0);
    * var p2 = p0.add(p1); // p2===p0 and p2=(2,3,3) and p1=(1,1,0).
    * @returns { DSMath.Point } <i>this</i> modified point reference.
    */
    Point.prototype.add = function (iP)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point);

      this.x += iP.x;
      this.y += iP.y;
      this.z += iP.z;
      return this;
    };

    /**
    * @public
    * @description Adds a point multiplied by a value to <i>this</i> point.
    * @param {DSMath.Point} iP The point.
    * @param {Number} iS The scale.
    * @memberof DSMath.Point
    * @method addScaledPoint
    * @instance
    * @example
    * var p0 = new DSMath.Point(1,2,3);
    * var p1 = new DSMath.Point(1,1,0);
    * var p2 = p0.addScaledPoint(p1,0.5); // p2===p0 and p2=(1.5,2.5,3) and p1=(1,1,0).
    * @returns { DSMath.Point } <i>this</i> modified point reference.
    */
    Point.prototype.addScaledPoint = function (iP, iS)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point);
      DSMath.TypeCheck(iS, true, 'number');

      this.x += iS * iP.x;
      this.y += iS * iP.y;
      this.z += iS * iP.z;
      return this;
    };

    /**
    * @public
    * @description Adds a vector to <i>this</i> point.
    * @param {DSMath.Vector3D} iV The vector.
    * @memberof DSMath.Point
    * @method addVector
    * @instance
    * @example
    * var p0 = new DSMath.Point(1,2,3);
    * var v0 = new DSMath.Vector3D(1,1,0);
    * var p1 = p0.addVector(v0); // p0===p1 and p1=(2,3,3)
    * @returns {DSMath.Point } <i>this</i> modified point reference.
    */
    Point.prototype.addVector = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);

      this.x += iV.x;
      this.y += iV.y;
      this.z += iV.z;
      return this;
    };

    /**
    * @public
    * @description Adds a vector multiplied by a value to <i>this</i> point.
    * @param {DSMath.Vector3D} iV The vector to add.
    * @param {Number} iS The scale.
    * @memberof DSMath.Point
    * @method addScaledVector
    * @instance
    * @example
    * var p0 = new DSMath.Point(1,2,3);
    * var v0 = new DSMath.Vector3D(1,1,0);
    * var p1 = p0.addScaledVector(v0,2); // p0===p1 and p1=(3,4,3)
    * @returns {DSMath.Point } <i>this</i> modified point reference.
    */
    Point.prototype.addScaledVector = function (iV, iS)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);
      DSMath.TypeCheck(iS, true, 'number');

      this.x += iV.x * iS;
      this.y += iV.y * iS;
      this.z += iV.z * iS;
      return this;
    };

    /**
    * @public
    * @description Subtract a point from <i>this</i> point.
    * @param {DSMath.Point}    iP   The point.
    * @param {DSMath.Vector3D} [oV] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Point
    * @method sub
    * @instance
    * @example
    * var p0 = new DSMath.Point(1,2,3);
    * var p1 = new DSMath.Point(1,1,0);
    * var v0 = p0.sub(p1); // p0=(1,2,3) and p1=(1,1,0) and v0=(0,1,3).
    * @returns { DSMath.Vector3D } The reference of the operation result.
    */
    Point.prototype.sub = function (iP, oV)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point);
      DSMath.TypeCheck(oV, false, DSMath.Vector3D);

      oV = oV || new Vector3D();
      oV.x = this.x - iP.x;
      oV.y = this.y - iP.y;
      oV.z = this.z - iP.z;
      return oV;
    };

    /**
    * @public
    * @description Subtract a vector from <i>this</i> point.
    * @param {DSMath.Vector3D} iV The vector.
    * @memberof DSMath.Point
    * @method subVector
    * @instance
    * @example
    * var p0 = new DSMath.Point(1,2,3);
    * var v0 = new DSMath.Vector3D(1,1,0);
    * var p1 = p0.subVector(v0); // v1===v0 and v1=(0,1,3);
    * @returns {DSMath.Point } <i>this</i> modified point reference.
    */
    Point.prototype.subVector = function (iV)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);

      this.x -= iV.x;
      this.y -= iV.y;
      this.z -= iV.z;
      return this;
    };

    /**
    * @public
    * @description Subtract a vector multiplied by a value from <i>this</i> point.
    * @param {DSMath.Vector3D} iV The vector.
    * @param {Number}                       iS The scale.
    * @memberof DSMath.Point
    * @method subScaledVector
    * @instance
    * @example
    * var p0 = new DSMath.Point(1,2,3);
    * var v0 = new DSMath.Vector3D(1,1,0);
    * var p1 = p0.subScaledVector(v0,2); // p0===p1 and p1=(-1,0,3)
    * @returns {DSMath.Point } <i>this</i> modified point reference.
    */
    Point.prototype.subScaledVector = function (iV, iS)
    {
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);
      DSMath.TypeCheck(iS, true, 'number');

      this.x -= iV.x * iS;
      this.y -= iV.y * iS;
      this.z -= iV.z * iS;
      return this;
    };

    /**
    * @public
    * @description Multiplies <i>this</i> point by a scalar.
    * @param {Number} iS The scalar.
    * @memberof DSMath.Point
    * @method multiplyScalar
    * @instance
    * @example
    * var p0 = new DSMath.Point(1,2,3);
    * var s = 2;
    * var p1 = p0.multiplyScalar(s); // p0===p1 and p1=(2,4,6) and s=2
    * @returns { DSMath.Point } <i>this</i> modified point reference.
    */
    Point.prototype.multiplyScalar = function (iS)
    {
      DSMath.TypeCheck(iS, true, 'number');

      this.x *= iS;
      this.y *= iS;
      this.z *= iS;
      return this;
    };

    /**
    * @public
    * @description Divides <i>this</i> point by a scalar.
    * @param {Number} iS The scalar.
    * @memberof DSMath.Point
    * @method divideScalar
    * @instance
    * @example
    * var p0 = new DSMath.Point(1,2,3);
    * var s = 2;
    * var p1 = p0.divideScalar(s); // p0===p1 and p1=(0.5,1,1.5) and s=2
    * @returns { DSMath.Point } <i>this</i> modified point reference.
    */
    Point.prototype.divideScalar = function (iS)
    {
      DSMath.TypeCheck(iS, true, 'number');

      this.x /= iS;
      this.y /= iS;
      this.z /= iS;
      return this;
    };

    /**
    * @public
    * @description Returns the distance between <i>this</i> point and another point.
    * @param {DSMath.Point} iP The Point.
    * @memberof DSMath.Point
    * @method distanceTo
    * @instance
    * @example
    * var p0 = new DSMath.Point(1,2,3);
    * var p1 = new DSMath.Point(1,1,0);
    * var dist = p0.distanceTo(p1); // dist=&#8730;10
    * @returns { Number } The distance between <i>this</i> point and the given one.
    */
    Point.prototype.distanceTo = function (iP)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point);

      var dx = this.x - iP.x;
      var dy = this.y - iP.y;
      var dz = this.z - iP.z;
      return Math.sqrt(dx * dx + dy * dy + dz * dz);
    };

    /**
    * @public
    * @description Returns the square distance between <i>this</i> point and another point.
    * @param {DSMath.Point} iP The Point.
    * @memberof DSMath.Point
    * @method squareDistanceTo
    * @instance
    * @example
    * var p0 = new DSMath.Point(1,2,3);
    * var p1 = new DSMath.Point(1,1,0);
    * var sqDist = p0.squareDistanceTo(p1); // sqDist=10
    * @returns { Number } The square distance between <i>this</i> point and the given one.
    */
    Point.prototype.squareDistanceTo = function (iP)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point);

      var dx = this.x - iP.x;
      var dy = this.y - iP.y;
      var dz = this.z - iP.z;
      return (dx * dx + dy * dy + dz * dz);
    };

    /**
    * @public
    * @description Returns the square distance between <i>this</i> point and the origin.
    * @param {DSMath.Point} iP The point.
    * @memberof DSMath.Point
    * @method squareDistanceToOrigin
    * @instance
    * @example
    * var p0 = new DSMath.Point(1,2,3);
    * var sqDistp0 = p0.squareDistanceToOrigin(); // sqDistp0=14
    * var sqDistp02 = p0.squareDistanceTo(DSMath.Point.origin); // sqDistp02==sqDistp0
    * @returns { Number } The square distance of <i>this</i> point to the origin.
    */
    Point.prototype.squareDistanceToOrigin = function ()
    {
      var d_out = this.x * this.x + this.y * this.y + this.z * this.z;
      return d_out;
    };

    /**
    * @public
    * @memberof DSMath.Point
    * @method distanceToLine
    * @instance
    * @description
    * Returns the distance between <i>this</i> point and the given line.
    * @param {DSMath.Line} iL The line.
    * @example
    * var p0 = new DSMath.Point(-Math.SQRT2, Math.SQRT2, 0);
    * var l0 = new DSMath.Line().setDirection(Math.SQRT1_2, Math.SQRT1_2, 0);
    * var dist = p0.distanceToLine(l0); // dist=2;
    * @return {Number} The distance between <i>this</i> point and the line given.
    */
    Point.prototype.distanceToLine = function (iLine)
    {
      DSMath.TypeCheck(iLine, true, DSMath.Line);

      return iLine.distanceToPoint(this);
    };

    /**
    * @public
    * @memberof DSMath.Point
    * @method distanceToCircle
    * @instance
    * @description
    * Returns the distance between <i>this</i> point and the given circle.
    * @param {DSMath.Circle} iC The circle.
    * @example
    * var p0 = new DSMath.Point(1,2,3);
    * var c0 = new DSMath.Circle(2).setCenter(1,1,1);
    * var dist = p0.distanceToCircle(c0); // dist=1
    * @return {Number} The distance between <i>this</i> point and the circle given.
    */
    Point.prototype.distanceToCircle = function (iCircle)
    {
      DSMath.TypeCheck(iCircle, true, DSMath.Circle);

      var dir = iCircle.getDirectionsNotCloned();
      var op = this.sub(iCircle.center).projectOnPlaneFromVectors(dir[0], dir[1]);
      var opNorm = op.norm();
      return Math.abs(opNorm - iCircle.radius);
    };

    /**
    * @public
    * @memberof DSMath.Point
    * @method distanceToPlane
    * @instance
    * @description
    * Returns the distance between <i>this</i> point and the given plane.
    * @param {DSMath.Plane} iP The plane.
    * @example
    * var p0   = new DSMath.Point(1,2,3);
    * var pl0  = new DSMath.Plane().setOrigin(1,1,1);
    * var dist = p0.distanceToPlane(pl0); // dist=2;
    * @return {Number} The distance between <i>this</i> point and the plane given.
    */
    Point.prototype.distanceToPlane = function (iPlane)
    {
      DSMath.TypeCheck(iPlane, true, DSMath.Plane);

      var N = iPlane.getNormal();
      var op = this.sub(iPlane.origin);
      return Math.abs(N.dot(op));
    };

    /**
    * @public
    * @description Returns the min distance between <i>this</i> point and an array of points.
    * @param {DSMath.Point[]} iAPts The array of points.
    * @param {Number[]}                    [oId] The array to be fill by the indices realizing the min distance.
    * @memberof DSMath.Point
    * @method distanceToPointArray
    * @instance
    * @example
    * var p0 = new DSMath.Point(1,2,3);
    * var p1 = new DSMath.Point(1,1,0);
    * var p2 = new DSMath.Point(0,1,1);
    * var tabOfPoints = [p0, p1, p2];
    * var pRef = new DSMath.Point(1,1,1);
    * var minId = [];
    * var dist = pRef.distanceToPointArray(tabOfPoints, minId); // dist=1 and minId = [1,2].
    * @returns { Number } The min distance between <i>this</i> point and the array of points.
    */
    Point.prototype.distanceToPointArray = function (aP, oId)
    {
      DSMath.TypeCheck(aP, true, [DSMath.Point], []);
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
               + (this.y - aP[i].y) * (this.y - aP[i].y)
               + (this.z - aP[i].z) * (this.z - aP[i].z);
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
    * @description Project <i>this</i> point on the given Line.
    * @param {DSMath.Line} iLine The Line support of the projection.
    * @memberof DSMath.Point
    * @method projectOnLine
    * @instance
    * @example
    * var l0 = new DSMath.Line().setDirection(1,1,0);
    * var p0 = new DSMath.Point(1,0,0);
    * var p1 = p0.projectOnLine(l0); // p1===p0 and p1=(0.5,0.5,0)
    * @returns { DSMath.Point } <i>this</i> modified point reference.
    */
    Point.prototype.projectOnLine = function (iLine)
    {
      DSMath.TypeCheck(iLine, true, DSMath.Line);

      var diff = this.sub(iLine.origin);
      diff.project(iLine.direction);
      this.copy(iLine.origin);
      this.addVector(diff);
      return this;
    };

    /**
    * @public
    * @description Project <i>this</i> point on the given circle.
    * @param {DSMath.Circle} iCircle The circle support of the projection.
    * @memberof DSMath.Point
    * @method projectOnCircle
    * @instance
    * @example
    * var c0 = new DSMath.Circle(2).setCenter(1,1,1).setVectors(1,1,0, -1,1,0);
    * var p0 = new DSMath.Point(3,3,10);
    * var p1 = p0.projectOnCircle(c0); // p1===p0 and p1=(1+&#8730;2,1+&#8730;2,1)
    * @returns { DSMath.Point } <i>this</i> modified point reference.
    */
    Point.prototype.projectOnCircle = function (iCircle)
    {
      DSMath.TypeCheck(iCircle, true, DSMath.Circle);

      var dir = iCircle.getDirectionsNotCloned();
      var op = this.sub(iCircle.center).projectOnPlaneFromVectors(dir[0], dir[1]);
      var opNorm = op.norm();
      if (opNorm > DSMath.defaultTolerances.epsgForRelativeTest)
      {
        this.setFromVector(op).multiplyScalar(iCircle.radius / opNorm).add(iCircle.center);
      }
      return this;
    };

    /**
    * @public
    * @description Project <i>this</i> point on the given plane.
    * @param {DSMath.Plane} iPlane The plane support of the projection.
    * @memberof DSMath.Point
    * @method projectOnPlane
    * @instance
    * @example
    * var pl0 = new DSMath.Plane().setOrigin(1,0,0).setVectors(1,1,0, 1,0,1);
    * var p0 = new DSMath.Point(0,0,0);
    * var p1 = p0.projectOnPlane(pl0); //p1===p0 and p1=(1/3,-1/3,-1/3)
    * @returns { DSMath.Point } <i>this</i> modified point reference.
    */
    Point.prototype.projectOnPlane = function (iPlane)
    {
      DSMath.TypeCheck(iPlane, true, DSMath.Plane);

      var dir = iPlane.getDirectionsNotCloned();
      var op = this.sub(iPlane.origin);
      var u = op.dot(dir[0]);
      var v = op.dot(dir[1]);
      this.copy(iPlane.origin).addScaledVector(dir[0], u).addScaledVector(dir[1], v);
      return this;
    };

    /**
    * @public
    * @description Compares <i>this</i> point with another one for equality.
    * @param {DSMath.Point} iP       The point to be compared with <i>this</i>.
    * @param {Number}                    [iTol=0] The comparison accuracy. If not given, strict comparison is performed.
    * @memberof DSMath.Point
    * @method isEqual
    * @instance
    * @example
    * var p1 = new DSMath.Point(1.0011,0,0);
    * var p2 = new DSMath.Point(1.0001,0,0);
    * var pX = new DSMath.Point(1,0,0);
    * var boolP1PX = p1.isEqual(pX, 0.001); // boolP1PX = FALSE;
    * var boolP2PX = p2.isEqual(pX, 0.001); // boolP2PX = TRUE;
    * @returns {boolean} true if the points have equal coordinates at the given tolerance, false otherwise.
    */
    Point.prototype.isEqual = function (iP, iTol)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point);
      DSMath.TypeCheck(iTol, false, 'number');

      var areEqual = false;
      if ((arguments.length < 2))
      {
        areEqual = (this.x == iP.x) && (this.y == iP.y) && (this.z == iP.z);
      }
      else
      {
        areEqual = !((Math.abs(this.x - iP.x) > iTol) || (Math.abs(this.y - iP.y) > iTol) || (Math.abs(this.z - iP.z) > iTol));
      }
      return areEqual;
    };

    /**
    * @public
    * @description Computes the linear interpolation between <i>this</i> and another point
    * @param {DSMath.Point} iP The point reference for the interpolation.
    * @param {Number}                    iR The ratio in [0, 1].
    * @memberof DSMath.Point
    * @method lerp
    * @instance
    * @example
    * var p1 = new DSMath.Point(1,0,0);
    * var p2 = new DSMath.Point(0,1,0);
    * var intP = p1.lerp(p2, 0.4);       // p1=intP=(0.6,0.4,0)
    * @returns {DSMath.Point } <i>this</i> modified point reference.
    */
    Point.prototype.lerp = function (iP, iR)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point);
      DSMath.TypeCheck(iR, true, 'number');

      this.x += iR * (iP.x - this.x);
      this.y += iR * (iP.y - this.y);
      this.z += iR * (iP.z - this.z);

      return this;
    };

    /**
    * @public
    * @description Clamps <i>this</i> point coordinates between two point coordinates.
    * @param {DSMath.Point} iMin The point containing the min coordinates.
    * @param {DSMath.Point} iMax The point containing the max coordinates.
    * @memberof DSMath.Point
    * @method clamp
    * @instance
    * @example
    * var p1 = new DSMath.Point(2,1,3);
    * var minP = new DSMath.Point(1.4, 1.5, 1.6);
    * var maxP = new DSMath.Point(2.4, 2.5, 2.6);
    * var pClamp = p1.clamp(minP, maxP); // pClamp===p1 and pClamp=(2, 1.5, 2.6);
    * @returns {DSMath.Point} <i>this</i> modified point reference.
    */
    Point.prototype.clamp = function (iMin, iMax)
    {
      DSMath.TypeCheck(iMin, true, DSMath.Point);
      DSMath.TypeCheck(iMax, true, DSMath.Point);

      this.x = this.x < iMin.x ? iMin.x : (this.x > iMax.x ? iMax.x : this.x);
      this.y = this.y < iMin.y ? iMin.y : (this.y > iMax.y ? iMax.y : this.y);
      this.z = this.z < iMin.z ? iMin.z : (this.z > iMax.z ? iMax.z : this.z);
      return this;
    };

    /**
    * @public
    * @description Clamps <i>this</i> point coordinates between two Number values
    * @param {Number} iMin The min value.
    * @param {Number} iMax The max value.
    * @memberof DSMath.Point
    * @method clampScalar
    * @instance
    * @example
    * var p1 = new DSMath.Point(2,1,3);
    * var pClamp = p1.clampScalar(1.5, 2.5); // pClamp===p1 and pClamp=(2, 1.5, 2.5);
    * @returns {DSMath.Point} <i>this</i> modified point reference.
    */
    Point.prototype.clampScalar = function (iMin, iMax)
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
    * @description Transforms <i>this</i> point by multiplying it by a Matrix3x3.
    * @param {DSMath.Matrix3x3} iM The Matrix3x3.
    * @memberof DSMath.Point
    * @method applyMatrix3x3
    * @instance
    * @example
    * var p1 = new DSMath.Point(1,0,0);
    * var m = DSMath.Matrix3x3.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
    * var pRot = p1.applyMatrix3x3(m); // pRot===p1 and pRot=(0,1,0).
    * @returns {DSMath.Point } <i>this</i> modified vector reference.
    */
    Point.prototype.applyMatrix3x3 = function (iM)
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
    * @description Transforms <i>this</i> point by multiplying it with a Transformation.
    * @param {DSMath.Transformation} iT The Transformation.
    * @memberof DSMath.Point
    * @method applyTransformation
    * @instance
    * @example
    * var p1 = new DSMath.Point(1,0,0);
    * var t = new DSMath.Transformation();
    * t.setRotation(DSMath.Vector3D.zVect, Math.PI/2);
    * t.vector.set(1,2,3);
    * var pT = p1.applyTransformation(t); // pT===p1 and p1=(1,3,3).
    * @returns {DSMath.Point } <i>this</i> modified point reference.
    */
    Point.prototype.applyTransformation = function (iT)
    {
      DSMath.TypeCheck(iT, true, DSMath.Transformation);

      var c = iT.matrix.coef;
      var t = iT.vector;
      var x = this.x;
      var y = this.y;
      var z = this.z;

      this.x = c[0] * x + c[1] * y + c[2] * z + t.x;
      this.y = c[3] * x + c[4] * y + c[5] * z + t.y;
      this.z = c[6] * x + c[7] * y + c[8] * z + t.z;

      return this;
    };

    /**
    * @public
    * @description Transforms <i>this</i> point by multiplying it with a Quaternion.
    * <br>
    * If the quaternion is not a unit quaternion, the computation will used its normalized form.
    * @param {DSMath.Quaternion} iQ The unit quaternion.
    * @memberof DSMath.Point
    * @method applyQuaternion
    * @instance
    * @example
    * var p1 = new DSMath.Point(1,0,0);
    * var q = DSMath.Quaternion.makeRotation(DSMath.Vector3D.zVect, Math.PI/2);
    * var pT = p1.applyQuaternion(q); // pT===p1 and p1=(0,1,0).
    * @returns {DSMath.Point } <i>this</i> modified vector reference.
    */
    Point.prototype.applyQuaternion = function (iQ)
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
    * @name origin
    * @type {Number}
    * @readonly
    * @memberOf DSMath.Point
    * @description The (0, 0, 0) point.
    */
    Object.defineProperty(Point, "origin", {
      value: new Point(0, 0, 0),
      writable: false,
      enumerable: true,
      configurable: false
    });
    Object.freeze(Point.origin); // We need to freeze the object. Only the value was read only.

    /**
    * @public
    * @description Creates a new point equals to the addition of two points.
    * @param {DSMath.Point} iP1 The first point.
    * @param {DSMath.Point} iP2 The second point.
    * @param {DSMath.Point} [oP] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Point
    * @method add
    * @static
    * @example
    * var p0 = new DSMath.Point(1,2,3);
    * var p1 = new DSMath.Point(1,1,0);
    * var p2 = DSMath.Point.add(p0, p1); // p0=(1,2,3) and p1=(1,1,0) and p2=(2,3,3).
    * @returns { DSMath.Point } The reference of the operation result.
    */
    Point.add = function (iP1, iP2, oP)
    {
      DSMath.TypeCheck(iP1, true, DSMath.Point);
      DSMath.TypeCheck(iP2, true, DSMath.Point);
      DSMath.TypeCheck(oP, false, DSMath.Point);

      oP = (oP) ? oP : new Point();

      oP.x = iP1.x + iP2.x;
      oP.y = iP1.y + iP2.y;
      oP.z = iP1.z + iP2.z;

      return oP;
    };

    /**
    * @public
    * @description Creates a new point equals to the addition of a a vector to a point.
    * @param {DSMath.Point}    iP   The point to be translated.
    * @param {DSMath.Vector3D} iV   The vector.
    * @param {DSMath.Point}    [oP] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Point
    * @method addVector
    * @static
    * @example
    * var p0 = new DSMath.Point(1,2,3);
    * var v0 = new DSMath.Vector3D(1,1,0);
    * var p1 = DSMath.Point.addVector(p0, v0); // p0=(1,2,3) and p1=(2,3,3)
    * @returns { DSMath.Point } The reference of the operation result.
    */
    Point.addVector = function (iP, iV, oP)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point);
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);
      DSMath.TypeCheck(oP, false, DSMath.Point);

      oP = (oP) ? oP.copy(iP) : iP.clone();
      return oP.addVector(iV);
    };

    /**
    * @public
    * @description Creates a new point equals to the subtraction of a vector from point.
    * @param {DSMath.Point}    iP   The point to be translated.
    * @param {DSMath.Vector3D} iV   The vector.
    * @param {DSMath.Point}    [oP] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Point
    * @method subVector
    * @static
    * @example
    * var p0 = new DSMath.Point(1,2,3);
    * var v0 = new DSMath.Vector3D(1,1,0);
    * var p1 = DSMath.Point.subVector(p0, v0); // p0=(1,2,3) and p1=(0,1,3)
    * @returns { DSMath.Point } The reference of the operation result.
    */
    Point.subVector = function (iP, iV, oP)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point);
      DSMath.TypeCheck(iV, true, DSMath.Vector3D);
      DSMath.TypeCheck(oP, false, DSMath.Point);

      oP = (oP) ? oP.copy(iP) : iP.clone();
      return oP.subVector(iV);
    };

    /**
    * @public
    * @description Creates a new point equals to the multiplication of a point by a scalar.
    * @param {DSMath.Point} iP   The point.
    * @param {Number}                    iS   The scalar.
    * @param {DSMath.Point} [oP] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Point
    * @method multiplyScalar
    * @static
    * @example
    * var p0 = new DSMath.Point(1,2,3);
    * var s = 2;
    * var p1 = DSMath.Point.multiplyScalar(p0, s); // p0=(1,2,3) and s=2 and p1=(2,4,6);
    * @returns { DSMath.Point } The reference of the operation result.
    */
    Point.multiplyScalar = function (iP, iS, oP)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point);
      DSMath.TypeCheck(iS, true, 'number');
      DSMath.TypeCheck(oP, false, DSMath.Point);

      oP = (oP) ? oP.copy(iP) : iP.clone();
      return oP.multiplyScalar(iS);
    };

    /**
    * @public
    * @description Creates a new point equals to the division of a point by a scalar.
    * @param {DSMath.Point} iP The point.
    * @param {Number}                    iS The scalar.
    * @memberof DSMath.Point
    * @method divideScalar
    * @static
    * @example
    * var p0 = new DSMath.Point(1,2,3);
    * var s = 2;
    * var p1 = DSMath.Point.divideScalar(p0, s); // p0=(1,2,3) and s=2 and p1=(0.5,1,1.5);
    * @returns { DSMath.Point } The reference of the operation result.
    */
    Point.divideScalar = function (iP, iS, oP)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point);
      DSMath.TypeCheck(iS, true, 'number');
      DSMath.TypeCheck(oP, false, DSMath.Point);

      oP = (oP) ? oP.copy(iP) : iP.clone();
      return oP.divideScalar(iS);
    };

    /**
    * @public
    * @description Creates a new point equals to the linear interpolation between two points.
    * @param {DSMath.Point} iP1  The first  point reference for the interpolation.
    * @param {DSMath.Point} iP2  The second point reference for the interpolation.
    * @param {Number}                    iR   The ratio in [0, 1].
    * @param {DSMath.Point} [oP] Reference of the operation result (avoid allocation).
    * @memberof DSMath.Point
    * @method lerp
    * @static
    * @example
    * var p1 = new DSMath.Point(1,0,0);
    * var p2 = new DSMath.Point(0,1,0);
    * var intP = DSMath.Point.lerp(p1, p2, 0.4); // intV=(0.6,0.4,0)
    * @returns {DSMath.Point } The reference of the operation result.
    */
    Point.lerp = function (iP1, iP2, iR, oP)
    {
      DSMath.TypeCheck(iP1, true, DSMath.Point);
      DSMath.TypeCheck(iP2, true, DSMath.Point);
      DSMath.TypeCheck(iR, true, 'number');
      DSMath.TypeCheck(oP, false, DSMath.Point);

      oP = (oP) ? oP : new Point();

      oP.x = iP1.x + iR * (iP2.x - iP1.x);
      oP.y = iP1.y + iR * (iP2.y - iP1.y);
      oP.z = iP1.z + iR * (iP2.z - iP1.z);

      return oP;
    };

    DSMath.Point = Point;

    return Point;
  }
);

