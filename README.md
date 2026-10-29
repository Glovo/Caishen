<div align="center">

# 📚 Caishen

**iOS payment card text field with on-device card number, expiry and CVC validation**

Caishen is a Swift UI library, shipped as a CocoaPod, that puts the card number, expiry month and year, and CVC into one text field. It detects the card type from the first digits and validates the input on the device. It is **not** a payment gateway: it never contacts a card issuer, so a valid result only means the input is well-formed. This repo is Glovo's fork of [prolificinteractive/Caishen](https://github.com/prolificinteractive/Caishen).

[![Swift](https://img.shields.io/badge/Swift-5.1-F05138?logo=swift&logoColor=white)](Caishen.podspec)
[![iOS](https://img.shields.io/badge/iOS-15.0%2B-000000?logo=apple&logoColor=white)](Caishen.podspec)
[![CocoaPods](https://img.shields.io/badge/CocoaPods-2.4.0-EE3322?logo=cocoapods&logoColor=white)](Caishen.podspec)
<br/>
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

</div>

---

## Table of contents

- [Overview](#overview)
- [Adding a card type](#adding-a-card-type)
- [Build & local development](#build--local-development)
- [Testing](#testing)
- [Security & data handling](#security--data-handling)
- [Localization](#localization)
- [Repository layout](#repository-layout)
- [Contributing & conventions](#contributing--conventions)
- [Glossary](#glossary)
- [Ownership & support](#ownership--support)

---

## Overview

Caishen gives an app a **`CardTextField`** for payment card details. The user types the card number; the field detects the card type from the **Issuer Identification Number (IIN)**, formats the number into groups, then slides in the month, year and CVC fields. Once everything is entered, the delegate receives a `Card` and a `CardValidationResult`; `.Valid` means the number, expiry and CVC all passed the card type's checks.

It serves a similar purpose to [PaymentKit](https://github.com/stripe/PaymentKit), but it is a standalone framework written entirely in Swift. It also integrates easily with third-party frameworks such as [CardIO](https://www.card.io).

<p align="center"><img src="caishen_example.gif" alt="Caishen example" /></p>

| | |
|---|---|
| Language / build | Swift 5.1 ([`Caishen.podspec`](Caishen.podspec)) · Xcode project [`Caishen.xcodeproj`](Caishen.xcodeproj) · CocoaPods through [`Gemfile`](Gemfile) |
| Minimum iOS | 15.0 ([`Caishen.podspec`](Caishen.podspec)) |
| Distribution | Git tags on this repo (podspec `:tag => s.version.to_s`); current version `2.4.0` |
| Built-in card types | 7 (Amex, China UnionPay, Diners Club, Discover, JCB, MasterCard, Visa) in [`CardTypeRegister.swift`](Pod/Classes/Cards/CardTypeRegister.swift) |
| Localization | en, de, zh-Hans ([`Pod/Resources/`](Pod/Resources)) |
| Accessibility | Section 508 compliance notes in [`Section 508.md`](<Section 508.md>) |
| Owner | No CODEOWNERS or catalog file (see [Ownership & support](#ownership--support)) |

### What this fork changes

| Change | Where |
|---|---|
| Text change events are sent after each change; `StylizedTextField` gets a public `init`; some `CardInfoTextFieldDelegate` methods become optional | Commits `4b8d127`, `ff901d4`, `9952493` (2019-01) |
| A card type can have **several number groupings** (`numberGroupings: [[Int]]`, e.g. 16 and 19 digits) | PX-246, PR #2 (2021-10) |
| Podspec `source` points at `Glovo/caishen.git` | PR #3 (2021-10) |
| `String.isNumeric()` crash fix | PAY-4307, PR #6 (2024-10) |
| Release `2.4.0`: minimum iOS 15.0, Swift 5.1 | PR #7 (2024-10) |

On 2026-10-29 GitHub's compare showed this fork 12 commits ahead of and 2 commits behind upstream `master`.

---

## Adding a card type

To accept a card type that Caishen doesn't ship, define it in your app and register it on the text field:

1. Create a type that conforms to [`CardType`](Pod/Classes/Cards/CardType.swift) with `name`, `identifyingDigits` (IIN prefixes) and `CVCLength`.
2. Optionally set `numberGroupings` (default `[[4, 4, 4, 4]]`), `requiresCVC` and `requiresExpiry` (both default `true`; `false` hides that field and skips its validation).
3. Add an image asset named exactly like `name`. Images are looked up through `cardTextField.cardTypeImageStore`, which defaults to the Caishen bundle (`Bundle(for: CardTextField.self)`); any `Bundle` works as a store.
4. Register it: `cardTextField?.cardTypeRegister.register(cardType: MyCardType())`. By default every text field uses `CardTypeRegister.sharedCardTypeRegister`, so a registration applies to all of them.

> [!IMPORTANT]
> **No two card types may provide the exact same identifying number** (e.g. `309` for both Diners Club and JCB). Overlapping prefixes are fine: IINs are matched longest first, so `3096` beats `309` ([`CardType.swift`](Pod/Classes/Cards/CardType.swift)).

<details><summary><b>Example: a custom card type</b></summary>

```swift
struct MyCardType: CardType {

    // MARK: - Required

    // The name of your specified card type:
    public let name = "My Card Type"

    // Note: The image that will be displayed in the card number text field's image view when this card type
    // has been detected will load from an asset with the name `cardType.name`.

    // If the Issuer Identification Number (the first six digits of the entered card number) of a card number
    // starts with anything from 1000 to 1111, the card is identified as being of type "MyCardType":
    public let identifyingDigits = Set(1000...1111)

    // The number of digits expected in the Card Validation Code.
    public let CVCLength = 4

    // MARK: - Optional

    // The groupings of your card number type. The following results in a card number format
    // like "100 - 0000 - 00000 - 000000".
    // Not specifying this will result in a 16 digit number, separated into 4 groups of 4 digits.
    // List several groupings to accept several lengths, e.g. [[4, 4, 4, 4], [4, 4, 4, 4, 3]].
    public let numberGroupings = [[3, 4, 5, 6]]

    /**
     A boolean flag that indicates whether CVC validation is required for this card type or not.
     Setting this value to false will hide the CVC text field from the `CardTextField` and remove the required validation routine. The default is true.
     */
    public let requiresCVC = true

    /**
     A boolean flag that indicates whether expiry validation is required for this card type or not.
     Setting this value to false will hide the month and year text field from the `CardTextField` and remove the required
     validation routine. The default is true.
     */
    public let requiresExpiry = true

    public init() {

    }
}

...

class MyViewController: UIViewController, CardTextFieldDelegate {

    @IBOutlet weak var cardTextField: CardTextField?
    ...

    override func viewDidLoad() {
        super.viewDidLoad()
        cardTextField?.cardTypeRegister.register(cardType: MyCardType())
    }

    ...
}
```

</details>

<details><summary><b>Variant: adding a built-in card type to the library</b></summary>

1. Add `<Name>.swift` under [`Pod/Classes/Cards/Default Card Types/`](<Pod/Classes/Cards/Default Card Types>), modelled on an existing type such as [`Visa.swift`](<Pod/Classes/Cards/Default Card Types/Visa.swift>).
2. Add an image set named after the type's `name` to [`Pod/Assets/Media.xcassets/`](Pod/Assets/Media.xcassets).
3. Add the type to `defaultCardTypes` in [`CardTypeRegister.swift`](Pod/Classes/Cards/CardTypeRegister.swift).
4. Add the new file to the `Caishen` target in [`Caishen.xcodeproj`](Caishen.xcodeproj) so local builds and tests see it.
5. Cover it in [`CaishenTests/`](CaishenTests); [`MultipleGroupingsCardType.swift`](CaishenTests/MultipleGroupingsCardType.swift) shows a test-only card type.

</details>

---

## Build & local development

> [!NOTE]
> **Prerequisites:** Xcode with an iOS 15.0+ simulator, Ruby with Bundler, and CocoaPods from the [`Gemfile`](Gemfile) ([`Gemfile.lock`](Gemfile.lock) pins `cocoapods 1.5.3`).

```bash
bundle install                                     # install CocoaPods from Gemfile.lock
bundle exec pod lib lint --allow-warnings          # validate Caishen.podspec (the podspec asks for this before a release)
xcodebuild build -project Caishen.xcodeproj -scheme Caishen -destination 'generic/platform=iOS'   # build the framework
```

**Swift version:** CocoaPods builds use the podspec's `swift_version = '5.1'`, but [`Caishen.xcodeproj`](Caishen.xcodeproj) still sets `SWIFT_VERSION = 4.2`.

### Install in an app

> [!IMPORTANT]
> **`pod "Caishen"` does not get this fork.** It resolves from the public CocoaPods trunk, whose latest `Caishen` was `2.2.1` (published by the upstream maintainers) on 2026-10-29. Point at this repo's tag to get the changes listed in [Overview](#overview).

```ruby
pod 'Caishen', :git => 'https://github.com/Glovo/Caishen.git', :tag => '2.4.0'
```

With [Carthage](https://github.com/Carthage/Carthage), add this to your Cartfile (the shared `Caishen` scheme is in [`Caishen.xcodeproj`](Caishen.xcodeproj)):

```
github "Glovo/Caishen" == 2.4.0
```

### Use it in an app

To add a text field for card information to a view, either:

- add a `UITextField` to your view in Interface Builder and change its class to **`CardTextField`**, or
- create a `CardTextField` in code with `init(frame:)` or `init?(coder:)`.

To get updates about the entered card information, conform your view controller to **`CardTextFieldDelegate`** and set it as the text field's `cardTextFieldDelegate`.

<details><summary><b>Delegate example</b></summary>

```swift
class MyViewController: UIViewController, CardTextFieldDelegate {

    @IBOutlet weak var cardTextField: CardTextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        cardTextField?.cardTextFieldDelegate = self

        ...
    }

    func cardTextField(_ cardTextField: CardTextField, didEnterCardInformation information: Card, withValidationResult validationResult: CardValidationResult) {
        // A valid card has been entered, if validationResult == CardValidationResult.Valid
    }

    func cardTextFieldShouldShowAccessoryImage(_ cardTextField: CardTextField) -> UIImage? {
        // You can return an image which will be used on cardTextField's accessory button.
        // If you return nil but provide an accessory button action, the unicode character "⇤" is displayed
        // instead of an image to indicate an action that affects the text field.
    }

    func cardTextFieldShouldProvideAccessoryAction(_ cardTextField: CardTextField) -> (() -> ())? {
        // You can return a callback function which will be called if a user tapped on cardTextField's accessory button.
        // If you return nil, cardTextField won't display an accessory button at all.
    }

    ...
}
```

`cardTextFieldShouldProvideAccessoryButtonAccessibilityLabel(_:)` is optional and sets the accessory button's VoiceOver label ([`CardTextFieldDelegate.swift`](Pod/Classes/UI/CardTextFieldDelegate.swift)).

</details>

<details><summary><b>Customizing the text field appearance</b></summary>

`CardTextField` is mostly customizable like any other `UITextField`. Setting any of these standard attributes (from code or Interface Builder) affects it just like any other `UITextField`:

| Property | Type | Description |
|:---|:---|:---|
| `placeholder` | `String?` | The card number placeholder. When using a card number as placeholder, format it with the `cardNumberSeparator` set for the text field (with `" - "` as separator, use a placeholder like `"1234 - 1234 - 1234 - 1234"`). |
| `textColor` | `UIColor?` | The color of text entered into the `CardTextField`. |
| `backgroundColor` | `UIColor?` | The background color of the text field. |
| `font` | `UIFont?` | The font of the entered text. |
| `isSecureTextEntry` | `Bool` | When `true`, any input in the text field is masked with "•" characters. |
| `keyboardAppearance` | `UIKeyboardAppearance` | The keyboard appearance when editing text in the text field. |
| `borderStyle` | `UITextField.BorderStyle` | The border style for the text field. |

`CardTextField` also offers attributes tailored to its purpose, all `@IBInspectable` ([`CardTextField.swift`](Pod/Classes/UI/CardTextField.swift)):

| Property | Type | Description |
|:---|:---|:---|
| `cardNumberSeparator` | `String?` | Separates the groups in a card number. Defaults to `" - "`. |
| `viewAnimationDuration` | `Double` | Duration in seconds of the animation between the card number field and the details (month, year and CVC fields). Defaults to `0.3`. |
| `invalidInputColor` | `UIColor?` | Text color for invalid input. An invalid card number flashes in this color; an expired card's expiry is shown in it. |
| `imageViewLeadingInset`, `imageViewTrailingInset`, `accessoryButtonLeadingInset`, `accessoryButtonTrailingInset` | `CGFloat` | Insets around the card-type image and the accessory button. Default `1.0`, `4.0`, `4.0`, `5.0`. |

</details>

<details><summary><b>CardIO</b></summary>

CardIO lets users scan their card with the camera. You may still want a text field for manual entry, because users may restrict camera access or simply prefer to type. To link to CardIO, use the accessory button together with `CardTextField.prefill(_:month:year:cvc:)`. This mirrors [`Example/Caishen/ViewController.swift`](Example/Caishen/ViewController.swift):

```swift
// 1. Conform your view controller to CardTextFieldDelegate and CardIOPaymentViewControllerDelegate:
class ViewController: UIViewController, CardTextFieldDelegate, CardIOPaymentViewControllerDelegate {

    @IBOutlet weak var cardTextField: CardTextField!

    // MARK: - CardTextFieldDelegate
    func cardTextField(_ cardTextField: CardTextField, didEnterCardInformation information: Card, withValidationResult validationResult: CardValidationResult) {
        if validationResult == .Valid {
            // A valid payment card has been manually entered or CardIO was used to scan one.
        }
    }

    // 2. Optionally provide an image for the CardIO button:
    func cardTextFieldShouldShowAccessoryImage(_ cardTextField: CardTextField) -> UIImage? {
        return UIImage(named: "cardIOIcon")
    }

    // 3. Make the accessory button open CardIO:
    func cardTextFieldShouldProvideAccessoryAction(_ cardTextField: CardTextField) -> (() -> ())? {
        return { [weak self] in
            guard let cardIOViewController = CardIOPaymentViewController(paymentDelegate: self) else {
                return
            }
            self?.present(cardIOViewController, animated: true, completion: nil)
        }
    }

    // MARK: - CardIOPaymentViewControllerDelegate

    // 4. When CardIO returns card information, prefill the text field with it:
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        cardTextField.prefill(cardInfo.cardNumber, month: Int(cardInfo.expiryMonth), year: Int(cardInfo.expiryYear), cvc: cardInfo.cvv)
        paymentViewController.dismiss(animated: true, completion: nil)
    }

    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismiss(animated: true, completion: nil)
    }
}
```

</details>

<details><summary><b>Using the components as separate text fields</b></summary>

Instead of one text field for number, expiry and CVC, you can use a separate text field for each part.

```swift
class ViewController: UIViewController, NumberInputTextFieldDelegate, CardInfoTextFieldDelegate {

    @IBOutlet weak var cardNumberTextField: NumberInputTextField!
    @IBOutlet weak var monthInputTextField: MonthInputTextField!
    @IBOutlet weak var yearInputTextField: YearInputTextField!
    @IBOutlet weak var cvcInputTextField: CVCInputTextField!

    // A card that is not nil when valid information has been entered in the text fields:
    var card: Card? {
        let number = cardNumberTextField.cardNumber
        let cvc = CVC(rawValue: cvcInputTextField.text ?? "")
        let expiry = Expiry(month: monthInputTextField.text ?? "", year: yearInputTextField.text ?? "")
                        ?? Expiry.invalid

        let cardType = cardNumberTextField.cardTypeRegister.cardType(for: cardNumberTextField.cardNumber)
        if cardType.validate(cvc: cvc).union(cardType.validate(expiry: expiry)).union(cardType.validate(number: number)) == .Valid {
            return Card(number: number, cvc: cvc, expiry: expiry)
        } else {
            return nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        cardNumberTextField.numberInputTextFieldDelegate = self
        monthInputTextField.cardInfoTextFieldDelegate = self
        yearInputTextField.cardInfoTextFieldDelegate = self
        cvcInputTextField.cardInfoTextFieldDelegate = self

        // Set the `deleteBackwardCallback`s - closures which are called whenever a user hits
        // backspace on an empty text field.
        monthInputTextField.deleteBackwardCallback = { _ in self.cardNumberTextField.becomeFirstResponder() }
        yearInputTextField.deleteBackwardCallback = { _ in self.monthInputTextField.becomeFirstResponder() }
        cvcInputTextField.deleteBackwardCallback = { _ in self.yearInputTextField.becomeFirstResponder() }
    }

    func numberInputTextFieldDidComplete(_ numberInputTextField: NumberInputTextField) {
        cvcInputTextField.cardType = numberInputTextField.cardTypeRegister.cardType(for: numberInputTextField.cardNumber)
        print("Card number: \(numberInputTextField.cardNumber)")
        print(card)
        monthInputTextField.becomeFirstResponder()
    }

    func numberInputTextFieldDidChangeText(_ numberInputTextField: NumberInputTextField) {

    }

    func textField(_ textField: UITextField, didEnterValidInfo: String) {
        switch textField {
        case is MonthInputTextField:
            print("Month: \(didEnterValidInfo)")
            yearInputTextField.becomeFirstResponder()
        case is YearInputTextField:
            print("Year: \(didEnterValidInfo)")
            cvcInputTextField.becomeFirstResponder()
        case is CVCInputTextField:
            print("CVC: \(didEnterValidInfo)")
        default:
            break
        }
        print(card)
    }

    // Optional:
    func textField(_ textField: UITextField, didEnterPartiallyValidInfo: String) {
        // The user entered information that is not valid but might become valid on further input.
        // Example: Entering "1" for the CVC is partially valid, while entering "a" is not.
    }

    // Optional:
    func textField(_ textField: UITextField, didEnterOverflowInfo overFlowDigits: String) {
        // This function is used in a CardTextField to carry digits to the next text field.
        // Example: A user entered "02/20" as expiry and now tries to append "5" to the month.
        //          On a card text field, the year will be replaced with "5" - the overflow digit.
    }

    // ...
}
```

</details>

### Run the example app

To run the example project, clone the repo and run `pod install` from the [`Example/`](Example) directory first:

```bash
cd Example && pod install            # Example/Pods/ is git-ignored; also pulls CardIO
open Caishen_Example.xcworkspace     # run the Caishen_Example scheme
```

The example is older than the library: its project targets iOS 8.3 and its [`Podfile.lock`](Example/Podfile.lock) records Caishen `2.0.1` and CocoaPods `1.1.1`, while the podspec now requires iOS 15.0. If `pod install` rejects the deployment target, raise it in the example project. [`_Pods.xcodeproj`](_Pods.xcodeproj) is a symlink to `Example/Pods/Pods.xcodeproj` and only resolves after `pod install`.

---

## Testing

```bash
xcodebuild test -project Caishen.xcodeproj -scheme CaishenTests \
  -destination 'platform=iOS Simulator,name=<an iOS 15.0+ simulator>'   # unit tests
bundle exec pod lib lint --allow-warnings                               # podspec lint
```

- [`CaishenTests/`](CaishenTests) holds 6 `*Tests.swift` files (one is the Xcode template `CaishenTests.swift`) covering card number formatting and validation, CVC, expiry and `String` extensions, plus 2 helpers: [`XCTAssertValidation.swift`](CaishenTests/XCTAssertValidation.swift) and [`MultipleGroupingsCardType.swift`](CaishenTests/MultipleGroupingsCardType.swift).
- [`Pod/Tests/CaishenTests.swift`](Pod/Tests/CaishenTests.swift) is an older template stub that `Caishen.xcodeproj` doesn't reference.

> [!WARNING]
> [`.travis.yml`](.travis.yml) is upstream's Travis config: Xcode 10, an `iPhone XS` simulator on iOS 12.0 and Ruby 2.3.1. That is below the iOS 15.0 deployment target, so its test step can't run as written. The repo has no other CI config (no `.github/workflows`).

---

## Security & data handling

> [!WARNING]
> Caishen handles **raw cardholder data**: the full card number, expiry and CVC live in its text fields and in the `Card` passed to your delegate. What happens to them next is up to the app.

- **Validation is local only.** Number checks cover length, the Luhn algorithm and digits only; CVC checks cover digits and length; expiry checks cover a valid date that hasn't passed. None of this confirms the card with the issuer; use a payment gateway for that ([`CardType.swift`](Pod/Classes/Cards/CardType.swift)).
- **No network calls.** Nothing under [`Pod/Classes/`](Pod/Classes) uses `URLSession` or `URLRequest`.
- **VoiceOver reads the card number aloud**, digit by digit, followed by the detected card type (`accessibilityValue` in [`NumberInputTextField.swift`](Pod/Classes/UI/NumberInputTextField.swift)). It also announces an invalid number or an expired card. See [`Section 508.md`](<Section 508.md>).

---

## Localization

- 3 bundles in [`Pod/Resources/`](Pod/Resources): `en`, `de` and `zh-Hans`, each a `Localizable.strings` with the same 8 keys (VoiceOver labels and announcements).
- Keys are defined in [`Localization.swift`](Pod/Classes/Localization.swift) and loaded from the Caishen bundle (`Bundle(for: CardTextField.self)`), table `Localizable`.
- The bundles are edited by hand; there is no sync workflow. Add a key to all three files and to `Localization`.

---

## Repository layout

```text
.
├── Pod/                          ⭐ library source shipped by the podspec
│   ├── Classes/                  Swift sources
│   │   ├── Cards/                Card, CardType, CardTypeRegister, Number, Expiry, CVC
│   │   │   └── Default Card Types/   built-in card types
│   │   ├── Format/               CardNumberFormatter
│   │   ├── UI/                   CardTextField, NumberInputTextField, detail text fields, CardView.xib
│   │   └── Validation/           CardValidationResult option set
│   ├── Assets/Media.xcassets/    card-type and CVC images, named after CardType.name
│   ├── Resources/                Localizable.strings (en, de, zh-Hans)
│   └── Tests/                    old template test stub, not in the Xcode project
├── CaishenTests/                 unit tests (CaishenTests scheme)
├── Caishen.xcodeproj/            framework and test targets; shared schemes Caishen, CaishenTests
├── Example/                      demo app (Caishen_Example) using CardIO; Pods/ is git-ignored
├── Caishen.podspec               pod name, version, minimum iOS/Swift, release tag
├── Gemfile, Gemfile.lock         CocoaPods version for bundle exec
├── .travis.yml                   upstream Travis config (tests + pod lib lint)
├── Section 508.md                accessibility compliance notes
├── _Pods.xcodeproj               symlink to Example/Pods/Pods.xcodeproj (resolves after pod install)
├── caishen.jpg                   banner image
├── caishen_example.gif           demo GIF
└── LICENSE                       MIT
```

---

## Contributing & conventions

1. **Style:** code contributions follow the [Prolific Swift Style Guide](https://github.com/prolificinteractive/swift-style-guide).
2. **Pull requests:** submit changes as a pull request. Glovo changes have come from branches in this repo (PR #2, PR #3). GitHub issues are turned off for this repo.
3. **Ticket in the title:** Glovo changes carry a Jira key in the subject, e.g. `[PAY-4307] Fixed String.isNumeric() crash`.
4. **Releasing:** bump `s.version` in [`Caishen.podspec`](Caishen.podspec), run `pod lib lint Caishen.podspec`, merge, then push a git tag equal to the version. The podspec fetches source by that tag (`:tag => s.version.to_s`); tag `2.4.0` sits on the PR #7 commit.
5. **Card types:** see [Adding a card type](#adding-a-card-type) for the IIN rule and the files to touch.

There is no CODEOWNERS file, so GitHub doesn't request reviewers automatically.

---

## Glossary

| Term | Meaning |
|---|---|
| IIN | Issuer Identification Number: the first digits of a card number (up to six), used to detect the card type. |
| Luhn check | Checksum over the card number digits; part of number validation. |
| CVC | Card Validation Code printed on the card; its length depends on the card type. |
| CardIO | Third-party SDK that scans a card with the camera; used by the example app. |
| CocoaPods trunk | The public pod registry that `pod "Caishen"` resolves from (upstream releases, not this fork). |
| Carthage | Dependency manager that builds the shared `Caishen` scheme from source. |
| Section 508 | US accessibility law; [`Section 508.md`](<Section 508.md>) maps its mobile requirements to Caishen. |

---

## Ownership & support

- **Team:** not declared; the repo has no CODEOWNERS or `catalog-info.yaml`. The latest changes were PR #6 (PAY-4307) and PR #7 (release `2.4.0`), both 2024-10-02, and PR #2 (PX-246, 2021-10).
- **Upstream:** [prolificinteractive/Caishen](https://github.com/prolificinteractive/Caishen), maintained and funded by Prolific Interactive. The names and logos are trademarks of Prolific Interactive.
- **License:** Caishen is Copyright (c) 2017 Prolific Interactive. It may be redistributed under the terms in the [`LICENSE`](LICENSE) file (MIT).
