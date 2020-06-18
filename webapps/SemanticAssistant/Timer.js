/**
 * 
 */
define('DS/SemanticAssistant/Timer', [
	'DS/TraceableRequirementsUtils/jQuery',
	'UWA/Class',
	'UWA/Class/Timed'
],
function(jQuery,
		 Class,
		 Timed) {
	'use strict';
	
	var defaultIntervall = 2000;
	
	var Timer = Class.extend(Timed, {
		
		running: false,
		
		intervall: undefined,
		
		callback: undefined,
		
		timer: undefined,
	
		init: function(intervall, callback, argument) {
			this.running = false;
			this.intervall = intervall;
			this.callback = callback;
			this.argument = argument || '';
		},
		
		start: function() {
			if (this.hasDelayed('timer')) {
				this.clearDelayed('timer');
			}
			this.running = true;
			this.setDelayed('timer', this.end, this.intervall);
		},
		
		end: function() {
			if (this.hasDelayed('timer')) {
				this.clearDelayed('timer');
			}
			
			this.running = false;
			this.timer = undefined;
			console.log('Timer triggers SAW Quality Check');
			this.callback(this.argument);
		},
		
		check: function() {
			this.start();
		},
		
		setIntervall: function(ms) {
			if(UWA.is(ms, 'number') && ms > 0) {
				this.intervall = ms;
			}
		}
		
	});
	
	return Timer;
	
});
