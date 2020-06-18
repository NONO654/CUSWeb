/**
 * Created by XI2 on 7/5/2015.
 */

define('DS/SMAExeCOSAdmin/Views/StationROPropertiesView', [
    'UWA/Core',
    'DS/W3DXComponents/Views/Temp/TempItemView',
    'DS/SMAExeCOSAdmin/Views/ServerForm',
    'DS/W3DXComponents/Views/Layout/ScrollView',
    'DS/W3DXComponents/IdCard',
    'DS/SMAExeCOSAdmin/Forms/COSFormUtils'
], function(
    UWACore,
    ItemView,
    ServerForm,
    ScrollView,
    IdCard,
    FormUtils
    ) {

    'use strict';
    var _name = 'station-ro-properties';


    // properties view for stations and groups
    // used by station and group's properties facet
    var StationROProperties = ItemView.extend({
        name : _name,
        tagName : 'div',
        template : function() {
            return '<div class=\'' + this.getClassNames('-subcontainer') + '\'></div>';
        },
        domEvents : {},

        init : function(options) {
            [ 'container', 'template', 'tagName', 'domEvents' ].forEach(function(propToDelete) {
                delete options[propToDelete];
            });

            this._parent(options);
        },

        setup : function() {

            this.container.addClassName(this.getClassNames('-container'));
            this._form = this._initForm();
//            this.listenTo(this.model, 'onChange', this.onModelChange);
        },

        	onModelChange:function(){
        		this._form.syncFields();
        		this.render();
        	},

        // declares fields of the view
        _initForm : function() {
            var model = this.model;
            var formOptions = {
                className : 'vertical',
                fields : function() {
      				   return FormUtils.getStationROFields(model, false, model.get('serverName'), true);
               }
            };

            var form = this.formProperties = new ServerForm(UWACore.extend({
                model:this.model
            }, formOptions));

            return form;
        },

        onRender : function() {
            var container = this.getElement('.station-ro-properties-subcontainer');

            // No render call as this is not a view
            this.formProperties.inject(container);
            container.render = function() {};
            container.container = container;
            var scrollerView = new ScrollView({
                view : container,
                useInfiniteScroll : false,
                usePullToRefresh : false
            });

            scrollerView.render().inject(this.container);
        },

        onDestroy : function() {

            if (this.formProperties) {
                this.formProperties.destroy();
                delete this.formProperties;
            }
        }
    });

    return StationROProperties;
});

