import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:instaclone/model/post_model.dart';
import 'package:instaclone/pages/home_page.dart';
import 'package:share/share.dart';

import '../services/db_service.dart';
import '../services/utils_service.dart';

class PostPage extends StatefulWidget {
  final Post post;
  PostPage({super.key, required this.post});

  @override
  State<PostPage> createState() => _PostPageState();
}


class _PostPageState extends State<PostPage> {
  bool isLoading = false;
  late final Post post;


  _dialogRemovePost(Post post)async{
    var result = await Utils.dialogCommon(context, "Instagram", "Do you want to remove this post?", false);
    if(result){
      setState(() {
        isLoading = true;
      });
      DBService.removePost(post).then((value) => {
        Navigator.pushReplacementNamed(context, HomePage.id)
      });
    }
  }

  void _apiPostLike(Post post) async {
    setState(() {
      isLoading = true;
    });

    await DBService.likePost(post, true);
    setState(() {
      isLoading = false;
      post.liked = true;
    });
  }

  void _apiPostUnLike(Post post) async {
    setState(() {
      isLoading = true;
    });

    await DBService.likePost(post, false);
    setState(() {
      isLoading = false;
      post.liked = false;
    });
  }


  @override
  void initState() {
    super.initState();
    post = widget.post;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Post",
            style: TextStyle(
                color: Colors.black, fontSize: 25, fontFamily: "Billabong"),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Color.fromRGBO(193, 53, 132, 1),
              )),
        ),
      body: Stack(
        children: [
          Container(
              width: MediaQuery.of(context).size.width,
              child: _itemOfPost(post)),
          isLoading ? const Center(
            child: CircularProgressIndicator(),
          ) : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _itemOfPost(Post post) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Divider(),
          GestureDetector(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child:
                          post.img_user.isEmpty ? const Image(
                            image: AssetImage("assets/images/avatar-3814081_1280.png"),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ) :
                          Image.network(post.img_user,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 10,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.handle,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            SizedBox(height: 2,),
                            Text(post.date,
                              style: TextStyle(fontWeight: FontWeight.normal,),
                            ),
                          ],
                        )
                      ],
                    ),
                    post.mine ? IconButton(
                      icon: Icon(Icons.more_horiz),
                      onPressed: (){
                        _dialogRemovePost(post);
                      },
                    ) : SizedBox.shrink()
                  ],
                ),
              ),
          ),
          const SizedBox(height: 8,),
          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            imageUrl: post.img_post,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
          ),
          Row(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: (){
                      if(!post.liked){
                        _apiPostLike(post);
                      }else{
                        _apiPostUnLike(post);
                      }
                    },
                    icon: post.liked ? const Icon(
                      EvaIcons.heart,
                      color: Colors.red,
                    ) : const Icon(
                      EvaIcons.heartOutline,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () async{
                      await Share.share(post.img_post, subject: "Check out this post: ${post.caption}");
                    },
                    icon: const Icon(
                      EvaIcons.shareOutline,
                    ),
                  ),
                ],
              )
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
            child: RichText(
              softWrap: true,
              overflow: TextOverflow.visible,
              text: TextSpan(
                  text: "${post.caption}",
                  style: const TextStyle(color: Colors.black)
              ),
            ),
          ),
        ],
      ),
    );
  }
}
