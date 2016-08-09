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

MouseArea {
    id: panelIconWidget

    anchors.fill: parent
    
    state: backupStateGlobal
    onClicked: plasmoid.expanded = !plasmoid.expanded

    PlasmaCore.IconItem {
        id: backupIcon

        anchors.fill: parent
        colorGroup: PlasmaCore.ColorScope.colorGroup        
    }
    
    states: [
        State {
            name: "ok"
            PropertyChanges { target: backupIcon; source: "state-ok"}
        },
        State {
            name: "disabled"
            PropertyChanges { target: backupIcon; source: "state-offline"}
        },
        State {
            name: "notconfigured"
            PropertyChanges { target: backupIcon; source: "state-information"}
        },
        State {
            name: "information"
            PropertyChanges { target: backupIcon; source: "state-information"}
        },
        State {
            name: "warning"
            PropertyChanges { target: backupIcon; source: "state-warning"}
        },
        State {
            name: "error"
            PropertyChanges { target: backupIcon; source: "state-error"}
        },
        State {
            name: "pause"
            PropertyChanges { target: backupIcon; source: "state-pause"}
        },
        State {
            name: "busy"
            PropertyChanges { target: backupIcon; source: "state-sync"}
        },
        State {
            name: "offline"
            PropertyChanges { target: backupIcon; source: "state-offline"}
        }
    ]
}
