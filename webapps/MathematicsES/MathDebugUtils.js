//===================================================================
// COPYRIGHT DASSAULT SYSTEMES 2019
//===================================================================
// Common debug utilities
//===================================================================
// 22/02/19 Q48 Creation
//===================================================================

define('MathematicsES/MathDebugUtils',
  ['MathematicsES/MathNameSpace'
  ], 
  
  function (DSMath)
  {
    'use strict';

    var DebugUtils = function ()
    {
    };

    DebugUtils.prototype._LEVEL = 0;

    DebugUtils.prototype.IsActive = function (iLevel)
    {
      if (this._LEVEL >= iLevel)
        return true;

      return false;
    };

    DebugUtils.prototype.PrintType = function (iObject)
    {
      if (iObject === undefined)
        return 'undefined';
      
      if (iObject instanceof Array)
        return 'Array';

      if (iObject.constructor === DSMath.Line)
        return 'Line';

      if (iObject.constructor === DSMath.Circle)
        return 'Circle';

      if (iObject.constructor === DSMath.Ellipse)
        return 'Ellipse';

      if (iObject.constructor === DSMath.NurbsCurve)
        return 'NurbsCurve';

      if (iObject.constructor === DSMath.MinDist)
        return 'MinDist';

      if (iObject.constructor === DSMath.MinDistPtCrv)
        return 'MinDistPtCrv';

      if (iObject.constructor === DSMath.MinDistCrvCrv)
        return 'MinDistCrvCrv';

      if (iObject.constructor === DSMath.Intersect)
        return 'Intersect';

    };
    
    DSMath.DebugUtils = DebugUtils;
    return DebugUtils;
  }
);
