

(function () {
	'use strict';
	var JOB_STATE, COS_RESPONSE_KEYS, ERROR_MSG, EVENT, EXECUTION_DONE;

	// All possible Job states - If Started then it is treated as Not Started and Done is treated as Completed
	JOB_STATE = {
		NotStarted: 'Not Started',
		Running: 'Running',
		Paused: 'Paused',
		Waiting: 'Waiting',
		Completed: 'Completed',
		Aborted: 'Aborted',
		Failed: 'Failed',
		Queued: 'Queued',
		Canceled: 'Canceled',
		Stopping: 'Stopping'
	};

	EXECUTION_DONE = [
		JOB_STATE.Aborted,
		JOB_STATE.Completed,
		JOB_STATE.Failed,
		JOB_STATE.Canceled];

	//Cos configuartion keys
	COS_RESPONSE_KEYS = {
		GROUP_NAME: '@groupName',
		PATH: '@path',
		RUNNING: '@nRunning',
		STATUS: '@status'
	};

	//User messages
	ERROR_MSG = {
		CONTEXT_UPDATE_FAILED: 'Unable to fetch current Job context. Please contact your system administrator'
	};

	EVENT = {
		/**
		 * Fired when `xs-wg-cos-data` changes loads data for the first time on setting object id.
		 *
		 * @event dataready
		 * @param {Object} data Current Job status for each activity/Process.
		 */
		DATAREADY: 'dataready',
		/**
		 * Fired when value changes.
		 *
		 * @event change
		 * @param {Object} data Current Job status for each activity/Process.
		 */
		CHANGE: 'change',
		/**
		 * Fired when there is any error.
		 *
		 * @event error
		 * @param {Object} error Error Message.
		 */
		ERROR: 'error'
	};

	/**
	 * `<xs-wg-cos-data>` is a UI less component to fetch data related to status of Simulation Process.
	 *
	 * In typical use, add `<xs-wg-cos-data>` in your body, pass simulation object id and get Job status for each Activity:
	 *
	 *     <body>
	 *       <xs-wg-cos-data object-id="1111.2222.3333.4444" value="{{cosvalue}}" on-change="dataChanged"></xs-wg-cos-data>
	 *
	 * listen to change event in case auto-update is set to true
	 * Default time to auto refresh is 10000 seconds, can be updated using wait property
	 *
	 * When object id changes/initialized, value property will be available after dataready event has been fired.
 	 * listen to dataready event before reading value property
	 */

	window.Polymer({
		is: 'xs-wg-cos-data',
		properties: {

			/** Simulation Object id for COS data has to be fetched */
			objectId: {
				type: String,
				notify: true,
				observer: '_objectIdChanged'
			},

			/** COS Specific data for given simulation object */
			data: {
				type: Object,
				notify: true
			},

			/** Wheather COS data has to updated automatically after give wait time */
			autoUpdate: {
				type: Boolean,
				value: false,
				notify: true
			},

			/** Wait time after which COS data will be updated */
			wait: {
				type: Number,
				value: 10000,
				notify: true
			},

			/** Is component loaded or not */
			loaded: {
				type: Boolean,
				value: false,
				notify: true
			}
		},


		detached: function(){
			this._stopPolling();
		},

		/**
		 * When object id changes, then update the value property for this object
		 * listen to dataready event before reading value property
		 * @param {String} objectId simulation object id
		 */
		_objectIdChanged: function(objectId){
			// This feature is currently LA, hence enable it using XS_RUN flag
			if (localStorage.getItem('XS_RUN') === 'true') {
				this._updateValue(objectId, true, this.autoUpdate);
				this.jobMonitor = true;
			} else {
				// Tell Data handlers that this component is done loading - in case of component not active due to LA
				this.fire(EVENT.DATAREADY, {data: undefined});
				this.loaded = true;
			}
		},

		/**
		 * Reloads data for job
		 * @param {Boolean} init update which job is currently monitored
		 */
		reloadData: function(init) {
			var changeEvent = true;
			if (init) {
				changeEvent = false;
			}
			if (localStorage.getItem('XS_RUN') === 'true') {
				this._updateValue(this.objectId, true, true, changeEvent);
			} else {
				// Tell Data handlers that this component is done loading - in case of component not active due to LA
				this.fire(EVENT.DATAREADY, {data: undefined});
				this.loaded = true;
			}
		},

		_updateValue: function(objectId, init, startpolling, fireChange) {
			// If init then set loading status to false
			if (init) { this.loaded = false; }
			this.getValue(objectId, init).then(function(value){
				// Update this.data so that it can be read via binding or using components reference
				this.data = init ? this.resetStatus(this.data) : this.data;
				this.data = this._mergeValueToData(value, this.data);

				if (startpolling && value !== undefined && this.data.status !== 'Completed') {
					this._startPolling(objectId);
				}

				//delete extra status property if any
				this.data && this.data.status && delete this.data.status;
				if (init && !fireChange) {
					this.loaded = true;
					this.fire(EVENT.DATAREADY, {data: this.data});
				} else {
					this.fire(EVENT.CHANGE, {data: this.data});
				}


			}.bind(this)).catch(function(error){
				this.fire(EVENT.ERROR, {error: error, msg: ERROR_MSG.CONTEXT_UPDATE_FAILED});
			}.bind(this));
		},

		_mergeValueToData: function(value, data) {
			//Case 1: If both are not defined the return undefined
			if (value === undefined && data === undefined) {
				return undefined;
			}

			//if value is undefined then return data (alredy been reset)
			if (value === undefined && data !== undefined) {
				return data;
			}

			// If value is something and data is undefined then return value

			if (value !== undefined && data === undefined) {
				return value;
			}

			for (var key in value) {
				if (value.hasOwnProperty(key)) {
					data[key] = value[key];
				}
			}
			return data;


		},

		getValue: function(objectId, force) {
			return new Promise(function(resolve, reject) {
				// Fetch Last running job from MCS
				this.getLatestJob(objectId, force).then(function(latestJobData){
					// Resolve state to Not Stated if no job available
					if (!latestJobData) {
						resolve(undefined);
					} else {
						this.getCurrentWorkItemsFromCOS(latestJobData.id, latestJobData.eedServerName, latestJobData.eedJobId).then(function(data){
							resolve(this.processWorkItems(latestJobData, data.workItems, data.state));
						}.bind(this)).catch(reject);
					}
				}.bind(this)).catch(reject);
			}.bind(this));
		},

		/**
		 * resets the job status for all existing data (Process or Activity) to Not Started
		 * @param {Object} value value property of this component
		 * @returns {Object} updated value object having all job status as Not Started
		 */
		resetStatus: function(value) {
			for (var key in value) {
				if (value.hasOwnProperty(key)) {
					value[key] = JOB_STATE.NotStarted;
				}
			}
			return value;
		},


		/**
		 * Fetches latest job info
		 * @param {String} objectId Simulation Object id for which jobs are to be retrieved
		 * @param {Boolean} force update the job from MCS
		 * @returns {Promise} Latest job information {jobid, eedid and eedserver name
		 */
		getLatestJob: function(objectId, force) {
			if (!force && this.latestJobPromise) {
				return this.latestJobPromise;
			}
			this.latestJobPromise =  new Promise(function(resolve, reject) {
				// Get latest job
				this.$.simulationInfo.sendRequest({
					uri: this.$.dashboard.getMcsUri() + '/resources/slmservices/simulations/filter',
					verb: 'POST',
					data: JSON.stringify([objectId]),
					onComplete : function(httprequest){
						try {
							// Return only latest execution job details
							var data = JSON.parse(httprequest.response)[0];
							if (data && data.latestExecution.eedJobId) {
							 	resolve(data.latestExecution);
							} else {
								resolve(undefined);
							}
						} catch (ex) {
							reject(ex);
						}
					},
					onError: function(httprequest){
						reject(new Error(httprequest));
					}
				});
			}.bind(this));
			return this.latestJobPromise;
		},

		/**
		 * Provides job context - which activity is currently running/paused
		 * @param {any} objectId Simulation Job object id
		 * @param {any} cosServerId Cos server name
		 * @param {any} eedJobId eed id - COS
		 * @returns {Promise} on resolve provides current jobs context
		 */
		getCurrentWorkItemsFromCOS: function(objectId, cosServerId, eedJobId) {
			return new Promise(function(resolve, reject) {
				var response, state;
				this.$.jobInfo.cosServerId = cosServerId;
				//Fires COS web service to get full summary
				this.$.jobInfo.sendRequest({
					objectId: objectId,
					uri: this.$.jobInfo.parseUri('job/' + eedJobId + '/summary/full').href,
					onComplete: function(httprequest) {
						var workItems, _workItems;
						try {
							response = JSON.parse(httprequest.response);
							if (response.JobInfo.PendingWI) {
								state = JOB_STATE.Waiting;
							} else  {
								state = response.JobInfo[COS_RESPONSE_KEYS.STATUS];
							}
							_workItems = response.JobInfo.JobSummary.WorkItemSummaries.WorkItemSummary;
							if (_workItems.toString === [].toString) {
								workItems = _workItems;
							} else {
								workItems = [];
								workItems.push(_workItems);
							}
							resolve({
								workItems: workItems,
								state: state
							});
						}
						catch (ex) {
							reject(ex);
						}
					},
					onError: function(httprequest) {
						reject(new Error(httprequest));
					}
				});
			}.bind(this));
		},

		//Stop polling if everything is done or not running
		processWorkItems: function(latestJobData, workItems, state) {
			var JOB_DATA = {}, status = JOB_STATE.NotStarted;
			workItems.forEach(function(workitem){
				var substatus = workitem.WorkItemSummaryDetails.WorkItemSummaryDetail['@status'];
				if (workitem['@type'] === 'com.dassault_systemes.sma.adapter.Task') {
					if (Number(workitem['@nWorkItems']) === Number(workitem['@nFinished'])) {
						//status can be completed / Failed / Cancelled
						if (workitem['@errorLevel'] === 'Failed') {
							status = JOB_STATE.Failed;
						} else if (workitem['@errorLevel'] === 'Canceled') {
							status = JOB_STATE.Canceled;
						} else {
							status = JOB_STATE.Completed;
						}
					} else if (state === 'Paused' && (substatus === 'Pending' || substatus === 'Running')) {
						status = 'Paused';
					} else if (state === 'Waiting' && (substatus === 'Paused Before' || substatus === 'Paused After'|| substatus === 'Running')) {
						status = 'Waiting';
					} else if (state === 'Running' && Number(workitem['@nRunning']) > 0) {
						status = 'Running';
					}
					//If this is for process then key is process1 else activity as per group name
					if (workitem[COS_RESPONSE_KEYS.GROUP_NAME] === undefined) {
						JOB_DATA.process1 = status;
					} else {
						JOB_DATA[workitem[COS_RESPONSE_KEYS.GROUP_NAME]] = status;
					}
				}
			});
			//iF job is finieshed then just stop polling - for the first time
			if (EXECUTION_DONE.indexOf(latestJobData.state) !== -1) {
				this._stopPolling();
				JOB_DATA.status = 'Completed';
				return JOB_DATA;
			} else if (!this._isCurrentJobInexecution(state)) {
				//Addition ugly check for parameter history updation
				// Check job status on MCS
				// In case job is completed then return old job status as actual completed state will
				// be given once datarefresh is called
				this._stopPolling();
				this._waitTillJobCompletedOnMCS(latestJobData.id).then(function(){
					this.fire('datarefresh');
				}.bind(this)).catch(function(error){
					this.fire('error', error);
				});
				// return old data - do not notify any on that job is completed
				return this.data ? this.data : JOB_DATA;
			}
			return JOB_DATA;
		},

		_startPolling: function(objectId){
			this._stopPolling();
			this._pollStatusInterval = setInterval(function(){
				if (this.isAttached) {
					this._updateValue(objectId, false, false);
				}
			}.bind(this), this.wait);
		},

		_stopPolling: function() {
			if (this._pollStatusInterval) {
				clearInterval(this._pollStatusInterval);
				this._pollStatusInterval = undefined;
			}
		},

		/**
		 * polls MCS every 3 second and resolves a promise when job is completed on MCS
		 * @param {String} jobObjectId JOb Object Id
		 * @returns {Promise} return a promise which resolves when job is completed on MCS
		 */
		_waitTillJobCompletedOnMCS: function(jobObjectId){
			return new Promise(function(resolve, reject) {
				this._getJobStatusFromMCS(jobObjectId, resolve, reject);
			}.bind(this));
		},


		_getJobStatusFromMCS: function(jobObjectId, onComplete, onError) {
			this.$.jobdetails.sendRequest({
				uri: this.$.dashboard.getMcsUri() + '/resources/e6w/service/SMA_JobDetails?jobId=' + jobObjectId,
				verb: 'GET',
				onComplete : function(httprequest){
					var response = JSON.parse(httprequest.response).datarecords;
					var data = response.datagroups[0].dataelements;
					if (data.status && data.status.value && data.status.value[0]) {
						var status = data.status.value[0].value;
						if (EXECUTION_DONE.indexOf(status) === -1) {
							this.async(function () {
								this._getJobStatusFromMCS(jobObjectId, onComplete, onError);
							}, 3000);
						} else {
							onComplete();
						}
					} else {
						onComplete();
					}
				}.bind(this),
				onError: function(httprequest){
					onError(httprequest);
				}
			});
		},



		/**
		 * If state is such that job is in progress then true else false
		 * @param {String} state Current job state
		 * @returns {Boolean} if passed state is valid state for COS - currently job is in progress or not
		 */
		_isCurrentJobInexecution: function(state) {
			return (state === JOB_STATE.Running
					|| state === JOB_STATE.Paused
					|| state === JOB_STATE.Waiting
					|| state === JOB_STATE.Started
					|| state === JOB_STATE.Queued
					|| state === JOB_STATE.Stopping);
		}
	});
}(this));
