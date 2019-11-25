//
//  NetworkService.swift
//  lior-sdk
//
//  Created by romaAdmin on 13.11.2019.
//  Copyright © 2019 ItWorksinUA. All rights reserved.
//

import Alamofire
import UIKit
// import SwifterSwift

internal extension Dictionary {
    func jsonString(prettify: Bool = false) -> String? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        let options = (prettify == true) ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: options) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
}

open class NetworkService {
    public typealias EmptyClosure = () -> Void
    public typealias ErrorClosure = (Error?) -> Void
    public typealias GenericCallback<T> = (T?, Error?) -> Void
    public typealias ResponseCallback = GenericCallback<Any>

    public static let shared = NetworkService()

    var deviceToken: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
    private(set) var sessionToken: String?

    public var securityCode = "12345"

    public func getSessionToken(_ completion: ErrorClosure?) {
        request(query: .sessionToken(firebaseID: deviceToken, securityCode: securityCode)) { (sessionToken: SessionToken?, error: Error?) in
            if let token = sessionToken?.token {
                self.sessionToken = token
                completion?(nil)
            } else {
                completion?(error)
            }
        }
    }

    public func registerClientDevice(phoneNumber: String, name: String = UIDevice.current.name, completion: GenericCallback<ClientDevice>?) {
        let deviceGuid = UIDevice.current.identifierForVendor!.uuidString

        request(query: .registerClient(registrationID: deviceToken, phoneNumber: phoneNumber, deviceName: name, deviceGuid: deviceGuid), completion)
    }

    public func pullMessageData(status: String, completion: GenericCallback<MessageData>?) {
        request(query: .pullMessage(registrationID: deviceToken, status: status), completion)
    }

    public func sendCallbackData(messageFrom: String, fromDevice: String, toDevice: String, mode: String, status: String, completion: GenericCallback<GenericStatus>?) {
        request(query: .callbackData(registrationID: deviceToken, messageFrom: messageFrom, fromDevice: fromDevice, toDevice: toDevice, mode: mode, status: status), completion)
    }

    public func getCampaignByPhoneNumber(outgoingPhoneNumber: String, completion: GenericCallback<GenericStatus>?) {
        request(query: .campaignByPhoneNumber(registrationID: deviceToken, outgoingPhoneNumber: outgoingPhoneNumber), completion)
    }

    public func respondTopic(fromDevice: String, status: String, completion: GenericCallback<GenericStatus>?) {
        request(query: .respondTopic(registrationID: deviceToken, fromDevice: fromDevice, status: status), completion)
    }

    private func request<T>(query: Query, _ completion: GenericCallback<T>?) where T: Codable, T: BaseResponse {
        Alamofire.upload(multipartFormData: { formData in
            query.params.forEach { arg0 in
                let (key, value) = arg0
                guard let valueStr = value as? String, let data = valueStr.data(using: .utf8, allowLossyConversion: false) else { return }
                formData.append(data, withName: key)
            }
        }, to: query.endpoint, method: query.method, headers: query.headers(sessionToken: sessionToken)) { result in
            switch result {
            case let .success(request, _, _):
                request.responseDecodable(completionHandler: { (response: DataResponse<T>) in
                    switch response.result {
                    case let .success(value):
                        if let status = value.status, let code = status.code.flatMap({ Int($0) }) {
                            if code == 0 {
                                completion?(value, nil)
                                return
                            } else {
                                completion?(nil, self.error(code: code, message: status.msg ?? ""))
                                return
                            }
                        } else {
                            completion?(nil, self.error(code: 404, message: "unknown status"))
                            return
                        }
                    case let .failure(error):
                        completion?(nil, error)
                    }
                })
            case let .failure(error):
                completion?(nil, error)
            }
        }

        #if DEBUG
            let jsonString = query.params.jsonString() ?? ""
            print("-------------------------")
            print("\(query.method.rawValue.uppercased()) \(query.endpoint)")
            let headers = query.headers(sessionToken: sessionToken)
            if !headers.isEmpty {
                print("HEADERS \(headers.jsonString() ?? "")")
            }
            print("PARAMS \(jsonString)")
            print("-------------------------")
        #endif
    }

    private init() {}

    fileprivate enum Query {
        case sessionToken(firebaseID: String, securityCode: String)
        case registerClient(registrationID: String, phoneNumber: String, deviceName: String, deviceGuid: String)
        case pullMessage(registrationID: String, status: String)
        case callbackData(registrationID: String, messageFrom: String, fromDevice: String, toDevice: String, mode: String, status: String)
        case campaignByPhoneNumber(registrationID: String, outgoingPhoneNumber: String)
        case respondTopic(registrationID: String, fromDevice: String, status: String)

        fileprivate var endpoint: String {
            var path: String
            switch self {
            case .sessionToken:
                path = "/getSessionToken"
            case .registerClient:
                path = "/registerClientDevice"
            case .pullMessage:
                path = "/pullMessageData"
            case .callbackData:
                path = "/sendCallbackData"
            case .campaignByPhoneNumber:
                path = "/getCampaignByPhoneNumber"
            case .respondTopic:
                path = "/respondTopic"
            }

            return "https://picup-server-sdk-v2.appspot.com\(path)"
        }

        fileprivate var method: HTTPMethod {
            return .post
        }

        fileprivate func headers(sessionToken: String?) -> HTTPHeaders {
            var headers: HTTPHeaders = [:]
            switch self {
            case .sessionToken:
                break
            default:
                guard let sessionToken = sessionToken else { return headers }
                headers["Authorization"] = "Bearer \(sessionToken)"
                switch self {
                case .callbackData, .respondTopic:
                    headers["User-Agent"] = "PicupSdkMobile"
                default:
                    break
                }
            }
            return headers
        }

        fileprivate var params: Parameters {
            var params: Parameters = [:]
            switch self {
            case let .sessionToken(firebaseID, securityCode):
                params = [
                    "id": firebaseID,
                    "code": securityCode,
                ]
            case let .registerClient(registrationID, _, _, _),
                 let .pullMessage(registrationID, _),
                 let .callbackData(registrationID, _, _, _, _, _),
                 let .campaignByPhoneNumber(registrationID, _),
                 let .respondTopic(registrationID, _, _):
                params["registrationID"] = registrationID

                switch self {
                case let .pullMessage(_, status),
                     let .callbackData(_, _, _, _, _, status),
                     let .respondTopic(_, _, status):
                    params["status"] = status
                default: break
                }

                switch self {
                case let .registerClient(_, phoneNumber, deviceName, deviceGuid):
                    params["phoneNumber"] = phoneNumber
                    params["deviceName"] = deviceName
                    params["deviceGuid"] = deviceGuid
                case let .callbackData(_, messageFrom, fromDevice, toDevice, mode, _):
                    params["messageFrom"] = messageFrom
                    params["fromDevice"] = fromDevice
                    params["toDevice"] = toDevice
                    params["mode"] = mode
                case let .campaignByPhoneNumber(_, outgoingPhoneNumber):
                    params["outgoingPhoneNumber"] = outgoingPhoneNumber
                case let .respondTopic(_, fromDevice, _):
                    params["fromDevice"] = fromDevice
                default: break
                }
            }
            params["organizationCode"] = "\(555)"
            params["sdkVersion"] = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            return params
        }
    }

    fileprivate func error(code: Int, message: String) -> Error {
        return NSError(domain: Bundle.main.bundleIdentifier ?? "lior-sdk-internal", code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }
}

// MARK: - Alamofire response handlers

private extension DataRequest {
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
            decoder.dateDecodingStrategy = .iso8601
        }
        return decoder
    }

    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
            encoder.dateEncodingStrategy = .iso8601
        }
        return encoder
    }

    func decodableResponseSerializer<T: Decodable>() -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            guard error == nil else { return .failure(error!) }

            guard let data = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }

            return Result { try self.decoder.decode(T.self, from: data) }
        }
    }

    @discardableResult
    func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: decodableResponseSerializer(), completionHandler: completionHandler)
    }
}
