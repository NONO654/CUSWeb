[NODEDECLARATION]
SimObj : SIMObjSimulationObjectGeneric
MSRRef : SIMObjSimulationCategoryReference
MSRInst : SIMObjSimulationCategoryInstance
V5Inst : SIMObjSimulationV5RepInstanceGeneric
V5Rep : SIMObjSimulationV5RepReferenceGeneric

[NAVIGATES]
SimObj-[Owner]!>MSRInst-[InstOf]>MSRRef-[Owner]!>V5Inst-[InstOf]>V5Rep

[LINES]
V5Rep.PLMID

[COLUMNS]
V5Rep.V_discipline
