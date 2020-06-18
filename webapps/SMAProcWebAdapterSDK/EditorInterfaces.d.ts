// Those values are static properties of DtVariable, which typescript cannot declare on the DtVariable interface
export interface Variable {
    /** Beware the actual value will change to match the executor */
    readonly STRUCT_SCALAR:0
    /** Beware the actual value will change to match the executor */
    readonly STRUCT_ARRAY:1
    /** Beware the actual value will change to match the executor */
    readonly STRUCT_AGGREGATE:2
    /** Beware the actual value will change to match the executor */
    readonly STRUCT_UNKNOWN:3

    readonly ROLE_UNKNOWN:0
    readonly ROLE_PARAMETER:1
    readonly ROLE_PROPERTY:2

    /** Beware the actual value will change to match the executor */
    readonly MODE_INPUT:0
    /** Beware the actual value will change to match the executor */
    readonly MODE_OUTPUT:1
    /** Beware the actual value will change to match the executor */
    readonly MODE_INOUT:2
    /** Beware the actual value will change to match the executor */
    readonly MODE_LOCAL:3
}
export interface DtVariable { 
    /** variable name */ getName(): string
    setName(name: string): void
    getDisplayName(): string

    /** Structure must be set before any other property of the variable */
    setStructure(structure: Variable['STRUCT_SCALAR'] | Variable['STRUCT_ARRAY'] | Variable['STRUCT_AGGREGATE']): void
    getStructure(): Variable['STRUCT_SCALAR'] | Variable['STRUCT_ARRAY'] | Variable['STRUCT_AGGREGATE'] | Variable['STRUCT_UNKNOWN']

    /** Returns true if this is a parameter */ isParameter(): boolean
    /** Returns true if this is a property */ isProperty(): boolean

    setMode(mode: Variable['MODE_INPUT'] | Variable['MODE_OUTPUT'] | Variable['MODE_INOUT'] | Variable['MODE_LOCAL']): void
    getMode(): Variable['MODE_INPUT'] | Variable['MODE_OUTPUT'] | Variable['MODE_INOUT'] | Variable['MODE_LOCAL']

    /** DataType has to be set before value */
    setDataType(mode: number): void
    getDataType(): number
    
}



export interface DtScalarVariable {
    setExpression(expression: string): void
    getExpression(): string

    setValue(value: any): void
    getValue(): any
}

export interface DtArrayVariable {
    setSizable(sizable: boolean): void
    isSizable(): boolean

    /**
     * Dimensions of 3 dimensional array of dimension [3,4,5],
     * can be specified as [3, 4, 5] or as a string in the form '[3, 4, 5]' or '[3][4][5]'
     */
    setDimensions(dimensions: number[]|string): void
    getDimensions(): number[]
    getDimensionAsString(): string
    // resize()

    setValues(values: Array<any>): void
    getValues(): Array<any>

    setValue(value: any, index: number[]|string): void
    getValue(index: number[]|string): any
}


export interface DataContainer {
    getName(): string
    getParameters(): DtVariable[]
    findParameterByName(name: string): DtVariable
    addParameter(parameter: DtVariable)
    removeParameter(parameter: DtVariable)

}
export interface Step {}
export interface ExtensionDescriptor {
    getPropertyByName(name: string): DtVariable
    getProperties(): DtVariable[]
    // getPluginConfigurations(): Array<any>
}
export interface ExtensionEditor {
    /**
     * Called upon opening the editor
     */
    UpdateUI(
        container: DataContainer, // content, parameter
        step: Step, // properties
        descriptor: ExtensionDescriptor // adapter schema
    ): void;

    /** Called to save data from the editor */
    Apply(): void
}
/**
 * Define an adapter editor
 * This is a custom element which will be loaded through HTML import
 * and instantiated using the descriptor information.
 */
export interface AdapterEditor extends HTMLElement {
    ExtensionEditorImpl: ExtensionEditor
}
// From 3DOrchestrate ADK
export interface DtComponent {
    addParameter(p: DtVariable)
    // removeParameter(p: DtVariable)
    // List<DtVariable> getParameterList
    // getParameter(String name)
    // getParameterByTag(String tag)
    // hasParameter(String name)
    // hasParameterByTag(String tag)
    // same with Property
    // Variable getProperty(String name)
    // Variable getPropertyByTag(String tag)
    // ScalarVariable getScalarProperty(String name)
    // ScalarVariable getScalarPropertyByTag(String tag)
    // ArrayVariable getArrayProperty(String name)
    // ArrayVariable getArrayPropertyByTag(String tag)
    // AggregateVariable getAggregateProperty(String name)
    // AggregateVariable getAggregatePropertyByTag(String tag)
    // VariableCollection getPropertyVarList()
    // boolean hasProperty(String propertyName)
    // boolean hasPropertyByTag(String propertyTag)
    // HashMap getPluginList()
    // Plugin getPlugin(String name)
    // no notion of content
    // DtVariable getVariableInRole(String name, int role)
}
