import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/contact_map_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _controller = PageController();
  Map<String, dynamic>? _info;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final info = await ApiService.getCafeInfo();
      setState(() {
        _info = info;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final info = _info ?? {};

    return Scaffold(
      body: PageView(
        controller: _controller,
        scrollDirection: Axis.vertical,
        physics: const PageScrollPhysics(),
        children: [
          SizedBox.expand(child: _HeroSection()),
          SizedBox.expand(child: _PhotoGrid()),
          SizedBox.expand(child: _InfoSection(info: info)),
          SizedBox.expand(child: _ContactSection(info: info)),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.charcoal, width: 4),
      ),
      child: Image.asset(
        'assets/images/laboratorium.jpg',
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (_, _, _) => Container(
          color: AppTheme.charcoal,
          child: const Center(
            child: Text(
              '[ hero image placeholder ]',
              style: TextStyle(color: AppTheme.gray),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  final List<String> imagePaths = const [
    'assets/images/cafe/1.png',
    'assets/images/cafe/2.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.offWhite,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('THE SPACE', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: imagePaths
                  .map(
                    (path) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8, right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.charcoal,
                            width: 4,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppTheme.charcoal,
                              offset: Offset(6, 6),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: SizedBox.expand(
                          child: Image.asset(path, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final Map<String, dynamic> info;
  const _InfoSection({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.offWhite,
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(thickness: 3, color: AppTheme.charcoal),
            const SizedBox(height: 16),
            Text('ABOUT US', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              info['about'] ?? '',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 40),
            Text(
              'PAST EVENTS',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.burgundy,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(height: 400, child: _PastEventsCarousel()),
          ],
        ),
      ),
    );
  }
}

class _PastEventsCarousel extends StatefulWidget {
  const _PastEventsCarousel();

  @override
  State<_PastEventsCarousel> createState() => _PastEventsCarouselState();
}

class _PastEventsCarouselState extends State<_PastEventsCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;

  final List<Map<String, dynamic>> pastEvents = const [
    {
      'image': 'assets/images/past_events/event1.jpg',
      'title': 'Luzer Fest',
      'date': 'February 7, 2026',
      'description': 'An evening of music with local artists',
    },
    {
      'image': 'assets/images/past_events/event2.jpg',
      'title': 'Twin Peaks Night',
      'date': 'February 24, 2026',
      'description': 'Wine and music public event',
    },
    {
      'image': 'assets/images/past_events/event3.jpg',
      'title': 'Origamy Workshop',
      'date': 'February 27, 2026',
      'description':
          'Workshop: learn the art of origamy - by the Japanese embassy',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemCount: pastEvents.length,
          itemBuilder: (context, index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: EdgeInsets.symmetric(
                horizontal: _currentPage == index ? 0 : 8,
                vertical: _currentPage == index ? 0 : 16,
              ),
              child: _PastEventCard(event: pastEvents[index]),
            );
          },
        ),
        Positioned(
          left: 0,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.charcoal.withAlpha(125),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.chevron_left,
                color: AppTheme.white,
                size: 32,
              ),
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        ),
        Positioned(
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.charcoal.withAlpha(125),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.chevron_right,
                color: AppTheme.white,
                size: 32,
              ),
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pastEvents.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 12 : 8,
                height: _currentPage == index ? 12 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? AppTheme.burgundy
                      : AppTheme.gray,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PastEventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const _PastEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            event['image'],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppTheme.charcoal,
              child: const Center(
                child: Icon(Icons.broken_image, color: AppTheme.gray, size: 48),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withAlpha(180)],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(150),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    event['title'],
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(150),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    event['date'],
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(150),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    event['description'],
                    style: const TextStyle(color: AppTheme.white, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  final Map<String, dynamic> info;
  const _ContactSection({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.charcoal,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONTACT',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: AppTheme.white),
                ),
                const SizedBox(height: 32),
                _ContactRow(Icons.phone_outlined, info['phone'] ?? ''),
                const SizedBox(height: 16),
                _ContactRow(Icons.email_outlined, info['email'] ?? ''),
                const SizedBox(height: 16),
                _ContactRow(Icons.location_on_outlined, info['address'] ?? ''),
                const SizedBox(height: 16),
                _ContactRow(Icons.access_time_outlined, info['hours'] ?? ''),
              ],
            ),
          ),

          const SizedBox(width: 24),

          const Expanded(
            child: SizedBox(height: 300, child: ContactMapWidget()),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.white),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
