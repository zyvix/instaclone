import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:instaclone/model/member_model.dart';
import 'package:instaclone/services/db_service.dart';
import 'package:share/share.dart';
import '../model/post_model.dart';
import '../services/utils_service.dart';
import 'feeduserpage.dart';
class MyFeedPage extends StatefulWidget {
  final PageController? pageController;
  const MyFeedPage({super.key, this.pageController});

  @override
  State<MyFeedPage> createState() => _MyFeedPageState();
}

class _MyFeedPageState extends State<MyFeedPage> {
  bool isLoading = false;
  List<Post> items = [];

  _apiLoadFeeds(){
    setState(() {
      isLoading = true;
    });
    DBService.loadFeeds().then((value) => {
      _resLoadFeeds(value),
    });
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

  _resLoadFeeds(List<Post> posts) {
    setState(() {
      items = posts;
      isLoading = false;
    });

  }

  _dialogRemovePost(Post post)async{
    var result = await Utils.dialogCommon(context, "Instagram", "Do you want to remove this post?", false);
    if(result){
      setState(() {
        isLoading = true;
      });
      DBService.removePost(post).then((value) => {
        _apiLoadFeeds(),
      });
    }
  }


  @override
  void initState() {
    super.initState();
    _apiLoadFeeds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Instagram", style: TextStyle(color: Colors.black, fontFamily: 'Billabong', fontSize: 30),),
        actions: [
          IconButton(
            onPressed: (){
              widget.pageController!.animateToPage(2, duration: const Duration(milliseconds: 100), curve: Curves.easeIn);
            },
            color: const Color.fromRGBO(193, 53, 132, 1),
            icon: const Icon(Icons.camera_alt),
          ),
        ],
      ),

      body: Stack(
        children: [
          ListView.builder(
            itemCount: items.length,
            reverse: false,
            itemBuilder: (ctx, index){
              return _itemOfPost(items[index]);
            },
          ),
          isLoading ? const Center(
            child: CircularProgressIndicator(),
          ) : const SizedBox.shrink(),
        ],
      )
    );
  }

  Widget _itemOfPost(Post post){
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
              onTap: () {
                if (!post.mine) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              OtherProfilePage(uid: post.uid)));
                }
              }
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
