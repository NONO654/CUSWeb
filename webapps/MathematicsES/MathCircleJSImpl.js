define('MathematicsES/MathCircleJSImpl',
  ['MathematicsES/MathNameSpace',
   'MathematicsES/MathTypeCheck',
   'MathematicsES/MathTypeCheckInternal',
   'MathematicsES/MathPointJSImpl',
   'MathematicsES/MathVector2DJSImpl',
   'MathematicsES/MathVector3DJSImpl',
   'MathematicsES/MathLineJSImpl',
   'MathematicsES/MathPlaneJSImpl'
  ], 
  
  function (DSMath, TypeCheck, TypeCheckInternal, Point, Vector2D, Vector3D, Line, Plane)
  {
    'use strict';

    /**
    * @public
    * @exports Circle
    * @class
    * @classdesc Representation of a Circle in 3D.
    *
    * @constructor
    * @constructordesc
    * The DSMath.Circle constructor creates a circle in 3D, which is represented by a center, a plane defining the circle support, a radius, a shift and a scale.
    * <br>
    * The circle has a parametrization distortion equals to radius*scale. Eval(t) = center + radius*(cos(t*scale + shift)*firstAxis + sin(t*scale + shift)*secondAxis).
    * <br>
    * The two orthonormalized vectors can only be managed with <i>this</i> class methods.
    * @param {Number}                       [iR=1]        The radius of the circle. The radius has to be strictly positive.
    * @param {Number}                       [iS=1]        The scale of the circle. The scale has to be different of zero.
    * @param {DSMath.Point}    [iC=(0,0,0)]  The circle center. Note the content of the point given is duplicated so <i>this</i>.center!==iC.
    * @param {DSMath.Vector3D} [iD1=(1,0,0)] The circle plane support first direction. Note the content of the vector given is duplicated.
    * @param {DSMath.Vector3D} [iD2=(0,1,0)] The circle plane support second direction. Note the content of the vector given is duplication.
    * @param {Number}                       [iShift=0]    The parameter shift.
    * @memberof DSMath
    */
    var Circle = function (iR, iS, iC, iD1, iD2, iShift)
    {
      DSMath.TypeCheck(iR, false, 'number');
      DSMath.TypeCheck(iS, false, 'number');
      DSMath.TypeCheck(iC, false, DSMath.Point);
      DSMath.TypeCheck(iD1, false, DSMath.Vector3D);
      DSMath.TypeCheck(iD2, false, DSMath.Vector3D);
      DSMath.TypeCheck(iShift, false, 'number');

      // Attributes
      // -------------------------------------
      // Public
      this.center = iC ? iC.clone() : new Point();
      this.radius = iR || 1.; // Radius can not be null. If so, put if to 1.
      this.shift = iShift || 0.;
      this.scale = iS || 1.; // The scale can not be null. If so, put it to 1.

      // Private
      var dir = new Array(2);
      dir[0] = (iD1) ? iD1.clone() : new Vector3D(1, 0, 0);
      dir[1] = (iD2) ? iD2.clone() : new Vector3D(0, 1, 0);

      if (iD1 || iD2)
        Vector3D.orthoNormalize(dir[0], dir[1]);

      /** @nodoc */
      // Method only intended for perfo. Use very carefully.
      // The vectors values should only be read, the caller takes its responsibility of the consistency of the changes otherwise.
      this.getDirectionsNotCloned = function ()
      {
        return dir;
      };
    };

    // ---------------------------------------------------------------------------------
    // Data members
    // ---------------------------------------------------------------------------------
    /**
    * The center property of a circle.
    * @member
    * @instance
    * @name center
    * @public
    * @type { DSMath.Point }
    * @memberOf DSMath.Line
    */
    Circle.prototype.center = null;

    /**
    * The radius property of a circle.
    * @member
    * @instance
    * @name radius
    * @public
    * @type { Number }
    * @memberOf DSMath.Circle
    */
    Circle.prototype.radius = null;

    /**
    * The shift property of a circle.
    * @member
    * @instance
    * @name shift
    * @public
    * @type { Number }
    * @memberOf DSMath.Circle
    */
    Circle.prototype.shift = null;

    /**
    * The scale property of a circle.
    * @member
    * @instance
    * @name scale
    * @public
    * @type { Number }
    * @memberOf DSMath.Circle
    */
    Circle.prototype.scale = null;

    // ---------------------------------------------------------------------------------
    // Private methods
    // ---------------------------------------------------------------------------------

    /** @ignore */
    // Utility method (for internal use) - put the parameter in the principal range
    Circle.prototype.putInRange = function (iParam, iRange)
    {
      DSMath.TypeCheckInternal(iParam, true, 'number');
      DSMath.TypeCheckInternal(iRange, true, ['number'], 2);

      var oParam = iParam;

      if (oParam < iRange[0] || oParam > iRange[1])
      {
        var nPi2 = Math.floor((oParam - iRange[0]) / DSMath.constants.PI2);
        var newParam = iParam - (nPi2 * DSMath.constants.PI2);
        if (newParam >= iRange[0] && newParam <= iRange[1])
          oParam = newParam;
      }

      return oParam;
    };
    
    /** @ignore */
    Circle.prototype.IsInfinite = function ()
    {
      return true;
    }

    // ---------------------------------------------------------------------------------
    // Public methods
    // ---------------------------------------------------------------------------------

    /**
    * @public
    * @memberof DSMath.Circle
    * @method clone
    * @instance
    * @description
    * Clones <i>this</i> Circle.
    * @example
    * var c0 = new DSMath.Circle(2).setCenter(1,1,1).setVectors(1,1,0, -1,1,0);
    * var c1 = c0.clone(); // c1==c0 but c1!==c0
    * @returns {DSMath.Circle} The cloned circle.
    */
    Circle.prototype.clone = function ()
    {
      var oC = new Circle();
      return oC.copy(this);
    };

    /**
    * @public
    * @memberof DSMath.Circle
    * @method copy
    * @instance
    * @description
    * Copies <i>this</i> Circle.
    * @example
    * var c0 = new DSMath.Circle(2).setCenter(1,1,1).setVectors(1,1,0, -1,1,0);
    * var c1 = new DSMath.Circle();
    * c1.copy(c0); // c1==c0 but c1!==c0
    * @returns {DSMath.Circle} <i>this</i> modified circle reference.
    */
    Circle.prototype.copy = function (iToCopy)
    {
      DSMath.TypeCheck(iToCopy, true, DSMath.Circle);

      this.center.copy(iToCopy.center);
      this.radius = iToCopy.radius;
      this.shift = iToCopy.shift;
      this.scale = iToCopy.scale;

      var dir = this.getDirectionsNotCloned();
      var dirToCopy = iToCopy.getDirectionsNotCloned();
      dir[0].copy(dirToCopy[0]);
      dir[1].copy(dirToCopy[1]);

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Circle
    * @method setCenter
    * @instance
    * @description
    * Assigns new coordinates values to <i>this</i> circle center.
    * @param {Number | DSMath.Point}  iX     Value for the x coordinate of the center or the point to copy.
    * @param {Number}                              [iY=0] Value for the y coordinate of the center. Not used if iX is a Point.
    * @param {Number}                              [iZ=0] Value for the z coordinate of the center. Not used if iX is a Point.
    * @example
    * var c0 = new DSMath.Circle().setCenter(1,2,3); // c0.center=[1,2,3]
    * var p0 = new DSMath.Point(1,1,1);
    * c0.setCenter(p0);                               // c0.center=[1,1,1] (copy of p0).
    * p0.set(0,0,0);                                  // c0.center=[1,1,1]
    * @returns {DSMath.Circle} <i>this</i> modified circle reference.
    */
    Circle.prototype.setCenter = function (iX, iY, iZ)
    {
      DSMath.TypeCheck(iX, true, ['number', DSMath.Point]);
      DSMath.TypeCheck(iY, false, 'number');
      DSMath.TypeCheck(iZ, false, 'number');

      if (iX.constructor === Point)
        this.center.copy(iX);
      else
        this.center.set(iX, iY || 0, iZ || 0);
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Circle
    * @method setVectors
    * @instance
    * @description
    * Assigns new vectors to <i>this</i> plane support.
    * <br>
    * If the given vectors are not orthonormalized, the method does it if possible.
    * <br>
    * The vector must not be colinear. Otherwise the vectors are not changed.
    * @param {DSMath.Vector3D} iV1 New value of the first vector of the plane support. Note the content of the vector given is duplicated.
    * @param {DSMath.Vector3D} iV2 New value of the second vector of the plane support. Note the content of the vector given is duplicated.
    * @example
    * var c0 = new DSMath.Circle(2).setCenter(1,2,3).setVectors(1,1,0, -1,0,0);
    * var dir = c0.getDirections(); // dir[0] = (1/&#8730;2,1/&#8730;2,0) and dir[1]=(-1/&#8730;2,1/&#8730;2,0)
    * @returns {DSMath.Circle} <i>this</i> modified circle reference.
    */
    Circle.prototype.setVectors = function (iV1, iV2)
    {
      DSMath.TypeCheck(iV1, true,  [DSMath.Vector3D, 'number']);
      DSMath.TypeCheck(iV2, false, [DSMath.Vector3D, 'number']);
      DSMath.TypeCheck(arguments[2], false, 'number');
      DSMath.TypeCheck(arguments[3], false, 'number');
      DSMath.TypeCheck(arguments[4], false, 'number');
      DSMath.TypeCheck(arguments[5], false, 'number');

      Plane.prototype.setVectors.apply(this, arguments);
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Circle
    * @method setRadius
    * @instance
    * @description
    * Assigns new radius value.
    * @param {Number} iR The new radius value. The radius given has to be strictly positive.
    * @example
    * var c0 = new DSMath.Circle().setCenter(1,2,3).setVectors(1,1,0, -1,0,0).setRadius(2); // c0.radius=2
    * var c1 = c0.setRadius(3); // c1===c0 and c1.radius=3;
    * @returns {DSMath.Circle} <i>this</i> modified circle reference.
    */
    Circle.prototype.setRadius = function (iR)
    {
      DSMath.TypeCheck(iR, false, 'number');

      this.radius = iR || 1;
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Circle
    * @method setScale
    * @instance
    * @description
    * Assigns new scale value.
    * @param {Number} [iS=1] The new scale value. The scale has to be different of zero.
    * @example
    * var c0 = new DSMath.Circle().setCenter(1,2,3).setVectors(1,1,0, -1,0,0).setScale(2); // c0.scale=2
    * var c1 = c0.setScale(3); // c1===c0 and c1.scale=3;
    * @returns {DSMath.Circle} <i>this</i> modified circle reference.
    */
    Circle.prototype.setScale = function (iS)
    {
      DSMath.TypeCheck(iS, false, 'number');

      this.scale = iS || 1;
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Circle
    * @method setShift
    * @instance
    * @description
    * Assigns new shift value.
    * @param {Number} [iS=1] The new shift value.
    * @example
    * var c0 = new DSMath.Circle().setCenter(1,2,3).setVectors(1,1,0, -1,0,0).setShift(2); // c0.shift=2
    * var c1 = c0.setShift(3); // c1===c0 and c1.shift=3;
    * @returns {DSMath.Circle} <i>this</i> modified circle reference.
    */
    Circle.prototype.setShift = function (iShift)
    {
      DSMath.TypeCheck(iShift, false, 'number');

      this.shift = iShift || 0;
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Circle
    * @method getDirections
    * @instance
    * @description
    * Retrieves a copy of the circle plane support directions.
    * @param {DSMath.Vector3D[]} [oA] Reference of the operation result (avoid allocation).
    * @example
    * var c0 = new DSMath.Circle(2).setCenter(1,2,3).setVectors(1,1,0, -1,1,0);
    * var dir = c0.getDirections(); // dir[0]=(1/&#8730;2,1/&#8730;2,0), dir[1]=(-1/&#8730;2,1/&#8730;2,0)
    * @returns {DSMath.Vector3D[]} Reference of the operation result - The array of orthonormalized direction ([first direction, second direction]).
    */
    Circle.prototype.getDirections = function (ioArray)
    {
      DSMath.TypeCheck(ioArray, false, [DSMath.Vector3D], 2);

      return Plane.prototype.getDirections.apply(this, arguments);
    };

    /**
    * @public
    * @memberof DSMath.Circle
    * @method evalPoint
    * @instance
    * @description
    * Returns the point of <i>this</i> circle corresponding to the given parameters.
    * @param {Number} iT   The circle parameter. The evaluation made is : center + radius*(cos(iT*scale + shift)*firstAxis + sin(iT*scale + shift)*secondAxis).
    * @example
    * var c0 = new DSMath.Circle().setRadius(2).setVectors(1,1,0, -1,1,0).setCenter(1,2,3);
    * var p0 = c0.evalPoint(0);         // p0 = (1+2/&#8730;2, 2+2/&#8730;2, 3);
    * var p1 = c0.evalPoint(Math.PI/2); // p1 = (1-2/&#8730;2, 2+2/&#8730;2, 3);
    * var p2 = c0.evalPoint(Math.PI);   // p2 = (1-2/&#8730;2, 2-2/&#8730;2, 3);
    * @returns { DSMath.Point } The reference of the operation result - The point evaluated.
    */
    Circle.prototype.evalPoint = function (iT)
    {
      DSMath.TypeCheck(iT, true, 'number');

      var t = iT * this.scale + this.shift;

      var cost = Math.cos(t);
      var sint = Math.sin(t);
      var dir = this.getDirectionsNotCloned();

      var pointEval = new DSMath.Point();
      pointEval.x = this.center.x + this.radius * (cost * dir[0].x + sint * dir[1].x);
      pointEval.y = this.center.y + this.radius * (cost * dir[0].y + sint * dir[1].y);
      pointEval.z = this.center.z + this.radius * (cost * dir[0].z + sint * dir[1].z);

      return pointEval;
    };

    /**
    * @public
    * @memberof DSMath.Circle
    * @method evalFirstDeriv
    * @instance
    * @description
    * Returns the gradient of <i>this</i> circle corresponding to the given parameters.
    * @param {Number} iT   The circle parameter. The evaluation made is : center + radius*(cos(iT*scale + shift)*firstAxis + sin(iT*scale + shift)*secondAxis).
    * @example
    * var c0 = new DSMath.Circle().setRadius(Math.SQRT2).setVectors(1,1,0, -1,1,0).setCenter(1,2,3);
    * var v0 = c0.evalFirstDeriv(0);         // v0 = (-1,  1, 0);
    * var v1 = c0.evalFirstDeriv(Math.PI/2); // v1 = (-1, -1, 0);
    * var v2 = c0.evalFirstDeriv(Math.PI);   // v2 = ( 1, -1, 0);
    * @returns { DSMath.Vector3D } The reference of the operation result - The gradient evaluated.
    */
    Circle.prototype.evalFirstDeriv = function (iT)
    {
      DSMath.TypeCheck(iT, true, 'number');

      var t = iT * this.scale + this.shift;

      var cost = Math.cos(t);
      var sint = Math.sin(t);
      var dir = this.getDirectionsNotCloned();

      var gradEval = new DSMath.Vector3D();
      gradEval.x = this.radius * (-sint * dir[0].x + cost * dir[1].x);
      gradEval.y = this.radius * (-sint * dir[0].y + cost * dir[1].y);
      gradEval.z = this.radius * (-sint * dir[0].z + cost * dir[1].z);

      return gradEval;
    };

    /**
    * @private
    * @memberof DSMath.Circle
    * @method evalSecondDeriv
    * @instance
    * @description
    * Returns the second derivative of <i>this</i> circle corresponding to the given parameters.
    * @param {Number} iT the circle parameter.
    * @example
    * var c0 = new DSMath.Circle().setRadius(Math.SQRT2).setVectors(1,1,0, -1,1,0).setCenter(1,2,3);
    * var v0 = c0.evalSecondDeriv(0);         // v0 = (-1, -1, 0);
    * var v1 = c0.evalSecondDeriv(Math.PI/2); // v1 = ( 1, -1, 0);
    * var v2 = c0.evalSecondDeriv(Math.PI);   // v2 = ( 1,  1, 0);
    * @returns { DSMath.Vector3D } The reference of the operation result - the second derivative evaluated.
    */
    Circle.prototype.evalSecondDeriv = function (iT)
    {
      DSMath.TypeCheck(iT, true, 'number');

      var t = iT * this.scale + this.shift;

      var cost = Math.cos(t);
      var sint = Math.sin(t);
      var dir = this.getDirectionsNotCloned();

      var oSecondDeriv = new DSMath.Vector3D();
      oSecondDeriv.x = this.radius * (-cost * dir[0].x - sint * dir[1].x);
      oSecondDeriv.y = this.radius * (-cost * dir[0].y - sint * dir[1].y);
      oSecondDeriv.z = this.radius * (-cost * dir[0].z - sint * dir[1].z);

      return oSecondDeriv;
    };

    /**
    * @public
    * @memberof DSMath.Circle
    * @method eval
    * @instance
    * @description
    * Compute the 3D point and the 2D coordinates corresponding to the given parameters.
    * @param {Number}                       iT        The circle parameter.
    * @param {DSMath.Point}    [oPoint]  The 3D point evaluated. It has to be allocated by the caller or the computation will not be done.
    * @param {DSMath.Vector2D} [oVect2D] The 2D coordinates on the circle plane support. It has to be allocated by the caller or the computation will not be done.
    * @example
    * var c0 = new DSMath.Circle().setRadius(2).setVectors(1,1,0, -1,1,0).setCenter(1,2,3);
    * var v0 = new DSMath.Vector2D();
    * var p0 = new DSMath.Point();
    * c0.eval(Math.PI/2, null, v0); // v0=(0,2)
    * c0.eval(Math.PI/2, p0);       // p0=(1-2/&#8730;2,2+2/&#8730;2,3)
    * c0.eval(Math.PI, p0, v0);     // p0=(1-2/&#8730;2,2-2/&#8730;2,3) and v0=(-2,0)
    */
    Circle.prototype.eval = function (iParam, oPoint, oVect2D)
    {
      DSMath.TypeCheck(iParam, true, 'number');
      DSMath.TypeCheck(oPoint, false, DSMath.Point);
      DSMath.TypeCheck(oVect2D, false, DSMath.Vector2D);

      var t = iParam * this.scale + this.shift;

      var cost = Math.cos(t);
      var sint = Math.sin(t);

      if (oVect2D)
        oVect2D.set(this.radius * cost, this.radius * sint);

      if (oPoint)
      {
        var dir = this.getDirectionsNotCloned();
        oPoint.x = this.center.x + this.radius * (cost * dir[0].x + sint * dir[1].x);
        oPoint.y = this.center.y + this.radius * (cost * dir[0].y + sint * dir[1].y);
        oPoint.z = this.center.z + this.radius * (cost * dir[0].z + sint * dir[1].z);
      }
    };

    /**
    * @public
    * @memberof DSMath.Circle
    * @method applyTransformation
    * @instance
    * @description
    * Transforms <i>this</i> Circle by applying a transformation on its origin and directions.
    * <br> The transformation has to be reversible and the transformation matrix vectors should be orthogonal and have the same norm (iT.isScaling()=true).
    * Otherwise, the transformation result is not a circle. In such case <i>this</i> circle is not changed.
    * <br>
    * If the transformation performs a scaling, the circle radius is multiplied by the scale.
    * @param {DSMath.Transformation} iT The transformation to apply.
    * @example
    * var t0 = DSMath.Transformation.makeRotation(DSMath.Vector3D.zVect, Math.PI/2, new DSMath.Point(1,1,1));
    * var c0 = new DSMath.Circle(2).setCenter(1,2,3).setVectors(1,1,0, -1,1,0);
    * var c1 = c0.applyTransformation(t0);         // c0===c1 and c1.origin=(0,1,3) and c1.radius=2 and c1.scale=1 and c1.shift=0
    * var dir = c1.getDirections();                // dir[0]=(-1/&#8730;2,1/&#8730;2,0) and dir[1]=(-1/&#8730;2,-1/&#8730;2,0)
    * var t1 = t0.multiplyByScaling(2, c1.center); // We compose t0 with a scaling at the circle center.
    * var c2 = c0.applyTransformation(t1);         // c2===c0 and c2.origin=(1,0,3) and c1.radius=4 and c1.scale=1 and c1.shift=0
    * dir = c2.getDirections();                    // dir[0]=-1/&#8730;2,-1/&#8730;2,0 and dir[1]=1/&#8730;2,-1/&#8730;2,0)
    * @returns {DSMath.Circle} <i>this</i> modified circle reference.
    */
    Circle.prototype.applyTransformation = function (iT)
    {
      DSMath.TypeCheck(iT, true, DSMath.Transformation);

      var scaling = iT.getScaling();

      if (scaling.scale > 0)
      {
        var dir = this.getDirectionsNotCloned();
        this.center.applyTransformation(iT);
        dir[0].applyTransformation(iT).normalize();
        dir[1].applyTransformation(iT).normalize();

        // If we do a scaling, the circle radius change.
        this.radius *= scaling.scale;
      } // Else ==> ellipse.

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Circle
    * @method getParam
    * @instance
    * @description
    * Returns the parameter(s) on <i>this</i> circle corresponding to a point in 3D, in the parameters limits given.
    * @param { DSMath.Point } iPoint       The 3D Point.
    * @param { Number }       iStartParam  The lowest circle parameters on which we can find a solution.
    * @param { Number }       iEndParam    The highest circle parameters on which we can find a solution.
    * @param { Number }       [iTol=1e-13] The max 3D distance between the solution and the point given.
    * @example
    * var c0 = new DSMath.Circle().setRadius(2);
    * var p0 = new DSMath.Point(0,2,0);
    * var p1 = new DSMath.Point(2*Math.SQRT1_2, 2*Math.SQRT1_2,0);
    * var p2 = new DSMath.Point(-0.0002, 2, 0);
    * var p3 = new DSMath.Point(-0.2,2,0);
    * var t0 = c0.getParam(p0, 0, Math.PI  , 0.001);   // t0.length=1 and t0[0]=Math.PI/2
    * var t1 = c0.getParam(p1, 0, Math.PI  , 0.001);   // t1.length=1 and t1[0]=Math.PI/4
    * var t2 = c0.getParam(p2, 0, Math.PI/2, 0.001); // t2.length=1 and t2[0]=Math.PI/2. The error made here is ~0.0002 but far under the tolerance given.
    * var t3 = c0.getParam(p3, 0, Math.PI  , 0.001);   // t3.length=0. The point is too far from the circle (dist>0.001).
    * @returns { Number[] } An array containing 0, 1 or 2 parameters that can be evaluated on the point.
    * <br>
    * Two parameters are return if the solution is on the circle closure.
    */
    Circle.prototype.getParam = function (iPoint, iStartParam, iEndParam, iTol)
    {
      DSMath.TypeCheck(iPoint, true, DSMath.Point);
      DSMath.TypeCheck(iStartParam, true, 'number');
      DSMath.TypeCheck(iEndParam, true, 'number');
      DSMath.TypeCheck(iTol, false, 'number');

      var paramSol = [];
      var dir = this.getDirectionsNotCloned();
      var lengthTol = Math.min(iTol, DSMath.defaultTolerances.epsgForRelativeTest * this.radius);

      // Vector center=>point
      // -----------------------------------------------------
      var vecDiff = iPoint.sub(this.center);
      var vecDiff2D = new Vector2D();
      vecDiff2D.set(vecDiff.dot(dir[0]), vecDiff.dot(dir[1]));
      if (vecDiff2D.squareNorm() < lengthTol * lengthTol)
        return paramSol;

      // Projection on the circle
      // ------------------------------------------------------
      var angle = Math.atan2(vecDiff2D.y, vecDiff2D.x);
      var param = (angle - this.shift) * 1.0 / this.scale;
      var pointSolution = this.evalPoint(param);
      if (pointSolution.squareDistanceTo(iPoint) > iTol * iTol) // The closest distance is too far.
        return paramSol;

      // Extremity check
      // -----------------------------------------------------
      var pointStart = pointSolution;
      var pointStart2D = new Vector2D();
      this.eval(iStartParam, pointStart, pointStart2D);
      var isStartSolution = (pointStart.squareDistanceTo(iPoint) < iTol * iTol &&
                             pointStart2D.cross(vecDiff2D) < lengthTol);

      var pointEnd = pointStart;
      var pointEnd2D = pointStart2D;
      this.eval(iEndParam, pointEnd, pointEnd2D);
      var isEndSolution = (pointEnd.squareDistanceTo(iPoint) < iTol * iTol &&
                           pointEnd2D.cross(vecDiff2D) > -lengthTol);

      if (isStartSolution)
        paramSol[0] = iStartParam;
      if (isEndSolution)
        paramSol[paramSol.length] = iEndParam;

      // General case
      // ----------------------------------------------------
      if (!isStartSolution && !isEndSolution)
      {
        var paramPeriod = (2 * Math.PI) / Math.abs(this.scale);
        var idInterval = Math.floor(iStartParam / paramPeriod);
        param += (param > 0) ? idInterval * paramPeriod : (idInterval + 1) * paramPeriod;
        param += (param < iStartParam) ? paramPeriod : 0.;

        if (param >= iStartParam * (1 - DSMath.defaultTolerances.epsgForRelativeTest) &&
           param <= iEndParam * (1 + DSMath.defaultTolerances.epsgForRelativeTest))
        {
          paramSol[0] = param;
        }
      }

      return paramSol;
    };

    /**
    * @public
    * @typedef IntersectionLineCircleData
    * @type Object
    * @property {Number} paramCircle The parameter on the line at the intersection.
    * @property {Number} paramLine   The parameter on the circle first at the intersection.
    */

    /**
    * @public
    * @memberof DSMath.Circle
    * @method intersectLine
    * @instance
    * @description
    * Intersects a portion of <i>this</i> circle with a portion of the specified line.
    * @param {DSMath.Line} iLine        The line.
    * @param {Number}      iStartLine   Start parameter defining the segment of the specified line to be intersected.
    * @param {Number}      iEndLine     End parameter defining the segment of specified line to be intersected.
    * @param {Number}      iStartCircle Start parameter defining the segment of <i>this</i> circle to be intersected.
    * @param {Number}      iEndCircle   End parameter defining the segment of <i>this</i> circle to be intersected.
    * @param {Number}      iTol         The precision to be used for the computation.
    * @return {IntersectionLineCircleData[]} The intersection result. The length of the array is the number of solution.
    * @example
    * var l0 = new DSMath.Line();
    * var c0 = new DSMath.Circle();
    * var intersectParams = c0.intersectLine(l0, -2, 2, 0, (2*Math.PI)/c0.scale, 0.000001);
    * // intersectParams.length=2 and intersectParams[0]={paramCircle=0, paramLine=1} and intersectParams[1]={paramCircle=PI, paramLine=-1}.
    */
    Circle.prototype.intersectLine = function (iLine, iStartLine, iEndLine, iStartCircle, iEndCircle, iTol)
    {
      DSMath.TypeCheck(iLine, true, DSMath.Line);
      DSMath.TypeCheck(iStartLine, true, 'number');
      DSMath.TypeCheck(iEndLine, true, 'number');
      DSMath.TypeCheck(iStartCircle, true, 'number');
      DSMath.TypeCheck(iEndCircle, true, 'number');
      DSMath.TypeCheck(iTol, true, 'number');

      // Local variables
      // ---------------------------------------------------
      var sol = [];
      var epsgRel = DSMath.defaultTolerances.epsgForRelativeTest;
      var line = iLine.clone();
      line.direction.normalize();
      var scaleLine = line.direction.dot(iLine.direction);
      iStartLine *= scaleLine;
      iEndLine *= scaleLine;
      var dirCircle = this.getDirectionsNotCloned();
      var paramLine = [];

      // Compute the parameter solution on line
      // --------------------------------------------------

      var N = Vector3D.cross(dirCircle[0], dirCircle[1]);
      var diffOrigins = this.center.sub(iLine.origin);
      var paramLine0 = diffOrigins.dot(line.direction);
      var ptLine0 = line.evalPoint(paramLine0);

      var vecDiff = this.center.sub(ptLine0, diffOrigins);
      var distPtLine0 = vecDiff.dot(N);
      var lineDirN = line.direction.dot(N);
      if (Math.abs(lineDirN) < epsgRel && Math.abs(distPtLine0) < iTol * (1 + epsgRel))
      {
        // /!\ The point(s) might not be on the circle plane /!\
        var sqLength = this.radius * this.radius + distPtLine0 * distPtLine0 - vecDiff.squareNorm();// R^2-dist2D^2
        if (sqLength > 0)
        {
          paramLine[0] = Math.sqrt(sqLength);
          paramLine[1] = -paramLine[0];
        }
        else
        {
          paramLine[0] = 0;
        }
      }
      else if (Math.abs(lineDirN) > epsgRel)
      {
        paramLine[0] = distPtLine0 / lineDirN;
      }

      // Computation of the final parameters and check the 
      // validity of the solution.
      // --------------------------------------------------
      for (var i = 0; i < paramLine.length; i++)
      {
        // Line limits
        paramLine[i] += paramLine0;
        if (paramLine[i] < iStartLine)
          paramLine[i] = iStartLine;
        else if (paramLine[i] > iEndLine)
          paramLine[i] = iEndLine;

        // Circle param
        var ptOnLine = line.evalPoint(paramLine[i]); // /!\ Might not be on the circle plane /!\
        var diff = ptOnLine.sub(this.center, vecDiff);
        var angle = Math.atan2(diff.dot(dirCircle[1]), diff.dot(dirCircle[0]));
        var paramCircle = (angle - this.shift) / this.scale;

        // Circle limits
        var paramPeriod = DSMath.constants.PI2 / Math.abs(this.scale);
        var idInterval = (paramCircle < 0) ? Math.floor(iStartCircle / paramPeriod) + 1 : Math.floor(iStartCircle / paramPeriod);
        if (paramCircle + idInterval * paramPeriod < iStartCircle)
        {
          var distStart = iStartCircle - (paramCircle + idInterval * paramPeriod);
          var distEnd = iEndCircle - (paramCircle + (idInterval + 1) * paramPeriod);
          paramCircle = (distEnd >= 0) ? paramCircle + (idInterval + 1) * paramPeriod : (distStart <= -distEnd) ? iStartCircle : iEndCircle;
        }
        else if (paramCircle + idInterval * paramPeriod > iEndCircle)
        {
          var distStart = paramCircle + (idInterval - 1) * paramPeriod - iStartCircle;
          var distEnd = paramCircle + idInterval * paramPeriod - iEndCircle;
          paramCircle = (distStart >= 0) ? paramCircle + (idInterval - 1) * paramPeriod : (-distStart < distEnd) ? iStartCircle : iEndCircle;
        }
        else
          paramCircle += idInterval * paramPeriod;

        // Validity of the solution
        var ptOnCircle = this.evalPoint(paramCircle);
        var diffPts = ptOnLine.sub(ptOnCircle, diff);
        if (diffPts.squareNorm() < iTol * iTol)
          sol[sol.length] = { paramCircle: paramCircle, paramLine: paramLine[i] / scaleLine };
      }

      return sol;
    };

    /**
    * @public
    * @typedef IntersectionCircleCircleData
    * @type Object
    * @property {Number} paramCircle      The parameter on the circle at the intersection.
    * @property {Number} paramOtherCircle The parameter on the other circle at the intersection.
    */

    /**
    * @public
    * @memberof DSMath.Circle
    * @method intersectCircle
    * @instance
    * @description
    * Intersects a portion of <i>this</i> circle with a portion of the another circle.
    * @param {DSMath.Line} iCircle      The other circle.
    * @param {Number}      iStartCircle Start parameter defining the segment of the other circle to be intersected.
    * @param {Number}      iEndCircle   End parameter defining the segment of the other circle to be intersected.
    * @param {Number}      iStartThis   Start parameter defining the segment of <i>this</i> circle to be intersected.
    * @param {Number}      iEndThis     End parameter defining the segment of <i>this</i> circle to be intersected.
    * @param {Number}      iTol         The precision to be used for the computation.
    * @return {IntersectionCircleCircleData} The intersection result. The length of the array is the number of solution.
    * @example
    * var c0 = new DSMath.Circle();
    * var c1 = new DSMath.Circle().setCenter(Math.SQRT2, 0, 0);
    * var intersectParams = c0.intersectCircle(c1, 0, c1.radius*2*Math.PI,  0, c0.radius*2*Math.PI, 0.000001);
    * // intersectParams.length=2 and intersectParams[0]={paramCircle=PI/4, paramOtherCircle=3PI/4} and intersectParams[1]={paramCircle=7PI/4, paramOtherCircle=5PI/4}
    */
    Circle.prototype.intersectCircle = function (iCircle2, iStart2, iEnd2, iStart1, iEnd1, iTol)
    {
      DSMath.TypeCheck(iCircle2, true, DSMath.Circle);
      DSMath.TypeCheck(iStart2, true, 'number');
      DSMath.TypeCheck(iEnd2, true, 'number');
      DSMath.TypeCheck(iStart1, true, 'number');
      DSMath.TypeCheck(iEnd1, true, 'number');
      DSMath.TypeCheck(iTol, true, 'number');

      // Local variables
      // ---------------------------------------------------
      var sol = [];
      var epsgRel = DSMath.defaultTolerances.epsgForRelativeTest;
      var sqEpsgLength = epsgRel * epsgRel * Math.max(this.center.squareDistanceToOrigin(), iCircle2.center.squareDistanceToOrigin(), 1);
      var O1O2 = iCircle2.center.sub(this.center);
      var sqO1O2 = O1O2.squareNorm();
      var dir1 = this.getDirectionsNotCloned();
      var dir2 = iCircle2.getDirectionsNotCloned();
      var N1 = Vector3D.cross(dir1[0], dir1[1]);
      var N2 = Vector3D.cross(dir2[0], dir2[1]);
      var N1xN2 = Vector3D.cross(N1, N2);
      var sqN1N2 = N1xN2.squareNorm();
      var P = undefined;
      var V = undefined;
      var nbSol = 0;

      // We compute the potentials points solution
      // -------------------------------------------------------
      if (sqN1N2 < epsgRel)// Same normal plane
      {
        var O1O2N1 = O1O2.dot(N1);
        var O1O2Proj = Vector3D.multiplyScalar(N1, O1O2N1);
        O1O2Proj = Vector3D.sub(O1O2, O1O2Proj, O1O2Proj);
        var sqDist2D = O1O2Proj.squareNorm();
        var distMax = this.radius + iCircle2.radius + iTol;
        var distMin = Math.abs(this.radius - iCircle2.radius) - iTol;
        if (sqDist2D < distMin * distMin || distMax * distMax < sqDist2D || O1O2N1 > iTol)
          return 0;

        if (sqDist2D > sqEpsgLength)
        {
          var distMinSingle = this.radius + iCircle2.radius - iTol;
          if (distMinSingle * distMinSingle < sqDist2D && sqDist2D < distMax * distMax)
          {
            var dist2D = O1O2Proj.norm();
            O1O2Proj.multiplyScalar(this.radius / dist2D);
            P = DSMath.Point.addVector(this.center, O1O2Proj);
            nbSol = 1;
          }
          else
          {
            var lambda = 0.5 * (1 + (this.radius * this.radius - iCircle2.radius * iCircle2.radius) / sqDist2D); //Al Kashi relation
            var gamma = this.radius * this.radius - lambda * lambda * sqDist2D; // The square distance from the point P+lamdba
            nbSol = 1;
            if (gamma > 0)
            {
              var dir = Vector3D.cross(N1, O1O2Proj);
              gamma = Math.sqrt(gamma / sqDist2D);
              V = Vector3D.multiplyScalar(dir, gamma, dir);
              nbSol += 1;
            }
            O1O2Proj.multiplyScalar(lambda);
            P = DSMath.Point.addVector(this.center, O1O2Proj);
          }
        }
      }
      else
      { // != normals
        var O1O2N2 = O1O2.dot(N2);
        var lambda = (this.radius * this.radius - O1O2N2 * O1O2N2 / sqN1N2);
        var dir = Vector3D.cross(N1, N1xN2);
        dir.multiplyScalar(-O1O2N2 / sqN1N2);
        P = DSMath.Point.addVector(this.center, dir);
        nbSol = 1;
        if (lambda > sqEpsgLength)
        {
          V = N1xN2.multiplyScalar(Math.sqrt(lambda));
          nbSol += 1;
        }
      }

      // We compute the solution parameters and check
      // the validity of the solutions
      // -------------------------------------------------------
      var period1 = DSMath.constants.PI2 / Math.abs(this.scale);
      var period2 = DSMath.constants.PI2 / Math.abs(iCircle2.scale);
      var pt1, pt2;
      for (var i = 0; i < nbSol; i++)
      {
        if (i == 1)
          V.multiplyScalar(-1);
        var PtSol = (nbSol == 1) ? P : DSMath.Point.addVector(P, V);

        // We compute the param on this circle
        var O1P = PtSol.sub(this.center, O1O2);
        var angle1 = Math.atan2(O1P.dot(dir1[1]), O1P.dot(dir1[0]));
        var param1 = (angle1 - this.shift) / this.scale;
        var idInterval1 = (param1 < 0) ? Math.floor(iStart1 / period1) + 1 : Math.floor(iStart1 / period1);
        if (param1 + idInterval1 * period1 < iStart1)
        {
          var distStart = iStart1 - (param1 + idInterval1 * period1);
          var distEnd = iEnd1 - (param1 + (idInterval1 + 1) * period1);
          param1 = (distEnd >= 0) ? param1 + (idInterval1 + 1) * period1 : (distStart <= -distEnd) ? iStart1 : iEnd1;
        }
        else if (param1 + idInterval1 * period1 > iEnd1)
        {
          var distStart = param1 + (idInterval1 - 1) * period1 - iStart1;
          var distEnd = param1 + idInterval1 * period1 - iEnd1;
          param1 = (distStart >= 0) ? param1 + (idInterval1 - 1) * period1 : (-distStart < distEnd) ? iStart1 : iEnd1;
        }
        else
          param1 += idInterval1 * period1;

        pt1 = this.evalPoint(param1);

        // We compute the param on the other circle
        var O2P = PtSol.sub(iCircle2.center, O1P);
        var angle2 = Math.atan2(O2P.dot(dir2[1]), O1P.dot(dir2[0]));
        var param2 = (angle2 - iCircle2.shift) / iCircle2.scale;
        var idInterval2 = (param2 < 0) ? Math.floor(iStart2 / period2) + 1 : Math.floor(iStart2 / period2);
        if (param2 + idInterval2 * period2 < iStart2)
        {
          var distStart = iStart2 - (param2 + idInterval2 * period2);
          var distEnd = iEnd2 - (param2 + (idInterval2 + 1) * period2);
          param2 = (distEnd >= 0) ? param2 + (idInterval2 + 1) * period2 : (distStart <= -distEnd) ? iStart2 : iEnd2;
        }
        else if (param2 + idInterval2 * period2 > iEnd2)
        {
          var distStart = param2 + (idInterval2 - 1) * period2 - iStart2;
          var distEnd = param2 + idInterval2 * period2 - iEnd2;
          param2 = (distStart >= 0) ? param2 + (idInterval2 - 1) * period2 : (-distStart < distEnd) ? iStart2 : iEnd2;
        }
        else
          param2 += idInterval2 * period2;

        pt2 = iCircle2.evalPoint(param2);

        // We check and save the result
        if (pt1.squareDistanceTo(pt2) < iTol * iTol)
          sol[sol.length] = { paramCircle: param1, paramOtherCircle: param2 };
      }

      return sol;
    };

    DSMath.Circle = Circle;

    return Circle;
  }
);
