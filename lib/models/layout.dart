import 'control.dart';

/// Holds one saved layout: a name, a list of controls,
/// and a communication configuration map.
///
/// Includes JSON (de)serialization for persistence.
class LayoutConfig {
  final String name;
  final List<ControlData> controls;
  final Map<String, String> commConfig;

  LayoutConfig({
    required this.name,
    required this.controls,
    required this.commConfig,
  });

  /// Convert to a JSON‐compatible map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'controls': controls.map((c) => c.toJson()).toList(),
      'commConfig': commConfig,
    };
  }

  /// Create a LayoutConfig from a JSON map.
  factory LayoutConfig.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final controlsJson = json['controls'] as List<dynamic>;
    final controls = controlsJson
        .map((e) => ControlData.fromJson(e as Map<String, dynamic>))
        .toList();
    final commConfigMap = Map<String, String>.from(json['commConfig'] as Map);
    return LayoutConfig(
      name: name,
      controls: controls,
      commConfig: commConfigMap,
    );
  }
}
