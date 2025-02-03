import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class FireBaseHelperFunctions {
  static Future<List<String>> fetchAllUserDetails(String collectionId) async {
    try {
      // Query the collection to get all documents
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionId).get();

      // Extract the document IDs from the query snapshot
      List<String> documentIds =
          querySnapshot.docs.map((doc) => doc.id).toList();

      return documentIds;
    } catch (e) {
      print('Error fetching all user details: $e');
      return [];
    }
  }

  static Future<List<Map<dynamic, dynamic>>> getDataFromCollection(
      String collectionId) async {
    CollectionReference data =
        FirebaseFirestore.instance.collection(collectionId);

    QuerySnapshot querySnapshot = await data.get();
    List<Map<dynamic, dynamic>> supplierList = [];

    for (var doc in querySnapshot.docs) {
      Map<dynamic, dynamic> record = (doc.data() as Map<dynamic, dynamic>);
      record['id'] = doc.id;
      supplierList.add(record);
    }

    return supplierList;
  }

  static Future<List<Map<String, dynamic>>> fetchTopKDocuments(
      String collectionId, int k) async {
    try {
      // Query the collection, order by timestamp and limit to k documents
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(collectionId)
          .orderBy('datetime',
              descending: true) // Using datetime to order the documents
          .limit(k)
          .get();

      // Convert documents to a List of Map objects
      List<Map<String, dynamic>> documents = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return documents;
    } catch (e) {
      print('Error fetching top $k documents: $e');
      return [];
    }
  }

  static Future<bool> documentExists(
      String collectionName, String documentId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentId)
          .get();
      return docSnapshot.exists;
    } catch (e) {
      print("Error checking document existence: $e");
      return false;
    }
  }

  static Future<bool> collectionExists(String collectionName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking collection existence: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>> getDataFromDocument(
      String collectionId, String documentId) async {
    DocumentReference document =
        FirebaseFirestore.instance.collection(collectionId).doc(documentId);

    try {
      DocumentSnapshot documentSnapshot = await document.get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> documentData =
            documentSnapshot.data() as Map<String, dynamic>;

        documentData['id'] = documentSnapshot.id;

        return documentData;
      } else {
        throw Exception("Document does not exist");
      }
    } catch (e) {
      print("Error getting document: $e");
      throw Exception("Error getting document: $e");
    }
  }

  static void addData(
      String collectionId, String documentId, Map<String, dynamic> data) async {
    CollectionReference users =
        FirebaseFirestore.instance.collection(collectionId);

    await users.doc(documentId).set(data);
  }

  static void updateQuantityData(String collectionId, String documentId,
      Map<String, dynamic> keyValuePairs, bool add) async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection(collectionId);

    try {
      DocumentSnapshot docSnapshot = await collection.doc(documentId).get();

      if (!docSnapshot.exists) {
        Map<String, dynamic> initialData = {};
        keyValuePairs.forEach((key, value) {
          initialData[key] = add ? value : -value;
        });

        await collection.doc(documentId).set(initialData);
      } else {
        Map<String, dynamic> updates = {};
        keyValuePairs.forEach((key, value) {
          updates[key] =
              add ? FieldValue.increment(value) : FieldValue.increment(-value);
        });

        await collection.doc(documentId).update(updates);
      }
    } catch (e) {}
  }

  static void updateData(String collectionId, String documentId,
      Map<String, dynamic> keyValuePairs) async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection(collectionId);

    try {
      DocumentSnapshot docSnapshot = await collection.doc(documentId).get();

      if (!docSnapshot.exists) {
        Map<String, dynamic> initialData = {};
        keyValuePairs.forEach((key, value) {
          initialData[key] = value;
        });

        await collection.doc(documentId).set(initialData);
      } else {
        Map<String, dynamic> updates = {};
        keyValuePairs.forEach((key, value) {
          updates[key] = value;
        });

        await collection.doc(documentId).update(updates);
      }
    } catch (e) {}
  }

  static Future<void> deleteDocument(
      String collectionId, String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionId)
          .doc(documentId)
          .delete();
      print("Document deleted successfully.");
    } catch (e) {
      print("Error deleting document: $e");
    }
  }

  static Stream<Map<String, dynamic>> getDocumentStream(
      String collection, String documentId) {
    return FirebaseFirestore.instance
        .collection(collection)
        .doc(documentId)
        .snapshots()
        .debounceTime(Duration(milliseconds: 1000)) // Cooldown of 3 seconds
        .map((snapshot) => snapshot.data() ?? {});
  }

  static Future<List<Map<String, dynamic>>> getDataFromCollectionAfterDate(
      String collectionId, DateTime afterDate) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    try {
      // Convert the DateTime to a Timestamp for Firestore query
      Timestamp afterTimestamp = Timestamp.fromDate(afterDate);

      // Query the collection where `datetime` is greater than or equal to `afterTimestamp`
      QuerySnapshot querySnapshot = await _firestore
          .collection(collectionId)
          .where('datetime', isGreaterThanOrEqualTo: afterTimestamp)
          .get();

      // Extract the data from the documents
      List<Map<String, dynamic>> documents = [];
      for (var doc in querySnapshot.docs) {
        documents.add(doc.data() as Map<String, dynamic>);
      }

      return documents;
    } catch (e) {
      print('Error fetching data from Firestore: $e');
      rethrow;
    }
  }
}
