import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum CallerSDKType { generated, custom }

class ConnectorConfig {
  final String region;
  final String environment;
  final String projectId;

  ConnectorConfig(this.region, this.environment, this.projectId);
}

class FirebaseDataConnect {
  final FirebaseFirestore _firestore;
  final ConnectorConfig _config;
  final CallerSDKType _sdkType;

  FirebaseDataConnect._(
    this._firestore,
    this._config,
    this._sdkType,
  );

  static FirebaseDataConnect instanceFor({
    required ConnectorConfig connectorConfig,
    required CallerSDKType sdkType,
  }) {
    return FirebaseDataConnect._(
      FirebaseFirestore.instance,
      connectorConfig,
      sdkType,
    );
  }

  Future<void> setData(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).set(data);
  }

  Future<void> updateData(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  Future<void> deleteData(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  Stream<QuerySnapshot> streamCollection(String collection, {List<Query Function(Query)>? queries}) {
    Query ref = _firestore.collection(collection);
    if (queries != null) {
      for (var query in queries) {
        ref = query(ref);
      }
    }
    return ref.snapshots();
  }
}