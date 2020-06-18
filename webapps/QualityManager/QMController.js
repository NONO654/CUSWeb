/**
* @fullreview XK7 I2S 17:12:29
*/

define(
  //define - file Path
  'DS/QualityManager/QMController',
  //define - Dependencies
  [
    'UWA/Core',
    'UWA/Class',
    'DS/QualityManager/QMPresetStreamer'
  ],

  function (
    UWACore,
    UWAClass,
    QMPresetStreamer
  ) {
   'use strict';

   var QMController = UWAClass.singleton({
        
    init: function () {

     this.isInitialized = true;
     this.initPresetDB();
    },
    
    linkToViewer: function(iViewer) {

        this._webGLV6Viewer = iViewer;
    },
    
    //getInstance: function (iWebGLV6Viewer) {

    //    if (!isInitialized)
    //    init(iWebGLV6Viewer);
    //},

    initPresetDB: function () {

     QMPresetStreamer.init();
     this.currentUser = QMPresetStreamer.getItem("currentUser"); // currentUser will contain string value for current user
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

    getCurrentUserPresetQuery: function () {

     var query = "Users/" + this.currentUser + "/" + "Preset/";
     return query;
    },

    validateAttribute: function (iAttrib, iValue) {

     var retVal = true;

     if (iAttrib == "ReflectionsOnGround" || iAttrib == "Preset")
      retVal = false;

     return retVal
    },

    setAttribute: function (iMode, iPreset, iProperty, iAttrib, iValue) {

     this.setAttributeOnViewer(iMode,iAttrib, iValue);
     this.setAttributeOnDB(iMode, iPreset, iProperty, iAttrib, iValue);
    }, 

    setAttributeOnViewer: function (iMode,iAttrib, iValue) {

     // kind of patch
     if (iAttrib == "IterativeAntiAliasing")
     {
      if (iValue == "NoAA")
      {
       return false;
      }
      iAttrib = "AntiAliasing";
     }
     
     if (!this.validateAttribute(iAttrib, iValue))
      return false;
     

     var oldValue = this._webGLV6Viewer._getQMSetting(iAttrib);
     if (oldValue.value != iValue) {

      var property;
      if (typeof iValue === 'string')
       property = JSON.parse('{' + '"' + iAttrib + '"' + ':' + '"' + iValue + '"' + '}');
      else
       property = JSON.parse('{' + '"' + iAttrib + '"' + ':' + iValue + '}');

      this._webGLV6Viewer._setQMSettings(property);

      var curValue = this._webGLV6Viewer._getQMSetting(iAttrib);
      if (curValue.value != oldValue.value)
       return true;
     }
     return false;
    },

    setAttributeOnDB: function (iMode,iPreset, iProperty, iAttrib, iValue) {

     var query = this.getCurrentUserPresetQuery() + iMode + "/" + this.prestToModify + "/" + iProperty + "/";
     var attribQuerry = query + iAttrib;
     QMPresetStreamer.setItem(attribQuerry, iValue);

     var presetQuerry = query + "Preset";
     QMPresetStreamer.setItem(presetQuerry, iPreset);

     //QMPresetStreamer.commit();
    },

    setProperty: function (iMode, iPreset, iProperty) {

     this.setPropertyOnViewer(iMode, iPreset, iProperty);
     this.setPropertyOnDB(iMode, iPreset, iProperty);
    },

    setPropertyOnViewer: function (iMode, iPreset, iProperty) {

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
       this.setAttributeOnViewer(iMode, attrib, value);
      }
     }
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

     this.setGlobalPresetOnViewer(iMode, iPreset);
     this.setGlobalPresetOnDB(iMode, iPreset, iUpdatePropertyDB);
     },

    setGlobalPresetOnViewer: function (iMode, iPreset) {

     var query = this.getCurrentUserPresetQuery() + iMode + "/" + iPreset;
     var rootProperties = QMPresetStreamer.getItem(query);
     if (!UWACore.is(rootProperties))
      return false;

     for (var currentProperty in rootProperties) {
      if (rootProperties.hasOwnProperty(currentProperty)) {
       this.setPropertyOnViewer(iMode, iPreset, currentProperty)
      }
     }
    },

    setGlobalPresetOnDB: function (iMode, iPreset,iUpdatePropertyDB) {

     var query = this.getCurrentUserPresetQuery() + iMode + "/currentGlobalPreset";
     QMPresetStreamer.setItem(query, iPreset);
     //QMPresetStreamer.commit();

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
     var currentPreset = this.getCurrentGlobalPreset("Static");
     this.setGlobalPreset("Static", currentPreset, false);

     //currentPreset = this.getCurrentGlobalPreset("Dynamic");
    // this.setGlobalPreset("Dynamic", currentPreset, false);
    },

    dispose: function() {

     this._webGLV6Viewer = null;
    }
   });
   return QMController;
  });
