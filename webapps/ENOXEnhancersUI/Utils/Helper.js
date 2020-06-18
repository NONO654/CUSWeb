define('DS/ENOXEnhancersUI/Utils/Helper', [
  'UWA/Core',
  'DS/UIKIT/Alert',
  'DS/Notifications/NotificationsManagerViewOnScreen',
  'DS/Notifications/NotificationsManagerUXMessages',
  'DS/UIKIT/Mask',
  'DS/ENOXEnhancers/Constants/Constants'
], function(
  UWACore,
  UIKITAlert,
  WUXNotificationsManagerViewOnScreen,
  WUXNotificationsManagerUXMessages,
  UIKITMask,
  Constants
)
{
  'use strict';

  var Helper = {
    showAlert: function _showAlert(msgType, alertMsg, location)
    {
      var hideDelay = 3000;
      if (msgType == Constants.ERROR)
      {
        hideDelay = 6000;
      }
      var alert = new UIKITAlert(
      {
        visible: true,
        autoHide: true,
        hideDelay: 3000,
        icon: true,
        messages: [
        {
          message: alertMsg,
          className: msgType
        }]
      });

      alert.inject(location ? location : 'top');
    },
    showNotification: function _showNotification(msgType, msgTitle, msgSubTitle, msg, sticky)
    {
      var infoOptions = {
        level: msgType,
        title: msgTitle,
        subtitle: msgSubTitle,
        message: msg,
        sticky: sticky
      };

      window.notifs = WUXNotificationsManagerUXMessages;
      WUXNotificationsManagerViewOnScreen
        .setNotificationManager(window.notifs);
      window.notifs.addNotif(infoOptions);
    },
    loadingON: function _loadingON(msg, container)
    {
      var maskContainer = Constants.EMPTY_STRING;
      if (container)
      {
        maskContainer = container;
      }
      else
      {
        maskContainer = widget.body;
      }
      if (msg)
      {
        UIKITMask.mask(maskContainer, msg);
      }
      else
      {
        UIKITMask.mask(maskContainer);
      }
    },
    loadingOFF: function _loadingOFF(container)
    {
      var maskContainer = Constants.EMPTY_STRING;
      if (container)
      {
        maskContainer = container;
      }
      else
      {
        maskContainer = widget.body;
      }
      UIKITMask.unmask(maskContainer);
    },
    /**Sorts the models on the passed attribute field
     * @ sortQuery: this contains the attribute name and order for sorting
     * @ currentContent: content of current view
     **/
    sortCollection: function _sortCollection(sortQuery, currentContent)
    {
      var sortAttribute = sortQuery.sortAttribute,
        sortOrder = sortQuery.sortOrder;
      var tempAttribute = 'lowercase' + sortAttribute.toLowerCase().trim();
      currentContent.comparator = sortAttribute;
      var content = currentContent._models || currentContent;
      for (var i = 0; i < content.length; i++)
      {
        content[i]._attributes[tempAttribute] = content[i]._attributes[sortAttribute].toLowerCase();
      }
      content.sort();
      var tempCollection = new UWA.Class.Collection();
      tempCollection.add(content);
      try
      {
        currentContent.reset();
        currentContent.add(tempCollection._models);
        if (sortOrder === 'DESC')
        {
          currentContent._models.reverse();
        }
        return currentContent;
      }
      catch (e)
      {
        if (sortOrder === 'DESC')
        {
          tempCollection._models.reverse();
          currentContent = tempCollection;
        }
        return currentContent;
      }

    },
    prepareCollection: function _prepareCollection(result)
    {
      var coll = new UWA.Class.Collection(),
        modelArray = [];
      for (var i = 0; i < result.length; i++)
      {
        var pid = result[i];
        var mod = new UWA.Class.Model(
        {
          'id': pid
        });
        modelArray[i] = mod;
      }
      coll.add(modelArray);
      return coll;
    },
    getObjectId: function _getObjectId(objList)
    {
      var idList = '';
      for (var i = 0; i < objList.length; i++)
      {
        idList = idList + objList[i].id + ',';
      }
      return idList;
    },
    formIdString: function _formIdString(objList)
    {
      try
      {
        var idList = '';
        if (objList._models)
        {
          for (var i = 0; i < objList.length; i++)
          {
            idList = idList + objList._models[i].id + ',';
          }
        }
        else
        {
          for (var i = 0; i < objList.length; i++)
          {
            idList = idList + objList[i] + ',';
          }
        }
      }
      catch (error)
      {
        console.log('Error while forming webservice input id string.')
      }

      return idList;
    }
  };

  return Helper;
});
