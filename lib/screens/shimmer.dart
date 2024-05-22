import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerList extends StatefulWidget {
  const ShimmerList({super.key});

  @override
  State<ShimmerList> createState() => _ShimmerListState();
}

class _ShimmerListState extends State<ShimmerList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: ListView.builder(
              itemCount: 8,
              itemBuilder: (context,index){
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Shimmer.fromColors(
                      child:const ShimmerLayout() ,
                      baseColor: Colors.grey.withOpacity(0.5),
                      highlightColor: Colors.white
                  ),
                );
              }
          ),
        )
    );
  }
}

class ShimmerLayout extends StatefulWidget {
  const ShimmerLayout({super.key});

  @override
  State<ShimmerLayout> createState() => _ShimmerLayoutState();
}

class _ShimmerLayoutState extends State<ShimmerLayout> {
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          height: 30,
          width: MediaQuery.of(context).size.width - 40,
          color: Colors.grey,
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 80,
              height: 15,
              color: Colors.grey,
            ),
            SizedBox(width: 10),
            Container(
              width: 60,
              height: 15,
              color: Colors.grey,
            ),


          ],
        ),

        Container(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          height: 30,
          width: MediaQuery.of(context).size.width - 40,
          color: Colors.grey,
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 60,
              height: 15,
              color: Colors.grey,
            ),
            SizedBox(width: 10),
            Container(
              width: 60,
              height: 15,
              color: Colors.grey,
            ),

          ],
        ),
      ],
    );
  }
}







class ShimmerScreen extends StatefulWidget {
  const ShimmerScreen({Key? key}) : super(key: key);

  @override
  State<ShimmerScreen> createState() => _ShimmerScreenState();
}

class _ShimmerScreenState extends State<ShimmerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          itemCount: 2,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.withOpacity(0.5),
                highlightColor: Colors.white,
                child: const ChallengeShimmer(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ChallengeShimmer extends StatelessWidget {
  const ChallengeShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(

      width: 350,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Colors.grey.withOpacity(0.8),
            width: 1,
          ),
        ),

        color: Colors.transparent,
        child: ListTile(
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                child: Row(
                  children: [

                    SizedBox(width: 50),
                  ],
                ),
              ),
              SizedBox(height: 10,),


              SizedBox(height: 10,)

            ],
          ),
        ),
      ),
    );
  }
}




class ShimmerDetail extends StatefulWidget {
  const ShimmerDetail({super.key});

  @override
  State<ShimmerDetail> createState() => _ShimmerDetailState();
}




class _ShimmerDetailState extends State<ShimmerDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: ListView.builder(
              itemCount: 6,
              itemExtent: 250,

              itemBuilder: (context,index){
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Shimmer.fromColors(
                      child:const LayoutDetail() ,
                      baseColor: Colors.grey.withOpacity(0.5),
                      highlightColor: Colors.white
                  ),
                );
              }
          ),
        )
    );
  }
}





class LayoutDetail extends StatefulWidget {
  const LayoutDetail({super.key});

  @override
  State<LayoutDetail> createState() => _LayoutDetailState();
}

class _LayoutDetailState extends State<LayoutDetail> {
  @override
  Widget build(BuildContext context) {
              return Container(
                height: 100,
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.grey,

                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: Colors.grey.withOpacity(0.8),
                      width: 1,
                    ),
                  ),

                  color: Colors.transparent,
                  child: ListTile(

                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          child: Row(
                            children: [

                              SizedBox(width: 50),
                            ],
                          ),
                        ),

                        SizedBox(height: 10,)

                      ],
                    ),
                  ),
                ),
              );
  }
}
