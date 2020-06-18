(function(GLOBAL, template) {
    var typeRepFactory, demoControl;
    var getTreeDocument, getTreeListView;
    var getTreeNodeModel, getTreeNodeView;

    var imported = false;
    var readyFunctions = [];
    
    ////////////////////////////////////////////
    // --------- Import/Setup stuff --------- //
    ////////////////////////////////////////////

    // Set up some callbacks to execute functions when typeRepFactory is ready.
    var onImport = function(cb) {
        if (typeRepReady) {
            cb();
        } else {
            readyFunctions.push(cb);
        }
    };
    
    var executeReadyFunctions = function(){
    	//To be called after import.
    	imported = true;
    	var fn
    	while(fn = readyFunctions.shift() !== undefined){
    		typeof fn === function ? fn() : throw 'Ready function must be a function.';
    	}
    };
    
    var UWA, UWAPromise, TreeListView, TreeNodeModel, TypeRepFactory, NLSUtils, SMAAnalyticsTweakerUI;
    var typeRepFactory;
    
    require([
		'UWA/Core',
		'UWA/Class/Promise',
		'DS/Tree/TreeListView',
		'DS/Tree/TreeNodeModel',
		'DS/Tweakers/TypeRepresentationFactory',
		'DS/SMAAnalyticsNLS/SMAAnalyticsNLSUtils',
		'DS/SMAAnalyticsTweakerUI/SMAAnalyticsTweakerUI',
		'DS/SMAAnalyticsUI/SMAAnalyticsPopover',
	],
	function (_UWA, _UWAPromise, _TreeListView, _TreeNodeModel, _TypeRepFactory, _NLSUtils, _SMAAnalyticsTweakerUI) {
    	UWA = _UWA;
    	UWAPromise = _UWAPromise;
    	TreeListView = _TreeListView;
    	TreeNodeModel = _TreeNodeModel;
    	TypeRepFactory = _TypeRepFactory;
    	NLSUtils = _NLSUtils;
    	SMAAnalyticsTweakerUI= _SMAAnalyticsTweakerUI;
    	
    	var typeRepFactory = new TypeRepFactory();
    	typeRepFactory.onReady = executeReadyFunctions();
    });
    
    /////////////////////////////////////////
    // --------- Create Elements --------- //
    /////////////////////////////////////////

    var stylePanelPrototype = { is: 'ra-tweakerstylepanel', behaviors: [] };

    stylePanelPrototype.createdCallback = function() {
        var that = this;

        var clone = document.importNode(template.content, true);
        this.appendChild(clone);
        
        this._applyCb = function(){}; //no-op for placeholder (for robustness). Should get set before it gets called.
        
        this.divs = {};

        onImport(function() {
        	that.initialize();
        });
    };
    
    stylePanelPrototype.initialize = function(){
    	//Create tweaker UI
    	this.
    	
    	//Create buttons
    };
    
    stylePanelPrototype.setTweakerJson = function(json){
    	var that = this;
    	
    	this.tweakerJson = json;
    	
    	onImport(function(){
    		that.tweakerUi.buildTweakerUI(that.divs.tweakerContainer, that.tweakerJson, typeRepFactory /*, proxy*/);
    	});
    };
    
    stylePanelPrototype.onApply = function(cb){
    	if(typeof cb === 'function'){
    		this._applyCb = cb;
    	} else {
    		throw 'Callback must be a function.';
    	}
    };
    
    stylePanelPrototype.onCancel = function(cb){
    	
    };
});

