//
//  AppStoreHeader.h
//  PageCollectionView
//
//  Created by yecongcong on 2017/6/22.
//  Copyright © 2017年 lotogram. All rights reserved.
//

#ifndef AppStoreHeader_h
#define AppStoreHeader_h

static int rankIndex;

@interface SKUIAttributedStringLayout : NSObject
@property (nonatomic,readonly) NSAttributedString * attributedString;
@end

@interface SKUIStyledButton : UIControl
@property (nonatomic,retain) SKUIAttributedStringLayout * titleLayout;
@end

@interface SKUIReviewMetadata : NSObject

@property (nonatomic,copy) NSString * body;
@property (nonatomic,copy) NSString * nickname;
@property (assign,nonatomic) float rating;
@property (nonatomic,copy) NSString * title;

@end

@interface SUViewController : UIViewController
@end

@interface SKUIComposeReviewFormViewController : SUViewController
-(void)_submit;
@end

@interface SKUIItemOfferButtonState : NSObject
@property(nonatomic) _Bool hasImage;
@property(nonatomic) long long progressType;
@property(nonatomic) _Bool showingConfirmation;
@property(nonatomic) _Bool highlighted;
@end

@interface SKRemoteComposeReviewViewController :UIViewController
@end

@interface SKComposeReviewViewController : UIViewController
@end

@interface SKUIViewController:UIViewController
@end

@interface SKUIStackedBar : UIView
- (void)animateToFullSizeIfNecessary;
@end

@interface SKUIStorePageSectionsViewController:SKUIViewController
{
    _Bool _scrollOffsetHasChanged;
}
@property(readonly, nonatomic) UICollectionView *collectionView;
@property(readonly, nonatomic) NSArray *sections;
- (void)_reloadRelevantEntityProviders;
- (void)_reloadCollectionView;
- (void)_prefetchArtworkForVisibleSections;
- (SKUIStackedBar *)SKUIStackedBar;
-(void)collectionView:(id)arg1 didSelectItemAtIndexPath:(id)arg2 ;
@end

@interface SKUIStackDocumentViewController : SKUIViewController
@property(readonly, nonatomic) SKUIStorePageSectionsViewController *sectionsViewController;
@end

@interface SKUIGridViewElementPageSection : NSObject
@end

@interface SKUIDocumentContainerViewController: SKUIViewController
- (id)childViewController;
@end

@interface SUStorePageViewController: UIViewController
@end

@interface SKUIAccountButtonsView : UIView
@property(readonly, nonatomic) UIButton *appleIDButton;
@end

@interface SKUIAccountButtonsViewController:UIViewController
- (void)_signOut;
@end

@interface SKUIItemOfferButton : UIControl
@property (assign,nonatomic) id delegate;
@end

@interface SKUICardViewElement : NSObject
@property(readonly, retain, nonatomic) NSDictionary *attributes;
@end

@interface SKUITabBarController:UITabBarController
@end

@interface SKUISearchFieldController : NSObject
@property (nonatomic,readonly) UIViewController * contentsController;
@property (nonatomic,readonly) UISearchBar * searchBar;
-(void)searchBar:(id)arg1 textDidChange:(id)arg2 ;
-(void)searchBarSearchButtonClicked:(id)arg1 ;
@end

@interface SKUISegmentedControlViewElementController : NSObject
@property (nonatomic,readonly) UIView * segmentedControlView; 
-(void)segmentedControl:(id)arg1 didSelectSegmentIndex:(long long)arg2 ;
@end

#endif /* AppStoreHeader_h */
