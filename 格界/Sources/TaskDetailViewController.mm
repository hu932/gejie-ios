#import "TaskDetailViewController.h"
#import "GJTheme.h"

@implementation TaskDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = GJ_BG_DARK;
    self.title = @"任务详情";
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = GJ_TEXT_PRIMARY;
    [self buildUI];
}

- (void)buildUI {
    CGFloat W = self.view.bounds.size.width;
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    sv.backgroundColor = [UIColor clearColor];
    [self.view addSubview:sv];

    CGFloat y = 20, pad = 16, cw = W - 32;

    // 任务信息
    if (_taskData) {
        y = [self addSection:sv y:y width:cw pad:pad title:@"📋 任务信息" dict:_taskData];
    }
    // 商品信息
    if (_productData) {
        y = [self addSection:sv y:y width:cw pad:pad title:@"🛍 商品详情" dict:_productData];
    }
    sv.contentSize = CGSizeMake(W, y + 40);
}

- (CGFloat)addSection:(UIScrollView *)sv y:(CGFloat)y width:(CGFloat)cw pad:(CGFloat)pad
                title:(NSString *)title dict:(NSDictionary *)dict {
    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(pad, y, cw, 0)];
    card.backgroundColor = GJ_BG_CARD;
    card.layer.cornerRadius = GJ_RADIUS_MD;
    card.layer.borderWidth = 1;
    card.layer.borderColor = GJ_BORDER.CGColor;
    [sv addSubview:card];

    UILabel *hdr = [[UILabel alloc] initWithFrame:CGRectMake(14, 12, cw-28, 20)];
    hdr.text = title;
    hdr.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    hdr.textColor = GJ_TEXT_SECONDARY;
    [card addSubview:hdr];

    CGFloat iy = 42;
    for (NSString *key in dict.allKeys) {
        id val = dict[key];
        if ([val isKindOfClass:[NSDictionary class]] ||
            [val isKindOfClass:[NSArray class]]) continue;

        UILabel *kl = [[UILabel alloc] initWithFrame:CGRectMake(14, iy, cw*0.35, 20)];
        kl.text = key;
        kl.font = GJ_FONT_CAPTION;
        kl.textColor = GJ_TEXT_MUTED;
        [card addSubview:kl];

        UILabel *vl = [[UILabel alloc] initWithFrame:CGRectMake(cw*0.38, iy, cw*0.58, 20)];
        vl.text = [NSString stringWithFormat:@"%@", val];
        vl.font = GJ_FONT_SMALL;
        vl.textColor = GJ_TEXT_PRIMARY;
        vl.numberOfLines = 2;
        [vl sizeToFit];
        vl.frame = CGRectMake(cw*0.38, iy, cw*0.58, MAX(20, vl.frame.size.height));
        [card addSubview:vl];
        iy += vl.frame.size.height + 8;
    }

    card.frame = CGRectMake(pad, y, cw, iy + 14);
    return y + card.frame.size.height + 14;
}

@end
