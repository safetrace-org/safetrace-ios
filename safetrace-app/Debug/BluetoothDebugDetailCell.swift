import SafeTrace
import UIKit

private func makeLabel() -> UILabel {
    let label = UILabel()
    label.font = .bodyRegular
    label.numberOfLines = 0
    return label
}

class BluetoothDebugDetailCell: UITableViewCell {
    let scanDateLabel = makeLabel()
    let traceCreatedDateLabel = makeLabel()
    let uploadedDateLabel = makeLabel()
    let uuidLabel = makeLabel()
    let detailLabel = makeLabel()
    let traceIDLabel = makeLabel()
    let errorLabel = makeLabel()

    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        scanDateLabel.font = .bodyBold

        let stackView = UIStackView(arrangedSubviews: [
            scanDateLabel,
            traceCreatedDateLabel,
            uploadedDateLabel,
            uuidLabel,
            detailLabel,
            traceIDLabel,
            errorLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(record: PeripheralRecord, index: Int) {
        scanDateLabel.text = "\(index + 1). Detected: \(dateFormatter.string(from: record.scanDate))"

        let traceCreatedDisplay = record.traceGeneratedDate != nil
            ? dateFormatter.string(from: record.traceGeneratedDate!)
            : "null"
        traceCreatedDateLabel.text = "Trace Created: \(traceCreatedDisplay)"

        let traceUploadedDisplay = record.traceUploadedDate != nil
            ? dateFormatter.string(from: record.traceUploadedDate!)
            : "null"
        uploadedDateLabel.text = "Uploaded: \(traceUploadedDisplay)"

        uuidLabel.text = "UUID: \(record.uuid.uuidString)"

        detailLabel.text = "RSSI: \(Int(record.rssi)) | Foreground: \(record.foreground) | Skipped: \(record.isSkipped)"

        traceIDLabel.text = "Trace ID: \(record.traceID ?? "null")"

        errorLabel.text = "Error: \(formatError(record.error))"
    }

    private func formatError(_ error: DebugTraceError?) -> String {
        guard let error = error else {
            return "None"
        }

        return "\(error.description) | \(error.context) | \(dateFormatter.string(from: error.createdDate))"
    }
}
