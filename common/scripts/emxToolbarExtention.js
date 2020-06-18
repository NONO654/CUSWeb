//=================================================================
// method for adding html string or elements to existing toolbar
// author John M. Williams
// date 02/21/2006
// Version 1.0
//
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//=================================================================

//
// emxAddToToolbar takes an html element or html string as argument
//
function emxAddToToolbar(){
    var arg = arguments[0];
    switch(typeof arg){
        case "string":
            emxAddStringToToolbar(arg);
        break;
        case "object":
            emxAddObjectToToolbar(arg);
        break;
        default:
            //insert error routine
        break;
    }
}


//
// emxAddStringToToolbar takes an html string as argument
//
function emxAddStringToToolbar(arg){
    var toolbarTable = toolbars[0].element.childNodes[0];
    var rowObj = toolbarTable.rows[0];
    var newTD = document.createElement("td");
    rowObj.appendChild(newTD);
    newTD.innerHTML = arg;
};


//
// emxAddObjectToToolbar takes an html element as argument
//
function emxAddObjectToToolbar(arg){
    var toolbarTable = toolbars[0].element.childNodes[0];
    var rowObj = toolbarTable.rows[0];
    var newTD = document.createElement("td");
    rowObj.appendChild(newTD);
    newTD.appendChild(arg);
};
/*
function test(){
	// tests
	try{
		toolbars[0].element.childNodes[0];
		emxAddToToolbar("Text Only:<input type='text'/>");
		var myElement = document.createElement("select");
        myElement.options[0] = new Option('new text1','new value');
        myElement.options[1] = new Option('new text2','new value');
        myElement.options[2] = new Option('new text3','new value');
		emxAddToToolbar(myElement);
	}catch(e){
		setTimeout("test()",100);
	}
}


emxUICore.addEventHandler(window, "load", test);
*/
