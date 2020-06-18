//===================================================================
// COPYRIGHT DASSAULT SYSTEMES 2018
//===================================================================
// JavaScript ellipse object class
//===================================================================
// 01/10/18 Q48 Creation
// 20/01/19 Q48 Fix to intersectLine for tangent cases
//===================================================================

define('MathematicsES/MathEllipseJSImpl',
  ['MathematicsES/MathNameSpace',
   'MathematicsES/MathTypeCheck',
   'MathematicsES/MathTypeCheckInternal',
   'MathematicsES/MathPointJSImpl',
   'MathematicsES/MathPoint2DJSImpl',
   'MathematicsES/MathVector2DJSImpl',
   'MathematicsES/MathVector3DJSImpl',
   'MathematicsES/MathLineJSImpl',
   'MathematicsES/MathCircleJSImpl',
   'MathematicsES/MathPlaneJSImpl'
   ],
   
  function (DSMath, TypeCheck, TypeCheckInternal, Point, Point2D, Vector2D, Vector3D, Line, Circle, Plane)
  {
    'use strict';

    /**
    * @private
    * @exports Ellipse
    * @class
    * @classdesc Representation of an Ellipse in 3D.
    *
    * @constructor
    * @constructordesc
    * The DSMath.Ellipse constructor creates an ellipse in 3D, which is represented by a center, \
      two directions (defining the major / minor axes),\
      a major radius, a minor radius,\
      a shift and a scale.
    * <br>
    * The ellipse evalualation is given by:
      w(t) = t*scale + shift
      Eval(w(t)) = center + (firstAxis * majorRadius * cos(w)) + (secondAxis * minorRadius * cos(w))
    * <br>
    * The two orthonormalized vectors can only be managed with <i>this</i> class methods.
    * @param {Number}          [iR1     = 1]      The major radius of the ellipse. The radius has to be strictly positive.
    * @param {Number}          [iR2     = 1]      The minor radius of the ellipse. The radius has to be strictly positive.
    * @param {DSMath.Point}    [iC     = (0,0,0)] The ellipse center. Note the content of the point given is duplicated so <i>this</i>.center!==iC.
    * @param {DSMath.Vector3D} [iD1    = (1,0,0)] The ellipse plane support first direction. Note the content of the vector given is duplicated.
    * @param {DSMath.Vector3D} [iD2    = (0,1,0)] The ellipse plane support second direction. Note the content of the vector given is duplication.
    * @param {Number}          [iS     = 1]       The scale of the ellipse. The scale has to be different of zero.
    * @param {Number}          [iShift = 0]       The parameter shift.
    * @memberof DSMath
    */

    var Ellipse = function (iR1, iR2, iC, iD1, iD2, iScale, iShift)
    {
      DSMath.TypeCheck(iR1, false, 'number');
      DSMath.TypeCheck(iR2, false, 'number');
      DSMath.TypeCheck(iC, false, DSMath.Point);
      DSMath.TypeCheck(iD1, false, DSMath.Vector3D);
      DSMath.TypeCheck(iD2, false, DSMath.Vector3D);
      DSMath.TypeCheck(iScale, false, 'number');
      DSMath.TypeCheck(iShift, false, 'number');

      // Attributes
      // -------------------------------------

      // Public
      this.center = iC ? iC.clone() : new Point();
      this.radiusMaj = iR1 || 1.0; // Radius can not be null. If so, put if to 1.
      this.radiusMin = iR2 || 1.0; // Radius can not be null. If so, put if to 1.

      this.shift = iShift || 0.0;
      this.scale = iScale || 1.0; // The scale can not be null. If so, put it to 1.

      // Private
      var dir = new Array(2);
      dir[0] = (iD1) ? iD1.clone() : new Vector3D(1, 0, 0);
      dir[1] = (iD2) ? iD2.clone() : new Vector3D(0, 1, 0);

      if (iD1 || iD2)
        Vector3D.orthoNormalize(dir[0], dir[1]); // normalize and make dir[1] orthogonal to dir[0] in the plane

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
    * The center property of an ellipse.
    * @member
    * @instance
    * @name center
    * @private
    * @type { DSMath.Point }
    * @memberOf DSMath.Line
    */
    Ellipse.prototype.center = null;

    /**
    * The major radius property of an ellipse.
    * @member
    * @instance
    * @name radiusMaj
    * @private
    * @type { Number }
    * @memberOf DSMath.Ellipse
    */
    Ellipse.prototype.radiusMaj = null;

    /**
    * The minor radius property of an ellipse.
    * @member
    * @instance
    * @name radiusMin
    * @private
    * @type { Number }
    * @memberOf DSMath.Ellipse
    */
    Ellipse.prototype.radiusMin = null;

    /**
    * The shift property of an ellipse.
    * @member
    * @instance
    * @name shift
    * @private
    * @type { Number }
    * @memberOf DSMath.Ellipse
    */
    Ellipse.prototype.shift = null;

    /**
    * The scale property of an ellipse.
    * @member
    * @instance
    * @name scale
    * @private
    * @type { Number }
    * @memberOf DSMath.Ellipse
    */
    Ellipse.prototype.scale = null;

    // ---------------------------------------------------------------------------------
    // Private methods
    // ---------------------------------------------------------------------------------

    /** @ignore */
    // Essentially an evalUV (in support plane co-ordinates)
    Ellipse.prototype.EvalUV = function (iT)
    {
      DSMath.TypeCheckInternal(iT, true, 'number');

      var t = iT * this.scale + this.shift;

      var cosT = Math.cos(t);
      var sinT = Math.sin(t);

      var oP = new DSMath.Point2D();
      oP.x = this.radiusMaj * cosT;
      oP.y = this.radiusMin * sinT;

      return oP;
    }

    /** @ignore */
    // Essentially an eval-gradUV (in support plane co-ordinates)
    Ellipse.prototype.EvalFirstDerivUV = function (iT)
    {
      DSMath.TypeCheckInternal(iT, true, 'number');

      var t = iT * this.scale + this.shift;

      var cosT = Math.cos(t);
      var sinT = Math.sin(t);

      var oP = new DSMath.Vector2D();
      oP.x = this.radiusMaj * -sinT;
      oP.y = this.radiusMin * cosT;

      return oP;
    }

    /** @ignore */
    // Essentially an eval-gradUV (in support plane co-ordinates)
    Ellipse.prototype.EvalSecondDerivUV = function (iT)
    {
      DSMath.TypeCheckInternal(iT, true, 'number');

      var t = iT * this.scale + this.shift;

      var cosT = Math.cos(t);
      var sinT = Math.sin(t);

      var oP = new DSMath.Vector2D();
      oP.x = this.radiusMaj * -cosT;
      oP.y = this.radiusMin * -sinT;

      return oP;
    }
        
    /** @ignore */
    Ellipse.prototype.putInRange = function (iParam, iRange)
    {
      DSMath.TypeCheckInternal(iParam, true, 'number');
      DSMath.TypeCheckInternal(iRange, true, ['number'], 2);

      // Call the equivalent method on the circle
      return Circle.prototype.putInRange(iParam, iRange);
    };

    /** @ignore */
    Ellipse.prototype.IsInfinite = function ()
    {
      return true;
    }

    // ---------------------------------------------------------------------------------
    // Public methods
    // ---------------------------------------------------------------------------------

    /**
    * @private
    * @memberof DSMath.Ellipse
    * @method clone
    * @instance
    * @description
    * Clones <i>this</i> Ellipse.
    * @example
    * var e0 = new DSMath.Ellipse(2).setCenter(1,1,1).setVectors(1,1,0, -1,1,0);
    * var e1 = e0.clone(); // e1 == e0 but e1 !== e0
    * @returns {DSMath.Ellipse} The cloned ellipse.
    */
    Ellipse.prototype.clone = function ()
    {
      var oE = new Ellipse();
      return oE.copy(this);
    };

    /**
    * @private
    * @memberof DSMath.Ellipse
    * @method copy
    * @instance
    * @description
    * Copies <i>this</i> Ellipse.
    * @example
    * var e0 = new DSMath.Ellipse(3, 2).setCenter(1,1,1).setVectors(1,1,0, -1,1,0);
    * var e1 = new DSMath.Ellipse();
    * e1.copy(e0); // e1 == e0 but e1 !== e0
    * @returns {DSMath.Ellipse} <i>this</i> modified ellipse reference.
    */
    Ellipse.prototype.copy = function (iToCopy)
    {
      DSMath.TypeCheck(iToCopy, true, DSMath.Ellipse);

      this.center.copy(iToCopy.center);
      this.radiusMaj = iToCopy.radiusMaj;
      this.radiusMin = iToCopy.radiusMin;

      this.shift = iToCopy.shift;
      this.scale = iToCopy.scale;

      var dir = this.getDirectionsNotCloned();
      var dirToCopy = iToCopy.getDirectionsNotCloned();
      dir[0].copy(dirToCopy[0]);
      dir[1].copy(dirToCopy[1]);

      return this;
    };

    /**
    * @private
    * @memberof DSMath.Ellipse
    * @method setCenter
    * @instance
    * @description
    * Assigns new coordinates values to <i>this</i> ellipse center.
    * @param {Number | DSMath.Point}  iX     Value for the x coordinate of the center or the point to copy.
    * @param {Number}                 [iY=0] Value for the y coordinate of the center. Not used if iX is a Point.
    * @param {Number}                 [iZ=0] Value for the z coordinate of the center. Not used if iX is a Point.
    * @example
    * var e0 = new DSMath.Ellipse().setCenter(1,2,3); // c0.center=[1,2,3]
    * var p0 = new DSMath.Point(1,1,1);
    * e0.setCenter(p0);                               // c0.center=[1,1,1] (copy of p0).
    * p0.set(0,0,0);                                  // c0.center=[1,1,1]
    * @returns {DSMath.Ellipse} <i>this</i> modified ellipse reference.
    */
    Ellipse.prototype.setCenter = function (iX, iY, iZ)
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
    * @private
    * @memberof DSMath.Ellipse
    * @method setVectors
    * @instance
    * @description
    * Assigns new vectors to <i>this</i> plane support.
    * <br>
    * If the given vectors are not orthonormalized, the method does it if possible.
    * <br>
    * The vectors must not be colinear. Otherwise the vectors are not changed.
    * @param {DSMath.Vector3D} iV1 New value of the first vector of the plane support. Note the content of the vector given is duplicated.
    * @param {DSMath.Vector3D} iV2 New value of the second vector of the plane support. Note the content of the vector given is duplicated.
    * @example
    * var e0 = new DSMath.Ellipse(2).setCenter(1,2,3).setVectors(1,1,0, 1,0,0);
    * var dir = e0.getDirections(); // dir[0] = (1/&#8730;2,1/&#8730;2,0) and dir[1]=(-1/&#8730;2,1/&#8730;2,0)
    * @returns {DSMath.Ellipse} <i>this</i> modified ellipse reference.
    */
    Ellipse.prototype.setVectors = function (iV1, iV2)
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
    * @private
    * @memberof DSMath.Ellipse
    * @method setMajorRadius
    * @instance
    * @description
    * Assigns new major radius value.
    * @param {Number} iR The new major radius value. The radius given has to be strictly positive.
    * @example
    * var e0 = new DSMath.Ellipse().setCenter(1,2,3).setVectors(1,1,0, -1,0,0).setMajorRadius(2); // e0.radiusMaj = 2
    * var e1 = e0.setMajorRadius(3); // e1 === e0 and e1.radiusMaj = 3;
    * @returns {DSMath.Ellipse} <i>this</i> modified ellipse reference.
    */
    Ellipse.prototype.setMajorRadius = function (iR)
    {
      DSMath.TypeCheck(iR, false, 'number');

      if (iR)
        this.radiusMaj = iR;

      return this;
    };

    /**
    * @private
    * @memberof DSMath.Ellipse
    * @method setMinorRadius
    * @instance
    * @description
    * Assigns new minor radius value.
    * @param {Number} iR The new minor radius value. The radius given has to be strictly positive.
    * @example
    * var e0 = new DSMath.Ellipse().setCenter(1,2,3).setVectors(1,1,0, -1,0,0).setMinorRadius(2); // e0.radiusMin = 2
    * var e1 = e0.setMinorRadius(3); // e1 === e0 and e1.radiusMin = 3;
    * @returns {DSMath.Ellipse} <i>this</i> modified ellipse reference.
    */
    Ellipse.prototype.setMinorRadius = function (iR)
    {
      DSMath.TypeCheck(iR, false, 'number');

      if (iR)
        this.radiusMin = iR;

      return this;
    };

    /**
    * @private
    * @memberof DSMath.Ellipse
    * @method setRadii
    * @instance
    * @description
    * Assigns new major and minor radius values.
    * @param {Number} iRMaj The new major radius value. The radius given has to be strictly positive.
    * @param {Number} iRMin The new minor radius value. The radius given has to be strictly positive.
    * @example
    * var e0 = new DSMath.Ellipse().setCenter(1,2,3).setVectors(1,1,0, -1,0,0).setRadii(2, 2); // e0.radiusMaj = 2
    * var e1 = e0.setRadii(3, 2); // e1 === e0 and e1.radiusMaj = 3;
    * @returns {DSMath.Ellipse} <i>this</i> modified ellipse reference.
    */
    Ellipse.prototype.setRadii = function (iRMaj, iRMin)
    {
      DSMath.TypeCheck(iRMaj, false, 'number');
      DSMath.TypeCheck(iRMin, false, 'number');

      this.setMajorRadius(iRMaj);
      this.setMinorRadius(iRMin);

      return this;
    };

    /**
    * @private
    * @memberof DSMath.Ellipse
    * @method setScale
    * @instance
    * @description
    * Assigns new scale value.
    * @param {Number} [iS=1] The new scale value. The scale has to be different of zero.
    * @example
    * var e0 = new DSMath.Ellipse().setCenter(1,2,3).setVectors(1,1,0, -1,0,0).setScale(2); // e0.scale = 2
    * var e1 = e0.setScale(3); // e1 === e0 and e1.scale = 3;
    * @returns {DSMath.Ellipse} <i>this</i> modified ellipse reference.
    */
    Ellipse.prototype.setScale = function (iS)
    {
      DSMath.TypeCheck(iS, false, 'number');

      this.scale = iS || 1;
      return this;
    };

    /**
    * @private
    * @memberof DSMath.Ellipse
    * @method setShift
    * @instance
    * @description
    * Assigns new shift value.
    * @param {Number} [iS=1] The new shift value.
    * @example
    * var e0 = new DSMath.Ellipse().setCenter(1,2,3).setVectors(1,1,0, -1,0,0).setShift(2); // e0.shift = 2
    * var e1 = e0.setShift(3); // e1 === e0 and e1.shift = 3;
    * @returns {DSMath.Ellipse} <i>this</i> modified ellipse reference.
    */
    Ellipse.prototype.setShift = function (iShift)
    {
      DSMath.TypeCheck(iShift, false, 'number');

      this.shift = iShift || 0;
      return this;
    };

    /**
    * @private
    * @memberof DSMath.Ellipse
    * @method getDirections
    * @instance
    * @description
    * Retrieves a copy of the ellipse plane support directions.
    * @param {DSMath.Vector3D[]} [oA] Reference of the operation result (avoid allocation).
    * @example
    * var e0 = new DSMath.Ellipse(2).setCenter(1,2,3).setVectors(1,1,0, -1,1,0);
    * var dir = e0.getDirections(); // dir[0]=(1/&#8730;2,1/&#8730;2,0), dir[1]=(-1/&#8730;2,1/&#8730;2,0)
    * @returns {DSMath.Vector3D[]} Reference of the operation result - The array of orthonormalized direction ([first direction, second direction]).
    */
    Ellipse.prototype.getDirections = function (ioArray)
    {
      DSMath.TypeCheck(ioArray, false, [DSMath.Vector3D], 2);

      return Plane.prototype.getDirections.apply(this, arguments);
    };

    /**
    * @private
    * @memberof DSMath.Ellipse
    * @method evalPoint
    * @instance
    * @description
    * Returns the point of <i>this</i> ellipse corresponding to the given parameters.
    * @param {Number}        iT  The ellipse parameter. The evaluation made is : center + (firstAxis * majorRadius * cos(iT*scale + shift)) + (secondAxis * minorRadius * cos(iT*scale + shift))
    * @example
    * var e0 = new DSMath.Ellipse().setRadii(2, 1).setVectors(1,0,0, 0,1,0).setCenter(1,2,3);
    * var p0 = e0.evalPoint(0);         // p0 = ( 3, 2, 3)
    * var p1 = e0.evalPoint(Math.PI/2); // p1 = ( 1, 3, 3)
    * var p2 = e0.evalPoint(Math.PI);   // p2 = (-1, 2, 3)
    * @returns { DSMath.Point } The reference of the operation result - The point evaluated.
    */
    Ellipse.prototype.evalPoint = function (iT)
    {
      DSMath.TypeCheck(iT, true, ['number', DSMath.Point2D]);

      var ptUV = (iT.constructor === Point2D) ? iT : this.EvalUV(iT);

      var dir = this.getDirectionsNotCloned();

      var pointEval = new DSMath.Point();
      pointEval.x = this.center.x + (ptUV.x * dir[0].x) + (ptUV.y * dir[1].x);
      pointEval.y = this.center.y + (ptUV.x * dir[0].y) + (ptUV.y * dir[1].y);
      pointEval.z = this.center.z + (ptUV.x * dir[0].z) + (ptUV.y * dir[1].z);
      return pointEval;
    };

    /**
    * @private
    * @memberof DSMath.Ellipse
    * @method evalFirstDeriv
    * @instance
    * @description
    * Returns the derivative of <i>this</i> ellipse corresponding to the given parameter.
    * @param {Number}  iT The ellipse parameter
    * @example
    * var e0 = new DSMath.Ellipse().setRadii(2, 1).setVectors(1,0,0, 0,1,0).setCenter(1,2,3);
    * var v0 = e0.evalFirstDeriv(0);         // v0 = (  0,  1, 0)
    * var v1 = e0.evalFirstDeriv(Math.PI/2); // v1 = ( -2,  0, 0)
    * var v2 = e0.evalFirstDeriv(Math.PI);   // v2 = (  0, -1, 0)
    * @returns { DSMath.Vector3D } The reference of the operation result - the gradient evaluated.
    */
    Ellipse.prototype.evalFirstDeriv = function (iT)
    {
      DSMath.TypeCheck(iT, true, ['number', DSMath.Vector2D]);

      var dirUV = (iT.constructor === Vector2D) ? iT : this.EvalFirstDerivUV(iT);

      var dir = this.getDirectionsNotCloned();

      var oDeriv = new DSMath.Vector3D();
      oDeriv.x = (dirUV.x * dir[0].x) + (dirUV.y * dir[1].x);
      oDeriv.y = (dirUV.x * dir[0].y) + (dirUV.y * dir[1].y);
      oDeriv.z = (dirUV.x * dir[0].z) + (dirUV.y * dir[1].z);
      return oDeriv;
    }

    /**
    * @private
    * @memberof DSMath.Ellipse
    * @method evalSecondDeriv
    * @instance
    * @description
    * Returns the second derivative of <i>this</i> ellipse corresponding to the given parameter.
    * @param {Number}  iT the ellipse parameter.
    * @example
    * var e0 = new DSMath.Ellipse().setRadii(2, 1).setVectors(1,0,0, 0,1,0).setCenter(1,2,3);
    * var v0 = e0.evalSecondDeriv(0);         // v0 = (  0,  1, 0)
    * var v1 = e0.evalSecondDeriv(Math.PI/2); // v1 = ( -2,  0, 0)
    * var v2 = e0.evalSecondDeriv(Math.PI);   // v2 = (  0, -1, 0)
    * @returns { DSMath.Vector3D } The reference of the operation result - the second derivative evaluated.
    */
    Ellipse.prototype.evalSecondDeriv = function (iT)
    {
      DSMath.TypeCheck(iT, true, ['number', DSMath.Vector2D]);

      var dirUV = (iT.constructor === Vector2D) ? iT : this.EvalSecondDerivUV(iT);

      var dir = this.getDirectionsNotCloned();

      var oSecondDeriv = new DSMath.Vector3D();
      oSecondDeriv.x = (dirUV.x * dir[0].x) + (dirUV.y * dir[1].x);
      oSecondDeriv.y = (dirUV.x * dir[0].y) + (dirUV.y * dir[1].y);
      oSecondDeriv.z = (dirUV.x * dir[0].z) + (dirUV.y * dir[1].z);
      return oSecondDeriv;
    }
    /**
    * @private
    * @memberof DSMath.Ellipse
    * @method eval
    * @instance
    * @description
    * Compute the 3D point and the 2D coordinates corresponding to the given parameters.
    * @param {Number}           iT       The ellipse parameter.
    * @param {DSMath.Point}    [oPoint]  The 3D point evaluated. It has to be allocated by the caller or the computation will not be done.
    * @param {DSMath.Vector2D} [oVect2D] The 2D coordinates on the ellipse plane support. It has to be allocated by the caller or the computation will not be done.
    * @example
    * var e0 = new DSMath.Ellipse().setRadii(2, 1).setVectors(1,0,0, 0,1,0).setCenter(1,2,3);
    * var v0 = new DSMath.Vector2D();
    * var p0 = new DSMath.Point();
    * e0.eval(Math.PI/2, null, v0); // v0 = ( 0, 1)
    * e0.eval(Math.PI/2, p0);       // p0 = ( 1, 3, 3)
    * e0.eval(Math.PI, p0, v0);     // p0 = (-1, 2, 3) and v0 = (-2, 0)
    */
    Ellipse.prototype.eval = function (iParam, oPoint, oVect2D)
    {
      DSMath.TypeCheck(iParam, true, 'number');
      DSMath.TypeCheck(oPoint, false, DSMath.Point);
      DSMath.TypeCheck(oVect2D, false, DSMath.Vector2D);

      var ptUV = this.EvalUV(iParam);

      if (oVect2D)
        oVect2D.set(ptUV.x, ptUV.y);

      if (oPoint)
        oPoint.copy(this.evalPoint(ptUV));
    };

    /**
    * @private
    * @memberof DSMath.Ellipse
    * @method applyTransformation
    * @instance
    * @description
    * Transforms <i>this</i> Ellipse by applying a transformation on its origin and directions.
    * <br> The transformation has to be reversible and the transformation matrix vectors should be orthogonal.
    * Otherwise, the transformation result is not an ellipse. In such case <i>this</i> ellipse is not changed.
    * <br>
    * If the transformation performs a scaling, the ellipse radii are multiplied by the scales.
    * @param {DSMath.Transformation} iT The transformation to apply.
    * @example
    * var t0 = DSMath.Transformation.makeRotation(DSMath.Vector3D.zVect, Math.PI/2, new DSMath.Point(1,1,1));
    * var e0 = new DSMath.Ellipse(2, 1).setCenter(1,2,3).setVectors(1,0,0, 0,1,0);
    * var e1 = e0.applyTransformation(t0);         // e0 === e1 and e1.center = (0,1,3)
    * var dir = e1.getDirections();                // dir[0] = (0,1,0) and dir[1] = (-1,0,0)
    * var t1 = t0.multiplyByScaling(2, e1.center); // We compose t0 with a scaling at the ellipse center --> now scaling and rotation
    * var e2 = e0.applyTransformation(t1);         // e2 === e0 and e2.center = (1,0,3), e2.radiusMaj = 4, e2.radiusMin = 2
    * dir = e2.getDirections();                    // dir[0] = (-1,0,0) and dir[1] = (0,-1,0)
    * @returns {DSMath.Ellipse} <i>this</i> modified ellipse reference.
    */
    Ellipse.prototype.applyTransformation = function (iT)
    {
      DSMath.TypeCheck(iT, true, DSMath.Transformation);

      if (iT.matrix.isOrthogonal())
      {
        var dir = this.getDirectionsNotCloned();
        this.center.applyTransformation(iT);

        dir[0].applyTransformation(iT);
        dir[1].applyTransformation(iT);

        var norm0 = dir[0].norm();
        var norm1 = dir[1].norm();

        dir[0].normalize();
        dir[1].normalize();

        this.radiusMaj *= norm0;
        this.radiusMin *= norm1;
      }

      return this;
    };

    /**
    * @private
    * @memberof DSMath.Ellipse
    * @method getParam
    * @instance
    * @description
    * Returns the parameter(s) on <i>this</i> ellipse corresponding to a point in 3D, in the parameters limits given.
    * @param { DSMath.Point } iPoint       The 3D Point.
    * @param { Number }       iStartParam  The lowest ellipse parameters on which we can find a solution.
    * @param { Number }       iEndParam    The highest ellipse parameters on which we can find a solution.
    * @param { Number }       [iTol=1e-13] The max 3D distance between the solution and the point given.
    * @example
    * var e0 = new DSMath.Ellipse(2*Math.SQRT2, Math.SQRT2).setCenter(1,1,1).setVectors(1,1,0, -1,1,0);
    * var p0 = new DSMath.Point(0,2,1);
    * var t0 = e0.getParam(p0, 0, Math.PI  , 0.001);   // t0.length=1 and t0[0]=Math.PI/2
    * @returns { Number[] } An array containing 0, 1 or 2 parameters that can be evaluated on the point.
    * <br>
    * Two parameters are return if the solution is on the ellipse closure.
    */
    Ellipse.prototype.getParam = function (iPoint, iStartParam, iEndParam, iTol)
    {
      DSMath.TypeCheck(iPoint, true, DSMath.Point);
      DSMath.TypeCheck(iStartParam, true, 'number');
      DSMath.TypeCheck(iEndParam, true, 'number');
      DSMath.TypeCheck(iTol, false, 'number');

      var paramSol = [];
      var dir = this.getDirectionsNotCloned();

      // Local UV projection
      // -------------------

      var localVec = iPoint.sub(this.center);

      var U = dir[0].dot(localVec);
      var V = dir[1].dot(localVec);

      // Check the projected point
      // -------------------------

      var localPoint = new DSMath.Point2D(U, V);

      var projPoint = this.evalPoint(localPoint);

      var dist = projPoint.distanceTo(iPoint);

      if (dist > iTol) // closest point is too far --> no solution
        return paramSol;

      // Check start point
      // -----------------

      var startPt = this.evalPoint(iStartParam);
      var distStartPt = startPt.distanceTo(iPoint);
      if (distStartPt <= iTol)
        paramSol.push(iStartParam);

      // Check end point
      // ---------------

      var endPt = this.evalPoint(iEndParam);
      var distEndPt = endPt.distanceTo(iPoint);
      if (distEndPt <= iTol)
        paramSol.push(iEndParam);

      // Check interior points
      // ---------------------

      if (paramSol.length == 0)
      {
        var angle = Math.atan2(V / this.radiusMin, U / this.radiusMaj);
        var param = (angle - this.shift) * 1.0 / this.scale;

        while (param < iStartParam)
          param += Math.PI * 2;

        while (param > iEndParam)
          param -= Math.PI * 2;

        if (param >= iStartParam && param <= iEndParam)
          paramSol.push(param);
      }


      return paramSol;
    };

    /**
    * @private
    * @memberof DSMath.Ellipse
    * @method arcLength
    * @instance
    * @description
    * Returns the arc length on <i>this</i> ellipse in the range given.
    * @param { Number }       iStartParam  The lowest ellipse parameters on which we can find a solution.
    * @param { Number }       iEndParam    The highest ellipse parameters on which we can find a solution.
    * @example
    * var e0 = new DSMath.Ellipse(2, 1).setCenter(1,1,1).setVectors(1,0,0, 0,1,0);
    * var t0 = e0.arcLength(0, Math.PI);
    * @returns { Number } The arc length of the ellipse
    * <br>
    */
    Ellipse.prototype.arcLength = function (iStartParam, iEndParam)
    {
      DSMath.TypeCheck(iStartParam, true, 'number');
      DSMath.TypeCheck(iEndParam, true, 'number');

      var oArcLength = 0.0;

      var iStartAngle = (iStartParam - this.shift) / this.scale;
      var iEndAngle = (iEndParam - this.shift) / this.scale;

      var angleStepSize = Math.PI / 500; // Q48 - to decide how to choose this!
      //var angleStepSize = Math.PI / 10; // Q48 - to decide how to choose this!

      var nSteps = Math.ceil((iEndAngle - iStartAngle) / angleStepSize);

      angleStepSize = (iEndAngle - iStartAngle) / nSteps;

      var currAngle = iStartAngle + (angleStepSize / 2.0);

      for (var iStep = 0; iStep <= nSteps; iStep++)
      {
        var currD = Math.sqrt(Math.pow(this.radiusMaj * Math.cos(currAngle), 2) + Math.pow(this.radiusMin * Math.sin(currAngle), 2));

        if (iStep == 0 || iStep == nSteps)
          currD *= 0.5;

        oArcLength += currD * angleStepSize;

        currAngle += angleStepSize;
      }

      return oArcLength;
    };

    /**
    * @private
    * @typedef IntersectionLineEllipseData
    * @type Object
    * @property {Number} paramEllipse The parameter on the line at the intersection.
    * @property {Number} paramLine    The parameter on the ellipse first at the intersection.
    */

    /**
    * @private
    * @memberof DSMath.Ellipse
    * @method intersectLine
    * @instance
    * @description
    * Intersects a portion of <i>this</i> ellipse with a portion of the specified line.
    * @param {DSMath.Line} iLine         The line.
    * @param {Number}      iStartLine    Start parameter defining the segment of the specified line to be intersected.
    * @param {Number}      iEndLine      End parameter defining the segment of specified line to be intersected.
    * @param {Number}      iStartEllipse Start parameter defining the segment of <i>this</i> ellipse to be intersected.
    * @param {Number}      iEndEllipse   End parameter defining the segment of <i>this</i> ellipse to be intersected.
    * @param {Number}      iTol          The precision to be used for the computation.
    * @return {IntersectionLineEllipseData[]} The intersection result. The length of the array is the number of solution.
    * @example
    * var l0 = new DSMath.Line();
    * var e0 = new DSMath.Ellipse();
    * var intersectParams = e0.intersectLine(l0, -2, 2, 0, (2*Math.PI), 0.000001);
    * // intersectParams.length = 3,
    * // intersectParams[0] = {paramEllipse =   0, paramLine =  1}
    * // intersectParams[1] = {paramEllipse =  PI, paramLine = -1}
    * // intersectParams[2] = {paramEllipse = 2PI, paramLine =  1}
    */
    Ellipse.prototype.intersectLine = function (iLine, iStartLine, iEndLine, iStartEllipse, iEndEllipse, iTol)
    {
      DSMath.TypeCheck(iLine, true, DSMath.Line);
      DSMath.TypeCheck(iStartLine, true, 'number');
      DSMath.TypeCheck(iEndLine, true, 'number');
      DSMath.TypeCheck(iStartEllipse, true, 'number');
      DSMath.TypeCheck(iEndEllipse, true, 'number');
      DSMath.TypeCheck(iTol, true, 'number');

      // Output variable
      // ---------------

      var sol = [];

      // Local data
      // ----------

      var dir = this.getDirections();

      // Intersect line and ellipse support plane
      // ----------------------------------------

      var supportPlane = new DSMath.Plane();
      supportPlane.setOrigin(this.center);
      supportPlane.setVectors(dir[0], dir[1]);

      var planeIntersect = supportPlane.intersectLine(iLine, iTol);

      // No line / plane intersection
      // ----------------------------

      if (planeIntersect.diag == -1)
        return sol;

      // Single line / plane intersection
      // --------------------------------

      if (planeIntersect.diag == 0)
      {
        var intersection3D = iLine.evalPoint(planeIntersect.paramOnLine);

        var parMin = this.shift;
        var parMax = DSMath.PI2 * this.scale + this.shift;

        var paramOnEllipse = this.getParam(intersection3D, parMin, parMax, iTol);
        if (paramOnEllipse.length == 1)
          sol[0] = { paramEllipse: paramOnEllipse, paramLine: planeIntersect.paramOnLine };

        return sol;
      }

      // Line is in the plane
      // --------------------

      var deltaO = this.center.sub(iLine.origin);

      var lineNorm = Vector3D.cross(iLine.direction, supportPlane.getNormal());

      // eq(1): Line    = LineOri + t1 * LineDir
      // eq(2): Ellipse = EllipseOri + (rMaj * AxisMaj * cos(t2)) + (rMin * AxisMin * sin(t2))

      // Solve eq(1) = eq(2)
      //      Define LineNorm = ellipse-plane-normal ^ lineDir
      //      --> eq(1) * LineNorm = eq(2) * LineNorm
      //      --> (LineOri - EllipseOri) * LineNorm = [(rMaj * AxisMaj * cos(b)) + (rMin * AxisMin * sin(b))] * LineNorm
      //            (note: LineDir * LineNorm = 0)

      //      Define A = (rMaj * AxisMaj) * LineNorm
      //      Define B = (rMin * AxisMaj) * LineNorm
      //      Define C = (LineOri - EllipseOri) * LineNorm
      //        --> C = A*cos(t2) + B*cos(t2)
      //        --> C = D * cos(t2 + phi)


      var A = this.radiusMaj * (dir[0].dot(lineNorm));
      var B = this.radiusMin * (dir[1].dot(lineNorm));
      var C = deltaO.dot(lineNorm);

      var D = Math.sqrt((A * A) + (B * B));

      if (Math.abs(C) > Math.abs(D) + iTol)
        return sol; // no solutions

      var cosAngle = -C / D;
      if (Math.abs(cosAngle) > 1) // force to one solution
        cosAngle = Math.sign(cosAngle);

      var angle = Math.acos(cosAngle);

      //var angleOffset = Math.acos(A / D);
      var angleOffset = Math.atan2(B / D, A / D);

      var angleIntersect = [angleOffset - angle];
      if (angle > 0)
        angleIntersect[1] = angleOffset + angle;

      var iStartAngle = (iStartEllipse * this.scale) + this.shift;
      var iEndAngle = (iEndEllipse * this.scale) + this.shift;

      var startJ = Math.floor(iStartAngle / DSMath.constants.PI2) - 1;
      var endJ = Math.ceil(iEndAngle / DSMath.constants.PI2) + 1;

      //var nTwoPi = (iEndAngle - iStartAngle) / DSMath.constants.PI2;

      var nSol = 0;

      for (var j = startJ; j < endJ; j++)
      {
        for (var i = 0; i < angleIntersect.length; i++)
        {
          var currentAngle = angleIntersect[i] + (j * DSMath.constants.PI2);

          var paramOnEllipse = (currentAngle - this.shift) / this.scale;

          // Take care of potential admissible solution
          // ------------------------------------------

          if (paramOnEllipse < iStartEllipse && paramOnEllipse >= iStartEllipse - iTol)
            paramOnEllipse = iStartEllipse;
          else if (paramOnEllipse > iEndEllipse && paramOnEllipse <= iEndEllipse + iTol)
            paramOnEllipse = iEndEllipse;

          if (paramOnEllipse >= iStartEllipse && paramOnEllipse <= iEndEllipse)
          {
            var pt3D = this.evalPoint(paramOnEllipse);
            var paramOnLine = iLine.getParam(pt3D, iStartLine, iEndLine, iTol);

            if (paramOnLine.length == 1)
            {
              var addSol = true;

              for (var iSol = 0; iSol < nSol && addSol === true; iSol++)
              {
                if (Math.abs(paramOnEllipse - sol[iSol].paramEllipse) < iTol &&
                    Math.abs(paramOnLine[0] - sol[iSol].paramLine) < iTol)
                {
                  addSol = false;
                }
              }

              if (addSol === true)
              {
                sol[nSol] = { paramEllipse: paramOnEllipse, paramLine: paramOnLine[0] };
                nSol++;
              }
            }
          }
        }
      }

      return sol;
    };

    DSMath.Ellipse = Ellipse;

    return Ellipse;
  }
);
