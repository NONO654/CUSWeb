
//RuleDialogValidationsForBasics.js
//Includes all the operations to be performed on Rule Dilaog Page..which may vary depending upon the Type of rule.
/*Functions included:
 * insertFeatureOptions
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
			if(vMode == "edit")
			{
				vRuleClassificationValue = DVValuesAddedMap.get("Rule Classification");
				document.getElementById("RuleForm").ruleClassification.value = vRuleClassificationValue;
			}
			
			if(vMode == "copy" && !isIE)
			{
				vRuleClassificationValue = DVValuesAddedMap.get("Rule Classification");
				document.getElementById("RuleForm").ruleClassification.value = vRuleClassificationValue;
			}
		
		vDescriptionValue = DVValuesAddedMap.get("description");
		document.getElementById("RuleForm").txtDescription.value = vDescriptionValue;
		
		vErrorMessageValue = DVValuesAddedMap.get("Error Message");
		document.getElementById("RuleForm").txtErrorMsg.value = vErrorMessageValue;
		
		vComparisonOperatorValue = DVValuesAddedMap.get("Comparison Operator");
		document.getElementById("RuleForm").comparisonOperator.value = vComparisonOperatorValue;
	
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
	
	
	function emptyRuleExpression() {
		
	return true;	
	}
