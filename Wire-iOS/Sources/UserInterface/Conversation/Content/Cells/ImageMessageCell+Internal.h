//
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
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


#import "ImageMessageCell.h"
@import WireExtensionComponents;

@class ImageToolbarView;
@class ImageCache;
@class ObfuscationView;

@interface ImageMessageCell (Interal)

- (void)setImage:(id<MediaAsset>)image;
- (BOOL)imageSmallerThanMinimumSize;
- (CGSize)sizeForMessage:(id<ZMImageMessageData>)messageData;
- (void)updateImageBorder;
- (BOOL)imageToolbarFitsInsideImage;
- (BOOL)imageToolbarNeedsToBeCompact;
- (void)updateImageMessageConstraintConstants;

static ImageCache *imageCache(void);

@end

@interface ImageMessageCell ()
/// Can either be UIImage or FLAnimatedImage
@property (nonatomic, strong) id<MediaAsset> image;

@property (nonatomic) BOOL autoStretchVertically;
@property (nonatomic) UIEdgeInsets defaultLayoutMargins;

@property (nonatomic) CGSize originalImageSize;
@property (nonatomic) CGSize imageSize;

@property (nonatomic, strong) ImageToolbarView *imageToolbarView;
@property (nonatomic, strong) UIView *imageViewContainer;
@property (nonatomic, strong) ThreeDotsLoadingView *loadingView;
@property (nonatomic, strong) ObfuscationView *obfuscationView;
@end
