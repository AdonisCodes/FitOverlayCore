// CreateProfilePictureWorkflow.swift
// Copyright (c) 2025 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Temporal
import Vapor

@Workflow
internal final class CreateProfilePictureWorkflow {
    func run(input: CreateProfilePictureActivityInput) async throws {
        try await Workflow.executeActivity(
            ProfilePictureActivities.Activities.CreatePicture.self,
            options: ActivityOptions(startToCloseTimeout: .seconds(30)),
            input: input
        )
    }
}
