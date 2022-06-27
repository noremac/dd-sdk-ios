/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-2020 Datadog, Inc.
 */

import Foundation

/// Creates V2 Storage configuration for V1 Tracing.
internal func createV2TracingStorageConfiguration() -> FeatureStorageConfiguration {
    return FeatureStorageConfiguration(
        directories: .init(
            authorized: "com.datadoghq.traces/v2",
            unauthorized: "com.datadoghq.traces/intermediate-v2",
            deprecated: [
                "com.datadoghq.traces/v1",
                "com.datadoghq.traces/intermediate-v1",
            ]
        ),
        featureName: "tracing"
    )
}

/// Creates V2 Upload configuration for V1 Tracing.
internal func createV2TracingUploadConfiguration(v1Configuration: FeaturesConfiguration.Tracing) -> FeatureUploadConfiguration {
    return FeatureUploadConfiguration(
        featureName: "tracing",
        createRequestBuilder: { v1Context, telemetry in
            return RequestBuilder(
                url: v1Configuration.uploadURL,
                queryItems: [],
                headers: [
                    .contentTypeHeader(contentType: .textPlainUTF8),
                    .userAgentHeader(
                        appName: v1Context.applicationName,
                        appVersion: v1Context.version,
                        device: v1Context.device
                    ),
                    .ddAPIKeyHeader(clientToken: v1Context.clientToken),
                    .ddEVPOriginHeader(source: v1Context.ciAppOrigin ?? v1Context.source),
                    .ddEVPOriginVersionHeader(sdkVersion: v1Context.sdkVersion),
                    .ddRequestIDHeader(),
                ],
                telemetry: telemetry
            )
        },
        payloadFormat: DataFormat(prefix: "", suffix: "", separator: "\n")
    )
}
