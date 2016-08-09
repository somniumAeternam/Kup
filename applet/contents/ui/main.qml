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
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: mainWindow

    property string backupStateGlobal: "ok"

    Plasmoid.toolTipMainText: i18n("Backup")
    Plasmoid.toolTipSubText: i18n("Kup Backup")
    Plasmoid.icon: "preferences-system-time"
    Plasmoid.switchWidth: units.gridUnit * 15
    Plasmoid.switchHeight: units.gridUnit * 15
    Plasmoid.compactRepresentation: CompactRepresentation { }
    Plasmoid.fullRepresentation: PopupDialog {
        id: dialogItem
        Layout.minimumWidth: units.gridUnit * 22
        Layout.minimumHeight: units.gridUnit * 20
        anchors.fill: parent
        focus: true
    }
    
    function toggleEnableBackup(enable) {
        if (enable) {
            backupStateGlobal = "ok"
        }
        else {
            backupStateGlobal = "disabled"
        }
//        handler.enableBackup(checked);  
    }
}

