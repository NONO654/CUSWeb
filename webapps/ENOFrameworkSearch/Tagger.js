define('DS/ENOFrameworkSearch/Tagger', [
    'UWA/Core',
	'UWA/Drivers/Alone',
	'UWA/Class/Debug',
    'UWA/Controls/Abstract',
	'UWA/Class/Listener',
	'DS/TagNavigator/TagNavigator',
	'DS/TagNavigatorProxy/TagNavigatorProxy'
], function (UWACore,
	StandAlone,
	UWADebug,
    UWAAbstract,
	Listener,
	TagNavigator,
	TagNavigatorProxy) {
	
	'use strict';
	
    var tagger = UWAAbstract.extend(UWADebug, Listener, {
		tagNavigatorProxy : null,
		init: function () {
			var tagger = TagNavigator.get6WTagger("context2");
			tagger.setAsCurrent();
			
		}
	});
	return tagger;
});
