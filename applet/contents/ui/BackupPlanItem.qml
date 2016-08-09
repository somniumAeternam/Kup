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
import org.kde.kcoreaddons 1.0 as KCoreAddons
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras

PlasmaComponents.ListItem {
    id: backupItem
    
    state: backupState
    checked: backupItem.containsMouse
    enabled: true
    height: backupItemBase.height

    /*PlasmaCore.DataSource {
        id: dataSource

        property string downloadSource: "network/interfaces/" + DeviceName + "/receiver/data"
        property string uploadSource: "network/interfaces/" + DeviceName + "/transmitter/data"

        connectedSources: showSpeed && plasmoid.expanded ? [downloadSource, uploadSource] : []
        engine: "systemmonitor"
        interval: 2000
    }*/

    Item {
        id: backupItemBase

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            // Reset top margin from PlasmaComponents.ListItem
            topMargin: -Math.round(units.gridUnit / 3)
        }
        height: Math.max(units.iconSizes.medium, backupNameLabel.height + backupStatusLabel.height) + Math.round(units.gridUnit / 2)
       
       PlasmaCore.IconItem {
            id: backupSvgIcon
           
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            width: backupNameLabel.height + backupStatusLabel.height
            height: width            
            colorGroup: PlasmaCore.ColorScope.colorGroup
        }
            
        PlasmaComponents.Label {
            id: backupNameLabel

            anchors {
                bottom: backupSvgIcon.verticalCenter
                left: backupSvgIcon.right
                leftMargin: Math.round(units.gridUnit / 2)
                right: backupStartButton.visible ? backupStartButton.left : parent.right
                
            }
            height: paintedHeight
            elide: Text.ElideRight
            text: backupName
            textFormat: Text.PlainText
        }

        PlasmaComponents.Label {
            id: backupStatusLabel

            anchors {
                left: backupSvgIcon.right
                leftMargin: Math.round(units.gridUnit / 2)
                right: backupStartButton.visible ? backupStartButton.left : parent.right
                top: backupNameLabel.bottom
            }
            height: paintedHeight
            elide: Text.ElideRight
            font.pointSize: theme.smallestFont.pointSize
            opacity: 0.6
            text: backupStatus
        }

       PlasmaComponents.BusyIndicator {
            id: backupRunningIndicator

            anchors {
                right: backupStartButton.visible ? backupStartButton.left : parent.right
                rightMargin: Math.round(units.gridUnit / 2)
                verticalCenter: backupSvgIcon.verticalCenter
            }
            height: units.iconSizes.medium; width: height
        }

        PlasmaComponents.Button {
            id: backupStartButton

            anchors {
                right: openFolderButton.left
                rightMargin: Math.round(units.gridUnit / 4)
                verticalCenter: backupSvgIcon.verticalCenter
            }
            visible: backupItem.containsMouse
            text: "Start backup"
            tooltip: i18n("Datensicherungen konfigurieren")

            onClicked: startBackup()
        }
        
        PlasmaComponents.ToolButton {
            id: openFolderButton

            anchors {
                right: openLogButton.left
                rightMargin: Math.round(units.gridUnit / 4)
                verticalCenter: backupSvgIcon.verticalCenter
            }
            visible: backupItem.containsMouse
            iconSource: "document-open-folder"
            tooltip: i18n("Dateien öffnen")

            onClicked: {
                handler.openFolder();
            }
        }
        
        PlasmaComponents.ToolButton {
            id: openLogButton

            anchors {
                right: parent.right
                rightMargin: Math.round(units.gridUnit / 2)
                verticalCenter: backupSvgIcon.verticalCenter
            }
            visible: backupItem.containsMouse
            iconSource: "help-about"
            tooltip: i18n("Log-Datei öffnen")

            onClicked: {
                handler.openLog();
            }
        }
    }
    
    states: [
        State {
            name: "ok"
            PropertyChanges { target: backupSvgIcon; source: "state-ok"}
            PropertyChanges { target: backupRunningIndicator; visible: false}
            PropertyChanges { target: backupStartButton; enabled: true}
            PropertyChanges { target: openFolderButton; enabled: true}
            PropertyChanges { target: openLogButton; enabled: true}
        },
        State {
            name: "information"
            PropertyChanges { target: backupSvgIcon; source: "state-information"}
            PropertyChanges { target: backupRunningIndicator; visible: false}
            PropertyChanges { target: backupStartButton; enabled: true}
            PropertyChanges { target: openFolderButton; enabled: true}
            PropertyChanges { target: openLogButton; enabled: true}
        },
        State {
            name: "warning"
            PropertyChanges { target: backupSvgIcon; source: "state-warning"}
            PropertyChanges { target: backupRunningIndicator; visible: false}
            PropertyChanges { target: backupStartButton; enabled: true}
            PropertyChanges { target: openFolderButton; enabled: true}
            PropertyChanges { target: openLogButton; enabled: true}
        },
        State {
            name: "error"
            PropertyChanges { target: backupSvgIcon; source: "state-error"}
            PropertyChanges { target: backupRunningIndicator; visible: false}
            PropertyChanges { target: backupStartButton; enabled: true}
            PropertyChanges { target: openFolderButton; enabled: true}
            PropertyChanges { target: openLogButton; enabled: true}
        },
        State {
            name: "pause"
            PropertyChanges { target: backupSvgIcon; source: "state-pause"}
            PropertyChanges { target: backupRunningIndicator; visible: false}
            PropertyChanges { target: backupStartButton; enabled: true}
            PropertyChanges { target: openFolderButton; enabled: true}
            PropertyChanges { target: openLogButton; enabled: true}
        },
        State {
            name: "busy"
            PropertyChanges { target: backupSvgIcon; source: "state-sync"}
            PropertyChanges { target: backupRunningIndicator; visible: !backupStartButton.visible}
            PropertyChanges { target: backupStartButton; enabled: false}
            PropertyChanges { target: openFolderButton; enabled: true}
            PropertyChanges { target: openLogButton; enabled: true}
        },
        State {
            name: "offline"
            PropertyChanges { target: backupSvgIcon; source: "state-offline"}
            PropertyChanges { target: backupRunningIndicator; visible: false}
            PropertyChanges { target: backupStartButton; enabled: false}
            PropertyChanges { target: openFolderButton; enabled: false}
            PropertyChanges { target: openLogButton; enabled: false}
        }
    ]
    
    function startBackup() {        
        backupItem.state = "busy"        
//        handler.startBackup();
    }
}
