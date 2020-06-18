/**
* @fullreview XK7 I2S 17:11:29
* refrence used : SNInfraUX/SNInfraUX.mweb/src/SearchPreferences.js
*/
(function () {
    var prereqs = [
        'UWA/Core',
        'UWA/Class'
    ];
    if (window.location.protocol !== "file:") {
        prereqs.push('text!DS/QualityManager/assets/mdl_GIVisualQualityPresets.json');
    }
    define(
      //define - file Path
      'DS/QualityManager/QMGIPresetStreamer',
      //define - Dependencies
        prereqs,

      function (
        UWACore,
        UWAClass,
        mdlQualityManagerPreset
      ) {

          'use strict';

          var QMPresetStreamer = UWAClass.singleton({

              init: function () {
                  this.GIQualityPresets = this.getQualityPresets();
                  if (!UWACore.is(this.GIQualityPresets))
                      return;
              },

              setItem: function (iKey, iValue) {
                  if (!UWACore.is(localStorage) || !UWACore.is(this.GIQualityPresets))
                      return;

                  var prevObj = this.GIQualityPresets;
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
                  if (!UWACore.is(localStorage) || !UWACore.is(this.GIQualityPresets))
                      return null;

                  var prevObj = this.GIQualityPresets;
                  var keyArray = iKey.split("/");
                  var keyLength = keyArray.length;
                  for (var i = 0 ; i < keyLength; i++) {
                      if (UWACore.is(prevObj))
                          prevObj = prevObj[keyArray[i]];
                  }

                  return prevObj;
              },

              // if not present this func will generate entire quality preset model from QualityManager.mweb\src\assets\mdl_GIVisualQualityPresets.json
              // else retriew model from local database
              getQualityPresets: function () {
                  var GIQualityPresets = null;

                  if (!UWACore.is(localStorage))
                      return GIQualityPresets;

                  var qualityPresetsDB = localStorage.getItem('GIQualityPresets');
                  if (UWACore.is(qualityPresetsDB)) {
                      try {
                          GIQualityPresets = JSON.parse(qualityPresetsDB);
                      }
                      catch (e) {
                          console.error('Error parsing GIQualityPresets:', e);
                      }
                  }
                  else {
                      GIQualityPresets = this.buidQualityPresets();
                  }

                  return GIQualityPresets;
              },

              commit: function () {
                  if (!UWACore.is(localStorage) || !UWACore.is(this.GIQualityPresets))
                      return;

                  localStorage.setItem('GIQualityPresets', JSON.stringify(this.GIQualityPresets));
              },

              retoreDB: function () {
                  this.GIQualityPresets = this.getQualityPresets();
              },

              buidQualityPresets: function () {
                  this.GIQualityPresets = mdlQualityManagerPreset ? JSON.parse(mdlQualityManagerPreset) : null;
                  if (UWACore.is(this.GIQualityPresets)) {
                      this.commit();
                  }
                  return this.GIQualityPresets;
              },

          });
          return QMPresetStreamer;
      });
})();
