import 'package:fitness/features/dashboard/models/plan_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class PlanDetailsScreen extends StatelessWidget {
  const PlanDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PlanModel plan = Get.arguments as PlanModel;

    return Scaffold(
      appBar: AppBar(title: Text(plan.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type', style: Theme.of(context).textTheme.titleMedium),
            Text(plan.type.capitalizeFirst!, style: const TextStyle(color: Color(0xFF001F3F))),
            const SizedBox(height: 16),
            Text('Description', style: Theme.of(context).textTheme.titleMedium),
            Text(plan.description, style: const TextStyle(color: Color(0xFF001F3F))),
            const SizedBox(height: 16),
            Text('Duration', style: Theme.of(context).textTheme.titleMedium),
            Text('${plan.duration} weeks', style: const TextStyle(color: Color(0xFF001F3F))),
            const SizedBox(height: 16),
            Text('Frequency', style: Theme.of(context).textTheme.titleMedium),
            Text(plan.frequency.capitalizeFirst!, style: const TextStyle(color: Color(0xFF001F3F))),
            const SizedBox(height: 16),
            Text('Goals', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8.0,
              children: plan.goals
                  .map((goal) => Chip(
                        label: Text(goal, style: const TextStyle(color: Color(0xFF001F3F))),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('Media', style: Theme.of(context).textTheme.titleMedium),
            if (plan.media.isEmpty)
              const Text('No media available', style: TextStyle(color: Color(0xFF001F3F)))
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: plan.media.length,
                itemBuilder: (context, index) {
                  final media = plan.media[index];
                  if (media['type'] == 'image') {
                    return Image.network(
                      media['url']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error, color: Colors.red),
                    );
                  } else {
                    return VideoPlayerWidget(url: media['url']!);
                  }
                },
              ),
            const SizedBox(height: 16),
            Text('Created', style: Theme.of(context).textTheme.titleMedium),
            Text(
              DateFormat('yyyy-MM-dd').format(plan.createdAt.toDate()),
              style: const TextStyle(color: Color(0xFF001F3F)),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({super.key, required this.url});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? GestureDetector(
            onTap: () {
              setState(() {
                _controller.value.isPlaying ? _controller.pause() : _controller.play();
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                if (!_controller.value.isPlaying)
                  const Icon(Icons.play_circle, color: Colors.white, size: 50),
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
}