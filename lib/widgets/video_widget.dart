import 'package:flutter/material.dart';
import 'package:douban_app/widgets/image/cached_network_image.dart';
import 'package:douban_app/constant/Constant.dart';
import 'package:douban_app/widgets/video_progress_bar.dart';

///http://vt1.doubanio.com/201902111139/0c06a85c600b915d8c9cbdbbaf06ba9f/view/movie/M/302420330.mp4
class VideoWidget extends StatefulWidget {
  final String url;
  final String previewImgUrl; //预览图片的地址

  VideoWidget(this.url, {Key key, this.previewImgUrl}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VideoWidgetState();
  }
}

class _VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController _controller;
  VoidCallback listener;
  bool _showSeekBar = true;

  _VideoWidgetState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        //初始化完成后，更新状态
        setState(() {});
        if (_controller.value.duration == _controller.value.position) {
          _controller.seekTo(Duration(seconds: 0));
          setState(() {});
        }
      });
    _controller.addListener(listener);
  }

  @override
  void deactivate() {
    _controller.removeListener(listener);
    super.deactivate();
  }

  FadeAnimation imageFadeAnim =
      FadeAnimation(child: const Icon(Icons.play_arrow, size: 100.0));

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      GestureDetector(
        child: VideoPlayer(_controller),
        onTap: () {
          _showSeekBar = !_showSeekBar;
//          if (!_controller.value.initialized) {
//            return;
//          }
//          if (_controller.value.isPlaying) {
//            imageFadeAnim =
//                FadeAnimation(child: const Icon(Icons.pause, size: 100.0));
//            _controller.pause();
//          } else {
//            imageFadeAnim =
//                FadeAnimation(child: const Icon(Icons.play_arrow, size: 100.0));
//            _controller.play();
//          }
        },
      ),
      Align(
        child: IconButton(
            iconSize: 55.0,
            icon: Image.asset(Constant.ASSETS_IMG +
                (_controller.value.isPlaying
                    ? 'ic_pause.png'
                    : 'ic_playing.png')),
            onPressed: () {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            }),
        alignment: Alignment.center,
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                height: 13.0,
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                      playedColor: Colors.amberAccent,
                      backgroundColor: Colors.grey),
                ),
              ),
            ),
            getDurationText()
          ],
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Center(
            child: _controller.value.isBuffering
                ? const CircularProgressIndicator()
                : null),
      ),
      Center(child: imageFadeAnim),
    ];

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        fit: StackFit.passthrough,
        children: children,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose(); //释放播放器资源
  }

  Widget getPreviewImg() {
    return widget.previewImgUrl.isNotEmpty
        ? CachedNetworkImage(imageUrl: widget.previewImgUrl)
        : null;
  }

  getMinuteSeconds(var inSeconds) {
    if (inSeconds == null || inSeconds <= 0) {
      return '00:00';
    }
    var tmp = inSeconds ~/ Duration.secondsPerMinute;
    var minute;
    if (tmp < 10) {
      minute = '0$tmp';
    } else {
      minute = '$tmp';
    }

    var tmp1 = inSeconds % Duration.secondsPerMinute;
    var seconds;
    if (tmp1 < 10) {
      seconds = '0$tmp1';
    } else {
      seconds = '$tmp1';
    }
    return '$minute:$seconds';
  }

  getDurationText() {
    var txt;
    if (_controller.value.position == null ||
        _controller.value.duration == null) {
      txt = '00:00/00:00';
    } else {
      txt =
          '${getMinuteSeconds(_controller.value.position.inSeconds)}/${getMinuteSeconds(_controller.value.duration.inSeconds)}';
    }
    return Text(
      '$txt',
      style: TextStyle(color: Colors.white, fontSize: 14.0),
    );
  }
}

class FadeAnimation extends StatefulWidget {
  FadeAnimation(
      {this.child, this.duration = const Duration(milliseconds: 500)});

  final Widget child;
  final Duration duration;

  @override
  _FadeAnimationState createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: widget.duration, vsync: this);
    animationController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    animationController.forward(from: 0.0);
  }

  @override
  void deactivate() {
    animationController.stop();
    super.deactivate();
  }

  @override
  void didUpdateWidget(FadeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return animationController.isAnimating
        ? Opacity(
            opacity: 1.0 - animationController.value,
            child: widget.child,
          )
        : Container();
  }
}