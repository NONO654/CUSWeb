define(
  'DS/ENOXDataDragAndDrop/js/ENOXDataDragAndDrop',
  [
	'DS/Core/ModelEvents',
	'DS/Handlebars/Handlebars',
  'DS/DataDragAndDrop/DataDragAndDrop',
  'text!DS/ENOXDataDragAndDrop/html/ENOXDataDragAndDrop.html',
  'css!DS/ENOXDataDragAndDrop/css/ENOXDataDragAndDrop.css',
	'css!DS/UIKIT/UIKIT.css'
	],

	function (
    ModelEvents,
    Handlebars,
    DataDragAndDrop,
    htmlEnoxDataDragAndDrop
  ){

    'use strict';
    var template = Handlebars.compile(htmlEnoxDataDragAndDrop);

    var EnoxDataDragAndDrop = function (options) {
      this._init(options);
    };

    EnoxDataDragAndDrop.prototype._init = function(options){
  		var _options = options ? UWA.clone(options, false) : {};
  		var defaults = {
        droppableAreas : [],
        modelEvents : new ModelEvents()
      };
  		UWA.merge(_options, defaults);
      UWA.merge(this, _options);
  		this._initDivs();
      this._render();
  	};

    EnoxDataDragAndDrop.prototype._initDivs = function () {
  		this._container = document.createElement('div');
  		this._container.innerHTML = template(this._options);
      this._container.classList.add("enox-data-drag-drop-main-container");
      UWA.extendElement(this._container);
  	};

    EnoxDataDragAndDrop.prototype._render = function () {
      for (var i = 0; i < this.droppableAreas.length; i++) {
        this._makeHTML5Droppable(this.droppableAreas[i]);
        UWA.extendElement(this.droppableAreas[i]);
      }
    };

    EnoxDataDragAndDrop.prototype._makeHTML5Droppable = function (droppableArea) {
      var that = this;
      this._isInDroppableArea = false; //actual droppable area
      this._isInCurrentContextArea = true;   //Total widget area
      droppableArea.ondragover = function(event) {
        that._isInCurrentContextArea = true;
        if(that._isInDroppableArea){
          event.preventDefault && event.preventDefault();
          if(!event.defaultPrevented) event.defaultPrevented = true;  //For IE
        }else{
            that._isInDroppableArea = true;
            this.classList.add("enox-drag-over");
            event.dataTransfer.effectAllowed = "all";
            event.dataTransfer.dropEffect = "move";
        }
      };
      droppableArea.ondragleave = function(event) {
        that._isInCurrentContextArea = true;
        that._isInDroppableArea = false;
        this.classList.remove("enox-drag-over");
        event.dataTransfer.effectAllowed = "none";
        event.dataTransfer.dropEffect = "none";
      };
      droppableArea.ondrop = function(event) {
        that._isInCurrentContextArea = true;
        that._isInDroppableArea = false;
        this.classList.remove("enox-drag-over");
        event.dataTransfer.dropEffect = "none";
        event.dataTransfer.effectAllowed = "none";
        var data = event.dataTransfer.getData("text");
        var dataDropped = data ? JSON.parse(data) : "";
        if (event.dataTransfer.items) {
          var items = [];
            for (var i = 0; i < event.dataTransfer.items.length; i++) {
              if (event.dataTransfer.items[i].kind === 'file') {
                items.push(event.dataTransfer.items[i].getAsFile());
                dataDropped = {data : items};
              }
            }
          }
        that.modelEvents.publish({event : "onDrop" , data : {data : dataDropped, droparea : this, event : event}});
      };
      document.ondragover = function(event){
        if(!that._isInDroppableArea){// && that._isInCurrentContextArea
          event.dataTransfer.dropEffect = "none";
          event.dataTransfer.effectAllowed = "none";
          event.preventDefault && event.preventDefault();
          if(!event.defaultPrevented) event.defaultPrevented = true;  //For IE
        }
        that._isInCurrentContextArea = false;
      };
      document.ondrop = function(event) {
        that._isInCurrentContextArea = false;
        event.preventDefault && event.preventDefault();
        if(!event.defaultPrevented) event.defaultPrevented = true;  //For IE
      };
    };
    return EnoxDataDragAndDrop;
  }
)
