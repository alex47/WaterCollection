import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.Controls 2.10

Window {
    id: mainWindow

    visible: true

    width: 900
    height: 500

    minimumWidth: 900
    minimumHeight: 500

    title: qsTr("Collecting water")

    Item {
        id: configurationItemView

        Text {
            id: barSegmentVerticalCountText
            text: qsTr("Height of the bars  ")

            font.pointSize: 10
            renderType: Text.NativeRendering

            x: 20
            y: 20
        }

        SpinBox {
            id: barSegmentVerticalCountSpinBox

            x: barSegmentVerticalCountText.contentWidth + barSegmentVerticalCountText.x
            y: barSegmentVerticalCountText.y - height / 4

            from: 3
            to: 20

            value: 10

            onValueChanged: setupWindow()
        }

        Text {
            id: barSegmentHorizontalCountText
            text: qsTr("Number of bars  ")

            font.pointSize: 10
            renderType: Text.NativeRendering

            x: barSegmentVerticalCountText.x
            y: barSegmentVerticalCountText.y + 60
        }

        SpinBox {
            id: barSegmentHorizontalCountSpinBox

            x: barSegmentVerticalCountSpinBox.x
            y: barSegmentHorizontalCountText.y - height / 4

            from: 3
            to: 20

            value: 10

            onValueChanged: setupWindow()
        }

        Button {
            id: refreshCharButton

            x: barSegmentHorizontalCountText.x
            y: barSegmentHorizontalCountText.y + 60

            text: "Refresh"
            font.pointSize: 10

            onClicked: setupWindow()
        }

    }

    Item {
        id: chartItemView

        property var barSegmentWidth: 0
        property var barSegmentHeight: 0

        property var barSegmentHorizontalCount: 0
        property var barSegmentVerticalCount: 0

        property var barCollection: []
        property var waterHeightCollection: []
        property var xAxisCollection: []

        x: 300
        y: mainWindow.height - height

        width: mainWindow.width - x - 28
        height: mainWindow.height

        Rectangle {
            id: lineXAxis0

            x: 0
            y: chartItemView.height * 0.9

            width: chartItemView.width
            height: 1

            color: "#808080"
        }

    }

    Binding {
        id: barSegmentWidthBinding
        target: chartItemView
        property: "barSegmentWidth"
        value: chartItemView.width / chartItemView.barSegmentHorizontalCount
    }

    Binding {
        id: barSegmentHeightBinding
        target: chartItemView
        property: "barSegmentHeight"
        value: (chartItemView.height * 0.8) / chartItemView.barSegmentVerticalCount
    }

    Component.onCompleted: setupWindow();

    function setupWindow()
    {
        deleteObjects()

        chartItemView.barSegmentVerticalCount = barSegmentVerticalCountSpinBox.value
        chartItemView.barSegmentHorizontalCount = barSegmentHorizontalCountSpinBox.value

        var barHeights = generateBarHeights()
        addBars(barHeights)

        var waterHeights = calculateWaterHeigths(barHeights)
        addWaterHeights(waterHeights)

        addXAxises()
    }

    function deleteObjects()
    {
        for (var i = chartItemView.barCollection.length - 1; i >= 0; i--) {
            chartItemView.barCollection[i].destroy()
            chartItemView.barCollection.pop()

            chartItemView.waterHeightCollection[i].destroy()
            chartItemView.waterHeightCollection.pop()
        }

        for (var i = chartItemView.xAxisCollection.length - 1; i >= 0; i--) {
            chartItemView.xAxisCollection[i].destroy()
            chartItemView.xAxisCollection.pop()
        }
    }

    function generateBarHeights()
    {
        var barHeights = []

        for (var i = 0; i < chartItemView.barSegmentHorizontalCount; i++) {
            var randomBarHeight = Math.round(Math.random() * chartItemView.barSegmentVerticalCount)
            barHeights.push(randomBarHeight)
        }

        return barHeights
    }

    function calculateWaterHeigths(barHeights)
    {
        var waterHeights = []

        for (var i = 0; i < barHeights.length; i++) {

            var leftWallSize = barHeights[i]
            var rightWallSize = barHeights[i]

            var leftWallFound = false
            var rightWallFound = false

            var waterHeight = 0

            // Look for highest wall to the left
            for (var j = i - 1; j >= 0; j--) {
                if (barHeights[j] >= leftWallSize) {
                    leftWallSize = barHeights[j]
                    leftWallFound = true
                }
            }

            // Look for highest wall to the right
            for (var j = i + 1; j < barHeights.length; j++) {
                if (barHeights[j] >= rightWallSize) {
                    rightWallSize = barHeights[j]
                    rightWallFound = true
                }
            }

            if (leftWallFound && rightWallFound) {
                waterHeight = Math.min(leftWallSize - barHeights[i], rightWallSize - barHeights[i])
            }

            waterHeights.push(waterHeight)
        }

        return waterHeights
    }

    function addBars(barHeights)
    {
        for (var i = 0; i < chartItemView.barSegmentHorizontalCount; i++) {

            var red = Math.random()
            var green = Math.random()
            var blue = Math.random()

            var newBar = Qt.createQmlObject('
                import QtQuick 2.0;

                Rectangle {
                    id: bar' + i + '

                    border.width: 1
                    border.color: Qt.rgba(' + red * 0.75 + ', ' + green * 0.75 + ', ' + blue * 0.75 + ', 1);
                    color: Qt.rgba(' + red + ', ' + green + ', ' + blue + ', 1);

                    x: lineXAxis0.x + chartItemView.barSegmentWidth * ' + i + '
                    y: lineXAxis0.y - (chartItemView.barSegmentHeight * ' + barHeights[i] + ')

                    width: chartItemView.barSegmentWidth;
                    height: chartItemView.barSegmentHeight * ' + barHeights[i] + '
                }
                ', chartItemView);

            chartItemView.barCollection.push(newBar)
        }
    }

    function addWaterHeights(waterHeights)
    {
        for (var i = 0; i < chartItemView.barSegmentHorizontalCount; i++) {

            var newWaterHeight = Qt.createQmlObject('
                import QtQuick 2.0;

                Text {
                    x: lineXAxis0.x + chartItemView.barSegmentWidth * ' + i + ' + chartItemView.barSegmentWidth * 0.5
                    y: lineXAxis0.y + chartItemView.height * 0.025

                    text: "' + waterHeights[i] + '"

                    font.pointSize: 10
                    renderType: Text.NativeRendering
                }
                ', chartItemView);

            chartItemView.waterHeightCollection.push(newWaterHeight)
        }
    }

    function addXAxises()
    {
        for (var i = 1; i <= chartItemView.barSegmentVerticalCount; i++) {
            var newAxis = Qt.createQmlObject('
                import QtQuick 2.0;

                Rectangle {
                    id: lineXAxis' + i + '

                    x: lineXAxis0.x
                    y: lineXAxis0.y - chartItemView.barSegmentHeight * ' + i + '
                    z: 1

                    width: chartItemView.width
                    height: 1

                    color: "#b3808080"
                }
                ', chartItemView);

            chartItemView.xAxisCollection.push(newAxis)
        }
    }
}
