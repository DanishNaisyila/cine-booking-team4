import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie_model_all_azka.dart';

class FirebaseServiceAzka {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> registerUser({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await _db.collection('users').doc(cred.user!.uid).set({
        'email': email.trim(),
        'username': username.trim(),
        'created_at': FieldValue.serverTimestamp(),
        'balance': 0.0,
        'role': 'user',
        'status': 'active',
        'deleted': false,
        'updated_at': FieldValue.serverTimestamp(),
      });

      return cred.user;
    } catch (e) {
      print("REGISTER ERROR: $e");
      rethrow;
    }
  }

  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return cred.user;
    } catch (e) {
      print("LOGIN ERROR: $e");
      rethrow;
    }
  }

  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<UserModelAzka?> getUserData(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return UserModelAzka.fromFirestore(doc);
    } catch (e) {
      print("GET USER DATA ERROR: $e");
      return null;
    }
  }

  Future<List<MovieModelAzka>> getMovies() async {
    try {
      final snapshot = await _db.collection('movies').get();
      return snapshot.docs
          .map((doc) => MovieModelAzka.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("GET MOVIES ERROR: $e");
      return [];
    }
  }

  Future<MovieModelAzka?> getMovieById(String movieId) async {
    try {
      final doc = await _db.collection('movies').doc(movieId).get();
      if (!doc.exists) return null;
      return MovieModelAzka.fromFirestore(doc);
    } catch (e) {
      print("GET MOVIE BY ID ERROR: $e");
      return null;
    }
  }

  Future<void> createBooking(BookingModelAzka booking) async {
    try {
      await _db
          .collection('bookings')
          .doc(booking.bookingId)
          .set(booking.toFirestore());

      final movieRef = _db.collection('movies').doc(booking.movieId);
      final movieDoc = await movieRef.get();

      if (movieDoc.exists) {
        final data = movieDoc.data() as Map<String, dynamic>;
        final currentSeats = List<String>.from(data['booked_seats'] ?? []);
        final updated = [...currentSeats, ...booking.seats];
        
        final uniqueSeats = updated.toSet().toList();

        await movieRef.update({'booked_seats': uniqueSeats});
      } else {
        await movieRef.set({
          'booked_seats': booking.seats
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print("CREATE BOOKING ERROR: $e");
      rethrow;
    }
  }

  Future<List<BookingModelAzka>> getUserBookings(String userId) async {
    try {
      final snapshot = await _db
          .collection('bookings')
          .where('user_id', isEqualTo: userId)
          .orderBy('booking_date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BookingModelAzka.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("GET USER BOOKINGS ERROR: $e");
      
      if (e.toString().contains('index') || e.toString().contains('FAILED_PRECONDITION')) {
        print("Using fallback query...");
        try {
          final allSnapshot = await _db.collection('bookings').get();
          
          final userBookings = allSnapshot.docs
              .map((doc) => BookingModelAzka.fromFirestore(doc))
              .where((booking) => booking.userId == userId)
              .toList()
            ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
          
          return userBookings;
        } catch (fallbackError) {
          print("FALLBACK ERROR: $fallbackError");
          return [];
        }
      }
      
      return [];
    }
  }

  Future<List<String>> getBookedSeats(String movieId) async {
    try {
      final doc = await _db.collection('movies').doc(movieId).get();
      if (!doc.exists) return [];
      final data = doc.data() as Map<String, dynamic>;
      return List<String>.from(data['booked_seats'] ?? []);
    } catch (e) {
      print("GET BOOKED SEATS ERROR: $e");
      return [];
    }
  }

  Future<void> updateMovieBookedSeats(String movieId, List<String> bookedSeats) async {
    try {
      await _db.collection('movies').doc(movieId).update({
        'booked_seats': bookedSeats,
      });
    } catch (e) {
      print("UPDATE MOVIE BOOKED SEATS ERROR: $e");
    }
  }

  Future<void> clearAllSeats(String movieId) async {
    try {
      await _db.collection('movies').doc(movieId).update({
        'booked_seats': [],
      });
    } catch (e) {
      print("CLEAR SEATS ERROR: $e");
    }
  }
}