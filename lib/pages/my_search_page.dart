import 'package:flutter/material.dart';
import 'package:instaclone/pages/userprofile.dart';
import 'package:instaclone/services/db_service.dart';

import '../model/member_model.dart';

class MySearchPage extends StatefulWidget {
  const MySearchPage({super.key});

  @override
  State<MySearchPage> createState() => _MySearchPageState();
}

class _MySearchPageState extends State<MySearchPage> {
  bool isLoading = false;
  var searchController = TextEditingController();
  List<Member> items = [];

  void _apiSearchMembers(String keyword){
    setState(() {
      isLoading = true;
    });
    DBService.searchMember(keyword).then((users) => {
      _respSearchMembers(users),
    });
  }

  void _respSearchMembers(List<Member> members){
    setState(() {
      items = members;
      isLoading = false;
    });
  }

  void _apiFollowMember(Member someone)async{
    setState(() {
      isLoading =true;
    });
    await DBService.followMember(someone);
    setState(() {
      someone.followed = true;
      isLoading = false;
    });
    DBService.storePostsToMyFeed(someone);
  }

  void _apiUnfollowMember(Member someone)async{
    setState(() {
      isLoading =true;
    });
    await DBService.unFollowMember(someone);
    setState(() {
      someone.followed = false;
      isLoading = false;
    });
    DBService.removePostsFromMyFeed(someone);
  }

  int maxChar = 22;

  @override
  void initState() {
    super.initState();
    _apiSearchMembers("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Search",
          style: TextStyle(
            color: Colors.black, fontFamily: "Billabong", fontSize: 25,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.only(left: 10, right: 10,),
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(7)
                  ),
                  child: TextField(
                    style: TextStyle(color: Colors.black87),
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                      icon: Icon(Icons.search, color: Colors.grey,),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (ctx, index){
                      return _itemOfMember(items[index]);
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

  Widget _itemOfMember(Member member){
    return GestureDetector(
      child: Container(
        height: 90,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(70),
                  border: Border.all(
                    width: 1.5,
                    color: Color.fromRGBO(193, 53, 132, 1),
                  )
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22.5),
                child: member.img_url.isEmpty ? Image(
                  image: AssetImage("assets/images/avatar-3814081_1280.png"),
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                ) : Image.network(member.img_url,
                  width: 45, height: 45, fit: BoxFit.cover,),
              ),
            ),
            SizedBox(width: 15,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.fullname.length < maxChar ? member.fullname :
                "${member.fullname.substring(0, maxChar)}...",
                  style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 3,),
                Text(member.email.length < maxChar ? member.email :
                "${member.email.substring(0, maxChar)}...",
                  style: TextStyle(color: Colors.black54),),
              ],
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: (){
                      if(member.followed){
                        _apiUnfollowMember(member);
                      }else{
                        _apiFollowMember(member);
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                      ),
                      child: Center(
                        child: member.followed ? Text("Following") : Text("Follow"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UserProfilePage(member: member)
        ));
      },
    );
  }

}
