import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:industrial/models/attachment.dart';
import 'package:industrial/models/chat.dart';
import 'package:industrial/models/comment.dart';
import 'package:industrial/models/interest.dart';
import 'package:industrial/models/job.dart';
import 'package:industrial/models/message.dart';
import 'package:industrial/models/post.dart';
import 'package:industrial/models/user.dart';

class Database {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  //COLLECTIONS

  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');
  CollectionReference comments =
      FirebaseFirestore.instance.collection('comments');
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  CollectionReference interests =
      FirebaseFirestore.instance.collection('interests');
  CollectionReference jobs = FirebaseFirestore.instance.collection('jobs');

  //UTILS

  Future<Attachment> postAttachment(File file) async {
    Random rnd = Random();
    int id = rnd.nextInt(4294967296);
    var snapshot = await storage.ref().child('images/$id').putFile(file);
    return Attachment(id: id, url: await snapshot.ref.getDownloadURL());
  }

  //USERS

  Stream<Object> getUserStream(uid) {
    return users.doc(uid).snapshots();
  }

  Future<void> addUser(User user) {
    return users
        .doc(user.id)
        .set(user.toJson())
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<List<User>> getAllUsers() async {
    return (await users.get())
        .docs
        .map((doc) => User.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> editUserData(User user) {
    return users
        .doc(user.id)
        .set(user.toJson())
        .then((value) => print("User Edited"))
        .catchError((error) => print("Failed to edit user: $error"));
  }

  Future<User> getUserData(uid) async {
    return User.fromJson(
        ((await users.doc(uid).get()).data()! as Map<String, dynamic>));
  }

  // POSTS

  Stream<Object> getPostStream(postId) {
    return posts.doc(postId).snapshots();
  }

  Future<Post> getPostData(int postId) async {
    return Post.fromJson(((await posts.doc(postId.toString()).get()).data()!
        as Map<String, dynamic>));
  }

  Future<void> addPostToUser(String uid, int postId) async {
    List postIds = (await getUserData(uid)).toJson()['posts'];
    return users.doc(uid).update({
      'posts': [
        ...postIds,
        postId,
      ]
    });
  }

  Future<void> makePost(Post post) {
    return posts
        .doc(post.id.toString())
        .set(post.toJson())
        .then((value) => print("Post Added"))
        .catchError((error) => print("Failed to add post: $error"));
  }

  Future<void> likePost(Post post, String uid) async {
    List postLikes = (await getPostData(post.id)).toJson()['likes'];
    return posts.doc(post.id.toString()).update({
      'likes': [
        ...postLikes,
        uid,
      ]
    });
  }

  Future<void> unlikePost(Post post, String uid) async {
    List postLikes = (await getPostData(post.id)).toJson()['likes'];
    postLikes.remove(uid);
    return posts.doc(post.id.toString()).update({'likes': postLikes});
  }

  Future<List<Post>> getAllPosts() async {
    return (await posts.where('interests').get())
        .docs
        .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Post>> getPostsWithFilters(List interests) async {
    List inter = await Database().getAllInterests();
    List filter = [];
    inter.forEach((element) {
      if (interests.contains(element.id)) {
        filter.add(element.name);
      }
    });
    print(filter);
    return (await posts.where('interests', arrayContainsAny: filter).get())
        .docs
        .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Post>> getPostWithName(String str) async {
    return (await posts.where('description', isGreaterThanOrEqualTo: str).get())
        .docs
        .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deletePost(String postId, String userId) async {
    posts.doc(postId).delete();
    users.doc(userId);
    List postIds = (await getUserData(userId)).toJson()['posts'];
    postIds.remove(int.parse(postId));
    users.doc(userId).update({'posts': postIds});
  }

  //COMMENTS

  Future<Comment?> getCommentData(String commentId) async {
    var data = (await comments.doc(commentId).get()).data();
    if (data == null) {
      return null;
    }
    return Comment.fromJson((data as Map<String, dynamic>));
  }

  Future<void> postComment(Comment comment) {
    return comments
        .doc(comment.id.toString())
        .set(comment.toJson())
        .then((value) => print("Comment Added"))
        .catchError((error) => print("Failed to add comment: $error"));
  }

  Future<void> addCommentToPost(Post post, Comment comment) async {
    List postComments = (await getPostData(post.id)).toJson()['comments'];
    return posts.doc(post.id.toString()).update({
      'comments': [
        ...postComments,
        comment.id,
      ]
    });
  }

  //CHATS

  Stream<Object> getChatStream(id) {
    return chats.doc(id).snapshots();
  }

  Future<void> createChat(Chat chat) {
    chat.users.forEach((element) {
      addChatToUser(element, chat);
    });
    return chats
        .doc(chat.id.toString())
        .set(chat.toJson())
        .then((value) => print("Chat Added"))
        .catchError((error) => print("Failed to add chat: $error"));
  }

  Future<void> addChatToUser(uid, Chat chat) async {
    List userChats = (await getUserData(uid)).toJson()['chats'];
    return users.doc(uid).update({
      'chats': [
        ...userChats,
        {
          'id': chat.id,
          'users': [chat.users.firstWhere((element) => element != uid)]
        }
      ]
    });
  }

  Future<Chat?> searchForChat(uid, receiverId) async {
    if (uid == receiverId) {
      return null;
    }
    try {
      Chat? chat = (await chats.get())
          .docs
          .map((doc) => Chat?.fromJson(doc.data() as Map<String, dynamic>))
          .toList()
          .firstWhere((element) =>
              element.users.length == 2 &&
              element.users.contains(uid) &&
              element.users.contains(receiverId));
      return chat;
    } catch (e) {
      return null;
    }
  }

  Future<Chat> getChatData(String chatId) async {
    return Chat.fromJson(
        ((await chats.doc(chatId).get()).data()! as Map<String, dynamic>));
  }

  Future<void> postMessage(String chatId, Message message) async {
    List chatMessages = (await getChatData(chatId)).toJson()['messages'];
    return chats.doc(chatId).update({
      'messages': [
        ...chatMessages,
        message.toJson(),
      ]
    });
  }

  //INTERESTS

  Future<List<Interest>> getAllInterests() async {
    List<Interest> result = (await interests.get())
        .docs
        .map((doc) => Interest.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    return result;
  }

  //JOBS

  Future<List<Job>> getAllJobs() async {
    List<Job> result = (await jobs.get())
        .docs
        .map((doc) => Job.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    return result;
  }

  Future<void> addJobToUser(String uid, int jobId) async {
    List jobIds = (await getUserData(uid)).toJson()['jobs'] ?? [];
    return users.doc(uid).update({
      'jobs': [
        ...jobIds,
        jobId,
      ]
    });
  }

  Future<void> makeJob(Job job) {
    return jobs
        .doc(job.id.toString())
        .set(job.toJson())
        .then((value) => print("Job Added"))
        .catchError((error) => print("Failed to add job: $error"));
  }

  Future<Job> getJobData(int jobId) async {
    return Job.fromJson(((await jobs.doc(jobId.toString()).get()).data()!
        as Map<String, dynamic>));
  }

  Stream<Object> getJobsStream(jobId) {
    return jobs.doc(jobId).snapshots();
  }

  Future<List<Job>> getJobWithName(String str) async {
    return (await jobs.where('description', isGreaterThanOrEqualTo: str).get())
        .docs
        .map((doc) => Job.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteJob(String jobId, String userId) async {
    jobs.doc(jobId).delete();
    users.doc(userId);
    List jobIds = (await getUserData(userId)).toJson()['jobs'] ?? [];
    jobIds.remove(int.parse(jobId));
    users.doc(userId).update({'posts': jobIds});
  }
}
