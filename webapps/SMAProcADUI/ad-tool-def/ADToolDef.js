/*!  Copyright 2017 Dassault Systemes. All rights reserved. */
define(["DS/SMAProcADUI/ad-util/ADObservable"],function(b){var a={};var c=function(){this._modelID="";this._name="";this._description="";this._icon="";this._lifecycleState="";this._revision="";this._revisionComments="";this._isLatestRevision=true;Object.defineProperty(this,"modelID",{get:function(){return this._modelID}});Object.defineProperty(this,"name",{get:function(){return this._name}});Object.defineProperty(this,"description",{get:function(){return this._description}});Object.defineProperty(this,"icon",{get:function(){return this._icon},set:function(d){this._icon=d;if(!this._initializing){this.notifyObservers("icon")}}});Object.defineProperty(this,"lifecycleState",{get:function(){return this._lifecycleState}});Object.defineProperty(this,"revision",{get:function(){return this._revision}});Object.defineProperty(this,"revisionComments",{get:function(){return this._revisionComments}});Object.defineProperty(this,"isLatestRevision",{get:function(){return this._isLatestRevision}});b.makeObservable(this)};a.ADToolDef=c;c.prototype.load=function(d){this._modelID=d.id;this._name=d.title?d.title:"Unknown tool";this._description=d.description?d.description:"No description available";this._icon="";this._lifecycleState=d.currentState;this._revision=d.revision;this._revisionComments=d.revisionComments?d.revisionComments:"";this._isLatestRevision=d.isLatestrevision};return a});