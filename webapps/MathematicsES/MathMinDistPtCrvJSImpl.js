//===================================================================
// COPYRIGHT DASSAULT SYSTEMES 2018
//===================================================================
// JavaScript pt - curve minimum distance utility operator
//===================================================================
// 14/02/19 Q48 Creation (rename of MathMinDistJSImpl)
//===================================================================

define('MathematicsES/MathMinDistPtCrvJSImpl',
  ['MathematicsES/MathNameSpace',
   'MathematicsES/MathTypeCheck',
   'MathematicsES/MathTypeCheckInternal',
   'MathematicsES/MathPointJSImpl',
   'MathematicsES/MathVector3DJSImpl',
   'MathematicsES/MathLineJSImpl',
   'MathematicsES/MathCircleJSImpl',
   'MathematicsES/MathEllipseJSImpl',
   'MathematicsES/MathNurbsCurveJSImpl'
  ],

  function (DSMath, TypeCheck, TypeCheckInternal, Point, Vector3D, Line, Circle, Ellipse, NurbsCurve)
  {
    'use strict';

    /**
    * @private
    * @exports MinDistPtCrv
    * @class
    * @classdesc Utlity class to compute the minimum distance between a point and a curve
    *
    * @constructor
    * @constructordesc
    * The DSMath.MinDistPtCrv constructor creates a min-dist object from one
      curve (with start / end parameters) and a 3D point to be run.
    * @param {DSMath.Line | DSMath.Circle | DSMath.Ellipse | DSMath.NurbsCurve} iCrv The curve to compute the minimum distance to
    * @param {Number[]} iRange The start and end limits (curve parameters) of the curve
    * @param {DSMath.Point} iPt3D The target point
    * @memberof DSMath
    */

    var MinDistPtCrv = function (iCrv, iRange, iPt3D)
    {
      DSMath.TypeCheck(iCrv, true, [DSMath.Line, DSMath.Circle, DSMath.Ellipse, DSMath.NurbsCurve]);
      DSMath.TypeCheck(iRange, true, ['number'], 2);
      DSMath.TypeCheck(iPt3D, true, DSMath.Point);

      // Attributes
      // -------------------------------------

      // Public
      this.hasSol = false;

      this.crv = iCrv ? iCrv : null;

      this.range = [iRange[0], iRange[1]];

      this.pt3D = iPt3D ? iPt3D.clone() : null;

      this.tolLength = 1.0e-6; // length tolerance (X) for intersections - copied from SWx (put in static utility)?
      this.tolAngle = 1.0e-08; // tolerance for angles - how to choose this?

      /** @ignore */
      // Utility method (for internal use) - check if the current point is a solution
      this.IsSolution = function (iT, iDistVec, iCrvTgt)
      {
        DSMath.TypeCheckInternal(iT, true, 'number');
        DSMath.TypeCheckInternal(iDistVec, false, DSMath.Vector3D);
        DSMath.TypeCheckInternal(iCrvTgt, false, DSMath.Vector3D);

        var distVec;
        var crvTgt;

        if (iDistVec && iCrvTgt)
        {
          distVec = iDistVec;
          crvTgt = iCrvTgt;
        }
        else
        {
          distVec = new DSMath.Vector3D();
          crvTgt = new DSMath.Vector3D();

          this.Eval(iT, distVec, crvTgt);
        }

        // Check if the point is on the curve
        // ----------------------------------

        if (distVec.squareNorm() < this.tolLength * this.tolLength)
          return true;

        var angle = distVec.getAngleTo(crvTgt) - Math.PI / 2;
        if (Math.abs(angle) < this.tolAngle)
          return true;

        return false;
      }

      /** @ignore */
      // Utility method (for internal use) - evaluate the system of equations
      this.Eval = function (iT, oVec, oTgt, oIsSolution)
      {
        DSMath.TypeCheckInternal(iT, true, 'number');
        DSMath.TypeCheckInternal(oVec, false, DSMath.Vector3D);
        DSMath.TypeCheckInternal(oTgt, false, DSMath.Vector3D);
        DSMath.TypeCheckInternal(oIsSolution, false, [], []);

        // Compute: (target - curr-pt) * curr-tgt
        var crvPt = this.crv.evalPoint(iT);
        var crvTgt = this.crv.evalFirstDeriv(iT);

        var distVec = crvPt.sub(this.pt3D);

        if (oVec)
          oVec.copy(distVec);

        if (oTgt)
          oTgt.copy(crvTgt);

        if ((typeof oIsSolution !== 'undefined') && oIsSolution.length > 0)
        {
          oIsSolution[0] = this.IsSolution(iT, distVec, crvTgt);

          if (oIsSolution[0] === true)
            return 0.0;
        }

        // How to choose the "function to minimize:
        //   4 options:
        // 
        //     FX = 1: (T - C(t)) * C'(t)
        //     FX = 2: (T - C(t)) * C'(t) / ( |T - C(t)| * |C'(t)| )
        //     FX = 3: (T - C(t)) * C'(t) / ( |C'(t)| )
        //     FX = 4: (T - C(t)) * C'(t) / ( |T - C(t)| )

        // Currently, _FX = 3 is the most stable result

        if (this._FX === 4)
        {
          var oFX = distVec.dot(crvTgt) / distVec.norm();
          return oFX;
        }

        if (this._FX === 3)
        {
          var oFX = distVec.dot(crvTgt) / crvTgt.norm();
          return oFX;
        }

        if (this._FX === 2)
        {
          var oFX = distVec.dot(crvTgt) / (distVec.norm() * crvTgt.norm());
          return oFX;
        }

        var oDist = distVec.dot(crvTgt);
        return oDist;
      }

      /** @ignore */
      // Utility method (for internal use) - evaluate the gradient of the system of equations
      this.EvalGrad = function (iT, iFX, iDistVec, iTgt)
      {
        DSMath.TypeCheckInternal(iT, true, 'number');
        DSMath.TypeCheckInternal(iFX, true, 'number')
        DSMath.TypeCheckInternal(iDistVec, true, DSMath.Vector3D);
        DSMath.TypeCheckInternal(iTgt, true, DSMath.Vector3D);

        var crvDeriv2 = this.crv.evalSecondDeriv(iT);

        if (this._FX === 4)
        {
          var term1 = iDistVec.norm() * (iDistVec.dot(crvDeriv2) + iTgt.squareNorm());
          var term2 = iFX * iTgt.dot(iDistVec);

          var oDeriv = term1 - term2;
          oDeriv /= iDistVec.squareNorm();

          return oDeriv;
        }
        
        if (this._FX === 3)
        {
          var term1 = iTgt.norm() * (iDistVec.dot(crvDeriv2) + iTgt.squareNorm());
          var term2 = iFX * iTgt.dot(crvDeriv2);// / iTgt.squareNorm();

          var oDeriv = term1 - term2;
          oDeriv /= iTgt.squareNorm();

          return oDeriv;
        }

        if (this._FX === 2)
        {
          var term1 = iDistVec.dot(crvDeriv2) + iTgt.squareNorm();
          var coef2 = iFX;

          var term2 = iFX * iTgt.squareNorm();
          var term3 = iTgt.dot(crvDeriv2) * iDistVec.norm() / iTgt.norm();

          var oDeriv = term1 - (coef2 * (term2 + term3));
          oDeriv /= (iDistVec.norm() * iTgt.norm());

          return oDeriv;
        }

        var oDeriv = iDistVec.dot(crvDeriv2) + iTgt.squareNorm();
        return oDeriv;
      }

      /** @ignore */
      // Utility method (for internal use) - run the Newton solver
      this.Solve = function (iT)
      {
        DSMath.TypeCheckInternal(iT, true, 'number');

        if (this._DEBUG >= 1)
          console.log("MinDistPtCrv::Solve from " + iT);

        // Check if the init is already a solution
        // ---------------------------------------

        if (this.IsSolution(iT) === true)
        {
          if (this._DEBUG >= 1)
            console.log("  Init is a solution --> stop processing");

          return iT;
        }

        // Setup the Newton
        // ----------------

        var maxIter = 100; // Q48 - how to decide this?

        var currT = iT;

        var counter = 0;
        while (counter < maxIter)
        {
          // Evaluate the min-distance equation
          // ----------------------------------

          var distVec = new DSMath.Vector3D();
          var crvTgt =  new DSMath.Vector3D();

          var isSolution = [false];
          var fX = this.Eval(currT, distVec, crvTgt, isSolution);

          if (this._DEBUG >= 2)
          {
            console.log("   Iteration " + counter);
            console.log("     at " + currT + "  (= " + this.crv.evalPoint(currT).getArray() + ")");
          }

          // Check if we have found a solution
          // ---------------------------------

          if (isSolution[0] === true)
          {
            if (this._DEBUG >= 2)
              console.log("       --> has converged!");

            break;
          }

          if (this._DEBUG >= 2)
          {
            console.log("       --> vec to target: " + distVec.getArray());
            console.log("       --> crv tangent: " + crvTgt.getArray());
            console.log("       --> fX = " + fX);
          }

          // Compute the step (Newton)
          // -------------------------

          var currGrad = this.EvalGrad(currT, fX, distVec, crvTgt);
          var currStep = -fX / currGrad;

          if (this._DEBUG >= 2)
          {
            console.log("     --> gradient = " + currGrad);
            console.log("     --> step of " + currStep);
          }

          if (isNaN(currGrad) || isNaN(currStep))
          {
            if (this._DEBUG >= 2)
              console.log("         --> invalid step")

            break;
          }

          // Update the current point
          currT += currStep;

          // Restrict to the domain
          currT = this.PutInRange(this.crv, currT, this.range);

          counter++;
        }

        var oSol = currT;

        if (this._DEBUG >= 1)
          console.log("MinDistPtCrv::Solve finished at " + oSol);

        return oSol;
      }

      /** @ignore */
      // Utility method (for internal use) - compute analytic solutions (line and circle)
      this.ComputeAnalytic = function (oSol)
      {
        DSMath.TypeCheckInternal(oSol, true, ['number'], []);

        if (this.crv.constructor === Line)
        {
          var vFromOrigin = this.pt3D.sub(this.crv.origin);

          // The distance along the line is vFromOrigin * direction / |direction|
          //   --> the parameter along the line is "distance along the line" / |direction|

          var paramOnLine = vFromOrigin.dot(this.crv.direction) / this.crv.direction.squareNorm();
          oSol.push(paramOnLine);

          return true;
        }

        if (this.crv.constructor === Circle)
        {
          var vFromCentre = this.pt3D.sub(this.crv.center);

          var dir = [new DSMath.Vector3D(), new DSMath.Vector3D()];
          this.crv.getDirections(dir);

          var cosAlpha = vFromCentre.dot(dir[0]);
          var sinAlpha = vFromCentre.dot(dir[1]);

          var alpha = Math.atan2(sinAlpha, cosAlpha);
          alpha = this.crv.putInRange(alpha, this.range);

          oSol.push(alpha);

          return true;
        }

        return false;
      }
      
      /** @ignore */
      // Utility method (for internal use) - compute relevant inits
      this.ComputeInits = function (oInitPts)
      {
        DSMath.TypeCheckInternal(oInitPts, true, ['number'], []);

        // For Nurbs curve - just put an init in the middle of each arc

        if (this.crv.constructor === NurbsCurve)
        {
          var nKnots = this.crv.KnotVec.length;
          for (var iArc = 0; iArc < nKnots - 1; iArc++)
          {
            var midArc = (this.crv.KnotVec[iArc + 1].knotValue + this.crv.KnotVec[iArc].knotValue) / 2;
            oInitPts.push(midArc);
          }

          return true;
        }

        if (this.crv.constructor === Ellipse)
        {
          var vFromCentre = this.pt3D.sub(this.crv.center);

          var dir = [new DSMath.Vector3D(), new DSMath.Vector3D()];
          this.crv.getDirections(dir);

          var cosAlpha = vFromCentre.dot(dir[0]);
          var sinAlpha = vFromCentre.dot(dir[1]);

          var alpha = Math.atan2(sinAlpha, cosAlpha);
          alpha = this.crv.putInRange(alpha, this.range);

          oInitPts.push(alpha);

          return true;
        }

        return false;
      }
          
      // ---------------------------------------------------------------------------------
      // DEBUG
      // ---------------------------------------------------------------------------------
      this._DEBUG = 0;
      
      //this._FX = 1; // (E-P).E'
      //this._FX = 2; // (E-P).E' / (|E-P||E'|)
      this._FX = 3; // (E-P).E' / |E'|
      //this._FX = 4; // (E-P).E' / (|E-P|) - same as minimising |E-P|

    };

    // ---------------------------------------------------------------------------------
    // Data members
    // ---------------------------------------------------------------------------------

    MinDistPtCrv.prototype.crv = null;
    MinDistPtCrv.prototype.range = null;
    MinDistPtCrv.prototype.hasSol = null;
    MinDistPtCrv.prototype.pt3D = null;

    // ---------------------------------------------------------------------------------
    // Private methods
    // ---------------------------------------------------------------------------------

    /** @ignore */
    // Utility method (for internal use) - put the parameter in the given range
    // accounting for periodics
    MinDistPtCrv.prototype.PutInRange = function (iCurve, iParam, iRange)
    {
      DSMath.TypeCheck(iCurve, true, [DSMath.Line, DSMath.Circle, DSMath.Ellipse, DSMath.NurbsCurve]);
      DSMath.TypeCheck(iParam, true, 'number');
      DSMath.TypeCheck(iRange, true, ['number'], 2);

      // Treat periodics
      if (iCurve.constructor === Ellipse || iCurve.constructor === Circle)
      {
        var oParam = iCurve.putInRange(iParam, iRange);
        return oParam;
      }

      var oParam = iParam;
      
      if (iCurve.constructor === NurbsCurve && iCurve.IsPeriodic === true)
        oParam = iCurve.putInPrincipalRange(iParam);

      oParam = Math.max(iRange[0], Math.min(iRange[1], oParam));
      return oParam;
    }

    // ---------------------------------------------------------------------------------
    // Public methods
    // ---------------------------------------------------------------------------------

    /**
    * @private
    * @memberof DSMath.MinDistPtCrv
    * @method Run
    * @instance
    * @description
    * Runs the minimum distance operator
    * @param {Number} [iT] An init points to start from
    * @example
    * var e0 = new DSMath.Ellipse(50.0, 5.0).setCenter(0.0, 0.0, 0.0).setVectors(1,0,0, 0,1,0);
    * var m0 = new DSMath.MinDistPtCrv(e0, [0.0, DSMath.constants.PI2], new DSMath.Point(60.0, 0.0, 0.0));
    * var sol = m0.Run(); // sol = 0.0;
    * @returns {Number} The curve parameter corresponding to the point of minimum distance
    */
    MinDistPtCrv.prototype.Run = function (iT)
    {
      DSMath.TypeCheck(iT, false, 'number');

      if (this._DEBUG >= 1)
      {
        console.log("MinDistPtCrv::Run in mode " + this._FX);
        console.log("\ttarget is " + this.pt3D.getArray());
      }

      this.hasSol = false;

      var listSol = [];

      // Analytical configuration
      // ------------------------

      this.hasSol = this.ComputeAnalytic(listSol);

      if (this.hasSol)
        return listSol[0];

      // Remaining configurations require a solver
      // -----------------------------------------

      var initPts = new Array();
      if (iT)
        initPts[0] = iT;
      else
        this.ComputeInits(initPts);

      var bestSol = 0.0;
      var minDist = -1.0; // initialize negative

      for (var i = 0; i < initPts.length; i++)
      {
        if (this._DEBUG >= 1)
          console.log("MinDistPtCrv::Run solve from init-" + i + " at: " + initPts[i] + " (" + this.crv.evalPoint(initPts[i]).getArray() + ")");

        var currSol = this.Solve(initPts[i]);
        var isSol = this.IsSolution(currSol);

        if (isSol === true)
        {
          if (this._DEBUG >= 1)
            console.log("MinDistPtCrv::Run solve from init-" + i + " converged");

          var currDist = this.crv.evalPoint(currSol).sub(this.pt3D).norm();
          if (currDist < minDist || minDist < 0.0)
          {
            if (this._DEBUG >= 1)
              console.log("MinDistPtCrv::Run --> store as current best solution");

            this.hasSol = true;
            minDist = currDist;
            bestSol = currSol;
          }
        }
        else
        {
          if (this._DEBUG >= 1)
            console.error("MinDistPtCrv::Run solve from init-" + i + " did not converge");
        }
      }

      return bestSol;
    };

    DSMath.MinDistPtCrv = MinDistPtCrv;

    return MinDistPtCrv;
  }
);
