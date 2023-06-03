//
//  CanvasView.swift
//  PDFLinkPOC
//
//  Created by Dileepa Chandrasekara on 2023-06-03.
//

import UIKit
import PDFKit

class CanvasView: UIView {

    var page: PDFPage?

    init(data: Data) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        page = loadPDFPage(pdfData: data)
    }

    init(pdfPage: PDFPage){
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        page = pdfPage
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadPDFPage(pdfData: Data) -> PDFPage? {

        guard let document = PDFDocument(data: pdfData) else {
            return nil
        }
        return document.page(at: 0)
    }

    override func draw(_ layer: CALayer, in ctx: CGContext) {
        guard let page else {
            return
        }

        if let cgPDFPage = page.pageRef {
            let cropBoxBounds = page.bounds(for: .cropBox)
            print(page.displaysAnnotations)

            let scaleX = layer.bounds.width / cropBoxBounds.width
            let scaleY = layer.bounds.height / cropBoxBounds.height

            ctx.saveGState()

            ctx.scaleBy(x: scaleX, y: scaleY)
            ctx.translateBy(x: -cropBoxBounds.origin.x, y: cropBoxBounds.height + cropBoxBounds.origin.y )
            ctx.scaleBy(x: 1, y: -1)
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.fill(cropBoxBounds)
            ctx.drawPDFPage(cgPDFPage)
            ctx.restoreGState()
        }
    }

    override func draw(_ rect: CGRect) {}
}
