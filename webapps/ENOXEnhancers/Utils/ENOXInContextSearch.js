define('DS/ENOXEnhancers/Utils/ENOXInContextSearch', [
    'DS/ENOXEnhancers/Constants/Constants'
  ],
  function(
    Constants
  )
  {
    'use strict';
    var ENOXContentSearchInWidget = function() {}
    /**showSearchInput: fired when seach icon is selected from toolbar.
     * @ searchElements: uwa elements related with search.
     **/
    ENOXContentSearchInWidget.prototype.showSearchInput = function(searchElements)
    {
      searchElements.input.show();
      searchElements.input.focus();
      searchElements.searchInput.hide();
    }
    /**launchSearch: fired when 'ENTER' key is pressed in input box.
     * @ searchElements: uwa elements related with search.
     **/
    ENOXContentSearchInWidget.prototype.launchSearch = function(searchElements)
    {
      var query = searchElements.input.getValue();
      console.log('query fired: ' + query);
      if (query === Constants.EMPTY_STRING)
      {
        self.widget.dispatchEvent('onResetSearch');
      }
      else
      {
        self.widget.dispatchEvent('onSearch', query);
      }
    }
    /** hideSearchInput: fired when 'ESC' key is pressed in inputbox.
     * It will empty the inputbox content then fires 'onResetSearch' event.
     * @ searchElements: uwa elements related with search.
     **/
    ENOXContentSearchInWidget.prototype.hideSearchInput = function(searchElements)
    {
      var inputBox = widget.getElement('.searchInContext_input');
      inputBox.value = Constants.EMPTY_STRING;
      searchElements.input.hide();
      searchElements.searchInput.show();
      self.widget.dispatchEvent('onResetSearch');
    }

    return ENOXContentSearchInWidget;

  });
