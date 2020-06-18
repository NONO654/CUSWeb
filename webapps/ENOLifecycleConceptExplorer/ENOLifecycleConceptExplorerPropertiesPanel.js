define('DS/ENOLifecycleConceptExplorer/ENOLifecycleConceptExplorerPropertiesPanel',
	[
		'UWA/Core', 
		'UWA/Controls/Abstract',
		'UWA/Element',
		'DS/UIKIT/Input/Text'
	],
	function(UWA, Abstract, Element, Text)
	{
		var PropertiesPanel=Abstract.extend({
			html:'',
			propertiesPanelDiv:null,
			currentPerson:null,
			nodeData:{},
			readOnly:false,
			funcReframeAll:null,
			init:function(options)
			{
				/*
				options={
					propertiesPanelDiv: The panel in which to add the properties info
					readOnly: if properties are Read Only
					iconPath: path for icons,
					funcReframeAll: function to reset the map
				}
				*/
				this._parent(options);
				this.readOnly=options.readOnly;
				this.funcReframeAll=options.funcReframeAll;
				this.html=
				[
					'<div class="properties-image-div">',
	    				'<img src=""/>',
		    			'<div class="properties-close-button">',
		    				'<span class="fonticon fonticon-2x fonticon-cancel"></span>',
		    			'</div>',
	    			'</div>',
	    			'<div class="properties-title-div">',
		    			'<div class="properties-title">',
                            '<div></div>',
		    			'</div>',
	    			'</div>',
	    			
	    			'<div class="properties-menu-div">',
	    				
	    				'<div class="menu-tab properties">',
	    					widget.localize ? widget.localize.properties : "Properties",
	    				'</div>',
	    				
	    				'<div class="menu-tab comments">',
	    					widget.localize ? widget.localize.comments : "Comments",
	    				'</div>',

	    				'<div class="menu-tab spacer">',
	    				'</div>',
	    			
	    			'</div>',
    				
    				'<div class="properties-content-div">',

    					'<div class="content properties">',
    						
    						'<div class="description-title">',
    							'<b>', 
    								(widget.localize ? widget.localize["description"] : "Description"),
		                		'</b>',
    						'</div>',

							'<div class="description-text">',
							'</div>',

							'<textarea></textarea>',

    						'<div class="created-by">',
    						'</div>',

    					'</div>',

    					'<div class="content comments">',
    						
    						'<div class="comments-div">',
    						'</div>',
    						
    						'<div class="comments-input-div">',

    							'<div class="comments-input-person-image-div">',
    								'<img src=""/>',
    							'</div>',

    							'<div class="input-text">',
    								'<textarea>',
    								'</textarea>',
    							'</div>',

    							'<div class="buttons-div">',

    								'<button class="cancel">',
    									widget.localize ? widget.localize.cancel : "Cancel",
    								'</button>',

    								'<button class="ok">',
    									widget.localize ? widget.localize.OK : "OK",
    								'</button>',

    							'</div>',

    						'</div>',

    					'</div>',	

    				'</div>'

    			].join('\n');

    			if (options && options.propertiesPanelDiv)
    			{
    				this.setupPropertiesPanel(options.propertiesPanelDiv)
    			}
			},
			//Inject the properties panel in the UWA elem 
			setupPropertiesPanel:function(propertiesPanelDiv)
			{
				var that=this;
				this.propertiesPanelDiv=propertiesPanelDiv;
				this.propertiesPanelDiv.setHTML(this.html);
				new Text().inject(this.propertiesPanelDiv.getElement(".properties-title-div"));

				//Clicking the Properties tab
				this.propertiesPanelDiv.getElement('.menu-tab.properties').addEvents({
					click:function(evt){
						UWA.extendElement(evt.target).addClassName('selected');
						that.propertiesPanelDiv.getElement('.content.properties').show();
						that.propertiesPanelDiv.getElement('.content.comments').hide();
						that.propertiesPanelDiv.getElement('.menu-tab.comments').removeClassName('selected');
						that.propertiesPanelDiv.getElement('.menu-tab.comments').setStyle('border-left','none');
					}
				});

				this.propertiesPanelDiv.getElement('.menu-tab.comments').addEvents({
					click:function(evt){
						var commDiv=UWA.extendElement(evt.target);
						commDiv.addClassName('selected');
						commDiv.setStyle('border-left','1px ridge #c8c8c8');
						that.propertiesPanelDiv.getElement('.content.comments').show();
						that.propertiesPanelDiv.getElement('.content.properties').hide();
						that.propertiesPanelDiv.getElement('.menu-tab.properties').removeClassName('selected');
						that.propertiesPanelDiv.getElement('.comments-input-div > .input-text > textarea').focus();
						evt.stopPropagation();

					}
				});

				var buttons_div = that.propertiesPanelDiv.getElement('.comments-input-div > .buttons-div');
				//Setup Comment button Menus
    			this.propertiesPanelDiv.getElement('button.ok').addEvents({
    				click:function(evt){

    					var comment_text= that.propertiesPanelDiv.getElement('.input-text textarea').value;
						that.nodeData.saveComment(comment_text);
						that.propertiesPanelDiv.getElement('.input-text textarea').value="";
						UWA.Event.dispatchEvent(that.propertiesPanelDiv.getElement('.input-text textarea'), "keyup", { keyCode: 13 });
    				}

    			});

    			this.propertiesPanelDiv.getElement('button.cancel').addEvents({
    				click:function(evt){
    				    that.propertiesPanelDiv.getElement('.input-text textarea').value = "";
    				    UWA.Event.dispatchEvent(that.propertiesPanelDiv.getElement('.input-text textarea'), "keyup", { keyCode: 13 });
    				}
    			});

    			buttons_div.hide();
    			//enable the OK button if there is text
    			this.propertiesPanelDiv.getElement('.input-text textarea').addEvents({
    				keyup:function(evt)
    				{    				    
    				    (this.value.length ? buttons_div.show() : buttons_div.hide());
    				}
    			});

    			this.propertiesPanelDiv.getElement('.properties-close-button').addEvents({
    				click:function(evt){
    					that.hidePanel();
    				}
    			});

    			//title change is committed
    			this.propertiesPanelDiv.getElement('.properties-title-div input[type="text"]').addEvents({
	    				
	    				keydown:function(evt){
	    					//if escape is pressed
	    					if(evt.keyCode==27)
	    					{
	    						this.hide();
	    						this.value=that.propertiesPanelDiv.getElement('.properties-title div').getText();
	    						that.propertiesPanelDiv.getElement('.properties-title').show();
	    						return false;
	    					}
	    					//if enter is pressed
	    					else if(evt.keyCode==13)
	    					{
	    						that.propertiesPanelDiv.getElement('.properties-title div').setHTML(this.value);
	    						this.hide();
	    						that.nodeData.setNewTitle(this.value);
	    						that.propertiesPanelDiv.getElement('.properties-title').show();
	    						return false;
	    					} 
	    				},
	    				
	    				//when the title box loses focus
	    				blur:function(evt){
	    					//Change the properties name when the current title and text box title do not match
	    					if(this.value!==that.propertiesPanelDiv.getElement('.properties-title div').getHTML())
	    					{
	    						that.propertiesPanelDiv.getElement('.properties-title div').setHTML(this.value);
	    						that.nodeData.setNewTitle(this.value);
	    					}
	    					that.propertiesPanelDiv.getElement('.properties-title').show();
	    					this.hide();
	    					return false;
	    				}
    				});

    			//The changed description is committed 
    			this.propertiesPanelDiv.getElement('.content.properties textarea').addEvents({
    				
    				keydown:function(evt){
    						//if escape is pressed
	    					if(evt.keyCode==27)
	    					{
	    						this.hide();
	    						this.value=that.propertiesPanelDiv.getElement('.content.properties .description-text').getText();
	    						that.propertiesPanelDiv.getElement('.content.properties .description-text').show();
	    						return false;
	    					}
	    				},
	    				//when the title box loses focus
	    			blur:function(evt){
	    					//Change the properties name when the current description and text box description do not match
	    					if(this.value!==that.propertiesPanelDiv.getElement('.content.properties .description-text').getHTML())
	    					{
	    						that.propertiesPanelDiv.getElement('.content.properties .description-text').setHTML(this.value);
	    						that.nodeData.setNewDescription(this.value);
	    					}
	    					that.propertiesPanelDiv.getElement('.content.properties .description-text').show();
	    					this.hide();
	    					return false;
	    				}
    			});

			    that.resizeCommentsSection=function(evt) {
			        var currentHeight=that.propertiesPanelDiv.clientHeight;
			        var heightFixed = that.propertiesPanelDiv.getElement(".properties-image-div").clientHeight
                            + that.propertiesPanelDiv.getElement(".properties-title-div").clientHeight
                            + that.propertiesPanelDiv.getElement(".properties-menu-div").clientHeight
                            + that.propertiesPanelDiv.getElement(".comments-input-div").clientHeight;
			        if (heightFixed < currentHeight) {
			            that.propertiesPanelDiv.getElement(".comments-div").setStyle("max-height", (currentHeight - heightFixed -80) + 'px');
			        }
                    
			    }

    			window.addEventListener('resize', that.resizeCommentsSection);
			},

			setPropertiesAndComments:function(nodeData)
			{
				var that=this;
				this.nodeData=nodeData;
				this.propertiesPanelDiv.getElement('.content.properties .description-text').removeClassName('textbox-hover');
				this.propertiesPanelDiv.getElement('.properties-title').removeClassName('textbox-hover');

				//Add all the comments to the vomments div
				var commentsDiv=this.propertiesPanelDiv.getElement('.comments-div');
				commentsDiv.setHTML('');
				
				//add the bottom border if there is a comment else not
				nodeData.comments.length ? commentsDiv.addClassName("comments-div-bottom-border") : commentsDiv.removeClassName("comments-div-bottom-border");
				
				this.propertiesPanelDiv.getElement('.properties-image-div img').setAttributes({
					src:nodeData.imageurl
				});

				this.propertiesPanelDiv.getElement('.properties-title div').setHTML(nodeData.name);
				this.propertiesPanelDiv.getElement('.properties-title-div input[type="text"]').value=nodeData.name;

				
				nodeData.comments.forEach(function(comment,index){
					
					that.addComment(comment, !(index==0));
					
				});

				//Scroll to the new comment
				commentsDiv.scrollTop=commentsDiv.scrollHeight;
				
				this.propertiesPanelDiv.getElement('.comments-input-person-image-div img').setAttributes({
			    	src:that.currentPerson.image,
			    	onError:function(){
			    		this.onerror=null;
			    		this.src=that.options.iconPath + 'SWXDefaultPersonImage.png';
			    	}
			    });

				//properties
				if (nodeData.type=='nonleaf')
				{
				    var strDescription ='';
	            
		            if (nodeData.desc.length>0){
		                strDescription+=nodeData.desc;
		            }
		            
		            this.propertiesPanelDiv.getElement(".content.properties .description-text").setHTML(strDescription);
		            this.propertiesPanelDiv.getElement(".content.properties textarea").setHTML(strDescription);

		            strDescription ='';
		            if  (nodeData.modifiedby && nodeData.modifiedby.length 
		            	&& nodeData.modifieddate && nodeData.modifieddate.length)
		            {                   
			           	//Calculate the correct time zone 
						var date_here=new Date();
				        var tzOffset=date_here.getTimezoneOffset();
				        var dat=new Date(nodeData.modifieddate*1000-tzOffset*60*1000);
			            
			            strDescription+='<br><b>Modified</b> on ' + dat.toLocaleDateString() + ", " + dat.toLocaleTimeString()
			            + '<br>' +
			            'by ' + nodeData.modifiedby;
		        	}
		        	
		        	if  (nodeData.createdby && nodeData.createddate)
		        	{
			        		//Calculate the correct time zone 
						var date_here=new Date();
				        var tzOffset=date_here.getTimezoneOffset();
				        var dat=new Date(nodeData.createddate*1000-tzOffset*60*1000);
			            
			            strDescription+='<br><br><b>' + 
			            (widget.localize ? widget.localize.created :"Created")
			            + '</b> ' 
			            + ' ' + dat.toLocaleDateString() + ", " + dat.toLocaleTimeString()
			            + '<br>' +
			            (widget.localize ? widget.localize.by : "by") +
			             ' ' + nodeData.createdby;
		        	}

		            this.propertiesPanelDiv.getElement('.content.properties .created-by').setHTML(strDescription);
		            this.propertiesPanelDiv.getElement('.menu-tab.properties').show();

		            //Adding code to edit title and description of non leaf node

		            if (!this.readOnly) {

		                this.propertiesPanelDiv.getElement('.properties-title').addEvents({

		                    mouseover: function (evt) {
		                        UWA.extendElement(this).addClassName('textbox-hover');
		                    },

		                    mouseout: function (evt) {
		                        UWA.extendElement(this).removeClassName('textbox-hover');
		                    },

		                    click: function (evt) {

		                        if (UWA.extendElement(this).hasClassName('textbox-hover')) {
		                            that.propertiesPanelDiv.getElement('.properties-title-div input[type="text"]').show();
		                            that.propertiesPanelDiv.getElement('.properties-title-div input[type="text"]').focus();
		                            that.propertiesPanelDiv.getElement('.properties-title-div input[type="text"]').select();
		                            UWA.extendElement(this).hide();
		                            UWA.extendElement(this).removeClassName('textbox-hover');
		                        }
		                    }
		                });

		                //code to highlight descrption div to indicate the user to click and change it
		                this.propertiesPanelDiv.getElement('.content.properties .description-text').addEvents({

		                    mouseover: function (evt) {
		                       UWA.extendElement(evt.target).addClassName('textbox-hover');
		                    },

		                    mouseout: function (evt) {
		                        UWA.extendElement(this).removeClassName('textbox-hover');
		                    },

		                    click: function (evt) {
		                        
		                        if (UWA.extendElement(this).hasClassName('textbox-hover')) {
		                        	var descriptionTextArea=that.propertiesPanelDiv.getElement('.content.properties textarea');
		                            descriptionTextArea.show();
		                            descriptionTextArea.focus();
		                            descriptionTextArea.select();
		                            descriptionTextArea.setStyle("height",descriptionTextArea.scrollHeight + 5 + 'px');
		                            UWA.extendElement(this).hide();
		                            UWA.extendElement(this).removeClassName('textbox-hover');
		                        }
		                    }
		                });

		                this.propertiesPanelDiv.getElement('.comments-input-div').show();
		            }
		            else {
		                this.propertiesPanelDiv.getElement('.comments-input-div').hide();
		            }
	        	}
	        	else
	        	{
	        		this.propertiesPanelDiv.getElement('.properties-title').removeEvents();
	        		this.propertiesPanelDiv.getElement('.content.properties .description-text').removeEvents();
	        		this.propertiesPanelDiv.getElement('.menu-tab.properties').hide();
	        		this.selectComments();

	        	}

	        	if(that.propertiesPanelDiv.getElement('.menu-tab.properties').getStyle('display')!=='none')
				{
					that.propertiesPanelDiv.getElement('.menu-tab.comments').setStyle('border-left','1px ridge #c8c8c8');
					that.propertiesPanelDiv.getElement('.menu-tab.spacer').removeClassName('long');
				}
				else
				{
					that.propertiesPanelDiv.getElement('.menu-tab.spacer').addClassName('long');
					that.propertiesPanelDiv.getElement('.menu-tab.comments').setStyle('border-left','none');
				}
				
	        	that.propertiesPanelDiv.getElement('.comments-input-div > .input-text > textarea').focus();

	        	that.resizeCommentsSection();
			},

			selectProperties:function()
			{
				// Trigger click event on properties tab
				UWA.Event.dispatchEvent(this.propertiesPanelDiv.getElement('.menu-tab.properties'), 'click');
			},

			selectComments:function()
			{
				// Trigger click event on properties tab
				UWA.Event.dispatchEvent(this.propertiesPanelDiv.getElement('.menu-tab.comments'), 'click');
			},

			show:function(contentWhich)
			{
				this.propertiesPanelDiv.setStyle("display","inline-block");
				var offsetwidth=this.propertiesPanelDiv.offsetWidth;
				var mapContainer=this.propertiesPanelDiv.getParent().getElement(".viewport");
				if(mapContainer)
				{
					mapContainer.setStyle('width',"calc(100% - " + offsetwidth + "px)");
					UWA.Event.dispatchEvent(mapContainer,'resize');
					this.funcReframeAll();
				}

				//this.propertiesPanelDiv.removeClassName("properties-panel-close");
				contentWhich && contentWhich=='comments'? this.selectComments() : this.selectProperties();
			},

			hidePanel:function()
			{
				this.propertiesPanelDiv.hide();
				var mapContainer=this.propertiesPanelDiv.getParent().getElement(".viewport");
				if(mapContainer)
				{
					mapContainer.setStyle('width',"100%");
					UWA.Event.dispatchEvent(mapContainer,'resize');
					this.funcReframeAll();
				}
				//this.propertiesPanelDiv.addClassName("properties-panel-close");
			},

			isVisible:function()
			{
				return this.propertiesPanelDiv.getStyle('display')!=='none';
				/*return (!this.propertiesPanelDiv.hasClassName('properties-panel-close')
					&& this.propertiesPanelDiv.getStyle('display')=='block');*/
			},
			addComment:function(comment, addCommentSeparator)
			{
				var that=this;
				var commentsDiv=this.propertiesPanelDiv.getElement('.comments-div');

				//Add a separator for all except the last one
				if(addCommentSeparator)
				{
					UWA.createElement('div',{
						'class':'comments-separator'
					}).inject(commentsDiv);
				}
				
				//Add the div to contain person information
				var commentPerson=UWA.createElement('div',{
						'class':'comment-person-div'
					}).inject(commentsDiv);

				//Add the image of the person
				UWA.createElement('div',{
					'class': 'comment-person-image-div',
					html:'<img src="'+ comment.person.image+
					'"onError="this.onerror=null;this.src=\''+ that.options.iconPath + 'SWXDefaultPersonImage.png\';">'
				}).inject(commentPerson);
				
				//Calculate the correct time zone 
				var date_here=new Date();
		        var tzOffset=date_here.getTimezoneOffset();
		        var dat=new Date(comment.when*1000-tzOffset*60*1000);
		        var editedOn=null;
		        if(Number(comment.editeddate))
		        	editedOn=new Date(comment.editeddate*1000-tzOffset*60*1000)

		        //Set the person name and time stamp
				UWA.createElement('div',{
					'class': 'comment-person-name-div',
					html: comment.person.name + '<br>' + 
					(widget.localize ? widget.localize.created : "Created") + " " +
					dat.toLocaleDateString() + ', ' + dat.toLocaleTimeString() +
					(editedOn ? '<br>' + 
						(widget.localize ? widget.localize.modified : "Modified") + " " +
						editedOn.toLocaleDateString() + ', ' + editedOn.toLocaleTimeString():"")

				}).inject(commentPerson);

				//Set the comment text
				var commentDiv=UWA.createElement('div',{
					html:comment.text,
					'class':'comment-text' + ' id' + comment.id
				}).inject(commentsDiv);

				commentDiv.comment=comment;

				if(!this.readOnly && comment.person.login===this.currentPerson.login)
				{

					//Set the comment text
					var commentTextArea=UWA.createElement('textarea',{
						html:comment.text,
						'class':'id' + comment.id
					}).inject(commentsDiv)

					commentTextArea.value=comment.text;
					commentTextArea.comment=comment;

					commentDiv.addEvents({
						mouseover:function(evt){
							UWA.extendElement(this).addClassName('textbox-hover');
		    			},
		    				
	    				mouseout:function(evt){
	    					UWA.extendElement(this).removeClassName('textbox-hover');
	    				},

	    				click:function(evt){
	    					if (UWA.extendElement(this).hasClassName('textbox-hover'))
	    					{
	    						var commentTxtArea=commentsDiv.getElement('textarea.id' + this.comment.id);
	    						commentTxtArea.show();
	    						commentTxtArea.focus();
	    						commentTxtArea.select();
	    						commentTxtArea.setStyle('height', commentTxtArea.scrollHeight + 5 + 'px');
	    						UWA.extendElement(this).hide();
	    						UWA.extendElement(this).removeClassName('textbox-hover');
	    					}
	    				}
					});

					commentTextArea.addEvents({

						keydown:function(evt){

	    						//if escape is pressed
		    					if(evt.keyCode==27)
		    					{
		    						this.hide();
		    						this.value=this.comment.text;
		    						commentsDiv.getElement('.comment-text' + '.id' + this.comment.id).show();
		    						return false;
		    					}
	    					},
	    				//when the title box loses focus
	    				blur:function(evt){
		    					//Change the properties name when the current description and text box description do not match
		    					if(this.value!==this.comment.text)
		    					{
		    						commentsDiv.getElement('.comment-text' + '.id' + this.comment.id).setHTML(this.value);
		    						this.comment.editComment(this.value);
		    					}
		    					commentsDiv.getElement('.comment-text' + '.id' + this.comment.id).show();
		    					this.hide();
		    					return false;
		    				}
					});
				}

			}
		});
		
		return PropertiesPanel;
	}
);
