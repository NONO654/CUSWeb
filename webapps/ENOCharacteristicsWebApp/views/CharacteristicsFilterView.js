define("DS/ENOCharacteristicsWebApp/views/CharacteristicsFilterView",["UWA/Core","UWA/Class/View","DS/Logger/Logger","DS/ENOCharacteristicsWebApp/controls/TextFilterBox"],function(e,d,b,c){var a=d.extend({name:"CharacteristicsFilterView",className:"gls_ctn_filter",_logger:null,_context:null,_charDlgWindow:null,_fltBox:null,setup:function(f){var g=f||{};this._logger=b.getLogger("CharacteristicsFilterView");this._logger.log("setup");this._parent(f);this._context=f.CharacteristicsControl;this._charDlgWindow=f.CharacteristicsWindow},render:function(){this._logger.log("render");this._fltBox=new c({CharacteristicsControl:this._context,CharacteristicsWindow:this._charDlgWindow});this.container.setContent(this._fltBox);return this},setFilter:function(f){this._fltBox.setFilter(f)}});return a});