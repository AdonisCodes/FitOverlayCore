// GenericErrors.swift
// Copyright (c) 2026 FitOverlay
// All source code and related assets are the property of FitOverlay.
// All rights reserved.

import Vapor

/// Represents common error cases that can occur throughout the application
/// Conforms to String, Error, Decodable, and Encodable protocols for serialization and error handling
public enum GenericErrors: String, Error, Decodable, Encodable {
    /// Error when a request is aborted
    case abortError
    /// Error related to Alamofire networking operations
    case alamofireError
    /// Error when decoding a response fails
    case failedToDecodeResponse
    /// Error when response encoding fails
    case failedToEncodeResponse
    /// Error for invalid verification code
    case invalidCode
    /// Error for an invalid or unknown licence key
    case invalidLicenseKey
    /// Error for incorrectly formatted phone number
    case invalidPhoneNumber
    /// Error for invalid authentication token
    case invalidToken
    /// Error for malformed URL
    case invalidUrl
    /// Error for invalid user ID format
    case invalidUserId
    /// Error when a licence has reached its maximum number of device activations
    case licenseActivationLimitReached
    /// Error when a licence is expired or revoked
    case licenseNotActive
    /// Error for network connectivity issues
    case networkConnectivityError
    /// Error when API returns neither error nor response
    case unexpectedApiStateNoErrorAndNoResponse
    /// Generic unknown error
    case unknownError
    /// Error when attempting to create user that already exists
    case userAlreadyExists
    /// Error when user cannot be found
    case userNotFound
    /// Error when verification code requests exceed rate limit
    case verificationCodeRateLimit

    /// Provides human-readable error messages for each error case
    /// - Returns: A string containing the user-friendly error message
    public var message: String {
        switch self {
        case .invalidCode:
            "The verification code you entered is invalid!"
        case .invalidLicenseKey:
            "We couldn't find a licence for this key!"
        case .userAlreadyExists:
            "A user with this phone number already exists!"
        case .userNotFound:
            "Sorry, We couldn't find the user for this phone number!"
        case .invalidToken:
            "Your Authentication Token is Invalid!"
        case .invalidUserId:
            "Your UserID isn't a valid UUID. We're Investigating"
        case .licenseActivationLimitReached:
            "This licence has reached its maximum number of active devices!"
        case .licenseNotActive:
            "This licence is no longer active. Please contact support!"
        case .failedToDecodeResponse:
            "An Invalid Response Object was sent down to the client!"
        case .failedToEncodeResponse:
            "Unfortunately we couldn't encode the response on the server side."
        case .unknownError:
            "An unknown Error has occured!"
        case .alamofireError:
            "There was an error making the request!"
        case .networkConnectivityError:
            "Please check your internet connection. It might be offline."
        case .verificationCodeRateLimit:
            "Please wait before sending another code! You're too fast! 💨"
        case .abortError:
            "The request was aborted!"
        case .invalidUrl:
            "The URL is invalid & Couldn't be parsed!"
        case .invalidPhoneNumber:
            "The phone number provided is formatted incorrectly!"
        case .unexpectedApiStateNoErrorAndNoResponse:
            "The API route didn't send down a valid response (No Error / Response Body). Investigate!"
        }
    }
}
