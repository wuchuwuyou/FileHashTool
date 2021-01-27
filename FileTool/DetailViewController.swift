//
//  DetailViewController.swift
//  FileTool
//
//  Created by Murphy on 2021/1/26.
//  Copyright © 2021 Lenovo. All rights reserved.
//

import Cocoa
import CommonCrypto

struct FileModel {
    var name : String = ""
    var path : String = ""
    var size : Int64 = 0
    var formatSize : String = ""
    var fileHash : String = ""
    var permissions : String = ""
    var isDir : Bool = false
    var modifyTime :  String = ""
    var createTime : String = ""
    var icon: NSImage = NSImage()
    mutating func formatData() -> [[String : String]] {
        let n = ["key":"Name","value":self.name]
        let p = ["key":"Path","value":self.path]
        let s = ["key":"Size","value":NSNumber(value: self.size).stringValue]
        let fs = ["key":"FormatSize","value":self.formatSize]
        let ps = ["key":"Permissions","value":self.permissions]
        let m = ["key":"Modify","value":self.modifyTime]
        let c = ["key":"Create","value":self.createTime]
        let d = ["key":"Dir","value":NSNumber(value: self.isDir).stringValue]
        let f = ["key":"MD5","value":self.fileHash]
//        let requiredAttributes = [URLResourceKey.localizedNameKey, URLResourceKey.effectiveIconKey,
//                                  URLResourceKey.typeIdentifierKey, URLResourceKey.contentModificationDateKey,
//                                  URLResourceKey.fileSizeKey, URLResourceKey.isDirectoryKey,
//                                  URLResourceKey.isPackageKey]
//        do {
//            let properties = try NSURL(fileURLWithPath: self.path).resourceValues(forKeys: requiredAttributes)
//            let image = properties[URLResourceKey.effectiveIconKey] as? NSImage  ?? NSImage()
//            self.icon = image
//        } catch  {
//
//        }

        var arr :[[String : String]] = []
        arr.append(n)
        arr.append(p)
        arr.append(s)
        arr.append(fs)
        arr.append(ps)
        arr.append(m)
        arr.append(c)
        arr.append(d)
        arr.append(f)
        return arr
    }
}

class DetailViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    var url:URL = URL(fileURLWithPath: "")  {
        didSet {
            //            self.updateViews()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.updateViews()
    }
    
    var dataSource:[[String : String]] = []
    func updateViews() {
        let lp = self.url.path;
        if lp.isEmpty {
            return
        }
        print(url)
        let title = self.url.lastPathComponent
        self.title = title;
        var model = self.handleFile(url)
        self.dataSource = model.formatData()
        self.tableView.reloadData()
    }
    
    
    func formateDate(_ date:NSDate) -> String {
        let timeZone = NSTimeZone.system
        let interval: TimeInterval = TimeInterval(timeZone.secondsFromGMT())
        let localDate = (date as Date).addingTimeInterval(interval)
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatterGet.string(from: localDate)
    }
    
    func md5File(url: URL) -> Data? {
        
        let bufferSize = 1024 * 1024
        
        do {
            // Open file for reading:
            let file = try FileHandle(forReadingFrom: url)
            defer {
                file.closeFile()
            }
            
            // Create and initialize MD5 context:
            var context = CC_MD5_CTX()
            CC_MD5_Init(&context)
            
            // Read up to `bufferSize` bytes, until EOF is reached, and update MD5 context:
            while autoreleasepool(invoking: {
                let data = file.readData(ofLength: bufferSize)
                if data.count > 0 {
                    data.withUnsafeBytes {
                        _ = CC_MD5_Update(&context, $0.baseAddress, numericCast(data.count))
                    }
                    return true // Continue
                } else {
                    return false // End of file
                }
            }) { }
            
            // Compute the MD5 digest:
            var digest: [UInt8] = Array(repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            _ = CC_MD5_Final(&digest, &context)
            
            return Data(digest)
            
        } catch {
            print("Cannot open file:", error.localizedDescription)
            return nil
        }
    }
    
    
    func handleFile(_ url:URL) -> FileModel {
        var m = FileModel()
        m.path = url.path
        m.name = url.lastPathComponent
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize:NSNumber = fileAttributes[FileAttributeKey.size] as! NSNumber? {
                print("File Size: \(fileSize.uint32Value)")
                m.size = fileSize.int64Value
            }
            let bcf = ByteCountFormatter()
            bcf.countStyle = .file
            bcf.allowedUnits = .useAll
            m.formatSize = bcf.string(fromByteCount: m.size)
            //            -rwx
            m.permissions.append("-")
            if FileManager.default.isReadableFile(atPath: url.path) {
                m.permissions.append("r")
            }else {
                m.permissions.append("-")
            }
            
            if FileManager.default.isWritableFile(atPath: url.path) {
                m.permissions.append("w")
            }else {
                m.permissions.append("-")
            }
            if FileManager.default.isExecutableFile(atPath: url.path) {
                m.permissions.append("x")
            }else {
                m.permissions.append("-")
            }
            
            if let permissions = fileAttributes[FileAttributeKey.posixPermissions] {
                //                m.permissions = permissions
                print("File permissions: \(permissions)")
            }
            
            if let creationDate = fileAttributes[FileAttributeKey.creationDate] {
                print("File Creation Date: \(creationDate)")
                m.createTime = formateDate(creationDate as! NSDate)
            }
            
            if let modificationDate = fileAttributes[FileAttributeKey.modificationDate] {
                print("File Modification Date: \(modificationDate)")
                m.modifyTime = formateDate(modificationDate as! NSDate)
            }
            
            if let type = fileAttributes[FileAttributeKey.type] as? FileAttributeType {
                print("File type: \(type)")
                if type == FileAttributeType.typeDirectory {
                    m.isDir = true
                } else {
                    m.isDir = false
                }
            }
            if let data = md5File(url: url) {
                let hexDigest = data.map { String(format: "%02hhx", $0) }.joined()
                m.fileHash = hexDigest
            }
            
        } catch let error as NSError {
            print("Get attributes errer: \(error)")
        }
        return m
    }
}

extension DetailViewController : NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let dict:[String : String] = self.dataSource[row]
        var image: NSImage?
        var text: String = ""
        var cellIdentifier: String = ""

        if tableColumn == tableView.tableColumns[0] {
      
            if let key = dict["key"] {
                text = key
            }
            cellIdentifier = "cell"
        } else if tableColumn == tableView.tableColumns[1] {

            image = nil
            if let val = dict["value"] {
                text = val
            }
            cellIdentifier = "cell"
        }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            cell.imageView?.image = image ?? nil
            return cell
        }
        return nil

    }
}

extension DetailViewController : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.dataSource.count;
    }
    
//    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
//        
//        let dict:[String : String] = self.dataSource[row]
//        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: self) as! NSTableCellView
//        
//        if (tableColumn != nil) {
//            if tableColumn!.identifier.rawValue == "key" {
//                cell.textField?.stringValue = dict["key"] ?? ""
//            }else {
//                cell.textField?.stringValue = dict["value"] ?? ""
//            }
//        }
//        return cell
//    }
}
