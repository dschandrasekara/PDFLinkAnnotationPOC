//
//  ViewController.swift
//  PDFLinkPOC
//
//  Created by Dileepa Chandrasekara on 2023-06-03.
//

import UIKit
import PDFKit

class ViewController: UIViewController {

    var pdfDocument: PDFDocument?

    override func loadView() {
        super.loadView()
    }

    func getData(pdfPage: PDFPage) -> Data {
        let cropBox = pdfPage.bounds(for: .cropBox)
        var adjustedCropBox = cropBox
        if ((pdfPage.rotation == 90) || (pdfPage.rotation == 270) || (pdfPage.rotation == -90)) {
            adjustedCropBox.size = CGSize(width: cropBox.height, height: cropBox.width)
        }

        let renderer = UIGraphicsPDFRenderer(bounds: adjustedCropBox)
        return renderer.pdfData { (ctx) in
            ctx.beginPage()
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.fill(adjustedCropBox)
            pdfPage.transform(ctx.cgContext, for: .cropBox)

            switch pdfPage.rotation {
            case 0:
                ctx.cgContext.translateBy(x: 0, y: adjustedCropBox.height)
                ctx.cgContext.scaleBy(x: 1, y: -1)
            case 90:
                ctx.cgContext.scaleBy(x: 1, y: -1)
                ctx.cgContext.rotate(by: -.pi / 2)
            case 180, -180:
                ctx.cgContext.scaleBy(x: 1, y: -1)
                ctx.cgContext.translateBy(x: adjustedCropBox.width, y: 0)
                ctx.cgContext.rotate(by: .pi)
            case 270, -90:
                ctx.cgContext.translateBy(x: adjustedCropBox.height, y: adjustedCropBox.width)
                ctx.cgContext.rotate(by: .pi / 2)
                ctx.cgContext.scaleBy(x: -1, y: 1)
            default:
                break
            }
            pdfPage.draw(with: .cropBox, to: ctx.cgContext)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        let fileUrl = Bundle.main.url(forResource: "Doc", withExtension: "pdf")
        guard let fileUrl else {
            return
        }
        pdfDocument = PDFDocument(url: fileUrl)
        let firstPage: PDFPage? = pdfDocument?.page(at: 0)
        print("first page annotation count \(firstPage?.annotations.count)")
        guard let firstPage else {
            return
        }
        let pdfData = getData(pdfPage: firstPage)
        let canvasView = CanvasView(data: pdfData)
        self.view.addSubview(canvasView)

        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            canvasView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            canvasView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 0)
        ])
    }
}
