/// Country/region information for SMS login
///
/// Source: biu/src/service/passport-login-web-country.ts#CountryInfo
class CountryInfo {
  const CountryInfo({
    required this.id,
    required this.name,
    required this.countryCode,
  });

  factory CountryInfo.fromJson(Map<String, dynamic> json) {
    return CountryInfo(
      id: json['id'] as int? ?? 0,
      name: json['cname'] as String? ?? '',
      countryCode: json['country_code'] as String? ?? '',
    );
  }

  /// Country ID
  final int id;

  /// Country/region name (Chinese)
  final String name;

  /// Country code (e.g., "86" for China)
  final String countryCode;

  /// Get display string with country code
  String get displayCode => '+$countryCode';
}

/// Response from country list API
///
/// Source: biu/src/service/passport-login-web-country.ts#CountryListResponse
class CountryListResponse {
  const CountryListResponse({
    required this.code,
    required this.list,
    this.defaultCountry,
  });

  factory CountryListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    CountryInfo? defaultCountry;
    if (data?['default'] != null) {
      defaultCountry =
          CountryInfo.fromJson(data!['default'] as Map<String, dynamic>);
    }

    final listData = data?['list'] as List<dynamic>?;
    final list = listData
            ?.map((e) => CountryInfo.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return CountryListResponse(
      code: json['code'] as int? ?? -1,
      defaultCountry: defaultCountry,
      list: list,
    );
  }

  /// Response code (0 = success)
  final int code;

  /// Default country/region
  final CountryInfo? defaultCountry;

  /// All available countries/regions
  final List<CountryInfo> list;

  /// Check if response is successful
  bool get isSuccess => code == 0;
}
