//
// Wire
// Copyright (C) 2018 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import Foundation

private let zmLog = ZMSLog(tag: "ImageMessageCell")

extension ImageMessageCell {
    override open func configure(for convMessage: ZMConversationMessage?, layoutProperties: ConversationCellLayoutProperties?) {
        guard let convMessage = convMessage else { return }
        guard Message.isImage(convMessage) else { return }

        super.configure(for: convMessage, layoutProperties: layoutProperties)
        let imageMessageData: ZMImageMessageData? = convMessage.imageMessageData
        // request
        convMessage.requestImageDownload()
        // there is no harm in calling this if the full content is already available
        let minimumMediaSize: CGFloat = 48.0
        originalImageSize = size(forMessage: imageMessageData)
        imageSize = CGSize(width: max(minimumMediaSize, originalImageSize.width), height: max(minimumMediaSize, originalImageSize.height))
        if autoStretchVertically {
            fullImageView.contentMode = imageSmallerThanMinimumSize() ? .left : .scaleAspectFill
        } else if showsPreview {
            let isSmall: Bool = imageSize.height < PreviewHeightCalculator.standardCellHeight
            fullImageView.contentMode = isSmall ? .scaleAspectFit : .scaleAspectFill
        } else {
            fullImageView.contentMode = .scaleAspectFill
        }

        updateImageBorder()
        imageToolbarView.showsSketchButton = !(imageMessageData?.isAnimatedGIF)!
        imageToolbarView.imageIsEphemeral = convMessage.isEphemeral
        imageToolbarView.isPlacedOnImage = imageToolbarFitsInsideImage()
        imageToolbarView.configuration = imageToolbarNeedsToBeCompact() ? .compactCell : .cell
        updateImageMessageConstraintConstants()

        if let imageData = imageMessageData?.imageData, imageData.count > 0 {
            let isAnimatedGIF: Bool = imageMessageData!.isAnimatedGIF ///TODO: why first call is not animated?

            print("🏀 time = \(Date().timeIntervalSince1970) isAnimatedGIF =\(isAnimatedGIF)")

            let creationBlock = { [weak self] (_ data: Data?) -> Any? in
                var image: Any? = nil

                print("🏉 time = \(Date().timeIntervalSince1970) isAnimatedGIF =\(isAnimatedGIF)")

                if let data = data {
                    print("⚽ time = \(Date().timeIntervalSince1970) isAnimatedGIF =\(isAnimatedGIF)")

                    if isAnimatedGIF {
                        // We MUST make a copy of the data here because FLAnimatedImage doesn't read coredata blobs efficiently

                        let copy = Data(data) // data.copy //Data(bytes: data.bytes, count: data.count)
                        image = FLAnimatedImage(animatedGIFData: copy)
                    } else {
                        /// hits 2 times here
                        let screenSize: CGSize = UIScreen.main.nativeBounds.size
                        var widthRatio: CGFloat = 0
                        var minimumHeight: CGFloat = 0
                        if let width = self?.imageSize.width, let height = self?.imageSize.height {
                            widthRatio = min(screenSize.width / width, 1.0)
                            minimumHeight = height * widthRatio
                        } else {
                            widthRatio = 1
                        }

                        let maxSize: CGFloat = max(screenSize.width, minimumHeight)
                        image = UIImage(from: data, withMaxSize: maxSize)
                    }
                }

                if image == nil {
                    zmLog.debug("Invalid image data returned from sync engine!")
                }
                return image
            }

            let completion = {[weak self] (_ image: Any?, _ cacheKey: String?) -> Void in
                print("🎾 time = \(Date().timeIntervalSince1970), cacheKey=\(String(describing: cacheKey)) isAnimatedGIF =\(isAnimatedGIF), image = \(String(describing: image))")
                if image != nil && self?.message != nil && cacheKey != nil && (cacheKey == Message.nonNilImageDataIdentifier(self?.message)) {
                    self?.setImage(image as! MediaAsset)
                } else {
                    zmLog.debug("finished loading image but cell is no longer on screen.")
                }

            }

            ///FIXME: creationBlock is not called after second refresh, isAnimatedGIF == true
            ImageMessageCell.imageCache().removeImage(forCacheKey: Message.nonNilImageDataIdentifier(convMessage))
            ImageMessageCell.imageCache().image(for: imageData, cacheKey: Message.nonNilImageDataIdentifier(convMessage), creationBlock: creationBlock, completion: completion)
        } else {
            if convMessage.isObfuscated {
                loadingView.isHidden = true
                obfuscationView.isHidden = false
                imageToolbarView.isHidden = true
            } else {
                // We did not download the medium image yet, start the progress animation
                loadingView.startProgressAnimation()
                loadingView.isHidden = false
            }
        }
    }
}

