define('CSIMathematics/CSIDeclareMathematics', ['CSIMathematics/CSIDeclareMathVector3DJS',
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

   /*
   * Declare the function that will declare the mathematics serialize functions
   */
  var declareMathematics = function(CSICommands)
  {
     declareMathVector3D(CSICommands);
     declareMathVector2D(CSICommands);

     // Depends of vectors
     declareMathPoint(CSICommands);
     declareMathPoint2D(CSICommands);
     declareMath2x2Matrix(CSICommands);
     declareMath3x3Matrix(CSICommands);

     // Depends of points & vectors
     declareMathAxis(CSICommands);
     declareMathLine(CSICommands);
     declareMathLine2D(CSICommands);
     declareMathCircle(CSICommands);

     // Depends of point & vector & mat3x3
     declareMathTransformation(CSICommands);

     // Depends of point & vector & line
     declareMathPlane(CSICommands);
  };

  return declareMathematics;
});
