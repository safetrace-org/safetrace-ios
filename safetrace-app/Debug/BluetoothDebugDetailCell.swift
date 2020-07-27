import SafeTrace
import UIKit

class BluetoothDebugDetailCell: UITableViewCell {
    let scanDateLabel = UILabel()
    let traceCreatedDateLabel = UILabel()
    let uploadedDateLabel = UILabel()
    let detailLabel = UILabel()
    let errorLabel = UILabel()

    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        scanDateLabel.font = .bodyBold
        traceCreatedDateLabel.font = .bodyRegular
        uploadedDateLabel.font = .bodyRegular
        detailLabel.font = .bodyRegular
        errorLabel.font = .bodyRegular

        let stackView = UIStackView(arrangedSubviews: [
            scanDateLabel,
            traceCreatedDateLabel,
            uploadedDateLabel,
            detailLabel,
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

    func configure(record: PeripheralRecord) {
        scanDateLabel.text = "Detected: \(dateFormatter.string(from: record.scanDate))"

        let traceCreatedDisplay = record.traceGeneratedDate != nil
            ? dateFormatter.string(from: record.traceGeneratedDate!)
            : "null"
        traceCreatedDateLabel.text = "Trace Created: \(traceCreatedDisplay)"

        let traceUploadedDisplay = record.traceUploadedDate != nil
            ? dateFormatter.string(from: record.traceUploadedDate!)
            : "null"
        uploadedDateLabel.text = "Uploaded: \(traceUploadedDisplay)"

        detailLabel.text = "RSSI: \(Int(record.rssi)) | Foreground: \(record.foreground) | Skipped: \(record.isSkipped)"

        errorLabel.text = "Error: \(formatError(record.error))"
    }

    private func formatError(_ error: DebugTraceError?) -> String {
        guard let error = error else {
            return "None"
        }

        return "\(error.description) | \(error.context) | \(dateFormatter.string(from: error.createdDate))"
    }
}
