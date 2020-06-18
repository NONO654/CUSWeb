define('DS/ENOXRelatedItem/js/ENOXCard', [
                                                                       'UWA/Core',
                                                                       'UWA/Class/Model',
                                                                       'UWA/Class/View',
                                                                       'UWA/Class/Events',
                                                                       'DS/Handlebars/Handlebars',
                                                                       'text!DS/ENOXRelatedItem/html/ENOXCard.html',
                                                                       'css!DS/ENOXRelatedItem/css/ENOXCard.css'
                                                                       ], function(
                                                                    		   UWA,
                                                                    		   UWAModel,
                                                                    		   UWAView,
                                                                    		   UWAEvents,
                                                                    		   Handlebars,
                                                                    		   CardTemplate,
                                                                    		   CardCSS
                                                                       ) {
	'use strict';

	var cardTemplate = Handlebars.compile(CardTemplate);
	var ENOXCard = UWAView.extend(UWAEvents,{

		name: 'xapp-card',

		className: function () {
			return this.getClassNames('-container');
		},
		// DOM-Events to be called on on-click or on-cancel of the card
		domEvents: {
			'click .xapp-card-subcontainer': '_triggerSelectCard',
			'click .cancel': '_triggerCancelCard'
		},

		setup: function (options) {
			var that = this;
			that.context = options.context;
			that.model = options.modelKey;
			var templateOptions = {
				closable: UWA.is(options.closable, 'boolean')? options.closable : false,
				needImage: UWA.is(options.needImage, 'boolean')? options.needImage : true,
				image: that.model.get('image'),
				title: that.model.get('title'),
				subtitle: that.model.get('subtitle'),
				description: that.model.get('description')
			};
			that.container.setHTML(cardTemplate(templateOptions));
		},
		
		_triggerSelectCard: function(event){
			var that = this;
			if (event.target.classList.contains('fonticon-close')) {
				return;
			}
			that.dispatchEvent('onSelect', [that, that.context, event]);
		},

		_triggerCancelCard: function (event) {
			var that = this;
			that.dispatchEvent('onCancel', [that, that.context, event]);
		}
	});
	return ENOXCard;
});

