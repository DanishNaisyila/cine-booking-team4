import 'package:cloud_firestore/cloud_firestore.dart';

class MovieModelAzka {
  final String movieId;
  final String title;
  final String posterUrl;
  final int basePrice;
  final double rating;
  final int duration;
  final String description;
  final List<String> bookedSeats;

  MovieModelAzka({
    required this.movieId,
    required this.title,
    required this.posterUrl,
    required this.basePrice,
    required this.rating,
    required this.duration,
    required this.description,
    this.bookedSeats = const [],
  });

  factory MovieModelAzka.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return MovieModelAzka(
      movieId: doc.id,
      title: data['title']?.toString() ?? 'Unknown Movie',
      posterUrl: data['poster_url']?.toString() ?? '',
      basePrice: (data['base_price'] as num? ?? 50000).toInt(),
      rating: (data['rating'] as num? ?? 0.0).toDouble(),
      duration: (data['duration'] as num? ?? 120).toInt(),
      description: data['description']?.toString() ?? 'No description available',
      bookedSeats: List<String>.from(data['booked_seats'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'poster_url': posterUrl,
      'base_price': basePrice,
      'rating': rating,
      'duration': duration,
      'description': description,
      'booked_seats': bookedSeats,
    };
  }
  
  int get availableSeats => 48 - bookedSeats.length;
  
  bool isSeatAvailable(String seatId) => !bookedSeats.contains(seatId);
  
  @override
  String toString() {
    return 'MovieModelAzka{movieId: $movieId, title: $title, availableSeats: $availableSeats, bookedSeats: $bookedSeats}';
  }
}

class UserModelAzka {
  final String uid;
  final String email;
  final String username;
  final DateTime createdAt;

  UserModelAzka({
    required this.uid,
    required this.email,
    required this.username,
    required this.createdAt,
  });

  factory UserModelAzka.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModelAzka(
      uid: doc.id,
      email: data['email']?.toString() ?? '',
      username: data['username']?.toString() ?? 'User',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}

class BookingModelAzka {
  final String bookingId;
  final String userId;
  final String movieId;
  final String movieTitle;
  final List<String> seats;
  final int totalPrice;
  final DateTime bookingDate;
  final String qrData;

  BookingModelAzka({
    required this.bookingId,
    required this.userId,
    required this.movieId,
    required this.movieTitle,
    required this.seats,
    required this.totalPrice,
    required this.bookingDate,
    required this.qrData,
  });

  factory BookingModelAzka.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return BookingModelAzka(
      bookingId: doc.id,
      userId: data['user_id'] ?? '',
      movieId: data['movie_id'] ?? '',
      movieTitle: data['movie_title'] ?? '',
      seats: List<String>.from(data['seats'] ?? []),
      totalPrice: data['total_price'] ?? 0,
      bookingDate: (data['booking_date'] as Timestamp).toDate(),
      qrData: data['qr_data'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'movie_id': movieId,
      'movie_title': movieTitle,
      'seats': seats,
      'total_price': totalPrice,
      'booking_date': Timestamp.fromDate(bookingDate),
      'qr_data': qrData,
    };
  }
}