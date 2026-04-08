//
//  HomeProgressCards.swift
//  Physio_Connect
//
//  Created by user@8 on 03/01/26.
//

import UIKit

final class HomePainTrendCardView: UIView {
    private let container = UIView()
    private let iconWrap = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let trendLabel = UILabel()
    private let chartView = LineChartView()
    private let yAxisStack = UIStackView()
    private let titleHeaderStack = UIStackView()
    let leftButton = UIButton(type: .system)
    let rightButton = UIButton(type: .system)
    var onPreviousTapped: (() -> Void)?
    var onNextTapped: (() -> Void)?
    private let xAxisStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(painSeries: [Int], averagePain: Double, percentChange: Int, offsetWeeks: Int = 0) {
        let labels = rollingWeekdayLabels(count: painSeries.count, offsetWeeks: offsetWeeks)
        chartView.configure(series: painSeries, maxValue: 10, lineColor: UIColor(hex: "EF4444"), labels: labels)
        updateXAxisLabels(labels)
        trendLabel.text = String(format: "%.1f", averagePain)
        trendLabel.textColor = UIColor(hex: "16A34A")
    }

    private func build() {
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UITheme.Colors.surface
        container.layer.cornerRadius = 20
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.03
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = CGSize(width: 0, height: 4)
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.separator.cgColor
        addSubview(container)

        iconWrap.translatesAutoresizingMaskIntoConstraints = false
        iconWrap.backgroundColor = UIColor(hex: "FEE2E2")
        iconWrap.layer.cornerRadius = 18

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: "waveform.path.ecg")
        iconView.tintColor = UIColor(hex: "EF4444")
        iconWrap.addSubview(iconView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Pain Level"
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Last 7 days"
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel

        trendLabel.translatesAutoresizingMaskIntoConstraints = false
        trendLabel.font = .systemFont(ofSize: 14, weight: .bold)
        trendLabel.textAlignment = .right

        titleHeaderStack.translatesAutoresizingMaskIntoConstraints = false
        titleHeaderStack.axis = .horizontal
        titleHeaderStack.spacing = 16
        titleHeaderStack.alignment = .center

        leftButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        leftButton.tintColor = .secondaryLabel
        rightButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        rightButton.tintColor = .secondaryLabel

        leftButton.addTarget(self, action: #selector(didTapLeft), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(didTapRight), for: .touchUpInside)

        titleHeaderStack.addArrangedSubview(leftButton)
        titleHeaderStack.addArrangedSubview(rightButton)

        yAxisStack.translatesAutoresizingMaskIntoConstraints = false
        yAxisStack.axis = .vertical
        yAxisStack.alignment = .leading
        yAxisStack.distribution = .equalSpacing
        let yLabels = ["10", "5", "0"]
        yLabels.forEach {
            let label = UILabel()
            label.text = $0
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textColor = .tertiaryLabel
            yAxisStack.addArrangedSubview(label)
        }

        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.backgroundColor = UIColor.tertiarySystemFill
        chartView.layer.cornerRadius = 12

        xAxisStack.translatesAutoresizingMaskIntoConstraints = false
        xAxisStack.axis = .horizontal
        xAxisStack.distribution = .equalSpacing
        updateXAxisLabels(rollingWeekdayLabels(count: 7, offsetWeeks: 0))

        container.addSubview(iconWrap)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(trendLabel)
        container.addSubview(titleHeaderStack)
        container.addSubview(yAxisStack)
        container.addSubview(chartView)
        container.addSubview(xAxisStack)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            iconWrap.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            iconWrap.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconWrap.widthAnchor.constraint(equalToConstant: 36),
            iconWrap.heightAnchor.constraint(equalToConstant: 36),

            iconView.centerXAnchor.constraint(equalTo: iconWrap.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconWrap.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconWrap.trailingAnchor, constant: 12),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            trendLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            trendLabel.trailingAnchor.constraint(equalTo: titleHeaderStack.leadingAnchor, constant: -16),
            
            titleHeaderStack.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            titleHeaderStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            yAxisStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 14),
            yAxisStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            yAxisStack.heightAnchor.constraint(equalToConstant: 120),

            chartView.topAnchor.constraint(equalTo: yAxisStack.topAnchor),
            chartView.leadingAnchor.constraint(equalTo: yAxisStack.trailingAnchor, constant: 10),
            chartView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalToConstant: 120),

            xAxisStack.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 6),
            xAxisStack.leadingAnchor.constraint(equalTo: chartView.leadingAnchor),
            xAxisStack.trailingAnchor.constraint(equalTo: chartView.trailingAnchor),
            xAxisStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
    }

    @objc private func didTapLeft() { onPreviousTapped?() }
    @objc private func didTapRight() { onNextTapped?() }

    private func updateXAxisLabels(_ labels: [String]) {
        xAxisStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        labels.forEach { text in
            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 11, weight: .medium)
            label.textColor = .tertiaryLabel
            xAxisStack.addArrangedSubview(label)
        }
    }

    private func rollingWeekdayLabels(count: Int, offsetWeeks: Int) -> [String] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        formatter.dateFormat = "EEE"
        let currentDayRaw = calendar.startOfDay(for: Date())
        let today = calendar.date(byAdding: .day, value: -(offsetWeeks * 7), to: currentDayRaw) ?? currentDayRaw
        let safeCount = max(count, 1)
        return (0..<safeCount).map { offset in
            let shift = offset - (safeCount - 1)
            let date = calendar.date(byAdding: .day, value: shift, to: today) ?? today
            return formatter.string(from: date)
        }
    }
}

final class HomeAdherenceCardView: UIView {
    private let container = UIView()
    private let titleLabel = UILabel()
    private let percentLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let chartView = LineChartView()
    private let yAxisStack = UIStackView()
    private let titleHeaderStack = UIStackView()
    let leftButton = UIButton(type: .system)
    let rightButton = UIButton(type: .system)
    var onPreviousTapped: (() -> Void)?
    var onNextTapped: (() -> Void)?
    private let xAxisStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(adherenceSeries: [Int], weeklyPercent: Int, offsetWeeks: Int = 0) {
        percentLabel.text = "\(weeklyPercent)%"
        let labels = rollingWeekLabels(count: adherenceSeries.count, offsetWeeks: offsetWeeks)
        chartView.configure(series: adherenceSeries, maxValue: 100, lineColor: UIColor(hex: "0EA5E9"), labels: labels)
        updateXAxisLabels(labels)
    }

    private func build() {
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UITheme.Colors.surface
        container.layer.cornerRadius = 20
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.03
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = CGSize(width: 0, height: 4)
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.separator.cgColor
        addSubview(container)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Weekly Adherence"
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label

        percentLabel.translatesAutoresizingMaskIntoConstraints = false
        percentLabel.font = .systemFont(ofSize: 26, weight: .bold)
        percentLabel.textColor = UIColor(hex: "0284C7")

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "this week"
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel

        titleHeaderStack.translatesAutoresizingMaskIntoConstraints = false
        titleHeaderStack.axis = .horizontal
        titleHeaderStack.spacing = 16
        titleHeaderStack.alignment = .center

        leftButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        leftButton.tintColor = .secondaryLabel
        rightButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        rightButton.tintColor = .secondaryLabel

        leftButton.addTarget(self, action: #selector(didTapLeft), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(didTapRight), for: .touchUpInside)

        titleHeaderStack.addArrangedSubview(leftButton)
        titleHeaderStack.addArrangedSubview(rightButton)

        yAxisStack.translatesAutoresizingMaskIntoConstraints = false
        yAxisStack.axis = .vertical
        yAxisStack.alignment = .leading
        yAxisStack.distribution = .equalSpacing
        let yLabels = ["100", "50", "0"]
        yLabels.forEach {
            let label = UILabel()
            label.text = $0
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textColor = .tertiaryLabel
            yAxisStack.addArrangedSubview(label)
        }

        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.backgroundColor = UIColor.tertiarySystemFill
        chartView.layer.cornerRadius = 12

        xAxisStack.translatesAutoresizingMaskIntoConstraints = false
        xAxisStack.axis = .horizontal
        xAxisStack.distribution = .equalSpacing
        updateXAxisLabels(rollingWeekLabels(count: 6, offsetWeeks: 0))

        container.addSubview(titleLabel)
        container.addSubview(titleHeaderStack)
        container.addSubview(percentLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(yAxisStack)
        container.addSubview(chartView)
        container.addSubview(xAxisStack)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            titleHeaderStack.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            titleHeaderStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            percentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            percentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            subtitleLabel.leadingAnchor.constraint(equalTo: percentLabel.trailingAnchor, constant: 8),
            subtitleLabel.bottomAnchor.constraint(equalTo: percentLabel.bottomAnchor, constant: -2),

            yAxisStack.topAnchor.constraint(equalTo: percentLabel.bottomAnchor, constant: 12),
            yAxisStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            yAxisStack.heightAnchor.constraint(equalToConstant: 110),

            chartView.topAnchor.constraint(equalTo: yAxisStack.topAnchor),
            chartView.leadingAnchor.constraint(equalTo: yAxisStack.trailingAnchor, constant: 10),
            chartView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalToConstant: 110),

            xAxisStack.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 6),
            xAxisStack.leadingAnchor.constraint(equalTo: chartView.leadingAnchor),
            xAxisStack.trailingAnchor.constraint(equalTo: chartView.trailingAnchor),
            xAxisStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func didTapLeft() { onPreviousTapped?() }
    @objc private func didTapRight() { onNextTapped?() }

    private func updateXAxisLabels(_ labels: [String]) {
        xAxisStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        labels.forEach { text in
            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 11, weight: .medium)
            label.textColor = .tertiaryLabel
            xAxisStack.addArrangedSubview(label)
        }
    }

    private func rollingWeekLabels(count: Int, offsetWeeks: Int) -> [String] {
        let calendar = Calendar.current
        let currentDayRaw = calendar.startOfDay(for: Date())
        let today = calendar.date(byAdding: .day, value: -(offsetWeeks * 7), to: currentDayRaw) ?? currentDayRaw
        let safeCount = max(count, 1)
        return (0..<safeCount).map { offset in
            let shift = offset - (safeCount - 1)
            let date = calendar.date(byAdding: .weekOfYear, value: shift, to: today) ?? today
            let week = calendar.component(.weekOfYear, from: date)
            return "W\(week)"
        }
    }
}

final class LineChartView: UIView {
    private var series: [Int] = []
    private var maxValue: Int = 10
    private var lineColor: UIColor = .systemBlue
    private var labels: [String] = []

    private let gridLayer = CAShapeLayer()
    private let fillLayer = CAShapeLayer()
    private let lineLayer = CAShapeLayer()
    private var dotLayers: [CAShapeLayer] = []
    private let indicatorLine = CAShapeLayer()
    private let indicatorDot = CAShapeLayer()
    private let valueLabel = UILabel()
    private var indicatorIndex: Int?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        setupLayers()
        setupIndicator()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(series: [Int], maxValue: Int, lineColor: UIColor, labels: [String] = []) {
        self.series = series
        self.maxValue = max(1, maxValue)
        self.lineColor = lineColor
        self.labels = labels
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updatePaths(animated: true)
    }

    private func setupLayers() {
        gridLayer.strokeColor = UIColor.separator.cgColor
        gridLayer.lineWidth = 1
        gridLayer.fillColor = UIColor.clear.cgColor
        gridLayer.lineDashPattern = [3, 3]
        layer.addSublayer(gridLayer)

        fillLayer.fillColor = lineColor.withAlphaComponent(0.10).cgColor
        layer.addSublayer(fillLayer)

        lineLayer.strokeColor = lineColor.cgColor
        lineLayer.lineWidth = 2.5
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineCap = .round
        lineLayer.lineJoin = .round
        layer.addSublayer(lineLayer)
    }

    private func setupIndicator() {
        indicatorLine.strokeColor = UIColor.separator.cgColor
        indicatorLine.lineWidth = 1
        indicatorLine.lineDashPattern = [3, 3]
        indicatorLine.isHidden = true
        layer.addSublayer(indicatorLine)

        indicatorDot.fillColor = UIColor.white.cgColor
        indicatorDot.strokeColor = lineColor.cgColor
        indicatorDot.lineWidth = 2
        indicatorDot.isHidden = true
        layer.addSublayer(indicatorDot)

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        valueLabel.textColor = .white
        valueLabel.backgroundColor = UIColor.black.withAlphaComponent(0.78)
        valueLabel.layer.cornerRadius = 10
        valueLabel.layer.masksToBounds = true
        valueLabel.textAlignment = .center
        valueLabel.isHidden = true
        addSubview(valueLabel)
    }

    private func setupGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        addGestureRecognizer(pan)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0
        longPress.allowableMovement = 10
        addGestureRecognizer(longPress)

        if #available(iOS 13.4, *) {
            let hover = UIHoverGestureRecognizer(target: self, action: #selector(handleHover(_:)))
            addGestureRecognizer(hover)
        }
    }

    private func updatePaths(animated: Bool) {
        guard series.count >= 2 else { return }

        let inset: CGFloat = 10
        let chartRect = bounds.insetBy(dx: inset, dy: inset)
        let stepX = chartRect.width / CGFloat(max(series.count - 1, 1))

        let points: [CGPoint] = series.enumerated().map { idx, value in
            let percent = CGFloat(value) / CGFloat(maxValue)
            let y = chartRect.maxY - (chartRect.height * percent)
            return CGPoint(x: chartRect.minX + CGFloat(idx) * stepX, y: y)
        }

        let gridPath = UIBezierPath()
        let gridRows = 3
        for i in 0..<gridRows {
            let y = chartRect.minY + (chartRect.height / CGFloat(gridRows - 1)) * CGFloat(i)
            gridPath.move(to: CGPoint(x: chartRect.minX, y: y))
            gridPath.addLine(to: CGPoint(x: chartRect.maxX, y: y))
        }
        gridLayer.path = gridPath.cgPath

        let smoothPath = makeMonotonePath(points: points)
        lineLayer.strokeColor = lineColor.cgColor
        lineLayer.path = smoothPath.cgPath

        let fillPath = UIBezierPath(cgPath: smoothPath.cgPath)
        fillPath.addLine(to: CGPoint(x: points.last!.x, y: chartRect.maxY))
        fillPath.addLine(to: CGPoint(x: points.first!.x, y: chartRect.maxY))
        fillPath.close()
        fillLayer.fillColor = lineColor.withAlphaComponent(0.14).cgColor
        fillLayer.path = fillPath.cgPath

        dotLayers.forEach { $0.removeFromSuperlayer() }
        dotLayers = points.map { point in
            let dot = CAShapeLayer()
            let dotRect = CGRect(x: point.x - 3, y: point.y - 3, width: 6, height: 6)
            dot.path = UIBezierPath(ovalIn: dotRect).cgPath
            dot.fillColor = lineColor.cgColor
            layer.addSublayer(dot)
            return dot
        }

        if let index = indicatorIndex, index < points.count {
            updateIndicator(at: index, points: points, chartRect: chartRect)
        }

        if animated {
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = 0
            anim.toValue = 1
            anim.duration = 0.6
            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            lineLayer.add(anim, forKey: "line")
            fillLayer.add(anim, forKey: "fill")
        }
    }

    private func makeMonotonePath(points: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath()
        guard points.count > 1 else { return path }
        path.move(to: points[0])

        let count = points.count
        var slopes = [CGFloat](repeating: 0, count: count - 1)
        var tangents = [CGFloat](repeating: 0, count: count)

        for i in 0..<(count - 1) {
            let dx = points[i + 1].x - points[i].x
            let dy = points[i + 1].y - points[i].y
            slopes[i] = dx == 0 ? 0 : dy / dx
        }

        tangents[0] = slopes[0]
        tangents[count - 1] = slopes[count - 2]
        if count > 2 {
            for i in 1..<(count - 1) {
                if slopes[i - 1] * slopes[i] <= 0 {
                    tangents[i] = 0
                } else {
                    tangents[i] = (slopes[i - 1] + slopes[i]) / 2
                }
            }
        }

        for i in 0..<(count - 1) {
            let p0 = points[i]
            let p1 = points[i + 1]
            let dx = p1.x - p0.x
            let c1 = CGPoint(x: p0.x + dx / 3, y: p0.y + tangents[i] * dx / 3)
            let c2 = CGPoint(x: p1.x - dx / 3, y: p1.y - tangents[i + 1] * dx / 3)
            path.addCurve(to: p1, controlPoint1: c1, controlPoint2: c2)
        }
        return path
    }

    private func updateIndicator(at index: Int, points: [CGPoint], chartRect: CGRect) {
        let point = points[index]

        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: point.x, y: chartRect.minY))
        linePath.addLine(to: CGPoint(x: point.x, y: chartRect.maxY))
        indicatorLine.path = linePath.cgPath
        indicatorLine.isHidden = false

        let dotRect = CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10)
        indicatorDot.path = UIBezierPath(ovalIn: dotRect).cgPath
        indicatorDot.strokeColor = lineColor.cgColor
        indicatorDot.isHidden = false

        let labelText = (index < labels.count ? labels[index] + " • " : "") + "\(series[index])"
        valueLabel.text = " \(labelText) "
        valueLabel.sizeToFit()
        let labelWidth = max(30, valueLabel.bounds.width + 8)
        valueLabel.frame = CGRect(
            x: min(max(point.x - labelWidth / 2, chartRect.minX), chartRect.maxX - labelWidth),
            y: max(chartRect.minY - 26, 2),
            width: labelWidth,
            height: 20
        )
        valueLabel.isHidden = false
    }

    private func hideIndicator() {
        indicatorIndex = nil
        indicatorLine.isHidden = true
        indicatorDot.isHidden = true
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

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        updateIndicator(at: gesture.location(in: self))
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            hideIndicator()
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

    private func updateIndicator(at location: CGPoint) {
        guard series.count >= 1 else { return }
        let inset: CGFloat = 10
        let chartRect = bounds.insetBy(dx: inset, dy: inset)
        guard bounds.contains(location) else { return }

        let count = max(series.count, 1)
        let stepX = count > 1 ? chartRect.width / CGFloat(count - 1) : 0
        let clampedX = min(max(location.x, chartRect.minX), chartRect.maxX)
        let rawIndex = stepX == 0 ? 0 : Int(round((clampedX - chartRect.minX) / stepX))
        let index = max(0, min(rawIndex, series.count - 1))
        indicatorIndex = index

        let points: [CGPoint] = series.enumerated().map { idx, value in
            let percent = CGFloat(value) / CGFloat(maxValue)
            let y = chartRect.maxY - (chartRect.height * percent)
            return CGPoint(x: chartRect.minX + CGFloat(idx) * stepX, y: y)
        }
        updateIndicator(at: index, points: points, chartRect: chartRect)
        bringSubviewToFront(valueLabel)
    }
}
