/*

Ext Gantt 2.2.23
Copyright(c) 2009-2014 Bryntum AB
http://bryntum.com/contact
http://bryntum.com/license

*/
Ext.define('Gnt.locale.It', {
    extend      : 'Sch.locale.Locale',
    requires    : 'Sch.locale.It',
    singleton   : true,

    l10n        : {
        'Gnt.util.DurationParser' : {
            unitsRegex : {
                MILLI       : /^ms$|^mil/i,
                SECOND      : /^s$|^sec/i,
                MINUTE      : /^m$|^min/i,
                HOUR        : /^o$|^ora|^ore/i,
                DAY         : /^g$|^giorn/i,
                WEEK        : /^s$|^sett|^settimana/i,
                MONTH       : /^mese|^mesi/i,
                QUARTER     : /^t$|^tri|^trimestr/i,
                YEAR        : /^a$|^an|^anno/i
            }
        },

        'Gnt.util.DependencyParser' : {
            typeText    : {
                SS  : 'II',
                SF  : 'IF',
                FS  : 'FI',
                FF  : 'FF'
            }
        },

        'Gnt.field.Duration' : {
            invalidText : 'Valore durata non valido'
        },

        'Gnt.feature.DependencyDragDrop' : {
            fromText    : 'Da',
            toText      : 'A',
            startText   : 'Inizio',
            endText     : 'Fine'
        },

        'Gnt.Tooltip' : {
            startText       : 'Inizio: ',
            endText         : 'Fine: ',
            durationText    : 'Durata: '
        },

        'Gnt.plugin.TaskContextMenu' : {
            taskInformation     : 'Informazioni attività...',
            newTaskText         : 'Nuova attività',
            deleteTask          : 'Elimina attività',
            editLeftLabel       : 'Modifica etichetta sinistra',
            editRightLabel      : 'Modifica etichetta destra',
            add                 : 'Aggiungi...',
            deleteDependency    : 'Elimina dipendenza...',
            addTaskAbove        : 'Attività precedente',
            addTaskBelow        : 'Attività seguente',
            addMilestone        : 'Milestone',
            addSubtask          : 'Sotto-attività',
            addSuccessor        : 'Successore',
            addPredecessor      : 'Predecessore',
            convertToMilestone  : 'Converti in milestone',
            convertToRegular    : 'Converti in attività normale'
        },

        'Gnt.plugin.DependencyEditor' : {
            fromText            : 'Da',
            toText              : 'A',
            typeText            : 'Tipo',
            lagText             : 'Lag',
            endToStartText      : 'Fine-a-Inizio',
            startToStartText    : 'Inizio-a-Inizio',
            endToEndText        : 'Fine-a-Fine',
            startToEndText      : 'Inizio-a-Fine'
        },

        'Gnt.widget.calendar.Calendar' : {
            dayOverrideNameHeaderText : 'Nome',
            overrideName        : 'Nome',
            startDate           : 'Data Inizio',
            endDate             : 'Data Fine',
            error               : 'Errore',
            dateText            : 'Data',
            addText             : 'Aggiungi',
            editText            : 'Modifica',
            removeText          : 'Rimuovi',
            workingDayText      : 'Giorni lavorativi',
            weekendsText        : 'Fine settimana',
            overriddenDayText   : 'Giorno escluso',
            overriddenWeekText  : 'Settimana esclusa',
            workingTimeText     : 'Orario lavorativo',
            nonworkingTimeText  : 'Orario non lavorativo',
            dayOverridesText    : 'Giorno escluso',
            weekOverridesText   : 'Settimana esclusa',
            okText              : 'OK',
            cancelText          : 'Annulla',
            parentCalendarText  : 'Calendario padre',
            noParentText        : 'Nessun padre',
            selectParentText    : 'Seleziona padre',
            newDayName          : '[Senza nome]',
            calendarNameText    : 'Nome Calendario',
            tplTexts            : {
                tplWorkingHours : 'Ore lavorative per',
                tplIsNonWorking : 'è non lavorativa',
                tplOverride     : 'bypassa',
                tplInCalendar   : 'in calendario',
                tplDayInCalendar: 'giorno standard in calendario',
                tplBasedOn      : 'Basata su'
            },
            overrideErrorText   : 'C\'è già un override per questo giorno',
            overrideDateError   : 'C\'è già un override di settimana per questa data: {0}',
            startAfterEndError  : 'La data di inizio deve essere precedente a quella di fine',
            weeksIntersectError : 'L\'override di settimana non deve intersecarsi'
        },

        'Gnt.widget.calendar.AvailabilityGrid' : {
            startText           : 'Inizio',
            endText             : 'Fine',
            addText             : 'Aggiungi',
            removeText          : 'Rimuovi',
            error               : 'Errore'
        },

        'Gnt.widget.calendar.DayEditor' : {
            workingTimeText    : 'Tempo lavorativo',
            nonworkingTimeText : 'Tempo non-lavorativo'
        },

        'Gnt.widget.calendar.WeekEditor' : {
            defaultTimeText    : 'Tempo predefinito',
            workingTimeText    : 'Tempo lavorativo',
            nonworkingTimeText : 'Tempo non-lavorativo',
            error              : 'Errore',
            noOverrideError    : "L\'override settimanale contiene solo giorni 'predefiniti' - impossibile salvare"
        },

        'Gnt.widget.calendar.ResourceCalendarGrid' : {
            name        : 'Nome',
            calendar    : 'Calendario'
        },

        'Gnt.widget.calendar.CalendarWindow' : {
            ok      : 'Ok',
            cancel  : 'Annulla'
        },

        'Gnt.field.Assignment' : {
            cancelText : 'Annulla',
            closeText  : 'Salva e Chiudi'
        },

        'Gnt.column.AssignmentUnits' : {
            text : 'Unità'
        },

        'Gnt.column.Duration' : {
            text : 'Durata'
        },

        'Gnt.column.Effort' : {
            text : 'Impegno'
        },

        'Gnt.column.EndDate' : {
            text : 'Fine'
        },

        'Gnt.column.PercentDone' : {
            text : '% eseguita'
        },

        'Gnt.column.ResourceAssignment' : {
            text : 'Risorse assegnate'
        },

        'Gnt.column.ResourceName' : {
            text : 'Nome Risorsa'
        },

        'Gnt.column.Rollup' : {
            text : 'Attività di roll-up',
            yes  : 'Si',
            no   : 'No'
        },

        'Gnt.column.SchedulingMode' : {
            text : 'Modalità'
        },

        'Gnt.column.Predecessor' : {
            text : 'Predecessore'
        },

        'Gnt.column.Successor' : {
            text : 'Successore'
        },

        'Gnt.column.StartDate' : {
            text : 'Inizio'
        },

        'Gnt.column.WBS' : {
            text : 'WBS'
        },

        'Gnt.column.Sequence' : {
            text : '#'
        },

        'Gnt.column.Calendar' : {
            text : 'Calendario'
        },

        'Gnt.widget.taskeditor.TaskForm' : {
            taskNameText            : 'Nome',
            durationText            : 'Durata',
            datesText               : 'Date',
            baselineText            : 'Riferimento',
            startText               : 'Inizio',
            finishText              : 'Fine',
            percentDoneText         : 'Percentuale completamento',
            baselineStartText       : 'Inizio',
            baselineFinishText      : 'Fine',
            baselinePercentDoneText : 'Percentuale completamento',
            effortText              : 'Impegno',
            invalidEffortText       : 'Valore impegno non valido',
            calendarText            : 'Calendario',
            schedulingModeText      : 'Modalità programmazione',
            rollupText              : 'Roll-up'
        },

        'Gnt.widget.DependencyGrid' : {
            idText                      : 'ID',
            snText                      : 'SN',
            taskText                    : 'Nome attività',
            blankTaskText               : 'Selezionare attività',
            invalidDependencyText       : 'Dipendenza non valida',
            parentChildDependencyText   : 'Trovata dipendenza tra figlio e padre',
            duplicatingDependencyText   : 'Trovata duplicazione dipendenza',
            transitiveDependencyText    : 'Dipendenza transitiva',
            cyclicDependencyText        : 'Dipendenza ciclica',
            typeText                    : 'Tipo',
            lagText                     : 'Lag',
            clsText                     : 'Classe CSS',
            endToStartText              : 'Fine-a-Inizio',
            startToStartText            : 'Inizio-a-Inizio',
            endToEndText                : 'Fine-a-Fine',
            startToEndText              : 'Inizio-a-Fine'
        },

        'Gnt.widget.AssignmentEditGrid' : {
            confirmAddResourceTitle : 'Conferma',
            confirmAddResourceText  : 'Nessuna risorsa &quot;{0}&quot; trovata in elenco. Aggiungerla?',
            noValueText             : 'Selezionare una risorsa da assegnare',
            noResourceText          : 'Nessuna risorsa &quot;{0}&quot; trovata in elenco'
        },

        'Gnt.widget.taskeditor.TaskEditor' : {
            generalText         : 'Generale',
            resourcesText       : 'Risorse',
            dependencyText      : 'Predecessori',
            addDependencyText   : 'Aggiungi nuova',
            dropDependencyText  : 'Rimuovi',
            notesText           : 'Note',
            advancedText        : 'Avanzate',
            wbsCodeText         : 'Codice WBS',
            addAssignmentText   : 'Aggiungi nuova',
            dropAssignmentText  : 'Rimuovi'
        },

        'Gnt.plugin.TaskEditor' : {
            title           : 'Informazioni Attività',
            alertCaption    : 'Informazioni',
            alertText       : 'Correggre gli errori marcati per salvare le modifiche',
            okText          : 'Ok',
            cancelText      : 'Annulla'
        },

        'Gnt.field.EndDate' : {
            endBeforeStartText : 'La data di fine è precedente a quella di inizio'
        },

        'Gnt.column.Note'   : {
            text            : 'Note'
        },

        'Gnt.column.AddNew' : {
            text            : 'Aggiungi nuova colonna...'
        },

        'Gnt.column.EarlyStartDate' : {
            text            : 'Inizio Anticipato'
        },

        'Gnt.column.EarlyEndDate' : {
            text            : 'Fine Anticipata'
        },

        'Gnt.column.LateStartDate' : {
            text            : 'Inizio Ritardato'
        },

        'Gnt.column.LateEndDate' : {
            text            : 'Fine Ritardata'
        },

        'Gnt.field.Calendar' : {
            calendarNotApplicable : 'Il calendario attività non ha sovrapposizioni con il calendario delle risorse assegnate'
        },

        'Gnt.column.Slack' : {
            text            : 'Tolleranza'
        },

        'Gnt.column.Name'   : {
            text            : 'Nome Attività'
        },

        'Gnt.column.BaselineStartDate'   : {
            text            : 'Data Inizio Riferimento'
        },

        'Gnt.column.BaselineEndDate'   : {
            text            : 'Data Fine Riferimento'
        },

        'Gnt.column.Milestone'   : {
            text            : 'Milestone'
        },

        'Gnt.field.Milestone'   : {
            yes             : 'Si',
            no              : 'No'
        },

        'Gnt.field.Dependency'  : {
            invalidFormatText       : 'Formato dipendenza non valido',
            invalidDependencyText   : 'Trovata dipendenza non valida, accertarsi di non avere percorsi ciclici tra le attività',
            invalidDependencyType   : 'Dipendenza non valida di tipo {0}. I valori non consentiti sono: {1}.'
        },
        /*Labels for Custom Columns*/
        'Gnt.column.Type'   : {
            text            : 'Tipo'
        },
        'Gnt.column.Id'   : {
            text            : 'Id'
        },
        'Gnt.column.Dependency'   : {
            text            : 'Dipendenza'
        },
        'Gnt.column.State'   : {
            text            : 'Stato'
        },
        'Gnt.column.PercentComplete'   : {
            text            : '%'
        },
        'Gnt.column.Estimated Duration'   : {
            text            : 'Durata stimata'
        },
        'Gnt.column.Estimated Start Date'   : {
            text            : 'Data di inizio stimata'
        },
        'Gnt.column.Estimated Finish Date'   : {
            text            : 'Data di fine stimata'
        },
        'Gnt.column.Actual Duration'   : {
            text            : 'Durata effettiva'
        },
        'Gnt.column.Actual Start Date'   : {
            text            : 'Data di inizio effettiva'
        },
        'Gnt.column.Actual Finish Date'   : {
            text            : 'Data di fine effettiva'
        }
        ,
        'Gnt.column.Baseline Initial Start Date'   : {
            text            : 'Data inizio iniziale riferimento'
        },
        'Gnt.column.Baseline Initial Finish Date'   : {
            text            : 'Data fine iniziale riferimento'
        },
        'Gnt.column.Baseline Current Start Date'   : {
            text            : 'Data inizio corrente riferimento'
        },
        'Gnt.column.Baseline Current Finish Date'   : {
            text            : 'Data fine corrente riferimento'
        },
        'Gnt.column.Deviation'   : {
            text            : 'Deviazione'
        },
        'Gnt.column.Assignee'   : {
            text            : 'Assegnatario'
        }
    }
});
