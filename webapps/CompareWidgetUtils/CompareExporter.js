define('DS/CompareWidgetUtils/CompareExporter', [
  'UWA/Class',
  'UWA/Class/Options',
  'DS/PADUtils/PADUtilsServices'
], function(
    Class,
    Options,
    PADUtilsServices
    ) {
  'use strict';


  /**
   * @description
   * Export the results of the Compare widget.
   * Originally copied from xNavExporter.js, which does the same for the Product Structure widget.
   * Some of the original unused code is left in place but commented out, in case what the
   * Compare widget needs to do is enhanced.  The original code may be useful to see.
   *
   * This module makes the printing and csv generation predicatbly similar.
   * The node data is flattened to string data separated into tables.
   * This data is then fed into different renderers (csv, html) to produce the final output.
   *
   * 2019/01/22 Created for FUN085629
   */

  var TABLE_CONSTANTS = {
    TABLE: '<table style="border:1px solid black; border-collapse:collapse;">',
    TABLE_CLOSE: '</table><br/>',
    HEADER: '<th style="border:1px solid black; background-color:#A7C942; text-align:left; color:#FFFFFF; font-size:.8em; padding-top:5px; paddingbottom:4px;word-break:break-word;display:table-cell;">',
    HEADER_CLOSE: '</th>',
    ROW: '<tr>',
    ROW_CLOSE: '</tr>',
    DATA: '<td>',
    DATA_CLOSE: '</td>'
  };

  var escapeHTML = (function () {
      var map = {
              '&': '&amp;',
              '<': '&lt;',
              '>': '&gt;',
              '"': '&quot;',
              "'": '&#x27;',
              '/': '&#x2F;'
          },
          re = /[&<>"'\/]/g,
          reTagsOnly = /[<>\/]/g;

      function replace(str) {
          return map[str];
      }

      return function (string, tagsOnly) {
          return String(string).replace(tagsOnly ? reTagsOnly : re, replace);
      };
  }());

  function iterate(array, context, callback) {
      var len = array.length;
      for (var i = 0; i < len; i++) {
          var item = array[i];
          callback(context, item, i);
      }
  }

/*  function getLabelForColumn(column) {
       var lineName = column.text;
       if (lineName === '' || lineName === null || lineName === undefined) {
           var key = 'treelistview_customization_' + column.dataIndex;
           if (UWA.is(PADUtilsnls[key])) {
               lineName = PADUtilsnls[key];
           } else {
               lineName = column.dataIndex;
           }
       }

       return lineName;
   }
*/
   function stringifyInt(value) {
     return '' + value;
   }

  function quotify(str) {
    return '\"' + str + '\"';
  }

/*  function getLocalizedDateFromNode(node, columnName) {
      var date_value = node.options.grid[columnName];
      var result = Utility.convertDateTime(date_value);
      return result;
      // var parsed_date = Date.parse(date_value);
      // if (!isNaN(parsed_date)) {
      //     date_value = new Date(parsed_date).toLocaleString();
      // }
      // return date_value;
  }
*/
/*  function getColumnData(dataIndex, node) {
    if (dataIndex === "tree") {
        return node.options.label;
    } else if (UWA.is(internals.customizedColumnRenderers[dataIndex], 'function')) {
        return internals.customizedColumnRenderers[dataIndex](node);
    } else if (UWA.is(node.options.grid[dataIndex], 'string')) {
        return node.options.grid[dataIndex];
    } else if (UWA.is(node.options.grid[dataIndex], 'number')) {
        // IR-656254 we are not exporting ints.
        return stringifyInt(node.options.grid[dataIndex]);
    } else {
      // if it is undefined...return empty string.
      return '';
    }
  }
*/
/*  function appendRowData(currentTable, keptColumns, node) {
    var rowData = [];
    rowData.push(stringifyInt(node.getDepth()));
    rowData.push(getColumnData('tree', node));
    iterate(keptColumns, null, function(nullCtx, column) {
        // IR-638921 Need to process column by kind.
        var custo = column.customisation ? column.customisation : column.xnav_options;
        var kind = custo.kind;
        if (kind) {
          switch (kind) {
            case 'date':
              rowData.push(getLocalizedDateFromNode(node, column.dataIndex));
              break;
          default:
            // IR-651546 Handling date we forgot the other custom attributes of string kind.
            rowData.push(getColumnData(column.dataIndex, node));
            break;
          }
        } else {
          rowData.push(getColumnData(column.dataIndex, node));
        }
    });

    currentTable.rows.push(rowData);
  }
*/

/*  function generateRenderStruct(twodapp, toremovelist) {
    var structure = {
      columns: [],
      tables: []
    };

    var XNavSettings = require('DS/PADUtils/XNavSettings');
    var availableColumns = XNavSettings.getAvailableColumns();
    var actualColumns = twodapp.options.views.treelistview.options.columns.slice();

    iterate(actualColumns, null, function(nullCtx, column) {
      var custo = column.customisation ? column.customisation : column.xnav_options;
      var isExp = custo && custo.exportable ? custo.exportable.value : false;
      if (typeof isExp !== 'undefined' && !isExp) {
        var dataIndex = column.dataIndex;
        if (toremovelist.indexOf(dataIndex) === -1) toremovelist.push(dataIndex);
      }
    });

    var context = {
      kept: [],
      tree: null
    };

    iterate(actualColumns, context, function(ctx, column) {
      if (column.dataIndex === 'tree') {
        ctx.tree = column;
      } else if (availableColumns.available_columns.indexOf(column.dataIndex) !== -1 && (toremovelist.indexOf(column.dataIndex) === -1)){
        ctx.kept.push(column);
      }
    });

    structure.columns.push(PADUtilsnls.export_level);
    structure.columns.push(context.tree.text);

    iterate(context.kept, structure, function(str, col) {
      str.columns.push(getLabelForColumn(col));
    });

    iterate(twodapp.options.model.getRoots(), structure, function(struct, root) {
      var currentTable = null;
      if (root.isVisible()) {
        currentTable = {
          rows: []
        };
        struct.tables.push(currentTable);
        appendRowData(currentTable, context.kept, root);
        root.processDescendants({
          processNode: function() {
              if (this.isVisible()) {
                appendRowData(currentTable, context.kept, this);
              }
          }
        });
      }
    });

    return structure;
  }
*/
  function StringBuilder(){
    this._str = '';
  }

  StringBuilder.prototype = {
    CRLF: '\r\n',
    append: function(value) {
      // convert int into string...
      this._str += value + '';
    },
    appendCRLF: function() {
      this._str += this.CRLF;
    },
    toString: function() {
      return this._str;
    }
  };


  function HtmlRenderer(options) {
    var opts = options || {};
    this._debug = opts.debug === true;
    this._builder = new StringBuilder();
  }

  HtmlRenderer.prototype = {
    render: function(structure) {
      var self = this;

      // for each table...
      // open
      // headers...
      // body
      // rows
      // close
      this.appendCRLF();
      iterate(structure.tables, structure.columns, function(colsArray, table) {
        self._builder.append(TABLE_CONSTANTS.TABLE);
        self._builder.append('<thead><tr>');
        self.appendCRLF();
        iterate(colsArray, null, function(nullCtx, col) {
          self._builder.append(TABLE_CONSTANTS.HEADER);
          self._builder.append(col);
          self._builder.append(TABLE_CONSTANTS.HEADER_CLOSE);
        });
        self.appendCRLF();
        self._builder.append('</tr></thead>');
        self._builder.append('<tbody>');
        iterate(table.rows, null, function(nullCtx, row) {
          self.appendCRLF();
          self._builder.append(TABLE_CONSTANTS.ROW);
          iterate(row, null, function(nullCtx, data) {
            self._builder.append(TABLE_CONSTANTS.DATA);
            // TODO escapeHTML so <>&"' end up showing in the HTML print window.
            self._builder.append(data);
            self._builder.append(TABLE_CONSTANTS.DATA_CLOSE);
          });
          self._builder.append(TABLE_CONSTANTS.ROW_CLOSE);
        });
        self.appendCRLF();
        self._builder.append('</tbody>');
        self._builder.append(TABLE_CONSTANTS.TABLE_CLOSE);
      });

      return this._builder.toString();
    },
    appendCRLF: function() {
      if (this._debug) {
        // Makes it easier to debug the HTML.
        this._builder.appendCRLF();
      }
    }
  };

  function CsvRenderer() {
    this._builder = new StringBuilder();
  }

  CsvRenderer.prototype = {
    renderHeaders: function(headers) {
      var end = headers.length - 1;
      iterate(headers, this, function(thisPtr, header, idx) {
        thisPtr._builder.append(quotify(header));
        if (idx !== end) {
          thisPtr._builder.append(','); //comma only delimiter Excel does not like spaces
        }
      });

      this._builder.appendCRLF();
    },
    renderTables: function(tables, columns) {
      var self = this;

      iterate(tables, null, function(nullCtx, table) {
        iterate(table.rows, null, function(nullCtx, row) {
          var rowDataEnd = row.length - 1;
          iterate(row, null, function(nullCtx, data, rowDataIndex) {
            self._builder.append(quotify(data));
            if (rowDataIndex !== rowDataEnd) {
              self._builder.append(','); //comma only delimiter Excel does not like spaces
            }
          });
          self._builder.appendCRLF();
        });
      });
    },
    render: function(structure) {
      // add BOM so excel is not stupid about importing.
      // most doc say that it is EF BB BF
      // But MS site says use this unicode character.
      // http://stackoverflow.com/questions/17879198/adding-utf-8-bom-to-string-blob
      // https://msdn.microsoft.com/library/2yfce773%28v=vs.94%29.aspx?f=255&MSPPError=-2147217396
      this._builder.append('\uFEFF');
      this.renderHeaders(structure.columns);
      this.renderTables(structure.tables, structure.columns);
      return this._builder.toString();
    }
  };

  var internals = {
/*    customizedColumnRenderers: {
        'ds6w:created': function(node) {
            return getLocalizedDateFromNode(node, 'ds6w:created');
        },

        'ds6w:modified': function(node) {
            return getLocalizedDateFromNode(node, 'ds6w:modified');
        },

        'ds6w:reserved': function(node) {
          var reservedString = node.options.grid['ds6w:reserved'];
          if (reservedString) {
            var reserved = (reservedString.toLowerCase() === 'true');
            if (reserved) {
              return nlsENXNav.tooltip_reserved;
            } else {
              return nlsENXNav.tooltip_unreserved;
            }
          } else {
            return nlsENXNav.tooltip_unreserved;
          }
        }
    },
*/    options: {
//      columns_to_remove: ['tree', 'find_in_ctx', 'hide_show', 'bi_color'],
      csv_base_file_name: "CSV Report"
    }
  };

  // </editor-fold>

  var CompareExporter = Class.singleton({
    /**
     * @description
     * <blockquote>
     * Generates the HTML and dispatches it to the print() mechanism on PADUtilsServices.
     * </blockquote>
     *
     * @memberof module:DS/CompareWidgetUtils/CompareExporter#
     *
     * @param {Object} struct - The structure to output
     * @param {Object} options - Available options.
     *
     */
    printHtml: function(struct, options) {
        var renderer = new HtmlRenderer();
        var output = renderer.render(struct);

        PADUtilsServices.printhtml(output);
    },

    /**
     * @description
     * <blockquote>
     * Generates the CSV and dispatches it to the download() mechanism on PADUtilsServices.
     * </blockquote>
     *
     * @memberof module:DS/CompareWidgetUtils/CompareExporter#
     *
     * @param {Object} struct - The structure to output
     * @param {Object} options - Available options.
     *
     */
    generateCsv: function(struct, options) {
    	if (options.csv_base_file_name) {
    		internals.options.csv_base_file_name = options.csv_base_file_name;
    	}
    	
    	var renderer = new CsvRenderer();
    	var output = renderer.render(struct);

    	if (options.outputToConsole)
    		console.log(output);

    	if (!options.noOutputToFile)
    		PADUtilsServices.downloadfile(output, internals.options.csv_base_file_name + " " + (new Date()).toString().split(' ').splice(1, 4).join(' ') + '.csv', 'text/csv');
    },

    /**
     * @description
     * <blockquote>
     * Generates the CSV and dispatches it to the console.
     * </blockquote>
     *
     * @memberof module:DS/CompareWidgetUtils/CompareExporter#
     *
     * @param {Object} struct - The structure to output
     * @param {Object} options - Available options.
     *
     */
    consoleOutput: function(struct, options) {
    	options.outputToConsole = true;
    	options.noOutputToFile = true;
    	this.generateCsv(struct, options);
    },

    /**
     * @description
     * <blockquote>
     * Generates the Data for CSV and HTML.
     * This method is only exposed for testing.
     * </blockquote>
     *
     * @memberof module:DS/CompareWidgetUtils/CompareExporter#
     *
     */
//    generateRenderStruct: generateRenderStruct
  });

  return CompareExporter;
});
