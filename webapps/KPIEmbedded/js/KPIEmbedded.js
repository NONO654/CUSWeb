define('DS/KPIEmbedded/js/KPIEmbedded', [
    'DS/Handlebars/Handlebars',
    'UWA/Class/View',
    'text!DS/KPIEmbedded/html/KPIEmbeddedBase.html',
    'text!DS/KPIEmbedded/html/KPIEmbeddedMain.html',
    'text!DS/KPIEmbedded/html/KPIEmbeddedDetails.html',
    'css!DS/KPIEmbedded/css/KPIEmbedded.css'
], function (Handlebars, View, BaseTemplate, MainTemplate, DetailsTemplate) {
    'use strict';

    var KPIEmbedded = View.extend({

        name: 'x-app-kpi-embedded-view',
        state: 0,
        currentKpiIdx: null,

        className: function () {
            return this.getClassNames('-container');
        },

        setup: function () {
            var that = this;
            that.kpiCockpit = that.options.kpiCockpit;

            // Compile Handlebars templating functions
            that.baseTemplate = Handlebars.compile(BaseTemplate);
            that.mainTemplate = Handlebars.compile(MainTemplate);
            that.detailsTemplate = Handlebars.compile(DetailsTemplate);

            // For each KPIs...
            that.kpiCockpit.kpis.forEach(function (kpi) {
                // Create label based on value and units (if available)
                kpi.label = kpi.value;
                if (kpi.units !== undefined) {
                    kpi.label += ' ' + kpi.units;
                }

                // Determine if objective is achieved for each passed kpi
                kpi.objectiveNotAchieved = (kpi.comparison === 'gt' && kpi.value < kpi.objective) || (kpi.comparison === 'lt' && kpi.value > kpi.objective);
            });
        },

        render: function () {
            var that = this;
            that.open = false;

            // At first render, that Global Scoring view
            that.container.setHTML(that.baseTemplate({
                value: that.kpiCockpit.globalScoringValue + '<span class="to-hide-when-minified"> / ' + that.kpiCockpit.globalScoringTarget + '</span>',
                name: 'GLOBAL SCORING',
                clickable: true
            }));
            var globalScoringElt = that.container.getElement('.kpi-outer');

            globalScoringElt.addEventListener('click', function () {
                if (that.open) {
                    that.container.getElements('.kpi-main-view, .kpi-details-view').forEach(function (el) {
                        el.destroy();
                    });
                    that.open = false;
                } else {
                    if (that.state === 2 && that.currentKpiIdx !== null) {
                        that.switchToDetailsView(that.currentKpiIdx);
                    } else {
                        that.switchToMainView();
                    }
                    that.open = true;
                }
            });

            return that;
        },

        switchToMainView: function () {
            var that = this;
            that.state = 1;

            var newElt = document.createElement('div');
            newElt.innerHTML = that.mainTemplate({
                globalScore: that.kpiCockpit.globalScoringValue + '<span class="to-hide-when-minified"> / ' + that.kpiCockpit.globalScoringTarget + '</span>',
                kpis: that.kpiCockpit.kpis
            });
            that.container.appendChild(newElt.firstChild);

            // Create listeners
            that.container.getElements('.kpi-infos').forEach(function (elt) {
                elt.addEventListener('click', function () {
                    that.switchToDetailsView(elt.getAttribute('data-kpi-idx'));
                });
            });

            that.container.getElement('.close-icon').addEventListener('click', function () {
                that.open = false;
                that.container.getElement('.kpi-main-view').destroy();
            });

            // Update label in base element
            that.container.getElement('.kpi-outer .kpi-value').innerHTML = that.kpiCockpit.globalScoringValue + '<span class="to-hide-when-minified"> / ' + that.kpiCockpit.globalScoringTarget + '</span>',
            that.container.getElement('.kpi-outer .kpi-name').textContent = 'GLOBAL SCORING';
            that.container.getElement('.kpi-outer .kpi-value').removeClassName('kpi-not-achieved');
        },

        switchToDetailsView: function (kpiIdx) {
            var that = this;
            that.state = 2;
            that.currentKpiIdx = kpiIdx;

            var kpi = that.kpiCockpit.kpis[kpiIdx];

            // Remove main view
            var oldMainView = that.container.getElement('.kpi-main-view');
            if (oldMainView !== null) {
                oldMainView.destroy();
            }

            // Create details view
            var newElt = document.createElement('div');
            newElt.innerHTML = that.detailsTemplate({
                label: kpi.label,
                name: kpi.name,
                objective: kpi.objective,
                objectiveNotAchieved: kpi.objectiveNotAchieved,
                addMoreInfos: (kpi.name === 'Interferences')
            });
            that.container.appendChild(newElt.firstChild);

            // Create listeners
            that.container.getElement('.close-icon').addEventListener('click', function () {
                that.open = false;
                that.container.getElement('.kpi-details-view').destroy();
            });
            that.container.getElement('.return-icon').addEventListener('click', function () {
                that.container.getElement('.kpi-details-view').destroy();
                that.switchToMainView();
            });
            that.container.getElement('[data-kpi-objective]').addEventListener('click', function () {
                //TransientWidget.showWidget(widgetBTDUrl, 'Business Target Definition');
            });
            that.container.getElement('[data-open-more-infos]').addEventListener('click', function () {
                /*if (kpi.name === 'Weight') {
                    TransientWidget.showWidget(widgetBVAUrl, 'Weight and Balance');
                } else {
                    TransientWidget.showWidget(widgetBVAUrl, 'Business Value Assessment');
                }*/
            });

            that.container.appendChild(newElt.firstChild);

            // Update label in base element
            that.container.getElement('.kpi-outer .kpi-value').textContent = kpi.label;
            that.container.getElement('.kpi-outer .kpi-name').textContent = kpi.name;
            if (kpi.objectiveNotAchieved) {
                that.container.getElement('.kpi-outer .kpi-value').addClassName('kpi-not-achieved');
            }
        }
    });

    return KPIEmbedded;
});
