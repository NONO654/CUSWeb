define('MathematicsES/MathLine2DJSImpl', 
  ['MathematicsES/MathNameSpace'     ,
   'MathematicsES/MathTypeCheck',
   'MathematicsES/MathTypeCheckInternal',
   'MathematicsES/MathPoint2DJSImpl' ,
   'MathematicsES/MathVector2DJSImpl'
   ],
    
  function (DSMath, TypeCheck, TypeCheckInternal, Point2D, Vector2D) 
  {
    'use strict';

/**
* @public
* @exports Line2D
* @class
* @classdesc Representation of a Line2D in 2D.
*
* @constructor
* @constructordesc
* The DSMath.Line2D constructor creates a Line2D in 2D, which is represented by an origin and a direction. The direction norm is the scale of the Line2D (scale=parametrization distortion).
* @param {DSMath.Point2D}  [iO=(0,0)] The Line2D origin. Note the content of the Point2D given is duplicated so <i>this</i>.origin!==iO.
* @param {DSMath.Vector2D} [iD=(1,0)] The Line2D direction. Note the content of the vector given is duplicated so <i>this</i>.direction!==iD. No normalization is performed since its norm describes the Line2D scale.
* @memberof DSMath
*/
var Line2D = function (iO, iD)
{
  DSMath.TypeCheck(iO, false, DSMath.Point2D);
  DSMath.TypeCheck(iD, false, DSMath.Vector2D);

  this.origin = (iO) ? iO.clone() : new Point2D(0, 0);
  this.direction = (iD) ? iD.clone() : new Vector2D(1, 0);
};

/**
* The origin property of a Line2D.
* @member
* @instance
* @name origin
* @public
* @type { DSMath.Point2D }
* @memberOf DSMath.Line2D
*/
Line2D.prototype.origin = null;

/**
* The direction property of a Line2D.
* @member
* @instance
* @name direction
* @public
* @type { DSMath.Vector2D }
* @memberOf DSMath.Line2D
*/
Line2D.prototype.direction = null;

/**
 * The scale property of a Line2D.
 * @member
 * @instance
 * @name scale
 * @public
 * @type { Number }
 * @memberOf DSMath.Line2D
*/
Object.defineProperty(Line2D.prototype, "scale", {
   enumerable: true,
   configurable: true,
   get: function () {
      return this.getScale();
   },
   set: function (l) {
      return this.setScale(l);
   }
});

/**
* @public
* @memberof DSMath.Line2D
* @method clone
* @instance
* @description
* Clones <i>this</i> Line2D.
* @example
* var l0 = new DSMath.Line2D().set(1,2,Math.SQRT1_2, Math.SQRT1_2);
* var l1 = l0.clone(); // l1==l0 but l1!==l0.
* @returns {DSMath.Line2D} The cloned Line2D.
*/
Line2D.prototype.clone = function ()
{
  var l_out = new Line2D();
  return l_out.copy(this);
};

/**
* @public
* @memberof DSMath.Line2D
* @method copy
* @instance
* @description
* Copies <i>this</i> Line2D.
* @param {DSMath.Line2D} iL The Line2D to copy.
* @example
* var l0 = new DSMath.Line2D().set(1,2,Math.SQRT1_2, Math.SQRT1_2);
* var l1 = new DSMath.Line2D();
* l1.copy(l0); // l1==l0 but l1!==l0;
* @returns {DSMath.Line2D} <i>this</i> modified Line2D reference.
*/
Line2D.prototype.copy = function (iToCopy)
{
  DSMath.TypeCheck(iToCopy, true, DSMath.Line2D);

   this.origin.copy(iToCopy.origin);
   this.direction.copy(iToCopy.direction);
   return this;
};

/**
* @public
* @memberof DSMath.Line2D
* @method set
* @instance
* @description
* Assigns new coordinate the <i>this</i> Line2D origin and direction.
* @param {Number} [iOx=0] The new x origin coordinate
* @param {Number} [iOy=0] The new y origin coordinate
* @param {Number} [iDx=0] The new x direction coordinate
* @param {Number} [iDy=0] The new y direction coordinate
* @example
* var l0 = new DSMath.Line2D().set(1,2,Math.SQRT1_2, Math.SQRT1_2);
* // l0.origin = [1,2]
* // l0.direction = [1/&#8730;2,1/&#8730;2]
* @returns {DSMath.Line2D}  <i>this</i> modified Line2D reference.
*/
Line2D.prototype.set = function(iOx, iOy, iDx, iDy)
{
  DSMath.TypeCheck(iOx, false, 'number');
  DSMath.TypeCheck(iOy, false, 'number');
  DSMath.TypeCheck(iDx, false, 'number');
  DSMath.TypeCheck(iDy, false, 'number');

  this.origin.set(iOx || 0, iOy || 0);
  this.direction.set(iDx || 0, iDy || 0);
  return this;
};

/**
* @public
* @memberof DSMath.Line2D
* @method setOrigin
* @instance
* @description
* Assigns new coordinates values to <i>this</i> Line2D origin.
* @param {Number | DSMath.Point2D}  iX     Value for the x coordinate or the Point2D to copy.
* @param {Number}                   [iY=0] Value for the y coordinate. Not used if iX is a Point2D.
* @param {Number}                   [iZ=0] Value for the z coordinate. Not used if iX is a Point2D.
* @example
* var l0 = new DSMath.Line2D().setOrigin(1,2); // l0.origin=[1,2]
* var p0 = new DSMath.Point2D(1,1);
* l0.setOrigin(p0);                           // l0.origin=[1,1] (copy of p0).
* p0.set(0,0);                                // l0.origin=[1,1]
* @returns {DSMath.Line2D} <i>this</i> modified Line2D reference.
*/
Line2D.prototype.setOrigin = function (iX, iY, iZ)
{
  DSMath.TypeCheck(iX, true, ['number', DSMath.Point2D]);
  DSMath.TypeCheck(iY, false, 'number');
  DSMath.TypeCheck(iZ, false, 'number');

  if (iX.constructor === Point2D)
    this.origin.copy(iX);
  else
    this.origin.set(iX, iY || 0, iZ || 0);
  return this;
};

/**
* @public
* @memberof DSMath.Line2D
* @method setDirection
* @instance
* @description
* Assigns new coordinates values to <i>this</i> Line2D direction.
* @param {Number | DSMath.Vector2D}  iX     Value for the x coordinate or the vector to copy.
* @param {Number}                    [iY=0] Value for the y coordinate. Not used if iX is a Vector2D.
* @param {Number}                    [iZ=0] Value for the z coordinate. Not used if iX is a Vector2D.
* @example
* var l0 = new DSMath.Line2D().setDirection(1,2); // l0.direction=[1,2]
* var v0 = new DSMath.Vector2D(1,1);
* l0.setDirection(v0);                           // l0.direction=[1,1] (copy of v0).
* v0.set(1,0);                                   // l0.direction=[1,1]
* @returns {DSMath.Line2D} <i>this</i> modified Line2D reference.
*/
Line2D.prototype.setDirection = function(iX, iY, iZ)
{
  DSMath.TypeCheck(iX, true, ['number', DSMath.Vector2D]);
  DSMath.TypeCheck(iY, false, 'number');
  DSMath.TypeCheck(iZ, false, 'number');

  if (iX.constructor === Vector2D)
    this.direction.copy(iX);
  else
    this.direction.set(iX, iY || 0, iZ || 0);
  return this;
};

/**
* @private
* @memberof DSMath.Line2D
* @method setScale
* @instance
* @description
* Assigns a new scale to the Line2D.
* @param {Number} iS The new scale. It should not equal 0.
* @example
* var l0 = new DSMath.Line2D().set(1,1,1,1);
* var l1 = l0.setScale(1); // l1===l0 and l1.direction=(1/&#8731;2,1/&#8731;2).
* @returns {DSMath.Line2D}  <i>this</i> modified Line2D reference.
*/
Line2D.prototype.setScale = function (s)
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
* @memberof DSMath.Line2D
* @method getScale
* @instance
* @description
* Rerieves the Line2D scale.
* @example
* var l0 = new DSMath.Line2D().set(1,2,3,4);
* var l0Scale = l0.getScale(); // =5
* @returns {Number} The scale.
*/
Line2D.prototype.getScale = function ()
{
   var vect = this.direction;
   return (vect.norm());
};

/**
* @private
* @memberof DSMath.Line2D
* @method evalPoint
* @instance
* @description
* Returns the Point2D of <i>this</i> Line2D corresponding to a given parameter.
* @param {Number}         iT   The parameter.
* @param {DSMath.Point2D} [oP] Reference of the operation result (avoid allocation).
* @example
* var l0   = new DSMath.Line2D().set(1,2, Math.SQRT1_2, Math.SQRT1_2);
* var l0p0 = l0.evalPoint(0); // p0==l0.origin;
* var l0p1 = l0.evalPoint(1); // p1=(1+1/&#8730;2, 2+1/&#8730;2)
* var l0pt = l0.evalPoint(Math.SQRT2); // pt=(2,3);
* var l1   = new DSMath.Line2D().set(1,2,3,4);
* var l1p0 = l1.evalPoint(0); // l1p0=(1,2);
* var l1p1 = l1.evalPoint(1); // l1p1=(4,6);
* @returns {DSMath.Point2D} The reference of the operation result.
*/
Line2D.prototype.evalPoint = function (iT, oP)
{
  DSMath.TypeCheck(iT, true, 'number');
  DSMath.TypeCheck(oP, false, DSMath.Point2D);

  oP = (oP) ? op.copy(this.origin) : this.origin.clone();
  return oP.addScaledVector(this.direction, iT);
};

/**
* @public
* @memberof DSMath.Line2D
* @method squareDistanceToPoint
* @instance
* @description
* Returns the square distance between <i>this</i> Line2D and the given Point2D.
* @param {DSMath.Point2D} iP The Point2D.
* @example
* var p0 = new DSMath.Point2D(-Math.SQRT2, Math.SQRT2);
* var l0 = new DSMath.Line2D().setDirection(Math.SQRT1_2, Math.SQRT1_2);
* var sqDist = l0.squareDistanceToPoint(p0); // sqDist=4;
* @return {Number} The square distance between <i>this</i> Line2D and the Point2D given.
*/
Line2D.prototype.squareDistanceToPoint = function (iP)
{
  DSMath.TypeCheck(iP, true, DSMath.Point2D);

  var firstAxis = this.direction
  var ori = this.origin;
  var oriToPt = ori.sub(iP);
  var crossPrd = oriToPt.cross(firstAxis);

  return (crossPrd * crossPrd) / firstAxis.squareNorm();
};

/**
* @public
* @memberof DSMath.Line2D
* @method distanceToPoint
* @instance
* @description
* Returns the distance between <i>this</i> Line2D and the given Point2D.
* @param {DSMath.Point2D} iP The Point2D.
* @example
* var p0 = new DSMath.Point2D(-Math.SQRT2, Math.SQRT2);
* var l0 = new DSMath.Line2D().setDirection(Math.SQRT1_2, Math.SQRT1_2);
* var dist = l0.distanceToPoint(p0); // dist=2;
* @return {Number} The distance between <i>this</i> Line2D and the Point2D given.
*/
Line2D.prototype.distanceToPoint = function (iP)
{
  DSMath.TypeCheck(iP, true, DSMath.Point2D);

  return Math.sqrt(this.squareDistanceToPoint(iP));
};

/**
* @public
* @memberof DSMath.Line2D
* @method getParam
* @instance
* @description
* Returns the parameter(s) on <i>this</i> line corresponding to a point in 2D, in the parameters limits given.
* @param { DSMath.Point2D } iPoint       The 2D Point.
* @param { Number }         iStartParam  The lowest line parameters on which we can find a solution.
* @param { Number }         iEndParam    The highest line parameters on which we can find a solution.
* @param { Number }         [iTol=1e-13] The max 2D distance between the solution and the point given.
* @example
* var eps  = DSMath.defaultTolerances.epsgForRelativeTest;
* var l0   = new DSMath.Line2D().setDirection(1,1);
* var dEps = new DSMath.Vector2D(-eps*Math.SQRT1_2,eps*Math.SQRT1_2);
* var p0 = new DSMath.Point2D(Math.SQRT1_2, Math.SQRT1_2);
* var p1 = new DSMath.Point2D(1,1);
* var p2 = p1.clone().addScaledVector(dEps,0.99);
* var p3 = p1.clone().addScaledVector(dEps,1.1);
* var t0 = l0.getParam(p0, 0, 1, eps); // t0.length=1 and t0[0]=Math.SQRT1_2
* var t1 = l0.getParam(p1, 0, 1, eps); // t1.length=1 and t1[0]=1
* var t2 = l0.getParam(p2, 0, 1, eps); // t2.length=1 and t2[0]=1. The error made here is under the tolerance given.
* var t3 = l0.getParam(p3, 0, 1, eps); // t3.length=0. The point is too far from the line (dist>eps)
* @returns { Number[] } An array containing 0 or 1 parameter that can be evaluated on the point.
*/
Line2D.prototype.getParam = function(iPoint, iStartParam, iEndParam, iTol)
{
  DSMath.TypeCheck(iPoint, true, DSMath.Point2D);
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
* @memberof DSMath.Line2D
* @method intersectLine
* @instance
* @description
* Intersects a portion of <i>this</i> Line2D with a portion of the specified Line2D.
* @param {DSMath.Line2D} iLine2D The second Line2D.
* @param {Number} iStartThis Start parameter defining the segment of <i>this</i> Line2D to be intersected.
* @param {Number} iEndThis End parameter defining the segment of <i>this</i> Line2D to be intersected.
* @param {Number} iStartLine2D Start parameter defining the segment of the specified Line2D to be intersected.
* @param {Number} iEndLine2D End parameter defining the segment of specified Line2D to be intersected.
* @param {Number} [iTol=1e-13] The precision to be used for the computation (max distance error).
* @return {IntersectionLineLineData} The intersection result.
* @example
* var l0 = new DSMath.Line2D().setDirection(1,1);
* var l1 = new DSMath.Line2D().setOrigin(1,0).setDirection(-1,1);
* var intl0l1 = l0.intersectLine(l1, -1, 1, -1, 1); // intl0l1.diag=1, intl0l1.param1=0.5, intL0l1.param2=0.5;
*/
Line2D.prototype.intersectLine = function (iLine, iStart1, iEnd1, iStart2, iEnd2, iTol)
{
  DSMath.TypeCheck(iLine, true, DSMath.Line2D);
  DSMath.TypeCheck(iStart1, true, 'number');
  DSMath.TypeCheck(iEnd1, true, 'number');
  DSMath.TypeCheck(iStart2, true, 'number');
  DSMath.TypeCheck(iEnd2, true, 'number');
  DSMath.TypeCheck(iTol, false, 'number');

  iTol = iTol || DSMath.defaultTolerances.epsgForRelativeTest;
  var sqEpsg = DSMath.defaultTolerances.epsgForSquareRelativeTest;
  var sqEpsgAbs = sqEpsg * Math.max(1, this.origin.squareDistanceToOrigin());

  var result = { param1: 0, param2: 0, diag: -1 };
  var d1 = this.direction;
  var n1 = d1.norm();
  var d2 = iLine.direction;
  var n2 = d2.norm();

  var det = -d1.x * d2.y + d1.y * d2.x;
  if (Math.abs(det) > DSMath.defaultTolerances.epsgForRelativeTest * n1 * n2)
  {
    var o1o2 = iLine.origin.sub(this.origin);
    var t2 = (-d2.y * o1o2.x + d2.x * o1o2.y) / det;
    var t1 = (-d1.y * o1o2.x + d1.x * o1o2.y) / det;

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

  } else if (iLine.squareDistanceToPoint(this.origin) < sqEpsgAbs)
  {
    result.diag = 1; // the result is a line.
  }

  return result;
};

/**
* @public
* @memberof DSMath.Line2D
* @method intersectFullLine
* @instance
* @description
* Intersects <i>this</i> full Line2D with the specified full Line2D.
* @param {DSMath.Line2D} iLine2D The second Line2D.
* @param {Number} [iTol=1e-13] The precision to be used for the computation (max distance error).
* @return {IntersectionLineLineData} The intersection result.
* @example
* var l0 = new DSMath.Line2D().setDirection(1,1);
* var l1 = new DSMath.Line2D().setOrigin(1,0).setDirection(-1,1);
* var intl0l1 = l0.intersectFullLine(l1); // intl0l1.diag=1, intl0l1.param1=0.5, intL0l1.param2=0.5;
*/
Line2D.prototype.intersectFullLine = function (iLine, iTol)
{
  DSMath.TypeCheck(iLine, true, DSMath.Line2D);
  DSMath.TypeCheck(iTol, false, 'number');

  iTol = iTol || DSMath.defaultTolerances.epsgForRelativeTest;
  var sqEpsg = DSMath.defaultTolerances.epsgForSquareRelativeTest;
  var sqEpsgAbs = sqEpsg * Math.max(1, this.origin.squareDistanceToOrigin());

  var result = { param1: 0, param2: 0, diag: -1 };
  var d1 = this.direction;
  var n1 = d1.norm();
  var d2 = iLine.direction;
  var n2 = d2.norm();

  var det = -d1.x * d2.y + d1.y * d2.x;
  if (Math.abs(det) > DSMath.defaultTolerances.epsgForRelativeTest * n1 * n2)
  {
    var o1o2 = iLine.origin.sub(this.origin);
    result.diag = 0;
    result.param1 = (-d2.y * o1o2.x + d2.x * o1o2.y) / det;
    result.param2 = (-d1.y * o1o2.x + d1.x * o1o2.y) / det;
  } 
  else if (iLine.squareDistanceToPoint(this.origin) < sqEpsgAbs)
  {
    result.diag = 1; // the result is a line.
  }

  return result;
};

/**-----------------------------------------
 * -------------- STATIC -------------------
 * -----------------------------------------
 */
/**
* @public
* @memberof DSMath.Line2D
* @method makeFromPoints
* @static
* @description
* Creates a line 2D defined by the two given points.
* <br> By default the line scale is 1. If both line parameters are provided, the scale will be updated.
* @param {DSMath.Point2D} iPt1      The first point on the line.
* @param {DSMath.Point2D} iPt2      The second point on the line. Has to be different from iPt1.
* @param {Number}         [iParam1] The line parameter for which the first point is reached (<=> line.EvalPoint(iParam1)==iPt1)
* @param {Number}         [iParam2] The line parameter for which the second point is reached (<=> line.EvalPoint(iParam2)==iPt2)
* @example
* var pt0 = new DSMath.Point2D(2,2);
* var pt1 = new DSMath.Point2D(4,2);
* var l0 = DSMath.Line2D.makeFromPoints(pt0,pt1);     // l0.origin=[2,2], l0.direction=[1,0] so l0.scale=1
* var l1 = DSMath.Line2D.makeFromPoints(pt0,pt1,1);   // l1.origin=[1,2], l1.direction=[1,0] so l1.scale=1
* var l2 = DSMath.Line2D.makeFromPoints(pt0,pt1,0,1); // l2.origin=[2,2], l2.direction=[2,0] so l2.scale=2
* @returns {DSMath.Line2D} The created line.
*/
Line2D.makeFromPoints = function (iPt0, iPt1, iParam0, iParam1)
{
  DSMath.TypeCheck(iPt0, true, DSMath.Point2D);
  DSMath.TypeCheck(iPt1, true, DSMath.Point2D);
  DSMath.TypeCheck(iParam0, false, 'number');
  DSMath.TypeCheck(iParam1, false, 'number');

  var line = new DSMath.Line2D();

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

DSMath.Line2D = Line2D;

return Line2D;

});
