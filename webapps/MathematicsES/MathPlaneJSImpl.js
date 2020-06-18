define('MathematicsES/MathPlaneJSImpl',
  ['MathematicsES/MathNameSpace',
   'MathematicsES/MathTypeCheck',
   'MathematicsES/MathTypeCheckInternal',
   'MathematicsES/MathLineJSImpl'    ,
   'MathematicsES/MathPointJSImpl'   ,
   'MathematicsES/MathVector3DJSImpl'
  ],
  
  function (DSMath, TypeCheck, TypeCheckInternal, Line, Point, Vector3D)
  {
    'use strict';

    /**
    * @public
    * @exports Plane
    * @class
    * @classdesc Representation of a Plane in 3D.
    *
    * @constructor
    * @constructordesc
    * The DSMath.Plane constructor creates a Plane in 3D, which is represented by an origin and two orthonormalized directions.
    * @param {DSMath.Point}    [iO=(0,0,0)] The plane origin. Note the content of the point given is duplicated so <i>this</i>.origin!==iO.
    * @param {DSMath.Vector3D} [iD1=(1,0,0)] The plane first direction. Note the content of the vector given is duplicated.
    * @param {DSMath.Vector3D} [iD2=(0,1,0)] The plane second direction. Note the content of the vector given is duplication.
    * @memberof DSMath
    */
    var Plane = function (iO, iD1, iD2)
    {
      DSMath.TypeCheck(iO, false, DSMath.Point);
      DSMath.TypeCheck(iD1, false, DSMath.Vector3D);
      DSMath.TypeCheck(iD2, false, DSMath.Vector3D);

      this.origin = (iO) ? iO.clone() : new Point(0, 0, 0);

      var dir = new Array(2);
      dir[0] = (iD1) ? iD1.clone() : new Vector3D(1, 0, 0);
      dir[1] = (iD2) ? iD2.clone() : new Vector3D(0, 1, 0);

      if (iD1 || iD2)
        Vector3D.orthoNormalize(dir[0], dir[1]);

      this.getDirectionsNotCloned = function ()
      {
        return dir;
      };
    };

    /**
    * The <tt>origin</tt> property of a line.
    * @member
    * @instance
    * @name origin
    * @public
    * @type { DSMath.Vector3D }
    * @memberOf DSMath.Plane
    */
    Plane.prototype.origin = null;

    /**
    * @public
    * @memberof DSMath.Plane
    * @method clone
    * @instance
    * @description
    * Clones <i>this</i> Plane.
    * @example
    * var pl0 = new DSMath.Plane().setOrigin(1,2,3).setVectors(1,1,0, -1,1,0);
    * var pl1 = pl0.clone(); //pl1==pl0 but pl1!==pl0.
    * @returns {DSMath.Plane} The cloned plane.
    */
    Plane.prototype.clone = function ()
    {
      var p_out = new Plane();
      p_out.copy(this);
      return p_out;
    };

    /**
    * @public
    * @memberof DSMath.Plane
    * @method copy
    * @instance
    * @description
    * Copies <i>this</i> Plane.
    * @param {DSMath.Plane} iP The plane to copy.
    * @example
    * var pl0 = new DSMath.Plane().setOrigin(1,2,3).setVectors(1,1,0, -1,1,0);
    * var pl1 = new DSMath.Plane();
    * pl1.copy(pl0); //pl1==pl0 but pl1!==pl0.
    * @returns {DSMath.Plane} <i>this</i> modified plane reference.
    */
    Plane.prototype.copy = function (iToCopy)
    {
      DSMath.TypeCheck(iToCopy, false, DSMath.Plane);

      var vectp_out = this.getDirectionsNotCloned();
      var vect = iToCopy.getDirectionsNotCloned();
      vectp_out[0].copy(vect[0]);
      vectp_out[1].copy(vect[1]);

      this.origin.copy(iToCopy.origin);
    };

    /**
    * @public
    * @memberof DSMath.Plane
    * @method setOrigin
    * @instance
    * @description
    * Assigns new coordinates values to <i>this</i> plane origin.
    * @param {Number | DSMath.Point}  iX     Value for the x coordinate or the point to copy.
    * @param {Number}                              [iY=0] Value for the y coordinate. Not used if iX is a Point.
    * @param {Number}                              [iZ=0] Value for the z coordinate. Not used if iX is a Point.
    * @example
    * var pl0 = new DSMath.Plane().setOrigin(1,2,3); // pl0.origin=[1,2,3]
    * var p0 = new DSMath.Point(1,1,1);
    * pl0.setOrigin(p0);                              // pl0.origin=[1,1,1] (copy of p0).
    * p0.set(0,0,0);                                  // pl0.origin=[1,1,1]
    * @returns {DSMath.Plane} <i>this</i> modified plane reference.
    */
    Plane.prototype.setOrigin = function (iX, iY, iZ)
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
    * @memberof DSMath.Plane
    * @method setVectors
    * @instance
    * @description
    * Assigns new vectors to <i>this</i> plane.
    * <br>
    * If the given vectors are not orthonormalized, the method does it if possible.
    * <br>
    * The vector must not be colinear.
    * @param {DSMath.Vector3D | Number}  iV1      New value of the first vector or the first vector x coordinate.
    * @param {DSMath.Vector3D | Number}  iV2      New value of the second vector or the first vector y coordinate.
    * @param {Number}                                 [iV1Z=0] The first  vector z coordinate.
    * @param {Number}                                 [iV2X=0] The second vector x coordinate.
    * @param {Number}                                 [iV2Y=0] The second vector y coordinate.
    * @param {Number}                                 [iV2Z=0] The second vector z coordinate.
    * @example
    * var pl0 = new DSMath.Plane().setOrigin(1,2,3).setVectors(1,1,0, -1,0,0);
    * var dir = pl0.getDirections(); // dir[0] = (1/&#8730;2,1/&#8730;2,0) and dir[1]=(-1/&#8730;2,1/&#8730;2,0)
    * @returns {DSMath.Plane} <i>this</i> modified plane reference.
    */
    Plane.prototype.setVectors = function (iV1, iV2)
    {
      DSMath.TypeCheck(iV1, true, [DSMath.Vector3D, 'number']);
      DSMath.TypeCheck(iV2, false, [DSMath.Vector3D, 'number']);
      DSMath.TypeCheck(arguments[2], false, 'number');
      DSMath.TypeCheck(arguments[3], false, 'number');
      DSMath.TypeCheck(arguments[4], false, 'number');
      DSMath.TypeCheck(arguments[5], false, 'number');

      var dir = this.getDirectionsNotCloned();

      dir[0] = (iV1.constructor === Vector3D) ? dir[0].copy(iV1) : dir[0].set(arguments[0], arguments[1] || 0, arguments[2] || 0);
      dir[1] = (iV2.constructor === Vector3D) ? dir[1].copy(iV2) : dir[1].set(arguments[3] || 0, arguments[4] || 0, arguments[5] || 0);

      Vector3D.orthoNormalize(dir[0], dir[1]);

      return this;
    }

    /**
    * @public
    * @memberof DSMath.Plane
    * @method setNormal
    * @instance
    * @description
    * Defines <i>this</i> plane vectors from a normal given.
    * @param {Number | DSMath.Vector3D} iX Value for the normal x coordinate or the normal vector to copy.
    * @param {Number}                                [iY=0] Value for the normal y coordinate. Not used if iX is a Vector3D.
    * @param {Number}                                [iZ=0] Value for the normal z coordinate. Not used if iX is a Vector3D.
    * @example
    * var pl0 = new DSMath.Plane().setOrigin(1,1,1).setNormal(1,1,0);
    * var dir = pl0.getDirections(); // dir[0]=(1/&#8730;2,-1/&#8730;2,0) and dir[1]=(0,0,-1)
    */
    Plane.prototype.setNormal = function (iX, iY, iZ)
    {
      DSMath.TypeCheck(iX, true, ['number', DSMath.Vector3D]);
      DSMath.TypeCheck(iY, false, 'number');
      DSMath.TypeCheck(iZ, false, 'number');

      var dir = this.getDirectionsNotCloned();

      // We set dir[0]=Normal
      // ------------------------------------
      if (iX.constructor === Vector3D)
        dir[0].copy(iX);
      else
        dir[0].set(iX, iY, iZ);

      var sqNNorm = dir[0].squareNorm();

      // We compute dir[1] then dir[0]
      // ------------------------------------
      dir[1].copy(dir[0]).cross(DSMath.Vector3D.xVect);

      // If iN is colinear to (1,0,0) we use (0,1,0) as reference.
      if (dir[1].squareNorm() < DSMath.defaultTolerances.epsgForSquareAngleTest * sqNNorm)
      {
        dir[1].copy(dir[0]).cross(DSMath.Vector3D.yVect);
      }

      dir[1].normalize();
      dir[0].cross(dir[1]).multiplyScalar(-1).normalize();

      return this;
    };

    /**
    * @public
    * @memberof DSMath.Plane
    * @method makeFromPoints
    * @instance
    * @description
    * Defines <i>this</i> plane from three points.
    * @param {DSMath.Point} iO The origin of the plane.
    * @param {DSMath.Point} iP1 The point which iP1-iO represents the first plane direction.
    * @param {DSMath.Point} iP2 The point which iP2-iO represents the second plane direction.
    * @example
    * var p0 = new DSMath.Point(1,1,1);
    * var p1 = new DSMath.Point(2,2,1);
    * var p2 = new DSMath.Point(0,1,1);
    * var pl0 = new DSMath.Plane().makeFromPoints(p0,p1,p2); // pl0.origin = p0
    * var dir = pl0.getDirections(); // dir[0] = (1/&#8730;2,1/&#8730;2,0) and dir[1]=(-1/&#8730;2,1/&#8730;2,0);
    * @returns {DSMath.Plane} <i>this</i> modified plane reference.
    */
    Plane.prototype.makeFromPoints = function (iO, iP1, iP2)
    {
      DSMath.TypeCheck(iO, true, DSMath.Point);
      DSMath.TypeCheck(iP1, true, DSMath.Point);
      DSMath.TypeCheck(iP2, true, DSMath.Point);

      this.origin = iO;
      var d1 = iP1.sub(iO);
      var d2 = iP2.sub(iO);
      this.setVectors(d1, d2);
      return this;
    };

    /**
    * @public
    * @memberof DSMath.Plane
    * @method getDirections
    * @instance
    * @description
    * Retrieves a copy of the plane directions.
    * @param {DSMath.Vector3D[]} [oA] Reference of the operation result (avoid allocation).
    * @example
    * var pl0 = new DSMath.Plane().setOrigin(1,2,3).setVectors(1,1,0, -1,1,0);
    * var dir = pl0.getDirections(); // dir[0]=(1/&#8730;2,1/&#8730;2,0), dir[1]=(-1/&#8730;2,1/&#8730;2,0)
    * @returns {DSMath.Vector3D[]} Reference of the operation result - The array of orthonormalized direction ([first direction, second direction]).
    */
    Plane.prototype.getDirections = function (ioArray)
    {
      DSMath.TypeCheck(ioArray, false, [DSMath.Vector3D], 2);

      var vec = this.getDirectionsNotCloned();
      if (arguments.length < 1)
        return new Array(vec[0].clone(), vec[1].clone());
      else
      {
        ioArray[0].copy(vec[0]);
        ioArray[1].copy(vec[1]);
        return ioArray;
      }
    };

    /**
    * @public
    * @memberof DSMath.Plane
    * @method getNormal
    * @instance
    * @description
    * Retrieves the normal to the plane.
    * @param {DSMath.Vector3D} [oN] Reference of the operation result (avoid allocation).
    * @example
    * var pl0 = new DSMath.Plane().setOrigin(1,2,3).setVectors(1,1,0, -1,1,0);
    * var N = pl0.getNormal(); // N=(0,0,1);
    * @returns { DSMath.Vector3D } The reference of the operation result - The normal to the plane.
    */
    Plane.prototype.getNormal = function (oN)
    {
      DSMath.TypeCheck(oN, false, DSMath.Vector3D);

      var dir = this.getDirectionsNotCloned();
      oN = (oN) ? oN.copy(dir[0]) : dir[0].clone();
      oN.cross(dir[1]);
      return oN;
    };

    /**
    * @public
    * @memberof DSMath.Plane
    * @method evalPoint
    * @instance
    * @description
    * Returns the point of <i>this</i> plane corresponding to the given parameters.
    * @param {Number} iU The value along the first plane direction.
    * @param {Number} iV The value along the second plane direction.
    * @param {DSMath.Point} [oP] Reference of the operation result (avoid allocation).
    * @example
    * var pl0 = new DSMath.Plane().setOrigin(1,2,3).setVectors(1,1,0, -1,1,0);
    * var p0 = pl0.evalPoint(0,0);                    // p0=(1,2,3)
    * var p1 = pl0.evalPoint(1,0);                    // p1=(1+1/&#8730;2,2+1/&#8730;2,3);
    * var p2 = pl0.evalPoint(0,1);                    // p2=(1-1/&#8730;2,2+1/&#8730;2,3);
    * var p3 = pl0.evalPoint(Math.SQRT2, Math.SQRT2); // p3=(1,4,3);
    * @returns { DSMath.Point } The reference of the operation result - The point evaluated.
    */
    Plane.prototype.evalPoint = function (iU, iV, oP)
    {
      DSMath.TypeCheck(iU, true, 'number');
      DSMath.TypeCheck(iV, true, 'number');
      DSMath.TypeCheck(oP, false, DSMath.Point);

      var dir = this.getDirectionsNotCloned();

      oP = (oP) ? oP.copy(this.origin) : this.origin.clone();
      oP.addScaledVector(dir[0], iU).addScaledVector(dir[1], iV);

      return oP;
    };

    /**
    * @public
    * @typedef IntersectionLinePlaneData
    * @type Object
    * @property {Number} paramOnLine   The parameter on the line at the intersection.
    * @property {Number} param1OnPlane The parameter on the plane first direction at the intersection.
    * @property {Number} param2OnPlane The parameter on the plane second direction at the intersection.
    * @property {Number} diag          Equals -1 if no intersection exist, 0 if the intersection is only located at point, 1 if the line relies on the plane
    */

    /**
    * @public
    * @memberof DSMath.Plane
    * @method intersectLine
    * @description
    * Computes the intersection of a line and <i>this</i> plane.
    * @param {DSMath.Line} iL The line to be intersected with <i>this</i> plane.
    * @param {Number} [iTol=1e-13] The precision to be used for the computation (max distance error).
    * @example
    * var pl0 = new DSMath.Plane();
    * var l0 = new DSMath.Line().setOrigin(0,1,1).setDirection(1,0,-1);
    * var l1 = new DSMath.Line().setOrigin(0,1,1).setDirection(1,0,0);
    * var l2 = new DSMath.Line().setOrigin(0,0,0).setDirection(1,0,0);
    * var intl0pl0 = pl0.intersectLine(l0); // intl0pl0={paramOnLine=1,param1OnPlane=1,param2OnPlane=1,diag=0}
    * var intl1pl0 = pl0.intersectLine(l1); // intl1pl0={paramOnLine=0,param1OnPlane=0,param2OnPlane=0,diag=-1}
    * var intl2pl0 = pl0.intersectLine(l2); // intl2pl0={paramOnLine=0,param1OnPlane=0,param2OnPlane=0,diag=1}
    * @returns { IntersectionLinePlaneData } The intersection result.
    */
    Plane.prototype.intersectLine = function (iL, iTol)
    {
      DSMath.TypeCheck(iL, true, DSMath.Line);
      DSMath.TypeCheck(iTol, false, 'number');

      var result = { paramOnLine: 0, param1OnPlane: 0, param2OnPlane: 0, diag: -1 };
      iTol = iTol || DSMath.defaultTolerances.epsgForRelativeTest;

      // Retrieve information
      var dir = this.getDirectionsNotCloned();
      var dL = iL.direction;
      var dLNorm = iL.scale;

      // Needed computation
      var N = this.getNormal();
      var oPoL = iL.origin.sub(this.origin);
      var distoL = Math.abs(oPoL.dot(N));
      var cosA = dL.dot(N) / dLNorm;

      if (cosA * cosA > DSMath.defaultTolerances.epsilonForSquareRelativeTest)
      {
        result.paramOnLine = -(distoL / cosA) / dLNorm;
        result.param1OnPlane = oPoL.dot(dir[0]) + dL.dot(dir[0]) * result.paramOnLine;
        result.param2OnPlane = oPoL.dot(dir[1]) + dL.dot(dir[1]) * result.paramOnLine;
        result.diag = 0;
      }
      else
      {
        // The plane and the line are parallel
        result.diag = (distoL < iTol) ? 1  // The line relies on the plane
                                  : -1; // No intersection at the given tolerance.
      }

      return result;
    };

    /**
    * @public
    * @memberof DSMath.Plane
    * @method applyTransformation
    * @instance
    * @description
    * Transforms <i>this</i> Plane by applying a transformation on its origin and directions.
    * <br>
    * The transformation has to be inversible.
    * @param {DSMath.Transformation} iT The transformation to apply.
    * @example
    * var pl0 = new DSMath.Plane();
    * var t0 = DSMath.Transformation.makeRotation(DSMath.Vector3D.zVect, Math.PI/2).setVector(1,2,3);
    * var t1 = DSMath.Transformation.makeScaling(2, new DSMath.Point(1,1,1));
    * var pl1 = pl0.applyTransformation(t0); // pl1===pl0 and pl1.origin=(1,2,3)
    * var dirPl1 = pl1.getDirections();      // dirPl1[0]=(0,1,0) and dirPl1[1]=(-1,0,0);
    * var pl2 = pl0.applyTransformation(t1); // pl2===pl0 and pl2.origin=(1,3,5);
    * var dirPl2 = pl2.getDirections();      // dirPl2[0]=(0,1,0) and dirPl2[1]=(-1,0,0);
    * @returns {DSMath.Plane} <i>this</i> modified plane reference.
    */
    Plane.prototype.applyTransformation = function (iT)
    {
      DSMath.TypeCheck(iT, true, DSMath.Transformation);

      var dir = this.getDirectionsNotCloned();
      this.origin.applyTransformation(iT);
      dir[0].applyTransformation(iT);
      dir[1].applyTransformation(iT);

      if (!iT.matrix.isAnIsometry())
      {
        // The vectors are no longer orthonormalize ==> we make them again.
        this.setVectors(dir[0], dir[1]);
      }
      return this;
    };

    DSMath.Plane = Plane;

    return Plane;
  }
);

