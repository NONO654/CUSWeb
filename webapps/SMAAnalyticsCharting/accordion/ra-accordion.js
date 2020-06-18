(function(global) {
    // var elementProto = Object.create(HTMLDivElement.prototype);
    var elementProto = { is: 'ra-accordionElement' };

    // var sectionProto = Object.create(HTMLDivElement.prototype);

    //==========================================
    //           Define element proto
    //==========================================

    elementProto.createdCallback = function() {
        this.data = [];
    };

    elementProto.setData = function(data) {
        this.data = data;
        this.data.state = 'shown';
        if (typeof data.title !== 'undefined') {
            this.data.title = data.title;
        }

        if (typeof data.sections !== 'undefined') {
            this.data.sections = data.sections;
        }
    };

    elementProto.addTitle = function(sectionElement) {
        var titleElement = document.querySelector(
            '#' + sectionElement.id + 'title'
        );
        if (titleElement != null) {
            return;
        }
        var titleElement = document.createElement('span');
        titleElement.textContent = this.data.title;
        titleElement.id = sectionElement.id + 'title';
        titleElement.classList.add('menuTitle');
        sectionElement.appendChild(titleElement);
    };

    // displays the given section and collapses the other sections
    elementProto.displaySection = function(sectionSelector) {
        var that = this;

        if (this.data.sections.length > 0) {
            this.data.sections.forEach(function(section) {
                if (section.contentSelector == sectionSelector) {
                    if (
                        section.element.divs.contentDiv.childElementCount === 0
                    ) {
                        section.element.hideSection();
                    } else {
                        section.element.showSection();
                    }
                } else {
                    // remove the active section
                    section.element.hideSection();
                }
            });
        }
    };

    // hide everything
    elementProto.hideSection = function(sectionSelector) {
        var that = this;
        if (this.data.sections.length > 0) {
            this.data.sections.forEach(function(section) {
                section.element.hideSection();
            });
        }
    };

    elementProto.setupSections = function() {
        var that = this;
        if (this.data.sections.length > 0) {
            this.data.sections.forEach(function(section) {
                var sectionElement = document.createElement(
                    'ra-accordionSection'
                );
                section.element = sectionElement;

                sectionElement.setData(section);
                sectionElement.id = section.contentSelector;
                sectionElement.classList.add('accordionSection');
                sectionElement.addClickCallback(function() {
                    if (sectionElement.collapsed === true) {
                        that.displaySection(section.contentSelector);
                    } else {
                        that.hideSection(section.contentSelector);
                    }
                });
                sectionElement.addElementContent();
                sectionElement.hideSection();

                that.appendChild(sectionElement);
            });
        }
    };

    // Do an initial build of the hierarchy
    elementProto.setup = function(data) {
        this.setData(data);
        // setup each section
        this.setupSections();
        // display the first section
    };

    Polymer(elementProto);

    global.DS.RAComponents.accordionElement = elementProto;
})(this);
