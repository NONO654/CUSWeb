define('CSIMathematics/CSIMathematicsDeclareTypes', ['CSIMathematics/CSIDeclareMathVector3DJS',
                                                     'CSIMathematics/CSIDeclareMathVector2DJS',
                                                     'CSIMathematics/CSIDeclareMathPointJS',
                                                     'CSIMathematics/CSIDeclareMathPoint2DJS',
                                                     'CSIMathematics/CSIDeclareMathMat2x2JS',
                                                     'CSIMathematics/CSIDeclareMathMat3x3JS',
                                                     'CSIMathematics/CSIDeclareMathAxisJS',
                                                     'CSIMathematics/CSIDeclareMathTransformationJS',
                                                     'CSIMathematics/CSIDeclareMathLineJS',
                                                     'CSIMathematics/CSIDeclareMathLine2DJS',
                                                     'CSIMathematics/CSIDeclareMathPlaneJS',
                                                     'CSIMathematics/CSIDeclareMathCircleJS'
], function (declareMathVector3D, declareMathVector2D, declareMathPoint, declareMathPoint2D,
             declareMath2x2Matrix, declareMath3x3Matrix, declareMathAxis, declareMathTransformation,
             declareMathLine, declareMathLine2D, declareMathPlane, declareMathCircle) {
  'use strict';

   var module = {};

   /*
   * Declare the function that will declare the mathematics serialize functions
   * from declarative json file.
   */
   module.declareTypes = function(iCSICommand, iTypeName)
  {
      if(iTypeName=="CATMathPoint")
         declareMathPoint(iCSICommand);
      else if(iTypeName=="CATMathPoint2D")
         declareMathPoint2D(iCSICommand);
      else if(iTypeName=="CATMathVector")
         declareMathVector3D(iCSICommand);
      else if(iTypeName=="CATMathVector2D")
         declareMathVector2D(iCSICommand);
      else if(iTypeName=="CATMath3x3Matrix")
         declareMath3x3Matrix(iCSICommand);
      else if(iTypeName=="CATMath2x2Matrix")
         declareMath2x2Matrix(iCSICommand);
      else if(iTypeName=="CATMathTransformation")
         declareMathTransformation(iCSICommand);
      else if(iTypeName=="CATMathAxis")
         declareMathAxis(iCSICommand);
      else if(iTypeName=="CATMathLine")
         declareMathLine(iCSICommand);
      else if(iTypeName=="CATMathLine2D")
         declareMathLine2D(iCSICommand);
      else if(iTypeName=="CATMathPlane")
         declareMathPlane(iCSICommand);
      else if(iTypeName=="CATMathCircle")
         declareMathCircle(iCSICommand);
  };

  return module;
});
