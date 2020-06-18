define('DS/ENOChgActionGridUX/scripts/View/ChgChangeActionHome', ['UWA/Core', 'UWA/Drivers/Alone',
  'DS/UIKIT/Input',
  'DS/UIKIT/Input/Button',
  'UWA/Class/View',
  'DS/UIKIT/Modal',
  'DS/ENOChgActionGridUX/scripts/Wrapper/ChgSplitViewWrapper',
  'DS/ENOChgActionGridUX/scripts/Triptych/ChgTriptychWrapper',
  'DS/CoreEvents/ModelEvents',
  'DS/ENOChgActionGridUX/scripts/View/ChgzApplicationFrame',
  'DS/ENOChgActionGridUX/scripts/View/ChgWelcomePanelWrapper',
  'DS/Controls/Expander',
  'DS/ENOChgActionGridUX/scripts/View/ChgDataGridLayout',
  'DS/ENOChgActionGridUX/scripts/Wrapper/ChgIDCardWrapper',
  'i18n!DS/ENOChgActionGridUX/assets/nls/ENOChgActionDataGridNLS',
  'DS/ENOChgActionGridUX/scripts/Config/ChgCAAppGlobalVariable'
],
  function (UWA, UWAAlone,
    Input,
    Button,
    View,
    Modal,
    ENOXSplitView,
    TriptychWrapper,
    ModelEvents,
    zApplicationFrame,
    WelcomePanelWrapper,
    WUXExpander,
    ChgDataGridLayout,
    IDCardWrapper,
    APP_NLS,
    ChgCAAppGlobalVariable
  ) {
    'use strict';
    var ChgChangeActionHome = {

      /*
       * Method to initialize the home screen
       */
      init: function (contentAppdiv, optionsHome) {


        // to initialize the tripch component and inject inside the target
        var appChannelOptions = {};
        appChannelOptions.name = "appChannelModleEvent";
        this._applicationChannel = new ModelEvents(appChannelOptions);
        // Initialize the WelcomePanel
        this._welcomePanelComponent = new WelcomePanelWrapper();

        // Initialize the Loading frame
        //  this._applicationContainer = contentAppdiv;
        this._applicationContainer = document.createElement('div');
        UWA.extendElement(this._applicationContainer);
        //  this._applicationContainer.classList.add('xmodel-application');
        widget.body.setContent(this._applicationContainer);

        ChgCAAppGlobalVariable.getImmersiveFrame().inject(this._applicationContainer);

        //this._zApplicationFrame.inject(this._applicationContainer);
        this._zApplicationFrame = new zApplicationFrame();
        this._zApplicationFrame._init(this._applicationChannel, /* xPflRouter,*/ this._welcomePanelComponent);
        //this._zApplicationFrame.inject(this._applicationContainer);
        //  widget.setBody(this._zApplicationFrame);
        ChgCAAppGlobalVariable.getImmersiveFrame().setContentInBackgroundLayer(this._zApplicationFrame);

        this._welcomePanelComponent.init(this._applicationChannel, /*xPflRouter,*/ this._zApplicationFrame._triptychWrapper.getLeftPanelContainerTriptych());
        this._applicationChannel.publish({
          event: 'triptych-set-size',
          data: {
            side: 'left',
            size: 200
          }
        });

        // this._ChgDataGridViewDialog = new ChgDataGridViewDialog();
        // Landing page container
        this._container = UWA.createElement('div');
        this._container.classList.add('changeAction-landingpage');
        // div for recent change action
        this._recentCAsContainer = UWA.createElement('div');
        this._recentCAsContainer.classList.add('recent-cas');
        // creating the empty Icon div

        this._emptyDiv = UWA.createElement('div', {
          'id': 'emptyDivCARecent',
          'styles': {
            'color': 'silver',
            'text-align': 'center',
            'justify-content': 'center',
            'padding': '50px'

          }
        });
        this._contentsContainer = UWA.createElement('div', {
          styles: { "height": "100%" }
        }
        );
        UWA.createElement('div', {
          id: "skeleton-container",
          text: APP_NLS.NO_INFORMATION_CA,
          "class": "skeleton-container",
          styles: {
            "height": "100%", "width": "100%", "Display": "flex", "align-items": "center",
            "justify-content": "center"
          }
        }).inject(this._contentsContainer);
        this._emptyDiv.setAttribute("id", "emptyContent");
        this._emptyDiv.setHTML("<span class='fonticon fonticon-wux-ui-3ds wux-ui-3ds-2x wux-ui-3ds-change'></span><br/><font-size='17px>" + APP_NLS.CHG_No_RecentItems + "</font>");
        this._recentCAsContainer.appendChild(this._emptyDiv);
        // Div for data grid indexed chnage action
        var that = this;
        //  this._myMVsContainer = UWA.createElement('div');

        /*this._myMVsContainer = UWA.createElement('div', {
          'id': 'myMVsContainer',
          'styles': {
            'height': '100%'
          }
        });*/
        this._myMVsContainer = this.getSplitView(this._applicationChannel);
        this.setSplitViewEvent(this._myMVsContainer);
        this._myMVsContainer.addRightCloseButton();
        this._myMVsContainer.getRight().appendChild(this._contentsContainer);
        //this._myMVsContainer.classList.add('my-cas');
        // header for both _container
        var headerRecentCAs = APP_NLS.CHG_Recent_CA_Header;
        var headerMyCAs = 'My Change Actions';
        this._expander1 = new WUXExpander({
          style: 'simple',
          header: headerRecentCAs,
          body: this._recentCAsContainer,
          //height: 180,
          expandedFlag: true
        });
        //this._expander1.inject(this._container);
        this._container.appendChild(this._myMVsContainer.getContent());
        /*  this._expander1.getContent().addEventListener('collapse', function() {
            this._myMVsContainer.classList.add('expanded');
          });*/

        /*this._expander1.getContent().addEventListener('expand', function() {
          this._myMVsContainer.classList.remove('expanded');
        });*/
        var midcontain = this._zApplicationFrame._triptychWrapper.getMainPanelContainer();
        midcontain.appendChild(this._container);
        //Create Grid View Layout
        var option = {};
        option.modelEvents = this._applicationChannel;
        option.target = this._myMVsContainer.getLeftViewWrapper(); //split view getLeft doesnot support MASK, remove this when working
        //option.target = this._myMVsContainer.getLeft() ;
        if(enoviaServerCAWidget.indexMode=="true"){
          ChgDataGridLayout.createIndexedView(option);
        }else{
        ChgDataGridLayout.create(option);
        }

        //Add Search in Dashboard
        var channel = this._applicationChannel;
        widget.addEvents({
          onSearch : function(query){
            channel.publish(
              {
                event: 'ca-DataGrid-on-search',
                data: { "query": query },
                context: that
              }
            )
          },
          onResetSearch : function(query){
            channel.publish(
              {
                event: 'ca-DataGrid-on-reset-search',
                data: { "query": query },
                context: that
              }
            )
          }
        });
      },
      getSplitView: function (appChannel) {
        var sView = new ENOXSplitView();
        var split_options = {
          modelEvents: appChannel,
          withtransition: false,
          withoverflowhidden: false,
          params: {
            leftWidth: 20,
            rightWidth: 80,
            leftVisible: true,
            rightVisible: false
          },
          rightMaximizer: true,
          leftMaximizer: false,
          resizable: true
          //mobileOptim: true
        };
        sView.init(split_options);
        return sView;
      },
      setSplitViewEvent: function (splitView) {
        var me = splitView;
        var selectedId = "";
        me._modelEvents.subscribe({ event: 'ca-DataGrid-on-dblclick' }, function (data) {
          // if(me._rightVisible){
          //   me._hideRight();
          // }else{

          //me.getRight().innerText = "#TODO : ID CARD\n\n" + JSON.stringify(data);
          selectedId = data.model.id;
          var option = {};
          option.target = me.getRightViewWrapper();
          option.pid = data.model.id;
          option.data = data.model;
          option._modelEvents = me._modelEvents;
          //me._rightPanel.addClassName("right-container-mobile-view");
          me._rightPanel.classList.add("right-container-mobile-view");
          me._showSide("right");
          IDCardWrapper.CAIDCardWrapper(option);

          // }
        });

        me._modelEvents.subscribe({ event: 'ca-DataGrid-on-click' }, function (data) {
          if(me._rightVisible){
            selectedId = data.model.id;
            var option = {};
            option.target = me.getRightViewWrapper();
            option.pid = data.model.id;
            option.data = data.model;
            option._modelEvents = me._modelEvents;
            IDCardWrapper.CAIDCardWrapper(option);
          }
        });

        me._modelEvents.subscribe({ event: 'ca-DataGrid-on-addChild' }, function (data) {
          if(me._rightVisible){
            selectedId = data.model.id;
            var option = {};
            option.target = me.getRightViewWrapper();
            option.pid = data.model.id;
            option.data = data.model;
            option._modelEvents = me._modelEvents;
            IDCardWrapper.CAIDCardWrapper(option);
          }
        });

        me._modelEvents.subscribe({ event: 'ca-DataGrid-on-unselect' }, function (data) {
          if(me._rightVisible){
             if(data.model.options.grid.id == selectedId){
               selectedId = data.model.getTreeDocument().getSelectedNodes()[0].options.grid.id;
               var option = {};
               option.target = me.getRightViewWrapper();
               option.pid = data.model.getTreeDocument().getSelectedNodes()[0].options.grid.id;
               option.data = data.model.getTreeDocument().getSelectedNodes()[0].options.grid;
               option._modelEvents = me._modelEvents;
               IDCardWrapper.CAIDCardWrapper(option);
             }
          }
        });

        me._modelEvents.subscribe({ event: 'ca-DataGrid-on-unselect-all' }, function (data) {
          if(me._rightVisible){
             me.getRightViewWrapper().empty();
             me.getRightViewWrapper().setHTML("<div class='noInfo'>"+APP_NLS.CHG_NO_INFO_AVAILABLE+"</div>");
          }
        });

        me._modelEvents.subscribe({ event: 'ca-DataGrid-toolbar-eyeToggle' }, function (data) {
          if (me._rightVisible) {
            me._hideSide("right");
          } else {
            me._showSide("right");
          }
        });

        me._modelEvents.subscribe({ event: 'ca-back-to-summary' }, function (data) {
          if (me._rightVisible) {
            me._hideSide("right");
          }
        });
        
      }

    }
    return ChgChangeActionHome;
  });
