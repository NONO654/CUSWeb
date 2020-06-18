//===================================================================
// COPYRIGHT DASSAULT SYSTEMES 2018
//===================================================================
// Strict test of the JavaScript NurbsCurve objects based
// on the MathJSODt
//===================================================================
// 16/11/18 Q48 Creation
// 31/01/19 Q48 Add getParam and arcLength computation
// 05/02/19 Q48 Add basic support for periodic NURBS
// 11/02/19 Q48 Add detection of discontinuities in NURBS (knot multiplicity)
// 11/02/19 Q48 Add function to detect NURBS self-intersection
//===================================================================

define('MathematicsES/MathNurbsCurveJSImpl',
  ['MathematicsES/MathNameSpace',
   'MathematicsES/MathTypeCheck',
   'MathematicsES/MathTypeCheckInternal',
   'MathematicsES/MathPointJSImpl',
   'MathematicsES/MathVector3DJSImpl'
   ],
   
function (DSMath, TypeCheck, TypeCheckInternal, Point, Vector3D)
{
  'use strict';
  
  /**
  * @private
  * @typedef NurbsKnot
  * @type Object
  * @property {Number} knotValue The parameter value of the knot
  * @property {Number} knotMult  The multiplicity of the knot
  */

  /**
  * @private
  * @exports NurbsCurve
  * @class
  * @classdesc Representation of a NURBS curve in 3D.
  *

  * @constructor
  * @constructordesc
  * The DSMath.NurbsCurve constructor creates a NURBS curve in 3D, which is represented by \
    a set of knots (value and multiplicity), \
    a set of control points,\
    an optional set of weights,\
    a polynomial degree.
  * @param {NurbsKnot[]}    [iKnotVector]         The set of knots for the parameterisation.
  * @param {DSMath.Point[]} [iCPs]                The set of (3D) control points.
  * @param {Number[]}       [iW]                  The set of weights (the weights are taken to be 1 if this array is empty).
  * @param {Number}         [iDegree]             The degree of the NURBS
  * @param {Boolean}        [iIsPeriodic = false] Flag to indicate periodic NURBS
  * @memberof DSMath
  */

  var NurbsCurve = function (iKnotVector, iCPs, iW, iDegree, iIsPeriodic)
  {
    DSMath.TypeCheck(iKnotVector, false, [Object], []);
    DSMath.TypeCheck(iCPs, false, [DSMath.Point], []);
    DSMath.TypeCheck(iW, false, ['number'], []);
    DSMath.TypeCheck(iDegree, false, 'number');

    // Attributes
    // -------------------------------------

    this.OK = false; // not OK unless the data is set

    // Public
    if (iKnotVector && iCPs && iW && iDegree)
      this.setData(iKnotVector, iCPs, iW, iDegree, iIsPeriodic);

    /** @ignore */
    // Private (internal method for evaluation)
    this.EvalBasisFunction = function (iT, iI, iP)
    {
      DSMath.TypeCheckInternal(iT, true, 'number');
      DSMath.TypeCheckInternal(iI, true, 'number');
      DSMath.TypeCheckInternal(iP, true, 'number');

      if (this._DEBUG >= 3)
      {
        this._DEBUG_INDENT += "  ";
        console.log(this._DEBUG_INDENT + "EvalBasisFunction(" + iI + ", " + iP + ") at " + iT)
      }

      // Lowest degree
      // -------------

      if (iP == 0)
      {
        var isInArc = false;

        if (this._DEBUG >= 3)
          console.log(this._DEBUG_INDENT + "Arc range " + this.KnotVecFull[iI] + " -> " + this.KnotVecFull[iI + 1])

        if (this.IsArcActive(iI) === true)
        {
          if (this._DEBUG >= 3)
            console.log(this._DEBUG_INDENT + " --> active arc");

          if (iT >= this.KnotVecFull[iI])
          {
            var isLastArc = false;

            if (this.IsPeriodic === false) // only for non-periodics "close" the domain of the last arc ("<=" instead of "<")
            {
              var lastMult = this.KnotVec[this.KnotVec.length - 1].knotMult;

              var lastKnotIndexFull = this.KnotVecFull.length - lastMult - 1;
              if (iI == lastKnotIndexFull) // last arc
              {
                isLastArc = true;

                if (this._DEBUG >= 3)
                  console.log(this._DEBUG_INDENT + "  --> detected last arc");
              }
            }

            if (isLastArc === true)
            {
              if (iT <= this.KnotVecFull[iI + 1])
                isInArc = true;
            }
            else
            {
              if (iT < this.KnotVecFull[iI + 1])
                isInArc = true;
            }
          }
        }
        else
        {
          if (this._DEBUG >= 3)
            console.log(this._DEBUG_INDENT + " --> inactive arc");
        }

        var oVal = 0.0;
        if (isInArc === true)
          oVal = 1.0;

        if (this._DEBUG >= 3)
        {
          console.log(this._DEBUG_INDENT + "EvalBasisFunction(" + iI + ", " + iP + ") at " + iT + "  --> " + oVal);
          this._DEBUG_INDENT = this._DEBUG_INDENT.slice(0, this._DEBUG_INDENT.length - 2); // decrease indent
        }

        return oVal;
      }

      // Compute the local knot index
      // ----------------------------

      var knotData = this.ComputeLocalKnotInfo(iI);

      // Recursive calls to compute first term
      // --------------------------------------

      var oRes = 0.0;

      if (knotData.knotSubIndex + iP >= this.KnotVec[knotData.knotIndex].knotMult)
      {
        var coef1 = (iT - this.KnotVecFull[iI]) / (this.KnotVecFull[iI + iP] - this.KnotVecFull[iI]);
        var func1 = this.EvalBasisFunction(iT, iI, iP - 1);
        oRes += coef1 * func1;

        if (this._DEBUG >= 3)
        {
          console.log(this._DEBUG_INDENT + " 1st term: " + coef1 + " * " + func1);
          console.log(this._DEBUG_INDENT + "           coef: (" + iT + " - " + this.KnotVecFull[iI] + ") / (" + this.KnotVecFull[iI + iP] + " - " + this.KnotVecFull[iI] + ")");
        }
      }

      // Propagate to the next knot
      // --------------------------

      knotData = this.PropagateKnotInfo(knotData);

      // Recursive calls to compute second term
      // --------------------------------------

      if (knotData.knotSubIndex + iP + 1 >= this.KnotVec[knotData.knotIndex].knotMult)
      {
        var coef2 = (this.KnotVecFull[iI + iP + 1] - iT) / (this.KnotVecFull[iI + iP + 1] - this.KnotVecFull[iI + 1]);
        var func2 = this.EvalBasisFunction(iT, iI + 1, iP - 1);
        oRes += coef2 * func2;

        if (this._DEBUG >= 3)
        {
          console.log(this._DEBUG_INDENT + " 2nd term: " + coef2 + " * " + func2);
          console.log(this._DEBUG_INDENT + "           coef: (" + this.KnotVecFull[iI + iP + 1] + " - " + iT + ") / (" + this.KnotVecFull[iI + iP + 1] + " - " + this.KnotVecFull[iI + 1] + ")");
        }
      }
          
      if (this._DEBUG >= 3)
      {
        console.log(this._DEBUG_INDENT + "EvalBasisFunction(" + iI + ", " + iP + ") at " + iT + "  --> " + oRes);
        this._DEBUG_INDENT = this._DEBUG_INDENT.slice(0, this._DEBUG_INDENT.length - 2); // decrease indent
      }

      return oRes;
    }

    /** @ignore */
    // Private (internal method for evaluation)
    this.EvalBasisFunctionFirstDeriv = function (iT, iI, iP)
    {
      DSMath.TypeCheckInternal(iT, true, 'number');
      DSMath.TypeCheckInternal(iI, true, 'number');
      DSMath.TypeCheckInternal(iP, true, 'number');

      // Lowest degree
      // -------------

      if (iP == 0)
        return 0.0;

      // Compute the local knot index
      // ----------------------------

      var knotData = this.ComputeLocalKnotInfo(iI);

      // Recursive calls to compute first term
      // --------------------------------------

      var oRes = 0.0;

      if (knotData.knotSubIndex + iP >= this.KnotVec[knotData.knotIndex].knotMult)
      {
        var eCoef1 = (iT - this.KnotVecFull[iI]) / (this.KnotVecFull[iI + iP] - this.KnotVecFull[iI]);
        var dCoef1 = 1.0 / (this.KnotVecFull[iI + iP] - this.KnotVecFull[iI]);

        var eBasis1 = this.EvalBasisFunction(iT, iI, iP - 1);
        var dBasis1 = this.EvalBasisFunctionFirstDeriv(iT, iI, iP - 1);

        oRes += (eCoef1 * dBasis1) + (dCoef1 * eBasis1);
      }

      // Propagate to the next knot
      // --------------------------

      knotData = this.PropagateKnotInfo(knotData);

      // Recursive calls to compute second term
      // --------------------------------------

      if (knotData.knotSubIndex + iP + 1 >= this.KnotVec[knotData.knotIndex].knotMult)
      {
        var eCoef2 = (this.KnotVecFull[iI + iP + 1] - iT) / (this.KnotVecFull[iI + iP + 1] - this.KnotVecFull[iI + 1]);
        var dCoef2 = -1.0 / (this.KnotVecFull[iI + iP + 1] - this.KnotVecFull[iI + 1]);

        var eBasis2 = this.EvalBasisFunction(iT, iI + 1, iP - 1);
        var dBasis2 = this.EvalBasisFunctionFirstDeriv(iT, iI + 1, iP - 1);

        oRes += (eCoef2 * dBasis2) + (dCoef2 * eBasis2);
      }

      return oRes;
    }

    /** @ignore */
    // Private (internal method for evaluation)
    this.EvalBasisFunctionSecondDeriv = function (iT, iI, iP)
    {
      DSMath.TypeCheckInternal(iT, true, 'number');
      DSMath.TypeCheckInternal(iI, true, 'number');
      DSMath.TypeCheckInternal(iP, true, 'number');

      // Lowest degree
      // -------------

      if (iP == 0 || iP == 1)
        return 0.0;

      // Compute the local knot index
      // ----------------------------

      var knotData = this.ComputeLocalKnotInfo(iI);

      // Recursive calls to compute first term
      // --------------------------------------

      var oRes = 0.0;

      // Term-1
      if (knotData.knotSubIndex + iP >= this.KnotVec[knotData.knotIndex].knotMult)
      {
        var eCoef1 = (iT - this.KnotVecFull[iI]) / (this.KnotVecFull[iI + iP]- this.KnotVecFull[iI]);
        var dCoef1 = 1.0 / (this.KnotVecFull[iI + iP]- this.KnotVecFull[iI]);

        var dBasis1 = this.EvalBasisFunctionFirstDeriv(iT, iI, iP - 1);
        var cBasis1 = this.EvalBasisFunctionSecondDeriv(iT, iI, iP - 1);

        oRes += (eCoef1 * cBasis1) + (2 * dCoef1 * dBasis1);
      }

      // Propagate to the next knot
      // --------------------------

      knotData = this.PropagateKnotInfo(knotData);

      // Recursive calls to compute second term
      // --------------------------------------

      if (knotData.knotSubIndex + iP + 1 >= this.KnotVec[knotData.knotIndex].knotMult)
      {
        var eCoef2 = (this.KnotVecFull[iI + iP + 1] - iT) / (this.KnotVecFull[iI + iP + 1] - this.KnotVecFull[iI + 1]);
        var dCoef2 = -1.0 / (this.KnotVecFull[iI + iP + 1] - this.KnotVecFull[iI + 1]);

        var dBasis2 = this.EvalBasisFunctionFirstDeriv(iT, iI + 1, iP - 1);
        var cBasis2 = this.EvalBasisFunctionSecondDeriv(iT, iI + 1, iP - 1);

        oRes += (eCoef2 * cBasis2) + (2 * dCoef2 * dBasis2);
      }

      return oRes;
    }

    /** @ignore */
    // Private (internal method for evaluation)
    this.ComputeLocalKnotInfo = function (iI)
    {
      // Compute the local knot index
      // ----------------------------

      var knotIndexFull = 0;
      var knotIndex = 0;
      for (var i = 0; i < this.KnotVec.length; i++)
      {
        var nextKnotIndexFull = knotIndexFull + this.KnotVec[i].knotMult;
        if (nextKnotIndexFull > iI)
          break;

        knotIndexFull = nextKnotIndexFull;
        knotIndex++;
      }

      var knotSubIndex = iI - knotIndexFull;

      var oData = {knotIndex : knotIndex, knotIndexFull : knotIndexFull, knotSubIndex : knotSubIndex};
      return oData;
    }

    this.PropagateKnotInfo = function (iKnotInfo)
    {
      var oData = {knotIndex : iKnotInfo.knotIndex, knotIndexFull : iKnotInfo.knotIndexFull, knotSubIndex : iKnotInfo.knotSubIndex};

      if (iKnotInfo.knotSubIndex + 1 == this.KnotVec[iKnotInfo.knotIndex].knotMult)
      {
        oData.knotIndex++;
        oData.knotSubIndex = -1;
      }

      oData.knotIndexFull++;
      return oData;
    }
        
    /** @ignore */
    // Private (internal method for evaluation)
    this.IsArcActive = function (iI)
    {
      var knotData = this.ComputeLocalKnotInfo(iI);

      var knotIndex = knotData.knotIndex;
      var knotIndexFull = knotData.knotIndexFull;
      var knotSubIndex = knotData.knotSubIndex;

      if (knotSubIndex != this.KnotVec[knotIndex].knotMult - 1)
        return false; // inactive arc

      if (this.IsPeriodic === true)
      {
        if (knotIndex < this.Degree)
          return false;

        if (knotIndex >= this.KnotVec.length - 1 - this.Degree)
          return false;
      }
      else
      {
        if (knotIndex == this.KnotVec.length - 1)
          return false;
      }

      return true;
    }

    // ---------------------------------------------------------------------------------
    // DEBUG
    // ---------------------------------------------------------------------------------
    this._DEBUG = 0;
    this._DEBUG_INDENT = "  ";
  };

  // ---------------------------------------------------------------------------------
  // Data members
  // ---------------------------------------------------------------------------------

  NurbsCurve.prototype.OK = null;
  NurbsCurve.prototype.KnotVec = null;
  NurbsCurve.prototype.CPs = null;
  NurbsCurve.prototype.Weights = null;
  NurbsCurve.prototype.Degree = null;
  NurbsCurve.prototype.IsPeriodic = null;

  // ---------------------------------------------------------------------------------
  // Private methods
  // ---------------------------------------------------------------------------------
  
  /** @ignore */
  NurbsCurve.prototype.IsInfinite = function ()
  {
    return false;
  }
  
  ///** @ignore */
  //NurbsCurve.prototype.IsPeriodic = function ()
  //{
  //  return this.IsPeriodic;
  //}

  /** @ignore */
  NurbsCurve.prototype.GetFirstKnot = function ()
  {
    if (this.IsPeriodic === true)
      return this.KnotVec[this.Degree].knotValue;

    return this.KnotVec[0].knotValue;
  }

  /** @ignore */
  NurbsCurve.prototype.GetLastKnot = function ()
  {
    if (this.IsPeriodic === true)
      return this.KnotVec[this.KnotVec.length - 1 - this.Degree].knotValue;

    return this.KnotVec[this.KnotVec.length - 1].knotValue;
  }
  
  /** @ignore */
  NurbsCurve.prototype.GetKnotRange = function ()
  {
    var oRange = [];
    oRange[0] = this.GetFirstKnot();
    oRange[1] = this.GetLastKnot();

    return oRange;
  }

  /** @ignore */
  NurbsCurve.prototype.UpdateDegree = function (iNewDegree)
  {
    if (this.IsPeriodic === true)
      this.Degree = iNewDegree;
  }
  
  /** @ignore */
  NurbsCurve.prototype.putInPrincipalRange = function (iParam)
  {
    if (this.IsPeriodic === false) // Nothing to do for non-periodics!
      return iParam;

    // Take care if iParam == lastKnot
    //    - this is specially handled in the evaluators ("<" vs "<=" for the last arc)
    //    - but for periodics we don't treat it specially (we keep the "<")

    if (iParam >= this.GetFirstKnot() && iParam < this.GetLastKnot())
      return iParam;

    // Compute the number of cycles to add / subtract

    var period = this.GetLastKnot() - this.GetFirstKnot();
      
    var nPeriod = Math.floor((iParam - this.GetFirstKnot()) / period);

    var oParam = iParam - (nPeriod * period);
    return oParam;
  }

  // ---------------------------------------------------------------------------------
  // Public methods
  // ---------------------------------------------------------------------------------

  /**
  * @private
  * @memberof DSMath.NurbsCurve
  * @param {NurbsKnot[]}     iKnotVector          The set of knots for the parameterisation.
  * @param {DSMath.Point[]}  iCPs                 The set of (3D) control points.
  * @param {Number[]}        iW                   The set of weights (the weights are taken to be 1 if this array is empty).
  * @param {Number}          iDegree              The degree of the NURBS
  * @param {Boolean}        [iIsPeriodic = false] Flag to indicate periodic NURBS
  * @method setData
  * @instance
  * @description
  * Set the data for <i>this</i> NurbsCurve.
  * @example
  * var knots = [ {knotValue: 0.0, knotMult: 3}, {knotValue: 7.5, knotMult: 3} ];
  * var CPs = [ new DSMath.Point(2,2,0), new DSMath.Point(3,6,1), new DSMath.Point(4,5,0) ];
  * var weights = [ 1, 1, 1 ];
  * var degree = 2;
  * var n0 = new DSMath.NurbsCurve(); // n0.OK === false
  * n0.setData(knots, CPs, weights, degree); // n0.OK === true
  * @returns {DSMath.NurbsCurve} <i>this</i> modified nurbs curve reference.
  */
  NurbsCurve.prototype.setData = function (iKnotVector, iCPs, iW, iDegree, iIsPeriodic)
  {
    DSMath.TypeCheck(iKnotVector, true, [Object], []);
    DSMath.TypeCheck(iCPs, true, [DSMath.Point], []);
    DSMath.TypeCheck(iW, true, ['number'], []);
    DSMath.TypeCheck(iDegree, true, 'number');

    this.OK = true; // assume everything will be OK

    var nKnots = 0;
    for (var i = 0; i < iKnotVector.length; i++)
      nKnots += iKnotVector[i].knotMult;

    var isPeriodic = iIsPeriodic ? iIsPeriodic : false;

    if (isPeriodic)
    {
      if (nKnots != iCPs.length + 1)
        this.OK = false;
    }
    else
    {
      if (nKnots != iCPs.length + 1 + iDegree)
        this.OK = false;
    }

    if (iW.length > 0 && iW.length != iCPs.length)
      this.OK = false;

    // Inconsistent data --> stop and return (no data is set)
    // ------------------------------------------------------

    if (this.OK === false)
      return this;

    // Periodic
    // --------

    this.IsPeriodic = isPeriodic;

    // Degree
    // ------

    this.Degree = iDegree;

    // Knot vector
    // -----------

    this.KnotVec = [];

    if (this.IsPeriodic === true)
    {
      var knotGap = iKnotVector[1].knotValue - iKnotVector[0].knotValue;
      this.KnotVec.push({ knotValue: iKnotVector[0].knotValue - (2 * knotGap), knotMult : 1 });
      this.KnotVec.push({ knotValue: iKnotVector[0].knotValue -      knotGap , knotMult : 1 });
    }

    for (var i = 0; i < iKnotVector.length; i++)
      this.KnotVec.push({ knotValue: iKnotVector[i].knotValue, knotMult: iKnotVector[i].knotMult });

    if (this.IsPeriodic === true)
    {
      var knotGap = iKnotVector[iKnotVector.length - 1].knotValue - iKnotVector[iKnotVector.length - 2].knotValue;
      this.KnotVec.push({ knotValue: iKnotVector[iKnotVector.length - 1].knotValue +     knotGap , knotMult : 1 });
      this.KnotVec.push({ knotValue: iKnotVector[iKnotVector.length - 1].knotValue + 2 * knotGap , knotMult : 1 });
    }

    this.KnotVecFull = [];
    for (var i = 0; i < this.KnotVec.length; i++)
    {
      for (var j = 0; j < this.KnotVec[i].knotMult; j++)
        this.KnotVecFull.push( this.KnotVec[i].knotValue );
    }

    // Control points and weights
    // --------------------------

    this.CPs = [];
    this.Weights = [];

    if (iW.length == 0) // no weights supplied --> set all to 1
    {
      for (var i = 0; i < iCPs.length; i++)
        iW.push(1.0);
    }

    for (var i = 0; i < iCPs.length; i++)
    {
      this.CPs.push(iCPs[i].clone());
      this.Weights.push(iW[i]);
    }

    if (isPeriodic === true) // copy the last "degree" CPs / weights to the end of the list
    {
      for (var i = 0; i < this.Degree; i++)
      {
        this.CPs.push(iCPs[i].clone());
        this.Weights.push(iW[i]);
      }
    }

    return this;
  };

  /**
  * @private
  * @memberof DSMath.NurbsCurve
  * @method clone
  * @instance
  * @description
  * Clones <i>this</i> NurbsCurve.
  * @example
  * var knots = [ {knotValue: 0.0, knotMult: 3}, {knotValue: 7.5, knotMult: 3} ];
  * var CPs = [ new DSMath.Point(2,2,0), new DSMath.Point(3,6,1), new DSMath.Point(4,5,0) ];
  * var weights = [ 1, 1, 1 ];
  * var degree = 2;
  * var n0 = new DSMath.NurbsCurve(knots, CPs, weights, degree); // n0.OK should be true
  * var n1 = n0.clone(); // n1 == n0 but n1 !== n0
  * @returns {DSMath.NurbsCurve} The cloned nurbs curve.
  */
  NurbsCurve.prototype.clone = function ()
  {
    var oN = new NurbsCurve();
    return oN.copy(this);
  };

  /**
  * @private
  * @memberof DSMath.NurbsCurve
  * @method copy
  * @instance
  * @description
  * Copies <i>this</i> NurbsCurve.
  * @example
  * var knots = [ {knotValue: 0.0, knotMult: 3}, {knotValue: 7.5, knotMult: 3} ];
  * var CPs = [ new DSMath.Point(2,2,0), new DSMath.Point(3,6,1), new DSMath.Point(4,5,0) ];
  * var weights = [ 1, 1, 1 ];
  * var degree = 2;
  * var n0 = new DSMath.NurbsCurve(knots, CPs, weights, degree); // n0.OK should be true
  * var n1 = new DSMath.NurbsCurve();
  * n1.copy(n0); // n1 == n0 but n1 !== n0
  * @returns {DSMath.NurbsCurve} <i>this</i> modified nurbs curve reference.
  */
  NurbsCurve.prototype.copy = function (iToCopy)
  {
    DSMath.TypeCheck(iToCopy, true, DSMath.NurbsCurve);

    if (iToCopy.OK === false)
    {
      this.OK = false;
      return this;
    }

    this.setData(iToCopy.KnotVec, iToCopy.CPs, iToCopy.Weights, iToCopy.Degree);
    return this;
  };

  /**
  * @private
  * @memberof DSMath.NurbsCurve
  * @method evalPoint
  * @instance
  * @description
  * Returns the point of <i>this</i> nurbs curve corresponding to the given parameters.
  * @param {Number} iT  The curve parameter.
  * @example
  * var knots = [{knotValue: 0.0, knotMult: 3}, {knotValue: 7.5, knotMult: 3}];
  * var CPs = [ new DSMath.Point(2,2,0), new DSMath.Point(3,6,1), new DSMath.Point(4,5,0) ];
  * var weights = [ 1.0, 1.0, 1.0 ];
  * var degree = 2;
  * var n0 = new DSMath.NurbsCurve(knots, CPs, weights, degree); // n0.OK should be true
  * var p0 = n0.evalPoint(0);   // p0 = (2.0, 2.0, 0.0)
  * var p1 = n0.evalPoint(3.0); // p1 = (2.8, 4.4, 0.48)
  * var p2 = n0.evalPoint(7.5); // p2 = (4.0, 5.0, 0.0)
  * @returns { DSMath.Point } The reference of the operation result - the point evaluated.
  */
  NurbsCurve.prototype.evalPoint = function (iT)
  {
    DSMath.TypeCheck(iT, true, 'number');

    if (this._DEBUG >= 1)
      console.log("NurbsCurve evalPoint at " + iT);
    
    iT = this.putInPrincipalRange(iT);
    
    if (this._DEBUG >= 1 && this.IsPeriodic === true)
      console.log("  periodic NURBS --> evaluate at " + iT);

    var ePoint = new DSMath.Point();
    var eSumW = 0.0;

    for (var i = 0; i < this.CPs.length; i++)
    {
      if (this._DEBUG >= 2)
        console.log("  Compute contribution from CP[" + i + "] at: (" + this.CPs[i].getArray() + ")");

      var weightedBasis = this.Weights[i] * this.EvalBasisFunction(iT, i, this.Degree);

      if (this._DEBUG >= 2)
        console.log("  --> weighted contribution of " + weightedBasis);

      ePoint.addScaledPoint(this.CPs[i], weightedBasis);
      eSumW += weightedBasis;
    }

    var oPoint = this.ComputePoint(ePoint, eSumW);
    return oPoint;
  };

  /**
  * @private
  * @memberof DSMath.NurbsCurve
  * @method evalFirstDeriv
  * @instance
  * @description
  * Returns the derivative of <i>this</i> nurbs curve corresponding to the given parameter.
  * @param {Number} iT  The curve parameter
  * @example
  * var knots = [ {knotValue: 0.0, knotMult: 3}, {knotValue: 7.5, knotMult: 3} ];
  * var CPs = [ new DSMath.Point(2,2,0), new DSMath.Point(3,6,1), new DSMath.Point(4,5,0) ];
  * var weights = [ 1, 1, 1 ];
  * var degree = 2;
  * var n0 = new DSMath.NurbsCurve(knots, CPs, weights, degree); // n0.OK should be true
  * var p0 = n0.evalFirstDeriv(0);   // v0 = (8/30, 32/30, 8/30)
  * var p1 = n0.evalFirstDeriv(3.0); // v1 = (8/30, 16/30, 16/300)
  * var p2 = n0.evalFirstDeriv(7.5); // v2 = (8/30, -8/30, -8/30)
  * @returns { DSMath.Vector3D } The reference of the operation result - the gradient evaluated.
  */
  NurbsCurve.prototype.evalFirstDeriv = function (iT)
  {
    DSMath.TypeCheck(iT, true, 'number');

    if (this._DEBUG >= 1)
      console.log("NurbsCurve evalFirstDeriv at " + iT);

    iT = this.putInPrincipalRange(iT);

    if (this._DEBUG >= 1 && this.IsPeriodic === true)
      console.log("  periodic NURBS --> evaluate at " + iT);

    var ePoint = new DSMath.Point(); // sum(w *       basisFunction * CP)
    var dPoint = new DSMath.Point(); // sum(w * deriv-basisFunction * CP)

    var eSumW = 0.0; // sum(w *       basisFunction)
    var dSumW = 0.0; // sum(w * deriv-basisFunction)

    for (var i = 0; i < this.CPs.length; i++)
    {
      var currTerm  = this.Weights[i] * this.EvalBasisFunction(iT, i, this.Degree);
      var currDeriv = this.Weights[i] * this.EvalBasisFunctionFirstDeriv(iT, i, this.Degree);

      ePoint.addScaledPoint(this.CPs[i], currTerm);
      dPoint.addScaledPoint(this.CPs[i], currDeriv);

      eSumW += currTerm;
      dSumW += currDeriv;
    }

    var oDeriv = this.ComputeFirstDeriv(ePoint, dPoint, eSumW, dSumW);
    return oDeriv;
  }

  /**
  * @private
  * @memberof DSMath.NurbsCurve
  * @method evalSecondDeriv
  * @instance
  * @description
  * Returns the second derivative of <i>this</i> nurbs curve corresponding to the given parameter.
  * @param {Number} iT  The curve parameter
  * @example
  * var knots = [ {knotValue: 0.0, knotMult: 3}, {knotValue: 7.5, knotMult: 3} ];
  * var CPs = [ new DSMath.Point(2,2,0), new DSMath.Point(3,6,1), new DSMath.Point(4,5,0) ];
  * var weights = [ 1, 1, 1 ];
  * var degree = 2;
  * var n0 = new DSMath.NurbsCurve(knots, CPs, weights, degree); // n0.OK should be true
  * var v0 = n0.evalSecondDeriv(0);   // v0 = (??)
  * var v1 = n0.evalSecondDeriv(3.0); // v1 = (??)
  * var v2 = n0.evalSecondDeriv(7.5); // v2 = (??)
  * @returns { DSMath.Vector3D } The reference of the operation result - the second derivative evaluated.
  */
  NurbsCurve.prototype.evalSecondDeriv = function (iT)
  {
    DSMath.TypeCheck(iT, true, 'number');

    if (this._DEBUG >= 1)
      console.log("NurbsCurve evalSecondDeriv at " + iT);

    iT = this.putInPrincipalRange(iT);

    if (this._DEBUG >= 1 && this.IsPeriodic === true)
      console.log("  periodic NURBS --> evaluate at " + iT);

    var ePoint = new DSMath.Point(); // sum(w *              basisFunction * CP)
    var dPoint = new DSMath.Point(); // sum(w *        deriv-basisFunction * CP)
    var cPoint = new DSMath.Point(); // sum(w * second-deriv-basisFunction * CP)

    var eSumW = 0.0; // sum(w *              basisFunction)
    var dSumW = 0.0; // sum(w *        deriv-basisFunction)
    var cSumW = 0.0; // sum(w * second-deriv-basisFunction)

    for (var i = 0; i < this.CPs.length; i++)
    {
      var eTerm = this.Weights[i] * this.EvalBasisFunction(iT, i, this.Degree);
      var dTerm = this.Weights[i] * this.EvalBasisFunctionFirstDeriv(iT, i, this.Degree);
      var cTerm = this.Weights[i] * this.EvalBasisFunctionSecondDeriv(iT, i, this.Degree);

      ePoint.addScaledPoint(this.CPs[i], eTerm);
      dPoint.addScaledPoint(this.CPs[i], dTerm);
      cPoint.addScaledPoint(this.CPs[i], cTerm);

      eSumW += eTerm;
      dSumW += dTerm;
      cSumW += cTerm;
    }

    var oSecondDeriv = this.ComputeSecondDeriv(ePoint, dPoint, cPoint, eSumW, dSumW, cSumW);
    return oSecondDeriv;
  }

  /** @ignore */
  // Internal method for performance
  NurbsCurve.prototype.ComputePoint = function (ePoint, eSumW)
  {
    DSMath.TypeCheck(ePoint, true, DSMath.Point);
    DSMath.TypeCheck(eSumW, true, 'number');

    // Inputs:
    //   ePoint = Sum( basis-function[i] * weight[i] * CP[i] )
    //   eSumW =  Sum( basis-function[i] * weight[i] )

    // Evaluation:
    //   oPoint = ePoint / eSumW

    var oPoint = ePoint.clone().divideScalar(eSumW);
    return oPoint;
  }

  /** @ignore */
  // Internal method for performance
  NurbsCurve.prototype.ComputeFirstDeriv = function (ePoint, dPoint, eSumW, dSumW)
  {
    DSMath.TypeCheck(ePoint, true, DSMath.Point);
    DSMath.TypeCheck(dPoint, true, DSMath.Point);
    DSMath.TypeCheck(eSumW, true, 'number');
    DSMath.TypeCheck(dSumW, true, 'number');

    // Inputs:
    //   ePoint = Sum( basis-function[i] * weight[i] * CP[i] )
    //   dPoint = Sum( basis-function-deriv[i] * weight[i] * CP[i] )

    //   eSumW =  Sum( basis-function[i] * weight[i] )
    //   dSumW =  Sum( basis-function-deriv[i] * weight[i] )

    var nE = this.ComputePoint(ePoint, eSumW);

    // First derivative:
    //  F(t)  = Sum( f_i(u) * w[i] * CP[i] ) / Sum( f_i(u) * w[i])
    //        =  ePoint / eSumW
    //
    //  F'(t) =  ( (eSumW * dPoint) - (ePoint * dSumW) ) / (eSumW * eSumW)
    //        =  (dPoint / eSumW) - (F(t) * dSumW / eSumW)

    var term1 = dPoint.clone().divideScalar(eSumW);
    var term2 = nE.multiplyScalar(dSumW / eSumW);

    var oDeriv = term1.sub(term2);
    return oDeriv;
  }

  /** @ignore */
  // Internal method for performance
  NurbsCurve.prototype.ComputeSecondDeriv = function (ePoint, dPoint, cPoint, eSumW, dSumW, cSumW)
  {
    DSMath.TypeCheck(ePoint, true, DSMath.Point);
    DSMath.TypeCheck(dPoint, true, DSMath.Point);
    DSMath.TypeCheck(cPoint, true, DSMath.Point);
    DSMath.TypeCheck(eSumW, true, 'number');
    DSMath.TypeCheck(dSumW, true, 'number');
    DSMath.TypeCheck(cSumW, true, 'number');

    // Inputs:
    //   ePoint = Sum( basis-function[i] * weight[i] * CP[i] )
    //   dPoint = Sum( basis-function-deriv[i] * weight[i] * CP[i] )
    //   cPoint = Sum( basis-function-second-deriv[i] * weight[i] * CP[i] )

    //   eSumW =  Sum( basis-function[i] * weight[i] )
    //   dSumW =  Sum( basis-function-deriv[i] * weight[i] )
    //   cSumW =  Sum( basis-function-second-deriv[i] * weight[i] )

    var nE = this.ComputePoint(ePoint, eSumW);
    var nT = this.ComputeFirstDeriv(ePoint, dPoint, eSumW, dSumW);

    // Second derivative:
    //  F(t)  = Sum( f_i(u) * w[i] * CP[i] ) / Sum( f_i(u) * w[i])
    //        =  ePoint / eSumW
    //
    //  F'(t) =  ( (eSumW * dPoint) - (ePoint * dSumW) ) / (eSumW * eSumW)
    //        =  (dPoint / eSumW) - (F(t) * dSumW / eSumW)
    //
    // F''(t) = ( ((eSumW * cPoint) - (dPoint * dSumW)) / (eSumW * eSumW) )
    //                - F(t) * ((eSumW * cSumW) - (dSumW * dSumW)) / (eSumW * eSumW)
    //                - F'(t) * (dSumW / eSumW)
    //        = [ cPoint - (2 * F'(t) * dSumW) - (F(t) * cSumW) ] / eSumW

    var oSecondDeriv = cPoint.clone().subScaledVector(nT, 2 * dSumW).sub(nE.multiplyScalar(cSumW));
    oSecondDeriv.divideScalar(eSumW);

    return oSecondDeriv;
  }

  /**
  * @private
  * @memberof DSMath.NurbsCurve
  * @method FindDiscontinuties
  * @instance
  * @description
  * Checks the knot vector of <i>this</i> nurbs curve for discontinuities greater than or equal to the current level.
  * For example, if the given level is "1", this returns a list of all G1 or G0 discontinuities.
  * @param {Number} iContinuity  The required continuity level.
  * @example
  * var knots = [{knotValue: 0.0, knotMult: 3}, {knotValue: 0.0, knotMult: 2}, {knotValue: 7.5, knotMult: 3}];
  * var CPs = [ new DSMath.Point(0,0,0), new DSMath.Point(2,8,0), new DSMath.Point(4,0,0), new DSMath.Point(6,8,0), new DSMath.Point(8,0,0) ];
  * var weights = [ 1.0, 1.0, 1.0, 1.0, 1.0 ];
  * var degree = 2;
  * var n0 = new DSMath.NurbsCurve(knots, CPs, weights, degree); // n0.OK should be true
  * var discontinuitiesG0 = n0.FindDiscontinuties(0); // discontinuitiesG0 should be empty
  * var discontinuitiesG1 = n0.FindDiscontinuties(1); // discontinuitiesG1 should be [1] (discontinuity at knot-1)
  * @returns { Number[] } The array of knot indices with discontinuities.
  */
  NurbsCurve.prototype.FindDiscontinuties = function (iRequiredLevel)
  {
    var oDiscontinuities = [];

    if (this.OK === false)
      return oDiscontinuities;

    var startIndex = 1;
    var endIndex = this.KnotVec.length - 1;

    if (this.IsPeriodic === true)
    {
      startIndex += (this.Degree - 1);
      endIndex -= (this.Degree - 1); // check the last given knot too!
    }

    for (var iKnot = startIndex; iKnot < endIndex; iKnot++)
    {
      if (this.Degree - this.KnotVec[iKnot].knotMult < iRequiredLevel)
        oDiscontinuities.push(iKnot);
    }

    return oDiscontinuities;
  }

  /**
  * @private
  * @memberof DSMath.NurbsCurve
  * @method getParam
  * @instance
  * @description
  * Returns the parameter on <i>this</i> NurbsCurve corresponding to a point in 3D, in the parameters limits given.
  * @param { DSMath.Point } iPoint       The 3D Point.
  * @param { Number }       iStartParam  The lowest NurbsCurve parameter on which we can find a solution.
  * @param { Number }       iEndParam    The highest NurbsCurve parameter on which we can find a solution.
  * @param { Number }       [iTol=1e-13] The max 3D distance between the solution and the point given.
  * @example
  * var knots = [ {knotValue: 0.0, knotMult: 4}, {knotValue: 25.0, knotMult: 4} ];
  * var CPs = [ new DSMath.Point(2,2,0), new DSMath.Point(3,6,1), new DSMath.Point(4,5,0), new DSMath.Point(5,7,0) ];
  * var weights = [ 1, 1, 1, 1 ];
  * var degree = 3;
  * var n0 = new DSMath.NurbsCurve();
  * n0.setData(knots, CPs, weights, degree); // n0.OK === true
  * var t0 = n0.getParam(n0.evalPoint(10.0, 0, 25.0)); // t0 = 10.0
  * @returns { Number[] } An array containing 0, or 1 that can be evaluated on the point.
  * <br>
  */
  NurbsCurve.prototype.getParam = function (iPoint, iStartParam, iEndParam, iTol)
  {
    var tol = iTol || 1.0e-13; // default tolerance of 10^-13

    var paramSol = [];

    // Check start point
    // -----------------

    var startPt = this.evalPoint(iStartParam);
    var distStartPt = startPt.distanceTo(iPoint);
    if (distStartPt <= tol)
      paramSol.push(iStartParam);

    // Check end point
    // ---------------

    var endPt = this.evalPoint(iEndParam);
    var distEndPt = endPt.distanceTo(iPoint);
    if (distEndPt <= tol)
      paramSol.push(iEndParam);

    // Check interior points
    // ---------------------

    if (paramSol.length == 0)
    {
      var minDistOp = new DSMath.MinDistPtCrv(this, [iStartParam, iEndParam], iPoint);
      var minDistPar = minDistOp.Run();

      if (minDistOp.hasSol === true)
      {
        var minDistPt = this.evalPoint(minDistPar);

        if (minDistPt.distanceTo(iPoint) <= tol)
          paramSol.push(minDistPar);
      }
    }

    return paramSol;
  };

  /**
  * @private
  * @memberof DSMath.NurbsCurve
  * @method arcLength
  * @instance
  * @description
  * Returns the arc length on <i>this</i> NurbsCurve in the range given.
  * @param { Number }       iStartParam  The low curve parameter (the start of the arc)
  * @param { Number }       iEndParam    The high curve parameter (the end of the arc)
  * @example
  * var knots = [ {knotValue: 0.0, knotMult: 4}, {knotValue: 25.0, knotMult: 4} ];
  * var CPs = [ new DSMath.Point(2,2,0), new DSMath.Point(3,6,1), new DSMath.Point(4,5,0), new DSMath.Point(5,7,0) ];
  * var weights = [ 1, 1, 1, 1 ];
  * var degree = 3;
  * var n0 = new DSMath.NurbsCurve();
  * n0.setData(knots, CPs, weights, degree); // n0.OK === true
  * var t0 = n0.arcLength(0, 25.0); // t0 = 6.0297846530222285
  * @returns { Number } The arc length of the NurbsCurve
  * <br>
  */
  NurbsCurve.prototype.arcLength = function (iStartParam, iEndParam)
  {
    var oArcLength = 0.0;

    // Estimate of the full curve length
    // ---------------------------------

    var polyLineLength = 0.0;

    for (var iCP = 0; iCP < this.CPs.length - 1; iCP++)
      polyLineLength += this.CPs[iCP].distanceTo(this.CPs[iCP + 1]);

    var stepLengthResolution = 0.001; // Q48 - to decide how to choose this!

    // Compute the step size (in parameter space)
    // ------------------------------------------

    var paramLength = this.GetLastKnot() - this.GetFirstKnot();

    var stepSizeParam = paramLength * stepLengthResolution / polyLineLength;

    // Compute the number of steps
    // ---------------------------

    var nSteps = Math.ceil((iEndParam - iStartParam) / stepSizeParam);
    stepSizeParam = (iEndParam - iStartParam) / nSteps; // update the step size (for integer number of steps)

    // Compute the arc length (discretisation)
    // ---------------------------------------

    var prevPoint = this.evalPoint(iStartParam);

    for (var iStep = 1; iStep <= nSteps; iStep++)
    {
      var currParam = iStartParam + (iStep * stepSizeParam);

      var currPoint = this.evalPoint(currParam);

      oArcLength += prevPoint.distanceTo(currPoint);

      prevPoint.copy(currPoint);
    }

    return oArcLength;
  };

  /**
  * @private
  * @memberof DSMath.NurbsCurve
  * @method selfIntersections
  * @instance
  * @description
  * Returns the self intersections of <i>this</i> NurbsCurve.
  * @example
  * var knots = [ {knotValue: 0.0, knotMult: 3}, {knotValue: 0.5, knotMult: 1}, {knotValue: 1.0, knotMult: 3} ];
  * var CPs = [ new DSMath.Point(0,0,0), new DSMath.Point(4,8,0), new DSMath.Point(4,0,0), new DSMath.Point(0,8,0) ];
  * var weights = [ 1, 1, 1, 1 ];
  * var degree = 2;
  * var n0 = new DSMath.NurbsCurve();
  * n0.setData(knots, CPs, weights, degree); // n0.OK === true
  * var selfInter = n0.selfIntersections(); // selfInter should be [DSMath.Point2D(1/6, 5/6)]
  * @returns { DSMath.Point2D[] } An array of 2D points containing the self intersection parameter values
  * <br>
  */
  NurbsCurve.prototype.selfIntersections = function ()
  {
    var oSelfIntersections = [];

    for (var iKnot = 0; iKnot < this.KnotVec.length - 2; iKnot++)
    {
      var knotRange0 = [ this.KnotVec[iKnot].knotValue, this.KnotVec[iKnot + 1].knotValue ];

      for (var jKnot = iKnot + 1; jKnot < this.KnotVec.length - 1; jKnot++)
      {
        var knotRange1 = [ this.KnotVec[jKnot].knotValue, this.KnotVec[jKnot + 1].knotValue ];

        var intersect = new DSMath.Intersect(this, this, knotRange0[0], knotRange0[1], knotRange1[0], knotRange1[1]);
        var interSol = intersect.Run();

        for (var iSol = 0; iSol < interSol.length; iSol++)
        {
          // Avoid false intersections where adjancent arcs touch
          if (Math.abs(interSol[iSol].x - interSol[iSol].y) > intersect.tolLength)
            oSelfIntersections.push(interSol[iSol]);
        }
      }
    }

    return oSelfIntersections;
  };

  /**
  * @private
  * @memberof DSMath.NurbsCurve
  * @method ComputeArcPolyline
  * @instance
  * @description
  * Computes the set of lines joining subsequent control points
  * @example
  * var knots = [ {knotValue: 0.0, knotMult: 3}, {knotValue: 7.5, knotMult: 3} ];
  * var CPs = [ new DSMath.Point(2,2,0), new DSMath.Point(3,6,1), new DSMath.Point(4,5,0) ];
  * var weights = [ 1, 1, 1 ];
  * var degree = 2;
  * var n0 = new DSMath.NurbsCurve(knots, CPs, weights, degree); // n0.OK should be true
  * var polyline = n0.ComputePolyline(); // 2 lines: (2,2,0) -> (3,6,1) and (3,6,1) -> (4,5,0)
  * @returns { DSMath.Line[] } The array of DSMath.Line objects
  */
  NurbsCurve.prototype.ComputePolyline = function ()
  {
    var oLines = [];

    for (var i = 0; i < this.CPs.length - 1; i++)
    {
      var lineDir = new DSMath.Vector3D();
      this.CPs[i + 1].sub(this.CPs[i], lineDir);

      oLines.push(new DSMath.Line(this.CPs[i], lineDir));
    }

    return oLines;
  }

  DSMath.NurbsCurve = NurbsCurve;

  return NurbsCurve;
});
