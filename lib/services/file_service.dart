import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:instaclone/services/auth_service.dart';

class FileService{
  static final _storage = FirebaseStorage.instance.ref();
  static final folder_user = "user_images";
  static final folder_post = "post_images";

  static Future<String> uploadUserImage(File _image)async{
    String uid = AuthService.currentUserId();
    String img_name = uid;
    var firebaseStorageRef = _storage.child(folder_user).child(img_name);
    var uploadTask = firebaseStorageRef.putFile(_image);
    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
    final String dowloadUrl = await firebaseStorageRef.getDownloadURL();
    print(dowloadUrl);
    return dowloadUrl;
  }

  static Future<String> uploadPostImage(File _image)async{
    String uid = AuthService.currentUserId();
    String img_name = uid + "_" + DateTime.now().toString();
    var firebaseStorageRef = _storage.child(folder_post).child(img_name);
    var uploadTask = firebaseStorageRef.putFile(_image);
    final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
    final String dowloadUrl = await firebaseStorageRef.getDownloadURL();
    print(dowloadUrl);
    return dowloadUrl;
  }

}