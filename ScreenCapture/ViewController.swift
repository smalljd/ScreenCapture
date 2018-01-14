//
//  ViewController.swift
//  ScreenCapture
//
//  Created by Jeff on 1/13/18.
//  Copyright © 2018 Jeff Small. All rights reserved.
//

import AVFoundation
import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var outputTextField: NSTextField!
    @IBOutlet weak var outputTextFieldLabel: NSTextFieldCell!

    var session: AVCaptureSession?
    var movieFileOutput: AVCaptureMovieFileOutput?

    var isRecording = false

    // Screen recordings are expected to be in .mov format
    let outputURL = URL(fileURLWithPath: "/Users/Jeff/Desktop/movie.mov", isDirectory: false)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func didTapCaptureScreen(_ sender: Any) {
        if isRecording {
            finishRecording()
        } else {
            recordScreen(outputDestination: outputURL)
        }

        isRecording = !isRecording
    }

    func recordScreen(outputDestination: URL) {
        session = AVCaptureSession()
        session?.sessionPreset = AVCaptureSessionPresetHigh

        addInput(displayID: CGMainDisplayID(), toSession: session)

        movieFileOutput = AVCaptureMovieFileOutput()

        if session?.canAddOutput(movieFileOutput) == true {
            session?.addOutput(movieFileOutput)
        }

        session?.startRunning()

        // Delete any existing movie file at the specified destination
        if FileManager.default.fileExists(atPath: outputDestination.path) {
            do {
                try FileManager.default.removeItem(at: outputDestination)

            } catch (let error) {
                print("Error removing file at \(outputDestination.path): \n\(error)")
            }
        }

        movieFileOutput?.startRecording(toOutputFileURL: outputDestination,
                                        recordingDelegate: self)
    }

    private func addInput(displayID: CGDirectDisplayID, toSession session: AVCaptureSession?) {
        guard let input = AVCaptureScreenInput(displayID: displayID), let session = session else {
            fatalError("Could not capture main display input.")
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }
    }

    func finishRecording() {
        movieFileOutput?.stopRecording()
    }
}

extension ViewController: AVCaptureFileOutputRecordingDelegate {
    public func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {

        if error == nil {
            outputTextField.stringValue = "Screen captured: \(outputURL.path)"
        } else {
            outputTextField.stringValue = "Error capturing screen: \(error.localizedDescription)"
        }

        session?.stopRunning()
    }
}

