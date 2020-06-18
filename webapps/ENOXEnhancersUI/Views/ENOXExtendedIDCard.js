define('DS/ENOXEnhancersUI/Views/ENOXExtendedIDCard', [
  'UWA/Promise',
  'DS/ENOXIDCard/js/IDCard',
  'DS/Core/ModelEvents',
  'DS/UIKIT/Input/Button',
  'DS/ENOXEnhancersUI/Views/ENOXSetView',
  'DS/ENOXEnhancers/Utils/Helper'
], function(
  UWAPromise,
  ENOXIDCard,
  ModelEvents,
  UIKITButton,
  ENOXSetView,
  XEnhancersHelper
)
{
  var ExtendedIDCard = ENOXIDCard.extend(
  {
    name: 'ExtendedIDCard',

    domEvents:
    {
      'click .title-section': 'toggleMinified'
    },
    addToggleCollapseButton: function(triptychView, renderTo)
    {
      renderTo.addClassName('title-section-buttons');

      ENOXSetView.prototype.createToggle(triptychView, renderTo);
    },
    addExtraFreeZones: function(freezoneData, divElement)
    {
      for (var i = 2; i < freezoneData.length; i++)
      {
        var freezoneClass = new this.options.requireJson[freezoneData[i].require](),
          freezoneGetter = freezoneData[i].methodName,
          freezonediv = UWA.createElement('div',
          {
            class: 'free-zone free-zone-' + i,
            html: freezoneClass[freezoneGetter]('extra free zone')
          }).inject(divElement);
      }
    },
    addTypeIcon: function(typeIconUrl, element)
    {
      var icon = UWA.createElement('img',
      {
        src: typeIconUrl,
        styles:
        {
          'vertical-align': 'initial'
        }
      });
      element.insertBefore(icon, element.firstChild);

    },
    prepareStateSection: function(documentData, idCard, renderTo)
    {
      var stateDiv = UWA.createElement('div',
        {
          styles:
          {
            display: 'inline',
          }
        }),
        stateSectionData = idCard.stateSection;
      if (stateSectionData.previous && documentData[stateSectionData.previous])
      {
        var previousSectionDiv = UWA.createElement('div',
        {
          styles:
          {
            display: 'inline',
            'margin-right': '5px'
          }
        });
        var state = new UIKITButton(
        {
          value: documentData[stateSectionData.previous],
          className: 'btn-sm',
          styles:
          {
            height: '70% !important'
          }
        }).inject(previousSectionDiv);

        var arrow = UWA.createElement('span',
        {
          class: 'fonticon fonticon-left ',
          styles:
          {
            color: '#8080804f',
            float: 'right',
            margin: '0px 0px 0px 0px'
          }
        });
        state.elements.input.appendChild(arrow);

        previousSectionDiv.inject(stateDiv);
      }
      if (stateSectionData.current && documentData[stateSectionData.current])
      {
        var currentSectionDiv = UWA.createElement('div',
        {
          styles:
          {
            display: 'inline',
            'margin-right': '5px'
          }
        });
        var state = new UIKITButton(
        {
          value: documentData[stateSectionData.current],
          className: 'primary btn-sm',
          styles:
          {
            height: '70% !important'
          }
        }).inject(currentSectionDiv);
        currentSectionDiv.inject(stateDiv);

      }
      if (stateSectionData.next && documentData[stateSectionData.next])
      {
        var nextSectionDiv = UWA.createElement('div',
        {
          styles:
          {
            display: 'inline',
            'margin-right': '5px'
          }
        });
        var state = new UIKITButton(
        {
          value: documentData[stateSectionData.next],
          className: 'btn-sm',
          styles:
          {
            height: '70% !important'
          }
        }).inject(nextSectionDiv);

        var arrow = UWA.createElement('span',
        {
          class: 'fonticon fonticon-right ',
          styles:
          {
            color: '#8080804f',
            float: 'left',
            margin: '0px 0px 0px 0px'
          }
        });

        state.elements.input.appendChild(arrow);
        nextSectionDiv.inject(stateDiv);
      }
      stateDiv.inject(renderTo);
      return stateDiv;
    },
    getNLSAndRequireJson: function(data)
    {
      var nlsArr = [],
        keys = Object.keys(data);

      for (var i = 0; i < keys.length; i++)
      {
        if (Array.isArray(data[keys[i]]))
        {
          for (var j = 0; j < data[keys[i]].length; j++)
          {
            var obj = data[keys[i]][j]
            if (obj.label && !nlsArr[obj.label.nls])
            {
              nlsArr[obj.label.nls] = 'i18n!' + obj.label.nls;
            }

            if (obj.require && !nlsArr[obj.require])
            {
              nlsArr[obj.require] = obj.require;
            }
          }
        }
        else
        {
          if (data[keys[i]].label && !nlsArr[obj.label.nls])
          {
            nlsArr[data[keys[i]].label.nls] = 'i18n!' + data[keys[i]].label.nls;
          }
        }
      }

      return nlsArr;

    },
    prepareIDCardModel: function(data)
    {
      var that = this,
        i18nJson, myModel,
        idCardOptions = data.idCard,
        documentData = data.documentData,
        parentResolve = data.resolve;

      var i18nPromise = new UWAPromise(function(resolve, reject)
      {
        idCardOptions.resolve = resolve;
        var nlsAndRequireJson = that.getNLSAndRequireJson(idCardOptions);
        XEnhancersHelper.getRequireFromJson(nlsAndRequireJson, resolve);
      }).then(function(result)
      {
        that.options.requireJson = result;
        myModel = new UWA.Class.Model(
        {
          name: documentData[idCardOptions.name.dataindex],
          version: documentData[idCardOptions.version.dataindex],
          thumbnail: documentData[idCardOptions.thumbnail],
          modelEvents: new ModelEvents(),
          freezones: [],
          attributes: [],
          withHomeButton: idCardOptions.withHomeButton,
          withActionsButton: idCardOptions.withActionsButton,
          withInformationButton: idCardOptions.withInformationButton,
          showBackButton: idCardOptions.showBackButton
        });
        var count = 0;
        idCardOptions.freezones.forEach(function(item)
        {
          if (count < 2)
          {
            var freezoneClass = new result[item.require](),
              freezoneGetter = item.methodName;
            myModel._attributes.freezones.push(result[item.label.nls][
              item
              .label
              .id
            ] + " : " + freezoneClass[freezoneGetter]('Test'));
            count++;
          }
        });

        idCardOptions.attributes.forEach(function(item)
        {
          var attr = {
            name: result[item.label.nls][item.label.id],
            value: (item.type && item.type === "date") ? XEnhancersHelper
              .getFormattedDate(
                documentData[item.dataindex], idCardOptions.formatter) : documentData[
                item.dataindex]
          };
          myModel._attributes.attributes.push(attr);
        });

        parentResolve(myModel);
      });

    },
    setup: function(options)
    {
      var that = this,
        _myParent = that._parent,
        parentResolve = options.resolve;
      var promise = new UWAPromise(function(resolve, reject)
      {
        options.resolve = resolve;
        that.prepareIDCardModel(options);

      });
      promise.then(function(result)
      {
        that._parent = _myParent;
        that.model = result;
        that._parent();
        parentResolve(that);
      });
    },
    render: function()
    {
      var that = this;
      this._parent();
      var titleSection = this.getElements('.title-section')[0];
      this.prepareStateSection(this.options.documentData, this.options.idCard,
        titleSection);
      this.addTypeIcon(this.options.documentData.icon, titleSection);
      this.addExtraFreeZones(this.options.idCard.freezones, this.getElements(
        '.lower-main-section')[0])
      this.addToggleCollapseButton(this.options
        .enoxtriptychview, this.getElements('.title-section-buttons')[0]);
    }
  });

  return ExtendedIDCard;
});
