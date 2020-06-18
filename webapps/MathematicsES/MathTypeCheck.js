//===================================================================
// COPYRIGHT DASSAULT SYSTEMES 2019
//===================================================================
// JavaScript type checking utility class (public functions)
//   - The JS language has no type checking built in
//   - Some type checking of arguments could be helpful (IR-658563)
// This class provides a utility method to check the type of a
// function argument against a list of expected types
//===================================================================
// 06/02/19 Q48 Creation
//===================================================================

define('MathematicsES/MathTypeCheck',
  ['MathematicsES/MathNameSpace'
  ], 
  
  function (DSMath)
  {
    'use strict';

    // iArg               is the input variable to check the type of
    // iMandatory         indicates whether the variable is required to exist (ie not 'undefined')
    // iExpectedType      is the expected type of the variable
    // iExpectedTypeArray is the expected type of the variable if in an array

    // Examples:
    // Case   iExpectedType            iExpectedTypeArray
    //
    //   1     'number'                         -                          iArg should be a number
    //   2     ['number', String]               -                          iArg should be a number OR a String
    //   3     []                               []                         iArg should be an array
    //   4     ['number']                       []                         iArg should be an array of numbers
    //   5     ['number', String]               []                         iArg should be an array with all elements a 'number' or String
    //   6     ['number']                       I                          iArg should be an array of at least I 'numbers'
    //   7     []                         ['number', String]               iArg should be an array with A[0] 'number' and A[1] String
    //   8     []                         [['number', String], 'number']   iArg should be an array with A[0] 'number' or String and A[1] 'number'

    var TypeCheck = function (iArg, iMandatory, iExpectedType, iExpectedArrayType)
    {
      // "Eval" is a function pointer which is set to "NoTypeCheck" by default --> minimise impact on performance
      //   - if the user calls TypeCheck.prototype.Activate(), then "Eval" is set to "TypeCheck.prototype.DoTypeCheck"
      //     to then call the type check

      return TypeCheck.prototype.Eval(iArg, iMandatory, iExpectedType, iExpectedArrayType);
    };

    TypeCheck.prototype.NoTypeCheck = function (iArg, iMandatory, iExpectedType, iExpectedArrayType)
    {
      //return true;
    };

    TypeCheck.prototype.DoTypeCheck = function (iArg, iMandatory, iExpectedType, iExpectedArrayType)
    {
      var typeOK = TypeCheck.prototype.TypeCheckPrivate(iArg, iMandatory, true, iExpectedType, iExpectedArrayType);

      if (typeOK === false)
      {
        TypeCheck.prototype.PrintKO(true, "TypeCheck is KO --> throw error");
        TypeCheck.prototype.ThrowError();
      }
      else
      {
        TypeCheck.prototype.PrintOK("TypeCheck is OK");
      }

      return typeOK;
    };

    TypeCheck.prototype.Eval = TypeCheck.prototype.NoTypeCheck; // inactive by default!

    TypeCheck.prototype.Activate = function ()
    {
      TypeCheck.prototype.Eval = TypeCheck.prototype.DoTypeCheck; // function pointer
    };

    TypeCheck.prototype.Deactivate = function ()
    {
      TypeCheck.prototype.Eval = TypeCheck.prototype.NoTypeCheck; // function pointer
    };

    TypeCheck.prototype.LogInf = false;
    TypeCheck.prototype.LogErr = true;

    TypeCheck.prototype._DEPTH = -1;

    TypeCheck.prototype.ThrowError = function ()
    {
      TypeCheck.prototype.PrintKO(true, "  --> TypeCheck.ThrowError!");
    };

    TypeCheck.prototype.SingleTypeCheck = function (iArg, iExpectedType)
    {
      var oMatch = false;

      if (isNaN(iArg))
      {
        if (iArg instanceof Array)
        {
          TypeCheck.prototype.PrintKO(true, "SingleTypeCheck: has an array as input")
          return false; // should not happen!
        }

        if (iArg.constructor === iExpectedType)
          return true;

        return false;
      }

      if (iExpectedType === 'number')
        return true;

      if (iExpectedType === Boolean)
        return true;

      return false;
    };

    // Wrapper to the implementation (to handle _DEPTH for debugging)
    // --------------------------------------------------------------

    TypeCheck.prototype.TypeCheckPrivate = function (iArg, iMandatory, iRequireOK, iExpectedType, iExpectedTypeArray)
    {
      TypeCheck.prototype._DEPTH++;

      var oIsOK = TypeCheck.prototype.DoTypeCheckPrivate(iArg, iMandatory, iRequireOK, iExpectedType, iExpectedTypeArray);

      TypeCheck.prototype._DEPTH--;

      return oIsOK;
    };

    TypeCheck.prototype.DoTypeCheckPrivate = function (iArg, iMandatory, iRequireOK, iExpectedType, iExpectedTypeArray)
    {
      // Test if the variable is undefined
      // ---------------------------------

      if (iArg === undefined || iArg === null)
      {
        if (iMandatory === true)
        {
          TypeCheck.prototype.PrintKO(iRequireOK, "DoTypeCheck(" + TypeCheck.prototype._DEPTH + "): mandatory argument is null / undefined");
          return false;
        }

        TypeCheck.prototype.PrintOK("DoTypeCheck(" + TypeCheck.prototype._DEPTH + "): undefined / null argument is OK");

        return true;
      }

      // Test if the variable is an array
      // --------------------------------

      if (iExpectedType instanceof Array)
      {
        var isOK;

        if (iExpectedTypeArray === undefined)
        {
          // ---------------------------------------------------------------------------
          // Case-2: expect iArg to be a single object but we allow many different types
          // ---------------------------------------------------------------------------

          // Expecting a single object but with many type options
          //   eg iArg could be number or Point --> iExpectedType = ['number', DSMath.Point]

          isOK = false;

          for (var iType = 0; iType < iExpectedType.length && isOK === false; iType++)
            isOK = TypeCheck.prototype.TypeCheckPrivate(iArg, true, false, iExpectedType[iType]);
        }
        else // we're expecting iArg to be an array
        {
          if (iArg instanceof Array)
          {
            isOK = true;
            
            if (iExpectedTypeArray instanceof Array)
            {
              if (iExpectedTypeArray.length === 0)
              {
                if (iExpectedType.length === 0)
                {
                  // ------------------------------------------------------------
                  // Case-3: expect iArg to be an array (any length and any type)
                  // ------------------------------------------------------------

                  isOK = true;
                }
                else
                {
                  // ---------------------------------------------------------------------------------------
                  // Case-4: expect iArg to be an array (any length but all types must match iExpectedType)
                  // Case-5: expect iArg to be an array (any length but all types must match iExpectedTypes)
                  // ---------------------------------------------------------------------------------------

                  isOK = true;

                  for (var iType = 0; iType < iArg.length && isOK === true; iType++)
                    isOK = TypeCheck.prototype.TypeCheckPrivate(iArg[iType], true, true, iExpectedType);
                }
              }
              else
              {
                // ---------------------------------------------------------------------------------------
                // Case-7: expect iArg to be an array (types must match those given in iExpectedTypeArray)
                // Case-8: expect iArg to be an array (types must match those given in iExpectedTypeArray)
                // ---------------------------------------------------------------------------------------

                isOK = true;

                for (var iType = 0; iType < iExpectedTypeArray.length && isOK === true; iType++)
                  isOK = TypeCheck.prototype.TypeCheckPrivate(iArg[iType], true, true, iExpectedTypeArray[iType]);
              }
            }
            else if (!isNaN(iExpectedTypeArray))
            {
              // ---------------------------------------------------------------------------------------------------
              // Case-6: expect iArg to be an array of length iExpectedTypeArray (with types given by iExpectedType)
              // ---------------------------------------------------------------------------------------------------

              for (var iArgElem = 0; iArgElem < iExpectedTypeArray && isOK === true; iArgElem++)
                isOK = TypeCheck.prototype.TypeCheckPrivate(iArg[iArgElem], true, true, iExpectedType);
            }
            else
            {
              // Unexpected signature!
              isOK = false;
            }
          }
          else
          {
            // iArg is not an array!
            isOK = false;
          }
        }

        if (isOK === false)
        {
          TypeCheck.prototype.PrintKO(iRequireOK, "DoTypeCheck(" + TypeCheck.prototype._DEPTH + "): expected array types are KO");
          return false;
        }

        TypeCheck.prototype.PrintOK("DoTypeCheck(" + TypeCheck.prototype._DEPTH + "): expected array types are OK");
        return true;
      }

      // ---------------------------------------------
      // Case-1: iArg is expected to be a single type!
      // ---------------------------------------------

      var foundMatch = TypeCheck.prototype.SingleTypeCheck(iArg, iExpectedType);

      //var foundMatch = false;

      //if (iExpectedType instanceof Array) // array of options!
      //{
      //  for (var iType = 0; iType < iExpectedType.length && foundMatch === false; iType++)
      //    foundMatch = TypeCheck.prototype.SingleTypeCheck(iArg, iExpectedType[iType]);
      //}
      //else
      //{
      //  foundMatch = TypeCheck.prototype.SingleTypeCheck(iArg, iExpectedType);
      //}

      if (foundMatch === false)
      {
        TypeCheck.prototype.PrintKO(iRequireOK, "DoTypeCheck(" + TypeCheck.prototype._DEPTH + "): expected type does not match actual type");
        return false;
      }

      TypeCheck.prototype.PrintOK("DoTypeCheck(" + TypeCheck.prototype._DEPTH + "): expected type is OK");
      return true;
    };

    TypeCheck.prototype.PrintKO = function (iRequireOK, iString)
    {
      if (TypeCheck.prototype.LogErr === true && iRequireOK)
      {
        console.error(iString);
        return;
      }
    };
    
    TypeCheck.prototype.PrintOK = function (iString)
    {
      if (TypeCheck.prototype.LogInf === true)
      {
        console.log(iString);
        return;
      }
    };

    DSMath.TypeCheck = TypeCheck;
    return TypeCheck;
  }
);
