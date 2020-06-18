
//RuleDialogValidationsForBasicsInPCR.js
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
    var vRDO = "";
    
	function getRuleBasics(DVValuesAddedMap,vMode)
     {
		if (vMode == "edit"){
		vDescriptionValue = DVValuesAddedMap.get("description");
		document.getElementById("RuleForm").txtDescription.value = vDescriptionValue;

		vComparisonOperatorValue = DVValuesAddedMap.get("Comparison Operator");
        document.getElementById("RuleForm").comparisonOperator.value = vComparisonOperatorValue;
        
        vCompatibilityOptionValue = DVValuesAddedMap.get("Compatibility Option");
        document.getElementById("RuleForm").compType.value = vCompatibilityOptionValue;
      
        }
     }

	function emptyRuleExpression(){

	}

