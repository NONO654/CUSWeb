(function(GLOBAL, template) {
    var chartSettingsControlPrototype = {
        is: 'ra-chartsettingscontrol',
        behaviors: [
            GLOBAL.DS.RAComponents.control
        ]
    };

/* DESCRIPTION:
 *
 * 
 *
 */

    chartSettingsControlPrototype.createdCallback = function() {
        var that = this;
        
        var clone = document.importNode(template.content, true);
        this.appendChild(clone);        
                 
    };

    chartSettingsControlPrototype.addCheckBox = function(value, label, checked){
    
        var that = this;
        var newCheckBox = document.createElement('ra-checkboxcontrol');
        
        newCheckBox.setValue(value);
        newCheckBox.setLabel(label);
        if(checked !== undefined && checked === true){
            newCheckBox.setCheck(true);
        }
        
        newCheckBox.setUpdateCallback(this.settingChanged.bind(this));
        
        this.querySelector('.controlBody').appendChild(newCheckBox);    
        return newCheckBox;

    };
    
    chartSettingsControlPrototype.addRadioButtonGroup = function(radioButtons){
    
        var that = this;
        var radioButtonGroup = document.createElement('ra-radiobuttongroupcontrol');
        radioButtons.forEach(function(radioButton){        	
        	radioButtonGroup.addRadioButton(radioButton);
        });
        
        radioButtonGroup.setUpdateCallback(this.settingChanged.bind(this));

        this.querySelector('.controlBody').appendChild(radioButtonGroup);    
        return radioButtonGroup;

    };
    
    
    chartSettingsControlPrototype.setChangeListener = function(listener) {
        this.changeListener = listener;        
        
    };
    
     chartSettingsControlPrototype.settingChanged = function(e) {
        
            if (typeof this.changeListener  === 'function') {
                this.changeListener(e);
            }
        
    };
    


    Polymer(chartSettingsControlPrototype);
    GLOBAL.DS.RAComponents.chartsettingscontrol = chartSettingsControlPrototype;
})(this, document._currentScript.parentElement.querySelector('template'));
/*
 * document.currentScript is not fully supported in IE11 and in FF the query
 * returns null (searching the widget instead of the component html)
 * document._currentScript is the polyfilled version supported by Polymer
 */
