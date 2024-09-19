// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// FlutterSoundRecorder? _recorder;
// String? _recordPath;
//
// // Initialize the recorder
// void initializeRecorder() async {
//   _recorder = FlutterSoundRecorder();
//   await _recorder!.openRecorder();
// }
//
// // Request audio recording permission
// Future<bool> requestAudioRecordingPermission() async {
//   PermissionStatus status = await Permission.microphone.request();
//   return status.isGranted;
// }
// // Call this function before starting the recording
//
// // Start recording
// Future<void> startRecording() async {
//   bool hasRecordingPermission = await requestAudioRecordingPermission();
//   if (hasRecordingPermission) {
//     if (_recorder != null && !_recorder!.isRecording) {
//       final tempDir = await getTemporaryDirectory();
//       _recordPath = '${tempDir.path}/audio';
//       await _recorder!.startRecorder(
//         toFile: _recordPath!,
//       );
//     }
//   } else {
//     if (kDebugMode) {
//       print("No Permisson ");
//     }
//   }
// }
//
// // Stop recording and save the audio file
// Future<void> stopRecording() async {
//   if (_recorder != null && _recorder!.isRecording) {
//     await _recorder!.stopRecorder();
//   }
// }
//
// // Upload the recorded audio file to Firebase Storage
// Future<String> uploadRecordingToFirebaseStorage() async {
//   if (_recordPath == null) {
//     throw Exception('No recording found');
//   }
//
//   File file = File(_recordPath!);
//   String uniqueName = DateTime.now().millisecondsSinceEpoch.toString();
//
//   Reference referenceRoot = FirebaseStorage.instance.ref();
//   Reference referenceDirVoice = referenceRoot.child("voice_messages");
//   Reference referenceVoice = referenceDirVoice.child(uniqueName);
//   await referenceVoice.putFile(file);
//   String downloadUrl = await referenceVoice.getDownloadURL();
//   if (kDebugMode) {
//     print("added to storage");
//   }
//   return downloadUrl;
// }
//
// // Save the voice message details to Firestore
// Future<void> saveRecordingToFirestore(String downloadURL) async {
//   CollectionReference voiceMessagesCollection =
//       FirebaseFirestore.instance.collection('voice_messages');
//   await voiceMessagesCollection.add({
//     'downloadURL': downloadURL,
//     'fileName': "vm",
//     'createdAt': DateTime.now(),
//   });
// }
//
// // Call the methods to initialize the recorder, start/stop recording, and upload/save the voice message
// void sendVoiceMessage() async {
//   initializeRecorder();
//   await startRecording();
//   await Future.delayed(const Duration(seconds: 10)); // Record for 10 seconds
//   await stopRecording();
//
//   String downloadURL = await uploadRecordingToFirebaseStorage();
//   await saveRecordingToFirestore(downloadURL);
// }
