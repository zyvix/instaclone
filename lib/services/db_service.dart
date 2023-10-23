import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instaclone/model/member_model.dart';
import 'package:instaclone/services/auth_service.dart';
import 'package:instaclone/services/utils_service.dart';

import '../model/post_model.dart';
import 'hive.dart';

class DBService{
  static final _firestore = FirebaseFirestore.instance;

  static String folder_users = "users";
  static String folder_posts = "posts";
  static String folder_feeds = "feeds";
  static String folder_following = "following";
  static String folder_followers = "followers";

  static Future storeMember(Member member)async{
    member.uid = AuthService.currentUserId();
    Map<String, String> params = await Utils.deviceParams();
    print(params.toString());

    member.device_id = params['device_id']!;
    member.device_type = params['device_type']!;
    member.device_token = params['device_token']!;
    return _firestore.collection(folder_users).doc(member.uid).set(member.toJson());
  }

  static Future<Member> loadMember() async{
    String uid = AuthService.currentUserId();
    var value = await _firestore.collection(folder_users).doc(uid).get();
    Member member = Member.fromJson(value.data()!);

    var querySnapshot1 = await _firestore.collection(folder_users)
        .doc(uid).collection(folder_followers).get();
    member.followers_count = querySnapshot1.docs.length;

    var querySnapshot2 = await _firestore.collection(folder_users)
        .doc(uid).collection(folder_following).get();
    member.following_count = querySnapshot2.docs.length;

    return member;
  }

  static Future updateMember(Member member) async{
    String uid = AuthService.currentUserId();
    return _firestore.collection(folder_users).doc(uid).update(member.toJson());
  }

  static Future<List<Member>> searchMember(String keyword) async{
    List<Member> members = [];
    String uid = AuthService.currentUserId();

    var querySnapshot = await _firestore
        .collection(folder_users)
        .orderBy("email")
        .startAt([keyword]).get();
    print(querySnapshot.docs.length);
    
    querySnapshot.docs.forEach((result) {
      Member newMember = Member.fromJson(result.data());
      if(newMember.uid != uid) members.add(newMember);
    });

    return members;
  }


  static Future<Post> storePost(Post post)async{
    Member me = await loadMember();
    post.uid = me.uid;
    post.fullname = me.fullname;
    post.date = Utils.currentDate();
    post.img_user = me.img_url;
    post.handle = me.handle;

    String postId = _firestore.collection(folder_users).doc(me.uid).collection(folder_posts).doc().id;
    post.id = postId;
    await _firestore.collection(folder_users).doc(me.uid).collection(folder_posts).doc(postId).set(post.toJson());

    return post;
  }

  static Future<List<Post>> refreshPost()async{
    List<Post> posts = [];
    Member me = await loadMember();

    var querySnapshot = await _firestore
        .collection(folder_users)
    .doc(me.uid).collection(folder_posts).get();

    querySnapshot.docs.forEach((result) {
      posts.add(Post.fromJSON(result.data()));
    });

    posts.forEach((element) {
      element.uid = me.uid;
      element.fullname = me.fullname;
      element.img_user = me.img_url;
      element.handle = me.handle;
    });

    return posts;
  }

  static Future<Post> storeFeed(Post post)async{
    String uid = AuthService.currentUserId();
    await _firestore.collection(folder_users).doc(uid).collection(folder_feeds).doc(post.id).set(post.toJson());
    return post;
  }

  static Future<List<Post>> loadPosts() async {
    List<Post> posts = [];
    String uid = AuthService.currentUserId();
    var querySnapshot = await _firestore.collection(folder_users)
        .doc(uid).collection(folder_posts).get();
    querySnapshot.docs.forEach((result) {
      posts.add(Post.fromJSON(result.data()));
    });
    return posts;
  }

  static Future<List<Post>> loadFeeds() async {
    List<Post> posts = [];
    String uid = AuthService.currentUserId();

    var querySnapshot = await _firestore.collection(folder_users)
        .doc(uid).collection(folder_feeds).get();

    querySnapshot.docs.forEach((result) {
      Post post = Post.fromJSON(result.data());
      if(post.uid == uid) post.mine = true;
      posts.add(post);
    });

    return posts;
  }

  static Future likePost(Post post, bool liked) async {
    String uid = AuthService.currentUserId();
    post.liked = liked;
    
    await _firestore.collection(folder_users).doc(uid).collection(folder_feeds).doc(post.id).set(post.toJson());
    if(uid == post.uid){
      await _firestore.collection(folder_users).doc(uid).collection(folder_posts).doc(post.id).set(post.toJson());
    }
  }

  static Future<List<Post>> loadLikes() async {
    String uid = AuthService.currentUserId();
    List<Post> posts = [];

    var querySnapshot = await _firestore.collection(folder_users)
    .doc(uid).collection(folder_feeds).where("liked", isEqualTo: true).get();

    querySnapshot.docs.forEach((result) {
      Post post = Post.fromJSON(result.data());
      if(post.uid == uid) post.mine = true;
      posts.add(post);
    });

    return posts;
  }

  static Future<bool> followMember(Member someone) async{
    Member me = await loadMember();

    await _firestore.collection(folder_users)
        .doc(me.uid).collection(folder_following)
        .doc(someone.uid).set(someone.toJson());
    
    await _firestore.collection(folder_users)
        .doc(someone.uid).collection(folder_followers)
        .doc(me.uid).set(me.toJson());

    return true;
  }

  static Future<bool> unFollowMember(Member someone) async{
    Member me = await loadMember();

    await _firestore.collection(folder_users)
        .doc(me.uid).collection(folder_following)
        .doc(someone.uid).delete();

    await _firestore.collection(folder_users)
        .doc(someone.uid).collection(folder_followers)
        .doc(me.uid).delete();

    return false;
  }

  static Future storePostsToMyFeed(Member someone) async {
    List<Post> posts = [];
    var querySnapshot = await _firestore.collection(folder_users)
        .doc(someone.uid).collection(folder_posts).get();

    querySnapshot.docs.forEach((result) {
      var post = Post.fromJSON(result.data());
      post.liked = false;
      posts.add(post);
    });

    for(Post post in posts){
      storeFeed(post);
    }
  }

  static Future removeFeed(Post post) async {
    String uid = AuthService.currentUserId();
    return await _firestore.collection(folder_users).doc(uid)
        .collection(folder_feeds).doc(post.id).delete();
  }

  static Future removePostsFromMyFeed(Member someone) async {
    List<Post> posts = [];
    var querySnapshot = await _firestore.collection(folder_users)
        .doc(someone.uid).collection(folder_posts).get();
    
    querySnapshot.docs.forEach((result) {
      posts.add(Post.fromJSON(result.data()));
    });

    for (Post post in posts){
      removeFeed(post);
    }
  }


  static Future removePost(Post post)async{
    String uid = AuthService.currentUserId();
    await removeFeed(post);
    return await _firestore.collection(folder_users)
        .doc(uid).collection(folder_posts).doc(post.id).delete();
  }


  static Future<Member> loadOtherMember(String uid) async{
    var value = await _firestore.collection(folder_users).doc(uid).get();
    Member member = Member.fromJson(value.data()!);

    var querySnapshot1 = await _firestore.collection(folder_users)
        .doc(uid).collection(folder_followers).get();
    member.followers_count = querySnapshot1.docs.length;

    var querySnapshot2 = await _firestore.collection(folder_users)
        .doc(uid).collection(folder_following).get();
    member.following_count = querySnapshot2.docs.length;

    return member;
  }

  static Future<List<Post>> loadOtherPosts(String uid) async {
    List<Post> posts = [];
    var querySnapshot = await _firestore.collection(folder_users)
        .doc(uid).collection(folder_posts).get();
    querySnapshot.docs.forEach((result) {
      posts.add(Post.fromJSON(result.data()));
    });
    return posts;
  }

  static Future<Member> loadUser(String? userUid) async {
    userUid ??= HiveDB.loadUid();
    var value = await _firestore.collection(folder_users).doc(userUid).get();
    Member user = Member.fromJson(value.data()!);

    var querySnapshot1 = await _firestore
        .collection(folder_users)
        .doc(userUid)
        .collection(folder_followers)
        .get();
    user.followers_count = querySnapshot1.docs.length;

    var querySnapshot2 = await _firestore
        .collection(folder_users)
        .doc(userUid)
        .collection(folder_following)
        .get();
    user.following_count = querySnapshot2.docs.length;

    return user;
  }

  static Future<List<Post>> loadOtherfPosts(String? userUid) async {
    List<Post> posts = [];
    userUid ??= HiveDB.loadUid();
    var querySnapshot = await _firestore
        .collection(folder_users)
        .doc(userUid)
        .collection(folder_posts)
        .get();
    for (var element in querySnapshot.docs) {
      Post post = Post.fromJSON(element.data());
      posts.add(post);
    }
    return posts;
  }

  static Future<Post> loadThatPost(String? userUid, String uid) async {
    print(uid);
    var querySnapshot = await _firestore
        .collection(folder_users)
        .doc(userUid)
        .collection(folder_posts)
        .doc(uid).get();
    Post post = Post.fromJSON(querySnapshot.data()!);
    return post;
  }

  static Future<bool> isFollowing(Member someone) async {

    String myUid = AuthService.currentUserId();

    var result = await _firestore.collection(folder_users)
        .doc(myUid).collection(folder_following)
        .doc(someone.uid).get();

    return result.exists;

  }

}