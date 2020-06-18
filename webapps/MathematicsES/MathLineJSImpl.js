define('MathematicsES/MathLineJSImpl',
  ['MathematicsES/MathNameSpace'     ,
   'MathematicsES/MathTypeCheck',
   'MathematicsES/MathTypeCheckInternal',
   'MathematicsES/MathPointJSImpl',
   'MathematicsES/MathVector3DJSImpl'
  ],
   
  function (DSMath, TypeCheck, TypeCheckInternal, Point, Vector3D)
  {
    'use strict';

    /**
    * @public
    * @exports Line
    * @class
    * @classdesc Representation of a Line in 3D.
    *
    * @constructor
    * @constructordesc
    * The DSMath.Line constructor creates a Line in 3D, which is represented by an origin and a direction. The direction norm is the scale of the line (scale=parametrization distortion).
    * @param {DSMath.Point}    [iO=(0,0,0)] The line origin. Note the content of the point given is duplicated so <i>this</i>.origin!==iO.
    * @param {DSMath.Vector3D} [iD=(1,0,0)] The line direction. Note the content of the vector given is duplicated so <i>this</i>.direction!==iD. No normalization is performed since its norm describes the line scale.
    * @memberof DSMath
    */
    var Line = function (iO, iD)
    {
      DSMath.TypeCheck(iO, false, DSMath.Point);
      DSMath.TypeCheck(iD, false, DSMath.Vector3D);

      this.origin = (iO) ? iO.clone() : new Point(0, 0, 0);
      this.direction = (iD) ? iD.clone() : new Vector3D(1, 0, 0);
    };

    /**
    * The origin property of a line.
    * @member
    * @instance
    * @name origin
    * @public
    * @type { DSMath.Point }
    * @memberOf DSMath.Line
    */
    Line.prototype.origin = null;

    /**
    * The direction property of a line.
    * @member
    * @instance
    * @name direction
    * @public
    * @type { DSMath.Vector3D }
    * @memberOf DSMath.Line
    */
    Line.prototype.direction = null;

    /**
     * The scale property of a line.
     * @member
     * @instance
     * @name scale
     * @public
     * @type { Number }
     * @memberOf DSMath.Line
    */
    Object.defineProperty(Line.prototype, "scale", {
      enumerable: true,
      configurable: true,
      get: function ()
      {
        return this.getScale();
      },
      set: function (l)
      {
        return this.setScale(l);
      }
    });

    // ---------------------------------------------------------------------------------
    // Private methods
    // ---------------------------------------------------------------------------------

    /** @ignore */
    Line.prototype.IsInfinite = function ()
    {
      return true;
    }

    /**
    * @public
    * @memberof DSMath.Line
    * @method clone
    * @instance
    * @description
    * Clones <i>this</i> Line.
    * @example
    * var l0 = new DSMath.Line().set(1,2,3,Math.SQRT1_2, Math.SQRT1_2, 0);
    * var l1 = l0.clone(); // l1==l0 but l1!==l0.
    * @returns {DSMath.Line} The cloned Line.
    */
    Line.prototype.clone = function ()
    {
      var l_out = new Line();
      return l_out.copy(this);
    };

    /**
    * @public
    * @memberof DSMath.Line
    * @method copy
    * @instance
    * @description
    * Copies <i>this</i> Line.
    * @param {DSMath.Line} iL The line to copy.
    * @example
    * var l0 = new DSMath.Line().set(1,2,3,Math.SQRT1_2, Math.SQRT1_2, 0);
    * var l1 = new DSMath.Line();
    * l1.copy(l0); // l1==l0 but l1!==l0;
    * @returns {DSMath.Line}  <i>this</i> modified line reference.
    */
    Line.prototype.copy = function (iToCopy)
    {
      DSMath.TypeCheck(iToCopy, true, DSMath.Line);

      this.origin.copy(iToCopy.origin);
      this.direction.copy(iToCopy.direction);
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Line
    * @method set
    * @instance
    * @description
    * Assigns new coordinate the <i>this</i> line origin and direction.
    * @param {Number} [iOx=0] The new x origin coordinate
    * @param {Number} [iOy=0] The new y origin coordinate
    * @param {Number} [iOz=0] The new z origin coordinate
    * @param {Number} [iDx=0] The new x direction coordinate
    * @param {Number} [iDy=0] The new y direction coordinate
    * @param {Number} [iDz=0] The new z direction coordinate
    * @example
    * var l0 = new DSMath.Line().set(1,2,3,Math.SQRT1_2, Math.SQRT1_2, 0);
    * // l0.origin = [1,2,3]
    * // l0.direction = [1/&#8730;2,1/&#8730;2,0]
    * @returns {DSMath.Line}  <i>this</i> modified line reference.
    */
    Line.prototype.set = function (iOx, iOy, iOz, iDx, iDy, iDz)
    {
      DSMath.TypeCheck(iOx, false, 'number');
      DSMath.TypeCheck(iOy, false, 'number');
      DSMath.TypeCheck(iOz, false, 'number');
      DSMath.TypeCheck(iDx, false, 'number');
      DSMath.TypeCheck(iDy, false, 'number');
      DSMath.TypeCheck(iDz, false, 'number');

      this.origin.set(iOx || 0, iOy || 0, iOz || 0);
      this.direction.set(iDx || 0, iDy || 0, iDz || 0);
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Line
    * @method setOrigin
    * @instance
    * @description
    * Assigns new coordinates values to <i>this</i> line origin.
    * @param {Number | DSMath.Point}  iX     Value for the x coordinate or the point to copy.
    * @param {Number}                              [iY=0] Value for the y coordinate. Not used if iX is a Point.
    * @param {Number}                              [iZ=0] Value for the z coordinate. Not used if iX is a Point.
    * @example
    * var l0 = new DSMath.Line().setOrigin(1,2,3); // l0.origin=[1,2,3]
    * var p0 = new DSMath.Point(1,1,1);
    * l0.setOrigin(p0);                             // l0.origin=[1,1,1] (copy of p0).
    * p0.set(0,0,0);                                // l0.origin=[1,1,1]
    * @returns {DSMath.Line} <i>this</i> modified line reference.
    */
    Line.prototype.setOrigin = function (iX, iY, iZ)
    {
      DSMath.TypeCheck(iX, true, ['number', DSMath.Point]);
      DSMath.TypeCheck(iY, false, 'number');
      DSMath.TypeCheck(iZ, false, 'number');

      if (iX.constructor === Point)
        this.origin.copy(iX);
      else
        this.origin.set(iX, iY || 0, iZ || 0);

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Line
    * @method setDirection
    * @instance
    * @description
    * Assigns new coordinates values to <i>this</i> line direction.
    * @param {Number | DSMath.Vector3D}  iX     Value for the x coordinate or the vector to copy.
    * @param {Number}                                 [iY=0] Value for the y coordinate. Not used if iX is a Vector3D.
    * @param {Number}                                 [iZ=0] Value for the z coordinate. Not used if iX is a Vector3D.
    * @example
    * var l0 = new DSMath.Line().setDirection(1,2,3); // l0.direction=[1,2,3]
    * var v0 = new DSMath.Vector3D(1,1,1);
    * l0.setDirection(v0);                             // l0.direction=[1,1,1] (copy of v0).
    * v0.set(1,0,0);                                   // l0.direction=[1,1,1]
    * @returns {DSMath.Line} <i>this</i> modified line reference.
    */
    Line.prototype.setDirection = function (iX, iY, iZ)
    {
      DSMath.TypeCheck(iX, true, ['number', DSMath.Vector3D]);
      DSMath.TypeCheck(iY, false, 'number');
      DSMath.TypeCheck(iZ, false, 'number');

      if (iX.constructor === Vector3D)
        this.direction.copy(iX);
      else
        this.direction.set(iX, iY || 0, iZ || 0);

      return this;
    };

    /**
    * @private
    * @memberof DSMath.Line
    * @method setScale
    * @instance
    * @description
    * Assigns a new scale to the line.
    * @param {Number} iS The new scale. iS should not be equals to 0.
    * @example
    * var l0 = new DSMath.Line().set(1,1,1,1,1,1);
    * var l1 = l0.setScale(1); // l1===l0 and l1.direction=(1/&#8731;3,1/&#8731;3,1/&#8731;3).
    * @returns {DSMath.Line}  <i>this</i> modified line reference.
    */
    Line.prototype.setScale = function (s)
    {
      DSMath.TypeCheck(s, true, 'number');

      if (Math.abs(s) > DSMath.defaultTolerances.epsgForLengthTest)
      {
        this.direction.normalize();
        this.direction.multiplyScalar(s);
      }

      return this;
    };

    /**
    * @private
    * @memberof DSMath.Line
    * @method getScale
    * @instance
    * @description
    * Rerieves the line scale.
    * @example
    * var l0 = new DSMath.Line().set(1,2,3,4,5,6);
    * var l0Scale = l0.getScale(); // &#8730;77
    * @returns {Number} The scale.
    */
    Line.prototype.getScale = function ()
    {
      var vect = this.direction;
      return (vect.norm());
    };

    /**
    * @private
    * @memberof DSMath.Line
    * @method evalPoint
    * @instance
    * @description
    * Returns the point of <i>this</i> line corresponding to a given parameter.
    * @param {Number}                    iT   The parameter.
    * @param {DSMath.Point} [oP] Reference of the operation result (avoid allocation).
    * @example
    * var l0 = new DSMath.Line().set(1,2,3, Math.SQRT1_2, Math.SQRT1_2, 0);
    * var l0p0 = l0.evalPoint(0); // p0==l0.origin;
    * var l0p1 = l0.evalPoint(1); // p1=(1+1/&#8730;2, 2+1/&#8730;2, 3)
    * var l0pt = l0.evalPoint(Math.SQRT2); // pt=(2,3,3);
    * var l1 = new DSMath.Line().set(1,2,3,4,5,6);
    * var l1p0 = l1.evalPoint(0); // l1p0=(1,2,3);
    * var l1p1 = l1.evalPoint(1); // l1p1=(5,7,9);
    * @returns {DSMath.Point} The reference of the operation result.
    */
    Line.prototype.evalPoint = function (iT, oP)
    {
      DSMath.TypeCheck(iT, true, 'number');
      DSMath.TypeCheck(oP, false, DSMath.Point);

      oP = (oP) ? op.copy(this.origin) : this.origin.clone();
      return oP.addScaledVector(this.direction, iT);
    };

    /**
    * @private
    * @memberof DSMath.Line
    * @method evalFirstDeriv
    * @instance
    * @description
    * Returns the derivative of <i>this</i> line corresponding to the given parameter (the direction)
    * @param {Number} iT  The line parameter
    * @example
    * var l0 = new DSMath.Line().set(1,2,3, 1,2,0);
    * var v0 = l0.evalFirstDeriv(0);   // v0 = (1, 2, 0)
    * var v1 = l0.evalFirstDeriv(0.5); // v1 = (1, 2, 0)
    * var v2 = l0.evalFirstDeriv(1.0); // v2 = (1, 2, 0)
    * @returns { DSMath.Vector3D } The reference of the operation result - the gradient evaluated.
    */
    Line.prototype.evalFirstDeriv = function (iT)
    {
      DSMath.TypeCheck(iT, true, 'number');

      var oDeriv = this.direction.clone();
      return oDeriv;
    };

    /**
    * @private
    * @memberof DSMath.Line
    * @method evalSecondDeriv
    * @instance
    * @description
    * Returns the second derivative of <i>this</i> line corresponding to the given parameter (the direction)
    * @param {Number} iT  The line parameter
    * @example
    * var l0 = new DSMath.Line().set(1,2,3, 1,2,0);
    * var v0 = l0.evalSecondDeriv(0);   // v0 = (0, 0, 0)
    * var v1 = l0.evalSecondDeriv(0.5); // v1 = (0, 0, 0)
    * var v2 = l0.evalSecondDeriv(1.0); // v2 = (0, 0, 0)
    * @returns { DSMath.Vector3D } The reference of the operation result - the gradient evaluated.
    */
    Line.prototype.evalSecondDeriv = function (iT)
    {
      DSMath.TypeCheck(iT, true, 'number');

      var oSecondDeriv = new DSMath.Vector3D(0,0,0);
      return oSecondDeriv;
    };

    /**
    * @public
    * @memberof DSMath.Line
    * @method squareDistanceToPoint
    * @instance
    * @description
    * Returns the square distance between <i>this</i> line and the given point.
    * @param {DSMath.Point} iP The point.
    * @example
    * var p0 = new DSMath.Point(-Math.SQRT2, Math.SQRT2, 0);
    * var l0 = new DSMath.Line().setDirection(Math.SQRT1_2, Math.SQRT1_2, 0);
    * var sqDist = l0.squareDistanceToPoint(p0); // sqDist=4;
    * @return {Number} The square distance between <i>this</i> line and the point given.
    */
    Line.prototype.squareDistanceToPoint = function (iP)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point);

      var firstAxis = this.direction
      var ori = this.origin;
      var oriToPt = ori.sub(iP);
      return (oriToPt.cross(firstAxis).squareNorm()) / firstAxis.squareNorm();
    };

    /**
    * @public
    * @memberof DSMath.Line
    * @method distanceToPoint
    * @instance
    * @description
    * Returns the distance between <i>this</i> line and the given point.
    * @param {DSMath.Point} iP The point.
    * @example
    * var p0 = new DSMath.Point(-Math.SQRT2, Math.SQRT2, 0);
    * var l0 = new DSMath.Line().setDirection(Math.SQRT1_2, Math.SQRT1_2, 0);
    * var dist = l0.distanceToPoint(p0); // dist=2;
    * @return {Number} The distance between <i>this</i> line and the point given.
    */
    Line.prototype.distanceToPoint = function (iP)
    {
      DSMath.TypeCheck(iP, true, DSMath.Point);

      return Math.sqrt(this.squareDistanceToPoint(iP));
    };

    /**
    * @public
    * @typedef DistanceLineLineData
    * @type Object
    * @property {Number} param1 The parameter on the first line at the point achieving the computed distance.
    * @property {Number} param2 The parameter on the second line at the point achieving the computed distance.
    * @property {Number} diag   Equals 0 if the line have a min distance, 1 if the line are parallel but not confused, 2 if they are confused.
    */

    /**
    * @public
    * @memberof DSMath.Line
    * @method distanceToLine
    * @instance
    * @description
    * Returns the distance between <i>this</i> line and another line.
    * @param {DSMath.Line} iL   The second line.
    * @param {DistanceLineLineData}     [oD] Filled if given. param1 is the parameter on <i>this</i> line. param2 is the parameters on the given line.
    * <br>
    * If the line are parallel, param1 is set to zero and param2 is the corresponding parameters on the given Line.
    * @example
    * var l0 = new DSMath.Line().setDirection(1,1,0);
    * var l1 = new DSMath.Line().set(1,1,2, 1,-1,0);
    * var oD = {param1:0, param2:0, diag:0};
    * var distL0L1 = l0.distanceToLine(l1,oD); // distL0L1=2 and oD.param1=1, oD.param2=0, oD.diag=0
    * @return {Number} The distance between <i>this</i> line and the given one.
    */
    Line.prototype.distanceToLine = function (iL, oD)
    {
      DSMath.TypeCheck(iL, true, DSMath.Line);
      DSMath.TypeCheck(oD, false, Object);

      oD = oD || { param1: 0, param2: 0, diag: 0 };
      var dist = 0;

      var sqEpsg = DSMath.defaultTolerances.epsgForSquareAngleTest;
      var epsi = DSMath.defaultTolerances.epsilonForRelativeTest;
      var n1 = this.getScale();
      var d1 = this.direction;
      var n2 = iL.getScale();
      var d2 = iL.direction;
      var o1o2 = this.origin.sub(iL.origin);
      var cos12 = d1.dot(d2) / (n1 * n2);

      if (Math.abs(cos12 * cos12 - 1) < sqEpsg)
      {
        // Case the two lines are //
        epsi = this.distanceTo(iL);
        oD.diag = (dist < epsi) ? 2 : 1;
        oD.param2 = Math.sqrt(o1o2.squareNorm() - dist * dist) / n2;
        oD.param2 *= (o1o2.dot(d2) > 0) ? 1 : -1;
      } else
      {
        // General case
        dist = Math.abs(Vector3D.cross(d1, d2).dot(o1o2)) / (n1 * n2);

        var det = 1 - cos12 * cos12;
        var o1o2d1 = o1o2.dot(d1) / n1;
        var o1o2d2 = o1o2.dot(d2) / n2;
        oD.diag = 0;
        oD.param1 = (cos12 * o1o2d2 - o1o2d1) / (det * n1);
        oD.param2 = (o1o2d2 - cos12 * o1o2d1) / (det * n2);
      }

      return dist;
    };

    /**
    * @public
    * @memberof DSMath.Line
    * @method squareDistanceToLine
    * @instance
    * @description
    * Returns the square distance between <i>this</i> line and another line.
    * @param {DSMath.Line} iL   The second line.
    * @param {DistanceLineLineData}     [oD] Filled if given. param1 The parameter on <i>this</i> line. param2 is the parameters on the given line.
    * <br>
    * If the line are parallel, param1 is set to zero and param2 is the corresponding parameters on the given Line.
    * @example
    * var l0 = new DSMath.Line().setDirection(1,1,0);
    * var l1 = new DSMath.Line().set(1,1,2, 1,-1,0);
    * var oD = {param1:0, param2:0, diag:0};
    * var sqDistL0L1 = l0.squareDistanceToLine(l1,oD); // sqDistL0L1=4 and oD.param1=1, oD.param2=0
    * @return {Number} The distance between <i>this</i> line and the given one.
    */
    Line.prototype.squareDistanceToLine = function (iL, oD)
    {
      DSMath.TypeCheck(iL, true, DSMath.Line);
      DSMath.TypeCheck(oD, false, Object);

      oD = oD || { param1: 0, param2: 0, diag: 0 };
      var dist = this.distanceToLine(iL, oD);
      return dist * dist;
    };


    /**
    * @public
    * @memberof DSMath.Line
    * @method getParam
    * @instance
    * @description
    * Returns the parameter(s) on <i>this</i> line corresponding to a point in 3D, in the parameters limits given.
    * @param { DSMath.Point } iPoint       The 3D Point.
    * @param { Number }       iStartParam  The lowest line parameters on which we can find a solution.
    * @param { Number }       iEndParam    The highest line parameters on which we can find a solution.
    * @param { Number }       [iTol=1e-13] The max 3D distance between the solution and the point given.
    * @example
    * var eps  = DSMath.defaultTolerances.epsgForRelativeTest;
    * var l0   = new DSMath.Line().setDirection(1,1,0);
    * var dEps = new DSMath.Vector3D(-eps*Math.SQRT1_2,eps*Math.SQRT1_2,0);
    * var p0 = new DSMath.Point(Math.SQRT1_2, Math.SQRT1_2,0);
    * var p1 = new DSMath.Point(1,1,0);
    * var p2 = p1.clone().addScaledVector(dEps,0.99);
    * var p3 = p1.clone().addScaledVector(dEps,1.1);
    * var t0 = l0.getParam(p0, 0, 1, eps); // t0.length=1 and t0[0]=Math.SQRT1_2
    * var t1 = l0.getParam(p1, 0, 1, eps); // t1.length=1 and t1[0]=1
    * var t2 = l0.getParam(p2, 0, 1, eps); // t2.length=1 and t2[0]=1. The error made here is under the tolerance given.
    * var t3 = l0.getParam(p3, 0, 1, eps); // t3.length=0. The point is too far from the line (dist>eps)
    * @returns { Number[] } An array containing 0 or 1 parameter that can be evaluated on the point.
    */
    Line.prototype.getParam = function (iPoint, iStartParam, iEndParam, iTol)
    {
      DSMath.TypeCheck(iPoint, true, DSMath.Point);
      DSMath.TypeCheck(iStartParam, true, 'number');
      DSMath.TypeCheck(iEndParam, true, 'number');
      DSMath.TypeCheck(iTol, false, 'number');

      var paramSol = [];

      var diff = iPoint.sub(this.origin);
      var param = diff.dot(this.direction) / this.direction.squareNorm();

      param = (param < iStartParam) ? iStartParam : (iEndParam < param) ? iEndParam : param;

      var pt = this.evalPoint(param);
      diff = pt.sub(iPoint, diff);
      if (diff.squareNorm() < iTol * iTol)
        paramSol[0] = param;

      return paramSol;
    };

    /**
    * @public
    * @typedef IntersectionLineLineData
    * @type Object
    * @property {Number} param1 The parameter on the first line at the intersection.
    * @property {Number} param2 The parameter on the second line at the intersection.
    * @property {Number} diag   Equals -1 if no intersection exists, 0 if the lines only intersects at one point, 1 if the line are confused.
    */

    /**
    * @public
    * @memberof DSMath.Line
    * @method intersectLine
    * @instance
    * @description
    * Intersects a portion of <i>this</i> line with a portion of the specified line.
    * @param {DSMath.Line} iLine The second line.
    * @param {Number} iStartThis Start parameter defining the segment of <i>this</i> line to be intersected.
    * @param {Number} iEndThis End parameter defining the segment of <i>this</i> line to be intersected.
    * @param {Number} iStartLine Start parameter defining the segment of the specified line to be intersected.
    * @param {Number} iEndLine End parameter defining the segment of specified line to be intersected.
    * @param {Number} [iTol=1e-13] The precision to be used for the computation (max distance error).
    * @return {IntersectionLineLineData} The intersection result.
    * @example
    * var l0 = new DSMath.Line().setDirection(1,1,0);
    * var l1 = new DSMath.Line().setOrigin(0,1,1).setDirection(-1,0,1);
    * var intl0l1 = l0.intersectLine(l1, -1, 1, -1, 1); // intl0l1.diag=1, intl0l1.param1=1, intL0l1.param2=-1;
    */
    Line.prototype.intersectLine = function (iLine, iStart1, iEnd1, iStart2, iEnd2, iTol)
    {
      DSMath.TypeCheck(iLine, true, DSMath.Line);
      DSMath.TypeCheck(iStart1, true, 'number');
      DSMath.TypeCheck(iEnd1, true, 'number');
      DSMath.TypeCheck(iStart2, true, 'number');
      DSMath.TypeCheck(iEnd2, true, 'number');
      DSMath.TypeCheck(iTol, false, 'number');

      iTol = iTol || DSMath.defaultTolerances.epsgForRelativeTest;
      var sqEpsg = DSMath.defaultTolerances.epsgForSquareRelativeTest;
      var sqEpsgAbs = sqEpsg * Math.max(1, this.origin.squareDistanceToOrigin());

      var result = { param1: 0, param2: 0, diag: -1 };

      // Pseudo-versioning...
      var VERSION = 2;

      var d1 = this.direction;
      var n1 = d1.norm();
      var d2 = iLine.direction;
      var n2 = d2.norm();

      var cos12 = d1.dot(d2) / (n1 * n2);
      var sqSin12 = 1 - cos12 * cos12;

      // Line not parallel
      if (sqSin12 > sqEpsg)
      {
        var t1 = 0.0;
        var t2 = 0.0;

        if (VERSION >= 2)
        {
          var O1 = this.origin;
          var O2 = iLine.origin;

          // L1 = O1 + t1*d1
          // L2 = O2 + t2*d2
          //   ==> O1 + t1*d1 = O2 + t2*d2
          //   ==> (O1 - O2) = t2*d2 - t1*d1
          //     ==> (O1 - O2)*p1 =  t2*(d2*p1)
          //     ==> (O2 - O2)*p2 = -t1*(d1*p2)

          // Take dot-product with a vector perpendicular to d1 and the common normal
          //   ==> (O1 - O2)*p1 = -t2* (d2*p1)
          var normal = d1.clone().cross(d2);
          var p1 = normal.clone().cross(d1);

          var LHS = O1.sub(O2).dot(p1);
          var RHS = d2.dot(p1);

          t2 = LHS / RHS;

          var p2 = normal.clone().cross(d2);
          LHS = O1.sub(O2).dot(p2);
          RHS = -d1.dot(p2);

          t1 = LHS / RHS;
        }
        else
        {
          var o1o2 = this.origin.sub(iLine.origin);
          var o1o2d1 = o1o2.dot(d1);
          var o1o2d2 = o1o2.dot(d2);

          t1 = (cos12 * o1o2d2 - o1o2d1) / (sqSin12 * n1 * n1);
          t2 = (o1o2d2 - cos12 * o1o2d1) / (sqSin12 * n2 * n2);
        }

        t1 = (t1 < iStart1) ? iStart1 : (t1 > iEnd1) ? iEnd1 : t1;
        t2 = (t2 < iStart2) ? iStart2 : (t2 > iEnd2) ? iEnd2 : t2;

        var p1 = this.evalPoint(t1);
        var p2 = iLine.evalPoint(t2);

        if (p1.squareDistanceTo(p2) < iTol * iTol)
        {
          result.param1 = t1;
          result.param2 = t2;
          result.diag = 0; // the result is a point.
        }
      }
      else if (iLine.squareDistanceToPoint(this.origin) < sqEpsgAbs)
      {
        result.diag = 1; // the result is a line.
      }

      return result;
    };

    /**
    * @public
    * @memberof DSMath.Line
    * @method intersectFullLine
    * @instance
    * @description
    * Intersects <i>this</i> full line with the specified full line.
    * @param {DSMath.Line} iLine The second line.
    * @param {Number} [iTol=1e-13] The precision to be used for the computation (max distance error).
    * @return {IntersectionLineLineData} The intersection result.
    * @example
    * var l0 = new DSMath.Line().setDirection(1,1,0);
    * var l1 = new DSMath.Line().setOrigin(0,1,1).setDirection(-1,0,1);
    * var intl0l1 = l0.intersectFullLine(l1); // intl0l1.diag=1, intl0l1.param1=1, intL0l1.param2=-1;
    */
    Line.prototype.intersectFullLine = function (iLine, iTol)
    {
      DSMath.TypeCheck(iLine, true, DSMath.Line);
      DSMath.TypeCheck(iTol, false, 'number');

      iTol = iTol || DSMath.defaultTolerances.epsgForRelativeTest;
      var sqEpsg = DSMath.defaultTolerances.epsgForSquareRelativeTest;
      var sqEpsgAbs = sqEpsg * Math.max(1, this.origin.squareDistanceToOrigin());

      var result = { param1: 0, param2: 0, diag: -1 };
      var d1 = this.direction;
      var n1 = d1.norm();
      var d2 = iLine.direction;
      var n2 = d2.norm();

      var cos12 = d1.dot(d2) / (n1 * n2);
      var sqSin12 = 1 - cos12 * cos12;

      // Line not parallel
      if (sqSin12 > sqEpsg)
      {
        var o1o2 = this.origin.sub(iLine.origin);
        var o1o2d1 = o1o2.dot(d1);
        var o1o2d2 = o1o2.dot(d2);

        var t1 = (cos12 * o1o2d2 - o1o2d1) / (sqSin12 * n1 * n1);
        var t2 = (o1o2d2 - cos12 * o1o2d1) / (sqSin12 * n2 * n2);

        var p1 = this.evalPoint(t1);
        var p2 = iLine.evalPoint(t2);

        if (p1.squareDistanceTo(p2) < iTol * iTol)
        {
          result.param1 = t1;
          result.param2 = t2;
          result.diag = 0; // the result is a point.
        }
      } else if (iLine.squareDistanceToPoint(this.origin) < sqEpsgAbs)
      {
        result.diag = 1; // the result is a line.
      }

      return result;
    };

    /**
    * @public
    * @memberof DSMath.Line
    * @method intersectCircle
    * @instance
    * @description
    * Intersects a portion of <i>this</i> line with a portion of the specified circle.
    * @param {DSMath.Circle} iCircle      The circle.
    * @param {Number}                     iStartCircle Start parameter defining the segment of the specified circle to be intersected.
    * @param {Number}                     iEndCircle   End parameter defining the segment of the specified circle to be intersected.
    * @param {Number}                     iStartLine   Start parameter defining the segment of <i>this</i> line to be intersected.
    * @param {Number}                     iEndLine     End parameter defining the segment of <i>this</i> line to be intersected.
    * @param {Number}                     iTol         The precision to be used for the computation.
    * @return {IntersectionLineCircleData[]} The intersection result. The length of the array is the number of solution.
    * @example
    * var l0 = new DSMath.Line();
    * var c0 = new DSMath.Circle();
    * var intersectParams = l0.intersectCircle(c0, 0, (2*Math.PI)/c0.scale, -2, 2, 1e-6);
    * // intersectParams.length=2 and intersectParams[0]={paramCircle=0, paramLine=1} and intersectParams[1]={paramCircle=PI, paramLine=-1}.
    */
    Line.prototype.intersectCircle = function (iCircle, iStartCircle, iEndCircle, iStartLine, iEndLine, iTol)
    {
      DSMath.TypeCheck(iCircle, true, DSMath.Circle);
      DSMath.TypeCheck(iStartCircle, true, 'number');
      DSMath.TypeCheck(iEndCircle, true, 'number');
      DSMath.TypeCheck(iStartLine, true, 'number');
      DSMath.TypeCheck(iEndLine, true, 'number');
      DSMath.TypeCheck(iTol, true, 'number');

      return iCircle.intersectLine(this, iStartLine, iEndLine, iStartCircle, iEndCircle, iTol);
    };

    /**
    * @public
    * @memberof DSMath.Line
    * @method applyTransformation
    * @instance
    * @description
    * Transforms <i>this</i> Line by applying a transformation on its origin and direction.
    * @param {DSMath.Transformation} iT The transformation to apply.
    * @example
    * var l0 = new DSMath.Line().setDirection(1,1,0).setOrigin(1,1,1);
    * var t = DSMath.Transformation.makeRotation(DSMath.Vector3D.zVect, Math.PI/2).setVector(1,2,3);
    * var l1 = l0.applyTransformation(t); // l1===l0 and l1.origin=(0,3,4) and l1.direction(-1,1,0);
    * @returns {DSMath.Line} <i>this</i> modified line reference.
    */
    Line.prototype.applyTransformation = function (iT)
    {
      DSMath.TypeCheck(iT, true, DSMath.Transformation);

      this.origin.applyTransformation(iT);
      this.direction.applyTransformation(iT);
      return this;
    };

    /**-----------------------------------------
     * -------------- STATIC -------------------
     * -----------------------------------------
     */
    /**
    * @public
    * @memberof DSMath.Line
    * @method makeFromPoints
    * @static
    * @description
    * Creates a line defined by the two given points.
    * <br> By default the line scale is 1. If both line parameters are provided, the scale will be updated.
    * @param {DSMath.Point} iPt1      The first point on the line.
    * @param {DSMath.Point} iPt2      The second point on the line. Has to be different from iPt1.
    * @param {Number}       [iParam1] The line parameter for which the first point is reached (<=> line.EvalPoint(iParam1)==iPt1)
    * @param {Number}       [iParam2] The line parameter for which the second point is reached (<=> line.EvalPoint(iParam2)==iPt2)
    * @example
    * var pt0 = new DSMath.Point(2,2,0);
    * var pt1 = new DSMath.Point(4,2,0);
    * var l0 = DSMath.Line.makeFromPoints(pt0,pt1);     // l0.origin=[2,2,0], l0.direction=[1,0,0] so l0.scale=1
    * var l1 = DSMath.Line.makeFromPoints(pt0,pt1,1);   // l1.origin=[1,2,0], l1.direction=[1,0,0] so l1.scale=1
    * var l2 = DSMath.Line.makeFromPoints(pt0,pt1,0,1); // l2.origin=[2,2,0], l2.direction=[2,0,0] so l2.scale=2
    * @returns {DSMath.Line} The created line.
    */
    Line.makeFromPoints = function (iPt0, iPt1, iParam0, iParam1)
    {
      DSMath.TypeCheck(iPt0, true, DSMath.Point);
      DSMath.TypeCheck(iPt1, true, DSMath.Point);
      DSMath.TypeCheck(iParam0, false, 'number');
      DSMath.TypeCheck(iParam1, false, 'number');

      var line = new DSMath.Line();

      iPt1.sub(iPt0, line.direction);

      if (arguments.length >= 4 && Math.abs(iParam1 - iParam0) > DSMath.defaultTolerances.epsgForLengthTest)
        line.setScale(line.direction.norm() / (iParam1 - iParam0));
      else
        line.setScale(1);

      line.origin.copy(iPt0);
      if (iParam0)
        line.origin.addScaledVector(line.direction, -iParam0);

      return line;
    };

    DSMath.Line = Line;

    return Line;
  }
);

