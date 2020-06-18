/**
 * @license Copyright 2017 Dassault Systemes. All rights reserved.
 *
 * @overview : LayoutManager of the UX Scaffolding
 *
 * @author H9M
 */

define('DS/ENOXAppsScaffoldingTemp/LayoutManager.vlh2',
   [
       'UWA/Core'
   ],

   function (UWACore) {
      'use strict';

       /**
       Layout Manager is used when it is required to add certain modules to the DOM 
       @param scope {Object} the DOM element within which the routes get applied 
       @param markup {String} the html markup to add to the scope
       */
      var layoutManager = function (manager) {

          // Private variables
          var core = this;
          var handles = {};

          core.manager = manager;
          
          var counter = 0,
              moduleId,
              uniqueModuleId;

          /*if (scope === widget) {
              scope = widget.body
          }

          if (markup) {
              scope.addContent(markup);
          }*/

          // Public API
          return {
              /**
              Add routes  	
              @param {Object} newHandles
              **/
              addRoutes: function (newHandles) {
                  UWACore.extend(handles, newHandles);
                  return this;
              },

              /**
              Start the Layout Manager 
              **/
              start: function () {
                  var path,
                      elts;

                  for (path in handles) {
                      if (handles.hasOwnProperty(path)) {
                          if (scope === widget.body && path === 'widget.body') {
                              elts = [widget.body];
                              widget.body.empty();
                          }
                          else {
                              elts = scope.getElements(path);
                          }
                          
                          elts.forEach(function (elt) {
                              //ask other handlers on this component to stop
                              elt.triggerEvent('STOP_MODULES');

                              //bind the current handler for stop events
                              //TODO H9M not working yet
                              elt.addEvent('STOP_MODULES', function () {
                                  (function (handler) {
                                      handler.stop();
                                  })(handles[path]);
                              });
                              
                              // unique Id for module
                              moduleId = Object.keys(handles[path])[0];
                              uniqueModuleId = 'module-' + moduleId + '-' + (++counter);

                              //start the current handler
                              core.manager.registerModule(uniqueModuleId, handles[path][moduleId]);
                              core.manager.start(uniqueModuleId, elt);
                          });
                      }
                  }
              },
              
              autoload: function (rootNode) {
            	  var modulesToLoad = rootNode.querySelectorAll('[data-sch-module]');

            	  for (var i = 0; i < modulesToLoad.length; i++) {
            		  var node = modulesToLoad[i];
            		  
            		  // Check if module has already been mounted
            		  if (node.getAttribute('data-sch-loaded') !== '1') {
                		  var moduleId = node.getAttribute('data-sch-module');
                		  var Module = core.manager.modules[moduleId];

                		  // Check if module has specific id and if there is a config linked to the module
                		  var config;
                		  var moduleInstanceId = node.getAttribute('data-sch-module-id');
                		  if (moduleInstanceId !== null && moduleInstanceId !== '') {
                			  config = core.manager.getConfig(moduleInstanceId);
                		  }

                		  // Create the module
                		  var moduleInstance;
                		  if (config !== undefined) {
                			  moduleInstance = new Module(config);
                		  }

                		  // Render the module
                		  moduleInstance.render(node);

                		  // Tag the module as loaded
                		  node.setAttribute('data-sch-autoload', '1');
            		  }
            	  }
              }
          };

      };

      return layoutManager;
   });
