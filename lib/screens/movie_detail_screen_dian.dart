import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service_azka.dart';
import '../controllers/booking_controller_nadif.dart';
import 'seat_selection_screen_vina.dart';
import '../utils/constants.dart';

class MovieDetailScreenDian extends StatefulWidget {
  final String movieId;

  const MovieDetailScreenDian({super.key, required this.movieId});

  @override
  State<MovieDetailScreenDian> createState() => _MovieDetailScreenDianState();
}

class _MovieDetailScreenDianState extends State<MovieDetailScreenDian> {
  final FirebaseServiceAzka _firebaseService = FirebaseServiceAzka();
  dynamic _movie;
  bool _isLoading = true;
  int _availableSeats = 0;

  @override
  void initState() {
    super.initState();
    _loadMovie();
  }

  Future<void> _loadMovie() async {
    try {
      final movie = await _firebaseService.getMovieById(widget.movieId);
      if (movie != null) {
        setState(() {
          _movie = movie;
          _availableSeats = movie.availableSeats;
          _isLoading = false;
        });
        
        // Load booked seats
        final controller = Provider.of<BookingControllerNadif>(context, listen: false);
        await controller.loadBookedSeats(widget.movieId);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToSeatSelection() {
    if (_movie == null || _availableSeats <= 0) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SeatSelectionScreenVina(
          movieId: _movie.movieId,
          movieTitle: _movie.title,
          basePrice: _movie.basePrice,
        ),
      ),
    );
  }

  Widget _buildPosterSection() {
    return Stack(
      children: [
        // Poster Image
        Container(
          height: 400,
          width: double.infinity,
          color: AppColors.netflixGrey,
          child: _movie?.posterUrl != null
              ? Image.network(
                  _movie!.posterUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.netflixGrey,
                    child: const Center(
                      child: Icon(
                        Icons.movie,
                        color: Colors.white,
                        size: 100,
                      ),
                    ),
                  ),
                )
              : Container(
                  color: AppColors.netflixGrey,
                  child: const Center(
                    child: Icon(
                      Icons.movie,
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                ),
        ),

        // Gradient Overlay
        Container(
          height: 400,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
                AppColors.netflixDark,
              ],
            ),
          ),
        ),

        // Back Button
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),

        // Movie Info
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _movie?.title ?? '',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        '${_movie?.rating ?? 0}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        '${_movie?.duration ?? 0} min',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.netflixRed,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Rp ${_movie?.basePrice ?? 0}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          const Text(
            'Synopsis',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _movie?.description ?? 'No description available',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Availability
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.netflixGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Seats',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '$_availableSeats seats left',
                      style: TextStyle(
                        color: _availableSeats == 0
                            ? Colors.red
                            : _availableSeats < 10
                                ? Colors.orange
                                : Colors.green,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (_availableSeats > 0)
                  ElevatedButton.icon(
                    onPressed: _navigateToSeatSelection,
                    icon: const Icon(Icons.event_seat),
                    label: const Text('Select Seats'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.netflixRed,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.netflixDark,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.netflixRed,
              ),
            )
          : _movie == null
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
                      const Text(
                        'Movie not found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.netflixRed,
                        ),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 400,
                      flexibleSpace: FlexibleSpaceBar(
                        background: _buildPosterSection(),
                      ),
                      backgroundColor: Colors.transparent,
                      automaticallyImplyLeading: false,
                    ),
                    SliverToBoxAdapter(
                      child: _buildContentSection(),
                    ),
                  ],
                ),
    );
  }
}