import 'package:metrowealth/core/services/firebase_data_connect.dart';

class DefaultConnector {
  static final ConnectorConfig connectorConfig = ConnectorConfig(
    'us-central1',
    'default',
    'metrowealth',
  );

  DefaultConnector({required this.dataConnect});
  
  static DefaultConnector get instance {
    return DefaultConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}