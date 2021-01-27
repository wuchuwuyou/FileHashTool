//
//  ViewController.swift
//  FileTool
//
//  Created by Murphy on 2021/1/26.
//  Copyright © 2021 Lenovo. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var reviceView: DestinationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.reviceView.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    func handleURLS(_ urls:[URL]) {
        for (_,url) in urls.enumerated() {
            if url.isFileURL {
                let detail = self.storyboard?.instantiateController(withIdentifier: "DetailViewController") as! DetailViewController
//                let detail = DetailViewController(nibName: nil, bundle: nil)
                detail.url = url
                let window = NSWindow(contentViewController: detail)
                window.orderFront(nil)
            }
        }
    }
}

extension ViewController:DestinationViewDelegate {
    func processURLs(_ urls: [URL]) {
        self.handleURLS(urls);
    }
}
