#import "RNCustomKeyboard.h"
#import "RCTBridge+Private.h"
#import "RCTUIManager.h"
#import "RCTTextField.h"

@implementation RNCustomKeyboard

@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE(CustomKeyboard)

RCT_EXPORT_METHOD(install:(nonnull NSNumber *)reactTag withType:(nonnull NSString *)keyboardType maxLength:(int) maxLength)
{
    UIView *inputView = [[RCTRootView alloc] initWithBridge:((RCTBatchedBridge *)_bridge).parentBridge moduleName:@"CustomKeyboard" initialProperties:
                         @{
                           @"tag": reactTag,
                           @"type": keyboardType
                           }
                         ];
    [inputView setFrame:CGRectMake(0, 0, 0, 260)];

    if (_dicInputMaxLength == nil) {
        _dicInputMaxLength = [NSMutableDictionary dictionaryWithCapacity:0];
    }

    [_dicInputMaxLength setValue:[NSNumber numberWithInt:maxLength] forKey:[reactTag stringValue]];


    RCTTextField *view = (RCTTextField *)[_bridge.uiManager viewForReactTag:reactTag];
    UITextField *textField = (UITextField *)[view backedTextInputView];
    textField.tintColor = [UIColor clearColor];
    textField.inputView = inputView;
    [view reloadInputViews];
}

RCT_EXPORT_METHOD(uninstall:(nonnull NSNumber *)reactTag)
{
    RCTTextField *view = (RCTTextField *)[_bridge.uiManager viewForReactTag:reactTag];
    UITextField *textField = (UITextField *)[view backedTextInputView];

    textField.inputView = nil;
    [textField reloadInputViews];
}

RCT_EXPORT_METHOD(getSelectionRange:(nonnull NSNumber *)reactTag callback:(RCTResponseSenderBlock)callback) {
    RCTTextField *view = (RCTTextField *)[_bridge.uiManager viewForReactTag:reactTag];
    UITextField *textField = (UITextField *)[view backedTextInputView];
    UITextRange *range = textField.selectedTextRange;

    const NSInteger start = [textField offsetFromPosition:textField.beginningOfDocument toPosition:range.start];
    const NSInteger end = [textField offsetFromPosition:textField.beginningOfDocument toPosition:range.end];
    callback(@[@{@"text":textField.text, @"start":[NSNumber numberWithInteger:start], @"end":[NSNumber numberWithInteger:end]}]);
}

RCT_EXPORT_METHOD(insertText:(nonnull NSNumber *)reactTag withText:(NSString*)text) {
    RCTTextField *view = (RCTTextField *)[_bridge.uiManager viewForReactTag:reactTag];
    UITextField *textField = (UITextField *)[view backedTextInputView];
    if (_dicInputMaxLength != nil) {
        NSString *textValue = [NSString stringWithFormat:@"%@", textField.text];
        int  maxLegth = [_dicInputMaxLength[reactTag.stringValue] intValue];
        if ([textValue length] >= maxLegth) {
            return;
        }
    }
    [textField replaceRange:textField.selectedTextRange withText:text];
}

RCT_EXPORT_METHOD(backSpace:(nonnull NSNumber *)reactTag) {
    RCTTextField *view = (RCTTextField *)[_bridge.uiManager viewForReactTag:reactTag];
    UITextField *textField = (UITextField *)[view backedTextInputView];

    UITextRange *range = textField.selectedTextRange;
    if ([textField comparePosition:range.start toPosition:range.end] == 0) {
        range = [textField textRangeFromPosition:[textField positionFromPosition:range.start offset:-1] toPosition:range.start];
    }
    [textField replaceRange:range withText:@""];
}

RCT_EXPORT_METHOD(doDelete:(nonnull NSNumber *)reactTag) {
    RCTTextField *view = (RCTTextField *)[_bridge.uiManager viewForReactTag:reactTag];
    UITextField *textField = (UITextField *)[view backedTextInputView];

    UITextRange *range = textField.selectedTextRange;
    if ([textField comparePosition:range.start toPosition:range.end] == 0) {
        range = [textField textRangeFromPosition:range.start toPosition:[textField positionFromPosition: range.start offset: 1]];
    }
    [textField replaceRange:range withText:@""];
}

RCT_EXPORT_METHOD(moveLeft:(nonnull NSNumber *)reactTag) {
    RCTTextField *view = (RCTTextField *)[_bridge.uiManager viewForReactTag:reactTag];
    UITextField *textField = (UITextField *)[view backedTextInputView];

    UITextRange *range = textField.selectedTextRange;
    UITextPosition *position = range.start;

    if ([textField comparePosition:range.start toPosition:range.end] == 0) {
        position = [textField positionFromPosition: position offset: -1];
    }

    textField.selectedTextRange = [textField textRangeFromPosition: position toPosition:position];
}

RCT_EXPORT_METHOD(moveRight:(nonnull NSNumber *)reactTag) {
    RCTTextField *view = (RCTTextField *)[_bridge.uiManager viewForReactTag:reactTag];
    UITextField *textField = (UITextField *)[view backedTextInputView];

    UITextRange *range = textField.selectedTextRange;
    UITextPosition *position = range.end;

    if ([textField comparePosition:range.start toPosition:range.end] == 0) {
        position = [textField positionFromPosition: position offset: 1];
    }

    textField.selectedTextRange = [textField textRangeFromPosition: position toPosition:position];
}

RCT_EXPORT_METHOD(switchSystemKeyboard:(nonnull NSNumber *)reactTag) {
    RCTTextField *view = (RCTTextField *)[_bridge.uiManager viewForReactTag:reactTag];
    UITextField *textField = (UITextField *)[view backedTextInputView];

    UIView *inputView = textField.inputView;
    textField.inputView = nil;
    [textField reloadInputViews];
    textField.inputView = inputView;
}

RCT_EXPORT_METHOD(dismiss:(nonnull NSNumber *)reactTag) {
    RCTTextField *view = (RCTTextField *)[_bridge.uiManager viewForReactTag:reactTag];
    UITextField *textField = (UITextField *)[view backedTextInputView];

    [textField resignFirstResponder];
}

@end
