define('DS/ENOXDocumentPresenter/js/util/DocumentSearchUtil', [
                                                       'UWA/Core',
                                                       'UWA/Utils/InterCom'
                                                       ], function (UWA, InterCom) {
	'use strict';
	var DocumentSearchUtil = {
			initialize: function(){
				this.socketName = 'search_socket_' + (new Date()).getTime();
				this.socket = new InterCom.Socket(this.socketName, { dispatchRetryInterval: 5 });
				this.socket.subscribeServer('SearchComServer');
				this.listener = this.objectsSelected.bind(this);
				this.socket.addListener('Selected_Objects_search', this.listener);
				var options = this.options();
				this.socket.dispatchEvent('RegisterContext', options);
				return this;
			},

			options: function (title, types, role, defaultSearchCriteria, multiSel, excludeList) {
				var opts = {};
				opts.title = title;
				opts.mode = 'furtive'; // furtive means with an OK & Cancel buttons
				opts.app_socket_id = this.socketName; // name of the socket for communication
				opts.widget_id = widget.id; // our widget id
				opts.default_with_precond = true; // will use a precondition
				opts.show_precond = false; // do not show the precondition when searching
				opts.idcard_activated = false; // do not show an idcard of the object selected
				opts.multisel = UWA.is(multiSel)? multiSel : false;
				opts.role = role; // role used when performing the query
        if (types) {
        			opts.precond = '(';
            		types = types.split(',');
            		types.forEach(function (item, index) {
            			if (index !== 0) { opts.precond += ' OR ';}
            			opts.precond += 'types/' + item;
            		});
            		opts.precond +=')';
        			if (excludeList!=='' && excludeList!==undefined){
                 opts.precond += excludeList;
               }
            	}
			/*	if (defaultSearchCriteria) {
					opts.default_search_criteria = defaultSearchCriteria;
				}*/

				return (opts);
			},

			destroy: function () {
				var optionsUnregister = {};
				optionsUnregister.widget_id = widget.id;
				this.socket.dispatchEvent('unregisterSearchContext', optionsUnregister);
				this.socket.unsubscribeServer('SearchComServer');
				this.socket.removeListener('Selected_Objects_search', this.listener);
				this.socket.disconnect();
				delete this.socket;
			},

			activate: function (title, types, role, defaultSearchCriteria, bMultiSel, excludeList, callback) {
				var options = this.options(title, types, role, defaultSearchCriteria, bMultiSel, excludeList);
				/*if (!UWA.is(callback, 'function')) {
					options.mode = 'default';
				}*/
				this.callback = callback;
				//this.socket.dispatchEvent('unregisterSearchContext', { widget_id: widget.id });
				//this.socket.dispatchEvent('RegisterContext', options);
				this.socket.dispatchEvent('InContextSearch', options);
			},

			isAvailable: function () {
				return (UWA.is(this.socket));
			},

			configureSearch: function (options) {
				var that = this;
				if (!that.isAvailable()){
					that.initialize(options);
				}
			},

			launchSearch: function(options){
				var that =this;
					that.activate('Document Management',
							options.allowedTypes, options.role || ''/* role */, /* '*'+ */
							options.criteria/* +'*' */, options.multiSel, options.excludeList,
							function(results) {
					options.in_apps_callback(results);
				});
			},

			objectsSelected: function (parameters) {
				var result = [], i, len;
				if (this.callback) {
					i = 0;
					len = parameters.length;
					for (; i < len; i++) {
						result.push(parameters[i]);
					}
					this.callback(result);
				}
			}
	};
	return DocumentSearchUtil;
});
