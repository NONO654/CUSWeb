
//RuleDialogValidationsForBasicsInMPR.js
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
    var vVaultValue = "";
    var vRDOValue = "";
    var vRDOValueName = "";
    
	function getRuleBasics(DVValuesAddedMap,vMode)
     {
		if (vMode == "edit" || vMode == "copy"){
			
			vDescriptionValue = DVValuesAddedMap.get("description");
			document.getElementById("RuleForm").txtDescription.value = vDescriptionValue;
		
	        vRDOValue = DVValuesAddedMap.get("Design Responsibility");
	        document.getElementById("RuleForm").hDRId.value = vRDOValue;
	        if(DVValuesAddedMap.get("Design Responsibility")!="null"){
	           vRDOValueName = DVValuesAddedMap.get("Design Responsibility");
	        }
	        document.getElementById("RuleForm").txtDRDisplay.value = vRDOValueName;
        
        }
		if (vMode == "edit" ){
			vMandatoryValue = DVValuesAddedMap.get("Mandatory Rule");
			document.getElementById("RuleForm").mandatory.value = vMandatoryValue;
		}
     }

 function emptyRuleExpression(){
		return true;

	 }

