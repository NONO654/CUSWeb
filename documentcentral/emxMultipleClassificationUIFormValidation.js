//=================================================================
// JavaScript File - emxMultipleClassificationUIFormValidation.js
//
// Copyright (c) 1992-2016 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
// static const char RCSID[] = $Id: emxMultipleClassificationUIFormValidation.js.rca 1.6 Wed Oct 22 16:54:24 2008 przemek Experimental przemek $
//=================================================================


// Periodically check whether elements to propagate have changed
// their value since the last check
function checkAndPropagate() {
  for (var i=0; i<document.propagateElems.length; i++) {
    var elem = document.propagateElems[i];
    if (hasChanged(elem)) {
      elem.mcmonchange();
    }
  }
  setTimeout("checkAndPropagate()", 200);
}

// Compares current state with stored previous state
function hasChanged(elem) {
  return elem.value != elem.prevValue;
}

// Test whether the element is a dynamic attribute,
// If so, return its base name, stripping out the prefix.
// Else return null.
function getBaseName(elem) {
  var match = elem.name.match(/^#[0-9]+,(.*)/);
  return (match == null ? elem.name : match[1]);
}

// Loop over our elements of interest; for those that
// are replicates of this, update their state to match
// this.
function propagate() {
  var baseName = getBaseName(this);
  var elems = document.propagateElems;
  for (var elemNum = 0; elemNum < elems.length; elemNum++) {
    var elem = elems[elemNum];
    if (getBaseName(elem) == baseName) {
      elem.value = this.value;
      elem.prevValue = elem.value;
    }
  }
}

// Find all form elements that represent the replicated attribute,
// and perform some surgery on them.  Add an onchange handler
// (of sorts) to propagate value changes as needed, and also
// add some explanatory hint text below the field.
function modifyRedundantFields() {
  // Keep track of the elements that we mess with
  document.propagateElems = new Array();
  var form = document.forms[0];
  var n = 0;
  for (var elemNum=0; elemNum<form.length; elemNum++){
    var elem = form[elemNum];
    var baseName = getBaseName(elem);
    if (baseName != null) {
      // if there are any dupes, one of them is definitely #2
      var firstDup = '#2,' + baseName;
      if (firstDup in form && elem.type != 'hidden') {
        document.propagateElems[n++] = elem;
        elem.prevValue = elem.value;

        // Set the onchange, sort of.
        // The JS onchange does not respond to programmatic value changes,
        // such as by calendar widget, so roll our own onchange.
        elem.mcmonchange = propagate;

        // Add the hint text by inserting it into the DOM
        var container = elem.parentNode;  // the TD, I hope...
        var br = document.createElement('br');
        var span = document.createElement('span');
        span.setAttribute('class', 'hint');      
        // There's probably a more 'correct' way to do i18n in js...
        var text = document.createTextNode(document.emxRedundantAttrsHintStr);
        span.appendChild(text);
        container.appendChild(br);
        container.appendChild(span);
      }
    }
  }
  // Our mcmonchange monitors value changes via this timeout
  setTimeout("checkAndPropagate()", 200);
}

