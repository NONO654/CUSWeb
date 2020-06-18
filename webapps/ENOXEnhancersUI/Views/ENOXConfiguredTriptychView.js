define("DS/ENOXEnhancersUI/Views/ENOXConfiguredTriptychView", [
    'UWA/Core',
    'UWA/Promise',
    'DS/CoreEvents/ModelEvents',
    'DS/ENOXTriptych/js/ENOXTriptych',
    'DS/ENOXEnhancersUI/Views/ENOXSetView',
    'DS/ENOXEnhancers/Utils/Helper',
    'DS/ENOXEnhancers/Constants/Constants',
    'DS/ENOXEnhancersUI/Utils/Helper',
    'DS/ENOXEnhancersUI/Constants/Constants',
    'i18n!DS/ENOXEnhancers/assets/nls/ENOXEnhancers',
    'i18n!DS/ENOXEnhancersUI/assets/nls/ENOXEnhancersUI',
    'css!DS/ENOXTriptych/css/ENOXTriptych.css',
    'css!DS/ENOXEnhancersUI/css/ENOXEnhancersUI.css'
  ],
  function(
    UWA,
    UWAPromise,
    ModelEvents,
    ENOXTriptych,
    ENOXSetView,
    XEnhancersHelper,
    Constants,
    Helper,
    UIConstants,
    XEnhancersNLS,
    XEnhancersUINLS
  )
  {
    'use strict';
    var configuredTriptych = function() {};

    /*Adjusts the width of left panel as per content
     */
    function adjustLeftPanel(enoxTriptych)
    {
      enoxTriptych._leftPanel.style.width = enoxTriptych._currentLeft + "px";
      enoxTriptych._rightPanel.style.width = (widget.body.clientWidth - enoxTriptych._currentLeft) +
        "px";
    }

    /**@ render access: private
    /@return ENOXTriptych init options
    **/
    function render(triptychView)
    {
      //init variable
      var triptychContainer = triptychView.triptychContainer;
      var jsonConfig = triptychView.jsonConfig;
      var options = triptychView.options;
      var leftView = new UWA.Element('div',
      {
        class: 'triptych-container triptych-left open borderLeft leftView'
      }).inject(triptychContainer);
      var rightView = new UWA.Element('div',
      {
        class: 'triptych-container triptych-rightPanel rightView'
      }).inject(triptychContainer);
      var mainView = new UWA.Element('div',
      {
        class: 'triptych-container triptych-modal triptych-modal-main mainView'
      }).inject(triptychContainer);
      var modelEvents = new ModelEvents();
      triptychView.modelEvents = modelEvents;
      var rightVisiblity = jsonConfig.right[0].config[0].originalState !=
        undefined ? jsonConfig.right[0].config[0].originalState : Constants.EMPTY_STRING;
      var leftVisiblity = jsonConfig.left[0].config[0].originalState !=
        undefined ? jsonConfig.left[0].config[0].originalState : Constants.EMPTY_STRING;
      var mainVisiblity = jsonConfig.main[0].config[0].originalState !=
        undefined ? jsonConfig.main[0].config[0].originalState : Constants.EMPTY_STRING;

      var openOrder = jsonConfig.order ? jsonConfig.order.split(',') : Constants.EMPTY_JSON_ARRAY;
      if (openOrder.indexOf('left') < 0)
      {
        openOrder.push('left');
      }
      if (openOrder.indexOf('right') < 0)
      {
        openOrder.push('right');
      }
      if (openOrder.indexOf('main') < 0)
      {
        openOrder.push('main');
      }

      openOrder.forEach(function(item)
      {
        if (jsonConfig[item][0].config[0].originalState === 'open')
        {
          jsonConfig[item][0].side = item;
          triptychView.renderFromJson(jsonConfig[item][0]);
        }
        else if (item === 'main')
        {
          mainView.addClassName('hideMainView');
        }
      });

      //creating options for ENOXTriptych
      var triptychOptions = {
        left: jsonConfig['left'][0]['config'][0],
        right: jsonConfig['right'][0]['config'][0],
        container: triptychContainer,
        withtransition: jsonConfig['triptych'][0]["withtransition"],
        modelEvents: modelEvents,
        withoverflowhidden: jsonConfig['triptych'][0]["withoverflowhidden"],
        borderLeft: jsonConfig['triptych'][0]["borderLeft"],
        borderRight: jsonConfig['triptych'][0]["borderRight"],
        originalRight: jsonConfig['triptych'][0]["originalRight"]
      };

      //preparing input for ENOXTriptych for return parameter
      var triptychContent = {
        'leftView': leftView,
        'rightView': rightView,
        'mainView': mainView,
        'options': triptychOptions
      };
      return triptychContent;
    }

    configuredTriptych.prototype.onResize = function ()
    {
      try {
        var that = this;
        adjustLeftPanel(that.enoxTriptych);
      } catch (error) {
        console.log('Error while resizing.: ' + error);
      }
    }

    configuredTriptych.prototype.init = function(options)
    {
      this.options = options || Constants.EMPTY_JSON_OBJECT;
    }
    configuredTriptych.prototype.buildview = function()
    {
      var that = this;
      var triptychContainer = new UWA.Element('div',
      {
        class: 'extended-triptych-view',
        styles:
        {
          height: 'inherit'
        }
      });
      that.options.renderTo ? triptychContainer.inject(that.options.renderTo) :
        Constants.EMPTY_STRING;

      require(['text!' + that.options.configurations], function(configurations)
      {
        var jsonConfig = Constants.EMPTY_JSON_OBJECT;
        if (typeof configurations === 'string')
        {
          jsonConfig = JSON.parse(configurations);
        }
        var options = that.options || Constants.EMPTY_JSON_OBJECT;
        that.triptychContainer = triptychContainer;
        that.jsonConfig = jsonConfig;

        //TODO move parameters to configuredTriptych object
        var triptychContent = render(that);
        var enoxTriptych = new ENOXTriptych();
        //For storing ENOXTriptych reference. used to get triptych _rightpanel and _leftpanel and others.
        that.enoxTriptych = enoxTriptych;
        enoxTriptych.init(triptychContent.options, triptychContent.leftView,
          triptychContent.mainView, triptychContent.rightView);
        if (triptychContent.mainView.hasClassName('hideMainView'))
        {
          that.mainview = triptychContent.mainView;
          that.onResize();
        }
      });
    };

    /**Loads from json.
    /@ jsonConfiguration : {collection:{url:"collection doc url",
    /                                   options:"all the options"},
    /                       view:{ url:""},
    /                       panel:"left/right"}
    **/
    configuredTriptych.prototype.renderFromJson = function(jsonConfiguration)
    {
      var triptychView = this,
        panel = jsonConfiguration.side;
      var panelContainer = "";
      if (panel === 'left')
      {
        panelContainer = widget.getElements('.leftView')[0];
      }
      else if (panel === 'right')
      {
        panelContainer = widget.getElements('.rightView')[0];
      }
      else if (panel === 'main')
      {
        panelContainer = widget.getElements('.mainView')[0];
      }
      if (!panelContainer || !panel)
      {
        console.log('PanelContainer not available');
      }
      Helper.loadingON('Loading...', panelContainer);

      var pageCollection = !jsonConfiguration.pagecollection || XEnhancersHelper.isArrayEmpty(
          jsonConfiguration.pagecollection.url) ? Constants.EMPTY_STRING :
        jsonConfiguration.pagecollection.url;
      var collection = !jsonConfiguration.collection || XEnhancersHelper.isArrayEmpty(
          jsonConfiguration.collection.url) ? Constants.EMPTY_STRING :
        jsonConfiguration.collection.url;
      var view = !jsonConfiguration.view || XEnhancersHelper.isArrayEmpty(jsonConfiguration.view
        .url) ? Constants.EMPTY_STRING : jsonConfiguration.view.url;
      var pageCollectionOptions = !jsonConfiguration.pagecollection ||
        XEnhancersHelper.isArrayEmpty(jsonConfiguration.pagecollection.options) ?
        Constants.EMPTY_JSON_OBJECT : jsonConfiguration.pagecollection.options;
      var collectionOptions = !jsonConfiguration.collection || XEnhancersHelper.isArrayEmpty(
          jsonConfiguration.collection.options) ? Constants.EMPTY_JSON_OBJECT :
        jsonConfiguration.collection.options;
      var viewOptions = !jsonConfiguration.view || XEnhancersHelper.isArrayEmpty(
          jsonConfiguration.view.options) ? Constants.EMPTY_JSON_OBJECT :
        jsonConfiguration.view.options;

      var promiseArray = [];
      if (!XEnhancersHelper.isStringEmpty(view))
      {
        var promiseView = new UWAPromise(function(resolve, reject)
        {
          require([view], function(panelView)
          {
            var result = {};
            result.view = panelView;
            resolve(result);
          });
        });
        promiseArray.push(promiseView);
      }
      else
      {
        console.log('view is not provided to load ' + panel + ' panel');
      }

      if (!XEnhancersHelper.isStringEmpty(collection))
      {
        var promiseCollection = new UWAPromise(function(resolve, reject)
        {
          require([collection], function(panelCollection)
          {
            var result = {};
            result.collection = panelCollection;
            resolve(result);
          });
        });
        promiseArray.push(promiseCollection);
      }
      else
      {
        console.log('collection is not provided to load ' + panel + ' panel');
      }

      if (!XEnhancersHelper.isStringEmpty(pageCollection))
      {
        var promisePageCollection = new UWAPromise(function(resolve, reject)
        {
          require([collection], function(panelPageCollection)
          {
            var result = {};
            result.pageCollection = panelPageCollection;
            resolve(result);
          });
        });
        promiseArray.push(promisePageCollection);
      }

      Promise.all(promiseArray).then(function(result)
      {
        if (result && result.length > 0 && result[0].view && result[1].collection)
        {
          var collectionClass = result[2] ? result[2].pageCollection.createCollection() :
            result[1].collection.createCollection();
          var options = result[2] ? UWA.merge(pageCollectionOptions, triptychView.options) :
            UWA.merge(collectionOptions, triptychView.options);
          //For Closing the main panel. Currently below code is called repeatedly.
          if (triptychView.jsonConfig.main[0].config[0].originalState ===
            "close")
          {
            triptychView.renderContent(
            {
              'side': 'middle',
              'content': null
            });
            if (!triptychView.mainview.hasClassName('hideMainView')) {
              triptychView.mainview.addClassName('hideMainView');
            }
            triptychView.onResize();
          }
          //For controlling the render. Multiple click issue fixed.
          if (triptychView.request === undefined)
          {
            triptychView.request = 0
          }
          else
          {
            triptychView.request += 1;
          }
          options.request = triptychView.request;
          var collection = new collectionClass([], options);
          var view = result[0].view;
          collection.fetch(
          {
            onComplete: function(data)
            {
              var options = data.options || Constants.EMPTY_JSON_OBJECT;
              if (options.request === undefined || options.request == triptychView.request)
              {
                options.renderTo = panelContainer;
                options.triptychView = triptychView;
                options.options ? delete options.options : Constants.EMPTY_STRING;
                options.collectionOptions = collectionOptions;
                options.collection = result[1].collection;
                options.pageEnabled = result[2] ? true : false;
                if (options.pageEnabled)
                {
                  options.pageCollectionOptions = pageCollectionOptions;
                  options.pageCollection = result[2].pageCollection;
                }
                var panelView;
                options = UWA.merge(viewOptions, options);
                options.events = options.contents && options.contents.events ?
                  options.contents.events :
                  {};
                if ((view.parent && view.parent === UWA.Class.View) || (
                    view.parent && view.parent.parent && view.parent.parent === UWA.Class
                    .View))
                {
                  options.data = data;
                  panelView = new view(options);
                  panelView.render();
                }
                else
                {
                  panelView = new view();
                  panelView.init(options);
                  panelView.render(data);
                }
                if (panel === "left")
                {
                  adjustLeftPanel(triptychView.enoxTriptych);
                }
                Helper.loadingOFF(panelContainer);
                Helper.loadingOFF();
                return panelView;
              }
              else
              {
                console.log('Multiple request is made. Please refresh.' +
                  triptychView.request);
              }

            },
            onFailure: function(err)
            {
              throw new Error(XEnhancersHelper.getMessage(
              {
                key: err.error
              }));
            }
          });
        }
      }, function(error)
      {
        throw new Error(XEnhancersHelper.getMessage(
        {
          key: err.error
        }));
      });
    }

    /*Loads div node data to the specified panel
    /@ sideAndContent: {side, content}
    */
    configuredTriptych.prototype.renderContent = function(sideAndContent)
    {
      this.modelEvents.publish(
      {
        event: 'triptych-set-content',
        data: sideAndContent
      });
    };
    /**For resizing left or right panel.
    /@eventinput: {side, size}
    **/
    configuredTriptych.prototype.resize = function(eventinput)
    {
      this.modelEvents.publish(
      {
        event: 'triptych-set-size',
        data: eventinput
      });
      var mainview = this.mainview || widget.getElements('.mainView')[0];
      if (mainview && mainview.hasClassName('hideMainView'))
      {
        if (eventinput.side == 'left')
        {
          var currentWidgetSize = widget.body.clientWidth;
          var rightSize = currentWidgetSize - this.enoxTriptych._options.left.originalSize;
          this.enoxTriptych._rightPanel.style.width = rightSize + 'px';
        }
      }
    }
    //TODO private
    configuredTriptych.prototype.showMainView = function()
    {
      var mainViewDiv = this.mainview;
      if (mainViewDiv.hasClassName('hideMainView'))
      {
        mainViewDiv.removeClassName('hideMainView');
      }
      if (XEnhancersHelper.isObjectEmpty(this.enoxTriptych._rightResizer))
      {
        this.enoxTriptych._rightResizer.classList.remove('displaynone');
        this.enoxTriptych._rightResizer.hidden = false;
      }
      if (XEnhancersHelper.isObjectEmpty(this.enoxTriptych._leftResizer))
      {
        this.enoxTriptych._leftResizer.classList.remove('displaynone');
        this.enoxTriptych._leftResizer.hidden = false;
      }
    }
    return configuredTriptych;
  }
);
