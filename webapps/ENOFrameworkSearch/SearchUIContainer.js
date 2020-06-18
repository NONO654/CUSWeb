define('DS/ENOFrameworkSearch/SearchUIContainer', [
    'UWA/Core',
	'UWA/Class/Debug',
    'UWA/Controls/Abstract',
	'UWA/Class/Listener',
	'UWA/Drivers/Alone',
	'DS/SNInfraUX/SearchUtils',
	'i18n!DS/ENOFrameworkSearch/assets/nls/ENOFrameworkSearch.json'
], function (UWACore,
	UWADebug,
    UWAAbstract,
	Listener,
	Alone,
	SearchUtils,
	SearchUIContaineri18n
	) {
		'use strict';
		var SearchUIContainer = UWAAbstract.extend(UWADebug, Listener, {
			init:function(parentElement, isInContext){
				var searchMainDivClasses = "windowshade search push-right";
				if(SearchUtils.isInTheSimpleSearch() === true){
					searchMainDivClasses = "windowshade search";
				}
				var searchMainDiv = UWA.createElement('div', {
					'id':'searchContainer',
					'class':searchMainDivClasses,
					'styles':{'z-index': '1300',
							'bottom': '0px', 
							'display': 'none', 
							'top': '43px',
							'background-color': 'white'
					}
				});
				
				searchMainDiv.inject(parentElement.document.body);
				var searchBody = UWA.createElement('div', {
					'class':'windowshade-body'
				});
				searchBody.inject(searchMainDiv);
				var searchContent = UWA.createElement('div', {
					'id':'pageContentDiv1',
					'styles':{'bottom': '0px', 'top': '0px'}
				});
				searchContent.inject(searchBody);

				var searchHeaderDiv = UWA.createElement('div', {
					'id':'divSearchHead',
					'class':'windowshade-header',
					'styles':{'text-align': 'end', 'background-color': 'white'}
				});
				searchHeaderDiv.inject(searchContent);
				if(!isInContext){
				var closeButtonToolTip =  SearchUIContaineri18n.get("close_button_tooltip");
				var cancelSpan = UWA.createElement('span', {
					'class':'fonticon fonticon-2x fonticon-cancel',
					'title':closeButtonToolTip,
					'id':'closeWidget',
					'styles':{'cursor':'pointer','color':'#b4b6ba','border-color':'#d1d4d4','vertical-align':'center','line-height':'40px','font':'18px','position':'absolute','right':'4px','font-size':'18px'}
				});
				cancelSpan.inject(searchHeaderDiv);
				}
				var searchResultsDiv = UWA.createElement('div', {
					'id':'windowshade-content',
					'class':'windowshade-content form',
					'styles':{'left':'0px'}
				});
				searchResultsDiv.inject(searchContent);
				var searchResultsSubDiv = UWA.createElement('div', {
					'id':'searchResultsContainer',
					'styles':{'height':'100%'}
				});
				searchResultsSubDiv.inject(searchResultsDiv);
				jQuery('#closeWidget').bind('click', function(){
					jQuery('#searchContainer').fadeOut(); 
					jQuery('#searchResultsContainer').empty();
				});
				if(isInContext){
					jQuery('#tagger-close').hide();
				}
			}
		});
		return SearchUIContainer;
	});
