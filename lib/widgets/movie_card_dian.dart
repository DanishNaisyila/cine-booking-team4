import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MovieCardDian extends StatelessWidget {
  final dynamic movie;
  final VoidCallback onTap;

  const MovieCardDian({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final availableSeats = movie.availableSeats;
    final isSoldOut = availableSeats == 0;
    final isAlmostFull = availableSeats > 0 && availableSeats <= 5;

    return GestureDetector(
      onTap: isSoldOut ? null : onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.netflixGrey,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Poster Movie
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: Container(
                height: 140,
                color: AppColors.netflixGrey,
                child: movie.posterUrl != null && movie.posterUrl.isNotEmpty
                    ? Image.network(
                        movie.posterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: AppColors.netflixGrey,
                            child: const Center(
                              child: Icon(
                                Icons.movie,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: AppColors.netflixRed,
                              strokeWidth: 2,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: AppColors.netflixGrey,
                        child: const Center(
                          child: Icon(
                            Icons.movie,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
              ),
            ),

            /// Movie Info
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.netflixBlack,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Judul Film
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 34, // ✅ TAMBAHKAN constraint
                    ),
                    child: Text(
                      movie.title.length > 20
                          ? '${movie.title.substring(0, 20)}...'
                          : movie.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),

                  /// Rating + Durasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.amber, size: 12),
                          const SizedBox(width: 3),
                          Text(
                            '${movie.rating}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined,
                              color: Colors.grey, size: 12),
                          const SizedBox(width: 3),
                          Text(
                            '${movie.duration}m',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  /// Harga + Badge - FIX OVERFLOW
                  SizedBox(
                    height: 20, // ✅ TAMBAHKAN height constraint
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            'Rp ${movie.basePrice}',
                            style: const TextStyle(
                              color: AppColors.netflixRed,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        /// Badge Ketersediaan
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSoldOut
                                ? AppColors.seatSold
                                : isAlmostFull
                                    ? AppColors.warningOrange
                                    : AppColors.successGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isSoldOut ? 'SOLD OUT' : '$availableSeats left',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
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
}