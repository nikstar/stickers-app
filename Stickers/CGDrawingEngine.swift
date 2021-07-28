/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The view that is responsible for the drawing. StrokeCGView can draw a StrokeCollection as .calligraphy, .ink or .debug.
*/

import UIKit

class StrokeCGView: UIView {
    
    var strokeCollection: StrokeCollection? {
        didSet {
            if oldValue !== strokeCollection {
                setNeedsDisplay()
                print("needsDisplay")
            }
            if let lastStroke = strokeCollection?.strokes.last {
                setNeedsDisplay(for: lastStroke)
                print("needsDisplayStroke")
            }
            strokeToDraw = strokeCollection?.activeStroke
        }
    }
    
    var strokeToDraw: Stroke? {
        didSet {
            if oldValue !== strokeToDraw && oldValue != nil {
                setNeedsDisplay()
            } else {
                if let stroke = strokeToDraw {
                    setNeedsDisplay(for: stroke)
                }
            }
        }
    }

    let strokeColor = UIColor.systemGreen.withAlphaComponent(0.5)

    // Hold samples when attempting to draw lines that are too short.
    private var heldFromSample: StrokeSample?
    private var heldFromSampleUnitVector: CGVector?

    private var lockedAzimuthUnitVector: CGVector?
    private let azimuthLockAltitudeThreshold = CGFloat.pi / 2.0 * 0.80 // locking azimuth at 80% altitude

    // MARK: - Dirty rect calculation and handling.
    var dirtyRectViews: [UIView]!
    var lastEstimatedSample: (Int, StrokeSample)?
    
    func dirtyRects(for stroke: Stroke) -> [CGRect] {
        var result = [CGRect]()
        for range in stroke.updatedRanges() {
            var lowerBound = range.lowerBound
            if lowerBound > 0 { lowerBound -= 1 }
            
            if let (index, _) = lastEstimatedSample {
                if index < lowerBound {
                    lowerBound = index
                }
            }
            
            let samples = stroke.samples
            var upperBound = range.upperBound
            if upperBound < samples.count { upperBound += 1 }
            let dirtyRect = dirtyRectForSampleStride(stroke.samples[lowerBound..<upperBound])
            result.append(dirtyRect)
        }
        if stroke.predictedSamples.isEmpty == false {
            let dirtyRect = dirtyRectForSampleStride(stroke.predictedSamples[0..<stroke.predictedSamples.count])
            result.append(dirtyRect)
        }
        if let previousPredictedSamples = stroke.previousPredictedSamples {
            let dirtyRect = dirtyRectForSampleStride(previousPredictedSamples[0..<previousPredictedSamples.count])
            result.append(dirtyRect)
        }
        return result
    }

    func dirtyRectForSampleStride(_ sampleStride: ArraySlice<StrokeSample>) -> CGRect {
        var first = true
        var frame = CGRect.zero
        for sample in sampleStride {
            let sampleFrame = CGRect(origin: sample.location, size: .zero)
            if first {
                first = false
                frame = sampleFrame
            } else {
                frame = frame.union(sampleFrame)
            }
        }
        let maxStrokeWidth = CGFloat(20.0)
        return frame.insetBy(dx: -1 * maxStrokeWidth, dy: -1 * maxStrokeWidth)
    }

    func updateDirtyRects(for stroke: Stroke) {
        let updateRanges = stroke.updatedRanges()
        for (index, dirtyRectView) in dirtyRectViews.enumerated() {
            if index < updateRanges.count {
                dirtyRectView.alpha = 1.0
                dirtyRectView.frame = dirtyRectForSampleStride(stroke.samples[updateRanges[index]])
            } else {
                dirtyRectView.alpha = 0.0
            }
        }
    }

    func setNeedsDisplay(for stroke: Stroke) {
        for dirtyRect in dirtyRects(for: stroke) {
            setNeedsDisplay(dirtyRect)
        }
    }
    
    // MARK: - Inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.drawsAsynchronously = true

        let dirtyRectView = { () -> UIView in
            let view = UIView(frame: CGRect(x: -10, y: -10, width: 0, height: 0))
            view.layer.borderColor = UIColor.red.cgColor
            view.layer.borderWidth = 0.5
            view.isUserInteractionEnabled = false
            view.isHidden = true
            self.addSubview(view)
            return view
        }
        dirtyRectViews = [dirtyRectView(), dirtyRectView()]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Drawing methods.

extension StrokeCGView {

    override func draw(_ rect: CGRect) {
        UIColor.clear.set()
        UIRectFill(rect)

        // Optimization opportunity: Draw the existing collection in a different view,
        // and only draw each time we add a stroke.
        if let strokeCollection = strokeCollection {
            for stroke in strokeCollection.strokes {
                draw(stroke: stroke, in: rect)
            }
        }

        if let stroke = strokeToDraw {
            draw(stroke: stroke, in: rect)
        }
    }

}

private extension StrokeCGView {

    /**
     Note: this is not a particularily efficient way to draw a great stroke path
     with CoreGraphics. It is just a way to produce an interesting looking result.
     For a real world example you would reuse and cache CGPaths and draw longer
     paths instead of an awful lot of tiny ones, etc. You would also respect the
     draw rect to cull your draw requests. And you would use bezier paths to
     interpolate between the points to get a smooother curve.
     */
    func draw(stroke: Stroke, in rect: CGRect) {

        stroke.clearUpdateInfo()

        guard stroke.samples.isEmpty == false,
            let context = UIGraphicsGetCurrentContext()
            else { return }

        prepareToDraw()
        lineSettings(in: context)

        if stroke.samples.count == 1 {
            // Construct a fake segment to draw for a stroke that is only one point.
            let sample = stroke.samples.first!
            let tempSampleFrom = StrokeSample(
                timestamp: sample.timestamp,
                location: sample.location + CGVector(dx: -0.5, dy: 0.0),
                coalesced: false,
                predicted: false,
                force: sample.force,
                azimuth: sample.azimuth,
                altitude: sample.altitude,
                estimatedProperties: sample.estimatedProperties,
                estimatedPropertiesExpectingUpdates: [])

            let tempSampleTo = StrokeSample(
                timestamp: sample.timestamp,
                location: sample.location + CGVector(dx: 0.5, dy: 0.0),
                coalesced: false,
                predicted: false,
                force: sample.force,
                azimuth: sample.azimuth,
                altitude: sample.altitude,
                estimatedProperties:
                sample.estimatedProperties,
                estimatedPropertiesExpectingUpdates: [])

            let segment = StrokeSegment(sample: tempSampleFrom)
            segment.advanceWithSample(incomingSample: tempSampleTo)
            segment.advanceWithSample(incomingSample: nil)

            draw(segment: segment, in: context)
        } else {
            for segment in stroke {
                draw(segment: segment, in: context)
            }
        }

    }

    func draw(segment: StrokeSegment, in context: CGContext) {

        guard let toSample = segment.toSample else { return }

        let fromSample: StrokeSample = heldFromSample ?? segment.fromSample

        // Skip line segments that are too short.
        if (fromSample.location - toSample.location).quadrance < 0.003 {
            if heldFromSample == nil {
                heldFromSample = fromSample
                heldFromSampleUnitVector = segment.fromSampleUnitNormal
            }
            return
        }

        fillColor(in: context, toSample: toSample, fromSample: fromSample)
        draw(segment: segment, in: context, toSample: toSample, fromSample: fromSample)

        if heldFromSample != nil {
            heldFromSample = nil
            heldFromSampleUnitVector = nil
        }
    }

    func draw(segment: StrokeSegment,
              in context: CGContext,
              toSample: StrokeSample,
              fromSample: StrokeSample) {

        let unitVector = heldFromSampleUnitVector != nil ? heldFromSampleUnitVector! : segment.fromSampleUnitNormal
        let fromUnitVector = unitVector
        let toUnitVector = segment.toSampleUnitNormal

        lineSettings(in: context)
        
        context.beginPath()
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.setLineWidth(20.0)
        print(contentScaleFactor)
        context.move(to: fromSample.location)
        context.addLine(to: toSample.location)
        context.closePath()
        context.drawPath(using: .fillStroke)
    }


    func prepareToDraw() {
        lastEstimatedSample = nil
        heldFromSample = nil
        heldFromSampleUnitVector = nil
        lockedAzimuthUnitVector = nil
    }

    func lineSettings(in context: CGContext) {
        context.setLineWidth(10)
        context.setLineCap(.round)
        context.setStrokeColor(strokeColor.cgColor)
    }

    func fillColor(in context: CGContext, toSample: StrokeSample, fromSample: StrokeSample) {
        let fillColorRegular = UIColor.systemGreen.withAlphaComponent(0.5).cgColor
        context.setFillColor(fillColorRegular)
    }

}

