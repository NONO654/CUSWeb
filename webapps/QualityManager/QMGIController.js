/**
* @fullreview 
*/

define(
  //define - file Path
  'DS/QualityManager/QMGIController',
  //define - Dependencies
  [
    'UWA/Core',
    'UWA/Class',
    'DS/QualityManager/QMGIPresetStreamer'
  ],

  function (
    UWACore,
    UWAClass,
    QMPresetStreamer
  ) {
      'use strict';

      var QMGIController = UWAClass.singleton({

          init: function () {

              this.isInitialized = true;
              this.initPresetDB();
              this.properties = {};
              this._QMSettings = {
                  MaxSamples: { value: { "Static": true, "Batch": false } },
                  MinSamples: { value: { "Static": true, "Batch": false } },
                  Clamping: { value: { "Static": true, "Batch": true } },
                  GaussFilter: { value: { "Static": true, "Batch": true } },
                  Size: { value: { "Static": true, "Batch": true } },
                  CenterWeight: { value: { "Static": true, "Batch": true } },
                  MAxTraceDepth: { value: { "Static": true, "Batch": true } },
                  GlossyThreshold: { value: { "Static": true, "Batch": true } },
                  RenderRefractiveShadow: { value: { "Static": true, "Batch": true } },
                  LocationBasedSampling: { value: { "Static": true, "Batch": true } },
                  Distribution: { value: { "Static": true, "Batch": true } },
                  Factor: { value: { "Static": true, "Batch": true } },
                  PathTerminationDepth: { value: { "Static": true, "Batch": true } },
                  VisualizationMode: { value: { "Static": true, "Batch": false } },
                  EnableFinalGathering: { value: { "Static": true, "Batch": true } },
                  NoOfPhotons: { value: { "Static": true, "Batch": true } },
                  PathDepth: { value: { "Static": true, "Batch": true } },
                  PhotonRadius: { value: { "Static": true, "Batch": true } },
                  RefineMap: { value: { "Static": true, "Batch": true } },
                  PrecalculateIrradiance: { value: { "Static": true, "Batch": true } },
                  Caustics: { value: { "Static": true, "Batch": true } },
                  CausticsPhotonNumber: { value: { "Static": true, "Batch": true } },
                  CausticsPathDepth: { value: { "Static": true, "Batch": true } },
                  CausticRadius: { value: { "Static": true, "Batch": true } },
                  CausticRefinePhotonMap: { value: { "Static": true, "Batch": true } },
                  RayOffset: { value: { "Static": true, "Batch": true } },
                  AllowGroundShadows: { value: { "Static": true, "Batch": true } },
                  AllowReflectionsOnGround: { value: { "Static": true, "Batch": true } },
                  AllowBloom: { value: { "Static": true, "Batch": true } },
                  AllowDepthOfField: { value: { "Static": true, "Batch": true } },
                  DownsamplingFctor: { value: { "Static": true, "Batch": false } },
              };
          },

          initPresetDB: function () {

              QMPresetStreamer.init();
              this.currentUser = QMPresetStreamer.getItem("currentUser"); // currentUser will contain string value for current user
              var query = "Users/" + this.currentUser + "/" + "currentPreset";
              this.currentPreset = QMPresetStreamer.getItem(query); // currentPreset will contain string value for current Rendering mode
              this.prestToModify = "Custom"; // may be in future we can add more modifiable preset than Custom
          },

          setCurrentUser: function (iUserName) {

              var query = "Users/" + iUserName;
              var user = QMPresetStreamer.getItem(query);

              if (UWACore.is(user)) {
                  QMPresetStreamer.setItem("currentUser", iUserName);
                  this.currentUser = iUserName;
              }
              else {
                  //ToDO : if user is not saved in DB create user
                  //QMPresetStreamer.createUser(iUserName);
                  //QMPresetStreamer.setItem("currentUser", iUserName);
                  // this.currentUser = iUserName;
              }

          },

          setCurrentPreset: function (iPresetName) {

              var query = "Users/" + this.currentUser + "/" + "currentPreset";
              var preset = QMPresetStreamer.getItem(query);

              if (UWACore.is(preset)) {
                  QMPresetStreamer.setItem(query, iPresetName);
                  this.currentPreset = iPresetName;
              }
              else {
                  //ToDO : if user is not saved in DB create user
                  //QMPresetStreamer.createUser(iUserName);
                  //QMPresetStreamer.setItem("currentUser", iUserName);
                  // this.currentUser = iUserName;
              }

          },

          getCurrentUserPresetQuery: function () {

              var query = "Users/" + this.currentUser + "/" + "Preset/";
              return query;
          },

          getCurrentPreset: function () {

              var query = "Users/" + this.currentUser + "/" + "currentPreset";
              var preset = QMPresetStreamer.getItem(query);
              return preset;
          },

          validateAttribute: function (iAttrib, iValue) {

              var retVal = true;

              if (iAttrib == "ReflectionsOnGround" || iAttrib == "Preset")
                  retVal = false;

              return retVal
          },

          setAttribute: function (iMode, iPreset, iProperty, iAttrib, iValue) {

              this.setAttributeOnDB(iMode, iPreset, iProperty, iAttrib, iValue);
          },
 
          setAttributeOnDB: function (iMode, iPreset, iProperty, iAttrib, iValue) {

              var query = this.getCurrentUserPresetQuery() + iMode + "/" + this.prestToModify + "/" + iProperty + "/";
              var attribQuerry = query + iAttrib;
              QMPresetStreamer.setItem(attribQuerry, iValue);

              var presetQuerry = query + "Preset";
              QMPresetStreamer.setItem(presetQuerry, iPreset);

          },

          setProperty: function (iMode, iPreset, iProperty) {

              this.setPropertyOnDB(iMode, iPreset, iProperty);
          },

          setPropertyOnDB: function (iMode, iPreset, iProperty) {

              var query = this.getCurrentUserPresetQuery() + iMode + "/" + iPreset;
              var rootProperties = QMPresetStreamer.getItem(query);
              if (!UWACore.is(rootProperties))
                  return false;

              var currentProperty = rootProperties[iProperty];
              if (!UWACore.is(currentProperty))
                  return false;

              for (var attrib in currentProperty) {
                  if (currentProperty.hasOwnProperty(attrib)) {
                      var value = currentProperty[attrib];
                      this.setAttributeOnDB(iMode, iPreset, iProperty, attrib, value);
                  }
              }
          },

          setGlobalPreset: function (iMode, iPreset, iUpdatePropertyDB) {
              this.setGlobalPresetOnDB(iMode, iPreset, iUpdatePropertyDB);
          },

          setGlobalPresetOnDB: function (iMode, iPreset, iUpdatePropertyDB) {

              var query = this.getCurrentUserPresetQuery() + iMode + "/currentGlobalPreset";
              QMPresetStreamer.setItem(query, iPreset);
            
              if (!iUpdatePropertyDB)
                  return;

              query = this.getCurrentUserPresetQuery() + iMode + "/" + iPreset;
              var rootProperties = QMPresetStreamer.getItem(query);
              if (!UWACore.is(rootProperties))
                  return false;

              for (var currentProperty in rootProperties) {
                  if (rootProperties.hasOwnProperty(currentProperty)) {
                      this.setPropertyOnDB(iMode, iPreset, currentProperty)
                  }
              }
          },

          getCurrentGlobalPreset: function (iMode) {

              var query = this.getCurrentUserPresetQuery() + iMode + "/currentGlobalPreset";
              var oGlobalPreset = QMPresetStreamer.getItem(query);
              return oGlobalPreset;
          },

          getPresetValue: function (iMode, iPreset) {

              var query = this.getCurrentUserPresetQuery() + iMode + "/" + iPreset;
              var oProperties = QMPresetStreamer.getItem(query);
              return oProperties;
          },

          commitToDB: function () {

              QMPresetStreamer.commit();
          },

          restoreFromDB: function () {

              QMPresetStreamer.retoreDB();
              var currentRenderingMode = this.getCurrentPreset();
              var currentPreset = this.getCurrentGlobalPreset(currentRenderingMode);
              this.setGlobalPreset(currentRenderingMode, currentPreset, false);
          },
          setQMsetting: function (iParams, iMode, iValue) {
              var setting = this._QMSettings[iParams];
              if(iValue == "true") 
                  setting.value[iMode] = true;
              else
                  setting.value[iMode] = false;
              //switch (iParams) {
              //    case "MaxSamples":
              //        {
              //            this._QMSettings.MaxSamples.value[iMode] = iValue;
              //            break;
              //        }
              //}
          },

          getQMsetting: function (iParams, iMode) {
              //switch (iParams) {
              //    case "MaxSamples":
              //        {
              //            return this._QMSettings.MaxSamples.value[iMode];
              //            break;
              //        }
              //}
              var setting = this._QMSettings[iParams];
              return setting.value[iMode];
               
          },


      });
      return QMGIController;
  });
