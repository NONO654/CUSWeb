//===================================================================
// COPYRIGHT DASSAULT SYSTEMES 2018
//===================================================================
// JavaScript pt - curve minimum distance utility operator
//===================================================================
// 15/02/19 Q48 Creation
//===================================================================

define('MathematicsES/MathMinDistCrvCrvJSImpl',
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
    * @exports MinDistCrvCrv
    * @class
    * @classdesc Utlity class to compute the minimum distance between a point and a curve
    *
    * @constructor
    * @constructordesc
    * The DSMath.MinDistCrvCrv constructor creates a min-dist object from two
    * curves (with start / end parameters) to be run.
    * @param {DSMath.Line | DSMath.Circle | DSMath.Ellipse | DSMath.NurbsCurve} iCrv1 The first curve
    * @param {Number[]} iRange1 The start and end limits (curve parameters) of the first curve
    * @param {DSMath.Line | DSMath.Circle | DSMath.Ellipse | DSMath.NurbsCurve} iCrv2 The first curve
    * @param {Number[]} iRange2 The start and end limits (curve parameters) of the first curve
    * @memberof DSMath
    */

    var MinDistCrvCrv = function (iCrv1, iRange1, iCrv2, iRange2)
    {
      DSMath.TypeCheck(iCrv1, true, [DSMath.Line, DSMath.Circle, DSMath.Ellipse, DSMath.NurbsCurve]);
      DSMath.TypeCheck(iRange1, true, ['number'], 2);
      DSMath.TypeCheck(iCrv2, true, [DSMath.Line, DSMath.Circle, DSMath.Ellipse, DSMath.NurbsCurve]);
      DSMath.TypeCheck(iRange2, true, ['number'], 2);


      // Attributes
      // -------------------------------------

      // Public
      this.hasSol = false;

      this.crv1 = iCrv1 ? iCrv1 : null;
      this.crv2 = iCrv2 ? iCrv2 : null;

      this.range1 = [iRange1[0], iRange1[1]];
      this.range2 = [iRange2[0], iRange2[1]];

      this.tolLength = 1.0e-6; // length tolerance (X) for intersections - copied from SWx (put in static utility)?
      this.tolAngle = 1.0e-08; // tolerance for angles - how to choose this?

      // Internal methods
      // -------------------------------------

      /** @ignore */
      // Utility method (for internal use) - check if the current point is a solution
      this.IsSolution = function (iPt, iDistVec, iCrvTgt)
      {
        DSMath.TypeCheckInternal(iPt, true, DSMath.Point2D);
        DSMath.TypeCheckInternal(iDistVec, false, DSMath.Vector3D);
        DSMath.TypeCheckInternal(iCrvTgt, false, [DSMath.Vector3D], 2);

        var distVec = iDistVec;
        var crvTgt = iCrvTgt;

        if (distVec === undefined || crvTgt === undefined)
        {
          distVec = new DSMath.Vector3D();

          crvTgt = [];
          crvTgt.push(new DSMath.Vector3D());
          crvTgt.push(new DSMath.Vector3D());

          this.Eval(iPt, distVec, crvTgt);
        }

        // Check if the two curves are close
        // ---------------------------------

        if (distVec.squareNorm() < this.tolLength * this.tolLength)
          return true;

        // Check if the chord is perpendicular
        // -----------------------------------

        var isSolution = true;

        for (var iCrv = 0; iCrv < 2 && isSolution === true; iCrv++)
        {
          var angle = distVec.getAngleTo(crvTgt[iCrv]) - Math.PI / 2;
          if (Math.abs(angle) > this.tolAngle)
            isSolution = false;
        }

        return isSolution;
      }

      /** @ignore */
      // Utility method (for internal use) - evaluate the system of equations
      this.Eval = function (iPt, oVec, oTgt, oIsSolution)
      {
        DSMath.TypeCheckInternal(iPt, true, DSMath.Point2D);
        DSMath.TypeCheckInternal(oVec, false, DSMath.Vector3D);
        DSMath.TypeCheckInternal(oTgt, false, [DSMath.Vector3D], 2);
        DSMath.TypeCheckInternal(oIsSolution, false, [], []);

        // Compute: [(pt(1) - pt(2)) * curr-tgt(1)], [(pt(1) - pt(2)) * curr-tgt(2)]
        // --------------------------------------------------------------------------

        var crvPt = [];
        crvPt.push(this.crv1.evalPoint(iPt.x));
        crvPt.push(this.crv2.evalPoint(iPt.y));

        var crvTgt = [];
        crvTgt.push(this.crv1.evalFirstDeriv(iPt.x));
        crvTgt.push(this.crv2.evalFirstDeriv(iPt.y));

        var distVec = crvPt[1].sub(crvPt[0]);

        if (oVec)
          oVec.copy(distVec);

        if (oTgt)
        {
          oTgt[0].copy(crvTgt[0]);
          oTgt[1].copy(crvTgt[1]);
        }

        if ((typeof oIsSolution !== 'undefined') && oIsSolution.length > 0)
        {
          oIsSolution[0] = this.IsSolution(iPt, distVec, crvTgt);

          if (oIsSolution[0] === true)
            return new DSMath.Vector2D();
        }

        var oFX1 = distVec.dot(crvTgt[0]) / crvTgt[0].norm();
        var oFX2 = distVec.dot(crvTgt[1]) / crvTgt[1].norm();

        return new DSMath.Vector2D(oFX1, oFX2);
      }

      /** @ignore */
      // Utility method (for internal use) - evaluate the gradient of the system of equations
      this.EvalStep = function (iPt, iFX, iDistVec, iTgt, oStep)
      {
        DSMath.TypeCheckInternal(iPt, true, DSMath.Point2D);
        DSMath.TypeCheckInternal(iFX, true, DSMath.Vector2D)
        DSMath.TypeCheckInternal(iDistVec, true, DSMath.Vector3D);
        DSMath.TypeCheckInternal(iTgt, true, [DSMath.Vector3D], 2);

        var crvSecondDeriv = [];
        crvSecondDeriv.push(this.crv1.evalSecondDeriv(iPt.x));
        crvSecondDeriv.push(this.crv2.evalSecondDeriv(iPt.y));

        // F(x, y) = [(pt(1) - pt(2)) * tgt(1) / |tgt(1)|] + [(pt(1) - pt(2)) * tgt(2) / |tgt(2)|]
        // F(x, y) = (pt(1) - pt(2) * (nTgt(1)) + nTgt(2))
        //      nTgt(1) = tgt(1) / |tgt(1)| the normalised tangent vector of the curve
        //      nTgt(2) = tgt(2) / |tgt(2)| the normalised tangent vector of the curve

        // dF/dx = [(pt(1) - pt(2)) * d(nTgt(1)) / dx] + [tgt(1) * (nTgt(1) + nTgt(2))]
        //
        // d(|tgt(1)|/dx = tgt(1) * secondDeriv(1) / |tgt(1)|
        //
        // d(nTgt(1))/dx = [ ((|tgt(1)|*secondDeriv(1)) - (tgt(1)* nTgt(1)*secondDeriv(1)) ] / |tgt(1)|^2
        //

        var tgtNorm = [iTgt[0].norm(), iTgt[1].norm()];

        var tgtNormDeriv = [];
        tgtNormDeriv[0] = iTgt[0].dot(crvSecondDeriv[0]) / tgtNorm[0];
        tgtNormDeriv[1] = iTgt[1].dot(crvSecondDeriv[1]) / tgtNorm[1];

        var normTgt = [];
        normTgt[0] = iTgt[0].clone().divideScalar(tgtNorm[0]);
        normTgt[1] = iTgt[1].clone().divideScalar(tgtNorm[1]);

        var normTgtDeriv = []; // derivative of the normalised tangent
        normTgtDeriv[0] = (crvSecondDeriv[0].clone().multiplyScalar(tgtNorm[0])).sub(iTgt[0].clone().multiplyScalar(tgtNormDeriv[0])).divideScalar(tgtNorm[0] * tgtNorm[0]);
        normTgtDeriv[1] = (crvSecondDeriv[1].clone().multiplyScalar(tgtNorm[1])).sub(iTgt[1].clone().multiplyScalar(tgtNormDeriv[1])).divideScalar(tgtNorm[1] * tgtNorm[1]);

        var derivs = [];

        derivs[0] = new DSMath.Vector2D();
        derivs[0].x = iDistVec.dot(normTgtDeriv[0]) - iTgt[0].norm();
        derivs[0].y = iTgt[1].dot(normTgt[0]);

        derivs[1] = new DSMath.Vector2D();
        derivs[1].x = -iTgt[0].dot(normTgt[1]);
        derivs[1].y = iDistVec.dot(normTgtDeriv[1]) + iTgt[1].norm();

        // Jakobian is ( derivs[0].x   derivs[0].y )
        //             ( derivs[1].x   derivs[1].y )

        var detJakobian = derivs[0].cross(derivs[1]);

        if (Math.abs(detJakobian) < 1.0e-12) // Q48 - how to decide this?
          return false;

        var invDet = 1.0 / detJakobian;

        // Jakobian inverse is intDet * (  derivs[1].y   -derivs[0].y )
        //                              ( -derivs[1].x    derivs[0].x )

        var mat1 = new DSMath.Vector2D( derivs[1].y, -derivs[0].y);
        var mat2 = new DSMath.Vector2D(-derivs[1].x,  derivs[0].x);

        oStep.x = -invDet * iFX.dot(mat1);
        oStep.y = -invDet * iFX.dot(mat2);

        return true;
      }

      /** @ignore */
      // Utility method (for internal use) - run the Newton solver
      this.Solve = function (iInit, oSol)
      {
        DSMath.TypeCheckInternal(iInit, true, DSMath.Point2D);
        DSMath.TypeCheckInternal(oSol, true, []);

        if (this._DEBUG.IsActive(2))
        {
          console.log("");
          console.log("  MinDistCrvCrv::Solve from " + iInit.getArray());
        }

        // Check if the init is already a solution
        // ---------------------------------------

        if (this.IsSolution(iInit) === true)
        {
          if (this._DEBUG.IsActive(2))
            console.log("    Init is a solution --> stop processing");

          oSol.push(iInit.clone());
          return true;
        }

        // Setup the Newton
        // ----------------

        var maxIter = 100; // Q48 - how to decide this?

        var currPt = iInit.clone();

        var converged = false;

        var counter = 0;
        while (counter < maxIter)
        {
          // Evaluate the min-distance equation
          // ----------------------------------

          var distVec = new DSMath.Vector3D();
          var crvTgt =  [new DSMath.Vector3D(), new DSMath.Vector3D()];

          var isSolution = [false];
          var fX = this.Eval(currPt, distVec, crvTgt, isSolution);

          if (this._DEBUG.IsActive(3))
          {
            console.log("     Iteration " + counter);
            console.log("       at " + currPt.getArray());
            console.log("         --> " + this.crv1.evalPoint(currPt.x).getArray() + " on curve-1");
            console.log("         --> " + this.crv2.evalPoint(currPt.y).getArray() + " on curve-2");
          }

          // Check if we have found a solution
          // ---------------------------------

          if (isSolution[0] === true)
          {
            if (this._DEBUG.IsActive(3))
              console.log("         --> has converged!");

            converged = true;

            break;
          }

          if (this._DEBUG.IsActive(3))
          {
            console.log("         --> separation vector: " + distVec.getArray());
            console.log("         --> crv1 tangent: " + crvTgt[0].getArray());
            console.log("         --> crv2 tangent: " + crvTgt[1].getArray());
            console.log("         --> fX = " + fX.getArray());
          }

          // Compute the step (Newton)
          // -------------------------

          var currStep = new DSMath.Vector2D();
          var stepOK = this.EvalStep(currPt, fX, distVec, crvTgt, currStep);

          if (this._DEBUG.IsActive(3))
            console.log("      step is " + stepOK + " (" + currStep.getArray() + ")");

          if (stepOK === false)
            break;

          if (isNaN(currStep.x) || isNaN(currStep.y))
          {
            if (this._DEBUG.IsActive(3))
              console.log("           --> invalid step")

            break;
          }

          // Check if we are trying to go out of the domain
          // ----------------------------------------------

          var processedDomain = false;
          
          for (var iCrv = 0; iCrv < 2 && !processedDomain; iCrv++)
          {
            var currParam = iCrv === 0 ? currPt.x : currPt.y;
            var currDir   = iCrv === 0 ? currStep.x : currStep.y;
            var domain    = iCrv === 0 ? this.range1 : this.range2;

            var atDomain = false;
            if (currParam <= domain[0] && currDir < 0) // below lower bound
              atDomain = true;

            if (currParam >= domain[1] && currDir > 0) // above upper bound
              atDomain = true;

            if (atDomain)
            {
              if (this._DEBUG.IsActive(2))
                console.log("  MinDistCrvCrv::Solve at domain limit for curve-" + iCrv);

              var limitCurve = iCrv === 0 ? this.crv1 : this.crv2;
              var otherCurve = iCrv === 1 ? this.crv1 : this.crv2;

              var otherDomain = iCrv === 1 ? this.range1 : this.range2;

              var target = limitCurve.evalPoint(currParam);

              var minDist = new DSMath.MinDistPtCrv(otherCurve, otherDomain, target);
              var solDomain = minDist.Run();

              if (!minDist.hasSol)
              {
                if (this._DEBUG.IsActive(2))
                  console.log("  MinDistCrvCrv::Solve at domain limit for curve-" + iCrv + " failed to converge");
                
                return false;
              }

              var solData = [0.0, 0.0];
              solData[iCrv] = currParam;
              solData[1 - iCrv] = solDomain;

              currPt.setFromArray(solData);

              processedDomain = true;
            }
          }

          if (processedDomain)
          {
            converged = true;
            break;
          }

          // Update the current point
          // ------------------------

          currPt.addVector(currStep);

          // Restrict to the domain
          currPt.x = this.PutInRange(this.crv1, currPt.x, this.range1);
          currPt.y = this.PutInRange(this.crv2, currPt.y, this.range2);

          counter++;
        }

        if (this._DEBUG.IsActive(2))
        {
          console.log("  MinDistCrvCrv::Solve finished at " + currPt.getArray());
          console.log("                     on crv-1 at: " + this.crv1.evalPoint(currPt.x).getArray());
          console.log("                     on crv-2 at: " + this.crv2.evalPoint(currPt.y).getArray());
        }
                
        if (counter === maxIter)
        {
          if (this._DEBUG.IsActive(2))
            console.log("    Failed to converge after " + maxIter + " (= max) iterations");

          return false;
        }
                
        if (converged === false)
        {
          if (this._DEBUG.IsActive(2))
            console.log("    Failed to converge after " + counter + " iterations");

          return false;
        }

        if (this._DEBUG.IsActive(2))
          console.log("    Converged after " + counter + " iterations");

        oSol.push(currPt.clone());
        return true;
      }

      /** @ignore */
      // Utility method (for internal use) - compute analytic solutions (line and circle)
      this.ComputeAnalytic = function (oSol)
      {
        DSMath.TypeCheckInternal(oSol, true, []);

        if (this.crv1.constructor == DSMath.Line && this.crv2.constructor == DSMath.Line)
        {
          // Line1: P1 = O1 + x*d1 
          // Line2: P2 = O2 + y*d2
          // At the minimum (P1 - P2).d1 = 0 and (P1 - P2).d2 = 0
          //   --> ( d1.d1  -d1.d2 ) * ( x ) = ( (P2-P1).d1 )
          //       ( d1.d2  -d2.d2 )   ( y )   ( (P2-P1).d2 )

          //   --> invert matrix and solve

          var d1 = this.crv1.direction.clone();
          var d2 = this.crv2.direction.clone();
          var O1 = this.crv1.origin.clone();
          var O2 = this.crv2.origin.clone();

          var mat2x2 = new DSMath.Matrix2x2( d1.dot(d1), -d1.dot(d2), d1.dot(d2), -d2.dot(d2) );
          mat2x2.inverse(); // invert the matrix to solve
          mat2x2.transpose(); // transpose because we can only read out the columns not the rows!
          
          var firstRow = mat2x2.getFirstColumn();
          var secondRow = mat2x2.getSecondColumn();

          var deltaO = O2.sub(O1);
          var vecSol = new DSMath.Vector2D(deltaO.dot(d1), deltaO.dot(d2));

          var param1 = firstRow.dot(vecSol);
          var param2 = secondRow.dot(vecSol);

          oSol.push(new DSMath.Point2D(param1, param2));

          return true;
        }

        if (this.crv1.constructor == DSMath.Circle && this.crv2.constructor == DSMath.Circle)
        {
          // The minimum distance is on the line joining the centres
          var O1 = this.crv1.center.clone();
          var O2 = this.crv2.center.clone();

          var deltaO = O2.sub(O1);//.normalise();

          var dir1 = this.crv1.getDirections();
          var angle1 = dir1[0].getAngleTo(deltaO);
          angle1 = this.crv1.putInRange(angle1, [0.0, DSMath.constants.PI2]); // put in the principle range

          var dir2 = this.crv2.getDirections();
          var angle2 = dir2[0].getAngleTo(deltaO) + DSMath.constants.PI;
          angle2 = this.crv2.putInRange(angle2, [0.0, DSMath.constants.PI2]); // put in the principle range

          oSol.push(new DSMath.Point2D(angle1, angle2));
          return true;
        }

        var isLineCircle = 0;
        if (this.crv1.constructor == DSMath.Circle && this.crv2.constructor == DSMath.Line)
          isLineCircle = 1;

        if (this.crv1.constructor == DSMath.Line && this.crv2.constructor == DSMath.Circle)
          isLineCircle = 2;

        if (isLineCircle > 0)
        {

          // Line P1 = O1 + x*d1
          //  At the minimum the vector from the circle centre to the line is perpendicular to the line direction
          //    (P1 - O2) * d1 = 0
          
          var line = (isLineCircle === 1) ? this.crv2 : this.crv1;
          var circle = (isLineCircle === 1) ? this.crv1 : this.crv2;

          var OL = line.origin.clone();
          var OC = circle.center.clone();

          var dirL = line.direction.clone();

          var deltaO = OC.sub(OL);

          var paramLine = deltaO.dot(dirL) / dirL.squareNorm();

          var ptLine = line.evalPoint(paramLine);

          var dirC = circle.getDirections();

          var angleC = dirC[0].getAngleTo(ptLine.sub(OC));

          var ptSol = new DSMath.Point2D();
          if (isLineCircle === 1)
          {
            ptSol.x = angleC;
            ptSol.y = paramLine;
          }
          else
          {
            ptSol.x = paramLine;
            ptSol.y = angleC;
          }

          oSol.push(ptSol);
          return true;
        }

        return false;
      }

      /** @ignore */
      // Utility method (for internal use) - compute relevant inits
      this.ComputeInits = function (oInitPts)
      {
        DSMath.TypeCheckInternal(oInitPts, true, [], []);

        var curves = [this.crv1, this.crv2];
        var ranges = [this.range1, this.range2];

        // Case with at least one Nurbs
        // ----------------------------

        if (curves[0].constructor == DSMath.NurbsCurve || curves[1].constructor == DSMath.NurbsCurve)
          return this.ComputeInits_Nurbs(oInitPts);

        // Case with at least one line (with ellipse or circle)
        // ----------------------------------------------------

        if (curves[0].constructor == DSMath.Line || curves[1].constructor == DSMath.Line)
          return this.ComputeInits_Line(oInitPts);

        // Circle / ellipse or ellipse / circle case
        // -----------------------------------------

        var isCircleEllipse0 = (curves[0].constructor == DSMath.Circle || curves[0].constructor == DSMath.Ellipse);
        var isCircleEllipse1 = (curves[1].constructor == DSMath.Circle || curves[1].constructor == DSMath.Ellipse);

        if (isCircleEllipse0 && isCircleEllipse1)
          return this.ComputeInits_WithCentres(oInitPts);

        return false;
      }

      // Compute inits where both curves are a circle or an ellipse
      // ----------------------------------------------------------

      this.ComputeInits_WithCentres = function (oInitPts)
      {
        DSMath.TypeCheckInternal(oInitPts, true, [], []);

        // Compute the line joining the centres
        // ------------------------------------

        var lineDirection = this.crv2.center.sub(this.crv1.center);
        var line = new DSMath.Line(this.crv1.center, lineDirection.clone().normalize());

        // Intersect the line with the two curves
        // --------------------------------------

        var curves = [this.crv1, this.crv2];
        var ranges = [this.range1, this.range2];

        var initData = [0.0, 0.0];

        for (var iCrv = 0; iCrv < 2; iCrv++)
        {
          var intersect = new DSMath.Intersect(curves[iCrv], line, ranges[iCrv][0], ranges[iCrv][1], 0.0, lineDirection.norm());
          var interSol = intersect.Run();
        
          if (interSol.length === 1) // expect only one solution!
            initData[iCrv] = interSol[0].x;
        }
        
        var init = new DSMath.Point2D().setFromArray(initData);
        oInitPts.push(init);

        return oInitPts;
      }

      // Compute inits where one curve is a Line and the other is an ellipse or circle
      // -----------------------------------------------------------------------------

      this.ComputeInits_Line = function (oInitPts)
      {
        DSMath.TypeCheckInternal(oInitPts, true, [], []);

        var indexLine;
        if (this.crv1.constructor == DSMath.Line)
          indexLine = 0;
        else if (this.crv2.constructor == DSMath.Line)
          indexLine = 1;
        else
          return false;

        var curves = [this.crv1, this.crv2];
        var ranges = [this.range1, this.range2];

        var lineCurve = curves[indexLine];
        var otherCurve = curves[1 - indexLine];

        // Compute min distance between the line and centre
        // ------------------------------------------------

        var minDistLine = new DSMath.MinDistPtCrv(lineCurve, ranges[indexLine], otherCurve.center);
        var initLine = minDistLine.Run();

        // Compute the min distance between the init on the line and the other curve
        // -------------------------------------------------------------------------

        var targetLine = lineCurve.evalPoint(initLine);

        var minDistOther = new DSMath.MinDistPtCrv(otherCurve, ranges[1 - indexLine], targetLine);
        var initOther = minDistOther.Run();
        
        var initData = [0.0, 0.0];
        initData[    indexLine] = initLine;
        initData[1 - indexLine] = initOther;

        var init = new DSMath.Point2D().setFromArray(initData);
        oInitPts.push(init);

        return oInitPts;
      }

      // Compute inits where (at least) one curve is a Nurbs
      // ---------------------------------------------------

      this.ComputeInits_Nurbs = function (oInitPts)
      {
        DSMath.TypeCheckInternal(oInitPts, true, [], []);

        var indexNurbs;
        if (this.crv1.constructor == DSMath.NurbsCurve)
          indexNurbs = 0;
        else if (this.crv2.constructor == DSMath.NurbsCurve)
          indexNurbs = 1;
        else
          return false;

        var curves = [this.crv1, this.crv2];
        var ranges = [this.range1, this.range2];

        var nurbsCurve = curves[indexNurbs];
        var otherCurve = curves[1 - indexNurbs];

        // Build the init list for the main Nurbs
        // --------------------------------------

        var initNurbs = [];

        var nKnots = nurbsCurve.KnotVec.length;
        for (var iArc = 0; iArc < nKnots - 1; iArc++)
        {
          var startArc = nurbsCurve.KnotVec[iArc].knotValue;
          initNurbs.push(startArc);

          var midArc = (nurbsCurve.KnotVec[iArc + 1].knotValue + nurbsCurve.KnotVec[iArc].knotValue) / 2;
          initNurbs.push(midArc);
        }

        initNurbs.push(nurbsCurve.GetLastKnot());

        // Nurbs - Nurbs case
        // ------------------

        if (otherCurve.constructor == NurbsCurve)
        {
          var initOther = [];

          var nKnots = otherCurve.KnotVec.length;
          for (var iArc = 0; iArc < nKnots - 1; iArc++)
          {
            var startArc = otherCurve.KnotVec[iArc].knotValue;
            initOther.push(startArc);

            var midArc = (otherCurve.KnotVec[iArc + 1].knotValue + otherCurve.KnotVec[iArc].knotValue) / 2;
            initOther.push(midArc);
          }

          initOther.push(otherCurve.GetLastKnot());

          for (var iInit = 0; iInit < initNurbs.length; iInit++)
          {
            for (var jInit = 0; jInit < initOther.length; jInit++)
            {
              var initData = [0.0, 0.0];
              initData[indexNurbs] = initNurbs[iInit];
              initData[1 - indexNurbs] = initOther[jInit];

              var init = new DSMath.Point2D().setFromArray(initData);
              oInitPts.push(init);
            }
          }

          return true;
        }

        // Nurbs - "other" case
        // --------------------

        for (var iInit = 0; iInit < initNurbs.length; iInit++)
        {
          var target = nurbsCurve.evalPoint(initNurbs[iInit]);

          var minDist = new DSMath.MinDistPtCrv(curves[1 - indexNurbs], ranges[1 - indexNurbs], target);
          var otherInit = minDist.Run();

          var initData = [0.0, 0.0];
          initData[indexNurbs] = initNurbs[iInit];
          initData[1 - indexNurbs] = otherInit;

          var init = new DSMath.Point2D().setFromArray(initData);
          oInitPts.push(init);
        }

        return true;
      }

      // ---------------------------------------------------------------------------------
      // DEBUG
      // ---------------------------------------------------------------------------------
      //this._DEBUG = 0;
      this._DEBUG = new DSMath.DebugUtils();

    };

    // ---------------------------------------------------------------------------------
    // Data members
    // ---------------------------------------------------------------------------------

    MinDistCrvCrv.prototype.crv1 = null;
    MinDistCrvCrv.prototype.crv2 = null;
    MinDistCrvCrv.prototype.range1 = null;
    MinDistCrvCrv.prototype.range2 = null;
    
    MinDistCrvCrv.prototype.hasSol = null;
    
    // ---------------------------------------------------------------------------------
    // Private methods
    // ---------------------------------------------------------------------------------

    /** @ignore */
    // Utility method (for internal use) - put the parameter in the given range
    // accounting for periodics
    MinDistCrvCrv.prototype.PutInRange = function (iCurve, iParam, iRange)
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
    * @memberof DSMath.MinDistCrvCrv
    * @method Run
    * @instance
    * @description
    * Runs the minimum distance operator
    * @param {Number} [iT] An init points to start from
    * @example
    * var e0 = new DSMath.Ellipse(12.0, 5.0).setCenter(10,0,0).setVectors(1,0,0, 0,1,0);
    * var c0 = new DSMath.Circle(5.0).setCenter(10,15,0).setVectors(1,0,0, 0,1,0);
    * var geomEllipse = { _Geometry: e0, _Range: [0, DSMath.constants.PI2] };
    * var geomCircle  = { _Geometry: c0, _Range: [0, DSMath.constants.PI2] };
    * var m0 = new DSMath.MinDist(geomEllipse, geomCircle);
    * var sol = m0.Run(); // sol = new DSMath.Point2D(DSMath.constants.PI / 2, 3 * DSMath.constants.PI / 2);
    * @returns {Number} The curve parameter corresponding to the point of minimum distance
    */
    MinDistCrvCrv.prototype.Run = function (iT)
    {
      DSMath.TypeCheck(iT, false, DSMath.Point2D);

      if (this._DEBUG.IsActive(1))
        console.log("MinDistCrvCrv::Run between " + this._DEBUG.PrintType(this.crv1) + " and " + this._DEBUG.PrintType(this.crv2));

      this.hasSol = false;

      var listSol = [];

      // Analytical configuration
      // ------------------------

      var isTreated = this.ComputeAnalytic(listSol);

      if (isTreated === true)
        return listSol[0];

      // Remaining configurations require a solver
      // -----------------------------------------

      var initPts = new Array();
      if (iT)
        initPts[0] = iT;
      else
        this.ComputeInits(initPts);
      
      if (this._DEBUG.IsActive(1))
      {
        console.log("");
        console.log("Found " + initPts.length + " inits");
        for (var i = 0; i < initPts.length; i++)
          console.log("At " + initPts[i].getArray());
      }

      var bestSol = new DSMath.Point2D();
      var minDist = -1.0; // initialize negative

      for (var i = 0; i < initPts.length; i++)
      {
        if (this._DEBUG.IsActive(1))
        {
          console.log("");
          console.log("MinDistCrvCrv::Run solve from init-" + i + " at: " + initPts[i].getArray());
          console.log("                     on crv-1 at: " + this.crv1.evalPoint(initPts[i].x).getArray());
          console.log("                     on crv-2 at: " + this.crv2.evalPoint(initPts[i].y).getArray());
        }

        // Solve the min-distance from the init
        // ------------------------------------

        var currSolArray = []; // has to be an array to pass by reference!
        var solveOK = this.Solve(initPts[i], currSolArray);
        if (solveOK)
        {
          var currSol = currSolArray[0];

          if (this._DEBUG.IsActive(1))
          {
            console.log("MinDistCrvCrv::Run solve from init-" + i + " converged");
            console.log("  to: " + currSol.getArray());
          }

          var currDist = this.crv1.evalPoint(currSol.x).sub(this.crv2.evalPoint(currSol.y)).norm();
          if (currDist < minDist || minDist < 0.0)
          {
            if (this._DEBUG.IsActive(1))
              console.log("MinDistCrvCrv::Run --> store as current best solution");

            this.hasSol = true;
            minDist = currDist;
            bestSol.copy(currSol);
          }
        }
        else
        {
          if (this._DEBUG.IsActive(1))
            console.error("MinDistCrvCrv::Run solve from init-" + i + " failed to solve");
        }
      }

      if (this._DEBUG.IsActive(1))
      {
        console.log("MinDistCrvCrv::Run --> return best solution " + bestSol.getArray());
        console.log("                     on crv-1 at: " + this.crv1.evalPoint(bestSol.x).getArray());
        console.log("                     on crv-2 at: " + this.crv2.evalPoint(bestSol.y).getArray());
      }

      return bestSol;
    };

    DSMath.MinDistCrvCrv = MinDistCrvCrv;

    return MinDistCrvCrv;
  }
);
