/**
 * @fullreview KPE3 I2S 18:08:17
 */

define('DS/QualityManagerUI/SliderSpinBox', [
    'UWA/Core',
    'DS/Controls/Slider',
    'DS/Controls/SpinBox',
    'DS/Controls/TooltipModel',

    'UWA/Controls/Abstract'
], function (UWA, WUXSlider, WUXSpinBox, WUXTooltipModel) {

    'use strict';

    return UWA.Controls.Abstract.extend({
        init: function(options){

            this._parent(options);
            this.recId = options.recId || null;
            this.isExponential = options.isExponential || false;
            this.isLogarithmic = options.isLogarithmic || false;
            this.isLinear = options.isLinear || false;
            this.minValue = options.minValue;
            this.spinBoxMaxValue = options.maxValue;
            this.sliderMaxValue = this.spinBoxMaxValue;
            this.initialValue = options.initialValue;
            this.spinBoxStepValue = options.stepValue;
            this.sliderStepValue = this.spinBoxStepValue;
            this._value = this.initialValue;
            this.sliderMinValue = this.minValue;
            this.sliderInitialValue = this.initialValue;
            this.decimals = options.decimals;

            if (this.isLogarithmic || this.isExponential || this.isLinear) {
               this.sliderMaxValue = options.sliderMaxValue;
               this.sliderMinValue = options.sliderMinValue;
               this.sliderInitialValue = options.sliderInitialValue;
            }
            
            this.spinSoftLimitMax = options.spinSoftLimitMax || this.spinBoxMaxValue;
            this.spinSoftLimitMin = options.spinSoftLimitMin || this.minValue;
            this.spinHardLimitMax = options.spinHardLimitMax || this.spinBoxMaxValue;
            this.spinHardLimitMin = options.spinHardLimitMin || this.minValue;

            this.sliderSoftLimitMax = options.sliderSoftLimitMax || null;
            this.sliderSoftLimitMin = options.sliderSoftLimitMin || null;
            this.sliderHardLimitMax = options.sliderHardLimitMax || null;
            this.sliderHardLimitMin = options.sliderHardLimitMin || null;

            this.minv = this.spinSoftLimitMin;//Math.log(this.spinSoftLimitMin);
            this.maxv = this.spinSoftLimitMax;//Math.log(this.spinSoftLimitMax);
            this.scale = (Math.log(this.spinSoftLimitMax) - Math.log(this.spinSoftLimitMax)) / (this.sliderMaxValue - this.sliderMinValue);
            this.step = (this.spinSoftLimitMax - this.spinSoftLimitMin) / (this.sliderMaxValue - this.sliderMinValue);
            this.iPixels = 100;
            this.b = this._optimizeBVal(this.spinSoftLimitMin, this.spinSoftLimitMax, this.spinBoxStepValue, this.iPixels);
            this.UserEdited = false;
           
            this._createLayout();
        },
        setValue: function (value) {

            if (typeof value === 'undefined'){
                return;
            }
            if (value < this.minValue || value > this.spinBoxMaxValue){
                return;
            }
            this._value = value;

            //Update values of sliderspinbox
            if (this.isExponential || this.isLogarithmic || this.isLinear) {

                this.elements.spinBox.value = value;
                if (this.isExponential) {

                    var logvalue = Math.round(Math.log2(value));
                    this.value = Math.pow(2, logvalue);
                    this.elements.slider.value = logvalue;//Math.round(Math.log2(value));
                }
                else if (this.isLogarithmic) {
                    var logPosition = Math.round(this.iPixels * ((Math.log(value + this.b) - Math.log(this.minv + this.b)) / (Math.log(this.maxv + this.b) - Math.log(this.minv + this.b)))); //Math.round(this.sliderMinValue + (Math.log(value) - this.minv) / this.scale);
                    this.value = value;//Math.exp(((Math.log(this.maxv + this.b) - Math.log(this.minv + this.b)) * value * 0.01) + Math.log(this.minv + this.b)) - this.b; //Math.exp((logPosition - this.sliderMinValue) * this.scale + this.minv);
                    this.elements.slider.value = logPosition;//Math.round(this.sliderMinValue + (Math.log(value) - this.minv) / this.scale);
                    this.elements.spinBox.value = value;
                }
                else if (this.isLinear) {

                    var linearPosition = Math.round(this.sliderMinValue + (value - this.minValue) / this.step);
                    this.value = (((linearPosition - this.sliderMinValue) * this.step) + this.minValue);
                    this.elements.slider.value = linearPosition;//Math.round(this.sliderMinValue + (value - this.minValue) / this.step);
                    this.elements.spinBox.value = value;
                }
            }
            else {

                this.elements.spinBox.value = value;
                this.elements.slider.value = value;
            }
        },
        getValue: function(){
            return this._value;
        },
        setDisabled: function (value) {
           
            this.elements.spinBox.disabled = value;
            this.elements.slider.disabled = value;
            
        },   
        setTooltips: function (value) {
            var tooltipMdl = new WUXTooltipModel({ shortHelp: value });
            this.elements.spinBox.tooltipInfos = tooltipMdl;          
        },
        setHide: function (value) {

            this.elements.spinBox.getContent().style.display = value;
            this.elements.slider.getContent().style.display = value;
            this.elements.slider.getContent().style.height = '10px';
        },
        _createLayout: function(){
            this.elements.container = UWA.createElement('div', {Class: 'dx-slider-spinbox-container'});
            var mainContainer = UWA.Element('div', { 'class': 'wux-container' });

            var spinBoxContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
            this.elements.slider = new WUXSlider({
                minValue: this.sliderMinValue,
                maxValue: this.sliderMaxValue,
                stepValue: this.sliderStepValue,
                value: this.sliderInitialValue
            }).inject(spinBoxContainer);
            this.elements.slider.getContent().style.width = '100px';
            this.elements.slider.getContent().style.height = '10px';
            this.slider = this.elements.slider;
            var sliderContainer = new UWA.Element('div', { 'class': 'wux-control-inline-container' }).inject(mainContainer);
            this.elements.spinBox = new WUXSpinBox({
                minValue: this.minValue,
                maxValue: this.spinBoxMaxValue,
                stepValue: this.spinBoxStepValue,
                value: this.initialValue,
                decimals: this.decimals
            }).inject(sliderContainer);
            
            this.elements.spinBox.getContent().style.width = '100px';
           
            mainContainer.inject(this.elements.container);
            
        },
        
        _createEvents: function(){
            var self = this;
           
            self.elements.slider.addEventListener('change', function (event) {
               
                var newValue = event.dsModel.value;         
               
                //slider For N
                if (self.options.isExponential) {
                                       
                    newValue = Math.pow(2, newValue);
                    if (self.value === newValue) return;
                                       
                }
                else if (self.options.isLogarithmic) {
                    // Logarithmic slider
                    //Compute log value from position and assign to spinBox   
                    //
                    if (newValue >= 0 && newValue < 1 && self.recId == "PathTerminationDepth")
                    {
                        self.elements.slider.value = 0;
                        self.elements.spinBox.value = 0;
                        return;
                    }
                    if (newValue== 1 && self.recId == "PathTerminationDepth") {
                        self.elements.slider.value = 1;
                        self.elements.spinBox.value = 1;
                        return;
                    }
                    //  newValue = Math.exp((event.dsModel.value - self.sliderMinValue) * self.scale + self.minv);
                    newValue = Math.exp(((Math.log(self.maxv + self.b) - Math.log(self.minv + self.b)) * newValue * 0.01) + Math.log(self.minv + self.b)) - self.b;
                   
                    if (self.value === newValue.toFixed()) return;
                }
                else if (self.options.isLinear) {

                    // Linear slider                  
                    newValue = (((event.dsModel.value - self.sliderMinValue) * self.step) + self.minValue);
                    if (self.value === newValue) return;
                }
                if (self.value === newValue) {
                    return;
                }
                self.value = newValue;
                self.setSpinBox = true;               
                self.elements.spinBox.value = newValue;
                
            });
            self.elements.spinBox.addEventListener('change', function (event) {
                var newValue = event.dsModel.value;
                var logvalue = Math.round(Math.log2(newValue));
                
                //spinbox For N ++
                if (self.options.isExponential) {
                if (self.value === newValue) {
                    return;
                }
                    //Adjust soft/hard limits of slider
                    if (newValue < self.spinHardLimitMax && newValue > self.spinSoftLimitMax) {
                        self.elements.slider.maxValue = self.sliderHardLimitMax;
                    }
                    else {
                        self.elements.slider.maxValue = self.sliderSoftLimitMax;
                    }
                    //Increase or decrease no by clicking Up/Down button
                    if (newValue != event.dsModel.valueToCommit) {
                        if (newValue >= event.dsModel.valueToCommit) {
                            logvalue = Math.ceil(Math.log2(newValue));
                        }
                        else
                            logvalue = Math.floor(Math.log2(newValue));

                        newValue = Math.pow(2, logvalue);
                        self.value = newValue;
                        self.elements.spinBox.value = newValue;
                    }
                    else {
                        //No edited by user
                        logvalue = Math.round(Math.log2(newValue));                      
                        newValue = Math.pow(2, logvalue);
                        self.value = newValue;
                        self.elements.spinBox.value = newValue;
                    }         
                   
                    self.elements.slider.value = self._actualValueToSliderValue(logvalue);
                   
                } //spinbox For N --
                else if (self.options.isLogarithmic) {
                    // Logarithmic spinbox ++  
                    if (newValue >= 0 && newValue < 1 && self.recId == "PathTerminationDepth") {
                       
                        self.elements.spinBox.value = 0;
                        self.elements.slider.value = 0;
                        return;
                    }
                    if (newValue != event.dsModel.valueToCommit) {
                        self.UserEdited = false;
                    }
                    else
                    {
                        self.UserEdited = true;
                    }

                    //Adjust soft/hard limits of slider
                    var adjVal = newValue.toFixed();
                    
                    if (self.UserEdited) {
                        if (adjVal <= self.spinHardLimitMax && adjVal > self.spinSoftLimitMax || newValue >= self.spinHardLimitMin && newValue < self.spinSoftLimitMin) {

                           // self.minv = Math.log(self.spinHardLimitMin);
                            self.minv = self.spinHardLimitMin;
                            self.b = self._optimizeBVal(self.spinHardLimitMin, self.spinHardLimitMax, self.spinBoxStepValue, self.iPixels);
                            self.maxv = self.spinHardLimitMax;
                           // self.scale = (Math.log(self.spinHardLimitMax) - Math.log(self.spinHardLimitMin)) / (self.sliderMaxValue - self.sliderMinValue);
                        }
                        else {

                           // self.minv = Math.log(self.spinSoftLimitMin);
                            self.minv = self.spinSoftLimitMin;
                            self.b = self._optimizeBVal(self.spinSoftLimitMin, self.spinSoftLimitMax, self.spinBoxStepValue, self.iPixels);
                            self.maxv = self.spinSoftLimitMax;
                          //  self.scale = (Math.log(self.spinSoftLimitMax) - Math.log(self.spinSoftLimitMin)) / (self.sliderMaxValue - self.sliderMinValue);
                        }
                    }
                    else {
                        self.UserEdited = false;
                    }
                                      
                    //Compute position value from value and assign to slider

                    //   var logPosition =  Math.round(self.sliderMinValue + (Math.log(event.dsModel.valueToCommit) - self.minv) / self.scale);   
                    // self.value = Math.exp((logPosition - self.sliderMinValue) * self.scale + self.minv);
                    var logPosition = Math.round(self.iPixels * ((Math.log(newValue + self.b) - Math.log(self.minv + self.b)) / (Math.log(self.maxv + self.b) - Math.log(self.minv + self.b))));
                    self.value = Math.exp(((Math.log(self.maxv + self.b) - Math.log(self.minv + self.b)) * logPosition * 0.01) + Math.log(self.minv + self.b)) - self.b;                
                                      
                    if (self.value === newValue) {
                        return;
                    }
                    
                    self.elements.slider.value = logPosition;
                    //  Logarithmic spinbox --
                }
                else if (self.options.isLinear) {
                    // Linear spinbox ++
                    if (newValue != event.dsModel.valueToCommit) {
                        self.UserEdited = false;
                    }
                    else {
                        self.UserEdited = true;
                    }
                    if (self.UserEdited) {
                        if (newValue <= self.spinHardLimitMax && newValue > self.spinSoftLimitMax || newValue >= self.spinHardLimitMin && newValue < self.spinSoftLimitMin) {

                            self.minValue = self.spinHardLimitMin;
                            self.step = (self.spinHardLimitMax - self.spinHardLimitMin) / (self.sliderMaxValue - self.sliderMinValue);
                        }
                        else {

                            self.minValue = self.spinSoftLimitMin;
                            self.step = (self.spinSoftLimitMax - self.spinSoftLimitMin) / (self.sliderMaxValue - self.sliderMinValue);
                        }
                    }

                    
                    var linearPosition = Math.round(self.sliderMinValue + (event.dsModel.valueToCommit - self.minValue) / self.step);
                    self.value = (((linearPosition - self.sliderMinValue) * self.step) + self.minValue);
                    if (self.value === newValue) {
                        return;
                    }

                  
                    self.elements.slider.value = linearPosition;
                    //  Linear spinbox --
                }
                else {                     
                    self.value = newValue;
                    if (self.value === newValue) {
                        return;
                    }
                    self.elements.slider.value = self._actualValueToSliderValue(self.value);
                }
              
            });
                  
        },


        _optimizeBVal:function(iMin,iMax,iStep,iPixels)
        {
            var currMin = iMin;
            var currMax = iMax;
            var currBVal = 0.5*(currMin+currMax);

            var currMinStep = iPixels * (Math.log(iMin + iStep + currMin) - Math.log(iMin + currMin)) / (Math.log(iMax + currMin)- Math.log(iMin + currMin));
            var currMaxStep = iPixels * (Math.log(iMin + iStep + currMax) - Math.log(iMin + currMax)) / (Math.log(iMax + currMax) - Math.log(iMin + currMax));
            var currBStep = iPixels * (Math.log(iMin + iStep + currBVal) - Math.log(iMin + currBVal)) / (Math.log(iMax + currBVal) - Math.log(iMin + currBVal));

            for (var i = 0; i < 20; i++)
            {
                if(currBStep < 1.0 ){

                    currMax = currBVal;
                    currMaxStep = currBStep;
                }
                else {
                    currMin = currBVal;
                    currMinStep = currBStep;
                }
                currBVal = 0.5 * (currMin + currMax);
                currBStep = iPixels * (Math.log(currMin + iStep + currBVal) - Math.log(currMin + currBVal)) / (Math.log(currMax + currBVal) - Math.log(currMin + currBVal));
            }

            return currBVal;
        },
        _sliderValueToActualValue: function (value) {
            return value;
        },
        _actualValueToSliderValue: function(value){
            return value;
        }
    });
});
