//
//  EZPlayerAudibleLegibleViewController.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import UIKit
import AVFoundation
public struct  MediaTypes: OptionSet {
    public  let rawValue: Int

    public static let audios = MediaTypes(rawValue: 1 << 0)
    public static let closedCaption = MediaTypes(rawValue: 1 << 1)
    public static let subtitles = MediaTypes(rawValue: 1 << 2)

    public init(rawValue: MediaTypes.RawValue) {
        self.rawValue = rawValue
    }
}
open class EZPlayerAudibleLegibleViewController: UIViewController {
    fileprivate let mediaTypeTableViewIdentifier = "mediaTypeTableViewIdentifier"
    fileprivate let audioTitle = "Audios"
    fileprivate let subtitleTitle = "Subtitles"
    fileprivate let closedCaptionTitle = "CC"
    fileprivate let sectionHeight: CGFloat = 44.0
    fileprivate let cellHeight: CGFloat = 44.0

    fileprivate weak var player: EZPlayer!

    fileprivate var audios: [(audio: AVMediaSelectionOption,localDisplayName: String)]?
    fileprivate var closedCaption: [AVMediaSelectionOption]?
    fileprivate var subtitles: [(subtitle: AVMediaSelectionOption,localDisplayName: String)]?
    fileprivate var mediaTypes: MediaTypes = []

    // MARK: - Life cycle
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?,player: EZPlayer, sourceView: UIView? = nil ,barButtonItem:UIBarButtonItem? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .popover
        guard let popoverPresentationController = self.popoverPresentationController else {
            return
        }
        if sourceView != nil {
            popoverPresentationController.sourceView = sourceView
            popoverPresentationController.sourceRect = sourceView!.bounds
        }
        if barButtonItem != nil {
            popoverPresentationController.barButtonItem = barButtonItem
        }
        popoverPresentationController.permittedArrowDirections = .down
        popoverPresentationController.backgroundColor = UIColor.white
        popoverPresentationController.delegate = self


        self.player = player
        self.audios = self.player.playerasset?.audios
        self.closedCaption = self.player.playerasset?.closedCaption
        self.subtitles = self.player.playerasset?.subtitles


        if let audios = self.audios ,audios.count > 0{
            self.mediaTypes = mediaTypes.union([.audios])
        }
        if let subtitles = self.subtitles ,subtitles.count > 0{
            self.mediaTypes = mediaTypes.union([.subtitles])
        }

        if let closedCaption = self.closedCaption ,closedCaption.count > 0{
            self.mediaTypes = mediaTypes.union([.closedCaption])
        }


    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.player.pause()
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.player.play()
    }

    open override var preferredContentSize: CGSize{
        get{
            var lines = (self.audios?.count ?? 0)
            lines += lines > 0 ? 1 : 0
            var secendLines = (self.subtitles?.count ?? 0) +  (self.closedCaption?.count ?? 0)
            secendLines += secendLines > 0 ? 2 : 0
            return CGSize(width: CGFloat(480), height: CGFloat( (lines + secendLines + 1) * 44 ))
        }
        set{
            super.preferredContentSize = newValue
        }
    }

    // MARK: - Orientations
    override open var shouldAutorotate : Bool {
        return true
    }

    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.all]
    }

}

extension EZPlayerAudibleLegibleViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .none
        }else{
            return .fullScreen
        }
    }

    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .none
        }else{
            return .fullScreen
        }
    }

    public func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navigationController = UINavigationController(rootViewController: controller.presentedViewController)
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissPop))
        navigationController.topViewController!.navigationItem.rightBarButtonItem = btnDone
        return navigationController
    }

    @objc func dismissPop() {
        self.dismiss(animated: true, completion: nil)
    }


}
extension EZPlayerAudibleLegibleViewController: UITableViewDataSource,UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        var num = 0
        if self.mediaTypes.contains(.audios) {
            num += 1
        }
        if self.mediaTypes.contains(.subtitles) || self.mediaTypes.contains(.closedCaption){
            num += 1
        }
        return num
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        if section == 0{
            if self.mediaTypes.contains(.audios) {
                title = self.audioTitle
                return title
            }
        }
        if self.mediaTypes.contains(.subtitles) {
            title = self.subtitleTitle
        }

        if self.mediaTypes.contains(.closedCaption) {
            title += (title == "" ? self.closedCaptionTitle : "&\(self.closedCaptionTitle)")
        }
        return title
    }

    public func  tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return self.sectionHeight
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0
    }


    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var num = 0
        if section == 0{
            if self.mediaTypes.contains(.audios) {
                return self.audios?.count ?? 0
            }
        }
        if self.mediaTypes.contains(.subtitles) {
            num = self.subtitles?.count ?? 0
        }

        if self.mediaTypes.contains(.closedCaption) {
            num += self.closedCaption?.count ?? 0
        }
        return num + 1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell : UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: self.mediaTypeTableViewIdentifier)
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: self.mediaTypeTableViewIdentifier)
        }

        if indexPath.section == 0{
            if self.mediaTypes.contains(.audios) {
                if let audio = self.audios?[indexPath.row]{
                    cell.textLabel?.text = "\(audio.localDisplayName) (\(audio.audio.displayName))"
                    cell.accessoryType = audio.audio == self.player.playerItem?.selectedMediaCharacteristicAudibleOption ? .checkmark : .none
                }
                return cell
            }
        }
        if indexPath.row == 0 {
            cell.textLabel?.text = "None"
            cell.accessoryType = self.player.playerItem?.selectedMediaCharacteristicLegibleOption == nil ? .checkmark : .none
            return cell
        }
        var row = indexPath.row - 1
        if self.mediaTypes.contains(.subtitles) && self.mediaTypes.contains(.closedCaption){
            if let subtitles = self.subtitles , let closedCaption = self.closedCaption{
                if row < subtitles.count {
                    let subtitle = subtitles[row]
                    cell.textLabel?.text = "\(subtitle.localDisplayName) (\(subtitle.subtitle.displayName))"
                    cell.accessoryType = subtitle.subtitle == self.player.playerItem?.selectedSubtitleOption ? .checkmark : .none

                }else{
                    row = row - subtitles.count
                    let closedCaption = closedCaption[row]
                    cell.textLabel?.text = "\(closedCaption.displayName)\(row)"
                    cell.accessoryType = closedCaption == self.player.playerItem?.selectedClosedCaptionOption ? .checkmark : .none

                }
            }
        }else if self.mediaTypes.contains(.subtitles) {
            if  let subtitle = self.subtitles?[row] {
                cell.textLabel?.text = "\(subtitle.localDisplayName) (\(subtitle.subtitle.displayName))"
                cell.accessoryType = subtitle.subtitle == self.player.playerItem?.selectedSubtitleOption ? .checkmark : .none
            }
        }else if self.mediaTypes.contains(.closedCaption) {
            if let closedCaption = self.closedCaption?[row]{
                cell.textLabel?.text = "\(closedCaption.displayName)\(row)"
                cell.accessoryType = closedCaption == self.player.playerItem?.selectedClosedCaptionOption ? .checkmark : .none
            }
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            if self.mediaTypes.contains(.audios) {
                if let audio = self.audios?[indexPath.row]{
                    self.player.playerItem?.selectedMediaCharacteristicAudibleOption = audio.audio
                    tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
                }
                return
            }
        }
        if indexPath.row == 0 {
            self.player.playerItem?.selectedMediaCharacteristicLegibleOption = nil
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            return
        }
        var row = indexPath.row - 1
        if self.mediaTypes.contains(.subtitles) && self.mediaTypes.contains(.closedCaption){
            if let subtitles = self.subtitles , let closedCaption = self.closedCaption{
                if row < subtitles.count {
                    let subtitle = subtitles[row]
                    self.player.playerItem?.selectedSubtitleOption = subtitle.subtitle

                }else{
                    row = row - subtitles.count
                    let closedCaption = closedCaption[row]
                    self.player.playerItem?.selectedClosedCaptionOption = closedCaption


                }
            }
        }else if self.mediaTypes.contains(.subtitles) {
            if  let subtitle = self.subtitles?[row] {
                self.player.playerItem?.selectedSubtitleOption = subtitle.subtitle
            }
        }else if self.mediaTypes.contains(.closedCaption) {
            if let closedCaption = self.closedCaption?[row]{
                self.player.playerItem?.selectedClosedCaptionOption = closedCaption
            }
        }
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
    }

}


