define('DS/ENOChgActionGridUX/scripts/Config/ChgCAAppGlobalVariable',
  ['UWA/Class',
		"DS/Windows/ImmersiveFrame"],
  function(UWAClass, ImmersiveFrame) {
    'use strict';
    var immersiveFrame = new ImmersiveFrame({});
  var xModelGlobalVariable = UWAClass.singleton({
  getImmersiveFrame : function() {
    return immersiveFrame;
  }
})

    return xModelGlobalVariable;
  });
