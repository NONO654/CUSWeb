import {E6W} from './util.js';

export default class PCW {
  static createSimulation_$beforeSend (name, me, ctx) {
    // get the parameters
    const {_title='DIAGNOSTICS_PROCESS'} = me;

    const body = `{
      "datarecords": {
        "datagroups": [
          {
            "updateAction": "CREATE",
            "dataelements": {
              "title": {
                "value": [
                  {
                    "value": "${_title}"
                  }
                ]
              },
              "Simulation Kind": {
                "value": [
                  {
                    "value": "method"
                  }
                ]
              }
            }
          }
        ],
        "name": "SMA_Process"
      },
      "name": "SMA_Process"
    }`;

    me.payload = E6W.buildPayload(body);
    me.headers = E6W.buildHeaders(ctx.mcs.csrf);
  }

  static createTemplate_$beforeSend (name, me, ctx) {
    // get the parameters
    const {_sourceId='DIAGNOSTICS_PROCESS'} = me;

    const body = `{
      "datarecords": {
        "datagroups": [
          {
            "updateAction": "CREATE",
            "dataelements": {
              "sourceId": {
                "value": [
                  {
                    "value": "${_sourceId}"
                  }
                ]
              },
              "title": {
                "value": [
                  {
                    "value": "F3YTest1"
                  }
                ]
              },
              "templateView": {
                "value": [
                  {
                    "value": "Custom"
                  }
                ]
              },
              "simulationKind": {
                "value": [
                  {
                    "value": "method"
                  }
                ]
              }
            }
          }
        ],
        "name": "SMA_Template"
      },
      "name": "SMA_Template"
    }`;

    me.payload = E6W.buildPayload(body);
    me.headers = E6W.buildHeaders(ctx.mcs.csrf);
  }
  
  static createActivity_$beforeSend (name, me, ctx) {    
    // get the parameters
    const {_title='Activity', _parentId=ctx.simulation.id} = me;
    const internalId = 'Activity' + E6W.generateGUID();

    const body = `{
      "datarecords": {
        "datagroups": [
          {
            "updateAction": "CREATE",
            "dataelements": {
              "parentId": {
                "value": [{"value": "${_parentId}"}]
              },
              "title": {
                "value": [{"value": "${_title}"}]
              },
              "internalId": {
                "value": [{"value": "${internalId}"}]
              },
              "sequenceFlows": {               
                "value": [
                  {
                    "value": "{\\"Outerflow\\":[{\\"firstChildID\\":\\"${internalId}\\"},{\\"executionMode\\":\\"always\\",\\"fromFlowItemID\\":\\"${internalId}\\"}]}"
                  }
                ]
              }
            }
          }
        ],
        "name": "SMA_Activity"
      },
      "name": "SMA_Activity"
    }`;
     
    me.payload = E6W.buildPayload(body);
    me.headers = E6W.buildHeaders(ctx.mcs.csrf);
  }

  static createGateway_$beforeSend (name, me, ctx) {    
    // get the activity id
    const {_title='Gateway1', _parentId=ctx.activity.id} = me;
    const internalId = 'Gateway' + E6W.generateGUID();

    const body = `{
      "datarecords": {
        "datagroups": [
          {
            "updateAction": "CREATE",
            "dataelements": {
              "parentId": {
                "value": [{"value": "${_parentId}"}]
              },
              "title": {
                "value": [{"value": "${_title}"}]
              },
              "createAction": {
                "value": [{"value": "addAbove"}]
              }
            }
          }
        ],
        "name": "SMA_Gateway"
      },
      "name": "SMA_Gateway"
    }`;
     
    me.payload = E6W.buildPayload(body);
    me.headers = E6W.buildHeaders(ctx.mcs.csrf);
  }

  static updateStationAffinity_$beforeSend (name, me, ctx) {
    // get the list of parameters
    const {_activityId=ctx.activity.id, _Host='localhost', _cestamp=ctx.activity.cestamp} = me;

    const body = `{
      "datarecords": {
        "datagroups": [
          {
            "updateAction": "MODIFY",
            "objectId": "${_activityId}",
            "dataelements": {
              "Host": {"value": [{"value": "${_Host}"}]},
              "cestamp": {"value": [{"value": "${_cestamp}"}]}
            }
          }
        ],
        "name": "SMA_ActExeOption"
      },
      "name": "SMA_ActExeOption"
    }`;   
    
    me.payload = E6W.buildPayload(body);
    me.headers = E6W.buildHeaders(ctx.mcs.csrf);
  }

  static createParameter_$beforeSend (name, me, ctx) {    
    // get the list of parameters
    let {_id=ctx.activity.id, _name, _type='real', _mode='both', _value} = me;  

    const body = `{
      "datarecords": {
        "datagroups": [
          {
            "updateAction": "CREATE",
            "objectId": "${_id}",
            "dataelements": {
              "id": {
                "value": [
                  {
                    "value": null
                  }
                ]
              },
              "name": {
                "value": [
                  {
                    "value": "${_name}"
                  }
                ]
              },
              "type": {
                "value": [
                  {
                    "value": "${_type}"
                  }
                ]
              },
              "mode": {
                "value": [
                  {
                    "value": "${_mode}"
                  }
                ]
              },
              "AppDataKey": {
                "value": []
              },
              "AppDataValue": {
                "value": []
              },
              "AppDataIndex": {
                "value": []
              },
              "valuetype": {
                "value": [
                  {
                    "value": "single"
                  }
                ]
              },
              "Value": {
                "value": [
                  {
                    "value": "${_value}"
                  }
                ]
              },
              "cestamp": {
                "value": [
                  {
                    "value": null
                  }
                ]
              }
            }
          }
        ],
        "name": "SMA_Parameter"
      },
      "name": "SMA_Parameter"
    }`;


    me.payload = E6W.buildPayload(body);
    me.headers = E6W.buildHeaders(ctx.mcs.csrf);
  }

  static createStep_$beforeSend (name, me, ctx) {
    const stepId = 'FunctionStep' + E6W.generateGUID(); //'FunctionStepb3146e90-9d1c-4714-ab17-31f6da77a9c3';

    // get all parameters that were passed on
    const {_activityId=ctx.activity.id, _name='Calculator', 
          _extensionName='com.dassault_systemes.sma.adapter.Calculator',
          _cestamp=ctx.activity.cestamp} = me;

    const body = `{
      "datarecords": {
        "datagroups": [
          {
            "updateAction": "CREATE",
            "objectId": "${_activityId}",
            "dataelements": {
              "stepName": {
                "value": [
                  {
                    "value": "${_name}"
                  }
                ]
              },
              "extensionName": {
                "value": [
                  {
                    "value": "${_extensionName}"
                  }
                ]
              },
              "createAction": {
                "value": [
                  {
                    "value": "add"
                  }
                ]
              },
              "cestamp": {
                "value": [
                  {
                    "value": "${_cestamp}"
                  }
                ]
              },
              "StepId": {
                "value": [
                  {
                    "value": "${stepId}"
                  }
                ]
              },
              "mainStepId": {
                "value": [
                  {
                    "value": "${stepId}"
                  }
                ]
              }
            }
          }
        ],
        "name": "SMA_Step"
      },
      "name": "SMA_Step"
    }`;

    // prepare the data
    me.payload = E6W.buildPayload(body);
    me.headers = E6W.buildHeaders(ctx.mcs.csrf);
  }

  static createPath_$beforeSend (name, me, ctx) {
    // get all parameters that were passed on
    const {_simulationId=ctx.simulation.id,
      _activityId=ctx.activity.id} = me;

    const body = `{
      "datarecords": {
        "datagroups": [
          {
            "updateAction": "CREATE",
            "objectId": "${_simulationId}",
            "dataelements": {
              "pathElementsInOrder": {
                "value": [
                  {
                    "value": "${_activityId}"
                  }
                ]
              },
              "referenceId": {
                "value": [
                  {
                    "value": ""
                  }
                ]
              }
            }
          }
        ],
        "name": "SMA_Path"
      },
      "name": "SMA_Path"
    }`;

    // prepare the data
    me.payload = E6W.buildPayload(body);
    me.headers = E6W.buildHeaders(ctx.mcs.csrf);
  }

  static deletePath_$beforeSend (name, me, ctx) {
    // get all parameters that were passed on
    const {_simulationId=ctx.simulation.id,
      _referenceId=ctx.path.referenceId} = me;

    const body = `{
      "datarecords": {
        "datagroups": [
          {
            "updateAction": "DELETE",
            "objectId": "${_simulationId}",
            "dataelements": {
              "referenceId": {
                "value": [
                  {
                    "value": "${_referenceId}"
                  }
                ]
              }
            }
          }
        ],
        "name": "SMA_Path"
      },
      "name": "SMA_Path"
    }`;

    // prepare the data
    me.payload = E6W.buildPayload(body);
    me.headers = E6W.buildHeaders(ctx.mcs.csrf);
  }

  static updateCalculatorStep_$beforeSend (name, me, ctx) {
    //TODO: Step name and extension name
    // get the list of parameters
    let {_activityId, _stepId, _expression, _cestamp=ctx.activity.cestamp} = me;

    const body = `{
      "datarecords": {
        "datagroups": [
          {
            "updateAction": "MODIFY",
            "objectId": "${_activityId}",
            "dataelements": {
              "cestamp": {
                "value": [
                  {
                    "value": "${_cestamp}"
                  }
                ]
              },
              "StepId": {
                "value": [
                  {
                    "value": "${_stepId}"
                  }
                ]
              },
              "StepFlowItem": {
                "value": [
                  {
                    "value": "{\\"name\\":\\"Calculator\\",\\"xsi:type\\":\\"wfcmm:functionStepType\\",\\"description\\":null,\\"StepConfig\\":{\\"extensionName\\":\\"com.dassault_systemes.sma.adapter.Calculator\\",\\"extensionWrittenVersion\\":null,\\"extensionLoadVersion\\":null,\\"Properties\\":{\\"Property\\":[{\\"name\\":\\"expression\\",\\"valuetype\\":\\"single\\",\\"type\\":\\"string\\",\\"Value\\":{\\"<TEXT>\\":\\"${_expression}\\"}}]}},\\"id\\":\\"${_stepId}\\",\\"ExecutionConfig\\":{}}"
                  }
                ]
              }
            }
          }
        ],
        "name": "SMA_Step"
      },
      "name": "SMA_Step"
    }`;

    me.payload = E6W.buildPayload(body);
    me.headers = E6W.buildHeaders(ctx.mcs.csrf);
  }


}

