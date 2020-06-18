//===================================================================
// COPYRIGHT DASSAULT SYSTEMES 2018
//===================================================================
// JavaScript curve-curve intersection utility operator
//===================================================================
// 01/11/18 Q48 Creation
// 30/11/18 Q48 Improvements to init finder for ellipse / circle cases
// 20/01/19 Q48 Tolerance consistency
// 06/02/19 Q48 Check validity of derivatives to stop solver
// 06/02/19 Q48 Update init finder for periodic NURBS
// 10/06/19 Q48 Tolerance and duplicate point tidying for IR-688991
//                  - associated to version level 1
//===================================================================

define('MathematicsES/MathIntersectJSImpl',
  ['MathematicsES/MathNameSpace',
   'MathematicsES/MathTypeCheck',
   'MathematicsES/MathTypeCheckInternal',
   'MathematicsES/MathPointJSImpl',
   'MathematicsES/MathPoint2DJSImpl',
   'MathematicsES/MathVector2DJSImpl',
   'MathematicsES/MathVector3DJSImpl',
   'MathematicsES/MathMat2x2JSImpl',
   'MathematicsES/MathLineJSImpl',
   'MathematicsES/MathCircleJSImpl',
   'MathematicsES/MathEllipseJSImpl',
   'MathematicsES/MathNurbsCurveJSImpl',
   'MathematicsES/MathPlaneJSImpl',
   'MathematicsES/MathMinDistPtCrvJSImpl'
  ],

  function (DSMath, TypeCheck, TypeCheckInternal, Point, Point2D, Vector2D, Vector3D, Matrix2x2, Line, Circle, Ellipse, NurbsCurve, Plane, MinDistPtCrv)
  {
    'use strict';

    /**
    * @private
    * @exports Intersect
    * @class
    * @classdesc Utlity class to compute the intersection of two math curve geometries.
    *
    * @constructor
    * @constructordesc
    * The DSMath.Intersect constructor creates an intersection object from two
    * curves (with start / end parameters) to be run.
    * @param {DSMath.Line | DSMath.Circle | DSMath.Ellipse | DSMath.NurbsCurve}  iCrv1 The first curve to intersect
    * @param {DSMath.Line | DSMath.Circle | DSMath.Ellipse | DSMath.NurbsCurve}  iCrv2 The second curve to intersect
    * @param {Number} iStart1 The start limit (curve parameter) of the first curve
    * @param {Number} iEnd1 The end limit (curve parameter) of the first curve
    * @param {Number} iStart2 The start limit (curve parameter) of the second curve
    * @param {Number} iEnd2 The end limit (curve parameter) of the second curve
    * @memberof DSMath
    */

    var Intersect = function (iCrv1, iCrv2, iStart1, iEnd1, iStart2, iEnd2)
    {
      DSMath.TypeCheck(iCrv1, false, [DSMath.Line, DSMath.Circle, DSMath.Ellipse, DSMath.NurbsCurve]);
      DSMath.TypeCheck(iCrv2, false, [DSMath.Line, DSMath.Circle, DSMath.Ellipse, DSMath.NurbsCurve]);
      DSMath.TypeCheck(iStart1, false, 'number');
      DSMath.TypeCheck(iEnd1, false, 'number');
      DSMath.TypeCheck(iStart2, false, 'number');
      DSMath.TypeCheck(iEnd2, false, 'number');

      // Attributes
      // -------------------------------------

      // Public

      this.crv1 = iCrv1 || null;
      this.crv2 = iCrv2 || null;

      this.range1 = [iStart1, iEnd1];
      this.range2 = [iStart2, iEnd2];

      this.tolLength = 1.0e-6; // length tolerance (X) for intersections - copied from SWx (put in static utility)?

      this.Eval = function (iPt, oVec)
      {
        if (!this.crv1 || !this.crv2)
          return 0.0;

        var f1 = this.crv1.evalPoint(iPt.x);
        var f2 = this.crv2.evalPoint(iPt.y);

        var distVec = f1.sub(f2);

        if (oVec)
          oVec.copy(distVec);

        var oDist = distVec.squareNorm();
        return oDist;
      }

      this.EvalStep = function (iPt, iDistVec, oStep)
      {
        if (!this.crv1 || !this.crv2)
          return false;

        var gradF = this.crv1.evalFirstDeriv(iPt.x);
        var gradG = this.crv2.evalFirstDeriv(iPt.y);

        var A =  gradF.dot(gradF);
        var B = -gradF.dot(gradG);
        var C =  gradG.dot(gradG);

        var det = (A*C) - (B*B);

        if (Math.abs(det) < 1.0e-12) // Q48 - how to decide this?
          return false;

        var detInv = 1.0 / det;

        var mat1 = new DSMath.Vector3D();
        mat1.addScaledVector(gradF, C);
        mat1.addScaledVector(gradG, B);
        mat1.multiplyScalar(detInv);

        var mat2 = new DSMath.Vector3D();
        mat2.addScaledVector(gradF, -B);
        mat2.addScaledVector(gradG, -A);
        mat2.multiplyScalar(detInv);

        oStep.x = mat1.dot(iDistVec);
        oStep.y = mat2.dot(iDistVec);

        if (isNaN(oStep.x) || isNaN(oStep.y)) // protection
          return false;

        return true;
      }

      this.ComputeInits = function (oInitPts)
      {
        DSMath.TypeCheckInternal(oInitPts, true, [], []); // must (at least) be an array

        // Treat "closed" geometry (ellipse / circle)
        // ------------------------------------------

        var hasCentre = [false, false];

        if (this.crv1.constructor == Circle || this.crv1.constructor == Ellipse)
          hasCentre[0] = true;

        if (this.crv2.constructor == Circle || this.crv2.constructor == Ellipse)
          hasCentre[1] = true;

        if (hasCentre[0] && hasCentre[1])
        {
          this.ComputeInits_CentreCentre(oInitPts);

          if (this._DEBUG >= 1)
          {
            console.log("Computed " + oInitPts.length + " inits");
            for (var iInit = 0; iInit < oInitPts.length; iInit++)
              console.log("  init-" + iInit + ": " + oInitPts[iInit].getArray())
          }

          return;
        }

        // Treat NURBS
        // -----------

        var lines0 = [];

        if (this.crv1.constructor == NurbsCurve)
          lines0 = this.crv1.ComputePolyline();
        else if (this.crv1.constructor == Line)
          lines0[0] = this.crv1;

        var lines1 = [];

        if (this.crv2.constructor == NurbsCurve)
          lines1 = this.crv2.ComputePolyline();
        else if (this.crv2.constructor == Line)
          lines1[0] = this.crv2;

        if (lines0.length > 0)
        {
          if (lines1.length > 0)
            this.ComputeInits_LineLine(lines0, lines1, oInitPts);
          else
            this.ComputeInits_LineCentre(lines0, this.crv2, 0, oInitPts);
        }
        else
        {
          if (lines1.length > 0)
            this.ComputeInits_LineCentre(lines1, this.crv1, 1, oInitPts);
          else
            this.ComputeInits_NoImpl();
        }

        if (this._DEBUG >= 1)
        {
          console.log("Computed " + oInitPts.length + " inits");
          for (var iInit = 0; iInit < oInitPts.length; iInit++)
            console.log("  init-" + iInit + ": " + oInitPts[iInit].getArray());
        }

        return;
      }

      this.ComputeInits_CentreCentre = function (oInitPts)
      {
        DSMath.TypeCheckInternal(oInitPts, true, [], []); // must (at least) be an array

        var method = 1;

        if (method === 1)
        {
          // Multi-step process:
          // -------------------
          //
          //   1. For each curve - intersect the axes of this circle / ellipse with the other circle / ellipse
          //        a. Expect up to two intersection points
          //   2. For each intersection point, compute the tangent direction on the other circle / ellipse
          //        a. Build a line from the intersection point and tangent direction
          //        b. Intersect this line with the original circle / ellipse
          //   3. Build the 2D init from:
          //        a. The intersection point in step-1 (on the other circle / ellipse)
          //        b. The intersection point in step-2 (on this circle / ellipse)

          var curves = [this.crv1, this.crv2];

          var range = 0.0;
          for (var iCurve = 0; iCurve < 2; iCurve++)
          {
            if (curves[iCurve].constructor == Circle)
              range += curves[iCurve].radius;
            else if (curves[iCurve].constructor == Ellipse)
              range += curves[iCurve].radiusMaj;
          }

          for (var iCurve = 0; iCurve < 2; iCurve++)
          {
            var dir = [new DSMath.Vector3D(), new DSMath.Vector3D()];
            curves[iCurve].getDirections(dir);

            // Intersect the axes of this curve with the other curve
            // -----------------------------------------------------

            for (var iDir = 0; iDir < 2; iDir++)
            {
              var axisLine = new DSMath.Line(curves[iCurve].center, dir[iDir]);
              
              var intersectOp1 = new DSMath.Intersect(axisLine, curves[1 - iCurve], -range, range, 0.0, DSMath.constants.PI2);
              var inits1 = intersectOp1.Run();

              for (var iInit = 0; iInit < inits1.length; iInit++)
              {
                // Compute the line from intersection point and tangent
                // ----------------------------------------------------

                var init3D  = curves[1 - iCurve].evalPoint(inits1[iInit].y); // the 3D of the intersection
                var initTgt = curves[1 - iCurve].evalFirstDeriv(inits1[iInit].y).normalize(); // the tangent of the other curve

                var tgtLine = new DSMath.Line(init3D, initTgt);

                // Intersect the line with this circle / ellipse
                // ---------------------------------------------

                var intersectOp2 = new DSMath.Intersect(tgtLine, curves[iCurve], -range, range, 0.0, DSMath.constants.PI2);
                var inits2 = intersectOp2.Run();

                // Build the inits
                // ---------------

                for (var jInit = 0; jInit < inits2.length; jInit++)
                {
                  if (iCurve === 0)
                    oInitPts.push(new DSMath.Point2D(inits2[jInit].y, inits1[iInit].y));
                  else
                    oInitPts.push(new DSMath.Point2D(inits1[iInit].y, inits2[jInit].y));
                }
              }
            }
          }

          return;
        }
        //else // method 0 (not used anymore)
        //{
        //  // Canonical curves
        //  // ----------------
        //  //    Intersect the line joining the curve centers and then offset the inits

        //  // Take care if the centers are coincident (to do)
        //  var cDir = this.crv2.center.sub(this.crv1.center); // from c1 to c2

        //  if (cDir.squareNorm() < this.tolX * this.tolX)
        //  {
        //    var dir = this.crv1.getDirections();
        //    cDir.copy(dir[0]);
        //  }
        //  else
        //  {
        //    cDir.normalize();
        //  }

        //  var cLine = new DSMath.Line(this.crv1.center, cDir);

        //  // Typical distances (extent of the line)
        //  var curves = [this.crv1, this.crv2];

        //  var range3D = 0.0;

        //  for (var i = 0; i < 2; i++)
        //  {
        //    if (curves[i].constructor == Circle)
        //      range3D += curves[i].radius;
        //    else if (curves[i].constructor == Ellipse)
        //      range3D += curves[i].radiusMaj;
        //  }

        //  //range3D /= cDir.norm(); // put in the parameter space of the line

        //  var intersectOp1 = new DSMath.Intersect(cLine, this.crv1, -range3D, 1.0 + range3D, this.range1[0], this.range1[1]);
        //  var inits1 = intersectOp1.Run();

        //  var intersectOp2 = new DSMath.Intersect(cLine, this.crv2, -range3D, 1.0 + range3D, this.range2[0], this.range2[1]);
        //  var inits2 = intersectOp2.Run();

        //  // Fail if no inits
        //  // ----------------

        //  if (inits1.length == 0 || inits2.length == 0)
        //    return;

        //  // Find the best init
        //  // ------------------

        //  var bestInitIsSol = false;

        //  var bestInit;
        //  var minFX = -1.0;

        //  for (var iInit1 = 0; iInit1 < inits1.length; iInit1++)
        //  {
        //    for (var iInit2 = 0; iInit2 < inits2.length; iInit2++)
        //    {
        //      var ptInit = new DSMath.Point2D(inits1[iInit1].y, inits2[iInit2].y);
        //      var fX = this.Eval(ptInit);

        //      if (fX < minFX || minFX < 0.0)
        //      {
        //        minFX = fX;
        //        bestInit = ptInit.clone();

        //        if (fX < this.tolX)
        //          bestInitIsSol = true;
        //      }
        //    }
        //  }

        //  // Compute the inits
        //  // -----------------

        //  var grad1 = this.crv1.evalFirstDeriv(bestInit.x);
        //  var grad2 = this.crv2.evalFirstDeriv(bestInit.y);

        //  var oriSign = 1.0;
        //  if (grad1.dot(grad2) < 0.0)
        //    oriSign = -1.0;

        //  var initNudgeAngle = DSMath.constants.PI / 4.0; // how to set this??
        //  var initNudge = new DSMath.Vector2D(initNudgeAngle, oriSign * initNudgeAngle);

        //  if (bestInitIsSol)
        //  {
        //    oInitPts[0] = bestInit.clone();
        //  }
        //  else
        //  {
        //    oInitPts[0] = bestInit.clone().addVector(initNudge);
        //    oInitPts[1] = bestInit.clone().addScaledVector(initNudge, -1.0);
        //  }

        //  var initOffset = new DSMath.Vector2D(DSMath.constants.PI, DSMath.constants.PI);
        //  bestInit.addVector(initOffset);

        //  oInitPts.push(bestInit.clone().addVector(initNudge));
        //  oInitPts.push(bestInit.clone().addScaledVector(initNudge, -1.0));
        //}
      }

      this.ComputeInits_LineLine = function (iLines0, iLines1, oInitPts)
      {
        DSMath.TypeCheckInternal(iLines0, true, [DSMath.Line], []);
        DSMath.TypeCheckInternal(iLines1, true, [DSMath.Line], []);
        DSMath.TypeCheckInternal(oInitPts, true, [], []); // must (at least) be an array

        var infR = 100000;

        var totalLength0 = 0.0;
        for (var i = 0; i < iLines0.length; i++)
          totalLength0 += iLines0[i].direction.norm();

        var totalLength1 = 0.0;
        for (var i = 0; i < iLines1.length; i++)
          totalLength1 += iLines1[i].direction.norm();

        var cumulativeLength0 = 0.0;

        for (var i = 0; i < iLines0.length; i++)
        {
          var currLength0 = iLines0[i].direction.norm();

          var cumulativeLength1 = 0.0;

          for (var j = 0; j < iLines1.length; j++)
          {
            if (this._DEBUG >= 2)
            {
              console.log("");
              console.log("Compute init from intersection of line[" + i + "] and line[" + j + "]");
            }

            var currLength1 = iLines1[j].direction.norm();

            var interRes = iLines0[i].intersectLine(iLines1[j], -infR, infR, -infR, infR);
            if (interRes.diag === 0)
            {
              var currFrac0 = (cumulativeLength0 + (currLength0 / 2)) / totalLength0;
              var currFrac1 = (cumulativeLength1 + (currLength1 / 2)) / totalLength1;

              var initPt = new DSMath.Point2D();

              initPt.x = this.UpdateInitParameter(this.crv1, iLines0[i], this.range1, i, interRes.param1, currFrac0);
              initPt.y = this.UpdateInitParameter(this.crv2, iLines1[j], this.range2, j, interRes.param2, currFrac1);

              oInitPts.push(initPt);
            }

            cumulativeLength1 += currLength1;
          }

          cumulativeLength0 += currLength0;
        }
      }

      this.ComputeInits_LineCentre = function (iLines, iOtherCrv, iIndexLines, oInitPts)
      {
        var infR = 100000;

        var totalLengthLines = 0.0;
        for (var i = 0; i < iLines.length; i++)
          totalLengthLines += iLines[i].direction.norm();

        var cumulativeLengthLine = 0.0;

        for (var i = 0; i < iLines.length; i++)
        {
          var currLengthLine = iLines[i].direction.norm();

          if (this._DEBUG >= 2)
          {
            console.log("");
            console.log("Compute init from intersection of line[" + i + "] and other curve");
            console.log("");
          }

          var currFracLine = (cumulativeLengthLine + (currLengthLine / 2)) / totalLengthLines;

          var lineIntersector = new DSMath.Intersect(iLines[i], iOtherCrv, -infR, infR, 0.0, DSMath.constants.PI2);
          var sol2D = lineIntersector.Run();

          for (var iInit = 0; iInit < sol2D.length; iInit++)
          {
          
            if (this._DEBUG >= 2)
            {
              console.log("");
              console.log("Process intersection solution " + iInit);
            }

            var initPt = sol2D[iInit].clone();

            if (iIndexLines === 0) // the nurbs (or line) is crv1
              initPt.x = this.UpdateInitParameter(this.crv1, iLines[i], this.range1, i, initPt.x, currFracLine);
            else // the nurbs (or line) is crv2
              initPt.y = this.UpdateInitParameter(this.crv2, iLines[i], this.range2, i, initPt.y, currFracLine);

            oInitPts.push(initPt);
          }

          cumulativeLengthLine += currLengthLine;
        }
      }

      this.ComputeInits_NoImpl = function ()
      {
        console.error("No implementation of init computation");
      }

      this.UpdateInitParameter = function (iCrv, iLine, iRange, iIndex, iParam, iFracPolyArc)
      {
        DSMath.TypeCheckInternal(iCrv, true, [DSMath.Line, DSMath.Circle, DSMath.Ellipse, DSMath.NurbsCurve]);
        DSMath.TypeCheckInternal(iLine, true, DSMath.Line);
        DSMath.TypeCheckInternal(iRange, true, ['number'], 2);
        DSMath.TypeCheckInternal(iIndex, true, 'number');
        DSMath.TypeCheckInternal(iParam, true, 'number');
        DSMath.TypeCheckInternal(iFracPolyArc, true, 'number');

        var oParam = iParam;

        if (iCrv.constructor == NurbsCurve)
        {
          var init3D = iLine.evalPoint(iParam);

          var minKnot = iCrv.KnotVec[0].knotValue;
          var maxKnot = iCrv.KnotVec[iCrv.KnotVec.length - 1].knotValue;

          if (this._DEBUG >= 2)
            console.log("  NURBS curve - compute init near 3D point: " + init3D.getArray());

          var m0 = new DSMath.MinDistPtCrv(iCrv, [minKnot, maxKnot], init3D);
          if (this._DEBUG >= 1)
            m0._DEBUG = this._DEBUG - 1;

          var initNurbs = iFracPolyArc * (maxKnot - minKnot);

          var minDistRes;
          if (iCrv.IsPeriodic === true)
            minDistRes = m0.Run();
          else
            minDistRes = m0.Run(initNurbs);

          if (m0.hasSol === true) // found a solution
          {
            oParam = minDistRes;

            if (this._DEBUG >= 2)
              console.log("  min-dist operator converged to: " + oParam);
          }
          else
          {
            oParam = initNurbs;

            if (this._DEBUG >= 2)
              console.warn("  min-dist operator didn't converge --> use initial guess: " + initNurbs);
          }
        }
        else if (iCrv.constructor == Line)
        {
          oParam = this.PutInRange(iLine, iParam, iRange);
        }

        return oParam;
      }

      this.Solve = function (iInit, oSol)
      {
        DSMath.TypeCheckInternal(iInit, true, DSMath.Point2D);
        DSMath.TypeCheckInternal(oSol, true, [], []); // must (at least) be an array

        var tolNull = Math.pow(DSMath.defaultTolerances.epsgForLengthTest, 2);

        // Check if the init is already a solution
        // ---------------------------------------

        var iFX = this.Eval(iInit);
        if (iFX < tolNull)
        {
          oSol[0] = iInit.clone();
          return;
        }

        // Setup the Newton
        // ----------------

        var maxIter = 10000; // Q48 - how to decide this?

        var currPt = iInit.clone();

        var converged = false;

        var counter = 0;
        while (counter < maxIter)
        {
          // Evaluate the intersection equation
          // ----------------------------------

          var distVec = new DSMath.Vector3D();
          var fX = this.Eval(currPt, distVec);

          if (this._DEBUG >= 2)
          {
            console.log("  Iteration " + counter);
            console.log("    at " + currPt.getArray());
            console.log("      --> fX = " + fX);
          }

          // Check convergence
          // -----------------

          if (fX < tolNull)
          {
            if (this._DEBUG >= 2)
              console.log("    converged!");
           
            converged = true;

            break;
          }

          // Compute the step (generalised Newton)
          // -------------------------------------

          var currGrad = new DSMath.Vector2D();
          var stepOK = this.EvalStep(currPt, distVec, currGrad);

          if (this._DEBUG >= 2)
            console.log("    step is " + stepOK + " (" + currGrad.getArray() + ")");

          if (stepOK === false)
            break;

          // Update the current point
          // ------------------------

          currPt.addScaledVector(currGrad, -1.0);

          // Restrict to the domain
          // ----------------------

          if (this.crv1.IsInfinite() === false)
            currPt.x = this.PutInRange(this.crv1, currPt.x, this.range1);

          if (this.crv2.IsInfinite() === false)
            currPt.y = this.PutInRange(this.crv2, currPt.y, this.range2);

          counter++;
        }

        if (counter === maxIter)
        {
          if (this._DEBUG >= 1)
            console.log("  Failed to converge after " + maxIter + " (= max) iterations");

          return false;
        }

        if (converged === false)
        {
          if (this._DEBUG >= 1)
            console.log("  Failed to converge after " + counter + " iterations");

          return false;
        }

        // Put the solution back in the requested domain
        if (this.crv1.IsInfinite() === true)
          currPt.x = this.PutInRange(this.crv1, currPt.x, this.range1);

        if (this.crv2.IsInfinite() === true)
          currPt.y = this.PutInRange(this.crv2, currPt.y, this.range2);

        // Store the solution
        oSol[0] = currPt.clone();
        return true;
      }

      this.ComputeAnalytic = function (oSol)
      {
        DSMath.TypeCheckInternal(oSol, true, [], []); // must (at least) be an array

        // Treat (semi-)canonical cases
        // ----------------------------

        // Line   - Line
        // Line   - Circle
        // Line   - Ellipse
        // Circle - Circle

        // Line - line
        if (this.crv1.constructor == Line && this.crv2.constructor == Line)
        {
          // Q48 (05/06/19): Should we pass in this.tolLength ??
          var interSol = this.crv1.intersectLine(this.crv2, this.range1[0], this.range1[1], this.range2[0], this.range2[1]);

          if (interSol.diag === 0)
            oSol[0] = new DSMath.Point2D(interSol.param1, interSol.param2);

          return true;
        }

        // Circle - circle
        if (this.crv1.constructor == Circle && this.crv2.constructor == Circle)
        {
          var tol = undefined;
          if (this._VERSION >= 1)
            tol = this.tolLength;

          if (this._VERSION >= 1) // order of the range inputs is the opposite to the one expected
            var interSol = this.crv1.intersectCircle(this.crv2, this.range2[0], this.range2[1], this.range1[0], this.range1[1], tol);
          else
            var interSol = this.crv1.intersectCircle(this.crv2, this.range1[0], this.range1[1], this.range2[0], this.range2[1], tol);

          if (interSol != 0 && interSol.length > 0)
          {
            oSol[0] = new DSMath.Point2D(interSol[0].paramCircle, interSol[0].paramOtherCircle);
            if (interSol.length > 1)
              oSol[1] = new DSMath.Point2D(interSol[1].paramCircle, interSol[1].paramOtherCircle);
          }

          return true;
        }

        // Non-symmetric cases
        // -------------------

        var isTreated = false;

        var curves = [this.crv1, this.crv2];
        var ranges = [this.range1, this.range2];

        // Circle - line
        for (var i = 0; i < 2 && isTreated === false; i++)
        {

          if (curves[i].constructor === Circle && curves[1 - i].constructor === Line)
          {
            var interSol = curves[i].intersectLine(curves[1 - i], ranges[1 - i][0], ranges[1 - i][1], ranges[i][0], ranges[i][1], this.tolLength);

            for (var iSol = 0; iSol < interSol.length; iSol++)
            {
              var interPt = new Array(0.0, 0.0);

              interPt[i] = interSol[iSol].paramCircle;
              interPt[1 - i] = interSol[iSol].paramLine;

              oSol[iSol] = new DSMath.Point2D().setFromArray(interPt);
            }

            isTreated = true;
          }
        }

        if (isTreated === true)
          return true;
        
        // Ellipse - line
        for (var i = 0; i < 2 && isTreated === false; i++)
        {
          if (curves[i].constructor === Ellipse && curves[1 - i].constructor === Line)
          {
            var interSol = curves[i].intersectLine(curves[1 - i], ranges[1 - i][0], ranges[1 - i][1], ranges[i][0], ranges[i][1], this.tolLength);

            for (var iSol = 0; iSol < interSol.length; iSol++)
            {
              var interPt = new Array(0.0, 0.0);

              interPt[i] = interSol[iSol].paramEllipse;
              interPt[1 - i] = interSol[iSol].paramLine;

              oSol[iSol] = new DSMath.Point2D().setFromArray(interPt);
            }

            isTreated = true;
          }
        }

        if (isTreated === true)
          return true;

        return false;
      }

      this.ComputeAnalyticTilted = function (oSol)
      {
        DSMath.TypeCheckInternal(oSol, true, [], []); // must (at least) be an array

        // Compute cases where the support planes are tilted
        // -------------------------------------------------

        // Ellipse - circle
        // Ellipse - ellipse

        // Q48 (07/11/18) - to do (but not needed for sketcher)

        return false;
      }

      // ---------------------------------------------------------------------------------
      // Versioning
      // ---------------------------------------------------------------------------------

      this._VERSION = 0; // Q48 (01/11/18): Creation
      //this._VERSION = 1; // Q48 (05/06/19): IR-688991 - tolerance for circle-circle

      // ---------------------------------------------------------------------------------
      // DEBUG
      // ---------------------------------------------------------------------------------
      this._DEBUG = 0;

      this.DebugSampleCurves = function ()
      {
        console.log("Intersect::Run")

        var curves = [this.crv1, this.crv2];

        for (var iCurve = 0; iCurve < 2; iCurve++)
        {
          console.log("  Sample curve-" + iCurve);

          if (curves[iCurve].constructor === Ellipse || curves[iCurve].constructor === Circle)
          {
            for (var jSample = 0; jSample < 4; jSample++)
            {
              var param = jSample * DSMath.constants.PI2 / 4;
              var samplePt =  curves[iCurve].evalPoint(param);
              var sampleTgt = curves[iCurve].evalFirstDeriv(param);

              console.log("    at " + param + " --> " + samplePt.getArray());
              console.log("      --> tgt " + sampleTgt.getArray());
            }
          }
        }
      }
      // ---------------------------------------------------------------------------------
    };

    // ---------------------------------------------------------------------------------
    // Data members
    // ---------------------------------------------------------------------------------

    Intersect.prototype.crv1 = null;
    Intersect.prototype.crv2 = null;
    Intersect.prototype.range1 = null;
    Intersect.prototype.range2 = null;
    
    // ---------------------------------------------------------------------------------
    // Private methods
    // ---------------------------------------------------------------------------------

    /** @ignore */
    // Utility method (for internal use) - put the parameter in the given range
    // accounting for periodics
    Intersect.prototype.PutInRange = function (iCurve, iParam, iRange)
    {
      DSMath.TypeCheckInternal(iCurve, true, [DSMath.Line, DSMath.Circle, DSMath.Ellipse, DSMath.NurbsCurve]);
      DSMath.TypeCheckInternal(iParam, true, 'number');
      DSMath.TypeCheckInternal(iRange, true, ['number'], 2);

      return MinDistPtCrv.prototype.PutInRange(iCurve, iParam, iRange);
    }

    /** @ignore */
    // Utility method (for internal use) - put the parameter in the given domain (with tolerance)
    Intersect.prototype.PutInDomain = function (iParam, iDomain)
    {
      DSMath.TypeCheckInternal(iParam, true, 'number');
      DSMath.TypeCheckInternal(iDomain, true, ['number'], 2);

      var oRet = [iParam, true];

      if (iParam < iDomain[0]) // below the domain
      {
        if (iParam < iDomain[0] - this.tolLength) // really below the domain
          oRet[1] = false;
        else
          oRet[0] = iDomain[0]; // just below the domain --> snap to the boundary
      }

      if (iParam > iDomain[1]) // above the domain
      {
        if (iParam > iDomain[1] + this.tolLength) // really below the domain
          oRet[1] = false;
        else
          oRet[0] = iDomain[1];
      }

      return oRet; // the return data
    }

    // ---------------------------------------------------------------------------------
    // Public methods
    // ---------------------------------------------------------------------------------
 
    /**
    * @private
    * @memberof DSMath.Intersect
    * @method Run
    * @instance
    * @description
    * Runs the intersection operator
    * @param {DSMath.Point2D[]} [iInit] A list of init points to start from
    * @example
    * var e0 = new DSMath.Ellipse(2.0, 1.0).setCenter(0.0, 0.0, 0.0);
    * var c0 = new DSMath.Circle(1.0).setCenter(3.0, 0.0, 0.0);
    * var i0 = new DSMath.Intersect(e0, c0, 0.0, DSMath.constants.PI2, 0.0, DSMath.constants.PI2);
    * var init = new DSMath.Point2D(DSMath.constants.PI / 4, 3 * DSMath.constants.PI / 4);
    * var interRes = i0.Run(init); // interRes = [ (0.0, pi) ];
    * var interResNoNinit = i0.Run(); // interResNoInit = [ (0, pi), (2pi, pi) ];
    * @returns {DSMath.Point2D[]} The intersection results (2 curve parameters, stored for convenience as a 2D-point)
    */
    Intersect.prototype.Run = function (iInit)
    {
      DSMath.TypeCheck(iInit, false, DSMath.Point2D);

      if (this._DEBUG >= 1)
        this.DebugSampleCurves();

      var solPts = []; // local storage of the solution points

      if (this.crv1 === null || this.crv2 === null)
        return oSol;

      var isTreated = false;

      if (isTreated === false)
      {
        // Analytical configuration
        // ------------------------

        isTreated = this.ComputeAnalytic(solPts);

        if (this._VERSION < 1)
        {
          if (isTreated === true)
            return solPts;
        }
      }

      if (isTreated === false)
      {
        // Other configurations can be computed
        // ------------------------------------

        isTreated = this.ComputeAnalyticTilted(solPts); // does nothing - assume everything is in the plane

        if (this._VERSION < 1)
        {
          if (isTreated === true)
            return solPts;
        }
      }

      if (isTreated === false)
      {
        // Remaining configurations require a solver
        // -----------------------------------------

        var initPts = new Array();
        if (iInit)
          initPts[0] = iInit;
        else
          this.ComputeInits(initPts);

        for (var i = 0; i < initPts.length; i++)
        {
          if (this._DEBUG >= 1)
          {
            var init0 = this.crv1.evalPoint(initPts[i].x);
            var init1 = this.crv2.evalPoint(initPts[i].y);

            console.log("");
            console.log("Solve from init at: " + initPts[i].getArray());
            console.log("  --> at 3D point: " + init0.getArray() + " on curve-0");
            console.log("  --> at 3D point: " + init1.getArray() + " on curve-1");
          }

          // Solve the intersection from the init
          // ------------------------------------

          var currSolArray = []; // has to be an array to pass by reference!

          var solveOK = this.Solve(initPts[i], currSolArray);
          if (solveOK === false)
          {
            if (this._DEBUG >= 1)
              console.log("  --> failed to converge");

            continue;
          }

          // Get the solution
          // ----------------

          var currSol = currSolArray[0]; // the actual solution

          if (this._DEBUG >= 1)
          {
            console.log("  --> converged to 2D point: " + currSolArray[0].getArray());
            console.log("    --> 3D point: " + this.Get3D(currSolArray)[0].getArray());
          }

          // Check the domains
          // -----------------

          var inDomain1 = this.PutInDomain(currSol.x, this.range1);
          var inDomain2 = this.PutInDomain(currSol.y, this.range2);

          if (inDomain1[1] === false || inDomain2[1] === false)
          {
            if (this._DEBUG >= 1)
            {
              console.log("  --> converged to solution outside range");
              if (inDomain1[1] === false)
                consoel.log("        outside the domain for curve-1: " + this.range1);

              if (inDomain2[1] === false)
                console.log("        outside the domain for curve-2: " + this.range2);
            }

            continue;
          }

          currSol.x = inDomain1[0]; // update the solution from the domain
          currSol.y = inDomain2[0]; // update the solution from the domain

          // Store the solution
          // ------------------

          solPts.push(currSol.clone());
        }
      }

      // Add the points to the output list (take care of duplicates!)
      // ------------------------------------------------------------

      var oSol = [];

      for (var i = 0; i < solPts.length; i++)
      {
        var addSol = true;
        for (var j = 0; j < oSol.length && addSol === true; j++)
        {
          if (Math.abs(solPts[i].x - oSol[j].x) < this.tolLength && Math.abs(solPts[i].y - oSol[j].y) < this.tolLength)
            addSol = false;
        }

        if (addSol === true)
          oSol.push(solPts[i].clone());
      }

      return oSol;
    };

    /**
    * @private
    * @memberof DSMath.Intersect
    * @method Get3D
    * @instance
    * @description
    * Computes the 3D intersection points from the 2 curve parameters (output of Run)
    * @param {DSMath.Point2D[]} iSol The list of solution points (as output of Run(): 2x curve parameters stored as a 2D point)
    * @example
    * var e0 = new DSMath.Ellipse(2.0, 1.0).setCenter(0.0, 0.0, 0.0);
    * var c0 = new DSMath.Circle(1.0).setCenter(3.0, 0.0, 0.0);
    * var i0 = new DSMath.Intersect(e0, c0, 0.0, DSMath.constants.PI2, 0.0, DSMath.constants.PI2);
    * var init = new DSMath.Point2D(DSMath.constants.PI / 4, 3 * DSMath.constants.PI / 4);
    * var interRes2D = i0.Run(init); // interRes2D = [ (0.0, pi) ];
    * var interRes3D = i0.Get3D(interRes2D); // interRes3D = [ (2.0, 0.0, 0.0) ];
    * @returns {DSMath.Point[]} The 3D intersection results
    */
    Intersect.prototype.Get3D = function (iSol2D)
    {
      DSMath.TypeCheck(iSol2D, true, [DSMath.Point2D], []); // an array of Point2D

      var oSol3D = [];
      for (var i = 0; i < iSol2D.length; i++)
      {
        var sol3D_0 = this.crv1.evalPoint(iSol2D[i].x);
        var sol3D_1 = this.crv2.evalPoint(iSol2D[i].y);

        var sol3D = new DSMath.Point();
        sol3D.addScaledPoint(sol3D_0, 0.5).addScaledPoint(sol3D_1, 0.5);

        oSol3D[i] = sol3D;
      }

      return oSol3D;
    };

    DSMath.Intersect = Intersect;

    return Intersect;
  }
);
