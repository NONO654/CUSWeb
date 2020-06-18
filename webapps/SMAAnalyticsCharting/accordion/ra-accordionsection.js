(function(global) {
    var sectionProto = { is: 'ra-accordionSection' };

    sectionProto.createdCallback = function(data) {
        this.data = data;

        this.divs = {};

        this.collapsed = true; // Start out collapsed
    };

    sectionProto.setData = function(data) {
        this.data = data;
    };

    sectionProto.addElementContent = function() {
        var that = this;
        var titleDiv = document.createElement('div');
        titleDiv.classList.add('accordionTitleDiv');
        titleDiv.textContent = this.data.title;
        this.appendChild(titleDiv);
        this.divs.title = titleDiv;

        // Add callback, if it exists.
        if (typeof this.clickCallback === 'function') {
            this.divs.title.addEventListener('click', this.clickCallback);
        }

        var contentDiv = document.createElement('div');
        contentDiv.classList.add('accordionContentDiv');
        this.appendChild(contentDiv);

        this.divs.contentDiv = contentDiv;
    };

    sectionProto.showSection = function() {
        this.collapsed = false;

        this.classList.add('active');
        this.divs.contentDiv.classList.remove('hidden');
        // this.addTitle();
    };

    sectionProto.hideSection = function() {
        this.collapsed = true;

        this.classList.remove('active');
        this.divs.contentDiv.classList.add('hidden');
        // this.removeTitle();
    };

    /*selectionElement.addTitle = function(){
    this.addTitle(section.element);
}

selectionElement.removeTitle = function(){
    var titleElement = this.title;
    if(titleElement !== null){
        titleElement.remove();
    }
}*/

    sectionProto.addClickCallback = function(callback) {
        this.clickCallback = callback;

        if (
            typeof this.divs.title !== 'undefined' &&
            typeof this.divs.title.addEventListener === 'function'
        ) {
            this.divs.title.addEventListener('click', callback);
        }
    };

    Polymer(sectionProto);
    global.DS.RAComponents.accordionSection = sectionProto;
})(this);
