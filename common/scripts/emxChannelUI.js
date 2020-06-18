

var emxChannelUI={
		lateTask:0,
		dueTask:0,

		JSONData:{},
		template: {
			descending:"descending",
			ascending:"ascending",
			channel : function(id){
				return $('<div class="hp-channel" id="'+id+'"></div>');
			},
			channel_head : function(){
				return $('<div class="hp-channel-head"></div>');
			},
			channel_head_title : function(header,href){
				href= href.replace(/\\/g,"/");
				return $('<div class="hp-channel-title"><a href="'+href+'">'+header+'</a></div>');
			},
			channel_head_functions : function(){
				return $('<div class="hp-channel-functions"></div>');
			},
			channel_list : function(){
				return $('<ul></ul>');
			},
			channel_head_list_iteam_filter_button : function(){
				var filterButton =  $('<button class="filter"></button>');
				$(filterButton).click(function(e){

					var eventPos = $(e.target).offset();
					e.stopPropagation();
					var channel = $(e.target).parents("div.hp-channel");
					var channelId = channel.attr('id');
					var filterSelector ='div[id$='+channelId+'].filter-menu';
					var filterElem = $(filterSelector,$(document.body)).show();
					eventPos.left=eventPos.left - filterElem.width() +5;

					filterElem.offset(eventPos);
				});
				return $('<li class="button"></li>').append(filterButton);

			},
			channel_head_list_iteam_tasks : function(tasks){
				return $('<li>'+tasks+' '+getTopWindow().emxUIConstants.ChannelUI_TASKS+'&nbsp;|</li>');
			},
			channel_head_list_iteam_lateTasks : function(tasks){
				return $('<li>'+tasks +' '+getTopWindow().emxUIConstants.ChannelUI_LATE+'&nbsp;|</li>');
			},
			channel_head_list_item_seeAll : function(href){
				return $('<li class="see-all"><a href="'+href+'">'+getTopWindow().emxUIConstants.ChannelUI_SEEALL+' ></a></li>');
			},
			channel_body: function(){
				return $('<div class="hp-channel-body scroll-pane"></div>');
			},
			channel_body_bumber : function(){
				return $('<div class="hp-channel-bumper"></div>');
			},
			channel_body_block : function(){
				return $('<div class="hp-channel-block"></div>');
			},
			channel_body_thumbnail : function(image){
				return $('<div class="hp-channel-block-thumbnail"><span></span><img src="'+image+'"/></div>');
			},
			channel_body_block_listItem: function(metadata){
				return $('<li>'+metadata+'</li>');
			},
			channel_body_badge : function(status){
				return $('<div class="badge '+status+'"></div>');
			},
			channelFilterOptions: function(){
				return $('<div class="filter-data"></div>');
			},
			channel_FilterPopup_filterMenu:function (channelId){
				return $('<div class="filter-menu" id="hpFilterMenu'+channelId+'"></div>');
			},
			channel_FilterPopup_filterHead:function (){
				return $('<div class="filter-menu-head"><div class="menu-title">'+getTopWindow().emxUIConstants.ChannelUI_FILTERS+'</div></div>');
			},
			channel_FilterPopup_filterBody:function (filters,sorts){
				var body =$('<div class="filter-menu-body"></div>');
				body.append(this.channel_FilterPopup_filterBodyContent(filters,sorts));
				return body;
			},
			channel_FilterPopup_filterBodyContent:function(filters,sorts){
				var bodycontent= $('<div class="filter-menu-body-content"></div>');

					var filterContent = this.channel_FilterPopup_filterContent(filters);
					bodycontent.append(filterContent);


					var sortingContent = this.channel_FilterPopup_sortingContent(sorts);
					bodycontent.append(sortingContent);

				return bodycontent;
			},
			channel_FilterPopup_filterContent:function(filters){


				var filterHead = $('<div class="filter-attr-head"><div class="attr-title">'+filters[0].displayName+'</div></div>');
				var filterBody = $('<div class="filter-attr"></div>');

				var filterBodyOprions = this.channel_FilterPopup_filterOptions(filters[0].id);
				filterBody.append(filterHead);
				filterBody.append(filterBodyOprions);
				return filterBody;

			},
			channel_FilterPopup_sortingContent:function(sorts){

				var sortHead = $('<div class="filter-attr-head"><div class="attr-title">'+sorts[0].displayName+'</div></div>');
				var sortBody = $('<div class="filter-attr"></div>');
				var sortBodyOprions = this.channel_FilterPopup_sortOptions(sorts);
				sortBody.append(sortHead);
				sortBody.append(sortBodyOprions);
				return sortBody;
			},
			channel_FilterPopup_filterOptions:function(id){
				var labelArr = eval("this.channel_"+id);

				var filterOptionBody = $('<div class="filter-attr-body"></div>');
				if(labelArr && labelArr.length>0){
					var filerOptionsUL = $('<ul></ul>');
					for(var i=0;i<labelArr.length;i++)
					{
						var anchor = $('<a class="checkbox"></a><label>'+labelArr[i]+'</label>');
						anchor.click(function(){
							$(this).toggleClass("selected");
						});
						var option =    $('<li></li>');
						option.append(anchor);
						filerOptionsUL.append(option);
					}
					eval("this.channel_"+id+"=[];");
					filterOptionBody.append(filerOptionsUL);
				}
				return filterOptionBody;
           },
           channel_FilterPopup_sortOptions:function(sorts){
        	   var sortingOptionBody = $('<div class="filter-attr-body"></div>');
        	   var sortingOptionsUL = $('<ul></ul>');
        	   var direction = sorts[0].direction;
        	   var sortAscending = $('<li><input type="radio" name="sort"><label class="sort ascending">A&nbsp;&#8594;&nbsp;Z</label></li>');
        	   var sortDescending = $('<li><input type="radio" name="sort"><label class="sort descending">Z&nbsp;&#8594;&nbsp;A</label></li>');
        	   if(direction && direction==this.ascending)
        		   $(":radio[name=sort]",sortAscending).attr("checked","checked");
        	   if(direction && direction==this.descending)
        		   $(":radio[name=sort]",sortDescending).attr("checked","checked");
        	   var i = $(".ascending").length;
        	   $(":radio[name=sort]",sortAscending).attr("name","sort"+i);
        	   $(":radio[name=sort]",sortDescending).attr("name","sort"+i);
        	   sortingOptionsUL.append(sortAscending);
        	   sortingOptionsUL.append(sortDescending);
        	   sortingOptionBody.append(sortingOptionsUL);
        		  return sortingOptionBody;
           },
           channel_FilterPopup_filterFooter: function(){
        	   var filterFooter = $('<div class="filter-menu-foot"></div>');
        	   var footerApply = $('<button class="apply">'+getTopWindow().emxUIConstants.ChannelUI_APPLY+'</button>');
        	   var footerReset= $('<button class="reset">'+getTopWindow().emxUIConstants.ChannelUI_RESET+'</button>');
        	   filterFooter.append(footerApply);
        	   filterFooter.append(footerReset);
        	   return filterFooter;
           },

           channel_label1:[],
           channel_label2:[],
           channel_label3:[]
		},
		_init:function(JSONData){
			this.setJSONData(JSONData);

			for(var i=0;i<JSONData.length;i++)
			{
				var channel = JSONData[i].channel;
				if(channel && channel.items.length>0)
				{
					var templateChannel = this.template.channel(i);
					var chnlBody = this.template.channel_body();
					chnlBody.append(this.template.channel_body_bumber());
					chnlBody=this._appendChannelBlocks(channel,chnlBody);
					chnlBody.append(this.template.channel_body_bumber());
					templateChannel.append(chnlBody);
					var header= this._buildChannelHead(channel); //channel.name,channel.link,channel.filters
					chnlBody.before(header);
					$(".hp-container").append(templateChannel);
					if(channel.filters && channel.sorts){

						var filterDiv= this._buildFilterPopup(channel,i);
						$(document.body).append(filterDiv);
						filterDiv.hide();
					}
				}
			}
			this._enableChannelScrollPane($(document));
			//Register Window event to close the filter menu if clicked anywhere else
			$(window).click(function(e){
				var filter = $(e.target).closest('div.filter-menu');
				if(filter.size()==0){
					$('div.filter-menu:visible').hide();
					}
			});

		},
		_buildChannelBlock:function(items,target){
				var bodyBlock = this.template.channel_body_block();
				var thumbNail = this.template.channel_body_thumbnail(items.image);
				this._registerBlockThumbnailOnClick(thumbNail,items.link,target);
				var iconStatus =items.iconStatus;
				if(iconStatus)
				{
					bodyBlock.append(this.template.channel_body_badge(items.iconStatus));
				}
				bodyBlock.append(thumbNail);
				bodyBlock.append(this._buildMetaData(items));
				return bodyBlock;
		},
		_buildChannelHead: function(channel) {
			var head = this.template.channel_head();
			head.append(this.template.channel_head_title(channel.name, channel.link));
			head.append(this._buildChannelFilter(channel));
			return head;
		},
		_buildChannelFilter:function(channel){
			var functions = this.template.channel_head_functions();
			var filterList = this.template.channel_list();
			var filterButton =this.template.channel_head_list_iteam_filter_button();
			if(channel.filters.length==0){
				$('.filter',filterButton).attr('disabled','true');
			}
			if(typeof channel.items[0].dueDate!="undefined"){
			filterList.append(this.template.channel_head_list_iteam_tasks(channel.items.length));
			filterList.append(this.template.channel_head_list_iteam_lateTasks(this.get_lateTask()));
			}
			filterList.append(this.template.channel_head_list_item_seeAll(channel.link));
			filterList.append(filterButton);
			functions.append(filterList);
			return functions;
		},
		_buildChannelBody:function(){
			var body = this.template.channel_body();
			body.append(this.template.channel_body_bumber());
			return body;
		},
		_buildMetaData:function(items){
			var metadata = this.template.channel_list();
			var label1 = items.label1;
			var label2 = items.label2;
			var label3 = items.label3;
			if(items.label1)
			{
				metadata.append(this.template.channel_body_block_listItem(items.label1));
				var bContains=$.inArray(items.label1,this.template.channel_label1);
				if(bContains==-1){
					this.template.channel_label1.push(items.label1);
				}
			}
			if(items.label2)
			{
				metadata.append(this.template.channel_body_block_listItem(items.label2));
				var bContains= $.inArray(items.label2,this.template.channel_label2);
				if(bContains==-1){
					this.template.channel_label2.push(items.label2);
				}
			}
			if(items.label3){
				metadata.append(this.template.channel_body_block_listItem(items.label3));
				var bContains= $.inArray(items.label3,this.template.channel_label3);
				if(bContains==-1){
				this.template.channel_label3.push(items.label3);
				}
			}
			return metadata;
		},
		_buildFilterPopup:function (channel,channelId){

			var filterPopupMenu = this.template.channel_FilterPopup_filterMenu(channelId);
			filterPopupMenu.append(this.template.channel_FilterPopup_filterHead());
			filterPopupMenu.append(this.template.channel_FilterPopup_filterBody(channel.filters,channel.sorts));
			filterPopupMenu.append(this.template.channel_FilterPopup_filterFooter());
			$(".apply",filterPopupMenu).click(this._applyFilter);
			$(".reset",filterPopupMenu).click(this._resetFilter);

			return filterPopupMenu;
		},
		_resetFilter:function(e){
			var filterDiv = $(this).closest('div.filter-menu');
			$('.selected',filterDiv).toggleClass("selected");
			emxChannelUI._applyFilter(e);
		},
		_applyFilter:function(e){
			var filterDiv = $(e.target).closest('div.filter-menu');
			var channelid=filterDiv.attr('id');
			channelid=channelid.split("hpFilterMenu")[1];
			var channelElem = $('div.hp-channel[id='+channelid+']');

			var selectedCheckBoxes = $('.selected',filterDiv);
			var filterSelects=[];
			for(var i=0;i<selectedCheckBoxes.length;i++)
			{
				var text = $(selectedCheckBoxes[i]).next("label").text();
				filterSelects.push(text);
			}
			var selectedSort = $(':checked',filterDiv).next("label").attr("class").split(" ")[1];
			filterDiv.css("display","none");
			var json = emxChannelUI.getJSONData();
			var channelObj = json[channelid];
			var filterid = channelObj.channel.filters[0].id;
			var channelBody = $(".hp-channel-body",channelElem);
			channelBody.remove();
			var head = $(".hp-channel-head",channelElem);
			channelBody= emxChannelUI.template.channel_body();
			head.after(channelBody);
			if(channelObj.channel.sorts[0].direction==selectedSort)
			{
				channelBody.append(emxChannelUI.template.channel_body_bumber());
				for(var i=0;i<channelObj.channel.items.length;i++)
				{
					var label = eval('channelObj.channel.items[i].'+filterid);
					if(($.inArray(label,filterSelects))!=-1 || filterSelects.length==0)
					{
						channelBody.append(emxChannelUI._buildChannelBlock(channelObj.channel.items[i],channelObj.channel.target));
					}
				}
				channelBody.append(emxChannelUI.template.channel_body_bumber());
			}
			else
			{
				channelBody.append(emxChannelUI.template.channel_body_bumber());
				var itemLength = channelObj.channel.items.length;
				for(var i=itemLength-1;i>=0;i--)
				{
					var label = eval('channelObj.channel.items[i].'+filterid);

					if(($.inArray(label,filterSelects))!=-1 || filterSelects.length==0)
					{
						channelBody.append(emxChannelUI._buildChannelBlock(channelObj.channel.items[i],channelObj.channel.target));
					}
				}
				channelBody.append(emxChannelUI.template.channel_body_bumber());
			}
			emxChannelUI._enableChannelScrollPane(channelElem);
		},
		_registerBlockThumbnailOnClick:function(thumbnail,link,target){

			thumbnail.click(function(){
				if(target == "content")
				{

					var contentFrame = getTopWindow().$("iframe#content");
                    if (contentFrame) {
                    	contentFrame.attr({"src":link});
                    }
				}
				else
				{
					getTopWindow().showModalDialog(link);
				}
			});
		},
		_enableChannelScrollPane:function(parentElem){
			this._enableJScrollPane(parentElem);
			$(window).bind(
					'resize',
					function(){
                    emxChannelUI._enableJScrollPane(parentElem,true);
					}
			  );

		},
		_enableJScrollPane:function(parentElem,eventBind){
			var elems = $('.scroll-pane',parentElem);
	        for(var i =0;i<elems.length;i++)
	        {
	        	$(elems[i]).jScrollPane();
	            var api = $(elems[i]).data('jsp');
	            var throttleTimeout;
	            if(eventBind){
	            	if (isIE) {
		            	// IE fires multiple resize events while you are dragging the browser window which
	                    // causes it to crash if you try to update the scrollpane on every one. So we need
	                    // to throttle it to fire a maximum of once every 50 milliseconds...
	                    if (!throttleTimeout) {
	                    	throttleTimeout = setTimeout(
	                    			function(){
	                    				api.reinitialise();
	                                    throttleTimeout = null;
	                                 },
	                                 50
	                                 );
	                               }
	                            } else {
	                                api.reinitialise();
	                            }
	            }

	        }
		},

		set_dueTask: function(duetask){
			this.duetask=duetask;
		},
		get_dueTask: function(){
			return this.duetask;
		},
		set_lateTask: function(latetask){
			this.latetask=latetask;
		},
		get_lateTask:function(){
			return this.latetask;
		},
		_appendChannelBlocks:function(channel,chnlBody){
			var dueTask=0;
			var lateTask=0;

			for(var j=0;j<channel.items.length;j++)
			{
				if(channel.items[j].iconStatus=="error")
				{
					lateTask++;
				}
				chnlBody.append(this._buildChannelBlock(channel.items[j],channel.target));

			}
			this.set_lateTask(lateTask);
			this.set_dueTask(dueTask);
			return chnlBody;
		},
		setJSONData:function(JSONData){
			this.JSONData=JSONData;
		},
		getJSONData:function(){
			return this.JSONData;
		}
};


function processChannelData(data) {
	emxChannelUI._init(data);
}

function getBaseURL(){
	var path = window.location.pathname.split( '/' )[1];
    return window.location.protocol+"//"+ window.location.host+"/"+path;

}


