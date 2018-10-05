import 'package:flutter/material.dart';
import 'dart:async';

class InfiniteBanner extends StatefulWidget{
  final List<Widget> data;
  final int delayTime,duration,count;
  InfiniteBanner({
    Key key,
    @required this.data,
    this.delayTime = 2000,
    this.duration = 3000,
    this.count = 30
  }):super(key : key);
  @override
    State<StatefulWidget> createState() {
      // TODO: implement createState
      return InfiniteBannerState();
    }
}
class InfiniteBannerState extends State<InfiniteBanner>{
  // 控制页面切换
  PageController controller;
  // 定时器
  Timer timer;
  // 是否处于滚动状态 当用户主动触摸时，设置为false
  // 此处的滚动是指controller.nextPage()
  bool isRoll = false;
  int currentPage,position;
  List<Widget> bannerList = [];
  // 重写initState，在生命周期里，initState只会执行一次
  void initState(){
    super.initState();
    initData();
    autoPlay();
  }
  Widget build(BuildContext context){
    return Container(
      child: Stack(
        children: <Widget>[
          _bannerView(),
          _indicator()
        ]
      ),
    );
  }
  void onPageChanged(index){
    currentPage = index;
    setState(() {});
  }
  // 数据初始化
  void initData(){
    var first = widget.data.first;
    var last = widget.data.last;
    bannerList.add(last);
    bannerList.addAll(widget.data);
    bannerList.add(first);
    currentPage=1;
    controller = PageController(initialPage: 1);
  }
  // 获取数量
  int getCount () => widget.data.length;
  // 定时器
  void autoPlay(){
    if(timer == null){
      // 设定定时器，每隔delayTime检测是否处于滚动，如果不处于滚动，则滚动到下一个banner
      timer = Timer.periodic(Duration(milliseconds: widget.delayTime), (timer) {
        if(!isRoll){
          controller.nextPage(duration: Duration(milliseconds: widget.duration),
              curve: Curves.linear);      
        }
      });
    }
  }
  // 轮播点
  Widget _indicator(){
    return Align(
      alignment: FractionalOffset.bottomCenter,
        child:Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:_dotList()
        ),
    );
  }
  List<Widget>  _dotList(){
    List<Widget> dotList = [];
    int count = getCount();
    for(var i = 0;i<count;i++){
      dotList.add(Container(
        width: 8.0,
        height: 8.0,
        margin: EdgeInsets.only(left: 3.0,right:3.0,bottom:8.0),
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          color: currentPage == (i+1) ? Colors.black38 : Colors.white,
        ),)
      );
    }
    return dotList;

  }
  // 轮播图片Widget
  Widget _bannerView() {
    return Listener(
      
      // 当屏幕被按压
      onPointerDown: (evt){
        isRoll = true;
      },
      // 当按压取消
      onPointerCancel: (evt){
        isRoll = false;
      },
      // 当不被按压
      onPointerUp: (evt){
        isRoll = false;
      },
      child: NotificationListener(
        onNotification: (scrollNotification){
          // 判断滚动是否停止或者是用户改变了滚动方向
          if (scrollNotification is ScrollEndNotification || scrollNotification is UserScrollNotification) {
            print(currentPage);
            if(currentPage == 0) {
             setState(() {
                currentPage = getCount();
                controller.jumpToPage(getCount());       
              });
            }else if(currentPage == getCount()+1){
              setState(() {
                currentPage = 1;
                controller.jumpToPage(1);       
              });
            }
            isRoll = false;
          }else{
            isRoll = true;
          }
        },
        child: PageView.custom(
          controller: controller,
          onPageChanged: onPageChanged,
          childrenDelegate:SliverChildBuilderDelegate((context,index){
            int current = index % bannerList.length;
            Widget render  =  bannerList[current];
              return GestureDetector(
                child: render,
              );
            } ,
             childCount: bannerList.length
        ),
      )
    ));
  }
}