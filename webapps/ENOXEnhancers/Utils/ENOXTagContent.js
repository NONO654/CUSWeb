define('DS/ENOXEnhancers/Utils/ENOXTagContent', [
    'UWA/Class',
    'UWA/Core',
    'DS/TagNavigatorProxy/TagNavigatorProxy',
    'DS/ENOXEnhancers/Services/SettingsManagement',
    'DS/ENOXEnhancers/Services/WebServices',
    'DS/ENOXEnhancers/Services/Resources',
    'DS/ENOXEnhancers/Constants/Constants'
  ],
  function(
    UWAClass,
    Core,
    TagNavigatorProxy,
    SettingsManagement,
    WebServices,
    Resources,
    Constants
  )
  {
    'use strict';
    var tagUpdate = UWAClass.extend(
    {
      taggerProxy: null,
      _initTaggerProxy: function(viewObj)
      {
        var that = this,
          options = options ||
          {},
          taggerOptions, taggerProxyEvents;

        taggerOptions = Core.merge(options,
        {
          widgetId: widget.id,
          filteringMode: 'WithFilteringServices',
          events:
          {
            'onFilterChange': that.onFilterChange,
            'onFilterSubjectsChange': that.onFilterChange,
          }
        });
        that.modelEvents = viewObj.modelEvents;

        that.taggerProxy = TagNavigatorProxy.createProxy(taggerOptions);

        that.taggerProxy.addFilterSubjectsListener(that.onFilterChange, that);
      },
      activateTaggerProxy: function()
      {
        var taggerProxy = this.taggerProxy;

        if (!this.taggerProxy)
        {
          return;
        }

        taggerProxy.activate();
      },

      deactivateTaggerProxy: function()
      {
        var taggerProxy = this.taggerProxy;

        if (!this.taggerProxy)
        {
          return;
        }

        taggerProxy.deactivate();
      },
      onFilterChange: function(filterTagObj)
      {
        console.log('In onFilterChange');
        if (Object.keys(filterTagObj.filteredSubjectList).length > 0)
        {
          var that = this;
          var filterIds = [];
          for (var i = 0; i < filterTagObj.filteredSubjectList.length; i++)
          {
            filterIds.push(filterTagObj.filteredSubjectList[i].replace('pid://', ''))
          }

          that.modelEvents.publish(
          {
            event: 'onFilterChange',
            data: filterIds
          });
        }
        else
        {
          console.log('No filtered id is present in applied tags.');
          filterTagObj.localfilters = {};
          filterTagObj.allfilters = {};
        }

      },

      setSubjectTags: function(taggerInput)
      {
        var that = this,
          taggerProxy = that.taggerProxy;
        taggerProxy.setSubjectsTags(taggerInput);
      },
    });

    /**
     * Public method used to convert tag info returned by BPS web service
     * into a format suitable for TagNavigatorProxy
     * @param {Object} tagsdataVal .
     * @returns {Object} .
     */
    tagUpdate.prototype.formatBpsTagDataForTNProxy = function(tagsdataVal)
    {
      var tagnameArr, dataGpArr, subObject, dataGp, dataEle, tname, sixw, tnameObject, tagObjx,
        valuename;
      tagnameArr = tagsdataVal.widgets[0].widgets[0].widgets;
      dataGpArr = tagsdataVal.widgets[0].datarecords.datagroups;
      subObject = {};
      dataGpArr.forEach(function(dataGpEntry)
      {
        dataGp = dataGpEntry;
        dataEle = dataGpEntry.dataelements;
        if (!dataEle)
        {
          return;
        }
        subObject['pid://' + dataGp.physicalId] = [];
        tagnameArr.forEach(function(tagnameArrEntry)
        {
          tname = tagnameArrEntry.name;
          sixw = tagnameArrEntry.selectable.sixw;
          tnameObject = dataEle[tname];
          if (!tnameObject)
          {
            return;
          }
          tnameObject.value.forEach(function(entry)
          {
            tagObjx = {};
            valuename = entry.value;
            tagObjx.object = valuename;
            tagObjx.sixw = sixw;
            var tnameSubStr = tname.replace('_tag_', '');
            tagObjx.field = tnameSubStr;
            tagObjx.dispValue = valuename;
            subObject['pid://' + dataGp.physicalId].push(tagObjx);
          });
        });
      });
      return subObject;
    };

    function tagComplete(result)
    {
      console.log('tags fetched successfully.');
      var subjectTags = this.formatBpsTagDataForTNProxy(JSON.parse(result));
      this.setSubjectTags(subjectTags);
      //For storing the tags.Used to make it fast, update with change in ui.
      var savedTagger = SettingsManagement.getSetting(Constants.CURRENT_TAG);
      savedTagger.allTags = subjectTags;
    }

    function tagFailed(error)
    {
      console.log("tag failed :" + error);
    }

    tagUpdate.prototype.renderTags = function(idList, callerReference)
    {
      var that = callerReference.tagger;
      that.taggerProxy.setSubjectsTags([]);
      var options = {};
      options.data = {
        "oid_list": idList,
        "isPhysicalIds": true
      };
      options.onComplete = tagComplete.bind(that);
      options.onFailure = tagFailed;
      options.timeout = 200000;
      options.method = Constants.POST;
      options.headers = {
        'content-type': Constants.APPLICATION_URL_ENCODED,
        'Accept': Constants.ACCEPT_APPLICATION_JSON
      }
      options.url = SettingsManagement.getPlatformURLs().get3DSpaceURL() + Resources.GET_TAGS;
      WebServices.callCustomService(options);
    },
    /* removes id list from the available tags.
     */
    tagUpdate.prototype.removeAParticuliarIdFromTag = function(idList)
    {
      var taggerObj = this;
      if (taggerObj.allTags == undefined)
      {
        console.log('No tag is updated in current view. Let Tags get updated, then check.');
      }
      else
      {
        var allTagsArray = Object.keys(taggerObj.allTags);
        idList.forEach(function(id)
        {
          for (var i = 0; i < allTagsArray.length; i++)
          {
            if (allTagsArray[i].contains(id))
            {
              var key = "pid://" + id;
              delete taggerObj.allTags[key];
            }
          }
        });
        taggerObj.taggerProxy.setSubjectsTags(taggerObj.allTags);
      }
    }


    return tagUpdate;
  });
