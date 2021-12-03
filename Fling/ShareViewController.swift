//
//  ShareViewController.swift
//  Bark
//
//  Created by Digit on 11/23/21.
//

import Cocoa

class ShareViewController: NSViewController {
    
    // UI Binding Attributes
    @objc dynamic var uploading = false;
    @objc dynamic var disableButtons = true;
    @objc dynamic var tabViewIndex = 0;
    @objc dynamic var errorMessage = "Unknown Error!";
    
    var fileURL: URL? = nil;
    
    // Global pasteboard
    let pasteboard = NSPasteboard.general
    
    override var nibName: NSNib.Name? {
        return NSNib.Name("ShareViewController")
    }
    
    override func loadView() {
        super.loadView()
        
        let item = self.extensionContext!.inputItems[0] as! NSExtensionItem
        if let attachments = item.attachments {
            for attachment in attachments {
                let provider = attachment as NSItemProvider
                
                NSLog(provider.registeredTypeIdentifiers.description)
                
                // Ensure this is a quicktime movie file
                if !provider.registeredTypeIdentifiers.contains("public.file-url") {
                    errorWithDelay(errorType: .noValidFileFound)
                    return
                }
                
                // Load the file url into the controller context
                provider.loadItem(forTypeIdentifier: "public.file-url") { item, _ in
                    self.fileURL = URL.init(dataRepresentation: item as! Data, relativeTo: nil)
                    self.disableButtons = false
                }
            }
        } else {
            errorWithDelay(errorType: .noValidFileFound)
        }
    }
    
    func finishWithDelay() {
        // Change the subview using the tab index
        DispatchQueue.main.async {
            self.tabViewIndex = 1
        }
        
        // Dispatch share complete after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.extensionContext!.completeRequest(returningItems: nil)
        }
    }
    
    func errorWithDelay(errorType: BarkErrorType) {
        let message = translateError(errorValue: errorType)
        
        DispatchQueue.main.async {
            self.errorMessage = message
            self.tabViewIndex = 2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.cancel(nil)
        }
    }
    
    func doUpload() {
        if let unwrappedUrl = self.fileURL {
            sendFile(fileURL: unwrappedUrl) { uploadResult in
                switch uploadResult {
                case .success(let shortCode):
                    self.pasteboard.clearContents()
                    self.pasteboard.setString("https://streamable.com/\(shortCode)", forType: NSPasteboard.PasteboardType.string)
                    self.finishWithDelay()
                case .failure(let errorType):
                    self.errorWithDelay(errorType: errorType)
                }
            }
        }
    }
    
    // Button Callbacks
    
    @IBAction func send(_ sender: AnyObject?) {
        self.uploading = true;
        self.disableButtons = true;
        self.doUpload()
    }
    
    @IBAction func cancel(_ sender: AnyObject?) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }
}

