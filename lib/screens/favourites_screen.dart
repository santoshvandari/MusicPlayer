import 'package:flutter/material.dart';
import 'package:music/services/favorites_service.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: FutureBuilder<List<String>>(
        future: FavoritesService.getFavorites(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final favorites = snapshot.data!;
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final song = favorites[index];
              return ListTile(
                title: Text(song.split('/').last),
                onTap: () {
                  // Handle playback
                },
              );
            },
          );
        },
      ),
    );
  }
}
