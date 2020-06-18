define('DS/ENOXEnhancersUI/Views/ENOX3DPlayViewer', [
    'UWA/Core',
    'UWA/Promise',
    'DS/3DPlayHelper/3DPlayHelper',
    'DS/UIKIT/Iconbar',
    'DS/ENOXEnhancers/Services/SettingsManagement',
    'DS/ENOXEnhancers/Constants/Constants',
    'DS/ENOXEnhancersUI/Constants/Constants',
    'DS/CoreEvents/ModelEvents',
    'DS/ENOXEnhancers/Services/Resources',
    'i18n!DS/ENOXEnhancersUI/assets/nls/ENOXEnhancersUI',
    'css!DS/ENOXEnhancersUI/css/ENOXEnhancersUI'
  ],
  function(
    UWACore,
    UWAPromise,
    _3DPlayHelper,
    Iconbar,
    SettingsManagement,
    Constants,
    UIConstants,
    ModelEvents,
    Resources,
    XEnhancersUINLS
  )
  {
    'use strict'
    var _3DPlayViewer = function() {};

    function playerFileProcessor(files)
    {
      var pdfFilesList = [];
      files.forEach(function(item)
      {
        if (item.dataelements.title.contains('.pdf') ||
          item.dataelements.title.contains('.PDF'))
        {
          pdfFilesList.push(item);
        }
      });
      return pdfFilesList;
    }

    function dummy3DPlay(message, pdfContainer, imageURl)
    {
      pdfContainer.empty();
      var dummy3DPlayConainer = UWA.createElement('div');

      var _3DPlayImage = UWA.createElement('img',
      {
        src: SettingsManagement.getPlatformURLs().get3DSpaceURL() + imageURl
      });
      _3DPlayImage.inject(dummy3DPlayConainer);

      var selectMessagediv = UWA.createElement('p',
      {
        class: 'dummy-3dplay-message',
        html: message
      });
      selectMessagediv.inject(dummy3DPlayConainer);

      dummy3DPlayConainer.inject(pdfContainer);

      return dummy3DPlayConainer;
    }

    function addFileIconsIn3DPlayContainer(pdfFileList, pdfContainer, fileIconContainer, that)
    {
      var iconBarItems = [];
      pdfFileList.forEach(function(item)
      {
        var iconBarItem = {
          fonticon: 'doc',
          text: item.dataelements.title,
          selectable: true,
          handler: function()
          {
            that.options.modelEvents.publish(
            {
              event: 'file-icon-click',
              data:
              {
                asset: that.options.input.asset,
                physicalId: item.id,
                renderTo: pdfContainer,
                fileName: item.dataelements.title
              }
            });
          }
        };
        iconBarItems.push(iconBarItem);
      });

      var filesIconBar = new Iconbar(
      {
        renderTo: fileIconContainer,
        items: iconBarItems
      });

      for (var i = 0; i < pdfFileList.length; i++)
      {
        filesIconBar.getItem(i).elements['container'].setAttribute('title', filesIconBar.getItem(
          i).text);
      }
      dummy3DPlay(XEnhancersUINLS['Message_Select_File'], pdfContainer, Resources._3DPLAY_LANDING_PAGE);

      return filesIconBar;
    }

    function load3DPlay(_3DPlayData)
    {
      _3DPlayData.asset.physicalid = _3DPlayData.physicalId;
      _3DPlayData.renderTo.empty();
      _3DPlayData.renderTo.setAttribute('fileName', _3DPlayData.fileName);
      var promise = new UWAPromise(function(resolve, reject)
      {
        var player = _3DPlayHelper(
        {
          container: _3DPlayData.renderTo,
          input:
          {
            asset: _3DPlayData.asset
          },
          options:
          {
            loading: "autoplay"
          }
        });
        resolve(player);
      });

      promise.then(function(result)
      {
        return result;
      });
    }

    function getEvents()
    {
      var modelEvents = new ModelEvents();

      modelEvents.subscribe(
        {
          event: 'file-icon-click'
        },
        function(data)
        {
          load3DPlay(data);
        });
      return modelEvents;
    }

    _3DPlayViewer.prototype.init = function(options)
    {
      this.options = {};
      this.options.modelEvents = getEvents();
      this.options.documentData = options.documentData;
      this.options.input = {
        asset:
        {
          provider: UIConstants.PROVIDER_EV6,
          dtype: UIConstants.DTYPE,
          serverurl: SettingsManagement.getPlatformURLs().get3DSpaceURL(),
          tenant: SettingsManagement.getPlatformURLs().getTenantId(),
          requiredAuth: 'none'
        },
      };
    }

    _3DPlayViewer.prototype.render = function(extWPContainer)
    {
      var that = this;
      var files = that.options.documentData.files;
      var pdfFilesList = files ? playerFileProcessor(files) : Constants.EMPTY_JSON_ARRAY;

      var fileIconsContainer = UWACore.createElement('div',
      {
        class: 'file-icons-div',
        styles:
        {
          'border-bottom': 'inset',
        }
      });
      if (pdfFilesList && pdfFilesList.length > 1)
      {
        fileIconsContainer.inject(extWPContainer);
      }
      extWPContainer.parentElement.style.height = widget.body.clientHeight * 0.8 + 'px';
      var playerContainer = UWACore.createElement('div',
      {
        class: 'canvas-div',
        styles:
        {
          height: 'inherit'
        }
      });
      playerContainer.inject(extWPContainer);
      var physicalId = '';
      if (files != undefined && files.length == 0)
      {
        dummy3DPlay(XEnhancersUINLS['Message_No_File_To_Preview'], playerContainer, Resources
          ._3DPLAY_ERROR_PAGE);
      }
      else if (files != undefined && files.length != 0 && pdfFilesList.length == 1)
      {
        load3DPlay(
        {
          asset: that.options.input.asset,
          physicalId: files[0].id,
          renderTo: playerContainer,
          fileName: files[0].dataelements.title
        });

      }

      else if (pdfFilesList.length == 0 && files != undefined && files.length != 0)
      {
        dummy3DPlay(XEnhancersUINLS['Message_UnSupported_File'], playerContainer, Resources._3DPLAY_ERROR_PAGE);
      }
      else if (pdfFilesList.length != 0 && files != undefined && files.length != 0)
      {
        extWPContainer.parentElement.style.height = widget.body.clientHeight * 0.75 + 'px';
        addFileIconsIn3DPlayContainer(pdfFilesList, playerContainer, fileIconsContainer, that);
      }
    }

    return _3DPlayViewer;
  });
