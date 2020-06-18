define('DS/ENOXEnhancersUI/Views/ENOXTabsView', [
    'DS/Controls/Button',
    'DS/Controls/Tab',
    'css!DS/ENOXEnhancersUI/css/ENOXEnhancersUI.css'
  ],
  function(Button,
    WUXTab)
  {
    'use strict';

    var ENOXTabsView = function()
    {
      this._name = 'TabsView';
      this.configurations = {};
      this.options = {};
    };


    ENOXTabsView.prototype.init = function(options)
    {
      var that = this;
      that.configurations = options || new Error('No configuration provided');
    }

    function createTab(tabOptions)
    {
      for (var i = 0; i < tabOptions.nbElement; i++)
      {
        var div = new UWA.Element('div');
        var button = new Button(
        {
          label: tabOptions.listofLabels[i],
          icon:
          {
            iconName: tabOptions.listofIcons[i],
            fontIconFamily: 1,
            fontIconSize: '2x'
          },
          displayStyle: 'lite',
          float: 'left',
        });
        button.getContent().style.color = '#368ec4';
        div.style.padding = '20px';
        div.appendChild(button.getContent());
        tabOptions.tab.add(
        {
          label: tabOptions.listofLabels[i],
          isSelected: tabOptions.selectedIndex == i ? true : false,
          content: div,
          icon:
          {
            iconName: tabOptions.listofIcons[i],
            fontIconFamily: 1
          },
          index: i
        });
      }
    }

    ENOXTabsView.prototype.render = function(dataOptions)
    {
      var listofIcons = [];
      var listofLabels = [];
      var listofRequires = [];
      var listofRequireMethods = [];
      var listofEvents = [];

      var jsonConfig = JSON.parse(this.configurations),
        individualtabJSON = {},
        initialSelectedIndex = 0;

      if (jsonConfig.hasOwnProperty("tab"))
      {
        individualtabJSON = jsonConfig.tab;
      }
      if (jsonConfig.hasOwnProperty("selectIndex"))
      {
        initialSelectedIndex = jsonConfig.selectIndex;
      }
      for (var i = 0; i < individualtabJSON.length; i++)
      {
        listofLabels[i] = individualtabJSON[i].textValue || new Error('Test Value Empty');
        listofIcons[i] = individualtabJSON[i].fonticon || new Error('Icon Value Empty');
        listofRequires[i] = individualtabJSON[i].require || new Error('Require Value Empty');
        listofRequireMethods[i] = individualtabJSON[i].methodName || new Error(
          'Method Value Empty');
        listofEvents[i] = individualtabJSON[i].eventName || new Error('Event value Empty');
      }
      var container = new UWA.Element('div',
      {
        'class': 'wux-control-inline-container',
        styles:
        {
          width: '100%',
          height: '100%'
        }
      });

      var tabContainer = new UWA.Element('div',
      {
        'class': 'tab-container'
      });
      tabContainer.inject(container);

      var tabWindow = new WUXTab(
      {
        reorderFlag: false,
        touchMode: true,
        pinFlag: false,
        multiSelFlag: true,
        displayStyle: ['strip']
      });
      tabWindow.getContent().addEventListener('change', function(e)
      {
        var pc = e.target.lastElementChild;
        var tabDataContainer = pc.getChildren()[e.dsModel.value];
        if (tabDataContainer)
        {
          tabDataContainer.setStyle('height', pc.clientHeight);
          tabDataContainer.empty()
        }
        var requireforthisTab = listofRequires[e.dsModel.value];
        var requireMethodForthisTab = listofRequireMethods[e.dsModel.value];
        var eventName = listofEvents[e.dsModel.value];
        if (eventName == 'change')
        {
          require([requireforthisTab],
            function(tabCollectionData)
            {
              dataOptions.renderTo = tabDataContainer;
              var tabCollection = new tabCollectionData();
              tabCollection[requireMethodForthisTab](dataOptions);
            });
        }
        console.log("Selected Tab" + e.dsModel.value)
      });
      var tabOptions = {
        tab: tabWindow,
        listofIcons: listofIcons,
        listofLabels: listofLabels,
        nbElement: listofIcons.length,
        selectedIndex: initialSelectedIndex
      };
      createTab(tabOptions);
      tabOptions.tab.inject(tabContainer);
      return container;

    }
    return ENOXTabsView;
  });
