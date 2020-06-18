define('DS/SemanticAssistant/SemanticAssistant_Slide',[
	'UWA/Core',
	'UWA/Element',
	'UWA/Class',
	'UWA/Class/Events',
	'UWA/Class/Listener',
	'UWA/Class/Options',
	'DS/PlatformAPI/PlatformAPI',
	'DS/PADUtils/PADContext',
	'DS/PADUtils/PADCommandProxy',
	'DS/TraceableRequirementsUtils/REQCommandProxy',
	'DS/SemanticAssistant/Model',
	'DS/UIKIT/Spinner',
    'DS/UIKIT/Scroller',
    'DS/UIKIT/Tooltip',
    'DS/UIKIT/Input/Button',
    'DS/UIKIT/Accordion',
    'DS/TraceableRequirementsUtils/jQuery',
    'DS/CKEditor/CKEditor',
    'i18n!DS/SemanticAssistant/assets/nls/saNLS',
	'css!DS/SemanticAssistant/SemanticAssistant.css'         
     ],
 function(Core,
		 Element,
		 Class,
		 Events,
		 Listener,
		 Options,
		 PlatformAPI,
		 PADContext,
		 PADCommandProxy,
		 REQCommandProxy,
		 SemanticModel,
		 Spinner,
		 Scroller,
		 Tooltip,
		 Button,
		 Accordion,
		 jQuery,
		 CKEditor,
		 saNLS
		 ){
	
	'use strict';
	
	var that = undefined;
	
	var SA = Class.extend(Events, Listener, Options, {			
			
		defaultOptions: {
			container: '.properties-panel',
			model: null
		},
		
		qualityClassNames: {
			high: 'find-in-resultgreen',
			medium: 'find-in-resultyellow',
			low: 'find-in-resultred'
		},
		
		globals: {
			metricDisplayed : null,
			words_detected : null,
			content : null,
			suggestTimeout : null,
			trcClass : 0,
			ckInstance : null,
			CKEDITOR : null,
			reqSpec: null
		},
		
		isLoading: true,
		
		isOpen: false, // boolean to check if panel has been opened
		
		model: undefined, // the module containing server calls to the TRC server
		
		userName: undefined, // dashboard user name
		
		panelSelector: undefined, // class name of panel. Used to update reference to container element.
		
		container: undefined, // actual container element.
		
		commandButton: undefined, // command in action bar to open semantic assistant
		
		lastAssessedReq: undefined, // reference to last requirement that was checked to avoid unnecessary recalculations
		
		selReqHasBeenChanged: false, // boolean if new requirement has been selected since last quality check
		
		selectedMetric: { // selected table row in results of quality check
			element: undefined,
			content: undefined
		},
		
		cursorPosition: undefined, // cursor position in ckeditor to restore after automated quality check
		
		tooltips: [], // stores all tooltip elements to be able to hide and delete them properly
		
		init: function(options) {  
     	  	
//     	  	widget.addPreference({
//     	  		type:"text",
// 		        name:'Url',
// 		        defaultValue:"https://authoring.reusecompany.com:9095/v18.1/trcapi.asmx/"
//     	  	});
     	  	
     	  	// store SA reference
     	  	that = this;
     	  	
     	  	// get container panel to place UI into
     	  	this.container = jQuery(options.container);
     	  	
     	  	// store selector to use on refresh
     	  	this.panelSelector = options.container;
     	  	
     	  	// get reference to command for closing button
     	  	this.commandButton = options.commandButton;
     	  	
     	  	// load 3ds user name to be used with web service
     	  	var userName3DX = PlatformAPI.getUser();
     	  	
     	  	if(UWA.is(userName3DX)) {
     	  		var newUserName = UWA.is(userName3DX.login) ? userName3DX.login : '';
	     	  	//newUserName = UWA.is(userName3DX.lastName) ? newUserName + userName3DX.lastName : newUserName;
	     	  	this.userName = newUserName === '' ? 'DefaultUser' : newUserName;
     	  	} else {
     	  		this.userName = 'DefaultUser';
     	  	}
     	  	
     	  	// get requirement specification name (to be used as title for metric block)
     	  	this.globals.reqSpec = PADContext.get().options.parentName;
     	  	
     	  	// create instance of interface-object that contains methods to communicate with web service servers
     	  	this.model = new SemanticModel(this, this.userName);

     	  	// try to establish connection to web service server
     	  	//this.model.connect(this.userName);
     	  	
		},
		
		toggleOpenClose: function() {
			if(this.isOpen) {
				this.close();
			} else {
				this.open();
			}
		},
		
		open: function() {
			
			this.lastAssessedReq = undefined;
			
			// store opened panel state locally and in rich view (to remember for refresh)
			this.isOpen = true;
			PADContext.get().options.isSemanticQualityPanelOpen = true;
			
			// 'refresh' panel variable
			this.container = jQuery(this.panelSelector);
			
			// make sure the panel is empty
			this.container.empty();
			
			// create panel with header
			this.loadUI(this.container);
			
			// show panel
			this.container.removeClass('off');
			
			// check if requirement specification was changed e.g. via structure editor
			//if (PADContext.get().options.parentName !== this.globals.reqSpec) {
				// reset sessionId and reconnect to TRC server to work with correct project name
				this.globals.reqSpec = PADContext.get().options.parentName;
				//this.model.disconnect(this.model.sessionId);
				//this.model.sessionId = '';
				this.model.connect(this.userName);
			//}
			
			// fill panel with metrics if Req. Specification selected, otherwise show empty panel
			//this.process(false);
			
			// not sure what this was thought to do. Ask Ines.
			this.dispatchEvent('onOpen');
		},
		
		process: function(keepCursorPosition) {
		/// decides whether or not to trigger quality check
			
			if (that.isOpen) {
				
				// only allow check for requirements
				if (that.checkSelection()){
					
					const selectedNode = PADContext.get().getSelectedNodes();
				
					if (UWA.is(selectedNode[0]) && (that.isLoading || !UWA.is(that.lastAssessedReq) || that.lastAssessedReq !== selectedNode[0].options.elementID || that.selReqHasBeenChanged)) {
						
						// if check was triggered by Timer, cursor position has to be restored after check
						if (keepCursorPosition) {
							that.storeCursorPosition();
						} else {
							that.cursorPosition = undefined;
						}
						
						that.checkQualitySelected(selectedNode);
					}
				} else {
					that.showFalseSelection(that.getSelectedType());
				}
			}
		},
		
		checkQualitySelected: function(selectedNode) {
		/// gets the selected requirement and triggers the quality check
			
			// delete highlighting
			this.clearRichViewContent();
			// get Requirement html content
			var node = jQuery("#" + selectedNode[0].options.elementID + "_content");
			// filter problematic/unwanted content
			var content = this.prepareReqContent(node);
			// if empty requirement, show error
			if (content.trim().length === 0) {
				this.showError(saNLS.get('SA_title_emptyRequirement'), saNLS.get('SA_info_emptyRequirement'));
				return;
			}
			// set header and info text
			this.showLoadingState('qualitycheck');
			// calculate quality via web server
			this.model.callbacks.calculateQuality(content);
			// save id of last calculated element to avoid multiple calculations of the same thing
			this.lastAssessedReq = selectedNode[0].options.elementID;
			// reset bool indicating if selected Req has been changed
			this.selReqHasBeenChanged = false;
		},
		
		clearRichViewContent: function(){ 
		/// To remove all existing highlights in RichContentEditor
				
			var qualityKeys = Object.keys(this.qualityClassNames);
			
			for (var i = 0; i < qualityKeys.length; ++i) {
				
				var qualityName = this.qualityClassNames[qualityKeys[i]];
				
				// find spans with class names and remove classes
				jQuery('.rich-object-content span.' + qualityName).contents().unwrap();				
				
			}
		},
		
		loadUI: function(panel) {
		/// Creates and assembles the HTML elements in the panel
			
			// check if container is valid
			if(!UWA.is(panel)) {
				console.error('Container-Panel to initiate SemanticAssistantUI not valid!');
			}
     	  
     	  	// create all panel elements and integrate them in panel
     	  	var container = UWA.createElement('div', {
     	  		'id': 'sa-container'
     	  	});
					
			var qual_header = UWA.createElement('div', {
				'id': 'qual_header',
				html: '<div id="title-bar"><div>'
			});
			
			var cancelButton = UWA.createElement('button', {
				'id': 'cancelButton',
				type: 'button',
				'class': 'close',
				html: '&times;'
			});
			
			var trc_quality = UWA.createElement('div', {
    	  		'id': 'trc_quality'
    	  	});
			
			var trc_metrics = UWA.createElement('div', {
				'id': 'trc_metrics'
			});
			
			var flip_panel = UWA.createElement('div', {
				'id': 'flipPanel'
			});
				
			var trc_main = UWA.createElement('div', {
				'id': 'trc_main'
			});
			
			var leftCollapsiblePanel = UWA.createElement('div', {
				'id': 'leftCollapsiblePanel',
			});
			
			// build element structure
			trc_metrics.inject(flip_panel);
			flip_panel.inject(trc_main);
			cancelButton.inject(qual_header);
			qual_header.inject(trc_quality);
			trc_main.inject(trc_quality);
			trc_quality.inject(leftCollapsiblePanel);
			leftCollapsiblePanel.inject(container);
			
			// place in DOM panel
			panel.html(container);
			
			cancelButton.addEvent('click', function(){
				console.log('closing button pressed');
				that.commandButton.cancel();
		    });
			
			this.tooltips.push(new Tooltip({
			    target: cancelButton,
			    body: saNLS.get('SA_close'),
			    position: 'bottom'
			}));
			
			return container;
			
		},
		
		close: function() {
		/// hides the panel and resets respective variables
			
			// delete highlighting
			this.clearRichViewContent();
			
			// hide tooltips
			this.clearTooltips();
			
			this.isOpen = false;
			this.container.addClass('off');
			PADContext.get().options.isSemanticQualityPanelOpen = false;
			
//			Right now we want to keep the selected metric upon closing, so it automatically is shown on reopening the panel
//			if this changes, uncomment the following lines
//			this.selectedMetric = {
//					element: undefined,
//					content: undefined
//			};
			
			// deactivate the assistant button if no requirement is selected
			this.commandButton._check_select();
			
			this.clearRichViewContent();
		},
		
		resize: function() {
		/// adapts size of panel content to enable and disable scroller
			jQuery('.resultsList').height(jQuery('.tbody').height());
			if (UWA.is(this.selectedMetric.element)) {
				this.selectedMetric.element.nextElementSibling.style.maxHeight = this.selectedMetric.element.nextElementSibling.scrollHeight + 'px';
			}
		},
		
		clearTooltips: function() {
		/// deletes all tooltip elements created for the semantic assistant
			for (var i = 0; i < this.tooltips.length; ++i) {
				if (UWA.is(this.tooltips[i], 'object')) {
					this.tooltips[i].destroy();
				}
			}
			this.tooltips = [];
		},
		
		hideTooltips: function() {
		// hides all tooltip elements created for the semantic assistant
			for (var i = 0; i < this.tooltips.length; ++i) {
				this.tooltips[i].hide();
			}
		},
		
		detailFields: [
		/// contains chapter titles for detail view
				'MetricName',
				'Quality',
				'FeaturesAsString',
				'AffectsOverallQuality',
				'Summary',
				'Description'
         ],
         
         fillMetricsOnError: function(metricsQuality) {
        /// create the table of found metric errors
        	 
			// get empty table
         	var table = this.createEmptyTableHeader();
         	var resultsList = jQuery(table).find('.resultsList');
         	
			jQuery('#trc_metrics').empty();
			
			if (metricsQuality.length === 0 && this.globals.trcClass === '1') {
				// quality is high and no errors were found? -> Damn, that is one perfect requirement
				this.showPerfectRequirement();
				return;
			} else if(this.globals.trcClass === '0') {
				// TRC server seems to have had some issues with the selected requirement. It didn't specify a quality class
				// and has not found any metrics
				this.showError(saNLS.get('SA_title_unexpectedResponse'), saNLS.get('SA_info_unexpectedResponse'));
				return;
			}
			
            // loop through metrics and build table rows
            jQuery(metricsQuality).each(function(index, item) {
					
                if (item.Description !== '')
                {

                    var quality='';
                    var row = '<div class="tableRow">';
                    
					switch (item.QualityLevel)
                    {
                        case'1':
                        	row += '<div class="image col1 highQuality"></div>';
                            quality = 'High';
                            break;
                        case '2':
                        	row += '<div class="image col1 mediumQuality"></div>';
                            quality = 'Medium';
                           	break;
                        case '3':
                        	row += '<div class="image col1 lowQuality"></div>';
                            quality = 'Low';
                           	break;
                    }
					
                    row+='<div class="metricName col2"><p>' + item.MetricName + '</p></div>';
                    row+='<div class="col3">' + quality + '</div></div>';
                    
                    // this was the ancient 4th column to show details
                    //row+= '<div id="details" class="col4 info"></div>';
                    
                    var htmlRow = jQuery(row);
                    var detailPanel = that.createDetailPanel(item);  
                    
                    // handle selection
                    htmlRow.click(function() {
                    	that.onTableRowSelect(htmlRow[0], item);              	
                    });
                    
                    // add tooltip so full title can be seen
                    that.tooltips.push(new Tooltip({
        			    target: htmlRow.find('.metricName p')[0],
        			    body: item.MetricName,
        			    position: 'bottom',
        			    closeOnClick: true,
        			    delay: {
        			    	show: 300
        			    }
        			}));
                    
                    resultsList.append(htmlRow);
                    resultsList.append(detailPanel);
                    
                    // mark as selected if metric is the same as previous selection
                    if (UWA.is(that.selectedMetric.element) && jQuery(that.selectedMetric.element).html() === htmlRow.html()) {
                    	that.onTableRowSelect(htmlRow[0], item, false);
                    }    
                }
            });
            
            // hide loading sign
            jQuery('.spinner').hide();
            this.isLoading = false;
            
            // add non-native scroll bar
            new Scroller({
			   element: table.getElement('.resultsList')
			}).inject(table.getElement('.tbody'));
            
            // insert table into panel
	        jQuery('#trc_metrics').append(table);
	        
	        // reset cursor position of it was stored
	        if (UWA.is(this.cursorPosition) && this.cursorPosition.length > 0) {
	        	this.restoreCursorPosition();
	        }
	        
	        // set colors etc. for table and table header
	        this.setQualityStatus();
	        
	        // adapt heights for scroll bar 
	        this.resize();
         
        },
         
		createDetailPanel: function(item) {
		///creates and assembles HTML elements for the metric detail panel
				
			var metricDiv = jQuery('<div class="detail-panel">');	
			
			var detailContainer = jQuery('<div class="detail-container">');
			
			var detailFields = this.detailFields;
			
			detailFields.forEach(function(entry){
				
				var title = '';
				var paragraph = jQuery('<p></p>');
				switch(entry){
					case 'MetricName':
						title = '<b>Metric</b><br>';
					break;
					case 'FeaturesAsString':
						title = '<b>Concepts found</b><br>';
					break;
					case 'AffectsOverallQuality':
						title = '<b>Mandatory</b><br>';
					break;
					case 'Description':
						title = '<b>Recomendation</b><br>';
					break;
					default:
						title = '<b>'+entry+': </b><br>';
						break;
				}
				
				paragraph.append(jQuery(title));
				
				if(entry === 'FeaturesAsString'){
					
					var contentText = item[entry];
					
					if(contentText.length > 0){
						
						var words = contentText.split(";");
						
						words.forEach(function(value,index,array){
							
							if(value.length !== 0){
								
								paragraph.append(value);
								
								if(index !== (array.length-1)){
									paragraph.append('<br>');
								}
							}
						});
					}else{
						paragraph.append('None<br>');
					}	
				}else{
					var contentText = item[entry];
					paragraph.append(contentText);
				}
				detailContainer.append(paragraph);
			});
			
			//metricDiv.append(header);
			metricDiv.append(detailContainer);

			return metricDiv;        	
		},
		
		onTableRowSelect: function(element, item, checkSelected) {
		/// handles selection and deselection of a table row in the metric results
			
			// due to some bug that sometimes it is 'forgotten' to hide a tooltip, do that manually
			this.hideTooltips();
			
			if (!UWA.is(checkSelected, 'boolean')) checkSelected = true;
			
			if (!checkSelected || !jQuery(element).hasClass('selected')) {
			// called either if table row is not selected or if it should not be checked if it is selected
				
				// remove current selection
				if (UWA.is(this.selectedMetric) && UWA.is(this.selectedMetric.element)) {
					jQuery(this.selectedMetric.element).removeClass('selected');
					this.selectedMetric.element.nextElementSibling.style.maxHeight = null;
				}
				
				// store selected item and element
				this.selectedMetric = {
						element: element,
						content: item
				};
				
				// deselect all table rows and hide detail panels
				jQuery(element).parent().children('.tableRow').each(function(index, row){
					if (jQuery(row).hasClass('selected')) {
						jQuery(row).removeClass('selected');
						row.nextElementSibling.style.maxHeight = 0;
					}
				});
				
				// add selection to clicked row
				jQuery(element).addClass('selected');
			    
			    var rtf = item.MetricRtf;
			    this.globals.metricDisplayed = item;
			    
			    // show details panel of selected item
				element.nextElementSibling.style.maxHeight = element.nextElementSibling.scrollHeight + 'px';
                
				// clear all highlighted words in richView
				this.clearRichViewContent(); 
				
				if (rtf !== '' || item.FeaturesAsString !== '') {
					
					// highlight word(s) for selected semantic error in richview
					this.highLightErrors(item);
					
			    }
				
			} else {
			// a simple deselection was computed
				
				// clear all highlighted words in richView
				this.clearRichViewContent(); 
				
				jQuery(element).removeClass('selected');
				
				// hide detail panel
				element.nextElementSibling.style.maxHeight = 0;
				
				// clear selection
				this.selectedMetric = {
						element: undefined,
						content: undefined
				};
			}
		},
		
		setQualityStatus: function() { 
		/// Changes the color of the UI depending of global quality of the selected requiement 
             
		 	jQuery('#trc_quality').removeClass();
           	jQuery('#qual_header').removeClass();
         	
            switch (this.globals.trcClass)
            {
               
                case '1':
             	  	jQuery('#qual_header').addClass('trc_quality_high');
             	 	jQuery('#qual_header #title-bar').html('High Quality');
             	 	jQuery('#trc_quality').addClass('trc_metric_high');
                   	break;
                case '2':
        	  		jQuery('#qual_header').addClass('trc_quality_medium');
        		 	jQuery('#qual_header #title-bar').html('Medium Quality');
        		 	jQuery('#trc_quality').addClass('trc_metric_medium');
                   	break;
                case '3':
             	  	jQuery('#qual_header').addClass('trc_quality_low');
             	 	jQuery('#qual_header #title-bar').html('Low Quality');
             	 	jQuery('#trc_quality').addClass('trc_metric_low'); 
                   	break;
          	   default:
          		   // no quality class is assigned, usually during error or false selection
          		   jQuery('#qual_header').addClass('trc_quality_not_assessed');
          		   jQuery('#trc_quality').addClass('trc_metric_not_assessed');
              		break;
            }
        },
        
        createEmptyTableHeader: function() { 
        /// creates and returns an empty table containing only header
			
			var table = UWA.createElement('div', {
			    'class': 'metric_table table-hover resultsTable',
			});
			var theader = UWA.createElement('div', {
				'class': 'tableRow thead',
				html: '<div class="col1"> </div><div class="col2">' + saNLS.get('SA_metric') + '</div><div class="col3">' + saNLS.get('SA_quality') + '</div>'
			});
			var ul = UWA.createElement('div', {
				'id': 'to-scroll',
				'class': 'resultsList'
			});
			var tbody = UWA.createElement('div', {
				'id': 'container-scroll',
				'class': 'tbody'
			});
			
			ul.inject(tbody, 'top');
			theader.inject(table, 'top');
			tbody.inject(table, 'bottom');
			
			return table;
			
		},
		
		onConnectionFailed: function(msg) {
			
			var msg = UWA.is(msg) ? msg : '';
			
			jQuery('.spinner').hide();
			
			var info;
			
			if (msg.length > 0) {
				info = saNLS.get('SA_info_connectionFailedPlusMsg') + '<br>"' + msg + '"';
			} else {
				info = saNLS.get('SA_info_connectionFailed');
			}
			
			this.showError(saNLS.get('SA_title_connectionFailed'), info);
		},
		
		showError: function(title, info) {
		/// displays error message and respective title in semantic assistant panel
			if(!this.isOpen) return;
			this.isLoading = false;
			jQuery('.spinner').hide();
			// reset quality state (border color)
			this.globals.trcClass = 0;
			this.setQualityStatus();
			jQuery('#sa-container #qual_header #title-bar').html(title);
			jQuery('#trc_main #flipPanel #trc_metrics').html('<p class="infoMessage">' + info + '</p>');
		},
		
		showPerfectRequirement: function() {
		/// Displays info message in case no metric error was found by TRC's server
			this.isLoading = false;
			jQuery('.spinner').hide();
			this.setQualityStatus();
			jQuery('#trc_main #flipPanel #trc_metrics').html('<p class="infoMessage">' + saNLS.get('SA_info_perfectReq') + '</p>');
		},
		
		getSelectedElement: function() {
		/// returns the currently in the RichView selected element
			var selectionExists = PADContext.get().getPADTreeDocument().getXSO().get().length ? true : false;
			
			if (selectionExists) {
				return PADContext.get().getSelectedNodes()[0];
			} else {
				return undefined;
			}
		},
		
		checkSelection: function() {
		/// checks if current selection is a requirement or not
			var selectedElement = this.getSelectedElement();
			
			if (selectedElement !== undefined && PADContext.get().getSelectedNodes()[0].options.kindof === 'Requirement') {
				return true;
			} else {
				that.lastAssessedReq = undefined;
				return false;
			}
			
		},
		
		getSelectedType: function() {
		/// returns the type of the currently selected element in the RichView
			var selectedElement = this.getSelectedElement();
			
			if (selectedElement !== undefined && UWA.is(PADContext.get().getSelectedNodes()[0].options.kindof)) {
				return PADContext.get().getSelectedNodes()[0].options.kindof;
			} else {
				return '';
			}
		},
		
		showFalseSelection: function(type) {
		/// shows message informing about a selection other than a requirement
			var type = UWA.is(type) ? type : '';
			
			// hide loading sign
            jQuery('.spinner').hide();
            this.isLoading = false;
            
			// reset last assessed requirement
			this.lastAssessedReq = undefined;
			
			// delete highlighting in rich view
			this.clearRichViewContent();
			
			// reset quality related colors in frames etc.
			this.globals.trcClass = 0;
			this.setQualityStatus();
			
			// if container object exists, adapt content
			if(UWA.is(this.container)) {
				
				if (UWA.is(type) && (type === '' || type === 'Requirement Specification')) {
					jQuery('#sa-container #qual_header #title-bar').html(saNLS.get('SA_title_noSelection'));
			 		jQuery('#trc_main #trc_metrics').html('<p class="infoMessage">' + saNLS.get('SA_info_noSelection') + '</p>');
				} else if (UWA.is(type) && type.length > 0) {
					jQuery('#sa-container #qual_header #title-bar').html(saNLS.get('SA_title_wrongSelection'));
					jQuery('#trc_main #trc_metrics').html('<p class="infoMessage">' + saNLS.replace(saNLS.get('SA_info_wrongSelection'), {type: type}) + '</p>');
				} else {
					jQuery('#sa-container #qual_header #title-bar').html(saNLS.get('SA_title_wrongSelection'));
			 		jQuery('#trc_main #trc_metrics').html('<p class="infoMessage">' + saNLS.get('SA_info_noSelection') + '</p>');
				}
				
			}
		},
		
		/**
         * @description
         * <p>Removes html elements that are not to be considered in the semantic quality calculation.</p>
         * 
         * @memberof module:DS/SemanticAssistant/SemanticAssistant#
         * 
         * @param {String} content - html node content of selected Requirement
         * 
         * @return {String} output - plain text without figures and other unwanted elements, ready for quality assessment
         */
		prepareReqContent: function(node) {
		/// method to get only longer statements from tables, ignore short statements like numbers or single words in cells
			
			var output = jQuery(node).clone();
			
			// remove figures and links
			output.find('[data-cke-display-name="figure"]').remove();
			output.find('a').remove();
					
			// get rid of table cells and list items with less than 4 words
			output.find('td, li').each(function(index, item) {
				if (jQuery(item).text().split(' ').length < 4) {
					jQuery(item).remove();
				} else {
					// add punctuation mark if not there and space
					if(UWA.is(jQuery(item).text().trim().match('.*[.?!:]'))) {
						jQuery(item).html(jQuery(item).text().trim() + ' ');
				    } else {
				    	jQuery(item).html(jQuery(item).text().trim() + '. ');
				    }
				}
			});
			
			// replace <p> and <div> with punctuation mark and space to concatenate strings properly
			output.find('p div').each(function(index, item) {
				if(UWA.is(jQuery(item).text().trim().match('.*[.?!:]'))) {
					jQuery(item).html(jQuery(item).text().trim() + ' ');
			    } else {
			    	jQuery(item).html(jQuery(item).text().trim() + '. ');
			    }
			});
			
			// in case some unusual tags remain
			output = output.text();
			
			return output;
		},
		
//		showLoadingState: function(title, info) {
//		/// shows spinner element and info message to inform about loading
//			
//			if(this.isOpen) {
//				this.globals.trcClass = '0';
//				this.setQualityStatus();
//				jQuery('#sa-container #qual_header #title-bar').html(title);
//		 		jQuery('#trc_main #trc_metrics').html('<p class="infoMessage">' + info + '</p><p id="saw-spinner-container"></p>');
//		 		
//		 		//create and show loading icon
//				var spinner = new Spinner({
//					id: 'trc_spinner'
//				}).inject(document.getElementById('saw-spinner-container')).show();
//			}
//			this.isLoading = true;
//		},
		
		showLoadingState: function(toWaitFor) {
			/// shows spinner element and info message to inform about loading
			
			// empty the panel
			jQuery('#trc_main #trc_metrics').empty();
			this.globals.trcClass = '0';
			this.setQualityStatus();
			
			// set title
			jQuery('#sa-container #qual_header #title-bar').html(saNLS.get('SA_loading') + ' ...');
			
			// build list of things to do
			var infoList = UWA.createElement('div', {
				'class': 'loading-list'
			}).inject(jQuery('#trc_main #trc_metrics')[0]);
			
			var stepOne = UWA.createElement('div', {
				html: '1. ' + saNLS.get('SA_title_loadingURL')
			}).inject(infoList);
			
			var stepTwo = UWA.createElement('div', {
				html: '2. ' + saNLS.get('SA_title_connectingToServer')
			}).inject(infoList);
			
			var stepThree = UWA.createElement('div', {
				html: '3. ' + saNLS.get('SA_title_calculatingQuality')
			}).inject(infoList);
			
			var iconContainer1 = UWA.createElement('div', {
					'class': 'iconContainer'
			}).inject(stepOne);
			
			var iconContainer2 = UWA.createElement('div', {
				'class': 'iconContainer'
			}).inject(stepTwo);
			
			var iconContainer3 = UWA.createElement('div', {
				'class': 'iconContainer'
			}).inject(stepThree);
			
			// add loading icon and 'done' icon according to step
			if (toWaitFor.toUpperCase() === 'URL') {
				
				var spinner = new Spinner({
					id: 'trc_spinner'
				}).inject(iconContainer1).show();
				
				var hourglass1 = UWA.createElement('span', {
					'class': 'badge badge-default',
					html: '<span class="badge-content fonticon fonticon-hourglass"> </span>'
				}).inject(iconContainer2);
				
				var hourglass2 = UWA.createElement('span', {
					'class': 'badge badge-default',
					html: '<span class="badge-content fonticon fonticon-hourglass"> </span>'
				}).inject(iconContainer3);
				
			} else if (toWaitFor.toUpperCase() === 'CONNECTION') {
				
				var tick = UWA.createElement('span', {
					'class': 'badge badge-success',
					html: '<span class="badge-content fonticon fonticon-check"></span>'
				}).inject(iconContainer1);
				
				var spinner = new Spinner({
					id: 'trc_spinner'
				}).inject(iconContainer2).show();
				
				var hourglass = UWA.createElement('span', {
					'class': 'badge badge-default',
					html: '<span class="badge-content fonticon fonticon-hourglass"> </span>'
				}).inject(iconContainer3);
				
			} else if (toWaitFor.toUpperCase() === 'QUALITYCHECK') {
				
				var tick1 = UWA.createElement('span', {
					'class': 'badge badge-success',
					html: '<span class="badge-content fonticon fonticon-check"></span>'
				}).inject(iconContainer1);
				
				var tick2 = UWA.createElement('span', {
					'class': 'badge badge-success',
					html: '<span class="badge-content fonticon fonticon-check"></span>'
				}).inject(iconContainer2);
				
				var spinner = new Spinner({
					id: 'trc_spinner'
				}).inject(iconContainer3).show();
				
			}
			
			this.isLoading = true;
		},
		
		storeCursorPosition: function(){
		/// stores cursor position in the ckeditor's via a bookmark element before automatically triggered quality check
			if (this.checkSelection) { 
				
				var selection = CKEditor.instances[this.getSelectedElement().options.elementID + '_content'].getSelection();
				
				if (UWA.is(selection)) {
					this.cursorPosition = selection.createBookmarks(true);
				}
				else {
					this.cursorPosition = undefined;
				}
				
			} else {
				this.cursorPosition = undefined;
			}
		},
		
		restoreCursorPosition: function() {
		/// restores the previously saved cursor position after quality check and possible highlighting
			
			if(UWA.is(this.cursorPosition) && this.cursorPosition.length > 0) {
				var editor = CKEditor.instances[this.getSelectedElement().options.elementID + '_content'];
				var bookmark = editor.document.getById(this.cursorPosition[0].startNode);
				if (bookmark !== null) {
					editor.getSelection().selectElement(bookmark);
					jQuery('.rich-object-content span#' + this.cursorPosition[0].startNode).remove();
				}
			}
		},
		
		searchReplace: function(parentNode, regex, highlightClass) {
		/// used to search recursively for text elements in RichEditorContent for highlighting of metric errors
			
			var excludeElements = ['script', 'canvas', 'iframe', 'style', 'img', 'a'];
			
			var child = parentNode.firstChild;
			
			if(!UWA.is(child)) return;
			
			do {
				
				if (child.nodeType === 1) {
					var tagName = child.tagName.toLowerCase();
					if ((excludeElements.indexOf(tagName) > -1) || ((tagName === 'td' || tagName === 'li') && child.textContent.split(' ').length < 4)) continue;
					child.normalize();
					this.searchReplace(child, regex, highlightClass);
				} else if (child.nodeType === 3) {
					
					var bk = 0;
					
					child.data.replace(regex, function(all) {
						var args = [].slice.call(arguments);
						var offset = args[args.length - 2];
						var newTextNode = child.splitText(offset + bk);
						var match = args[0];
						
						bk -= child.data.length + all.length;
		                newTextNode.data = newTextNode.data.substr(all.length);
						
						var span = document.createElement('span');
						span.className = highlightClass;
						span.textContent = match;
						
						child.parentNode.insertBefore(span, newTextNode);
						
						child = newTextNode;
					});
					regex.lastIndex = 0;
				}
				
			} while (child = child.nextSibling);
			
		},
		
		highLightErrors: function(item) {
		/// highlights metric errors in richview elements
			
			var selectedNode = PADContext.get().getSelectedNodes();
			var objectID = selectedNode[0].options.elementID;
			objectID = "#" + objectID + "_content";
			var parentNode = jQuery(objectID)[0];
			
			// check if valid selected item exists
			if (!UWA.is(parentNode)) return;
			
			// set highlight color from quality level
			var highlightClass;
			
			switch (item.QualityLevel) {
			case '1':
				highlightClass = this.qualityClassNames.high;
				break;
			case '2':
				highlightClass = this.qualityClassNames.medium;
				break;	
			case '3':
				highlightClass = this.qualityClassNames.low;
				break;
			default:
				highlightClass = this.qualityClassNames.low;
				break;
			}
				
			var wordslist = item.FeaturesAsString.split(/:|;|,/);
	        
			wordslist.forEach(function(element, index1, array1){
            	  
				if(element !== ""){
	        		
	        		// get rid of number of hits, z.B. '(x5)'
	            	var word = element.replace(/\(x[0-9]\)/,'');

	            	// several special cases need special treatment

					var regex;
					//var replacement;

					if (/'[0-9]+'/.test(word)) {/* in case numbers should be marked, we don't bother about word borders 
	            		(non-fitting unit could follow immediately) for some reason, semantic number errors are returned 
	            		in strings like '1' or '2'*/
	            		word = word.replace(/'/g, '');
	            		regex = new RegExp(word, 'g');
	            		//replacement = '<span class="' + highlightClass  + '" + id="findInSpan">' + word + '</span>';
	            		
	            	} else if (word === '(') {// in case found error is parenthesis, escape them
	            		regex = /\(/g;
	            		//replacement = '<span class="' + highlightClass  + '" + id="findInSpan">' + word + '</span>';
	            	} else if (word === ')') {// in case found error is parenthesis, escape them
	            		regex = /\)/g;
	            		//replacement = '<span class="' + highlightClass  + '" + id="findInSpan">' + word + '</span>';
	            	} else if (/[Bb]e /.test(word)){// for case of superfluous infinitives
	            		regex = new RegExp('\\b([Bb]e |[Aa]m |[Ii]s |[Aa]re )' + word.replace(/[Bb]e /, '') + '\\b', 'g');
	            		//replacement = '<span class="' + highlightClass  + '" + id="findInSpan">$1' + word.replace(/[Bb]e /, '') + '</span>';
	            	} else { // default case
	            		regex = new RegExp('\\b' + word + '\\b', 'g');
	            		//replacement = '<span class="' + highlightClass  + '" + id="findInSpan">' + word + '</span>';
	            	}
		            	
					//that.searchReplace(parentNode, regex, replacement);		
					that.searchReplace(parentNode, regex, highlightClass);		
				}
			});	
		}
	});
	
	return SA;
  	
});
