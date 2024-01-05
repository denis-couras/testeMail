//
//  ViewController.swift
//  testeMail
//
//  Created by Denis Couras on 05/12/23.
//

import UIKit
import MessageUI

class ViewController: UIViewController {

    @IBOutlet weak var lblTexto: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
//        setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func setup() {
        let message =
        """
            <p style='font-size: 25; font-family:helvetica;'>Tu <b>nombre completo</b> y <b>número</b> de DNI <i>registrados</i> en Shell Box</p>
        """
        let data = message.data(using: .utf8, allowLossyConversion: true)!

        let attributedString = try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        )

        var attributes = [NSAttributedString.Key : Any]()
        attributes[NSAttributedString.Key.foregroundColor] = UIColor.darkGray
        attributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: 25)

        let labelCreditsAttributes = NSMutableAttributedString(attributedString: attributedString!)

        lblTexto?.numberOfLines = .zero
        lblTexto?.lineBreakMode = .byWordWrapping
        lblTexto?.sizeToFit()

//        labelCreditsAttributes.setAttributedString(attributedString!)

        labelCreditsAttributes.addAttributes(
            attributes,
            range: NSRange(location: 0, length: attributedString?.length ?? 0)
        )
        lblTexto?.attributedText = labelCreditsAttributes
    }

    @IBAction func sendMail(_ sender: Any) {
        sendMail()
    }

    func sendMail() {
        // teste

        let recipientEmail = "dcouras@stefanini.com"
        let subject = "I need help resetting my password"
        let body =
        """
            I would like to report my experience with the App Shell Box\n\n
            [Describe your experience here]\n
            Information related to your device:\n\n

            OS: iOS\n
            OS Version: 17.1.1\n
            App Version: 9.18.61-b8913 PROD rufus\n
            Device: iPhone XR\n
            Date: 12/05/2023\n
        """

        // Show default mail composer
        if !MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([recipientEmail])
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: false)

            present(mail, animated: true)

        } else {
            createEmailUrl(to: recipientEmail, subject: subject, body: body) { url in
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        }

        // teste
    }
}

extension ViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
    }

    private func getURL(mailUrl: URL?) -> URL? {
        guard let url = mailUrl, UIApplication.shared.canOpenURL(url) else {
            return nil
        }
        return url
    }

    private func createEmailUrl(to: String, subject: String, body: String, completion: @escaping ((URL) -> Void)) {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")

        var listURL: [String: URL] = [:]

        if let defaultUrl = getURL(mailUrl: defaultUrl) {
            listURL["Mail"] = defaultUrl
        }

        if let gmailUrl = getURL(mailUrl: gmailUrl) {
            listURL["Gmail"] = gmailUrl
        }

        if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            listURL["Outlook"] = outlookUrl
        }

        if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            listURL["Yahoo"] = yahooMail
        }

        if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            listURL["Spark"] = sparkUrl
        } 

        guard !listURL.isEmpty else {
            completion(defaultUrl!)
            return
        }

        let alert = UIAlertController(title: "Choose email client", message: "", preferredStyle: .actionSheet)
        let sortedKeys = Array(listURL.keys).sorted()

        sortedKeys.forEach { key in
            if let url = listURL[key] {
                let action = UIAlertAction(title: key, style: .default) { _ in
                    completion(url)
                }
                alert.addAction(action)
            }
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)

        // teste

//        let activityViewController = UIActivityViewController(
//            activityItems: ["Choose yout mail client"] as [Any],
//            applicationActivities: nil
//        )
//        activityViewController.popoverPresentationController?.sourceView = self.view
//        activityViewController.setValue(subject, forKey: "subject")
//        activityViewController.excludedActivityTypes = [
//            .addToHomeScreen,
//            .addToReadingList,
//            .airDrop,
//            .assignToContact,
//            .collaborationCopyLink,
//            .collaborationInviteWithLink,
//            .copyToPasteboard,
//            .markupAsPDF,
//            .message,
//            .openInIBooks,
//            .postToFacebook,
//            .postToFlickr,
//            .postToTencentWeibo,
//            .postToTwitter,
//            .postToVimeo,
//            .postToWeibo,
//            .print,
//            .saveToCameraRoll,
//            .sharePlay
//        ]
//        self.present(
//            activityViewController,
//            animated: true,
//            completion: nil
//        )
    }
}

