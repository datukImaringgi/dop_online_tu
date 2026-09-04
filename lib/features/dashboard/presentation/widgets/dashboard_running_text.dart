import 'package:flutter/material.dart';

class DashboardRunningText
    extends StatefulWidget {
  const DashboardRunningText({
    super.key,
  });

  @override
  State<DashboardRunningText> createState() {
    return _DashboardRunningTextState();
  }
}

class _DashboardRunningTextState
    extends State<DashboardRunningText>
    with SingleTickerProviderStateMixin {
  late final AnimationController
  animationController;

  late final Animation<Offset>
  slideAnimation;

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(
            seconds: 20,
          ),
        );

    slideAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: const Offset(-1.2, 0),
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.linear,
      ),
    );

    animationController.repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius:
        BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: double.infinity,
            alignment: Alignment.center,
            decoration:
            const BoxDecoration(
              color: Color(0xFFFEF3C7),
              borderRadius:
              BorderRadius.only(
                topLeft:
                Radius.circular(7),
                bottomLeft:
                Radius.circular(7),
              ),
            ),
            child: const Icon(
              Icons.campaign_outlined,
              color: Color(0xFFD97706),
              size: 16,
            ),
          ),
          Expanded(
            child: ClipRect(
              child: SlideTransition(
                position: slideAnimation,
                child: const Row(
                  mainAxisSize:
                  MainAxisSize.max,
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceAround,
                  children: [
                    DashboardRunningTextItem(),
                    DashboardRunningTextItem(),
                    DashboardRunningTextItem(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardRunningTextItem
    extends StatelessWidget {
  const DashboardRunningTextItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 4,
          decoration:
          const BoxDecoration(
            color: Color(0xFFD97706),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Maksimal submit DOP di jam 16:00 ! ! !',
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            color: Color(0xFF92400E),
            fontSize: 11,
            height: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 30),
      ],
    );
  }
}