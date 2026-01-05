# Flutter Widget Capture & Share

Flutter 앱에서 위젯을 이미지로 캡처하고 사진 라이브러리에 저장하거나 공유하는 기능을 구현한 데모 프로젝트입니다.

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white" alt="iOS">
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android">
</div>

## ✨ 주요 기능

- 📸 **위젯 캡처**: `RepaintBoundary`를 사용하여 특정 위젯을 고해상도 이미지로 변환
- 💾 **사진 라이브러리 저장**: 캡처한 이미지를 기기의 사진 앱에 직접 저장
- 🔗 **공유 기능**: 시스템 공유 시트를 통해 다양한 앱으로 이미지 공유
- 🐛 **상세한 에러 로깅**: 모든 단계에서 print 문을 통한 디버깅 지원

## 🎬 데모

프로젝트를 실행하면:
1. 화면 중앙에 그라데이션 배경의 정사각형 위젯이 표시됩니다
2. "사진에 저장" 버튼으로 사진 앱에 직접 저장할 수 있습니다
3. "공유" 버튼으로 메시지, 이메일 등으로 이미지를 공유할 수 있습니다

## 🚀 시작하기

### 필수 요구사항

- Flutter SDK 3.7.2 이상
- iOS 개발: Xcode
- Android 개발: Android Studio

### 설치

1. 레포지토리 클론
```bash
git clone https://github.com/S-Soo100/flutter_capture_test.git
cd flutter_capture_test
```

2. 의존성 설치
```bash
flutter pub get
```

3. 앱 실행
```bash
flutter run
```

**중요**: 네이티브 플러그인을 사용하므로 처음 실행 시 전체 빌드가 필요합니다. Hot Reload가 아닌 완전한 재시작을 권장합니다.

## 📦 사용된 패키지

| 패키지 | 버전 | 용도 |
|--------|------|------|
| [share_plus](https://pub.dev/packages/share_plus) | ^10.1.4 | 시스템 공유 기능 |
| [path_provider](https://pub.dev/packages/path_provider) | ^2.1.5 | 임시 파일 저장 경로 제공 |
| [image_gallery_saver](https://pub.dev/packages/image_gallery_saver) | ^2.0.3 | 사진 라이브러리 저장 |

## 🔧 주요 구현

### 위젯 캡처

```dart
final GlobalKey _captureKey = GlobalKey();

RepaintBoundary(
  key: _captureKey,
  child: Container(
    // 캡처할 위젯
  ),
)
```

### 이미지 변환

```dart
Future<Uint8List?> _captureWidget() async {
  RenderRepaintBoundary boundary =
      _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

  ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  return byteData!.buffer.asUint8List();
}
```

### 사진 라이브러리 저장

```dart
await ImageGallerySaver.saveImage(
  pngBytes,
  quality: 100,
  name: 'capture_${DateTime.now().millisecondsSinceEpoch}',
);
```

## 📱 플랫폼별 설정

### iOS

`ios/Runner/Info.plist`에 사진 라이브러리 권한 추가 필요:

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>캡처한 이미지를 사진 라이브러리에 저장하기 위해 접근 권한이 필요합니다.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>캡처한 이미지를 사진 라이브러리에 저장하기 위해 접근 권한이 필요합니다.</string>
```

### Android

Android 12 이하 버전 지원을 위한 권한이 필요할 수 있습니다 (이미 설정됨).

## ⚠️ 문제 해결

### MissingPluginException 에러

**증상**: `No implementation found for method...` 에러 발생

**해결**:
```bash
flutter clean
flutter pub get
flutter run
```

네이티브 플러그인을 추가한 후에는 반드시 완전한 재빌드가 필요합니다.

### 사진 앱에 이미지가 안 보임

**문제**: "파일로 저장"을 선택하면 파일 앱에만 저장됩니다.

**해결**:
- 공유 시트에서 **"이미지 저장"** 또는 **"사진에 추가"** 선택
- 또는 앱의 "사진에 저장" 버튼 사용

## 📖 자세한 가이드

프로젝트 내 `WIDGET_CAPTURE_GUIDE.md` 파일에서 더 자세한 구현 가이드와 문제 해결 방법을 확인할 수 있습니다.

## 🏗️ 프로젝트 구조

```
flutter_capture_test/
├── lib/
│   └── main.dart              # 메인 앱 코드 (위젯 캡처 & 공유 구현)
├── ios/
│   └── Runner/
│       └── Info.plist         # iOS 권한 설정
├── android/
├── pubspec.yaml               # 패키지 의존성
└── README.md                  # 이 파일
```

## 💡 핵심 개념

### RepaintBoundary
- Flutter 위젯 트리에서 독립적인 렌더링 레이어를 생성
- 특정 영역만 이미지로 추출 가능
- 성능 최적화에도 사용됨

### pixelRatio
- 이미지 해상도 배율 조절
- 1.0: 기본 해상도
- 2.0: 2배 해상도 (Retina)
- 3.0: 3배 해상도 (고품질)

## 🤝 기여

이슈나 개선 사항이 있으면 자유롭게 Issue를 열어주세요!

## 📄 라이선스

이 프로젝트는 학습 목적으로 만들어졌으며 자유롭게 사용할 수 있습니다.

## 🙏 감사의 말

이 프로젝트는 [Claude Code](https://claude.com/claude-code)의 도움을 받아 제작되었습니다.

---

<div align="center">
  Made with ❤️ using Flutter
</div>
