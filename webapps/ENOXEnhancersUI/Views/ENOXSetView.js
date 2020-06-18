define('DS/ENOXEnhancersUI/Views/ENOXSetView', [
    'UWA/Core',
    'UWA/Promise',
    'DS/UIKIT/Iconbar',
    'DS/UIKIT/Input/Text',
    'DS/UIKIT/DropdownMenu',
    'DS/UIKIT/IconDropdown',
    'DS/UIKIT/Tooltip',
    'DS/CoreEvents/ModelEvents',
    'DS/ENOXEnhancers/Utils/ENOXInContextSearch',
    'DS/ENOXEnhancers/Constants/Constants',
    'DS/ENOXEnhancers/Utils/Helper',
    'DS/ENOXEnhancers/Services/SettingsManagement',
    'DS/ENOXEnhancersUI/Utils/Helper',
    'DS/ENOXEnhancersUI/Constants/Constants',
    'DS/ENOXEnhancers/Utils/ENOXTagContent',
    'DS/ENOXEnhancers/Utils/ENOXContentSearch',
    'i18n!DS/ENOXEnhancersUI/assets/nls/ENOXEnhancersUI',
    'css!DS/ENOXEnhancersUI/css/ENOXEnhancersUI.css'
  ],
  function (
    UWACore,
    UWAPromise,
    Iconbar,
    UIKitText,
    DropdownMenu,
    IconDropdown,
    Tooltip,
    ModelEvents,
    InContextSearch,
    Constants,
    Helper,
    SettingsManagement,
    UIHelper,
    XEnhancersConstants,
    TagContent,
    ContentSearch,
    XEnhancersUINLS
  ) {
    'use strict';

    function tagUpdate(objList, enoxSetView) {
      var idList = JSON.stringify(UIHelper.getObjectId(objList));
      idList = idList.substring(1, idList.length - 1);
      var tagger = enoxSetView.tagger;
      tagger.renderTags(idList, enoxSetView);
    }

    function addSearchAndTagEvents(that) {
      that.modelEvents.subscribe({
        event: 'onFilterChange'
      }, function (filteredIds) {
        that.options.sendRequest = true;
        var coll = UIHelper.prepareCollection(filteredIds);
        that.render(coll);
      });

      self.widget.removeEvent('onSearch');
      self.widget.removeEvent('onResetSearch');
      self.widget.addEvent('onResetSearch', that.clearSearch.bind(that));
      self.widget.addEvent('onSearch', that.onSearch.bind(that));
    }

    /*Handles the onclick event of sort view
     */
    function sortOnClickEvent(item, tooltip, enoxSetView) {
      var sortQuery = {
          "sortAttribute": "",
          "sortOrder": ""
        },
        tooltipText = item.text,
        spanElem = widget.getElement('.sort-content');
      tooltip.setBody(tooltipText);
      if (item.elements.icon.className.contains("alpha-asc")) { //This is applied
        item.elements.icon.className = "fonticon fonticon-sort-alpha-desc"; //This can be applied
        spanElem.className = "fonticon fonticon-sort-alpha-asc"; //As this is applied will be seen on top
        sortQuery.sortOrder = "asc"; // applied is sent to server for filtering
      } else if (item.elements.icon.className.contains("alpha-desc")) {
        item.elements.icon.className = "fonticon fonticon-sort-alpha-asc";
        spanElem.className = "fonticon fonticon-sort-alpha-desc";
        sortQuery.sortOrder = "desc";
      } else if (item.elements.icon.className.contains("num-desc")) {
        item.elements.icon.className = "fonticon fonticon-sort-num-asc";
        spanElem.className = "fonticon fonticon-sort-num-desc";
        sortQuery.sortOrder = "desc";
      } else if (item.elements.icon.className.contains("num-asc")) {
        item.elements.icon.className = "fonticon fonticon-sort-num-desc";
        spanElem.className = "fonticon fonticon-sort-num-asc";
        sortQuery.sortOrder = "asc";
      }

      spanElem.className += ' sort-content';
      sortQuery.sortAttribute = item.name.toLowerCase();

      var collectionClass = enoxSetView.options.pageEnabled ? enoxSetView.options.pageCollection
        .createCollection() : enoxSetView.options.collection.createCollection();
      var collOptions = enoxSetView.options.pageEnabled ? enoxSetView.options.pageCollectionOptions :
        enoxSetView.options.collectionOptions;
      collOptions = collOptions || {};
      collOptions.sort = sortQuery;
      var collection = new collectionClass([], collOptions);
      collection.fetch({
        onComplete: function (data) {
          enoxSetView.render(data);
        },
        onFailure: function (error) {
          console.log('error while sorting');
        }
      });
    }

    /**Adds the sorting function.
     **/
    function addSortComponent(enoxSetView, actionsContainer) {
      var sortOptions = enoxSetView.options.topbar.sortOptions.sort;

      //Prepare Items for Sort DropDownMenu
      var items = [],
        fonticonImage = Constants.EMPTY_STRING,
        tooltipText = Constants.EMPTY_STRING,
        getAllNLS = [];
      var span = UWACore.createElement('span', {
        class: 'fonticon fonticon-sort-num-asc sort-content'
      }).inject(actionsContainer);
      sortOptions.forEach(function (item) {
        getAllNLS[item.nls] = "i18n!" + item.nls;
      });
      var i18nPromise = new UWAPromise(function (resolve, reject) {
        Helper.getRequireFromJson(getAllNLS, resolve);
      }).then(function (result) {
        sortOptions.forEach(function (item) {
          if (item.type == "string") {
            fonticonImage = "sort-alpha-asc";
          } else {
            fonticonImage = "sort-num-asc"
          }
          var eachOption = {
            text: result[item.nls][item.text],
            name: item.name,
            fonticon: fonticonImage,
            selectable: true
          };
          if (item.text === enoxSetView.options.topbar.sortOptions.currentSort
            .text) {
            eachOption.selected = true;
            //Default sort can be either number or date. String handling is not provided.
            if (enoxSetView.options.topbar.sortOptions.currentSort.order ===
              "ASC") {
              eachOption.fonticon = 'sort-num-desc';
            } else {
              eachOption.fonticon = 'sort-num-asc';
            }
            tooltipText = result[item.nls][item.text];
          }
          items.push(eachOption);
        });
        //For tooltip
        var tooltip = new Tooltip({
          target: span,
          body: tooltipText
        });
        new DropdownMenu({
          target: span,
          items: items,
          events: {
            onClick: function (e, item) {
              console.log(item);
              sortOnClickEvent(item, tooltip, enoxSetView);
            }
          }
        });
      });
    }

    /**Search in widget
     **/
    function _renderSearchInContext(container) {
      try {
        var searchElements = {};
        var renderingcontainer = container;
        var searchContainer = UWACore.createElement('div', {
          "class": "searchInContext_container",
          styles: {
            width: 'fit-content'
          }
        });
        searchContainer.inject(renderingcontainer);
        searchElements.searchInput = UWACore.createElement('div', {
          'class': "searchInContext_holder fonticon fonticon-search",
          styles: {
            width: 'min-width'
          },
          events: {
            click: function () {
              var contentSearch = new InContextSearch();
              contentSearch.showSearchInput(searchElements);
            }
          }
        }).inject(searchContainer);
        searchElements.input = new UIKitText({
          className: "searchInContext_input",
          events: {
            onKeyDown: function (event) {
              if (event.which === 13) { //enter key pressed
                var contentSearch = new InContextSearch();
                contentSearch.launchSearch(searchElements);
              } else if (event.which === 27) { //Escape key pressed
                var contentSearch = new InContextSearch();
                contentSearch.hideSearchInput(searchElements);
              }
            }
          }
        }).inject(searchContainer).hide();
      } catch (e) {
        console.log('Error: Container passed is empty.');
      }
    }

    function _buildSkeleton(enoxSetView) {
      if (enoxSetView.topbar) {
        var topbar = enoxSetView.topbar;
        topbar.inject(enoxSetView.renderTo);
      } else {
        var topbar = new UWACore.createElement('div', {
          class: 'setview-topbar'
        });
        topbar.inject(enoxSetView.renderTo);
        enoxSetView.topbar = topbar;
        _buildTopbar(enoxSetView);
      }


      var content = new UWACore.createElement('div', {
        class: 'setview-content',
        styles: {
          height: (enoxSetView.renderTo.clientHeight - topbar.clientHeight - 50) + 'px'
        }

      });
      content.inject(enoxSetView.renderTo);
      enoxSetView.content = content;

      var footerDiv = new UWACore.createElement('div', {
        class: 'setview-content-footer',
        styles: {
          height: '30px'
        }
      });
      footerDiv.inject(enoxSetView.renderTo);
      _createFooter(footerDiv, enoxSetView);

      _renderContent(enoxSetView);
    }

    function _renderContent(enoxSetView) {
      var that = this,
        options = {
          renderTo: enoxSetView.content,
          options: enoxSetView.options
        };

      var views = enoxSetView.options.contents.views;
      var itemView = enoxSetView.options.currentView ? enoxSetView.options.currentView.id :
        enoxSetView.options.contents.itemView;
      enoxSetView.options.currentView = enoxSetView.options.currentView || views[0];

      options.collectionToolbar = enoxSetView.collectionToolbar; //For maintaing the collectiontoolbar. This is used for sorting in given view.
      views.forEach(function (item) {
        if (item.id == itemView) {
          enoxSetView.options.currentView = options.currentView = item;
          options.content = [];
          options.modelEvents = enoxSetView.modelEvents;
          var dataIndex = enoxSetView.page.currentPage - 1;
          if (enoxSetView.page.data[dataIndex].sendrequest) {
            var loadData = enoxSetView.page.data[dataIndex].data;
            for (var i = 0; i < loadData.length; i++) {
              options.content.push(loadData[i].id || loadData[i]);
            }
            var coll = coll = options.options.collection;
            var collOptions = {
              info: true,
              content: options.content
            };
            if (enoxSetView.data.options && enoxSetView.data.options.sort) {
              collOptions.sort = enoxSetView.data.options.sort;
            }
            var onComplete = function (data) {
              enoxSetView.page.data[dataIndex].sendrequest = false;
              enoxSetView.page.data[dataIndex].data = data;
              _loadView(item, options, enoxSetView, dataIndex);
            };
            var onFailure = function (error) {
              console.log('Failed to load data' + error);
            };

            if (UWA.is(coll, 'string')) {
              require([coll], function (collection) {
                var collectionClass = collection.createCollection();
                var collectionObject = new collectionClass([], collOptions);
                collectionObject.fetch({
                  onComplete: function (data) {
                    onComplete(data);
                  },
                  onFailure: function (error) {
                    onFailure(error);
                  }
                });
              });
            } else {
              var collectionClass = coll.createCollection();
              var collectionObject = new collectionClass([], collOptions);
              collectionObject.fetch({
                onComplete: function (data) {
                  onComplete(data);
                },
                onFailure: function (error) {
                  onFailure(error);
                }
              });
            }
          } else {
            _loadView(item, options, enoxSetView, dataIndex);
          }
        }
      });
    }

    function _loadView(viewItem, options, enoxSetView, index) {
      require([viewItem.view], function (view) {
        var viewObj = new view();
        options = UWA.merge(options, {
          renderData: enoxSetView.options.triptychView,
          idCard: enoxSetView.options.contents.idCard
        });
        viewObj.init(options);
        var pageData = {
          data: enoxSetView.page.data[index].data
        };
        options.renderTo.empty();
        enoxSetView.highlightSearchString(pageData);
        viewObj.render(pageData);
      });
    }

    function _buildTopbar(enoxSetView) {
      var topbar = enoxSetView.topbar,
        topbarWidth = topbar.clientWidth;
      topbar.inject(enoxSetView.renderTo);

      var topbarLeft = new UWACore.createElement('div', {
        class: 'setview-topbar setview-topbar-left',
        styles: {
          width: 'fit-content'
        }
      });
      topbarLeft.inject(topbar);

      var topbarMiddle = new UWACore.createElement('div', {
        class: 'setview-topbar setview-topbar-middle'
      });
      topbarMiddle.inject(topbar);

      var topbarRight = new UWACore.createElement('div', {
        class: 'setview-topbar setview-topbar-right',
        styles: {
          width: 'fit-content'
        }
      });
      topbarRight.inject(topbar);

      var topbarController = new UWACore.createElement('div', {
        class: 'setview-topbar setview-topbar-controller',
        styles: {
          width: '40px'
        }
      });
      topbarController.inject(topbarLeft);

      var topbarHeader = new UWACore.createElement('div', {
        class: 'setview-topbar setview-topbar-header',
        styles: {
          width: 'fit-content'
        }
      });
      topbarHeader.inject(topbarLeft);

      //Not supported currently
      var topbarBreadCrum = new UWACore.createElement('div', {
        class: 'setview-topbar setview-topbar-breadcrum'
      });
      topbarBreadCrum.inject(topbarMiddle);

      var topbarActions = new UWACore.createElement('div', {
        class: 'setview-topbar setview-topbar-actions'
      });
      topbarActions.inject(topbarRight);

      enoxSetView.options.topbar.showController ? ENOXSetView.prototype.createToggle(enoxSetView,
          topbarController) :
        topbarController.setStyles({
          display: 'none'
        });
      _createHeader(enoxSetView, topbarHeader);
      _createTopbarActions(enoxSetView, topbarActions);
    }

    function _createHeader(enoxSetView, topbarHeader) {
      var promiseShowTitle = function () {
        return new UWAPromise(function (resolve, reject) {
          var options = {
            resolve: resolve,
            reject: reject
          };
          _showTitle(enoxSetView, topbarHeader, options);
        });
      };

      promiseShowTitle().then(function (result) {
        _showCount(enoxSetView, topbarHeader);
      }, function (error) {
        throw new Error(Helper.getMessageKey(err.error));
      });
    }

    function onPagerOffsetChange(offset) {
      var that = this;
      UIHelper.loadingON('Loading...', that.content);
      that.page.currentPage = offset / that.page.limit + 1;
      _renderContent(that);
    }

    function loadNext(index, next) {
      next();
    }

    function _createFooter(footerDiv, enoxSetView) {
      if (enoxSetView.page.firstPage !== enoxSetView.page.lastPage) {
        var pager = new UWA.Controls.Pager({
          limit: enoxSetView.page.limit,
          offset: 0,
          max: enoxSetView.data.length,
          type: 1,
          showPageLinks: true,
          prevLabel: XEnhancersUINLS['Previous'],
          nextLabel: XEnhancersUINLS['Next'],
          length: enoxSetView.data.length,
          loadNext: loadNext.bind(enoxSetView),
          events: {
            onOffsetChange: onPagerOffsetChange.bind(enoxSetView)
          }
        });

        pager.inject(footerDiv);
        enoxSetView.pager = pager;
      }
    }

    function _showTitle(enoxSetView, topbarHeader, options) {
      var titleElement = new UWACore.createElement('div', {
        class: 'setview-topbar setview-topbar-title'
      });
      if (!Helper.isArrayEmpty(enoxSetView.options.topbar.title)) {
        var title = enoxSetView.options.topbar.title.id;
        if (!Helper.isStringEmpty(enoxSetView.options.topbar.title.nls)) {
          require(['i18n!' + enoxSetView.options.topbar.title.nls], function (NLS) {
            title = NLS[title];
            var titleElementValue = new UWACore.createElement('h3', {
              html: title
            });
            titleElementValue.inject(titleElement);

            options.resolve(titleElement);
          });
        } else {
          var titleElement = new UWACore.createElement('div', {
            class: 'setview-topbar setview-topbar-title'
          });
          titleElement.inject(topbarHeader);

          var titleElementValue = new UWACore.createElement('h3', {
            html: title
          });
          titleElementValue.inject(titleElement);
        }
      } else {
        titleElement.setStyles({
          display: 'none'
        });
        options.resolve();
      }
      titleElement.inject(topbarHeader);
    }

    function _showCount(enoxSetView, topbarHeader) {
      var count = new UWACore.createElement('div', {
        class: 'setview-topbar setview-topbar-count',
        styles: {
          width: '24px'
        }
      });
      if (!Helper.isArrayEmpty(enoxSetView.options.topbar.showCount)) {
        count.inject(topbarHeader);
        var content = new UWACore.createElement('h3', {
          html: enoxSetView.data.length
        });
        content.inject(count);
      } else {
        count.setStyles({
          display: 'none'
        });
      }
    }

    function _createTopbarActions(enoxSetView, topbarActions) {
      var actionsContainer = new UWACore.createElement('div', {
        class: 'setview-topbar setview-topbar-actions',
        styles: {
          width: 'max-content'
        }
      });
      actionsContainer.inject(topbarActions);
      var actionsCollection = enoxSetView.options.topbar.actionCollections || [];

      if (enoxSetView.options.contents.views) {
        var views = enoxSetView.options.contents.views,
          itemView = enoxSetView.options.contents.itemView,
          switchViews = {
            'fonticon': Constants.EMPTY_STRING,
            'content': {
              'type': 'icondropdown',
              'options': {
                'items': []
              }
            },
            'events': []
          };
        views.forEach(function (item) {
          if (item.id == itemView) {
            switchViews.fonticon = item.fonticon;
          }
          var data = enoxSetView.data;
          item.handler = function (event, action) {
            var options = {};
            options.collectionToolbar = enoxSetView.collectionToolbar;
            enoxSetView.options.currentView = options.currentView = action;
            options.renderTo = enoxSetView.content;
            options.modelEvents = enoxSetView.modelEvents;
            _loadView(action, options, enoxSetView, enoxSetView.page.currentPage - 1);
          };
          switchViews.content.options.items.push(item);
        });
        actionsCollection.unshift(switchViews);
      }

      if (enoxSetView.options.topbar.showMultiSel) {
        actionsCollection.unshift({
          'fonticon': 'select-on',
          'content': {
            'type': 'dropdownmenu',
            'options': {
              'items': [{
                  fonticon: 'select-none',
                  text: 'Unselect all'
                },
                {
                  fonticon: 'select-all',
                  text: 'Select All'
                }
              ]
            }
          }
        });
      }

      var items = {
        'className': 'divider'
      };
      actionsCollection.unshift(items);

      //Search
      if (enoxSetView.options.topbar.enableSearch) {
        _renderSearchInContext(actionsContainer)
      }
      //Search

      new Iconbar({
        renderTo: actionsContainer,
        items: actionsCollection
      });

      //Sorting Starts
      addSortComponent(enoxSetView, actionsContainer);
      //Sorting Ends

    }

    function _contains(data, array) {
      var contains = false;
      array.forEach(function (item) {
        if (item === data) {
          contains = true;
        }
      });

      return contains;
    }

    function _prepareModelEvents(enoxSetView, eventClass) {
      var viewEvents = enoxSetView.options.events,
        data = enoxSetView.data;
      for (var i = 0; i < viewEvents.length; i++) {
        var viewEvent = viewEvents[i];
        for (var jsonObj in viewEvent) {
          var array = viewEvent[jsonObj];
          for (var j = 0; j < array.length; j++) {
            var requiredDefine = array[j]["require"];
            var funcName = array[j]["name"];
            var eventName = array[j]["event"];
            enoxSetView.modelEvents.subscribe({
              'event': eventName,
            }, function (data) {
              var view = new eventClass[requiredDefine]();
              view[funcName](data);
            });
          }
        }
      }
    }

    var ENOXSetView = function () {
      this.name = '_ENOXSetView';
      this.defaultOptions = {
        data: {},
        topbar: {
          showController: false,
          title: Constants.EMPTY_STRING,
          showCount: false,
          // actionsCollection: Constants.EMPTY_JSON_ARRAY
        },
        // lazyRender: true,
        switchViews: Constants.EMPTY_JSON_ARRAY,
        selectionBehavior: {
          unselectAllOnEmptyArea: false,
          toggle: false,
          canMultiSelect: false,
          enableFeedbackForActiveCell: true
        },
        contents: {
          views: {},
          events: Constants.EMPTY_JSON_ARRAY,
          itemView: Constants.EMPTY_STRING
        }
      };
    };

    ENOXSetView.prototype.createToggle = function (triptychView, topbarController) {
      var view = triptychView;
      topbarController.setStyles({
        width: '40px'
      });
      var toggleAction = new Iconbar({
        renderTo: topbarController,
        items: [{
          fonticon: 'expand-collapse-panel',
          text: XEnhancersUINLS['Collapse'],
          className: 'mainView-toggle',
          handler: function (e, i) {
            e.stopPropagation();
            var parentEl = e.target.parentElement;
            if (parentEl.hasClassName('mainView-toggle')) {
              parentEl.removeClassName('mainView-toggle');
            } else {
              parentEl.addClassName('mainView-toggle');
            }
            view._modelEvents.publish({
              event: 'triptych-toggle-panel',
              data: 'right'
            });

          }
        }]
      });
    }

    ENOXSetView.prototype.init = function (options) {
      this.options = UWA.merge(options, this.defaultOptions);
      this.options.tagCall = true; //This is temporary. this will be removed later.
    }

    function _prepareData(enoxSetView) {
      var that = enoxSetView,
        pageSize = widget.getValue('pageSize') || 500;
      if (that.options.pageEnabled && Math.ceil(enoxSetView.data.length / pageSize) - 1 > 0) {
        that.page = {
          firstPage: 1,
          currentPage: 1,
          limit: pageSize || 50,
          lastPage: Math.ceil(enoxSetView.data.length / pageSize),
          length: enoxSetView.data.length,
          data: {}
        };
        var pageCount = 0;
        for (var i = 0; i < enoxSetView.data.length; i++) {
          if (i !== 0 && i % that.page.limit === 0) {
            pageCount++;
          }
          if (that.page.data[pageCount] === undefined) {
            that.page.data[pageCount] = {
              sendrequest: true,
              data: []
            };
          }

          var temp = enoxSetView.data._models ? enoxSetView.data._models[i] : enoxSetView.data[i];
          that.page.data[pageCount].data.push(temp);
        }
      } else if (!that.options.pageEnabled && !that.options.sendRequest) {
        that.page = {
          firstPage: 1,
          currentPage: 1,
          limit: enoxSetView.data.length,
          length: enoxSetView.data.length,
          lastPage: 1,
          data: {}
        };
        that.page.data[0] = {
          sendrequest: false,
          data: enoxSetView.data._models || enoxSetView.data
        };
      } else {
        that.page = {
          firstPage: 1,
          currentPage: 1,
          limit: enoxSetView.data.length,
          length: enoxSetView.data.length,
          lastPage: 1,
          data: {}
        };
        that.page.data[0] = {
          sendrequest: true,
          data: enoxSetView.data._models || enoxSetView.data
        };
      }
    }

    function _prepareSetViewContainer(enoxSetView) {
      var that = enoxSetView;
      var setViewContainer = that.getSetViewContainer();
      if (setViewContainer !== null) {
        UIHelper.loadingON('Loading...', setViewContainer);
        setViewContainer.empty();
      } else {
        setViewContainer = new UWA.Element('div', {
          class: 'setview-main-container'
        });
      }

      that.options.renderTo ? setViewContainer.inject(that.options.renderTo) :
        Constants.EMPTY_STRING;
      that.renderTo = setViewContainer;

      var viewEvents = that.options.events;
      var promiseArray = [],
        requiredEvents = [];
      that.modelEvents = that.options.modelEvents || new ModelEvents();
      if (viewEvents) {
        var loadEvents = {};
        for (var i = 0; i < viewEvents.length; i++) {
          var viewEvent = viewEvents[i];
          for (var jsonObj in viewEvent) {
            var array = viewEvent[jsonObj];
            for (var j = 0; j < array.length; j++) {
              var requiredDefine = array[j]["require"];
              if (!_contains(requiredDefine, requiredEvents)) {
                requiredEvents.push(requiredDefine);
                var promise = new UWAPromise(function (resolve, reject) {
                  require([requiredDefine], function (eventClass) {
                    loadEvents[requiredDefine] = eventClass;
                    resolve(loadEvents);
                  });
                });
                promiseArray.push(promise);
              }
            }
          }
        }

        Promise.all(promiseArray).then(function (result) {
          _prepareModelEvents(that, result[0]);
          _buildSkeleton(that);
        });
      } else {
        _buildSkeleton(that);
      }
    }

    ENOXSetView.prototype.getSetViewContainer = function _getSetViewContainer() {
      return widget.getElement('.setview-main-container');
    }

    function _updateCount(that, data) {
      if (that.options.topbar.showCount) {
        var startContent = (that.page.currentPage - 1) * that.page.limit,
          count = Constants.EMPTY_STRING;
        var itemCountDiv =
          widget.getElement('.setview-topbar.setview-topbar-count');
        var dataLength = that.data._models ? that.data._models.length : that.data.length;
        that.page.firstPage === that.page.lastPage ? count = dataLength :
          count = 1 + startContent + '/' + dataLength;
        itemCountDiv.children[0].setContent(count || '0');
      }
    }

    ENOXSetView.prototype.render = function (data) {
      var that = this;
      that.data = data;
      _prepareData(that);

      _prepareSetViewContainer(that);

      that.modelEvents.subscribe({
        event: 'view-change-count-update'
      }, function (data) {
        _updateCount(that, data);
      });

      that.modelEvents.subscribe({
        event: 'content-remove-count-update'
      }, function (data) {
        var dataRemoved = data.ids;
        dataRemoved.forEach(function (id) {
          var clonedData = UWACore.clone(that.data._models, false);
          for (var m = clonedData.length - 1; m >= 0; m--) {
            if (clonedData[m]._attributes.id === id) {
              that.data._models.splice(m, 1);
              that.data.length = that.data._models.length;
            }
          }
        });
        _prepareData(that);
        _updateCount(that, data);
        if (that.page.firstPage === that.page.lastPage) {
          var itemCountDiv = widget.getElement('.setview-content-footer');
          itemCountDiv.empty();
        }
      });

      if (that.options.tagCall) {
        var savedTagger = SettingsManagement.getSetting(Constants.CURRENT_TAG);
        savedTagger._initTaggerProxy(that);
        savedTagger.activateTaggerProxy();
        that.tagger = savedTagger;
        addSearchAndTagEvents(that);
        tagUpdate(data._models, that);
        that.options.tagCall = false;
      }
    }

    function widgetSearchInputBoxUpdate(query) {
      var searchInputBox = widget.getElement('.searchInContext_input'); //widget search input box element
      var searchInputBoxContent = searchInputBox.value;
      if (!(query === searchInputBoxContent)) {
        searchInputBox.value = query;
      }
    }

    ENOXSetView.prototype.clearSearch = function () {
      widgetSearchInputBoxUpdate(Constants.EMPTY_STRING);
      var that = this;
      var contentBeforeSearchCopy = that.contentBeforeSearchCopy;
      var tagListIds = UIHelper.formIdString(contentBeforeSearchCopy);
      var tagger = that.tagger;
      if (tagListIds.length > 0) {
        UIHelper.loadingON('Loading...', that.content);
        tagger.renderTags(tagListIds, that);
      }

      var currentTag = SettingsManagement.getSetting(Constants.CURRENT_TAG).taggerProxy
        .getCurrentFilter();
      if (Object.keys(currentTag.localfilters).length == 0 && tagListIds.length > 0) {
        that.render(contentBeforeSearchCopy);
      }
      that.currentQuery = Constants.EMPTY_STRING;
    }

    function searchOnComplete(result) {
      var idList = Helper.getIdsFromSearchResult(result);
      var that = this;
      that.render(idList);
      var tagListIds = UIHelper.formIdString(idList);
      var tagger = that.tagger;
      tagger.renderTags(tagListIds, that);
    }

    ENOXSetView.prototype.onSearch = function (query) {
      var that = this;

      if (that.currentQuery == undefined) { //For the first time when search is triggered.
        that.currentQuery = query;
        that.contentBeforeSearchCopy = that.data;
      } else if (that.currentQuery !== Constants.EMPTY_STRING && that.currentQuery !== query) { //When search is not cleared and another query is fired.
        that.data = that.contentBeforeSearchCopy;
        that.currentQuery = query;
      } else if (that.currentQuery === Constants.EMPTY_STRING) { //For the other time when search is triggered
        that.currentQuery = query;
      }

      var idList = JSON.stringify(UIHelper.formIdString(that.data));
      idList = idList.substring(1, idList.length - 1);
      var search = new ContentSearch();
      var options = {};
      options.onComplete = searchOnComplete.bind(this);
      UIHelper.loadingON('Loading...', that.content);
      search.onSearch(query, idList, options);
      widgetSearchInputBoxUpdate(query);
    }

    /*Highlights the searched string from the result rendered.
     * @renderCollection UWA collection with all the models that will be rendered.
     * Public : application can overrite to add their own field that are rendered.
     */
    ENOXSetView.prototype.highlightSearchString = function (renderCollection) {
      var searchInputBox = widget.getElement('.searchInContext_input');
      try {
        if (searchInputBox !== undefined) {
          var searchInputBoxContent = searchInputBox.value.trim();
          searchInputBoxContent = searchInputBoxContent.replace(/[*]/gi, '');
          var highlightField = Object.keys(renderCollection.data._models[0]._attributes);
          if (searchInputBoxContent !== "") {
            var stringToHighlight = [];
            for (var i = 0; i < renderCollection.data._models.length; i++) {
              var allProperties = renderCollection.data._models[i]._attributes.propertiesList;
              for (var j = 0; j < allProperties.length; j++) {
                var index = allProperties[j].indexOf(searchInputBoxContent);
                if (index >= 0) {
                  allProperties[j] = allProperties[j].substring(0, index) +
                    "<span class='highlightedSearchCriteria'>" + allProperties[j].substring(
                      index, index + searchInputBoxContent.length) + "</span>" + allProperties[
                      j].substring(index + searchInputBoxContent.length);
                }
              }
              for (var j = 0; j < highlightField.length; j++) {


                if (renderCollection.data._models[i]._attributes[highlightField[j]] !==
                  undefined && typeof (renderCollection.data._models[i]._attributes[
                    highlightField[j]]) === "string") {
                  var index = renderCollection.data._models[i]._attributes[highlightField[j]].indexOf(
                    searchInputBoxContent);
                  if (index >= 0) {
                    var name = renderCollection.data._models[i]._attributes[highlightField[j]];
                    name = name.substring(0, index) +
                      "<span class='highlightedSearchCriteria'>" + name.substring(index, index +
                        searchInputBoxContent.length) + "</span>" + name.substring(index +
                        searchInputBoxContent.length);
                    renderCollection.data._models[i]._attributes[highlightField[j]] = name;
                  }
                } else {
                  console.log("For this " + highlightField[j] + " value is undefined.");
                }

              }
            }
          }
        }
      } catch (error) {
        console.log("error whiling highlighting result. " + error)
      }

    }

    return ENOXSetView;
  });
