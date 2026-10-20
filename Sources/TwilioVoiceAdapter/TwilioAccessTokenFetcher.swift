//
//  TwilioAccessTokenFetcher.swift
//  TwilioVoicePackage
//
import Foundation

/// Access token server parameters. The app passes them to `TwilioVoiceController`.
public struct TwilioAccessTokenConfiguration {
    /// Token server base URL, e.g. "https://your-token-server.com"
    public let baseURLString: String
    /// Token endpoint, e.g. "/accessToken".
    /// If your token server is written in PHP, it needs .php extension at the end. For example : /accessToken.php
    public let accessTokenEndpoint: String
    /// Client identity the token is issued for
    public let identity: String

    public init(baseURLString: String, accessTokenEndpoint: String, identity: String) {
        self.baseURLString = baseURLString
        self.accessTokenEndpoint = accessTokenEndpoint
        self.identity = identity
    }
}

// TODO: the fetchAccessToken() should be async throws method and use it somwhere in init app section
class TwilioAccessTokenFetcher: NSObject {
    /// Set by `TwilioVoiceController.init(accessTokenConfiguration:)`
    static var configuration: TwilioAccessTokenConfiguration?

    static func fetchAccessToken() -> String {
        enum TokenError: Error {
            case notConfigured
            case wrongUrl
            case wrongToken
            
            func message() -> String {
                switch self {
                case .notConfigured:
                    return "TwilioAccessTokenFetcher: Access token configuration is not set"
                case .wrongUrl:
                    return "TwilioAccessTokenFetcher: Wrong URL"
                case .wrongToken:
                    return "TwilioAccessTokenFetcher: Wrong token"
                }
            }
        }
        
        do {
            guard let configuration else {
                throw TokenError.notConfigured
            }
            guard var urlComponents = URLComponents(string: configuration.baseURLString + configuration.accessTokenEndpoint) else {
                throw TokenError.wrongUrl
            }
            urlComponents.queryItems = [URLQueryItem(name: "identity", value: configuration.identity)]
            guard let accessTokenURL = urlComponents.url else {
                throw TokenError.wrongUrl
            }
            if let accessToken = try? String.init(contentsOf: accessTokenURL, encoding: .utf8) {
                return accessToken
            } else {
                throw TokenError.wrongToken
            }
        } catch {
            if let error = error as? TokenError {
                print(error.message())
            }
            // !!!Fake access token. Don't use it in production
            return "N3BF5Gqg90is9yBCZBIHnMg1pyPvV0J0ANZkz2rjZOU"
        }
    }
}
