/*=================================================================
 *  JavaScript Elapsed Timer
 *  emxUIElapsedTimer.js
 *  Version 1.0
 *
 *  This file contains the ElapsedTimer object which is used to get timing
 *  data for running JS code.  Currently, it only works in Firefox with
 *  Firebug extension getTopWindow().console.
 *  
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information 
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 * 
 *  static const char RCSID[] = $Id: emxUIElapsedTimer.js.rca 1.1.3.2 Wed Oct 22 15:48:05 2008 przemek Experimental przemek $
 *=================================================================
 */

var ElapsedTimer = {
    enabled: true,
    startTime: null,
    lastTimeCheck: null,
    thresholdMs: null,
	nesting:  [],

	indent: function _indent(str) {
		return "                              ".substring(0,this.nesting.length * 2) + str;
	},
	info: function _info(str) {
		if (getTopWindow().console != null) {
			if (getTopWindow().console.info) {
				getTopWindow().console.info(this.indent(str));
			} else {
				getTopWindow().console.log(this.indent("INFO: " + str));
			}
		}
	},
	warn: function _warn(str) {
		if (getTopWindow().console != null) {
			if (getTopWindow().console.warn) {
				getTopWindow().console.warn(this.indent(str));
			} else {
				getTopWindow().console.log(this.indent("WARNING: " + str));
			}
		}
	},
	log: function _log(str) {
		if (getTopWindow().console != null) {
			getTopWindow().console.log(this.indent(str));
		}
	},
	enable: function _enable() {
		this.enabled = true;
	},
	disable: function _disable() {
		this.enabled = false;
	},
    reset: function _reset(msg) {
		this.nesting = [];
		this.startTime = new Date();
		this.lastTimeCheck = this.startTime;
		if (msg != null) {
            this.info("Timer reset: " + msg);
        }
    },
    /* If a threshold is set, any incremental timing above the */
    /* threshold is output as a warning, to make it stand out  */
    setThreshold: function _setThreshold(ms) {
        this.thresholdMs = ms;
    },
    fmtSec: function _fmtSec(ms) {
        return (ms/1000) + "sec";
    },
    fmtMs: function _fmtMs(ms) {
        var out = "" + ms;
        var old;
        do {
            old = out;
            out = out.replace(/([0-9]{1,})([0-9]{3})/g, "$1,$2");
        } while (old != out);
        return out + "ms";
    },
    /* Output incremental and cumulative timing information */
    /* Incremental is since the last call to timeCheck()    */
    /* Cumulative is since last reset() (or initialization) */
    /* Optional thresholdMs overrides global threshold for  */
    /* this one timing check only.                          */
    /* Output goes to Firebug getTopWindow().console.                      */
    timeCheck: function _timeCheck(str, thresholdMs) {
    	if (!this.enabled) {
    		return;
    	}
        thresholdMs = thresholdMs ? thresholdMs : this.thresholdMs;
        if (this.lastTimeCheck == null) {
            this.reset();
        }
        var now = new Date();
        var cumulative = now.getTime() - this.startTime.getTime();
        var incremental = now.getTime() - this.lastTimeCheck.getTime();
        this.lastTimeCheck = now;
        var msg = "Timing: " + str + ": " + this.fmtMs(incremental) + " incremental; " + this.fmtMs(cumulative)+ " total";
        if (thresholdMs != null && incremental >= thresholdMs) {
            this.warn(msg);
        } else {
            this.log(msg);
        }
    },
	fn: function _fn(callee) {
		if (callee.name) {
			return callee.name; // works in FF, not IE
		}
		var fullStr = callee.toString();
		if (fullStr) {
			var name = fullStr.substr(9, fullStr.indexOf('(') - 9);
			if (name == "") {
				return "<anon>";
			}
			return name;
		} else {
			return "NULL";
		}
	},
    stack: function _stack(skipFrames) {
    	if (skipFrames == null) skipFrames = 0;
    	var up1 = arguments.callee.caller;
    	var f = up1;
    	path = [];
		try {
			do {
				if (--skipFrames < 0) {
					path.push(this.fn(f.arguments.callee));
				}
			} while (skipFrames >= -10 && (f = f.arguments.callee.caller)); // skipFrames test is necessary; seen inf loops
		} catch (e) {
			path.push('???');
		}
	    return path.reverse().join("/");
	},
	enter: function _enter(str) {
		this.timeCheck("{ ENTERING " + this.stack(1) + (str ? ": " + str : ""));
		this.nesting.push(this.lastTimeCheck);
	},
	exit: function _exit(str, thresholdMs)  {
	  try {
    	if (!this.enabled) {
    		return;
    	}
        thresholdMs = thresholdMs ? thresholdMs : this.thresholdMs;
        var now = new Date();
        var cumulative = now.getTime() - this.startTime.getTime();
		var inside = now.getTime() - this.nesting.pop().getTime();
        var incremental = now.getTime() - this.lastTimeCheck.getTime();
        this.lastTimeCheck = now;
        var msg = "} EXITING " + this.stack(1) + (str? ": " + str : "") + ": " + this.fmtMs(inside) + " INSIDE; " + this.fmtMs(incremental) + " incremental; " + this.fmtMs(cumulative)+ " total";
        if (thresholdMs != null && inside >= thresholdMs) {
            this.warn(msg);
        } else {
            this.log(msg);
        }
	  } catch (e) {this.warn(e)};
	} 
	
}
ElapsedTimer.reset();
