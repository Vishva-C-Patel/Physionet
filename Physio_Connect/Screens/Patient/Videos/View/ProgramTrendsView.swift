//
//  ProgramTrendsView.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class ProgramTrendsView: UIView {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let legendStack = UIStackView()
    private let painLegend = LegendDotView(text: "Pain Level", color: .systemOrange)
    private let adherenceLegend = LegendDotView(text: "Adherence", color: .systemBlue)

    private let yAxisLeft = UIStackView()
    private let yAxisRight = UIStackView()
    private let scrollView = UIScrollView()
    private let chartStack = UIStackView()
    private let chartContainer = UIView()
    private let xAxisStack = UIStackView()

    private let chartView = TrendChartView()
    private var chartHeightConstraint: NSLayoutConstraint?
    private let chartInset: CGFloat = 10
    private let axisItemWidth: CGFloat = 36
    private var chartWidthConstraint: NSLayoutConstraint?
    private var dataCount: Int = 0
    private var shouldScrollToLatest = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(painSeries: [Int], adherenceSeries: [Int]) {
        chartView.setData(pain: painSeries, adherence: adherenceSeries)
        let count = max(painSeries.count, adherenceSeries.count)
        dataCount = count
        updateXAxisLabels(count: count)
        shouldScrollToLatest = true
        setNeedsLayout()
    }

    private func build() {
        backgroundColor = .tertiarySystemFill
        layer.cornerRadius = 22
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 8)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.text = "Pain & Progress Trends"

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.text = "Your recovery is trending positively"

        legendStack.translatesAutoresizingMaskIntoConstraints = false
        legendStack.axis = .horizontal
        legendStack.spacing = 16
        legendStack.addArrangedSubview(painLegend)
        legendStack.addArrangedSubview(adherenceLegend)

        yAxisLeft.translatesAutoresizingMaskIntoConstraints = false
        yAxisLeft.axis = .vertical
        yAxisLeft.alignment = .leading
        yAxisLeft.distribution = .equalSpacing
        ["10", "5", "0"].forEach { text in
            let label = axisLabel(text)
            yAxisLeft.addArrangedSubview(label)
        }

        yAxisRight.translatesAutoresizingMaskIntoConstraints = false
        yAxisRight.axis = .vertical
        yAxisRight.alignment = .trailing
        yAxisRight.distribution = .equalSpacing
        ["100", "50", "0"].forEach { text in
            let label = axisLabel(text)
            yAxisRight.addArrangedSubview(label)
        }

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true

        chartStack.translatesAutoresizingMaskIntoConstraints = false
        chartStack.axis = .vertical
        chartStack.spacing = 6

        chartContainer.translatesAutoresizingMaskIntoConstraints = false
        chartContainer.backgroundColor = .clear
        chartContainer.layer.cornerRadius = 12

        chartView.translatesAutoresizingMaskIntoConstraints = false

        xAxisStack.translatesAutoresizingMaskIntoConstraints = false
        xAxisStack.axis = .horizontal
        xAxisStack.distribution = .equalSpacing
        xAxisStack.alignment = .center

        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(legendStack)
        addSubview(yAxisLeft)
        addSubview(yAxisRight)
        addSubview(scrollView)

        scrollView.addSubview(chartStack)
        chartStack.addArrangedSubview(chartContainer)
        chartStack.addArrangedSubview(xAxisStack)
        chartContainer.addSubview(chartView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            legendStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            legendStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            yAxisLeft.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            yAxisRight.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            scrollView.topAnchor.constraint(equalTo: legendStack.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: yAxisLeft.trailingAnchor, constant: 10),
            scrollView.trailingAnchor.constraint(equalTo: yAxisRight.leadingAnchor, constant: -10),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            chartView.topAnchor.constraint(equalTo: chartContainer.topAnchor),
            chartView.leadingAnchor.constraint(equalTo: chartContainer.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: chartContainer.trailingAnchor),
            chartView.bottomAnchor.constraint(equalTo: chartContainer.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            yAxisLeft.topAnchor.constraint(equalTo: chartContainer.topAnchor, constant: chartInset),
            yAxisLeft.bottomAnchor.constraint(equalTo: chartContainer.bottomAnchor, constant: -chartInset),
            yAxisRight.topAnchor.constraint(equalTo: chartContainer.topAnchor, constant: chartInset),
            yAxisRight.bottomAnchor.constraint(equalTo: chartContainer.bottomAnchor, constant: -chartInset)
        ])

        NSLayoutConstraint.activate([
            chartContainer.heightAnchor.constraint(equalToConstant: 140),
            chartStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            chartStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            chartStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            chartStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            chartStack.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        chartWidthConstraint = chartContainer.widthAnchor.constraint(equalToConstant: 0)
        chartWidthConstraint?.isActive = true
        xAxisStack.widthAnchor.constraint(equalTo: chartContainer.widthAnchor).isActive = true
    }

    private func updateXAxisLabels(count: Int) {
        xAxisStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let total = max(count, 1)
        xAxisStack.distribution = total <= 1 ? .fillEqually : .equalSpacing
        for i in 1...total {
            let label = axisLabel("D\(i)")
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 11, weight: .medium)
            xAxisStack.addArrangedSubview(label)
        }
    }

    private func axisLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let total = max(dataCount, 1)
        let desiredWidth = CGFloat(total) * axisItemWidth
        let visibleWidth = max(scrollView.bounds.width, 1)
        chartWidthConstraint?.constant = max(desiredWidth, visibleWidth)
        if shouldScrollToLatest {
            let maxOffsetX = max(scrollView.contentSize.width - scrollView.bounds.width, 0)
            scrollView.setContentOffset(CGPoint(x: maxOffsetX, y: 0), animated: false)
            shouldScrollToLatest = false
        }
    }
}

private final class LegendDotView: UIView {
    private let dot = UIView()
    private let label = UILabel()

    init(text: String, color: UIColor) {
        super.init(frame: .zero)
        label.text = text
        dot.backgroundColor = color
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build() {
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.layer.cornerRadius = 5
        dot.layer.masksToBounds = true

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel

        addSubview(dot)
        addSubview(label)

        NSLayoutConstraint.activate([
            dot.leadingAnchor.constraint(equalTo: leadingAnchor),
            dot.centerYAnchor.constraint(equalTo: centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 10),
            dot.heightAnchor.constraint(equalToConstant: 10),

            label.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

private final class TrendChartView: UIView {

    private var pain: [Int] = []
    private var adherence: [Int] = []

    private let gridLayer = CAShapeLayer()
    private let painLine = CAShapeLayer()
    private let painFill = CAShapeLayer()
    private let adherenceLine = CAShapeLayer()
    private let adherenceFill = CAShapeLayer()
    private let painGradient = CAGradientLayer()
    private let adherenceGradient = CAGradientLayer()
    private var valueLabels: [UILabel] = []
    private let indicatorLine = CAShapeLayer()
    private let indicatorDotPain = CAShapeLayer()
    private let indicatorDotAdherence = CAShapeLayer()
    private let valueLabel = UILabel()
    private var indicatorIndex: Int?
    private let chartInset: CGFloat = 10

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupLayers()
        setupIndicator()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setData(pain: [Int], adherence: [Int]) {
        self.pain = pain
        self.adherence = adherence
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateChart()
    }

    private func setupLayers() {
        gridLayer.lineWidth = 0.8
        gridLayer.lineDashPattern = [2, 4]
        gridLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(gridLayer)

        painLine.strokeColor = UIColor.systemOrange.cgColor
        painLine.lineWidth = 2.2
        painLine.fillColor = UIColor.clear.cgColor
        painLine.lineCap = .round
        painLine.lineJoin = .round

        painGradient.colors = [
            UIColor.systemOrange.withAlphaComponent(0.18).cgColor,
            UIColor.systemOrange.withAlphaComponent(0.0).cgColor
        ]
        painGradient.startPoint = CGPoint(x: 0.5, y: 0)
        painGradient.endPoint = CGPoint(x: 0.5, y: 1)
        painGradient.mask = painFill
        layer.addSublayer(painGradient)
        layer.addSublayer(painLine)

        adherenceLine.strokeColor = UIColor.systemBlue.cgColor
        adherenceLine.lineWidth = 2.2
        adherenceLine.fillColor = UIColor.clear.cgColor
        adherenceLine.lineCap = .round
        adherenceLine.lineJoin = .round

        adherenceGradient.colors = [
            UIColor.systemBlue.withAlphaComponent(0.18).cgColor,
            UIColor.systemBlue.withAlphaComponent(0.0).cgColor
        ]
        adherenceGradient.startPoint = CGPoint(x: 0.5, y: 0)
        adherenceGradient.endPoint = CGPoint(x: 0.5, y: 1)
        adherenceGradient.mask = adherenceFill
        layer.addSublayer(adherenceGradient)
        layer.addSublayer(adherenceLine)
    }

    private func setupIndicator() {
        indicatorLine.lineWidth = 1
        indicatorLine.lineDashPattern = [3, 3]
        indicatorLine.isHidden = true
        layer.addSublayer(indicatorLine)

        indicatorDotPain.fillColor = UIColor.white.cgColor
        indicatorDotPain.strokeColor = UIColor.systemOrange.cgColor
        indicatorDotPain.lineWidth = 2
        indicatorDotPain.isHidden = true
        layer.addSublayer(indicatorDotPain)

        indicatorDotAdherence.fillColor = UIColor.white.cgColor
        indicatorDotAdherence.strokeColor = UIColor.systemBlue.cgColor
        indicatorDotAdherence.lineWidth = 2
        indicatorDotAdherence.isHidden = true
        layer.addSublayer(indicatorDotAdherence)

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        valueLabel.textColor = .systemBackground
        valueLabel.backgroundColor = UIColor.label.withAlphaComponent(0.78)
        valueLabel.layer.cornerRadius = 10
        valueLabel.layer.masksToBounds = true
        valueLabel.textAlignment = .center
        valueLabel.isHidden = true
        addSubview(valueLabel)
    }

    private func setupGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        addGestureRecognizer(pan)

        if #available(iOS 13.4, *) {
            let hover = UIHoverGestureRecognizer(target: self, action: #selector(handleHover(_:)))
            addGestureRecognizer(hover)
        }
    }

    private func updateChart() {
        guard pain.count == adherence.count, pain.count >= 1 else { return }
        gridLayer.strokeColor = UIColor.label.withAlphaComponent(0.15).resolvedColor(with: traitCollection).cgColor

        let chartRect = bounds.insetBy(dx: chartInset, dy: chartInset)
        let stepX = chartRect.width / CGFloat(max(pain.count - 1, 1))

        let gridPath = UIBezierPath()
        let gridRows = 3
        for i in 0..<gridRows {
            let y = chartRect.minY + (chartRect.height / CGFloat(gridRows - 1)) * CGFloat(i)
            gridPath.move(to: CGPoint(x: chartRect.minX, y: y))
            gridPath.addLine(to: CGPoint(x: chartRect.maxX, y: y))
        }
        gridLayer.path = gridPath.cgPath
        gridLayer.frame = bounds

        let painPoints = pointsFor(series: pain, maxValue: 10, rect: chartRect, stepX: stepX)
        let adherencePoints = pointsFor(series: adherence, maxValue: 100, rect: chartRect, stepX: stepX)

        let painPath = makeWavePath(points: painPoints, tension: 1.0)
        painLine.path = painPath.cgPath

        let painFillPath = UIBezierPath(cgPath: painPath.cgPath)
        painFillPath.addLine(to: CGPoint(x: painPoints.last!.x, y: chartRect.maxY))
        painFillPath.addLine(to: CGPoint(x: painPoints.first!.x, y: chartRect.maxY))
        painFillPath.close()
        painFill.path = painFillPath.cgPath
        painGradient.frame = bounds

        let adherencePath = makeWavePath(points: adherencePoints, tension: 1.0)
        adherenceLine.path = adherencePath.cgPath

        let adherenceFillPath = UIBezierPath(cgPath: adherencePath.cgPath)
        adherenceFillPath.addLine(to: CGPoint(x: adherencePoints.last!.x, y: chartRect.maxY))
        adherenceFillPath.addLine(to: CGPoint(x: adherencePoints.first!.x, y: chartRect.maxY))
        adherenceFillPath.close()
        adherenceFill.path = adherenceFillPath.cgPath
        adherenceGradient.frame = bounds

        valueLabels.forEach { $0.removeFromSuperview() }
        valueLabels = []
        if let lastIndex = painPoints.indices.last {
            let painLabel = makeValueLabel(text: "\(pain[lastIndex])", color: .systemOrange)
            let painY = max(painPoints[lastIndex].y - 24, 2)
            painLabel.frame = CGRect(x: painPoints[lastIndex].x - 10, y: painY, width: 22, height: 14)
            addSubview(painLabel)
            valueLabels.append(painLabel)

            let adhLabel = makeValueLabel(text: "\(adherence[lastIndex])", color: .systemBlue)
            let adhY = max(adherencePoints[lastIndex].y - 24, 2)
            adhLabel.frame = CGRect(x: adherencePoints[lastIndex].x - 14, y: adhY, width: 28, height: 14)
            addSubview(adhLabel)
            valueLabels.append(adhLabel)
        }

        if let index = indicatorIndex, index < painPoints.count {
            updateIndicator(at: index, painPoints: painPoints, adherencePoints: adherencePoints, chartRect: chartRect)
        }

        animateLines()
    }

    private func makeValueLabel(text: String, color: UIColor) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textColor = color
        label.textAlignment = .center
        label.text = text
        return label
    }

    private func animateLines() {
        [painLine, adherenceLine, painFill, adherenceFill].forEach { $0.removeAllAnimations() }

        let lineAnim = CABasicAnimation(keyPath: "strokeEnd")
        lineAnim.fromValue = 0
        lineAnim.toValue = 1
        lineAnim.duration = 0.6
        lineAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        painLine.add(lineAnim, forKey: "stroke")
        adherenceLine.add(lineAnim, forKey: "stroke")

        let fillAnim = CABasicAnimation(keyPath: "opacity")
        fillAnim.fromValue = 0
        fillAnim.toValue = 1
        fillAnim.duration = 0.6
        fillAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        painFill.add(fillAnim, forKey: "fill")
        adherenceFill.add(fillAnim, forKey: "fill")
    }

    private func pointsFor(series: [Int], maxValue: Int, rect: CGRect, stepX: CGFloat) -> [CGPoint] {
        series.enumerated().map { index, value in
            let normalized = CGFloat(value) / CGFloat(max(maxValue, 1))
            let x = rect.minX + (CGFloat(index) * stepX)
            let y = rect.maxY - (normalized * rect.height)
            return CGPoint(x: x, y: y)
        }
    }

    // Catmull-Rom to Bezier conversion gives a smooth, sine-like curve.
    private func makeWavePath(points: [CGPoint], tension: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        guard !points.isEmpty else { return path }
        path.move(to: points[0])
        guard points.count > 1 else { return path }

        // With only 2 points, default curves collapse to a straight segment.
        // Force a smooth wave-like bend so the trend chart still looks organic.
        if points.count == 2 {
            let p1 = points[0]
            let p2 = points[1]
            let dx = p2.x - p1.x
            let dy = p2.y - p1.y
            let amplitude = max(8, min(24, abs(dy) * 0.6 + 8))
            let bend: CGFloat = dy >= 0 ? -amplitude : amplitude
            let c1 = CGPoint(x: p1.x + (dx * 0.33), y: p1.y + (dy * 0.15) + bend)
            let c2 = CGPoint(x: p1.x + (dx * 0.66), y: p1.y + (dy * 0.85) - bend)
            path.addCurve(to: p2, controlPoint1: c1, controlPoint2: c2)
            return path
        }

        for i in 0..<(points.count - 1) {
            let p0 = i > 0 ? points[i - 1] : points[i]
            let p1 = points[i]
            let p2 = points[i + 1]
            let p3 = (i + 2 < points.count) ? points[i + 2] : p2

            let c1 = CGPoint(
                x: p1.x + (p2.x - p0.x) * (tension / 6.0),
                y: p1.y + (p2.y - p0.y) * (tension / 6.0)
            )
            let c2 = CGPoint(
                x: p2.x - (p3.x - p1.x) * (tension / 6.0),
                y: p2.y - (p3.y - p1.y) * (tension / 6.0)
            )
            path.addCurve(to: p2, controlPoint1: c1, controlPoint2: c2)
        }
        return path
    }

    private func updateIndicator(at index: Int, painPoints: [CGPoint], adherencePoints: [CGPoint], chartRect: CGRect) {
        let painPoint = painPoints[index]
        let adherencePoint = adherencePoints[index]

        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: painPoint.x, y: chartRect.minY))
        linePath.addLine(to: CGPoint(x: painPoint.x, y: chartRect.maxY))
        indicatorLine.path = linePath.cgPath
        indicatorLine.strokeColor = UIColor.label.withAlphaComponent(0.15).resolvedColor(with: traitCollection).cgColor
        indicatorLine.isHidden = false

        indicatorDotPain.path = UIBezierPath(ovalIn: CGRect(x: painPoint.x - 5, y: painPoint.y - 5, width: 10, height: 10)).cgPath
        indicatorDotPain.isHidden = false

        indicatorDotAdherence.path = UIBezierPath(ovalIn: CGRect(x: adherencePoint.x - 5, y: adherencePoint.y - 5, width: 10, height: 10)).cgPath
        indicatorDotAdherence.isHidden = false

        valueLabel.text = " Pain \(pain[index]) • Adh \(adherence[index]) "
        valueLabel.sizeToFit()
        let labelWidth = max(120, valueLabel.bounds.width + 8)
        valueLabel.frame = CGRect(
            x: min(max(painPoint.x - labelWidth / 2, chartRect.minX), chartRect.maxX - labelWidth),
            y: max(chartRect.minY - 26, 2),
            width: labelWidth,
            height: 20
        )
        valueLabel.isHidden = false
        bringSubviewToFront(valueLabel)
    }

    private func updateIndicator(at location: CGPoint) {
        guard pain.count == adherence.count, pain.count >= 2 else { return }
        let chartRect = bounds.insetBy(dx: chartInset, dy: chartInset)
        guard bounds.contains(location) else { return }
        let stepX = chartRect.width / CGFloat(max(pain.count - 1, 1))
        let clampedX = min(max(location.x, chartRect.minX), chartRect.maxX)
        let rawIndex = Int(round((clampedX - chartRect.minX) / stepX))
        let index = max(0, min(rawIndex, pain.count - 1))
        indicatorIndex = index

        let painPoints = pointsFor(series: pain, maxValue: 10, rect: chartRect, stepX: stepX)
        let adherencePoints = pointsFor(series: adherence, maxValue: 100, rect: chartRect, stepX: stepX)
        updateIndicator(at: index, painPoints: painPoints, adherencePoints: adherencePoints, chartRect: chartRect)
    }

    private func hideIndicator() {
        indicatorLine.isHidden = true
        indicatorDotPain.isHidden = true
        indicatorDotAdherence.isHidden = true
        valueLabel.isHidden = true
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        updateIndicator(at: gesture.location(in: self))
        if gesture.state == .ended || gesture.state == .cancelled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.hideIndicator()
            }
        }
    }

    @objc private func handleHover(_ gesture: UIHoverGestureRecognizer) {
        let location = gesture.location(in: self)
        switch gesture.state {
        case .began, .changed:
            updateIndicator(at: location)
        case .ended, .cancelled:
            hideIndicator()
        default:
            break
        }
    }
}
