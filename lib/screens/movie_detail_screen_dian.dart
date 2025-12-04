import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service_azka.dart';
import '../controllers/booking_controller_nadif.dart';
import '../widgets/movie_card_dian.dart';
import 'movie_detail_screen_dian.dart';
import 'profile_screen_nadif.dart';
import '../utils/constants.dart';

class HomeScreenDian extends StatefulWidget {
  const HomeScreenDian({super.key});

  @override
  State<HomeScreenDian> createState() => _HomeScreenDianState();
}

class _HomeScreenDianState extends State<HomeScreenDian> {
  final FirebaseServiceAzka _firebaseService = FirebaseServiceAzka();
  List<dynamic> _movies = [];
  bool _isLoading = true;
  String? _error;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final movies = await _firebaseService.getMovies();
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
      
      final user = _firebaseService.getCurrentUser();
      if (user != null) {
        final userData = await _firebaseService.getUserData(user.uid);
        setState(() {
          _username = userData?.username ?? 'User';
        });
        
        final controller = Provider.of<BookingControllerNadif>(context, listen: false);
        controller.setCurrentUserId(user.uid);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load movies';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await _loadData();
  }

  void _navigateToDetail(String movieId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailScreenDian(movieId: movieId),
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreenNadif()),
    );
  }

  Future<void> _logout() async {
    final controller = Provider.of<BookingControllerNadif>(context, listen: false);
    await _firebaseService.logoutUser();
    controller.resetAll();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.netflixBlack, AppColors.netflixDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${_username?.split(' ')[0] ?? 'User'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Consumer<BookingControllerNadif>(
                builder: (context, controller, _) {
                  final totalSpent = controller.userBookings.fold(
                    0, (sum, b) => sum + b.totalPrice
                  );
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${controller.userBookings.length} bookings',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.netflixLightGrey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Rp $totalSpent spent',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.netflixLightGrey,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.person, color: Colors.white),
                onPressed: _navigateToProfile,
                tooltip: 'Profile',
                iconSize: 24,
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: _logout,
                tooltip: 'Logout',
                iconSize: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoviesGrid() {
    if (_movies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.movie_outlined,
              size: 60,
              color: AppColors.netflixLightGrey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No movies available',
              style: TextStyle(color: AppColors.netflixLightGrey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.netflixRed,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62, // OPTIMAL UNTUK CARD KECIL
      ),
      itemCount: _movies.length,
      itemBuilder: (_, index) {
        final movie = _movies[index];
        return Hero(
          tag: 'movie-${movie.movieId}',
          child: MovieCardDian(
            movie: movie,
            onTap: () => _navigateToDetail(movie.movieId),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.netflixDark,
      body: SafeArea(
        child: Column(
          children: [
            /// App Bar
            Container(
              color: AppColors.netflixBlack,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CINEBOOKING',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.netflixRed,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _refreshData,
                        tooltip: 'Refresh',
                        iconSize: 24,
                      ),
                      Consumer<BookingControllerNadif>(
                        builder: (context, controller, _) {
                          if (controller.userBookings.isEmpty) return const SizedBox();
                          return Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.confirmation_number, color: Colors.white),
                                onPressed: _navigateToProfile,
                                tooltip: 'My Bookings',
                                iconSize: 24,
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: AppColors.netflixRed,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '${controller.userBookings.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// User Header
            _buildHeader(),

            /// Movies Grid
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.netflixRed,
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 60,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  _error!,
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _refreshData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.netflixRed,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.netflixRed,
                          onRefresh: _refreshData,
                          child: _buildMoviesGrid(),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: _movies.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                if (_movies.isNotEmpty) {
                  _navigateToDetail(_movies[0].movieId);
                }
              },
              backgroundColor: AppColors.netflixRed,
              icon: const Icon(Icons.movie),
              label: const Text('Book Now'),
              heroTag: 'book-now-fab',
            )
          : null,
    );
  }
}