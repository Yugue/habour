import 'package:flutter/material.dart';
import 'package:harbour/core/constants/app_routes.dart';
import 'package:harbour/core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Harbour',
      description:
          'Find meaningful connections with like-minded individuals who share your values and traditions.',
      icon: Icons.favorite,
    ),
    OnboardingPage(
      title: 'Your Values Matter',
      description:
          'We help you connect with people who cherish traditional values, faith, and family.',
      icon: Icons.home,
    ),
    OnboardingPage(
      title: 'Build Your Future',
      description:
          'Find someone who shares your vision for the future – from faith to family to community.',
      icon: Icons.wb_sunny,
    ),
    OnboardingPage(
      title: 'Take Control',
      description:
          'Our focused matching helps you find people who are truly compatible with your lifestyle and beliefs.',
      icon: Icons.check_circle,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page, navigate to login
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            _buildPageIndicator(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button
                  TextButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRoutes.login);
                    },
                    child: Text(
                      'Skip',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textMedium,
                      ),
                    ),
                  ),
                  // Next button
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(page.icon, size: 100, color: AppTheme.primaryBlue),
            const SizedBox(height: 40),
            Text(
              page.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              page.description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => _buildIndicator(index == _currentPage),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color:
            isActive
                ? AppTheme.primaryBlue
                : AppTheme.textLight.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });
}
