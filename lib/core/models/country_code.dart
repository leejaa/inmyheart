class CountryCode {
  final String name;
  final String code;
  final String flag;

  const CountryCode({
    required this.name,
    required this.code,
    required this.flag,
  });

  static const List<CountryCode> countries = [
    CountryCode(
      name: '대한민국',
      code: '82',
      flag: '🇰🇷',
    ),
    CountryCode(
      name: '미국/캐나다',
      code: '1',
      flag: '🇺🇸',
    ),
    CountryCode(
      name: '일본',
      code: '81',
      flag: '🇯🇵',
    ),
    CountryCode(
      name: '중국',
      code: '86',
      flag: '🇨🇳',
    ),
    CountryCode(
      name: '베트남',
      code: '84',
      flag: '🇻🇳',
    ),
    CountryCode(
      name: '태국',
      code: '66',
      flag: '🇹🇭',
    ),
    CountryCode(
      name: '필리핀',
      code: '63',
      flag: '🇵🇭',
    ),
    CountryCode(
      name: '인도네시아',
      code: '62',
      flag: '🇮🇩',
    ),
    CountryCode(
      name: '말레이시아',
      code: '60',
      flag: '🇲🇾',
    ),
    CountryCode(
      name: '싱가포르',
      code: '65',
      flag: '🇸🇬',
    ),
    CountryCode(
      name: '호주',
      code: '61',
      flag: '🇦🇺',
    ),
    CountryCode(
      name: '영국',
      code: '44',
      flag: '🇬🇧',
    ),
    CountryCode(
      name: '프랑스',
      code: '33',
      flag: '🇫🇷',
    ),
    CountryCode(
      name: '독일',
      code: '49',
      flag: '🇩🇪',
    ),
    CountryCode(
      name: '이탈리아',
      code: '39',
      flag: '🇮🇹',
    ),
    CountryCode(
      name: '스페인',
      code: '34',
      flag: '🇪🇸',
    ),
    CountryCode(
      name: '러시아',
      code: '7',
      flag: '🇷🇺',
    ),
    CountryCode(
      name: '인도',
      code: '91',
      flag: '🇮🇳',
    ),
    CountryCode(
      name: '브라질',
      code: '55',
      flag: '🇧🇷',
    ),
    CountryCode(
      name: '멕시코',
      code: '52',
      flag: '🇲🇽',
    ),
    CountryCode(
      name: '터키',
      code: '90',
      flag: '🇹🇷',
    ),
    CountryCode(
      name: '대만',
      code: '886',
      flag: '🇹🇼',
    ),
    CountryCode(
      name: '홍콩',
      code: '852',
      flag: '🇭🇰',
    ),
    CountryCode(
      name: '마카오',
      code: '853',
      flag: '🇲🇴',
    ),
  ];
}
