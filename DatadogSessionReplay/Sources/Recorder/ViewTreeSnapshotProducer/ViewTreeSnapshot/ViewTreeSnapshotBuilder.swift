/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-Present Datadog, Inc.
 */

import Foundation
import UIKit

/// Builds `ViewTreeSnapshot` for given root view.
///
/// Note: This builder is used by `Recorder` on the main thread.
internal struct ViewTreeSnapshotBuilder {
    /// Records subtree of the root view.
    let viewTreeRecorder: ViewTreeRecorder
    /// Generates stable IDs for traversed views.
    let idsGenerator: NodeIDGenerator
    /// Provides base64 image data with a built in caching mechanism.
    let imageDataProvider: ImageDataProviding

    /// Builds the `ViewTreeSnapshot` for given root view.
    ///
    /// - Parameter rootView: the root view
    /// - Parameter recorderContext: the context of the Recorder from the moment of requesting this snapshot
    /// - Returns: snapshot describing the view tree starting in `rootView`. All properties in snapshot nodes
    /// are computed relatively to the `rootView` (e.g. the `x` and `y` position of all descendant nodes  is given
    /// as its position in the root, no matter of nesting level).
    func createSnapshot(of rootView: UIView, with recorderContext: Recorder.Context) -> ViewTreeSnapshot {
        let context = ViewTreeRecordingContext(
            recorder: recorderContext,
            coordinateSpace: rootView,
            ids: idsGenerator,
            imageDataProvider: imageDataProvider
        )
        let snapshot = ViewTreeSnapshot(
            date: recorderContext.date.addingTimeInterval(recorderContext.viewServerTimeOffset ?? 0),
            context: recorderContext,
            viewportSize: rootView.bounds.size,
            nodes: viewTreeRecorder.recordNodes(for: rootView, in: context)
        )
        return snapshot
    }
}

extension ViewTreeSnapshotBuilder {
    init() {
        self.init(
            viewTreeRecorder: ViewTreeRecorder(nodeRecorders: createDefaultNodeRecorders()),
            idsGenerator: NodeIDGenerator(),
            imageDataProvider: ImageDataProvider()
        )
    }
}

/// An arrays of default node recorders executed for the root view-tree hierarchy.
internal func createDefaultNodeRecorders() -> [NodeRecorder] {
    return [
        UnsupportedViewRecorder(),
        UIViewRecorder(),
        UILabelRecorder(),
        UIImageViewRecorder(),
        UITextFieldRecorder(),
        UITextViewRecorder(),
        UISwitchRecorder(),
        UISliderRecorder(),
        UISegmentRecorder(),
        UIStepperRecorder(),
        UINavigationBarRecorder(),
        UITabBarRecorder(),
        UIPickerViewRecorder(),
        UIDatePickerRecorder(),
    ]
}
