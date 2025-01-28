# in my heart

인연을 찾아주는 소개팅 앱 in my heart 입니다.

## 주요 기능

- 연락처 기반 매칭
  - 내 연락처에 있는 사람들 중에서 인연을 찾을 수 있습니다.
  - 한 사람에게만 호감을 표시할 수 있습니다.
  - 아직 가입하지 않은 친구를 초대할 수 있습니다.

- 퀴즈 기능
  - 매일 새로운 퀴즈를 통해 인연을 찾을 수 있습니다.
  - 퀴즈에 참여한 친구들 중에서 선택할 수 있습니다.

## 개발 환경 설정

1. Flutter SDK 설치
```bash
flutter pub get
```

2. Firebase 설정
- `google-services.json` 파일을 `android/app/` 디렉토리에 추가
- `GoogleService-Info.plist` 파일을 `ios/Runner/` 디렉토리에 추가

3. 환경 변수 설정
- `.env` 파일을 프로젝트 루트 디렉토리에 생성하고 필요한 환경 변수 설정

## 필요 권한

- 연락처 접근 권한: 친구 목록 조회 및 초대를 위해 필요
- 알림 권한: 새로운 소식을 알려드리기 위해 필요

## 지원 플랫폼

- Android: minSdkVersion 23 이상
- iOS: iOS 11.0 이상
