define('DS/ENOXEnhancers/Utils/Helper', [
  "UWA/Core",
  'UWA/Promise',
  "DS/ENOXEnhancers/Constants/Constants",
  'i18n!DS/ENOXEnhancers/assets/nls/ENOXEnhancers'
], function(
  UWACore,
  UWAPromise,
  Constants,
  XEnhancersNLS
)
{
  'use strict';

  var Helper = {
    getFormattedHistoryJSON : function _getFormattedHistoryJSON(data) {
      var historyArray=[];
      var history,author;

      data.forEach(function(item){
        history={};
        author={};
        history.action=item.dataelements.action;
        history.date=item.dataelements.time;
        history.description=item.dataelements.description;
        history.state=item.dataelements.state;
        author.fullName=item.dataelements.user;
        author.user=item.dataelements.user;
        history.author=author;
        historyArray.push(history);
      });

      return historyArray;
    },
    getMessage: function _getMessage(data)
    {
      var key = data != undefined && Helper.isStringEmpty(data['key']) ? data['key'] :
        '0001';
      var concats = data != undefined && Helper.isArrayEmpty('appends') ? data.appends :
        Constants.EMPTY_JSON_ARRAY;
      var value = XEnhancersNLS[key] || key;
      return value.concat(concats);
    },
    getFormattedDate: function _getFormattedDate(strDate, formatter)
    {
      var date = new Date(strDate);
      var formattedDate = date.toLocaleString('en-US', formatter);
      return formattedDate;
    },
    isStringEmpty: function _isStringEmpty(stringobj)
    {
      var empty = true;
      if (!(stringobj === undefined || stringobj === Constants.EMPTY_STRING || stringobj ===
          null))
      {
        if (!UWA.is(stringobj, 'string'))
        {
          throw new Error('Data is not a typeOf string');
        }
        else
        {
          empty = false;
        }
      }
      return empty;
    },
    isHTMLElementEmpty: function _isHTMLElementEmpty(element)
    {
      var empty = true;
      if (!(element === undefined || element === Constants.EMPTY_STRING || element === null))
      {
        if (!UWA.is(element, 'element'))
        {
          throw new Error('Data is not a typeOf HTML Element');
        }
        else
        {
          empty = false;
        }
      }
      return empty;
    },
    isObjectEmpty: function _isObjectEmpty(obj)
    {
      var empty = true;
      if (!(obj === undefined || obj == Constants.EMPTY_STRING))
      {
        if (!UWA.is(obj, 'object'))
        {
          empty = false;
        }
        else if (!(Object.keys(obj).length === 0 &&
            obj.constructor === Object))
        {
          empty = false;
        }
      }
      return empty;
    },
    isArrayEmpty: function _isArrayEmpty(arrayObj)
    {
      var empty = true;
      if (!(arrayObj === undefined || arrayObj == Constants.EMPTY_STRING))
      {
        if (!UWA.is(arrayObj, 'array'))
        {
          empty = false;
        }
        else if (arrayObj.length > 0)
        {
          empty = false;
        }
      }

      return empty;
    },
    getRequireFromJson: function _getRequireFromJson(jsonArr, callback)
    {
      var requireArr = Object.values(jsonArr),
        requireKeys = Object.keys(jsonArr);
      var requirePromise = new UWAPromise(function(resolve, reject)
      {
        require(requireArr, function(data)
        {
          resolve(arguments)
        });
      }).then(function(result)
      {
        for (var i = 0; i < requireKeys.length; i++)
        {
          jsonArr[requireKeys[i]] = result[i];
        }

        callback(jsonArr);

      });

    },
    getIdsFromSearchResult: function _getIdsFromSearchResult(result)
    {
      result = JSON.parse(result);
      var idList = [],
        dataGrp = result.widgets[0].datarecords.datagroups;
      for (var i = 0; i < dataGrp.length; i++)
      {
        idList.push(dataGrp[i].physicalId)
      }
      return idList;
    },

    getTitle: function _getTitle(title)
    {

      return "<b>Title</b>  :"+title;
    },
    
     getOwner: function _getOwner(owner)
    {

      return "<b>Owner</b> :"+owner;
    },
    
     getChange: function _getChange(change)
    {

      return "<b>Change</b> :"+change;
    },
    
     getModified: function _getModified(modified)
    {

      return "<b>Modified</b> :"+modified;
    },
    
     getDescription: function _getDescription(description)
    {

      return "<b>Description</b> :"+description;
    }
  };

  return Helper;
});
