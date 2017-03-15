//
//  EZPlayerFairPlayResourceLoaderDelegate.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2017/3/6.
//  Copyright © 2017年 yangjun zhu. All rights reserved.
//

import Foundation
import AVFoundation
public class EZPlayerFairPlayResourceLoaderDelegate: EZPlayerAVAssetResourceLoaderDelegate {
    fileprivate let resourceLoadingRequestQueue = DispatchQueue(label: "EZPlayer-resourcerequests")
    
    fileprivate let documentURL : URL = {
        guard let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { fatalError("Unable to determine library URL") }
        return URL(fileURLWithPath: documentPath)
    }()
    
    override public var customScheme: String {
        return "skd"
    }
    
    //Returns the Application Certificate needed to generate the Server Playback Context message.
    public var fetchApplicationCertificate: (() -> Data?)?
    
    public var contentKeyFromKeyServerModuleWithSPCData: ((_ spcData: Data, _ assetIDString: String) -> Data?)?
    
    
    public let assetIdentifier: String
    
    public init(asset: AVURLAsset, assetIdentifier: String) {
        
        self.assetIdentifier = assetIdentifier
        super.init(asset: asset, delegateQueue: DispatchQueue(label: "EZPlayer-\(self.assetIdentifier)-FairPlayResourceLoaderDelegate"))
    }
    
    @discardableResult public func deletePersistedConentKeyForAsset() throws -> Bool {
        guard let filePathURLForPersistedContentKey = filePathURLForPersistedContentKey() else {
            return false
        }
        
        try FileManager.default.removeItem(at: filePathURLForPersistedContentKey)
        UserDefaults.standard.removeObject(forKey: "\(self.assetIdentifier)-Key")
        return true
        
    }
    
    
    //    /// Returns the Application Certificate needed to generate the Server Playback Context message.
    //    public func fetchApplicationCertificate() -> Data? {
    //
    //        // MARK: ADAPT: YOU MUST IMPLEMENT THIS METHOD.
    //        let applicationCertificate: Data? = nil
    //
    //        if applicationCertificate == nil {
    //            fatalError("No certificate being returned by \(#function)!")
    //        }
    //
    //
    //        return applicationCertificate
    //    }
    //
    //    public func contentKeyFromKeyServerModuleWithSPCData(spcData: Data, assetIDString: String) -> Data? {
    //
    //        // MARK: ADAPT: YOU MUST IMPLEMENT THIS METHOD.
    //        let ckcData: Data? = nil
    //
    //        if ckcData == nil {
    //            fatalError("No CKC being returned by \(#function)!")
    //        }
    //
    //
    //        return ckcData
    //    }
    
    
    
    
}


// MARK: - AVAssetResourceLoaderDelegate
extension EZPlayerFairPlayResourceLoaderDelegate{
    
    /*
     resourceLoader:shouldWaitForLoadingOfRequestedResource:
     
     When iOS asks the app to provide a CK, the app invokes
     the AVAssetResourceLoader delegate’s implementation of
     its -resourceLoader:shouldWaitForLoadingOfRequestedResource:
     method. This method provides the delegate with an instance
     of AVAssetResourceLoadingRequest, which accesses the
     underlying NSURLRequest for the requested resource together
     with support for responding to the request.
     */
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        
        printLog("was called")
        
        return shouldLoadOrRenewRequestedResource(resourceLoadingRequest: loadingRequest)
    }
    
    
    /*
     resourceLoader: shouldWaitForRenewalOfRequestedResource:
     
     Delegates receive this message when assistance is required of the application
     to renew a resource previously loaded by
     resourceLoader:shouldWaitForLoadingOfRequestedResource:. For example, this
     method is invoked to renew decryption keys that require renewal, as indicated
     in a response to a prior invocation of
     resourceLoader:shouldWaitForLoadingOfRequestedResource:. If the result is
     YES, the resource loader expects invocation, either subsequently or
     immediately, of either -[AVAssetResourceRenewalRequest finishLoading] or
     -[AVAssetResourceRenewalRequest finishLoadingWithError:]. If you intend to
     finish loading the resource after your handling of this message returns, you
     must retain the instance of AVAssetResourceRenewalRequest until after loading
     is finished. If the result is NO, the resource loader treats the loading of
     the resource as having failed. Note that if the delegate's implementation of
     -resourceLoader:shouldWaitForRenewalOfRequestedResource: returns YES without
     finishing the loading request immediately, it may be invoked again with
     another loading request before the prior request is finished; therefore in
     such cases the delegate should be prepared to manage multiple loading
     requests.
     */
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest) -> Bool {
        
        printLog("was called")
        
        return shouldLoadOrRenewRequestedResource(resourceLoadingRequest: renewalRequest)
    }
}


private extension EZPlayerFairPlayResourceLoaderDelegate {
    
    
    func shouldLoadOrRenewRequestedResource(resourceLoadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        
        guard let url = resourceLoadingRequest.request.url else {
            return false
        }
        
        // only should handle FPS Content Key requests.
        if url.scheme != self.customScheme {
            return false
        }
        
        resourceLoadingRequestQueue.async {
            self.prepareAndSendContentKeyRequest(resourceLoadingRequest: resourceLoadingRequest)
        }
        
        return true
    }
    
    func prepareAndSendContentKeyRequest(resourceLoadingRequest: AVAssetResourceLoadingRequest) {
        guard let url = resourceLoadingRequest.request.url, let assetIDString = url.host else {
            printLog("Failed to get url or assetIDString for the request object of the resource.")
            return
        }
        
        func __finishLoading(code: Int, errorDescription: String)  {
            printLog(errorDescription)
            let error = toNSError(code: -1, userInfo: [NSLocalizedDescriptionKey: errorDescription])
            resourceLoadingRequest.finishLoading(with: error)
        }
        
        var shouldPersist = false
        if #available(iOS 9.0, *) {
            shouldPersist = self.asset.resourceLoader.preloadsEligibleContentKeys
            
            // Check if this reuqest is the result of a potential AVAssetDownloadTask.
            if shouldPersist {
                if resourceLoadingRequest.contentInformationRequest != nil {
                    resourceLoadingRequest.contentInformationRequest!.contentType = AVStreamingKeyDeliveryPersistentContentKeyType
                }
                else {
                    __finishLoading(code: -1, errorDescription: "Unable to set contentType on contentInformationRequest.")
                    return
                }
            }
        }
        
        // Check if we have an existing key on disk for this asset.
        if let filePathURLForPersistedContentKey = filePathURLForPersistedContentKey() {
            
            // Verify the file does actually exist on disk.
            if FileManager.default.fileExists(atPath: filePathURLForPersistedContentKey.path) {
                
                do {
                    // Load the contents of the persistedContentKey file.
                    let persistedContentKeyData = try Data(contentsOf: filePathURLForPersistedContentKey)
                    
                    guard let dataRequest = resourceLoadingRequest.dataRequest else {
                        __finishLoading(code: -2, errorDescription: "Error loading contents of content key file.")
                        return
                    }
                    
                    // Pass the persistedContentKeyData into the dataRequest so complete the content key request.
                    dataRequest.respond(with: persistedContentKeyData)
                    resourceLoadingRequest.finishLoading()
                    return
                    
                } catch let error as NSError {
                    printLog("Error initializing Data from contents of URL: \(error.localizedDescription)")
                    resourceLoadingRequest.finishLoading(with: error)
                    return
                }
            }
        }
        
        // Get the application certificate.
        guard let applicationCertificate = self.fetchApplicationCertificate?() else {
            __finishLoading(code: -3, errorDescription: "Error loading application certificate.")
            return
        }
        
        guard let assetIDData = assetIDString.data(using: String.Encoding.utf8) else {
            __finishLoading(code: -4, errorDescription: "errorDescription: Error retrieving Asset ID.")
            return
        }
        
        var resourceLoadingRequestOptions: [String : AnyObject]? = nil
        
        // Check if this reuqest is the result of a potential AVAssetDownloadTask.
        if shouldPersist,#available(iOS 9.0, *)  {
            // Since this request is the result of an AVAssetDownloadTask, we configure the options to request a persistent content key from the KSM.
            resourceLoadingRequestOptions = [AVAssetResourceLoadingRequestStreamingContentKeyRequestRequiresPersistentKey: true as AnyObject]
        }
        
        
        let spcData: Data!
        
        do {
            /*
             To obtain the Server Playback Context (SPC), we call
             AVAssetResourceLoadingRequest.streamingContentKeyRequestData(forApp:contentIdentifier:options:)
             using the information we obtained earlier.
             */
            spcData = try resourceLoadingRequest.streamingContentKeyRequestData(forApp: applicationCertificate, contentIdentifier: assetIDData, options: resourceLoadingRequestOptions)
        } catch let error as NSError {
            printLog("Error obtaining key request data: \(error.domain) reason: \(error.localizedFailureReason)")
            resourceLoadingRequest.finishLoading(with: error)
            return
        }
        
        /*
         Send the SPC message (requestBytes) to the Key Server and get a CKC in reply.
         
         The Key Server returns the CK inside an encrypted Content Key Context (CKC) message in response to
         the app’s SPC message.  This CKC message, containing the CK, was constructed from the SPC by a
         Key Security Module in the Key Server’s software.
         
         When a KSM receives an SPC with a media playback state TLLV, the SPC may include a content key duration TLLV
         in the CKC message that it returns. If the Apple device finds this type of TLLV in a CKC that delivers an FPS
         content key, it will honor the type of rental or lease specified when the key is used.
         */
        guard let ckcData = self.contentKeyFromKeyServerModuleWithSPCData?(spcData,  assetIDString) else {
            
            __finishLoading(code: -5, errorDescription: "Error retrieving CKC from KSM.")
            return
        }
        
        // Check if this reuqest is the result of a potential AVAssetDownloadTask.
        if shouldPersist, #available(iOS 9.0, *){
            // Since this request is the result of an AVAssetDownloadTask, we should get the secure persistent content key.
            var error: NSError?
            
            /*
             Obtain a persistable content key from a context.
             
             The data returned from this method may be used to immediately satisfy an
             AVAssetResourceLoadingDataRequest, as well as any subsequent requests for the same key url.
             
             The value of AVAssetResourceLoadingContentInformationRequest.contentType must be set to AVStreamingKeyDeliveryPersistentContentKeyType when responding with data created with this method.
             */
            let  persistentContentKeyData = resourceLoadingRequest.persistentContentKey(fromKeyVendorResponse: ckcData, options: nil, error: &error)
            
            
            if let error = error {
                printLog("Error creating persistent content key: \(error)")
                resourceLoadingRequest.finishLoading(with: error)
                return
            }
            
            // Save the persistentContentKeyData onto disk for use in the future.
            do {
                let persistentContentKeyURL = documentURL.appendingPathComponent("\(asset.url.hashValue).key")
                
                if persistentContentKeyURL == documentURL {
                    printLog("failed to create the URL for writing the persistent content key")
                    resourceLoadingRequest.finishLoading(with: error)
                    return
                }
                
                do {
                    try persistentContentKeyData.write(to: persistentContentKeyURL, options: Data.WritingOptions.atomicWrite)
                    
                    // Since the save was successful, store the location of the key somewhere to reuse it for future calls.
                    UserDefaults.standard.set("\(asset.url.hashValue).key", forKey: "\(self.assetIdentifier)-Key")
                    
                    guard let dataRequest = resourceLoadingRequest.dataRequest else {
                        printLog("no data is being requested in loadingRequest")
                        let error = NSError(domain: EZPlayerErrorDomain, code: -6, userInfo: [NSLocalizedDescriptionKey: "no data is being requested in loadingRequest"])
                        resourceLoadingRequest.finishLoading(with: error)
                        return
                    }
                    
                    // Provide data to the loading request.
                    dataRequest.respond(with: persistentContentKeyData)
                    resourceLoadingRequest.finishLoading()  // Treat the processing of the request as complete.
                    
                    // Since the request has complete, notify the rest of the app that the content key has been persisted for this asset.
                    
                    NotificationCenter.default.post(name: .EZPlayerDidPersistContentKeyNotification, object: self, userInfo: [Notification.Key.EZPlayerDidPersistAssetIdentifierKey : self.assetIdentifier])
                    
                } catch let error as NSError {
                    printLog("failed writing persisting key to path: \(persistentContentKeyURL) with error: \(error)")
                    resourceLoadingRequest.finishLoading(with: error)
                    return
                }
                
            }
        }else{
            guard let dataRequest = resourceLoadingRequest.dataRequest else {
                __finishLoading(code: -6, errorDescription: "no data is being requested in loadingRequest")
                return
            }
            
            // Provide data to the loading request.
            dataRequest.respond(with: ckcData)
            resourceLoadingRequest.finishLoading()  // Treat the processing of the request as complete.
        }
        
    }
    
    
    func filePathURLForPersistedContentKey() -> URL? {
        var filePathURL: URL?
        
        guard let fileName = UserDefaults.standard.value(forKey: "\(self.assetIdentifier)-Key") as? String else {
            return filePathURL
        }
        
        let url = documentURL.appendingPathComponent(fileName)
        
        if url != documentURL {
            filePathURL = url
        }
        
        return filePathURL
    }
    
    
}


