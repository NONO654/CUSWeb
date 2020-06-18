define('DS/ENOXCAD_Save/views/XCAD_SetDerivedOutputView', [ 
	// -- Module Dependencies --
	'UWA/Core', 
	'DS/Core/Core', 
	'DS/ApplicationFrame/ContextualUIManager', 
	'DS/WebappsUtils/WebappsUtils', 
	'DS/Utilities/Dom', 
    'DS/Controls/Button',
    'DS/Controls/ButtonGroup',
    'DS/Windows/Dialog',
	'DS/ENOXCAD_Save/controllers/XCAD_InteractionsWEB_CAD',
	'DS/Controls/Toggle'
], 
function(UWACore, WUXCore, ContextualUIManager, WebappsUtils, DomUtils, WUXButton, WUXButtonGroup,WUXDialog,XCAD_InteractionsWEB_CAD, WUXToggle) {
	'use strict';
	
	/* derivedOutputs = [{
			name : 'derived outputs name',
			checked : true/false,
			mixedState : true/false
		},
		...]
	*/
	return function(derivedOutputs) {
		var containerCheckboxLabel = new UWA.Element('div', { 'class': 'wux-control-inline-container', style: { 'vertical-align': 'top' } });
		//containerCheckboxLabel.inject(mainContainer);

		var h = document.createElement('h1');                // Create a <h1> element
		var t3 = document.createTextNode('Checkbox values : ');     // Create a text node
		h.appendChild(t3);                                   // Append the text to <h1>
		containerCheckboxLabel.appendChild(h);

		//new UWA.Element('br').inject(mainContainer);

		var containerCheckbox = new UWA.Element('div', { 'class': 'wux-control-inline-container', style: { 'vertical-align': 'top' } });
		//containerCheckbox.inject(mainContainer);

		var buttonGroup3 = new WUXButtonGroup({ type: 'checkbox' });
		buttonGroup3.inject(containerCheckbox);
		for (var i in derivedOutputs) {
			var DO = derivedOutputs[i];
			buttonGroup3.addChild(new WUXToggle({ 
				type: 'checkbox', 
				label: DO.name, 
				checkFlag: DO.icon != "I_UPSUnChecked",			
			    mixedState: DO.icon == "I_UPSPartialCheck",
			    value: 'carots' 
			   }));
		}
		
		buttonGroup3.addEventListener('change', function onChange(e) {
		  t3.textContent = 'Checkbox values : ' + e.dsModel.value.toString();
		});
		
		var DOdialog = new WUXDialog({
			   title: 'Derived Outputs',
			   modalFlag : true,
			   content: containerCheckbox,
			   immersiveFrame: widget.XCAD_MainController.myImmersiveFrame,
			   buttons: {
			       Cancel: new WUXButton({
			           onClick: function (e) {
			               var button = e.dsModel;
			               var myDialog = button.dialog;
			               console.log('on Cancel button : dialog title = ' + myDialog.title);	
			               myDialog.close();
			           }
			       }),
			       Ok: new WUXButton({
			           onClick: function (e) {
			               var button = e.dsModel;
			               var myDialog = button.dialog;
			               var CheckboxesList=buttonGroup3.elements.container.getChildren();
			               var derivedOutputs_Icon_Dico = [];
			       		for (var i in CheckboxesList) {
			       			var toogle = CheckboxesList[i].dsModel;
			       			
			       			var icon = "";
			       			if (toogle.checkFlag == false)
			       				icon = "I_UPSUnChecked";
			       			else if (toogle.mixedState == true)
			       				icon = "I_UPSPartialCheck";
			       			else
			       				icon = "I_UPSCheckBox";
			       					
			       			derivedOutputs_Icon_Dico.push({
			       				name: toogle.label, 
			       				icon: icon
			       			});
			       		}
			               console.log('on OK button : On Ok Derived outputs = ' + buttonGroup3.value);
			               widget.XCAD_MainController.onSetDerivedOutputOk(derivedOutputs_Icon_Dico);
			               myDialog.close();			               
			           }
			       })
			   }
			});
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		// 1) Create Main view (ENOUPSSetDerivedOutputView)
		/*var ENOUPSSetDerivedOutputView = UWACore.createElement('div', {
            styles: {
                height: '100%',
	        	width: '100%',
            	overflow: 'auto'
            }
        });





        // 2) create the table
		// 		2.1) create table head
		var table = UWA.createElement('table', {
			class: 'table table-bordered table-striped',
            styles: {
            	marginTop : '30px',
            	marginBottom : '80px',
            }
		});
		table.inject(ENOUPSSetDerivedOutputView);

		var colgroup = UWA.createElement('colgroup', {
		    html: '	<col style="width: 67%;"> \
		    		<col style="width: 33%;">'
		});
		colgroup.inject(table);	    

		var thead = UWA.createElement('thead', {
			html: '	<tr style="font-weight: bold; font-style: italic; text-align: center;"> \
						<th>Derived Output</th> \
						<th>Automatic</th> \
					</tr> '
		});
		thead.inject(table);

		// 		2.2) create table body
		var tbody = UWA.createElement('tbody');
		tbody.inject(table);
		
		var listToggles = [];
		for (var i in derivedOutputs) {
			var DO = derivedOutputs[i];
			
			var row = UWA.createElement('tr');
			row.inject(tbody);
	
			var thLabel = UWA.createElement('th', {
			    html: DO.name
			});
			thLabel.inject(row);
			
			var thIcon = UWA.createElement('th');
			thIcon.inject(row);
			
			var toggle = new WUXToggle({
			    label: "",
			    checkFlag: DO.icon != "I_UPSUnChecked",
			    mixedState: DO.icon == "I_UPSPartialCheck",
			});
			toggle.derivedOutputName = DO.name;// value not set in "label" because should not be display
			toggle.inject(thIcon);
			listToggles.push(toggle);
		}
        
        
		
		
		
		
		
		
		// 4) Create footer 
        var footerDiv = UWACore.createElement('div', {
            'class': 'ENOUPSNewFileNameView_footer'
        });
        footerDiv.inject(ENOUPSSetDerivedOutputView);



        // 5) Create and insert buttons OK in footer
        var okButton = new WUXButton({
            label: 'OK', // TODO: nls
            emphasize: 'primary',
            touchMode: true
        });
        okButton.inject(footerDiv);
        okButton.addEventListener('click', function() {
        	var derivedOutputs_Icon_Dico = [];
    		for (var i in listToggles) {
    			var toogle = listToggles[i];
    			
    			var icon = "";
    			if (toogle.checkFlag == false)
    				icon = "I_UPSUnChecked";
    			else if (toogle.mixedState == true)
    				icon = "I_UPSPartialCheck";
    			else
    				icon = "I_UPSCheckBox";
    					
    			derivedOutputs_Icon_Dico.push({
    				name: toogle.derivedOutputName, 
    				icon: icon
    			});
    		}

            widget.XCAD_MainController.onSetDerivedOutputOk(derivedOutputs_Icon_Dico);
        });

        

        // 6) Create and insert buttons Cancel in footer
        var cancelButton = new WUXButton({
            label: 'Cancel',// TODO : nls
            touchMode: true
        });
        cancelButton.addEventListener('click', function() {
            widget.XCAD_MainController.hideLeftSidePanel();
        });
        cancelButton.inject(footerDiv);*/
        
        return ENOUPSSetDerivedOutputView;
	};

});
