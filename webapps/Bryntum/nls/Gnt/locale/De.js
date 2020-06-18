/*

Ext Gantt 2.2.23
Copyright(c) 2009-2014 Bryntum AB
http://bryntum.com/contact
http://bryntum.com/license

*/
Ext.define('Gnt.locale.De', {
    extend      : 'Sch.locale.Locale',
    requires    : 'Sch.locale.De',
    singleton   : true,

    l10n        : {
        'Gnt.util.DurationParser' : {
            unitsRegex : {
                MILLI       : /^ms$|^Millisek/i,
                SECOND      : /^s$|^Sek/i,
                MINUTE      : /^min$|^Minute/i,
                HOUR        : /^h$|^St$|^Stunde/i,
                DAY         : /^T$|^Tag/i,
                WEEK        : /^W$|^Wo|^Woche/i,
                MONTH       : /^Mo|^Monat/i,
                QUARTER     : /^Q$|^Quartal|^Qrt/i,
                YEAR        : /^J$|^Jh|^Jahr/i
            }
        },

        'Gnt.util.DependencyParser' : {
            typeText : {
                SS : 'SS',
                SF : 'SF',
                FS : 'FS',
                FF : 'FF'
            }
        },

        'Gnt.field.Duration' : {
            invalidText : 'Ungültiger Wert für die Dauer'
        },

        'Gnt.feature.DependencyDragDrop' : {
            fromText    : 'Von',
            toText      : 'Bis',
            startText   : 'Start',
            endText     : 'Ende'
        },

        'Gnt.Tooltip' : {
            startText       : 'Beginnt: ',
            endText         : 'Endet: ',
            durationText    : 'Dauer: '
        },

        'Gnt.plugin.TaskContextMenu' : {
            taskInformation     : 'Aufgabeninformationen...',
            newTaskText         : 'Neue Aufgabe',
            deleteTask          : 'Aufgabe(n) löschen',
            editLeftLabel       : 'Linke Bezeichnung bearbeiten',
            editRightLabel      : 'Rechte Bezeichnung bearbeiten',
            add                 : 'Hinzufügen...',
            deleteDependency    : 'Abhängigkeit löschen...',
            addTaskAbove        : 'Aufgabe vor',
            addTaskBelow        : 'Aufgabe unter',
            addMilestone        : 'Meilenstein',
            addSubtask          : 'Unteraufgabe',
            addSuccessor        : 'Nachfolger',
            addPredecessor      : 'Vorgänger',
            convertToMilestone  : 'Zu Meilenstein konvertieren',
            convertToRegular    : 'Zu regulärer Aufgabe konvertieren'
        },

        'Gnt.plugin.DependencyEditor' : {
            fromText            : 'Von',
            toText              : 'Zu',
            typeText            : 'Typ',
            lagText             : 'Zeitabstand',
            endToStartText      : 'Fertigstellung-Start',
            startToStartText    : 'Start-Start',
            endToEndText        : 'Fertigstellung-Fertigstellung',
            startToEndText      : 'Start-Fertigstellung'
        },

        'Gnt.widget.calendar.Calendar' : {
            dayOverrideNameHeaderText : 'Name',
            overrideName        : 'Name',
            startDate           : 'Startdatum',
            endDate             : 'Enddatum',
            error               : 'Fehler',
            dateText            : 'Datum',
            addText             : 'Hinzufügen',
            editText            : 'Ändern',
            removeText          : 'Entfernen',
            workingDayText      : 'Arbeitstag',
            weekendsText        : 'Wochenende',
            overriddenDayText   : 'Tag mit Überschneidung',
            overriddenWeekText  : 'Woche mit Überschneidung',
            workingTimeText     : 'Arbeitszeit',
            nonworkingTimeText  : 'keine Arbeitszeit',
            dayOverridesText    : 'Überschneidungen an Tagen',
            weekOverridesText   : 'Überschneidungen in Wochen',
            okText              : 'OK',
            cancelText          : 'Abbrechen',
            parentCalendarText  : 'Ursprungskalender',
            noParentText        : 'Kein Ursprungskalender',
            selectParentText    : 'Ursprungskalender wählen',
            newDayName          : '[Ohne Name]',
            calendarNameText    : 'Kalendername',
            tplTexts            : {
                tplWorkingHours : 'Arbeitszeit für',
                tplIsNonWorking : 'ist keine Arbeitszeit',
                tplOverride     : 'Überschneidung',
                tplInCalendar   : 'in Kalender',
                tplDayInCalendar: 'Standardtag in Kalender',
                tplBasedOn      : 'Basierend auf'
            },
            overrideErrorText   : 'Für diesen Tag existiert bereits eine Überschneidung',
            overrideDateError   : 'In dieser Woche existiert bereits eine Überschneidung für folgendes Datum: {0}',
            startAfterEndError  : 'Startdatum größer als Enddatum',
            weeksIntersectError : 'Wochenüberschneidungen sollten sich nicht überlagern'
        },

        'Gnt.widget.calendar.AvailabilityGrid' : {
            startText           : 'Start',
            endText             : 'Ende',
            addText             : 'Hinzufügen',
            removeText          : 'Entfernen',
            error               : 'Fehler'
        },

        'Gnt.widget.calendar.DayEditor' : {
            workingTimeText     : 'Arbeitszeit',
            nonworkingTimeText  : 'Keine Arbeitszeit'
        },

        'Gnt.widget.calendar.WeekEditor' : {
            defaultTimeText     : 'Standardzeit',
            workingTimeText     : 'Arbeitszeit',
            nonworkingTimeText  : 'Keine Arbeitszeit',
            error               : 'Fehler',
            noOverrideError     : "Wochenüberschneidungen beinhaltet nur 'Standard' Tage - kann nicht gespeichert werden."
        },

        'Gnt.widget.calendar.ResourceCalendarGrid' : {
            name        : 'Name',
            calendar    : 'Kalender'
        },

        'Gnt.widget.calendar.CalendarWindow' : {
            ok      : 'Ok',
            cancel  : 'Abbrechen'
        },

        'Gnt.field.Assignment' : {
            cancelText : 'Abbrechen',
            closeText  : 'Speichern und schliessen'
        },

        'Gnt.column.AssignmentUnits' : {
            text : 'Einheiten'
        },

        'Gnt.column.Duration' : {
            text : 'Dauer'
        },

        'Gnt.column.Effort' : {
            text : 'Aufwand'
        },

        'Gnt.column.EndDate' : {
            text : 'Fertig stellen'
        },

        'Gnt.column.PercentDone' : {
            text : '% erledigt'
        },

        'Gnt.column.ResourceAssignment' : {
            text : 'Zugewiesene Ressourcen'
        },

        'Gnt.column.ResourceName' : {
            text : 'Ressourcenname'
        },

        'Gnt.column.Rollup' : {
            text : 'Rollup',
            no   : 'Ja',
            yes  : 'Nein'
        },

        'Gnt.column.SchedulingMode' : {
            text : 'Modus'
        },

        'Gnt.column.Predecessor' : {
            text : 'Vorgänger'
        },

        'Gnt.column.Successor' : {
            text : 'Nachfolger'
        },

        'Gnt.column.StartDate' : {
            text : 'Anfang'
        },

        'Gnt.column.WBS' : {
            text : 'Projektplan'
        },

        'Gnt.column.Sequence' : {
            text : 'Nr.'
        },

        'Gnt.column.Calendar' : {
            text : 'Kalender'
        },

        'Gnt.widget.taskeditor.TaskForm' : {
            taskNameText            : 'Name',
            durationText            : 'Dauer',
            datesText               : 'Daten',
            baselineText            : 'Referenzlinie',
            startText               : 'Start',
            finishText              : 'Ende',
            percentDoneText         : 'Abgeschlossen in Prozent',
            baselineStartText       : 'Start',
            baselineFinishText      : 'Ende',
            baselinePercentDoneText : 'Prozent abgeschlossen',
            effortText              : 'Aufwand',
            invalidEffortText       : 'Ungültiger Wert für Aufwand',
            calendarText            : 'Kalender',
            schedulingModeText      : 'Planungsmodus',
            rollupText              : 'Zusammenfassen'
        },

        'Gnt.widget.DependencyGrid' : {
            idText                      : 'Kennung',
            snText                      : 'SN',
            taskText                    : 'Aufgabenname',
            blankTaskText               : 'Bitte Aufgabe wählen',
            invalidDependencyText       : 'Ungültige Abhängigkeit',
            parentChildDependencyText   : 'Abhängigkeit zwischen Abhängigkeit und Ursprung',
            duplicatingDependencyText   : 'Doppelte Abhängigkeit gefunden',
            transitiveDependencyText    : 'Transitive Abhängigkeit',
            cyclicDependencyText        : 'Zirkuläre Referenz',
            typeText                    : 'Typ',
            lagText                     : 'Verzögern',
            clsText                     : 'CSS-Klasse',
            endToStartText              : 'Fertigstellung-Start',
            startToStartText            : 'Start-Start',
            endToEndText                : 'Fertigstellung-Fertigstellung',
            startToEndText              : 'Start-Fertigstellung'
        },

        'Gnt.widget.AssignmentEditGrid' : {
            confirmAddResourceTitle : 'Bestätigen',
            confirmAddResourceText  : 'Ressource &quot;{0}&quot; nicht in der Liste gefunden. Möchten Sie sie hinzufügen?',
            noValueText             : 'Bitte eine Ressource für die Zuordnung auswählen',
            noResourceText          : 'Ressource &quot;{0}&quot; nicht in der Liste gefunden'
        },

        'Gnt.widget.taskeditor.TaskEditor' : {
            generalText         : 'Generell',
            resourcesText       : 'Ressourcen',
            dependencyText      : 'Vorgänger',
            addDependencyText   : 'Neu hinzufügen',
            dropDependencyText  : 'Entfernen',
            notesText           : 'Notizen',
            advancedText        : 'Fortgeschritten',
            wbsCodeText         : 'WBS-Code',
            addAssignmentText   : 'Neu hinzufügen',
            dropAssignmentText  : 'Entfernen'
        },

        'Gnt.plugin.TaskEditor' : {
            title           : 'Aufgabeninformationen',
            alertCaption    : 'Informationen',
            alertText       : 'Bitte die markierten Fehler zum Speichern beheben',
            okText          : 'Ok',
            cancelText      : 'Abbrechen'
        },

        'Gnt.field.EndDate' : {
            endBeforeStartText : 'Das Enddatum liegt vor dem Startdatum'
        },

        'Gnt.column.Note'   : {
            text            : 'Notiz'
        },

        'Gnt.column.AddNew' : {
            text            : 'Neue Spalte hinzufügen...'
        },

        'Gnt.column.EarlyStartDate' : {
            text            : 'Frühes Startdatum'
        },

        'Gnt.column.EarlyEndDate' : {
            text            : 'Frühes Ende'
        },

        'Gnt.column.LateStartDate' : {
            text            : 'Später Start'
        },

        'Gnt.column.LateEndDate' : {
            text            : 'Spätes Ende'
        },

        'Gnt.field.Calendar' : {
            calendarNotApplicable : 'Aufgabenkalender hat keine Überlappung mit den Kalendern der zugwiesenen Ressourcen'
        },

        'Gnt.column.Slack' : {
            text            : 'Spielraum'
        },

        'Gnt.column.Name'   : {
            text            : 'Vorgangsname'
        },

        'Gnt.column.BaselineStartDate'   : {
            text            : 'Startdatum der Referenzlinie'
        },

        'Gnt.column.BaselineEndDate'   : {
            text            : 'Enddatum der Referenzlinie'
        },

        'Gnt.column.Milestone'   : {
            text            : 'Meilenstein'
        },

        'Gnt.field.Milestone'   : {
            yes             : 'Ja',
            no              : 'Nein'
        },

        'Gnt.field.Dependency'  : {
            invalidFormatText       : 'Ungültiges Abhängigkeitsformat',
            invalidDependencyText   : 'Ungültige Abhängigkeit gefunden. Stellen Sie sicher, dass sich keine Kreispfade zwischen Ihren Aufgaben befinden.',
            invalidDependencyType   : 'Ungültiger Abhängigkeitstyp {0}. Zulässige Werte sind: {1}.'
        }
        /*Labels for Custom Columns*/
        ,
        'Gnt.column.Type'   : {
            text            : 'Typ'
        },
        'Gnt.column.Id'   : {
            text            : 'Kennung'
        },
        'Gnt.column.Dependency'   : {
            text            : 'Abhängigkeit'
        },
        'Gnt.column.State'   : {
            text            : 'Stadium'
        },
        'Gnt.column.PercentComplete'   : {
            text            : '%'
        },
        'Gnt.column.Estimated Duration'   : {
            text            : 'Vorgesehene Dauer'
        },
        'Gnt.column.Estimated Start Date'   : {
            text            : 'Vorgesehenes Startdatum'
        },
        'Gnt.column.Estimated Finish Date'   : {
            text            : 'Vorgesehenes Fertigstellungsdatum'
        },
        'Gnt.column.Actual Duration'   : {
            text            : 'Tatsächliche Dauer'
        },
        'Gnt.column.Actual Start Date'   : {
            text            : 'Tatsächliches Startdatum'
        },
        'Gnt.column.Actual Finish Date'   : {
            text            : 'Tatsächliches Fertigstellungsdatum'
        }
        ,
        'Gnt.column.Baseline Initial Start Date'   : {
            text            : 'Ursprüngliches Startdatum der Referenzlinie'
        },
        'Gnt.column.Baseline Initial Finish Date'   : {
            text            : 'Ursprüngliches Fertigstellungsdatum der Referenzlinie'
        },
        'Gnt.column.Baseline Current Start Date'   : {
            text            : 'Aktuelles Startdatum der Referenzlinie'
        },
        'Gnt.column.Baseline Current Finish Date'   : {
            text            : 'Aktuelles Fertigstellungsdatum der Referenzlinie'
        },
        'Gnt.column.Deviation'   : {
            text            : 'Abweichung'
        },
        'Gnt.column.Assignee'   : {
            text            : 'Inhaber'
        }
    }
});
