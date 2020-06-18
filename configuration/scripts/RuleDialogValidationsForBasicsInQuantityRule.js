
//RuleDialogValidationsForBasicsInQuantityRule.js
//Includes all the operations to be performed on Rule Dilaog Page..which may vary depending upon the Type of rule.
/*Functions included:
 * remove
 * removeFeature
 * removeFeatureOption
 * createNamedElement
 * submitRule
 * fnValidate
 */

    var vDescriptionValue = "";
    var vQuantityValue = "";
    var vRuleClassificationValue = "";
    var vVaultValue = "";
    var vRDOValue = "";
    var vRDOValueName = "";
    
	function getRuleBasics(DVValuesAddedMap,vMode)
     {
		if (vMode == "edit" || vMode == "copy"){
			
		vDescriptionValue = DVValuesAddedMap.get("description");
		document.getElementById("RuleForm").txtDescription.value = vDescriptionValue;
			
		vQuantityValue = DVValuesAddedMap.get("Quantity");
		document.getElementById("RuleForm").txtquantity.value = vQuantityValue;
		
		vVaultValue = DVValuesAddedMap.get("vault");
        document.getElementById("RuleForm").txtVaultDisplay.value = vVaultValue;
        vRDOValue = DVValuesAddedMap.get("Design Responsibility ID");
        document.getElementById("RuleForm").hDRId.value = vRDOValue;
        if(DVValuesAddedMap.get("Design Responsibility")!="null"){
           vRDOValueName = DVValuesAddedMap.get("Design Responsibility");
        }
        document.getElementById("RuleForm").txtDRDisplay.value = vRDOValueName;
        
      }
    }

	//This function is for validations  on basic fields in Create mode
	function emptyRuleExpression(vMode,vRuleType){
		
		if (vMode == "Qunatity Rule"){
			var usageQuantityField = document.getElementById("RuleForm").txtquantity;
			var usageQuantity  = usageQuantityField.value;
			
			var isAlphaNumeric = null;
			if(usageQuantity != ""){
			    isAlphaNumeric = usageQuantity.match((/[a-zA-Z]/));
			}
		    if(isAlphaNumeric){
		        alert(ALERT_MESSAGE);
		        usageQuantityField.value = "";
		        usageQuantityField.focus();
		    }else if(usageQuantity != ""){
		    	isAlphaNumeric = basicValidation('RuleForm',usageQuantityField,usageQuantityField.id,false,false,true,false,false,false,false);
		    	if(!isAlphaNumeric){
		    		 alert(ALERT_MESSAGE);
		            usageQuantityField.value = "";
		            usageQuantityField.focus();        	
		    	}    	
		    	else{
		    		if(isNaN(usageQuantity))
		    			{
		    			alert(ALERT_MESSAGE);
			            usageQuantityField.value = "";
			            usageQuantityField.focus();
		    			}
		    		if(usageQuantity <0)
	    			{
	    			alert(ALERT_MESSAGE);
		            usageQuantityField.value = "";
		            usageQuantityField.focus();
	    			}
		    	}
		    }
		}

	}

