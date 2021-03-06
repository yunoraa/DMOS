//
//  ScanTextView.swift
//  DMOSV4
//
//  Created by Adrian Brambila on 4/26/22.
//

import SwiftUI
import VisionKit
import Vision
import AVFoundation

struct ScanTextView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var recognizedText: String
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedText: $recognizedText, parent: self)
    }
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let documentViewController = VNDocumentCameraViewController()
        documentViewController.delegate = context.coordinator
        return documentViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        // nothing to do here
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var recognizedText: Binding<String>
        var parent: ScanTextView
        
        init(recognizedText: Binding<String>, parent: ScanTextView) {
            self.recognizedText = recognizedText
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            let extractedImages = extractImages(from: scan)
            let processedText = recognizeText(from: extractedImages)
            recognizedText.wrappedValue = processedText
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        fileprivate func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
            var extractedImages = [CGImage]()
            for index in 0..<scan.pageCount {
                let extractedImage = scan.imageOfPage(at: index)
                guard let cgImage = extractedImage.cgImage else { continue }
                
                extractedImages.append(cgImage)
            }
            return extractedImages
        }
        
        fileprivate func recognizeText(from images: [CGImage]) -> String {
            
            var entireRecognizedText = ""
            let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
                guard error == nil else { return }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
                
                let maximumRecognitionCandidates = 1
                for observation in observations {
                    guard let candidate = observation.topCandidates(maximumRecognitionCandidates).first else { continue }
                    
                    entireRecognizedText += "\(candidate.string)\n"
                    
                }
                
            }
            
            recognizeTextRequest.recognitionLevel = .accurate
            
            for image in images {
                let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
                
                try? requestHandler.perform([recognizeTextRequest])
            }
            
            /*  let set1 = Set(entireRecognizedText)
             let set2 = Set("Benadryl")
             let SameElements = set1.intersection(set2)
             var test = String(SameElements)*/
            
            /* let splitTextArray = entireRecognizedText.components(separatedBy: "\n")
             for string in splitTextArray{
             
             if string.contains(Meds().id){
             entireRecognizedText = Meds().id
             }
             }*/
            
            let splitTextArray = entireRecognizedText.components(separatedBy: "\n")
            for string in splitTextArray{
                for i in 0..<Meds().id.count{
                    
                    if string.contains(Meds().id[i]){
                        
                        entireRecognizedText = Meds().id[i]
                        
                    }
                }
                
            }
            
            textToSpeech(myText: entireRecognizedText)
            return entireRecognizedText
            
        }
        
    }
    
}

func textToSpeech(myText: String){
    let synthesizer = AVSpeechSynthesizer()
    let utterance = AVSpeechUtterance(string: myText)
    utterance.volume = 1
    utterance.rate = 0.5
    let voice = AVSpeechSynthesisVoice(language: "en-US")
    utterance.voice = voice
    
    synthesizer.speak(utterance)
    
}

//    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
//        let documentViewController = VNDocumentCameraViewController()
//        documentViewController.delegate = context.coordinator
//        return documentViewController
//    }
//
//    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
//                // nothing to do here
//    }
//
//    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate{
//        var recognizedText: Binding<String>
//        var parent: ScanTextView
//
//        init(recognizedText: Binding<String>, parent: ScanTextView){
//            self.recognizedText = recognizedText
//            self.parent = parent
//        }
//        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
//            //code
//        }
//    }
//    @Binding var recognizeText: String
//    func makeCoordinator() -> Coordinator {
//        Coordinator(recognizedText: $recognizeText, parent: self)
//    }
//
//    fileprivate func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
//        var extractedImages = [CGImage]()
//        for index in 0..<scan.pageCount {
//            let extractedImage = scan.imageOfPage(at: index)
//            guard let cgImage = extractedImage.cgImage else { continue }
//
//            extractedImages.append(cgImage)
//        }
//        return extractedImages
//    }
//
//    fileprivate func recognizeText(from images: [CGImage]) -> String {
//        var entireRecognizedText = ""
//        let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
//            guard error == nil else { return }
//
//            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
//
//            let maximumRecognitionCandidates = 1
//            for observation in observations {
//                guard let candidate = observation.topCandidates(maximumRecognitionCandidates).first else { continue }
//
//                entireRecognizedText += "\\(candidate.string)\\n"
//
//            }
//        }
//        recognizeTextRequest.recognitionLevel = .accurate
//
//        for image in images {
//            let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
//
//            try? requestHandler.perform([recognizeTextRequest])
//        }
//
//        return entireRecognizedText
//    }
//
//    fileprivate func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
//        var extractedImages = [CGImage]()
//        for index in 0..<scan.pageCount {
//            let extractedImage = scan.imageOfPage(at: index)
//            guard let cgImage = extractedImage.cgImage else { continue }
//
//            extractedImages.append(cgImage)
//        }
//        return extractedImages
//    }
//
//
//
//
//    }

