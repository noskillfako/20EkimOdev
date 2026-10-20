class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';

  // Renter tabs
  static const String explore = '/explore';
  static const String popular = '/popular';
  static const String myRentals = '/my-rentals';

  // Owner tabs
  static const String myListings = '/my-listings';
  static const String incomingOffers = '/incoming-offers';
  static const String rentalHistory = '/rental-history';

  // Shared tabs
  static const String chatList = '/chats';
  static const String profile = '/profile';

  // Pushed screens
  static const String vehicleDetail = '/vehicle/:id';
  static const String chatRoom = '/chat/:id';
  static const String addVehicle = '/add-vehicle';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String gallery = '/gallery';

  // Helpers
  static String vehicleDetailPath(String id) => '/vehicle/$id';
  static String chatRoomPath(String id) => '/chat/$id';
}
