//
//  ViewController.swift
//  ScreenCapture
//
//  Created by Jeff on 1/13/18.
//  Copyright © 2018 Jeff Small. All rights reserved.
//

import AVFoundation
import Cocoa

enum CaptureState {
    case running
    case stopped
}

class ViewController: NSViewController {

    @IBOutlet weak var outputTextField: NSTextField!
    @IBOutlet weak var outputTextFieldLabel: NSTextFieldCell!

    var session: AVCaptureSession?
    var movieFileOutput: AVCaptureMovieFileOutput?
    var captureState: CaptureState = .stopped

    // Screen recordings are expected to be in .mov format
    let outputURL = URL(fileURLWithPath: "/Users/Jeff/Desktop/movie.mov")

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func didTapCaptureScreen(_ sender: Any) {
        switch captureState {
        case .stopped:
            recordScreen(outputDestination: outputURL)
        case .running:
            finishRecording()
        }
    }

    func recordScreen(outputDestination: URL) {
        session = AVCaptureSession()
        session?.sessionPreset = .high

        addInput(displayID: CGMainDisplayID(), toSession: session)
        addOutput(AVCaptureMovieFileOutput(), toSession: session)

        // Overwrite any existing file at the output destination
        deleteFileIfExists(at: outputDestination)

        // Start the show 🎥
        session?.startRunning()
        movieFileOutput?.startRecording(to: outputDestination, recordingDelegate: self)
    }

    private func addInput(displayID: CGDirectDisplayID, toSession session: AVCaptureSession?) {
        guard let session = session else {
            fatalError("Could not capture main display input.")
        }

        let input = AVCaptureScreenInput(displayID: displayID)
        if session.canAddInput(input) {
            session.addInput(input)
        }
    }

    private func addOutput(_ output: AVCaptureFileOutput, toSession session: AVCaptureSession?) {
        guard let session = session else {
            return
        }

        if session.canAddOutput(output) {
            session.addOutput(output)
        }
    }

    func deleteFileIfExists(at url: URL) {
        // Delete any existing movie file at the specified destination
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)

            } catch (let error) {
                print("Error removing file at \(url.path): \n\(error)")
            }
        }
    }

    func finishRecording() {
        movieFileOutput?.stopRecording()
    }
}

extension ViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            outputTextField.stringValue = "Screen captured: \(outputURL.path)"
        } else {
            outputTextField.stringValue = "Error capturing screen: \(error?.localizedDescription ?? "")"
        }

        session?.stopRunning()
    }
}
