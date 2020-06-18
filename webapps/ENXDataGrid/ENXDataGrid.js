// wrapper on DataGridView. In case we decide to replace DataGridView then this module needs to be changed without impacting other.

define('DS/ENXDataGrid/ENXDataGrid', ['DS/DataGridView/DataGridView', 'DS/Tree/TreeDocument', 'DS/Tree/TreeNodeModel'],
  function(DataGridView, TreeDocument, TreeNodeModel) {
    'use strict';
    var ENXDataGrid = DataGridView.inherit({
      name: 'ENXDataGrid',
      init: function(properties) {
        this._parent(properties);
      }
		
    });
    return ENXDataGrid;
  });
