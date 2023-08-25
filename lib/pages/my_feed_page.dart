import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

import '../model/post_model.dart';
class MyFeedPage extends StatefulWidget {
  final PageController? pageController;
  const MyFeedPage({super.key, this.pageController});

  @override
  State<MyFeedPage> createState() => _MyFeedPageState();
}

class _MyFeedPageState extends State<MyFeedPage> {
  bool isLoading = false;
  List<Post> items = [];

  String image_1 =
      "https://images.unsplash.com/photo-1509695507497-903c140c43b0";
  String image_2 =
      "https://images.unsplash.com/photo-1536640217560-1085f2c1bcdb";
  String image_3=
      "https://images.unsplash.com/photo-1647891941746-fe1d53ddc7a6";

  @override
  void initState() {
    super.initState();
    items.add(Post(image_1, "Best photo I have ever seen"));
    items.add(Post(image_2, "Best photo I have ever seen"));
    items.add(Post(image_3, "Best photo I have ever seen"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text("Instagram", style: TextStyle(color: Colors.black, fontFamily: 'Billabong', fontSize: 30),),
        actions: [
          IconButton(
            onPressed: (){
              widget.pageController!.animateToPage(2, duration: Duration(milliseconds: 200), curve: Curves.easeIn);
            },
            color: Color.fromRGBO(193, 53, 132, 1),
            icon: Icon(Icons.camera_alt),
          ),
        ],
      ),

      body: Stack(
        children: [
          ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, index){
              return _itemOfPost(items[index]);
            },
          ),

          isLoading ? Center(
            child: CircularProgressIndicator(),
          ) : SizedBox.shrink(),
        ],
      )
    );
  }

  Widget _itemOfPost(Post post){
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Divider(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image(
                        image: AssetImage("assets/images/avatar-3814081_1280.png"),
                        width: 40,
                        height: 40,
                      ),
                    ),
                    SizedBox(width: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Zafar",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        SizedBox(height: 3,),
                        Text("2023-09-03 13:40",
                          style: TextStyle(fontWeight: FontWeight.normal,),
                        ),
                      ],
                    )
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz),
                  onPressed: (){},
                )
              ],
            ),
          ),
          SizedBox(height: 8,),
          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            imageUrl: post.img_post,
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
            fit: BoxFit.cover,
          ),
          Row(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: (){},
                    icon: Icon(
                      EvaIcons.heartOutline,
                      color: Colors.red,
                    ),
                  ),
                  IconButton(
                    onPressed: (){},
                    icon: Icon(
                      EvaIcons.shareOutline,
                    ),
                  ),
                ],
              )
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(right: 10, left: 10, bottom: 10),
            child: RichText(
              softWrap: true,
              overflow: TextOverflow.visible,
              text: TextSpan(
                text: "${post.caption}",
                style: TextStyle(color: Colors.black)
              ),
            ),
          ),
        ],
      ),
    );
  }
}
