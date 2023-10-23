import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instaclone/model/member_model.dart';
import 'package:instaclone/pages/post_page.dart';
import 'package:instaclone/services/db_service.dart';
import '../model/post_model.dart';

class UserProfilePage extends StatefulWidget {

  final Member member;

  const UserProfilePage({super.key, required this.member});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool isLoading = false;
  int axisCount = 1;
  List<Post> items = [];
  String fullname = "", email = "", img_url = "";
  int count_posts = 0, count_followers = 0, count_following = 0;
  Member fullMember = Member("", "", "", "");

  _resLoadPosts(List<Post> posts){
    setState(() {
      items = posts;
      count_posts = posts.length;
    });
  }

  _loadFullMemberData() async {
    await DBService.loadOtherMember(widget.member.uid).then((value) => {
      _showMemberInfo(value),
    });
  }

  _loadUserPosts() async {
    await DBService.loadOtherPosts(widget.member.uid).then((value) => {
      _resLoadPosts(value),
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFullMemberData();
    _loadUserPosts();
  }

  void _showMemberInfo(Member member){
    setState(() {
      isLoading = false;
      fullname = member.fullname;
      email = member.email;
      img_url = member.img_url;
      count_following = member.following_count;
      count_followers = member.followers_count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Profile",
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
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                GestureDetector(
                  onTap: (){},
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(70),
                          border: Border.all(
                            width: 1.5,
                            color: const Color.fromRGBO(193, 53, 132, 1),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: img_url.isEmpty ? const Image(
                            image: AssetImage("assets/images/avatar-3814081_1280.png"),
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ) : Image.network(
                            img_url,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //myinfo
                const SizedBox(height: 10,),
                Text(fullname.toUpperCase(),
                    style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3,),
                Text(email,
                    style: const TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.normal)),

                //mycounts
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: 80,
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Column(
                            children: [
                              Text(count_posts.toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),),
                              const SizedBox(height: 3,),
                              const Text("POSTS",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Column(
                            children: [
                              Text(count_followers.toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),),
                              const SizedBox(height: 3,),
                              const Text("FOLLOWERS",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Column(
                            children: [
                              Text(count_following.toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),),
                              const SizedBox(height: 3,),
                              const Text("FOLLOWING",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            axisCount = 1;
                          });
                        },
                        child: const Icon(
                          Icons.list_alt,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            axisCount = 2;
                          });
                        },
                        child: const Icon(
                          Icons.grid_view,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: axisCount,
                    ),
                    itemCount: items.length,
                    itemBuilder: (ctx, index){
                      return _itemOfPost(items[index]);
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemOfPost(Post post){
    return Container(
      margin: const EdgeInsets.all(5),
      child: GestureDetector(
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PostPage(post: post)
          ));
        },
        child: Column(
          children: [
            Expanded(
              child: CachedNetworkImage(
                width: MediaQuery.of(context).size.width,
                imageUrl: post.img_post,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 3,),
            Text(post.caption, style: TextStyle(color: Colors.black87.withOpacity(0.7)),
              maxLines: 2,)
          ],
        ),
      ),
    );
  }



}
