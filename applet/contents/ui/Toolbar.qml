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
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: toolbar
    
    state: backupStateGlobal

    height: enableBackupButton.height

    PlasmaCore.Svg {
        id: lineSvg
        imagePath: "widgets/line"
    }
    
    Row {
        anchors {
            bottom: parent.bottom
            left: parent.left
            top: parent.top
        }

        SwitchButton {
            id: enableBackupButton

            property string switchButtonText: i18n("Backup")

            enabled: true

            onClicked: toggleEnableBackup(checked)
        } 
    }

    PlasmaComponents.ToolButton {
        id: openEditorButton

        anchors {
            right: parent.right
            rightMargin: Math.round(units.gridUnit / 2)
            verticalCenter: parent.verticalCenter
        }

        iconSource: "configure"
        tooltip: i18n("Datensicherungen konfigurieren")

        onClicked: {
            handler.openEditor();
        }
    }
    
    states: [
        State {
            name: "ok"
            PropertyChanges { target: enableBackupButton; checked: true}
        },
        State {
            name: "disabled"
            PropertyChanges { target: enableBackupButton; checked: false}
        },
        State {
            name: "notconfigured"
            PropertyChanges { target: enableBackupButton; checked: true}
        },
        State {
            name: "information"
            PropertyChanges { target: enableBackupButton; checked: true}
        },
        State {
            name: "warning"
            PropertyChanges { target: enableBackupButton; checked: true}
        },
        State {
            name: "error"
            PropertyChanges { target: enableBackupButton; checked: true}
        },
        State {
            name: "pause"
            PropertyChanges { target: enableBackupButton; checked: true}
        },
        State {
            name: "busy"
            PropertyChanges { target: enableBackupButton; checked: true}
        },
        State {
            name: "offline"
            PropertyChanges { target: enableBackupButton; checked: true}
        }
    ]
}
