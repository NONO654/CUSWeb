//===================================================================
// COPYRIGHT DASSAULT SYSTEMES 2018
//===================================================================
// JavaScript type checking utility class (internal functions)
//===================================================================
//   - The JS language has no type checking built in
//   - Some type checking of arguments could be helpful (IR-658563)
// This class provides a utility method to check the type of a
// function argument against a list of expected types
//===================================================================
// 06/02/19 Q48 Creation
//===================================================================


define('MathematicsES/MathTypeCheckInternal',
  ['MathematicsES/MathNameSpace',
   'MathematicsES/MathTypeCheck'
  ], 
  
  function (DSMath)
  {
    'use strict';

    var TypeCheckInternal = function (iArg, iMandatory, iExpectedType, iExpectedTypeArray)
    {
      return TypeCheckInternal.prototype.Eval(iArg, iMandatory, iExpectedType, iExpectedTypeArray);
    };

    TypeCheckInternal.prototype.NoTypeCheck = function (iArg, iMandatory, iExpectedType, iExpectedTypeArray)
    {
      return true;
    }

    TypeCheckInternal.prototype.DoTypeCheck = function (iArg, iMandatory, iExpectedType, iExpectedTypeArray)
    {
      return DSMath.DoTypeCheck(iArg, iMandatory, iExpectedType, iExpectedTypeArray); // skip the isActive or not stage!
    };

    TypeCheckInternal.prototype.Eval = TypeCheckInternal.prototype.NoTypeCheck; // inactive by default!

    TypeCheckInternal.prototype.Activate = function ()
    {
      TypeCheckInternal.prototype.Eval = TypeCheckInternal.prototype.DoTypeCheck; // function pointer
    };

    TypeCheckInternal.prototype.Deactivate = function ()
    {
      TypeCheckInternal.prototype.Eval = TypeCheckInternal.prototype.NoTypeCheck; // function pointer
    };

    DSMath.TypeCheckInternal = TypeCheckInternal;
    return TypeCheckInternal;
  }
);
