/*! Copyright 2014 Dassault Systèmes */
var testVariable="Ext";var ShimModuleName="DS/ENOGantt/Ven/Ext";var VenModuleName="Sencha";var VenMWebName="DS/Sencha/";var jsName="ext-all";var deps=[];if(typeof window[testVariable]!=="undefined"){define(ShimModuleName,function(){return window[testVariable]})}else{if(require.toUrl(VenMWebName+VenModuleName).indexOf(jsName)===-1){var lMwebPath=require.toUrl(VenMWebName);var lIndexOfQuestionMark=lMwebPath.indexOf("?");if(lIndexOfQuestionMark>-1){lMwebPath=lMwebPath.substring(0,lIndexOfQuestionMark)}var pathConfig={};pathConfig[VenMWebName+VenModuleName]=lMwebPath+jsName;var shimConfig={};shimConfig[VenMWebName+VenModuleName]={deps:deps,exports:testVariable};require.config({paths:pathConfig,shim:shimConfig})}}define(ShimModuleName,[VenMWebName+VenModuleName],function(a){return a});