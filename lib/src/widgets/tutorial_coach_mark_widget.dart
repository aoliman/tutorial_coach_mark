import 'package:flutter/material.dart';
import '../target/target_content.dart';
import '../target/target_focus.dart';
import '../target/target_position.dart';
import '../util.dart';
import 'animated_focus_light.dart';

class TutorialCoachMarkWidget extends StatefulWidget {
  const TutorialCoachMarkWidget({
    Key key,
    this.targets,
    this.finish,
    this.paddingFocus = 10,
    this.clickTarget,
    this.clickOverlay,
    this.alignSkip = Alignment.bottomRight,
    this.textSkip = "SKIP",
    this.onClickSkip,
    this.colorShadow = Colors.black,
    this.opacityShadow = 0.8,
    this.textStyleSkip = const TextStyle(color: Colors.white),
    this.hideSkip,
    this.focusAnimationDuration,
    this.pulseAnimationDuration,
    this.itemCount,
    this.startItem,
    this.selectItemColor,
    this.unSelectItemColor
  }) : super(key: key);

  final List<TargetFocus> targets;
  final Function(TargetFocus) clickTarget;
  final Function(TargetFocus) clickOverlay;
  final Function() finish;
  final Color colorShadow;
  final double opacityShadow;
  final double paddingFocus;
  final Function(TargetFocus) onClickSkip;
  final AlignmentGeometry alignSkip;
  final String textSkip;
  final TextStyle textStyleSkip;
  final bool hideSkip;
  final Duration focusAnimationDuration;
  final Duration pulseAnimationDuration;
  final num itemCount;
  final num startItem ;
  final Color selectItemColor;
  final Color unSelectItemColor;

  @override
  TutorialCoachMarkWidgetState createState() => TutorialCoachMarkWidgetState();
}

class TutorialCoachMarkWidgetState extends State<TutorialCoachMarkWidget> {
  final GlobalKey<AnimatedFocusLightState> _focusLightKey = GlobalKey();
  bool showContent = false;
  TargetFocus currentTarget;
  num currentController;
  @override
  void initState() {
    super.initState();
    currentController = widget.startItem;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: <Widget>[
          AnimatedFocusLight(
            key: _focusLightKey,
            targets: widget.targets,
            finish: widget.finish,
            paddingFocus: widget.paddingFocus,
            colorShadow: widget.colorShadow,
            opacityShadow: widget.opacityShadow,
            focusAnimationDuration: widget.focusAnimationDuration,
            pulseAnimationDuration: widget.pulseAnimationDuration,
            clickTarget: (target) {
              widget.clickTarget?.call(target);
              currentController += 1;
            },
            clickOverlay: (target) {
              widget.clickOverlay?.call(target);

            },
            focus: (target) {
              setState(() {
                currentTarget = target;
                showContent = true;
              });
            },
            removeFocus: () {
              setState(() {
                showContent = false;
              });
            },
          ),
          AnimatedOpacity(
            opacity: showContent ? 1 : 0,
            duration: Duration(milliseconds: 300),
            child: _buildContents(),
          ),

          Container(child:
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
            _buildSkip(),
            Align(
              alignment:Alignment.bottomCenter ,
               child: Container(color: Colors.transparent,margin: EdgeInsets.only(bottom: 24),width: 70,height: 12,
                 child: ListView.builder(itemBuilder: (context, index) {
                   return Container(margin: EdgeInsets.all(2),decoration: BoxDecoration(color: index == currentController? widget.selectItemColor ?? Colors.black.withOpacity(0.5): widget.unSelectItemColor ?? Colors.white,borderRadius: BorderRadius.circular(8)),height: 16,width: 8,);
                 },itemCount:widget.itemCount ,scrollDirection: Axis.horizontal,),
               ),
             ),
            _buildNext(),
          ],),)
        ],
      ),
    );
  }

  Widget _buildContents() {
    if (currentTarget == null) {
      return SizedBox.shrink();
    }

    List<Widget> children = List();

    TargetPosition target = getTargetCurrent(currentTarget);

    var positioned = Offset(
      target.offset.dx + target.size.width / 2,
      target.offset.dy + target.size.height / 2,
    );

    double haloWidth;
    double haloHeight;

    if (currentTarget.shape == ShapeLightFocus.Circle) {
      haloWidth = target.size.width > target.size.height ? target.size.width : target.size.height;
      haloHeight = haloWidth;
    } else {
      haloWidth = target.size.width;
      haloHeight = target.size.height;
    }

    haloWidth = haloWidth * 0.6 + widget.paddingFocus;
    haloHeight = haloHeight * 0.6 + widget.paddingFocus;

    double weight = 0.0;
    double top;
    double bottom;
    double left;

    children = currentTarget.contents.map<Widget>((i) {
      switch (i.align) {
        case ContentAlign.bottom:
          {
            weight = MediaQuery.of(context).size.width;
            left = 0;
            top = positioned.dy + haloHeight;
            bottom = null;
          }
          break;
        case ContentAlign.top:
          {
            weight = MediaQuery.of(context).size.width;
            left = 0;
            top = null;
            bottom = haloHeight + (MediaQuery.of(context).size.height - positioned.dy);
          }
          break;
        case ContentAlign.left:
          {
            weight = positioned.dx - haloWidth;
            left = 0;
            top = positioned.dy - target.size.height / 2 - haloHeight;
            bottom = null;
          }
          break;
        case ContentAlign.right:
          {
            left = positioned.dx + haloWidth;
            top = positioned.dy - target.size.height / 2 - haloHeight;
            bottom = null;
            weight = MediaQuery.of(context).size.width - left;
          }
          break;
        case ContentAlign.custom:
          {
            left = i.customPosition.left;
            top = i.customPosition.top;
            bottom = i.customPosition.bottom;
            weight = MediaQuery.of(context).size.width;
          }
          break;
      }

      return Positioned(
        top: top,
        bottom: bottom,
        left: left,
        child: Container(
          width: weight,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: i.child,
          ),
        ),
      );
    }).toList();

    return Stack(
      children: children,
    );
  }

  Widget _buildSkip() {
    if (widget.hideSkip) {
      return SizedBox.shrink();
    }
    return Align(
      alignment: currentTarget?.alignSkip ?? widget.alignSkip,
      child: SafeArea(
        child: AnimatedOpacity(
          opacity: showContent ? 1 : 0,
          duration: Duration(milliseconds: 300),
          child: InkWell(
            onTap: (){
              widget.onClickSkip(currentTarget);
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                widget.textSkip,
                style: widget.textStyleSkip,
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildNext() {
    return Align(
      alignment: currentTarget?.alignSkip ?? widget.alignSkip,
      child: SafeArea(
        child: AnimatedOpacity(
          opacity: showContent ? 1 : 0,
          duration: Duration(milliseconds: 300),
          child: InkWell(
            onTap: next,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("التالى",
                style: widget.textStyleSkip,
              ),
            ),
          ),
        ),
      ),
    );
  }


  void next(){
    widget.clickTarget?.call(currentTarget);
    _focusLightKey?.currentState?.next();
    setState(() {
      currentController += 1;
    });


  }
  void previous() => _focusLightKey?.currentState?.previous();
}
