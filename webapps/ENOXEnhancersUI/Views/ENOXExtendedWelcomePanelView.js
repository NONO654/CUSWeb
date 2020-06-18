define('DS/ENOXEnhancersUI/Views/ENOXExtendedWelcomePanelView', [
    'UWA/Core',
    'UWA/Class/View',
    'DS/ENOXWelcomePanel/js/ENOXWelcomePanel',
    'DS/Core/ModelEvents',
    'DS/ENOXEnhancers/Constants/Constants',
    'DS/ENOXStandardActionbar/js/ENOXStandardActionbar',
    'DS/ENOXEnhancers/Utils/Helper',
    'DS/ENOXEnhancers/Services/SettingsManagement',
    'DS/ENOXEnhancersUI/Constants/Constants',
    'i18n!DS/ENOXEnhancersUI/assets/nls/ENOXEnhancersUI',
    'css!DS/ENOXEnhancersUI/css/ENOXEnhancersUI'
  ],
  function(Core,
    UWAView,
    ENOXWelcomePanel,
    ModelEvents,
    Constants,
    ENOXStandardActionbar,
    Helper,
    SettingsManagement,
    UIConstants,
    XEnhancersUINLS
  )
  {
    'use strict'
    var ExtendedWelcomePanel = ENOXWelcomePanel.extend(
    {
      name: 'ExtendedWelcomePanel',

      defaultOptions:
      {
        selected: '',
        showHomePage: true,
        showAplhaOrdering: true,
        showNumbeOrdering: true,
        showCollapse: true
      },

      adjustToolTip: function(position)
      {
        var activities = this.activities;

        for (var i = 0; i < activities.length; i++)
        {
          var actions = activities[i].actions;
          for (var j = 0; j < actions.length; j++)
          {
            actions[j].tooltipElt.options.position = position;
          }
        }
      },

      getEvents: function _getEvents(welcomePanelView)
      {
        var options = welcomePanelView.options,
          userEvents = options.events || Constants.EMPTY_JSON_OBJECT;
        var myModelEvents = Helper.isArrayEmpty(userEvents) ? new ModelEvents(JSON.parse(
            userEvents)) :
          new ModelEvents();
        myModelEvents.subscribe(
        {
          event: 'welcome-panel-toggle'
        }, function()
        {
          showPanelWithIconAndText();
        });
        myModelEvents.subscribe(
        {
          event: 'welcome-panel-action-selected'
        }, function(data)
        {
          //For Tag Update. this helpe in knowing current tagger
          var tagObj = SettingsManagement.getSetting(data.id + UIConstants.TAG_OBJ);
          var currentActiveTag = SettingsManagement.getSetting(Constants.CURRENT_TAG);
          if (currentActiveTag)
          {
            currentActiveTag.deactivateTaggerProxy();
          }
          SettingsManagement.addSetting(Constants.CURRENT_TAG, tagObj);
          //Tag ends
          if (window.event)
          {
            var elementClicked = event.currentTarget;
            var alreadySelected = elementClicked
              .hasClassName('currentselection');
            if (!alreadySelected)
            {
              var prevSelElement = widget.getElement('.currentselection');
              prevSelElement ? prevSelElement.removeClassName('currentselection').removeClassName(
                'selected') : '';
              elementClicked.addClassName('currentselection');
            }
          }
          else
          {
            widget.getElement("#" + data.id + ".action-new.activity-btn").addClassName(
              'selected currentselection');
          }

          var activities = options.activities,
            displayOptions, side;
          for (var i = 0; i < activities.length; i++)
          {
            if (activities[i].actions[0].id == data.id)
            {
              side = activities[i].actions[0].options.side || 'right';
              displayOptions = activities[i].actions[0].options ||
                Constants.EMPTY_JSON_OBJECT;
              break;
            }
          }
          var sideAndContent = {
            side: side,
            model: displayOptions.model || Constants.EMPTY_JSON_OBJECT,
            collection: displayOptions.collection || Constants.EMPTY_JSON_OBJECT,
            pagecollection: displayOptions.pagecollection || Constants.EMPTY_JSON_OBJECT,
            view: displayOptions.view || Constants.EMPTY_JSON_OBJECT
          };
          options.triptychView.renderFromJson(sideAndContent);
        });

        myModelEvents.subscribe(
        {
          event: 'action-expand'
        }, function()
        {
          var activities = options._models[0]._attributes.WelcomePanelActivities.activities,
            element = this.event.currentTarget;

          if (element.hasClassName('fonticon-expand-right'))
          {
            element.removeClassName('fonticon-expand-right');
            element.addClassName('fonticon-expand-down');
            that.getExpandActionData(activities, element.parentElement.parentElement,
              that);
          }
          else if (element.hasClassName('fonticon-expand-down'))
          {
            element.removeClassName('fonticon-expand-down');
            element.addClassName('fonticon-expand-right');
            that.collapseActivity(element.parentElement.parentElement);
          }
        });

        return myModelEvents;
      },

      getActionToolBarOptions: function _getActionToolBarOptions(welcomePanelView)
      {
        var actions = [],
          options = welcomePanelView.options,
          triptychView = welcomePanelView.options.triptychView;
        if (options.showHomePage)
        {
          actions.push(
          {
            id: 'WelcomePanelHome',
            text: XEnhancersUINLS['Home'],
            fonticon: 'home-alt',
            disable: true
          });
        }
        if (options.showAplhaOrdering)
        {
          actions.push(
          {
            id: 'WelcomePanelSortAlpha',
            text: XEnhancersUINLS['AlphaOrder'],
            fonticon: 'sort-alpha-asc',
            disable: true
          });
        }
        if (options.showNumbeOrdering)
        {
          actions.push(
          {
            id: 'WelcomePanelSortNum',
            text: XEnhancersUINLS['NumOrder'],
            fonticon: 'sort-num-asc',
            disable: true
          });
        }
        if (options.showCollapse)
        {
          actions.push(
          {
            id: 'WelcomePanelToggleButton',
            text: XEnhancersUINLS['Collapse'],
            fonticon: 'fonticon fonticon-chevron-left',
            handler: function()
            {
              var isLeftPanelMin = widget.getElement('#' + this.id).children[0].hasClassName(
                'fonticon-chevron-right');
              var leftPanelSize = Constants.EMPTY_STRING;
              if (isLeftPanelMin)
              {
                //TODO find earlier width
                leftPanelSize = triptychView.jsonConfig.left[0].config[0].originalSize;
              }
              else
              {
                leftPanelSize = triptychView.jsonConfig.left[0].config[0].minWidth;
              }
              var eventinput = {
                side: 'left',
                size: leftPanelSize
              };
              triptychView.resize(eventinput);
              welcomePanelView.toggleCollapseButton(this);
            }
          });
        }

        return {
          actions: actions
        };
      },

      showPanelWithIconAndContent: function _showPanelWithIconAndContent()
      {
        var icons = widget.getElements('.' + UIConstants.ACTION_NEW);
        for (var i = 0; i < icons.length; i++)
        {
          icons[i].removeClassName('triptych-left-panel-only-icons');
          icons[i].getChildren()[0].removeClassName(UIConstants.FONTICON_2X_CLASS);
          icons[i].getChildren()[1].show();
        }
      },


      showPanelWithOnlyIcon: function _showPanelWithOnlyIcon()
      {
        var icons = widget.getElements('.' + UIConstants.ACTION_NEW);
        for (var i = 0; i < icons.length; i++)
        {
          icons[i].addClassName('triptych-left-panel-only-icons');
          icons[i].getChildren()[0].addClassName(UIConstants.FONTICON_2X_CLASS);
          icons[i].getChildren()[1].hide();
        }
      },

      removeSeparator: function _removeSeparator()
      {
        var separator = this.container.getElements('.separator');
        separator.forEach(function(item)
        {
          item.remove();
        });
      },

      setup: function _setup(options)
      {
        this.options = UWA.merge(options, this.defaultOptions);
        this.options.actionToolbarOptions = this.getActionToolBarOptions(this);
        this.options.modelEvents = this.getEvents(this);

        var extWPContainer = UWA.createElement('div',
        {
          class: 'extended-welcome-panel-view-container',
          styles:
          {
            width: '100%',
            height: '100%'
          }
        });

        this.parentContainer = extWPContainer;
        this.activities = options.data._models[0]._attributes.WelcomePanelActivities.activities;
        options.activities = options.data._models[0]._attributes.WelcomePanelActivities.activities;
        this.modelEvents = this.options.modelEvents;
        this.options.actionToolbarOptions.parentContainer = extWPContainer;
        var actionbar = new ENOXStandardActionbar(this.options.actionToolbarOptions);
        actionbar.actionBar.setStyle('min-width', ' auto');
        this.collapsed = false;
        this._parent(options);
      },

      render: function _render(data)
      {
        this.adjustToolTip('top left');
        this._parent();
        this.removeSeparator();
        var triptychView = this.options.triptychView;
        var sideAndContent = {
          side: 'left',
          content: this.parentContainer
        };
        triptychView.renderContent(sideAndContent);
        var defaultWelcome = widget.getValue('welcome');
        //TODO remove one lable works
        defaultWelcome = defaultWelcome.replace(' ', '');
        if (defaultWelcome)
        {
          var dataAction = {
            id: defaultWelcome
          };

          this.options.modelEvents.publish(
          {
            event: 'welcome-panel-action-selected',
            data: dataAction
          });
        }
      },

      toggleCollapseButton: function _toggleCollapseButton(el, isCollapsed)
      {
        var buttonElement = widget.getElement('#' + el.id).children[0];
        if (buttonElement.hasClassName('fonticon-chevron-right') && !isCollapsed)
        {
          buttonElement.removeClassName('fonticon-chevron-right');
          buttonElement.addClassName('fonticon-chevron-left');
          this.showPanelWithIconAndContent();
        }
        else if (buttonElement.hasClassName('fonticon-chevron-left'))
        {
          widget.getElements('.ExtendedWelcomePanel-container')[0].removeClassName(
            'expanded');
          buttonElement.removeClassName('fonticon-chevron-left');
          buttonElement.addClassName('fonticon-chevron-right');
          this.showPanelWithOnlyIcon();
        }
      }

    });

    return ExtendedWelcomePanel;
  });
