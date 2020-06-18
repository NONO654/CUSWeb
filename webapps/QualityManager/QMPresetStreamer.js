/**
* @fullreview XK7 I2S 17:11:29
* refrence used : SNInfraUX/SNInfraUX.mweb/src/SearchPreferences.js
*/
(function(){
    var prereqs = [
        'UWA/Core',
        'UWA/Class'
    ];
    if(window.location.protocol !== "file:") {
        prereqs.push('text!DS/QualityManager/assets/mdl_QualityManagerPreset.json');
    }
define(
  //define - file Path
  'DS/QualityManager/QMPresetStreamer',
  //define - Dependencies
    prereqs,

  function (
    UWACore,
    UWAClass,
    mdlQualityManagerPreset
  ) {

    'use strict';

    var QMPresetStreamer = UWAClass.singleton({

      init: function ()
      {
        this.qualityPresets	= this.getQualityPresets();
        if (!UWACore.is( this.qualityPresets))
        return;
      },

      setItem: function (iKey, iValue)
      {
       if (!UWACore.is(localStorage) || !UWACore.is(this.qualityPresets))
        return;

       var prevObj = this.qualityPresets;
       var keyArray = iKey.split("/");
       var keyLength = keyArray.length;

       for (var i = 0 ; i < keyLength; i++) {
        if (i == keyLength - 1) {
         if (UWACore.is(prevObj))
          prevObj[keyArray[i]] = iValue;
        }
        else {
         if (UWACore.is(prevObj))
          prevObj = prevObj[keyArray[i]];
        }
       }
      },

      getItem: function (iKey) {
       if (!UWACore.is(localStorage) || !UWACore.is(this.qualityPresets))
        return null;

       var prevObj = this.qualityPresets;
       var keyArray = iKey.split("/");
       var keyLength = keyArray.length;
       for (var i = 0 ; i < keyLength; i++) {
        if (UWACore.is(prevObj))
         prevObj = prevObj[keyArray[i]];
       }

       return prevObj;
      },

     // if not present this func will generate entire quality preset model from QualityManager.mweb\src\assets\mdl_QualityManagerPreset.json
     // else retriew model from local database
      getQualityPresets: function () {
       var qualityPresets = null;

       if (!UWACore.is(localStorage))
        return qualityPresets;

       var qualityPresetsDB = localStorage.getItem('qualityPresets');
       if (UWACore.is(qualityPresetsDB)) {
        try {
         qualityPresets = JSON.parse(qualityPresetsDB);
        }
        catch (e) {
         console.error('Error parsing qualityPresets:', e);
        }
       }
       else {
        qualityPresets = this.buidQualityPresets();
       }

       return qualityPresets;
      },

      commit: function ()
      {
       if (!UWACore.is(localStorage) || !UWACore.is(this.qualityPresets) )
        return;

       localStorage.setItem('qualityPresets', JSON.stringify(this.qualityPresets));
      },

      retoreDB:function()
      {
       this.qualityPresets = this.getQualityPresets();
      },

      buidQualityPresets:function ()
      {
          this.qualityPresets = mdlQualityManagerPreset ? JSON.parse(mdlQualityManagerPreset) : null;
       if (UWACore.is(this.qualityPresets))
        {
          this.commit();
        }        
       return this.qualityPresets;
      },
     
    });
    return QMPresetStreamer;
  });
})();
