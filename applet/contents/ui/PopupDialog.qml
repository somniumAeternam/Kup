/*
    Copyright 2016 Steffen Golle <somnium@stampernet.de>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

FocusScope {
    
    state: backupStateGlobal

    Toolbar {
        id: toolbar

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
    }
    
    PlasmaComponents.ListItem {
        id: header
               
        anchors {
                left: parent.left
                right: parent.right
                top: toolbar.bottom
            }            
        sectionDelegate: true        
        height: headerLabel.height + units.gridUnit; width: parent.width        
        visible: opacity != 0

        PlasmaComponents.Label {
            id: headerLabel

            anchors.centerIn: parent
            height: paintedHeight
            font.weight: Font.DemiBold
            
            text: i18n("Backup plans")
        }
    }
    
    Column {
        id: enableItemColumn
        
        anchors.centerIn: parent
        spacing: units.gridUnit / 2
        visible: opacity != 0

        PlasmaCore.IconItem {
            anchors.horizontalCenter: parent.horizontalCenter
            width: enableBackupButton2.width
            height: width
            source: "state-offline"
        }
        
        PlasmaExtras.Heading {
            id: activateItemText
            
            anchors.horizontalCenter: parent.horizontalCenter
            level: 3
            opacity: 0.6
            text: i18n("Backup is not activated.")            
        }
        
        PlasmaComponents.Button {
            id: enableBackupButton2
            
            anchors.horizontalCenter: parent.horizontalCenter

            text: "Aktivieren"
            tooltip: i18n("Datensicherungen konfigurieren")

            onClicked: toggleEnableBackup(true)
        }        
    }
    
    Column {
        id: configureItemColumn   
        
        anchors.centerIn: parent
        spacing: units.gridUnit / 2
        visible: opacity != 0

        PlasmaCore.IconItem {
            anchors.horizontalCenter: parent.horizontalCenter
            width: openEditorButton2.width
            height: width
            source: "state-information"
        }
        
        PlasmaExtras.Heading {
            id: configureItemText
            
            anchors.horizontalCenter: parent.horizontalCenter
            level: 3
            opacity: 0.6
            text: i18n("No Backup Plans configured.")            
        }
        
        PlasmaComponents.Button {
            id: openEditorButton2
            
            anchors.horizontalCenter: parent.horizontalCenter

            text: "Konfigurieren"
            tooltip: i18n("Datensicherungen konfigurieren")

            onClicked: {
                handler.openEditor();
            }
        }
    }

    PlasmaExtras.ScrollArea {
        id: scrollView

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            top: header.bottom
        }
        visible: opacity != 0
        
        ListView {
            id: backupView

            anchors {
                left: parent.left
                right: parent.right
                top: parent.bottom
            }
        
            clip: true
            model: BackupPlanModel {}
            currentIndex: -1
            boundsBehavior: Flickable.StopAtBounds
            delegate: BackupPlanItem {}
        }
    }
    
    states: [
        State {
            name: "ok"
            PropertyChanges { target: header; opacity: 1.0}
            PropertyChanges { target: enableItemColumn; opacity: 0.0}
            PropertyChanges { target: configureItemColumn; opacity: 0.0}
            PropertyChanges { target: scrollView; opacity: 1.0}
        },
        State {
            name: "disabled"
            PropertyChanges { target: header; opacity: 0.0}
            PropertyChanges { target: enableItemColumn; opacity: 1.0}
            PropertyChanges { target: configureItemColumn; opacity: 0.0}
            PropertyChanges { target: scrollView; opacity: 0.0}
        },
        State {
            name: "notconfigured"
            PropertyChanges { target: header; opacity: 0.0}
            PropertyChanges { target: enableItemColumn; opacity: 0.0}
            PropertyChanges { target: configureItemColumn; opacity: 1.0}
            PropertyChanges { target: scrollView; opacity: 0.0}
        },
        State {
            name: "information"
            PropertyChanges { target: header; opacity: 1.0}
            PropertyChanges { target: enableItemColumn; opacity: 0.0}
            PropertyChanges { target: configureItemColumn; opacity: 0.0}
            PropertyChanges { target: scrollView; opacity: 1.0}
        },
        State {
            name: "warning"
            PropertyChanges { target: header; opacity: 1.0}
            PropertyChanges { target: enableItemColumn; opacity: 0.0}
            PropertyChanges { target: configureItemColumn; opacity: 0.0}
            PropertyChanges { target: scrollView; opacity: 1.0}
        },
        State {
            name: "error"
            PropertyChanges { target: header; opacity: 1.0}
            PropertyChanges { target: enableItemColumn; opacity: 0.0}
            PropertyChanges { target: configureItemColumn; opacity: 0.0}
            PropertyChanges { target: scrollView; opacity: 1.0}
        },
        State {
            name: "pause"
            PropertyChanges { target: header; opacity: 1.0}
            PropertyChanges { target: enableItemColumn; opacity: 0.0}
            PropertyChanges { target: configureItemColumn; opacity: 0.0}
            PropertyChanges { target: scrollView; opacity: 1.0}
        },
        State {
            name: "busy"
            PropertyChanges { target: header; opacity: 1.0}
            PropertyChanges { target: enableItemColumn; opacity: 0.0}
            PropertyChanges { target: configureItemColumn; opacity: 0.0}
            PropertyChanges { target: scrollView; opacity: 1.0}
        },
        State {
            name: "offline"
            PropertyChanges { target: header; opacity: 1.0}
            PropertyChanges { target: enableItemColumn; opacity: 0.0}
            PropertyChanges { target: configureItemColumn; opacity: 0.0}
            PropertyChanges { target: scrollView; opacity: 1.0}
        }
    ]
    
    transitions: [
        Transition {
            from: "disabled"
            NumberAnimation { target: header; property: "opacity"; to: 1.0; duration: 500}
            NumberAnimation { target: enableItemColumn; property: "opacity"; to: 0.0; duration: 500}
            NumberAnimation { target: scrollView; property: "opacity"; to: 1.0; duration: 500}
        },
        Transition {
            to: "disabled"
            NumberAnimation { target: header; property: "opacity"; to: 0.0; duration: 500}
            NumberAnimation { target: enableItemColumn; property: "opacity"; to: 1.0; duration: 500}
            NumberAnimation { target: scrollView; property: "opacity"; to: 0.0; duration: 500}
        },
        Transition {
            from: "notconfigured"
            NumberAnimation { target: header; property: "opacity"; to: 1.0; duration: 500}
            NumberAnimation { target: configureItemColumn; property: "opacity"; to: 0.0; duration: 500}
            NumberAnimation { target: scrollView; property: "opacity"; to: 1.0; duration: 500}
        },
        Transition {
            to: "notconfigured"
            NumberAnimation { target: header; property: "opacity"; to: 0.0; duration: 500}
            NumberAnimation { target: configureItemColumn; property: "opacity"; to: 1.0; duration: 500}
            NumberAnimation { target: scrollView; property: "opacity"; to: 0.0; duration: 500}
        }
    ]
}
