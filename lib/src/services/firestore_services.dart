import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/guest_record_model.dart';

class FirestoreService {
  final CollectionReference records =
      FirebaseFirestore.instance.collection("guest_records");

  Future<void> addRecord(GuestRecordModel model) async {
    await records.add(model.toMap());
  }

  Future<void> updateRecord(String docId, GuestRecordModel model) async {
    await records.doc(docId).update(model.toMap());
  }
}
